import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_style.dart';
import '../view_model/email_setting_view_model.dart';

class EmailSettingPage extends ConsumerStatefulWidget {
  const EmailSettingPage({Key? key}) : super(key: key);

  @override
  _EmailSettingPageState createState() => _EmailSettingPageState();
}

class _EmailSettingPageState extends ConsumerState<EmailSettingPage> {
  final List<TextEditingController> _controllers = [TextEditingController()];
  static const int MAX_EMAIL_COUNT = 5;
  final Map<int, String> _errorMessages = {};

  // 이메일 유효성 검사 함수
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  // 중복 이메일 확인 함수
  bool _hasDuplicateEmails(List<String> emails) {
    final uniqueEmails = emails.toSet();
    return uniqueEmails.length != emails.length;
  }

  // 이메일 유효성 검사 및 에러 메시지 업데이트
  void _validateEmail(int index) {
    final email = _controllers[index].text;
    setState(() {
      if (email.isEmpty) {
        _errorMessages.remove(index);
      } else if (!_isValidEmail(email)) {
        _errorMessages[index] = '이메일 형식이 올바르지 않습니다.';
      } else {
        // 중복 이메일 확인
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
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addEmailField() {
    if (_controllers.length < MAX_EMAIL_COUNT) {
      setState(() {
        _controllers.add(TextEditingController());
      });
    }
  }

  void _removeEmailField(int index) {
    if (_controllers.length > 1 && index > 0) {
      setState(() {
        _controllers[index].dispose();
        _controllers.removeAt(index);
        // 에러 메시지도 함께 제거
        _errorMessages.remove(index);
        // 인덱스 재조정
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
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final emails = ref.watch(emailSettingProvider);
    final emailNotifier = ref.read(emailSettingProvider.notifier);

    return Scaffold(
      backgroundColor: Color(0xFFFFF9F2), // 배경색 설정
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: Text(
          '이메일 입력',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.h),
            Text(
              '보호자의 이메일을 입력해주세요.',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              '사용자의 대화 내역을 전달받을 수 있습니다. (최대 5개)',
              style: TextStyle(fontSize: 14.sp, color: Colors.black54),
            ),
            SizedBox(height: 24.h),

            // 이메일 입력 필드들과 추가 버튼을 포함하는 영역
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // 이메일 입력 필드들
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
                                      hintText: '이메일을 입력해주세요',
                                      hintStyle: TextStyle(color: Colors.grey),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16.w,
                                        vertical: 18.h,
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
                                                  : Color(0xFFFB6B00),
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
                                                  : Color(0xFFFB6B00),
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
                                    onTap: () {
                                      _removeEmailField(i);
                                    },
                                    behavior: HitTestBehavior.opaque,
                                    child: Container(
                                      width: 20.w,
                                      height: 20.h,
                                      child: Container(
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
                                        child: Center(
                                          child: Icon(
                                            Icons.close,
                                            size: 16.sp,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 32.h),
                        ],
                      ),

                    // 이메일 추가 버튼
                    if (_controllers.length < MAX_EMAIL_COUNT)
                      GestureDetector(
                        onTap: _addEmailField,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          margin: EdgeInsets.only(bottom: 16.h),
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          decoration: BoxDecoration(
                            color: Color(0xFFFBB279),
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

            // 다음 버튼
            GestureDetector(
              onTap: () {
                // 유효성 검사 에러가 있는지 확인
                bool hasErrors = _errorMessages.isNotEmpty;

                // 에러가 있으면 클릭 무시
                if (hasErrors) {
                  return;
                }

                // 이메일 저장 및 다음 화면으로 이동
                List<String> validEmails = [];
                for (var controller in _controllers) {
                  if (controller.text.isNotEmpty &&
                      _isValidEmail(controller.text)) {
                    validEmails.add(controller.text);
                  }
                }

                if (validEmails.isNotEmpty) {
                  emailNotifier.saveEmails(validEmails);
                  context.pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('유효한 이메일을 입력해주세요.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 329.w,
                margin: EdgeInsets.only(bottom: 88.h),
                padding: EdgeInsets.symmetric(vertical: 16.h),
                decoration: BoxDecoration(
                  color:
                      _errorMessages.isNotEmpty
                          ? Colors.grey
                          : Color(0xFFFF6B00),
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
