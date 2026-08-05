# Contexto del Proyecto — RedMotors: Inclusión escalable de nueva Empresa y marcas chinas

## Nombre del proyecto

RedMotors — Inclusión escalable de nueva Empresa y marcas chinas — Sprint 1.

## Objetivo general

Permitir que RedMotors incorpore de forma escalable nuevas Empresas y marcas (incluyendo marcas chinas) sin depender de la lógica binaria actual (Otobai/Bavarian) hardcodeada en Apex, Flows y configuración relacionada, de modo que agregar una Empresa nueva sea un cambio de configuración y no un cambio de código.

## Alcance del Sprint 1

Línea base y análisis inicial: creación del entorno de trabajo aislado (rama y carpeta separadas de VN-RQ106), recopilación de las fuentes documentales entregadas, e inventario de los puntos del código que hoy asumen únicamente dos Empresas (Otobai/Bavarian). No incluye cambios funcionales, retrieve de metadata ni deploys — eso corresponde a sprints posteriores una vez cerrado el análisis.

## Carpeta y rama

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
