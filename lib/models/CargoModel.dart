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

  CargoModel({
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

  Map<String, dynamic> toJson() {
    return {
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
  }
}
