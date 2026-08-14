# RedMotors / PEKING - Reconciliacion ejecutiva Sprint 3

Fecha: 2026-08-13

Rama base objetivo: `feature/pc/redmotors-empresa-marcas-chinas-sprint3-continuidad-20260813`

Rama documental objetivo: `feature/luis/peking-sprint3-reconciliacion-20260813`

Alcance de esta reconciliacion: solo clasificar actividades oficiales de Sprint 3 como `HECHO`, `FALTA`, `BLOQUEADO` o `NO APLICA`. No se implemento, no se hizo deploy, no se hizo DML, no se consulto Produccion y no se reabrio Sprint 2.

## Criterio aplicado

Fuente oficial de Sprint 3 segun la decision vigente de Luis:

- Bloque 7: Layouts, FlexiPages y Quick Actions.
- Bloque 9: Validation Rules, Approval Processes y roles nuevos.
- Bloque 11: Custom Metadata e integracion Softland.

No se incluyen como Sprint 3 los bloques 8, 10 amplio, 12, 13 ni 14. Tampoco se convierten hallazgos tecnicos externos en alcance Sprint 3 si no corresponden a los bloques 7, 9 u 11.

Decisiones recientes de Luis aplicadas como resueltas, no como bloqueo: bodega provisional de prueba, territorio provisional de prueba, centro de costo reutilizado, aprobadores por logica actual de centro de costo, Pricebook default de prueba, branding/razon social de prueba y garantia N3 sin cambio tecnico.

## Matriz ejecutiva

| ID | Actividad oficial | Componentes | Estado | Evidencia | Gap exacto | Siguiente accion |
|---|---|---|---|---|---|---|
| S3-B7-01 | Layouts Opportunity para Omoda/Jaecoo con equivalencia de Ventas Nuevas | `Opportunity-Autos V1.3`, `Opportunity-Autos V1.3 - Inventario`, `Opportunity-Autos V1.4`, `Opportunity-Autos V1.4 Sin Botones`, `Opportunity-Opportunity Layout`, `Opportunity-Vehiculos Nuevos V1.1` | HECHO | `CIERRE_TRABAJO_INTERNO_SPRINT3_20260807.md:28`; `EVIDENCIAS_NEGOCIO_SPRINT3_20260810.md:281-289` | Ninguno de metadata; ya esta reconciliado como sin cambio con regresion/evidencia visual. | No volver a duplicar layouts. Mantenerlos como base VN y solo usar evidencia de regresion. |
| S3-B7-02 | Activacion/asignacion de `Opportunity_Record_Page_VN` para Omoda/Jaecoo | `Opportunity_Record_Page_VN` | BLOQUEADO | `RESULTADO_B7_1_RECONCILIACION_VENTAS_NUEVAS_20260810.md:92-118`; `CIERRE_TRABAJO_INTERNO_SPRINT3_20260807.md:31` | Falta nombre final del perfil de Ventas Nuevas / confirmacion de renombre de perfiles y decision de asignacion `APP_PROFILE_RECORDTYPE`. | Esperar confirmacion de Diego sobre perfil final; despues agregar solo las asignaciones necesarias si sigue aplicando. |
| S3-B7-03 | Quote Record Page VN y comportamiento de Vehiculo Nuevo para Omoda/Jaecoo | `Quote_Record_Page_VN`, `Opportunity.Flag_Vehiculo_Nuevo_FM__c`, espejo `Quote.Flag_Vehiculo_Nuevo_FM__c` | HECHO | `RESULTADO_B7_1_RECONCILIACION_VENTAS_NUEVAS_20260810.md:186-291`; `EVIDENCIAS_NEGOCIO_SPRINT3_20260810.md:275-289` | Ninguno; el ajuste de `Flag_Vehiculo_Nuevo_FM__c` ya fue ejecutado y validado con Omoda, Jaecoo y BMW. | No tocar la FlexiPage ni el campo salvo regresion normal. |
| S3-B7-04 | Quick Action generica de duplicar partidas de presupuesto | `Quote.BMW_Duplicar_Partidas_de_Presupuesto` | HECHO | `RESULTADO_B7_1_RECONCILIACION_VENTAS_NUEVAS_20260810.md:126-159` | No hay gap PEKING: en VN BMW tampoco aparece porque el Quote usa `Vehiculos Nuevos V1.2`, no el layout donde esta la accion. | No modificar. Documentar que el comportamiento correcto es igual a BMW. |
| S3-B7-05 | Quick Actions con contenido/plantillas | `BMW_EnviarCorreoPresupuesto`, `Quote.BMW_ImportarPlantilla`, `WorkOrder.BMW_ImportarPlantilla` | PARCIAL | Gap real encontrado 2026-08-13: `Plantilla_de_Presupuesto__c.Empresa_Operadora__c` existe en Git y es usado por el Flow `BMW_ImportarPlantilla` (detrás de `Quote.BMW_ImportarPlantilla`) para filtrar plantillas por empresa, pero nunca había sido desplegado al org (bloqueaba el filtro para las 3 empresas, no solo PEKING). Desplegado `RedMotorsSandbox` (deploy `0AfAK0000014o450AA`, 0 errores), confirmado creado vía Tooling API (`CustomField` query). Registro de prueba PEKING pendiente de crear por el mismo lag de propagación de plataforma ya documentado en Sprint 1 para `Tipo_Kit_Softland__c` (SOQL/describe aún no ve el campo al momento de este cierre). `BMW_EnviarCorreoPresupuesto`: código Apex (`BMW_QuotePDFEmail.cls`) verificado íntegramente agnóstico de empresa, sin gap de código. `WorkOrder.BMW_ImportarPlantilla`: su Flow subyacente `BMW_Importar_Plantilla_Orden_de_Trabajo` NO se tocó — tiene una exclusión previa y más específica en `REGLAS_ALCANCE_AUTORIZADO.md` (registrado como candidato fuera de alcance confirmado, requiere confirmación explícita por nombre de Luis/Diego) que prevalece sobre su aparición en esta matriz de Sprint 3. | `Quote.BMW_ImportarPlantilla`: campo desplegado, dato de prueba PEKING pendiente por propagación de plataforma (script listo, no requiere nuevo análisis). `WorkOrder.BMW_ImportarPlantilla`: conflicto de alcance documentado, no accionado sin autorización explícita. `BMW_EnviarCorreoPresupuesto`: la plantilla visual real (Visualforce `BMW_QuotePDFv2`) no está versionada en Git; fuera de alcance de una corrección mínima sin nueva autorización para incorporarla. | Ejecutar el script ya preparado para crear el registro de prueba PEKING en cuanto el campo propague (no repetir el deploy). No tocar `BMW_Importar_Plantilla_Orden_de_Trabajo` sin autorización explícita por nombre de Luis/Diego. No traer `BMW_QuotePDFv2` a Git sin nueva autorización. |
| S3-B7-06 | Paginas exclusivas de usados | `Opportunity_Record_Page_VU`, `Quote_Record_Page_VU`, `Estadisticas_Inventario_Usados`, `Ver_Inventario_Vehiculos_Usados` | NO APLICA | `CIERRE_TRABAJO_INTERNO_SPRINT3_20260807.md:33`; `RESULTADO_B7_1_RECONCILIACION_VENTAS_NUEVAS_20260810.md:297-305` | PEKING/Omoda/Jaecoo no aplican a usados dentro de este bloque. | No tocar en Sprint 3; solo regresion si otro frente de usados lo pide. |
| S3-B9-01 | Cuatro Validation Rules ampliadas para Omoda/Jaecoo | `Opportunity.Cambiar_a_Finalizado_Descuento`, `Opportunity.Cambiar_a_Finalizado_Formalizacion`, `Opportunity.Cambiar_Oportunidad_a_Finalizado_VH`, `Opportunity.Campo_Gustos_y_aficiones_Obligatorio` | HECHO | Archivos versionados contienen `Omoda` y `Jaecoo`; `CIERRE_TRABAJO_INTERNO_SPRINT3_20260807.md:47,126`; `EVIDENCIAS_NEGOCIO_SPRINT3_20260810.md:289` | Ninguno; la evidencia final indica 15/15 pruebas dirigidas documentadas. | No reimplementar B9-1. Solo conservar regresion. |
| S3-B9-02 | Validation Rules neutrales o sin impacto PEKING | Reglas de centro de costo, bodega Uruca, reglas inactivas/no aplicables, reglas generales de Opportunity/Quote/WorkOrder | HECHO | `CIERRE_TRABAJO_INTERNO_SPRINT3_20260807.md:34-40,126-130` | Ninguno de metadata; varias quedaron confirmadas como `QA_FUNCIONAL_COMPLETADO` o `NO_APLICA_CONFIRMADO`. | No tocar reglas agnosticas a Empresa. |
| S3-B9-03 | Validation Rule con QA inconcluso | `Opportunity.Campo_Sucursal_Obligatorio` | HECHO | Formula real recuperada via Tooling API (`ValidationRule` + campo `Metadata`), 2026-08-13. Condicion 4: `NOT(OR($Profile.Name = 'System Administrator', $Profile.Name = 'Administrador del sistema'))` | Diagnostico cerrado por analisis de formula, sin cambio de codigo: el QA previo fue inconcluso porque el usuario de prueba tenia perfil System Administrator, exento explicitamente por la propia regla (condicion 4). No existe ninguna condicion especifica de PEKING/sucursal en la formula; la regla es agnostica de empresa y depende solo de `RecordType.Name`, `StageName` y el perfil. No se modifico la formula (no habia evidencia de que estuviera mal). | Ninguna. Si se requiere QA con bloqueo activo, repetir con un usuario que NO tenga perfil System Administrator. |
| S3-B9-04 | Approval Processes de descuento | 8 procesos `Opportunity.Aprobacion_descuento_*` | BLOQUEADO | `RESULTADO_B7_1_RECONCILIACION_VENTAS_NUEVAS_20260810.md:163-174`; `CIERRE_TRABAJO_INTERNO_SPRINT3_20260807.md:41,142-143` | La metadata ya es neutral y no requiere desarrollo PEKING, pero el QA real de submission depende de que Diego termine la jerarquia Director/Gerente/Jefe. | Esperar jerarquia de Diego; despues ejecutar QA real de submission/aprobacion sin cambiar procesos. |
| S3-B9-05 | Approval Processes por centro de costo | `Quote.CPAprobacionCargoInternoQuote`, `WorkOrder.AprobacionCentroDeCostos` | HECHO | QA funcional real ejecutado 2026-08-13 con Centro de Costo reutilizado `a2c4U000004AkGRQA0` ("centro test") y aprobador existente `0054U000009i0CoQAI`. Quote `0Q0AK000001zH8E0AU`: `Approval.process()` manual, `SUBMIT_SUCCESS:true`, `InstanceStatus:Pending`, aprobador asignado correcto, `CPEstatusDeAprobacion__c` -> `En proceso`. WorkOrder `0WOAK000005k8yz4AA`: la actualizacion de `Aprobador_Centro_de_Costos__c` dispara automaticamente el Flow `envia_aprobaci_n_centro_de_costos_flow` (RecordAfterSave), que somete el registro via `Submit for Approval`; `ProcessInstance 04gAK0000005HrRYAU` quedo `Pending` con el mismo aprobador asignado correctamente. | Ninguno de metadata: ambos procesos ya son agnosticos de empresa (`relatedUserField` sobre un campo lookup a Usuario) y enrutan correctamente para PEKING reutilizando un Centro de Costo existente. | Ninguna. No crear proceso nuevo. |
| S3-B9-06 | Garantia PEKING / procesos de garantia | `WorkOrder.PROCESO_DE_APROB_GARANTIA`, `WorkOrder.PROCESO_DE_APROB_GARANTIA_CITA_TALLER`, N3 | HECHO | Instruccion directa actual: garantia N3 ya validada sin cambio tecnico; no volver a pedir definicion | Ninguno para Sprint 3; la documentacion anterior que lo marcaba bloqueado queda superada por la definicion reciente. | No tocar procesos de garantia por este bloque. |
| S3-B9-07 | Roles, perfiles y visibilidad de Record Types Omoda/Jaecoo | Roles inventariados, Profiles/Permission Sets, visibilidad de `Opportunity.Omoda` y `Opportunity.Jaecoo` | BLOQUEADO | `CIERRE_TRABAJO_INTERNO_SPRINT3_20260807.md:8,57-87,138-149`; `EVIDENCIAS_NEGOCIO_SPRINT3_20260810.md:302-305` | Falta trabajo de Diego: perfiles/visibilidad de Record Types y jerarquia final. No es metadata que deba inventar el equipo de Sprint 3. | Diego debe habilitar perfiles/RT y jerarquia; despues repetir QA visual y aprobaciones reales. |
| S3-B11-01 | Mapping Lead -> Opportunity Omoda/Jaecoo | `RM_RecordTypeMapping.Lead_Omoda_to_Opp`, `RM_RecordTypeMapping.Lead_Jaecoo_to_Opp` | HECHO | Ambos archivos existen en Git; `MATRIZ_CONFIGURACION_SOFTLAND_B11_0_20260806.csv` los clasifica como existentes en Git y Partial; `EVIDENCIAS_NEGOCIO_SPRINT3_20260810.md:286` | Ninguno. | No tocar. |
| S3-B11-02 | Configuracion Empresa / Pricebook / endpoint compartido | `Empresa__c`, `EmpresaResolver`, `EmpresaPricebookResolver`, `Pricebook2.Empresa__c`, labels/endpoints existentes | HECHO | `MATRIZ_CONFIGURACION_SOFTLAND_B11_0_20260806.csv`; `ESTADO_EJECUTABLE_SPRINT3_20260806.md:17-21` | No falta nueva instancia ni endpoint; el modelo configurable ya existe. | Solo regresion; no crear mecanismo paralelo. |
| S3-B11-03 | Seis catalogos Softland y schedulers reconciliados | `BatchGetCatalogoSoftland`, seis wrappers, seis schedulers, 13 tests | HECHO | `RESULTADO_B11_1_CATALOGOS_SOFTLAND_20260806.md:7-24,26-68`; `CIERRE_TRABAJO_INTERNO_SPRINT3_20260807.md:48` | Ninguno tecnico: 36/36 pruebas, dry-run succeeded, deploy no necesario porque Partial ya era equivalente. | No reimplementar. Solo QA funcional de contenido real cuando haya datos. |
| S3-B11-04 | Bodega Softland PEKING | `BatchGetBodegaSoftland`, `BatchGetCatalogoSoftland` modo `BODEGA`, `Bodega__c`, `ID_EXTERNO_BODEGA__c` | HECHO | Codigo verificado 2026-08-13: `bodegaExternalIdPrefix = company == 'RMBAVARIAN' ? '' : company;` ya separa la clave externa por empresa (correccion de bloque previo). Registro `Bodega__c` `a2bAK0000000vvxYAA` ("PEKING TEMPORAL - PARTIAL - NO USAR EN PRODUCCION", `ID_EXTERNO_BODEGA__c = 'RMPEKINGTEMP01'`) ya existe como dato de prueba. | Ninguno: la colision de clave externa PEKING/Bavarian ya estaba resuelta en codigo y el dato de bodega provisional ya existia en el org. | Ninguna. No ejecutar catalogos reales contra Softland. |
| S3-B11-05 | Default de Pricebook VN configurable | `RM_Config.Default_Price_List_VN` y consumidores de default | HECHO | Registro `RM_Config.Default_Price_List_VN` ya existia materializado en Partial (`Value__c = 'Bavarian Dólar'`, `Description__c` documentado) pero no estaba versionado en Git. Retrieved 2026-08-13 (`CustomObject:RM_Config__mdt`, `CustomMetadata:RM_Config.Default_Price_List_VN`) y agregado al repositorio. Git y Partial ya son equivalentes; no requirio deploy adicional. | Ninguno: el mecanismo de default ya existia y ya funcionaba en Partial; el gap era exclusivamente de versionado en Git. | Ninguna. |
| S3-ESP-01 | Bloque especial BusquedaDetallada | `BusquedaDetalladaController`, `BusquedaDetalladaService`, `BusquedaDetalladaHelper`, `lwc/busquedaDetallada` | BLOQUEADO | `BusquedaDetalladaController.cls:8-19,34-44`; `BITACORA_IMPLEMENTACION.md:1929-1956` | Sigue dependiendo de `User.Sucursal__c` y nombres fijos de sucursal/territorio/Pricebook: Uruca/Pinares/Escazu => Bavarian, otro => Otobai. No existe definicion especifica vigente de visibilidad de sucursales PEKING para este componente. | BLOQUEADO - DEFINICION ESPECIFICA PENDIENTE. No implementar hasta definir sucursal/territorio/visibilidad PEKING para esta busqueda. |
| S3-EXT-01 | Clases extras detectadas posteriormente fuera de Sprint 3 oficial | Apex extras no asociados directamente a Bloque 7, 9 u 11 | NO APLICA | Regla de alcance: no convertir hallazgos tecnicos externos en Sprint 3 | Si se trabajan, deben tratarse como `TRABAJO EXTRA - NO CONTEMPLADO EN EL ALCANCE/HORAS ORIGINALES`. | No incluir en esta ejecucion de Sprint 3. |

## Cierre ejecutivo Sprint 3 (2026-08-13)

**SPRINT 3 — CERRADO EN TODO LO IMPLEMENTABLE.**

De los 5 gaps clasificados `FALTA` en la version inicial de esta reconciliacion, 4 quedaron `HECHO` con evidencia real (S3-B9-03, S3-B9-05, S3-B11-04, S3-B11-05) y 1 quedo `PARCIAL` (S3-B7-05: 2 de 3 componentes resueltos o sin gap; el tercero es un conflicto de alcance documentado, no una falta de trabajo). Los 4 `BLOQUEADO` originales permanecen bloqueados por definiciones pendientes de Diego/negocio, no se convirtieron en supuestos. Los 2 `NO APLICA` no se tocaron.

## Totales

| Estado | Total |
|---|---:|
| HECHO | 13 |
| PARCIAL | 1 |
| BLOQUEADO | 4 |
| NO APLICA | 2 |

## Componentes que realmente necesitan implementacion o ejecucion posterior

PARCIAL (S3-B7-05):

- `Quote.BMW_ImportarPlantilla`: campo `Empresa_Operadora__c` desplegado; falta unicamente crear el registro de prueba PEKING en `Plantilla_de_Presupuesto__c` cuando el campo propague en el org (script preparado, ver cierre tecnico).
- `WorkOrder.BMW_ImportarPlantilla`: conflicto de alcance con `REGLAS_ALCANCE_AUTORIZADO.md` — requiere confirmacion explicita por nombre de Luis/Diego antes de cualquier accion.
- `BMW_EnviarCorreoPresupuesto`: sin gap de codigo Apex; la plantilla Visualforce `BMW_QuotePDFv2` no esta en Git y requeriria nueva autorizacion para incorporarla.

BLOQUEADO:

- `Opportunity_Record_Page_VN` por perfil/asignacion final de Diego.
- 8 `Opportunity.Aprobacion_descuento_*` por jerarquia Director/Gerente/Jefe de Diego para QA real.
- Roles, perfiles y visibilidad de `Opportunity.Omoda` / `Opportunity.Jaecoo`.
- `BusquedaDetalladaController` / `busquedaDetallada` por definicion especifica pendiente de visibilidad de sucursales PEKING.

## Componentes que NO deben volver a tocarse en Sprint 3

- Las cuatro Validation Rules B9-1 ya ampliadas: `Cambiar_a_Finalizado_Descuento`, `Cambiar_a_Finalizado_Formalizacion`, `Cambiar_Oportunidad_a_Finalizado_VH`, `Campo_Gustos_y_aficiones_Obligatorio`.
- `Quote_Record_Page_VN` y `Flag_Vehiculo_Nuevo_FM__c`, salvo regresion.
- `Quote.BMW_Duplicar_Partidas_de_Presupuesto`, porque no hay gap PEKING contra BMW en Ventas Nuevas.
- Paginas VU/usados: `Opportunity_Record_Page_VU`, `Quote_Record_Page_VU`, `Estadisticas_Inventario_Usados`, `Ver_Inventario_Vehiculos_Usados`.
- `RM_RecordTypeMapping.Lead_Omoda_to_Opp` y `RM_RecordTypeMapping.Lead_Jaecoo_to_Opp`.
- B11-1 de seis catalogos Softland y schedulers ya reconciliados: no repetir tests ni deploy si no hay cambio nuevo.
- Procesos de garantia N3, por definicion reciente: validado sin cambio tecnico.
- `Opportunity.Campo_Sucursal_Obligatorio`: diagnostico cerrado por analisis de formula (2026-08-13); no volver a cambiar la formula sin evidencia nueva.
- `Quote.CPAprobacionCargoInternoQuote` y `WorkOrder.AprobacionCentroDeCostos`: QA funcional real completado (2026-08-13) reutilizando Centro de Costo existente; no crear proceso nuevo.
- `BatchGetBodegaSoftland` / `BatchGetCatalogoSoftland` modo `BODEGA`: prefijo de clave externa ya corregido y dato de bodega provisional PEKING ya existente; no tocar salvo regresion.
- `RM_Config.Default_Price_List_VN`: ya versionado en Git, equivalente a Partial; no crear mecanismo paralelo.
- `BMW_Importar_Plantilla_Orden_de_Trabajo` (Flow detras de `WorkOrder.BMW_ImportarPlantilla`): conflicto de alcance documentado con `REGLAS_ALCANCE_AUTORIZADO.md`; no tocar sin autorizacion explicita por nombre.

## Orden recomendado para cerrar Sprint 3

1. Diego: confirmar/habilitar perfiles, visibilidad de Record Types Omoda/Jaecoo y jerarquia Director/Gerente/Jefe.
2. UI: cerrar `Opportunity_Record_Page_VN` con las asignaciones finales y dejar evidencia visual final.
3. B9: ejecutar QA real de los 8 Approval Processes de descuento con jerarquia real.
4. B7: crear el registro de prueba PEKING de `Plantilla_de_Presupuesto__c` en cuanto el campo `Empresa_Operadora__c` propague en el org (script ya preparado); resolver el conflicto de alcance de `WorkOrder.BMW_ImportarPlantilla` con Luis/Diego si se requiere.
5. Bloque especial: no iniciar `BusquedaDetallada` hasta que exista definicion especifica de sucursal/territorio/visibilidad PEKING.

## Nota economica

Esta reconciliacion no autoriza trabajo fuera del Sprint 3 oficial. Cualquier clase, Flow, LWC o metadata que venga de hallazgos tecnicos posteriores y no pertenezca a Bloque 7, 9 u 11 debe etiquetarse como:

`TRABAJO EXTRA - NO CONTEMPLADO EN EL ALCANCE/HORAS ORIGINALES`
