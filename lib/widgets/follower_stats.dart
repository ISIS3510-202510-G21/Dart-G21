import 'package:flutter/material.dart';
import 'package:dart_g21/core/colors.dart';
import '../controllers/profile_controller.dart';
import '../controllers/user_controller.dart';
import '../views/FollowersOrFollowingView.dart';
import '../models/profile.dart';

class FollowerStats extends StatelessWidget {
  final bool isOffline;
  final ProfileController profileController;
  final UserController userController;
  final String userId;

  const FollowerStats({
    Key? key,
    this.isOffline = false,
    required this.profileController,
    required this.userController,
    required this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Profile?>(
      stream: profileController.getProfileByUserId(userId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final profile = snapshot.data!;
        final followersCount = profile.followers.length;
        final followingCount = profile.following.length;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Following
            GestureDetector(
              onTap: () => _navigateTo(context, false),
              child: Column(
                children: [
                  Text(
                    '$followingCount',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Following',
                    style: TextStyle(color: AppColors.secondaryText, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 40),
            // Followers
            GestureDetector(
              onTap: () => _navigateTo(context, true),
              child: Column(
                children: [
                  Text(
                    '$followersCount',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Followers',
                    style: TextStyle(color: AppColors.secondaryText, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _navigateTo(BuildContext context, bool isFollowers) async {
    final profile = await profileController.getProfileByUserId(userId).first;

    if (profile == null) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FollowersOrFollowingView(
          profileId: profile.id,
          currentUserId: userId,
          isFollowers: isFollowers,
          profileController: profileController,
          userController: userController,
        ),
      ),
    );
  }
}
