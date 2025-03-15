import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pet/core/api/api_service.dart' hide ChatResponse;
import 'package:pet/core/api/models/chat_response.dart';
import 'package:pet/core/storage/app_storage.dart';
import 'package:pet/core/network/dio_client.dart';

part 'chat_repository.g.dart';

class ChatRepository {
  final ApiService _apiService;
  final AppStorage _appStorage;

  ChatRepository(this._apiService, this._appStorage);

  /// 텍스트 메시지로 채팅 생성
  Future<ChatResponse?> createChat(
    String message, {
    List<File>? chatFiles,
  }) async {
    try {
      // 파일 처리
      String fileNames = '';
      List<MultipartFile> multipartFiles = [];

      if (chatFiles != null && chatFiles.isNotEmpty) {
        List<String> fileNamesList = [];

        for (final file in chatFiles) {
          if (file.existsSync()) {
            final fileName = file.path.split('/').last;
            fileNamesList.add(fileName);

            // 파일을 MultipartFile로 변환
            final multipartFile = await MultipartFile.fromFile(
              file.path,
              filename: fileName,
              contentType: MediaType.parse(_getMimeType(fileName)),
            );
            multipartFiles.add(multipartFile);
          }
        }

        // 파일 이름들을 쉼표로 구분하여 하나의 문자열로 합침
        fileNames = fileNamesList.join(',');
      }

      // 파일 이름은 쿼리 파라미터로, 파일 데이터는 multipart/form-data 형식으로 전송
      final response = await _apiService.createChat(
        fileNames: fileNames,
        files: multipartFiles,
      );

      return response;
    } catch (e) {
      print('채팅 생성 실패: $e');
      return null;
    }
  }

  /// 오디오 파일 업로드
  Future<ChatResponse?> uploadAudio(String audioPath) async {
    try {
      final file = File(audioPath);
      if (!file.existsSync()) {
        throw Exception('오디오 파일이 존재하지 않습니다: $audioPath');
      }

      final fileName = audioPath.split('/').last;

      // 오디오 파일을 MultipartFile로 변환
      final audioFile = await MultipartFile.fromFile(
        audioPath,
        filename: fileName,
        contentType: MediaType.parse(_getMimeType(fileName)),
      );

      // /chats 엔드포인트를 사용하여 오디오 파일 업로드
      final response = await _apiService.createChat(
        fileNames: fileName,
        files: [audioFile],
      );

      return response;
    } catch (e) {
      print('오디오 업로드 실패: $e');
      return null;
    }
  }

  /// 채팅 이름 설정
  Future<ChatResponse?> setChatName(String chatId, String name) async {
    try {
      // 로그인한 사용자 ID가 있으면 사용, 없으면 'guest' 사용
      final userId = _appStorage.getUserId() ?? 'guest';

      // URL 쿼리 파라미터 형식으로 채팅 이름 설정
      final response = await _apiService.setChatName(
        chatId: chatId,
        name: name,
        data: {'userId': userId},
      );

      return response;
    } catch (e) {
      print('채팅 이름 설정 실패: $e');
      return null;
    }
  }

  /// 채팅 업데이트
  Future<ChatResponse?> updateChat(
    String chatId,
    Map<String, dynamic> data,
  ) async {
    try {
      // 로그인한 사용자 ID가 있으면 사용, 없으면 'guest' 사용
      final userId = _appStorage.getUserId() ?? 'guest';

      // userId 추가
      data['userId'] = userId;

      final response = await _apiService.updateChat(chatId, data);

      return response;
    } catch (e) {
      print('채팅 업데이트 실패: $e');
      return null;
    }
  }

  // 파일 확장자에 따른 MIME 타입 반환
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
  final appStorage = ref.watch(appStorageProvider).value!;
  return ChatRepository(apiService, appStorage);
}
