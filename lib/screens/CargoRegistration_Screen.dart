// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:zarlif/screens/sender_screen.dart';
import '../models/sender_model.dart';
import '../Api/cargoapi.dart';
import '../Api/sender_api.dart';
import '../models/cargomodel.dart';

class CargoRegistrationScreen extends StatefulWidget {
  const CargoRegistrationScreen({super.key});

  @override
  State<CargoRegistrationScreen> createState() =>
      _CargoRegistrationScreenState();
}

class _CargoRegistrationScreenState extends State<CargoRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

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

  String? _selectedColorChange;
  Jalali? _selectedJalaliDate;
  String _displayDate = 'در حال بارگذاری...';

  List<Sender> _senders = [];
  Sender? _selectedSender;
  bool _isLoadingSenders = true;

  double _totalPercent = 0.0;

  @override
  void initState() {
    super.initState();
    _selectedJalaliDate = Jalali.now();
    _displayDate = _formatJalali(_selectedJalaliDate!);
    _loadSenders();
    _setupNumberFormatting();
    _setupPpmListeners();
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
    final ppmControllers = [
      _pvcController,
      _dirtyFlakeController,
      _polymerController,
      _wasteController,
      _coloredFlakeController,
    ];
    for (var controller in ppmControllers) {
      controller.addListener(_calculateTotalPpm);
    }
  }

  void _calculateTotalPpm() {
    final ppmControllers = [
      _pvcController,
      _dirtyFlakeController,
      _polymerController,
      _wasteController,
      _coloredFlakeController,
    ];

    double total = 0;
    for (var controller in ppmControllers) {
      final value = double.tryParse(controller.text) ?? 0;
      total += value;
    }

    double _totalPpm;
    setState(() => _totalPpm = total);
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
          SnackBar(content: Text('خطا: $e'), backgroundColor: Colors.red),
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > 600;
        final maxWidth = isTablet ? 600.0 : double.infinity;

        return Scaffold(
          appBar: _buildAppBar(),
          body: Center(
            child: Container(
              width: maxWidth,
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                autovalidateMode:
                    AutovalidateMode.onUserInteraction, // اعتبارسنجی در لحظه
                child: Column(
                  children: [
                    _buildHeaderSection(),
                    const SizedBox(height: 20),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children:
                              [
                                    _buildDateField(),
                                    _buildSenderDropdown(),
                                    _buildNumberField(
                                      'وزن (kg)',
                                      _weightController,
                                      TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                      isDecimal: true,
                                    ),
                                    _buildPercentField(
                                      'رطوبت (%)',
                                      _moistureController,
                                    ),
                                    _buildNumberField(
                                      'قیمت (ریال)',
                                      _priceController,
                                      TextInputType.number,
                                      formatNumber: true,
                                    ),
                                    _buildPercentField(
                                      'PVC (%)',
                                      _pvcController,
                                    ),
                                    _buildPercentField(
                                      'پرک کثیف (%)',
                                      _dirtyFlakeController,
                                    ),
                                    _buildPercentField(
                                      'پلیمر (%)',
                                      _polymerController,
                                    ),
                                    _buildPercentField(
                                      'مواد زائد (%)',
                                      _wasteController,
                                    ),
                                    _buildPercentField(
                                      'پرک رنگی (%)',
                                      _coloredFlakeController,
                                    ),
                                    // نمایش مجموع درصدها
                                    _buildTotalPercentIndicator(),
                                    _buildColorChangeDropdown(),
                                    _buildField(
                                      'وارد کننده اطلاعات',
                                      _enteredByController,
                                      TextInputType.text,
                                    ),
                                  ]
                                  .map(
                                    (e) => Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 12,
                                      ),
                                      child: e,
                                    ),
                                  )
                                  .toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ویجت برای نمایش مجموع درصدها
  Widget _buildTotalPercentIndicator() {
    Color color;
    IconData icon;
    String status;

    if (_totalPercent == 0) {
      color = Colors.grey;
      icon = Icons.info_outline;
      status = 'درصدها وارد نشده‌اند';
    } else if (_totalPercent > 100) {
      color = Colors.red;
      icon = Icons.error_outline;
      status = 'مجموع درصدها بیشتر از ۱۰۰ است';
    } else if (_totalPercent == 100) {
      color = Colors.green;
      icon = Icons.check_circle_outline;
      status = 'مجموع درصدها کامل است';
    } else {
      color = Colors.orange;
      icon = Icons.warning_amber_outlined;
      status = 'مجموع درصدها کمتر از ۱۰۰ است';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مجموع درصدها: ${_totalPercent.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontFamily: 'Vazir',
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  status,
                  style: TextStyle(
                    fontFamily: 'Vazir',
                    fontSize: 12,
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

  Widget _buildDateField() {
    return InkWell(
      onTap: () => _selectJalaliDate(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'تاریخ',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          suffixIcon: const Icon(Icons.calendar_today, color: Colors.blue),
        ),
        child: Text(_displayDate, style: const TextStyle(fontFamily: 'Vazir')),
      ),
    );
  }

  Widget _buildNumberField(
    String label,
    TextEditingController controller,
    TextInputType type, {
    bool isDecimal = false,
    bool formatNumber = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      inputFormatters: formatNumber
          ? [FilteringTextInputFormatter.digitsOnly]
          : [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        suffixText: formatNumber ? 'ریال' : null,
      ),
      validator: (v) => (v?.isEmpty ?? true) ? 'الزامی' : null,
    );
  }

  Widget _buildPercentField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        suffixText: '%',
      ),
      style: const TextStyle(fontFamily: 'Vazir'),
      onChanged: (value) {
        // اعتبارسنجی در لحظه
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

  Widget _buildField(
    String label,
    TextEditingController controller,
    TextInputType text,
  ) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 16,
        ),
      ),
      style: const TextStyle(fontFamily: 'Vazir'),
      onChanged: (value) {
        // اعتبارسنجی در لحظه
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

  // بقیه متدها بدون تغییر می‌مانند...
  Widget _buildSenderDropdown() {
    return Row(
      children: [
        Expanded(
          child: _isLoadingSenders
              ? const LinearProgressIndicator()
              : _senders.isEmpty
              ? const Text(
                  'هیچ فرستنده‌ای ثبت نشده',
                  style: TextStyle(color: Colors.grey),
                )
              : DropdownButtonFormField<Sender>(
                  value: _selectedSender,
                  decoration: InputDecoration(
                    labelText: 'فرستنده',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                  ),
                  items: _senders
                      .map(
                        (sender) => DropdownMenuItem(
                          value: sender,
                          child: Text(sender.senderName),
                        ),
                      )
                      .toList(),
                  onChanged: (Sender? newValue) =>
                      setState(() => _selectedSender = newValue),
                  validator: (value) =>
                      value == null ? 'فرستنده را انتخاب کنید' : null,
                ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.people, color: Colors.blue),
          tooltip: 'مدیریت فرستنده‌ها',
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SenderManagementScreen()),
            );
            _loadSenders();
          },
        ),
      ],
    );
  }

  Widget _buildColorChangeDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedColorChange,
      decoration: InputDecoration(
        labelText: 'تغییر رنگ',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: [
        'A',
        'B',
        'C',
        'D',
      ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: (v) => setState(() => _selectedColorChange = v),
      validator: (v) => v == null ? 'انتخاب کنید' : null,
    );
  }

  PreferredSizeWidget _buildAppBar() => PreferredSize(
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
            'ثبت بار',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 18,
              fontFamily: 'Vazir',
            ),
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
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
        ),
      ),
    ),
  );

  Widget _buildHeaderSection() => Card(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: const Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.analytics, color: Colors.blue),
          const SizedBox(width: 8),
          Text(
            'اطلاعات بار',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              fontFamily: 'Vazir',
            ),
          ),
          Spacer(),
          Text(
            'ثبت اطلاعات',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontFamily: 'Vazir',
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    ),
  );

  Widget _buildActionButtons() => Row(
    children: [
      Expanded(
        child: ElevatedButton(
          onPressed: () async {
            if (!_formKey.currentState!.validate()) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('لطفا خطاهای فرم را برطرف کنید'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            if (_totalPercent > 100) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'مجموع درصدها نمی‌تواند بیشتر از ۱۰۰ باشد (${_totalPercent.toStringAsFixed(1)}%)',
                  ),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            final gregorian = _selectedJalaliDate!.toDateTime();
            final isoDate =
                '${gregorian.year}-${_twoDigits(gregorian.month)}-${_twoDigits(gregorian.day)}';

            final cargo = CargoModel(
              receiveDate: isoDate,
              senderId: _selectedSender!.id ?? 0,
              weightScale: _parseFormattedDouble(_weightController.text),
              humidity: _parseFormattedDouble(_moistureController.text),
              pricePerUnit: _parseFormattedNumber(_priceController.text),
              pvc: _parseFormattedDouble(_pvcController.text),
              dirtyFlake: _parseFormattedDouble(_dirtyFlakeController.text),
              polymer: _parseFormattedDouble(_polymerController.text),
              wasteMaterial: _parseFormattedDouble(_wasteController.text),
              coloredFlake: _parseFormattedDouble(_coloredFlakeController.text),
              colorChange: _selectedColorChange!,
              userName: _enteredByController.text.trim(),
            );

            final messenger = ScaffoldMessenger.of(context);
            messenger.showSnackBar(
              const SnackBar(
                content: Text('در حال ثبت...'),
                backgroundColor: Colors.blue,
              ),
            );

            final result = await CargoApi.addCargo(cargo);

            messenger.hideCurrentSnackBar();
            messenger.showSnackBar(
              SnackBar(
                content: Text(result["message"]),
                backgroundColor: result["success"] ? Colors.green : Colors.red,
              ),
            );

            if (result["success"]) {
              if (mounted) Navigator.pop(context);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'ثبت نهایی',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Vazir',
            ),
          ),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: OutlinedButton(
          onPressed: () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            side: const BorderSide(color: Colors.grey),
          ),
          child: const Text(
            'انصراف',
            style: TextStyle(color: Colors.grey, fontFamily: 'Vazir'),
          ),
        ),
      ),
    ],
  );
}
