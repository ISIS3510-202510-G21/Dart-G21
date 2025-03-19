class User {
  String id;
  String name;
  String email;
  String username;
  String userType;

  User({required this.id, required this.name, required this.email, required this.username, required this.userType});

  // Convertir objeto a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'username': username,
      'user_type': userType
    };
  }

  // Convertir Firestore Map a objeto User
  factory User.fromMap(Map<String, dynamic> map, String id) {
    return User(
      id: id,
      name: map['name'],
      email: map['email'],
      username: map['username'],
      userType: map['user_type'],
    );
  }
}
