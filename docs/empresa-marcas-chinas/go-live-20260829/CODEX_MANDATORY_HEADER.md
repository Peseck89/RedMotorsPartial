# Encabezado obligatorio para prompts Codex del go-live

Antes de ejecutar esta tarea:

1. Lee `docs/empresa-marcas-chinas/go-live-20260829/README_AUTORITATIVO.md`.
2. Ejecuta `AGENT_PRECHECK.md`.
3. Lee la fuente original indicada para esta tarea.
4. No uses memoria de conversación como única fuente.
5. Si tu conclusión contradice una fuente oficial o el estado live, explica la contradicción antes de modificar nada.
6. Si la tarea toca Producción, respeta `REGLAS_PRODUCCION.md` y no ejecutes Deploy/DML/Quick Deploy salvo autorización explícita para esa acción concreta.

Todos los prompts Codex deben terminar exactamente con:

`Notificación ntfy al tema redmotors-claude-7f92c81a6d una sola vez al finalizar; si falla, máximo un reintento.`
