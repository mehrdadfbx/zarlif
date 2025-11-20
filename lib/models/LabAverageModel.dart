class LabAverageModel {
  final String senderName;
  final double avgPvc;
  final double avgWaste;
  final double avgColoredFlake;

  LabAverageModel({
    required this.senderName,
    required this.avgPvc,
    required this.avgWaste,
    required this.avgColoredFlake,
  });

  factory LabAverageModel.fromJson(Map<String, dynamic> json) {
    return LabAverageModel(
      senderName: json['sender_name'],
      avgPvc: double.parse(json['avg_pvc']),
      avgWaste: double.parse(json['avg_waste_material']),
      avgColoredFlake: double.parse(json['avg_colored_flake']),
    );
  }
}
