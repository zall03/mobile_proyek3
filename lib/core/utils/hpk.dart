/// Perhitungan 1000 Hari Pertama Kehidupan (HPK) dan usia kehamilan.
///
/// Semua fungsi memakai tanggal kalender lokal tanpa jam, sehingga hasilnya
/// sama di perangkat dan tidak bergantung pada waktu server.
library;

const int hpkTotalDays = 1000;
const int gestationDays = 280;

DateTime dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

/// Format tanggal yang dipakai backend: YYYY-MM-DD.
String isoDate(DateTime value) {
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '${value.year}-$month-$day';
}

DateTime hplFromHpht(DateTime hpht) =>
    dateOnly(hpht).add(const Duration(days: gestationDays));

DateTime hpkEndDate(DateTime hpht) =>
    dateOnly(hpht).add(const Duration(days: hpkTotalDays - 1));

DateTime estimatedHphtFromBirth(DateTime birthDate) =>
    dateOnly(birthDate).subtract(const Duration(days: gestationDays));

int daysSince(DateTime from, {DateTime? now}) {
  final start = dateOnly(from);
  final today = dateOnly(now ?? DateTime.now());
  return today.difference(start).inDays;
}

/// Hari HPK ke-1 dimulai pada tanggal HPHT.
int hpkDayOf(DateTime hpht, {DateTime? now}) {
  final day = daysSince(hpht, now: now) + 1;
  if (day < 1) return 1;
  if (day > hpkTotalDays) return hpkTotalDays;
  return day;
}

double hpkProgressOf(DateTime hpht, {DateTime? now}) =>
    (hpkDayOf(hpht, now: now) / hpkTotalDays).clamp(0.0, 1.0);

bool hpkIsComplete(DateTime hpht, {DateTime? now}) =>
    daysSince(hpht, now: now) >= hpkTotalDays;

int gestationalDaysOf(DateTime hpht, {DateTime? now}) {
  final days = daysSince(hpht, now: now);
  return days < 0 ? 0 : days;
}

int gestationalWeeksOf(DateTime hpht, {DateTime? now}) =>
    gestationalDaysOf(hpht, now: now) ~/ 7;

int trimesterOf(DateTime hpht, {DateTime? now}) {
  final week = gestationalWeeksOf(hpht, now: now);
  if (week < 13) return 1;
  if (week < 27) return 2;
  return 3;
}

int daysUntilDueOf(DateTime hpht, {DateTime? now}) {
  final remaining = gestationDays - gestationalDaysOf(hpht, now: now);
  return remaining < 0 ? 0 : remaining;
}

double gestationProgressOf(DateTime hpht, {DateTime? now}) =>
    (gestationalDaysOf(hpht, now: now) / gestationDays).clamp(0.0, 1.0);
