import 'package:dart_g21/data/database/app_database.dart';
import 'package:dart_g21/models/category.dart';
import 'package:dart_g21/models/location.dart' as model;
import 'package:dart_g21/models/skill.dart' as model;
import 'package:drift/drift.dart';

class DriftRepository {
  final AppDatabase db;
  DriftRepository(this.db);
  List<Category_event> _categories = [];
  // --- CATEGORIES ---


  Future<List<Category_event>> getCategoriesDrift() async {
    final categories = await db.select(db.categories).get();
    _categories = categories.map((c) => Category_event(id: c.id, name: c.name)).toList();
    return categories.map((c) => Category_event(id: c.id, name: c.name)).toList();
  }

  List<Category_event> getListCategoriesDrift() {
    return _categories;
  }

  Future<void> saveCategoriesDrift(List<Category_event> categories) async {
    await db.batch((batch) {
      batch.insertAllOnConflictUpdate(db.categories, categories.map((c) => CategoriesCompanion(
        id: Value(c.id),
        name: Value(c.name),
      )).toList());
    });
  }

  Future<void> saveCategoryDrift(Category_event category) async {
    await db.into(db.categories).insertOnConflictUpdate(CategoriesCompanion(
      id: Value(category.id),
      name: Value(category.name),
    ));
  }

  Future<Category_event?> getCategoryByIdDrift(String id) async {
    final category = await (db.select(db.categories)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
    return category != null ? Category_event(id: category.id, name: category.name) : null;
  }

  // --- SKILLS ---
  Future<List<model.Skill>> getSkillsDrift() async {
    final skills = await db.select(db.skills).get();
    return skills.map((s) => model.Skill(id: s.id, name: s.name)).toList();
  }

  Future<void> saveSkillsDrift(List<model.Skill> skills) async {
    await db.batch((batch) {
      batch.insertAllOnConflictUpdate(db.skills, skills.map((s) => SkillsCompanion(
        id: Value(s.id),
        name: Value(s.name),
      )).toList());
    });
  }

  Future<void> saveSkillDrift(model.Skill skill) async {
    await db.into(db.skills).insertOnConflictUpdate(SkillsCompanion(
      id: Value(skill.id),
      name: Value(skill.name),
    ));
  }

  // --- LOCATIONS ---
  Future<List<model.Location>> getLocationsDrift() async {
    final locations = await db.select(db.locations).get();
    return locations.map((l) => model.Location(
      id: l.id,
      address: l.address,
      city: l.city,
      details: l.details ?? '',
      university: l.university,
      latitude: l.latitude,
      longitude: l.longitude,
    )).toList();
  }

  Future<void> saveLocationsDrift(List<model.Location> locations) async {
    await db.batch((batch) {
      batch.insertAllOnConflictUpdate(db.locations, locations.map((l) => LocationsCompanion(
        id: Value(l.id),
        address: Value(l.address),
        city: Value(l.city),
        details: Value(l.details),
        university: Value(l.university),
        latitude: Value(l.latitude),
        longitude: Value(l.longitude),
      )).toList());
    });
  }

  Future<void> saveLocationDrift(model.Location location) async {
    await db.into(db.locations).insertOnConflictUpdate(LocationsCompanion(
      id: Value(location.id),
      address: Value(location.address),
      city: Value(location.city),
      details: Value(location.details),
      university: Value(location.university),
      latitude: Value(location.latitude),
      longitude: Value(location.longitude),
    ));
  }

  Future<model.Location?> getLocationByIdDrift(String id) async {
    final location = await (db.select(db.locations)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
    return location != null
        ? model.Location(
            id: location.id,
            address: location.address,
            city: location.city,
            details: location.details ?? '',
            university: location.university,
            latitude: location.latitude,
            longitude: location.longitude,
          )
        : null;
  }
}
