import 'package:flutter/material.dart';
import '../../core/colors.dart';

class HeadHome extends StatelessWidget {
  final String location;

  const HeadHome({
    Key? key,
    required this.location,
  }) : super(key: key);

  //Location bar
  Widget _buildUpBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Icon(Icons.menu, color: AppColors.primary, size: 28),
        Column(
          children: [
            const Text(
              "Current Location ▼",
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 12,
              ),
            ),
            Text(
              location,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ],
        ),
        const Icon(Icons.account_circle_outlined, color: AppColors.primary, size: 28),
      ],
    );
  }

  //Search bar
  Widget _buildSearchBar() {
    return Row(
      children: [
        SizedBox(
        width: 240,
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
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: AppColors.primary.withOpacity(0.5),
                  width: 1.5,
                ),
              ),

              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: AppColors.primary.withOpacity(0.5),
                  width: 1.5,
                ),
              ),
            ),
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterButton() {
    return SizedBox(
      height: 55,
      width: 120,// 🔹 Alto fijo del botón
      child: ElevatedButton.icon(
        onPressed: () {
          // Acción cuando se presiona el botón
          //TODO
        },
        icon: Container(
          width: 31,
          height: 31,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary.withOpacity(0.7), width: 2),
            color: Colors.transparent,
          ),
          child: Center(
            child: Icon(
              Icons.filter_list,
              color: AppColors.primary.withOpacity(0.7),
              size: 24,
            ),
          ),
        ),
        label: const Text(
          "Filters",
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 14,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondaryButton,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Container(
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
          SizedBox(height: 25),
          _buildUpBar(),
          SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSearchBar(),
              const SizedBox(width: 0),
              _buildFilterButton(),
            ],
          )
        ],
      ),
    );
  }
}
