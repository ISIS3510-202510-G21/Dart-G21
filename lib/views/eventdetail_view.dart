import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dart_g21/models/category.dart';
import 'package:flutter/material.dart';
import 'package:dart_g21/controllers/event_controller.dart';
import 'package:dart_g21/controllers/user_controller.dart';
import 'package:dart_g21/controllers/profile_controller.dart';
import 'package:dart_g21/controllers/category_controller.dart';
import 'package:dart_g21/controllers/location_controller.dart';
import 'package:dart_g21/controllers/skill_controller.dart';
import 'package:dart_g21/models/event.dart';
import 'package:dart_g21/models/location.dart';
import 'package:dart_g21/models/profile.dart';
import 'package:dart_g21/core/colors.dart';
import 'package:dart_g21/views/successfulregistration_view.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class EventDetailScreen extends StatefulWidget {
  final String eventId;
  final String userId;

  const EventDetailScreen({Key? key, required this.eventId, required this.userId}) : super(key: key);

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final EventController _eventController = EventController();
  final UserController _userController = UserController();
  final ProfileController _profileController = ProfileController();
  final CategoryController _categoryController = CategoryController();
  final LocationController _locationController = LocationController();
  final SkillController _skillController = SkillController();
  late final Connectivity _connectivity;
  late Future<List<String>> _skillsFuture;

  Event? _event;
  String creatorName = "";
  String creatorImage = "";
  String creatorHeadline = "";
  Category_event? _category;
  Location? _location;

  bool isConnected = true;

  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;


  @override
  void initState() {
    super.initState();
    fetchEventData();
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
      _loadOnlineData();
    } else {
      _loadOfflineData();
}
}

Future<void> _loadOfflineData() async {
    final fetchedEvent = await _eventController.getEventByIdOffline(widget.eventId);
    if (fetchedEvent != null) {
      setState(() {
        _event = fetchedEvent;
      });
    }

    final profile = await _profileController.getProfileFromLocal(_event!.creator_id);
    final name = await _profileController.getUserNameFromLocal(_event!.creator_id);
    setState(() {
      creatorName = name ?? "Unknown";
      creatorHeadline = profile?.headline ?? "No headline provided";
      //creatorImage =profile?.picture ?? "";
      //verificar si existe un profile antes de intentar acceder a sus propiedades
      if (profile != null) {
        creatorImage =profile?.picture ?? "";
        /* creatorImage = (profile.thumbnail != null && profile.thumbnail!.isNotEmpty)
            ? profile.thumbnail!
            : profile.picture; */
      } else {
        creatorImage = "";
      }
    });

   // _category = await _categoryController.getCategoryByIdOffline(_event!.category);
    _category = await _categoryController.getCategoryByIdOfflineDrift(_event!.category);
   // _location = await _locationController.getLocationByIdOffline(_event!.location_id);
    _location = await _locationController.getLocationByIdOfflineDrift(_event!.location_id);
}

Future<void> _loadOnlineData() async {
    final fetchedEvent = await _eventController.getEventById(widget.eventId);
    if (fetchedEvent != null) {
      setState(() {
        _event = fetchedEvent;
        _skillsFuture = _skillController.getSkillsByIds(_event?.skills ?? []);
      });
    }

    final profileStream = _profileController.getProfileByUserId(_event!.creator_id);
    profileStream.listen((profile) async {
      if (profile != null) {
        final user = await _userController.getUserById(_event!.creator_id);
        setState(() {
          creatorName = user?.name ?? "Unknown";
          creatorHeadline = profile.headline;
          creatorImage = profile.picture;
          /* creatorImage = (profile.thumbnail != null && profile.thumbnail!.isNotEmpty)
            ? profile.thumbnail!
            : profile.picture; */
        });

        // Guardamos para offline
        await _profileController.saveUserNameToLocal(_event!.creator_id, creatorName);
        await _profileController.saveProfileToLocal(_event!.creator_id, profile);
      }
    });

    _category = await _categoryController.getCategoryById(_event!.category);
    _location = await _locationController.getLocationById(_event!.location_id);
}

  Future<void> fetchEventData() async {
    final fetchedEvent = await _eventController.getEventById(widget.eventId);
    if (fetchedEvent != null) {
      setState(() => _event = fetchedEvent);
      fetchCreatorData(fetchedEvent.creator_id);
    }
  }

  Future<void> fetchCreatorData(String creatorId) async {
    final profileStream = _profileController.getProfileByUserId(creatorId);
    profileStream.listen((profile) async {
      if (profile != null) {
        final user = await _userController.getUserById(creatorId);
        setState(() {
          creatorImage = profile.picture;
          /* creatorImage = (profile.thumbnail != null && profile.thumbnail!.isNotEmpty)
            ? profile.thumbnail!
            : profile.picture; */
          creatorHeadline = profile.headline;
          creatorName = user?.name ?? "Unknown";
        });
      }
    });
  }

  String _formatTimeWithAmPm(DateTime dateTime) {
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day} ${_monthName(dateTime.month)} ${dateTime.year}';
  }

  String _monthName(int month) {
    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    if (_event == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isFree = _event!.cost == 0;
    final daysLeft = _event!.start_date.difference(DateTime.now()).inDays;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Event Detail", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
              imageUrl: _event!.image,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 200,
                width: double.infinity,
                color: Colors.grey.shade200,
                child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              errorWidget: (context, url, error) => Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
              ),
              cacheManager: CacheManager(
                Config(
                'customCacheKeyMyEvents',
                stalePeriod: const Duration(days: 7),
                maxNrOfCacheObjects: 100,
                ),
              ),
              ),
            ),
            const SizedBox(height: 16),

            //HEADER CARD: Nombre, costo, categoría, ubicación
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _event!.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          // Cost
                          Row(
                            children: [
                              const Icon(Icons.credit_card, color: Colors.grey),
                              const SizedBox(width: 6),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Cost", style: TextStyle(fontSize: 14)),
                                  Text(
                                    _event!.cost == 0 ? "FREE" : "\$${_event!.cost}",
                                    style: const TextStyle(fontSize: 14, color: AppColors.secondary),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          // SEPARADOR
                          Container(width: 1, height: 40, color: Colors.grey.shade300),

                          // Cambio de Location a Attendee!
                          Row(
                                children: [
                                  const Icon(Icons.people_alt_outlined, size: 25, color: Colors.grey),
                                  const SizedBox(width: 6),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text("Attendees", style: TextStyle(fontSize: 14)),
                                        GestureDetector(
                                        onTap: () {

                                            Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => AttendeesView(attendeeIds: _event!.attendees),
                                          ),
                                          );
                                        
                                         
                                        },
                                        child: Text(
                                          "${_event!.attendees.length} people",
                                          style: const TextStyle(color: AppColors.secondary, fontSize: 13, decoration: TextDecoration.underline),
                                        ),
                                        )
                                      
                                    ],
                                  ),
                                ],
                              ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            //DATE CARD: Start y End Date
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // START DATE
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text("Start Date", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.event_available, size: 30, color: Colors.grey),
                                    const SizedBox(width: 6),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(_formatTimeWithAmPm(_event!.start_date),
                                            style: const TextStyle(color: AppColors.secondary, fontSize: 14)),
                                        Text(_formatDate(_event!.start_date),
                                            style: const TextStyle(color: AppColors.secondary, fontSize: 14)),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Separador
                          Container(width: 1, height: 70, margin: const EdgeInsets.symmetric(horizontal: 12), color: Colors.grey.shade300),

                          //END DATE
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text("End Date", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.calendar_month, size: 30, color: Colors.grey),
                                    const SizedBox(width: 6),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(_formatTimeWithAmPm(_event!.end_date),
                                            style: const TextStyle(color: AppColors.secondary, fontSize: 14)),
                                        Text(_formatDate(_event!.end_date),
                                            style: const TextStyle(color: AppColors.secondary, fontSize: 14)),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      daysLeft>=0 ?Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "$daysLeft days to go",
                          style: const TextStyle(color: Color.fromARGB(255, 20, 104, 23), fontSize: 14),
                        ),
                      ):Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "$daysLeft days left",
                          style: const TextStyle(color: Colors.red, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            //DESCRIPTION + SKILLS CARD
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Description", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 8),
                      Text(_event!.description, style: const TextStyle(fontSize: 14)),
                      const SizedBox(height: 16),
                      const Text("Location", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("${_location?.address}, ${_location?.city}", style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                                if (_location?.details != null && _location!.details.isNotEmpty)
                                  Text(_location?.details??"Unknown", style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                              ],
                            ),
                      const SizedBox(height: 16),
                      const Text("Category", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 8),
                      Text(_category?.name ?? "Unknown",style: const TextStyle(fontSize: 14, color: AppColors.secondary),), //CAMBIO PARA INTEGRAR
                      const SizedBox(height: 16),
                      isConnected?    const Text("Skills", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)): const Text(""),
                      const SizedBox(height: 8),
                      isConnected? FutureBuilder<List<String>>(
                        future: _skillController.getSkillsByIds(_event!.skills),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return const Text("Loading...");
                          return Text(
                            snapshot.data!.join(", "),
                            style: const TextStyle(fontSize: 14, color: AppColors.secondary),
                          );
                        },
                      ): const Text(
                        "",
                      ),   

                    ],
                  ),
                ),
              ),
            ),

            //Card del host
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      //Foto del speaker
                      ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: creatorImage,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                        width: 70,
                        height: 70,
                        color: Colors.grey.shade200,
                        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                        ),
                        errorWidget: (context, url, error) => Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person, size: 32, color: Colors.grey),
                        ),
                        cacheManager: CacheManager(
                        Config(
                          'customCacheKeyMyEvents',
                          stalePeriod: const Duration(days: 7),
                          maxNrOfCacheObjects: 100,
                        ),
                        ),
                      ),
                      ),
                      const SizedBox(width: 16),

                      //Datos del speaker
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            creatorName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            creatorHeadline.isNotEmpty ? creatorHeadline : "No headline provided",
                            style: const TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20), // separador entre la última card y el botón

            isConnected?    SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    final profileId = await _profileController.getProfileIdFromUserId(widget.userId);
                    if (profileId != null) {
                      await _eventController.subscribeUserToEvent(widget.eventId, widget.userId); 
                      await _profileController.registerEventToProfile(profileId, widget.eventId);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SuccessfulregistrationView(
                            eventId: widget.eventId,
                            userId: widget.userId,
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("No profile found for this user")),
                      );
                    }

                  } catch (e) {
                    print("Error subscribing to event: $e");
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Something went wrong while booking the event")),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Book Event", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ): Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "You cannot book this event without an internet connection.",
                    style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
