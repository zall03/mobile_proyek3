import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class IngredientImage extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double size;
  final double borderRadius;

  const IngredientImage({
    super.key,
    required this.imageUrl,
    required this.name,
    this.size = 40,
    this.borderRadius = 10,
  });

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Icon(
        _fallbackIcon,
        color: AppColors.primaryDark,
        size: size * 0.5,
      ),
    );

    final url = imageUrl;
    if (url == null || url.isEmpty) {
      return fallback;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return fallback;
        },
      ),
    );
  }

  IconData get _fallbackIcon {
    final n = name.toLowerCase();
    if (n.contains('ikan') ||
        n.contains('udang') ||
        n.contains('cum') ||
        n.contains('kerang')) {
      return Icons.set_meal;
    }
    if (n.contains('telur')) return Icons.egg_alt;
    if (n.contains('ayam') ||
        n.contains('daging') ||
        n.contains('sapi') ||
        n.contains('kambing')) {
      return Icons.restaurant_menu;
    }
    return Icons.eco;
  }
}