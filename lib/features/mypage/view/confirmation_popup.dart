import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_style.dart';
import '../../../shared/widgets/custom_popup.dart';

class ConfirmationPopup extends StatelessWidget {
  final String title;
  final String message;
  final String confirmButtonText;
  final String cancelButtonText;
  final VoidCallback onConfirm;

  const ConfirmationPopup({
    super.key,
    required this.title,
    required this.message,
    required this.confirmButtonText,
    this.cancelButtonText = '취소',
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPopup(
      title: title,
      titleColor: AppColors.primary,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.sp),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 8.h),
            Text(
              message,
              style: AppTextStyle.pretendard_18_regular.copyWith(
                color: AppColors.darkGrey,
                height: 1.6,
              ),
              textAlign: TextAlign.start,
            ),
            SizedBox(height: 32.h),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onConfirm();
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        side: BorderSide(color: AppColors.primary),
                      ),
                    ),
                    child: Text(
                      confirmButtonText,
                      style: AppTextStyle.pretendard_16_regular.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      cancelButtonText,
                      style: AppTextStyle.pretendard_16_regular.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }
}

void showLogoutConfirmation(BuildContext context, VoidCallback onConfirm) {
  showDialog(
    context: context,
    builder:
        (context) => ConfirmationPopup(
          title: '로그아웃',
          message: '정말 로그아웃하시겠습니까?\n언제든지 다시 로그인할 수 있어요.',
          confirmButtonText: '로그아웃',
          onConfirm: onConfirm,
        ),
  );
}

void showWithdrawalConfirmation(BuildContext context, VoidCallback onConfirm) {
  showDialog(
    context: context,
    builder:
        (context) => ConfirmationPopup(
          title: '회원탈퇴',
          message: '정말 탈퇴하시겠습니까?\n탈퇴 시 계정은 삭제되며,\n대화 내역은 복구되지 않습니다.',
          confirmButtonText: '회원탈퇴',
          onConfirm: onConfirm,
        ),
  );
}
