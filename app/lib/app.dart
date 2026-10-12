import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/theme/app_theme.dart';
import 'shell/home_shell.dart';

/// Widget raíz: tema, idioma y pantalla inicial.
class HamtimerApp extends StatelessWidget {
  const HamtimerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hamtimer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      // La UI está en español. Los delegados traducen los widgets de Material
      // (selectores de fecha y hora, botones de diálogo...).
      // TODO(i18n): migrar los textos a ARB (ver lib/l10n) y cambiar a inglés.
      locale: const Locale('es'),
      supportedLocales: const [Locale('es')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: const HomeShell(),
    );
  }
}
