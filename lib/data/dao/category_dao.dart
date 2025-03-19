import 'package:dart_g21/models/category.dart';
import '../database/firestore_service.dart';

class CategoryDAO {
  final FirestoreService _firestore = FirestoreService();
  final String collectionPath = "categories";

  // Obtener categorías en tiempo real
  Stream<List<Category_event>> getCategoriesStream() {
    return _firestore.getCollectionStream(collectionPath).map((data) {
      return data.map((doc) => Category_event.fromMap(doc, doc["id"])).toList();
    });
  }

  // Obtener categoría por ID
  Future<Category_event?> getCategoryById(String categoryId) async {
    final doc = await _firestore.getDocumentById(collectionPath, categoryId);
    if (doc.exists) {
      return Category_event.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  // Agregar categoría
  Future<void> insertCategory(Category_event category) async {
    await _firestore.addDocument(collectionPath, category.toMap());
  }

  // Actualizar categoría
  Future<void> updateCategory(Category_event category) async {
    await _firestore.updateDocument(collectionPath, category.id, category.toMap());
  }

  // Eliminar categoría
  Future<void> deleteCategory(String categoryId) async {
    await _firestore.deleteDocument(collectionPath, categoryId);
  }
}