import 'package:flutter/material.dart';
import '../models/sender_model.dart';
import '../Api/sender_api.dart';

class SenderManagementScreen extends StatefulWidget {
  const SenderManagementScreen({super.key});

  @override
  State<SenderManagementScreen> createState() => _SenderManagementScreenState();
}

class _SenderManagementScreenState extends State<SenderManagementScreen> {
  List<Sender> _senders = [];
  bool _isLoading = false;
  bool _isOperationInProgress = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSenders();
  }

  Future<void> _loadSenders() async {
    setState(() => _isLoading = true);
    try {
      final data = await SenderApi.getSenders();
      setState(() => _senders = data);
      print('تعداد فرستنده‌ها loaded: ${data.length}');
    } catch (e) {
      _showSnackBar("خطا در بارگذاری فرستنده‌ها: $e", isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addSender() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final address = _addressController.text.trim();

    if (name.isEmpty) {
      _showSnackBar("نام فرستنده الزامی است", isError: true);
      return;
    }

    if (_isOperationInProgress) return;

    setState(() => _isOperationInProgress = true);

    final newSender = Sender(
      addedDate: DateTime.now(),
      senderName: name,
      phoneNumber: phone,
      address: address,
    );

    print('در حال افزودن فرستنده: ${newSender.toMap()}');

    try {
      final success = await SenderApi.addSender(newSender);

      if (success) {
        _showSnackBar("فرستنده با موفقیت اضافه شد");
        await _loadSenders(); // رفرش لیست
        _clearControllers();
      } else {
        _showSnackBar("خطا در افزودن فرستنده", isError: true);
      }
    } catch (e) {
      _showSnackBar("خطا در افزودن: $e", isError: true);
    } finally {
      setState(() => _isOperationInProgress = false);
    }
  }

  Future<void> _updateSender(Sender sender) async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final address = _addressController.text.trim();

    if (name.isEmpty) {
      _showSnackBar("نام فرستنده الزامی است", isError: true);
      return;
    }

    if (_isOperationInProgress) return;

    setState(() => _isOperationInProgress = true);

    final updatedSender = Sender(
      id: sender.id,
      addedDate: sender.addedDate,
      senderName: name,
      phoneNumber: phone,
      address: address,
    );

    print('در حال ویرایش فرستنده: ${updatedSender.toMap()}');

    try {
      final success = await SenderApi.updateSender(updatedSender);

      if (success) {
        _showSnackBar("فرستنده با موفقیت ویرایش شد");
        await _loadSenders(); // رفرش لیست
        _clearControllers();
      } else {
        _showSnackBar("خطا در ویرایش فرستنده", isError: true);
      }
    } catch (e) {
      _showSnackBar("خطا در ویرایش: $e", isError: true);
    } finally {
      setState(() => _isOperationInProgress = false);
    }
  }

  Future<void> _deleteSender(Sender sender) async {
    if (sender.id == null) {
      _showSnackBar("خطا: شناسه فرستنده نامعتبر است", isError: true);
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("حذف فرستنده"),
        content: Text("آیا از حذف «${sender.senderName}» مطمئن هستید؟"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("خیر"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("بله"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isOperationInProgress = true);

    print('در حال حذف فرستنده با ID: ${sender.id}');

    try {
      final success = await SenderApi.deleteSender(sender.id!);

      if (success) {
        _showSnackBar("فرستنده حذف شد");
        await _loadSenders(); // رفرش لیست
      } else {
        _showSnackBar("خطا در حذف فرستنده", isError: true);
      }
    } catch (e) {
      _showSnackBar("خطا در حذف: $e", isError: true);
    } finally {
      setState(() => _isOperationInProgress = false);
    }
  }

  void _clearControllers() {
    _nameController.clear();
    _phoneController.clear();
    _addressController.clear();
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

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      textDirection: TextDirection.rtl,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 16,
        ),
      ),
    );
  }

  void _showEditBottomSheet(Sender sender) {
    _nameController.text = sender.senderName;
    _phoneController.text = sender.phoneNumber;
    _addressController.text = sender.address;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "ویرایش فرستنده",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    label: "نام فرستنده",
                    controller: _nameController,
                  ),
                  const SizedBox(height: 12),
                  _buildInputField(
                    label: "شماره تماس",
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  _buildInputField(
                    label: "آدرس",
                    controller: _addressController,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text("انصراف"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isOperationInProgress
                              ? null
                              : () async {
                                  await _updateSender(sender);
                                  if (mounted) Navigator.pop(ctx);
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[700],
                          ),
                          child: _isOperationInProgress
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  "ذخیره تغییرات",
                                  style: TextStyle(color: Colors.white),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: SafeArea(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blue[700],
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
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
                "فرستنده‌های بار",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
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
      ),
      body: RefreshIndicator(
        onRefresh: _loadSenders,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // فرم افزودن فرستنده
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildInputField(
                        label: "نام فرستنده",
                        controller: _nameController,
                      ),
                      const SizedBox(height: 12),
                      _buildInputField(
                        label: "شماره تماس",
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 12),
                      _buildInputField(
                        label: "آدرس",
                        controller: _addressController,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isOperationInProgress ? null : _addSender,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[700],
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: _isOperationInProgress
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  "افزودن فرستنده",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 10),

              // لیست فرستنده‌ها
              Expanded(
                child: _isLoading && _senders.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : _senders.isEmpty
                    ? const Center(
                        child: Text(
                          "هیچ فرستنده‌ای ثبت نشده",
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _senders.length,
                        itemBuilder: (ctx, index) {
                          final sender = _senders[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            elevation: 2,
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              title: Text(
                                sender.senderName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                textDirection: TextDirection.rtl,
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (sender.phoneNumber.isNotEmpty)
                                    Text(
                                      "📞 ${sender.phoneNumber}",
                                      textDirection: TextDirection.rtl,
                                    ),
                                  if (sender.address.isNotEmpty)
                                    Text(
                                      "📍 ${sender.address}",
                                      textDirection: TextDirection.rtl,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  Text(
                                    "شناسه: ${sender.id ?? 'نامشخص'}",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () =>
                                        _showEditBottomSheet(sender),
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.orange,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => _deleteSender(sender),
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
