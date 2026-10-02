import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../injection_container.dart';
import '../../../auth/presentation/pages/profile_page.dart';
import '../../domain/entities/child.dart';
import '../../domain/usecases/child_usecases.dart';

class ChildDetailPage extends StatefulWidget {
  final Child child;

  const ChildDetailPage({super.key, required this.child});

  @override
  State<ChildDetailPage> createState() => _ChildDetailPageState();
}

class _ChildDetailPageState extends State<ChildDetailPage> {
  List<ChildMeasurement> _measurements = [];
  bool _loading = true;
  String _chartTab = 'TB/U';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await sl<GetMeasurementsUsecase>().call(widget.child.id);
    if (!mounted) return;
    result.fold(
      (_) => setState(() => _loading = false),
      (list) => setState(() {
        _measurements = list..sort((a, b) => a.measuredAt.compareTo(b.measuredAt));
        _loading = false;
      }),
    );
  }

  ChildMeasurement? get _latest => _measurements.isNotEmpty ? _measurements.last : null;

  String get _statusLabel {
    if (_latest == null) return 'Belum ada data';
    final age = widget.child.ageInMonths;
    final h = _latest!.height;
    final median = _whoMedian(widget.child.gender, age);
    final threshold = _whoMinus2Sd(widget.child.gender, age);
    if (h < threshold) return 'Stunting';
    if (h < median - 1) return 'Gizi Baik';
    return 'Gizi Baik & Tumbuh Normal';
  }

  bool get _isNormal {
    if (_latest == null) return true;
    final age = widget.child.ageInMonths;
    return _latest!.height >= _whoMinus2Sd(widget.child.gender, age);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dapur Cerdas', style: GoogleFonts.playfairDisplay(fontSize: 14, fontWeight: FontWeight.w800, color: const Color(0xFF1B5E20))),
            Text('Si Kecil', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF6B7280))),
          ],
        ),
        iconTheme: const IconThemeData(color: Color(0xFF111827)),
        actions: [
          const Icon(Icons.notifications_none_rounded, color: Color(0xFF6B7280)),
          const SizedBox(width: 12),
          InkWell(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage())),
            borderRadius: BorderRadius.circular(14),
            child: const CircleAvatar(radius: 14, backgroundColor: Color(0xFFE8F5E9), child: Icon(Icons.person, size: 14, color: Color(0xFF1B5E20))),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeaderCard(child: widget.child, latest: _latest),
            const SizedBox(height: 12),
            _StatRow(latest: _latest, isNormal: _isNormal),
            const SizedBox(height: 16),
            _ChartCard(
              child: widget.child,
              measurements: _measurements,
              loading: _loading,
              tab: _chartTab,
              statusLabel: _statusLabel,
              isNormal: _isNormal,
              onTabChanged: (v) => setState(() => _chartTab = v),
            ),
            const SizedBox(height: 16),
            _MpasiGuide(ageMonths: widget.child.ageInMonths, statusLabel: _statusLabel, isNormal: _isNormal),
            const SizedBox(height: 12),
            _FoodRecs(),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showAddDialog,
                icon: const Icon(Icons.edit, size: 16, color: Colors.white),
                label: Text('Perbarui Data Pengukuran (Catat BB/TB)', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E20),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddDialog() async {
    final wCtrl = TextEditingController(text: _latest?.weight.toString() ?? '');
    final hCtrl = TextEditingController(text: _latest?.height.toString() ?? '');
    DateTime date = DateTime.now();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setS) {
        return AlertDialog(
          title: Text('Catat Pengukuran', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: wCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Berat (kg)', hintText: 'contoh 11.2')),
              const SizedBox(height: 10),
              TextField(controller: hCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Tinggi (cm)', hintText: 'contoh 83.5')),
              const SizedBox(height: 10),
              InkWell(
                onTap: () async {
                  final p = await showDatePicker(context: ctx, initialDate: date, firstDate: DateTime(2020), lastDate: DateTime.now());
                  if (p != null) setS(() => date = p);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE5E7EB)), borderRadius: BorderRadius.circular(8)),
                  child: Text(DateFormat('dd MMM yyyy').format(date), style: GoogleFonts.plusJakartaSans()),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B5E20), foregroundColor: Colors.white),
              child: const Text('Simpan'),
            ),
          ],
        );
      }),
    );
    if (ok != true) return;
    final w = double.tryParse(wCtrl.text.replaceAll(',', '.'));
    final h = double.tryParse(hCtrl.text.replaceAll(',', '.'));
    if (w == null || h == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Berat dan tinggi harus angka', style: GoogleFonts.plusJakartaSans()), backgroundColor: Colors.red));
      return;
    }
    final res = await sl<AddMeasurementUsecase>().call(childId: widget.child.id, weight: w, height: h, measuredAt: date);
    res.fold(
      (f) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(f.message, style: GoogleFonts.plusJakartaSans()), backgroundColor: Colors.red));
      },
      (_) {
        _load();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Pengukuran dicatat', style: GoogleFonts.plusJakartaSans()), backgroundColor: const Color(0xFF1B5E20)));
      },
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final Child child;
  final ChildMeasurement? latest;
  const _HeaderCard({required this.child, this.latest});

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd MMM yyyy');
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFF3F4F6))),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(radius: 28, backgroundColor: const Color(0xFFE8F5E9), child: Icon(child.gender == 'male' ? Icons.boy : Icons.girl, color: const Color(0xFF1B5E20), size: 28)),
              Positioned(bottom: 0, right: 0, child: Container(width: 18, height: 18, decoration: BoxDecoration(color: const Color(0xFF1B5E20), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)), child: const Icon(Icons.check, size: 10, color: Colors.white))),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(child.name, style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800, color: const Color(0xFF111827))),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF16A34A), shape: BoxShape.circle)),
                          const SizedBox(width: 4),
                          Text('Aktif', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700, color: const Color(0xFF166534))),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text('${child.ageInMonths} Bulan (${child.gender == 'male' ? 'Laki-laki' : 'Perempuan'})', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF6B7280))),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _MiniTag(icon: Icons.cake_outlined, label: df.format(child.birthDate)),
                    const SizedBox(width: 8),
                    _MiniTag(icon: Icons.water_drop_outlined, label: 'Gol. O+'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniTag extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MiniTag({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE5E7EB))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 12, color: const Color(0xFF6B7280)), const SizedBox(width: 4), Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF374151), fontWeight: FontWeight.w600))]),
    );
  }
}

class _StatRow extends StatelessWidget {
  final ChildMeasurement? latest;
  final bool isNormal;
  const _StatRow({this.latest, required this.isNormal});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _StatCard(icon: Icons.monitor_weight_outlined, label: 'Berat (BB)', value: latest == null ? '-' : '${latest!.weight.toStringAsFixed(1)} kg', status: latest == null ? 'Belum ada' : 'Normal')),
        const SizedBox(width: 10),
        Expanded(child: _StatCard(icon: Icons.height, label: 'Tinggi (TB)', value: latest == null ? '-' : '${latest!.height.toStringAsFixed(1)} cm', status: latest == null ? 'Belum ada' : (isNormal ? 'Normal' : 'Stunting'))),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String status;
  const _StatCard({required this.icon, required this.label, required this.value, required this.status});
  @override
  Widget build(BuildContext context) {
    final ok = status == 'Normal';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFF3F4F6))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, size: 14, color: const Color(0xFF6B7280)), const SizedBox(width: 6), Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF6B7280)))]),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800, color: const Color(0xFF111827))),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: ok ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(20)),
            child: Text(status, style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700, color: ok ? const Color(0xFF166534) : const Color(0xFF991B1B))),
          ),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final Child child;
  final List<ChildMeasurement> measurements;
  final bool loading;
  final String tab;
  final String statusLabel;
  final bool isNormal;
  final Function(String) onTabChanged;

  const _ChartCard({
    required this.child,
    required this.measurements,
    required this.loading,
    required this.tab,
    required this.statusLabel,
    required this.isNormal,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFF3F4F6))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Grafik Standar WHO', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF111827))),
              const Spacer(),
              _TabPill(label: 'TB/U', active: tab == 'TB/U', onTap: () => onTabChanged('TB/U')),
              const SizedBox(width: 6),
              _TabPill(label: 'BB/U', active: tab == 'BB/U', onTap: () => onTabChanged('BB/U')),
            ],
          ),
          const SizedBox(height: 2),
          Text(tab == 'BB/U' ? 'Berat Badan menurut Umur (BB/U)' : 'Tinggi Badan menurut Umur (TB/U)', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF6B7280))),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: isNormal ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isNormal ? const Color(0xFFBBF7D0) : const Color(0xFFFECACA)),
            ),
            child: Row(
              children: [
                Icon(isNormal ? Icons.check_circle : Icons.warning_amber_rounded, size: 16, color: isNormal ? const Color(0xFF16A34A) : const Color(0xFFDC2626)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(statusLabel, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: isNormal ? const Color(0xFF166534) : const Color(0xFF991B1B))),
                      Text(
                        measurements.isEmpty ? 'Catat pengukuran pertama untuk melihat kurva' : 'Z-score: ${_zScore(child, measurements.isNotEmpty ? measurements.last.height : 0).toStringAsFixed(2)} SD • Pantau tiap bulan',
                        style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF6B7280)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(height: 180, child: loading ? const Center(child: CircularProgressIndicator()) : _WhoChart(child: child, measurements: measurements, tab: tab)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendDot(color: const Color(0xFF1B5E20), label: 'Garis ${child.name.split(' ').first}'),
              const SizedBox(width: 12),
              _LegendDot(color: const Color(0xFFF59E0B), label: 'Median WHO'),
              const SizedBox(width: 12),
              _LegendDot(color: const Color(0xFFDC2626), label: 'Ambang Stunting', dashed: true),
            ],
          ),
        ],
      ),
    );
  }
}

class _TabPill extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _TabPill({required this.label, required this.active, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(color: active ? const Color(0xFF1B5E20) : Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: active ? const Color(0xFF1B5E20) : const Color(0xFFE5E7EB))),
        child: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: active ? Colors.white : const Color(0xFF374151))),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  final bool dashed;
  const _LegendDot({required this.color, required this.label, this.dashed = false});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: dashed ? Colors.transparent : color, shape: BoxShape.circle, border: dashed ? Border.all(color: color, width: 2) : null)),
        const SizedBox(width: 4),
        Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w600, color: const Color(0xFF6B7280))),
      ],
    );
  }
}

class _WhoChart extends StatelessWidget {
  final Child child;
  final List<ChildMeasurement> measurements;
  final String tab;
  const _WhoChart({required this.child, required this.measurements, required this.tab});

  @override
  Widget build(BuildContext context) {
    final isWeight = tab == 'BB/U';
    final who = isWeight ? _whoWeightTable(child.gender) : _whoTable(child.gender);
    final medianSpots = who.map((e) => FlSpot(e.age.toDouble(), e.median)).toList();
    final minus2Spots = who.map((e) => FlSpot(e.age.toDouble(), e.minus2)).toList();

    final childSpots = measurements.map((m) {
      final age = _ageAt(m.measuredAt, child.birthDate);
      return FlSpot(age, isWeight ? m.weight : m.height);
    }).toList();

    final unit = isWeight ? 'kg' : 'cm';
    final minY = isWeight ? 5.0 : 64.0;
    final maxY = isWeight ? 17.0 : 98.0;
    final interval = isWeight ? 2.0 : 6.0;

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true, drawVerticalLine: true, horizontalInterval: interval, verticalInterval: 6, getDrawingHorizontalLine: (_) => FlLine(color: const Color(0xFFF3F4F6), strokeWidth: 1)),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, interval: interval, reservedSize: 32, getTitlesWidget: (v, _) => Text(isWeight ? v.toStringAsFixed(0) : v.toInt().toString(), style: GoogleFonts.plusJakartaSans(fontSize: 9, color: const Color(0xFF9CA3AF))))),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, interval: 6, reservedSize: 22, getTitlesWidget: (v, _) => Text('${v.toInt()} bln', style: GoogleFonts.plusJakartaSans(fontSize: 8, color: const Color(0xFF9CA3AF))))),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minX: 6,
        maxX: 36,
        minY: minY,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(spots: medianSpots, isCurved: true, color: const Color(0xFFF59E0B), barWidth: 2, dotData: const FlDotData(show: false)),
          LineChartBarData(spots: minus2Spots, isCurved: true, color: const Color(0xFFDC2626), barWidth: 1.5, dashArray: [6, 4], dotData: const FlDotData(show: false)),
          if (childSpots.isNotEmpty)
            LineChartBarData(
              spots: childSpots,
              isCurved: true,
              color: const Color(0xFF1B5E20),
              barWidth: 3,
              dotData: FlDotData(show: true, getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(radius: 4, color: const Color(0xFF1B5E20), strokeWidth: 2, strokeColor: Colors.white)),
            ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touched) => touched.map((s) {
              if (s.barIndex == 2 && s.bar.spots.length > s.spotIndex) {
                return LineTooltipItem('${s.y.toStringAsFixed(1)} $unit', GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white));
              }
              return null;
            }).toList(),
          ),
        ),
      ),
    );
  }

  double _ageAt(DateTime measured, DateTime birth) => (measured.difference(birth).inDays / 30.44).clamp(6, 60).toDouble();
}

class _MpasiGuide extends StatelessWidget {
  final int ageMonths;
  final String statusLabel;
  final bool isNormal;
  const _MpasiGuide({required this.ageMonths, required this.statusLabel, required this.isNormal});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFF3F4F6))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.menu_book_rounded, size: 18, color: Color(0xFFD97706)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pedoman Gizi MPASI', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF111827))),
                    Text('Standar Kemenkes RI untuk Usia $ageMonths Bulan', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF6B7280))),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(20)),
                child: Text('2 Porsi/Hari', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700, color: const Color(0xFF1D4ED8))),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            isNormal
                ? 'Prioritas Pertahankan: Berikan minimal 2 porsi protein hewani setiap hari untuk menjaga sintesis hormon pertumbuhan & kepadatan tulang.'
                : 'Prioritas Percepatan Tinggi: Berikan minimal 2 porsi protein hewani setiap hari untuk mengejar ketertinggalan pertumbuhan & kepadatan tulang.',
            style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF374151), height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _FoodRecs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _FoodCard(icon: Icons.egg_alt, title: 'Telur Ayam', subtitle: 'Kolin & DHA', color: const Color(0xFFFEF3C7))),
        const SizedBox(width: 8),
        Expanded(child: _FoodCard(icon: Icons.set_meal, title: 'Ikan Kembung', subtitle: 'Omega-3 & Kalium', color: const Color(0xFFDBEAFE))),
        const SizedBox(width: 8),
        Expanded(child: _FoodCard(icon: Icons.restaurant, title: 'Daging Sapi', subtitle: 'Zat Besi Heme', color: const Color(0xFFFEE2E2))),
      ],
    );
  }
}

class _FoodCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  const _FoodCard({required this.icon, required this.title, required this.subtitle, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFF3F4F6))),
      child: Column(
        children: [
          Container(width: 36, height: 36, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 18, color: const Color(0xFF374151))),
          const SizedBox(height: 8),
          Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF111827))),
          Text(subtitle, style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF6B7280))),
        ],
      ),
    );
  }
}

// WHO 2006 approximate median & -2SD for height-for-age (cm) & weight-for-age (kg)
class _WhoPoint {
  final int age;
  final double median;
  final double minus2;
  const _WhoPoint(this.age, this.median, this.minus2);
}

List<_WhoPoint> _whoWeightTable(String gender) {
  final isBoy = gender == 'male';
  return [
    _WhoPoint(6, isBoy ? 7.9 : 7.3, isBoy ? 6.4 : 5.8),
    _WhoPoint(9, isBoy ? 8.9 : 8.2, isBoy ? 7.2 : 6.6),
    _WhoPoint(12, isBoy ? 9.6 : 8.9, isBoy ? 7.7 : 7.1),
    _WhoPoint(15, isBoy ? 10.3 : 9.6, isBoy ? 8.3 : 7.7),
    _WhoPoint(18, isBoy ? 10.9 : 10.2, isBoy ? 8.8 : 8.1),
    _WhoPoint(21, isBoy ? 11.5 : 10.9, isBoy ? 9.2 : 8.6),
    _WhoPoint(24, isBoy ? 12.2 : 11.5, isBoy ? 9.7 : 9.1),
    _WhoPoint(27, isBoy ? 12.7 : 12.1, isBoy ? 10.1 : 9.5),
    _WhoPoint(30, isBoy ? 13.3 : 12.7, isBoy ? 10.6 : 10.0),
    _WhoPoint(33, isBoy ? 13.8 : 13.3, isBoy ? 11.0 : 10.4),
    _WhoPoint(36, isBoy ? 14.3 : 13.9, isBoy ? 11.3 : 10.8),
  ];
}

List<_WhoPoint> _whoTable(String gender) {
  final isBoy = gender == 'male';
  return [
    _WhoPoint(6, isBoy ? 67.6 : 65.7, isBoy ? 63.3 : 61.5),
    _WhoPoint(9, isBoy ? 72.0 : 70.1, isBoy ? 67.5 : 65.6),
    _WhoPoint(12, isBoy ? 75.7 : 74.0, isBoy ? 71.0 : 69.3),
    _WhoPoint(15, isBoy ? 79.1 : 77.5, isBoy ? 74.1 : 72.4),
    _WhoPoint(18, isBoy ? 82.3 : 80.7, isBoy ? 76.9 : 75.2),
    _WhoPoint(21, isBoy ? 85.0 : 83.4, isBoy ? 79.4 : 77.8),
    _WhoPoint(24, isBoy ? 87.1 : 85.5, isBoy ? 81.3 : 79.8),
    _WhoPoint(27, isBoy ? 88.8 : 87.3, isBoy ? 82.9 : 81.4),
    _WhoPoint(30, isBoy ? 90.7 : 89.2, isBoy ? 84.7 : 83.2),
    _WhoPoint(33, isBoy ? 92.5 : 91.0, isBoy ? 86.3 : 84.9),
    _WhoPoint(36, isBoy ? 95.4 : 94.1, isBoy ? 89.1 : 87.8),
  ];
}

double _whoMedian(String gender, int ageMonths) {
  final t = _whoTable(gender);
  for (int i = t.length - 1; i >= 0; i--) if (ageMonths >= t[i].age) return t[i].median;
  return t.first.median;
}

double _whoMinus2Sd(String gender, int ageMonths) {
  final t = _whoTable(gender);
  for (int i = t.length - 1; i >= 0; i--) if (ageMonths >= t[i].age) return t[i].minus2;
  return t.first.minus2;
}

double _zScore(Child child, double height) {
  final age = child.ageInMonths;
  final median = _whoMedian(child.gender, age);
  final sd = (median - _whoMinus2Sd(child.gender, age)) / 2;
  if (sd == 0) return 0;
  return (height - median) / sd;
}