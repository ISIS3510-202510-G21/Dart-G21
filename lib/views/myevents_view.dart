import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dart_g21/controllers/event_controller.dart';
import 'package:dart_g21/controllers/profile_controller.dart';
import 'package:dart_g21/controllers/user_controller.dart';
import 'package:dart_g21/models/event.dart';
import 'package:dart_g21/models/profile.dart';
import 'package:dart_g21/models/user.dart';
import 'package:dart_g21/views/eventdetail_view.dart';
import 'package:dart_g21/widgets/eventcardMyEvents_view.dart';
import 'package:flutter/material.dart';
import 'package:dart_g21/core/colors.dart';
import 'package:dart_g21/widgets/navigation_bar_host.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:hive_flutter/hive_flutter.dart';

class MyEventsPage extends StatefulWidget {
  final String userId;

  MyEventsPage({Key? key, required this.userId}) : super(key: key);

  @override
  _MyEventsPageState createState() => _MyEventsPageState();
}

class _MyEventsPageState extends State<MyEventsPage> {
  final ProfileController _profileController = ProfileController();
  final EventController _eventController = EventController();
  final UserController _userController = UserController();
  int selectedIndex = 2;
  List<Event> upcomingEvents = [];
  List<Event> previousEvents = [];
  List<Event> eventsCreated = [];
  String profileId = "";
  String userType = "";
  bool isConnected = true;
  late final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  late Box myEventsBox;

    @override
  void initState() {
    super.initState();
    _setupConnectivity();
    _checkInitialConnectivityAndLoad();
    _initHive();
  }

  Future<void> _initHive() async {
    await Hive.initFlutter();
    myEventsBox = await Hive.openBox('myEventsBox');
  }

void _setupConnectivity() {
    _connectivity = Connectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      final prev = isConnected;
      setState(() {
        isConnected = !results.contains(ConnectivityResult.none);

      });
      if (!prev && isConnected) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Connection Restored", style: TextStyle(color: AppColors.primary, fontSize: 16,)),
            backgroundColor: const Color.fromARGB(255, 37, 108, 39),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
       } 
      //else if (prev && !isConnected) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(
      //       content: const Text("Connection lost, Offline mode activated", style: TextStyle(color: AppColors.primary, fontSize: 16,)),
      //       backgroundColor: AppColors.buttonRed,
      //       behavior: SnackBarBehavior.floating,
      //       shape: RoundedRectangleBorder(
      //         borderRadius: BorderRadius.circular(12),
      //       ),
      //     ),
      //   );
      // }
    });
  }

  Future<void> _checkInitialConnectivityAndLoad() async {
  final result = await Connectivity().checkConnectivity();
  setState(() {
    isConnected = !result.contains(ConnectivityResult.none);
  });


}

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16),
          child: Row(
            children: [
              Text("My Events", style: TextStyle(fontSize: 24, color: Colors.black, fontWeight: FontWeight.normal)),
            ],
          ),
        ),
        FutureBuilder<User?>(
          future: _userController.getUserById(widget.userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return Center(child: Text("Error al cargar el usuario"));
            }
            userType = snapshot.data!.userType;
            return const SizedBox.shrink();
          },
        ),
        Expanded(
          child: isConnected
              ? StreamBuilder<Profile?>(
                  stream: _profileController.getProfileByUserId(widget.userId),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Center(child: Text("No profile found"));
                    final profile = snapshot.data!;
                    profileId = profile.id;
                    return FutureBuilder<List<List<Event>>>(
                      future: _eventController.getEventsByIds(profile.events_associated).then(
                        (events) => _eventController.classifyEvents(events, widget.userId),
                      ),
                      builder: (context, eventSnapshot) {
                        if (!eventSnapshot.hasData) return const Center(child: Text("No events found"));
                        upcomingEvents = eventSnapshot.data![0];
                        previousEvents = eventSnapshot.data![1];
                        eventsCreated = eventSnapshot.data![2];
                        // guardar local
                        myEventsBox.put('${widget.userId}_upcoming', upcomingEvents.map((e) => e.toJson()).toList());
                        myEventsBox.put('${widget.userId}_previous', previousEvents.map((e) => e.toJson()).toList());
                        myEventsBox.put('${widget.userId}_created', eventsCreated.map((e) => e.toJson()).toList());

                        return _buildListView();
                      },
                    );
                  },
                )
              : _buildOfflineView(),
        ),
      ],
    );
  }

Widget _buildListView() {
  return ListView(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    children: [
      buildSectionTitle("Upcoming Events"),
      ...upcomingEvents.map((event) => EventCard(
           event: event,
            profileId: profileId,
            isConnected: isConnected,
            onDelete: () => _handleDelete(event.id),
            onTap: () => _navigateToDetail(event.id),
          )),
      const SizedBox(height: 20),
      buildSectionTitle("Previous Events"),
      ...previousEvents.map((event) => EventCard(
            event: event,
            profileId: profileId,
            isConnected: isConnected,
            onDelete: () => _handleDelete(event.id),
            onTap: () => _navigateToDetail(event.id),
          )),
      if (userType != "Attendee") ...[
        const SizedBox(height: 20),
        buildSectionTitle("Created By Me"),
        ...eventsCreated.map((event) => EventCard(
            event: event,
            profileId: profileId,
            isConnected: isConnected,
            onDelete: () => _handleDelete(event.id),
            onTap: () => _navigateToDetail(event.id),
          )),
      ]
    ],
  );
}

void _handleDelete(String eventId) async {
  try {
    await _profileController.removeEventFromProfile(profileId, eventId);
    setState(() {
      upcomingEvents.removeWhere((e) => e.id == eventId);
      previousEvents.removeWhere((e) => e.id == eventId);
      eventsCreated.removeWhere((e) => e.id == eventId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Event removed from My Events")),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Error removing event")),
    );
  }
}

void _navigateToDetail(String eventId) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => EventDetailScreen(
        eventId: eventId,
        userId: widget.userId,
      ),
    ),
  );
}

  Widget _buildOfflineView() {
    final List<dynamic> u = myEventsBox.get('${widget.userId}_upcoming', defaultValue: []);
    final List<dynamic> p = myEventsBox.get('${widget.userId}_previous', defaultValue: []);
    final List<dynamic> c = myEventsBox.get('${widget.userId}_created', defaultValue: []);
    upcomingEvents = u.map((e) => Event.fromJson(Map<String, dynamic>.from(e))).toList();
    previousEvents = p.map((e) => Event.fromJson(Map<String, dynamic>.from(e))).toList();
    eventsCreated = c.map((e) => Event.fromJson(Map<String, dynamic>.from(e))).toList();
    return _buildListView();
  }

  Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
    );
  }


}
