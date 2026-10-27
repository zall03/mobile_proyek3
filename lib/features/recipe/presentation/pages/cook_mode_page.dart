import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../cooking_log/presentation/cubit/cooking_log_cubit.dart';
import '../../../cooking_log/presentation/cubit/cooking_log_state.dart';
import '../../../cooking_log/presentation/widgets/cook_summary_view.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/utils/parse_steps.dart';
import '../widgets/recipe_body.dart' show formatQuantity;

/// Mode masak: satu langkah per layar, dibaca sambil tangan_basah di bahan.
///
/// Tidak ada pencatatan dan pemotongan stok sampai pengguna menekan
/// "Selesai Masak", jadi keluar di tengah tidak merusak stok.
class CookModePage extends StatefulWidget {
  final Recipe recipe;
  final int servings;

  const CookModePage({super.key, required this.recipe, required this.servings});

  @override
  State<CookModePage> createState() => _CookModePageState();
}

class _CookModePageState extends State<CookModePage> {
  static const List<int> _timerPresets = [3, 5, 10, 15, 20];

  late final PageController _pageController;
  late final List<String> _steps;
  late final Stopwatch _elapsed;

  final Set<int> _done = {};
  int _index = 0;

  Timer? _ticker;
  int _timerTotal = 0;
  int _timerLeft = 0;

  @override
  void initState() {
    super.initState();
    _steps = parseRecipeSteps(widget.recipe.instructions);
    _pageController = PageController();
    _elapsed = Stopwatch()..start();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _onTick());
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _onTick() {
    if (!mounted) return;

    setState(() {
      if (_timerLeft > 0) _timerLeft--;
    });

    if (_timerLeft == 0 && _timerTotal > 0) {
      _timerTotal = 0;
      _timerLeft = 0;
      SystemSound.play(SystemSoundType.alert);
      HapticFeedback.heavyImpact();
    }
  }

  int get _minutesSpent => (_elapsed.elapsedMilliseconds / 60000).floor();

  bool get _isLastStep => _index == _steps.length - 1;

  void _goTo(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  void _toggleDone(int index) {
    setState(() {
      if (!_done.remove(index)) _done.add(index);
    });
  }

  void _pickDuration(int minutes) {
    setState(() {
      _timerTotal = minutes;
      _timerLeft = 0;
    });
  }

  void _toggleTimer() {
    setState(() {
      if (_timerLeft > 0) {
        _timerLeft = 0;
        _timerTotal = 0;
      } else if (_timerTotal > 0) {
        _timerLeft = _timerTotal * 60;
      }
    });
  }

  void _clearTimer() {
    setState(() {
      _timerLeft = 0;
      _timerTotal = 0;
    });
  }

  Future<void> _confirmExit() async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Keluar dari mode masak?',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Progres langkah tidak disimpan dan stok belum dipotong.',
          style: GoogleFonts.plusJakartaSans(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Lanjut Masak',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textGrey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Keluar',
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFFB3261E),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (leave == true && mounted) Navigator.pop(context);
  }

  void _finish() {
    _elapsed.stop();
    _ticker?.cancel();

    context.read<CookingLogCubit>().start(
      recipeId: widget.recipe.id,
      servings: widget.servings,
      durationMinutes: _minutesSpent > 0 ? _minutesSpent : null,
    );
  }

  /// Bahan yang disebut di teks langkah, lengkap dengan takaran terpakai.
  ///
  /// Resep tidak menyimpan pemetaan langkah ke bahan, jadi pencocokan
  /// dibuat dari kemunculan nama bahan di dalam kalimat langkah.
  List<String> _ingredientLines(int index) {
    final step = _steps[index].toLowerCase();
    final base = widget.recipe.servings < 1 ? 1 : widget.recipe.servings;
    final factor = widget.servings / base;
    final lines = <String>[];

    for (final ingredient in widget.recipe.ingredients) {
      final name = ingredient.ingredientName.toLowerCase();
      final tail = name.split(' ').last;
      final hit =
          step.contains(name) || (tail.length >= 4 && step.contains(tail));

      if (!hit) continue;

      lines.add(
        '${ingredient.ingredientName}  ${formatQuantity(ingredient.quantityNeeded * factor, ingredient.unit)}',
      );
    }

    return lines;
  }

  @override
  Widget build(BuildContext context) {
    if (_steps.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.bgGradientStart,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.primaryDark),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Resep ini belum punya langkah memasak, jadi mode masak tidak bisa dimulai.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                height: 1.6,
                color: AppColors.textGrey,
              ),
            ),
          ),
        ),
      );
    }

    return BlocConsumer<CookingLogCubit, CookingLogState>(
      listener: (context, state) {
        if (state is CookingLogSuccess) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => CookSummaryView(
                recipe: widget.recipe,
                servings: widget.servings,
                log: state.log,
                minutesSpent: _minutesSpent,
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        final saving = state is CookingLogLoading;
        final error = state is CookingLogFailure ? state.message : null;

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _confirmExit();
          },
          child: Scaffold(
            backgroundColor: AppColors.bgGradientStart,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              automaticallyImplyLeading: false,
              leading: IconButton(
                icon: const Icon(Icons.close, color: AppColors.primaryDark),
                onPressed: saving ? null : _confirmExit,
              ),
              title: Text(
                widget.recipe.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDark,
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Center(
                    child: Text(
                      _clock(_elapsed.elapsed.inSeconds),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            body: Column(
              children: [
                _StepHeader(
                  total: _steps.length,
                  index: _index,
                  doneCount: _done.length,
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _steps.length,
                    onPageChanged: (index) {
                      setState(() {
                        _index = index;
                        _clearTimer();
                      });
                    },
                    itemBuilder: (context, index) => _StepPage(
                      step: _steps[index],
                      isDone: _done.contains(index),
                      ingredientLines: _ingredientLines(index),
                      timerTotal: _timerTotal,
                      timerLeft: _timerLeft,
                      presets: _timerPresets,
                      onPickDuration: _pickDuration,
                      onToggleTimer: _toggleTimer,
                    ),
                  ),
                ),
                if (error != null) _ErrorStrip(message: error),
                _BottomBar(
                  stepIndex: _index,
                  total: _steps.length,
                  isDone: _done.contains(_index),
                  saving: saving,
                  onPrevious: _index == 0 ? null : () => _goTo(_index - 1),
                  onNext: _isLastStep ? null : () => _goTo(_index + 1),
                  onToggleDone: () => _toggleDone(_index),
                  onFinish: _finish,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static String _clock(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class _StepHeader extends StatelessWidget {
  final int total;
  final int index;
  final int doneCount;

  const _StepHeader({
    required this.total,
    required this.index,
    required this.doneCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: Column(
        children: [
          Row(
            children: List.generate(total, (i) {
              final color = i <= index
                  ? (doneCount > i
                        ? AppColors.primaryDark
                        : AppColors.primaryMedium)
                  : const Color(0xFFE5E7EB);

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i == total - 1 ? 0 : 5),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 4,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Langkah ${index + 1} dari $total',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDark,
                ),
              ),
              const Spacer(),
              if (doneCount > 0)
                Text(
                  '$doneCount selesai',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppColors.textGrey,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepPage extends StatelessWidget {
  final String step;
  final bool isDone;
  final List<String> ingredientLines;
  final int timerTotal;
  final int timerLeft;
  final List<int> presets;
  final ValueChanged<int> onPickDuration;
  final VoidCallback onToggleTimer;

  const _StepPage({
    required this.step,
    required this.isDone,
    required this.ingredientLines,
    required this.timerTotal,
    required this.timerLeft,
    required this.presets,
    required this.onPickDuration,
    required this.onToggleTimer,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            step,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              height: 1.5,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 28),
          _TimerPanel(
            total: timerTotal,
            left: timerLeft,
            presets: presets,
            onPick: onPickDuration,
            onToggle: onToggleTimer,
          ),
          if (ingredientLines.isNotEmpty) ...[
            const SizedBox(height: 28),
            Text(
              'Bahan di langkah ini',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textGrey,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ingredientLines
                  .map(
                    (line) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Text(
                        line,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
          if (isDone) ...[
            const SizedBox(height: 26),
            Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 18,
                  color: AppColors.primaryMedium,
                ),
                const SizedBox(width: 8),
                Text(
                  'Langkah ini sudah dikerjakan',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryMedium,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _TimerPanel extends StatelessWidget {
  final int total;
  final int left;
  final List<int> presets;
  final ValueChanged<int> onPick;
  final VoidCallback onToggle;

  const _TimerPanel({
    required this.total,
    required this.left,
    required this.presets,
    required this.onPick,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final running = left > 0;
    final selected = total > 0 && !running;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.timer_outlined,
                size: 18,
                color: running ? AppColors.primaryDark : AppColors.textGrey,
              ),
              const SizedBox(width: 8),
              Text(
                running ? 'Sisa waktu' : 'Timer langkah ini',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111827),
                ),
              ),
              const Spacer(),
              if (total > 0)
                Text(
                  '$total menit',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppColors.textGrey,
                  ),
                ),
            ],
          ),
          if (running) ...[
            const SizedBox(height: 12),
            Center(
              child: Text(
                _CookModePageState._clock(left),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                  height: 1.1,
                ),
              ),
            ),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: OutlinedButton.icon(
              onPressed: total == 0 ? null : onToggle,
              style: OutlinedButton.styleFrom(
                foregroundColor: running
                    ? const Color(0xFFB3261E)
                    : AppColors.primaryDark,
                side: BorderSide(
                  color: running
                      ? const Color(0xFFB3261E)
                      : AppColors.primaryDark,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: Icon(
                running ? Icons.stop_rounded : Icons.play_arrow_rounded,
                size: 20,
              ),
              label: Text(
                running ? 'Berhenti' : 'Mulai hitung',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          if (selected) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: presets
                  .map(
                    (minutes) => _PresetChip(
                      minutes: minutes,
                      selected: total == minutes,
                      onTap: () => onPick(minutes),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  final int minutes;
  final bool selected;
  final VoidCallback onTap;

  const _PresetChip({
    required this.minutes,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryDark : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? AppColors.primaryDark : const Color(0xFFE5E7EB),
            ),
          ),
          child: Text(
            '$minutes mnt',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : AppColors.primaryDark,
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final int stepIndex;
  final int total;
  final bool isDone;
  final bool saving;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback onToggleDone;
  final VoidCallback onFinish;

  const _BottomBar({
    required this.stepIndex,
    required this.total,
    required this.isDone,
    required this.saving,
    required this.onPrevious,
    required this.onNext,
    required this.onToggleDone,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: saving ? null : onToggleDone,
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDone
                      ? AppColors.primaryMedium
                      : AppColors.textGrey,
                  side: BorderSide(
                    color: isDone
                        ? AppColors.primaryMedium
                        : const Color(0xFFD1D5DB),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(
                  isDone ? Icons.check_circle : Icons.check_circle_outline,
                  size: 20,
                ),
                label: Text(
                  isDone ? 'Sudah dikerjakan' : 'Tandai sudah',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                SizedBox(
                  height: 52,
                  width: 60,
                  child: IconButton.outlined(
                    onPressed: onPrevious == null ? null : onPrevious,
                    icon: const Icon(Icons.arrow_back),
                    style: IconButton.styleFrom(
                      foregroundColor: AppColors.primaryDark,
                      disabledForegroundColor: const Color(0xFFD1D5DB),
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: _primaryButton(context)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _primaryButton(BuildContext context) {
    if (onNext != null) {
      return SizedBox(
        height: 52,
        child: ElevatedButton(
          onPressed: saving ? null : onNext,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryDark,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Berikutnya',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 52,
      child: ElevatedButton.icon(
        onPressed: saving ? null : onFinish,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDark,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: saving
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Color(0xFFFFFFFF)),
                ),
              )
            : const Icon(Icons.check_rounded, size: 22, color: Colors.white),
        label: Text(
          saving ? 'Menyimpan...' : 'Selesai Masak',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _ErrorStrip extends StatelessWidget {
  final String message;

  const _ErrorStrip({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, size: 18, color: Color(0xFFB3261E)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                height: 1.5,
                color: const Color(0xFFB3261E),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
