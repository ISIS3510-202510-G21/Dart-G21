import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_g21/models/category.dart';


class CategoryDAO {
  final CollectionReference categoriesCollection = FirebaseFirestore.instance.collection('categories');

  //Observer Pattern: Stream de usuarios en tiempo real
  Stream<List<Category_event>> getCategoriesStream() {
    return categoriesCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Category_event.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
    });
  }

  Future<Category_event?> getCategoryById(String categoryId) async {
    DocumentSnapshot doc = await categoriesCollection.doc(categoryId).get();
    if (doc.exists) {
      return Category_event.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  Future<void> insertCategory(Category_event category) async {
    await categoriesCollection.doc(category.id).set(category.toMap());
  }

  Future<void> updateCategory(Category_event category) async {
    await categoriesCollection.doc(category.id).update(category.toMap());
  }

  Future<void> deleteCategory(String categoryId) async {
    await categoriesCollection.doc(categoryId).delete();
  }
}