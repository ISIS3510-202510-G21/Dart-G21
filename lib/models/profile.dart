import 'package:dart_g21/models/event.dart';
import 'package:dart_g21/models/interest.dart';
import 'package:dart_g21/models/user.dart';
class Profile {
  String id;
  String picture;
  String description;
  String headline;
  List<String> events_associated;  
  List<String> followers;  
  List<String> following;  
  List<String> interests;  
  String user_ref;  // Referencia al usuario propietario

  Profile({required this.id, required this.picture, required this.description, required this.headline, required this.events_associated, required this.followers, required this.following, required this.interests, required this.user_ref,});

  // Convertir objeto a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'picture': picture,
      'description': description,
      'headline': headline,
      'events_associated': events_associated,  
      'followers': followers,
      'following': following,
      'interests': interests,
      'user_ref': user_ref,
    };
  }

  // Convertir Firestore Map a objeto Profile
  factory Profile.fromMap(Map<String, dynamic> map, String id) {
    return Profile(
      id: id,
      picture: map['picture'] ?? '',
      description: map['description'] ?? '',
      headline: map['headline'] ?? '',
      events_associated: List<String>.from(map['events_associated'] ?? []),
      followers: List<String>.from(map['followers'] ?? []),
      following: List<String>.from(map['following'] ?? []),
      interests: List<String>.from(map['interests'] ?? []),
      user_ref: map['user_ref'] ?? '',
    );
  }
}
