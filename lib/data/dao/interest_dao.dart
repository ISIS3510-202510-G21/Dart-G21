import 'package:dart_g21/models/interest.dart';

import '../database/firestore_service.dart';


class InterestDAO {
  final FirestoreService _firestore = FirestoreService();
  final String collectionPath = "interests";

  // 🔥 Obtener intereses en tiempo real
  Stream<List<Interest>> getInterestsStream() {
    return _firestore.getCollectionStream(collectionPath).map((data) {
      return data.map((doc) => Interest.fromMap(doc, doc["id"])).toList();
    });
  }

  // Obtener interés por ID
  Future<Interest?> getInterestById(String interestId) async {
    final doc = await _firestore.getDocumentById(collectionPath, interestId);
    if (doc.exists) {
      return Interest.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  // Agregar interés
  Future<void> insertInterest(Interest interest) async {
    await _firestore.addDocument(collectionPath, interest.toMap());
  }

  //Actualizar interés
  Future<void> updateInterest(Interest interest) async {
    await _firestore.updateDocument(collectionPath, interest.id, interest.toMap());
  }

  //Eliminar interés
  Future<void> deleteInterest(String interestId) async {
    await _firestore.deleteDocument(collectionPath, interestId);
  }
}