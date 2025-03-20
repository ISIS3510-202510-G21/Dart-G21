import 'package:dart_g21/data/dao/event_dao.dart';
import 'package:dart_g21/models/event.dart';

class EventRepository {

  final EventDAO _eventDao = EventDAO(); 

  // Exponer Observer desde DAO
  Stream<List<Event>> getEventsStream() {
    return _eventDao.getEventsStream();
  }

  Future<Event?> getEventById(String eventId) async {
    return await _eventDao.getEventById(eventId);
  }

  Future<void> addEvent(Event event) async {
    await _eventDao.insertEvent(event);
  }

  Future<void> updateEvent(Event event) async {
    await _eventDao.updateEvent(event);
  }

  Future<void> deleteEvent(String eventId) async {
    await _eventDao.deleteEvent(eventId);
  } 
}