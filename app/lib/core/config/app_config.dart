/// Configuración global de Hamtimer.
///
/// Todos los valores pueden sobrescribirse al compilar con `--dart-define`,
/// así no hay que tocar código para apuntar a otro backend o activar modos
/// especiales en la demo. Ejemplo:
///
/// ```sh
/// flutter run --dart-define=USE_FAKE_API=true --dart-define=FAST_POMODORO=true
/// ```
abstract final class AppConfig {
  /// URL base del backend (MockAPI.io). El recurso `/tasks` se agrega aparte.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://6acd58b8b406cb8ec0c70e50.mockapi.io',
  );

  /// Respaldo de emergencia: usa un repositorio en memoria en lugar de la API.
  /// Solo para la demo si MockAPI está caído; NO es la entrega oficial.
  static const bool useFakeApi = bool.fromEnvironment('USE_FAKE_API');

  /// Modo demo: los bloques de Pomodoro duran segundos en vez de minutos,
  /// para poder mostrar el ciclo completo en clase.
  static const bool fastPomodoro = bool.fromEnvironment('FAST_POMODORO');

  /// Tamaño de página para el scroll infinito de la lista de tareas.
  static const int pageSize = 10;

  /// Tiempo máximo de espera de cada petición HTTP.
  static const Duration requestTimeout = Duration(seconds: 15);
}
