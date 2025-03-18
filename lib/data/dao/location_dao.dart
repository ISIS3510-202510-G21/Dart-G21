import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_g21/models/location.dart';


class LocationDAO {
  final CollectionReference locationsCollection = FirebaseFirestore.instance.collection('locations');

  //Observer Pattern: Stream de usuarios en tiempo real
  Stream<List<Location>> getLocationsStream() {
    return locationsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Location.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
    });
  }

  Future<Location?> getLocationById(String locationId) async {
    DocumentSnapshot doc = await locationsCollection.doc(locationId).get();
    if (doc.exists) {
      return Location.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  Future<void> insertLocation(Location location) async {
    await locationsCollection.doc(location.id).set(location.toMap());
  }

  Future<void> updateLocation(Location location) async {
    await locationsCollection.doc(location.id).update(location.toMap());
  }

  Future<void> deleteLocation(String locationId) async {
    await locationsCollection.doc(locationId).delete();
  }
}