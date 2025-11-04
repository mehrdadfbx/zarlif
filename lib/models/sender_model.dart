class Sender {
  final int? id; // برای ویرایش و حذف
  final DateTime addedDate;
  final String senderName;
  final String phoneNumber;
  final String address;

  Sender({
    this.id,
    required this.addedDate,
    required this.senderName,
    required this.phoneNumber,
    required this.address,
  });

  /// تبدیل به Map برای ارسال به API
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id, // فقط اگر وجود داشت بفرست
      'name': senderName,
      'phone': phoneNumber,
      'address': address,
      // addedDate رو نمی‌فرستیم — سرور خودش تنظیم می‌کنه
    };
  }

  /// ساخت شیء از پاسخ API
  factory Sender.fromMap(Map<String, dynamic> map) {
    return Sender(
      id: map['id'] is int ? map['id'] : int.tryParse(map['id'].toString()),
      addedDate: DateTime.parse(
        map['added_date'] ??
            map['addedDate'] ??
            DateTime.now().toIso8601String(),
      ),
      senderName: (map['name'] ?? map['senderName'] ?? '').toString(),
      phoneNumber: (map['phone'] ?? map['phoneNumber'] ?? '').toString(),
      address: (map['address'] ?? '').toString(),
    );
  }

  /// کپی با امکان تغییر فیلدها
  Sender copyWith({
    int? id,
    DateTime? addedDate,
    String? senderName,
    String? phoneNumber,
    String? address,
  }) {
    return Sender(
      id: id ?? this.id,
      addedDate: addedDate ?? this.addedDate,
      senderName: senderName ?? this.senderName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
    );
  }

  @override
  String toString() {
    return 'Sender(id: $id, name: $senderName, phone: $phoneNumber)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Sender && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
