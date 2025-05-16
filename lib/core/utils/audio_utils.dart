import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

class AudioUtils {
  /// Decodes a base64 string and plays the resulting audio directly from memory
  static Future<void> playBase64Audio(String? base64Audio) async {
    try {
      print('오디오 재생 시작 시도');

      // 입력 데이터 null 또는 빈 문자열 체크
      if (base64Audio == null) {
        print('오디오 데이터가 null입니다.');
        return;
      }

      if (base64Audio.isEmpty) {
        print('오디오 데이터가 비어 있습니다.');
        return;
      }

      print('오디오 데이터 길이: ${base64Audio.length} 문자');

      // 데이터 정제 - 일부 base64 문자열은 앞뒤에 공백이나 특수문자가 포함될 수 있음
      String cleanBase64 = base64Audio.trim();
      print('공백 제거 후 데이터 길이: ${cleanBase64.length} 문자');

      // base64 데이터에서 헤더 제거(있는 경우)
      final RegExp dataUriRegExp = RegExp(r'^data:audio/\w+;base64,');
      cleanBase64 = cleanBase64.replaceAll(dataUriRegExp, '').trim();
      print('헤더 제거 후 데이터 길이: ${cleanBase64.length} 문자');

      // base64 디코딩
      Uint8List audioBytes;
      try {
        print('base64 디코딩 시도...');
        audioBytes = base64Decode(cleanBase64);
        print('base64 디코딩 성공: ${audioBytes.length} 바이트');
      } catch (e, decodingStack) {
        print('base64 디코딩 오류: $e');
        print('디코딩 스택 트레이스: $decodingStack');

        // 디코딩 오류 시 원본 데이터를 바이너리로 사용 시도
        print('원본 텍스트를 바이너리로 변환 시도...');
        try {
          audioBytes = Uint8List.fromList(utf8.encode(base64Audio));
          print('원본 데이터를 바이너리로 사용: ${audioBytes.length} 바이트');
        } catch (fallbackError) {
          print('바이너리 변환 실패: $fallbackError');
          return;
        }
      }

      // 오디오 데이터 크기 확인
      if (audioBytes.isEmpty) {
        print('디코딩된 오디오 데이터가 비어 있습니다.');
        return;
      }

      // 메모리에서 바로 오디오 재생
      print('AudioPlayer 초기화 중...');
      final player = AudioPlayer();

      try {
        print('오디오 소스 설정 중...');
        await player.setAudioSource(MyCustomSource(audioBytes));
        print('오디오 로드 완료, 재생 시작');

        await player.play();
        print('재생 명령 실행됨');
      } catch (audioError, audioStack) {
        print('오디오 재생 오류: $audioError');
        print('오디오 재생 스택 트레이스: $audioStack');

        // 재생 중 오류가 발생하면 플레이어 리소스 해제
        try {
          await player.dispose();
        } catch (disposeError) {
          print('AudioPlayer 해제 오류: $disposeError');
        }
        return;
      }
    } catch (e, stackTrace) {
      print('오디오 재생 오류: $e');
      print('스택 트레이스: $stackTrace');
      // 오류를 상위로 전파하지 않고 여기서 처리
      return;
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
