import 'package:flutter/material.dart';
import '../core/colors.dart';

class BottomNavBarHost extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const BottomNavBarHost({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 5.0,
      elevation: 8.0,
      color: AppColors.primary,
      shadowColor: AppColors.icons,
      child: SizedBox(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home, "Home", 0),
            _buildNavItem(Icons.map, "Map", 1),
            FloatingActionButton(
              onPressed: () {
                // Acción cuando se presiona el botón
                // TODO
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
}
