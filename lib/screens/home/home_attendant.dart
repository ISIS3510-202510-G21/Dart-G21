import 'package:dart_g21/core/colors.dart';
import 'package:dart_g21/screens/home/bar_categories.dart';
import 'package:dart_g21/screens/home/event_card.dart';
import 'package:dart_g21/screens/home/head.dart';
import 'package:dart_g21/widgets/navigation_bar_host.dart';
import 'package:flutter/material.dart';

class HomeAttendant extends StatefulWidget {
  @override
  _HomeAttendantState createState() => _HomeAttendantState();
}

class _HomeAttendantState extends State<HomeAttendant> {
  int _selectedIndex = 0;
  List<String> categories = ["UI/UX", "Programming", "Art", "Music"];

  // Datos de eventos
  List<Map<String, String>> upcoming = [
    {
      "image": "https://cdn.eventtia.com/event_files/206829/large/alpina-eventos-02.png?1740660481",
      "date": "March 6, 2025",
      "location": "Universidad de los Andes",
      "name": "Presentación Corporativa - Alpina"
    },
    {
      "image": "https://cdn.eventtia.com/banner_images/53244/original/BannersClavesAsambporteven17405043221740504322.jpg?1740504322",
      "date": "March 6, 2025",
      "location": "Universidad de los Andes",
      "name": "Evento derecho ejemplo 2"
    },
  ];

  List<Map<String, String>> nearby = [
    {
      "image": "https://cdn.eventtia.com/banner_images/53603/original/BannersInterEnvironmporteven17407552061740755206.jpg?1740755206",
      "date": "March 12, 2025",
      "location": "Universidad de los Andes",
      "name": "International trade and environment"
    },
    {
      "image": "https://cdn.eventtia.com/event_files/206668/large/feria-laboral-2025-1-banner-formulario.png?1740579857",
      "date": "March 19, 2025",
      "location": "Universidad de los Andes Edificio Santo Domingo",
      "name": "Feria Laboral Alumni 2025-1"
    }
  ];

  List<Map<String, String>> mightLike = [
    {
      "image": "https://cdn.eventtia.com/banner_images/53603/original/BannersInterEnvironmporteven17407552061740755206.jpg?1740755206",
      "date": "March 12, 2025",
      "location": "Universidad de los Andes",
      "name": "International trade and environment"
    },
    {
      "image": "https://cdn.eventtia.com/event_files/206668/large/feria-laboral-2025-1-banner-formulario.png?1740579857",
      "date": "March 19, 2025",
      "location": "Universidad de los Andes Edificio Santo Domingo",
      "name": "Feria Laboral Alumni 2025-1"
    }
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,

      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HeadHome(location: 'Bogota, Colombia'),
            const SizedBox(height: 14),
            BarCategories(categories: categories),
            _buildSectionTitle('Upcoming Events'),
            _buildHorizontalList(upcoming),
            _buildSectionTitle('Nearby Events'),
            _buildHorizontalList(nearby),
            _buildSectionTitle('You Might Like'),
            _buildHorizontalList(mightLike),
            const SizedBox(height: 20),
          ],
        ),
      ),


      bottomNavigationBar: BottomNavBarHost(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

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

  Widget _buildHorizontalList(List<Map<String, String>> events) {
    return SizedBox(
      height: 225,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: events.length,
        itemBuilder: (context, index) {
          return EventCard(event: events[index]);
        },
      ),
    );
  }
}
