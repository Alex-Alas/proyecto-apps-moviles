import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/app_config.dart';
import '../domain/task.dart';
import '../domain/task_repository.dart';
import 'task_json_mapper.dart';

/// Implementación de [TaskRepository] sobre la API REST de MockAPI.io.
///
/// Endpoints usados:
/// - `GET  /tasks?page=&limit=&category=&isCompleted=` → lista de tareas
/// - `POST /tasks`                                      → formulario
/// - `PUT  /tasks/:id`                                  → Pomodoro y check
class MockApiTaskRepository implements TaskRepository {
  MockApiTaskRepository({required this._client, String baseUrl = AppConfig.apiBaseUrl})
    : _tasksUri = Uri.parse('$baseUrl/tasks');

  final http.Client _client;
  final Uri _tasksUri;

  static const _notFound = 404;
  static const _jsonHeaders = {'Content-Type': 'application/json'};

  @override
  Future<List<Task>> fetchPage(TaskQuery query) {
    final uri = _tasksUri.replace(
      queryParameters: {
        'page': '${query.page}',
        'limit': '${query.limit}',
        // Las más próximas a vencer primero: lo urgente queda arriba.
        'sortBy': 'dueAt',
        'order': 'asc',
        if (query.category != null) 'category': query.category!.apiValue,
        if (query.isCompleted != null) 'isCompleted': '${query.isCompleted}',
      },
    );
    return _getList(uri);
  }

  @override
  Future<List<Task>> fetchAll() =>
      _getList(_tasksUri.replace(queryParameters: {'sortBy': 'dueAt', 'order': 'asc'}));

  @override
  Future<Task> create(TaskDraft draft) async {
    final response = await _send(
      () => _client.post(
        _tasksUri,
        headers: _jsonHeaders,
        body: jsonEncode(TaskJsonMapper.draftToJson(draft)),
      ),
    );
    return TaskJsonMapper.fromJson(_decodeObject(response));
  }

  @override
  Future<Task> update(Task task) async {
    final response = await _send(
      () => _client.put(
        _tasksUri.replace(path: '${_tasksUri.path}/${task.id}'),
        headers: _jsonHeaders,
        body: jsonEncode(TaskJsonMapper.toJson(task)),
      ),
    );
    return TaskJsonMapper.fromJson(_decodeObject(response));
  }

  Future<List<Task>> _getList(Uri uri) async {
    final response = await _send(() => _client.get(uri), allowNotFound: true);

    // Particularidad de MockAPI: cuando un filtro no tiene coincidencias
    // responde 404 "Not found" en lugar de una lista vacía.
    if (response.statusCode == _notFound) return const [];

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw const TaskRepositoryException('Respuesta inesperada del servidor');
    }
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(TaskJsonMapper.fromJson)
        .toList(growable: false);
  }

  /// Ejecuta la petición y convierte cualquier falla de red o de estado HTTP
  /// en un [TaskRepositoryException] con un mensaje entendible.
  Future<http.Response> _send(
    Future<http.Response> Function() request, {
    bool allowNotFound = false,
  }) async {
    final http.Response response;
    try {
      response = await request().timeout(AppConfig.requestTimeout);
    } on TimeoutException {
      throw const TaskRepositoryException('El servidor tardó demasiado en responder');
    } on Exception {
      throw const TaskRepositoryException('Sin conexión con el servidor');
    }

    final ok = response.statusCode >= 200 && response.statusCode < 300;
    final tolerated = allowNotFound && response.statusCode == _notFound;
    if (!ok && !tolerated) {
      throw TaskRepositoryException('Error del servidor (${response.statusCode})');
    }
    return response;
  }

  Map<String, dynamic> _decodeObject(http.Response response) {
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const TaskRepositoryException('Respuesta inesperada del servidor');
    }
    return decoded;
  }
}
