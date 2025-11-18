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

  // برای ارسال به سرور
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

  // برای دریافت از سرور (این متد گم شده بود!)
  factory CargoModel.fromJson(Map<String, dynamic> json) {
    return CargoModel(
      receiveDate: json['receive_date'] as String,
      senderId: json['sender_id'] as int,
      weightScale: (json['weight_scale'] as num).toDouble(),
      humidity: (json['humidity'] as num).toDouble(),
      pricePerUnit: json['price_per_unit'] as int,
      pvc: (json['pvc'] as num).toDouble(),
      dirtyFlake: (json['dirty_flake'] as num).toDouble(),
      polymer: (json['polymer'] as num).toDouble(),
      wasteMaterial: (json['waste_material'] as num).toDouble(),
      coloredFlake: (json['colored_flake'] as num).toDouble(),
      colorChange: json['color_change'] as String,
      userName: json['user_name'] as String,
    );
  }

  @override
  String toString() => 'CargoModel(date: $receiveDate, weight: $weightScale)';
}
