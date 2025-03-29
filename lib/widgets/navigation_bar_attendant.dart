import 'package:flutter/material.dart';
import '../core/colors.dart';

class BottomNavBarAttendant extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final String id_user;

  const BottomNavBarAttendant({
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
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home, "Home", 0),
            _buildNavItem(Icons.map, "Map", 1),
            _buildNavItem(Icons.event, "My events", 2),
            _buildNavItem(Icons.account_circle_outlined, "Profile", 3),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            icon,
            color: selectedIndex == index ? AppColors.secondary : AppColors.icons,
            size: 28,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: selectedIndex == index ? AppColors.secondary : AppColors.icons,
            ),
          ),
        ],
      ),
    );
  }
}
