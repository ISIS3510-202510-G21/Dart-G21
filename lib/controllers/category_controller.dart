import 'package:dart_g21/models/category.dart';
import 'package:dart_g21/repositories/category_repository.dart';

class CategoryController {
  final CategoryRepository _categoryRepository = CategoryRepository();

  Stream<List<Category_event>> getCategoriesStream() {
    return _categoryRepository.getCategoriesStream();
  }

  Future<Category_event?> getCategoryById(String categoryId) async {
    return await _categoryRepository.getCategoryById(categoryId);
  }

  Future<void> addCategory(Category_event category) async {
    await _categoryRepository.addCategory(category);
  }

  Future<void> updateCategory(Category_event category) async {
    await _categoryRepository.updateCategory(category);
  }

  Future<void> deleteCategory(String categoryId) async {
    await _categoryRepository.deleteCategory(categoryId);
  }


}