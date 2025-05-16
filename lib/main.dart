import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/storage/secure_storage_utils.dart';
import 'core/network/dio_client.dart';

void main() async {
  // Flutter 바인딩 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화 (직접 초기화 방식)
  await Firebase.initializeApp();

  // 카카오 SDK 초기화
  KakaoSdk.init(
    nativeAppKey: 'a1e5cdadeae290397049e5b6c51829ca',
    javaScriptAppKey: '2707b64775ef31cc6aeae01392466da6',
  );

  // 저장된 토큰 불러와 적용
  final token = await SecureStorageUtils.getAccessToken();
  if (token != null) {
    // 토큰 설정 (DioClient 내부에서 Bearer 접두사 처리)
    await DioClient.setToken(token);
    print('🔑 앱 시작 시 저장된 토큰이 설정되었습니다');
  } else {
    print('⚠️ 앱 시작 시 저장된 토큰이 없습니다');
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    requestPermissions();
  }

  Future<void> requestPermissions() async {
    await [Permission.microphone, Permission.speech].request();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);

    return ScreenUtilInit(
      designSize: const Size(393, 852),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'Poppet',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          routerConfig: router,
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
              child: child!,
            );
          },
        );
      },
    );
  }
}
