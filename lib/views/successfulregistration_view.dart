import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_g21/core/colors.dart';
import 'package:dart_g21/views/home_view.dart';
import 'package:dart_g21/views/myevents_view.dart';
import 'package:flutter/material.dart';
import 'package:dart_g21/models/event.dart';
import 'package:dart_g21/controllers/profile_controller.dart'; 
import 'package:dart_g21/models/profile.dart'; 
import 'package:dart_g21/controllers/user_controller.dart';
import 'package:dart_g21/models/user.dart'; 
import 'package:dart_g21/controllers/category_controller.dart';
import 'package:dart_g21/models/category.dart';
import 'package:dart_g21/controllers/skill_controller.dart';
import 'package:dart_g21/models/skill.dart';
import 'package:dart_g21/controllers/location_controller.dart';
import 'package:dart_g21/models/location.dart';
import 'package:dart_g21/controllers/event_controller.dart';
import 'package:dart_g21/models/event.dart';



class SuccessfulregistrationView extends StatefulWidget {
  const SuccessfulregistrationView({super.key, required this.eventId, required this.userId});
  final String eventId;
  final String userId;

  @override
  State<SuccessfulregistrationView> createState() => _SuccessfulregistrationViewState();
}

class _SuccessfulregistrationViewState extends State<SuccessfulregistrationView> {
  String creatorImage = '';
  String creatorName = '';
  Event? event;
  final _profileController = ProfileController();
  final _userController = UserController();
  final _eventController = EventController();
  final _categoryController = CategoryController();
  final _skillController = SkillController();
  final _locationController = LocationController();

  @override
  void initState() {
    super.initState();
    fetchEventData();
  }

  Future<void> fetchEventData() async {
    final fetchedEvent = await _eventController.getEventById(widget.eventId);
    if (fetchedEvent != null) {
      setState(() {
        event = fetchedEvent;
      });
      fetchCreatorData(fetchedEvent.creator_id);
    }
  }

  Future<void> fetchCreatorData(String creatorId) async {
    final profileStream = _profileController.getProfileByUserId(creatorId);
    profileStream.listen((profile) async {
      if (profile != null) {
        User? user = await _userController.getUserById(creatorId);
        setState(() {
          creatorImage = profile.picture;
          creatorName = user?.name ?? 'Unknown';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (event == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Event', style: TextStyle(fontSize: 24, color: Colors.black)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final isFree = event!.cost == 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event', style: TextStyle(fontSize: 24, color: Colors.black)),
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back),
        //   onPressed: () => Navigator.pop(context),
        // ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
         SizedBox(
              width: double.infinity,
              height: 106,
              child: Card(
                color: AppColors.buttonGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_box, color: AppColors.primary, size: 35),
                      SizedBox(width: 10),
                      Text(
                        "Event Booked Successfully",
                        style: TextStyle(color: AppColors.primary, fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text("Event Registration Details", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Row(
                  children: [
                    // Foto del creador
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: creatorImage.isNotEmpty
                          ? NetworkImage(creatorImage)
                          : null,
                      child: creatorImage.isEmpty ? const Icon(Icons.person, size: 30) : null,
                    ),
                    const SizedBox(width: 16),

                    // Contenido principal
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Nombre del evento
                          Text(
                            event!.name,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: AppColors.secondaryText),
                          ),
                         
                          // Nombre del creador
                          Text(
                            "By ${creatorName}",
                            style: const TextStyle(color: AppColors.secondaryText, fontSize: 12),
                          ),
                          const SizedBox(height: 12),

                          // Fila con costo y audiencia
                          Row(
                            children: [
                              // Costo
                              Row(
                                children: [
                                  const Icon(Icons.credit_card, size: 25, color: Colors.grey),
                                  const SizedBox(width: 6),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text("Cost", style: TextStyle(color: AppColors.secondaryText, fontWeight: FontWeight.w600, fontSize: 14)),
                                      Text(
                                        isFree ? "FREE" : "\$${event!.cost}",
                                        style: const TextStyle(color: AppColors.secondary, fontSize: 13),
                                      )
                                    ],
                                  ),
                                ],
                              ),

                              const SizedBox(width: 30),

                              // Separador vertical
                              Container(width: 1, height: 30, color: Colors.grey.shade300),

                              const SizedBox(width: 20),

                              Row(
                                children: [
                                  const Icon(Icons.people_alt_outlined, size: 25, color: Colors.grey),
                                  const SizedBox(width: 6),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text("Attendees", style: TextStyle(color: AppColors.secondaryText, fontWeight: FontWeight.w600, fontSize: 14)),
                                      Text(
                                        "${event!.attendees.length} people",
                                        style: const TextStyle(color: AppColors.secondary, fontSize: 13),
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
                  ],
                ),
              ),
            ),

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
                      const Text("Time", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(_formatTimeWithAmPm(event!.start_date), style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),

                      const SizedBox(height: 12),
                      const Text("Date", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text("${event!.start_date.day} ${_monthName(event!.start_date.month)} ${event!.start_date.year}", style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),

                      const SizedBox(height: 12),
                      const Text("Category", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      FutureBuilder(
                        future: _categoryController.getCategoryById(event!.category),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Text("Loading...");
                          } else if (snapshot.hasError) {
                            return const Text("Error loading category");
                          } else {
                            final category = snapshot.data;
                            return Text(category?.name ?? 'Unknown', style: const TextStyle(color: AppColors.textPrimary, fontSize: 14));
                          }
                        },
                      ),

                      const SizedBox(height: 12),
                      const Text("Skills", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        FutureBuilder<List<String>>(
                          future: _skillController.getSkillsByIds(event!.skills),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Text("Loading...");
                            } else if (snapshot.hasError) {
                              return const Text("Error loading skills");
                            } else {
                              final skills = snapshot.data;
                              return Text(
                                skills?.join(", ") ?? 'Unknown',
                                style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                                softWrap: true, //Permite ajuste de línea
                                overflow: TextOverflow.visible,
                              );
                            }
                          },
                        ),

                      const SizedBox(height: 12),
                      const Text("Location", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      FutureBuilder(
                        future: _locationController.getLocationById(event!.location_id),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Text("Loading...");
                          } else if (snapshot.hasError) {
                            return const Text("Error loading location");
                          } else {
                            final location = snapshot.data;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("${location?.address}, ${location?.city}", style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                                if (location?.details != null && location!.details.isNotEmpty)
                                  Text(location.details, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                              ],
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomePage(userId: widget.userId),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.home, color: AppColors.primary, size: 25),
                      SizedBox(width: 10),
                      Text("Home", style: TextStyle(color: AppColors.primary, fontSize: 16)),
        ],
      ),
    ),
  ),
)

          ],
        ),
      ),
    );
  }

  String _monthName(int month) {
    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return months[month - 1];
  }

  String _formatTimeWithAmPm(DateTime dateTime) {
  final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
  final minute = dateTime.minute.toString().padLeft(2, '0');
  final period = dateTime.hour < 12 ? 'AM' : 'PM';
  return '$hour:$minute $period';
}
}
