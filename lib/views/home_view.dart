import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dart_g21/views/chatbot_view.dart';
import 'package:dart_g21/views/map_view.dart';
import 'package:dart_g21/views/profile_view.dart';
import 'package:dart_g21/views/searchevent_view.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/auth_controller.dart';
import '../controllers/category_controller.dart';
import '../controllers/event_controller.dart';
import '../controllers/user_controller.dart';
import '../models/category.dart';
import '../models/user.dart';
import '../widgets/eventslist.dart';
import '../widgets/navigation_bar_attendant.dart';
import '../widgets/navigation_bar_host.dart';
import '../core/colors.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

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
  late final Connectivity _connectivity;
  final AuthController _authController = AuthController();

  bool isConnected = true;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
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
              MapView(userId: widget.userId,),
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
                EventsList(
                  eventsStreamProvider: () => isConnected
                      ? _eventController.getUpcomingEventsOnlineStream()
                      : _eventController.getUpcomingEventsOfflineStream(),
                  userId: widget.userId,
                ),
                _buildSectionTitle("Nearby Events"),
                EventsList(
                  eventsStreamProvider: () => isConnected
                      ?_eventController.getTopNearbyEventsOnlineStream(_location)
                      : _eventController.getTopNearbyEventsOfflineStream(_location),
                    userId: widget.userId),
                _buildSectionTitle("You Might Like"),
                EventsList(
                  eventsStreamProvider: () => isConnected
                      ?_eventController.getRecommendedEventsStreamForUserOnline(widget.userId)
                      :_eventController.getRecommendedEventsStreamForUserOffline(),
                    userId: widget.userId
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }


  String _location = "Loading location...";


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
      stream: getCategoriesConnection(),
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
                            builder: (context) => CategoriesFilter(categoryId: category.id, userId: widget.userId,),
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

  Stream<List<Category_event>> getCategoriesConnection(){
    if(isConnected){
      return _categoryController.getCategoriesStream();
    }else{
      return _categoryController.getCategoriesStreamOffline();
    }
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
    return SizedBox(
      height: 60, // Ajusta esta altura según necesites
      child: Stack(
        children: [
          // Ubicación centrada
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
          ),
          // Ícono de configuración en la esquina derecha
          Positioned(
            right: 16,
            top: 16, // Ajusta esta posición según necesites
            child: IconButton(
              icon: const Icon(Icons.logout, color: AppColors.primary, size: 20),
              onPressed: _logout, // <-- Corrección aquí
            ),
          ),
        ],
      ),
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
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SearchEventView(userId: widget.userId,),
            ),
          );
        },

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

  @override
  void initState() {
    super.initState();
    setUpConnectivity();
    _determinePosition();
  }

  void setUpConnectivity() {
    _connectivity = Connectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
        List<ConnectivityResult> results) async {
      final prev = isConnected;
      final currentlyConnected = !results.contains(ConnectivityResult.none);
      if (prev != currentlyConnected) {
        setState(() {
          isConnected = currentlyConnected;
        });
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }


  Future<void> _logout() async {
    try {
      // 1. Cerrar sesión en el backend (por ejemplo, Firebase)
      await _authController.signOut();

      // 2. Limpiar datos locales
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // 3. Redirigir al login
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/signin',
              (route) => false,
        );
      }
    } catch (e) {
      // Manejo de errores
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cerrar sesión: $e')),
        );
      }
    }
  }

}