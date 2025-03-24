import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pet/core/api/chat_repository.dart';
import 'package:pet/core/api/models/chat_response.dart';
import 'package:pet/core/provider/login_provider.dart';
import 'package:pet/core/utils/audio_utils.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../view/home_page.dart'; // isPlayingAudioProvider 가져오기

part 'home_view_model.g.dart';

// 녹음 상태를 나타내는 enum
enum RecordingState {
  initial, // 초기 상태 (녹음 시작 전)
  recording, // 녹음 중
  completed, // 녹음 완료
  uploading, // 업로드 중
  uploaded, // 업로드 완료
}

// ... 생략된 import는 동일합니다

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
  bool _isSegmentRecording = false;

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
      _recordingFiles.clear();
      await _startRecording();
    } else if (_recordingState == RecordingState.recording) {
      await _stopRecording(uploadImmediately: true);
    } else {
      _recordingState = RecordingState.initial;
      _recordingFiles.clear();
      state = const AsyncValue.data(null);
    }
  }

  /// ✅ 권한 요청을 통합
  Future<bool> _requestAllPermissions() async {
    final mic = await Permission.microphone.status;
    if (!mic.isGranted) {
      final micResult = await Permission.microphone.request();
      if (!micResult.isGranted) {
        print('❌ 마이크 권한이 거부됨');
        return false;
      }
    }

    // Android 13 이상이면 저장소 권한 생략 가능 (record 패키지 자체에서 저장함)
    if (Platform.isAndroid) {
      final deviceInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = deviceInfo.version.sdkInt;

      if (sdkInt < 33) {
        final storage = await Permission.storage.request();
        if (!storage.isGranted) {
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

    await _startSegmentRecording();

    _recordingState = RecordingState.recording;
    _elapsedSeconds = 0;
    state = const AsyncValue.data(null);

    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsedSeconds++;
      state = const AsyncValue.data(null);
    });
  }

  Future<void> _startSegmentRecording() async {
    if (_isSegmentRecording) return;
    _isSegmentRecording = true;

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

      _recordingTimer = Timer(const Duration(seconds: 59), () async {
        await _stopRecording(uploadImmediately: false);
        if (_recordingState == RecordingState.recording) {
          await _startSegmentRecording();
        }
      });
    } catch (e) {
      _isSegmentRecording = false;
      print('Recording error: $e');
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> _stopRecording({required bool uploadImmediately}) async {
    _recordingTimer?.cancel();

    if (_isSegmentRecording) {
      try {
        final filePath = await _audioRecorder.stop();
        _isSegmentRecording = false;
        _fileCounter++;

        if (filePath != null) {
          final recordedFile = File(filePath);
          _recordingFiles.add(recordedFile);
          print('Recording saved at: $filePath');
        }

        if (uploadImmediately) {
          _elapsedTimer?.cancel();
          _elapsedSeconds = 0;
          _recordingState = RecordingState.completed;
          state = const AsyncValue.data(null);
          await _uploadRecordings();
        }
      } catch (e) {
        _isSegmentRecording = false;
        print('Stop recording error: $e');
      }
    } else if (uploadImmediately) {
      _elapsedTimer?.cancel();
      _elapsedSeconds = 0;
      _recordingState = RecordingState.completed;
      state = const AsyncValue.data(null);
      await _uploadRecordings();
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

      int totalSize = 0;
      for (int i = 0; i < _recordingFiles.length; i++) {
        final fileSize = await _recordingFiles[i].length();
        totalSize += fileSize;
        print('파일 ${i + 1}의 크기: ${(fileSize / 1024).toStringAsFixed(2)} KB');
      }

      final loginInfo = ref.read(loginInfoProvider);
      final userName = loginInfo?.name;

      print('카카오 로그인 정보: $userName, 파일 수: ${_recordingFiles.length}');

      final response = await _chatRepository.uploadMultipleFlacFiles(
        _recordingFiles,
        name: userName,
      );

      if (response != null) {
        _lastChatResponse = response;
        print('Audio uploaded successfully: ${response.message}');

        _cleanupTempFiles();
        _recordingFiles.clear();

        if (response.data != null && response.data!.isNotEmpty) {
          try {
            ref.read(isPlayingAudioProvider.notifier).state = true;
            print('Playing audio from response data');

            await AudioUtils.playBase64Audio(response.data!);
            ref.read(isPlayingAudioProvider.notifier).state = false;
            resetToInitial();
          } catch (e) {
            ref.read(isPlayingAudioProvider.notifier).state = false;
            print('Audio playback error: $e');
          }
        } else {
          print('No audio data in response');
        }
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

  void resetToInitial() {
    _recordingState = RecordingState.initial;
    _recordingFiles.clear();
    _lastChatResponse = null;
    state = const AsyncValue.data(null);
  }

  int get recordingFilesCount => _recordingFiles.length;
}
