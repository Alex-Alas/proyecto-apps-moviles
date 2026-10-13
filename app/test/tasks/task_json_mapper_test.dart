import 'package:flutter_test/flutter_test.dart';
import 'package:hamtimer/features/tasks/data/task_json_mapper.dart';
import 'package:hamtimer/features/tasks/domain/task_category.dart';
import 'package:hamtimer/features/tasks/domain/task_priority.dart';

void main() {
  test('lee el JSON de MockAPI', () {
    final task = TaskJsonMapper.fromJson({
      'id': '7',
      'title': 'Leer capítulo 3',
      'category': 'study',
      'priority': 'high',
      'estimatedPomodoros': 3,
      'completedPomodoros': 1,
      'startAt': '2026-10-13T15:00:00.000Z',
      'dueAt': '2026-10-13T17:00:00.000Z',
      'isCompleted': false,
      'createdAt': '2026-10-12T10:00:00.000Z',
    });

    expect(task.id, '7');
    expect(task.category, TaskCategory.study);
    expect(task.priority, TaskPriority.high);
    expect(task.remainingPomodoros, 2);
    expect(task.dueAt.isAfter(task.startAt), isTrue);
  });

  test('tolera datos generados a mano (timestamps, números como texto, valores raros)', () {
    final task = TaskJsonMapper.fromJson({
      'id': 3,
      'title': 'x',
      'category': 'algo-desconocido',
      'estimatedPomodoros': '2',
      'startAt': 1760367600,
      'isCompleted': 'true',
    });

    expect(task.id, '3');
    expect(task.category, TaskCategory.personal);
    expect(task.priority, TaskPriority.medium);
    expect(task.estimatedPomodoros, 2);
    expect(task.isCompleted, isTrue);
    expect(task.startAt.year, 2025);
  });

  test('el cuerpo del PUT conserva los valores de la API', () {
    final task = TaskJsonMapper.fromJson({
      'id': '1',
      'title': 'T',
      'category': 'deepWork',
      'priority': 'med',
      'estimatedPomodoros': 1,
      'completedPomodoros': 0,
      'startAt': '2026-10-13T15:00:00.000Z',
      'dueAt': '2026-10-13T16:00:00.000Z',
      'isCompleted': false,
      'createdAt': '2026-10-12T10:00:00.000Z',
    });

    final json = TaskJsonMapper.toJson(task.withCompletedPomodoro());

    expect(json['category'], 'deepWork');
    expect(json['priority'], 'med');
    expect(json['completedPomodoros'], 1);
    expect(json['isCompleted'], true);
    expect(json['dueAt'], '2026-10-13T16:00:00.000Z');
  });
}
