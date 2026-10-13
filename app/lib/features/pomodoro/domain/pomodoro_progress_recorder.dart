import '../../tasks/domain/task.dart';

/// Lo único que el temporizador necesita saber de las tareas: cómo registrar
/// que se terminó un bloque de enfoque.
///
/// El módulo Pomodoro define esta interfaz mínima (segregación de interfaces)
/// y el módulo de tareas la implementa. Así el temporizador no depende de la
/// lista, la paginación ni la API.
abstract interface class PomodoroProgressRecorder {
  /// Suma un Pomodoro a [task], lo persiste (PUT) y devuelve la tarea
  /// actualizada, que puede haber quedado completada.
  Future<Task> recordCompletedPomodoro(Task task);
}
