import 'package:cloud_firestore/cloud_firestore.dart';

class Profile {
  String id;
  String picture;
  String? thumbnail;
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
    required this.thumbnail,
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
      'thumbnail': thumbnail, //agregué esto
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
          .map((id) => _db.collection("categories").doc(id)) 
          .toList(),
      'user_ref': _db.collection("users").doc(user_ref),
    };
  }

  // Convertir Firestore Map a objeto Profile, extrayendo los IDs de las referencias
  factory Profile.fromMap(Map<String, dynamic> map, String id) {
    return Profile(
      id: id,
      picture: map['profile_picture'] ?? '',
      thumbnail: map['thumbnail'] ?? null, //agregué esto
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

   factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      picture: json['profile_picture'] as String,
      thumbnail: json['thumbnail'],
      description: json['description'] as String,
      headline: json['headline'] as String,
      events_associated: List<String>.from(json['events_asociated']),
      followers: List<String>.from(json['followers']),
      following: List<String>.from(json['following']),
      interests: List<String>.from(json['interests']),
      user_ref: json['user_ref'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profile_picture': picture,
      'thumbnail': thumbnail,
      'description': description,
      'headline': headline,
      'events_asociated': events_associated,
      'followers': followers,
      'following': following,
      'interests': interests,
      'user_ref': user_ref,
};}

}
