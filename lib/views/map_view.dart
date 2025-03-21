import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../controllers/event_controller.dart';
import '../controllers/location_controller.dart';
import '../models/event.dart';

class MapView extends StatefulWidget {
  const MapView({Key? key}) : super(key: key);

  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  late GoogleMapController _mapController;
  Set<Marker> _markers = {};
  List<Event> _events = [];

  final EventController _eventController = EventController();
  final LocationController _locationController = LocationController();

  @override
  void initState() {
    super.initState();
    _loadEventsAndMarkers();
  }

  /// 🔹 Carga los eventos y sus marcadores en el mapa
  Future<void> _loadEventsAndMarkers() async {
    List<Event> events = await _eventController.getTop10UpcomingEventsStream().first;
    Set<Marker> markerSet = {};

    for (Event event in events) {
      final coordinates = await _locationController.getCoordinatesFromLocationId(event.location_id);
      if (coordinates != null) {
        markerSet.add(
          Marker(
            markerId: MarkerId(event.id),
            position: coordinates,
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
      _markers = markerSet;
    });
  }

  /// 🔹 Mueve la cámara al evento seleccionado
  void _moveCameraToEvent(String locationId) async {
    final coordinates = await _locationController.getCoordinatesFromLocationId(locationId);
    if (coordinates != null) {
      _mapController.animateCamera(CameraUpdate.newLatLng(coordinates));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Eventos Cercanos")),
      body: Column(
        children: [
          // 📍 Mapa en la mitad superior
          Expanded(
            flex: 1,
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(4.6097, -74.0817), // Bogotá por defecto
                zoom: 12,
              ),
              markers: _markers,
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
            ),
          ),
          // 📜 Lista de eventos en la mitad inferior
          Expanded(
            flex: 1,
            child: _events.isEmpty
                ? const Center(child: Text("No hay eventos disponibles"))
                : ListView.builder(
              itemCount: _events.length,
              itemBuilder: (context, index) {
                Event event = _events[index];
                return _buildEventCard(event);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 Widget de la tarjeta de evento
  Widget _buildEventCard(Event event) {
    return GestureDetector(
      onTap: () => _moveCameraToEvent(event.location_id),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: Image.network(
            event.image,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.image_not_supported, size: 50);
            },
          ),
          title: Text(event.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text("${event.start_date.day}/${event.start_date.month}/${event.start_date.year}"),
          trailing: const Icon(Icons.place, color: Colors.red),
        ),
      ),
    );
  }
}
