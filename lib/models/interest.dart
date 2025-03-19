class Interest {
  String id;
  String name;

  Interest({required this.id,required this.name});

  // Convertir objeto a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
    };
  }

  // Convertir Firestore Map a objeto User
  factory Interest.fromMap(Map<String, dynamic> map, String id) {
    return Interest(
      id:id,
      name: map['name'],
    );
  }
  
}