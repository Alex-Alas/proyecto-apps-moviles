import 'package:flutter/material.dart';

import '../core/widgets/feedback.dart';
import '../features/pomodoro/presentation/pomodoro_screen.dart';
import '../features/tasks/domain/task.dart';
import '../features/tasks/presentation/task_form_screen.dart';
import '../features/tasks/presentation/tasks_screen.dart';
import 'bottom_nav_bar.dart';

/// Contenedor principal con la barra de navegación inferior.
///
/// Las tres secciones viven en un [IndexedStack]: al cambiar de pestaña no se
/// destruyen, así la lista conserva su scroll y la pantalla Pomodoro sigue
/// escuchando al temporizador para abrir sus pop-ups.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  HomeTab _tab = HomeTab.tasks;

  /// Cambia cada vez que se abre "Nueva": la `key` nueva obliga a crear un
  /// formulario limpio en lugar de mostrar el que quedó a medias.
  int _formSession = 0;

  void _selectTab(HomeTab tab) {
    setState(() {
      if (tab == HomeTab.newTask && _tab != HomeTab.newTask) _formSession++;
      _tab = tab;
    });
  }

  void _onTaskCreated(Task task) {
    _selectTab(HomeTab.tasks);
    AppFeedback.show(context, 'Actividad "${task.title}" creada');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: _tab.index,
          children: [
            const TasksScreen(),
            const PomodoroScreen(),
            TaskFormScreen(
              key: ValueKey(_formSession),
              onClose: () => _selectTab(HomeTab.tasks),
              onCreated: _onTaskCreated,
            ),
          ],
        ),
      ),
      bottomNavigationBar: HomeBottomNavBar(selected: _tab, onSelected: _selectTab),
    );
  }
}
