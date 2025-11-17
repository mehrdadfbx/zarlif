import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // برای نمودار

class CargoReportScreen extends StatelessWidget {
  const CargoReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // تم شما
    final Color backgroundColor = const Color(0xFF1E1E1E);
    final Color cardColor = const Color(0xFF2D2D2D);
    final Color primaryBlue = const Color(0xFF4A90E2);
    final Color accentGreen = const Color(0xFF50C878);
    final Color textColor = Colors.white;
    final Color hintColor = const Color(0xFFB0B0B0);
    final Color borderColor = const Color(0xFF444444);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // کارت نمودار
            _buildChartCard(
              primaryBlue,
              accentGreen,
              cardColor,
              textColor,
              hintColor,
            ),
            const SizedBox(height: 16),
            // کارت جدول
            _buildTableCard(cardColor, textColor, hintColor, borderColor),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() => PreferredSize(
    preferredSize: const Size.fromHeight(70),
    child: SafeArea(
      child: Container(
        margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF2D2D2D),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
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

  Widget _buildChartCard(
    Color blue,
    Color green,
    Color card,
    Color text,
    Color hint,
  ) {
    return Card(
      color: card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bar_chart, color: blue, size: 20),
                const SizedBox(width: 8),
                Text(
                  'نمودار مقایسه‌ای',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: text,
                    fontFamily: 'Vazir',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final values = ['فیک پلاست', 'تولید باز', 'شرکت پلاست'];
                        final pvc = [12.5, 3.5, 85.3];
                        return BarTooltipItem(
                          '${values[groupIndex]}\nPVC: ${pvc[groupIndex]}%',
                          TextStyle(color: Colors.white, fontFamily: 'Vazir'),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              color: hint,
                              fontSize: 12,
                              fontFamily: 'Vazir',
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final labels = [
                            'فیک پلاست',
                            'تولید باز',
                            'شرکت پلاست',
                          ];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              labels[value.toInt()],
                              style: TextStyle(
                                color: hint,
                                fontSize: 11,
                                fontFamily: 'Vazir',
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true,
                    drawHorizontalLine: true,
                    horizontalInterval: 2,
                    getDrawingHorizontalLine: (value) =>
                        FlLine(color: Colors.grey[700]!, strokeWidth: 0.5),
                  ),
                  barGroups: [
                    _makeBarGroup(0, 1.2, green, card),
                    _makeBarGroup(1, 1.8, green, card),
                    _makeBarGroup(2, 7.8, blue, card),
                    // _makeBarGroup(3, 7.5, blue, card),
                    // _makeBarGroup(4, 7.2, blue, card),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: hint),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _legendItem('طبقه', blue),
                    const SizedBox(width: 16),
                    _legendItem('PVC', green),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _makeBarGroup(int x, double y, Color color, Color bg) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 16,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 8,
            color: bg,
          ),
        ),
      ],
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontFamily: 'Vazir',
          ),
        ),
      ],
    );
  }

  Widget _buildTableCard(Color card, Color text, Color hint, Color border) {
    return Card(
      color: card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.table_chart,
                  color: const Color(0xFF4A90E2),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'وزن (کیلوگرم) و PVC (%)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: text,
                    fontFamily: 'Vazir',
                  ),
                ),
                const Spacer(),
                Text(
                  'فستنده',
                  style: TextStyle(
                    color: hint,
                    fontSize: 12,
                    fontFamily: 'Vazir',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildTableRow(
              'فیک پلاست',
              '۱۴۰۴/۸/۲',
              '۸۲',
              '۱۰۰۰',
              '۱۲.۵',
              'A',
              border,
              text,
              hint,
            ),
            _buildTableRow(
              'تولید باز',
              '۱۴۰۴/۸/۲',
              '۱۰۸',
              '۴۳۰',
              '۳.۵',
              'A',
              border,
              text,
              hint,
            ),
            _buildTableRow(
              'شرکت پلاست',
              '۱۴۰۴/۸/۲',
              '۹۱',
              '۱۸۰۰',
              '۸۵.۳',
              'A',
              border,
              text,
              hint,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'میانگین رطوبت: ۳.۳%',
                style: TextStyle(
                  color: hint,
                  fontSize: 12,
                  fontFamily: 'Vazir',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableRow(
    String name,
    String date,
    String weight,
    String qty,
    String pvc,
    String change,
    Color border,
    Color text,
    Color hint,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: border, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              name,
              style: TextStyle(color: text, fontFamily: 'Vazir', fontSize: 13),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              date,
              style: TextStyle(color: hint, fontSize: 12, fontFamily: 'Vazir'),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              weight,
              style: TextStyle(color: text, fontFamily: 'Vazir'),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              qty,
              style: TextStyle(color: text, fontFamily: 'Vazir'),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '$pvc%',
              style: TextStyle(
                color: const Color(0xFF50C878),
                fontFamily: 'Vazir',
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              change,
              style: TextStyle(color: text, fontFamily: 'Vazir'),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
