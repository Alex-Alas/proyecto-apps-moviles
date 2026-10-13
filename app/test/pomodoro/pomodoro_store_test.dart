import 'package:flutter_test/flutter_test.dart';
import 'package:hamtimer/features/pomodoro/application/pomodoro_store.dart';
import 'package:hamtimer/features/pomodoro/domain/pomodoro_phase.dart';
import 'package:hamtimer/features/pomodoro/domain/pomodoro_progress_recorder.dart';
import 'package:hamtimer/features/tasks/domain/task.dart';

import '../support/task_factory.dart';

/// Registrador falso: aplica la regla del dominio sin red y anota las llamadas.
class _FakeRecorder implements PomodoroProgressRecorder {
  final List<String> recordedIds = [];

  @override
  Future<Task> recordCompletedPomodoro(Task task) async {
    recordedIds.add(task.id);
    return task.withCompletedPomodoro();
  }
}

void main() {
  const settings = PomodoroSettings(
    focus: Duration(seconds: 10),
    shortBreak: Duration(seconds: 3),
    longBreak: Duration(seconds: 6),
    focusExtension: Duration(seconds: 5),
    breakExtension: Duration(seconds: 2),
  );

  late DateTime now;
  late _FakeRecorder recorder;
  late PomodoroStore store;
  late List<PomodoroEvent> events;

  setUp(() {
    now = DateTime(2026, 10, 13, 9);
    recorder = _FakeRecorder();
    store = PomodoroStore(recorder: recorder, settings: settings, clock: () => now);
    events = [];
    store.events.listen(events.add);
  });

  tearDown(() => store.dispose());

  /// Arranca la etapa actual y simula que transcurre completa.
  Future<void> runCurrentPhase() async {
    final duration = store.remaining;
    store.start();
    now = now.add(duration);
    store.tick();
    await pumpEventQueue();
  }

  test('un bloque de enfoque registra un Pomodoro en la tarea activa', () async {
    store.addToQueue([buildTask(id: 'a', estimated: 3)]);

    await runCurrentPhase();

    expect(recorder.recordedIds, ['a']);
    expect(store.activeTask!.completedPomodoros, 1);
    expect(store.phase, PomodoroPhase.shortBreak);
    expect(events.single, isA<FocusBlockFinished>());
  });

  test('la tarea sale de la cola al alcanzar su estimado y pasa la siguiente', () async {
    store.addToQueue([buildTask(id: 'a', estimated: 1), buildTask(id: 'b')]);

    await runCurrentPhase();

    expect(store.queue.map((t) => t.id), ['b']);
  });

  test('cada 4 bloques toca descanso largo y luego se reinicia el ciclo', () async {
    for (var block = 1; block <= 4; block++) {
      expect(store.currentBlock, block);
      await runCurrentPhase(); // enfoque
      if (block < 4) {
        expect(store.phase, PomodoroPhase.shortBreak);
        store.skipBreakAndContinue();
        store.pause();
      }
    }

    expect(store.phase, PomodoroPhase.longBreak);
    await runCurrentPhase(); // descanso largo
    expect(events.last, isA<BreakFinished>());

    store.startNextFocus();
    expect(store.currentBlock, 1);
  });

  test('extender el enfoque no registra un Pomodoro extra', () async {
    store.addToQueue([buildTask(id: 'a', estimated: 5)]);
    await runCurrentPhase();

    store.extendFocus();
    store.pause();
    expect(store.remaining, settings.focusExtension);
    await runCurrentPhase();

    expect(recorder.recordedIds, ['a']);
  });

  test('saltar una etapa no cuenta como bloque completado', () {
    store.addToQueue([buildTask(id: 'a')]);

    store.skip();

    expect(store.phase, PomodoroPhase.shortBreak);
    expect(recorder.recordedIds, isEmpty);
  });

  test('terminar la sesión vacía la cola y reinicia el ciclo', () async {
    store.addToQueue([buildTask(id: 'a', estimated: 4)]);
    await runCurrentPhase();

    store.endSession();

    expect(store.queue, isEmpty);
    expect(store.phase, PomodoroPhase.focus);
    expect(store.currentBlock, 1);
    expect(store.isRunning, isFalse);
  });
}
