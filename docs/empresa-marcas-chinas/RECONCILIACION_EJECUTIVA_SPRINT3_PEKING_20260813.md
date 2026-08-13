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
| S3-B7-05 | Quick Actions con contenido/plantillas | `BMW_EnviarCorreoPresupuesto`, `Quote.BMW_ImportarPlantilla`, `WorkOrder.BMW_ImportarPlantilla` | FALTA | `RESULTADO_B7_1_RECONCILIACION_VENTAS_NUEVAS_20260810.md:81-87`; matriz B7 indica acciones expuestas pero no resueltas por perfil | Falta cerrar contenido de prueba/configuracion de plantilla/correo/presupuesto bajo PEKING. Con la definicion reciente de branding/razon social de prueba ya no debe tratarse como bloqueo de negocio. | Preparar lote puntual de configuracion/QA de acciones; no duplicar por nombre BMW si la accion actual es reutilizable. |
| S3-B7-06 | Paginas exclusivas de usados | `Opportunity_Record_Page_VU`, `Quote_Record_Page_VU`, `Estadisticas_Inventario_Usados`, `Ver_Inventario_Vehiculos_Usados` | NO APLICA | `CIERRE_TRABAJO_INTERNO_SPRINT3_20260807.md:33`; `RESULTADO_B7_1_RECONCILIACION_VENTAS_NUEVAS_20260810.md:297-305` | PEKING/Omoda/Jaecoo no aplican a usados dentro de este bloque. | No tocar en Sprint 3; solo regresion si otro frente de usados lo pide. |
| S3-B9-01 | Cuatro Validation Rules ampliadas para Omoda/Jaecoo | `Opportunity.Cambiar_a_Finalizado_Descuento`, `Opportunity.Cambiar_a_Finalizado_Formalizacion`, `Opportunity.Cambiar_Oportunidad_a_Finalizado_VH`, `Opportunity.Campo_Gustos_y_aficiones_Obligatorio` | HECHO | Archivos versionados contienen `Omoda` y `Jaecoo`; `CIERRE_TRABAJO_INTERNO_SPRINT3_20260807.md:47,126`; `EVIDENCIAS_NEGOCIO_SPRINT3_20260810.md:289` | Ninguno; la evidencia final indica 15/15 pruebas dirigidas documentadas. | No reimplementar B9-1. Solo conservar regresion. |
| S3-B9-02 | Validation Rules neutrales o sin impacto PEKING | Reglas de centro de costo, bodega Uruca, reglas inactivas/no aplicables, reglas generales de Opportunity/Quote/WorkOrder | HECHO | `CIERRE_TRABAJO_INTERNO_SPRINT3_20260807.md:34-40,126-130` | Ninguno de metadata; varias quedaron confirmadas como `QA_FUNCIONAL_COMPLETADO` o `NO_APLICA_CONFIRMADO`. | No tocar reglas agnosticas a Empresa. |
| S3-B9-03 | Validation Rule con QA inconcluso | `Opportunity.Campo_Sucursal_Obligatorio` | FALTA | `CIERRE_TRABAJO_INTERNO_SPRINT3_20260807.md:39,148` | El QA aislado no fue concluyente por posible automatizacion que cambia `alertEmail__c` o `NombreProducto__c`. Ya no debe bloquearse por sucursal/territorio provisional; el gap es tecnico de analisis/QA. | Hacer analisis dirigido de automatizaciones que interfieren y repetir QA; no cambiar formula sin evidencia. |
| S3-B9-04 | Approval Processes de descuento | 8 procesos `Opportunity.Aprobacion_descuento_*` | BLOQUEADO | `RESULTADO_B7_1_RECONCILIACION_VENTAS_NUEVAS_20260810.md:163-174`; `CIERRE_TRABAJO_INTERNO_SPRINT3_20260807.md:41,142-143` | La metadata ya es neutral y no requiere desarrollo PEKING, pero el QA real de submission depende de que Diego termine la jerarquia Director/Gerente/Jefe. | Esperar jerarquia de Diego; despues ejecutar QA real de submission/aprobacion sin cambiar procesos. |
| S3-B9-05 | Approval Processes por centro de costo | `Quote.CPAprobacionCargoInternoQuote`, `WorkOrder.AprobacionCentroDeCostos` | FALTA | `CIERRE_TRABAJO_INTERNO_SPRINT3_20260807.md:42-43`; `RESULTADO_B7_1_RECONCILIACION_VENTAS_NUEVAS_20260810.md:175-177` | Entrada/submission ya fue probada con placeholder. Falta QA real con centro de costo reutilizado y aprobador vigente, segun definicion reciente. | Ejecutar QA funcional real con centro de costo existente; no crear proceso nuevo. |
| S3-B9-06 | Garantia PEKING / procesos de garantia | `WorkOrder.PROCESO_DE_APROB_GARANTIA`, `WorkOrder.PROCESO_DE_APROB_GARANTIA_CITA_TALLER`, N3 | HECHO | Instruccion directa actual: garantia N3 ya validada sin cambio tecnico; no volver a pedir definicion | Ninguno para Sprint 3; la documentacion anterior que lo marcaba bloqueado queda superada por la definicion reciente. | No tocar procesos de garantia por este bloque. |
| S3-B9-07 | Roles, perfiles y visibilidad de Record Types Omoda/Jaecoo | Roles inventariados, Profiles/Permission Sets, visibilidad de `Opportunity.Omoda` y `Opportunity.Jaecoo` | BLOQUEADO | `CIERRE_TRABAJO_INTERNO_SPRINT3_20260807.md:8,57-87,138-149`; `EVIDENCIAS_NEGOCIO_SPRINT3_20260810.md:302-305` | Falta trabajo de Diego: perfiles/visibilidad de Record Types y jerarquia final. No es metadata que deba inventar el equipo de Sprint 3. | Diego debe habilitar perfiles/RT y jerarquia; despues repetir QA visual y aprobaciones reales. |
| S3-B11-01 | Mapping Lead -> Opportunity Omoda/Jaecoo | `RM_RecordTypeMapping.Lead_Omoda_to_Opp`, `RM_RecordTypeMapping.Lead_Jaecoo_to_Opp` | HECHO | Ambos archivos existen en Git; `MATRIZ_CONFIGURACION_SOFTLAND_B11_0_20260806.csv` los clasifica como existentes en Git y Partial; `EVIDENCIAS_NEGOCIO_SPRINT3_20260810.md:286` | Ninguno. | No tocar. |
| S3-B11-02 | Configuracion Empresa / Pricebook / endpoint compartido | `Empresa__c`, `EmpresaResolver`, `EmpresaPricebookResolver`, `Pricebook2.Empresa__c`, labels/endpoints existentes | HECHO | `MATRIZ_CONFIGURACION_SOFTLAND_B11_0_20260806.csv`; `ESTADO_EJECUTABLE_SPRINT3_20260806.md:17-21` | No falta nueva instancia ni endpoint; el modelo configurable ya existe. | Solo regresion; no crear mecanismo paralelo. |
| S3-B11-03 | Seis catalogos Softland y schedulers reconciliados | `BatchGetCatalogoSoftland`, seis wrappers, seis schedulers, 13 tests | HECHO | `RESULTADO_B11_1_CATALOGOS_SOFTLAND_20260806.md:7-24,26-68`; `CIERRE_TRABAJO_INTERNO_SPRINT3_20260807.md:48` | Ninguno tecnico: 36/36 pruebas, dry-run succeeded, deploy no necesario porque Partial ya era equivalente. | No reimplementar. Solo QA funcional de contenido real cuando haya datos. |
| S3-B11-04 | Bodega Softland PEKING | `BatchGetBodegaSoftland`, `BatchGetCatalogoSoftland` modo `BODEGA`, `Bodega__c`, `ID_EXTERNO_BODEGA__c` | FALTA | `CIERRE_TRABAJO_INTERNO_SPRINT3_20260807.md:49`; `BatchGetBodegaSoftland.cls` delega a `BatchGetCatalogoSoftland(BODEGA, company)` | La colision de clave externa PEKING/Bavarian fue confirmada. Con la definicion reciente de bodega provisional, ya no es bloqueo de negocio; falta cerrar mecanismo/dato de prueba sin asumir valor oficial. | Implementar/validar en lote autorizado la separacion de clave o dato de prueba PEKING para bodega; no ejecutar catalogos reales. |
| S3-B11-05 | Default de Pricebook VN configurable | `RM_Config.Default_Price_List_VN` y consumidores de default | FALTA | `MATRIZ_CONFIGURACION_SOFTLAND_B11_0_20260806.csv` indica default global en Partial y no versionado en Git | La definicion reciente permite crear/usar Pricebook default de prueba, pero falta materializarlo y probar precedencia cuando no haya seleccion explicita. | Preparar dato/config de prueba y QA dirigido; no resolver con nombre fijo si hay lookup Empresa disponible. |
| S3-ESP-01 | Bloque especial BusquedaDetallada | `BusquedaDetalladaController`, `BusquedaDetalladaService`, `BusquedaDetalladaHelper`, `lwc/busquedaDetallada` | BLOQUEADO | `BusquedaDetalladaController.cls:8-19,34-44`; `BITACORA_IMPLEMENTACION.md:1929-1956` | Sigue dependiendo de `User.Sucursal__c` y nombres fijos de sucursal/territorio/Pricebook: Uruca/Pinares/Escazu => Bavarian, otro => Otobai. No existe definicion especifica vigente de visibilidad de sucursales PEKING para este componente. | BLOQUEADO - DEFINICION ESPECIFICA PENDIENTE. No implementar hasta definir sucursal/territorio/visibilidad PEKING para esta busqueda. |
| S3-EXT-01 | Clases extras detectadas posteriormente fuera de Sprint 3 oficial | Apex extras no asociados directamente a Bloque 7, 9 u 11 | NO APLICA | Regla de alcance: no convertir hallazgos tecnicos externos en Sprint 3 | Si se trabajan, deben tratarse como `TRABAJO EXTRA - NO CONTEMPLADO EN EL ALCANCE/HORAS ORIGINALES`. | No incluir en esta ejecucion de Sprint 3. |

## Totales

| Estado | Total |
|---|---:|
| HECHO | 9 |
| FALTA | 5 |
| BLOQUEADO | 4 |
| NO APLICA | 2 |

## Componentes que realmente necesitan implementacion o ejecucion posterior

FALTA:

- `BMW_EnviarCorreoPresupuesto`
- `Quote.BMW_ImportarPlantilla`
- `WorkOrder.BMW_ImportarPlantilla`
- `Opportunity.Campo_Sucursal_Obligatorio` (analisis/QA dirigido antes de tocar formula)
- `Quote.CPAprobacionCargoInternoQuote` y `WorkOrder.AprobacionCentroDeCostos` (QA real con centro de costo existente)
- `BatchGetBodegaSoftland` / `BatchGetCatalogoSoftland` modo `BODEGA`
- `RM_Config.Default_Price_List_VN` o mecanismo equivalente de default de prueba

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

## Orden recomendado para cerrar Sprint 3

1. Diego: confirmar/habilitar perfiles, visibilidad de Record Types Omoda/Jaecoo y jerarquia Director/Gerente/Jefe.
2. UI: cerrar `Opportunity_Record_Page_VN` con las asignaciones finales y dejar evidencia visual final.
3. B9: ejecutar QA real de los 8 Approval Processes de descuento con jerarquia real.
4. B9: ejecutar QA real de centro de costo usando el centro/aprobador vigente que se definio reutilizar.
5. B7: cerrar las tres Quick Actions con contenido/configuracion de prueba, sin duplicar metadata si las acciones actuales son reutilizables.
6. B11: resolver bodega PEKING con dato provisional y validar que no colisione por `ID_EXTERNO_BODEGA__c`.
7. B11: materializar/probar default de Pricebook de prueba.
8. Bloque especial: no iniciar `BusquedaDetallada` hasta que exista definicion especifica de sucursal/territorio/visibilidad PEKING.

## Nota economica

Esta reconciliacion no autoriza trabajo fuera del Sprint 3 oficial. Cualquier clase, Flow, LWC o metadata que venga de hallazgos tecnicos posteriores y no pertenezca a Bloque 7, 9 u 11 debe etiquetarse como:

`TRABAJO EXTRA - NO CONTEMPLADO EN EL ALCANCE/HORAS ORIGINALES`
