import 'package:flutter/material.dart';

/// Paleta tomada 1:1 de los tokens de Tailwind exportados desde Stitch
/// (ver `docs/stitch/README.md`). Solo se declaran los tokens que la app usa.
abstract final class AppColors {
  // Superficie base del estilo neomórfico: todo "sale" o "se hunde" de aquí.
  static const Color surface = Color(0xFFE8EAF0);
  static const Color onSurface = Color(0xFF2E3040);
  static const Color onSurfaceVariant = Color(0xFF585A68);

  static const Color primary = Color(0xFF6366F1);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF818CF8);
  static const Color primaryFixed = Color(0xFFE0E2FF);
  static const Color onPrimaryFixed = Color(0xFF1E1B4B);

  static const Color secondary = Color(0xFF6C6E7E);
  static const Color tertiary = Color(0xFF7C3AED);

  static const Color outline = Color(0xFF8A8C9A);
  static const Color outlineVariant = Color(0xFFD0D2DC);

  static const Color error = Color(0xFFDC2626);
  static const Color errorContainer = Color(0xFFFEE2E2);

  // Luz y sombra de las superficies neomórficas.
  static const Color shadowDark = Color(0x14000000); // rgba(0,0,0,0.08)
  static const Color shadowLight = Color(0xB3FFFFFF); // rgba(255,255,255,0.7)
}
