import 'package:dart_g21/controllers/event_controller.dart';
import 'package:dart_g21/controllers/profile_controller.dart';
import 'package:dart_g21/controllers/user_controller.dart';
import 'package:dart_g21/models/event.dart';
import 'package:dart_g21/models/profile.dart';
import 'package:flutter/material.dart';
import 'package:dart_g21/core/colors.dart';
import 'package:dart_g21/widgets/navigation_bar_host.dart';

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
  String profileId = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Events", style: TextStyle(fontSize: 24, color: AppColors.textPrimary)),
      ),

      // Cuerpo con lista de eventos
      body: StreamBuilder<Profile?>(
        stream: _profileController.getProfileByUserId(widget.userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('No profile found'));
          } else {
            final profile = snapshot.data!;
            print("Profile: ${profile.events_associated}");
            return FutureBuilder<List<List<Event>>>(
              future: _eventController.getEventsByIds(profile.events_associated).then((events) {
                return _eventController.classifyEvents(events);
              }),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData) {
                  return Center(child: Text('No events found'));
                } else {
                  final classifiedEvents = snapshot.data!;
                  upcomingEvents = classifiedEvents[0];
                  previousEvents = classifiedEvents[1];
                  profileId = profile.id;

                  return ListView(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    children: [
                      //  Sección de Upcoming Events
                      buildSectionTitle("Upcoming Events"),
                      ...upcomingEvents.map((event) => buildEventCard(event, profileId)).toList(),

                      SizedBox(height: 20),

                      //  Sección de Previous Events
                      buildSectionTitle("Previous Events"),
                      ...previousEvents.map((event) => buildEventCard(event, profileId)).toList(),
                    ],
                  );
                }
              },
            );
          }
        },
      ),

      //  Barra de navegación inferior
      // bottomNavigationBar: BottomNavBarHost(
      //   selectedIndex: selectedIndex,
      //   onItemTapped: (index) {
      //     setState(() {
      //       selectedIndex = index;
      //     });
      //   },
      // ),
    );
  }

  // Widget para los títulos de sección ("Upcoming Events", "Previous Events")
  Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }

  //  Widget para cada tarjeta de evento
  Widget buildEventCard(Event event, String profileId) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          print("Evento seleccionado: ${event.name}");
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
                  //  Imagen y pago
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          event.image,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(height: 10),
                      if (event.cost != 0)
                        Icon(Icons.payments, color: AppColors.textPrimary),
                    ],
                  ),

                  SizedBox(width: 12),

                  //  Detalles del evento alineados arriba
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10),
                        Text(
                          event.start_date.toString(),
                          style: TextStyle(fontSize: 12, color: AppColors.secondary),
                        ),
                        SizedBox(height: 15),
                        Text(
                          event.name,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),

                  //  Botones de guardar y eliminar bien alineados
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
                          print("Eliminando evento: ${event.name}");

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
                            print("Error al eliminar evento: $e");
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
}