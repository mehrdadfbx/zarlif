import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class CargoAnalysisChartScreen extends StatelessWidget {
  const CargoAnalysisChartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final maxWidth = isTablet ? 600.0 : double.infinity;

    return Scaffold(
      appBar: PreferredSize(
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
                'گزارش واحد آزمایشگاه',
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
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              actions: const [
                Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white,
                    child: ClipOval(
                      child: Icon(Icons.science, color: Colors.blue, size: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl, // مهم: برای پشتیبانی از فارسی
        child: Center(
          child: Container(
            width: maxWidth,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildHeaderCard(),
                const SizedBox(height: 20),
                Expanded(child: _buildBarChart()),
                const SizedBox(height: 16),
                _buildLegendTable(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.bar_chart, color: Colors.blue, size: 20),
            SizedBox(width: 8),
            Text(
              'نمودار مقایسه‌ای',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                fontFamily: 'Vazir',
              ),
            ),
            Spacer(),
            Text(
              'واحد آزمایشگاه',
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
  }

  Widget _buildBarChart() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: 15, // افزایش یافته تا همه داده‌ها جا بشن
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                // tooltipBgColor: Colors.blue[800],
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final companyNames = ['پرک پلاست', 'تولید بار', 'شرکت پلاست'];
                  final labels = ['پلیمر', 'رطوبت', 'PVC'];
                  final values = [
                    [8.3, 3.5, 12.5], // پرک پلاست
                    [0.5, 1.5, 0.0], // تولید بار
                    [0.3, 1.2, 0.0], // شرکت پلاست
                  ];

                  final value = values[group.x][rodIndex];
                  return BarTooltipItem(
                    '${companyNames[group.x]}\n${labels[rodIndex]}: $value%',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Vazir',
                      fontSize: 12,
                    ),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 50,
                  getTitlesWidget: (value, meta) {
                    const titles = ['پرک پلاست', 'تولید بار', 'شرکت پلاست'];
                    if (value.toInt() >= 0 && value.toInt() < titles.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          titles[value.toInt()],
                          style: const TextStyle(
                            fontFamily: 'Vazir',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 5,
                  reservedSize: 30,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      '${value.toInt()}%',
                      style: const TextStyle(
                        fontFamily: 'Vazir',
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 5,
              getDrawingHorizontalLine: (value) =>
                  FlLine(color: Colors.grey[300]!, strokeWidth: 1),
            ),
            borderData: FlBorderData(show: false),
            barGroups: [
              _makeGroupData(
                0,
                [8.3, 3.5, 12.5],
                [Colors.grey, Colors.green, Colors.blue],
              ),
              _makeGroupData(
                1,
                [0.5, 1.5, 0.0],
                [Colors.grey, Colors.green, Colors.blue],
              ),
              _makeGroupData(
                2,
                [0.3, 1.2, 0.0],
                [Colors.grey, Colors.green, Colors.blue],
              ),
            ],
          ),
        ),
      ),
    );
  }

  BarChartGroupData _makeGroupData(
    int x,
    List<double> values,
    List<Color> colors,
  ) {
    return BarChartGroupData(
      x: x,
      barRods: values.asMap().entries.map((e) {
        final index = e.key;
        final value = e.value;
        return BarChartRodData(
          toY: value,
          color: colors[index],
          width: 16,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 15,
            color: Colors.grey[200],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLegendTable() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'وزن (کیلوگرم) و درصد (%)',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                fontFamily: 'Vazir',
              ),
            ),
            const SizedBox(height: 12),

            // سرستون جدول
            _buildTableHeader(),

            const Divider(height: 20, thickness: 1),

            // ردیف‌ها
            _buildTableRow('پرک پلاست', '۱۴۰۴/۴/۴', '۸۲', '۸.۳', '۳.۵', '۱۲.۵'),
            _buildTableRow('تولید بار', '۱۴۰۴/۴/۴', '۱۸', '۰.۵', '۱.۵', '۰.۰'),
            _buildTableRow('شرکت پلاست', '۱۴۰۴/۴/۴', '۹۱', '۰.۳', '۱.۲', '۰.۰'),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Row(
      children: [
        Expanded(flex: 3, child: _headerText('نام شرکت')),
        Expanded(flex: 2, child: _headerText('تاریخ')),
        Expanded(child: _headerText('وزن')),
        Expanded(child: _headerText('پلیمر %')),
        Expanded(child: _headerText('رطوبت %')),
        Expanded(child: _headerText('PVC %')),
      ],
    );
  }

  Widget _headerText(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Vazir',
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: Colors.blue,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildTableRow(
    String name,
    String date,
    String weight,
    String poly,
    String moisture,
    String pvc,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              name,
              style: const TextStyle(fontFamily: 'Vazir', fontSize: 12),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              date,
              style: const TextStyle(
                fontFamily: 'Vazir',
                fontSize: 11,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              weight,
              style: const TextStyle(fontFamily: 'Vazir', fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              poly,
              style: const TextStyle(fontFamily: 'Vazir', fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              moisture,
              style: const TextStyle(fontFamily: 'Vazir', fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              pvc,
              style: const TextStyle(fontFamily: 'Vazir', fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
