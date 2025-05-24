import 'dart:async';
import 'dart:math';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:dart_g21/core/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../controllers/category_controller.dart';
import '../controllers/event_controller.dart';
import '../models/category.dart';
import '../models/event.dart';
import '../widgets/eventcard_view.dart';
import 'eventdetail_view.dart';

class CategoriesFilter extends StatefulWidget {
  final String categoryId;
  final String userId;
  const CategoriesFilter({Key? key, required this.categoryId, required this.userId}) : super(key: key);

  @override
  _CategoriesFilterState createState() => _CategoriesFilterState();
}

class _CategoriesFilterState extends State<CategoriesFilter> {
  final CategoryController _categoryController = CategoryController();
  final EventController _eventController = EventController();

  late final Connectivity _connectivity;
  bool isConnected = true;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  List<bool> isSelected = [false, false];
  String selectedSort = "Soonest to Latest";
  Category_event? _category;

  @override
  void initState() {
    super.initState();
    _checkInitialConnectivityAndLoad();
    setUpConnectivity();
    _loadCategory();
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  void setUpConnectivity() {
    _connectivity = Connectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
        List<ConnectivityResult> results) async {
      final prev = isConnected;
      final currentlyConnected = !results.contains(ConnectivityResult.none);
      if (prev != currentlyConnected) {
        setState(() {
          isConnected = currentlyConnected;
        });
      }
    });
  }
  Future<void> _checkInitialConnectivityAndLoad() async {
    final result = await Connectivity().checkConnectivity();
    setState(() {
      isConnected = !result.contains(ConnectivityResult.none);
    });
    print("Estado inicial de conexión corregido: $isConnected");

    await _loadCategory();
  }

  Future<void> _loadCategory() async {
    Category_event? category;
    if (isConnected) {
      category = await _categoryController.getCategoryById(widget.categoryId);
    } else {
      //category = await _categoryController.getCategoryByIdOffline(widget.categoryId);
      category = await _categoryController.getCategoryByIdOfflineDrift(widget.categoryId);
    }
    if (mounted) {
      setState(() {
        _category = category;
      });
    }
  }

  // Filtros y ordenamiento en memoria
  Future<List<Event>> _applyFiltersAndSort(List<Event> events) {
    return Future.value(events)
        .then((filtered) async {
      if (isSelected[0]) {
        filtered =
        await _eventController.getFreeEventsStream(filtered).first;
      } else if (isSelected[1]) {
        filtered =
        await _eventController.getPaidEventsStream(filtered).first;
      }
      return filtered;
    })
        .then((filtered) {
      return _eventController
          .getEventsSortedByDate(filtered, selectedSort)
          .first;
    })
        .catchError((e, stack) {
      print('Error en _applyFiltersAndSort: $e');
      return <Event>[];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          _category?.name ?? "Category",
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 24),
        ),
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: StreamBuilder<List<Event>>(
              stream: isConnected
                  ? _eventController.getEventsByCategory(widget.categoryId)
                  : _eventController.getEventsByCategoryStreamOffline(widget.categoryId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text("Error loading events"));
                }
                List<Event> events = snapshot.data ?? [];
                return FutureBuilder<List<Event>>(
                  future: _applyFiltersAndSort(events),
                  builder: (context, filteredSnapshot) {
                    if (filteredSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final filteredEvents = filteredSnapshot.data ?? [];
                    if (filteredEvents.isEmpty) {
                      return const Center(child: Text("No events found"));
                    }
                    return ListView.builder(
                      itemCount: filteredEvents.length,
                      itemBuilder: (context, index) {
                        return EventCard(
                          event: filteredEvents[index],
                          onTap: () async {
                            await precacheImage(NetworkImage(filteredEvents[index].image), context);
                            logEventDetailClick(widget.userId, filteredEvents[index].name);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EventDetailScreen(
                                  eventId: filteredEvents[index].id,
                                  userId: widget.userId,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void logEventDetailClick(String userId, String eventName) {
    FirebaseFirestore.instance.collection('eventdetail_clicks').add({
      'user_id': userId,
      'timestamp': FieldValue.serverTimestamp(),
      'name': eventName,
    });
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: [
          _buildFilterButton("Free Events", 0),
          const SizedBox(width: 5),
          _buildFilterButton("Paid Events", 1),
          const SizedBox(width: 5),
          _buildSortMenu(),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label, int index) {
    final bool selected = isSelected[index];
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected[index]) {
            isSelected = [false, false];
          } else {
            isSelected = List.generate(isSelected.length, (i) => i == index);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.secondary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: selected ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildSortMenu() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: PopupMenuButton<String>(
        onSelected: (sortOption) {
          setState(() {
            selectedSort = sortOption;
          });
        },
        itemBuilder: (context) => const [
          PopupMenuItem(value: "Soonest to Latest", child: Text("Soonest to Latest")),
          PopupMenuItem(value: "Latest to Soonest", child: Text("Latest to Soonest")),
        ],
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Text(selectedSort, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ),
    );
  }
}