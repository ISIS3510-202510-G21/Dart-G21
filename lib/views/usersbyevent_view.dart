import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dart_g21/controllers/profile_controller.dart';
import 'package:dart_g21/controllers/user_controller.dart';
import 'package:dart_g21/models/profile.dart';
import 'package:dart_g21/models/user.dart';
import 'package:dart_g21/core/colors.dart';

class AttendeesView extends StatefulWidget {
  final List<String> attendeeIds;

  const AttendeesView({Key? key, required this.attendeeIds}) : super(key: key);

  @override
  _AttendeesViewState createState() => _AttendeesViewState();
}

class _AttendeesViewState extends State<AttendeesView> {
  final ProfileController _profileController = ProfileController();
  final UserController _userController = UserController();
  bool isConnected = true;
  List<Map<String, dynamic>> attendees = [];
  late final Connectivity _connectivity;
    late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;


  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _setupConnectivity();
    _checkInitialConnectivityAndLoad(); 
  }

void _setupConnectivity() {
  _connectivity = Connectivity();
  _connectivitySubscription = _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) async {
    final prev = isConnected;
    final currentlyConnected = !results.contains(ConnectivityResult.none);

    if (prev != currentlyConnected) {
      setState(() {
        isConnected = currentlyConnected;
      });

        await _loadInitialData();

      if (isConnected) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: const Text("Connection Restored", style: TextStyle(color: AppColors.primary, fontSize: 16)),
        //     backgroundColor: const Color.fromARGB(255, 37, 108, 39),
        //     behavior: SnackBarBehavior.floating,
        //     shape: RoundedRectangleBorder(
        //       borderRadius: BorderRadius.circular(12),
        //     ),
        //   ),
        // );
      } else {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: const Text("Connection lost, Offline mode activated", style: TextStyle(color: AppColors.primary, fontSize: 16)),
        //     backgroundColor: AppColors.buttonRed,
        //     behavior: SnackBarBehavior.floating,
        //     shape: RoundedRectangleBorder(
        //       borderRadius: BorderRadius.circular(12),
        //     ),
        //   ),
        // );
      }
    }
  });
}

Future<void> _checkInitialConnectivityAndLoad() async {
  final result = await Connectivity().checkConnectivity();
  setState(() {
    isConnected = !result.contains(ConnectivityResult.none);
  });
  await _loadInitialData();

}


Future<void> _loadInitialData() async {
    if (isConnected) {
      _loadAttendees();
    } else {
      _loadOfflineAttendees();
}
}


  Future<void> _loadAttendees() async {
    List<Map<String, dynamic>> result = [];
    for (String userId in widget.attendeeIds) {
      final profileFuture = _profileController.getProfileByUserId(userId).first;
      final userFuture = _userController.getUserById(userId);

      final profile = await profileFuture;
      final user = await userFuture;

      if (profile != null) {
        _profileController.saveProfileToLocal(userId, profile);
      }
      if (user != null) {
        _profileController.saveUserNameToLocal(userId, user.name);
      }

      if (profile != null && user != null) {
        result.add({
          'name': user.name,
          'headline': profile.headline,
          'description': profile.description,
          'image': profile.picture ?? '',
        });
      }
    }

    setState(() {
      attendees = result;
    });
  }

Future<void> _loadOfflineAttendees() async {
    List<Map<String, dynamic>> result = [];

    for (String userId in widget.attendeeIds) {
      final profile = await _profileController.getProfileFromLocal(userId);
      final userName = await _profileController.getUserNameFromLocal(userId);

      if (profile != null && userName != null) {
        result.add({
          'name': userName,
          'headline': profile.headline,
          'description': profile.description,
          'image': profile.picture ?? '',
        });
      }
    }

    setState(() {
      attendees = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Attendees', style: TextStyle(color: AppColors.textPrimary, fontSize: 24)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: attendees.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: attendees.length,
              itemBuilder: (context, index) {
                final attendee = attendees[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                  child: ListTile(
                    leading: CachedNetworkImage(
                      imageUrl: attendee['image'],
                      imageBuilder: (context, imageProvider) => CircleAvatar(
                      backgroundImage: imageProvider,
                      radius: 28,
                      backgroundColor: Colors.grey.shade200,
                      ),
                      placeholder: (context, url) => const CircularProgressIndicator(),
                      errorWidget: (context, url, error) => const Icon(Icons.person),
                    ),
                    title: Text(attendee['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(attendee['headline'] ?? '', style: const TextStyle(color: AppColors.secondary)),
                        const SizedBox(height: 4),
                        Text(attendee['description'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
