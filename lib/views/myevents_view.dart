import 'package:dart_g21/controllers/event_controller.dart';
import 'package:dart_g21/controllers/profile_controller.dart';
import 'package:dart_g21/controllers/user_controller.dart';
import 'package:dart_g21/models/event.dart';
import 'package:dart_g21/models/profile.dart';
import 'package:dart_g21/models/user.dart';
import 'package:flutter/material.dart';
import 'package:dart_g21/core/colors.dart';
import 'package:dart_g21/widgets/navigation_bar_host.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

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

  int selectedIndex = 2; // Índice del ícono seleccionado (My Events)
  List<Event> upcomingEvents = [];
  List<Event> previousEvents = [];
  List<Event> events_created = [];
  String profileId = "";
  String userType= "";


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 40,),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16),
          child: Row(
            children: const [
              Text(
                "My Events",
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      FutureBuilder<User?>(
      future: _userController.getUserById(widget.userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error al cargar el usuario"));
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return Center(child: Text("Usuario no encontrado"));
        }

        User user = snapshot.data!;
        userType = user.userType;

        return SizedBox.shrink(); // Default return to avoid null
      },
        ),

        Expanded(
          child: StreamBuilder<Profile?>(
            stream: _profileController.getProfileByUserId(widget.userId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: \${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data == null) {
                return const Center(child: Text('No profile found'));
              }

              final profile = snapshot.data!;
              profileId = profile.id;

              return FutureBuilder<List<List<Event>>>(
                future: _eventController.getEventsByIds(profile.events_associated).then(
                      (events) => _eventController.classifyEvents(events, widget.userId),
                ),
                builder: (context, eventSnapshot) {
                  if (eventSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (eventSnapshot.hasError) {
                    return Center(child: Text('Error: \${eventSnapshot.error}'));
                  } else if (!eventSnapshot.hasData) {
                    return const Center(child: Text('No events found'));
                  }

                  upcomingEvents = eventSnapshot.data![0];
                  previousEvents = eventSnapshot.data![1];
                  events_created = eventSnapshot.data![2];


                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    children: [
                      buildSectionTitle("Upcoming Events"),
                      ...upcomingEvents.map((event) => buildEventCard(event,profileId)),
                      const SizedBox(height: 20),
                      buildSectionTitle("Previous Events"),
                      ...previousEvents.map((event) => buildEventCard(event,profileId)),
                        const SizedBox(height: 20),
                      userType == "Attendee"
                      ? const SizedBox(height: 20)
                        : buildSectionTitle("Created By Me"),
                      ...events_created.map((event) => buildEventCard(event, profileId)),

                    ],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget buildEventCard(Event event, String profileId) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          print("Evento seleccionado: \${event.name}");
        },
        borderRadius: BorderRadius.circular(12),
        splashColor: Colors.blue.withOpacity(0.2),
        highlightColor: Colors.blue.withOpacity(0.1),
        child: Card(
          margin: EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
          child: Padding(
            padding: EdgeInsets.all(12),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: event.image,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            width: 120,
                            height: 120,
                            color: Colors.grey.shade200,
                            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
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
                      SizedBox(height: 10),
                      if (event.cost != 0)
                        Icon(Icons.payments, color: AppColors.textPrimary),
                    ],
                  ),

                  SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10),
                         Text(
                      "${_formatDate(event.start_date)} - ${_formatTime(event.start_date)}",
                      style: const TextStyle(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                        SizedBox(height: 15),
                        Text(
                          event.name,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),

                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.flag_outlined, color: AppColors.textPrimary),
                        onPressed: () {},
                      ),
                      Spacer(),
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: AppColors.textPrimary),
                        onPressed: () async {
                          print("Eliminando evento: \${event.name}");

                          try {
                            await _profileController.removeEventFromProfile(profileId, event.id);
                            setState(() {
                              upcomingEvents.removeWhere((e) => e.id == event.id);
                              previousEvents.removeWhere((e) => e.id == event.id);
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(" Evento eliminado de My Events"),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          } catch (e) {
                            print("Error al eliminar evento: \$e");
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Error eliminando evento"),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Formatea la fecha en Day, Month Day
  String _formatDate(DateTime date) {
    return "${_getWeekday(date.weekday)}, ${_getMonth(date.month)} ${date.day}";
  }

  ///Formatea la hora en hh:mm AM/PM
  String _formatTime(DateTime date) {
    return "${date.hour % 12 == 0 ? 12 : date.hour % 12}:${date.minute.toString().padLeft(2, '0')} ${date.hour < 12 ? 'AM' : 'PM'}";
  }

  ///Obtiene el nombre del día en inglés
  String _getWeekday(int day) {
    const weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    return weekdays[day - 1];
  }

  ///Obtiene el nombre del mes en inglés
  String _getMonth(int month) {
    const months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return months[month-1];
}

}
