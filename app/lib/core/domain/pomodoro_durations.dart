/// Reglas de tiempo de la técnica Pomodoro que usa Hamtimer.
///
/// Viven en `core` porque las comparten dos módulos: el formulario de tareas
/// (para validar que el horario alcance) y el temporizador.
abstract final class PomodoroDurations {
  static const Duration focus = Duration(minutes: 25);
  static const Duration shortBreak = Duration(minutes: 5);
  static const Duration longBreak = Duration(minutes: 15);

  /// Cada cuántos bloques de enfoque toca un descanso largo.
  static const int blocksPerCycle = 4;

  /// Tiempo de enfoque necesario para completar [pomodoros] bloques.
  static Duration focusTimeFor(int pomodoros) => focus * pomodoros;
}
