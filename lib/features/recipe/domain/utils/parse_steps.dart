/// Instructions disimpan sebagai satu blok teks dengan baris baru sebagai
/// pemisah langkah. Cookbook tidak selalu rapi, jadi baris kosong dan
/// penomoran yang sudah ada ikut dibersihkan.
List<String> parseRecipeSteps(String instructions) {
  final steps = <String>[];

  for (final raw in instructions.split(RegExp(r'[\r\n]+'))) {
    final line = raw.trim();
    if (line.isEmpty) continue;

    final cleaned = line
        .replaceFirst(RegExp(r'^(\d+[\.\)]|[-*\u2022])\s*'), '')
        .trim();
    steps.add(cleaned.isEmpty ? line : cleaned);
  }

  return steps;
}
