import 'package:flutter/material.dart';
import '../controllers/profile_controller.dart';
import '../controllers/user_controller.dart';
import '../widgets/profileCard.dart';

class FollowersOrFollowingView extends StatelessWidget {
  final String profileId;
  final String currentUserId; // 👈 usuario autenticado
  final bool isFollowers;
  final ProfileController profileController;
  final UserController userController;

  const FollowersOrFollowingView({
    Key? key,
    required this.profileId,
    required this.currentUserId, // 👈 se pasa correctamente
    required this.isFollowers,
    required this.profileController,
    required this.userController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Stream<List<String>> userIdsStream = isFollowers
        ? profileController.getFollowersStream(profileId)
        : profileController.getFollowingsStream(profileId);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(isFollowers ? "Followers" : "Following"),
        leading: const BackButton(),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black, // íconos y texto en negro
        elevation: 0,
      ),
      body: StreamBuilder<List<String>>(
        stream: userIdsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(isFollowers ? "No followers yet" : "Not following anyone"),
            );
          }

          final userIds = snapshot.data!;

          return ListView.builder(
            itemCount: userIds.length,
            itemBuilder: (context, index) {
              final userId = userIds[index];

              return ProfileCard(
                userId: userId, // usuario mostrado
                currentUserId: currentUserId, // 👈 usuario autenticado
                userController: userController,
                profileController: profileController,
              );
            },
          );
        },
      ),
    );
  }
}
