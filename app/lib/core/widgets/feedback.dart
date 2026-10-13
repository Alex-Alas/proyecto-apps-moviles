import 'package:flutter/material.dart';

/// Mensajes breves de retroalimentación compartidos por todas las pantallas.
abstract final class AppFeedback {
  static void show(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  /// Para los botones que existen en el diseño de Stitch pero cuya función
  /// todavía no forma parte del alcance (calendario, ajustes, sonido...).
  static void comingSoon(BuildContext context) => show(context, 'Próximamente');
}
