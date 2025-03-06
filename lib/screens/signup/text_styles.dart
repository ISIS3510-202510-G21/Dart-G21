import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dart_g21/core/colors.dart';

class AppTextStyles {
  static final TextStyle timeStyle = GoogleFonts.roboto(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    letterSpacing: 0.14,
  );

  static final TextStyle appNameStyle = GoogleFonts.roboto(
    fontSize: 32,
    fontWeight: FontWeight.w400,
    color: Color(0xFF120D26),
  );

  static final TextStyle titleStyle = GoogleFonts.roboto(
    fontSize: 28,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static final TextStyle inputStyle = GoogleFonts.roboto(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.secondaryText,
    letterSpacing: 0.5,
  );

  static final TextStyle buttonTextStyle = GoogleFonts.roboto(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.primary,
    letterSpacing: 0.5,
  );

  static final TextStyle socialLoginStyle = GoogleFonts.roboto(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    letterSpacing: 0.5,
  );

  static final TextStyle footerStyle = GoogleFonts.roboto(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    letterSpacing: 0.5,
    height: 1.5,
  );
}