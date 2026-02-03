class RequestCodeResponse {
  final int statusCode;
  final String status;
  final String message;
  final dynamic data;

  RequestCodeResponse({
    required this.statusCode,
    required this.status,
    required this.message,
    required this.data,
  });

  factory RequestCodeResponse.fromJson(Map<String, dynamic> json) {
    return RequestCodeResponse(
      statusCode: json['statusCode'] ?? 0,
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: json['data'],
    );
  }

  bool get isSuccess => statusCode == 200;
}

class AuthResponse {
  final String token;
  final String phone;
  final String? expiresAt;

  AuthResponse({required this.token, required this.phone, this.expiresAt});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] ?? '',
      phone: json['phone'] ?? '',
      expiresAt: json['expiresAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'token': token, 'phone': phone, 'expiresAt': expiresAt};
  }
}
