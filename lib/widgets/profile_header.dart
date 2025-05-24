import 'package:flutter/material.dart';
import 'package:dart_g21/core/colors.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String headline;

  const ProfileHeader({
    Key? key,
    required this.name,
    required this.headline,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          name,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          headline,
          style: const TextStyle(
            fontSize: 22,
            color: AppColors.secondaryText,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
} 
