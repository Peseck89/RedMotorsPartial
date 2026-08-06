# Índice Maestro de Auditoría — Empresa / Marcas Chinas / PEKING

Este documento es autocontenido: no depende de abrir los inventarios completos (1,329 filas) de las
auditorías externas para conocer el estado vigente del proyecto.

## 1. Fecha de actualización

2026-08-05 (Etapa 3 de la auditoría documental — consolidación de contexto e índice maestro).

## 2. Repositorio autoritativo

```
C:\Users\dokur\Documents\Repositorios\RedMotors-Sprint2-Flows-Components
```

## 3. Rama y HEAD reales al momento de esta actualización

- Rama: `feature/pc/redmotors-empresa-marcas-chinas-sprint2-flows-components-20260728`
- HEAD: `65bfa3d1dcb9e47e5c39894dc0c3939c09f3edeb` (verificado con `git rev-parse HEAD` en el momento
  de escribir este índice — **no asumido de auditorías anteriores**)

## 4. Upstream y estado de sincronización

- Upstream: `origin/feature/pc/redmotors-empresa-marcas-chinas-sprint2-flows-components-20260728`
- Estado: **0 ahead / 0 behind** (sincronizado, verificado con `git rev-list --left-right --count`)
- Repositorio limpio al momento de esta verificación: sin archivos modificados ni no rastreados.

> Este HEAD es una fotografía del momento de esta actualización. Para el estado real al momento de
> leer este documento, ejecutar `git rev-parse HEAD` y `git status -sb` — no asumir que el hash de
> arriba sigue vigente.

## 5. Regla para comenzar cualquier sesión de trabajo

1. Leer `AGENTS.md` (raíz del repositorio).
2. Leer `CLAUDE.md` (raíz del repositorio).
3. Leer `docs/empresa-marcas-chinas/REGLAS_ALCANCE_AUTORIZADO.md`.
4. Leer `docs/empresa-marcas-chinas/README_CONTEXTO_ACTIVO.md`.
5. Leer este índice maestro (`docs/empresa-marcas-chinas/auditoria/INDICE_MAESTRO_AUDITORIA.md`).

No es necesario leer recursivamente el resto de `docs/empresa-marcas-chinas/` — ver la regla de carga
de contexto en `README_CONTEXTO_ACTIVO.md` y `AGENTS.md`.

## 6. Jerarquía de fuentes autoritativas (resumen)

1. **Instrucción directa más reciente de Luis o Diego** — máxima autoridad, prevalece sobre cualquier
   texto escrito anterior cuando hay contradicción (ver sección 7.3 sobre Sprint 3).
2. `REGLAS_ALCANCE_AUTORIZADO.md` — regla de alcance y tabla-puerta de autorización.
3. `README_CONTEXTO_ACTIVO.md` — punto de entrada de contexto.
4. `DEV_Evaluacion_Alcance_Actualizada_20260805.docx` — fuente principal de alcance vigente.
5. `TD-RQ308_Diferencias_Alcance_Entrega_Oficial.docx` — documento oficial para Red Motors.
6. Matrices y planes vigentes de Sprint 2/Sprint 3 (ver tabla de la sección 8).
7. Documento original del cliente (`DEV Evaluación...docx.pdf`) y Manual de desarrollo — evidencia
   técnica de rango 2 y 3, vigente para contenido técnico no relacionado con asignación de Sprint.
8. Documentación técnica histórica de Sprint 1 (evidencia, no fuente de ejecución).
9. Borradores y preliminares sustituidos (ver tabla de la sección 9).

Detalle completo con 6 niveles en `Auditorias-RedMotors-PEKING\Etapa2-Revision-Clasificacion-20260805-200727\JERARQUIA_FUENTES_AUTORITATIVAS.md`.

## 7. Estado de Sprint 1, Sprint 2, Sprint 3 y TD-RQ308

### 7.1 Sprint 1

**Cerrado técnicamente y conservado como evidencia histórica.** El cierre 33 clases + 3 triggers está
documentado en `CIERRE_TECNICO_SPRINT1_33_CLASES_3_TRIGGERS_DRAFT.md` (ver sección 10 para su
tratamiento específico). Toda la documentación de bloques 1-21 y de reconciliación 33x3 es evidencia
histórica, no fuente para trabajo nuevo.

### 7.2 Sprint 2

**Pausado, no cerrado**, según la documentación vigente (`SPRINT2_FUENTES_AUTORITATIVAS.md`,
`CONTEXTO_RQ308_Y_AUTORIZACION_SPRINT3_20260805.md`). Cinco Flows permanecen bloqueados por
definiciones de negocio pendientes: `Work_Order_from_Quote`, `Work_Order_from_Quote_Selective`,
`SegregateWOLIs`, `aperturaCaseWorOrderEvent`, `ct_newCaseWorkOrderEvent`. El inicio de Sprint 3 **no
sustituye ni cierra** estos pendientes de Sprint 2.

### 7.3 Sprint 3

**Autorizado para continuar**, conforme a la instrucción más reciente de Luis (2026-08-05):

> "Puedes continuar con Sprint 3 con lo que tenemos del documento original. Era lo que te decía de
> que ellos dicen de momento detener, pero es mejor continuar para ganar tiempo, aunque luego cambie
> un poco la definición."

**Aplicación de esta instrucción, vigente sobre cualquier texto anterior:**

- Sprint 3 está autorizado para **continuar** trabajando con el alcance del documento original de
  PortalNet, para ganar tiempo, aunque algunas definiciones puedan ajustarse después.
- Las cinco confirmaciones que `PLAN_SPRINT3_CORREGIDO_20260805.md` (sección 12) solicita a Luis
  **no deben presentarse como un bloqueo total para iniciar** el trabajo de Sprint 3 — son puntos
  específicos que siguen abiertos, no una condición que impida todo avance.
- Las definiciones no resueltas se mantienen como **pendientes que pueden causar ajustes
  posteriores**, no como bloqueos absolutos.
- **No debe declararse que los cinco puntos de esa sección 12 quedaron respondidos** — no existe
  evidencia en el repositorio de esas cinco confirmaciones específicas. Solo existe evidencia de la
  autorización general de continuar citada arriba.
- Esta instrucción directa (2026-08-05) tiene prioridad sobre el texto de `PLAN_SPRINT3_CORREGIDO_20260805.md`
  cuando hay tensión entre "esperar las 5 confirmaciones" y "continuar para ganar tiempo" — pero
  **no se reescribió ni se borró** el texto de la sección 12 de ese plan: sigue documentando
  puntos abiertos válidos que pueden generar ajustes.
- Documentos que **sí** siguen vigentes para el contenido de Sprint 3: `LOTES_SPRINT3_CORREGIDOS_20260805.md`,
  `MATRIZ_ALCANCE_SPRINT3_CORREGIDA_20260805.csv`, `PENDIENTES_DESGLOSE_NOMINAL_S3_0_20260805.md`.
- El primer trabajo recomendado sigue siendo S3-0 (inventario y conciliación de solo lectura, sin
  modificar Salesforce), ahora entendido como autorizado a **iniciarse** bajo la instrucción de
  continuar, no como bloqueado en espera de las cinco confirmaciones.

### 7.4 TD-RQ308

`TD-RQ308_Diferencias_Alcance_Entrega_Oficial.docx` es el **documento oficial para Red Motors**,
aprobado en general por Luis el 2026-08-05 ("Sí, en general me parece bien el documento"). Pendiente
únicamente confirmar si ya se compartió con Diego y María por Drive (ver sección 12). Los extras
identificados en TD-RQ308 **no se incorporan automáticamente** a Sprint 3; requieren autorización o
control de cambios independiente.

## 8. Tabla de documentos vigentes

| Tema | Documento(s) vigente(s) |
|---|---|
| Gobierno de agentes de IA | `AGENTS.md`, `CLAUDE.md` |
| Alcance autorizado | `REGLAS_ALCANCE_AUTORIZADO.md` |
| Contexto activo | `README_CONTEXTO_ACTIVO.md` |
| Fuente principal de alcance | `DEV_Evaluacion_Alcance_Actualizada_20260805.docx` |
| Documento oficial Red Motors (RQ308) | `TD-RQ308_Diferencias_Alcance_Entrega_Oficial.docx` |
| Contexto y autorización de Sprint 3 | `CONTEXTO_RQ308_Y_AUTORIZACION_SPRINT3_20260805.md` |
| Decisiones RQ308/Sprint2/Sprint3 | `MATRIZ_DECISIONES_RQ308_SPRINT2_SPRINT3_20260805.md` |
| Plan vigente de Sprint 3 | `PLAN_SPRINT3_CORREGIDO_20260805.md`, `LOTES_SPRINT3_CORREGIDOS_20260805.md`, `MATRIZ_ALCANCE_SPRINT3_CORREGIDA_20260805.csv`, `RESUMEN_CORRECCION_SPRINT3_20260805.md`, `PENDIENTES_DESGLOSE_NOMINAL_S3_0_20260805.md` |
| Fuentes de Sprint 2 (pausado) | `SPRINT2_FUENTES_AUTORITATIVAS.md` |
| Inconsistencias de fuente | `INCONSISTENCIAS_FUENTE_ACTUALIZADA_20260805.md` |
| Índice de documentos históricos (Sprint 1) | `INDICE_DOCUMENTOS_HISTORICOS.md` (ver sección 10) |

Detalle completo con audiencia, contradicciones y evidencia en
`docs/empresa-marcas-chinas/auditoria/MATRIZ_DOCUMENTOS_CLAVE_VIGENCIA.csv`.

## 9. Tabla de documentos sustituidos y su reemplazo

| Documento sustituido | Reemplazado por |
|---|---|
| `LOTES_PROPUESTOS_SPRINT3_20260805.md` | `LOTES_SPRINT3_CORREGIDOS_20260805.md` |
| `PLAN_INICIO_SPRINT3_20260805.md` | `PLAN_SPRINT3_CORREGIDO_20260805.md` |
| `RESUMEN_PREPARACION_SPRINT3_20260805.md` | `RESUMEN_CORRECCION_SPRINT3_20260805.md` |
| `MATRIZ_ALCANCE_SPRINT3_PRELIMINAR_20260805.csv` | `MATRIZ_ALCANCE_SPRINT3_CORREGIDA_20260805.csv` |

Los cuatro se autodeclaran en su propio texto: *"ESTADO: SUSTITUIDO PARA EJECUCIÓN. Este documento
fue preparado con una versión incompleta de la línea base. Se conserva únicamente para trazabilidad y
no autoriza implementación."* **No se movieron, renombraron ni eliminaron** — siguen en su ubicación
original dentro de `docs/empresa-marcas-chinas/`, conservados por trazabilidad.

## 10. Aclaración sobre el cierre de Sprint 1 (documento DRAFT)

`CIERRE_TECNICO_SPRINT1_33_CLASES_3_TRIGGERS_DRAFT.md` es **evidencia histórica y el mejor registro
disponible** del cierre 33 clases + 3 triggers de Sprint 1 (la clase 33 sigue pendiente de
confirmación de Luis). **No es una fuente vigente para ejecutar Sprint 3** — Sprint 3 tiene su propia
línea base vigente (sección 8). No se clasifica como "sustituido" porque no existe ningún documento
que lo reemplace como registro de cierre de Sprint 1; simplemente no debe usarse como base de trabajo
de Sprint 3.

## 11. Ubicaciones exactas de las auditorías externas

| Etapa | Ruta |
|---|---|
| Etapa 1 — Inventario | `C:\Users\dokur\Documents\Auditorias-RedMotors-PEKING\Etapa1-Inventario-20260805-193325\` |
| Etapa 2 — Revisión y clasificación | `C:\Users\dokur\Documents\Auditorias-RedMotors-PEKING\Etapa2-Revision-Clasificacion-20260805-200727\` |
| Etapa 3 — Consolidación de contexto (esta) | `C:\Users\dokur\Documents\Auditorias-RedMotors-PEKING\Etapa3-Consolidacion-Contexto-20260805-205625\` |

Cada carpeta contiene su propio ZIP con todos los entregables. Ver sección 13 sobre el uso correcto
de estas auditorías externas.

## 12. Estados pendientes (no resueltos por este índice, requieren decisión o acción del usuario)

1. **Worktree roto** — `C:\Users\dokur\Documents\Repositorios\RedMotors-Empresa-Marcas-Chinas`.
   Referencia `.git` rota (apunta a una ruta de otro entorno/sesión inexistente en este equipo). No
   reparado, movido, renombrado ni eliminado. Ningún comando Git se ejecuta dentro de él.
2. **Cambio sin commit en `RedMotorsPartial-Sandbox`** —
   `force-app/main/default/lwc/jsconfig.json` modificado (1 línea) en la rama VN-RQ106
   (`feature/pc/redmotors-vn-rq106-anticipo-ui-20260527`), no relacionado con PEKING. Preservado sin
   tocar; corresponde al responsable de VN-RQ106 decidir.
3. **Archivo no rastreado en `RedMotors-Sprint1-Next8-Reconcile`** —
   `docs/empresa-marcas-chinas/CIERRE_TECNICO_SPRINT1_33_CLASES_3_TRIGGERS_DRAFT.md` (copia suelta
   desactualizada). El único commit "único" de ese worktree (`15c7033`) tiene patch-id idéntico al
   commit `c320138` ya incorporado al autoritativo — no es trabajo perdido.
4. **Documentos generales no específicos de PEKING** dentro de este repositorio: `ACTIVE_ASSIGNMENT.md`
   (documenta VN-RQ106, no PEKING), `AI_HANDOFF.md`, `WORK_LOG.md`, `WEEKLY_REPORT_LOG.md` — vigencia
   y alcance no confirmados en esta auditoría; fuera de su foco específico.
5. **Confirmación de envío de documentos externos** — no hay evidencia en el repositorio de que
   `TD-RQ308_Diferencias_Alcance_Entrega_Oficial.docx` ya se haya compartido con Diego y María por
   Drive, ni de que `MENSAJE_LUIS_REVISION_PLAN_SPRINT3_20260805.md` se haya enviado y respondido.

## 13. Regla: no usar las auditorías externas como sustituto de las fuentes versionadas

Las carpetas de `Auditorias-RedMotors-PEKING\` (Etapa 1, 2 y 3) son **evidencia de auditoría de un
momento específico**, generadas fuera de este repositorio y no versionadas por Git. Este índice
maestro (`INDICE_MAESTRO_AUDITORIA.md`) y la matriz de vigencia
(`MATRIZ_DOCUMENTOS_CLAVE_VIGENCIA.csv`) son las referencias vigentes y versionadas: si hay una
diferencia entre lo que dice una auditoría externa y lo que dice este índice, **este índice
prevalece** para trabajo nuevo, porque se actualiza junto con el repositorio. Las auditorías externas
siguen siendo la fuente del detalle completo (archivo por archivo) cuando se necesite justificar una
clasificación con evidencia extensa.

## 14. Procedimiento para mantener este índice actualizado

1. Cualquier cambio de vigencia de un documento (nuevo documento oficial, nueva sustitución, cierre
   de Sprint, nueva autorización de Luis/Diego) debe reflejarse aquí y en
   `MATRIZ_DOCUMENTOS_CLAVE_VIGENCIA.csv` en el mismo commit que introduce el cambio, cuando sea
   posible.
2. Antes de editar, releer el archivo actual (no asumir su contenido de memoria) y verificar rama/HEAD
   reales con `git status -sb` y `git rev-parse HEAD`.
3. Actualizar la sección 1 (fecha), y las secciones afectadas (7, 8, 9, 12 típicamente).
4. Agregar una entrada nueva en el historial de cambios (sección 15) con fecha, autor/agente y
   resumen del cambio.
5. No reescribir ni eliminar documentos históricos o sustituidos para "simplificar" — su valor es
   precisamente preservar el estado anterior con trazabilidad.
6. Cualquier reorganización física de documentos (mover, archivar, renombrar) requiere una etapa de
   auditoría separada y explícitamente autorizada — este índice no autoriza esas acciones por sí
   mismo.

## 15. Historial de cambios de este índice

| Fecha | Cambio |
|---|---|
| 2026-08-05 | Creación inicial del índice maestro, como parte de la Etapa 3 de la auditoría documental (consolidación de contexto). Basado en las Etapas 1 y 2 de la auditoría externa, con corrección de las cifras del repositorio autoritativo (ver `CORRECCIONES_VALIDACION_ETAPA2.md` en la carpeta de Etapa 3) y documentación de la instrucción más reciente de Luis sobre continuidad de Sprint 3. |
