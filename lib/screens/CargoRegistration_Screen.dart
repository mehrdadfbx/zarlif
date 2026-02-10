import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:zarlif/Api/CargoApi.dart';
import 'package:zarlif/models/CargoModel.dart';
import 'package:zarlif/screens/sender_screen.dart';
import '../models/sender_model.dart';
import '../api/sender_api.dart';

class CargoRegistrationScreen extends StatefulWidget {
  const CargoRegistrationScreen({super.key});

  @override
  State<CargoRegistrationScreen> createState() =>
      _CargoRegistrationScreenState();
}

class _CargoRegistrationScreenState extends State<CargoRegistrationScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TabController _tabController;

  // کنترلرها برای اطلاعات اصلی
  final _plateNumberController = TextEditingController();
  final _weightController = TextEditingController();
  final _numberController = TextEditingController();
  final _codeController = TextEditingController();
  final _theoryController = TextEditingController();
  final _responsibleController = TextEditingController();

  // لیست فرستنده‌ها از API
  List<Sender> _sendersList = [];
  Sender? _selectedSender;

  // مقادیر dropdown
  String? _selectedQualityGrade;
  String? _selectedResult;

  // کنترلرها برای آزمایش‌ها (3 آزمایش)
  final List<TextEditingController> _pvcControllers = List.generate(
    3,
    (_) => TextEditingController(),
  );
  final List<TextEditingController> _plasticizerControllers = List.generate(
    3,
    (_) => TextEditingController(),
  );
  final List<TextEditingController> _wasteMaterialControllers = List.generate(
    3,
    (_) => TextEditingController(),
  );
  final List<TextEditingController> _blackSaltColorControllers = List.generate(
    3,
    (_) => TextEditingController(),
  );
  final List<TextEditingController> _totalBlackSaltControllers = List.generate(
    3,
    (_) => TextEditingController(),
  );
  final List<TextEditingController> _moistureControllers = List.generate(
    3,
    (_) => TextEditingController(),
  );
  final List<TextEditingController> _wasteBlackSaltControllers = List.generate(
    3,
    (_) => TextEditingController(),
  );
  final List<TextEditingController> _mixedBlackSaltControllers = List.generate(
    3,
    (_) => TextEditingController(),
  );
  final List<TextEditingController> _colorChangeQuantitativeControllers =
      List.generate(3, (_) => TextEditingController());
  final List<TextEditingController> _cutSizemmControllers = List.generate(
    3,
    (_) => TextEditingController(),
  );
  final List<TextEditingController> _densityControllers = List.generate(
    3,
    (_) => TextEditingController(),
  );

  // dropdown‌های آزمایش‌ها
  final List<String?> _selectedColorChangeQualitative = [null, null, null];
  final List<String?> _selectedCutSizeQualitative = [null, null, null];

  bool _showBasicInfoPopup = true;
  bool _isSubmitting = false;

  // مقادیر حد قابل قبول
  final Map<String, dynamic> _acceptableLimits = {
    'pvc': 200,
    'plasticizer': 300,
    'wasteMaterial': 300,
    'blackSaltColor': 300,
    'totalBlackSalt': 300,
    'moisture': 2,
    'wasteBlackSalt': 5000,
    'mixedBlackSalt': 2,
    'colorChangeQuantitative': 20,
  };

  // لیست گزینه‌های dropdown
  final List<String> _qualityGradeOptions = ['A', 'B', 'C', 'D'];
  final List<String> _resultOptions = [
    'accepted',
    'relativeAccepted',
    'conditionalAccepted',
    'rejected',
  ];
  final List<String> _colorChangeOptions = ['کم', 'متوسط', 'زیاد'];
  final List<String> _cutSizeOptions = ['مناسب', 'نامناسب'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadSenders();
  }

  Future<void> _loadSenders() async {
    try {
      final response = await SenderApi.getSenders();
      if (response.isSuccess) {
        setState(() {
          _sendersList = response.data;
          if (_sendersList.isNotEmpty && _selectedSender == null) {
            _selectedSender = _sendersList.first;
          }
        });
      } else {
        _showSnackBar(
          'خطا در بارگذاری فرستندگان: ${response.message}',
          isError: true,
        );
      }
    } catch (e) {
      _showSnackBar('خطا در بارگذاری فرستندگان: $e', isError: true);
    } finally {}
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (var controller in [
      _plateNumberController,
      _weightController,
      _numberController,
      _codeController,
      _theoryController,
      _responsibleController,
      ..._pvcControllers,
      ..._plasticizerControllers,
      ..._wasteMaterialControllers,
      ..._blackSaltColorControllers,
      ..._totalBlackSaltControllers,
      ..._moistureControllers,
      ..._wasteBlackSaltControllers,
      ..._mixedBlackSaltControllers,
      ..._colorChangeQuantitativeControllers,
      ..._cutSizemmControllers,
      ..._densityControllers,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submitAllExperiments() async {
    if (!_validateBasicInfo()) {
      setState(() => _showBasicInfoPopup = true);
      return;
    }

    for (int i = 0; i < 3; i++) {
      if (_pvcControllers[i].text.isEmpty ||
          _plasticizerControllers[i].text.isEmpty ||
          _wasteMaterialControllers[i].text.isEmpty ||
          _blackSaltColorControllers[i].text.isEmpty ||
          _totalBlackSaltControllers[i].text.isEmpty ||
          _moistureControllers[i].text.isEmpty ||
          _wasteBlackSaltControllers[i].text.isEmpty ||
          _mixedBlackSaltControllers[i].text.isEmpty ||
          _selectedColorChangeQualitative[i] == null ||
          _colorChangeQuantitativeControllers[i].text.isEmpty ||
          _selectedCutSizeQualitative[i] == null ||
          _cutSizemmControllers[i].text.isEmpty ||
          _densityControllers[i].text.isEmpty) {
        _showSnackBar(
          'لطفاً تمام فیلدهای آزمایش ${i + 1} را پر کنید',
          isError: true,
        );
        _tabController.animateTo(i);
        return;
      }
    }

    setState(() => _isSubmitting = true);

    try {
      final receiptInfo = ReceiptInformation(
        sender: _selectedSender?.name ?? '',
        plateNumber: _plateNumberController.text,
        weight: double.parse(_weightController.text),
        number: _numberController.text,
        code: _codeController.text,
        qualityGrade: _selectedQualityGrade ?? 'A',
        result: _selectedResult ?? 'accepted',
        theory: _theoryController.text,
        responsible: _responsibleController.text,
      );

      final List<Experiment> experiments = [];
      for (int i = 0; i < 3; i++) {
        experiments.add(
          Experiment(
            row: 'تست ${i + 1}',
            pvc: double.parse(_pvcControllers[i].text),
            plasticizer: double.parse(_plasticizerControllers[i].text),
            wasteMaterial: double.parse(_wasteMaterialControllers[i].text),
            blackSaltColor: double.parse(_blackSaltColorControllers[i].text),
            totalBlackSalt: double.parse(_totalBlackSaltControllers[i].text),
            moisture: double.parse(_moistureControllers[i].text),
            wasteBlackSalt: double.parse(_wasteBlackSaltControllers[i].text),
            mixedBlackSalt: double.parse(_mixedBlackSaltControllers[i].text),
            colorChangeQualitative: _getColorChangeEnglishValue(
              _selectedColorChangeQualitative[i]!,
            ),
            colorChangeQuantitative: double.parse(
              _colorChangeQuantitativeControllers[i].text,
            ),
            cutSizeQualitative: _getCutSizeEnglishValue(
              _selectedCutSizeQualitative[i]!,
            ),
            cutSizemm: double.parse(_cutSizemmControllers[i].text),
            density: double.parse(_densityControllers[i].text),
          ),
        );
      }

      final request = SaveExperimentRequest(
        receiptInformation: receiptInfo,
        experiments: experiments,
      );

      print('📦 داده‌های ارسالی:');
      print(json.encode(request.toJson()));

      final response = await CargoApi.saveExperiment(request);

      if (response.isSuccess) {
        _showSnackBar(response.message);
        _clearForm();
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        _showSnackBar('خطا: ${response.message}', isError: true);
      }
    } on FormatException catch (e) {
      _showSnackBar(
        'لطفاً مقادیر عددی را به درستی وارد کنید. خطا: $e',
        isError: true,
      );
    } catch (e) {
      _showSnackBar('خطا در ارسال اطلاعات: $e', isError: true);
      print('❌ خطای کامل: $e');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String _getColorChangeEnglishValue(String persianValue) {
    switch (persianValue) {
      case 'کم':
        return 'low';
      case 'متوسط':
        return 'medium';
      case 'زیاد':
        return 'high';
      default:
        return 'low';
    }
  }

  String _getCutSizeEnglishValue(String persianValue) {
    switch (persianValue) {
      case 'مناسب':
        return 'suitable';
      case 'نامناسب':
        return 'unsuitable';
      default:
        return 'suitable';
    }
  }

  String _getResultPersianName(String value) {
    switch (value) {
      case 'accepted':
        return 'قبول';
      case 'relativeAccepted':
        return 'قبول نسبی';
      case 'conditionalAccepted':
        return 'قبول مشروط';
      case 'rejected':
        return 'مردود';
      default:
        return 'نامشخص';
    }
  }

  bool _validateBasicInfo() {
    if (_selectedSender == null ||
        _plateNumberController.text.isEmpty ||
        _numberController.text.isEmpty ||
        _codeController.text.isEmpty ||
        _weightController.text.isEmpty ||
        _selectedQualityGrade == null ||
        _selectedResult == null ||
        _theoryController.text.isEmpty ||
        _responsibleController.text.isEmpty) {
      _showSnackBar('لطفاً تمام اطلاعات اصلی را وارد کنید', isError: true);
      return false;
    }
    return true;
  }

  void _clearForm() {
    _plateNumberController.clear();
    _weightController.clear();
    _numberController.clear();
    _codeController.clear();
    _theoryController.clear();
    _responsibleController.clear();

    for (var controller in [
      ..._pvcControllers,
      ..._plasticizerControllers,
      ..._wasteMaterialControllers,
      ..._blackSaltColorControllers,
      ..._totalBlackSaltControllers,
      ..._moistureControllers,
      ..._wasteBlackSaltControllers,
      ..._mixedBlackSaltControllers,
      ..._colorChangeQuantitativeControllers,
      ..._cutSizemmControllers,
      ..._densityControllers,
    ]) {
      controller.clear();
    }

    setState(() {
      _selectedQualityGrade = null;
      _selectedResult = null;
      for (int i = 0; i < 3; i++) {
        _selectedColorChangeQualitative[i] = null;
        _selectedCutSizeQualitative[i] = null;
      }
    });
  }

  Future<void> _navigateToSenderManagementScreen() async {
    final result = await Navigator.push<Sender?>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const SenderManagementScreen(isSelectionMode: true),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _selectedSender = result;
      });

      if (!_sendersList.any((sender) => sender.id == result.id)) {
        setState(() {
          _sendersList.add(result);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    final horizontalPadding = screenWidth * 0.04;
    final verticalPadding = screenHeight * 0.02;
    final fieldSpacing = screenHeight * 0.015;
    final buttonSpacing = screenWidth * 0.03;
    final cardPadding = screenWidth * 0.03;
    final iconSize = screenWidth * 0.06;
    final fontSizeSmall = screenWidth * 0.035;
    final fontSizeMedium = screenWidth * 0.04;

    return Scaffold(
      appBar: _buildAppBar(screenWidth),
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Container(
                width: screenWidth > 600
                    ? screenWidth * 0.7
                    : screenWidth * 0.95,
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalPadding,
                ),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(
                            screenWidth * 0.02,
                          ),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          labelColor: Colors.blue[700],
                          unselectedLabelColor: Colors.grey,
                          indicator: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                              screenWidth * 0.02,
                            ),
                          ),
                          tabs: const [
                            Tab(text: 'تست اول'),
                            Tab(text: 'تست دوم'),
                            Tab(text: 'تست سوم'),
                          ],
                        ),
                      ),

                      SizedBox(height: fieldSpacing),

                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildTestTab(0, fontSizeSmall, fieldSpacing),
                            _buildTestTab(1, fontSizeSmall, fieldSpacing),
                            _buildTestTab(2, fontSizeSmall, fieldSpacing),
                          ],
                        ),
                      ),

                      SizedBox(height: fieldSpacing * 1.5),
                      _buildActionButtons(buttonSpacing, fontSizeMedium),
                    ],
                  ),
                ),
              ),
            ),

            if (_showBasicInfoPopup)
              _buildBasicInfoPopup(
                screenWidth,
                screenHeight,
                fontSizeSmall,
                fontSizeMedium,
                cardPadding,
                fieldSpacing,
              ),

            if (_isSubmitting)
              Container(
                color: Colors.black54,
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoPopup(
    double screenWidth,
    double screenHeight,
    double fontSizeSmall,
    double fontSizeMedium,
    double cardPadding,
    double fieldSpacing,
  ) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          width: screenWidth * 0.9,
          height: screenHeight * 0.85,
          padding: EdgeInsets.all(cardPadding * 1.5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(cardPadding * 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info,
                    color: Colors.blue,
                    size: fontSizeMedium * 1.5,
                  ),
                  SizedBox(width: cardPadding),
                  Text(
                    'اطلاعات اصلی بار',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: fontSizeMedium,
                      fontFamily: 'Vazir',
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () =>
                        setState(() => _showBasicInfoPopup = false),
                    icon: Icon(
                      Icons.close,
                      color: Colors.grey,
                      size: fontSizeMedium,
                    ),
                  ),
                ],
              ),

              SizedBox(height: fieldSpacing),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildSenderDropdown(fontSizeSmall),
                      SizedBox(height: fieldSpacing),

                      _buildTextField(
                        'شماره پلاک',
                        _plateNumberController,
                        fontSizeSmall: fontSizeSmall,
                      ),
                      SizedBox(height: fieldSpacing),

                      _buildTextField(
                        'شماره فاکتور',
                        _numberController,
                        fontSizeSmall: fontSizeSmall,
                      ),
                      SizedBox(height: fieldSpacing),

                      _buildTextField(
                        'کد',
                        _codeController,
                        fontSizeSmall: fontSizeSmall,
                      ),
                      SizedBox(height: fieldSpacing),

                      _buildNumberField(
                        'وزن (کیلوگرم)',
                        _weightController,
                        TextInputType.numberWithOptions(decimal: true),
                        fontSizeSmall: fontSizeSmall,
                      ),
                      SizedBox(height: fieldSpacing),

                      _buildQualityGradeDropdown(fontSizeSmall),
                      SizedBox(height: fieldSpacing),

                      _buildResultDropdown(fontSizeSmall),
                      SizedBox(height: fieldSpacing),

                      _buildTextField(
                        'نظر مدیر کارخانه',
                        _theoryController,
                        fontSizeSmall: fontSizeSmall,
                      ),
                      SizedBox(height: fieldSpacing),

                      _buildTextField(
                        'مسئول آزمایشگاه',
                        _responsibleController,
                        fontSizeSmall: fontSizeSmall,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: fieldSpacing),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_validateBasicInfo()) {
                      setState(() => _showBasicInfoPopup = false);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(
                      vertical: fontSizeMedium * 1.2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(fontSizeMedium),
                    ),
                  ),
                  child: Text(
                    'تایید اطلاعات',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Vazir',
                      fontSize: fontSizeMedium,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTestTab(
    int tabIndex,
    double fontSizeSmall,
    double fieldSpacing,
  ) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildBasicInfoSummary(fontSizeSmall, fieldSpacing),
          SizedBox(height: fieldSpacing),

          // PVC
          _buildNumberFieldWithLimit(
            'PVC (ppm)',
            _pvcControllers[tabIndex],
            _acceptableLimits['pvc'],
            fontSizeSmall: fontSizeSmall,
          ),
          SizedBox(height: fieldSpacing),

          // Plasticizer
          _buildNumberFieldWithLimit(
            'نرم‌کننده (ppm)',
            _plasticizerControllers[tabIndex],
            _acceptableLimits['plasticizer'],
            fontSizeSmall: fontSizeSmall,
          ),
          SizedBox(height: fieldSpacing),

          // Waste Material
          _buildNumberFieldWithLimit(
            'مواد زائد (ppm)',
            _wasteMaterialControllers[tabIndex],
            _acceptableLimits['wasteMaterial'],
            fontSizeSmall: fontSizeSmall,
          ),
          SizedBox(height: fieldSpacing),

          // Black Salt Color
          _buildNumberFieldWithLimit(
            ' پرک رنگی  (ppm)',
            _blackSaltColorControllers[tabIndex],
            _acceptableLimits['blackSaltColor'],
            fontSizeSmall: fontSizeSmall,
          ),
          SizedBox(height: fieldSpacing),

          // Total Black Salt
          _buildNumberFieldWithLimit(
            ' جمع ناخالصی(ppm)',
            _totalBlackSaltControllers[tabIndex],
            _acceptableLimits['totalBlackSalt'],
            fontSizeSmall: fontSizeSmall,
          ),
          SizedBox(height: fieldSpacing),

          // Moisture
          _buildNumberFieldWithLimit(
            'رطوبت (%)',
            _moistureControllers[tabIndex],
            _acceptableLimits['moisture'],
            fontSizeSmall: fontSizeSmall,
          ),
          SizedBox(height: fieldSpacing),

          // Waste Black Salt
          _buildNumberFieldWithLimit(
            'مواد زائد(ppm)',
            _wasteBlackSaltControllers[tabIndex],
            _acceptableLimits['wasteBlackSalt'],
            fontSizeSmall: fontSizeSmall,
          ),
          SizedBox(height: fieldSpacing),

          // Mixed Black Salt
          _buildNumberFieldWithLimit(
            ' پلیمر متفرقه(%)',
            _mixedBlackSaltControllers[tabIndex],
            _acceptableLimits['mixedBlackSalt'],
            fontSizeSmall: fontSizeSmall,
          ),
          SizedBox(height: fieldSpacing),

          // تغییر رنگ (کیفی)
          _buildColorChangeDropdown(tabIndex, fontSizeSmall),
          SizedBox(height: fieldSpacing),

          // Color Change (Quantitative)
          _buildNumberFieldWithLimit(
            'تغییر رنگ (%)',
            _colorChangeQuantitativeControllers[tabIndex],
            _acceptableLimits['colorChangeQuantitative'],
            fontSizeSmall: fontSizeSmall,
          ),
          SizedBox(height: fieldSpacing),

          // اندازه برش (کیفی)
          _buildCutSizeDropdown(tabIndex, fontSizeSmall),
          SizedBox(height: fieldSpacing),

          // Cut Size (mm)
          _buildNumberField(
            'اندازه برش (میلی‌متر)',
            _cutSizemmControllers[tabIndex],
            TextInputType.numberWithOptions(decimal: true),
            fontSizeSmall: fontSizeSmall,
          ),
          SizedBox(height: fieldSpacing),

          // Density
          _buildNumberField(
            'چگالی',
            _densityControllers[tabIndex],
            TextInputType.numberWithOptions(decimal: true),
            fontSizeSmall: fontSizeSmall,
          ),
          SizedBox(height: fieldSpacing * 2),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSummary(double fontSizeSmall, double fieldSpacing) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.summarize,
                  color: Colors.green,
                  size: fontSizeSmall * 1.2,
                ),
                SizedBox(width: 8),
                Text(
                  'خلاصه اطلاعات اصلی',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: fontSizeSmall,
                    fontFamily: 'Vazir',
                    color: Colors.green,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => setState(() => _showBasicInfoPopup = true),
                  icon: Icon(
                    Icons.edit,
                    color: Colors.blue,
                    size: fontSizeSmall,
                  ),
                  padding: EdgeInsets.all(16),
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            SizedBox(height: 8),
            if (_selectedSender != null)
              _buildSummaryRow(
                'فرستنده:',
                _selectedSender!.name,
                fontSizeSmall,
              ),
            if (_plateNumberController.text.isNotEmpty)
              _buildSummaryRow(
                'شماره پلاک:',
                _plateNumberController.text,
                fontSizeSmall,
              ),
            if (_numberController.text.isNotEmpty)
              _buildSummaryRow(
                'شماره فاکتور:',
                _numberController.text,
                fontSizeSmall,
              ),
            if (_codeController.text.isNotEmpty)
              _buildSummaryRow('کد:', _codeController.text, fontSizeSmall),
            if (_weightController.text.isNotEmpty)
              _buildSummaryRow(
                'وزن:',
                '${_weightController.text} کیلوگرم',
                fontSizeSmall,
              ),
            if (_selectedQualityGrade != null)
              _buildSummaryRow(
                'درجه کیفی:',
                _selectedQualityGrade!,
                fontSizeSmall,
              ),
            if (_selectedResult != null)
              _buildSummaryRow(
                'نتیجه:',
                _getResultPersianName(_selectedResult!),
                fontSizeSmall,
              ),
            if (_selectedSender == null &&
                _plateNumberController.text.isEmpty &&
                _weightController.text.isEmpty)
              Text(
                'اطلاعات اصلی وارد نشده است',
                style: TextStyle(
                  fontSize: fontSizeSmall * 0.9,
                  fontFamily: 'Vazir',
                  color: Colors.orange,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, double fontSizeSmall) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: fontSizeSmall * 0.9,
                fontFamily: 'Vazir',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: fontSizeSmall * 0.9,
                fontFamily: 'Vazir',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    double fontSizeSmall = 14,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
      ),
      style: TextStyle(fontSize: fontSizeSmall, fontFamily: 'Vazir'),
      validator: (v) => (v?.isEmpty ?? true) ? 'این فیلد الزامی است' : null,
    );
  }

  Widget _buildNumberField(
    String label,
    TextEditingController controller,
    TextInputType keyboardType, {
    double fontSizeSmall = 14,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
      ),
      style: TextStyle(fontSize: fontSizeSmall, fontFamily: 'Vazir'),
      validator: (v) {
        if (v?.isEmpty ?? true) return 'این فیلد الزامی است';
        final num = double.tryParse(v!);
        if (num == null) return 'عدد معتبر وارد کنید';
        return null;
      },
    );
  }

  Widget _buildNumberFieldWithLimit(
    String label,
    TextEditingController controller,
    dynamic limit, {
    double fontSizeSmall = 14,
  }) {
    final unit = label.contains('%') ? '%' : 'ppm';
    final limitText = 'حد قابل قبول: $limit$unit';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
            suffixIcon: controller.text.isNotEmpty
                ? _buildValueIndicator(controller.text, limit, label)
                : null,
          ),
          style: TextStyle(fontSize: fontSizeSmall, fontFamily: 'Vazir'),
          validator: (v) {
            if (v?.isEmpty ?? true) return 'این فیلد الزامی است';
            final num = double.tryParse(v!);
            if (num == null) return 'عدد معتبر وارد کنید';
            return null;
          },
          onChanged: (value) {
            setState(() {});
          },
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4, right: 8),
          child: Text(
            limitText,
            style: TextStyle(
              fontSize: fontSizeSmall * 0.8,
              fontFamily: 'Vazir',
              color: Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }

  Widget? _buildValueIndicator(String value, dynamic limit, String label) {
    final doubleValue = double.tryParse(value);
    if (doubleValue == null) return null;

    Color color;
    String tooltip;

    if (label.contains('%')) {
      color = doubleValue > limit ? Colors.red : Colors.green;
      tooltip = doubleValue > limit ? 'بیشتر از حد مجاز' : 'قابل قبول';
    } else {
      color = doubleValue > limit ? Colors.red : Colors.green;
      tooltip = doubleValue > limit ? 'بیشتر از حد مجاز' : 'قابل قبول';
    }

    return Tooltip(
      message: tooltip,
      child: Container(
        margin: const EdgeInsets.all(8),
        width: 20,
        height: 20,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: const Icon(Icons.circle, size: 20, color: Colors.white),
      ),
    );
  }

  Widget _buildSenderDropdown(double fontSizeSmall) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'فرستنده',
          style: TextStyle(
            fontSize: fontSizeSmall,
            fontFamily: 'Vazir',
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[400]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButton<Sender>(
                    value: _selectedSender,
                    isExpanded: true,
                    underline: const SizedBox(),
                    hint: Text(
                      'فرستنده را انتخاب کنید',
                      style: TextStyle(
                        fontSize: fontSizeSmall,
                        fontFamily: 'Vazir',
                      ),
                    ),
                    items: [
                      if (_selectedSender != null)
                        DropdownMenuItem(
                          value: null,
                          child: Text(
                            'بدون انتخاب',
                            style: TextStyle(
                              fontSize: fontSizeSmall,
                              fontFamily: 'Vazir',
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ..._sendersList.map((sender) {
                        return DropdownMenuItem(
                          value: sender,
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: fontSizeSmall * 0.7,
                                backgroundColor: Colors.blue[100],
                                child: Text(
                                  sender.name.substring(0, 1).toUpperCase(),
                                  style: TextStyle(
                                    fontSize: fontSizeSmall * 0.8,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      sender.name,
                                      style: TextStyle(
                                        fontSize: fontSizeSmall,
                                        fontFamily: 'Vazir',
                                      ),
                                    ),
                                    Text(
                                      sender.phone,
                                      style: TextStyle(
                                        fontSize: fontSizeSmall * 0.9,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      DropdownMenuItem<Sender>(
                        value: Sender(
                          id: -1,
                          name: 'افزودن فرستنده جدید',
                          phone: '',
                          address: '',
                          createdAt: DateTime.now(),
                          updatedAt: DateTime.now(),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.add_circle,
                              color: Colors.green,
                              size: fontSizeSmall * 1.2,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'افزودن فرستنده جدید',
                              style: TextStyle(
                                fontSize: fontSizeSmall,
                                fontFamily: 'Vazir',
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (sender) async {
                      if (sender != null && sender.id == -1) {
                        await _navigateToSenderManagementScreen();
                      } else {
                        setState(() {
                          _selectedSender = sender;
                        });
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () async {
                    final result = await Navigator.push<Sender?>(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const SenderManagementScreen(isSelectionMode: true),
                      ),
                    );

                    if (result != null && mounted) {
                      setState(() {
                        _selectedSender = result;
                      });
                    }
                  },
                  tooltip: 'جستجوی فرستنده',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQualityGradeDropdown(double fontSizeSmall) {
    return DropdownButtonFormField<String>(
      value: _selectedQualityGrade,
      decoration: InputDecoration(
        labelText: 'درجه کیفی',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
      ),
      items: _qualityGradeOptions
          .map(
            (grade) => DropdownMenuItem(
              value: grade,
              child: Text(
                grade,
                style: TextStyle(fontSize: fontSizeSmall, fontFamily: 'Vazir'),
              ),
            ),
          )
          .toList(),
      onChanged: (value) => setState(() => _selectedQualityGrade = value),
      validator: (value) => value == null ? 'درجه کیفی را انتخاب کنید' : null,
    );
  }

  Widget _buildResultDropdown(double fontSizeSmall) {
    return DropdownButtonFormField<String>(
      value: _selectedResult,
      decoration: InputDecoration(
        labelText: 'نتیجه بازرسی',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
      ),
      items: _resultOptions
          .map(
            (result) => DropdownMenuItem(
              value: result,
              child: Text(
                _getResultPersianName(result),
                style: TextStyle(fontSize: fontSizeSmall, fontFamily: 'Vazir'),
              ),
            ),
          )
          .toList(),
      onChanged: (value) => setState(() => _selectedResult = value),
      validator: (value) => value == null ? 'نتیجه را انتخاب کنید' : null,
    );
  }

  Widget _buildColorChangeDropdown(int tabIndex, double fontSizeSmall) {
    return DropdownButtonFormField<String>(
      value: _selectedColorChangeQualitative[tabIndex],
      decoration: InputDecoration(
        labelText: 'تغییر رنگ (کیفی)',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        helperText: 'حد قابل قبول: کم',
        helperStyle: TextStyle(
          fontSize: fontSizeSmall * 0.8,
          color: Colors.grey[600],
        ),
      ),
      items: _colorChangeOptions
          .map(
            (e) => DropdownMenuItem(
              value: e,
              child: Text(
                e,
                style: TextStyle(fontSize: fontSizeSmall, fontFamily: 'Vazir'),
              ),
            ),
          )
          .toList(),
      onChanged: (value) =>
          setState(() => _selectedColorChangeQualitative[tabIndex] = value),
      validator: (value) => value == null ? 'انتخاب کنید' : null,
    );
  }

  Widget _buildCutSizeDropdown(int tabIndex, double fontSizeSmall) {
    return DropdownButtonFormField<String>(
      value: _selectedCutSizeQualitative[tabIndex],
      decoration: InputDecoration(
        labelText: 'اندازه برش (کیفی)',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        helperText: 'حد قابل قبول: مناسب',
        helperStyle: TextStyle(
          fontSize: fontSizeSmall * 0.8,
          color: Colors.grey[600],
        ),
      ),
      items: _cutSizeOptions
          .map(
            (e) => DropdownMenuItem(
              value: e,
              child: Text(
                e,
                style: TextStyle(fontSize: fontSizeSmall, fontFamily: 'Vazir'),
              ),
            ),
          )
          .toList(),
      onChanged: (value) =>
          setState(() => _selectedCutSizeQualitative[tabIndex] = value),
      validator: (value) => value == null ? 'انتخاب کنید' : null,
    );
  }

  PreferredSizeWidget _buildAppBar(double screenWidth) => PreferredSize(
    preferredSize: Size.fromHeight(screenWidth * 0.15),
    child: SafeArea(
      child: Container(
        margin: EdgeInsets.all(screenWidth * 0.03),
        decoration: BoxDecoration(
          color: Colors.blue[700],
          borderRadius: BorderRadius.circular(screenWidth * 0.1),
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
          title: Text(
            'ثبت آزمایش پرک',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: screenWidth * 0.045,
              fontFamily: 'Vazir',
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(screenWidth * 0.08)),
          ),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: screenWidth * 0.03),
              child: CircleAvatar(
                radius: screenWidth * 0.04,
                backgroundColor: Colors.white,
                child: ClipOval(
                  child: Image.asset(
                    'assets/image/Logo.jpg',
                    width: screenWidth * 0.06,
                    height: screenWidth * 0.06,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.business,
                        color: Colors.blue,
                        size: screenWidth * 0.04,
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _buildActionButtons(double buttonSpacing, double fontSizeMedium) =>
      Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitAllExperiments,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(vertical: fontSizeMedium * 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(fontSizeMedium),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'ثبت نهایی تمام آزمایش‌ها',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Vazir',
                        fontSize: fontSizeMedium,
                      ),
                    ),
            ),
          ),
          SizedBox(width: buttonSpacing),
          Expanded(
            child: OutlinedButton(
              onPressed: _isSubmitting ? null : () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: fontSizeMedium * 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(fontSizeMedium),
                ),
                side: const BorderSide(color: Colors.grey),
              ),
              child: Text(
                'انصراف',
                style: TextStyle(
                  color: Colors.grey,
                  fontFamily: 'Vazir',
                  fontSize: fontSizeMedium,
                ),
              ),
            ),
          ),
        ],
      );
}
