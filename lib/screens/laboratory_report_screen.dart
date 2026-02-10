// // screens/laboratory_report_screen.dart
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:zarlif/Api/CargoApi.dart';
// import 'package:zarlif/models/LabAverageModel.dart';
// import 'package:zarlif/screens/CargoRegistration_Screen.dart';
// import '../models/cargomodel.dart' hide CargoModel;

// class LaboratoryReportScreen extends StatefulWidget {
//   const LaboratoryReportScreen({super.key});

//   @override
//   State<LaboratoryReportScreen> createState() => _LaboratoryReportScreenState();
// }

// class _LaboratoryReportScreenState extends State<LaboratoryReportScreen> {
//   late Future<List<CargoModel>> _futureCargos;
//   late Future<List<LabAverageModel>> _futureAverages;

//   @override
//   void initState() {
//     super.initState();
//     // _futureCargos = CargoApi.getAllCargos();
//     _futureAverages = fetchLabAverages();
//   }

//   /// دریافت داده و تبدیل به درصد
//   Future<List<LabAverageModel>> fetchLabAverages() async {
//     final url = Uri.parse(
//       "http://moghzi.ir/server/zarlif/server.php?action=get_avarage",
//     );
//     final response = await http.get(url);

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body)["data"] as List;
//       return data.map((item) {
//         final model = LabAverageModel.fromJson(item);

//         final double pvc = double.tryParse(model.avgPvc.toString()) ?? 0.0;
//         final double waste = double.tryParse(model.avgWaste.toString()) ?? 0.0;
//         final double colored =
//             double.tryParse(model.avgColoredFlake.toString()) ?? 0.0;

//         final double total = pvc + waste + colored;
//         final double pvcPercent = total > 0 ? (pvc / total) * 100 : 0.0;
//         final double wastePercent = total > 0 ? (waste / total) * 100 : 0.0;
//         final double coloredPercent = total > 0 ? (colored / total) * 100 : 0.0;

//         return LabAverageModel(
//           senderName: model.senderName,
//           avgPvc: double.parse(pvcPercent.toStringAsFixed(2)),
//           avgWaste: double.parse(wastePercent.toStringAsFixed(2)),
//           avgColoredFlake: double.parse(coloredPercent.toStringAsFixed(2)),
//         );
//       }).toList();
//     } else {
//       throw Exception("خطا در دریافت داده از سرور");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     /// ------------ تعریف متغیرهای MediaQuery ---------------
//     final Size size = MediaQuery.of(context).size;
//     final double scaleWidth = size.width / 390; // پایه طراحی موبایل
//     final double scaleHeight = size.height / 844;
//     final double scaleText = scaleWidth * 1.1;

//     return Scaffold(
//       backgroundColor: Colors.grey.shade100,
//       appBar: PreferredSize(
//         preferredSize: Size.fromHeight(70 * scaleHeight),
//         child: SafeArea(
//           child: Container(
//             margin: EdgeInsets.only(
//               top: 16 * scaleHeight,
//               left: 16 * scaleWidth,
//               right: 16 * scaleWidth,
//             ),
//             decoration: BoxDecoration(
//               color: Colors.blue[700],
//               borderRadius: BorderRadius.circular(40 * scaleWidth),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.2),
//                   blurRadius: 8 * scaleWidth,
//                   offset: Offset(0, 4 * scaleHeight),
//                 ),
//               ],
//             ),
//             child: AppBar(
//               backgroundColor: Colors.transparent,
//               elevation: 0,
//               centerTitle: true,
//               title: Text(
//                 'گزارش آزمایشگاه',
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                   fontSize: 18 * scaleText,
//                 ),
//               ),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(20 * scaleWidth),
//               ),
//               actions: [
//                 Padding(
//                   padding: EdgeInsets.only(right: 12 * scaleWidth),
//                   child: CircleAvatar(
//                     radius: 18 * scaleWidth,
//                     backgroundColor: Colors.white,
//                     child: ClipOval(
//                       child: Image.asset(
//                         'assets/image/Logo.jpg',
//                         width: 32 * scaleWidth,
//                         height: 32 * scaleWidth,
//                         fit: BoxFit.contain,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(12 * scaleWidth),
//         child: Column(
//           children: [
//             /// ==================== چارت ====================
//             FutureBuilder<List<LabAverageModel>>(
//               future: _futureAverages,
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return Padding(
//                     padding: EdgeInsets.all(40 * scaleWidth),
//                     child: const CircularProgressIndicator(),
//                   );
//                 }
//                 if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                   return Text(
//                     "داده‌ای برای نمایش نیست",
//                     style: TextStyle(
//                       fontFamily: "Vazir",
//                       fontSize: 14 * scaleText,
//                     ),
//                   );
//                 }

//                 final averages = snapshot.data!;

//                 return Container(
//                   padding: EdgeInsets.all(12 * scaleWidth),
//                   margin: EdgeInsets.only(bottom: 20 * scaleHeight),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(18 * scaleWidth),
//                     boxShadow: const [
//                       BoxShadow(
//                         color: Colors.black12,
//                         blurRadius: 8,
//                         offset: Offset(0, 4),
//                       ),
//                     ],
//                   ),
//                   height: 360 * scaleHeight, // ارتفاع چارت با MediaQuery
//                   child: Column(
//                     children: [
//                       Text(
//                         "میانگین مواد بر حسب درصد",
//                         style: TextStyle(
//                           fontFamily: "Vazir",
//                           fontSize: 16 * scaleText,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       SizedBox(height: 10 * scaleHeight),

//                       Expanded(
//                         child: BarChart(
//                           BarChartData(
//                             barTouchData: BarTouchData(
//                               enabled: true,
//                               handleBuiltInTouches: true,
//                               touchTooltipData: BarTouchTooltipData(
//                                 tooltipPadding: EdgeInsets.all(8 * scaleWidth),
//                                 getTooltipItem:
//                                     (group, groupIndex, rod, rodIndex) {
//                                       final String label = switch (rodIndex) {
//                                         0 => 'PVC',
//                                         1 => 'مواد زائد',
//                                         2 => 'پرک رنگی',
//                                         _ => '',
//                                       };
//                                       return BarTooltipItem(
//                                         '$label: ${rod.toY.toStringAsFixed(1)}%',
//                                         TextStyle(
//                                           color: Colors.white,
//                                           fontFamily: "Vazir",
//                                           fontSize: 11 * scaleText,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       );
//                                     },
//                               ),
//                             ),

//                             titlesData: FlTitlesData(
//                               leftTitles: AxisTitles(
//                                 sideTitles: SideTitles(
//                                   showTitles: true,
//                                   interval: 20,
//                                   getTitlesWidget: (value, meta) {
//                                     return Text(
//                                       value.toInt().toString(),
//                                       style: TextStyle(
//                                         fontFamily: "Vazir",
//                                         fontSize: 11 * scaleText,
//                                         color: Colors.black54,
//                                       ),
//                                     );
//                                   },
//                                 ),
//                               ),

//                               bottomTitles: AxisTitles(
//                                 sideTitles: SideTitles(
//                                   showTitles: true,
//                                   getTitlesWidget: (value, meta) {
//                                     final index = value.toInt();
//                                     if (index >= averages.length) {
//                                       return const SizedBox.shrink();
//                                     }
//                                     return Padding(
//                                       padding: EdgeInsets.only(
//                                         top: 6 * scaleHeight,
//                                       ),
//                                       child: Text(
//                                         averages[index].senderName,
//                                         style: TextStyle(
//                                           fontFamily: "Vazir",
//                                           fontSize: 12 * scaleText,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                     );
//                                   },
//                                 ),
//                               ),
//                             ),

//                             maxY: 100,
//                             gridData: const FlGridData(
//                               show: true,
//                               drawVerticalLine: false,
//                             ),
//                             borderData: FlBorderData(show: false),

//                             /// ایجاد گروه میله‌ای
//                             barGroups: List.generate(averages.length, (i) {
//                               final d = averages[i];
//                               return BarChartGroupData(
//                                 x: i,
//                                 barsSpace: 6 * scaleWidth,
//                                 barRods: [
//                                   BarChartRodData(
//                                     toY: d.avgPvc,
//                                     color: Colors.blueAccent,
//                                     width: 12 * scaleWidth,
//                                   ),
//                                   BarChartRodData(
//                                     toY: d.avgWaste,
//                                     color: Colors.grey,
//                                     width: 12 * scaleWidth,
//                                   ),
//                                   BarChartRodData(
//                                     toY: d.avgColoredFlake,
//                                     color: Colors.green,
//                                     width: 12 * scaleWidth,
//                                   ),
//                                 ],
//                               );
//                             }),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),

//             /// ==================== راهنمای رنگ‌ها ====================
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 LegendItem(color: Colors.blueAccent, text: 'PVC'),
//                 SizedBox(width: 16 * scaleWidth),
//                 LegendItem(color: Colors.grey, text: 'مواد زائد'),
//                 SizedBox(width: 16 * scaleWidth),
//                 LegendItem(color: Colors.green, text: 'پرک رنگی'),
//               ],
//             ),

//             SizedBox(height: 30 * scaleHeight),

//             /// ==================== جدول ====================
//             FutureBuilder<List<CargoModel>>(
//               future: _futureCargos,
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const CircularProgressIndicator();
//                 }
//                 if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                   return Text(
//                     "داده‌ای برای نمایش نیست",
//                     style: TextStyle(
//                       fontFamily: "Vazir",
//                       fontSize: 14 * scaleText,
//                     ),
//                   );
//                 }

//                 final cargos = snapshot.data!;

//                 return ClipRRect(
//                   borderRadius: BorderRadius.circular(16 * scaleWidth),
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(16 * scaleWidth),
//                       boxShadow: const [
//                         BoxShadow(
//                           color: Colors.black12,
//                           blurRadius: 6,
//                           offset: Offset(0, 3),
//                         ),
//                       ],
//                     ),
//                     child: SingleChildScrollView(
//                       scrollDirection: Axis.horizontal,
//                       child: DataTable(
//                         headingRowColor: MaterialStateColor.resolveWith(
//                           (states) => Colors.blue[700]!,
//                         ),
//                         headingTextStyle: TextStyle(
//                           fontFamily: "Vazir",
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                           fontSize: 13 * scaleText,
//                         ),
//                         dataTextStyle: TextStyle(
//                           fontFamily: "Vazir",
//                           fontSize: 12 * scaleText,
//                         ),
//                         dataRowHeight: 48 * scaleHeight,

//                         columns: [
//                           DataColumn(
//                             label: Text(
//                               'فرستنده',
//                               style: TextStyle(fontSize: 12 * scaleText),
//                             ),
//                           ),
//                           DataColumn(
//                             label: Text(
//                               'وزن (kg)',
//                               style: TextStyle(fontSize: 12 * scaleText),
//                             ),
//                           ),
//                           DataColumn(
//                             label: Text(
//                               'رطوبت (%)',
//                               style: TextStyle(fontSize: 12 * scaleText),
//                             ),
//                           ),
//                           DataColumn(
//                             label: Text(
//                               'قیمت (ریال)',
//                               style: TextStyle(fontSize: 12 * scaleText),
//                             ),
//                           ),
//                           DataColumn(
//                             label: Text(
//                               'PVC',
//                               style: TextStyle(fontSize: 12 * scaleText),
//                             ),
//                           ),
//                           DataColumn(
//                             label: Text(
//                               'پرک کثیف',
//                               style: TextStyle(fontSize: 12 * scaleText),
//                             ),
//                           ),
//                           DataColumn(
//                             label: Text(
//                               'پلیمر',
//                               style: TextStyle(fontSize: 12 * scaleText),
//                             ),
//                           ),
//                           DataColumn(
//                             label: Text(
//                               'مواد زائد',
//                               style: TextStyle(fontSize: 12 * scaleText),
//                             ),
//                           ),
//                           DataColumn(
//                             label: Text(
//                               'پرک رنگی',
//                               style: TextStyle(fontSize: 12 * scaleText),
//                             ),
//                           ),
//                           DataColumn(
//                             label: Text(
//                               'رنگ',
//                               style: TextStyle(fontSize: 12 * scaleText),
//                             ),
//                           ),
//                         ],

//                         rows: cargos.map((cargo) {
//                           return DataRow(
//                             cells: [
//                               // DataCell(Text(cargo.senderName)),
//                               DataCell(Text(cargo.weightScale.toString())),
//                               DataCell(Text("${cargo.humidity}%")),
//                               DataCell(Text(cargo.pricePerUnit.toString())),
//                               DataCell(Text("${cargo.pvc} ppm")),
//                               DataCell(Text("${cargo.dirtyFlake} ppm")),
//                               DataCell(Text("${cargo.polymer} ppm")),
//                               DataCell(Text("${cargo.wasteMaterial} ppm")),
//                               DataCell(Text("${cargo.coloredFlake} ppm")),
//                               DataCell(Text(cargo.colorChange)),
//                             ],
//                           );
//                         }).toList(),
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// /// ویجت راهنمای رنگ
// class LegendItem extends StatelessWidget {
//   final Color color;
//   final String text;

//   const LegendItem({super.key, required this.color, required this.text});

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Container(
//           width: 16,
//           height: 16,
//           decoration: BoxDecoration(
//             color: color,
//             borderRadius: BorderRadius.circular(4),
//           ),
//         ),
//         const SizedBox(width: 4),
//         Text(text, style: const TextStyle(fontFamily: "Vazir", fontSize: 12)),
//       ],
//     );
//   }
// }
import 'package:flutter/material.dart';

class LaboratoryReportScreen extends StatefulWidget {
  const LaboratoryReportScreen({super.key});

  @override
  State<LaboratoryReportScreen> createState() => _LaboratoryReportScreenState();
}

class _LaboratoryReportScreenState extends State<LaboratoryReportScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('صفحه گزارش آزمایشگاه')));
  }
}
