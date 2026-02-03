// user_info_response.dart
class UserInfoResponse {
  final int statusCode;
  final String status;
  final String message;
  final UserData? data;

  UserInfoResponse({
    required this.statusCode,
    required this.status,
    required this.message,
    required this.data,
  });

  factory UserInfoResponse.fromJson(Map<String, dynamic> json) {
    return UserInfoResponse(
      statusCode: json['statusCode'] ?? 0,
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: json['data'] != null ? UserData.fromJson(json['data']) : null,
    );
  }

  bool get isSuccess => statusCode == 200;
}

class UserData {
  final String? name;
  final String? family;
  final String phone;
  final String phoneCode;
  final int phoneIsVerify;
  final String role;
  final String activation;
  final String? token;
  final int date;

  UserData({
    this.name,
    this.family,
    required this.phone,
    required this.phoneCode,
    required this.phoneIsVerify,
    required this.role,
    required this.activation,
    this.token,
    required this.date,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      name: json['name']?.toString(),
      family: json['family']?.toString(),
      phone: json['phone']?.toString() ?? '',
      phoneCode: json['phone_code']?.toString() ?? '',
      phoneIsVerify: json['phone_is_verify'] is int
          ? json['phone_is_verify']
          : 0,
      role: json['role']?.toString() ?? '',
      activation: json['activation']?.toString() ?? '',
      token: json['token']?.toString(),
      date: json['date'] is int ? json['date'] : 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'family': family,
      'phone': phone,
      'phone_code': phoneCode,
      'phone_is_verify': phoneIsVerify,
      'role': role,
      'activation': activation,
      'token': token,
      'date': date,
    };
  }

  String get fullName {
    if (name != null && family != null) {
      return '$name $family';
    } else if (name != null) {
      return name!;
    } else if (family != null) {
      return family!;
    } else {
      return phone;
    }
  }

  bool get isActive => activation == "1";
  bool get isPhoneVerified => phoneIsVerify == 1;
  bool get isAdmin => role == "ادمین";

  @override
  String toString() {
    return 'UserData(name: $name, phone: $phone, role: $role, active: $isActive)';
  }
}
