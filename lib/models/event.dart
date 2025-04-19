import 'package:cloud_firestore/cloud_firestore.dart';


class Event {
  String id;
  String name;
  String description;
  DateTime start_date;
  DateTime end_date;
  String image;
  int cost;
  String location_id;  // Se almacena como referencia en Firestore
  String category;     // Se almacena como referencia en Firestore
  List<String> attendees; // Lista de referencias a usuarios en Firestore
  List<String> skills;
  String creator_id; // ID del creador del evento

  Event({
    required this.id,
    required this.name,
    required this.description,
    required this.start_date,
    required this.end_date,
    required this.image,
    required this.cost,
    required this.location_id,
    required this.category,
    required this.attendees,
    required this.skills,
    required this.creator_id,
  });

  // Convertir objeto a Map para Firestore (guardando referencias)
  Map<String, dynamic> toMap() {
    FirebaseFirestore db = FirebaseFirestore.instance;

    return {
      'name': name,
      'description': description,
      'start_date': start_date.toUtc(),
      'end_date': end_date.toUtc(),
      'image': image,
      'cost': cost,
      'location_id': db.collection("locations").doc(location_id), 
      'category': db.collection("categories").doc(category), 
      'attendees': attendees.map((id) => db.collection("users").doc(id)).toList(),
      'skills': skills.map((id) => db.collection("skills").doc(id)).toList(),
      'creator_id': db.collection("users").doc(creator_id), 
    };
  }

  //Convertir Firestore Map a objeto Event (extrayendo los IDs de las referencias)
  factory Event.fromMap(Map<String, dynamic> map, String id) {
    return Event(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      start_date: (map['start_date'] as Timestamp).toDate(),
      end_date: (map['end_date'] as Timestamp).toDate(),
      image: map['image'] ?? '',
      cost: map['cost'] ?? 0,
      location_id: (map['location_id'] is DocumentReference)
          ? (map['location_id'] as DocumentReference).id
          : map['location_id'] ?? '',
      category: (map['category'] is DocumentReference)
          ? (map['category'] as DocumentReference).id
          : map['category'] ?? '',
      attendees: (map['attendees'] as List<dynamic>?)
              ?.map((e) => e is DocumentReference ? e.id : e.toString())
              .toList() ??
          [],
      skills: (map['skills'] as List<dynamic>?)
          ?.map((e) => e is DocumentReference ? e.id : e.toString())
          .toList() ??
          [],
      creator_id: (map['creator_id'] is DocumentReference)
          ? (map['creator_id'] as DocumentReference).id
          : map['creator_id'] ?? '',
    );
  }

  /// Método para convertir el objeto Event en Map
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'image': image,
    'cost': cost,
    'category': category,
    'skills': skills,
    'location_id': location_id,
    'start_date': start_date.toIso8601String(),
    'end_date': end_date.toIso8601String(),
    'description': description,
    'attendees': attendees,
    'creator_id': creator_id,

  };

  /// Método para construir un Event desde Map
  factory Event.fromJson(Map<String, dynamic> json) => Event(
    id: json['id'],
    name: json['name'],
    image: json['image'],
    cost: json['cost'],
    category: json['category'],
    skills: List<String>.from(json['skills']),
    location_id: json['location_id'],
    start_date: DateTime.parse(json['start_date']),
    end_date: DateTime.parse(json['end_date']),
    description: json['description'] ?? '',
    attendees: List<String>.from(json['attendees'] ?? []),
    creator_id: json['creator_id'] ?? '',
  );
}

//