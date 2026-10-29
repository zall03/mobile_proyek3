import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/hpk.dart';
import '../../../../core/utils/who_standards.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/child.dart';
import '../../domain/usecases/child_usecases.dart';

class ChildDetailPage extends StatefulWidget {
  final Child child;
  final bool openMeasurementOnLoad;

  const ChildDetailPage({
    super.key,
    required this.child,
    this.openMeasurementOnLoad = false,
  });

  @override
  State<ChildDetailPage> createState() => _ChildDetailPageState();
}

class _ChildDetailPageState extends State<ChildDetailPage> {
  late Child _child;
  List<ChildMeasurement> _measurements = [];
  bool _loading = true;
  String? _error;
  String _chartTab = 'TB/U';
  bool _openedMeasurement = false;

  @override
  void initState() {
    super.initState();
    _child = widget.child;
    _load();
  }

  Future<void> _load() async {
    final childResult = await sl<GetChildByIdUsecase>().call(_child.id);
    final measurementResult = await sl<GetMeasurementsUsecase>().call(
      _child.id,
    );
    if (!mounted) return;

    final error = childResult.fold<String?>((failure) => failure.message, (
      child,
    ) {
      _child = child;
      return null;
    });
    final measurementError = measurementResult.fold<String?>(
      (failure) {
        return failure.message;
      },
      (list) {
        _measurements = list
          ..sort((a, b) => a.measuredAt.compareTo(b.measuredAt));
        return null;
      },
    );

    setState(() {
      _loading = false;
      _error = error ?? measurementError;
    });

    if (widget.openMeasurementOnLoad && !_openedMeasurement) {
      _openedMeasurement = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showMeasurementDialog();
      });
    }
  }

  ChildMeasurement? get _latest =>
      _measurements.isNotEmpty ? _measurements.last : null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGradientStart,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryDeep),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dapur Cerdas',
              style: GoogleFonts.playfairDisplay(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryDeep,
              ),
            ),
            Text(
              '1000 HPK',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: AppColors.textGrey,
              ),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          children: [
            _HeaderCard(child: _child),
            const SizedBox(height: 12),
            _StatRow(latest: _latest),
            const SizedBox(height: 16),
            _ChartCard(
              child: _child,
              measurements: _measurements,
              loading: _loading,
              tab: _chartTab,
              onTabChanged: (value) => setState(() => _chartTab = value),
            ),
            const SizedBox(height: 16),
            _HistorySection(
              child: _child,
              measurements: _measurements,
              loading: _loading,
              error: _error,
              onAdd: _showMeasurementDialog,
              onRetry: _load,
            ),
            const SizedBox(height: 16),
            _MpasiGuide(ageMonths: _child.ageInMonths),
            const SizedBox(height: 16),
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _showMeasurementDialog,
                icon: const Icon(Icons.add_chart, size: 18),
                label: Text(
                  'Catat pengukuran baru',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showMeasurementDialog() async {
    final weight = TextEditingController(text: _numInput(_latest?.weight));
    final height = TextEditingController(text: _numInput(_latest?.height));
    final head = TextEditingController(
      text: _numInput(_latest?.headCircumference),
    );
    final notes = TextEditingController();
    DateTime date = dateOnly(DateTime.now());
    String? dialogError;

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return AlertDialog(
            title: Text(
              'Catat Pengukuran',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Isi minimal satu ukuran.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: AppColors.textGrey,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: weight,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Berat (kg)',
                      hintText: 'contoh 9.4',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: height,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Tinggi (cm)',
                      hintText: 'contoh 74.5',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: head,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Lingkar kepala (cm)',
                      hintText: 'contoh 44',
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: dialogContext,
                        initialDate: date,
                        firstDate: dateOnly(_child.birthDate),
                        lastDate: dateOnly(DateTime.now()),
                      );
                      if (picked != null) {
                        setDialogState(() => date = picked);
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              DateFormat('d MMMM yyyy', 'id').format(date),
                              style: GoogleFonts.plusJakartaSans(fontSize: 13),
                            ),
                          ),
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 16,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: notes,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Catatan (opsional)',
                      hintText: 'contoh: diukur di posyandu',
                    ),
                  ),
                  if (dialogError != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      dialogError!,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: AppColors.danger,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  final w = _parse(weight.text);
                  final h = _parse(height.text);
                  final lk = _parse(head.text);
                  if (w == null && h == null && lk == null) {
                    setDialogState(
                      () => dialogError = 'Isi minimal satu ukuran',
                    );
                    return;
                  }
                  Navigator.pop(dialogContext, true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Simpan'),
              ),
            ],
          );
        },
      ),
    );

    final w = _parse(weight.text);
    final h = _parse(height.text);
    final lk = _parse(head.text);
    final note = notes.text.trim();
    weight.dispose();
    height.dispose();
    head.dispose();
    notes.dispose();

    if (saved != true) return;

    final result = await sl<AddMeasurementUsecase>().call(
      childId: _child.id,
      weight: w,
      height: h,
      headCircumference: lk,
      notes: note.isEmpty ? null : note,
      measuredAt: date,
    );
    if (!mounted) return;
    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            failure.message,
            style: GoogleFonts.plusJakartaSans(fontSize: 13),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      ),
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Pengukuran tersimpan',
              style: GoogleFonts.plusJakartaSans(fontSize: 13),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
        _load();
      },
    );
  }

  static double? _parse(String value) {
    if (value.trim().isEmpty) return null;
    return double.tryParse(value.trim().replaceAll(',', '.'));
  }

  static String _numInput(double? value) {
    if (value == null) return '';
    return value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(1);
  }
}

class _HeaderCard extends StatelessWidget {
  final Child child;

  const _HeaderCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('d MMM yyyy', 'id');
    final day = child.hpkDay;
    final progress = child.hpkProgress;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                child: Icon(
                  child.gender == 'male' ? Icons.boy : Icons.girl,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      child.name,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    Text(
                      '${child.ageInMonths} bulan · '
                      '${child.gender == 'male' ? 'Laki-laki' : 'Perempuan'}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _MiniTag(
                icon: Icons.cake_outlined,
                label: df.format(child.birthDate),
              ),
              if (child.isEstimatedHpht)
                const _MiniTag(
                  icon: Icons.info_outline,
                  label: 'HPHT perkiraan',
                )
              else
                _MiniTag(
                  icon: Icons.event_available_outlined,
                  label: 'HPHT ${df.format(child.hpht!)}',
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                child.isHpkComplete
                    ? 'Masa 1000 HPK selesai'
                    : 'Hari $day dari 1000 HPK',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.inkSoft,
                ),
              ),
              const Spacer(),
              Text(
                '${(progress * 100).round()}%',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(9999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.hairline,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
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
      decoration: BoxDecoration(
        color: AppColors.bgGradientStart,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textGrey),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              color: AppColors.inkSoft,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final ChildMeasurement? latest;

  const _StatRow({this.latest});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.monitor_weight_outlined,
            label: 'Berat',
            value: _value(latest?.weight, 'kg'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            icon: Icons.height,
            label: 'Tinggi',
            value: _value(latest?.height, 'cm'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            icon: Icons.circle_outlined,
            label: 'Lingkar kepala',
            value: _value(latest?.headCircumference, 'cm'),
          ),
        ),
      ],
    );
  }

  static String _value(double? value, String unit) {
    if (value == null) return '-';
    final text = value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(1);
    return '$text $unit';
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: AppColors.textGrey),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    color: AppColors.textGrey,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
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
  final ValueChanged<String> onTabChanged;

  const _ChartCard({
    required this.child,
    required this.measurements,
    required this.loading,
    required this.tab,
    required this.onTabChanged,
  });

  bool get _supportsAge => child.ageInMonths >= 6 && child.ageInMonths <= 36;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Kurva pertumbuhan',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
              ),
              _TabPill(
                label: 'TB/U',
                active: tab == 'TB/U',
                onTap: () => onTabChanged('TB/U'),
              ),
              const SizedBox(width: 6),
              _TabPill(
                label: 'BB/U',
                active: tab == 'BB/U',
                onTap: () => onTabChanged('BB/U'),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            tab == 'BB/U'
                ? 'Berat badan menurut umur'
                : 'Tinggi badan menurut umur',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: AppColors.textGrey,
            ),
          ),
          const SizedBox(height: 10),
          if (!_supportsAge)
            _ChartNote(
              text: child.ageInMonths < 6
                  ? 'Kurva ini dimulai pada usia 6 bulan. Catat pengukuran '
                        'tetap berguna untuk memantau tren.'
                  : 'Kurva di halaman ini berhenti di 36 bulan. Riwayat '
                        'pengukuran tetap tersimpan.',
            )
          else if (loading)
            const SizedBox(
              height: 180,
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          else
            SizedBox(
              height: 200,
              child: _WhoChart(
                child: child,
                measurements: measurements,
                tab: tab,
              ),
            ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendDot(
                color: AppColors.primary,
                label: child.name.split(' ').first,
              ),
              const SizedBox(width: 12),
              const _LegendDot(color: Color(0xFFF59E0B), label: 'Median WHO'),
              const SizedBox(width: 12),
              const _LegendDot(
                color: AppColors.danger,
                label: '-2 SD',
                bordered: true,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Angka median dan -2 SD dibulatkan dari tabel WHO 2006. '
            'Grafik bukan diagnosis; konsultasikan hasilnya ke tenaga kesehatan.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              color: AppColors.textGrey,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartNote extends StatelessWidget {
  final String text;

  const _ChartNote({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgGradientStart,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          color: AppColors.inkSoft,
          height: 1.4,
        ),
      ),
    );
  }
}

class _TabPill extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _TabPill({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        constraints: const BoxConstraints(minHeight: 44, minWidth: 48),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: active ? Colors.white : AppColors.inkSoft,
          ),
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  final bool bordered;

  const _LegendDot({
    required this.color,
    required this.label,
    this.bordered = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: bordered ? Colors.transparent : color,
            shape: BoxShape.circle,
            border: bordered ? Border.all(color: color, width: 2) : null,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: AppColors.textGrey,
          ),
        ),
      ],
    );
  }
}

class _WhoChart extends StatelessWidget {
  final Child child;
  final List<ChildMeasurement> measurements;
  final String tab;

  const _WhoChart({
    required this.child,
    required this.measurements,
    required this.tab,
  });

  @override
  Widget build(BuildContext context) {
    final isWeight = tab == 'BB/U';
    final who = isWeight ? _whoWeightTable(child.gender) : _whoTable();
    final medianSpots = who
        .map((point) => FlSpot(point.age.toDouble(), point.median))
        .toList();
    final minus2Spots = who
        .map((point) => FlSpot(point.age.toDouble(), point.minus2))
        .toList();

    final childSpots = <FlSpot>[];
    for (final measurement in measurements) {
      final value = isWeight ? measurement.weight : measurement.height;
      if (value == null) continue;
      final age = _ageAt(measurement.measuredAt, child.birthDate);
      if (age < 6 || age > 36) continue;
      childSpots.add(FlSpot(age, value));
    }

    final unit = isWeight ? 'kg' : 'cm';
    final minY = isWeight ? 5.0 : 64.0;
    final maxY = isWeight ? 17.0 : 98.0;
    final interval = isWeight ? 2.0 : 6.0;
    final childBarIndex = childSpots.isEmpty ? -1 : 2;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: interval,
          verticalInterval: 6,
          getDrawingHorizontalLine: (_) =>
              const FlLine(color: AppColors.hairline, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: interval,
              reservedSize: 32,
              getTitlesWidget: (value, _) => Text(
                isWeight ? value.toStringAsFixed(0) : value.toInt().toString(),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 9,
                  color: AppColors.textGrey,
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 6,
              reservedSize: 22,
              getTitlesWidget: (value, _) => Text(
                '${value.toInt()} bln',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 8,
                  color: AppColors.textGrey,
                ),
              ),
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
        minX: 6,
        maxX: 36,
        minY: minY,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: medianSpots,
            isCurved: true,
            color: const Color(0xFFF59E0B),
            barWidth: 2,
            dotData: const FlDotData(show: false),
          ),
          LineChartBarData(
            spots: minus2Spots,
            isCurved: true,
            color: AppColors.danger,
            barWidth: 1.5,
            dashArray: [6, 4],
            dotData: const FlDotData(show: false),
          ),
          if (childSpots.isNotEmpty)
            LineChartBarData(
              spots: childSpots,
              isCurved: true,
              color: AppColors.primary,
              barWidth: 3,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, bar, index) =>
                    FlDotCirclePainter(
                      radius: 4,
                      color: AppColors.primary,
                      strokeWidth: 2,
                      strokeColor: Colors.white,
                    ),
              ),
            ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touched) => touched.map((spot) {
              if (spot.barIndex != childBarIndex) return null;
              return LineTooltipItem(
                '${spot.y.toStringAsFixed(1)} $unit',
                GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  double _ageAt(DateTime measured, DateTime birth) =>
      (measured.difference(birth).inDays / 30.44).clamp(0, 60).toDouble();
}

class _HistorySection extends StatelessWidget {
  final Child child;
  final List<ChildMeasurement> measurements;
  final bool loading;
  final String? error;
  final VoidCallback onAdd;
  final VoidCallback onRetry;

  const _HistorySection({
    required this.child,
    required this.measurements,
    required this.loading,
    required this.error,
    required this.onAdd,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Riwayat pengukuran',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
              ),
              if (measurements.isNotEmpty)
                Text(
                  '${measurements.length} catatan',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: AppColors.textGrey,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          else if (error != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  error!,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppColors.danger,
                  ),
                ),
                TextButton(
                  onPressed: onRetry,
                  style: TextButton.styleFrom(
                    minimumSize: const Size(0, 44),
                    foregroundColor: AppColors.primary,
                  ),
                  child: const Text('Coba lagi'),
                ),
              ],
            )
          else if (measurements.isEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Belum ada pengukuran. Catat berat, tinggi, atau lingkar '
                  'kepala untuk mulai memantau pertumbuhan.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppColors.textGrey,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: onAdd,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 44),
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Catat pengukuran pertama'),
                ),
              ],
            )
          else
            for (final measurement in measurements.reversed)
              _MeasurementRow(child: child, measurement: measurement),
        ],
      ),
    );
  }
}

class _MeasurementRow extends StatelessWidget {
  final Child child;
  final ChildMeasurement measurement;

  const _MeasurementRow({required this.child, required this.measurement});

  @override
  Widget build(BuildContext context) {
    final values = <String>[
      if (measurement.weight != null) 'BB ${_fmt(measurement.weight!)} kg',
      if (measurement.height != null) 'TB ${_fmt(measurement.height!)} cm',
      if (measurement.headCircumference != null)
        'LK ${_fmt(measurement.headCircumference!)} cm',
    ];
    
    final ageInMonths = measurement.measuredAt.difference(child.birthDate).inDays ~/ 30;
    final gender = child.gender;
    
    GrowthStatus? weightStatus;
    GrowthStatus? heightStatus;
    
    if (measurement.weight != null && ageInMonths >= 0 && ageInMonths <= 60) {
      final zScore = WHOStandards.calculateWeightForAge(
        weightKg: measurement.weight!,
        ageInMonths: ageInMonths,
        gender: gender,
      );
      weightStatus = WHOStandards.interpretWeightForAge(zScore);
    }
    
    if (measurement.height != null && ageInMonths >= 0 && ageInMonths <= 60) {
      final zScore = WHOStandards.calculateHeightForAge(
        heightCm: measurement.height!,
        ageInMonths: ageInMonths,
        gender: gender,
      );
      heightStatus = WHOStandards.interpretHeightForAge(zScore);
    }
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  DateFormat('d MMM yyyy', 'id').format(measurement.measuredAt),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
              ),
              Text(
                values.isEmpty ? 'Tanpa ukuran' : values.join(' · '),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: AppColors.inkSoft,
                ),
              ),
            ],
          ),
          if (weightStatus != null || heightStatus != null) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _getStatusBgColor(weightStatus?.level ?? heightStatus?.level),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _getStatusBorderColor(weightStatus?.level ?? heightStatus?.level),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (weightStatus != null) ...[
                    Row(
                      children: [
                        Icon(
                          _getStatusIcon(weightStatus.level),
                          size: 14,
                          color: _getStatusColor(weightStatus.level),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'BB/U: ${weightStatus.label}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: _getStatusColor(weightStatus.level),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      weightStatus.description,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        color: AppColors.inkSoft,
                        height: 1.4,
                      ),
                    ),
                  ],
                  if (weightStatus != null && heightStatus != null)
                    const SizedBox(height: 8),
                  if (heightStatus != null) ...[
                    Row(
                      children: [
                        Icon(
                          _getStatusIcon(heightStatus.level),
                          size: 14,
                          color: _getStatusColor(heightStatus.level),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'TB/U: ${heightStatus.label}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: _getStatusColor(heightStatus.level),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      heightStatus.description,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        color: AppColors.inkSoft,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
          if (measurement.notes != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                measurement.notes!,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: AppColors.textGrey,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(GrowthLevel? level) {
    switch (level) {
      case GrowthLevel.severe:
        return const Color(0xFFB91C1C);
      case GrowthLevel.warning:
        return const Color(0xFFD97706);
      case GrowthLevel.normal:
        return const Color(0xFF15803D);
      default:
        return AppColors.textGrey;
    }
  }

  Color _getStatusBgColor(GrowthLevel? level) {
    switch (level) {
      case GrowthLevel.severe:
        return const Color(0xFFFEE2E2);
      case GrowthLevel.warning:
        return const Color(0xFFFEF3C7);
      case GrowthLevel.normal:
        return const Color(0xFFDCFCE7);
      default:
        return const Color(0xFFF3F4F6);
    }
  }

  Color _getStatusBorderColor(GrowthLevel? level) {
    switch (level) {
      case GrowthLevel.severe:
        return const Color(0xFFFECACA);
      case GrowthLevel.warning:
        return const Color(0xFFFDE68A);
      case GrowthLevel.normal:
        return const Color(0xFFBBF7D0);
      default:
        return const Color(0xFFE5E7EB);
    }
  }

  IconData _getStatusIcon(GrowthLevel? level) {
    switch (level) {
      case GrowthLevel.severe:
        return Icons.error_outline;
      case GrowthLevel.warning:
        return Icons.warning_amber_rounded;
      case GrowthLevel.normal:
        return Icons.check_circle_outline;
      default:
        return Icons.info_outline;
    }
  }

  static String _fmt(double value) => value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(1);
}

class _MpasiGuide extends StatelessWidget {
  final int ageMonths;

  const _MpasiGuide({required this.ageMonths});

  @override
  Widget build(BuildContext context) {
    final String body;
    if (ageMonths < 6) {
      body =
          'ASI eksklusif sampai 6 bulan. Pengukuran rutin tetap dicatat untuk '
          'melihat pertumbuhan.';
    } else if (ageMonths < 24) {
      body =
          'MPASI dimulai usia 6 bulan sambil melanjutkan ASI sampai 2 tahun. '
          'Sertakan sumber protein hewani pada menu harian.';
    } else {
      body =
          'Teruskan pola makan keluarga dengan gizi seimbang dan pantau '
          'pertumbuhan secara berkala.';
    }
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.accentOrangeBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFED7AA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.menu_book_rounded,
            size: 18,
            color: AppColors.accentOrangeText,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Panduan MPASI',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accentOrangeText,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  body,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: AppColors.inkSoft,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// WHO 2006 approximate median and -2SD, rounded, ages 6 to 36 months.
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

List<_WhoPoint> _whoTable() {
  return [
    _WhoPoint(6, 67.6, 63.3),
    _WhoPoint(9, 72.0, 67.5),
    _WhoPoint(12, 75.7, 71.0),
    _WhoPoint(15, 79.1, 74.1),
    _WhoPoint(18, 82.3, 76.9),
    _WhoPoint(21, 85.0, 79.4),
    _WhoPoint(24, 87.1, 81.3),
    _WhoPoint(27, 88.8, 82.9),
    _WhoPoint(30, 90.7, 84.7),
    _WhoPoint(33, 92.5, 86.3),
    _WhoPoint(36, 95.4, 89.1),
  ];
}
