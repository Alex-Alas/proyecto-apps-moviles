import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/feedback.dart';
import '../../../core/widgets/hamtimer_app_bar.dart';
import '../../../core/widgets/labels.dart';
import '../../../core/widgets/neo_box.dart';
import '../../../core/widgets/neo_button.dart';
import '../application/task_form_controller.dart';
import '../application/task_store.dart';
import '../domain/task.dart';
import '../domain/task_form_validator.dart';
import 'widgets/form_fields.dart';
import 'widgets/schedule_section.dart';

/// Pantalla 1 — "Nueva actividad" (formulario + POST).
///
/// Un usuario puede crear una tarea en 3 toques (escribir el objetivo, elegir
/// categoría y "Crear actividad"); el resto de campos trae valores por defecto.
class TaskFormScreen extends StatefulWidget {
  const TaskFormScreen({super.key, required this.onClose, required this.onCreated});

  /// Botón X: vuelve a la lista sin guardar.
  final VoidCallback onClose;

  /// Se llama tras un POST exitoso con la tarea ya guardada.
  final ValueChanged<Task> onCreated;

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TaskFormController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TaskFormController(onSubmit: context.read<TaskStore>().create);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final isTitleValid = _formKey.currentState?.validate() ?? false;
    final created = await _controller.submit(isTitleValid: isTitleValid);
    if (!mounted) return;
    if (created != null) {
      widget.onCreated(created);
    } else if (_controller.submitError != null) {
      AppFeedback.show(context, _controller.submitError!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        HamtimerAppBar(
          title: 'Nueva actividad',
          centerTitle: false,
          leading: AppBarIconButton(
            icon: Icons.close,
            tooltip: 'Cancelar',
            color: AppColors.onSurface,
            onPressed: widget.onClose,
          ),
          actions: [
            AppBarIconButton(
              icon: Icons.tune,
              tooltip: 'Plantillas rápidas',
              onPressed: () => AppFeedback.comingSoon(context),
            ),
          ],
        ),
        Expanded(
          child: ListenableBuilder(
            listenable: _controller,
            builder: (context, _) => Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                children: [
                  NeoBox(
                    radius: AppRadius.lg,
                    padding: const EdgeInsets.all(20),
                    child: _buildFields(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFields() {
    const gap = SizedBox(height: 24);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel('Objetivo de enfoque'),
        TitleField(
          controller: _controller.titleController,
          validator: _controller.validateTitle,
          autovalidate: _controller.submitAttempted,
        ),
        gap,
        const SectionLabel('Categoría'),
        CategorySelector(selected: _controller.category, onSelected: _controller.selectCategory),
        FieldError(_controller.categoryError),
        gap,
        const SectionLabel('Duración estimada'),
        PomodoroStepper(
          value: _controller.pomodoros,
          focusMinutes: _controller.focusMinutes,
          onIncrement: _controller.incrementPomodoros,
          onDecrement: _controller.decrementPomodoros,
          canDecrement: _controller.pomodoros > TaskFormValidator.minPomodoros,
        ),
        FieldError(_controller.pomodorosError),
        gap,
        const SectionLabel('Nivel de prioridad'),
        PrioritySelector(selected: _controller.priority, onSelected: _controller.selectPriority),
        gap,
        const SectionLabel('Horario'),
        ScheduleSection(
          startAt: _controller.startAt,
          dueAt: _controller.dueAt,
          onStartChanged: _controller.setStartAt,
          onDueChanged: _controller.setDueAt,
          error: _controller.scheduleError,
        ),
        const SizedBox(height: 28),
        PrimaryButton(
          label: 'Crear actividad',
          icon: Icons.add_task,
          loading: _controller.isSubmitting,
          onPressed: _submit,
        ),
      ],
    );
  }
}
