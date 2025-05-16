import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pet/core/api/api_service.dart';
import 'package:pet/core/storage/secure_storage_utils.dart';
import 'package:pet/core/provider/login_provider.dart';
import 'package:flutter/material.dart';

part 'email_repository.g.dart';

class EmailRepository {
  final ApiService _apiService;

  EmailRepository(this._apiService);

  /// 이메일 발송 주기 가져오기
  Future<int?> getEmailPeriod(String name) async {
    try {
      final response = await _apiService.getEmailPeriod();
      debugPrint('이메일 주기 응답: $response');

      // API 응답 형식: {"is_success": true, "code": 200, "message": "...", "data": {"period": 3}}
      if (response is Map<String, dynamic>) {
        // data 객체 확인
        if (response.containsKey('data') &&
            response['data'] is Map<String, dynamic>) {
          final data = response['data'] as Map<String, dynamic>;

          // period 값 확인
          if (data.containsKey('period')) {
            final period = data['period'];
            if (period is int) {
              return period;
            } else if (period is String) {
              return int.tryParse(period);
            }
          }
        }
      }

      return null;
    } catch (e) {
      debugPrint('이메일 주기 가져오기 실패: $e');
      return null;
    }
  }

  /// 이메일 발송 주기 업데이트
  Future<bool> updateEmailPeriod(String name, int period) async {
    try {
      final response = await _apiService.updateEmailPeriod(period: period);

      debugPrint('이메일 주기 업데이트 응답: $response');

      // API 응답 성공 여부 확인
      if (response is Map<String, dynamic> &&
          response.containsKey('is_success')) {
        return response['is_success'] == true;
      }

      return false;
    } catch (e) {
      debugPrint('이메일 주기 업데이트 실패: $e');
      return false;
    }
  }

  /// 사용자 이메일 가져오기
  Future<List<EmailData>?> getUserEmail() async {
    try {
      final response = await _apiService.getUserEmail();
      debugPrint('사용자 이메일 응답: $response)');

      // API 응답 형식: {"is_success": true, "code": 200, "message": "...", "data": {"email": "user@example.com"}}

      // 성공 여부 확인
      if (response.isSuccess && response.data != null) {
        return response.data;
      }

      return null;
    } catch (e) {
      debugPrint('사용자 이메일 가져오기 실패: $e');
      return null;
    }
  }

  /// 새 이메일 추가하기
  Future<bool> addEmail(String newEmail) async {
    try {
      final response = await _apiService.addEmail(data: {'newEmail': newEmail});

      debugPrint('이메일 추가 응답: $response');

      // API 응답 성공 여부 확인
      if (response is Map<String, dynamic> &&
          response.containsKey('is_success')) {
        return response['is_success'] == true;
      }

      return false;
    } catch (e) {
      debugPrint('이메일 추가 실패: $e');
      return false;
    }
  }

  Future<bool> deleteUserEmail({required int id}) async {
    try {
      final response = await _apiService.deleteUserEmail(id: id);
      debugPrint('이메일 삭제 응답: $response');

      // API 응답 성공 여부 확인
      return response.isSuccess;
    } catch (e) {
      debugPrint('이메일 삭제 실패: $e');
      return false;
    }
  }
}

@riverpod
EmailRepository emailRepository(EmailRepositoryRef ref) {
  final apiService = ref.watch(apiServiceProvider);
  return EmailRepository(apiService);
}

class EmailData {
  final int emailId;
  final String emailAddress;

  EmailData({required this.emailId, required this.emailAddress});

  factory EmailData.fromJson(Map<String, dynamic> json) {
    return EmailData(
      emailId: json['emailId'],
      emailAddress: json['emailAddress'],
    );
  }
  @override
  String toString() =>
      'EmailData(emailId: $emailId, emailAddress: $emailAddress)';
}

class EmailResponse {
  final bool isSuccess;
  final int code;
  final String message;
  final List<EmailData> data;

  EmailResponse({
    required this.isSuccess,
    required this.code,
    required this.message,
    required this.data,
  });

  factory EmailResponse.fromJson(Map<String, dynamic> json) {
    return EmailResponse(
      isSuccess: json['is_success'],
      code: json['code'],
      message: json['message'],
      data: List<EmailData>.from(
        (json['data'] as List).map((e) => EmailData.fromJson(e)),
      ),
    );
  }
  @override
  String toString() =>
      'EmailResponse(isSuccess: $isSuccess, code: $code, message: $message, data: $data)';
}
