import '../domain/task.dart';
import '../domain/task_category.dart';
import '../domain/task_priority.dart';
import '../domain/task_repository.dart';

/// Repositorio falso en memoria, con la misma interfaz que el de MockAPI.
///
/// Sirve para dos cosas: (1) tests rápidos sin red y (2) respaldo en la demo
/// si MockAPI no responde (`--dart-define=USE_FAKE_API=true`). Simula una
/// pequeña latencia para que los estados de carga se vean igual que en real.
class InMemoryTaskRepository implements TaskRepository {
  InMemoryTaskRepository({List<Task>? seed, this.latency = const Duration(milliseconds: 400)})
    : _tasks = [...?seed];

  /// Crea el repositorio con algunas tareas de ejemplo para la demo.
  factory InMemoryTaskRepository.withSampleData() =>
      InMemoryTaskRepository(seed: _sampleTasks(DateTime.now()));

  final List<Task> _tasks;
  final Duration latency;
  int _nextId = 1000;

  @override
  Future<List<Task>> fetchPage(TaskQuery query) async {
    await Future<void>.delayed(latency);
    final filtered = _sorted()
        .where((t) => query.category == null || t.category == query.category)
        .where((t) => query.isCompleted == null || t.isCompleted == query.isCompleted)
        .toList();
    final start = (query.page - 1) * query.limit;
    if (start >= filtered.length) return const [];
    return filtered.sublist(start, (start + query.limit).clamp(0, filtered.length));
  }

  @override
  Future<List<Task>> fetchAll() async {
    await Future<void>.delayed(latency);
    return _sorted();
  }

  @override
  Future<Task> create(TaskDraft draft) async {
    await Future<void>.delayed(latency);
    final task = Task(
      id: '${_nextId++}',
      title: draft.title.trim(),
      category: draft.category,
      priority: draft.priority,
      estimatedPomodoros: draft.estimatedPomodoros,
      completedPomodoros: 0,
      startAt: draft.startAt,
      dueAt: draft.dueAt,
      isCompleted: false,
      createdAt: DateTime.now(),
    );
    _tasks.add(task);
    return task;
  }

  @override
  Future<Task> update(Task task) async {
    await Future<void>.delayed(latency);
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index == -1) throw const TaskRepositoryException('La tarea ya no existe');
    _tasks[index] = task;
    return task;
  }

  List<Task> _sorted() => [..._tasks]..sort((a, b) => a.dueAt.compareTo(b.dueAt));

  static List<Task> _sampleTasks(DateTime now) {
    Task sample(
      String id,
      String title,
      TaskCategory category,
      TaskPriority priority, {
      required int estimated,
      int completed = 0,
      required Duration dueIn,
    }) {
      final dueAt = now.add(dueIn);
      return Task(
        id: id,
        title: title,
        category: category,
        priority: priority,
        estimatedPomodoros: estimated,
        completedPomodoros: completed,
        startAt: dueAt.subtract(Duration(minutes: 30 * estimated)),
        dueAt: dueAt,
        isCompleted: completed >= estimated,
        createdAt: now,
      );
    }

    return [
      sample(
        '1',
        'Terminar la tarea de ciberseguridad',
        TaskCategory.deepWork,
        TaskPriority.high,
        estimated: 3,
        completed: 2,
        dueIn: const Duration(hours: 2),
      ),
      sample(
        '2',
        'Revisar apuntes de cálculo',
        TaskCategory.study,
        TaskPriority.medium,
        estimated: 2,
        dueIn: const Duration(hours: 5),
      ),
      sample(
        '3',
        'Responder correo del profesor',
        TaskCategory.quickWin,
        TaskPriority.low,
        estimated: 1,
        completed: 1,
        dueIn: const Duration(hours: 1),
      ),
      sample(
        '4',
        'Reunión de equipo del proyecto',
        TaskCategory.meeting,
        TaskPriority.medium,
        estimated: 1,
        dueIn: const Duration(days: 1),
      ),
      sample(
        '5',
        'Ordenar el cuarto',
        TaskCategory.personal,
        TaskPriority.low,
        estimated: 1,
        dueIn: const Duration(days: 2),
      ),
    ];
  }
}
