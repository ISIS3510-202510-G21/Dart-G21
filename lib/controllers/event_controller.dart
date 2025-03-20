import 'package:dart_g21/models/event.dart';
import 'package:dart_g21/repositories/event_repository.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dart_g21/models/location.dart' as app_models;
import '../controllers/location_controller.dart';

class EventController {
  final EventRepository _eventRepository = EventRepository();
  final LocationController _locationController = LocationController();

  Stream<List<Event>> getEventsStream() {
    return _eventRepository.getEventsStream();
  }

  Future<Event?> getEventById(String eventId) async {
    return await _eventRepository.getEventById(eventId);
  }

  Future<void> addEvent(Event event) async {
    await _eventRepository.addEvent(event);
  }

  Future<void> updateEvent(Event event) async {
    await _eventRepository.updateEvent(event);
  }

  Future<void> deleteEvent(String eventId) async {
    await _eventRepository.deleteEvent(eventId);
  }

  //Clasificar eventos en una lista de eventos futuros y pasados
  List<List<Event>> classifyEvents(List<Event> events) {
    List<Event> upcomingEvents = [];
    List<Event> previousEvents = [];

    for (Event event in events) {
      if (event.start_date.isAfter(DateTime.now())) {
        upcomingEvents.add(event);
      } else {
        previousEvents.add(event);
      }
    }

    return [upcomingEvents, previousEvents];
  }

  //Obtener lista de eventos a partir de una lista de IDs
  Future<List<Event>> getEventsByIds(List<String> eventIds) async {
    List<Event> events = [];

    for (String eventId in eventIds) {
      Event? event = await getEventById(eventId);
      if (event != null) {
        events.add(event);
      }
    }

    return events;
  }

  //Clasificar eventos en una lista de eventos futuros y pasados a partir de una lista de IDs
  Future<List<List<Event>>> classifyEventsByIds(List<String> eventIds) async {
    List<Event> events = await getEventsByIds(eventIds);
    return classifyEvents(events);
  }

  Stream<List<Event>> getTop10UpcomingEventsStream() {
    return getEventsStream().map((events) {
      List<Event> sortedEvents = events
          .where((event) => event.start_date.isAfter(DateTime.now()))
          .toList();

      sortedEvents.sort((a, b) => a.start_date.compareTo(b.start_date));

      return sortedEvents.take(5).toList();
    });
  }

  Future<String> _getUserCity() async {
    Position? position;
    try {
      position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    } catch (e) {
      print("❌ Error obteniendo ubicación: $e");
      return "Desconocido";
    }

    if (position == null) return "Desconocido";

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        String city = placemarks.first.locality ?? "Desconocido";
        print("📍 Ciudad detectada: $city");
        return city;
      }
    } catch (e) {
      print("❌ Error al obtener la ciudad: $e");
    }

    return "Desconocido";
  }


  Future<List<Event>> getTop10NearbyEvents() async {
    String userCity = await _getUserCity(); // Obtener ciudad del usuario

    if (userCity == "Desconocido") {
      print("⚠ No se pudo determinar la ciudad del usuario.");
      return [];
    }

    List<Event> events = await _eventRepository.getEventsStream().first;
    List<Event> cityEvents = [];
    List<Event> otherEvents = [];

    for (Event event in events) {
      if (event.location_id == null || event.location_id.isEmpty) continue;

      app_models.Location? eventLocation = await _locationController.getLocationById(event.location_id);
      if (eventLocation == null) continue;

      // 🔹 Normalizar nombres para evitar problemas de comparación
      String eventCity = eventLocation.city.toLowerCase().trim();
      String userCityNormalized = userCity.toLowerCase().trim();

      if (eventCity.contains(userCityNormalized)) {
        cityEvents.add(event);
      } else {
        otherEvents.add(event);
      }
    }

    // 🔹 Tomar los 10 eventos más cercanos por fecha
    List<Event> sortedEvents = [...cityEvents, ...otherEvents]
        .where((event) => event.start_date.isAfter(DateTime.now()))
        .toList();
    sortedEvents.sort((a, b) => a.start_date.compareTo(b.start_date));

    return sortedEvents.take(10).toList();
  }


}

