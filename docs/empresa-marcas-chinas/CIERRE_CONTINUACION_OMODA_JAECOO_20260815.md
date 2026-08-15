# RedMotors / PEKING — Cierre de la continuación OMODA/JAECOO (Venta Nueva)

**Fecha:** 14-15 de agosto de 2026

**Rama de trabajo:** `feature/pc/redmotors-empresa-marcas-chinas-sprint2-flows-components-20260728`

**Relación con Sprint 4:** este documento **no reabre ni modifica** el cierre ya registrado en
[`CIERRE_IMPLEMENTACION_SPRINT4_PEKING_20260813.md`](CIERRE_IMPLEMENTACION_SPRINT4_PEKING_20260813.md)
(13 de agosto de 2026). Ese documento sigue vigente sin cambios: **Sprint 4, en su alcance
oficial, permanece CERRADO EN TODO LO IMPLEMENTABLE.**

Este documento cierra un bloque de trabajo **posterior y adicional**, autorizado directamente
durante los días 14 y 15 de agosto, que llevó el flujo funcional de Venta Nueva OMODA/JAECOO
desde la selección de inventario hasta el intento real de creación de presupuesto. Gran parte de
este trabajo avanza directamente uno de los pendientes que el cierre de Sprint 4 había dejado
abierto (el catálogo de Familia/Modelo de OMODA/JAECOO), usando datos provisionales que Luis ya
había autorizado para ese propósito exacto.

## Resumen ejecutivo

El recorrido completo de "Agregar vehículo" para OMODA y JAECOO — desde la grilla de inventario
hasta el intento de creación de `Quote`/`QuoteLineItem` — quedó implementado, desplegado y
validado. El único punto que impide completar la creación real del presupuesto es un incidente
externo y preexistente (`RQ329_INS_QuoteLineGuard`), confirmado independiente de este trabajo y
documentado por separado.

**Estado de este bloque: CERRADO EN TODO LO IMPLEMENTABLE — PENDIENTE EXTERNO: incidente
`RQ329_INS_QuoteLineGuard` (paquete administrado, fuera de este repositorio).**

## 1. Qué se pidió

Continuar, con datos provisionales ya autorizados por Luis, la validación funcional de OMODA y
JAECOO hasta el punto máximo posible sin depender de catálogo oficial ni de decisiones de negocio
nuevas — específicamente: que un usuario pueda ver inventario OMODA/JAECOO, seleccionarlo y llegar
al intento real de generar un presupuesto.

## 2. Qué se implementó — OMODA

| # | Componente | Acción | Evidencia |
|---|---|---|---|
| 1 | `Product2.recordTypes.Producto_Red_Motors` (metadata base) | Reconciliado desde Partial: la versión local estaba incompleta (21 líneas vs. 2,309 reales) | Commits `f242f55`, `09c16e8`, `7bddc28` |
| 2 | Cadena de picklists dependientes Marca→Categoría→Grupo→Familia→Modelo | `OMODA → OMODA QA → OMODA QA → OMODA QA → QA OMODA` habilitada de forma aditiva, sin alterar BMW/MINI/Motorrad/Kawasaki/Indian/Polaris | Commit `e72747f`. Dry-run `0AfAK0000015Lfx0AE`, deploy `0AfAK0000015LhZ0AU` |
| 3 | Catálogo temporal de fantasía OMODA 2026 | `Product2` `01tAK000009EFbVYAW`, `Pricebook2` "OMODA - 2026" `01sAK0000007MmzYAE`, `PricebookEntry` Standard `01uAK000000YeMQYA0` y OMODA-2026 `01uAK000000YeMRYA0` | DML directo en Partial (dato QA, no versionado en Git) |
| 4 | Unidad real de inventario OMODA | `Product2` `01tAK000009EGCbYAO` (RecordType Vehiculos, `esVehiculo__c=true`), `PricebookEntry` en "PEKING Dólares" `01uAK000000YeUVYA0` | DML directo en Partial |
| 5 | `Ubicaciones_por_Marca__c.Marca__c` | OMODA habilitado (picklist restringido local, sin GVS) | Commit `c8dfaf9`. Deploy `0AfAK0000015MFR0A2` |
| 6 | Bodega temporal PEKING | `Bodega_vehiculos_nuevos__c` false→true en `a2bAK0000000vvxYAA` ("PEKING TEMPORAL - PARTIAL - NO USAR EN PRODUCCION") | DML directo en Partial |
| 7 | Relación Marca↔Bodega y Producto↔Bodega | `Ubicaciones_por_Marca__c` `a5yAK00000048QPYAY`, `ProductoXBodega__c` `a2eAK00000035ETYAY` | DML directo en Partial |
| 8 | Visualización en grilla de inventario | Confirmado mediante invocación directa de `RM_VN_Inventario_Ctrl.getRecords`: 1 registro, precios de fantasía y Softland resueltos | Solo lectura, sin efectos secundarios |
| 9 | Resolución de bodega principal por empresa | `QuoteService.cls` ya bloqueaba RMPEKING de forma incondicional; extendido para resolver mediante `RM_Config__mdt` (`Bodega_Principal_RMPEKING = PKT01`, dato provisional) | Commit `e12cb5c`. Dry-run `0AfAK0000015Mc10AE`, deploy `0AfAK0000015Mgr0AE`. 10 pruebas automatizadas, RMBAVARIAN/RMOTOBAI sin regresión |
| 10 | Precio unitario del producto de interés QA | `Oportunidad_Producto_Interes__c` `a4KAK0000001Awb2AE`: `Precio_Unitario__c` null→1 (dato provisional) | DML directo en Partial |
| 11 | Intento real de creación de presupuesto | Alcanzado hasta el `insert` de `QuoteLineItem`; bloqueado únicamente por el incidente externo `RQ329_INS_QuoteLineGuard` (ver sección 5) | Verificación de rollback: sin registros parciales |

## 3. Qué se implementó — JAECOO

Se reutilizó íntegramente la arquitectura ya confirmada para OMODA (misma resolución de empresa
RMPEKING, misma bodega temporal, mismo mecanismo de picklists dependientes), replicando
únicamente los datos propios de la marca.

| # | Componente | Acción | Evidencia |
|---|---|---|---|
| 1 | Cadena de picklists dependientes | `JAECOO → JAECOO QA → JAECOO QA → JAECOO QA → QA JAECOO` habilitada de forma aditiva sobre el mismo `RecordType`, sin alterar ninguna marca existente (incluida OMODA) | Commit `241b509`. Dry-run `0AfAK0000015Op70AE`, deploy `0AfAK0000015Oqj0AE` |
| 2 | `Ubicaciones_por_Marca__c.Marca__c` | JAECOO habilitado junto con la cadena anterior, mismo commit/deploy | Verificado post-deploy: 8 valores activos (incluye JAECOO) |
| 3 | `Configuracion_de_ventas__c` JAECOO 2026 | `a07AK00000IjeXnYAJ`, apunta a "PEKING Dólares" (mismo Pricebook Softland que OMODA, es una configuración de empresa, no de marca) | DML directo en Partial |
| 4 | Catálogo temporal de fantasía JAECOO 2026 | `Product2` `01tAK000009EmNlYAK`, `Pricebook2` "JAECOO - 2026" `01sAK0000007OiLYAU`, `PricebookEntry` fantasía `01uAK000000YlxPYAS` | DML directo en Partial |
| 5 | Unidad real de inventario JAECOO | `Product2` `01tAK000009EmNmYAK` (RecordType Vehiculos), `PricebookEntry` en "PEKING Dólares" `01uAK000000YlxSYAS` | DML directo en Partial |
| 6 | Relación Marca↔Bodega y Producto↔Bodega | `Ubicaciones_por_Marca__c` `a5yAK0000004TZkYAM`, `ProductoXBodega__c` `a2eAK00000037bFYAQ`, misma bodega temporal ya habilitada para OMODA (sin cambio adicional necesario) | DML directo en Partial |
| 7 | Visualización en grilla de inventario | Confirmado mediante invocación directa de `RM_VN_Inventario_Ctrl.getRecords('JAECOO','2026','QA JAECOO', ...)`: 1 registro, precios de fantasía y Softland resueltos — mismo resultado exacto que OMODA | Solo lectura, sin efectos secundarios |
| 8 | Resolución de bodega principal por empresa | No requirió cambio adicional: `QuoteService.cls` resuelve JAECOO igual que OMODA (ambos mapean a `RMPEKING`); confirmado por lectura que la bodega de la unidad JAECOO ya coincide con `Bodega_Principal_RMPEKING` | Verificación de solo lectura, sin DML de prueba adicional |
| 9 | Intento real de creación de presupuesto | **No repetido deliberadamente.** El bloqueo `RQ329_INS_QuoteLineGuard` ya está confirmado como independiente de marca/empresa (afecta también a un test de BMW ya existente); repetir el intento con JAECOO no aporta evidencia nueva | Ver sección 5 |

## 4. Datos oficiales vs. datos provisionales

**Datos oficiales usados directamente (sin necesidad de autorización adicional):**

- Bodega "PEKING Dólares" (Pricebook), "PEKING TEMPORAL" (bodega física ya existente para QA),
  RecordTypes `Vehiculos` y `Producto Red Motors` (ya existentes, usados por todas las marcas).

**Datos provisionales autorizados por Luis (para avanzar QA mientras llega el catálogo oficial;
reemplazables sin cambio de código):**

- Valores de catálogo temporal: `OMODA QA` / `JAECOO QA` (Categoría, Grupo, Familia) y
  `QA OMODA` / `QA JAECOO` (Modelo) en los Global Value Sets correspondientes.
- Productos de catálogo de fantasía ("OMODA QA 2026", "JAECOO QA 2026") y sus `Pricebook2`
  ("OMODA - 2026", "JAECOO - 2026"), con `UnitPrice = 1` (precio simbólico de QA, no comercial).
- Unidades de inventario ("QAOMODA2026UNIT001", "QAJAECOO2026UNIT001") con `UnitPrice = 1`.
- `RM_Config__mdt.Bodega_Principal_RMPEKING = PKT01` — apunta a la bodega temporal de QA. Este es
  el único punto configurable que debe actualizarse (solo el valor del registro, sin tocar código
  ni hacer un nuevo deploy) cuando exista la bodega principal oficial de RMPEKING.
- `Oportunidad_Producto_Interes__c.Precio_Unitario__c = 1` en el registro de QA.

**Ningún dato oficial pendiente bloquea implementación restante** en este bloque: el único
catálogo real que faltaba (Familia/Modelo de OMODA/JAECOO, señalado como "PENDIENTE DE CATÁLOGO"
en el cierre de Sprint 4) ya tiene la autorización de negocio necesaria para avanzar con valores
provisionales, y así se hizo.

## 5. Incidente externo — `RQ329_INS_QuoteLineGuard` (separado de este cierre)

- **Naturaleza:** trigger de un paquete administrado instalado en el org (prefijo `RQ329`, sin
  código fuente en este repositorio) que falla en todo intento de crear una línea de presupuesto
  (`QuoteLineItem`), con el error `System.QueryException: Variable does not exist: tmpVar1`
  dentro de `RQ329_INS_LockGuard.assertLineChanges`.
- **Alcance del incidente:** confirmado que **no es específico de PEKING/OMODA/JAECOO** —
  reproducido de forma idéntica ejecutando una prueba automatizada ya existente sobre BMW
  (`RM_VN_QuoteController_Test.test_AgregarInventarioMismoModeloYLineItems`), que también falla
  por la misma causa.
- **Efecto transaccional:** cuando ocurre, Salesforce revierte automáticamente toda la operación
  (no queda ningún `Quote`, `QuoteLineItem` ni cambio parcial) — comportamiento estándar de la
  plataforma, no un defecto adicional.
- **Responsabilidad:** corresponde al proveedor/administrador del paquete `RQ329`, no a este
  proyecto. No se intentó ni se debe intentar corregirlo desde este repositorio.
- **Efecto sobre este cierre:** ninguno. El alcance solicitado para este bloque (llegar hasta el
  intento real de creación de presupuesto) se cumplió íntegramente; el incidente ocurre en un
  punto posterior, fuera de este alcance.

## 6. Matriz autoritativa final

| Requerimiento | Componente | Estado | Evidencia | Commit | Deploy | QA | Rollback disponible |
|---|---|---|---|---|---|---|---|
| Base real de Product2 en Git | `RecordType Producto_Red_Motors` (reconciliación) | COMPLETADO | 2,309 líneas reales vs. 21 previas | `f242f55`, `09c16e8`, `7bddc28` | N/A (solo Git) | Diff verificado, valores existentes intactos | `git revert 09c16e8` |
| Cadena de picklists OMODA | `Marca__c`/`Categor_a_veh_culo__c`/`Grupo__c`/`Familia__c`/`Modelo_De_Inter_s__c` | COMPLETADO (provisional) | +1 exacto por campo, BMW intacto | `e72747f` | `0AfAK0000015LhZ0AU` | Verificado post-deploy vía UI API | `git revert e72747f` + redeploy |
| Catálogo de fantasía OMODA | `Product2`/`Pricebook2`/`PricebookEntry` | COMPLETADO (provisional) | IDs en sección 2 | N/A (dato) | N/A (DML) | `getPBEFantasiaGroupByModel` retorna 1 | Ver sección 7 (UPDATE/DELETE documentados) |
| Inventario real OMODA | `Product2` + `PricebookEntry` Softland | COMPLETADO (provisional) | IDs en sección 2 | N/A (dato) | N/A (DML) | `getRecords` retorna 1 | Ver sección 7 |
| Ubicación OMODA | `Ubicaciones_por_Marca__c.Marca__c` | COMPLETADO | 7→8 valores | `c8dfaf9` | `0AfAK0000015MFR0A2` | Verificado post-deploy | `git revert c8dfaf9` + redeploy |
| Bodega temporal habilitada | `Bodega__c.Bodega_vehiculos_nuevos__c` | COMPLETADO | false→true | N/A (dato) | N/A (DML) | Confirmado por consulta | UPDATE a `false` (documentado) |
| Relación Marca/Producto↔Bodega OMODA | `Ubicaciones_por_Marca__c` + `ProductoXBodega__c` | COMPLETADO | IDs en sección 2 | N/A (dato) | N/A (DML) | `getRecords` end-to-end OK | DELETE de los 2 registros QA (documentado, no ejecutado) |
| Resolución de bodega principal RMPEKING | `QuoteService.cls` + `RM_Config__mdt` | COMPLETADO | Ver sección 2.9 | `e12cb5c` | `0AfAK0000015Mgr0AE` | 10/10 pruebas automatizadas | `git revert e12cb5c` + redeploy (BMW/Otobai no afectados) |
| Precio unitario OPI QA OMODA | `Oportunidad_Producto_Interes__c.Precio_Unitario__c` | COMPLETADO (provisional) | null→1 | N/A (dato) | N/A (DML) | Confirmado por consulta | UPDATE a `null` (documentado) |
| Cadena de picklists JAECOO | Mismos 5 campos, valores JAECOO | COMPLETADO (provisional) | +1 exacto por campo, OMODA/BMW intactos | `241b509` | `0AfAK0000015Oqj0AE` | Verificado post-deploy vía UI API | `git revert 241b509` + redeploy |
| Catálogo, inventario y ubicación JAECOO | `Product2`/`Pricebook2`/`PricebookEntry`/`Ubicaciones_por_Marca__c`/`ProductoXBodega__c`/`Configuracion_de_ventas__c` | COMPLETADO (provisional) | IDs en sección 3 | N/A (dato) | N/A (DML) | `getRecords` retorna 1, idéntico a OMODA | Ver sección 7 |
| Creación real de presupuesto (OMODA y JAECOO) | `Quote`/`QuoteLineItem` | BLOQUEADO POR INCIDENTE EXTERNO | `RQ329_INS_QuoteLineGuard`, reproducido también en BMW | N/A | N/A | Rollback completo confirmado, sin registros parciales | No aplica (nada que revertir) |

## 7. Backups y puntos de rollback

- **Backup externo:** `C:\Users\dokur\Documents\Auditorias-RedMotors-PEKING\Backup-JAECOO-Chain-20260815\` — copia de los 10 archivos de metadata en su estado previo a la cadena JAECOO (incluye `SHA256SUMS.txt` y `METADATA.txt` con HEAD/org/fecha de referencia). Backups equivalentes de bloques anteriores (Product2 completo, Ubicaciones_por_Marca__c) ya documentados en `CONTINUIDAD_CATALOGO_OMODA_PICKLIST_DEPENDENCIAS_20260814.md`.
- **Reversión de metadata:** cada commit funcional (`e72747f`, `c8dfaf9`, `e12cb5c`, `241b509`) es un cambio puramente aditivo y aislado; revertirlo con `git revert <commit>` y redesplegar el mismo conjunto de componentes restaura el estado anterior sin afectar otras marcas.
- **Reversión de datos QA (no ejecutada, solo documentada):**
  - `Oportunidad_Producto_Interes__c a4KAK0000001Awb2AE`: `UPDATE ... SET Precio_Unitario__c = null WHERE Id = 'a4KAK0000001Awb2AE'`.
  - `Bodega__c a2bAK0000000vvxYAA`: `UPDATE ... SET Bodega_vehiculos_nuevos__c = false WHERE Id = 'a2bAK0000000vvxYAA'` (solo si no hay otra marca dependiendo de ella en ese momento).
  - Registros QA creados (`Product2`, `Pricebook2`, `PricebookEntry`, `Ubicaciones_por_Marca__c`, `ProductoXBodega__c`, `Configuracion_de_ventas__c` de OMODA y JAECOO): eliminables individualmente por Id sin afectar ninguna otra marca, listados en las secciones 2 y 3 de este documento.
  - `RM_Config__mdt Bodega_Principal_RMPEKING`: reemplazar `Value__c` por el código de la bodega oficial cuando exista (edición del registro, sin deploy de código).

## 8. Production

**No fue tocada en ningún momento.** Todo el trabajo de este bloque (metadata y datos) se ejecutó
exclusivamente en `RedMotorsSandbox` / Partial (`redmotors--partial.sandbox.my.salesforce.com`).

## 9. Conclusión

El camino completo de venta de un vehículo OMODA o JAECOO — desde que aparece en el inventario
hasta el intento de generar el presupuesto — ya funciona en el ambiente de pruebas, usando datos
temporales autorizados mientras se recibe el catálogo oficial. Lo único que impide completar la
creación del presupuesto es una falla de un componente externo instalado en el sistema
(`RQ329`), que también afecta a las marcas ya existentes y que debe resolverse por separado, fuera
de este trabajo. En cuanto ese componente se corrija, el presupuesto debería poder crearse sin
cambios adicionales de este lado.
