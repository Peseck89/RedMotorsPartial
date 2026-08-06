# Contexto del Proyecto — RedMotors: Inclusión escalable de nueva Empresa y marcas chinas

## Contexto operativo vigente

- Worktree actual: `C:\Users\dokur\Documents\Repositorios\RedMotors-Sprint2-Flows-Components`
- Rama actual: `feature/pc/redmotors-empresa-marcas-chinas-sprint2-flows-components-20260728`
- Último commit de línea base: `264d344`
- Org de lectura: `RedMotorsSandbox`
- Estado: Sprint 2 pausado, Sprint 3 autorizado únicamente contra el alcance original.
- Restricción: ningún bloque funcional está autorizado todavía para implementación; primero se requiere la revisión de Luis y el cierre de S3-0.

## Nombre del proyecto

RedMotors — Inclusión escalable de nueva Empresa y marcas chinas — Sprint 1.

## Objetivo general

Permitir que RedMotors incorpore de forma escalable nuevas Empresas y marcas (incluyendo marcas chinas) sin depender de la lógica binaria actual (Otobai/Bavarian) hardcodeada en Apex, Flows y configuración relacionada, de modo que agregar una Empresa nueva sea un cambio de configuración y no un cambio de código.

## Alcance del Sprint 1

Línea base y análisis inicial: creación del entorno de trabajo aislado (rama y carpeta separadas de VN-RQ106), recopilación de las fuentes documentales entregadas, e inventario de los puntos del código que hoy asumen únicamente dos Empresas (Otobai/Bavarian). No incluye cambios funcionales, retrieve de metadata ni deploys — eso corresponde a sprints posteriores una vez cerrado el análisis.

## Carpeta y rama

> Antecedente histórico de Sprint 1. No usar como ruta operativa actual.

- Carpeta (worktree): `C:\Users\dokur\Documents\Repositorios\RedMotors-Empresa-Marcas-Chinas`
- Rama: `feature/pc/redmotors-empresa-marcas-chinas-sprint1-20260724`
- Base: `origin/main`

## Org objetivo

- Alias: RedMotorsSandbox
- Org ID: 00DAK000000npFt2AI

## Restricción de separación

Este proyecto no debe mezclarse con VN-RQ106. VN-RQ106 vive en su propio worktree (`RedMotorsPartial-Sandbox`, rama `feature/pc/redmotors-vn-rq106-anticipo-ui-20260527`) y permanece intacto. No se hace merge, cherry-pick ni copia de cambios entre ambas líneas de trabajo.

## Fuentes documentales recibidas

- `DEV Evaluación - Alcance - Inclusión de nueva Empresa- Marchas chinas Redmotors.docx.pdf`
- `Manual_Analisis_Empresa_RedMotors_2026-07-22.docx`

Ambos documentos están en `docs/empresa-marcas-chinas/` de este worktree, copiados sin modificar desde el origen.

## Entregables prioritarios

- Objeto configurable para Empresas y clases de soporte, que reemplace la asunción binaria actual y permita registrar nuevas Empresas/marcas como datos de configuración.
- Revisión y refactor de Apex y triggers relacionados con Empresa, Pricebook y Softland, para que lean la configuración en lugar de tener la lógica de Empresa hardcodeada.
- Pruebas y regresión sobre los flujos afectados (Empresa, Pricebook, integración Softland) antes de tocar producción.

## Principales riesgos

- Lógica binaria Otobai/Bavarian: gran parte del código asume que solo existen estas dos Empresas.
- Empresa desconocida cayendo en Bavarian por defecto: sin una tercera opción explícita, cualquier Empresa nueva podría heredar comportamiento incorrecto de Bavarian.
- Uso de `Name` como clave: identificar Empresa por el campo `Name` es frágil ante renombres o duplicados; se necesita una clave estable.
- Pricebooks y códigos Softland hardcodeados: los identificadores de Pricebook y los códigos de integración con Softland están fijos en código, no en configuración.
- Versiones activas de Flow: los Flows relacionados con Empresa pueden tener versiones activas que ya asumen la lógica binaria; hay que mapear cuáles antes de tocarlos.
- Documentos/PDF con identidad incorrecta: la generación de documentos (PDF) puede estar mostrando la identidad/marca equivocada si la Empresa no es una de las dos originales.

## Regla de trabajo

Primero análisis e inventario completo de los puntos afectados; después cambios quirúrgicos y pruebas dirigidas. No se hacen cambios amplios ni refactors especulativos antes de tener el inventario.

## Estado actual

Línea base creada desde `origin/main`. Sin retrieve de Salesforce, sin cambios funcionales, sin metadata nueva. Único contenido nuevo en el working tree: esta carpeta de contexto y los dos documentos fuente.

## Actualización documental — 2026-08-05

La revisión TD-RQ308 confirmó diferencias entre el alcance original de PortalNet y el requerimiento posterior versión 0.13 de Red Motors. Luis aprobó en general el documento de diferencias y autorizó comenzar Sprint 3 con el alcance original, sin incorporar automáticamente ampliaciones ni inventar definiciones funcionales. Sprint 2 permanece pausado y no cerrado por cinco Flows pendientes de respuestas de negocio.

Documentos relacionados:

- [`TD-RQ308_Diferencias_Alcance_Entrega_Oficial.docx`](TD-RQ308_Diferencias_Alcance_Entrega_Oficial.docx)
- [`CONTEXTO_RQ308_Y_AUTORIZACION_SPRINT3_20260805.md`](CONTEXTO_RQ308_Y_AUTORIZACION_SPRINT3_20260805.md)
- [`MATRIZ_DECISIONES_RQ308_SPRINT2_SPRINT3_20260805.md`](MATRIZ_DECISIONES_RQ308_SPRINT2_SPRINT3_20260805.md)

## Preparación de Sprint 3 — 2026-08-05

- [Matriz preliminar de alcance de Sprint 3 — sustituida para ejecución](MATRIZ_ALCANCE_SPRINT3_PRELIMINAR_20260805.csv)
- [Plan preliminar de Sprint 3 — sustituido para ejecución](PLAN_INICIO_SPRINT3_20260805.md)
- [Lotes preliminares de Sprint 3 — sustituidos para ejecución](LOTES_PROPUESTOS_SPRINT3_20260805.md)
- [Resumen preliminar de Sprint 3 — sustituido para ejecución](RESUMEN_PREPARACION_SPRINT3_20260805.md)

## Corrección de línea base de Sprint 3 — 2026-08-05

El plan preparado anteriormente quedó sustituido para ejecución y se conserva únicamente para trazabilidad. La línea base vigente es la versión actualizada del documento de alcance, que incluye la tabla consolidada y los bloques 1 a 14.

Sprint 3 explícito contiene solo tres bloques: Layouts/FlexiPages/Quick Actions; Validation Rules/Approval Processes/roles; y Custom Metadata/integración Softland configurable. List Views, Global Value Sets, Pricebooks/PricebookEntry y E2E/regresión no tienen Sprint escrito y requieren confirmación.

Sprint 2 continúa pausado y no cerrado. Durante esta corrección no se implementó ningún cambio en Salesforce.

- [Fuente actualizada](DEV_Evaluacion_Alcance_Actualizada_20260805.docx)
- [Fuentes autoritativas](FUENTES_AUTORITATIVAS_EMPRESA_MARCAS_CHINAS.md)
- [Inconsistencias de la fuente](INCONSISTENCIAS_FUENTE_ACTUALIZADA_20260805.md)
- [Matriz corregida](MATRIZ_ALCANCE_SPRINT3_CORREGIDA_20260805.csv)
- [Plan corregido](PLAN_SPRINT3_CORREGIDO_20260805.md)
- [Lotes corregidos](LOTES_SPRINT3_CORREGIDOS_20260805.md)
- [Resumen de corrección](RESUMEN_CORRECCION_SPRINT3_20260805.md)

## Ejecución de S3-0 — 2026-08-06

Luis autorizó continuar exclusivamente con la conciliación de lectura S3-0. El inventario nominal se ejecutó sobre los bloques 7, 9 y 11, sin cambios en Salesforce y sin autorizar lotes funcionales.

- [Matriz nominal S3-0](MATRIZ_NOMINAL_S3_0_20260806.csv)
- [Resultado de conciliación](RESULTADO_S3_0_CONCILIACION_20260806.md)
- [Propuesta del primer lote funcional](PROPUESTA_PRIMER_LOTE_FUNCIONAL_SPRINT3_20260806.md)
- [Preguntas pendientes para Luis, Diego y negocio](PREGUNTAS_S3_0_LUIS_DIEGO_20260806.md)

## Auditoría documental — Etapa 3 (2026-08-05)

Se realizó una auditoría documental externa en tres etapas (inventario, revisión/clasificación,
consolidación de contexto) sobre este y los demás worktrees relacionados con RedMotors. Como
resultado de la Etapa 3, se creó un **índice maestro versionado** dentro de este repositorio:

- Índice maestro: [`auditoria/INDICE_MAESTRO_AUDITORIA.md`](auditoria/INDICE_MAESTRO_AUDITORIA.md) —
  punto único de consulta para el estado vigente de Sprint 1, Sprint 2, Sprint 3 y TD-RQ308, sin
  necesidad de abrir los inventarios completos de la auditoría externa.
- Matriz de vigencia: [`auditoria/MATRIZ_DOCUMENTOS_CLAVE_VIGENCIA.csv`](auditoria/MATRIZ_DOCUMENTOS_CLAVE_VIGENCIA.csv)
  — clasificación concisa (vigente / evidencia histórica / sustituido) de los documentos clave del
  proyecto.
- Ubicación de las auditorías externas completas (no versionadas, fuera de este repositorio):
  `C:\Users\dokur\Documents\Auditorias-RedMotors-PEKING\Etapa1-Inventario-20260805-193325\`,
  `...\Etapa2-Revision-Clasificacion-20260805-200727\` y `...\Etapa3-Consolidacion-Contexto-20260805-205625\`.

**Repositorio autoritativo confirmado:** este mismo worktree,
`RedMotors-Sprint2-Flows-Components`, rama `feature/pc/redmotors-empresa-marcas-chinas-sprint2-flows-components-20260728`.

**Estado actual de Sprint 3:** autorizado para **continuar** con el alcance del documento original de
PortalNet, por instrucción directa de Luis del 2026-08-05 (ver
`CONTEXTO_RQ308_Y_AUTORIZACION_SPRINT3_20260805.md` y `auditoria/INDICE_MAESTRO_AUDITORIA.md` sección
7.3). Las preguntas pendientes de `PLAN_SPRINT3_CORREGIDO_20260805.md` (sección 12) no deben tratarse
como bloqueo total — quedan como definiciones que pueden generar ajustes posteriores.

**Worktree roto excluido:** `RedMotors-Empresa-Marcas-Chinas` (referencia `.git` rota) permanece sin
reparar, mover ni eliminar, y sin ningún comando Git ejecutado dentro de él en las tres etapas de la
auditoría.

**Ninguna limpieza física fue ejecutada** en ninguna de las tres etapas de esta auditoría. Solo se
crearon los dos archivos de índice mencionados arriba y se hicieron ediciones conservadoras y
puntuales a `README_CONTEXTO_ACTIVO.md` y a este archivo. Ningún documento existente fue movido,
renombrado, archivado ni eliminado.
