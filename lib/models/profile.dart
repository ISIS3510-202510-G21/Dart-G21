import 'package:dart_g21/models/event.dart';
import 'package:dart_g21/models/interest.dart';
import 'package:dart_g21/models/user.dart';

class Profile {
  String id;
  String picture;
  String description;
  List<Event> events_asociated;
  List<User> followers;
  List<User> following;
  List<Interest> interests;

  Profile({required this.id, required this.picture, required this.description, required this.events_asociated, required this.followers, required this.following, required this.interests});

  // Convertir objeto a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'picture': picture,
      'description': description,
      'events_asociated': events_asociated,
      'followers': followers,
      'following': following,
      'interests': interests
    };
  }

  // Convertir Firestore Map a objeto User
  factory Profile.fromMap(Map<String, dynamic> map, String id) {
    return Profile(
      id: id,
      picture: map['picture'],
      description: map['description'],
      events_asociated: map['events_asociated'],
      followers: map['followers'],
      following: map['following'],
      interests: map['interests'],
    );
  }
}