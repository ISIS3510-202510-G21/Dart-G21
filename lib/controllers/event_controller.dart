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

  ///Obtener eventos proximos a un usuario
  Stream<List<Event>> getTop10UpcomingEventsStream() {
    return getEventsStream().map((events) {
      List<Event> sortedEvents = events
          .where((event) => event.start_date.isAfter(DateTime.now()))
          .toList();

      sortedEvents.sort((a, b) => a.start_date.compareTo(b.start_date));

      return sortedEvents.take(5).toList();
    });
  }

  ///Obtener ciudad del usuario
  Future<String> _getUserCity() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return "Desconocido"; // 🔹 Retornar "Desconocido" si el GPS está apagado
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return "Desconocido";
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return "Desconocido";
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String city = place.locality ?? place.subAdministrativeArea ?? place.administrativeArea ?? "";

        if (city.isNotEmpty) {
          print("📍 Ciudad detectada: $city");
          return city;
        }
      }

      print("⚠ No se pudo determinar la ciudad del usuario.");
      return "Desconocido"; // 🔹 Si no encuentra la ciudad, retornar "Desconocido"
    } catch (e) {
      print("❌ Error al obtener la ciudad: $e");
      return "Desconocido"; // 🔹 Manejo de error: retornar "Desconocido"
    }
  }

  ///Obtener eventos proximos a un usuario según gps
  Stream<List<Event>> getTopNearbyEventsStream() async* {
    try {
      String userCity = await _getUserCity();

      if (userCity == "Desconocido") {

        yield* getBogotaEventsStream();
        return;
      }

      await for (List<Event> events in _eventRepository.getEventsStream()) {
        if (events.isEmpty) {
          continue;
        }

        List<Event> cityEvents = [];

        for (Event event in events) {
          try {
            if (event.location_id == null || event.location_id.isEmpty) continue;

            app_models.Location? eventLocation =
            await _locationController.getLocationById(event.location_id);

            if (eventLocation == null || eventLocation.city == null) {
              continue;
            }

            if (eventLocation.city.toLowerCase().trim() ==
                userCity.toLowerCase().trim()) {
              cityEvents.add(event);
            }
          } catch (error) {
            continue;
          }
        }

        if (cityEvents.isEmpty) {
          yield* getBogotaEventsStream();
        } else {
          yield cityEvents.take(10).toList();
        }
      }
    } catch (error) {
      yield* getBogotaEventsStream();
    }
  }

  ///Obtner eventos en Bogota
  Stream<List<Event>> getBogotaEventsStream() async* {
    try {
      yield await _eventRepository.getEventsStream().asyncMap((events) async {
        List<Event> bogotaEvents = [];

        for (Event event in events) {
          try {
            app_models.Location? eventLocation =
            await _locationController.getLocationById(event.location_id);

            if (eventLocation == null || eventLocation.city == null) {
              print("Ubicación no encontrada para el evento ${event.id}");
              continue;
            }

            bool esBogota = eventLocation.city?.toLowerCase().trim() == "bogotá";

            if (esBogota) {
              bogotaEvents.add(event);
            }
          } catch (error) {
            continue;
          }
        }

        if (bogotaEvents.isEmpty) {
          print("No se encontraron eventos en Bogotá.");
        }
        return bogotaEvents;
      }).first;
    } catch (error) {
      print("Error general en getBogotaEventsStream: $error");
      yield [];
    }
  }






}

