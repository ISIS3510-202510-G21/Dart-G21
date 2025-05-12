class SignUpDraft {
  String email;
  String name;
  String password;
  String userType;
  String headline;
  String description;
  String profileImagePath;

  SignUpDraft({
    required this.email,
    required this.name,
    required this.password,
    required this.userType,
    required this.headline,
    required this.description,
    required this.profileImagePath,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'name': name,
    'password': password,
    'userType': userType,
    'headline': headline,
    'description': description,
    'profileImagePath': profileImagePath,
  };

  factory SignUpDraft.fromJson(Map<String, dynamic> json) => SignUpDraft(
    email: json['email'] ?? '',
    name: json['name'] ?? '',
    password: json['password'] ?? '',
    userType: json['userType'] ?? '',
    headline: json['headline'] ?? '',
    description: json['description'] ?? '',
    profileImagePath: json['profileImagePath'] ?? '',
  );
}
