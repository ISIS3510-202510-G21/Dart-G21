import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../controllers/event_controller.dart';
import '../controllers/location_controller.dart';
import '../repositories/localStorage_repository.dart';
import '../models/event.dart';
import '../models/location.dart';
import '../core/colors.dart';
import '../widgets/eventcard_view.dart';
import 'eventdetail_view.dart';

class MapView extends StatefulWidget {
  final String userId;
  const MapView({Key? key, required this.userId}) : super(key: key);

  @override
  _MapView createState() => _MapView();
}

// Clase auxiliar para asociar evento y ubicación
class _EventWithLocation {
  final Event event;
  final Location location;
  _EventWithLocation(this.event, this.location);
}

class _MapView extends State<MapView> {
  late GoogleMapController _mapController;
  Set<Marker> _markers = {};
  final EventController _eventController = EventController();
  final LocationController _locationController = LocationController();
  List<Event> _events = [];
  List<_EventWithLocation> _eventsWithLocations = [];

  late final Connectivity _connectivity;
  bool isConnected = true;
  bool _isLoading = true;
  String? _staticMapImagePath;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _connectivity = Connectivity();
    _checkInitialConnectivity();
    _setupConnectivity();
  }

  Future<void> _checkInitialConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    setState(() {
      isConnected = !results.contains(ConnectivityResult.none);
    });
    await _initMapView();
  }

  void _setupConnectivity() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((results) async {
      final wasConnected = isConnected;
      final nowConnected = !results.contains(ConnectivityResult.none);

      if (wasConnected != nowConnected) {
        setState(() {
          isConnected = nowConnected;
          _isLoading = true;
        });
        await _initMapView();
      }
    });
  }

  Future<void> _initMapView() async {
    try {
      if (isConnected) {
        await downloadBogotaMapImageIfNeeded();
        await _loadEventsAndMarkers();
      } else {
        await _loadOfflineBogotaMap();
      }
    } catch (e) {
      print('Error in _initMapView: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadEventsAndMarkers() async {
    try {
      final events = await _eventController.getEventsStream().first;
      final markerList = <Marker>[];

      for (var event in events) {
        final location = await _locationController.getLocationById(event.location_id);
        if (_isValidLocation(location)) {
          markerList.add(_createMarker(event, location!));
        }
      }

      if (mounted) {
        setState(() {
          _events = events;
          _markers = markerList.toSet();
          _staticMapImagePath = null;
          _eventsWithLocations = []; // No se usa en online
        });
      }
    } catch (e) {
      print('Error loading events and markers: $e');
    }
  }

  Future<void> _loadOfflineBogotaMap() async {
    try {
      final path = await getBogotaMapImagePath();
      final file = File(path);

      if (file.existsSync() && await file.length() > 0) {
        _staticMapImagePath = path;
      }


      final eventsStream = _eventController.getBogotaEventsOfflineStream();
      final events = await eventsStream.first;
      final bogotaEvents = events.take(5).toList();


      List<_EventWithLocation> eventsWithLocations = [];
      for (var event in bogotaEvents) {
        final location = await _locationController.getLocationById(event.location_id);
        if (_isValidLocation(location)) {
          eventsWithLocations.add(_EventWithLocation(event, location!));
        }
      }

      if (mounted) {
        setState(() {
          _events = bogotaEvents;
          _eventsWithLocations = eventsWithLocations;
          // _markers no se usa en offline
        });
      }
    } catch (e) {
      print('Error loading offline Bogota map: $e');
      if (mounted) {
        setState(() {
          _events = [];
          _eventsWithLocations = [];
        });
      }
    }
  }

  bool _isValidLocation(Location? location) {
    return location != null && location.latitude != 0.0 && location.longitude != 0.0;
  }

  Marker _createMarker(Event event, Location location, {bool isOffline = false}) {
    return Marker(
      markerId: MarkerId(event.id),
      position: LatLng(location.latitude, location.longitude),
      infoWindow: InfoWindow(
        title: event.name,
        snippet: "${location.address} - ${location.city}",
        // No uses onTap aquí
      ),
      onTap: () {
        // Muestra el AlertDialog al tocar el marcador
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(event.name),
            content: Text(event.description),
            actions: [
              TextButton(
                child: const Text('Show Detail'),
                onPressed: () {
                  Navigator.of(context).pop(); // Cierra el diálogo
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EventDetailScreen(
                        eventId: event.id,
                        userId: widget.userId,
                      ),
                    ),
                  );
                },
              ),
              TextButton(
                child: const Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> downloadBogotaMapImageIfNeeded() async {
    try {
      final path = await getBogotaMapImagePath();
      final file = File(path);

      if (!file.existsSync() || await file.length() == 0) {
        const apiKey = 'AIzaSyD8RLt3b-cIdme2mgw0xqGk-SjdD2kqqa0';
        final url = 'https://maps.googleapis.com/maps/api/staticmap?'
            'center=4.6097,-74.0817&zoom=12&size=800x600&scale=2&key=$apiKey';

        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
          await file.writeAsBytes(response.bodyBytes);
          print('Mapa de Bogotá descargado: $path');
        } else {
          print('Error descargando mapa: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Error downloading map: $e');
    }
  }

  Future<String> getBogotaMapImagePath() async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/bogota_map.png';
  }

  Future<void> _moveCameraToEvent(String locationId) async {
    if (!isConnected) return;

    final location = await _locationController.getLocationById(locationId);
    if (_isValidLocation(location)) {
      _mapController.animateCamera(
          CameraUpdate.newLatLng(LatLng(location!.latitude, location.longitude))
      );
    }
  }

  // Conversión de lat/lng a posición en la imagen
  Offset latLngToOffset({
    required double lat,
    required double lng,
    required double width,
    required double height,
  }) {

    const minLat = 4.55;
    const maxLat = 4.70;
    const minLng = -74.15;
    const maxLng = -74.00;

    final dx = ((lng - minLng) / (maxLng - minLng)) * width;
    final dy = ((maxLat - lat) / (maxLat - minLat)) * height;

    return Offset(dx, dy);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),
        _buildHeader(),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildContent(),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: const BoxDecoration(color: AppColors.primary),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Events Close To You",
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
            ),
          ),
          _buildConnectionStatus(),
        ],
      ),
    );
  }

  Widget _buildConnectionStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isConnected ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isConnected ? "Online" : "Offline",
        style: TextStyle(
          color: isConnected ? Colors.green[700] : Colors.red[700],
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        Expanded(
          flex: 1,
          child: _buildMap(),
        ),
        Expanded(
          flex: 1,
          child: _buildEventsList(),
        ),
      ],
    );
  }

  Widget _buildMap() {
    if (isConnected) {
      return GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(4.6097, -74.0817),
          zoom: 12,
        ),
        markers: _markers,
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },
      );
    } else {
      if (_staticMapImagePath == null) {
        return const Center(child: Text('Mapa offline no disponible'));
      }

      // Tamaño de la imagen (ajusta según tu Static Map)
      const imageWidth = 800.0;
      const imageHeight = 600.0;

      return LayoutBuilder(
        builder: (context, constraints) {
          final scaleX = constraints.maxWidth / imageWidth  ;
          final scaleY = constraints.maxHeight / imageHeight;

          return Stack(
            children: [
              Image.file(
                File(_staticMapImagePath!),
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                fit: BoxFit.cover,
              ),
              ..._eventsWithLocations.map((e) {
                final offset = latLngToOffset(
                  lat: e.location.latitude,
                  lng: e.location.longitude,
                  width: imageWidth,
                  height: imageHeight,
                );
                final left = offset.dx * scaleX;
                final top = offset.dy * scaleY;

                return Positioned(
                  left: left - 16, // Centra el icono
                  top: top - 32,   // Ajusta según el tamaño del icono
                  child: GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text(e.event.name),
                          content: Text(e.event.description),
                          actions: [
                            TextButton(
                              child: const Text('View Detail'),
                              onPressed: () {
                                Navigator.of(context).pop(); // Cierra el diálogo
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EventDetailScreen(
                                      eventId: e.event.id,
                                      userId: widget.userId,
                                    ),
                                  ),
                                );
                              },
                            ),
                            TextButton(
                              child: const Text('Close'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Icon(Icons.location_on, color: Colors.red, size: 32),
                  ),
                );
              }).toList(),
            ],
          );
        },
      );
    }
  }

  Widget _buildEventsList() {
    if (_events.isEmpty) {
      return const Center(
        child: Text(
          'No hay eventos disponibles',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      itemCount: _events.length,
      itemBuilder: (context, index) {
        return EventCard(
          event: _events[index],
          onTap: () {
            if (isConnected) {
              _moveCameraToEvent(_events[index].location_id);
            }
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }
}