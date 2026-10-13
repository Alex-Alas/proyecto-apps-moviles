import '../domain/task.dart';
import '../domain/task_category.dart';
import '../domain/task_priority.dart';

/// Traduce entre el JSON del backend y las entidades del dominio.
///
/// Es tolerante con lo que llega de MockAPI (ids numéricos o de texto, fechas
/// en ISO-8601 o como timestamp, números como texto) para que un registro
/// creado a mano en el panel de MockAPI no tumbe la lista completa.
abstract final class TaskJsonMapper {
  static Task fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    final startAt = _date(json['startAt']) ?? now;
    return Task(
      id: json['id'].toString(),
      title: (json['title'] as String?)?.trim() ?? '',
      category: TaskCategory.fromApi(json['category'] as String?),
      priority: TaskPriority.fromApi(json['priority'] as String?),
      estimatedPomodoros: _int(json['estimatedPomodoros'], fallback: 1),
      completedPomodoros: _int(json['completedPomodoros'], fallback: 0),
      startAt: startAt,
      dueAt: _date(json['dueAt']) ?? startAt,
      isCompleted: _bool(json['isCompleted']),
      createdAt: _date(json['createdAt']) ?? now,
    );
  }

  /// Cuerpo del POST: el backend asigna `id`; el progreso arranca en cero.
  static Map<String, dynamic> draftToJson(TaskDraft draft) => {
    'title': draft.title.trim(),
    'category': draft.category.apiValue,
    'priority': draft.priority.apiValue,
    'estimatedPomodoros': draft.estimatedPomodoros,
    'completedPomodoros': 0,
    'startAt': draft.startAt.toUtc().toIso8601String(),
    'dueAt': draft.dueAt.toUtc().toIso8601String(),
    'isCompleted': false,
    'createdAt': DateTime.now().toUtc().toIso8601String(),
  };

  /// Cuerpo del PUT: la tarea completa (PUT reemplaza el recurso).
  static Map<String, dynamic> toJson(Task task) => {
    'id': task.id,
    'title': task.title,
    'category': task.category.apiValue,
    'priority': task.priority.apiValue,
    'estimatedPomodoros': task.estimatedPomodoros,
    'completedPomodoros': task.completedPomodoros,
    'startAt': task.startAt.toUtc().toIso8601String(),
    'dueAt': task.dueAt.toUtc().toIso8601String(),
    'isCompleted': task.isCompleted,
    'createdAt': task.createdAt.toUtc().toIso8601String(),
  };

  static DateTime? _date(Object? value) {
    if (value is String) return DateTime.tryParse(value)?.toLocal();
    if (value is num) {
      // Heurística: los timestamps en segundos tienen ~10 dígitos y en ms ~13.
      final millis = value < 100000000000 ? value * 1000 : value;
      return DateTime.fromMillisecondsSinceEpoch(millis.toInt());
    }
    return null;
  }

  static int _int(Object? value, {required int fallback}) {
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  static bool _bool(Object? value) => value == true || value == 'true';
}
