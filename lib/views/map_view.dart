import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../controllers/event_controller.dart';
import '../controllers/location_controller.dart';
import '../core/colors.dart';
import '../models/event.dart';
import '../widgets/eventcard_view.dart';

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
    List<Event> events = await _eventController.getTopNearbyEventsStream().first;
    List<Marker> markerList = [];

    for (Event event in events) {
      final location = await _locationController.getLocationById(event.location_id);

      if (location != null && location.latitude != 0.0 && location.longitude != 0.0) {
        markerList.add(
          Marker(
            markerId: MarkerId(event.id),
            position: LatLng(location.latitude, location.longitude),
            infoWindow: InfoWindow(
              title: event.name,
              snippet: "${event.start_date.day}/${event.start_date.month}/${event.start_date.year}",
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
    final location = await _locationController.getLocationById(locationId);
    if (location != null && location.latitude != 0.0 && location.longitude != 0.0) {
      _mapController.animateCamera(CameraUpdate.newLatLng(LatLng(location.latitude,location.longitude)));
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
                    ? const Center(child: Text("charging..."))
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


