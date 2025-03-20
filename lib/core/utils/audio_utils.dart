import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

class AudioUtils {
  /// Decodes a base64 string and plays the resulting audio
  static Future<void> playBase64Audio(String base64Audio) async {
    try {
      print('오디오 재생 시작');

      // 데이터 정제 - 일부 base64 문자열은 앞뒤에 공백이나 특수문자가 포함될 수 있음
      String cleanBase64 = base64Audio.trim();

      // 파일 저장 및 재생
      final file = await saveBase64AudioToFile(cleanBase64);

      // 오디오 재생
      final player = AudioPlayer();
      await player.setFilePath(file.path);
      print('오디오 로드 완료, 재생 시작');
      await player.play();
    } catch (e) {
      print('오디오 재생 오류: $e');
      rethrow;
    }
  }

  /// Decodes a base64 string and returns a file
  static Future<File> saveBase64AudioToFile(
    String base64Audio, {
    String? customFileName,
  }) async {
    try {
      print('base64 데이터 디코딩 시작');

      // base64 데이터에서 헤더 제거(있는 경우)
      final RegExp dataUriRegExp = RegExp(r'^data:audio/\w+;base64,');
      final cleanBase64 = base64Audio.replaceAll(dataUriRegExp, '').trim();

      // base64 디코딩 시도
      Uint8List bytes;
      try {
        bytes = base64Decode(cleanBase64);
        print('base64 디코딩 성공: ${bytes.length} 바이트');
      } catch (e) {
        print('base64 디코딩 오류: $e');
        // 디코딩 실패시 원본 데이터를 바이너리로 직접 사용
        bytes = Uint8List.fromList(utf8.encode(base64Audio));
        print('원본 데이터를 바이너리로 사용: ${bytes.length} 바이트');
      }

      // 파일 저장
      final tempDir = await getTemporaryDirectory();
      final fileName =
          customFileName ??
          'audio_${DateTime.now().millisecondsSinceEpoch}.mp3';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(bytes);
      print('오디오 파일 저장 완료: ${file.path}');

      return file;
    } catch (e) {
      print('오디오 파일 저장 오류: $e');
      rethrow;
    }
  }
}
