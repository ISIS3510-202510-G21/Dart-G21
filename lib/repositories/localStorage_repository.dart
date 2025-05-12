import 'dart:convert';
import 'package:dart_g21/controllers/location_controller.dart';
import 'package:dart_g21/controllers/profile_controller.dart';
import 'package:dart_g21/controllers/skill_controller.dart';
import 'package:dart_g21/controllers/user_controller.dart';
import 'package:dart_g21/data/database/app_database.dart';
import 'package:dart_g21/models/profile.dart';
import 'package:dart_g21/models/user.dart';
import 'package:dart_g21/repositories/drift_repository.dart';
import 'package:drift/backends.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dart_g21/models/event.dart';
import 'package:dart_g21/models/category.dart';
import 'package:dart_g21/models/location.dart' as model_location;
import 'package:dart_g21/models/skill.dart' as model_skill;
import 'package:synchronized/synchronized.dart';
import '../models/signup_draft.dart'; 
import '../controllers/category_controller.dart';

class LocalStorageRepository{
  final driftRepository = DriftRepository(AppDatabase());

  static final LocalStorageRepository _instance = LocalStorageRepository._internal();

  factory LocalStorageRepository() => _instance;

  LocalStorageRepository._internal();

  late Box _eventBox;
  late Box _categoryBox;
  late Box _skillBox;
  late Box _locationBox;
  late Box _recommendationBox;
  late Box _profileBox;


  final Lock _lock = Lock();

  Future<void> init() async {
    await Hive.initFlutter();
    _eventBox = await Hive.openBox('local_events');
    _categoryBox = await Hive.openBox('local_categories');
    _skillBox = await Hive.openBox('local_skills');
    _locationBox = await Hive.openBox('local_locations');
    _recommendationBox = await Hive.openBox('local_recommends');
    _profileBox = await Hive.openBox('local_profile');
  }

  /// ----------------------- Events ------------------------------
  List<Event> getEvents() {
    return _eventBox.values.map((e) => Event.fromJson(Map<String, dynamic>.from(jsonDecode(e)))).toList()
      ..sort((a, b) => a.start_date.compareTo(b.start_date));
  }

  Future<void> saveEvents(List<Event> events, CategoryController categoryController,
                          LocationController locationController,
                          ProfileController profileController, UserController userController, SkillController skillController) async {
    await _lock.synchronized(() async {
      for (var event in events) {
        if (!_eventBox.containsKey(event.id)) {
          print("SAVED ${_eventBox.values.length} events");
          // if (_eventBox.values.length >= 10) {
          //   await deleteOldEvents(); // Eliminar el evento más antiguo
          //   print("5 events DELETED");
          // }
          await _eventBox.put(event.id, jsonEncode(event.toJson()));
        }

        Category_event? category = await categoryController.getCategoryById(event.category);
        if (category != null) {
          //saveCategory(category);
          driftRepository.saveCategoryDrift(category);
        }
        model_location.Location? location = (await locationController.getLocationById(event.location_id));
        if (location != null) {
          //saveLocation(location);
          driftRepository.saveLocationDrift(location);
        }
        Profile? profile = await profileController.getProfileByUserId(event.creator_id).first;
        
        if (profile != null) {
          saveProfile(event.creator_id, profile);
          User? user = await userController.getUserById(event.creator_id);
          if (user != null) {
            saveUserName(event.creator_id, user.name);
          }

        }
        if (event.skills != null) {
          for (var skillId in event.skills!) {
            model_skill.Skill? skill = await skillController.getSkillById(skillId);
            if (skill != null) {
              //saveSkill(skill);
              driftRepository.saveSkillDrift(skill);
            }
          }
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

  Stream<List<Event>> getEventsByCategory(String categoryId) async* {
    List<Event> events = getEvents()
        .where((event) => event.category == categoryId)
        .toList();
    yield events;
  }
  
  Stream<List<Event>> getEventsByCity(String cityId) async* {
    List<Event> events = getEvents();
    List<Event> eventsCity=[];
    Event event;
    for (event in events) {
      model_location.Location? location = await getLocationById(event.location_id);
      if (location != null && location.city == cityId) {
        eventsCity.add(event);
      }
    }
  }

  Future<model_location.Location?> getLocationOfEvent(String eventId) async {
    final eventJson = _eventBox.get(eventId);
    model_location.Location? location;
    Event? event;
    if (eventJson != null) {
      event = Event.fromJson(Map<String, dynamic>.from(jsonDecode(eventJson)));
      return location = await getLocationById(event.location_id);
    }
    return null;
  }

  Future<void> saveEventDraft(Event eventDraft) async {
    final box = await Hive.openBox('event_drafts');
    await box.put('current_draft', jsonEncode(eventDraft.toJson()));
  }

  Future<Event?> getEventDraft() async {
    final box = await Hive.openBox('event_drafts');
    if (box.containsKey('current_draft')) {
      final draftJson = box.get('current_draft');
      return Event.fromJson(Map<String, dynamic>.from(jsonDecode(draftJson)));
    }
    return null;
  }


  Future<void> deleteEventDraft() async {
    final box = await Hive.openBox('event_drafts');
    await box.delete('current_draft');
  }

  Future<void> deleteOldEvents() async {
    await _lock.synchronized(() async {
      List<Event> events = getEvents()
          .where((event) => event.start_date.isBefore(DateTime.now()))
          .toList()
        ..sort((a, b) => a.start_date.compareTo(b.start_date));
      for (var i = 0; i < 5 && i < events.length; i++) {
        await _eventBox.delete(events[i].id);
  
      }
    });
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
  Future<void> saveCategory(Category_event category) async {
    await _lock.synchronized(() async {
      if (!_categoryBox.containsKey(category.id)) {
        await _categoryBox.put(category.id, jsonEncode(category.toJson()));
      }
    });
  }

  Future<Category_event?> getCategoryById(String categoryId) async {
    final categoryJson = _categoryBox.get(categoryId);
    if (categoryJson != null) {
      return Category_event.fromJson(Map<String, dynamic>.from(jsonDecode(categoryJson)));
    }
    return null;
  }


  /// ----------------------- Skills ------------------------------
  List<model_skill.Skill> getSkills() {
    return _skillBox.values.map((e) => model_skill.Skill.fromJson(Map<String, dynamic>.from(jsonDecode(e)))).toList();
  }

  Future<void> saveSkills(List<model_skill.Skill> skills) async {
    await _lock.synchronized(() async {
      for (var skill in skills) {
        if (!_skillBox.containsKey(skill.id)) {
          await _skillBox.put(skill.id, jsonEncode(skill.toJson()));

        }
      }
    });
  }

  /// ----------------------- Locations ------------------------------
  List<model_location.Location> getLocations() {
    return _locationBox.values.map((e) => model_location.Location.fromJson(Map<String, dynamic>.from(jsonDecode(e)))).toList();
  }

  Future<void> saveLocations(List<model_location.Location> locations) async {
    await _lock.synchronized(() async {
      for (var loc in locations) {
        if (!_locationBox.containsKey(loc.id)) {
          await _locationBox.put(loc.id, jsonEncode(loc.toJson()));
        }

      }
    });
  }
  Future<void> saveLocation(model_location.Location location) async {
    await _lock.synchronized(() async {
      if (!_locationBox.containsKey(location.id)) {
        await _locationBox.put(location.id, jsonEncode(location.toJson()));
      }
    });
  }



  Future<model_location.Location?> getLocationById(String locationId) async {
    final locationJson = _locationBox.get(locationId);
    if (locationJson != null) {
      return model_location.Location.fromJson(Map<String, dynamic>.from(jsonDecode(locationJson)));
    }
    return null;
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

// ----------------------- Profile ------------------------------

  Future<void> saveProfile(String userId, Profile profile) async {
    await _lock.synchronized(() async {
      if (!_profileBox.containsKey(userId)) {
        await _profileBox.put(userId, jsonEncode(profile.toJson()));
      } 
    });
  }

   Future<Profile?> getProfileByUserId(String userId) async {
    final profileJson = _profileBox.get(userId);
    if (profileJson != null) {
      return Profile.fromJson(Map<String, dynamic>.from(jsonDecode(profileJson)));
    }
    return null;
  }

   Future<void> saveFollowersAndFollowing(String userId, List<String> followers, List<String> following) async {
    await _lock.synchronized(() async {
      if (!_profileBox.containsKey('${userId}_followers')) {
        await _profileBox.put('${userId}_followers', jsonEncode(followers));
      }
      if (!_profileBox.containsKey('${userId}_following')) {
        await _profileBox.put('${userId}_following', jsonEncode(following));
      }
    });
  
  }


  Future<Map<String, List<String>>> getFollowersAndFollowing(String userId) async {
    final followersJson = _profileBox.get('${userId}_followers');
    final followingJson = _profileBox.get('${userId}_following');
    return {
      'followers': followersJson != null ? List<String>.from(jsonDecode(followersJson)) : [],
      'following': followingJson != null ? List<String>.from(jsonDecode(followingJson)) : [],
        };  
}

Future<void> saveUserName(String userId, String userName) async {
    await _lock.synchronized(() async {
      if (!_profileBox.containsKey('${userId}_username')) {
        await _profileBox.put('${userId}_username', jsonEncode(userName));
      }
    });
  }

  Future<String?> getUserName(String userId) async {
    final userNameJson = _profileBox.get('${userId}_username');
    if (userNameJson != null) {
      return jsonDecode(userNameJson);
    }
    return null;
  }

  Future<void> saveLastLoggedInUser({
    required String userId,
    required String email,
    required String name,
  }) async {
    final box = await Hive.openBox('last_user');
    await box.put('userId', userId);
    await box.put('email', email);
    await box.put('name', name);
  }

  Future<Map<String, String>?> getLastLoggedInUser() async {
    final box = await Hive.openBox('last_user');
    if (box.containsKey('userId') && box.containsKey('email') && box.containsKey('name')) {
      return {
        'userId': box.get('userId'),
        'email': box.get('email'),
        'name': box.get('name'),
      };
    }
    return null;
  }

// ------------------- Sign Up Draft -----------------------

Future<void> saveSignUpDraft(SignUpDraft draft) async {
  final box = await Hive.openBox('signup_draft');
  await box.put('data', draft.toJson());
}

Future<SignUpDraft?> getSignUpDraft() async {
  final box = await Hive.openBox('signup_draft');
  final data = box.get('data');
  if (data != null) {
    return SignUpDraft.fromJson(Map<String, dynamic>.from(data));
  }
  return null;
}

Future<void> deleteSignUpDraft() async {
  final box = await Hive.openBox('signup_draft');
  await box.delete('data');
}


}
  
  
