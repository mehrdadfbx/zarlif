import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  double _totalPpm = 0.0;

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطا: $e'), backgroundColor: Colors.red),
      );
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
    return Scaffold(
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 🔹 این بخش جایگزین "اطلاعات بار" شده
              _buildTopFields(),

              const SizedBox(height: 16),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children:
                        [
                              _buildPercentField(
                                'رطوبت (%)',
                                _moistureController,
                              ),
                              _buildPpmField('PVC (ppm)', _pvcController),
                              _buildPpmField(
                                'پرک کثیف (ppm)',
                                _dirtyFlakeController,
                              ),
                              _buildPpmField('پلیمر (ppm)', _polymerController),
                              _buildPpmField(
                                'مواد زائد (ppm)',
                                _wasteController,
                              ),
                              _buildPpmField(
                                'پرک رنگی (ppm)',
                                _coloredFlakeController,
                              ),
                              _buildTotalPpmIndicator(),
                              _buildColorChangeDropdown(),
                              _buildField(
                                'واردکننده اطلاعات',
                                _enteredByController,
                              ),
                            ]
                            .map(
                              (e) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: e,
                              ),
                            )
                            .toList(),
                  ),
                ),
              ),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopFields() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildDateField()),
            const SizedBox(width: 12),
            Expanded(child: _buildSenderDropdown()),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildNumberField(
                'وزن (kg)',
                _weightController,
                TextInputType.numberWithOptions(decimal: true),
                isDecimal: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildNumberField(
                'قیمت (ریال)',
                _priceController,
                TextInputType.number,
                formatNumber: true,
              ),
            ),
          ],
        ),
      ],
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
    );
  }

  Widget _buildPpmField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        suffixText: 'ppm',
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildSenderDropdown() {
    if (_isLoadingSenders) {
      return const LinearProgressIndicator();
    }

    return DropdownButtonFormField<Sender>(
      value: _selectedSender,
      decoration: InputDecoration(
        labelText: 'فرستنده',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: _senders
          .map(
            (sender) =>
                DropdownMenuItem(value: sender, child: Text(sender.senderName)),
          )
          .toList(),
      onChanged: (v) => setState(() => _selectedSender = v),
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
    );
  }

  Widget _buildTotalPpmIndicator() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.analytics, color: Colors.blue),
          const SizedBox(width: 8),
          Text(
            'مجموع: ${_formatNumber(_totalPpm.toInt())} ppm',
            style: const TextStyle(fontFamily: 'Vazir'),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() => AppBar(
    title: const Text('ثبت بار', style: TextStyle(fontFamily: 'Vazir')),
    centerTitle: true,
    backgroundColor: Colors.blue[700],
  );

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'ثبت نهایی',
              style: TextStyle(fontFamily: 'Vazir'),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('انصراف', style: TextStyle(fontFamily: 'Vazir')),
          ),
        ),
      ],
    );
  }
}
