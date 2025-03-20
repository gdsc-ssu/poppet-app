import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

class AudioUtils {
  /// Decodes a base64 string and plays the resulting audio directly from memory
  static Future<void> playBase64Audio(String base64Audio) async {
    try {
      print('오디오 재생 시작');

      // 데이터 정제 - 일부 base64 문자열은 앞뒤에 공백이나 특수문자가 포함될 수 있음
      String cleanBase64 = base64Audio.trim();

      // base64 데이터에서 헤더 제거(있는 경우)
      final RegExp dataUriRegExp = RegExp(r'^data:audio/\w+;base64,');
      cleanBase64 = cleanBase64.replaceAll(dataUriRegExp, '').trim();

      // base64 디코딩
      Uint8List audioBytes;
      try {
        audioBytes = base64Decode(cleanBase64);
        print('base64 디코딩 성공: ${audioBytes.length} 바이트');
      } catch (e) {
        print('base64 디코딩 오류: $e');

        audioBytes = Uint8List.fromList(utf8.encode(base64Audio));
        print('원본 데이터를 바이너리로 사용: ${audioBytes.length} 바이트');
      }

      // 메모리에서 바로 오디오 재생
      final player = AudioPlayer();
      await player.setAudioSource(MyCustomSource(audioBytes));
      print('오디오 로드 완료, 재생 시작');

      await player.play();
    } catch (e) {
      print('오디오 재생 오류: $e');
      rethrow;
    }
  }
}

/// 메모리 내 바이트 데이터를 오디오 소스로 변환하는 클래스
class MyCustomSource extends StreamAudioSource {
  final Uint8List _buffer;

  MyCustomSource(this._buffer);

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    // 요청된 범위 또는 전체 버퍼 처리
    start = start ?? 0;
    end = end ?? _buffer.length;

    return StreamAudioResponse(
      sourceLength: _buffer.length,
      contentLength: end - start,
      offset: start,
      stream: Stream.value(_buffer.sublist(start, end)),
      contentType: 'audio/mpeg', // MP3 형식으로 가정, 필요시 변경
    );
  }
}
