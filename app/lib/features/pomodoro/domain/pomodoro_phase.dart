import '../../../core/domain/pomodoro_durations.dart';

/// Etapas por las que pasa el temporizador.
enum PomodoroPhase {
  focus('Enfoque'),
  shortBreak('Descanso corto'),
  longBreak('Descanso largo');

  const PomodoroPhase(this.label);

  final String label;

  bool get isBreak => this != PomodoroPhase.focus;
}

/// Duraciones efectivas del temporizador.
///
/// [PomodoroSettings.standard] usa los tiempos reales de la técnica Pomodoro;
/// [PomodoroSettings.demo] los reduce a segundos para presentar en clase.
class PomodoroSettings {
  const PomodoroSettings({
    required this.focus,
    required this.shortBreak,
    required this.longBreak,
    required this.focusExtension,
    required this.breakExtension,
  });

  static const standard = PomodoroSettings(
    focus: PomodoroDurations.focus,
    shortBreak: PomodoroDurations.shortBreak,
    longBreak: PomodoroDurations.longBreak,
    focusExtension: Duration(minutes: 5),
    breakExtension: Duration(minutes: 2),
  );

  static const demo = PomodoroSettings(
    focus: Duration(seconds: 10),
    shortBreak: Duration(seconds: 4),
    longBreak: Duration(seconds: 8),
    focusExtension: Duration(seconds: 5),
    breakExtension: Duration(seconds: 3),
  );

  final Duration focus;
  final Duration shortBreak;
  final Duration longBreak;

  /// "Extender sesión (+5m)" del pop-up de bloque terminado.
  final Duration focusExtension;

  /// "Tomar +2 min" del pop-up de descanso terminado.
  final Duration breakExtension;

  int get blocksPerCycle => PomodoroDurations.blocksPerCycle;

  Duration durationOf(PomodoroPhase phase) => switch (phase) {
    PomodoroPhase.focus => focus,
    PomodoroPhase.shortBreak => shortBreak,
    PomodoroPhase.longBreak => longBreak,
  };
}

/// Avisos que el temporizador emite cuando termina una etapa, para que la
/// pantalla muestre el pop-up correspondiente.
sealed class PomodoroEvent {
  const PomodoroEvent();
}

/// Terminó un bloque de enfoque. [warning] trae un mensaje si no se pudo
/// guardar el avance en el backend.
class FocusBlockFinished extends PomodoroEvent {
  const FocusBlockFinished({required this.nextBreak, this.warning});

  final PomodoroPhase nextBreak;
  final String? warning;
}

/// Terminó un descanso (corto o largo).
class BreakFinished extends PomodoroEvent {
  const BreakFinished();
}
