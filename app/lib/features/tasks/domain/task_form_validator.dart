import '../../../core/domain/pomodoro_durations.dart';
import 'task_category.dart';

/// Reglas de validación del formulario "Nueva actividad".
///
/// Son funciones puras (sin Flutter de por medio): reciben valores y devuelven
/// `null` si todo está bien o el mensaje de error a mostrar. Así se pueden
/// probar con tests unitarios y reutilizar en cualquier pantalla.
abstract final class TaskFormValidator {
  static const int titleMinLength = 3;
  static const int titleMaxLength = 80;
  static const int minPomodoros = 1;

  static String? title(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Escribe el objetivo de la actividad';
    if (text.length < titleMinLength) {
      return 'Debe tener al menos $titleMinLength caracteres';
    }
    if (text.length > titleMaxLength) {
      return 'Máximo $titleMaxLength caracteres';
    }
    return null;
  }

  static String? category(TaskCategory? value) => value == null ? 'Elige una categoría' : null;

  static String? pomodoros(int value) =>
      value < minPomodoros ? 'Necesitas al menos $minPomodoros Pomodoro' : null;

  /// Validación cruzada del horario: combina tres campos del formulario
  /// (inicio, vencimiento y cantidad de Pomodoros), por eso no puede vivir en
  /// el validador de un solo campo.
  ///
  /// 1. El vencimiento debe ser posterior al inicio.
  /// 2. Entre ambos debe caber el tiempo de enfoque estimado
  ///    (Pomodoros × 25 min); si no, la tarea es imposible de cumplir.
  static String? schedule({
    required DateTime startAt,
    required DateTime dueAt,
    required int estimatedPomodoros,
  }) {
    if (!dueAt.isAfter(startAt)) {
      return 'La hora de fin debe ser posterior a la de inicio';
    }

    final available = dueAt.difference(startAt);
    final required = PomodoroDurations.focusTimeFor(estimatedPomodoros);
    if (available < required) {
      return 'No alcanza el tiempo: $estimatedPomodoros Pomodoro(s) '
          'necesitan ${required.inMinutes} min y solo hay ${available.inMinutes} min';
    }
    return null;
  }
}
