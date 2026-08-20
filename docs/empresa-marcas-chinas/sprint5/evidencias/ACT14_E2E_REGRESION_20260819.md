# Actividad 14 — Evidencia E2E / Regresión (2026-08-19)

Org: `RedMotorsSandbox` (Org Id `00DAK000000npFt2AI`, Partial Sandbox).

## 1. Opportunity → Quote (main flow, tramo inicial)

### OMODA

- Opportunity `006AK00000JOCQ5YAP` ("QA_PEKING_S3_RT_20260810 - Account Omoda-Omoda-10/08/2026"): vigente,
  `Empresa_Operadora__c = PEKING` (`a1UAK0000009wft2AA`), `CurrencyIsoCode = USD`, `Pricebook2 = PEKING
  Dólares`, `StageName = Prospecto`, `IsClosed = false`.
- Quote `0Q0AK000001y2BF0AY` ("PT-00080224"): `Status = Draft`, mismo Pricebook/moneda que la Opportunity.
- **Resultado: PASS** — Empresa, Pricebook y moneda se resuelven correctamente para PEKING/OMODA.

### JAECOO

- Opportunity `006AK00000JOCQ6YAP` ("QA_PEKING_S3_RT_20260810 - Account Jaecoo-Jaecoo-10/08/2026"): vigente,
  mismos valores de Empresa/moneda/Pricebook que OMODA.
- Quote `0Q0AK000001y2BG0AY` ("PT-00080225"): `Status = Draft`.
- **Resultado: PASS** — mismo comportamiento correcto que OMODA.

## 2. QuoteLineItem (punto de bloqueo conocido — RQ329)

Se intentó insertar un `QuoteLineItem` real (vía API, no Anonymous Apex, para reproducir el flujo real de
inserción) en los 2 Quotes anteriores:

| Quote | PricebookEntry usado | Resultado |
|---|---|---|
| OMODA (`0Q0AK000001y2BF0AY`) | PEKING Dólares / QAOMODA2026UNIT001 (`01uAK000000YeUVYA0`) | Error `RQ329_INS_QuoteLineGuard` |
| JAECOO (`0Q0AK000001y2BG0AY`) | PEKING Dólares / QAJAECOO2026UNIT001 (`01uAK000000YlxSYAS`) | Error `RQ329_INS_QuoteLineGuard` |
| OMODA (`0Q0AK000001y2BF0AY`) | PEKING Dólares / BSI, producto no vehicular (`01uAK000000YRFVYA4`) | Error `RQ329_INS_QuoteLineGuard` (prueba de aislamiento) |

Error exacto reproducido las 3 veces, idéntico al documentado en `CIERRE_CONTINUACION_OMODA_JAECOO_20260815.md`:

```
RQ329_INS_QuoteLineGuard: execution of BeforeInsert
caused by: System.QueryException: Variable does not exist: tmpVar1
Class.RQ329_INS_LockGuard.assertLineChanges: line 39, column 1
Trigger.RQ329_INS_QuoteLineGuard: line 2, column 1
```

**Hallazgo nuevo de Sprint 5:** la tercera prueba (BSI, producto no vehicular, sin relación con PEKING/OMODA/
JAECOO) reproduce el mismo error exacto en el mismo Quote. Esto confirma de forma adicional — más allá de lo
ya documentado en Sprint 4 — que el guard falla para **cualquier** inserción de `QuoteLineItem` sobre este
Quote, independientemente del producto o la marca. Refuerza la clasificación de que es un incidente
transversal preexistente, no un defecto de PEKING/OMODA/JAECOO ni de los cambios de Sprint 5.

No quedó ningún `QuoteLineItem` residual: se confirmó por consulta posterior (`SELECT Id FROM
QuoteLineItem WHERE QuoteId IN (...)` → 0 registros) que las 3 transacciones fallidas hicieron rollback
completo, sin mutaciones parciales.

**Clasificación: `BLOQUEADO EXTERNO`** (regla de la sección 14 del prompt de ejecución — patrón idéntico al
ya confirmado como preexistente/transversal). No se modificó `RQ329_INS_QuoteLineGuard` ni
`RQ329_INS_LockGuard`.

## 3. Work Order → Factura

**No alcanzable en este Sprint.** El flujo estándar de creación de Work Order (`Work_Order_from_Quote` /
`Work_Order_from_Quote_Selective`) y de factura depende de que el Quote tenga `QuoteLineItem` sincronizables;
al estar bloqueada la inserción de `QuoteLineItem` por el incidente externo `RQ329` (sección 2), este tramo
no puede ejecutarse de extremo a extremo con datos reales OMODA/JAECOO.

**Clasificación: `BLOQUEADO EXTERNO`** (bloqueo en cascada desde RQ329, no un defecto nuevo).

## 4. Inventario / Bodega / Ubicación

Se re-ejecutó `RM_VN_Inventario_Ctrl.getRecords(...)` (mismo patrón usado en el cierre de continuación
2026-08-15) para confirmar que la grilla de inventario sigue funcionando tras los cambios de Actividad 13:

| Marca | Parámetros | Resultado |
|---|---|---|
| OMODA | brand=OMODA, year=2026, model="QA OMODA" | `totalRecords=1`, registro `ProductoXBodega__c a2eAK00000035ETYAY`, bodega PEKING TEMPORAL, `preciosSoftland` (PEKING Dólares) y `preciosFantasia` resueltos correctamente |
| JAECOO | brand=JAECOO, year=2026, model="QA JAECOO" | `totalRecords=1`, registro `ProductoXBodega__c a2eAK00000037bFYAQ`, mismo resultado exacto que OMODA |

Sin fault, sin excepción no controlada, sin duplicado. **Resultado: PASS** (sin regresión tras Actividad 13).

Verificación adicional de datos de soporte, sin cambios respecto a lo documentado:

- `Ubicaciones_por_Marca__c` OMODA (`a5yAK00000048QPYAY`, Marca=OMODA) y JAECOO (`a5yAK0000004TZkYAM`,
  Marca=JAECOO): intactos.
- `ProductoXBodega__c` OMODA (`a2eAK00000035ETYAY`) y JAECOO (`a2eAK00000037bFYAQ`): ambos con
  `Bodega__c = a2bAK0000000vvxYAA` (PEKING TEMPORAL), `Disponible__c = 1`: intactos.
- `RM_Config__mdt` `Bodega_Principal_RMPEKING` = `PKT01`: intacto, sin regresión.
- `Bodega__c` `a2bAK0000000vvxYAA` (PKT01): `Bodega_vehiculos_nuevos__c = true`, intacto.

## 5. Aprobaciones (Centro de Costo)

`WorkOrder.AprobacionCentroDeCostos.approvalProcess-meta.xml` no fue tocado desde su última versión
funcional (commit `1d9d6039e4c2efa88d1783e46a7ade56247d28ab`, 2026-08-13, Sprint 3), ya validado
funcionalmente con datos PEKING reales en Sprint 3 (`RECONCILIACION_EJECUTIVA_SPRINT3_PEKING_20260813.md`).
No hubo cambios de Sprint 5 sobre este proceso ni sobre la definición de Centro de Costo. No se repitió la
suite completa de QA funcional (no aplica según regla de no repetir trabajo ya cerrado sin evidencia
contradictoria).

**Resultado: PASS (por inspección — sin cambios desde la última validación funcional)**, consistente con la
regla de negocio ya confirmada: el centro de costo no se separa por Empresa.

## 6. Integración Softland

Se inspeccionó la configuración de destino del cliente HTTP `RM_SoftlandClient.cls` (usa `Label.URLSoftland`
+ `Label.ambienteSoftland`, no un Named Credential dedicado):

- `URLSoftland` = `http://172.176.136.132:5080`
- `ambienteSoftland` = `IntegrationServices`

No se ejecutó ningún callout real (`postData`/`getToken`) contra este endpoint. Dos razones:

1. **Seguridad:** no fue posible confirmar con certeza, desde este entorno, que el endpoint apunta
   exclusivamente a un ambiente de pruebas aislado de producción externa (sección 23 del prompt de
   ejecución exige evitar efectos productivos cuando esto no puede garantizarse).
2. **Bloqueo natural:** el flujo real que dispara el callout de Softland (confirmación de Quote/Order) es
   posterior al paso de `QuoteLineItem`, que ya está bloqueado por `RQ329` (sección 2). No hay forma de
   alcanzar el punto de callout real con datos OMODA/JAECOO sin antes resolver ese incidente externo.

**Clasificación: `BLOQUEADO EXTERNO` / documentado hasta el punto seguro**, sin FAIL técnico atribuible a
Sprint 5. Endpoint y configuración quedan documentados para revisión de negocio/Diego.

## 7. Regresión general (Empresa configurable)

No se detectó ningún indicio de lógica binaria `if Bavarian else Otobai` reintroducida. `QuoteService.cls`
sigue resolviendo por `RM_Config__mdt` (sin cambios de Sprint 5 sobre este archivo). Los 2 `PricebookEntry`
nuevos de Actividad 13 no introdujeron hardcodes de Id ni lógica condicional: son datos, no código.

## Resumen de clasificación — Actividad 14

| Escenario | OMODA | JAECOO | Resultado | Evidencia |
|---|---|---|---|---|
| Opportunity → Quote (creación, Empresa, Pricebook, moneda) | Sí | Sí | PASS | Sección 1 |
| QuoteLineItem (inserción) | Sí | Sí | BLOQUEADO EXTERNO (RQ329) | Sección 2 |
| Work Order → Factura | Sí | Sí | BLOQUEADO EXTERNO (cascada RQ329) | Sección 3 |
| Inventario / grilla VN | Sí | Sí | PASS | Sección 4 |
| Bodega / Ubicación | Sí | Sí | PASS | Sección 4 |
| Aprobaciones (Centro de Costo) | N/A (lógica no separada por marca) | N/A | PASS (inspección) | Sección 5 |
| Integración Softland | N/A | N/A | BLOQUEADO EXTERNO (config. documentada, callout no ejecutado) | Sección 6 |
| Regresión arquitectura configurable por Empresa | N/A | N/A | PASS | Sección 7 |
