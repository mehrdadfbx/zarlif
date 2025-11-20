// screens/sales_screen.dart
import 'package:flutter/material.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // Mock Data
  final List<Map<String, dynamic>> salesData = [
    {
      "sender": "قادری",
      "weight": 120.5,
      "price": 25000000,
      "humidity": 2.5,
      "pvc": 10,
      "polymer": 15,
      "date": "2025-11-10",
    },
    {
      "sender": "احمدی",
      "weight": 95,
      "price": 18400000,
      "humidity": 3.1,
      "pvc": 14,
      "polymer": 12,
      "date": "2025-11-08",
    },
  ];

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
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
                "فروش",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: "Vazir",
                ),
              ),
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                labelStyle: const TextStyle(
                  fontFamily: "Vazir",
                  fontWeight: FontWeight.bold,
                ),
                tabs: const [
                  Tab(text: "لیست فروش‌ها"),
                  Tab(text: "ثبت فروش"),
                ],
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildSalesList(), _buildAddSaleForm()],
      ),
    );
  }

  // ------------------------- لیست فروش -------------------------
  Widget _buildSalesList() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(Colors.blue[700]),
          headingTextStyle: const TextStyle(
            color: Colors.white,
            fontFamily: "Vazir",
            fontWeight: FontWeight.bold,
          ),
          dataRowHeight: 55,
          columns: const [
            DataColumn(label: Text("فرستنده")),
            DataColumn(label: Text("وزن (kg)")),
            DataColumn(label: Text("قیمت (ریال)")),
            DataColumn(label: Text("رطوبت (%)")),
            DataColumn(label: Text("PVC")),
            DataColumn(label: Text("پلیمر")),
            DataColumn(label: Text("تاریخ")),
          ],
          rows: List.generate(salesData.length, (i) {
            final s = salesData[i];
            return DataRow(
              color: MaterialStateProperty.all(
                i % 2 == 0 ? Colors.teal.shade50 : Colors.grey.shade100,
              ),
              cells: [
                DataCell(
                  Text(
                    s["sender"].toString(),
                    style: const TextStyle(fontFamily: "Vazir"),
                  ),
                ),
                DataCell(
                  Text(
                    s["weight"].toString(),
                    style: const TextStyle(fontFamily: "Vazir"),
                  ),
                ),
                DataCell(
                  Text(
                    s["price"].toString(),
                    style: const TextStyle(fontFamily: "Vazir"),
                  ),
                ),
                DataCell(
                  Text(
                    s["humidity"].toString(),
                    style: const TextStyle(fontFamily: "Vazir"),
                  ),
                ),
                DataCell(
                  Text(
                    s["pvc"].toString(),
                    style: const TextStyle(fontFamily: "Vazir"),
                  ),
                ),
                DataCell(
                  Text(
                    s["polymer"].toString(),
                    style: const TextStyle(fontFamily: "Vazir"),
                  ),
                ),
                DataCell(
                  Text(
                    s["date"].toString(),
                    style: const TextStyle(fontFamily: "Vazir"),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  // ------------------------- فرم ثبت فروش -------------------------
  Widget _buildAddSaleForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _inputField("نام فرستنده"),
          _inputField("وزن (kg)", type: TextInputType.number),
          _inputField("قیمت (ریال)", type: TextInputType.number),
          _inputField("رطوبت (%)", type: TextInputType.number),
          _inputField("PVC", type: TextInputType.number),
          _inputField("پلیمر", type: TextInputType.number),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("فعلاً API نداری - بعداً اضافه میشه"),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "ثبت فروش",
              style: TextStyle(
                fontFamily: "Vazir",
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputField(String label, {TextInputType type = TextInputType.text}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: TextField(
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontFamily: "Vazir"),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
