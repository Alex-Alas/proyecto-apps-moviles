// Carga tareas de ejemplo en MockAPI para la demo.
//
// Uso (Node 18+):
//   node api/seed.mjs https://6acd58b8b406cb8ec0c70e50.mockapi.io
//
// Las fechas se calculan a partir de "ahora", así siempre hay tareas que
// vencen hoy (para el banner y el filtro "Hoy").

const baseUrl = (process.argv[2] ?? '').replace(/\/+$/, '');
if (!baseUrl) {
  console.error('Falta la URL base. Ejemplo: node api/seed.mjs https://<id>.mockapi.io');
  process.exit(1);
}

const HOUR = 60 * 60 * 1000;
const now = Date.now();

/** Crea una tarea que vence en `dueInHours` y empieza con margen suficiente. */
function task(title, category, priority, estimatedPomodoros, dueInHours, completedPomodoros = 0) {
  const dueAt = new Date(now + dueInHours * HOUR);
  const startAt = new Date(dueAt.getTime() - estimatedPomodoros * 30 * 60 * 1000);
  return {
    title,
    category,
    priority,
    estimatedPomodoros,
    completedPomodoros,
    startAt: startAt.toISOString(),
    dueAt: dueAt.toISOString(),
    isCompleted: completedPomodoros >= estimatedPomodoros,
    createdAt: new Date(now).toISOString(),
  };
}

const tasks = [
  task('Terminar la tarea de ciberseguridad', 'deepWork', 'high', 3, 2, 2),
  task('Responder correo del profesor', 'quickWin', 'low', 1, 1, 1),
  task('Repasar para el parcial de cálculo', 'study', 'high', 4, 6),
  task('Reunión de equipo del proyecto móvil', 'meeting', 'med', 1, 26),
  task('Leer capítulo 5 de arquitectura', 'study', 'med', 2, 30),
  task('Preparar presentación de negocios', 'deepWork', 'med', 3, 50),
  task('Pagar la mensualidad', 'quickWin', 'high', 1, 72),
  task('Salir a correr', 'personal', 'low', 1, 80),
];

for (const body of tasks) {
  const response = await fetch(`${baseUrl}/tasks`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  });
  console.log(`${response.status} ${body.title}`);
  if (!response.ok) process.exitCode = 1;
}
