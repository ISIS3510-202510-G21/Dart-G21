import 'package:flutter/material.dart';
import 'package:dart_g21/core/colors.dart';

class CustomInputField extends StatelessWidget {
  final String placeholder;
  final String iconPath;
  final bool isPassword;
  final VoidCallback? onToggleVisibility;
  final bool isPasswordVisible;
  final TextEditingController controller;

  const CustomInputField({
    Key? key,
    required this.placeholder,
    required this.iconPath,
    this.isPassword = false,
    this.onToggleVisibility,
    this.isPasswordVisible = false,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.secondaryText,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Image.asset(
              iconPath,
              width: 24,
              height: 24,
              color: AppColors.secondaryText,
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: isPassword && !isPasswordVisible,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: placeholder,
                hintStyle: const TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
              ),
              style: const TextStyle(
                fontSize: 16,
                letterSpacing: 0.5,
              ),
            ),
          ),
          if (isPassword)
            GestureDetector(
              onTap: onToggleVisibility,
              child: Padding(
                padding: const EdgeInsets.only(right: 18),
                child: Image.asset(
                  'lib/assets/visibility.png',
                  width: 24,
                  height: 24,
                  color: AppColors.secondaryText,
                ),
              ),
            ),
        ],
      ),
    );
  }
}