import 'package:flutter/foundation.dart';

import '../../../core/config/app_config.dart';
import '../../pomodoro/domain/pomodoro_progress_recorder.dart';
import '../domain/task.dart';
import '../domain/task_filter.dart';
import '../domain/task_repository.dart';
import '../domain/today_progress.dart';

/// Estado compartido de las tareas: la lista visible, su paginación, el
/// filtro activo y el progreso del día.
///
/// Las pantallas solo leen este estado y llaman a sus métodos; nunca hablan
/// con la API directamente. Cada vez que algo cambia se llama a
/// [notifyListeners] y Provider redibuja lo necesario.
class TaskStore extends ChangeNotifier implements PomodoroProgressRecorder {
  TaskStore({
    required this._repository,
    this.pageSize = AppConfig.pageSize,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final TaskRepository _repository;
  final int pageSize;
  final DateTime Function() _clock;

  List<Task> _tasks = const [];
  TaskFilter _filter = const AllTasksFilter();
  TodayProgress _todayProgress = TodayProgress.empty;
  int _nextPage = 1;
  bool _hasMore = true;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;

  /// Se incrementa en cada recarga. Si el usuario cambia de filtro mientras
  /// una petición sigue en vuelo, su respuesta llega con una generación vieja
  /// y se descarta, evitando mezclar resultados de dos filtros.
  int _generation = 0;

  List<Task> get tasks => List.unmodifiable(_tasks);
  TaskFilter get filter => _filter;
  TodayProgress get todayProgress => _todayProgress;
  bool get hasMore => _hasMore;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;

  // ---------------------------------------------------------------------------
  // GET: carga de la lista
  // ---------------------------------------------------------------------------

  /// Recarga desde cero la lista (con el filtro actual) y el banner del día.
  Future<void> refresh() async {
    final generation = ++_generation;
    _tasks = const [];
    _nextPage = 1;
    _hasMore = true;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.wait([_loadNextPage(generation), _loadTodayProgress()]);

    if (generation == _generation) {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Pide la siguiente página; lo dispara el scroll infinito al llegar al final.
  Future<void> loadMore() async {
    if (_isLoading || _isLoadingMore || !_hasMore) return;
    final generation = _generation;
    _isLoadingMore = true;
    notifyListeners();

    await _loadNextPage(generation);

    if (generation == _generation) {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> changeFilter(TaskFilter filter) async {
    if (filter == _filter) return;
    _filter = filter;
    await refresh();
  }

  Future<void> _loadNextPage(int generation) async {
    try {
      final List<Task> page;
      if (_filter.isClientSide) {
        // MockAPI no filtra por rango de fechas: se trae todo y se filtra aquí.
        // Como ya llegó la lista completa, no hay más páginas que pedir.
        final now = _clock();
        page = (await _repository.fetchAll()).where((t) => _filter.matches(t, now)).toList();
        if (generation != _generation) return;
        _hasMore = false;
      } else {
        page = await _repository.fetchPage(_filter.toQuery(page: _nextPage, limit: pageSize));
        if (generation != _generation) return;
        // Una página incompleta significa que ya no quedan más registros.
        _hasMore = page.length == pageSize;
        _nextPage++;
      }
      _tasks = [..._tasks, ...page];
    } on TaskRepositoryException catch (error) {
      if (generation != _generation) return;
      _errorMessage = error.message;
      _hasMore = false;
    }
  }

  /// El banner siempre refleja todas las tareas de hoy, sin importar el
  /// filtro ni cuántas páginas se hayan cargado.
  Future<void> _loadTodayProgress() async {
    try {
      final all = await _repository.fetchAll();
      _todayProgress = TodayProgress.fromTasks(all, _clock());
    } on TaskRepositoryException {
      // El banner es secundario: si falla, se queda con el último valor.
    }
  }

  /// Tareas pendientes que se pueden agregar a la sesión de Pomodoro.
  Future<List<Task>> fetchPendingTasks() async {
    final all = await _repository.fetchAll();
    return all.where((task) => !task.isCompleted).toList(growable: false);
  }

  // ---------------------------------------------------------------------------
  // POST: alta desde el formulario
  // ---------------------------------------------------------------------------

  /// Registra la tarea en el backend y recarga la lista para que aparezca en
  /// su posición correcta (ordenada por vencimiento).
  ///
  /// Lanza [TaskRepositoryException] si falla, para que el formulario lo muestre
  /// sin perder lo que el usuario escribió.
  Future<Task> create(TaskDraft draft) async {
    final created = await _repository.create(draft);
    await refresh();
    return created;
  }

  // ---------------------------------------------------------------------------
  // PUT: cambios de estado
  // ---------------------------------------------------------------------------

  /// Marca o desmarca una tarea como completada desde la tarjeta.
  ///
  /// Actualización optimista: la UI cambia al instante y, si el PUT falla, se
  /// revierte y se relanza el error para avisar al usuario.
  Future<void> toggleCompleted(Task task) async {
    final updated = task.copyWith(isCompleted: !task.isCompleted);
    _replace(updated);
    try {
      _replace(await _repository.update(updated));
      await _loadTodayProgress();
      notifyListeners();
    } on TaskRepositoryException {
      _replace(task);
      rethrow;
    }
  }

  @override
  Future<Task> recordCompletedPomodoro(Task task) async {
    final saved = await _repository.update(task.withCompletedPomodoro());
    _replace(saved);
    await _loadTodayProgress();
    notifyListeners();
    return saved;
  }

  /// Sustituye la tarea con el mismo `id` en la lista visible (si está).
  void _replace(Task task) {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index == -1) return;
    _tasks = [..._tasks]..[index] = task;
    notifyListeners();
  }
}
