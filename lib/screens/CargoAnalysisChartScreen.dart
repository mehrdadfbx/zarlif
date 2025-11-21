// screens/laboratory_report_screen.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:zarlif/Api/CargoApi.dart';
import 'package:zarlif/models/LabAverageModel.dart';
import '../models/cargomodel.dart';

class LaboratoryReportScreen extends StatefulWidget {
  const LaboratoryReportScreen({super.key});

  @override
  State<LaboratoryReportScreen> createState() => _LaboratoryReportScreenState();
}

class _LaboratoryReportScreenState extends State<LaboratoryReportScreen> {
  late Future<List<CargoModel>> _futureCargos;
  late Future<List<LabAverageModel>> _futureAverages;

  @override
  void initState() {
    super.initState();
    _futureCargos = CargoApi.getAllCargos();
    _futureAverages = fetchLabAverages();
  }

  /// دریافت داده‌ها و تبدیل به درصد نسبی برای هر فرستنده
  Future<List<LabAverageModel>> fetchLabAverages() async {
    final url = Uri.parse(
      "http://moghzi.ir/server/server.php?action=get_avarage",
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)["data"] as List;
      return data.map((item) {
        final model = LabAverageModel.fromJson(item);

        final double pvc = double.tryParse(model.avgPvc.toString()) ?? 0.0;
        final double waste = double.tryParse(model.avgWaste.toString()) ?? 0.0;
        final double colored =
            double.tryParse(model.avgColoredFlake.toString()) ?? 0.0;

        final double total = pvc + waste + colored;
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
    } else {
      throw Exception("خطا در دریافت داده از سرور");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: SafeArea(
          child: Container(
            margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
            decoration: BoxDecoration(
              color: Colors.blue[700],
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              title: const Text(
                'گزارش آزمایشگاه',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white,
                    child: ClipOval(
                      child: Image.asset(
                        'assets/image/Logo.jpg',
                        width: 32,
                        height: 32,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ],
              shadowColor: Colors.transparent,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            /// ==================== چارت میله‌ای گروهی ====================
            FutureBuilder<List<LabAverageModel>>(
              future: _futureAverages,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text(
                    "داده‌ای برای نمایش نیست",
                    style: TextStyle(fontFamily: "Vazir"),
                  );
                }

                final averages = snapshot.data!;

                return Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  height: 360,
                  child: Column(
                    children: [
                      const Text(
                        "میانگین مواد بر حسب درصد",
                        style: TextStyle(
                          fontFamily: "Vazir",
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: BarChart(
                          BarChartData(
                            barTouchData: BarTouchData(
                              longPressDuration: const Duration(
                                milliseconds: 300,
                              ),
                              enabled: true,
                              handleBuiltInTouches: true,
                              touchTooltipData: BarTouchTooltipData(
                                tooltipBorderRadius: BorderRadius.circular(8),
                                tooltipPadding: const EdgeInsets.all(8),
                                tooltipMargin: 8,
                                getTooltipItem:
                                    (group, groupIndex, rod, rodIndex) {
                                      final String label = switch (rodIndex) {
                                        0 => 'PVC',
                                        1 => 'مواد زائد',
                                        2 => 'پرک رنگی',
                                        _ => '',
                                      };
                                      return BarTooltipItem(
                                        '$label: ${rod.toY.toStringAsFixed(1)}%',
                                        const TextStyle(
                                          color: Colors.white,
                                          fontFamily: "Vazir",
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    },
                              ),
                            ),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 20,
                                  reservedSize: 30,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      value.toInt().toString(),
                                      style: const TextStyle(
                                        fontFamily: "Vazir",
                                        fontSize: 11,
                                        color: Colors.black54,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    final index = value.toInt();
                                    if (index >= averages.length) {
                                      return const SizedBox.shrink();
                                    }
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: Text(
                                        averages[index].senderName,
                                        style: const TextStyle(
                                          fontFamily: "Vazir",
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            maxY: 100,
                            gridData: const FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              horizontalInterval: 20,
                            ),
                            borderData: FlBorderData(show: false),
                            barGroups: List.generate(averages.length, (i) {
                              final d = averages[i];
                              return BarChartGroupData(
                                x: i,
                                barsSpace: 8,
                                barRods: [
                                  BarChartRodData(
                                    toY: d.avgPvc,
                                    color: Colors.blueAccent,
                                    width: 14,
                                    borderRadius: BorderRadius.circular(6),
                                    borderSide: const BorderSide(
                                      color: Colors.white,
                                      width: 1,
                                    ),
                                  ),
                                  BarChartRodData(
                                    toY: d.avgWaste,
                                    color: Colors.grey,
                                    width: 14,
                                    borderRadius: BorderRadius.circular(6),
                                    borderSide: const BorderSide(
                                      color: Colors.white,
                                      width: 1,
                                    ),
                                  ),
                                  BarChartRodData(
                                    toY: d.avgColoredFlake,
                                    color: Colors.green,
                                    width: 14,
                                    borderRadius: BorderRadius.circular(6),
                                    borderSide: const BorderSide(
                                      color: Colors.white,
                                      width: 1,
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            /// راهنمای رنگ‌ها
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                LegendItem(color: Colors.blueAccent, text: 'PVC'),
                SizedBox(width: 16),
                LegendItem(color: Colors.grey, text: 'مواد زائد'),
                SizedBox(width: 16),
                LegendItem(color: Colors.green, text: 'پرک رنگی'),
              ],
            ),
            const SizedBox(height: 30),

            /// ==================== جدول بارها (با گوشه‌های گرد) ====================
            FutureBuilder<List<CargoModel>>(
              future: _futureCargos,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text(
                    "داده‌ای برای نمایش نیست",
                    style: TextStyle(fontFamily: "Vazir"),
                  );
                }

                final cargos = snapshot.data!;

                return ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: MaterialStateColor.resolveWith(
                          (states) => Colors.blue[700]!,
                        ),
                        headingTextStyle: const TextStyle(
                          fontFamily: "Vazir",
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        dataTextStyle: const TextStyle(
                          fontFamily: "Vazir",
                          fontSize: 13,
                        ),
                        dataRowHeight: 48,
                        columns: const [
                          DataColumn(label: Text('فرستنده')),
                          DataColumn(label: Text('وزن (kg)')),
                          DataColumn(label: Text('رطوبت (%)')),
                          DataColumn(label: Text('قیمت (ریال)')),
                          DataColumn(label: Text('PVC')),
                          DataColumn(label: Text('پرک کثیف')),
                          DataColumn(label: Text('پلیمر')),
                          DataColumn(label: Text('مواد زائد')),
                          DataColumn(label: Text('پرک رنگی')),
                          DataColumn(label: Text('رنگ')),
                        ],
                        rows: cargos.map((cargo) {
                          return DataRow(
                            cells: [
                              DataCell(Text(cargo.userName)),
                              DataCell(Text(cargo.weightScale.toString())),
                              DataCell(Text("${cargo.humidity}%")),
                              DataCell(Text(cargo.pricePerUnit.toString())),
                              DataCell(Text("${cargo.pvc} ppm")),
                              DataCell(Text("${cargo.dirtyFlake} ppm")),
                              DataCell(Text("${cargo.polymer} ppm")),
                              DataCell(Text("${cargo.wasteMaterial} ppm")),
                              DataCell(Text("${cargo.coloredFlake} ppm")),
                              DataCell(Text(cargo.colorChange)),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// ویجت راهنمای رنگ‌ها
class LegendItem extends StatelessWidget {
  final Color color;
  final String text;

  const LegendItem({super.key, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontFamily: "Vazir", fontSize: 12)),
      ],
    );
  }
}
