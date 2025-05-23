class Location{
  String id;
  String address;
  String city;
  String details;
  bool university;
  double latitude;
  double longitude;

  Location({required this.id, required this.address, required this.city, required this.details,
            required this.university, required this.latitude, required this.longitude});

  // Convertir objeto a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'address': address,
      'city': city,
      'details': details,
      'university': university,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  // Convertir Firestore Map a objeto User
  factory Location.fromMap(Map<String, dynamic> map, String id) {
    return Location(
      id: id,
      address: map['address'],
      city: map['city'],
      details: map['details'],
      university: map['university'],
      latitude: map['latitude'],
      longitude: map['longitude'],
    );
  }

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'] as String,
      address: json['address'] as String,
      city: json['city'] as String,
      details: json['details'] as String,
      university: json['university'] as bool,
      latitude: json['latitude'] as double, 
      longitude: json['longitude'] as double,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'address': address,
      'city': city,
      'details': details,
      'university': university,
      'latitude': latitude,
      'longitude': longitude,
    };
  }


}