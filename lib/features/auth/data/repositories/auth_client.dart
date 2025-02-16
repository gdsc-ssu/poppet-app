import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/user_model.dart';

part 'auth_client.g.dart';

@RestApi()
abstract class AuthClient {
  factory AuthClient(Dio dio, {String baseUrl}) = _AuthClient;

  @POST('/auth/login')
  Future<UserModel> login(@Body() Map<String, dynamic> body);

  @POST('/auth/register')
  Future<UserModel> register(@Body() Map<String, dynamic> body);

  @GET('/auth/me')
  Future<UserModel> getProfile();

  @PUT('/auth/profile')
  Future<UserModel> updateProfile(@Body() Map<String, dynamic> body);
}
