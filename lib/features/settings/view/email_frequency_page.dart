import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_style.dart';
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

  @override
  void initState() {
    super.initState();
    // 저장된 주기 값 불러오기
    _loadFrequency();
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
        title: Text(
          '이메일 발송 주기 입력',
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
              '대화 내역을 받을 주기를 선정해 주세요.',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 24.h),

            // 발송 주기 선택 영역
            Text(
              '발송 주기',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 16.h),

            // 주기 선택 버튼들
            Row(
              children: [
                _buildleftButton(context, 1),

                _buildmiddleButton(context, 3),

                _buildrightButton(context, 7),
              ],
            ),

            Spacer(),

            // 완료 버튼
            GestureDetector(
              onTap: () async {
                // 선택된 주기 저장 및 이전 화면으로 이동
                await _saveFrequency(_selectedFrequency);

                // 완료 메시지 표시
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
                context.pop();
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: double.infinity,
                margin: EdgeInsets.only(bottom: 48.h),
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
          padding: EdgeInsets.symmetric(vertical: 16.h),
          decoration: BoxDecoration(
            color: isSelected ? Color(0xFFFB6B00) : Colors.white,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(12.r),
              topLeft: Radius.circular(12.r),
            ),
            border: Border.all(
              color: isSelected ? Color(0xFFFB6B00) : Colors.grey.shade300,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              '${days}일',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : Colors.black,
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
          padding: EdgeInsets.symmetric(vertical: 16.h),
          decoration: BoxDecoration(
            color: isSelected ? Color(0xFFFB6B00) : Colors.white,
            borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(12.r),
              topRight: Radius.circular(12.r),
            ),
            border: Border.all(
              color: isSelected ? Color(0xFFFB6B00) : Colors.grey.shade300,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              '${days}일',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : Colors.black,
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
          padding: EdgeInsets.symmetric(vertical: 16.h),
          decoration: BoxDecoration(
            color: isSelected ? Color(0xFFFB6B00) : Colors.white,
            border: Border(
              top: BorderSide(
                color: isSelected ? Color(0xFFFB6B00) : Colors.grey.shade300,
                width: 1.5,
              ),
              bottom: BorderSide(
                color: isSelected ? Color(0xFFFB6B00) : Colors.grey.shade300,
                width: 1.5,
              ),
            ),
          ),
          child: Center(
            child: Text(
              '${days}일',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
