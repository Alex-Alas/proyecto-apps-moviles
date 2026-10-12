# Diseño de referencia — Stitch

Proyecto original: <https://stitch.withgoogle.com/projects/9546024601731087296>
(acceso con la cuenta del equipo).

Pantallas exportadas: **Create Task Form**, **Tasks & Filter Screen**,
**Pomodoro Focus Timer**, **Add Task Modal Popup**, **Time Completed Modal
Popup** y **Break Reached Modal Popup**.

> Si se quiere conservar el HTML exportado, guardarlo en esta carpeta con el
> nombre de cada pantalla (p. ej. `create-task-form.html`).

## Tokens que usa la app

Los valores viven en `app/lib/core/theme/` y se tomaron tal cual del
`tailwind.config` exportado.

### Color

| Token | Hex | Uso |
|---|---|---|
| `surface` / `background` | `#E8EAF0` | Fondo de toda la app (base neomórfica) |
| `on-surface` | `#2E3040` | Texto principal |
| `on-surface-variant` | `#585A68` | Texto secundario |
| `primary` | `#6366F1` | Acciones, progreso, selección |
| `primary-container` | `#818CF8` | Botón primario deshabilitado |
| `primary-fixed` | `#E0E2FF` | Etiqueta "Activa" |
| `secondary` | `#6C6E7E` | Prioridad baja, íconos |
| `tertiary` | `#7C3AED` | Prioridad alta, vencimiento |
| `outline` / `outline-variant` | `#8A8C9A` / `#D0D2DC` | Placeholders, pistas |
| `error` | `#DC2626` | Errores de validación |

### Relieve neomórfico

| Clase CSS | Sombra | Widget |
|---|---|---|
| `neo-raised` | `6px 6px 14px rgba(0,0,0,.08), -6px -6px 14px rgba(255,255,255,.7)` | `NeoBox(style: NeoStyle.raised)` |
| `neo-raised-sm` | `3px 3px 8px …, -3px -3px 8px …` | `NeoStyle.raisedSmall` |
| `neo-inset` | `inset 4px 4px 8px …, inset -4px -4px 8px …` | `NeoStyle.inset` |
| `neo-inset-sm` | `inset 2px 2px 5px …` | `NeoStyle.insetSmall` |

### Tipografía y forma

- Fuente única: **Plus Jakarta Sans** (paquete `google_fonts`).
- Radios: `0.5rem` → 8, `1rem` → 12/16, `1.5rem` → 24, `full` → píldora.
- Íconos: Material Symbols → equivalentes de `Icons.*` de Flutter.

## Diferencias intencionales con el diseño

- Textos en **español** (el diseño está en inglés). Ver TODO de i18n en el README.
- "Action" de la barra inferior se llama **"Nueva"**.
- Las tarjetas muestran **prioridad y categoría** (el diseño mostraba solo una).
- Calendario, ajustes, sonido y plantillas muestran "Próximamente".
