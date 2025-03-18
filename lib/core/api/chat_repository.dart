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

  /// ✅ 여러 FLAC 오디오 파일 업로드
  Future<ChatResponse?> uploadMultipleFlacFiles(
    List<File> flacFiles, {
    String? name,
  }) async {
    try {
      List<MultipartFile> multipartFiles = [];

      for (final file in flacFiles) {
        if (!file.existsSync()) {
          print('FLAC 파일이 존재하지 않습니다: ${file.path}');
          continue;
        }

        final fileName = file.path.split('/').last;

        // FLAC 파일을 MultipartFile로 변환
        final multipartFile = await MultipartFile.fromFile(
          file.path,
          filename: fileName,
          contentType: MediaType('audio', 'flac'), // ✅ FLAC 파일 MIME 타입 지정
        );

        multipartFiles.add(multipartFile);
      }

      if (multipartFiles.isEmpty) {
        throw Exception('업로드할 FLAC 파일이 없습니다.');
      }

      // /chats 엔드포인트를 사용하여 오디오 파일들 업로드
      final response = await _apiService.createChat(
        files: multipartFiles,
        name: name,
      );

      return response;
    } catch (e) {
      print('FLAC 파일 업로드 실패: $e');
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
        return 'audio/flac'; // ✅ FLAC MIME 타입 설정
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
