class Skill {
  String id;
  String name;

  Skill({required this.id,required this.name});

  // Convertir objeto a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
    };
  }

  // Convertir Firestore Map a objeto Skill
  factory Skill.fromMap(Map<String, dynamic> map, String id) {
    return Skill(
      id:id,
      name: map['name'],
    );
  }

}