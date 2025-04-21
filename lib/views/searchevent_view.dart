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

class SearchEventView extends StatefulWidget {
  const SearchEventView({super.key});

  @override
  State<SearchEventView> createState() => _SearchEventViewState();
}

class _SearchEventViewState extends State<SearchEventView> {
  final EventController _eventController = EventController();
  final CategoryController _categoryController = CategoryController();
  final LocationController _locationController = LocationController();
  final SkillController _skillController = SkillController();

  List<Event> allEvents = [];
  List<Event> filteredEvents = [];

  String? selectedType;
  String? selectedCategoryId;
  String? selectedSkillId;
  String? selectedLocation;
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;

  @override
  void initState() {
    super.initState();
    loadInitialEvents();
  }

  Future<void> loadInitialEvents() async {
    final events = await _eventController.getFirstNEvents(20);
    events.sort((a, b) => a.start_date.compareTo(b.start_date));
    setState(() {
      allEvents = events;
      filteredEvents = events;
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
            Align (
              alignment: Alignment.centerLeft,
              child:Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                styledDropdown<String>(
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
                ),
                FutureBuilder(
                  future: _categoryController.getCategoriesStream().first,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox();
                    return styledDropdown<String>(
                      value: selectedCategoryId,
                      hint: "By Category",
                      items: snapshot.data!.map((cat) => DropdownMenuItem(
                        value: cat.id,
                        child: Text(cat.name),
                      )).toList(),
                      onChanged: (value) {
                        setState(() => selectedCategoryId = value);
                        applyFilters();
                      },
                    );
                  },
                ),
                FutureBuilder(
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
                ),
                styledDropdown<String>(
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
                ),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    minimumSize: const Size(157, 48.5),

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

                      style: const TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w500)

                  ),
                ),
                TextButton.icon(
                  onPressed: clearFilters,
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.buttonGreen,
                    foregroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    minimumSize: const Size(157, 48.5),
                  ),
                  icon: const Icon(Icons.clear, color: AppColors.primary),
                  label: const Text("Clear Filters", style: TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w500)),

                ),
              ],
            ),
            ),

            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: filteredEvents.length,
                itemBuilder: (context, index) {
                  final event = filteredEvents[index];
                  //return buildEventCard(event, context);
                  return EventCard(event: event, onTap: () {
                    print("Evento seleccionado: ${event.name}");
                    // Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //         builder: (context) => DetailEventScreen(eventId: event.id), 
                    //       ),
                    // );
                  });
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}