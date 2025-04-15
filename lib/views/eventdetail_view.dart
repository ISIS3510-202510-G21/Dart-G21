/* import 'package:flutter/material.dart';
import 'package:dart_g21/controllers/event_controller.dart';
import 'package:dart_g21/controllers/profile_controller.dart';
import 'package:dart_g21/controllers/user_controller.dart';
import 'package:dart_g21/controllers/category_controller.dart';
import 'package:dart_g21/controllers/location_controller.dart';
import 'package:dart_g21/controllers/skill_controller.dart';
import 'package:dart_g21/models/event.dart';
import 'package:dart_g21/core/colors.dart';

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
  String creatorImage = "";
  String creatorName = "";

  String _formatTimeWithAmPm(DateTime dateTime) {
  final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
  final minute = dateTime.minute.toString().padLeft(2, '0');
  final period = dateTime.hour < 12 ? 'AM' : 'PM';
  return '$hour:$minute $period';
  }

  String _monthName(int month) {
  const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", 
                  "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
  return months[month - 1];
  }


  @override
  void initState() {
    super.initState();
    fetchEventData();
  }

  Future<void> fetchEventData() async {
    final fetchedEvent = await _eventController.getEventById(widget.eventId);
    if (fetchedEvent != null) {
      setState(() {
        _event = fetchedEvent;
      });
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
          creatorName = user?.name ?? "Unknown";
        });
      }
    });
  }

  @override
Widget build(BuildContext context) {
  if (_event == null) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }

  return Scaffold(
    appBar: AppBar(
      title: const Text('Event', style: TextStyle(fontSize: 24, color: Colors.black)),
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
    ),
    body: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen del evento
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              _event!.image,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 16),

          // Título del evento y creador
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: creatorImage.isNotEmpty ? NetworkImage(creatorImage) : null,
                      child: creatorImage.isEmpty ? const Icon(Icons.person, size: 30) : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_event!.name,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text("By $creatorName",
                              style: const TextStyle(fontSize: 14, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          //sección de costos y asistentes
          Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      child: Column(
                        children: [
                          const Icon(Icons.attach_money, color: Colors.grey, size: 28),
                          const SizedBox(height: 6),
                          const Text("Cost",
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                          Text(
                            _event!.cost == 0 ? "FREE" : "\$${_event!.cost}",
                            style: const TextStyle(fontSize: 14, color: Colors.blue),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      child: Column(
                        children: [
                          const Icon(Icons.people_alt_outlined, color: Colors.grey, size: 28),
                          const SizedBox(height: 6),
                          const Text("Attendees",
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                          Text(
                            "${_event!.attendees.length} people",
                            style: const TextStyle(fontSize: 14, color: Colors.blue),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          //tarjeta de detalles del evento: fecha, hora, categoría, skills y ubicación.
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date
                  const Text("Date", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(
                    "${_event!.start_date.day} ${_monthName(_event!.start_date.month)} ${_event!.start_date.year}",
                    style: const TextStyle(color: Colors.black87, fontSize: 14),
                  ),
                  const SizedBox(height: 12),

                  // Time
                  const Text("Time", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(
                    _formatTimeWithAmPm(_event!.start_date),
                    style: const TextStyle(color: Colors.black87, fontSize: 14),
                  ),
                  const SizedBox(height: 12),

                  // Category
                  const Text("Category", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  FutureBuilder(
                    future: _categoryController.getCategoryById(_event!.category),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Text("Loading...");
                      final category = snapshot.data;
                      return Text(
                        category?.name ?? "Unknown",
                        style: const TextStyle(color: Colors.black87, fontSize: 14),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // Skills
                  const Text("Skills", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  FutureBuilder<List<String>>(
                    future: _skillController.getSkillsByIds(_event!.skills),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Text("Loading...");
                      return Text(
                        snapshot.data!.join(", "),
                        style: const TextStyle(color: Colors.black87, fontSize: 14),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // Location
                  const Text("Location", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  FutureBuilder(
                    future: _locationController.getLocationById(_event!.location_id),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Text("Loading...");
                      final location = snapshot.data;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${location?.address}, ${location?.city}",
                              style: const TextStyle(color: Colors.black87, fontSize: 14)),
                          if (location?.details != null && location!.details.isNotEmpty)
                            Text(location.details,
                                style: const TextStyle(color: Colors.black87, fontSize: 14)),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),


                  // Próximas secciones a agregar: costo, categoría, descripción, skills, ubicación, botón...
                ],
              ),
            ),
    );
  }
  
}
 */

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

            // Header Card con nombre, costo, skills
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_event!.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.credit_card, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text(isFree ? "FREE" : "\$${_event!.cost}", style: const TextStyle(fontSize: 14, color: Colors.blue)),
                        const SizedBox(width: 40),
                        const Icon(Icons.tag, color: Colors.grey),
                        const SizedBox(width: 6),
                        Expanded(
                          child: FutureBuilder<List<String>>(
                            future: _skillController.getSkillsByIds(_event!.skills),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) return const Text("Loading...");
                              return Text(
                                snapshot.data!.join(", "),
                                style: const TextStyle(fontSize: 14, color: Colors.blue),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Fecha y hora
            Row(
              children: [
                Expanded(
                  child: Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Text("Start Date", style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(_formatTimeWithAmPm(_event!.start_date), style: const TextStyle(color: Colors.blue)),
                          Text(_formatDate(_event!.start_date)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Text("End Date", style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(_formatTimeWithAmPm(_event!.end_date), style: const TextStyle(color: Colors.blue)),
                          Text(_formatDate(_event!.end_date)),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 12),
              child: Text("$daysLeft days left", style: const TextStyle(color: Colors.red)),
            ),
            const SizedBox(height: 16),

            const Text("Description", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text(_event!.description, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 20),

            const Text("Speaker", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            Row(
              children: [
                CircleAvatar(radius: 30, backgroundImage: NetworkImage(creatorImage)),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Nombre: $creatorName", style: const TextStyle(fontWeight: FontWeight.w500)),
                    Text("Headline: $creatorHeadline"),
                    const Text("Verified ✅"),
                  ],
                )
              ],
            ),

            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Book Event", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }
}

