// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Hamtimer';

  @override
  String get navTasks => 'Tareas';

  @override
  String get navPomodoro => 'Pomodoro';

  @override
  String get navNewTask => 'Nueva';

  @override
  String get tasksTitle => 'Mis actividades';

  @override
  String get tasksSubtitle => 'Tu plan de enfoque, ordenado por vencimiento';

  @override
  String get dailyProgress => 'Avance del día';

  @override
  String get filterAll => 'Todas';

  @override
  String get filterToday => 'Hoy';

  @override
  String get filterCompleted => 'Completadas';

  @override
  String get formTitle => 'Nueva actividad';

  @override
  String get formFocusObjective => 'Objetivo de enfoque';

  @override
  String get formCategory => 'Categoría';

  @override
  String get formEstimatedDuration => 'Duración estimada';

  @override
  String get formPriority => 'Nivel de prioridad';

  @override
  String get formSchedule => 'Horario';

  @override
  String get formSubmit => 'Crear actividad';

  @override
  String get pomodoroSessionTasks => 'Tareas de la sesión';

  @override
  String get pomodoroAddTask => 'Agregar tarea';

  @override
  String get comingSoon => 'Próximamente';
}
