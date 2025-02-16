import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/app_storage.dart';
import '../models/user_model.dart';
import 'auth_client.dart';

part 'auth_repository.g.dart';

class AuthRepository {
  final AuthClient _authClient;
  final AppStorage _storage;

  AuthRepository(this._authClient, this._storage);

  Future<UserModel> login(String email, String password) async {
    final response = await _authClient.login({
      'email': email,
      'password': password,
    });

    // Save user data to local storage
    await _storage.saveUserId(response.id);
    // You might want to save token here if your API returns one

    return response;
  }

  Future<UserModel> register(String email, String password, String name) async {
    final response = await _authClient.register({
      'email': email,
      'password': password,
      'name': name,
    });

    return response;
  }

  Future<UserModel> getProfile() async {
    return await _authClient.getProfile();
  }

  Future<UserModel> updateProfile(String name, String? profileImage) async {
    final response = await _authClient.updateProfile({
      'name': name,
      if (profileImage != null) 'profile_image': profileImage,
    });

    return response;
  }

  Future<void> logout() async {
    await _storage.clearAll();
  }
}

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  final dio = ref.watch(dioClientProvider);
  final storage = ref.watch(appStorageProvider).value!;
  final authClient = AuthClient(dio);

  return AuthRepository(authClient, storage);
}
