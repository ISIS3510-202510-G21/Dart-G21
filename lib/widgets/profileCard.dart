import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../controllers/profile_controller.dart';
import '../controllers/user_controller.dart';
import '../models/user.dart' as user_model;
import '../models/profile.dart' as profile_model;
import '../repositories/drift_repository.dart';
import '../repositories/localStorage_repository.dart';

class ProfileCard extends StatefulWidget {
  final String userId;
  final String currentUserId;
  final UserController userController;
  final ProfileController profileController;
  final DriftRepository driftRepository;
  final LocalStorageRepository localStorageRepository;
  final user_model.User user;
  final profile_model.Profile profile;
  final bool isFollowing;
  final bool isConnected;

  const ProfileCard({
    Key? key,
    required this.userId,
    required this.currentUserId,
    required this.userController,
    required this.profileController,
    required this.driftRepository,
    required this.localStorageRepository,
    required this.user,
    required this.profile,
    required this.isFollowing,
    required this.isConnected,
  }) : super(key: key);

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  late bool isConnected;
  late bool isFollowing;
  late Connectivity _connectivity;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    isConnected = widget.isConnected;
    isFollowing = widget.isFollowing;
    _checkInitialConnectivity();
    _setUpConnectivity();
  }

  Future<void> _checkInitialConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    setState(() {
      isConnected = !result.contains(ConnectivityResult.none);
    });
  }

  void _setUpConnectivity() {
    _connectivity = Connectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      final currentlyConnected = !results.contains(ConnectivityResult.none);
      if (mounted && currentlyConnected != isConnected) {
        setState(() {
          isConnected = currentlyConnected;
        });
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          buildProfileImage(widget.profile.picture),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.profile.headline.isNotEmpty ? widget.profile.headline : "No headline",
                  style: const TextStyle(color: Colors.indigo, fontSize: 14),
                ),
                Text(
                  widget.user.name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: isConnected
                ? () async {
              if (isFollowing) {
                await widget.profileController.unfollowUser(widget.currentUserId, widget.userId);
              } else {
                await widget.profileController.followUser(widget.currentUserId, widget.userId);
              }
              setState(() {
                isFollowing = !isFollowing;
              });
            }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: isConnected ? Colors.indigo.withOpacity(0.1) : Colors.grey.shade300,
              foregroundColor: isConnected ? Colors.indigo : Colors.grey,
              shape: const StadiumBorder(),
              elevation: 0,
            ),
            child: Text(isFollowing ? "Unfollow" : "Follow"),
          ),
        ],
      ),
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
