import 'dart:collection';

import 'package:dart_g21/views/chatbot_view.dart';
import 'package:dart_g21/views/map_view.dart';
import 'package:dart_g21/views/profile_view.dart';
import 'package:flutter/material.dart';
import '../controllers/category_controller.dart';
import '../controllers/event_controller.dart';
import '../controllers/location_controller.dart';
import '../controllers/user_controller.dart';
import '../models/category.dart';
import '../models/event.dart';
import '../models/user.dart';
import '../widgets/navigation_bar_attendant.dart';
import '../widgets/navigation_bar_host.dart';
import '../core/colors.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:dart_g21/models/location.dart' as app_models;
import 'categoriesfilter_view.dart';
import 'myevents_view.dart';


class HomePage extends StatefulWidget {
  final String userId;

  HomePage({Key? key, required this.userId}) : super(key: key);

  @override
  _HomePage createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  final CategoryController _categoryController = CategoryController();
  final UserController _userController = UserController();
  final EventController _eventController = EventController();
  final List<Color> colors = [
    AppColors.buttonRed,
    AppColors.buttonOrange,
    AppColors.buttonGreen,
    AppColors.buttonLightBlue,
    AppColors.buttonDarkBlue,
    AppColors.buttonPurple
  ];

  /// main view
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      bottomNavigationBar: _buildNavigationBar(),
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: [
              _buildMainContent(),
              MapView(),
              MyEventsPage(userId: widget.userId),
              ProfilePage(userId: widget.userId),
            ],
          ),
          if (_selectedIndex == 0) _buildChatbotButton(),
        ],
      ),

    );
  }
  int _selectedIndex = 0;


  Widget _buildMainContent() {
    return Column(
      children: [
        Container(
          height: 200,
          decoration: const BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 25),
              _buildUpBar(),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSearchBar(),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                _buildBarCategories(),
                SizedBox(height: 10),
                _buildSectionTitle("Upcoming Events"),
                _buildUpcomingEventsList(),
                _buildSectionTitle("Nearby Events"),
                _buildNearbyEventsList(),
                _buildSectionTitle("You Might Like"),
                _buildNearbyEventsRecommend(),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }


  String _location = "Loading location...";

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  /// bottom navigation bar
  Widget _buildNavigationBar() {
    return FutureBuilder<User?>(
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
        return user.userType == "Host"
            ? BottomNavBarHost(selectedIndex: _selectedIndex, onItemTapped: _onItemTapped, id_user: widget.userId)
            : BottomNavBarAttendant(selectedIndex: _selectedIndex, onItemTapped: _onItemTapped, id_user: widget.userId);
      },
    );
  }

  /// bar with categories
  Widget _buildBarCategories() {
    return StreamBuilder<List<Category_event>>(
      stream: _categoryController.getCategoriesStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error al cargar categorías"));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text("No hay categorías disponibles"));
        }

        List<Category_event> categories = snapshot.data!;
        return SizedBox(
          height: 41,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categories.map((category) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CategoriesFilter(categoryId: category.id),
                          ),
                        );
                      },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors[categories.indexOf(category) % colors.length],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(category.name, style: const TextStyle(color: AppColors.primary, fontSize: 15)),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  /// gets user location and turn into location
  Future<void> _determinePosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print("Servicios de ubicación desactivados.");
        setState(() => _location = "Bogotá, Colombia");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print("Permiso de ubicación denegado.");
          setState(() => _location = "Location denied");
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() => _location = "Location denied");
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);


      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks.first;

          String city = place.locality ?? "";
          String state = place.administrativeArea ?? "";
          String country = place.country ?? "Colombia"; // Valor por defecto

          String locationText = city.isNotEmpty ? city : (state.isNotEmpty ? state : country);


          setState(() {
            _location = locationText;
          });
        } else {
          setState(() => _location = "Bogotá, Colombia");
        }
      } catch (geoError) {
        setState(() => _location = "Bogotá, Colombia");
      }
    } catch (e) {
      setState(() => _location = "Bogotá, Colombia");
    }
  }

  /// head bar with location
  Widget _buildUpBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        //const Icon(Icons.menu, color: AppColors.primary, size: 28),
        Column(
          children: [
            const Text(
              "Current Location",
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 12,
              ),
            ),
            Text(
              _location,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ],
        ),
        //const Icon(Icons.account_circle_outlined, color: AppColors.primary, size: 28),
      ],
    );
  }

  /// search bar
  Widget _buildSearchBar() {
    return SizedBox(
      width: 340,
      height: 55,
      child: TextField(
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.transparent,
          hintText: "Search",
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
          prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.7)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: AppColors.primary.withOpacity(0.5),
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: AppColors.primary.withOpacity(0.5),
              width: 2.0,
            ),
          ),
        ),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  /// event card
  Widget _buildEventCard(Event event) {
    return SizedBox(
      width: 257,
      height: 124,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(11),
        elevation: 5,
        color: AppColors.primary,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (event.image.isNotEmpty && Uri.tryParse(event.image)?.hasAbsolutePath == true)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    event.image,
                    width: 220,
                    height: 106,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(width: 220, height: 106, color: Colors.white);
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(width: 220, height: 106, color: Colors.white);
                    },
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16, color: AppColors.secondaryText),
                        const SizedBox(width: 5),
                        Text(
                          "${event.start_date.day}/${event.start_date.month}/${event.start_date.year}",
                          style: const TextStyle(fontSize: 10, color: AppColors.secondaryText),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),

                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: AppColors.secondaryText),
                        const SizedBox(width: 5),
                        Expanded(
                          child: FutureBuilder<app_models.Location?>(
                            future: LocationController().getLocationById(event.location_id),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Text(
                                  "Loading location...",
                                  style: TextStyle(fontSize: 10, color: AppColors.secondaryText),
                                );
                              }
                              if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                                return const Text(
                                  "Unknown location",
                                  style: TextStyle(fontSize: 10, color: AppColors.secondaryText),
                                );
                              }
                              return Text(
                                snapshot.data!.address,
                                style: const TextStyle(fontSize: 10, color: AppColors.secondaryText),
                                maxLines: 1,
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
            ],
          ),
        ),
      ),
    );
  }

  /// title section for events
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// upcoming events list
  Widget _buildUpcomingEventsList() {
    return SizedBox(
      height: 220,
      child: StreamBuilder<List<Event>>(
        stream: EventController().getTop10UpcomingEventsStream(),

        builder: (context, snapshot) {

          print('!!!!1');
          print(EventController().getTop10UpcomingEventsStream());
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("error at charging the events"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No events"));
          }

          List<Event> events = snapshot.data!;

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: events.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(left: 5.0),
                child: _buildEventCard(events[index]),
              );
            },
          );
        },
      ),
    );
  }

  /// nearby events list
  Widget _buildNearbyEventsList() {
    return SizedBox(
      height: 220,
      child: StreamBuilder<List<Event>>(
        stream: EventController().getTopNearbyEventsStream(), 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error al cargar eventos cercanos: ${snapshot.error}",
                style: TextStyle(color: Colors.red),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data == null || snapshot.data!.isEmpty) {
            return const Center(child: Text("No hay eventos cercanos disponibles"));
          }

          List<Event> events = snapshot.data!;

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: events.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(left: 5.0),
                child: _buildEventCard(events[index]),
              );
            },
          );
        },
      ),
    );
  }

 Widget _buildNearbyEventsRecommend() {
  return SizedBox(
    height: 220,
    child: StreamBuilder<List<Event>>(
      stream: EventController().getRecommendedEventsStreamForUser(widget.userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Error al cargar eventos cercanos: ${snapshot.error}",
              style: TextStyle(color: Colors.red),
            ),
          );
        }

        List<Event> events = snapshot.data ?? []; 

        if (events.isEmpty) {
          return StreamBuilder<List<Event>>(
            stream: EventController().getEventsStream(), 
            builder: (context, allSnapshot) {
              if (allSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (allSnapshot.hasError) {
                return Center(
                  child: Text(
                    "Error al cargar eventos: ${allSnapshot.error}",
                    style: TextStyle(color: Colors.red),
                  ),
                );
              }

              List<Event> allEvents = allSnapshot.data ?? [];

              if (allEvents.isEmpty) {
                return const Center(child: Text("No hay eventos disponibles"));
              }

              allEvents = allEvents.take(10).toList();

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: allEvents.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 5.0),
                    child: _buildEventCard(allEvents[index]),
                  );
                },
              );
            },
          );
        }

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: events.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(left: 5.0),
              child: _buildEventCard(events[index]),
            );
          },
        );
      },
    ),
  );
}


  Widget _buildChatbotButton() {
    return Positioned(
      bottom: 20,
      right: 20,
      child: FloatingActionButton(
        backgroundColor: AppColors.secondary,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ChatBotPage(title: "ChatBot",)), 
          );
        },
        child: Image.asset(
          'lib/assets/chatBot.png',
          width: 40,
          height: 40,
        ),
      ),
    );
  }






}