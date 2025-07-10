import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_style.dart';
import '../../../shared/widgets/custom_popup.dart';

class TermsOfServiceContent extends StatelessWidget {
  const TermsOfServiceContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.sp, vertical: 28.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '제1장 총칙',
            style: AppTextStyle.pretendard_18_regular.copyWith(
              color: AppColors.darkGrey,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            '제1조(목적)',
            style: AppTextStyle.pretendard_16_regular.copyWith(
              color: AppColors.darkGrey,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            '본 약관은 정부24 (이하 "본 사이트")가 제공하는 모든 도메인 서비스의 이용조건 및 절차, 이용자와 본 사이트의 권리, 의무, 책임사항과 기타 필요한 사항을 규정함을 목적으로 합니다.',
            style: AppTextStyle.pretendard_14_light.copyWith(
              color: AppColors.darkGrey,
              height: 1.6,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            '제2조(용어의 정의)',
            style: AppTextStyle.pretendard_16_regular.copyWith(
              color: AppColors.darkGrey,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            '본 약관에서 사용하는 용어의 정의는 다음과 같습니다.',
            style: AppTextStyle.pretendard_14_light.copyWith(
              color: AppColors.darkGrey,
              height: 1.6,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            '① 이용자 : 본 사이트에 접속하여 본 사이트가 제공하는 서비스를 이용할 수 있는 자\n② 가입 : 본 사이트가 제공하는 신청서 양식에 해당 정보를 기재하고, 본 약관에 동의하여 서비스 이용계약을 완료하는 행위\n③ 회원 : 본 사이트에 개인정보를 제공하여 회원등록을 한 자(이하"회원"로 칭함)로서, 그 자격을 적법하게 부여받은 자로서 본 사이트의 정보를 지속적으로 제공받으며, 본 사이트가 제공하는 서비스를 이용할 수 있는 자\n④ 비밀번호 : 이용자와 회원ID가 일치하는지 를 확인하고 통신상의 자신의 비밀보호를 위하여 이용자 자신이 선정한 문자와 숫자의 조합',
            style: AppTextStyle.pretendard_14_light.copyWith(
              color: AppColors.darkGrey,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

void showTermsOfService(BuildContext context) {
  showDialog(
    context: context,
    builder:
        (context) =>
            const CustomPopup(title: '이용약관', child: TermsOfServiceContent()),
  );
}
