import 'package:dart_g21/data/dao/category_dao.dart';
import 'package:dart_g21/models/category.dart';

class CategoryRepository {

  final CategoryDAO _categoryDao = CategoryDAO();

  // Exponer Observer desde DAO
  Stream<List<Category_event>> getCategoriesStream() {
    return _categoryDao.getCategoriesStream();
  }

  Future<Category_event?> getCategoryById(String categoryId) async {
    return await _categoryDao.getCategoryById(categoryId);
  }

  Future<void> addCategory(Category_event category) async {
    await _categoryDao.insertCategory(category);
  }

  Future<void> updateCategory(Category_event category) async {
    await _categoryDao.updateCategory(category);
  }

  Future<void> deleteCategory(String categoryId) async {
    await _categoryDao.deleteCategory(categoryId);
  }
}