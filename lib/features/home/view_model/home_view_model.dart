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
import 'package:flutter_riverpod/flutter_riverpod.dart';
part 'home_view_model.g.dart';



enum RecordingState { initial, recording, completed, uploading, uploaded }

final recordingStateProvider = StateProvider<RecordingState>((ref) => RecordingState.initial);
@riverpod
class HomeViewModel extends _$HomeViewModel {
  final _audioRecorder = AudioRecorder();
  Timer? _recordingTimer;
  Timer? _elapsedTimer;
  int _fileCounter = 0;
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
    final stateRef = ref.read(recordingStateProvider.notifier);
    final current = ref.read(recordingStateProvider);

    if (current == RecordingState.initial) {
      await _startRecording();
    } else if (current == RecordingState.recording) {
      await _stopRecording();
      await uploadLastRecording();
    } else {
      stateRef.state = RecordingState.initial;
    }
  }

  Future<bool> _requestPermissions() async {
    final micStatus = await Permission.microphone.request();
    if (!micStatus.isGranted) return false;

    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt < 33) {
        final storageStatus = await Permission.storage.request();
        if (!storageStatus.isGranted) return false;
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
        RecordConfig(encoder: AudioEncoder.flac, bitRate: 128000, sampleRate: 44100),
        path: filePath,
      );

      ref.read(recordingStateProvider.notifier).state = RecordingState.recording;
      _elapsedSeconds = 0;

      _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) => _elapsedSeconds++);

      _recordingTimer = Timer(const Duration(seconds: 58), () async {
        await _stopRecording();
        await uploadLastRecording();
      });
    } catch (e) {
      print('녹음 시작 실패: $e');
    }
  }

  Future<void> _stopRecording() async {
    _recordingTimer?.cancel();
    _elapsedTimer?.cancel();

    if (ref.read(recordingStateProvider) == RecordingState.recording) {
      try {
        final path = await _audioRecorder.stop();
        ref.read(recordingStateProvider.notifier).state = RecordingState.completed;
        _fileCounter++;
        _elapsedSeconds = 0;

        if (path != null) {
          _lastRecordingPath = path;
          final file = File(path);
          if (await file.exists()) {
            final size = await file.length();
            print('녹음 저장됨: ${size / 1024} KB');
          }
        }
      } catch (e) {
        print('녹음 중지 실패: $e');
      }
    }
  }

  Future<void> uploadLastRecording() async {
    final file = File(_lastRecordingPath);
    if (!await file.exists()) return;

    ref.read(recordingStateProvider.notifier).state = RecordingState.uploading;

    try {
      final multipartFile = await MultipartFile.fromFile(
        file.path,
        filename: file.path.split('/').last,
        contentType: MediaType('audio', 'flac'),
      );

      final response = await ApiService(DioClient.dio).createChat(chat: [multipartFile]);

      print('서버 응답: ${response.is_success}');

      if (response.is_success && response.data != null) {
        ref.read(recordingStateProvider.notifier).state = RecordingState.uploaded;
        await playResponseAudio(response.data!);
      } else {
        ref.read(recordingStateProvider.notifier).state = RecordingState.uploaded;
      }
    } catch (e) {
      print('업로드 실패: $e');
      ref.read(recordingStateProvider.notifier).state = RecordingState.completed;
    }
  }

  Future<void> playResponseAudio(String audioData) async {
    

    if (audioData.isEmpty) return;

    try {
      
      await AudioUtils.playBase64Audio(audioData);
    } catch (e) {
      print('오디오 재생 실패: $e');
    } finally {

      ref.read(recordingStateProvider.notifier).state = RecordingState.initial;
    }
  }

  int get elapsedSeconds => _elapsedSeconds;
  String get elapsedTime {
    final min = (_elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final sec = (_elapsedSeconds % 60).toString().padLeft(2, '0');
    return '$min:$sec';
  }

  String get lastRecordingPath => _lastRecordingPath;
}