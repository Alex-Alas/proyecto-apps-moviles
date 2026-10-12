import 'package:flutter_test/flutter_test.dart';
import 'package:hamtimer/features/tasks/application/task_store.dart';
import 'package:hamtimer/features/tasks/data/in_memory_task_repository.dart';
import 'package:hamtimer/features/tasks/domain/task.dart';
import 'package:hamtimer/features/tasks/domain/task_category.dart';
import 'package:hamtimer/features/tasks/domain/task_filter.dart';
import 'package:hamtimer/features/tasks/domain/task_priority.dart';

import '../support/task_factory.dart';

void main() {
  final now = DateTime(2026, 10, 13, 9);

  TaskStore buildStore(List<Task> seed, {int pageSize = 3}) => TaskStore(
    repository: InMemoryTaskRepository(seed: seed, latency: Duration.zero),
    pageSize: pageSize,
    clock: () => now,
  );

  List<Task> manyTasks(int count) => [
    for (var i = 0; i < count; i++)
      buildTask(
        id: '$i',
        dueAt: now.add(Duration(days: i)),
      ),
  ];

  test('carga por páginas hasta agotar los registros (scroll infinito)', () async {
    final store = buildStore(manyTasks(7));

    await store.refresh();
    expect(store.tasks, hasLength(3));
    expect(store.hasMore, isTrue);

    await store.loadMore();
    await store.loadMore();
    expect(store.tasks, hasLength(7));
    expect(store.hasMore, isFalse);
  });

  test('el filtro de categoría se aplica en la consulta', () async {
    final store = buildStore([
      buildTask(id: 'a', category: TaskCategory.study),
      buildTask(id: 'b', category: TaskCategory.meeting),
    ]);

    await store.changeFilter(const CategoryFilter(TaskCategory.meeting));

    expect(store.tasks.map((t) => t.id), ['b']);
  });

  test('el filtro "Hoy" se resuelve en el cliente', () async {
    final store = buildStore([
      buildTask(id: 'today', dueAt: now.add(const Duration(hours: 3))),
      buildTask(id: 'tomorrow', dueAt: now.add(const Duration(days: 1))),
    ]);

    await store.changeFilter(const TodayFilter());

    expect(store.tasks.map((t) => t.id), ['today']);
    expect(store.hasMore, isFalse);
  });

  test('el progreso del día cuenta solo tareas que vencen hoy', () async {
    final store = buildStore([
      buildTask(id: '1', isCompleted: true, dueAt: now.add(const Duration(hours: 1))),
      buildTask(id: '2', dueAt: now.add(const Duration(hours: 2))),
      buildTask(id: '3', isCompleted: true, dueAt: now.add(const Duration(days: 2))),
    ]);

    await store.refresh();

    expect(store.todayProgress.completed, 1);
    expect(store.todayProgress.total, 2);
  });

  test('create hace POST y la tarea aparece en la lista', () async {
    final store = buildStore(const []);
    await store.refresh();

    await store.create(
      TaskDraft(
        title: 'Nueva',
        category: TaskCategory.quickWin,
        priority: TaskPriority.high,
        estimatedPomodoros: 1,
        startAt: now,
        dueAt: now.add(const Duration(hours: 1)),
      ),
    );

    expect(store.tasks.single.title, 'Nueva');
    expect(store.tasks.single.completedPomodoros, 0);
  });

  test('recordCompletedPomodoro suma un Pomodoro y completa al llegar al estimado', () async {
    final store = buildStore([buildTask(id: 'x', estimated: 2, completed: 1)]);
    await store.refresh();

    final updated = await store.recordCompletedPomodoro(store.tasks.single);

    expect(updated.completedPomodoros, 2);
    expect(updated.isCompleted, isTrue);
    expect(store.tasks.single.isCompleted, isTrue);
  });
}
