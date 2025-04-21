import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_g21/core/colors.dart';
import 'package:dart_g21/models/category.dart';
import 'package:dart_g21/models/profile.dart';
import 'package:dart_g21/controllers/profile_controller.dart';
import 'package:dart_g21/controllers/category_controller.dart';
import 'package:lucide_icons/lucide_icons.dart'; // Iconos tipo Material

class SelectCategoriesScreen extends StatefulWidget {
  final String userId;

  const SelectCategoriesScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<SelectCategoriesScreen> createState() => _SelectCategoriesScreenState();
}

class _SelectCategoriesScreenState extends State<SelectCategoriesScreen> {
  final CategoryController _categoryController = CategoryController();
  final ProfileController _profileController = ProfileController();

  List<String> selectedCategories = [];
  final int maxSelection = 5;

  final Map<String, IconData> categoryIconMapper = {
    "Software": LucideIcons.code,
    "Cloud Computing": LucideIcons.cloud,
    "UI/UX Design": LucideIcons.layout,
    "Negotiation": LucideIcons.heartHandshake, //revisar esto
    "Marketing": LucideIcons.badgePercent,
    "Finance": LucideIcons.piggyBank,
    "Public Speaking": LucideIcons.mic,
    "Data Science": LucideIcons.barChart3,
    
    "Leadership": LucideIcons.userCheck,
    "Sports": LucideIcons.activity,
    "Hackatons & Competitions": LucideIcons.trophy,
    "Workshops": LucideIcons.laptop,
    "Career Fairs": LucideIcons.briefcase,
    "Technology & Innovation": LucideIcons.cpu,
    "Science": LucideIcons.beaker,
    "Sustainability & Environment": LucideIcons.leaf,
    "Engineering": LucideIcons.settings,
    "Networking": LucideIcons.users,
    "Research": LucideIcons.search,
    "Entrepreneurship": LucideIcons.briefcase, 
    "SW Develop": LucideIcons.code2,
    "Psychology": LucideIcons.brain,
  };

  void toggleSelection(String categoryId) {
    setState(() {
      if (selectedCategories.contains(categoryId)) {
        selectedCategories.remove(categoryId);
      } else if (selectedCategories.length < maxSelection) {
        selectedCategories.add(categoryId);
      }
    });
  }

  Future<void> _saveSelection() async {
  try {
    print("Saving categories for userId: ${widget.userId}");
    print("Selected categories: $selectedCategories");

    await _profileController.updateUserCategories(widget.userId, selectedCategories);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Categories saved successfully")),
    );
    Navigator.pushReplacementNamed(context, '/home', arguments: widget.userId);
  } catch (e) {
    print("⛔ Error saving categories: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error saving categories")),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(""),
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 0, //ocultar la appbar visualmente
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Choose up to 5 categories you're interested in",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: StreamBuilder<List<Category_event>>(
                stream: _categoryController.getCategoriesStream(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final categories = snapshot.data!;
                  return GridView.count(
                    crossAxisCount: 2,
                    //Aca podemos ajustar tamaño de los cuadros
                    childAspectRatio: 1.0,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: categories.map((category) {
                      final isSelected = selectedCategories.contains(category.id);
                      final icon = categoryIconMapper[category.name] ?? LucideIcons.tag;

                      return GestureDetector(
                        onTap: () => toggleSelection(category.id),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected ? AppColors.secondary : Colors.grey.shade300,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: isSelected ? AppColors.secondary.withOpacity(0.1) : Colors.white,
                          ),
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              //Aca podemos ajustar tamaño de los cuadros
                              Icon(icon, size: 75, color: AppColors.secondary),
                              const SizedBox(height: 10),
                              Text(
                                category.name,
                                textAlign: TextAlign.center,
                                //Aca podemos ajustar tamaño de los cuadros
                                style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: selectedCategories.isEmpty ? null : _saveSelection,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                padding: const EdgeInsets.symmetric(horizontal: 200, vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text(
                "Continue",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}