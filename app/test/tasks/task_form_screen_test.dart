import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamtimer/features/tasks/application/task_store.dart';
import 'package:hamtimer/features/tasks/data/in_memory_task_repository.dart';
import 'package:hamtimer/features/tasks/domain/task.dart';
import 'package:hamtimer/features/tasks/presentation/task_form_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

void main() {
  setUpAll(() => initializeDateFormatting('es'));

  Future<List<Task>> pumpForm(WidgetTester tester) async {
    final created = <Task>[];
    final store = TaskStore(repository: InMemoryTaskRepository(latency: Duration.zero));
    // Pantalla alta para que todo el formulario quepa sin hacer scroll.
    tester.view.physicalSize = const Size(1080, 3200);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: store,
        child: MaterialApp(
          home: Scaffold(
            body: TaskFormScreen(onClose: () {}, onCreated: created.add),
          ),
        ),
      ),
    );
    return created;
  }

  testWidgets('muestra errores al enviar vacío', (tester) async {
    await pumpForm(tester);

    await tester.tap(find.text('Crear actividad'));
    await tester.pumpAndSettle();

    expect(find.text('Escribe el objetivo de la actividad'), findsOneWidget);
    expect(find.text('Elige una categoría'), findsOneWidget);
  });

  testWidgets('la validación cruzada bloquea un horario insuficiente y luego permite crear', (
    tester,
  ) async {
    final created = await pumpForm(tester);

    await tester.enterText(find.byType(TextField), 'Terminar la tarea de ciberseguridad');
    await tester.tap(find.text('Estudio'));
    // Por defecto hay 60 min y 2 Pomodoros; con 3 (75 min) ya no alcanza.
    await tester.tap(find.bySemanticsLabel('Agregar un Pomodoro'));
    await tester.pump();

    expect(find.textContaining('No alcanza el tiempo'), findsOneWidget);

    await tester.tap(find.text('Crear actividad'));
    await tester.pumpAndSettle();
    expect(created, isEmpty);

    await tester.tap(find.bySemanticsLabel('Quitar un Pomodoro'));
    await tester.pump();
    expect(find.textContaining('No alcanza el tiempo'), findsNothing);

    await tester.tap(find.text('Crear actividad'));
    await tester.pumpAndSettle();

    expect(created.single.title, 'Terminar la tarea de ciberseguridad');
    expect(created.single.estimatedPomodoros, 2);
  });
}
