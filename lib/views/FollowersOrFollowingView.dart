import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import '../controllers/profile_controller.dart';
import '../controllers/user_controller.dart';
import '../data/database/app_database.dart';
import '../models/user.dart' as user_model;
import '../models/profile.dart' as profile_model;
import '../repositories/drift_repository.dart';
import '../repositories/localStorage_repository.dart';
import '../widgets/profileCard.dart';

class FollowerData {
  final user_model.User user;
  final profile_model.Profile profile;
  final bool isFollowing;

  FollowerData({
    required this.user,
    required this.profile,
    required this.isFollowing,
  });
}

class FollowersOrFollowingView extends StatefulWidget {
  final String profileId;
  final String currentUserId;
  final bool isFollowers;
  final ProfileController profileController;
  final UserController userController;

  const FollowersOrFollowingView({
    Key? key,
    required this.profileId,
    required this.currentUserId,
    required this.isFollowers,
    required this.profileController,
    required this.userController,
  }) : super(key: key);

  @override
  _FollowersOrFollowingViewState createState() => _FollowersOrFollowingViewState();
}

class _FollowersOrFollowingViewState extends State<FollowersOrFollowingView> {
  final _localStorageRepository = LocalStorageRepository();
  final _driftRepository = DriftRepository(AppDatabase());

  List<FollowerData> followerDataList = [];
  bool isConnected = true;
  bool isLoading = true;

  late final Connectivity _connectivity;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _setupConnectivity();
    logFollowersOrFollowingView(
      widget.currentUserId,
      widget.profileId,
      widget.isFollowers,
    );
    _checkInitialConnectivityAndLoad();
  }

  void _setupConnectivity() {
    _connectivity = Connectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((results) async {
      final currentlyConnected = !results.contains(ConnectivityResult.none);
      if (currentlyConnected != isConnected) {
        setState(() {
          isConnected = currentlyConnected;
        });
      }
    });
  }

  Future<void> _checkInitialConnectivityAndLoad() async {
    final result = await Connectivity().checkConnectivity();
    isConnected = result != ConnectivityResult.none;

    if (isConnected) {
      await _loadOnline();

    } else {
      await _loadFromLocal();
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> _loadOnline() async {
    final followers = await widget.profileController.getFollowersStream(widget.profileId).first;
    final followings = await widget.profileController.getFollowingsStream(widget.profileId).first;
    final currentProfile = await widget.profileController.getProfileByUserId(widget.currentUserId).first;

    final ids = widget.isFollowers ? followers : followings;

    for (final id in ids) {
      final profile = await widget.profileController.getProfileByUserId(id).first;
      final user = await widget.userController.getUserById(id);
      final isFollowing = currentProfile?.following.contains(id) ?? false;

      if (user != null && profile != null) {
        final data = FollowerData(user: user, profile: profile, isFollowing: isFollowing);
        setState(() {
          followerDataList.add(data);
        });
        _driftRepository.saveUserDrift(user);
        _localStorageRepository.saveProfile(id, profile);
      }
    }

    await _localStorageRepository.saveFollowersAndFollowing(
      widget.profileId,
      followers.take(2).toList(),
      followings.take(2).toList(),
    );
  }

  Future<void> _loadFromLocal() async {
    final localData = await _localStorageRepository.getFollowersAndFollowing(widget.profileId);
    final ids = widget.isFollowers ? localData['followers']! : localData['following']!;

    for (final id in ids.take(2)) {
      final user = await _driftRepository.getUserByIdDrift(id);
      final profile = await _localStorageRepository.getProfileByUserId(id);

      if (user != null && profile != null) {
        final data = FollowerData(user: user, profile: profile, isFollowing: false);
        setState(() {
          followerDataList.add(data);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final int itemCount = isConnected
        ? followerDataList.length
        : (followerDataList.length > 2 ? 2 : followerDataList.length);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.isFollowers ? "Followers" : "Following"),
        leading: const BackButton(),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : followerDataList.isEmpty
          ? Center(
        child: Text(widget.isFollowers ? "No followers yet" : "Not following anyone"),
      )
          : ListView.builder(
        itemCount: itemCount,
        itemBuilder: (context, index) {
          final data = followerDataList[index];
          return ProfileCard(
            userId: data.user.id,
            currentUserId: widget.currentUserId,
            userController: widget.userController,
            profileController: widget.profileController,
            driftRepository: _driftRepository,
            localStorageRepository: _localStorageRepository,
            user: data.user,
            profile: data.profile,
            isFollowing: data.isFollowing,
            isConnected: isConnected,
          );
        },
      ),
    );
  }

  void logFollowersOrFollowingView(String userId, String viewedUserId, bool isFollowers) {
    print("LOGGING VIEW: $userId viewed ${isFollowers ? 'followers' : 'following'} of $viewedUserId");
    FirebaseFirestore.instance.collection('followers_following_logs').add({
      'user_id': userId,
      'viewed_user_id': viewedUserId,
      'type': isFollowers ? 'followers' : 'following',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }



}
