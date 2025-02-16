import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/custom_popup.dart';

class PrivacyPolicyContent extends StatelessWidget {
  const PrivacyPolicyContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '제1조 개인정보의 처리목적',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGrey,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            '① 정부24는 다음의 목적을 위하여 개인정보를 처리합니다. 처리하고 있는 개인정보는 다음의 목적 이외의 용도로는 이용되지 않으며, 이용 목적이 변경되는 경우에는 「개인정보 보호법」 제18조에 따라 별도의 동의를 받는 등 필요한 조치를 이행할 예정입니다.',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.darkGrey,
              height: 1.6,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'a. 1. 정부24 회원정보',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.darkGrey,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'i. 회원가입, 회원제 서비스 이용 및 제한적 본인 확인제에 따른 본인확인, 개인식별, 부정이용방지, 비인가 사용방지, 가입 의사 확인, 만 14세 미만 이용 개인정보 수집 시 법정대리인 동의여부 확인, 추후 법정대리인 본인확인, 분쟁 조정을 위한 기록보존, 불만처리 등 민원처리, 고지사항 전달 등을 목적으로 개인정보를 처리합니다.',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.darkGrey,
              height: 1.6,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'b. 2. 전자민원 신청이력(상담이력 포함)',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.darkGrey,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'i. 전자민원 신청이력(상담이력 포함)에 포함된 개인정보는 민원 처리에 관한 법률 제27조에 의거 민원 사무 처리를 위한 목적으로 민원 접수기관 및 처리기관에서 개인정보를 처리합니다.',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.darkGrey,
              height: 1.6,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'c. 3. 전자민원 증명서(신청서 및 발급물)',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.darkGrey,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'i. 전자민원 증명서(신청서 및 발급물)에 포함된 개인정보는 민원 처리에 관한 법률 제27조에 의거 민원 사무 처리를 위한 목적으로 민원 접수기관 및 처리기관에서 개인정보를 처리합니다.',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.darkGrey,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

void showPrivacyPolicy(BuildContext context) {
  showDialog(
    context: context,
    builder:
        (context) =>
            const CustomPopup(title: '개인정보처리방침', child: PrivacyPolicyContent()),
  );
}
