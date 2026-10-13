import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/task_priority.dart';

/// Decisiones visuales que dependen del dominio, centralizadas para que las
/// tarjetas, el formulario y el Pomodoro pinten igual una misma prioridad.
extension TaskPriorityVisuals on TaskPriority {
  Color get color => switch (this) {
    TaskPriority.high => AppColors.tertiary,
    TaskPriority.medium => AppColors.primary,
    TaskPriority.low => AppColors.secondary,
  };

  String get badgeLabel => 'Prioridad ${label.toLowerCase()}';
}
