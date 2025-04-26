import 'package:dart_g21/models/profile.dart';
import '../database/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; //esta bien??

class ProfileDAO {
  final FirestoreService _firestore = FirestoreService();
  final String collectionPath = "profiles";

  // Obtener perfiles en tiempo real
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

// Obtener un perfil por ID de usuario
 Stream<Profile?> getProfileByUserId(String userId) {
  return _firestore.getDocumentByField(collectionPath, 'user_ref', userId, 'users').map((doc) => doc != null ? Profile.fromMap(doc as Map<String, dynamic>, doc["id"]) : null);
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

  //actualizar categorías de usuario NUEVOO
  Future<void> updateCategoriesByUserId(String userId, List<String> categoryIds) async {
    try {
      //buscar el doc de perfil cuyo user_ref apunte al usuario con ese ID
      final snapshot = await _firestore
          .getCollection(collectionPath)
          .where("user_ref", isEqualTo: FirebaseFirestore.instance.collection("users").doc(userId))
          .get();

      if (snapshot.docs.isEmpty) {
        throw Exception("Perfil no encontrado para el usuario $userId");
      }

      final docId = snapshot.docs.first.id;

      //actualizar campo interests con referencias a categorías
      await _firestore.updateDocument(collectionPath, docId, {
        "interests": categoryIds
            .map((id) => FirebaseFirestore.instance.collection("categories").doc(id))
            .toList(),
      });

    } catch (e) {
      print("Error en ProfileDAO: $e");
      rethrow;
    }
  }

    //Agregar un evento a un perfil
    Future<void> registerEventToProfile(String profileId, String eventId) async {
      await _firestore.addReferenceToList(
        collectionPath: "profiles",
        docId: profileId,
        field: "events_asociated",
        referenceCollection: "events",
        referenceId: eventId,
      );
    }


  //obtener el ID de perfil a partir del ID de usuario
  Future<String?> getProfileIdByUserId(String userId) async {
    final ref = _firestore.getCollection("profiles");
    final query = await ref.where("user_ref", isEqualTo: _firestore.getCollection("users").doc(userId)).get();

    if (query.docs.isNotEmpty) {
      return query.docs.first.id; // ID del documento en `profiles`
    } else {
      print("No profile found for userId: $userId");
      return null;
    }
  }



}

