import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dart_g21/models/event.dart';
import 'package:dart_g21/models/category.dart';
import 'package:dart_g21/models/location.dart';
import 'package:dart_g21/models/skill.dart';
import 'package:synchronized/synchronized.dart';

class LocalStorageRepository{
  static final LocalStorageRepository _instance = LocalStorageRepository._internal();

  factory LocalStorageRepository() => _instance;

  LocalStorageRepository._internal();

  late Box _eventBox;
  late Box _categoryBox;
  late Box _skillBox;
  late Box _locationBox;
  late Box _recommendationBox;

  final Lock _lock = Lock();

  Future<void> init() async {
    await Hive.initFlutter();
    _eventBox = await Hive.openBox('local_events');
    _categoryBox = await Hive.openBox('local_categories');
    _skillBox = await Hive.openBox('local_skills');
    _locationBox = await Hive.openBox('local_locations');
    _recommendationBox = await Hive.openBox('local_recommends');
  }

  /// ----------------------- Events ------------------------------
  List<Event> getEvents() {
    return _eventBox.values.map((e) => Event.fromJson(Map<String, dynamic>.from(jsonDecode(e)))).toList()
      ..sort((a, b) => a.start_date.compareTo(b.start_date));
  }

  Future<void> saveEvents(List<Event> events) async {
    await _lock.synchronized(() async {
      for (var event in events) {
        if (!_eventBox.containsKey(event.id)) {
          await _eventBox.put(event.id, jsonEncode(event.toJson()));
        }
      }
    });
  }

  Future<Event?> getEventById(String eventId) async {
    final eventJson = _eventBox.get(eventId);
    if (eventJson != null) {
      return Event.fromJson(Map<String, dynamic>.from(jsonDecode(eventJson)));
    }
    return null;
  }

  /// ----------------------- Categories ------------------------------
  List<Category_event> getCategories() {
    return _categoryBox.values.map((e) => Category_event.fromJson(Map<String, dynamic>.from(jsonDecode(e)))).toList();
  }

  Future<void> saveCategories(List<Category_event> categories) async {
    await _lock.synchronized(() async {
      for (var category in categories) {
        if (!_categoryBox.containsKey(category.id)) {
          await _categoryBox.put(category.id, jsonEncode(category.toJson()));
        }
      }
    });
  }

  /// ----------------------- Skills ------------------------------
  List<Skill> getSkills() {
    return _skillBox.values.map((e) => Skill.fromJson(Map<String, dynamic>.from(jsonDecode(e)))).toList();
  }

  Future<void> saveSkills(List<Skill> skills) async {
    await _lock.synchronized(() async {
      for (var skill in skills) {
        if (!_skillBox.containsKey(skill.id)) {
          await _skillBox.put(skill.id, jsonEncode(skill.toJson()));

        }
      }
    });
  }

  /// ----------------------- Locations ------------------------------
  List<Location> getLocations() {
    return _locationBox.values.map((e) => Location.fromJson(Map<String, dynamic>.from(jsonDecode(e)))).toList();
  }

  Future<void> saveLocations(List<Location> locations) async {
    await _lock.synchronized(() async {
      for (var loc in locations) {
        if (!_locationBox.containsKey(loc.id)) {
          await _locationBox.put(loc.id, jsonEncode(loc.toJson()));
        }
      }
    });
  }

  /// ----------------------- Recommendations ------------------------------
  List<Event> getRecommends() {
    return _recommendationBox.values.map((e) => Event.fromJson(Map<String, dynamic>.from(jsonDecode(e)))).toList()
      ..sort((a, b) => a.start_date.compareTo(b.start_date));
  }

  Future<void> saveRecommends(List<Event> events) async {
    await _lock.synchronized(() async {
      await _recommendationBox.clear();
      for (var event in events) {
        if (!_recommendationBox.containsKey(event.id)) {
          await _recommendationBox.put(event.id, jsonEncode(event.toJson()));
        }
      }
    });
  }



}