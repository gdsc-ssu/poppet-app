import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pet/core/api/chat_repository.dart';
import 'package:pet/core/api/models/chat_response.dart';
import 'package:pet/core/provider/login_provider.dart';

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
  final List<File> _recordingFiles = [];
  int _elapsedSeconds = 0;
  ChatResponse? _lastChatResponse;

  ChatRepository get _chatRepository => ref.read(chatRepositoryProvider);

  @override
  Future<void> build() async {
    ref.onDispose(() {
      _recordingTimer?.cancel();
      _elapsedTimer?.cancel();
      _audioRecorder.dispose();
      _cleanupTempFiles();
    });
  }

  // 임시 파일 정리
  void _cleanupTempFiles() {
    for (final file in _recordingFiles) {
      if (file.existsSync()) {
        try {
          file.deleteSync();
        } catch (e) {
          print('임시 파일 삭제 실패: $e');
        }
      }
    }
  }

  Future<void> toggleRecording() async {
    if (_recordingState == RecordingState.initial) {
      await _startRecording();
    } else if (_recordingState == RecordingState.recording) {
      await _stopRecording();
    } else {
      // 녹음 완료 상태에서 다시 초기 상태로 돌아감
      _recordingState = RecordingState.initial;
      _recordingFiles.clear();
      state = const AsyncValue.data(null);
    }
  }

  Future<void> requestMicrophonePermission() async {
    PermissionStatus status = await Permission.microphone.status;
    if (status.isDenied) {
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

    // 임시 디렉토리 가져오기
    final tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}/recording_$_fileCounter.flac';

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
        final filePath = await _audioRecorder.stop();
        _recordingState = RecordingState.completed;
        _fileCounter++;
        _elapsedSeconds = 0;
        state = const AsyncValue.data(null);

        if (filePath != null) {
          final recordedFile = File(filePath);
          _recordingFiles.add(recordedFile);
          print('Recording saved at: $filePath');

          // 녹음 파일 업로드
          await _uploadRecordings();
        }
      } catch (e) {
        print('Stop recording error: $e');
      }
    }
  }

  Future<void> _uploadRecordings() async {
    if (_recordingFiles.isEmpty) {
      print('업로드할 녹음 파일이 없습니다.');
      return;
    }

    try {
      _recordingState = RecordingState.uploading;
      state = const AsyncValue.data(null);

      // 로그인한 사용자 이름 가져오기
      final loginInfo = ref.read(loginInfoProvider);
      final userName = loginInfo?.name;

      print('카카오 로그인 정보: $userName, 파일 수: ${_recordingFiles.length}');

      // 여러 FLAC 오디오 파일 업로드
      final response = await _chatRepository.uploadMultipleFlacFiles(
        _recordingFiles,
        name: userName,
      );

      if (response != null) {
        _lastChatResponse = response;
        _recordingState = RecordingState.uploaded;
        print('Audio uploaded successfully: ${response.message}');

        // 업로드 성공 후 임시 파일 정리
        _cleanupTempFiles();
        _recordingFiles.clear();
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
  List<File> get recordingFiles => List.unmodifiable(_recordingFiles);
  ChatResponse? get lastChatResponse => _lastChatResponse;
  String get elapsedTime {
    final minutes = (_elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_elapsedSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
