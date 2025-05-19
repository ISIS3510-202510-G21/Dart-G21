import 'package:flutter/material.dart';
import 'package:dart_g21/core/colors.dart';

class AboutSection extends StatelessWidget {
  final String? description;

  const AboutSection({Key? key, required this.description}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'About Me...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description ?? 'No description available',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.justify,
        ),
      ],
    );
  }
}
