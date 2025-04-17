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
  List<List<Event>> classifyEvents(List<Event> events, String? userId) {
    List<Event> upcomingEvents = [];
    List<Event> previousEvents = [];
    List<Event> userEvents = [];

    for (Event event in events) {
      if (event.start_date.isAfter(DateTime.now())) {
        upcomingEvents.add(event);
        
      } 
      if (event.start_date.isBefore(DateTime.now())) {
        previousEvents.add(event);
      }
      if (userId != null && event.creator_id == userId) {
          userEvents.add(event);
        }
    }

    return [upcomingEvents, previousEvents, userEvents];
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
  Future<List<List<Event>>> classifyEventsByIds(List<String> eventIds, String? userId) async {
    List<Event> events = await getEventsByIds(eventIds);
    return classifyEvents(events, userId);
  }

  ///Obtener eventos proximos a un usuario
  Stream<List<Event>> getTop10UpcomingEventsStream() {
    return getEventsStream().map((events) {
      List<Event> sortedEvents = events
          .where((event) => event.start_date.isAfter(DateTime.now()))
          .toList();

      sortedEvents.sort((a, b) => a.start_date.compareTo(b.start_date));

      return sortedEvents.take(10).toList();
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
          print("Ciudad detectada: $city");
          return city;
        }
      }

      print("No se pudo determinar la ciudad del usuario.");
      return "Desconocido"; 
    } catch (e) {
      print("Error al obtener la ciudad: $e");
      return "Desconocido"; 
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
      await for (List<Event> events in _eventRepository.getEventsStream()) {
        List<Event> bogotaEvents = [];

        for (Event event in events) {
          try {
            final eventLocation = await _locationController.getLocationById(event.location_id);

            if (eventLocation == null) {
              print("Ubicación no encontrada para el evento ${event.id}");
              continue;
            }

            final city = eventLocation.city;

            if (city is String && city.toLowerCase().trim() == "bogotá") {
              bogotaEvents.add(event);
            }

          } catch (error) {
            print("Error al procesar ubicación de evento ${event.id}: $error");
            continue;
          }
        }

        if (bogotaEvents.isEmpty) {
          print("No se encontraron eventos en Bogotá.");
        }

        yield bogotaEvents;
      }
    } catch (error) {
      print("Error general en getBogotaEventsStream: $error");
      yield [];
    }
  }



//Obtener los eventos recomendados para un usuario (user_id) 
Stream<List<Event>> getRecommendedEventsStreamForUser(String userId) {
  return _eventRepository.getRecommendedEventsStreamForUser(userId);
}

 Future<List<Event>> getFirstNEvents(int n) async {
  return await _eventRepository.getFirstNEvents(n);
}

  ///Obtener eventos por categoria (categoryId)
  Stream<List<Event>> getEventsByCategory(String categoryId) {
    return getEventsStream().map((events) {
      List<Event> eventsByCategory = events
          .where((event) => event.category==categoryId)
          .toList();

      return eventsByCategory;
    });
  }

  ///Clasificar eventos de una categoria gratis
  Stream<List<Event>> getFreeEventsStream(List<Event> eventsCategory) {
    return Stream.value(eventsCategory.where((event) => event.cost == 0).toList());
  }

  ///Clasificar eventos de una categoria con costo
  Stream<List<Event>> getPaidEventsStream(List<Event> eventsCategory) {
    return Stream.value(eventsCategory.where((event) => event.cost > 0).toList());
  }

  ///Ordenar eventos de una categoria por fecha
  Stream<List<Event>> getEventsSortedByDate(List<Event> events, String order) {
    if (order == "Soonest to Latest") {
      return Stream.value(events.toList()..sort((a, b) => a.start_date.compareTo(b.start_date)));
    }
    else if (order == "Latest to Soonest") {
      return Stream.value(events.toList()..sort((a, b) => b.start_date.compareTo(a.start_date)));
    }
    else {
      return Stream.value(events);
    }
  }

  //Obtener las cosas filtradas filterEvents
  Future<List<Event>> filterEvents({
    required List<Event> allEvents,
    String? selectedType,
    String? selectedCategoryId,
    String? selectedSkillId,
    String? selectedLocation,
    DateTime? selectedStartDate,
    DateTime? selectedEndDate,
  }) async {
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
      List<String> matchingLocationIds = await _locationController.getLocationIdsByUniversity(
        selectedLocation == 'university');
      result = result.where((e) => matchingLocationIds.contains(e.location_id)).toList();
    }
    if (selectedStartDate != null && selectedEndDate != null) {
      result = result.where((e) =>
        e.start_date.isAfter(selectedStartDate.subtract(const Duration(days: 0))) &&
        e.start_date.isBefore(selectedEndDate.add(const Duration(days: 1)))
      ).toList();
    }

    result.sort((a, b) => a.start_date.compareTo(b.start_date));
    return result;
}





}
