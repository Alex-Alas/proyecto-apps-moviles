import 'package:flutter/widgets.dart';

import '../../../core/domain/pomodoro_durations.dart';
import '../../../core/utils/date_utils.dart';
import '../domain/task.dart';
import '../domain/task_category.dart';
import '../domain/task_form_validator.dart';
import '../domain/task_priority.dart';
import '../domain/task_repository.dart';

/// Estado y comportamiento del formulario "Nueva actividad".
///
/// Separa la lógica (valores, validación, envío) de los widgets, que solo
/// pintan lo que este controlador expone. La persistencia se delega a
/// [onSubmit], de modo que el formulario no sabe si guarda en MockAPI, en
/// memoria o en otro backend.
class TaskFormController extends ChangeNotifier {
  TaskFormController({required this.onSubmit, DateTime? now}) {
    // Valores iniciales pensados para crear una tarea en pocos toques: empieza
    // en la próxima hora en punto y vence una hora después (alcanza para los
    // 2 Pomodoros por defecto).
    final base = now ?? DateTime.now();
    _startAt = base.withTime(base.hour, 0).add(const Duration(hours: 1));
    _dueAt = _startAt.add(const Duration(hours: 1));
  }

  final Future<Task> Function(TaskDraft draft) onSubmit;

  final TextEditingController titleController = TextEditingController();

  TaskCategory? _category;
  TaskPriority _priority = TaskPriority.defaultValue;
  int _pomodoros = 2;
  late DateTime _startAt;
  late DateTime _dueAt;
  bool _submitAttempted = false;
  bool _isSubmitting = false;
  String? _submitError;

  TaskCategory? get category => _category;
  TaskPriority get priority => _priority;
  int get pomodoros => _pomodoros;
  DateTime get startAt => _startAt;
  DateTime get dueAt => _dueAt;
  bool get isSubmitting => _isSubmitting;
  String? get submitError => _submitError;

  /// Tras el primer intento de envío, los errores se muestran en vivo.
  bool get submitAttempted => _submitAttempted;

  /// Minutos de enfoque que suma la estimación, para el texto del stepper.
  int get focusMinutes => PomodoroDurations.focusTimeFor(_pomodoros).inMinutes;

  // --- Errores por campo -----------------------------------------------------

  String? get categoryError => _submitAttempted ? TaskFormValidator.category(_category) : null;

  String? get pomodorosError => TaskFormValidator.pomodoros(_pomodoros);

  /// La validación cruzada del horario se muestra siempre (no espera al envío)
  /// porque es el error más fácil de cometer al mover fechas.
  String? get scheduleError =>
      TaskFormValidator.schedule(startAt: _startAt, dueAt: _dueAt, estimatedPomodoros: _pomodoros);

  String? validateTitle(String? value) => TaskFormValidator.title(value);

  // --- Cambios de valores ----------------------------------------------------

  void selectCategory(TaskCategory value) => _update(() => _category = value);

  void selectPriority(TaskPriority value) => _update(() => _priority = value);

  void incrementPomodoros() => _update(() => _pomodoros++);

  void decrementPomodoros() {
    if (_pomodoros <= TaskFormValidator.minPomodoros) return;
    _update(() => _pomodoros--);
  }

  void setStartAt(DateTime value) => _update(() => _startAt = value);

  void setDueAt(DateTime value) => _update(() => _dueAt = value);

  // --- Envío (POST) ----------------------------------------------------------

  /// Valida todo el formulario y, si es válido, envía la tarea.
  ///
  /// [isTitleValid] viene del `Form` de Flutter (que valida el `TextFormField`)
  /// y aquí se combina con las validaciones que no son de un solo campo.
  /// Devuelve la tarea creada o `null` si algo no pasó.
  Future<Task?> submit({required bool isTitleValid}) async {
    _update(() {
      _submitAttempted = true;
      _submitError = null;
    });

    final isValid =
        isTitleValid && categoryError == null && pomodorosError == null && scheduleError == null;
    if (!isValid || _isSubmitting) return null;

    _update(() => _isSubmitting = true);
    try {
      return await onSubmit(
        TaskDraft(
          title: titleController.text.trim(),
          category: _category!,
          priority: _priority,
          estimatedPomodoros: _pomodoros,
          startAt: _startAt,
          dueAt: _dueAt,
        ),
      );
    } on TaskRepositoryException catch (error) {
      _update(() => _submitError = error.message);
      return null;
    } finally {
      _update(() => _isSubmitting = false);
    }
  }

  void _update(VoidCallback change) {
    change();
    notifyListeners();
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }
}
