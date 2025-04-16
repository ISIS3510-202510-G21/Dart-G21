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

  Event? _event;
  String creatorName = "";
  String creatorImage = "";
  String creatorHeadline = "";

  @override
  void initState() {
    super.initState();
    fetchEventData();
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
              child: Image.network(_event!.image, height: 200, width: double.infinity, fit: BoxFit.cover),
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

                          // Category
                          FutureBuilder(
                            future: _categoryController.getCategoryById(_event!.category),
                            builder: (context, snapshot) {
                              return Row(
                                children: [
                                  const SizedBox(width: 12),
                                  const Icon(Icons.flag_outlined, color: Colors.grey),
                                  const SizedBox(width: 6),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text("Category", style: TextStyle(fontSize: 14)),
                                      Text(
                                        snapshot.data?.name ?? "Unknown",
                                        style: const TextStyle(fontSize: 14, color: AppColors.secondary),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                          // SEPARADOR
                          Container(width: 1, height: 40, color: Colors.grey.shade300),

                          // Location
                          FutureBuilder<Location?>(
                            future: _locationController.getLocationById(_event!.location_id),
                            builder: (context, snapshot) {
                              return Row(
                                children: [
                                  const SizedBox(width: 12),
                                  const Icon(Icons.location_on_outlined, color: Colors.grey),
                                  const SizedBox(width: 6),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text("Location", style: TextStyle(fontSize: 14)),
                                      Text(
                                        snapshot.data?.address ?? "Unknown",
                                        style: const TextStyle(fontSize: 14, color: AppColors.secondary),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
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
                      Align(
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
                      const Text("Skills", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 8),
                      FutureBuilder<List<String>>(
                        future: _skillController.getSkillsByIds(_event!.skills),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return const Text("Loading...");
                          return Text(
                            snapshot.data!.join(", "),
                            style: const TextStyle(fontSize: 14, color: AppColors.secondary),
                          );
                        },
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
                      CircleAvatar(
                        radius: 35,
                        backgroundImage: creatorImage.isNotEmpty
                            ? NetworkImage(creatorImage)
                            : null,
                        backgroundColor: Colors.grey.shade200,
                        child: creatorImage.isEmpty
                            ? const Icon(Icons.person, size: 32, color: Colors.grey)
                            : null,
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

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    final profileId = await _profileController.getProfileIdFromUserId(widget.userId);
                    if (profileId != null) {
                      await _eventController.subscribeUserToEvent(widget.eventId, widget.userId); // 👈 ¡CAMBIADO!
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
            ),

          ],
        ),
      ),
    );
  }
}

