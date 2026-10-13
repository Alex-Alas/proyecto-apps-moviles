import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../tasks/domain/task.dart';
import '../../tasks/domain/task_repository.dart';
import '../domain/pomodoro_phase.dart';
import '../domain/pomodoro_progress_recorder.dart';

/// Motor del temporizador Pomodoro y de la cola de tareas de la sesión.
///
/// Flujo de una sesión:
/// 1. El usuario agrega tareas a la cola; la primera es la tarea activa.
/// 2. Corre un bloque de **enfoque**. Al terminar se registra un Pomodoro en la
///    tarea activa (PUT) y se emite [FocusBlockFinished].
/// 3. Sigue un **descanso**: corto, o largo cada 4 bloques (fin del ciclo). Al
///    terminar se emite [BreakFinished].
/// 4. Cuando una tarea alcanza sus Pomodoros estimados sale de la cola y la
///    siguiente pasa a ser la activa.
///
/// Vive por encima de las pantallas (en el árbol de Provider), así que el
/// tiempo sigue corriendo aunque el usuario cambie de pestaña.
class PomodoroStore extends ChangeNotifier {
  PomodoroStore({
    required this._recorder,
    this.settings = PomodoroSettings.standard,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now,
       _remaining = settings.focus,
       _phaseDuration = settings.focus;

  final PomodoroProgressRecorder _recorder;
  final PomodoroSettings settings;
  final DateTime Function() _clock;
  final StreamController<PomodoroEvent> _events = StreamController.broadcast();

  PomodoroPhase _phase = PomodoroPhase.focus;
  Duration _phaseDuration;
  Duration _remaining;
  DateTime? _endsAt;
  Timer? _ticker;

  /// Bloques de enfoque terminados en el ciclo actual (0 a 4).
  int _completedBlocksInCycle = 0;

  /// `true` mientras corre una extensión (+5m / +2m). Al terminar una extensión
  /// de enfoque NO se registra otro Pomodoro: ese bloque ya se contó.
  bool _isExtension = false;

  List<Task> _queue = const [];

  // --- Lectura de estado para la UI -----------------------------------------

  PomodoroPhase get phase => _phase;
  Duration get remaining => _remaining;
  bool get isRunning => _ticker != null;
  Stream<PomodoroEvent> get events => _events.stream;
  List<Task> get queue => List.unmodifiable(_queue);
  Task? get activeTask => _queue.isEmpty ? null : _queue.first;

  /// Fracción transcurrida de la etapa actual, para el anillo del dial.
  double get progress => _phaseDuration.inMilliseconds == 0
      ? 0
      : 1 - _remaining.inMilliseconds / _phaseDuration.inMilliseconds;

  /// Número de bloque dentro del ciclo, para la píldora "Ciclo X/4".
  int get currentBlock => (_completedBlocksInCycle + (_phase == PomodoroPhase.focus ? 1 : 0)).clamp(
    1,
    settings.blocksPerCycle,
  );

  // --- Controles del temporizador --------------------------------------------

  void toggle() => isRunning ? pause() : start();

  void start() {
    if (isRunning) return;
    // Se guarda la hora de fin en lugar de restar segundos: así el conteo no se
    // desfasa aunque el sistema retrase algún tick.
    _endsAt = _clock().add(_remaining);
    _ticker = Timer.periodic(const Duration(milliseconds: 250), (_) => tick());
    notifyListeners();
  }

  void pause() {
    if (!isRunning) return;
    _stopTicker();
    notifyListeners();
  }

  /// Reinicia la etapa actual a su duración completa.
  void reset() {
    _stopTicker();
    _isExtension = false;
    _setPhase(_phase, settings.durationOf(_phase));
    notifyListeners();
  }

  /// Salta a la siguiente etapa sin registrar avance (botón "siguiente").
  void skip() {
    _stopTicker();
    _isExtension = false;
    _setPhase(
      _phase == PomodoroPhase.focus ? _nextBreak(_completedBlocksInCycle) : PomodoroPhase.focus,
      null,
    );
    notifyListeners();
  }

  @visibleForTesting
  void tick() {
    final endsAt = _endsAt;
    if (endsAt == null) return;
    final left = endsAt.difference(_clock());
    _remaining = left.isNegative ? Duration.zero : left;
    if (_remaining == Duration.zero) {
      _stopTicker();
      unawaited(_onPhaseCompleted());
    }
    notifyListeners();
  }

  // --- Acciones de los pop-ups -----------------------------------------------

  /// "Iniciar descanso": arranca el descanso preparado al terminar el enfoque.
  void startBreak() {
    _isExtension = false;
    start();
  }

  /// "Saltar descanso y continuar": vuelve directo a un bloque de enfoque.
  void skipBreakAndContinue() {
    _isExtension = false;
    _setPhase(PomodoroPhase.focus, null);
    start();
  }

  /// "Extender sesión (+5m)": unos minutos extra de enfoque antes del descanso.
  void extendFocus() {
    _isExtension = true;
    _setPhase(PomodoroPhase.focus, settings.focusExtension);
    start();
  }

  /// "Iniciar siguiente sprint": nuevo bloque de enfoque tras el descanso.
  void startNextFocus() {
    _isExtension = false;
    _setPhase(PomodoroPhase.focus, null);
    start();
  }

  /// "Tomar +2 min": alarga el descanso que acaba de terminar.
  void extendBreak() {
    _isExtension = true;
    _setPhase(_phase.isBreak ? _phase : PomodoroPhase.shortBreak, settings.breakExtension);
    start();
  }

  /// "Terminar sesión por hoy": vacía la cola y reinicia el ciclo.
  void endSession() {
    _stopTicker();
    _isExtension = false;
    _completedBlocksInCycle = 0;
    _queue = const [];
    _setPhase(PomodoroPhase.focus, null);
    notifyListeners();
  }

  // --- Cola de la sesión -----------------------------------------------------

  /// Agrega tareas al final de la cola, ignorando las que ya están en ella.
  void addToQueue(Iterable<Task> tasks) {
    final queuedIds = _queue.map((t) => t.id).toSet();
    _queue = [..._queue, ...tasks.where((t) => !t.isCompleted && !queuedIds.contains(t.id))];
    notifyListeners();
  }

  void removeFromQueue(Task task) {
    _queue = _queue.where((t) => t.id != task.id).toList(growable: false);
    notifyListeners();
  }

  bool isQueued(Task task) => _queue.any((t) => t.id == task.id);

  // --- Lógica interna --------------------------------------------------------

  Future<void> _onPhaseCompleted() async {
    if (_phase == PomodoroPhase.focus) {
      final wasExtension = _isExtension;
      _isExtension = false;
      String? warning;
      if (!wasExtension) {
        _completedBlocksInCycle++;
        warning = await _recordActiveTaskProgress();
      }
      final nextBreak = _nextBreak(_completedBlocksInCycle);
      _setPhase(nextBreak, null);
      notifyListeners();
      _events.add(FocusBlockFinished(nextBreak: nextBreak, warning: warning));
    } else {
      _isExtension = false;
      _events.add(const BreakFinished());
    }
  }

  /// Registra el Pomodoro en la tarea activa. Devuelve un aviso si el PUT
  /// falla: el bloque igual cuenta para el ciclo, solo no quedó guardado.
  Future<String?> _recordActiveTaskProgress() async {
    final task = activeTask;
    if (task == null) return null;
    try {
      final updated = await _recorder.recordCompletedPomodoro(task);
      _queue = updated.isCompleted
          ? _queue.where((t) => t.id != updated.id).toList(growable: false)
          : [for (final t in _queue) t.id == updated.id ? updated : t];
      return updated.isCompleted ? '¡"${updated.title}" completada!' : null;
    } on TaskRepositoryException catch (error) {
      return 'No se pudo guardar el avance: ${error.message}';
    }
  }

  /// Cada [PomodoroSettings.blocksPerCycle] bloques toca un descanso largo.
  PomodoroPhase _nextBreak(int completedBlocks) => completedBlocks >= settings.blocksPerCycle
      ? PomodoroPhase.longBreak
      : PomodoroPhase.shortBreak;

  /// Al salir de un descanso largo se cierra el ciclo y el contador vuelve a 0.
  void _finishCycleIfLongBreak() {
    if (_phase == PomodoroPhase.longBreak || _completedBlocksInCycle >= settings.blocksPerCycle) {
      _completedBlocksInCycle = 0;
    }
  }

  /// Cambia de etapa. [duration] nulo significa "la duración normal de esa
  /// etapa"; las extensiones pasan una duración propia.
  void _setPhase(PomodoroPhase phase, Duration? duration) {
    if (phase == PomodoroPhase.focus && _phase.isBreak) _finishCycleIfLongBreak();
    _phase = phase;
    _phaseDuration = duration ?? settings.durationOf(phase);
    _remaining = _phaseDuration;
    _endsAt = null;
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
    _endsAt = null;
  }

  @override
  void dispose() {
    _stopTicker();
    _events.close();
    super.dispose();
  }
}
