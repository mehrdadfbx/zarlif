class AuthResponse {
  final bool success;
  final String message;
  final String token;
  final String expiresAt;
  final User user;

  AuthResponse({
    required this.success,
    required this.message,
    required this.token,
    required this.expiresAt,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      token: json['token'] ?? '',
      expiresAt: json['expires_at'] ?? '',
      user: User.fromJson(json['user'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'token': token,
      'expires_at': expiresAt,
      'user': user.toJson(),
    };
  }
}

class User {
  final String id;
  final String phone;
  final String? name;

  User({required this.id, required this.phone, this.name});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      name: json['name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'phone': phone, 'name': name};
  }
}
