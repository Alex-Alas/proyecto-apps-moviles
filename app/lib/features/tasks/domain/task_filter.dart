import '../../../core/utils/date_utils.dart';
import 'task.dart';
import 'task_category.dart';
import 'task_repository.dart';

/// Filtros de la lista de tareas (chips debajo del banner de progreso).
///
/// Cada filtro decide *dónde* se aplica:
/// - Del lado del servidor, cuando MockAPI puede filtrar por un campo
///   (`category`, `isCompleted`). Se combina con la paginación.
/// - Del lado del cliente, cuando MockAPI no lo soporta (rangos de fecha para
///   "Hoy"). En ese caso se descarga la lista completa y se filtra localmente.
sealed class TaskFilter {
  const TaskFilter();

  String get label;

  /// `true` si el filtro necesita la lista completa para filtrar en el cliente.
  bool get isClientSide => false;

  /// Petición al servidor para la página [page].
  TaskQuery toQuery({required int page, required int limit}) => TaskQuery(page: page, limit: limit);

  /// Filtro local (solo se usa cuando [isClientSide] es `true`).
  bool matches(Task task, DateTime now) => true;

  /// Opciones en el orden en que aparecen los chips.
  static List<TaskFilter> get options => [
    const AllTasksFilter(),
    const TodayFilter(),
    const CompletedFilter(),
    for (final category in TaskCategory.values) CategoryFilter(category),
  ];
}

class AllTasksFilter extends TaskFilter {
  const AllTasksFilter();

  @override
  String get label => 'Todas';

  @override
  bool operator ==(Object other) => other is AllTasksFilter;

  @override
  int get hashCode => (AllTasksFilter).hashCode;
}

class TodayFilter extends TaskFilter {
  const TodayFilter();

  @override
  String get label => 'Hoy';

  @override
  bool get isClientSide => true;

  @override
  bool matches(Task task, DateTime now) => task.dueAt.isSameDayAs(now);

  @override
  bool operator ==(Object other) => other is TodayFilter;

  @override
  int get hashCode => (TodayFilter).hashCode;
}

class CompletedFilter extends TaskFilter {
  const CompletedFilter();

  @override
  String get label => 'Completadas';

  @override
  TaskQuery toQuery({required int page, required int limit}) =>
      TaskQuery(page: page, limit: limit, isCompleted: true);

  @override
  bool operator ==(Object other) => other is CompletedFilter;

  @override
  int get hashCode => (CompletedFilter).hashCode;
}

class CategoryFilter extends TaskFilter {
  const CategoryFilter(this.category);

  final TaskCategory category;

  @override
  String get label => category.label;

  @override
  TaskQuery toQuery({required int page, required int limit}) =>
      TaskQuery(page: page, limit: limit, category: category);

  @override
  bool operator ==(Object other) => other is CategoryFilter && other.category == category;

  @override
  int get hashCode => category.hashCode;
}
