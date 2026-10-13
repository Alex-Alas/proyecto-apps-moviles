import 'task.dart';
import 'task_category.dart';

/// Criterios con los que se pide una página de tareas al backend.
class TaskQuery {
  const TaskQuery({required this.page, required this.limit, this.category, this.isCompleted});

  final int page;
  final int limit;
  final TaskCategory? category;
  final bool? isCompleted;
}

/// Contrato de acceso a las tareas (principio de inversión de dependencias).
///
/// La lógica de la app depende de esta abstracción, nunca de HTTP ni de
/// MockAPI. Hoy hay dos implementaciones (MockAPI y memoria) y mañana el
/// backend real del equipo será solo una tercera, sin tocar pantallas.
abstract interface class TaskRepository {
  /// GET paginado y filtrado del lado del servidor.
  Future<List<Task>> fetchPage(TaskQuery query);

  /// GET de todas las tareas, para cálculos que necesitan el panorama completo
  /// (p. ej. el progreso del día o el filtro "Hoy").
  Future<List<Task>> fetchAll();

  /// POST: registra una tarea nueva y devuelve la versión guardada (con `id`).
  Future<Task> create(TaskDraft draft);

  /// PUT: reemplaza una tarea existente y devuelve la versión guardada.
  Future<Task> update(Task task);
}

/// Error de comunicación con el backend, con un mensaje apto para el usuario.
class TaskRepositoryException implements Exception {
  const TaskRepositoryException(this.message);

  final String message;

  @override
  String toString() => 'TaskRepositoryException: $message';
}
