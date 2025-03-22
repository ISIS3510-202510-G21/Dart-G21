import 'package:dart_g21/views/createevents_view.dart';
import 'package:dart_g21/views/map_view.dart';
import 'package:dart_g21/views/myevents_view.dart';
import 'package:dart_g21/views/profile_view.dart';
import 'package:flutter/material.dart';
import '../core/colors.dart';

class BottomNavBarHost extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final String id_user;

  const BottomNavBarHost({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.id_user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 5.0,
      elevation: 10.0,
      color: AppColors.primary,
      shadowColor: AppColors.icons,
      child: SizedBox(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home, "Home", 0),
            _buildNavItemRoute(Icons.map, "Map", MapView(), context),
            FloatingActionButton(
              onPressed: () {
                 Navigator.push(
          context,
          MaterialPageRoute(

            builder: (context) => CreateEventScreen(), // HABILITARLO DESPUES PARA Ir a Home 
        ),
      );
                
              },
              backgroundColor: AppColors.secondary,
              shape: CircleBorder(),
              elevation: 10,
              child: const Icon(
                Icons.add,
                color: AppColors.primary,
                size: 40,
              ),
            ),
            _buildNavItemRoute(Icons.event, "My events", MyEventsPage(userId: id_user), context),
            _buildNavItemRoute(Icons.account_circle_outlined, "Profile", ProfilePage(userId: id_user), context),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    return GestureDetector(
      onTap: () => onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            icon,
            color: selectedIndex == index ? AppColors.secondary : AppColors.icons,
            size: 32,
          ),
          SizedBox(height: 0),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: selectedIndex == index ? AppColors.secondary : AppColors.icons,
              ),
            ),
          ),
        ],
      ),
    );
  }


 Widget _buildNavItemRoute(IconData icon, String label, Widget page, BuildContext context) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => page, // Página dinámica
        ),
      );
    },
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(
          icon,
          color: selectedIndex == label ? AppColors.secondary : AppColors.icons,
          size: 32,
        ),
        SizedBox(height: 0),
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: selectedIndex == label ? AppColors.secondary : AppColors.icons,
            ),
          ),
        ),
      ],
    ),
  );
}


}
