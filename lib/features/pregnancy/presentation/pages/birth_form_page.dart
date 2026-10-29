import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/hpk.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/pregnancy.dart';
import '../cubit/pregnancy_cubit.dart';

/// Form kelahiran: menutup kehamilan dan membuat profil anak dalam satu
/// transaksi di backend. Dial ENERGY 1 / RHYTHM 1 / MOTION 1.
class BirthFormPage extends StatelessWidget {
  final Pregnancy pregnancy;

  const BirthFormPage({super.key, required this.pregnancy});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PregnancyCubit>(),
      child: _BirthForm(pregnancy: pregnancy),
    );
  }
}

class _BirthForm extends StatefulWidget {
  final Pregnancy pregnancy;

  const _BirthForm({required this.pregnancy});

  @override
  State<_BirthForm> createState() => _BirthFormState();
}

class _BirthFormState extends State<_BirthForm> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _weight = TextEditingController();
  final _length = TextEditingController();
  final _head = TextEditingController();
  final _notes = TextEditingController();

  late DateTime _deliveryDate;
  String _gender = 'Laki-laki';
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _deliveryDate = dateOnly(DateTime.now());
  }

  @override
  void dispose() {
    _name.dispose();
    _weight.dispose();
    _length.dispose();
    _head.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGradientStart,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryDeep),
        title: Text(
          'Catat Kelahiran',
          style: GoogleFonts.playfairDisplay(
            color: AppColors.primaryDeep,
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
            _IntroCard(
              pregnancy: widget.pregnancy,
              deliveryDate: _deliveryDate,
            ),
            const SizedBox(height: 20),
            const _Label('Nama bayi'),
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: _decoration('Nama lengkap bayi'),
              style: GoogleFonts.plusJakartaSans(),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nama bayi wajib diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            const _Label('Jenis kelamin'),
            Row(
              children: [
                Expanded(
                  child:                   _GenderChoice(
                    label: 'Laki-laki',
                    icon: Icons.boy,
                    selected: _gender == 'Laki-laki',
                    onTap: () => setState(() => _gender = 'Laki-laki'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _GenderChoice(
                    label: 'Perempuan',
                    icon: Icons.girl,
                    selected: _gender == 'Perempuan',
                    onTap: () => setState(() => _gender = 'Perempuan'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const _Label('Tanggal lahir'),
            _DateField(
              value: _deliveryDate,
              firstDate: dateOnly(widget.pregnancy.hphtDate),
              lastDate: dateOnly(DateTime.now()),
              onChanged: (date) => setState(() => _deliveryDate = date),
            ),
            const SizedBox(height: 20),
            const _Label('Ukuran lahir (opsional)'),
            Row(
              children: [
                Expanded(
                  child: _NumberField(
                    controller: _weight,
                    label: 'Berat (kg)',
                    hint: '3.1',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _NumberField(
                    controller: _length,
                    label: 'Panjang (cm)',
                    hint: '49',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _NumberField(
                    controller: _head,
                    label: 'Lingkar kepala (cm)',
                    hint: '34',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const _Label('Catatan (opsional)'),
            TextFormField(
              controller: _notes,
              maxLines: 3,
              decoration: _decoration(
                'Contoh: lahir spontan, kondisi ibu dan bayi baik',
              ),
              style: GoogleFonts.plusJakartaSans(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
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
                        'Simpan dan mulai 1000 HPK',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _submitting = true);
    final error = await context.read<PregnancyCubit>().registerBirth(
      id: widget.pregnancy.id,
      deliveryDate: _deliveryDate,
      babyName: _name.text.trim(),
      gender: _gender,
      birthWeightKg: _parse(_weight.text),
      birthLengthCm: _parse(_length.text),
      birthHeadCircumferenceCm: _parse(_head.text),
      notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (error == null) {
      Navigator.pop(context, true);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error, style: GoogleFonts.plusJakartaSans(fontSize: 13)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static double? _parse(String value) =>
      double.tryParse(value.trim().replaceAll(',', '.'));

  InputDecoration _decoration(String hint) {
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
        borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  final Pregnancy pregnancy;
  final DateTime deliveryDate;

  const _IntroCard({required this.pregnancy, required this.deliveryDate});

  @override
  Widget build(BuildContext context) {
    final hpht = dateOnly(pregnancy.hphtDate);
    final days = deliveryDate.difference(hpht).inDays;
    final weeks = days ~/ 7;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            pregnancy.motherName,
            style: GoogleFonts.playfairDisplay(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'HPHT ${DateFormat('d MMM yyyy', 'id').format(pregnancy.hphtDate)}'
            ' · lahir di usia $weeks minggu',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: AppColors.textGrey,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Data anak dan status kehamilan disimpan bersamaan. Bila gagal, '
            'keduanya tidak berubah.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: AppColors.inkSoft,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _GenderChoice extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _GenderChoice({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.08)
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: selected ? AppColors.primary : AppColors.textGrey,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? AppColors.primaryDeep : AppColors.ink,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;

  const _NumberField({
    required this.controller,
    required this.label,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        isDense: true,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
      ),
      style: GoogleFonts.plusJakartaSans(fontSize: 13),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return null;
        if (double.tryParse(value.replaceAll(',', '.')) == null) {
          return 'Angka';
        }
        return null;
      },
    );
  }
}

class _DateField extends StatefulWidget {
  final DateTime value;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTime> onChanged;

  const _DateField({
    required this.value,
    required this.firstDate,
    required this.lastDate,
    required this.onChanged,
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
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.value,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
    );
    if (picked != null) widget.onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label:
          'Tanggal lahir, ${DateFormat('d MMMM yyyy', 'id').format(widget.value)}',
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
              color: _focused ? AppColors.primary : AppColors.border,
              width: _focused ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  DateFormat('d MMMM yyyy', 'id').format(widget.value),
                  style: GoogleFonts.plusJakartaSans(fontSize: 14),
                ),
              ),
              const Icon(
                Icons.calendar_today_outlined,
                size: 18,
                color: AppColors.primary,
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
