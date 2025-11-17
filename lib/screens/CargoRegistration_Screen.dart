import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import '../models/sender_model.dart';
import '../Api/cargoapi.dart';
import '../Api/sender_api.dart';
import '../models/cargomodel.dart';
import 'sender_screen.dart';

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

  // فرمت‌کننده حرفه‌ای برای قیمت (بهترین روش در فلاتر)
  final _priceFormatter = ThousandsFormatter();

  @override
  void initState() {
    super.initState();
    _selectedJalaliDate = Jalali.now();
    _displayDate = _formatJalali(_selectedJalaliDate!);
    _loadSenders();
    _setupPercentListeners();
  }

  void _setupPercentListeners() {
    final controllers = [
      _moistureController,
      _pvcController,
      _dirtyFlakeController,
      _polymerController,
      _wasteController,
      _coloredFlakeController,
    ];
    for (var c in controllers) {
      c.addListener(_calculateTotalPercent);
    }
  }

  void _calculateTotalPercent() {
    double total = 0.0;
    final controllers = [
      _moistureController,
      _pvcController,
      _dirtyFlakeController,
      _polymerController,
      _wasteController,
      _coloredFlakeController,
    ];

    for (var c in controllers) {
      total += double.tryParse(c.text.replaceAll(',', '')) ?? 0.0;
    }

    setState(() => _totalPercent = total);
  }

  String _formatJalali(Jalali date) =>
      '${date.year}/${_twoDigits(date.month)}/${_twoDigits(date.day)}';

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  // اعتبارسنجی مشترک و قوی
  String? _validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) return 'الزامی';
    return null;
  }

  String? _validatePositiveNumber(String? value, {bool allowDecimal = false}) {
    if (value == null || value.trim().isEmpty) return 'الزامی';
    final clean = value.replaceAll(',', '').trim();
    final num = allowDecimal ? double.tryParse(clean) : int.tryParse(clean);
    if (num == null || num < 0) return 'عدد مثبت معتبر وارد کنید';
    return null;
  }

  String? _validatePercent(String? value) {
    final msg = _validatePositiveNumber(value, allowDecimal: true);
    if (msg != null) return msg;
    final num = double.tryParse(value!.replaceAll(',', ''))!;
    if (num > 100) return 'درصد نمی‌تواند بیشتر از ۱۰۰ باشد';
    return null;
  }

  // آیا می‌توان فرم را ارسال کرد؟
  bool get _canSubmit {
    if (!_formKey.currentState!.validate()) return false;
    if (_totalPercent > 100) return false;
    if (_selectedSender == null) return false;
    return true;
  }

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
            content: Text('خطا در بارگذاری فرستنده‌ها: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingSenders = false);
    }
  }

  Future<void> _selectJalaliDate(BuildContext context) async {
    final Jalali? picked = await showPersianDatePicker(
      context: context,
      initialDate: _selectedJalaliDate ?? Jalali.now(),
      firstDate: Jalali(1395, 1, 1),
      lastDate: Jalali(1410, 12, 29),
    );
    if (picked != null && picked != _selectedJalaliDate) {
      setState(() {
        _selectedJalaliDate = picked;
        _displayDate = _formatJalali(picked);
      });
    }
  }

  Future<void> _submitCargo() async {
    if (!_canSubmit) return;

    final gregorian = _selectedJalaliDate!.toDateTime();
    final isoDate =
        '${gregorian.year}-${_twoDigits(gregorian.month)}-${_twoDigits(gregorian.day)}';

    final cargo = CargoModel(
      receiveDate: isoDate,
      senderId: _selectedSender!.id ?? 0,
      weightScale:
          double.tryParse(_weightController.text.replaceAll(',', '')) ?? 0.0,
      humidity:
          double.tryParse(_moistureController.text.replaceAll(',', '')) ?? 0.0,
      pricePerUnit:
          int.tryParse(_priceController.text.replaceAll(',', '')) ?? 0,
      pvc: double.tryParse(_pvcController.text.replaceAll(',', '')) ?? 0.0,
      dirtyFlake:
          double.tryParse(_dirtyFlakeController.text.replaceAll(',', '')) ??
          0.0,
      polymer:
          double.tryParse(_polymerController.text.replaceAll(',', '')) ?? 0.0,
      wasteMaterial:
          double.tryParse(_wasteController.text.replaceAll(',', '')) ?? 0.0,
      coloredFlake:
          double.tryParse(_coloredFlakeController.text.replaceAll(',', '')) ??
          0.0,
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

    try {
      final result = await CargoApi.addCargo(cargo);
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text(result["message"] ?? 'عملیات نامشخص'),
          backgroundColor: result["success"] == true
              ? Colors.green
              : Colors.red,
        ),
      );
      if (result["success"] == true && mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(content: Text('خطای شبکه: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _moistureController.dispose();
    _priceController.dispose();
    _pvcController.dispose();
    _dirtyFlakeController.dispose();
    _polymerController.dispose();
    _wasteController.dispose();
    _coloredFlakeController.dispose();
    _enteredByController.dispose();
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
                autovalidateMode: AutovalidateMode.onUserInteraction,
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
                                      allowDecimal: true,
                                    ),
                                    _buildPercentField(
                                      'رطوبت (%)',
                                      _moistureController,
                                    ),
                                    _buildNumberField(
                                      'قیمت (ریال)',
                                      _priceController,
                                      formatThousands: true,
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
                                    _buildTotalPercentIndicator(),
                                    _buildColorChangeDropdown(),
                                    _buildTextField(
                                      'وارد کننده اطلاعات',
                                      _enteredByController,
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

  // ویجت‌های کمکی اصلاح‌شده
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
      status = 'مجموع بیشتر از ۱۰۰ است!';
    } else if (_totalPercent == 100) {
      color = Colors.green;
      icon = Icons.check_circle;
      status = 'کامل و صحیح';
    } else {
      color = Colors.orange;
      icon = Icons.warning_amber_outlined;
      status = 'مجموع کمتر از ۱۰۰ است';
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مجموع درصدها: ${_totalPercent.toStringAsFixed(1)}%',
                  style: TextStyle(fontWeight: FontWeight.bold, color: color),
                ),
                Text(status, style: TextStyle(fontSize: 12, color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField() => InkWell(
    onTap: () => _selectJalaliDate(context),
    borderRadius: BorderRadius.circular(12),
    child: InputDecorator(
      decoration: InputDecoration(
        labelText: 'تاریخ',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        suffixIcon: const Icon(Icons.calendar_today, color: Colors.blue),
      ),
      child: Text(_displayDate, style: const TextStyle(fontFamily: 'Vazir')),
    ),
  );

  Widget _buildNumberField(
    String label,
    TextEditingController controller, {
    bool allowDecimal = false,
    bool formatThousands = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: allowDecimal),
      inputFormatters: [
        if (formatThousands) _priceFormatter,
        if (!formatThousands && allowDecimal)
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
        if (!formatThousands && !allowDecimal)
          FilteringTextInputFormatter.digitsOnly,
      ],
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        suffixText: formatThousands ? ' ریال' : null,
      ),
      style: const TextStyle(fontFamily: 'Vazir'),
      validator: formatThousands
          ? (v) => _validatePositiveNumber(v)
          : (v) => _validatePositiveNumber(v, allowDecimal: allowDecimal),
      onChanged: (_) => _calculateTotalPercent(),
    );
  }

  Widget _buildPercentField(String label, TextEditingController controller) =>
      TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
        ],
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          suffixText: ' %',
        ),
        style: const TextStyle(fontFamily: 'Vazir'),
        validator: _validatePercent,
        onChanged: (_) => _calculateTotalPercent(),
      );

  Widget _buildTextField(String label, TextEditingController controller) =>
      TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        style: const TextStyle(fontFamily: 'Vazir'),
        validator: _validateRequired,
      );

  Widget _buildSenderDropdown() => Row(
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
                ),
                items: _senders
                    .map(
                      (s) =>
                          DropdownMenuItem(value: s, child: Text(s.senderName)),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _selectedSender = v),
                validator: (v) => v == null ? 'فرستنده را انتخاب کنید' : null,
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

  Widget _buildColorChangeDropdown() => DropdownButtonFormField<String>(
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
          Icon(Icons.edit_calendar, color: Colors.blue),
          SizedBox(width: 8),
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
            style: TextStyle(color: Colors.grey, fontFamily: 'Vazir'),
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
          onPressed: _canSubmit ? _submitCargo : null, // اینجا کلید اصلی است
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(vertical: 18),
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
            padding: const EdgeInsets.symmetric(vertical: 18),
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

// فرمت‌کننده هزارگان حرفه‌ای (بهترین روش در فلاتر)
class ThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    final clean = newValue.text.replaceAll(',', '');
    if (clean.isEmpty || !RegExp(r'^\d+$').hasMatch(clean)) {
      return oldValue;
    }

    final number = int.parse(clean);
    final formatter = NumberFormat('#,###');
    final formatted = formatter.format(number);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
