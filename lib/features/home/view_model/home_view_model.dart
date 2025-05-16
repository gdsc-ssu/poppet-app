import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pet/core/api/api_service.dart';
import 'package:pet/core/network/dio_client.dart';
import 'package:record/record.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:pet/core/utils/audio_utils.dart';

part 'home_view_model.g.dart';

enum RecordingState { initial, recording, completed, uploading, uploaded }

@riverpod
class HomeViewModel extends _$HomeViewModel {
  final _audioRecorder = AudioRecorder();
  Timer? _recordingTimer;
  Timer? _elapsedTimer;
  int _fileCounter = 0;
  RecordingState _recordingState = RecordingState.initial;
  String _lastRecordingPath = '';
  int _elapsedSeconds = 0;

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
      await uploadLastRecording(); // ✅ 녹음 종료 후 업로드
    } else {
      _recordingState = RecordingState.initial;
      state = const AsyncValue.data(null);
    }
  }

  Future<bool> _requestPermissions() async {
    final micStatus = await Permission.microphone.request();
    if (!micStatus.isGranted) {
      print('❌ 마이크 권한 거부됨');
      return false;
    }

    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt < 33) {
        final storageStatus = await Permission.storage.request();
        if (!storageStatus.isGranted) {
          print('❌ 저장소 권한 거부됨');
          return false;
        }
      }
    }

    return true;
  }

  Future<void> _startRecording() async {
    _recordingTimer?.cancel();
    _elapsedTimer?.cancel();

    final hasPermission = await _requestPermissions();
    if (!hasPermission) return;

    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/recording_$_fileCounter.flac';

    try {
      await _audioRecorder.start(
        RecordConfig(
          encoder: AudioEncoder.flac,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: filePath,
      );

      _recordingState = RecordingState.recording;
      _elapsedSeconds = 0;
      state = const AsyncValue.data(null);

      print('🔴 녹음 시작: $filePath');

      _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _elapsedSeconds++;
        state = const AsyncValue.data(null);
      });

      _recordingTimer = Timer(const Duration(seconds: 58), () async {
        await _stopRecording();
        await uploadLastRecording(); // 자동 업로드
      });
    } catch (e) {
      print('❌ 녹음 시작 실패: $e');
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
          final file = File(path);
          if (await file.exists()) {
            final size = await file.length();
            print(
              '✅ 녹음 파일 저장됨: $path (${(size / 1024).toStringAsFixed(2)} KB)',
            );
          } else {
            print('❌ 녹음 파일이 존재하지 않음: $path');
          }
        }
      } catch (e) {
        print('❌ 녹음 중지 실패: $e');
      }
    }
  }

  Future<void> uploadLastRecording() async {
    if (_lastRecordingPath.isEmpty) {
      print('❌ 저장된 녹음 파일이 없습니다.');
      return;
    }

    final file = File(_lastRecordingPath);
    if (!await file.exists()) {
      print('❌ 파일이 실제로 존재하지 않습니다: $_lastRecordingPath');
      return;
    }

    try {
      _recordingState = RecordingState.uploading;
      state = const AsyncValue.data(null);

      final dio = Dio();
      final multipartFile = await MultipartFile.fromFile(
        file.path,
        filename: file.path.split('/').last,
        contentType: MediaType('audio', 'flac'),
      );

      final response = await ApiService(
        DioClient.dio,
      ).createChat(chat: [multipartFile]);

      print('✅ 서버 응답: ${response.is_success} ${response.message}');

      // 서버로부터 받은 오디오 데이터가 있으면 재생
      if (response.is_success && response.data != null) {
        await playResponseAudio(response.data);
      } else {
        _recordingState = RecordingState.uploaded;
        state = const AsyncValue.data(null);
      }
    } catch (e, st) {
      print('❌ 업로드 실패: $e\n$st');
      _recordingState = RecordingState.completed;
      state = AsyncValue.error(e, st);
    }
  }

  /// 응답에서 받은 오디오 데이터를 재생합니다
  Future<void> playResponseAudio(String? audioData) async {
    if (audioData == null || audioData.isEmpty) {
      print('❌ 재생할 오디오 데이터가 없습니다');
      return;
    }

    try {
      print('🔊 오디오 데이터 재생 시작...');

      // 오디오 재생
      await AudioUtils.playBase64Audio(audioData);

      _recordingState = RecordingState.uploaded;
      state = const AsyncValue.data(null);
      print('✅ 오디오 재생 완료');
    } catch (e, st) {
      print('❌ 오디오 재생 실패: $e\n$st');
      _recordingState = RecordingState.uploaded;
      state = const AsyncValue.data(null);
    }
  }

  // Getter들
  bool get isRecording => _recordingState == RecordingState.recording;
  bool get isCompleted => _recordingState == RecordingState.completed;
  bool get isUploading => _recordingState == RecordingState.uploading;
  bool get isUploaded => _recordingState == RecordingState.uploaded;
  RecordingState get recordingState => _recordingState;
  String get lastRecordingPath => _lastRecordingPath;

  String get elapsedTime {
    final minutes = (_elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_elapsedSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
