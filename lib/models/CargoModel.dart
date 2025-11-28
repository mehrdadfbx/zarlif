// models/cargo_model.dart

class CargoModel {
  final String id; // شناسه یکتا (ضروری برای عملیات آینده)
  final String receiveDate; // تاریخ دریافت
  final int senderId; // آی‌دی فرستنده
  final double weightScale; // وزن باسکول
  final double humidity; // رطوبت
  final int pricePerUnit; // قیمت واحد
  final double pvc;
  final double dirtyFlake;
  final double polymer;
  final double wasteMaterial;
  final double coloredFlake;
  final String colorChange; // A, B, C
  final String userName; // نام کاربر ثبت‌کننده
  final String entryTime; // زمان ثبت (مثلاً 2025-11-21 16:13:22)
  final String senderName; // نام فرستنده بار (جدید و مهم)
  final String senderPhone; // شماره تلفن فرستنده (جدید و مهم)
  final int testNumber; // اگر هنوز استفاده می‌کنید، نگه داشته شود

  const CargoModel({
    required this.id,
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
    required this.entryTime,
    required this.senderName,
    required this.senderPhone,
    required this.testNumber,
  });

  /// تبدیل به JSON (فقط فیلدهایی که برای ثبت بار جدید لازم است)
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
    // user_name معمولاً توسط سرور از توکن یا سشن گرفته می‌شود
    // در صورت نیاز اضافه کنید: 'user_name': userName,
  };

  /// تبدیل امن از JSON دریافتی سرور
  factory CargoModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return CargoModel(
      id: json['id']?.toString() ?? "0",
      receiveDate: json['receive_date']?.toString() ?? "",
      senderId: parseInt(json['sender_id']),
      weightScale: parseDouble(json['weight_scale']),
      humidity: parseDouble(json['humidity']),
      pricePerUnit: parseInt(json['price_per_unit']),
      pvc: parseDouble(json['pvc']),
      dirtyFlake: parseDouble(json['dirty_flake']),
      polymer: parseDouble(json['polymer']),
      wasteMaterial: parseDouble(json['waste_material']),
      coloredFlake: parseDouble(json['colored_flake']),
      colorChange: json['color_change']?.toString() ?? "",
      userName: json['user_name']?.toString() ?? "",
      entryTime: json['entry_time']?.toString() ?? "",
      senderName: json['sender_name']?.toString() ?? "نامشخص",
      senderPhone: json['sender_phone']?.toString() ?? "نامشخص",
      testNumber: parseInt(json['test_number']), // اگر وجود نداشت 0 می‌ماند
    );
  }

  @override
  String toString() {
    return 'CargoModel(id: $id, date: $receiveDate, sender: $senderName, weight: $weightScale kg)';
  }
}
