import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_view_model.g.dart';

@riverpod
class HomeViewModel extends _$HomeViewModel {
  final _audioRecorder = AudioRecorder();
  Timer? _silenceTimer;
  Timer? _recordingTimer;
  Timer? _elapsedTimer;
  StreamSubscription? _amplitudeSubscription;
  int _fileCounter = 0;
  bool _isRecording = false;
  String _lastRecordingPath = '';
  int _elapsedSeconds = 0;

  @override
  Future<void> build() async {
    ref.onDispose(() {
      _silenceTimer?.cancel();
      _recordingTimer?.cancel();
      _elapsedTimer?.cancel();
      _amplitudeSubscription?.cancel();
      _audioRecorder.dispose();
    });
  }

  Future<void> toggleRecording() async {
    if (!_isRecording) {
      await _startRecording();
    } else {
      await _stopRecording();
    }
  }

  Future<void> requestMicrophonePermission() async {
    PermissionStatus status = await Permission.microphone.status;
    if (status.isDenied) {
      // We didn't ask for permission yet or the permission has been denied before but not permanently.
      await Permission.microphone.request();
    }
  }

  Future<void> _startRecording() async {
    // 기존 타이머와 스트림 취소
    _silenceTimer?.cancel();
    _recordingTimer?.cancel();
    _elapsedTimer?.cancel();
    _amplitudeSubscription?.cancel();

    await requestMicrophonePermission();
    final micStatus = await Permission.microphone.request();
    final storageStatus = await Permission.storage.request();

    if (micStatus != PermissionStatus.granted) {
      print('Microphone permission not granted');
      return;
    }

    if (storageStatus != PermissionStatus.granted) {
      print('Storage permission not granted');
      return;
    }

    final path = '/Users/junha/recording_${_fileCounter}.flac';

    try {
      await _audioRecorder.start(
        RecordConfig(
          encoder: AudioEncoder.flac,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: path,
      );

      _isRecording = true;
      _elapsedSeconds = 0;
      state = const AsyncValue.data(null);

      // 경과 시간 타이머 시작
      _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _elapsedSeconds++;
        state = const AsyncValue.data(null);
      });

      // 58초 타이머 시작
      _recordingTimer = Timer(const Duration(seconds: 58), () async {
        await _stopRecording();
        await _startRecording(); // 새로운 녹음 시작
      });

      // 음성 감지 모니터링 시작
      _startSilenceDetection();
    } catch (e) {
      print('Recording error: $e');
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> _stopRecording() async {
    _silenceTimer?.cancel();
    _recordingTimer?.cancel();
    _elapsedTimer?.cancel();
    _amplitudeSubscription?.cancel();

    if (_isRecording) {
      try {
        final path = await _audioRecorder.stop();
        _isRecording = false;
        _fileCounter++;
        _elapsedSeconds = 0;
        state = const AsyncValue.data(null);

        if (path != null) {
          _lastRecordingPath = path;
          print('Recording saved at: $path');
        }
      } catch (e) {
        print('Stop recording error: $e');
      }
    }
  }

  void _startSilenceDetection() {
    _amplitudeSubscription?.cancel();
    _amplitudeSubscription = _audioRecorder
        .onAmplitudeChanged(const Duration(milliseconds: 100))
        .listen((amp) {
          if (amp.current < 1) {
            // 무음 감지 임계값
            _silenceTimer?.cancel();
            _silenceTimer = Timer(const Duration(seconds: 1), () {
              _stopRecording();
            });
          } else {
            _silenceTimer?.cancel();
          }
        });
  }

  bool get isRecording => _isRecording;
  String get lastRecordingPath => _lastRecordingPath;
  String get elapsedTime {
    final minutes = (_elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_elapsedSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
