import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_style.dart';
import '../../../core/api/email_repository.dart';
import '../../../core/provider/login_provider.dart';
import '../view_model/email_setting_view_model.dart';

// 이메일 발송 주기를 위한 간단한 Provider
final emailFrequencyStateProvider = StateProvider<int>((ref) => 7); // 기본값 7일

class EmailFrequencyPage extends ConsumerStatefulWidget {
  const EmailFrequencyPage({Key? key}) : super(key: key);

  @override
  _EmailFrequencyPageState createState() => _EmailFrequencyPageState();
}

class _EmailFrequencyPageState extends ConsumerState<EmailFrequencyPage> {
  static const String _frequencyKey = 'email_frequency';
  int _selectedFrequency = 7; // 기본값 7일
  bool _isLoading = true; // 로딩 상태 추가

  @override
  void initState() {
    super.initState();
    // API에서 이메일 주기 가져오기
    _fetchEmailPeriod();
  }

  // API에서 이메일 주기 가져오기
  Future<void> _fetchEmailPeriod() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 로그인 정보 가져오기
      final loginInfo = ref.read(loginInfoProvider);
      if (loginInfo != null && loginInfo.name.isNotEmpty) {
        // API 호출
        final emailRepository = ref.read(emailRepositoryProvider);
        debugPrint('API 호출 시작: ${loginInfo.name}');
        final period = await emailRepository.getEmailPeriod(loginInfo.name);

        // 주기 값이 있으면 적용, 없으면 저장된 값 사용
        if (period != null) {
          debugPrint('API에서 가져온 이메일 주기: $period일');
          setState(() {
            _selectedFrequency = period;
            ref.read(emailFrequencyStateProvider.notifier).state = period;
          });
        } else {
          debugPrint('API에서 주기 값을 가져오지 못함, 로컬 저장소 사용');
          // API에서 값을 가져오지 못한 경우 로컬 저장소에서 가져오기
          _loadFrequency();
        }
      } else {
        debugPrint('로그인 정보 없음, 로컬 저장소 사용');
        // 로그인 정보가 없는 경우 로컬 저장소에서 가져오기
        _loadFrequency();
      }
    } catch (e) {
      debugPrint('이메일 주기 가져오기 오류: $e');
      // 오류 발생 시 로컬 저장소에서 가져오기
      _loadFrequency();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadFrequency() async {
    final prefs = await SharedPreferences.getInstance();
    final frequency = prefs.getInt(_frequencyKey) ?? 7;
    setState(() {
      _selectedFrequency = frequency;
    });
  }

  Future<void> _saveFrequency(int days) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_frequencyKey, days);
    ref.read(emailFrequencyStateProvider.notifier).state = days;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFF9F2), // 배경색 설정
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => context.pop(),
        ),
      ),
      body:
          _isLoading
              ? Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
              : Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16.h),
                    Text(
                      '이메일 발송 주기 입력',
                      style: AppTextStyle.pretendard_32_bold,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '대화 내역을 받을 주기를 선정해 주세요.',
                      style: AppTextStyle.pretendard_18_regular,
                    ),
                    SizedBox(height: 40.h),

                    // 발송 주기 선택 영역
                    Text('발송 주기', style: AppTextStyle.pretendard_18_medium),
                    SizedBox(height: 16.h),

                    // 주기 선택 버튼들
                    _buildButtons(),

                    Spacer(),

                    // 완료 버튼
                    GestureDetector(
                      onTap: () async {
                        try {
                          // 로딩 상태 표시
                          setState(() {
                            _isLoading = true;
                          });

                          // 로그인 정보 가져오기
                          final loginInfo = ref.read(loginInfoProvider);
                          if (loginInfo != null && loginInfo.name.isNotEmpty) {
                            // API를 통해 선택된 주기 서버에 업데이트
                            final emailRepository = ref.read(
                              emailRepositoryProvider,
                            );
                            final success = await emailRepository
                                .updateEmailPeriod(
                                  loginInfo.name,
                                  _selectedFrequency,
                                );

                            if (success) {
                              debugPrint(
                                '서버에 이메일 주기 업데이트 성공: ${_selectedFrequency}일',
                              );
                            } else {
                              debugPrint('서버에 이메일 주기 업데이트 실패');
                            }
                          }

                          // 로컬에도 선택된 주기 저장
                          await _saveFrequency(_selectedFrequency);

                          // 완료 메시지 표시
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '이메일 발송 주기가 ${_selectedFrequency}일로 설정되었습니다.',
                                ),
                                backgroundColor: Color(0xFFFF6B00),
                                duration: Duration(seconds: 2),
                              ),
                            );

                            // 이전 화면으로 이동
                            context.go('/mypage');
                          }
                        } catch (e) {
                          debugPrint('이메일 주기 저장 중 오류: $e');

                          // 오류 메시지 표시
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('설정 저장 중 오류가 발생했습니다.'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } finally {
                          // 로딩 상태 해제
                          if (mounted) {
                            setState(() {
                              _isLoading = false;
                            });
                          }
                        }
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(bottom: 88.h),
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        decoration: BoxDecoration(
                          color: Color(0xFFFF6B00),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Center(
                          child: Text(
                            '완료',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  // 주기 선택 버튼 위젯
  Widget _buildleftButton(BuildContext context, int days) {
    final isSelected = days == _selectedFrequency;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFrequency = days;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: isSelected ? Color.fromRGBO(248, 107, 0, 0.5) : Colors.white,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(12.r),
              topLeft: Radius.circular(12.r),
            ),
            border: Border.all(color: Colors.grey.shade300, width: 1.5),
          ),
          child: Center(
            child: Text(
              '${days}일',
              style: AppTextStyle.pretendard_24_medium.copyWith(
                color: isSelected ? Colors.white : Color(0xff333333),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildrightButton(BuildContext context, int days) {
    final isSelected = days == _selectedFrequency;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFrequency = days;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: isSelected ? Color.fromRGBO(248, 107, 0, 0.5) : Colors.white,
            borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(12.r),
              topRight: Radius.circular(12.r),
            ),
            border: Border.all(color: Colors.grey.shade300, width: 1.5),
          ),
          child: Center(
            child: Text(
              '${days}일',
              style: AppTextStyle.pretendard_24_medium.copyWith(
                color: isSelected ? Colors.white : Color(0xff333333),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildmiddleButton(BuildContext context, int days) {
    final isSelected = days == _selectedFrequency;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFrequency = days;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),

          decoration: BoxDecoration(
            color: isSelected ? Color.fromRGBO(248, 107, 0, 0.5) : Colors.white,
            border: Border(
              top: BorderSide(color: Colors.grey.shade300, width: 1.5),
              bottom: BorderSide(color: Colors.grey.shade300, width: 1.5),
            ),
          ),
          child: Center(
            child: Text(
              '${days}일',
              style: AppTextStyle.pretendard_24_medium.copyWith(
                color: isSelected ? Colors.white : Color(0xff333333),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 선택 버튼을 동적으로 생성하는 헬퍼 메서드
  Widget _buildButtons() {
    return Row(
      children: [
        _buildleftButton(context, 1),
        _buildmiddleButton(context, 3),
        _buildrightButton(context, 7),
      ],
    );
  }
}
