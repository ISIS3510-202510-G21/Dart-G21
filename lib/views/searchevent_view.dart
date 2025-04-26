import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dart_g21/views/eventdetail_view.dart';
import 'package:dart_g21/widgets/eventcard_view.dart';
import 'package:flutter/material.dart';
import 'package:dart_g21/controllers/event_controller.dart';
import 'package:dart_g21/controllers/category_controller.dart';
import 'package:dart_g21/controllers/location_controller.dart';
import 'package:dart_g21/controllers/skill_controller.dart';
import 'package:dart_g21/models/event.dart';
import 'package:dart_g21/models/category.dart';
import 'package:dart_g21/models/location.dart';
import 'package:dart_g21/models/skill.dart';
import 'package:dart_g21/core/colors.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SearchEventView extends StatefulWidget {
  final String userId;
  const SearchEventView({super.key, required this.userId});

  @override
  State<SearchEventView> createState() => _SearchEventViewState();
}

class _SearchEventViewState extends State<SearchEventView> {
  final EventController _eventController = EventController();
  final CategoryController _categoryController = CategoryController();
  final LocationController _locationController = LocationController();
  final SkillController _skillController = SkillController();
  late final Connectivity _connectivity;

  List<Event> allEvents = [];
  List<Event> filteredEvents = [];
  List<Category_event> localCategories = [];
  List<Skill> localSkills = [];
  List<Location> localLocations = [];

  String? selectedType;
  String? selectedCategoryId;
  String? selectedSkillId;
  String? selectedLocation;
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;

  bool isConnected = true;
  bool isLoading = false;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _setupConnectivity();
    _checkInitialConnectivityAndLoad(); 
  }

void _setupConnectivity() {
  _connectivity = Connectivity();
  _connectivitySubscription = _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) async {
    final prev = isConnected;
    final currentlyConnected = !results.contains(ConnectivityResult.none);

    if (prev != currentlyConnected) {
      setState(() {
        isConnected = currentlyConnected;
      });

      //Recarga datos según el nuevo estado de conexión
      await initHiveAndLoad();

      if (isConnected) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: const Text("Connection Restored", style: TextStyle(color: AppColors.primary, fontSize: 16)),
        //     backgroundColor: const Color.fromARGB(255, 37, 108, 39),
        //     behavior: SnackBarBehavior.floating,
        //     shape: RoundedRectangleBorder(
        //       borderRadius: BorderRadius.circular(12),
        //     ),
        //   ),
        // );
      } else {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: const Text("Connection lost, Offline mode activated", style: TextStyle(color: AppColors.primary, fontSize: 16)),
        //     backgroundColor: AppColors.buttonRed,
        //     behavior: SnackBarBehavior.floating,
        //     shape: RoundedRectangleBorder(
        //       borderRadius: BorderRadius.circular(12),
        //     ),
        //   ),
        // );
      }
    }
  });
}


Future<void> _checkInitialConnectivityAndLoad() async {
  final result = await Connectivity().checkConnectivity();
  setState(() {
    isConnected = !result.contains(ConnectivityResult.none);
  });
  print("Estado inicial de conexión corregido: $isConnected");

  await initHiveAndLoad(); // Ahora sí, después de saber el estado real
}

Future<List<Event>> getCachedEvents5() async {
  final events = await _eventController.getCachedEvents();
  return events.take(5).toList(); // Limitar a 10 eventos aquí
}
Future<void> initHiveAndLoad() async {

   setState(() {
    isLoading = true; // Inicia la carga
  });

  if (!isConnected) {
    final local = await getCachedEvents5(); 
    localCategories = await _categoryController.getCachedCategories();
    localSkills = await _skillController.getCachedSkills();
    localLocations = await _locationController.getCachedLocations();
    local.sort((a, b) => a.start_date.compareTo(b.start_date)); 
    setState(() {
      allEvents = local;
      filteredEvents = local; 
      isLoading = false; 
    });
  } else {
    //final categories = await _categoryController.getCategoriesStream().first;
    final skills = await _skillController.getSkillsStream().first;
    //final locations = await _locationController.getLocationsStream().first;
    final events = await _eventController.getFirstNEvents(20); 

    await _eventController.saveEventsToCache(events.take(5).toList()); 
    //await _categoryController.saveCategoriesToCache(categories);
    await _skillController.saveSkillsToCache(skills);
    //await _locationController.saveLocationsToCache(locations);

    events.sort((a, b) => a.start_date.compareTo(b.start_date));
    setState(() {
      allEvents = events; 
      filteredEvents = events; 
      isLoading = false;
    });
  }
}

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  void applyFiltersOffline() {
    List<Event> result = allEvents;

    if (selectedType != null) {
      result = result.where((e) => selectedType == 'free' ? e.cost == 0 : e.cost > 0).toList();
    }
    if (selectedCategoryId != null) {
      result = result.where((e) => e.category == selectedCategoryId).toList();
    }
    if (selectedSkillId != null) {
      result = result.where((e) => e.skills.contains(selectedSkillId)).toList();
    }
    if (selectedLocation != null) {
      List<String> matchingLocationIds = localLocations
        .where((location) => location.university == (selectedLocation == 'university'))
        .map((location) => location.id)
        .toList();
      result = result.where((e) => matchingLocationIds.contains(e.location_id)).toList();
    }
    if (selectedStartDate != null && selectedEndDate != null) {
      result = result.where((e) =>
        e.start_date.isAfter(selectedStartDate!.subtract(const Duration(days: 0))) &&
        e.start_date.isBefore(selectedEndDate!.add(const Duration(days: 1)))).toList();
    }

    result.sort((a, b) => a.start_date.compareTo(b.start_date));
    setState(() {
      filteredEvents = result;
    });
  }

  void applyFilters() async {
    final result = await _eventController.filterEvents(
      allEvents: allEvents,
      selectedType: selectedType,
      selectedCategoryId: selectedCategoryId,
      selectedSkillId: selectedSkillId,
      selectedLocation: selectedLocation,
      selectedStartDate: selectedStartDate,
      selectedEndDate: selectedEndDate,
    );

    setState(() {
      filteredEvents = result;
    });
  }

  void clearFilters() {
    setState(() {
      selectedType = null;
      selectedCategoryId = null;
      selectedSkillId = null;
      selectedLocation = null;
      selectedStartDate = null;
      selectedEndDate = null;
      filteredEvents = allEvents;
    });
  }

  Widget styledDropdown<T>({
    required T? value,
    required String hint,
    required List<DropdownMenuItem<T>> items,
    required Function(T?) onChanged,
  }) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 120, maxWidth: 150, minHeight: 34, maxHeight: 40), 
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.secondary, 
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            isExpanded: true,
            value: value,
            dropdownColor: AppColors.primary, 
            hint: Text(
              hint,
              style: const TextStyle(color: AppColors.primary, fontSize: 14),
            ),
            items: items.map((item) {
              return DropdownMenuItem<T>(
                value: item.value,
                child: DefaultTextStyle(
                  style: const TextStyle(color: Colors.black),
                  child: item.child,
                ),
              );
            }).toList(),
            onChanged: onChanged,
            iconEnabledColor: AppColors.primary,
            style: const TextStyle(color: AppColors.primary, fontSize: 14),
            selectedItemBuilder: (BuildContext context) {
              return items.map<Widget>((DropdownMenuItem<T> item) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    item.child is Text ? (item.child as Text).data ?? '' : item.value.toString(),
                    style: const TextStyle(color: AppColors.primary, fontSize: 14),
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Search", style: TextStyle(fontSize: 24, color: AppColors.textPrimary)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: "Search....",
                hintStyle: TextStyle(color: AppColors.secondaryText, fontSize: 16),
                prefixIcon: Icon(Icons.search, color: AppColors.secondary),
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
              ),
              onChanged: (value) {
                setState(() {
                  clearFilters();
                  filteredEvents = allEvents
                    .where((e) => e.name.toLowerCase().contains(value.toLowerCase()))
                    .toList();
                });
              },
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    isConnected ? styledDropdown<String>(
                      value: selectedType,
                      hint: "By Type",
                      items: const [
                        DropdownMenuItem(value: 'free', child: Text("Free")),
                        DropdownMenuItem(value: 'paid', child: Text("Paid")),
                      ],
                      onChanged: (value) {
                        setState(() => selectedType = value);
                        applyFilters();
                      },
                    ) : styledDropdown<String>(
                      value: selectedType,
                      hint: "By Type",
                      items: const [
                        DropdownMenuItem(value: 'free', child: Text("Free")),
                        DropdownMenuItem(value: 'paid', child: Text("Paid")),
                      ],
                      onChanged: (value) {
                        setState(() => selectedType = value);
                        applyFiltersOffline();
                      },
                    ),
                    const SizedBox(width: 8),
                    isConnected ? FutureBuilder(
                      future: _categoryController.getCategoriesStream().first.then((categories) {
                      return categories.map((cat) => DropdownMenuItem(
                        value: cat.id,
                        child: Text(cat.name),
                      )).toList();
                      }),
                      builder: (context, snapshot) {
                      if (!snapshot.hasData) return const SizedBox();
                      return styledDropdown<String>(
                        value: selectedCategoryId,
                        hint: "By Category",
                        items: snapshot.data!,
                        onChanged: (value) {
                        setState(() => selectedCategoryId = value);
                        applyFilters();
                        },
                      );
                      },
                    ) : styledDropdown<String>(
                      value: selectedCategoryId,
                      hint: "By Category",
                      items: localCategories.map((cat) => DropdownMenuItem(
                        value: cat.id,
                        child: Text(cat.name),
                      )).toList(),
                      onChanged: (value) {
                        setState(() => selectedCategoryId = value);
                        applyFiltersOffline();
                      },
                    ),
                    const SizedBox(width: 8),
                    isConnected ? FutureBuilder(
                      future: _skillController.getSkillsStream().first,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const SizedBox();
                        return styledDropdown<String>(
                          value: selectedSkillId,
                          hint: "By Skill",
                          items: snapshot.data!.map((skill) => DropdownMenuItem(
                            value: skill.id,
                            child: Text(skill.name),
                          )).toList(),
                          onChanged: (value) {
                            setState(() => selectedSkillId = value);
                            applyFilters();
                          },
                        );
                      },
                    ) : styledDropdown<String>(
                      value: selectedSkillId,
                      hint: "By Skill",
                      items: localSkills.map((skill) => DropdownMenuItem(
                        value: skill.id,
                        child: Text(skill.name),
                      )).toList(),
                      onChanged: (value) {
                        setState(() => selectedSkillId = value);
                        applyFiltersOffline();
                      },
                    ),
                    const SizedBox(width: 8),
                    isConnected ? styledDropdown<String>(
                      value: selectedLocation,
                      hint: "By Location",
                      items: const [
                        DropdownMenuItem(value: 'university', child: Text("University")),
                        DropdownMenuItem(value: 'other', child: Text("Other")),
                      ],
                      onChanged: (value) {
                        setState(() => selectedLocation = value);
                        applyFilters();
                      },
                    ) : styledDropdown<String>(
                      value: selectedLocation,
                      hint: "By Location",
                      items: const [
                        DropdownMenuItem(value: 'university', child: Text("University")),
                        DropdownMenuItem(value: 'other', child: Text("Other")),
                      ],
                      onChanged: (value) {
                        setState(() => selectedLocation = value);
                        applyFiltersOffline();
                      },
                    ),
                    const SizedBox(width: 8),
                    isConnected ? TextButton.icon(
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        minimumSize: const Size(150, 40),
                      ),
                      onPressed: () async {
                        final pickedStart = await showDatePicker(
                          context: context,
                          initialDate: selectedStartDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (pickedStart != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Now select the end date")),
                          );

                          final pickedEnd = await showDatePicker(
                            context: context,
                            initialDate: pickedStart,
                            firstDate: pickedStart,
                            lastDate: DateTime(2100),
                          );
                          if (pickedEnd != null) {
                            if (pickedStart.isAfter(pickedEnd)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Start date must be before end date")),
                              );
                            }
                          }

                          if (pickedEnd != null) {
                            setState(() {
                              selectedStartDate = pickedStart;
                              selectedEndDate = pickedEnd;
                            });
                            applyFilters();
                          }
                        }
                      },
                      icon: const Icon(Icons.date_range, color: AppColors.primary),
                      label: Text(
                        selectedStartDate == null || selectedEndDate == null
                            ? "By Date"
                            : "${selectedStartDate!.day}/${selectedStartDate!.month} - ${selectedEndDate!.day}/${selectedEndDate!.month}",
                        style: const TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ) : TextButton.icon(
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        minimumSize: const Size(150, 40),
                      ),
                      onPressed: () async {
                        final pickedStart = await showDatePicker(
                          context: context,
                          initialDate: selectedStartDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (pickedStart != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Now select the end date")),
                          );

                          final pickedEnd = await showDatePicker(
                            context: context,
                            initialDate: pickedStart,
                            firstDate: pickedStart,
                            lastDate: DateTime(2100),
                          );
                          if (pickedEnd != null) {
                            if (pickedStart.isAfter(pickedEnd)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Start date must be before end date")),
                              );
                            }
                          }

                          if (pickedEnd != null) {
                            setState(() {
                              selectedStartDate = pickedStart;
                              selectedEndDate = pickedEnd;
                            });
                            applyFiltersOffline();
                          }
                        }
                      },
                      icon: const Icon(Icons.date_range, color: AppColors.primary),
                      label: Text(
                        selectedStartDate == null || selectedEndDate == null
                            ? "By Date"
                            : "${selectedStartDate!.day}/${selectedStartDate!.month} - ${selectedEndDate!.day}/${selectedEndDate!.month}",
                        style: const TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: clearFilters,
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.buttonGreen,
                  foregroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  minimumSize: const Size(150, 40),
                ),
                icon: const Icon(Icons.clear, color: AppColors.primary),
                label: const Text("Clear Filters", style: TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w500)),
              ),
            ),
            const SizedBox(height: 20),
          
            isLoading?
                Expanded(
            
                child: Center(
                  child: CircularProgressIndicator(), // Indicador de carga
                ),
                ):
            filteredEvents.isEmpty && allEvents.isNotEmpty?
            Expanded(
              child: Center(
                child: Text("No events found with the selected filters", style: TextStyle(color: AppColors.secondaryText, fontSize: 16)),
              ),):
          
            Expanded(
              child: ListView.builder(
                itemCount: filteredEvents.length,
                itemBuilder: (context, index) {
                  final event = filteredEvents[index];
                  return EventCard(event: event, onTap: () {
                    print("Evento seleccionado: ${event.name}");
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventDetailScreen(eventId: event.id, userId: widget.userId),
                      ),
                    );
                  });
                },
              ),
            ),
          
          ],
        ),
      ),
    );
  }
}