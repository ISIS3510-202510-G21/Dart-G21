import 'package:flutter/material.dart';
import 'package:dart_g21/core/colors.dart';

class FollowerStats extends StatelessWidget {
  final String followers;
  final String following;
  final bool isOffline;

  const FollowerStats({
    Key? key,
    required this.followers,
    required this.following,
    this.isOffline = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            Text(following,style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold,),),
            const Text('Following', style: TextStyle(color: AppColors.secondaryText,fontSize: 14,),),
          ],
        ),
        const SizedBox(width: 40),
        Column(
          children: [
            Text(followers,style: const TextStyle(fontSize: 16,fontWeight: FontWeight.bold,),),
            const Text('Followers',style: TextStyle(color: AppColors.secondaryText,fontSize: 14,),),
          ],
        ),
      ],
    );
  }
}
