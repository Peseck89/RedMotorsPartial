# Precheck obligatorio de agente

Antes de cualquier análisis que pueda terminar en una modificación:

1. Leer `README_AUTORITATIVO.md`.
2. Leer `ESTADO_ACTUAL.md`.
3. Leer `REGLAS_PRODUCCION.md`.
4. Leer `FUENTES_Y_PRECEDENCIA.md`.
5. Leer la fuente original específica de la tarea.
6. Identificar proyecto(s): Marcas Chinas, Jerarquización o compartido.
7. Confirmar org objetivo y org ID/alias. Si es Producción, declarar explícitamente modo `READ ONLY`, `VALIDATE ONLY` o `DEPLOY AUTORIZADO`.
8. Confirmar repo/worktree, rama, HEAD, `git status`, remote y divergencia.
9. Confirmar que el componente no contiene cambios fusionados del otro proyecto que se perderían.
10. Confirmar dependencias y test requerido.
11. Confirmar rollback.
12. Indicar las fuentes usadas para la decisión.

## Detención obligatoria

Detener una mutación si:

- la fuente autoritativa no está disponible;
- hay contradicción no resuelta que cambie Producción;
- el ambiente no es inequívoco;
- el diff incluye componentes no autorizados;
- se requiere un dato productivo no documentado;
- se intenta usar un ID de Partial en Producción;
- se intenta des-fusionar código compartido;
- el cambio dispara integración externa no certificada;
- el paso requiere Deploy/DML/Quick Deploy sin autorización explícita.

## Salida mínima del precheck

- tarea;
- fuentes leídas;
- ambiente;
- repo/worktree/rama/HEAD/status;
- componentes objetivo;
- dependencias;
- riesgos;
- rollback;
- acción permitida en esta ejecución.
