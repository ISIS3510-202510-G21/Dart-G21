import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../controllers/event_controller.dart';
import '../controllers/location_controller.dart';
import '../core/colors.dart';
import '../models/event.dart';

class MapView extends StatefulWidget {
  const MapView({Key? key}) : super(key: key);

  @override
  _MapView createState() => _MapView();
}

class _MapView extends State<MapView> {
  late GoogleMapController _mapController;
  Set<Marker> _markers = {};
  final EventController _eventController = EventController();
  final LocationController _locationController = LocationController();
  List<Event> _events = [];

  @override
  void initState() {
    super.initState();
    _loadEventsAndMarkers();
  }

  /// Carga los eventos y coloca marcadores en el mapa
  Future<void> _loadEventsAndMarkers() async {
    List<Event> events = await _eventController
        .getTopNearbyEventsStream()
        .first;
    List<Marker> markerList = [];

    for (Event event in events) {
      final coordinates = await _locationController
          .getCoordinatesFromLocationId(event.location_id);
      if (coordinates != null) {
        markerList.add(
          Marker(
            markerId: MarkerId(event.id),
            position: coordinates,
            infoWindow: InfoWindow(
              title: event.name,
              snippet: "${event.start_date.day}/${event.start_date
                  .month}/${event.start_date.year}",
            ),
          ),
        );
      }
    }

    setState(() {
      _events = events;
      _markers = markerList.toSet();
    });
  }

  /// Mueve la cámara al evento seleccionado
  Future<void> _moveCameraToEvent(String locationId) async {
    final coordinates = await _locationController.getCoordinatesFromLocationId(
        locationId);
    if (coordinates != null) {
      _mapController.animateCamera(CameraUpdate.newLatLng(coordinates));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 40,),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: const BoxDecoration(
            color: AppColors.primary,
          ),
          child: const Text(
            "Events Close To You",
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
            ),
          ),
        ),

        Expanded(
          child: Column(
            children: [
              Expanded(
                flex: 1,
                child: GoogleMap(
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(4.6097, -74.0817), // Bogotá
                    zoom: 12,
                  ),
                  markers: _markers,
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;
                  },
                ),
              ),
              Expanded(
                flex: 1,
                child: _events.isEmpty
                    ? const Center(child: Text("charging----"))
                    : ListView.builder(
                  itemCount: _events.length,
                  itemBuilder: (context, index) {
                    return EventCard(
                      event: _events[index],
                      onTap: () =>
                          _moveCameraToEvent(_events[index].location_id),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback? onTap;

  const EventCard({Key? key, required this.event, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // 📌 Mueve la cámara cuando se toca
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  event.image,
                  width: 79,
                  height: 92,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 79,
                      height: 92,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${_formatDate(event.start_date)} - ${_formatTime(event.start_date)}",
                      style: const TextStyle(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      event.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Formatea la fecha en `Day, Month Day`
  String _formatDate(DateTime date) {
    return "${_getWeekday(date.weekday)}, ${_getMonth(date.month)} ${date.day}";
  }

  ///Formatea la hora en `hh:mm AM/PM`
  String _formatTime(DateTime date) {
    return "${date.hour % 12 == 0 ? 12 : date.hour % 12}:${date.minute.toString().padLeft(2, '0')} ${date.hour < 12 ? 'AM' : 'PM'}";
  }

  ///Obtiene el nombre del día en inglés
  String _getWeekday(int day) {
    const weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    return weekdays[day - 1];
  }

  ///Obtiene el nombre del mes en inglés
  String _getMonth(int month) {
    const months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return months[month - 1];
  }
}
