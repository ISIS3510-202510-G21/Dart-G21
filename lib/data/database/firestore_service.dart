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
Stream<Map<String, dynamic>?> getDocumentByField(
    String collectionPath, String field, String value, String collectionRef) {
  
  // Convertir el String en un DocumentReference
  DocumentReference ref = _db.collection(collectionRef).doc(value);
  
  print("Buscando en $collectionPath donde $field == ${ref.path}");

  return _db
      .collection(collectionPath)
      .where(field, isEqualTo: ref)
      .snapshots()
      .map((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          print(" Documento encontrado: ${snapshot.docs.first.data()}");
          var doc = snapshot.docs.first;
          return {"id": doc.id, ...doc.data() as Map<String, dynamic>}; 
        } else {
          print(" No se encontró ningún documento con $field == ${ref.path}");
          return null;
        }
      }).handleError((error) {
        print("Error en Firestore: $error");
      });
}


  ///Filtrar documentos por un campo específico
  Stream<List<Map<String, dynamic>>> queryCollectionStream(
      String collectionPath, String field, dynamic value) {
    return _db.collection(collectionPath).where(field, isEqualTo: value).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => {"id": doc.id, ...doc.data() as Map<String, dynamic>}).toList();
    });
  }

  ///Obtener un documento por un campo específico
  Stream<Map<String, dynamic>?> getDocumentByFieldOnce(String collectionPath, String field, dynamic value) {
    return _db.collection(collectionPath).where(field, isEqualTo: value).snapshots().map((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          print(" Documento encontrado: ${snapshot.docs.first.data()}");
          var doc = snapshot.docs.first;
          return {"id": doc.id, ...doc.data() as Map<String, dynamic>}; 
        } else {
          print(" No se encontró ningún documento con $field == ${value}");
          return null;
        }
      }).handleError((error) {
        print("Error en Firestore: $error");
      });
  }




}

