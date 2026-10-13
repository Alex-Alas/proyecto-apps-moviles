import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/neo_box.dart';
import '../../../../core/widgets/neo_button.dart';
import '../../domain/task_category.dart';
import '../../domain/task_priority.dart';

/// Texto rojo pequeño debajo de un campo con error.
class FieldError extends StatelessWidget {
  const FieldError(this.message, {super.key});

  final String? message;

  @override
  Widget build(BuildContext context) {
    if (message == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, size: 14, color: AppColors.error),
          const SizedBox(width: 4),
          Expanded(
            child: Text(message!, style: const TextStyle(fontSize: 12, color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

/// Campo "Objetivo de enfoque": un `TextFormField` dentro de una cavidad
/// neomórfica. Su validación la ejecuta el `Form` que lo contiene.
class TitleField extends StatelessWidget {
  const TitleField({
    super.key,
    required this.controller,
    required this.validator,
    required this.autovalidate,
  });

  final TextEditingController controller;
  final FormFieldValidator<String> validator;
  final bool autovalidate;

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      // Se usa FormField para poder dibujar el error FUERA de la cavidad,
      // conservando la forma del diseño.
      initialValue: controller.text,
      validator: (_) => validator(controller.text),
      autovalidateMode: autovalidate ? AutovalidateMode.always : AutovalidateMode.disabled,
      builder: (field) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NeoBox(
            style: NeoStyle.inset,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                const Icon(Icons.edit_note, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: controller,
                    onChanged: field.didChange,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.done,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    decoration: const InputDecoration(
                      hintText: '¿En qué necesitas enfocarte?',
                      hintStyle: TextStyle(color: AppColors.outline),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          FieldError(field.errorText),
        ],
      ),
    );
  }
}

/// Chips de categoría; la seleccionada se rellena de índigo.
class CategorySelector extends StatelessWidget {
  const CategorySelector({super.key, required this.selected, required this.onSelected});

  final TaskCategory? selected;
  final ValueChanged<TaskCategory> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final category in TaskCategory.values)
          _CategoryChip(
            category: category,
            isSelected: category == selected,
            onTap: () => onSelected(category),
          ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.category, required this.isSelected, required this.onTap});

  final TaskCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(category.icon, size: 16, color: isSelected ? AppColors.onPrimary : AppColors.outline),
        const SizedBox(width: 6),
        Text(
          category.label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? AppColors.onPrimary : AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );

    if (!isSelected) {
      return NeoButton(
        onPressed: onTap,
        small: true,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        semanticLabel: category.label,
        child: content,
      );
    }

    return Semantics(
      selected: true,
      button: true,
      label: category.label,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppRadius.md),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: content,
        ),
      ),
    );
  }
}

/// "Duración estimada": contador de Pomodoros con botones − / +.
class PomodoroStepper extends StatelessWidget {
  const PomodoroStepper({
    super.key,
    required this.value,
    required this.focusMinutes,
    required this.onIncrement,
    required this.onDecrement,
    required this.canDecrement,
  });

  final int value;
  final int focusMinutes;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final bool canDecrement;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return NeoBox(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const NeoBox(
            style: NeoStyle.insetSmall,
            width: 40,
            height: 40,
            child: Icon(Icons.timer_outlined, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$value ${value == 1 ? 'Pomodoro' : 'Pomodoros'}',
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  '$focusMinutes min de enfoque',
                  style: textTheme.labelSmall?.copyWith(color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          _StepButton(
            icon: Icons.remove,
            label: 'Quitar un Pomodoro',
            onPressed: canDecrement ? onDecrement : null,
          ),
          SizedBox(
            width: 28,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary),
            ),
          ),
          _StepButton(icon: Icons.add, label: 'Agregar un Pomodoro', onPressed: onIncrement),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.label, required this.onPressed});

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return NeoButton(
      onPressed: onPressed,
      small: true,
      width: 32,
      height: 32,
      radius: AppRadius.sm,
      padding: EdgeInsets.zero,
      semanticLabel: label,
      child: Icon(icon, size: 16, color: AppColors.onSurfaceVariant),
    );
  }
}

/// Selector segmentado de prioridad (Baja / Media / Alta).
class PrioritySelector extends StatelessWidget {
  const PrioritySelector({super.key, required this.selected, required this.onSelected});

  final TaskPriority selected;
  final ValueChanged<TaskPriority> onSelected;

  @override
  Widget build(BuildContext context) {
    return NeoBox(
      style: NeoStyle.inset,
      padding: const EdgeInsets.all(6),
      child: Row(
        children: [
          for (final priority in TaskPriority.values)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: _PrioritySegment(
                  priority: priority,
                  isSelected: priority == selected,
                  onTap: () => onSelected(priority),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PrioritySegment extends StatelessWidget {
  const _PrioritySegment({required this.priority, required this.isSelected, required this.onTap});

  final TaskPriority priority;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = Text(
      priority.label,
      style: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
      ),
    );

    return Semantics(
      button: true,
      selected: isSelected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: isSelected
            ? NeoBox(
                radius: AppRadius.sm,
                padding: const EdgeInsets.symmetric(vertical: 9),
                child: Center(child: label),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: 9),
                child: Center(child: label),
              ),
      ),
    );
  }
}
