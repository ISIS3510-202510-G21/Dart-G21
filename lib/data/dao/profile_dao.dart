import 'package:dart_g21/models/profile.dart';
import '../database/firestore_service.dart';

class ProfileDAO {
  final FirestoreService _firestore = FirestoreService();
  final String collectionPath = "profiles";

  // 🔥 Obtener perfiles en tiempo real
  Stream<List<Profile>> getProfilesStream() {
    return _firestore.getCollectionStream(collectionPath).map((data) {
      return data.map((doc) => Profile.fromMap(doc, doc["id"])).toList();
    });
  }

  // Obtener un perfil por ID
  Future<Profile?> getProfileById(String profileId) async {
    final doc = await _firestore.getDocumentById(collectionPath, profileId);
    if (doc.exists) {
      return Profile.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  // Agregar un perfil
  Future<void> insertProfile(Profile profile) async {
    await _firestore.addDocument(collectionPath, profile.toMap());
  }

  // Actualizar un perfil
  Future<void> updateProfile(Profile profile) async {
    await _firestore.updateDocument(collectionPath, profile.id, profile.toMap());
  }

  // Eliminar un perfil
  Future<void> deleteProfile(String profileId) async {
    await _firestore.deleteDocument(collectionPath, profileId);
  }
}