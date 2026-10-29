import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/hpk.dart';
import '../../domain/entities/child.dart';

typedef ChildProfileSubmit = void Function({
  required String name,
  required String gender,
  required DateTime birthDate,
  DateTime? hpht,
  double? birthWeightKg,
  double? birthLengthCm,
  double? birthHeadCircumferenceCm,
});

class ChildProfileForm extends StatefulWidget {
  final Child? initialChild;
  final ChildProfileSubmit onSubmit;

  const ChildProfileForm({
    super.key,
    this.initialChild,
    required this.onSubmit,
  });

  @override
  State<ChildProfileForm> createState() => _ChildProfileFormState();
}

class _ChildProfileFormState extends State<ChildProfileForm> {
  late final TextEditingController _name;
  late final TextEditingController _weight;
  late final TextEditingController _length;
  late final TextEditingController _head;
  late String _gender;
  late DateTime _birthDate;
  DateTime? _hpht;
  String? _error;

  @override
  void initState() {
    super.initState();
    final child = widget.initialChild;
    _name = TextEditingController(text: child?.name ?? '');
    _weight = TextEditingController(text: _fmt(child?.birthWeightKg));
    _length = TextEditingController(text: _fmt(child?.birthLengthCm));
    _head = TextEditingController(text: _fmt(child?.birthHeadCircumferenceCm));
    _gender = child?.gender ?? 'male';
    _birthDate = child?.birthDate ?? DateTime.now();
    _hpht = child?.hpht;
  }

  @override
  void dispose() {
    _name.dispose();
    _weight.dispose();
    _length.dispose();
    _head.dispose();
    super.dispose();
  }

  static String _fmt(double? value) {
    if (value == null) return '';
    return value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toString();
  }

  static double? _parse(String value) =>
      double.tryParse(value.trim().replaceAll(',', '.'));

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.initialChild == null
                    ? 'Tambah Profil Anak'
                    : 'Edit Profil Anak',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Profil untuk anak usia 0 sampai 1000 hari pertama kehidupan.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: AppColors.textGrey,
                  height: 1.4,
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.dangerBorder),
                  ),
                  child: Text(
                    _error!,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: AppColors.danger,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              _Label('Nama'),
              TextField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                decoration: _input('Nama anak'),
                style: GoogleFonts.plusJakartaSans(),
              ),
              const SizedBox(height: 14),
              _Label('Jenis kelamin'),
              Row(
                children: [
                  Expanded(
                    child: _Choice(
                      label: 'Laki-laki',
                      selected: _gender == 'male',
                      onTap: () => setState(() => _gender = 'male'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _Choice(
                      label: 'Perempuan',
                      selected: _gender == 'female',
                      onTap: () => setState(() => _gender = 'female'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _Label('Tanggal lahir'),
              _DateRow(value: _birthDate, onTap: _pickBirthDate),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(child: _Label('HPHT (opsional)')),
                  if (_hpht != null)
                    TextButton(
                      onPressed: () => setState(() => _hpht = null),
                      style: TextButton.styleFrom(
                        minimumSize: const Size(0, 32),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      child: Text(
                        'Hapus',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              _DateRow(
                value: _hpht,
                placeholder: 'Pakai perkiraan 280 hari sebelum lahir',
                onTap: _pickHpht,
              ),
              const SizedBox(height: 14),
              _Label('Ukuran lahir (opsional)'),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _weight,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: _input('BB kg'),
                      style: GoogleFonts.plusJakartaSans(fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _length,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: _input('TB cm'),
                      style: GoogleFonts.plusJakartaSans(fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _head,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: _input('LK cm'),
                      style: GoogleFonts.plusJakartaSans(fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        foregroundColor: AppColors.inkSoft,
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Batal',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Simpan',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _input(String hint) {
    return InputDecoration(
      hintText: hint,
      isDense: true,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
      ),
    );
  }

  Future<void> _pickBirthDate() async {
    final today = dateOnly(DateTime.now());
    final first = today.subtract(const Duration(days: 1000));
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate.isBefore(first) ? first : _birthDate,
      firstDate: first,
      lastDate: today,
    );
    if (picked == null) return;
    setState(() {
      _birthDate = picked;
      if (_hpht != null &&
          (_hpht!.isAfter(picked) ||
              _hpht!.isBefore(picked.subtract(const Duration(days: 320))))) {
        _hpht = null;
      }
    });
  }

  Future<void> _pickHpht() async {
    final first = _birthDate.subtract(const Duration(days: 320));
    final picked = await showDatePicker(
      context: context,
      initialDate: _hpht ?? _birthDate.subtract(const Duration(days: 280)),
      firstDate: first,
      lastDate: _birthDate,
    );
    if (picked != null) setState(() => _hpht = picked);
  }

  void _submit() {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Nama anak wajib diisi');
      return;
    }
    final today = dateOnly(DateTime.now());
    if (_birthDate.isAfter(today)) {
      setState(() => _error = 'Tanggal lahir tidak boleh di masa depan');
      return;
    }
    if (_hpht != null && _hpht!.isAfter(_birthDate)) {
      setState(() => _error = 'HPHT tidak boleh setelah tanggal lahir');
      return;
    }
    setState(() => _error = null);
    widget.onSubmit(
      name: name,
      gender: _gender,
      birthDate: dateOnly(_birthDate),
      hpht: _hpht,
      birthWeightKg: _parse(_weight.text),
      birthLengthCm: _parse(_length.text),
      birthHeadCircumferenceCm: _parse(_head.text),
    );
  }
}

class _DateRow extends StatelessWidget {
  final DateTime? value;
  final String placeholder;
  final VoidCallback onTap;

  const _DateRow({
    required this.value,
    required this.onTap,
    this.placeholder = 'Pilih tanggal',
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value == null
                    ? placeholder
                    : DateFormat('d MMMM yyyy', 'id').format(value!),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: value == null ? AppColors.textGrey : AppColors.ink,
                ),
              ),
            ),
            const Icon(
              Icons.calendar_today_outlined,
              size: 17,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _Choice extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Choice({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? AppColors.primaryDeep : AppColors.ink,
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
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.inkSoft,
        ),
      ),
    );
  }
}
