<<<<<<< HEAD
=======
// TODO Implement this library.
>>>>>>> 6206136ae5117f2fe88072f23139ebb6e7530c7d
// models/laboratory_report.dart
class CompanyData {
  final String name;
  final double moisture;
  final double pvc;
  final double polymer;

  const CompanyData({
    required this.name,
    required this.moisture,
    required this.pvc,
    required this.polymer,
  });

  factory CompanyData.fromJson(Map<String, dynamic> json) {
    return CompanyData(
      name: json['company_name'] as String,
      moisture: (json['moisture'] as num).toDouble(),
      pvc: (json['pvc'] as num).toDouble(),
      polymer: (json['polymer'] as num).toDouble(),
    );
  }
}

class LabRow {
  final String date;
  final String shift;
  final int weight;
  final double moisture;
  final int pvc;
  final int dirtyFlake;
  final int polymer;
  final int coloredMaterials;
  final double coloredFlake;
  final String colorGrade;
  final String operator;

  const LabRow({
    required this.date,
    required this.shift,
    required this.weight,
    required this.moisture,
    required this.pvc,
    required this.dirtyFlake,
    required this.polymer,
    required this.coloredMaterials,
    required this.coloredFlake,
    required this.colorGrade,
    required this.operator,
  });

  factory LabRow.fromJson(Map<String, dynamic> json) {
    return LabRow(
      date: json['date'] as String,
      shift: json['shift'] as String,
      weight: json['weight'] as int,
      moisture: (json['moisture'] as num).toDouble(),
      pvc: json['pvc'] as int,
      dirtyFlake: json['dirty_flake'] as int,
      polymer: json['polymer'] as int,
      coloredMaterials: json['colored_materials'] as int,
      coloredFlake: (json['colored_flake'] as num).toDouble(),
      colorGrade: json['color_grade'] as String,
      operator: json['operator'] as String,
    );
  }
}

class ReportSummary {
  final double avgMoisture;
  final double avgPvc;
  final double avgPolymer;
  final int totalSamples;

  const ReportSummary({
    required this.avgMoisture,
    required this.avgPvc,
    required this.avgPolymer,
    required this.totalSamples,
  });

  factory ReportSummary.fromJson(Map<String, dynamic> json) {
    return ReportSummary(
      avgMoisture: (json['avg_moisture'] as num).toDouble(),
      avgPvc: (json['avg_pvc'] as num).toDouble(),
      avgPolymer: (json['avg_polymer'] as num).toDouble(),
      totalSamples: json['total_samples'] as int,
    );
  }
}

class LaboratoryReport {
  final List<CompanyData> chartData;
  final List<LabRow> tableData;
  final ReportSummary summary;

  const LaboratoryReport({
    required this.chartData,
    required this.tableData,
    required this.summary,
  });

  factory LaboratoryReport.fromJson(Map<String, dynamic> json) {
    return LaboratoryReport(
      chartData: (json['chart_data'] as List)
          .map((e) => CompanyData.fromJson(e as Map<String, dynamic>))
          .toList(),
      tableData: (json['table_data'] as List)
          .map((e) => LabRow.fromJson(e as Map<String, dynamic>))
          .toList(),
      summary: ReportSummary.fromJson(json['summary'] as Map<String, dynamic>),
    );
  }
}
