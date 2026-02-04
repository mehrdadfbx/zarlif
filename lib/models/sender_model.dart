// models/sender_model.dart
class Sender {
  final int id;
  final String name;
  final String phone;
  final String address;
  final DateTime createdAt;
  final DateTime updatedAt;

  Sender({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Sender.fromJson(Map<String, dynamic> json) {
    return Sender(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'phone': phone, 'address': address};
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'address': address,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Sender(id: $id, name: $name, phone: $phone, address: $address)';
  }
}

class GetSendersResponse {
  final int statusCode;
  final String status;
  final String message;
  final List<Sender> data;

  GetSendersResponse({
    required this.statusCode,
    required this.status,
    required this.message,
    required this.data,
  });

  factory GetSendersResponse.fromJson(Map<String, dynamic> json) {
    return GetSendersResponse(
      statusCode: json['statusCode'] ?? 0,
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: json['data'] != null
          ? (json['data'] as List).map((item) => Sender.fromJson(item)).toList()
          : [],
    );
  }

  bool get isSuccess => statusCode == 200;
}

class AddSenderResponse {
  final int statusCode;
  final String status;
  final String message;
  final Sender? data;

  AddSenderResponse({
    required this.statusCode,
    required this.status,
    required this.message,
    required this.data,
  });

  factory AddSenderResponse.fromJson(Map<String, dynamic> json) {
    return AddSenderResponse(
      statusCode: json['statusCode'] ?? 0,
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: json['data'] != null ? Sender.fromJson(json['data']) : null,
    );
  }

  bool get isSuccess => statusCode == 200;
}

class DeleteSenderResponse {
  final int statusCode;
  final String status;
  final String message;

  DeleteSenderResponse({
    required this.statusCode,
    required this.status,
    required this.message,
  });

  factory DeleteSenderResponse.fromJson(Map<String, dynamic> json) {
    return DeleteSenderResponse(
      statusCode: json['statusCode'] ?? 0,
      status: json['status'] ?? '',
      message: json['message'] ?? '',
    );
  }

  bool get isSuccess => statusCode == 200;
}
