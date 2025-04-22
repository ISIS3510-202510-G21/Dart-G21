import 'dart:async';
import 'dart:io';
import 'package:dart_g21/controllers/auth_controller.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/material.dart';
import 'package:dart_g21/controllers/category_controller.dart';
import 'package:dart_g21/controllers/interest_controller.dart';
import 'package:dart_g21/controllers/profile_controller.dart';
import 'package:dart_g21/controllers/user_controller.dart';
import 'package:dart_g21/core/colors.dart';
import 'package:dart_g21/models/interest.dart';
import 'package:dart_g21/models/profile.dart';
import 'package:dart_g21/widgets/navigation_bar_host.dart';
import '../controllers/skill_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dart_g21/services/local_storage_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfilePage extends StatefulWidget {
  final String userId;
  ProfilePage({Key? key, required this.userId}) : super(key: key);
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileController _profileController = ProfileController();
  final CategoryController _categoryController = CategoryController();
  final UserController _userController = UserController();
  final AuthController _authController = AuthController();
  final double coverHeight = 200;
  final double profileHeight = 180;
  bool isConnected = true;
  late final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  late Box profileBox;
  String offlineName = "";
  String offlineHeadline = "";
  String offlineDescription = "";
  String offlineFollowers = "";
  String offlineFollowing = "";
  Profile profile_user = Profile(id: '', user_ref: '', headline: '', events_associated: [], picture: '', description: '', followers: [], following: [], interests: []);

   @override
  void initState() {
    super.initState();
    _setupConnectivity();
    _loadInitialData();
  }
 Future<void> _loadInitialData() async {
    if (isConnected) {
      _loadOnlineData();
    } else {
      _loadOfflineData();
    }
  }

    Future<void> _loadOnlineData() async {
    
    final profileStream = _profileController.getProfileByUserId(widget.userId);
    profileStream.listen((profile) async {
     
      if (profile != null) {
        setState(() {
          profile_user = profile;
        });

        // Guardar datos en el almacenamiento local
        await _profileController.saveProfileToLocal(widget.userId, profile);

        // Guardar seguidores y seguidos
        await _profileController.saveFollowersAndFollowingToLocal(
          widget.userId,
          profile.followers,
          profile.following,
        );
      }
    });
  }

   Future<void> _loadOfflineData() async {
    final profile = await _profileController.getProfileFromLocal(widget.userId);
    if (profile != null) {
      setState(() {
        profile_user = profile;
        offlineName = profile_user.user_ref;
        offlineHeadline = profile_user.headline;
        offlineDescription = profile_user.description;
        offlineFollowers = profile_user.followers.length.toString();
        offlineFollowing = profile_user.following.length.toString();
      });
    }
  }

  void _setupConnectivity() {
    _connectivity = Connectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      final prev = isConnected;
      setState(() {
        isConnected = !results.contains(ConnectivityResult.none);
        if (!isConnected) {
        _loadOfflineData();
        } else {
          _loadOnlineData();
        }
      });
      if (!prev && isConnected) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   // SnackBar(
        //   //   content: const Text("Connection Restored", style: TextStyle(color: AppColors.primary, fontSize: 16,)),
        //   //   backgroundColor: const Color.fromARGB(255, 37, 108, 39),
        //   //   behavior: SnackBarBehavior.floating,
        //   //   shape: RoundedRectangleBorder(
        //   //     borderRadius: BorderRadius.circular(12),
        //   //   ),
        //   // ),
        // );
      } else if (prev && !isConnected) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Connection lost, Offline mode activated", style: TextStyle(color: AppColors.primary, fontSize: 16,)),
            backgroundColor: AppColors.buttonRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  //Método para salir
  Future<void> logout(BuildContext context) async {
  await _authController.signOut();
  await LocalStorageService.clearUserId();

  Navigator.pushNamedAndRemoveUntil(
    context,
    '/signin',
    (route) => false,
  );
}

   @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 40),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16),
          child: Row(
            children: const [
              Text(
                "Profile",
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: isConnected
              ? ListView(
                  padding: EdgeInsets.zero,
                  children: <Widget>[
                    buildTop(profile_user),
                    buildContent(profile_user),
                  ],
                )
              : ListView(
                  padding: EdgeInsets.zero,
                  children: <Widget>[
                    buildTop(profile_user),
                    buildOfflineContent(),
                  ],
                ),
        ),
      ],
    );
  }


  Widget buildTop(Profile profile) {
    final bottom = 200.0;
    final top = 20.0;
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Container(margin: EdgeInsets.only(bottom: bottom), child: buildCoverImage()),
        Positioned(top: top, child: buildProfileImage(profile.picture)),
      ],
    );
  }

  Widget buildCoverImage() {
    return Container(
      color: AppColors.secondaryText,
    );
  }

Widget buildProfileImage(String? imagePath) {
  final bool hasImage = imagePath != null && imagePath.isNotEmpty;

  return CircleAvatar(
    radius: 90,
    backgroundColor: Colors.grey.shade300,
    child: hasImage
        ? ClipOval(
            child: CachedNetworkImage(
              imageUrl: imagePath!,
              width: 180,
              height: 180,
              fit: BoxFit.cover,
               cacheManager: CacheManager(
                    Config(
                      'customCacheKey',
                      stalePeriod: const Duration(days: 7), // Tiempo de expiración
                      maxNrOfCacheObjects: 100,
                    ),
                  ),
                 placeholder: (context, url) => Container(
                    width: 180,
                    height: 180,
                    color: Colors.grey.shade200,
                    child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
                  ),
            ),
          )
        : const Icon(
            Icons.person,
            size: 60,
            color: Colors.white,
          ),
  );
}

  Widget buildContent(Profile profile) {
    List<Color> colors = [AppColors.buttonPurple, AppColors.buttonRed, AppColors.buttonOrange, AppColors.secondary, AppColors.buttonGreen, AppColors.buttonLightBlue];
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 20),
          FutureBuilder(
            future: _userController.getUserById(profile.user_ref),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  return Text(
                    snapshot.data!.name,
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    textAlign: TextAlign.center,
                  );
                } else {
                  return Text('User not found');
                }
              }
              return Text('Loading...');
            },
          ),
          Text(
            profile.headline,
            style: TextStyle(fontSize: 22, color: AppColors.secondaryText),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          buildFollowerRow(profile),
          SizedBox(height: 20),
          buildAboutMe(profile.description),
          SizedBox(height: 20),
          buildInterestSection(profile, colors),
          SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget buildOfflineContent() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 20),
          Text(
            offlineName,
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            textAlign: TextAlign.center,
          ),
          Text(
            offlineHeadline,
            style: TextStyle(fontSize: 22, color: AppColors.secondaryText),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          buildFollowerRowOffline(offlineFollowers, offlineFollowing),
          SizedBox(height: 20),
          buildAboutMe(offlineDescription),
          SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget buildFollowerRow(Profile profile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            Text(profile.following.length.toString(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Following', style: TextStyle(color: AppColors.secondaryText, fontSize: 14)),
          ],
        ),
        SizedBox(width: 40),
        Column(
          children: [
            Text(profile.followers.length.toString(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Followers', style: TextStyle(color: AppColors.secondaryText, fontSize: 14)),
          ],
        ),
      ],
    );
  }

  Widget buildFollowerRowOffline(String followers, String following) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            Text(following, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Following', style: TextStyle(color: AppColors.secondaryText, fontSize: 14)),
          ],
        ),
        SizedBox(width: 40),
        Column(
          children: [
            Text(followers, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Followers', style: TextStyle(color: AppColors.secondaryText, fontSize: 14)),
          ],
        ),
      ],
    );
  }

  Widget buildAboutMe(String? description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text('About Me...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        ),
        SizedBox(height: 8),
        Text(
          description ?? 'No description available',
          style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
          textAlign: TextAlign.justify,
        ),
      ],
    );
  }

  Widget buildInterestSection(Profile profile, List<Color> colors) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Interest', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        SizedBox(height: 20),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (var interest in profile.interests)
              FutureBuilder(
                future: _categoryController.getCategoryById(interest),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData) {
                      return buildInterestChip(snapshot.data!.name, colors[interest.hashCode % colors.length]);
                    } else {
                      return Text('Interest not found');
                    }
                  }
                  return Text('Loading...');
                },
              ),
          ],
        ),
      ],
    );
  }

  Widget buildInterestChip(String label, Color color) {
    return Chip(
      label: Text(label, style: TextStyle(color: AppColors.primary, fontSize: 14)),
      backgroundColor: color,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical:6),
);
}
}
