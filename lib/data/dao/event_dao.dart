import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_g21/models/event.dart';


class EventDAO {
  final CollectionReference eventsCollection = FirebaseFirestore.instance.collection('events');

  //Observer Pattern: Stream de usuarios en tiempo real
  Stream<List<Event>> getEventsStream() {
    return eventsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Event.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
    });
  }

  Future<Event?> getEventById(String eventId) async {
    DocumentSnapshot doc = await eventsCollection.doc(eventId).get();
    if (doc.exists) {
      return Event.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  Future<void> insertEvent(Event event) async {
    await eventsCollection.doc(event.id).set(event.toMap());
  }

  Future<void> updateEvent(Event event) async {
    await eventsCollection.doc(event.id).update(event.toMap());
  }

  Future<void> deleteEvent(String eventId) async {
    await eventsCollection.doc(eventId).delete();
  }
}