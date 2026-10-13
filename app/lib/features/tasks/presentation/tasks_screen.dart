import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_labels.dart';
import '../../../core/widgets/feedback.dart';
import '../../../core/widgets/hamtimer_app_bar.dart';
import '../../../core/widgets/neo_button.dart';
import '../application/task_store.dart';
import '../domain/task.dart';
import '../domain/task_repository.dart';
import 'widgets/daily_progress_banner.dart';
import 'widgets/task_card.dart';
import 'widgets/task_filter_bar.dart';

/// Pantalla 2 — "Mis actividades" (GET).
///
/// Muestra el avance del día, los filtros y la lista de tareas con scroll
/// infinito: al acercarse al final se pide la siguiente página a la API.
class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  /// Distancia (px) al final de la lista a la que se pide la siguiente página.
  static const double _loadMoreThreshold = 300;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - _loadMoreThreshold) {
      context.read<TaskStore>().loadMore();
    }
  }

  Future<void> _toggleCompleted(Task task) async {
    try {
      await context.read<TaskStore>().toggleCompleted(task);
    } on TaskRepositoryException catch (error) {
      if (mounted) AppFeedback.show(context, error.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<TaskStore>();
    final now = DateTime.now();

    return Column(
      children: [
        HamtimerAppBar(
          title: 'Hamtimer',
          subtitle: DateLabels.todayHeader(now),
          leading: AppBarIconButton(
            icon: Icons.calendar_today_outlined,
            tooltip: 'Calendario',
            color: AppColors.primary,
            onPressed: () => AppFeedback.comingSoon(context),
          ),
          actions: [
            AppBarIconButton(
              icon: Icons.tune,
              tooltip: 'Preferencias',
              onPressed: () => AppFeedback.comingSoon(context),
            ),
          ],
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: store.refresh,
            child: CustomScrollView(
              controller: _scrollController,
              // Siempre desplazable, para que "jalar para recargar" funcione
              // aunque la lista sea corta.
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                const SliverToBoxAdapter(child: _ScreenHeader()),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                  sliver: SliverToBoxAdapter(
                    child: DailyProgressBanner(progress: store.todayProgress),
                  ),
                ),
                SliverToBoxAdapter(
                  child: TaskFilterBar(selected: store.filter, onSelected: store.changeFilter),
                ),
                ..._buildListSlivers(store, now),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Decide qué mostrar según el estado de la carga: cargando, error, vacío o
  /// la lista (con un indicador al final mientras llega la siguiente página).
  List<Widget> _buildListSlivers(TaskStore store, DateTime now) {
    if (store.isLoading && store.tasks.isEmpty) {
      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }

    if (store.errorMessage != null && store.tasks.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: _MessageState(
            icon: Icons.cloud_off_outlined,
            message: store.errorMessage!,
            actionLabel: 'Reintentar',
            onAction: store.refresh,
          ),
        ),
      ];
    }

    if (store.tasks.isEmpty) {
      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: _MessageState(
            icon: Icons.inbox_outlined,
            message: 'No hay actividades aquí todavía.\nCrea una con el botón "Nueva".',
          ),
        ),
      ];
    }

    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
        sliver: SliverList.separated(
          itemCount: store.tasks.length,
          separatorBuilder: (_, _) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            final task = store.tasks[index];
            return TaskCard(
              key: ValueKey(task.id),
              task: task,
              now: now,
              onToggleCompleted: () => _toggleCompleted(task),
            );
          },
        ),
      ),
      if (store.isLoadingMore)
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
    ];
  }
}

class _ScreenHeader extends StatelessWidget {
  const _ScreenHeader();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mis actividades',
            style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          Text(
            'Tu plan de enfoque, ordenado por vencimiento',
            style: textTheme.labelMedium?.copyWith(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

/// Estado vacío o de error, con una acción opcional.
class _MessageState extends StatelessWidget {
  const _MessageState({required this.icon, required this.message, this.actionLabel, this.onAction});

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: AppColors.outline),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.onSurfaceVariant),
          ),
          if (actionLabel != null) ...[
            const SizedBox(height: 16),
            NeoButton(
              onPressed: onAction,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                actionLabel!,
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
