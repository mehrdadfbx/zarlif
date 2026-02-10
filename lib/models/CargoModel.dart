import 'dart:convert';

// Enumها
enum ColorChangeQualitative { low, medium, high }

enum CutSizeQualitative { suitable, unsuitable }

enum ResultStatus {
  accepted('accepted'),
  relativeAccepted('relativeAccepted'),
  conditionalAccepted('conditionalAccepted'),
  rejected('rejected');

  final String value;
  const ResultStatus(this.value);

  String get persianName {
    switch (this) {
      case ResultStatus.accepted:
        return 'قبول';
      case ResultStatus.relativeAccepted:
        return 'قبول نسبی';
      case ResultStatus.conditionalAccepted:
        return 'قبول مشروط';
      case ResultStatus.rejected:
        return 'مردود';
    }
  }
}

// مدل اطلاعات رسید
class ReceiptInformation {
  final String sender;
  final String plateNumber;
  final double weight;
  final String number;
  final String code;
  final String qualityGrade;
  final String result;
  final String theory;
  final String responsible;

  ReceiptInformation({
    required this.sender,
    required this.plateNumber,
    required this.weight,
    required this.number,
    required this.code,
    required this.qualityGrade,
    required this.result,
    required this.theory,
    required this.responsible,
  });

  Map<String, dynamic> toJson() {
    return {
      'sender': sender,
      'plateNumber': plateNumber,
      'weight': weight,
      'number': number,
      'code': code,
      'qualityGrade': qualityGrade,
      'result': result,
      'theory': theory,
      'responsible': responsible,
    };
  }
}

// مدل آزمایش
class Experiment {
  final String row;
  final double pvc;
  final double plasticizer;
  final double wasteMaterial;
  final double blackSaltColor;
  final double totalBlackSalt;
  final double moisture;
  final double wasteBlackSalt;
  final double mixedBlackSalt;
  final String colorChangeQualitative;
  final double colorChangeQuantitative;
  final String cutSizeQualitative;
  final double cutSizemm;
  final double density;

  Experiment({
    required this.row,
    required this.pvc,
    required this.plasticizer,
    required this.wasteMaterial,
    required this.blackSaltColor,
    required this.totalBlackSalt,
    required this.moisture,
    required this.wasteBlackSalt,
    required this.mixedBlackSalt,
    required this.colorChangeQualitative,
    required this.colorChangeQuantitative,
    required this.cutSizeQualitative,
    required this.cutSizemm,
    required this.density,
  });

  Map<String, dynamic> toJson() {
    return {
      'row': row,
      'pvc': pvc,
      'plasticizer': plasticizer,
      'wasteMaterial': wasteMaterial,
      'blackSaltColor': blackSaltColor,
      'totalBlackSalt': totalBlackSalt,
      'moisture': moisture,
      'wasteBlackSalt': wasteBlackSalt,
      'mixedBlackSalt': mixedBlackSalt,
      'colorChangeQualitative': colorChangeQualitative,
      'colorChangeQuantitative': colorChangeQuantitative,
      'cutSizeQualitative': cutSizeQualitative,
      'cutSizemm': cutSizemm,
      'density': density,
    };
  }
}

// مدل درخواست ذخیره آزمایش
class SaveExperimentRequest {
  final ReceiptInformation receiptInformation;
  final List<Experiment> experiments;

  SaveExperimentRequest({
    required this.receiptInformation,
    required this.experiments,
  });

  Map<String, dynamic> toJson() {
    return {
      'receipt_information': receiptInformation.toJson(),
      'experiments': experiments.map((e) => e.toJson()).toList(),
    };
  }

  String toJsonString() {
    return json.encode(toJson());
  }
}

// مدل پاسخ API
class SaveExperimentResponse {
  final int statusCode;
  final String status;
  final String message;
  final dynamic data;
  final bool success;

  SaveExperimentResponse({
    required this.statusCode,
    required this.status,
    required this.message,
    this.data,
    required this.success,
  });

  bool get isSuccess => success;
}
