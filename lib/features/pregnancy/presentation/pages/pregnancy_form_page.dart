import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/hpk.dart';
import '../../domain/entities/pregnancy.dart';
import '../cubit/pregnancy_cubit.dart';
import '../cubit/pregnancy_state.dart';

class PregnancyFormPage extends StatefulWidget {
  final Pregnancy? pregnancy;

  const PregnancyFormPage({super.key, this.pregnancy});

  @override
  State<PregnancyFormPage> createState() => _PregnancyFormPageState();
}

class _PregnancyFormPageState extends State<PregnancyFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _notesController;

  DateTime? _hpht;
  DateTime? _hpl;
  bool _submitting = false;

  /// Batas atas usia kehamilan yang masih masuk akal: 42 minggu.
  static const _maxGestationDays = 294;

  @override
  void initState() {
    super.initState();
    final existing = widget.pregnancy;
    _nameController = TextEditingController(text: existing?.motherName ?? '');
    _notesController = TextEditingController(text: existing?.notes ?? '');
    _hpht = existing?.hphtDate;
    _hpl = existing?.dueDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGradientStart,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryDark),
        title: Text(
          widget.pregnancy == null ? 'Tambah Data Kehamilan' : 'Perbarui Data',
          style: GoogleFonts.playfairDisplay(
            color: AppColors.primaryDark,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            _Label('Nama ibu'),
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: _inputDecoration('Contoh: nama ibu'),
              style: GoogleFonts.plusJakartaSans(),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nama ibu wajib diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),
            _Label('HPHT (hari pertama haid terakhir)'),
            _DateField(
              value: _hpht,
              onChanged: (date) {
                setState(() {
                  _hpht = date;
                  _hpl = hplFromHpht(date);
                });
              },
            ),
            const SizedBox(height: 18),
            _Label('HPL (opsional, otomatis dari HPHT)'),
            _DateField(
              value: _hpl,
              placeholder: 'Pilih atau biarkan otomatis',
              firstDate: _hpht,
              lastDate: _hpht?.add(const Duration(days: 300)),
              onChanged: (date) => setState(() => _hpl = date),
            ),
            const SizedBox(height: 18),
            _Label('Catatan (opsional)'),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: _inputDecoration(
                'Contoh: kontrol rutin di puskesmas',
              ),
              style: GoogleFonts.plusJakartaSans(),
            ),
            const SizedBox(height: 20),
            if (_hpht != null) _Preview(hpht: _hpht!, hpl: _hpl),
            const SizedBox(height: 20),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  disabledBackgroundColor: AppColors.primaryDark.withValues(
                    alpha: 0.6,
                  ),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : Text(
                        'Simpan',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.plusJakartaSans(
        color: AppColors.textGrey,
        fontSize: 14,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.primaryMedium,
          width: 1.4,
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_hpht == null) {
      _snack('Tanggal HPHT belum dipilih');
      return;
    }

    final ageInDays = daysSince(_hpht!);
    if (ageInDays < 0) {
      _snack('Tanggal HPHT tidak boleh di masa depan');
      return;
    }
    if (ageInDays > _maxGestationDays) {
      _snack(
        'Usia kehamilan dari HPHT itu sudah lewat $_maxGestationDays hari '
        '(42 minggu). Periksa kembali tanggalnya.',
      );
      return;
    }
    if (_hpl != null && _hpl!.isBefore(_hpht!)) {
      _snack('HPL tidak boleh sebelum HPHT');
      return;
    }

    setState(() => _submitting = true);
    final cubit = context.read<PregnancyCubit>();
    final notes = _notesController.text.trim();
    final success = await cubit.saveProfile(
      motherName: _nameController.text.trim(),
      hphtDate: _hpht!,
      hplDate: _hpl,
      notes: notes.isEmpty ? null : notes,
      id: widget.pregnancy?.id,
    );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (success) {
      Navigator.pop(context);
      return;
    }

    final state = cubit.state;
    _snack(
      state is PregnancyFailure ? state.message : 'Gagal menyimpan, coba lagi.',
    );
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.plusJakartaSans(fontSize: 13),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _Preview extends StatelessWidget {
  final DateTime hpht;
  final DateTime? hpl;

  const _Preview({required this.hpht, this.hpl});

  @override
  Widget build(BuildContext context) {
    final preview = Pregnancy(
      id: '',
      motherName: '',
      hphtDate: hpht,
      dueDate: hpl ?? hplFromHpht(hpht),
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgGradientStart,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.insights_outlined,
            size: 20,
            color: AppColors.primaryDark,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Hari ${preview.hpkDay} dari 1000 HPK · '
              'Minggu ${preview.ageInWeeks} · Trimester ${preview.trimester} · '
              'HPL ${DateFormat('d MMM yyyy', 'id').format(preview.dueDate)}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryDark,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateField extends StatefulWidget {
  final DateTime? value;
  final ValueChanged<DateTime> onChanged;
  final String placeholder;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const _DateField({
    required this.value,
    required this.onChanged,
    this.placeholder = 'Pilih tanggal',
    this.firstDate,
    this.lastDate,
  });

  @override
  State<_DateField> createState() => _DateFieldState();
}

class _DateFieldState extends State<_DateField> {
  final _focusNode = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (mounted) setState(() => _focused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    final now = DateTime.now();
    final first = widget.firstDate ?? now.subtract(const Duration(days: 300));
    final last = widget.lastDate ?? now;
    final initial = widget.value ?? widget.lastDate ?? DateTime.now();
    final safeInitial = initial.isBefore(first)
        ? first
        : (initial.isAfter(last) ? last : initial);
    final picked = await showDatePicker(
      context: context,
      initialDate: safeInitial,
      firstDate: first,
      lastDate: last,
    );
    if (picked != null) widget.onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final text = widget.value == null
        ? widget.placeholder
        : DateFormat('d MMMM yyyy', 'id').format(widget.value!);

    return Semantics(
      button: true,
      label: 'Tanggal HPHT, $text',
      child: InkWell(
        focusNode: _focusNode,
        borderRadius: BorderRadius.circular(12),
        onTap: _pick,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _focused ? AppColors.primaryDark : AppColors.border,
              width: _focused ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: widget.value == null
                        ? AppColors.textGrey
                        : AppColors.ink,
                  ),
                ),
              ),
              const Icon(
                Icons.calendar_today_outlined,
                size: 18,
                color: AppColors.primaryMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;

  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.inkSoft,
        ),
      ),
    );
  }
}
