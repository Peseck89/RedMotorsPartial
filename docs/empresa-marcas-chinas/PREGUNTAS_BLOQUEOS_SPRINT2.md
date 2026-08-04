# Preguntas reales para desbloquear Sprint 2

Esta versión elimina preguntas ya respondidas sobre vigencia productiva, usados, arquitectura Empresa/Pricebook, incorporación de bundles y conciliación general Git–Partial.

## Decisiones resueltas — no volver a preguntar

- Solo se trabajan Flows activos en Producción; los doce candidatos del Lote 2 están activos.
- Los procesos exclusivos de usados no soportan PEKING.
- El lookup Empresa es principal; legacy Bavarian/Otobai es fallback temporal.
- `EmpresaPricebookResolver` es el contrato común y no selecciona opciones ambiguas.
- `kpiSucursales` y `cT_Estadisticas_Inventario_lwc` ya están versionados.
- Nueve conflictos Git–Partial fueron conciliados; despacho conserva dependencias faltantes separadas.
- Luis confirmó selección explícita de Empresa en `Opp_Flow_V5`, `Opp_flow_V3`, `Opp_Flow_v6`, `Opportunity_Flow_V2` y `aperturaCaseWorOrderEvent`.
- En `Opportunity_Flow_V2`, la Empresa seleccionada explícitamente prevalece sobre `$User.Empresa__c`; el dato del usuario no puede sobrescribirla.
- `Opp_Flow_V5` debe modificarse desde v29 activa; v30 Draft se ignora.
- `Opp_Flow_v6` debe modificarse desde v79 activa; v80 Draft se ignora.
- `SegregateWOLIs` debe resolver el Record Type por DeveloperName y eliminar el Id dependiente del ambiente.

## Flows sin bloqueo de decisión

- `Opp_Flow_V5` — ejecutable desde v29 activa.
- `Opp_flow_V3` — ejecutable desde v28 activa.
- `Opp_Flow_v6` — ejecutable desde v79 activa.
- `Opportunity_Flow_V2` — ejecutable desde v6 activa, con precedencia de Empresa explícita.

Estos cuatro Flows pueden integrar el selector de Empresa y la resolución dinámica de Pricebook sin otra decisión funcional conocida. La ejecución requiere autorización específica.

`SegregateWOLIs` puede sustituir técnicamente el Id fijo por DeveloperName, pero su comportamiento completo para PEKING continúa bloqueado por N3. `aperturaCaseWorOrderEvent` ya no espera una decisión de UX, pero continúa bloqueado por N4.

## Para negocio

### N1. Catálogo, moneda y precios para pruebas positivas

**Pregunta:** ¿Cuál es la fuente oficial de productos y precios PEKING para mantenimiento, gastos y mano de obra, y cuál es la moneda correcta de las listas “Local” de Bavarian y Otobai?

**Desbloquea:** cierre funcional de `PlanDeMantenimientoV2`, `CreateWoliFromExpense` y `AgregarManoObra`. No bloquea su refactor técnico seguro.

**Alternativa recomendada:** mientras no existan PBE oficiales, retornar no configurado y detener; nunca copiar productos/precios de otra Empresa.

### N2. Quote→WO, bodega, territorio y despacho

**Pregunta:** ¿Qué bodegas, territorios, reglas de bodega principal/apartados, reserva, despacho, devolución y taller aplican oficialmente a PEKING?

**Desbloquea:** `Work_Order_from_Quote`, `Work_Order_from_Quote_Selective` y la parte operativa de `aperturaCaseWorOrderEvent`/`ct_newCaseWorkOrderEvent`.

**Alternativa recomendada:** configuración explícita por Empresa; función no configurada debe detenerse con mensaje controlado.

### N3. Garantía y segregación

**Pregunta:** ¿Qué reglas de garantía, segregación de cargos y WOLI aplican a PEKING?

**Desbloquea:** comportamiento funcional de `SegregateWOLIs`.

**Alternativa recomendada:** política por Empresa; ausencia de configuración significa no disponible, nunca heredar Otobai.

### N4. Servicios y agenda

**Pregunta:** ¿Qué servicios, agenda, sucursales y territorios aplican a PEKING para los procesos de Caso→Work Order→Event?

**Desbloquea:** sublote 2E.

**Alternativa recomendada:** configuración empresarial aprobada; no inferir servicios o sucursales por similitud.

## Bloqueos de negocio que permanecen vigentes

- Contrato y operaciones Softland autorizadas para inventario/localización/despacho.
- Sucursales, servicios, capacidades, usuarios y textos legales para Community.
- Perfiles QA y permisos funcionales por proceso.
- Dependencias faltantes de despacho antes de conciliar `quoliGridDespacho`/`woliGridDespacho`.

## Clasificación después de las respuestas

| Estado | Flows |
|---|---|
| Ejecutables técnicamente | `Opp_Flow_V5`, `Opp_flow_V3`, `Opp_Flow_v6`, `Opportunity_Flow_V2` |
| Bloqueados por N2 | `Work_Order_from_Quote`, `Work_Order_from_Quote_Selective` |
| Bloqueado por N3 | `SegregateWOLIs` (salvo sustitución técnica del Record Type) |
| Bloqueados por N4 | `aperturaCaseWorOrderEvent`, `ct_newCaseWorkOrderEvent` |
| Implementados técnicamente; QA positivo bloqueado por N1 | `PlanDeMantenimientoV2`, `CreateWoliFromExpense`, `AgregarManoObra` |

Ninguna respuesta de este documento autoriza implementación por sí sola; cada sublote requiere aprobación expresa.
