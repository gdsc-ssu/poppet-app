import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pet/core/api/chat_repository.dart';
import 'package:pet/core/api/models/chat_response.dart';

part 'home_view_model.g.dart';

// 녹음 상태를 나타내는 enum
enum RecordingState {
  initial, // 초기 상태 (녹음 시작 전)
  recording, // 녹음 중
  completed, // 녹음 완료
  uploading, // 업로드 중
  uploaded, // 업로드 완료
}

@riverpod
class HomeViewModel extends _$HomeViewModel {
  final _audioRecorder = AudioRecorder();
  Timer? _recordingTimer;
  Timer? _elapsedTimer;
  int _fileCounter = 0;
  RecordingState _recordingState = RecordingState.initial;
  String _lastRecordingPath = '';
  int _elapsedSeconds = 0;
  ChatResponse? _lastChatResponse;

  ChatRepository get _chatRepository => ref.read(chatRepositoryProvider);

  @override
  Future<void> build() async {
    ref.onDispose(() {
      _recordingTimer?.cancel();
      _elapsedTimer?.cancel();
      _audioRecorder.dispose();
    });
  }

  Future<void> toggleRecording() async {
    if (_recordingState == RecordingState.initial) {
      await _startRecording();
    } else if (_recordingState == RecordingState.recording) {
      await _stopRecording();
    } else {
      // 녹음 완료 상태에서 다시 초기 상태로 돌아감
      _recordingState = RecordingState.initial;
      state = const AsyncValue.data(null);
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
    // 기존 타이머 취소
    _recordingTimer?.cancel();
    _elapsedTimer?.cancel();

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

      _recordingState = RecordingState.recording;
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
      });
    } catch (e) {
      print('Recording error: $e');
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> _stopRecording() async {
    _recordingTimer?.cancel();
    _elapsedTimer?.cancel();

    if (_recordingState == RecordingState.recording) {
      try {
        final path = await _audioRecorder.stop();
        _recordingState = RecordingState.completed;
        _fileCounter++;
        _elapsedSeconds = 0;
        state = const AsyncValue.data(null);

        if (path != null) {
          _lastRecordingPath = path;
          print('Recording saved at: $path');

          // 녹음 파일 업로드
          await _uploadRecording(path);
        }
      } catch (e) {
        print('Stop recording error: $e');
      }
    }
  }

  Future<void> _uploadRecording(String audioPath) async {
    try {
      _recordingState = RecordingState.uploading;
      state = const AsyncValue.data(null);

      final response = await _chatRepository.uploadAudio(audioPath);

      if (response != null) {
        _lastChatResponse = response;
        _recordingState = RecordingState.uploaded;
        print('Audio uploaded successfully: ${response.message}');
      } else {
        _recordingState = RecordingState.completed;
        print('Failed to upload audio');
      }

      state = const AsyncValue.data(null);
    } catch (e) {
      _recordingState = RecordingState.completed;
      print('Upload error: $e');
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  bool get isRecording => _recordingState == RecordingState.recording;
  bool get isCompleted => _recordingState == RecordingState.completed;
  bool get isUploading => _recordingState == RecordingState.uploading;
  bool get isUploaded => _recordingState == RecordingState.uploaded;
  RecordingState get recordingState => _recordingState;
  String get lastRecordingPath => _lastRecordingPath;
  ChatResponse? get lastChatResponse => _lastChatResponse;
  String get elapsedTime {
    final minutes = (_elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_elapsedSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
