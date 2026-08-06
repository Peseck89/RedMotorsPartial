# Plan propuesto de baseline Git–Partial — Sprint 3

**Estado:** propuesta documental; no ejecutada.

## Principio

Partial representa el estado actual del ambiente, pero no debe sobrescribir Git en bloque. Cada retrieve debe ir a una ubicación temporal, compararse archivo por archivo y entrar al repositorio solo mediante autorización específica. La cohorte histórica de 65 componentes solo Partial permanece intacta.

## Candidatos a versionar antes de modificar

1. Layouts y FlexiPages seleccionados en la matriz V2 que figuran `NO_EXISTE` en Git.
2. Validation Rules y Approval Processes que resulten funcionalmente aplicables a PEKING.
3. Los 15 Roles únicamente si se necesita una referencia de baseline; su versionamiento no autoriza cambios de jerarquía.
4. Quick Actions nominales ausentes en Git cuando el sublote funcional correspondiente sea autorizado.
5. Custom Metadata records de configuración solo mediante formato fuente válido y sin copiar secretos ni datos no versionables.

No debe versionarse el placeholder `Mecanismo_configurable_endpoints_Softland` hasta identificar un componente API real.

## Lotes de retrieve controlado

| Orden | Lote | Alcance | Riesgo | Validación mínima |
|---:|---|---|---|---|
| 1 | B0-A | 61 Layouts y 25 FlexiPages a temporal; seleccionar solo los aprobados | Alto por asignaciones no visibles en el XML | Inventario, diff semántico, referencias padre/hijo y activaciones |
| 2 | B0-B | 94 Validation Rules de los cuatro objetos objetivo | Alto por fórmulas activas e inactivas | Fórmula, estado, campos, Record Types y regresión negativa |
| 3 | B0-C | 18 Approval Processes y 15 Roles | Alto por seguridad/aprobadores | Criterios, pasos, dependencias por rol sin identidades personales |
| 4 | B0-D | Cinco Quick Actions nominales | Medio/alto por Flows y plantillas de Sprint 2 | Acción, target, Flow invocado, parámetros y permisos |
| 5 | B0-E | Configuración del bloque 11 ya identificada nominalmente | Alto por datos/configuración | Tipo API, diff sin valores sensibles y consumidores Apex |

Cada lote debe generar manifest exacto, evidencia de retrieve temporal, lista de incluidos/excluidos y revisión humana antes de copiar archivos.

## Estrategia de diff y decisión

- Normalizar solo diferencias de formato/XML; no eliminar nodos porque no aparezcan en Git.
- Preservar Partial cuando represente una ruta funcional vigente y Git no tenga evidencia posterior.
- Preservar Git cuando exista un cambio intencional, probado y no desplegado, documentando por qué no se toma Partial.
- Marcar `CONCILIACION_MANUAL` si ambas versiones contienen comportamiento válido.
- No cambiar clasificaciones funcionales por el solo hecho de recuperar o compilar metadata.

## Reversión

Antes de incorporar cada lote se conserva el retrieve temporal y el commit anterior. La reversión propuesta es retirar únicamente el commit documental/metadata del lote aprobado y restaurar la versión previamente versionada; nunca desplegar una reversión automática ni usar operaciones Git destructivas.

## Condiciones de terminado

- todos los archivos incorporados tienen origen y evidencia;
- el diff solo contiene el lote autorizado;
- no se copian IDs, secretos, endpoints ni datos sensibles;
- validación estructural local correcta;
- matriz actualizada con `EXISTE`/`NO_COMPARABLE` o diff real;
- revisión y autorización antes de cualquier dry-run o deploy.

## Orden recomendado

Primero resolver asignaciones de Layout/FlexiPage y seleccionar el subconjunto real. Después construir baseline de reglas/procesos aplicables. El bloque Softland permanece detenido. Ningún lote funcional debe comenzar hasta aprobar el baseline específico que consume.

## Ajuste posterior S3-0.2 — 2026-08-06

La selección detallada sustituye cualquier interpretación de recuperar las 219 filas en bloque y se encuentra en `SELECCION_BASELINE_GIT_PARTIAL_SPRINT3_20260806.md`.

El primer candidato futuro queda limitado a los seis Layouts con relación nominal a Record Types Omoda/Jaecoo/PEKING. Antes de recuperar al worktree se debe confirmar que esos Record Types representan el alcance PEKING y aprobar cada nombre API. FlexiPages no entran al primer baseline: no se demostró una activación explícita Omoda/Jaecoo/PEKING. Quick Actions deben tratarse en un lote separado por sus dependencias Flow/Visualforce.

## Estado posterior S3-0.3 — 2026-08-06

La integridad del inventario se completó como análisis con limitaciones. B0-UI-1 continúa únicamente propuesto y no autorizado. Su siguiente condición es revisar las preguntas pendientes de negocio y Softland; el cierre analítico no permite retrieve al worktree, cambio funcional ni deploy.
