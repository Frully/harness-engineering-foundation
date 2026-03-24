class Credentials {
  const Credentials({
    required this.email,
    required this.password,
    this.confirmPassword,
  });

  final String email;
  final String password;
  final String? confirmPassword;

  Map<String, dynamic> toJson() {
    final payload = <String, dynamic>{'email': email, 'password': password};
    if (confirmPassword != null) {
      payload['confirmPassword'] = confirmPassword;
    }
    return payload;
  }
}

const passwordPolicyMessage =
    'Password must be at least 8 characters and include uppercase, lowercase, number, and symbol.';
const passwordPolicyHint =
    'Use at least 8 characters with uppercase, lowercase, number, and symbol.';

String? validateRegisterCredentials({
  required String email,
  required String password,
  required String confirmPassword,
}) {
  if (email.trim().isEmpty ||
      password.trim().isEmpty ||
      confirmPassword.trim().isEmpty) {
    return 'Email, password, and password confirmation are all required.';
  }

  if (password != confirmPassword) {
    return 'Passwords do not match.';
  }

  if (!_isStrongPassword(password)) {
    return passwordPolicyMessage;
  }

  return null;
}

bool _isStrongPassword(String password) {
  final hasUpper = RegExp(r'[A-Z]').hasMatch(password);
  final hasLower = RegExp(r'[a-z]').hasMatch(password);
  final hasDigit = RegExp(r'\d').hasMatch(password);
  final hasSymbol = RegExp(
    r'[!@#$%^&*()_+\-=\[\]{}|;:,.<>/?~`]',
  ).hasMatch(password);
  return password.length >= 8 && hasUpper && hasLower && hasDigit && hasSymbol;
}

class User {
  const User({required this.id, required this.email, required this.createdAt});

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
