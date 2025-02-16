import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/models/user_model.dart';
import '../data/repositories/auth_repository.dart';

part 'login_view_model.g.dart';

@riverpod
class LoginViewModel extends _$LoginViewModel {
  @override
  FutureOr<UserModel?> build() {
    return null;
  }
}
