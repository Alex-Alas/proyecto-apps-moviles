# API — MockAPI.io

Hamtimer consume un recurso REST `tasks` alojado en MockAPI.io.

- **URL base:** `https://6acd58b8b406cb8ec0c70e50.mockapi.io`
- **Recurso:** `/tasks`

## Endpoints que usa la app

| Pantalla | Método | Ruta | Uso |
|---|---|---|---|
| Mis actividades | `GET` | `/tasks?page=1&limit=10&sortBy=dueAt&order=asc` | Lista paginada (scroll infinito) |
| Mis actividades | `GET` | `/tasks?category=study` · `/tasks?isCompleted=true` | Filtros del lado del servidor |
| Mis actividades / Pomodoro | `GET` | `/tasks` | Banner del día, filtro "Hoy", hoja "Agregar a la sesión" |
| Nueva actividad | `POST` | `/tasks` | Crear tarea |
| Pomodoro / check | `PUT` | `/tasks/:id` | Sumar Pomodoro, completar tarea |

> MockAPI responde `404 Not found` cuando un filtro no tiene coincidencias; la
> app lo interpreta como lista vacía.

## Esquema del recurso `tasks`

| Campo | Tipo | Valores |
|---|---|---|
| `id` | Object ID | lo asigna MockAPI |
| `title` | String | 3–80 caracteres |
| `category` | String | `deepWork` · `quickWin` · `personal` · `study` · `meeting` |
| `priority` | String | `low` · `med` · `high` |
| `estimatedPomodoros` | Number | ≥ 1 |
| `completedPomodoros` | Number | ≥ 0 |
| `startAt` | Date | ISO-8601 (UTC) |
| `dueAt` | Date | ISO-8601 (UTC), posterior a `startAt` |
| `isCompleted` | Boolean | |
| `createdAt` | Date | ISO-8601 (UTC) |

## Paso a paso para crearlo (por si hay que rehacerlo)

1. Entrar a <https://mockapi.io> e iniciar sesión con GitHub o Google.
2. **New Project** → nombre `hamtimer` (el prefijo de API es opcional; si se
   pone uno, hay que agregarlo a `API_BASE_URL`).
3. **New resource** → nombre `tasks` y los campos de la tabla anterior.
4. Dejar **0 registros** (los datos de Faker no respetan los valores válidos).
5. Cargar datos de ejemplo:

   ```sh
   node api/seed.mjs https://6acd58b8b406cb8ec0c70e50.mockapi.io
   ```

6. Verificar abriendo `<URL base>/tasks` en el navegador.

Para apuntar la app a otro proyecto de MockAPI no hace falta tocar código:

```sh
flutter run --dart-define=API_BASE_URL=https://<otro-id>.mockapi.io
```
