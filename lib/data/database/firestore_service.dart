import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  // Singleton para Firestore
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  ///Obtener referencia a una colección
  CollectionReference getCollection(String path) {
    return _db.collection(path);
  }

  ///Agregar un documento (Create)
  Future<void> addDocument(String collectionPath, Map<String, dynamic> data) async {
    await _db.collection(collectionPath).add(data);
  }

  ///Actualizar un documento (Update)
  Future<void> updateDocument(String collectionPath, String docId, Map<String, dynamic> data) async {
    await _db.collection(collectionPath).doc(docId).update(data);
  }

  ///Eliminar un documento (Delete)
  Future<void> deleteDocument(String collectionPath, String docId) async {
    await _db.collection(collectionPath).doc(docId).delete();
  }

  /// Obtener un solo documento por ID (Read)
  Future<DocumentSnapshot> getDocumentById(String collectionPath, String docId) async {
    return await _db.collection(collectionPath).doc(docId).get();
  }

  ///Obtener todos los documentos de una colección como Stream (Observer Pattern)
  Stream<List<Map<String, dynamic>>> getCollectionStream(String collectionPath) {
    return _db.collection(collectionPath).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => {"id": doc.id, ...doc.data() as Map<String, dynamic>}).toList();
    });
  }

  //Obtener un documento por un campo específico
  Future<DocumentSnapshot?> getDocumentByField(String collectionPath, String field, dynamic value) async {
    final snapshot = await _db.collection(collectionPath).where(field, isEqualTo: value).get();
    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first;
    }
    return null;
  }

  ///Filtrar documentos por un campo específico
  Stream<List<Map<String, dynamic>>> queryCollectionStream(
      String collectionPath, String field, dynamic value) {
    return _db.collection(collectionPath).where(field, isEqualTo: value).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => {"id": doc.id, ...doc.data() as Map<String, dynamic>}).toList();
    });
  }
}