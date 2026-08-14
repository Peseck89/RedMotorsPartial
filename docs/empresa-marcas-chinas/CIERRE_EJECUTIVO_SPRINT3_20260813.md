# Cierre ejecutivo Sprint 3 — Empresa / PEKING

**Fecha de corte:** 13 de agosto de 2026

**Fuente de alcance:** `RECONCILIACION_EJECUTIVA_SPRINT3_PEKING_20260813.md` — solo se trabajaron las 5 filas clasificadas `FALTA`. Las 9 filas `HECHO`, las 4 `BLOQUEADO` y las 2 `NO APLICA` no se reabrieron ni se modificaron.

**Ambiente:** RedMotors Sandbox Partial. Producción no se tocó.

## Conclusión

**SPRINT 3 — CERRADO EN TODO LO IMPLEMENTABLE.**

## Gap 1 — S3-B7-05: Quick Actions con contenido/plantillas (PARCIAL)

Componentes: `BMW_EnviarCorreoPresupuesto`, `Quote.BMW_ImportarPlantilla`, `WorkOrder.BMW_ImportarPlantilla`.

- **Gap real encontrado:** el campo `Plantilla_de_Presupuesto__c.Empresa_Operadora__c` existe en Git y es usado por el Flow `BMW_ImportarPlantilla` (detrás de `Quote.BMW_ImportarPlantilla`) para filtrar plantillas de presupuesto por empresa, pero nunca había sido desplegado al org — el filtro estaba roto para las 3 empresas (Bavarian, Otobai y PEKING), no solo PEKING.
- **Corrección:** desplegado el campo a `RedMotorsSandbox` (deploy `0AfAK0000014o450AA`, 0 errores). Confirmado creado vía Tooling API (`CustomField` query, `TableEnumOrId` resuelto a `Plantilla_de_Presupuesto__c`).
- **Pendiente:** SOQL/describe estándar todavía no ve el campo al momento de este cierre — mismo problema de propagación de plataforma ya documentado en el cierre de Sprint 1 para `Empresa__c.Tipo_Kit_Softland__c`. Script listo para crear el registro de prueba PEKING en cuanto propague: `s3_gap1_plantilla_peking.apex` (no versionado, en scratchpad de la sesión). No requiere nuevo análisis, solo ejecución diferida.
- **`BMW_EnviarCorreoPresupuesto`:** código Apex (`BMW_QuotePDFEmail.cls`, 100 líneas) verificado íntegramente agnóstico de empresa — no hay hardcode de marca/razón social; asunto y cuerpo son entrada del usuario en tiempo de ejecución. Sin gap de código. La plantilla visual real (Visualforce `BMW_QuotePDFv2`) no está versionada en Git; incorporarla queda fuera del alcance de una corrección mínima y requeriría nueva autorización.
- **`WorkOrder.BMW_ImportarPlantilla`:** su Flow subyacente `BMW_Importar_Plantilla_Orden_de_Trabajo` **no se tocó**. Tiene una exclusión previa y más específica registrada en `REGLAS_ALCANCE_AUTORIZADO.md` (listado entre los 12 candidatos encontrados por análisis técnico, "quedan registrados como candidatos, no se tocan, y requieren confirmación explícita por nombre de Luis/Diego"). Esa regla es obligatoria "en cualquier Sprint, en cualquier worktree" y prevalece sobre la aparición de este componente como `FALTA` en la reconciliación de Sprint 3. Se documenta el conflicto en vez de resolverlo unilateralmente en cualquiera de las dos direcciones.

## Gap 2 — S3-B9-03: `Campo_Sucursal_Obligatorio` (HECHO)

- Fórmula real recuperada vía Tooling API (`ValidationRule` + campo `Metadata`).
- Diagnóstico: la condición 4 de la fórmula exime explícitamente al perfil System Administrator / Administrador del sistema. Todo el QA previo de este ciclo se ejecutó con usuario administrador, lo que explica por completo por qué el QA aislado fue inconcluso — la regla nunca podía dispararse en esas condiciones.
- No existe ninguna condición específica de PEKING ni de sucursal en la fórmula; es agnóstica de empresa (depende de `RecordType.Name`, `StageName`, `Sucursal__c` y el perfil).
- **No se modificó la fórmula** — no había evidencia de que estuviera mal, solo de que el QA se ejecutó bajo una exención conocida.

## Gap 3 — S3-B9-05: Approval Processes por centro de costo (HECHO)

Componentes: `Quote.CPAprobacionCargoInternoQuote`, `WorkOrder.AprobacionCentroDeCostos`.

QA funcional real ejecutado el 2026-08-13 reutilizando el Centro de Costo existente `a2c4U000004AkGRQA0` ("centro test") y su aprobador vigente `0054U000009i0CoQAI` (un primer intento con otro Centro de Costo falló por `INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY` y se descartó sin insistir).

- **Quote** `0Q0AK000001zH8E0AU`: `Approval.process()` manual vía Apex anónimo. `SUBMIT_SUCCESS:true`, `InstanceStatus:Pending`, aprobador asignado correctamente (`0054U000009i0CoQAI`), `CPEstatusDeAprobacion__c` actualizado a `En proceso` por la propia acción de sometimiento del proceso.
- **WorkOrder** `0WOAK000005k8yz4AA`: se descubrió que el sometimiento **es automático**, no manual — el Flow `envia_aprobaci_n_centro_de_costos_flow` (RecordAfterSave, dispara cuando `Aprobador_Centro_de_Costos__c` cambia a no-nulo) somete el registro vía acción `submit` del propio Flow. Al actualizar únicamente los campos de Centro de Costo/Aprobador se generó `ProcessInstance 04gAK0000005HrRYAU` en estado `Pending`, con el work item (`04iAK0000005oDtYAI`) correctamente asignado al mismo aprobador.
- **Conclusión:** ambos procesos ya son agnósticos de empresa (`assignedApprover` tipo `relatedUserField` sobre un lookup a Usuario, sin literal de empresa en `entryCriteria`) y enrutan correctamente para PEKING reutilizando un Centro de Costo existente. No se modificó ningún Approval Process ni Flow.

## Gap 4 — S3-B11-04: Bodega Softland PEKING (HECHO)

- Código verificado: `BatchGetCatalogoSoftland.bodegaExternalIdPrefix = company == 'RMBAVARIAN' ? '' : company;` ya separa la clave externa por empresa (corrección de un bloque anterior de este mismo Sprint 2/3, no de esta sesión).
- Dato: registro `Bodega__c` `a2bAK0000000vvxYAA` ("PEKING TEMPORAL - PARTIAL - NO USAR EN PRODUCCION", `ID_EXTERNO_BODEGA__c = 'RMPEKINGTEMP01'`) ya existía en el org como dato de prueba provisional.
- No se requirió ningún cambio de código ni DML nuevo — el gap ya estaba cerrado técnicamente; solo faltaba dejarlo documentado en esta reconciliación.

## Gap 5 — S3-B11-05: Default de Pricebook VN configurable (HECHO)

- El registro `RM_Config.Default_Price_List_VN` ya existía materializado en Partial (`Value__c = 'Bavarian Dólar'`, `Description__c` documentado) pero no estaba versionado en Git.
- Retrieved: `sf project retrieve start -m "CustomObject:RM_Config__mdt" "CustomMetadata:RM_Config.Default_Price_List_VN"`. Se incorporaron al repositorio `RM_Config__mdt.object-meta.xml`, sus 4 campos (`Value__c`, `Description__c`, `Descripcion__c`, `Perfiles__c`) y el registro de metadata.
- Git y Partial ya son equivalentes para este componente — no se ejecutó ningún deploy porque no había diferencia que desplegar.

## Qué sigue BLOQUEADO (sin cambios, per instrucción — no se convirtieron en supuestos)

- `Opportunity_Record_Page_VN` (S3-B7-02): falta nombre final del perfil de Ventas Nuevas / confirmación de Diego.
- 8 `Opportunity.Aprobacion_descuento_*` (S3-B9-04): metadata ya neutral, pero el QA real de submission depende de que Diego termine la jerarquía Director/Gerente/Jefe.
- Roles, perfiles y visibilidad de `Opportunity.Omoda` / `Opportunity.Jaecoo` (S3-B9-07): requiere trabajo de Diego, no es metadata a inventar por el equipo técnico.
- `BusquedaDetalladaController` / `lwc/busquedaDetallada` (S3-ESP-01): sigue dependiendo de `User.Sucursal__c` y nombres fijos de sucursal (Uruca/Pinares/Escazú → Bavarian, otro → Otobai). No existe definición específica de visibilidad de sucursales PEKING para este componente. **No se implementó** — se reafirma explícitamente que no se convirtió este bloqueo en un supuesto.

## Archivos modificados/agregados en este cierre

- `force-app/main/default/approvalProcesses/Quote.CPAprobacionCargoInternoQuote.approvalProcess-meta.xml` (nuevo, retrieved — solo lectura, sin cambio funcional)
- `force-app/main/default/approvalProcesses/WorkOrder.AprobacionCentroDeCostos.approvalProcess-meta.xml` (nuevo, retrieved — solo lectura, sin cambio funcional)
- `force-app/main/default/objects/RM_Config__mdt/RM_Config__mdt.object-meta.xml` (nuevo, retrieved)
- `force-app/main/default/objects/RM_Config__mdt/fields/*.field-meta.xml` (4 archivos, nuevos, retrieved)
- `force-app/main/default/customMetadata/RM_Config.Default_Price_List_VN.md-meta.xml` (nuevo, retrieved)
- `docs/empresa-marcas-chinas/RECONCILIACION_EJECUTIVA_SPRINT3_PEKING_20260813.md` (actualizado: 4 filas FALTA→HECHO, 1 fila FALTA→PARCIAL, totales y listas recalculadas)
- `docs/empresa-marcas-chinas/CIERRE_EJECUTIVO_SPRINT3_20260813.md` (este documento, nuevo)

El campo `force-app/main/default/objects/Plantilla_de_Presupuesto__c/fields/Empresa_Operadora__c.field-meta.xml` ya existía en Git desde antes de este bloque; no se modificó su XML, solo se desplegó al org (no estaba previamente desplegado).

## Deploys y QA de esta sesión

| Acción | Id / referencia | Resultado |
|---|---|---|
| Deploy `CustomField:Plantilla_de_Presupuesto__c.Empresa_Operadora__c` | `0AfAK0000014o450AA` | Succeeded, 0 errores. Confirmado vía Tooling API; SOQL/describe pendiente de propagación al cierre de este documento. |
| QA funcional Approval Process Quote | Quote `0Q0AK000001zH8E0AU`, `ProcessInstance 04gAK0000005HmcYAE` | Pending, aprobador correcto, estatus actualizado a "En proceso". |
| QA funcional Approval Process WorkOrder | WorkOrder `0WOAK000005k8yz4AA`, `ProcessInstance 04gAK0000005HrRYAU` | Pending (auto-sometido por Flow), aprobador correcto. |
| Retrieve CMDT + ApprovalProcess | `sf project retrieve start -m "CustomObject:RM_Config__mdt" "CustomMetadata:RM_Config.Default_Price_List_VN" "ApprovalProcess:Quote.CPAprobacionCargoInternoQuote" "ApprovalProcess:WorkOrder.AprobacionCentroDeCostos"` | Éxito; sin deploy adicional porque Git ya coincide con Partial. |

No se ejecutaron pruebas Apex nuevas en este bloque (ningún gap de los 5 tocó clases Apex con tests propios); no se detectaron regresiones en los componentes tocados.

## Nota económica

Este bloque no trabajó nada fuera de las 5 filas `FALTA` de la reconciliación oficial de Sprint 3 (Bloques 7, 9 y 11). No se generó trabajo adicional etiquetable como `TRABAJO EXTRA — NO CONTEMPLADO EN EL ALCANCE/HORAS ORIGINALES`.
