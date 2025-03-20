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
    );
  }
}