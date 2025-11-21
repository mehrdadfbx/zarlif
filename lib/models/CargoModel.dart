// models/cargo_model.dart

class CargoModel {
  final String receiveDate;
  final int senderId;
  final double weightScale;
  final double humidity;
  final int pricePerUnit;
  final double pvc;
  final double dirtyFlake;
  final double polymer;
  final double wasteMaterial;
  final double coloredFlake;
  final String colorChange;
  final String userName;

  const CargoModel({
    required this.receiveDate,
    required this.senderId,
    required this.weightScale,
    required this.humidity,
    required this.pricePerUnit,
    required this.pvc,
    required this.dirtyFlake,
    required this.polymer,
    required this.wasteMaterial,
    required this.coloredFlake,
    required this.colorChange,
    required this.userName,
  });

  /// تبدیل مدل به JSON برای ارسال به سرور
  Map<String, dynamic> toJson() => {
    'receive_date': receiveDate,
    'sender_id': senderId,
    'weight_scale': weightScale,
    'humidity': humidity,
    'price_per_unit': pricePerUnit,
    'pvc': pvc,
    'dirty_flake': dirtyFlake,
    'polymer': polymer,
    'waste_material': wasteMaterial,
    'colored_flake': coloredFlake,
    'color_change': colorChange,
    'user_name': userName,
  };

  /// متد دریافت از سرور — نسخه نهایی و بدون Conflict
  factory CargoModel.fromJson(Map<String, dynamic> json) {
    // تبدیل امن عددی
    double parseDouble(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0; // مقدار پیش‌فرض
    }

    // تبدیل امن عدد صحیح
    int parseInt(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return CargoModel(
      receiveDate: json['receive_date'] ?? "",
      senderId: parseInt(json['sender_id']),
      weightScale: parseDouble(json['weight_scale']),
      humidity: parseDouble(json['humidity']),
      pricePerUnit: parseInt(json['price_per_unit']),
      pvc: parseDouble(json['pvc']),
      dirtyFlake: parseDouble(json['dirty_flake']),
      polymer: parseDouble(json['polymer']),
      wasteMaterial: parseDouble(json['waste_material']),
      coloredFlake: parseDouble(json['colored_flake']),
      colorChange: json['color_change'] ?? "",
      userName: json['user_name'] ?? "",
    );
  }

  @override
  String toString() => 'CargoModel(date: $receiveDate, weight: $weightScale)';
}
