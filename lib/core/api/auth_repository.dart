import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pet/core/api/api_service.dart';
import 'package:pet/core/api/models/auth_response.dart';
import 'package:pet/core/api/models/user_info.dart';
import 'package:pet/core/storage/app_storage.dart';
import 'package:pet/core/network/dio_client.dart';

part 'auth_repository.g.dart';

class AuthRepository {
  final ApiService _apiService;
  final AppStorage _appStorage;

  AuthRepository(this._apiService, this._appStorage);

  Future<bool> loginWithKakao(String accessToken) async {
    try {
      final response = await _apiService.loginWithKakao({
        'accessToken': accessToken,
      });

      return true;
    } catch (e) {
      print('카카오 로그인 실패: $e');
      return false;
    }
  }

  Future<void> logout() async {
    await _appStorage.clearAll();
  }

  bool get isLoggedIn => _appStorage.getToken() != null;
}

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  final apiService = ref.watch(apiServiceProvider);
  final appStorage = ref.watch(appStorageProvider).value!;
  return AuthRepository(apiService, appStorage);
}
