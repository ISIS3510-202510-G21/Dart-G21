import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_g21/models/category.dart';
import 'package:dart_g21/models/location.dart';
import 'package:dart_g21/models/user.dart';
import 'package:flutter/foundation.dart';

class Event {
  String id;
  String name;
  String description;
  DateTime start_date;
  DateTime end_date;
  String image;
  Int cost;
  String location_id;
  String category;
  List<String> attendees;

  Event({required this.id, required this.name, required this.description, required this.start_date, required this.end_date, required this.image, required this.cost, required this.location_id, required this.category, required this.attendees});


  // Convertir objeto a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'start_date': start_date.toUtc(),
      'end_date': end_date.toUtc(),
      'image': image,
      'cost': cost,
      'location_id': location_id,
      'category': category,
      'attendees': attendees
    };
  }

  // Convertir Firestore Map a objeto User
  factory Event.fromMap(Map<String, dynamic> map, String id) {
    return Event(
      id: id,
      name: map['name'],
      description: map['description'],
      start_date: (map['start_date'] as Timestamp).toDate(),
      end_date: (map['start_date'] as Timestamp).toDate(),
      image: map['image'],
      cost: map['cost'],
      location_id: map['location_id'] ?? '',
      category: map['category'] ?? '',
      attendees: List<String>.from(map['attendees'] ?? []),
    );
  }
}