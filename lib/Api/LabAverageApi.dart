// Api/LabAverageApi.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:zarlif/models/LabAverageModel.dart';

class LabApi {
  /// دریافت میانگین‌ها از سرور و تبدیل به درصد
  static Future<List<LabAverageModel>> fetchLabAverages() async {
    final url = Uri.parse(
      "http://moghzi.ir/server/zarlif/server.php?action=get_avarage",
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception("خطا در دریافت داده از سرور");
    }

    final data = jsonDecode(response.body)["data"] as List;

    return data.map((item) {
      final model = LabAverageModel.fromJson(item);

      // تبدیل مقادیر به double
      final double pvc = double.tryParse(model.avgPvc.toString()) ?? 0.0;
      final double waste = double.tryParse(model.avgWaste.toString()) ?? 0.0;
      final double colored =
          double.tryParse(model.avgColoredFlake.toString()) ?? 0.0;

      final double total = pvc + waste + colored;

      // محاسبه درصدها
      final double pvcPercent = total > 0 ? (pvc / total) * 100 : 0.0;
      final double wastePercent = total > 0 ? (waste / total) * 100 : 0.0;
      final double coloredPercent = total > 0 ? (colored / total) * 100 : 0.0;

      return LabAverageModel(
        senderName: model.senderName,
        avgPvc: double.parse(pvcPercent.toStringAsFixed(2)),
        avgWaste: double.parse(wastePercent.toStringAsFixed(2)),
        avgColoredFlake: double.parse(coloredPercent.toStringAsFixed(2)),
      );
    }).toList();
  }
}
