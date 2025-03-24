import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_style.dart';
import '../view_model/email_setting_view_model.dart';
import '../view/email_frequency_page.dart';
import '../../../core/provider/login_provider.dart';
import '../../../core/api/email_repository.dart';

class EmailSettingPage extends ConsumerStatefulWidget {
  const EmailSettingPage({Key? key}) : super(key: key);

  @override
  _EmailSettingPageState createState() => _EmailSettingPageState();
}

class _EmailSettingPageState extends ConsumerState<EmailSettingPage> {
  final List<TextEditingController> _controllers = [TextEditingController()];
  static const int MAX_EMAIL_COUNT = 5;
  final Map<int, String> _errorMessages = {};
  bool _isButtonEnabled = false;
  bool _initialized = false;
  bool _isLoading = false;

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  void _validateEmail(int index) {
    final email = _controllers[index].text;
    setState(() {
      if (email.isEmpty) {
        _errorMessages.remove(index);
      } else if (!_isValidEmail(email)) {
        _errorMessages[index] = '이메일 형식이 올바르지 않습니다.';
      } else {
        bool isDuplicate = false;
        for (int i = 0; i < _controllers.length; i++) {
          if (i != index && _controllers[i].text == email) {
            isDuplicate = true;
            break;
          }
        }

        if (isDuplicate) {
          _errorMessages[index] = '중복된 이메일입니다.';
        } else {
          _errorMessages.remove(index);
        }
      }

      _updateButtonState();
    });
  }

  void _updateButtonState() {
    bool hasValidEmail = false;
    bool hasErrorEmail = false;

    for (int i = 0; i < _controllers.length; i++) {
      final email = _controllers[i].text;
      if (email.isNotEmpty) {
        if (_isValidEmail(email) && !_errorMessages.containsKey(i)) {
          hasValidEmail = true;
        }
        if (_errorMessages.containsKey(i)) {
          hasErrorEmail = true;
        }
      }
    }

    setState(() {
      _isButtonEnabled = hasValidEmail && !hasErrorEmail;
    });
  }

  Future<void> _fetchEmails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final loginInfo = ref.read(loginInfoProvider);
      if (loginInfo == null) {
        throw Exception('로그인 정보가 없습니다.');
      }

      final emailRepository = ref.read(emailRepositoryProvider);
      final emailList = await emailRepository.getUserEmail(loginInfo.name);

      debugPrint('이메일 응답 데이터: $emailList');

      setState(() {
        _controllers.clear(); // 기존 컨트롤러 제거
        _errorMessages.clear(); // 오류 메시지 초기화

        if (emailList != null && emailList.isNotEmpty) {
          // 이메일 목록 추가
          for (final emailData in emailList) {
            final emailAddress = emailData.emailAddress;
            if (emailAddress.isNotEmpty) {
              debugPrint('추가되는 이메일: $emailAddress');
              final controller = TextEditingController(text: emailAddress);
              _controllers.add(controller);

              // 리스너 추가
              final index = _controllers.length - 1;
              controller.addListener(() {
                _validateEmail(index);
                _updateButtonState();
              });

              // 이메일 유효성 검사
              _validateEmail(index);
            }
          }
        }

        // 컨트롤러가 비어있거나 최대 개수에 도달하지 않았다면 빈 필드 추가
        if (_controllers.isEmpty || _controllers.length < MAX_EMAIL_COUNT) {
          final controller = TextEditingController();
          _controllers.add(controller);

          final index = _controllers.length - 1;
          controller.addListener(() {
            _validateEmail(index);
            _updateButtonState();
          });
        }
      });

      _updateButtonState();
    } catch (e) {
      debugPrint('이메일 가져오기 실패: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('이메일을 가져오는데 실패했습니다.'),
          backgroundColor: Colors.red,
        ),
      );

      setState(() {
        _controllers.clear();
        _errorMessages.clear();
        final controller = TextEditingController();
        _controllers.add(controller);
        controller.addListener(() {
          _validateEmail(0);
          _updateButtonState();
        });
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _controllers.first.addListener(() {
      _validateEmail(0);
      _updateButtonState();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _fetchEmails();
      _initialized = true;
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _addEmailField() async {
    if (_controllers.length < MAX_EMAIL_COUNT) {
      final previousIndex = _controllers.length - 1;
      final previousEmail = _controllers[previousIndex].text;

      // 이전 이메일이 비어있거나 유효하지 않은 경우
      if (previousEmail.isEmpty || !_isValidEmail(previousEmail)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('먼저 유효한 이메일을 입력해주세요.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // 이메일 추가 API 호출 전에 컨트롤러 추가
      final controller = TextEditingController();
      setState(() {
        _controllers.add(controller);
      });

      try {
        final loginInfo = ref.read(loginInfoProvider);
        if (loginInfo == null) {
          throw Exception('로그인 정보가 없습니다.');
        }

        final emailRepository = ref.read(emailRepositoryProvider);
        final success = await emailRepository.addEmail(
          loginInfo.name,
          previousEmail,
        );

        if (success) {
          // 성공 시 리스너 추가
          controller.addListener(() {
            _validateEmail(_controllers.indexOf(controller));
            _updateButtonState();
          });
          _updateButtonState();
        } else {
          setState(() {
            _controllers.removeLast();
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('이메일 추가에 실패했습니다.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        debugPrint('이메일 추가 중 오류 발생: $e');
        setState(() {
          _controllers.removeLast();
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('이메일 추가 중 오류가 발생했습니다.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _removeEmailField(int index) {
    if (_controllers.length > 1 && index > 0) {
      setState(() {
        _controllers[index].dispose();
        _controllers.removeAt(index);
        _errorMessages.remove(index);
        final newErrorMessages = <int, String>{};
        _errorMessages.forEach((key, value) {
          if (key > index) {
            newErrorMessages[key - 1] = value;
          } else if (key < index) {
            newErrorMessages[key] = value;
          }
        });
        _errorMessages.clear();
        _errorMessages.addAll(newErrorMessages);
        _updateButtonState();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F2),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 24.h),
            Text('이메일 입력', style: AppTextStyle.pretendard_32_bold),
            SizedBox(height: 4.h),
            Text(
              '보호자의 이메일을 입력해주세요.\n사용자의 대화 내역을 전달받을 수 있습니다.',
              style: AppTextStyle.pretendard_18_regular,
            ),
            SizedBox(height: 32.h),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    for (int i = 0; i < _controllers.length; i++)
                      Column(
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextFormField(
                                    controller: _controllers[i],
                                    keyboardType: TextInputType.emailAddress,
                                    onChanged: (_) => _validateEmail(i),
                                    decoration: InputDecoration(
                                      hintText:
                                          _controllers[i].text.isEmpty
                                              ? '이메일을 입력해주세요'
                                              : null,
                                      hintStyle: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16.w,
                                        vertical: 15.h,
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
                                        borderSide: BorderSide(
                                          color:
                                              _errorMessages.containsKey(i)
                                                  ? Colors.red
                                                  : const Color(0xFFFB6B00),
                                          width: 1.5.w,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
                                        borderSide: BorderSide(
                                          color:
                                              _errorMessages.containsKey(i)
                                                  ? Colors.red
                                                  : const Color(0xFFFB6B00),
                                          width: 1.5.w,
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (_errorMessages.containsKey(i))
                                    Padding(
                                      padding: EdgeInsets.only(
                                        top: 4.h,
                                        left: 8.w,
                                      ),
                                      child: Text(
                                        _errorMessages[i]!,
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 12.sp,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              if (i > 0)
                                Positioned(
                                  top: -8.h,
                                  right: -8.w,
                                  child: GestureDetector(
                                    onTap: () => _removeEmailField(i),
                                    behavior: HitTestBehavior.opaque,
                                    child: Container(
                                      width: 20.w,
                                      height: 20.h,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.2,
                                            ),
                                            blurRadius: 3,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.close,
                                          size: 16,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 26.h),
                        ],
                      ),
                    if (_controllers.length < MAX_EMAIL_COUNT)
                      GestureDetector(
                        onTap: _addEmailField,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          margin: EdgeInsets.only(bottom: 16.h),
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFBB279),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 24.sp,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap:
                  _isButtonEnabled
                      ? () {
                        List<String> validEmails = [];
                        for (var controller in _controllers) {
                          if (controller.text.isNotEmpty &&
                              _isValidEmail(controller.text)) {
                            validEmails.add(controller.text);
                          }
                        }

                        if (validEmails.isNotEmpty) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EmailFrequencyPage(),
                            ),
                          );
                        }
                      }
                      : null,
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 329.w,
                margin: EdgeInsets.only(bottom: 88.h),
                padding: EdgeInsets.symmetric(vertical: 16.h),
                decoration: BoxDecoration(
                  color:
                      _isButtonEnabled ? const Color(0xFFFF6B00) : Colors.grey,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: Text(
                    '다음',
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
}
