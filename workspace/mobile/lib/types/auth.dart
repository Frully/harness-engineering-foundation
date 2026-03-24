class Credentials {
  const Credentials({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
      };
}

class User {
  const User({
    required this.id,
    required this.email,
    required this.createdAt,
  });

  final int id;
  final String email;
  final DateTime createdAt;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      email: json['email'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
