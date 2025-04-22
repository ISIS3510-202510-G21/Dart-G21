class Category_event {
  String id;
  String name;
 

  Category_event({required this.id, required this.name});


  // Convertir objeto a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
    };
  }

  // Convertir Firestore Map a objeto User
  factory Category_event.fromMap(Map<String, dynamic> map, String id) {
    return Category_event(
      id: id,
      name: map['name'],
    );
  }

  factory Category_event.fromJson(Map<String, dynamic> json) {
    return Category_event(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

