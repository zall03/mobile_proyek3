enum RecipeAudience {
  baby6to12Months(
    apiValue: 'baby_6_12_months',
    label: 'Bayi 6-12 bulan',
    shortLabel: 'Bayi 6m+',
    icon: 'baby',
    restrictions: [
      'tanpa garam tambahan',
      'tanpa gula tambahan',
      'tanpa madu',
      'tanpa cabai atau rasa pedas',
      'tanpa susu sapi sebagai minuman utama',
      'tanpa makanan keras yang berisiko tersedak',
      'tanpa makanan olahan atau kemasan',
    ],
  ),
  babyOver1Year(
    apiValue: 'baby_over_1_year',
    label: 'Bayi di atas 1 tahun',
    shortLabel: 'Bayi 1th+',
    icon: 'toddler',
    restrictions: [
      'tanpa cabai atau rasa pedas',
      'tanpa daging, telur, atau ikan yang belum matang',
      'tanpa makanan keras yang berisiko tersedak',
      'garam dan gula dibatasi',
      'tanpa minuman berkafein',
    ],
  ),
  pregnantNursing(
    apiValue: 'pregnant_nursing',
    label: 'Ibu hamil & menyusui',
    shortLabel: 'Hamil & menyusui',
    icon: 'mother',
    restrictions: [
      'tanpa daging, telur, atau ikan yang belum matang',
      'tanpa ikan bermerkuri tinggi (hiu, todak, king mackerel, tilefish)',
      'tanpa alkohol',
      'tanpa susu atau keju yang belum dipasteurisasi',
      'kafein dibatasi',
      'sayur dan buah dicuci bersih sebelum diolah',
    ],
  ),
  family(
    apiValue: 'family',
    label: 'Semua keluarga',
    shortLabel: 'Keluarga',
    icon: 'family',
    restrictions: [],
  );

  const RecipeAudience({
    required this.apiValue,
    required this.label,
    required this.shortLabel,
    required this.icon,
    required this.restrictions,
  });

  final String apiValue;
  final String label;
  final String shortLabel;
  final String icon;
  final List<String> restrictions;
}
