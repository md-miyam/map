import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

ThemeData themeData() {
  return ThemeData(
    scaffoldBackgroundColor: AppColors.backGroundColor,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryColor),
    // appBarTheme
    appBarTheme: AppBarTheme(backgroundColor: AppColors.transparentColor),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 3.w),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedSuperellipseBorder(),
      ),
    ),
    // iconButtonTheme
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        padding: EdgeInsets.zero,
        highlightColor: AppColors.primaryColor.withAlpha(15),
        minimumSize: Size(32.w, 32.h),
      ),
    ),
    // elevatedButtonTheme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 19.w),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.secondaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        textStyle: AppTextStyles.semiBold14,
      ),
    ),
    // outlinedButtonTheme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.whiteColor,
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 19.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        side: BorderSide(
          color: AppColors.outLineButtonBorderColor,
          width: 1.sp,
        ),
        textStyle: AppTextStyles.semiBold14,
      ),
    ),
    // TEXT FIELD inputDecorationTheme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.textFieldBgColor,
      hintStyle: AppTextStyles.medium14.copyWith(
        color: AppColors.textFieldHinTextColor,
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: AppColors.textFieldBorderColor, width: 1.sp),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: AppColors.textFieldBorderColor, width: 1.sp),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: AppColors.textFieldBorderColor, width: 1.sp),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: AppColors.redColor ,
          width: 1.sp,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: AppColors.redColor ,
          width: 1.2.sp,
        ),
      ),

    ),
  );
}




// TextFormField(
// style: AppTextStyles.medium14.copyWith(color: AppColors.textFieldHinTextColor),
// cursorColor: AppColors.textFieldHinTextColor,
// decoration: InputDecoration(
// hintText: "Enter your email",
// hintStyle: AppTextStyles.medium14.copyWith(color: AppColors.textFieldHinTextColor),
// contentPadding: EdgeInsets.symmetric(
// vertical: 16.h,
// horizontal: 20.w,
// ),
// ),
// ),



// OutlinedButton(
// onPressed: () {},
// child: Row(
// mainAxisAlignment: MainAxisAlignment.spaceBetween,
// children: [
// Image.asset(ImagePath.google,height: 18.h,),
// Text("Continue with Google"),
// SizedBox(),
// ]),
// ),