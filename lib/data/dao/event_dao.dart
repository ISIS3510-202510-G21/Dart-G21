import 'package:dart_g21/models/event.dart';
import '../database/firestore_service.dart';

class EventDAO {
  final FirestoreService _firestore = FirestoreService();
  final String collectionPath = "events";

  //  Obtener eventos en tiempo real
  Stream<List<Event>> getEventsStream() {
    return _firestore.getCollectionStream(collectionPath).map((data) {
      return data.map((doc) => Event.fromMap(doc, doc["id"])).toList();
    });
  }

  // Obtener evento por ID
  Future<Event?> getEventById(String eventId) async {
    final doc = await _firestore.getDocumentById(collectionPath, eventId);
    if (doc.exists) {
      return Event.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  // Agregar evento
  Future<void> insertEvent(Event event) async {
    await _firestore.addDocument(collectionPath, event.toMap());
  }

  //Actualizar evento
  Future<void> updateEvent(Event event) async {
    await _firestore.updateDocument(collectionPath, event.id, event.toMap());
  }

  //Eliminar evento
  Future<void> deleteEvent(String eventId) async {
    await _firestore.deleteDocument(collectionPath, eventId);
  }

  // Obtener eventos recomendados para un usuario
  Stream<List<Event>> getRecommendedEventsStreamForUser(String userId) {
  return _firestore
      .getDocumentById("users", userId)
      .asStream()
      .asyncMap((doc) async {
        if (!doc.exists || doc.data() == null) {
          return [];
        }

        // Obtener lista de IDs de eventos
        final List<String> eventIds = List<String>.from((doc.data() as Map<String, dynamic>)["recommended_events"] ?? []);

        // Obtener detalles de los eventos en paralelo
        List<Event?> events = await Future.wait(
          eventIds.map((eventId) async => await getEventById(eventId)),
        );

        return events.whereType<Event>().toList(); // Filtrar eventos válidos
      });
}

}