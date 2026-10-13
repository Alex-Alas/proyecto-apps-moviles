# Hamtimer 🐹⏱️

Gestor de tareas con temporizador Pomodoro para estudiantes de 15 a 28 años con
problemas de procrastinación y manejo del tiempo.
Proyecto de **Desarrollo de Aplicaciones Móviles** (ESEN, 2026), hecho en Flutter.

## Estructura del repositorio

```
app/          Aplicación Flutter (Android, iOS, web)
api/          Guía del backend en MockAPI.io + script de datos de ejemplo
docs/stitch/  Tokens y notas del diseño hecho en Stitch
```

## Entrega actual: primeras 3 pantallas

| # | Pantalla | Requisito de la actividad | Archivo principal |
|---|---|---|---|
| 1 | Nueva actividad | **Formulario** + **POST** + **validación cruzada** | `features/tasks/presentation/task_form_screen.dart` |
| 2 | Mis actividades | **GET** paginado (scroll infinito) y filtros | `features/tasks/presentation/tasks_screen.dart` |
| 3 | Temporizador Pomodoro | **PUT** al terminar cada bloque | `features/pomodoro/presentation/pomodoro_screen.dart` |

**Validaciones cruzadas** del formulario (`task_form_validator.dart`):

1. El vencimiento debe ser posterior al inicio.
2. Entre inicio y vencimiento deben caber los Pomodoros estimados
   (Pomodoros × 25 min).

## Cómo correrla

Requisitos: Flutter 3.47 o superior.

```sh
cd app
flutter pub get
flutter run                 # usa la API de MockAPI
```

Opciones de compilación (`--dart-define`):

| Variable | Efecto |
|---|---|
| `API_BASE_URL=https://…` | Cambia el backend (por defecto, el MockAPI del equipo) |
| `USE_FAKE_API=true` | Respaldo de emergencia: datos en memoria, sin red |
| `FAST_POMODORO=true` | Modo demo: bloques de 10 s y descansos de 4–8 s |

Ejemplo para presentar en clase: `flutter run --dart-define=FAST_POMODORO=true`.

Datos de ejemplo en MockAPI: `node api/seed.mjs https://6acd58b8b406cb8ec0c70e50.mockapi.io`.

Calidad:

```sh
cd app
flutter analyze
flutter test
```

## Arquitectura

Organizada **por funcionalidad** (`features/`) y, dentro de cada una, por capas:

```
lib/
├── main.dart              Raíz de composición: elige implementaciones y las conecta
├── app.dart               MaterialApp: tema, idioma
├── core/                  Lo compartido: config, tema, widgets neomórficos, utilidades
├── shell/                 Barra de navegación inferior (Tareas · Pomodoro · Nueva)
└── features/
    ├── tasks/
    │   ├── domain/        Entidades y reglas puras (Task, filtros, validaciones, contrato del repositorio)
    │   ├── data/          Implementaciones del repositorio (MockAPI y en memoria) + mapeo JSON
    │   ├── application/   Estado (TaskStore) y lógica del formulario (TaskFormController)
    │   └── presentation/  Pantallas y widgets
    └── pomodoro/
        ├── domain/        Etapas, duraciones, eventos y el contrato PomodoroProgressRecorder
        ├── application/   Motor del temporizador (PomodoroStore)
        └── presentation/  Pantalla, dial, pop-ups y hoja "Agregar a la sesión"
```

Flujo de datos: **Widget → Store (ChangeNotifier + Provider) → TaskRepository → API**.
Los widgets nunca llaman a la API; los stores nunca conocen HTTP.

Cómo se aplican los principios SOLID:

- **S (responsabilidad única):** el validador solo valida, el mapper solo
  traduce JSON, el `TaskFormController` solo maneja el formulario, los widgets
  solo pintan.
- **O (abierto/cerrado):** un filtro nuevo es otra subclase de `TaskFilter`; un
  backend nuevo es otra implementación de `TaskRepository`, sin tocar pantallas.
- **L (sustitución de Liskov):** `MockApiTaskRepository` e
  `InMemoryTaskRepository` son intercambiables (los tests usan el segundo).
- **I (segregación de interfaces):** el temporizador solo conoce
  `PomodoroProgressRecorder` (un método), no todo el `TaskStore`.
- **D (inversión de dependencias):** las dependencias se inyectan por
  constructor y solo `main.dart` decide las clases concretas.

## Internacionalización (pendiente)

> **TODO:** la app debe quedar en **inglés**. Por ahora está en español con los
> textos escritos directamente en los widgets.

La infraestructura ARB ya está preparada (`app/l10n.yaml` y
`app/lib/l10n/app_es.arb`). Para activarla:

1. En `app/pubspec.yaml`, agregar `generate: true` dentro de `flutter:`.
2. Crear `app/lib/l10n/app_en.arb` con las mismas claves traducidas.
3. Reemplazar los textos fijos de los widgets por `AppLocalizations.of(context).<clave>`
   (también las etiquetas de los enums: categorías, prioridades, filtros y etapas).
4. En `app/lib/app.dart`, usar `AppLocalizations.supportedLocales` y sus
   delegados, y poner `Locale('en')` como idioma por defecto.

## Fuera del alcance de esta entrega

Gamificación (XP, rachas, mascotas), calendario semanal, dashboard, algoritmo
de triaje y vista sin conexión. El modelo y la arquitectura están pensados para
agregarlos sin rehacer las pantallas actuales.

## Integrantes

José Alas, Jade Cárcamo, Eliezer Martínez, Nehemías Rivas, Armando Salgado y
Luz Salomón — Lic. Jaime Mejía.
