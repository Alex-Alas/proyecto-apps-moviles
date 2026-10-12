import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'features/pomodoro/application/pomodoro_store.dart';
import 'features/pomodoro/domain/pomodoro_phase.dart';
import 'features/tasks/application/task_store.dart';
import 'features/tasks/data/in_memory_task_repository.dart';
import 'features/tasks/data/mockapi_task_repository.dart';
import 'features/tasks/domain/task_repository.dart';

/// Punto de entrada y "raíz de composición" de la app: el único lugar donde
/// se eligen las implementaciones concretas y se conectan entre sí. El resto
/// del código solo conoce abstracciones.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es');

  final TaskRepository repository = AppConfig.useFakeApi
      ? InMemoryTaskRepository.withSampleData()
      : MockApiTaskRepository(client: http.Client());

  runApp(
    MultiProvider(
      providers: [
        // Se carga la primera página en cuanto arranca la app.
        ChangeNotifierProvider(create: (_) => TaskStore(repository: repository)..refresh()),
        // El temporizador registra su avance a través del TaskStore, que
        // implementa la interfaz PomodoroProgressRecorder.
        ChangeNotifierProvider(
          create: (context) => PomodoroStore(
            recorder: context.read<TaskStore>(),
            settings: AppConfig.fastPomodoro ? PomodoroSettings.demo : PomodoroSettings.standard,
          ),
        ),
      ],
      child: const HamtimerApp(),
    ),
  );
}
