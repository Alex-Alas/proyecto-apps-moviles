import 'package:flutter/material.dart';

/// Categorías de actividad definidas en el diseño de Stitch.
///
/// [apiValue] es el texto que viaja a la API: se mantiene estable aunque la
/// etiqueta visible cambie (p. ej. al traducir la app al inglés).
enum TaskCategory {
  deepWork('deepWork', 'Trabajo profundo', Icons.psychology_outlined),
  quickWin('quickWin', 'Victoria rápida', Icons.bolt_outlined),
  personal('personal', 'Personal', Icons.person_outline),
  study('study', 'Estudio', Icons.menu_book_outlined),
  meeting('meeting', 'Reunión', Icons.groups_outlined);

  const TaskCategory(this.apiValue, this.label, this.icon);

  final String apiValue;
  final String label;
  final IconData icon;

  /// Si la API trae un valor desconocido no se rompe la app: cae en [personal].
  static TaskCategory fromApi(String? value) => TaskCategory.values.firstWhere(
    (category) => category.apiValue == value,
    orElse: () => TaskCategory.personal,
  );
}
