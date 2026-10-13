# Textos (ARB)

`app_es.arb` contiene los textos base en español. Todavía **no** se usa en los
widgets (ver la sección "Internacionalización" del README del proyecto).
Al migrar, cada texto fijo de la UI se reemplaza por su clave, p. ej.
`'Mis actividades'` → `AppLocalizations.of(context).tasksTitle`.
