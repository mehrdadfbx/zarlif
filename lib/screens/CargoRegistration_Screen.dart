// ignore_for_file: unused_element
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';

// مدل‌های موقت تا زمانی که API واقعی آماده شود
class Sender {
  final int? id;
  final String senderName;

  Sender({this.id, required this.senderName});
}

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
  final int testNumber;

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
    required this.testNumber,
  });
}

// API موقت
class SenderApi {
  static Future<List<Sender>> getSenders() async {
    // داده‌های نمونه تا زمانی که API واقعی آماده شود
    await Future.delayed(const Duration(seconds: 1)); // شبیه‌سازی تاخیر شبکه
    return [
      Sender(id: 1, senderName: 'شرکت الف'),
      Sender(id: 2, senderName: 'شرکت ب'),
      Sender(id: 3, senderName: 'شرکت ج'),
    ];
  }
}

class CargoApi {
  static Future<Map<String, dynamic>> addCargo(CargoModel cargo) async {
    // شبیه‌سازی ارسال به API
    await Future.delayed(const Duration(seconds: 2));

    // در حالت واقعی، اینجا درخواست HTTP ارسال می‌شود
    // فعلاً همیشه موفق برمی‌گردانیم
    return {
      "success": true,
      "message": "بار با موفقیت ثبت شد",
      "data": {"id": 123}, // ID نمونه
    };
  }
}

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

  // کنترلرها
  final _weightController = TextEditingController();
  final _moistureController = TextEditingController();
  final _priceController = TextEditingController();
  final _pvcController = TextEditingController();
  final _dirtyFlakeController = TextEditingController();
  final _polymerController = TextEditingController();
  final _wasteController = TextEditingController();
  final _coloredFlakeController = TextEditingController();
  final _enteredByController = TextEditingController();

  // کنترلرها برای آزمایش‌های مختلف
  final List<TextEditingController> _moistureControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  final List<TextEditingController> _pvcControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  final List<TextEditingController> _dirtyFlakeControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  final List<TextEditingController> _polymerControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  final List<TextEditingController> _wasteControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  final List<TextEditingController> _coloredFlakeControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  String? _selectedColorChange;
  Jalali? _selectedJalaliDate;
  String _displayDate = 'در حال بارگذاری...';
  List<Sender> _senders = [];
  Sender? _selectedSender;
  bool _isLoadingSenders = true;
  final List<double> _totalPpm = [0.0, 0.0, 0.0];

  // متغیر برای نمایش پاپ‌آپ اطلاعات اصلی
  bool _showBasicInfoPopup = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _selectedJalaliDate = Jalali.now();
    _displayDate = _formatJalali(_selectedJalaliDate!);
    _loadSenders();
    _setupNumberFormatting();
    _setupPpmListeners();

    // نمایش پاپ‌آپ اطلاعات اصلی هنگام شروع
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _showBasicInfoPopup = true;
      });
    });
  }

  void _setupNumberFormatting() {
    _priceController.addListener(() {
      final text = _priceController.text.replaceAll(',', '');
      if (text.isNotEmpty && RegExp(r'^\d+$').hasMatch(text)) {
        final number = int.tryParse(text) ?? 0;
        final formatted = _formatNumber(number);
        if (_priceController.text != formatted) {
          _priceController.value = TextEditingValue(
            text: formatted,
            selection: TextSelection.collapsed(offset: formatted.length),
          );
        }
      }
    });
  }

  void _setupPpmListeners() {
    for (int i = 0; i < 3; i++) {
      _setupControllerListeners(i);
    }
  }

  void _setupControllerListeners(int tabIndex) {
    final controllers = [
      _pvcControllers[tabIndex],
      _dirtyFlakeControllers[tabIndex],
      _polymerControllers[tabIndex],
      _wasteControllers[tabIndex],
      _coloredFlakeControllers[tabIndex],
    ];

    for (var controller in controllers) {
      controller.addListener(() => _calculateTotalPpm(tabIndex));
    }
  }

  void _calculateTotalPpm(int tabIndex) {
    final controllers = [
      _pvcControllers[tabIndex],
      _dirtyFlakeControllers[tabIndex],
      _polymerControllers[tabIndex],
      _wasteControllers[tabIndex],
      _coloredFlakeControllers[tabIndex],
    ];

    double total = 0;
    for (var controller in controllers) {
      final value = double.tryParse(controller.text) ?? 0;
      total += value;
    }

    setState(() {
      _totalPpm[tabIndex] = total;
    });
  }

  String _formatNumber(int number) {
    final str = number.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      buffer.write(str[str.length - 1 - i]);
      if ((i + 1) % 3 == 0 && i + 1 != str.length) buffer.write(',');
    }
    return buffer.toString().split('').reversed.join('');
  }

  int _parseFormattedNumber(String formatted) =>
      int.tryParse(formatted.replaceAll(',', '')) ?? 0;

  double _parseFormattedDouble(String formatted) =>
      double.tryParse(formatted.replaceAll(',', '')) ?? 0.0;

  String _formatJalali(Jalali date) =>
      '${date.year}/${_twoDigits(date.month)}/${_twoDigits(date.day)}';

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  Future<void> _loadSenders() async {
    setState(() => _isLoadingSenders = true);
    try {
      final senders = await SenderApi.getSenders();
      setState(() {
        _senders = senders;
        if (senders.isNotEmpty && _selectedSender == null) {
          _selectedSender = senders.first;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا در بارگذاری فرستندگان: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoadingSenders = false);
    }
  }

  Future<void> _selectJalaliDate(BuildContext context) async {
    final picked = await showPersianDatePicker(
      context: context,
      initialDate: _selectedJalaliDate ?? Jalali.now(),
      firstDate: Jalali(1395, 1, 1),
      lastDate: Jalali(1410, 12, 29),
    );
    if (picked != null) {
      setState(() {
        _selectedJalaliDate = picked;
        _displayDate = _formatJalali(picked);
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (var c in [
      _weightController,
      _moistureController,
      _priceController,
      _pvcController,
      _dirtyFlakeController,
      _polymerController,
      _wasteController,
      _coloredFlakeController,
      _enteredByController,
    ]) {
      c.dispose();
    }

    // Dispose all tab controllers
    for (var controllers in [
      _moistureControllers,
      _pvcControllers,
      _dirtyFlakeControllers,
      _polymerControllers,
      _wasteControllers,
      _coloredFlakeControllers,
    ]) {
      for (var controller in controllers) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    // محاسبه اندازه‌ها بر اساس درصد
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
                      // نمایش تاریخ در بالای فرم
                      _buildDateSection(
                        cardPadding,
                        fontSizeMedium,
                        fontSizeSmall,
                        iconSize,
                      ),
                      SizedBox(height: fieldSpacing * 1.5),

                      // تب‌بار
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
                            Tab(text: 'آزمایش یک'),
                            Tab(text: 'آزمایش دو'),
                            Tab(text: 'آزمایش سه'),
                          ],
                        ),
                      ),

                      SizedBox(height: fieldSpacing),

                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildTestTab(
                              0,
                              screenWidth,
                              cardPadding,
                              fontSizeSmall,
                              fieldSpacing,
                              fontSizeMedium,
                            ),
                            _buildTestTab(
                              1,
                              screenWidth,
                              cardPadding,
                              fontSizeSmall,
                              fieldSpacing,
                              fontSizeMedium,
                            ),
                            _buildTestTab(
                              2,
                              screenWidth,
                              cardPadding,
                              fontSizeSmall,
                              fieldSpacing,
                              fontSizeMedium,
                            ),
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

            // پاپ‌آپ اطلاعات اصلی
            if (_showBasicInfoPopup)
              _buildBasicInfoPopup(
                screenWidth,
                screenHeight,
                fontSizeSmall,
                fontSizeMedium,
                cardPadding,
                fieldSpacing,
              ),
          ],
        ),
      ),
    );
  }

  // ویجت برای نمایش تاریخ در بالای فرم
  Widget _buildDateSection(
    double cardPadding,
    double fontSizeMedium,
    double fontSizeSmall,
    double iconSize,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cardPadding),
      ),
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: Colors.blue, size: iconSize),
            SizedBox(width: cardPadding),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تاریخ دریافت بار',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: fontSizeMedium,
                    fontFamily: 'Vazir',
                  ),
                ),
                SizedBox(height: cardPadding * 0.3),
                InkWell(
                  onTap: () => _selectJalaliDate(context),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: cardPadding,
                      vertical: cardPadding * 0.5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(cardPadding * 0.5),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Row(
                      children: [
                        Text(
                          _displayDate,
                          style: TextStyle(
                            fontSize: fontSizeSmall,
                            fontFamily: 'Vazir',
                            color: Colors.blue[800],
                          ),
                        ),
                        SizedBox(width: cardPadding * 0.5),
                        Icon(
                          Icons.edit_calendar,
                          color: Colors.blue[700],
                          size: fontSizeSmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            // دکمه برای نمایش مجدد پاپ‌آپ اطلاعات اصلی
            IconButton(
              onPressed: () {
                setState(() {
                  _showBasicInfoPopup = true;
                });
              },
              icon: Icon(
                Icons.info_outline,
                color: Colors.blue,
                size: iconSize,
              ),
              tooltip: 'مشاهده اطلاعات اصلی',
            ),
          ],
        ),
      ),
    );
  }

  // ویجت پاپ‌آپ اطلاعات اصلی
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
          height: screenHeight * 0.6,
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
              // هدر پاپ‌آپ
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
                    onPressed: () {
                      setState(() {
                        _showBasicInfoPopup = false;
                      });
                    },
                    icon: Icon(
                      Icons.close,
                      color: Colors.grey,
                      size: fontSizeMedium,
                    ),
                  ),
                ],
              ),

              SizedBox(height: fieldSpacing),

              // محتوای پاپ‌آپ
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildSenderDropdown(fontSizeSmall),
                      SizedBox(height: fieldSpacing),
                      _buildNumberField(
                        'وزن (kg)',
                        _weightController,
                        TextInputType.numberWithOptions(decimal: true),
                        isDecimal: true,
                        fontSizeSmall: fontSizeSmall,
                      ),
                      SizedBox(height: fieldSpacing),
                      _buildNumberField(
                        'قیمت (ریال)',
                        _priceController,
                        TextInputType.number,
                        formatNumber: true,
                        fontSizeSmall: fontSizeSmall,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: fieldSpacing),

              // دکمه تایید
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_selectedSender != null &&
                        _weightController.text.isNotEmpty &&
                        _priceController.text.isNotEmpty) {
                      setState(() {
                        _showBasicInfoPopup = false;
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('لطفاً تمام اطلاعات اصلی را وارد کنید'),
                          backgroundColor: Colors.orange,
                        ),
                      );
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

  // ویجت برای هر تب آزمایش
  Widget _buildTestTab(
    int tabIndex,
    double screenWidth,
    double cardPadding,
    double fontSizeSmall,
    double fieldSpacing,
    double fontSizeMedium,
  ) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // نمایش خلاصه اطلاعات اصلی (فقط خواندنی)
          _buildBasicInfoSummary(screenWidth, cardPadding, fontSizeSmall),
          SizedBox(height: fieldSpacing),

          // فیلدهای آزمایش
          _buildPercentField(
            'رطوبت (%)',
            _moistureControllers[tabIndex],
            fontSizeSmall: fontSizeSmall,
          ),
          SizedBox(height: fieldSpacing),
          _buildPpmField(
            'PVC (ppm)',
            _pvcControllers[tabIndex],
            fontSizeSmall: fontSizeSmall,
          ),
          SizedBox(height: fieldSpacing),
          _buildPpmField(
            'پرک کثیف (ppm)',
            _dirtyFlakeControllers[tabIndex],
            fontSizeSmall: fontSizeSmall,
          ),
          SizedBox(height: fieldSpacing),
          _buildPpmField(
            'پلیمر (ppm)',
            _polymerControllers[tabIndex],
            fontSizeSmall: fontSizeSmall,
          ),
          SizedBox(height: fieldSpacing),
          _buildPpmField(
            'مواد زائد (ppm)',
            _wasteControllers[tabIndex],
            fontSizeSmall: fontSizeSmall,
          ),
          SizedBox(height: fieldSpacing),
          _buildPpmField(
            'پرک رنگی (ppm)',
            _coloredFlakeControllers[tabIndex],
            fontSizeSmall: fontSizeSmall,
          ),
          SizedBox(height: fieldSpacing),

          // نمایش مجموع ppm برای این آزمایش
          _buildTotalPpmIndicator(
            fontSizeSmall,
            fontSizeMedium,
            _totalPpm[tabIndex],
            tabIndex,
          ),
          SizedBox(height: fieldSpacing),

          // فیلدهای مشترک
          _buildColorChangeDropdown(fontSizeSmall),
          SizedBox(height: fieldSpacing),
          _buildField(
            'وارد کننده اطلاعات',
            _enteredByController,
            TextInputType.text,
            fontSizeSmall: fontSizeSmall,
          ),
        ],
      ),
    );
  }

  // ویجت برای نمایش خلاصه اطلاعات اصلی
  Widget _buildBasicInfoSummary(
    double screenWidth,
    double cardPadding,
    double fontSizeSmall,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(screenWidth * 0.02),
      ),
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
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
                SizedBox(width: cardPadding * 0.5),
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
                  onPressed: () {
                    setState(() {
                      _showBasicInfoPopup = true;
                    });
                  },
                  icon: Icon(
                    Icons.edit,
                    color: Colors.blue,
                    size: fontSizeSmall,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                  iconSize: fontSizeSmall * 1.2,
                ),
              ],
            ),
            SizedBox(height: cardPadding * 0.5),
            if (_selectedSender != null)
              Text(
                'فرستنده: ${_selectedSender!.senderName}',
                style: TextStyle(
                  fontSize: fontSizeSmall * 0.9,
                  fontFamily: 'Vazir',
                ),
              ),
            if (_weightController.text.isNotEmpty)
              Text(
                'وزن: ${_weightController.text} kg',
                style: TextStyle(
                  fontSize: fontSizeSmall * 0.9,
                  fontFamily: 'Vazir',
                ),
              ),
            if (_priceController.text.isNotEmpty)
              Text(
                'قیمت: ${_priceController.text} ریال',
                style: TextStyle(
                  fontSize: fontSizeSmall * 0.9,
                  fontFamily: 'Vazir',
                ),
              ),
            if (_selectedSender == null &&
                _weightController.text.isEmpty &&
                _priceController.text.isEmpty)
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

  // ویجت برای نمایش مجموع ppm
  Widget _buildTotalPpmIndicator(
    double fontSizeSmall,
    double fontSizeMedium,
    double totalPpm,
    int tabIndex,
  ) {
    Color color;
    IconData icon;
    String status;

    if (totalPpm == 0) {
      color = Colors.grey;
      icon = Icons.info_outline;
      status = 'مقادیر ppm وارد نشده‌اند';
    } else if (totalPpm > 1000000) {
      color = Colors.orange;
      icon = Icons.warning_amber_outlined;
      status = 'مجموع ppm بالا است';
    } else {
      color = Colors.blue;
      icon = Icons.check_circle_outline;
      status = 'مجموع ppm قابل قبول است';
    }

    return Container(
      padding: EdgeInsets.all(fontSizeMedium),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(fontSizeMedium),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: fontSizeMedium * 1.5),
          SizedBox(width: fontSizeMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'آزمایش ${tabIndex + 1} - مجموع ppm: ${_formatNumber(totalPpm.toInt())}',
                  style: TextStyle(
                    fontFamily: 'Vazir',
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: fontSizeMedium,
                  ),
                ),
                Text(
                  status,
                  style: TextStyle(
                    fontFamily: 'Vazir',
                    fontSize: fontSizeSmall,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberField(
    String label,
    TextEditingController controller,
    TextInputType type, {
    bool isDecimal = false,
    bool formatNumber = false,
    double fontSizeSmall = 14,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      inputFormatters: formatNumber
          ? [FilteringTextInputFormatter.digitsOnly]
          : [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(fontSizeSmall * 2),
        ),
        suffixText: formatNumber ? 'ریال' : null,
        contentPadding: EdgeInsets.symmetric(
          horizontal: fontSizeSmall,
          vertical: fontSizeSmall * 1.2,
        ),
      ),
      style: TextStyle(fontSize: fontSizeSmall, fontFamily: 'Vazir'),
      validator: (v) => (v?.isEmpty ?? true) ? 'الزامی' : null,
    );
  }

  Widget _buildPercentField(
    String label,
    TextEditingController controller, {
    double fontSizeSmall = 14,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(fontSizeSmall * 2),
        ),
        suffixText: '%',
        contentPadding: EdgeInsets.symmetric(
          horizontal: fontSizeSmall,
          vertical: fontSizeSmall * 1.2,
        ),
      ),
      style: TextStyle(fontSize: fontSizeSmall, fontFamily: 'Vazir'),
      onChanged: (value) {
        if (_formKey.currentState != null) {
          _formKey.currentState!.validate();
        }
      },
      validator: (v) {
        if (v?.isEmpty ?? true) return 'الزامی';
        final number = double.tryParse(v!);
        if (number == null) return 'عدد معتبر وارد کنید';
        if (number < 0) return 'درصد نمی‌تواند منفی باشد';
        if (number > 100) return 'درصد نمی‌تواند بیشتر از ۱۰۰ باشد';
        return null;
      },
    );
  }

  Widget _buildPpmField(
    String label,
    TextEditingController controller, {
    double fontSizeSmall = 14,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(fontSizeSmall * 2),
        ),
        suffixText: 'ppm',
        contentPadding: EdgeInsets.symmetric(
          horizontal: fontSizeSmall,
          vertical: fontSizeSmall * 1.2,
        ),
      ),
      style: TextStyle(fontSize: fontSizeSmall, fontFamily: 'Vazir'),
      onChanged: (value) {
        if (_formKey.currentState != null) {
          _formKey.currentState!.validate();
        }
      },
      validator: (v) {
        if (v?.isEmpty ?? true) return 'الزامی';
        final number = double.tryParse(v!);
        if (number == null) return 'عدد معتبر وارد کنید';
        if (number < 0) return 'مقدار نمی‌تواند منفی باشد';
        return null;
      },
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller,
    TextInputType text, {
    double fontSizeSmall = 14,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(fontSizeSmall * 2),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: fontSizeSmall,
          vertical: fontSizeSmall * 1.2,
        ),
      ),
      style: TextStyle(fontSize: fontSizeSmall, fontFamily: 'Vazir'),
      onChanged: (value) {
        if (_formKey.currentState != null) {
          _formKey.currentState!.validate();
        }
      },
      validator: (v) {
        if (v?.isEmpty ?? true) return 'الزامی';
        return null;
      },
    );
  }

  Widget _buildSenderDropdown(double fontSizeSmall) {
    return _isLoadingSenders
        ? const LinearProgressIndicator()
        : _senders.isEmpty
        ? Text(
            'هیچ فرستنده‌ای ثبت نشده',
            style: TextStyle(color: Colors.grey, fontSize: fontSizeSmall),
          )
        : DropdownButtonFormField<Sender>(
            value: _selectedSender,
            decoration: InputDecoration(
              labelText: 'فرستنده',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(fontSizeSmall * 2),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: fontSizeSmall,
                vertical: fontSizeSmall * 1.2,
              ),
            ),
            items: _senders
                .map(
                  (sender) => DropdownMenuItem(
                    value: sender,
                    child: Text(
                      sender.senderName,
                      style: TextStyle(fontSize: fontSizeSmall),
                    ),
                  ),
                )
                .toList(),
            onChanged: (Sender? newValue) =>
                setState(() => _selectedSender = newValue),
            validator: (value) =>
                value == null ? 'فرستنده را انتخاب کنید' : null,
          );
  }

  Widget _buildColorChangeDropdown(double fontSizeSmall) {
    return DropdownButtonFormField<String>(
      value: _selectedColorChange,
      decoration: InputDecoration(
        labelText: 'تغییر رنگ',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(fontSizeSmall * 2),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: fontSizeSmall,
          vertical: fontSizeSmall * 1.2,
        ),
      ),
      items: ['A', 'B', 'C', 'D']
          .map(
            (e) => DropdownMenuItem(
              value: e,
              child: Text(e, style: TextStyle(fontSize: fontSizeSmall)),
            ),
          )
          .toList(),
      onChanged: (v) => setState(() => _selectedColorChange = v),
      validator: (v) => v == null ? 'انتخاب کنید' : null,
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
            'ثبت بار',
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

  Widget _buildActionButtons(
    double buttonSpacing,
    double fontSizeMedium,
  ) => Row(
    children: [
      Expanded(
        child: ElevatedButton(
          onPressed: () async {
            // بررسی اطلاعات اصلی
            if (_selectedSender == null ||
                _weightController.text.isEmpty ||
                _priceController.text.isEmpty) {
              setState(() {
                _showBasicInfoPopup = true;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('لطفاً ابتدا اطلاعات اصلی را تکمیل کنید'),
                  backgroundColor: Colors.orange,
                ),
              );
              return;
            }

            if (!_formKey.currentState!.validate()) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('لطفا خطاهای فرم را برطرف کنید'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            final gregorian = _selectedJalaliDate!.toDateTime();
            final isoDate =
                '${gregorian.year}-${_twoDigits(gregorian.month)}-${_twoDigits(gregorian.day)}';

            // ارسال داده‌های هر سه آزمایش
            for (int i = 0; i < 3; i++) {
              final cargo = CargoModel(
                receiveDate: isoDate,
                senderId: _selectedSender!.id ?? 0,
                weightScale: _parseFormattedDouble(_weightController.text),
                humidity: _parseFormattedDouble(_moistureControllers[i].text),
                pricePerUnit: _parseFormattedNumber(_priceController.text),
                pvc: _parseFormattedDouble(_pvcControllers[i].text),
                dirtyFlake: _parseFormattedDouble(
                  _dirtyFlakeControllers[i].text,
                ),
                polymer: _parseFormattedDouble(_polymerControllers[i].text),
                wasteMaterial: _parseFormattedDouble(_wasteControllers[i].text),
                coloredFlake: _parseFormattedDouble(
                  _coloredFlakeControllers[i].text,
                ),
                colorChange: _selectedColorChange!,
                userName: _enteredByController.text.trim(),
                testNumber: i + 1, // شماره آزمایش
              );

              final messenger = ScaffoldMessenger.of(context);
              messenger.showSnackBar(
                SnackBar(
                  content: Text('در حال ثبت آزمایش ${i + 1}...'),
                  backgroundColor: Colors.blue,
                ),
              );

              final result = await CargoApi.addCargo(cargo);
              messenger.hideCurrentSnackBar();

              if (!result["success"]) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      'خطا در ثبت آزمایش ${i + 1}: ${result["message"]}',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
            }

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تمامی آزمایش‌ها با موفقیت ثبت شدند'),
                backgroundColor: Colors.green,
              ),
            );

            if (mounted) Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: EdgeInsets.symmetric(vertical: fontSizeMedium * 1.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(fontSizeMedium),
            ),
          ),
          child: Text(
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
          onPressed: () => Navigator.pop(context),
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
