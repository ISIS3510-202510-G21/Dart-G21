import 'package:dart_g21/core/colors.dart';
import 'package:dart_g21/screens/home/HomeView.dart';
import 'package:dart_g21/screens/home/bar_categories.dart';
import 'package:dart_g21/screens/home/event_card.dart';
import 'package:dart_g21/screens/home/head.dart';
import 'package:dart_g21/screens/MyEvents/head.dart'; // 🔹 Importa la vista "My Events"
import 'package:dart_g21/widgets/navigation_bar_host.dart';
import 'package:flutter/material.dart';

class HomeAttendant extends StatefulWidget {
  @override
  _HomeAttendantState createState() => _HomeAttendantState();
}

class _HomeAttendantState extends State<HomeAttendant> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,

      body: Stack(
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: [
              HomeView(),
              HomeView(),
              MyEventsPage(title: 'My Events'),
            ],
          ),


          Positioned(
            bottom: 20,
            right: 10,
            child: FloatingActionButton(
              backgroundColor: Colors.transparent,
              elevation: 0,
              onPressed: () {

                print("Chatbot abierto");
              },
              child: Image.asset(
                "lib/assets/chatBot.png",
                width: 60,
                height: 60,
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: BottomNavBarHost(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

}
