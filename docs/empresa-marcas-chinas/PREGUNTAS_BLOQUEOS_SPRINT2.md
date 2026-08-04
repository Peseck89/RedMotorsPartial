# Preguntas reales para desbloquear Sprint 2

Esta versión elimina preguntas ya respondidas sobre vigencia productiva, usados, arquitectura Empresa/Pricebook, incorporación de bundles y conciliación general Git–Partial.

## Decisiones resueltas — no volver a preguntar

- Solo se trabajan Flows activos en Producción; los doce candidatos del Lote 2 están activos.
- Los procesos exclusivos de usados no soportan PEKING.
- El lookup Empresa es principal; legacy Bavarian/Otobai es fallback temporal.
- `EmpresaPricebookResolver` es el contrato común y no selecciona opciones ambiguas.
- `kpiSucursales` y `cT_Estadisticas_Inventario_lwc` ya están versionados.
- Nueve conflictos Git–Partial fueron conciliados; despacho conserva dependencias faltantes separadas.

## Para Luis

### L1. UX y precedencia de Empresa en Flows de Opportunity

**Pregunta:** En `Opp_Flow_V5`, `Opp_flow_V3`, `Opportunity_Flow_V2`, `Opp_Flow_v6` y `aperturaCaseWorOrderEvent`, ¿la Empresa debe elegirse mediante un lookup/selector de `Empresa__c` o derivarse del registro/contexto? Para `Opportunity_Flow_V2`, ¿qué precedencia tiene la Empresa elegida frente a `$User.Empresa__c`?

**Desbloquea:** sublotes 2D1, parte de 2D2 y `aperturaCaseWorOrderEvent` en 2E.

**Alternativa recomendada:** lookup Empresa explícito cuando existe interacción; contexto del registro cuando no existe pantalla. `$User.Empresa__c` puede sugerir, pero no sobrescribir silenciosamente una Empresa explícita. No agregar PEKING al picklist legacy.

## Para Diego

### D1. Base de versión para Flows con active/latest distintos

**Pregunta:** Para `Opp_Flow_V5` (v29 activa, v30 Draft) y `Opp_Flow_v6` (v79 activa, v80 Draft), ¿qué versión debe ser la base editable y qué cambios del Draft deben preservarse antes de migrar Empresa/Pricebook?

**Desbloquea:** sublote 2D2.

**Alternativa recomendada:** partir de la versión activa y conciliar explícitamente solo cambios Draft aprobados; no activar el Draft por inferencia.

### D2. Record Type configurable para segregación

**Pregunta:** ¿Se aprueba resolver el Record Type de `SegregateWOLIs` por DeveloperName más configuración por Empresa/proceso, eliminando el Id dependiente de org?

**Desbloquea:** parte técnica del sublote 2C.

**Alternativa recomendada:** DeveloperName estable y configuración empresarial; nunca Id literal.

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

## Preguntas de otros lotes que permanecen vigentes

- Contrato y operaciones Softland autorizadas para inventario/localización/despacho.
- Sucursales, servicios, capacidades, usuarios y textos legales para Community.
- Perfiles QA y permisos funcionales por proceso.
- Dependencias faltantes de despacho antes de conciliar `quoliGridDespacho`/`woliGridDespacho`.

Ninguna respuesta de este documento autoriza implementación por sí sola; cada sublote requiere aprobación expresa.
