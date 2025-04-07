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
    "Engineering": LucideIcons.settings,
    "Leadership": LucideIcons.userCheck,
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
      await _profileController.updateUserCategories(widget.userId, selectedCategories);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Categories saved successfully")),
      );
      Navigator.pop(context);
    } catch (e) {
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
        title: const Text("Select Categories", style: TextStyle(color: AppColors.textPrimary)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text("Choose up to 5 categories you're interested in:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 20),
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
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    children: categories.map((category) {
                      final isSelected = selectedCategories.contains(category.id);
                      final icon = categoryIconMapper[category.name] ?? LucideIcons.tag;
                      return GestureDetector(
                        onTap: () => toggleSelection(category.id),
                        child: Container(
                          constraints: BoxConstraints(maxWidth: 480),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected ? AppColors.secondary : Colors.grey.shade300,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: isSelected ? AppColors.secondary.withOpacity(0.2) : Colors.white,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(icon, size: 40, color: AppColors.secondary),
                              const SizedBox(height: 8),
                              Text(
                                category.name,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
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
            ElevatedButton(
              onPressed: selectedCategories.isEmpty ? null : _saveSelection,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              ),
              child: const Text("Continue", style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
