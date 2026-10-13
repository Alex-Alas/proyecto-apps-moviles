import 'package:flutter_test/flutter_test.dart';
import 'package:hamtimer/features/tasks/domain/task_category.dart';
import 'package:hamtimer/features/tasks/domain/task_form_validator.dart';

void main() {
  group('title', () {
    test('rechaza vacío, muy corto y muy largo', () {
      expect(TaskFormValidator.title(''), isNotNull);
      expect(TaskFormValidator.title('   '), isNotNull);
      expect(TaskFormValidator.title('ab'), isNotNull);
      expect(TaskFormValidator.title('a' * 81), isNotNull);
    });

    test('acepta un objetivo válido (ignorando espacios)', () {
      expect(TaskFormValidator.title('  Estudiar cálculo  '), isNull);
    });
  });

  test('category es obligatoria', () {
    expect(TaskFormValidator.category(null), isNotNull);
    expect(TaskFormValidator.category(TaskCategory.study), isNull);
  });

  test('pomodoros debe ser >= 1', () {
    expect(TaskFormValidator.pomodoros(0), isNotNull);
    expect(TaskFormValidator.pomodoros(1), isNull);
    expect(TaskFormValidator.pomodoros(20), isNull);
  });

  group('schedule (validación cruzada)', () {
    final start = DateTime(2026, 10, 13, 10);

    test('el vencimiento debe ser posterior al inicio', () {
      expect(
        TaskFormValidator.schedule(startAt: start, dueAt: start, estimatedPomodoros: 1),
        contains('posterior'),
      );
      expect(
        TaskFormValidator.schedule(
          startAt: start,
          dueAt: start.subtract(const Duration(hours: 1)),
          estimatedPomodoros: 1,
        ),
        contains('posterior'),
      );
    });

    test('entre inicio y fin deben caber los Pomodoros estimados', () {
      // 3 Pomodoros = 75 min, pero solo hay 60.
      expect(
        TaskFormValidator.schedule(
          startAt: start,
          dueAt: start.add(const Duration(hours: 1)),
          estimatedPomodoros: 3,
        ),
        contains('No alcanza'),
      );
    });

    test('acepta un horario con tiempo suficiente (límite exacto incluido)', () {
      expect(
        TaskFormValidator.schedule(
          startAt: start,
          dueAt: start.add(const Duration(minutes: 50)),
          estimatedPomodoros: 2,
        ),
        isNull,
      );
    });
  });
}
