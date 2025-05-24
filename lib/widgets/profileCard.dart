import 'package:flutter/material.dart';
import '../controllers/user_controller.dart';
import '../controllers/profile_controller.dart';
import '../models/user.dart';
import '../models/profile.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class ProfileCard extends StatelessWidget {
  final String userId; // El usuario que se muestra en la tarjeta
  final String currentUserId; // El usuario autenticado actual
  final UserController userController;
  final ProfileController profileController;

  const ProfileCard({
    Key? key,
    required this.userId,
    required this.currentUserId,
    required this.userController,
    required this.profileController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Profile?>(
      stream: profileController.getProfileByUserId(currentUserId), // 👈 Perfil del usuario actual
      builder: (context, currentProfileSnapshot) {
        if (!currentProfileSnapshot.hasData) {
          return const SizedBox(
            height: 80,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final currentProfile = currentProfileSnapshot.data!;
        final bool isFollowing = currentProfile.following.contains(userId); // 👈 ¿lo sigue?

        return StreamBuilder<Profile?>(
          stream: profileController.getProfileByUserId(userId),
          builder: (context, profileSnapshot) {
            return FutureBuilder<User?>(
              future: userController.getUserById(userId),
              builder: (context, userSnapshot) {
                if (!profileSnapshot.hasData || !userSnapshot.hasData) {
                  return const SizedBox(height: 80);
                }

                final profile = profileSnapshot.data!;
                final user = userSnapshot.data!;
                final String? imageUrl = profile.picture;

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
                  ),
                  child: Row(
                    children: [
                      buildProfileImage(imageUrl),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (profile.headline.isNotEmpty) ? profile.headline : "No headline",
                              style: const TextStyle(color: Colors.indigo, fontSize: 14),
                            ),
                            Text(
                              user.name,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          if (isFollowing) {
                            profileController.unfollowUser(currentUserId, userId);
                          } else {
                            profileController.followUser(currentUserId, userId);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo.withOpacity(0.1),
                          foregroundColor: Colors.indigo,
                          shape: const StadiumBorder(),
                          elevation: 0,
                        ),
                        child: Text(isFollowing ? "Unfollow" : "Follow"),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget buildProfileImage(String? imagePath) {
    final bool hasImage = imagePath != null && imagePath.isNotEmpty;
    return CircleAvatar(
      radius: 30,
      backgroundColor: Colors.grey.shade300,
      child: hasImage
          ? ClipOval(
        child: CachedNetworkImage(
          imageUrl: imagePath,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          cacheManager: CacheManager(
            Config(
              'customCacheKey',
              stalePeriod: const Duration(days: 7),
              maxNrOfCacheObjects: 100,
            ),
          ),
          placeholder: (context, url) => Container(
            width: 60,
            height: 60,
            color: Colors.grey.shade200,
            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          errorWidget: (context, url, error) => Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.indigo,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.image_not_supported, size: 30, color: Colors.white),
          ),
        ),
      )
          : const Icon(Icons.person, size: 30, color: Colors.white),
    );
  }
}
