import 'package:dart_g21/models/user.dart';

import '../database/firestore_service.dart';


class UserDAO {
  final FirestoreService _firestore = FirestoreService();
  final String collectionPath = "users";

  // Observer Pattern: Escuchar cambios en la colección de usuarios
  Stream<List<User>> getUsersStream() {
    return _firestore.getCollectionStream(collectionPath).map((data) {
      return data.map((doc) => User.fromMap(doc, doc["id"])).toList();
    });
  }

  // Obtener usuario por ID
  Future<User?> getUserById(String userId) async {
    final doc = await _firestore.getDocumentById(collectionPath, userId);
    if (doc.exists) {
      return User.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  // Agregar usuario
  Future<void> insertUser(User user) async {
    await _firestore.addDocument(collectionPath, user.toMap());
  }

  // Actualizar usuario
  Future<void> updateUser(User user) async {
    await _firestore.updateDocument(collectionPath, user.id, user.toMap());
  }

  // Eliminar usuario
  Future<void> deleteUser(String userId) async {
    await _firestore.deleteDocument(collectionPath, userId);
  }

  // Obtener un usuario por email de usuario
  Stream<User?> getUserByEmail(String email) {
    return _firestore
        .getDocumentByFieldOnce(collectionPath, "email", email)
        .map((doc) => doc != null ? User.fromMap(doc as Map<String, dynamic>, doc["id"]) : null);
  }
}