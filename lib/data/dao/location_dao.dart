import 'package:dart_g21/models/location.dart';
import '../database/firestore_service.dart';

class LocationDAO {
  final FirestoreService _firestore = FirestoreService();
  final String collectionPath = "locations";

  // Obtener ubicaciones en tiempo real
  Stream<List<Location>> getLocationsStream() {
    return _firestore.getCollectionStream(collectionPath).map((data) {
      return data.map((doc) => Location.fromMap(doc, doc["id"])).toList();
    });
  }

  // Obtener ubicación por ID
  Future<Location?> getLocationById(String locationId) async {
    final doc = await _firestore.getDocumentById(collectionPath, locationId);
    if (doc.exists) {
      return Location.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  // Agregar ubicación
  Future<void> insertLocation(Location location) async {
    await _firestore.addDocument(collectionPath, location.toMap());
  }

  // Actualizar ubicación
  Future<void> updateLocation(Location location) async {
    await _firestore.updateDocument(collectionPath, location.id, location.toMap());
  }

  // Eliminar ubicación
  Future<void> deleteLocation(String locationId) async {
    await _firestore.deleteDocument(collectionPath, locationId);
  }
}