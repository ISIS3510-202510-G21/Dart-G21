import 'package:cloud_firestore/cloud_firestore.dart';

class Profile {
  String id;
  String picture;
  String description;
  String headline;
  List<String> events_associated;
  List<String> followers;
  List<String> following;
  List<String> interests;
  String user_ref;

  Profile({
    required this.id,
    required this.picture,
    required this.description,
    required this.headline,
    required this.events_associated,
    required this.followers,
    required this.following,
    required this.interests,
    required this.user_ref,
  });

  // Convertir objeto a Map para Firestore, guardando referencias
  Map<String, dynamic> toMap() {
    FirebaseFirestore _db = FirebaseFirestore.instance;

    return {
      'profile_picture': picture,
      'description': description,
      'headline': headline,
      'events_asociated': events_associated
          .map((id) => _db.collection("events").doc(id)) 
          .toList(),
      'followers': followers
          .map((id) => _db.collection("users").doc(id)) 
          .toList(),
      'following': following
          .map((id) => _db.collection("users").doc(id)) 
          .toList(),
      'interests': interests
          .map((id) => _db.collection("interests").doc(id)) 
          .toList(),
      'user_ref': _db.collection("users").doc(user_ref), 
    };
  }

  // Convertir Firestore Map a objeto Profile, extrayendo los IDs de las referencias
  factory Profile.fromMap(Map<String, dynamic> map, String id) {
    return Profile(
      id: id,
      picture: map['profile_picture'] ?? '',
      description: map['description'] ?? '',
      headline: map['headline'] ?? '',
      events_associated: (map['events_asociated'] as List<dynamic>?)
              ?.map((e) => e is DocumentReference ? e.id : e.toString())
              .toList() ??
          [],
      followers: (map['followers'] as List<dynamic>?)
              ?.map((e) => e is DocumentReference ? e.id : e.toString())
              .toList() ??
          [],
      following: (map['following'] as List<dynamic>?)
              ?.map((e) => e is DocumentReference ? e.id : e.toString())
              .toList() ??
          [],
      interests: (map['interests'] as List<dynamic>?)
              ?.map((e) => e is DocumentReference ? e.id : e.toString())
              .toList() ??
          [],
      user_ref: map['user_ref'] is DocumentReference
          ? (map['user_ref'] as DocumentReference).id
          : map['user_ref'] ?? '',
    );
  }
}
