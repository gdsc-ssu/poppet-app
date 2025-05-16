import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pet/core/api/api_service.dart' hide ChatResponse;
import 'package:pet/core/api/models/chat_response.dart';
import 'package:pet/core/storage/secure_storage_utils.dart';
import 'package:pet/core/network/dio_client.dart';

part 'chat_repository.g.dart';

class ChatRepository {
  final ApiService _apiService;

  ChatRepository(this._apiService);

  /// ✅ 여러 오디오 파일 업로드
  Future<ChatResponse?> uploadMultipleAudioFiles(
    List<File> audioFiles, {
    String? name,
  }) async {
    try {
      print("uploadMultipleAudioFiles 시작 - 파일 수: ${audioFiles.length}");
      List<MultipartFile> multipartFiles = [];

      // 파일 목록 유효성 검사
      if (audioFiles.isEmpty) {
        print('업로드할 오디오 파일이 없습니다.');
        return null;
      }

      for (int i = 0; i < audioFiles.length; i++) {
        final file = audioFiles[i];
        if (!file.existsSync()) {
          print('오디오 파일이 존재하지 않습니다: ${file.path}');
          continue;
        }

        final fileName = file.path.split('/').last;
        print('파일 $i 변환 중: $fileName');

        try {
          // 파일 확장자 확인하여 적절한 MIME 타입 선택
          final String mimeType = _getMimeType(fileName);
          print('파일 $i MIME 타입: $mimeType');

          // 오디오 파일을 MultipartFile로 변환
          final multipartFile = await MultipartFile.fromFile(
            file.path,
            filename: fileName,
            contentType: MediaType.parse(mimeType),
          );

          multipartFiles.add(multipartFile);
          print('파일 $i 변환 완료: ${multipartFile.filename}');
        } catch (e) {
          print('파일 $i 변환 실패: $e');
        }
      }

      if (multipartFiles.isEmpty) {
        print('변환된 파일이 없습니다. 업로드를 중단합니다.');
        return null;
      }

      print('업로드 시작 - 파일 수: ${multipartFiles.length}, 사용자: $name');

      try {
        // /chats 엔드포인트를 사용하여 오디오 파일들 업로드
        final response = await _apiService.createChat(chat: multipartFiles);

        // ⚠️ 서버 응답 데이터 체크
        print("API 응답 코드: ${response.code}, 메시지: ${response.message}");
        print("서버 응답 데이터 존재 여부: ${response.data != null}");
        if (response.data == null) {
          print("응답에 오디오 데이터가 없습니다.");
        } else if (response.data!.isEmpty) {
          print("응답의 오디오 데이터가 비어 있습니다.");
        } else {
          print("응답 데이터 크기: ${response.data!.length} 바이트");
        }

        return response;
      } catch (apiError, apiStackTrace) {
        print('API 호출 중 오류 발생: $apiError');
        print('API 호출 스택 트레이스: $apiStackTrace');
        return null;
      }
    } catch (e, stackTrace) {
      print('오디오 파일 업로드 실패: $e');
      print('스택 트레이스: $stackTrace');
      return null;
    }
  }

  /// 파일 확장자에 따른 MIME 타입 반환
  String _getMimeType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'flac':
        return 'audio/flac';
      case 'aac':
        return 'audio/aac';
      case 'mp3':
        return 'audio/mpeg';
      case 'wav':
        return 'audio/wav';
      default:
        return 'application/octet-stream';
    }
  }
}

@riverpod
ChatRepository chatRepository(ChatRepositoryRef ref) {
  final apiService = ref.watch(apiServiceProvider);
  return ChatRepository(apiService);
}
