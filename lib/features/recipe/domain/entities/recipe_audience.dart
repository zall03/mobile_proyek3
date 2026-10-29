enum RecipeAudience {
  pregnant(
    apiValue: 'pregnant',
    label: 'Ibu hamil',
    shortLabel: 'Ibu hamil',
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
  breastfeeding(
    apiValue: 'breastfeeding',
    label: 'Ibu menyusui',
    shortLabel: 'Ibu menyusui',
    icon: 'mother',
    restrictions: [
      'tanpa alkohol',
      'kafein dibatasi',
      'perhatikan makanan pemicu alergi pada bayi',
      'sayur dan buah dicuci bersih sebelum diolah',
    ],
  ),
  toddler(
    apiValue: 'toddler',
    label: 'Balita',
    shortLabel: 'Balita',
    icon: 'toddler',
    restrictions: [
      'tanpa garam tambahan',
      'tanpa gula tambahan',
      'tanpa madu',
      'tanpa cabai atau rasa pedas',
      'tanpa makanan keras yang berisiko tersedak',
      'garam dan gula dibatasi',
      'tanpa makanan olahan atau kemasan berlebihan',
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
