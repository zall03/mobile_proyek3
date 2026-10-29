/// Standar WHO untuk z-score pertumbuhan anak.
/// Simplified version - untuk akurasi penuh gunakan tabel lengkap WHO.

class WHOStandards {
  /// Hitung z-score untuk berat badan berdasarkan usia (weight-for-age)
  static double calculateWeightForAge({
    required double weightKg,
    required int ageInMonths,
    required String gender,
  }) {
    final median = _getWeightMedian(ageInMonths, gender);
    final sd = _getWeightSD(ageInMonths, gender);
    if (median == null || sd == null) return 0;
    return (weightKg - median) / sd;
  }

  /// Hitung z-score untuk tinggi badan berdasarkan usia (height-for-age)
  static double calculateHeightForAge({
    required double heightCm,
    required int ageInMonths,
    required String gender,
  }) {
    final median = _getHeightMedian(ageInMonths, gender);
    final sd = _getHeightSD(ageInMonths, gender);
    if (median == null || sd == null) return 0;
    return (heightCm - median) / sd;
  }

  /// Interpretasi z-score weight-for-age
  static GrowthStatus interpretWeightForAge(double zScore) {
    if (zScore < -3) {
      return GrowthStatus(
        'Gizi Buruk',
        'Berat badan sangat kurang untuk usia anak. Segera konsultasi ke dokter atau ahli gizi.',
        GrowthLevel.severe,
      );
    } else if (zScore < -2) {
      return GrowthStatus(
        'Gizi Kurang',
        'Berat badan kurang untuk usia anak. Perlu perhatian khusus pada asupan gizi.',
        GrowthLevel.warning,
      );
    } else if (zScore <= 2) {
      return GrowthStatus(
        'Normal',
        'Berat badan sesuai dengan usia anak.',
        GrowthLevel.normal,
      );
    } else if (zScore <= 3) {
      return GrowthStatus(
        'Berat Lebih',
        'Berat badan di atas rata-rata untuk usia anak.',
        GrowthLevel.warning,
      );
    } else {
      return GrowthStatus(
        'Obesitas',
        'Berat badan sangat tinggi untuk usia anak. Konsultasi dengan dokter.',
        GrowthLevel.severe,
      );
    }
  }

  /// Interpretasi z-score height-for-age
  static GrowthStatus interpretHeightForAge(double zScore) {
    if (zScore < -3) {
      return GrowthStatus(
        'Sangat Pendek',
        'Tinggi badan sangat kurang untuk usia anak. Segera konsultasi ke dokter.',
        GrowthLevel.severe,
      );
    } else if (zScore < -2) {
      return GrowthStatus(
        'Pendek (Stunting)',
        'Tinggi badan kurang untuk usia anak. Indikasi stunting, perlu perhatian gizi jangka panjang.',
        GrowthLevel.warning,
      );
    } else if (zScore <= 2) {
      return GrowthStatus(
        'Normal',
        'Tinggi badan sesuai dengan usia anak.',
        GrowthLevel.normal,
      );
    } else {
      return GrowthStatus(
        'Tinggi',
        'Tinggi badan di atas rata-rata untuk usia anak.',
        GrowthLevel.normal,
      );
    }
  }

  // Simplified WHO median weight (kg) by age and gender
  static double? _getWeightMedian(int months, String gender) {
    final isMale = gender.toLowerCase().contains('laki');
    if (months < 0 || months > 60) return null;

    // Sample data for 0-60 months (simplified)
    if (isMale) {
      if (months == 0) return 3.3;
      if (months <= 12) return 3.3 + (months * 0.5);
      if (months <= 24) return 9.6 + ((months - 12) * 0.2);
      if (months <= 36) return 12.0 + ((months - 24) * 0.15);
      if (months <= 48) return 13.8 + ((months - 36) * 0.13);
      return 15.4 + ((months - 48) * 0.12);
    } else {
      if (months == 0) return 3.2;
      if (months <= 12) return 3.2 + (months * 0.45);
      if (months <= 24) return 8.9 + ((months - 12) * 0.18);
      if (months <= 36) return 11.1 + ((months - 24) * 0.14);
      if (months <= 48) return 12.8 + ((months - 36) * 0.12);
      return 14.2 + ((months - 48) * 0.11);
    }
  }

  // Simplified WHO SD for weight
  static double? _getWeightSD(int months, String gender) {
    if (months < 0 || months > 60) return null;
    // Simplified: SD increases with age
    return 1.0 + (months * 0.02);
  }

  // Simplified WHO median height (cm) by age and gender
  static double? _getHeightMedian(int months, String gender) {
    final isMale = gender.toLowerCase().contains('laki');
    if (months < 0 || months > 60) return null;

    if (isMale) {
      if (months == 0) return 49.9;
      if (months <= 12) return 49.9 + (months * 2.0);
      if (months <= 24) return 73.9 + ((months - 12) * 0.9);
      if (months <= 36) return 84.7 + ((months - 24) * 0.7);
      if (months <= 48) return 93.1 + ((months - 36) * 0.6);
      return 100.3 + ((months - 48) * 0.5);
    } else {
      if (months == 0) return 49.1;
      if (months <= 12) return 49.1 + (months * 1.9);
      if (months <= 24) return 72.0 + ((months - 12) * 0.85);
      if (months <= 36) return 82.2 + ((months - 24) * 0.65);
      if (months <= 48) return 90.0 + ((months - 36) * 0.55);
      return 96.6 + ((months - 48) * 0.48);
    }
  }

  // Simplified WHO SD for height
  static double? _getHeightSD(int months, String gender) {
    if (months < 0 || months > 60) return null;
    return 2.5 + (months * 0.01);
  }
}

class GrowthStatus {
  final String label;
  final String description;
  final GrowthLevel level;

  const GrowthStatus(this.label, this.description, this.level);
}

enum GrowthLevel {
  severe,
  warning,
  normal,
}
