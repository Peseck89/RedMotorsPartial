# Resultado — bloque previo al cierre Sprint 2: regresiones del precheck 2026-08-12

**Fecha:** 12 de agosto de 2026
**Org validada:** `RedMotorsSandbox` (Partial)
**Rama:** `feature/pc/redmotors-empresa-marcas-chinas-sprint2-flows-components-20260728`
**Alcance:** exclusivamente las 3 regresiones técnicas confirmadas por el precheck del 2026-08-12. No se abordó ningún Flow, Community/Aura, dato oficial, texto legal ni configuración provisional. Sprint 2 sigue sin declararse cerrado.

## Hallazgo 1 — precioProductoJSON.cls (regresión confirmada, corregida)

**Problema:** un payload de precio con `empresa='RMPEKING'` no tenía rama de búsqueda de `Product2`. `List<Product2> prod` quedaba `null` y `prod.size()` lanzaba `NullPointerException` no controlada.

**Causa:** el sibling `productJSON.cls` (creación de producto) ya había recibido tratamiento para `RMPEKING` (rama `RMOTOBAI || RMPEKING` sobre `CodigoProductoInterno__c`), pero `precioProductoJSON.cls` (actualización de precio) nunca se actualizó en el mismo trabajo.

**Corrección aplicada:**
- Se replicó el patrón ya establecido y probado en `productJSON.cls`: `RMPEKING` ahora comparte rama con `RMOTOBAI` (`CodigoProductoInterno__c = articulo + '-' + empresa`). No es un hardcode nuevo; es el mismo patrón de identificador ya vigente en el resto del subsistema.
- La resolución de Pricebooks Local/Dólar dejó de depender de nombres literales por compañía (`'Bavarian Local'`, `'Otobai Local'`, …). Ahora se resuelve dinámicamente vía el modelo Empresa: se busca `Empresa__c` por `Codigo_ERP__c`/`Activa__c`, y los Pricebooks se obtienen por `Pricebook2.Empresa__c` (lookup) + `IsActive = true`, separando Local/Dólar por el nombre ya estandarizado (`contains('Local')`). Esto cubre Bavarian, Otobai y Peking sin ramas nuevas por compañía, y cualquier empresa futura que reciba sus propios Pricebooks vinculados vía `Empresa__c` funcionará sin tocar esta clase de nuevo.

**Limitación documentada (no corregida en este bloque):** `EmpresaResolver.resolveByCodigo` (la utilidad "oficial" para resolver Empresa) exige `Nombre_Legal__c` poblado. Se verificó en `RedMotorsSandbox` que **las tres Empresas (Bavarian, Otobai, Peking) tienen `Nombre_Legal__c` vacío**. Usar `EmpresaResolver` aquí habría roto también a Bavarian y Otobai. Por eso se implementó una resolución directa y más liviana (`SELECT Id FROM Empresa__c WHERE Codigo_ERP__c = :empresa AND Activa__c = true`) que no depende de ese campo. Queda pendiente para un bloque futuro: decidir si se puebla `Nombre_Legal__c` en las 3 Empresas o si se relaja esa validación en `EmpresaResolver`; no se inventó ningún valor oficial para ese campo.

**Hallazgo adicional fuera de alcance (no corregido):** al construir el caso de prueba de Peking se detectó que `precioProductoJSON.cls` llama `Decimal.valueOf(precio_empleado)` sin guarda de nulo (a diferencia de `Porcentaje_vendedor`/`Porcentaje_jefe`, que sí están guardados) al insertar un `PricebookEntry` nuevo. Este defecto es preexistente, afecta a las tres empresas por igual, y las pruebas de Bavarian/Otobai nunca lo detectaron porque no verifican el resultado de la segunda llamada a `createProduct`. No se corrigió por no ser parte de las regresiones confirmadas del precheck; se deja documentado para evaluación futura.

**Pruebas:** `precioProductoJSONTest.testprecioProductoJSONPeking` (nueva). Confirma que un payload `RMPEKING` sin producto existente no produce error 500, y que tras crear el producto la actualización resuelve correctamente los Pricebooks `PEKING Local`/`PEKING Dólares` vía `Empresa__c`. `testprecioProductoJSONBavarian` y `testprecioProductoJSONOtobai` (preexistentes) se ejecutaron sin cambios de comportamiento.

## Hallazgo 2 — familia de 8 schedulers Softland (NO es una regresión — confirmado y documentado, sin cambios de código)

**Precheck original:** afirmaba que 6 de 8 clases `Schedule*Softland.cls` habían sustituido `RMOTOBAI` por `RMPEKING` en vez de agregar Pekín conservando Otobai.

**Verificación realizada:** se revisó el historial completo (`git log -p`) de las 8 clases y de sus `Batch*Softland.cls` correspondientes, incluyendo el commit `58c0809` ("chore(sprint3): reconcile PEKING Softland catalog support", 2026-08-06) que introdujo el soporte de Pekín, y el commit de reconciliación de Sprint 1 (`6f8411d`) previo a este.

**Conclusión:** las 6 clases señaladas (`CondicionPago`, `Impuesto`, `CategoriaCliente`, `CuentaContable`, `CentroCosto`, `SubtipoDocumento`) **nunca sincronizaron Otobai**, ni antes ni después del commit `58c0809`, ni siquiera en su versión original de Sprint 1 (todas usaban `compania=RMBAVARIAN` fijo, sin parámetro de compañía). El commit `58c0809` agregó parametrización por compañía y encoló `RMBAVARIAN` + `RMPEKING`; no quitó nada que Otobai tuviera. Además, el propio documento `RESULTADO_B11_1_CATALOGOS_SOFTLAND_20260806.md` (sección "Comportamiento conciliado") deja constancia explícita y contemporánea: *"Ninguno de los seis schedulers productivos agrega RMOTOBAI a la ejecución operativa"* — es decir, la exclusión de Otobai en esos 6 catálogos fue una decisión conocida y documentada el 2026-08-06, no un efecto colateral accidental del trabajo de Pekín.

Las otras 2 clases de la familia de 8 (`ScheduleGetActividadComercialSoftland`, `ScheduleGetBodegaSoftland`) sí sincronizan `RMBAVARIAN` + `RMOTOBAI` y no fueron tocadas por el commit de Pekín; es probable que la similitud estructural entre las 8 clases haya llevado al precheck a asumir (incorrectamente) que las otras 6 debían tener el mismo patrón.

**Decisión (Luis/Diego vía sesión activa, 2026-08-12):** no se modifica código. Agregar Otobai a estos 6 catálogos sería una funcionalidad **nueva** (nunca existió), no la corrección de una regresión, y por tanto requiere autorización de negocio explícita fuera de este bloque. Se deja fuera de alcance.

**Sin cambios de código ni de pruebas para este hallazgo.**

## Hallazgo 3 — BatchGetCatalogoSoftland.calloutBodega (riesgo confirmado, corregido preventivamente)

**Problema:** la clave externa de `Bodega__c` (`ID_EXTERNO_BODEGA__c`) solo prefijaba el código crudo de Softland para `RMOTOBAI`. Cualquier otra compañía (`RMBAVARIAN` hoy; `RMPEKING` el día que se habilite en `ScheduleGetBodegaSoftland`, lo cual **no** se hizo en este bloque) usaba el código de bodega sin prefijo. Si dos compañías comparten el mismo código Softland de bodega, sus registros colisionarían en el upsert (Bavarian sobrescribiría a Pekín o viceversa).

**Estado actual de la sincronización de Bodega:** `ScheduleGetBodegaSoftland` sigue sincronizando únicamente `RMBAVARIAN` + `RMOTOBAI` (no se modificó; no se agregó Pekín — eso pertenece a un bloque posterior con datos oficiales de bodega, según lo pendiente documentado en `RESULTADO_B11_1_CATALOGOS_SOFTLAND_20260806.md`). El riesgo era **latente**, no materializado todavía.

**Corrección aplicada:** en `BatchGetCatalogoSoftland.calloutBodega`, la clave externa ahora se deriva del código de compañía (`company`, que ya es el mismo valor `Codigo_ERP__c`/`Codigo__c` de `Empresa__c`) de forma genérica:
- `RMBAVARIAN` conserva exactamente el formato histórico sin prefijo (compatibilidad total con bodegas ya sincronizadas — cero riesgo de duplicados).
- Cualquier otra compañía (`RMOTOBAI` hoy, `RMPEKING` cuando se habilite, y cualquier compañía futura) recibe su propio código como prefijo, evitando colisión entre compañías sin necesidad de agregar una rama nueva por cada compañía futura.
- El prefijo de `RMOTOBAI` se mantiene byte-a-byte idéntico al histórico (`'RMOTOBAI' + código`), por lo que no se generan duplicados sobre bodegas de Otobai ya sincronizadas.

**Pruebas:** 4 pruebas nuevas en `BatchGetCatalogoSoftlandTest.cls`:
- `testCalloutBodegaRMBAVARIANKeepsUnprefixedExternalId`
- `testCalloutBodegaRMOTOBAIKeepsHistoricalPrefix`
- `testCalloutBodegaRMPEKINGGetsOwnPrefix`
- `testBodegaExternalIdsDoNotCollideAcrossEmpresasWithSameSoftlandCode` (verifica directamente, sin callout, que tres compañías con el mismo código crudo de Softland producen tres registros de `Bodega__c` distintos)

Nota técnica: cada compañía sincroniza Bodega en su propio `Queueable` (`System.enqueueJob` independiente por compañía en el scheduler real), es decir en transacciones separadas. Por eso las pruebas de `calloutBodega` ejercitan una compañía por método/transacción — encadenar callout+DML de varias compañías dentro de una misma transacción de prueba dispara la restricción real de Salesforce *"You have uncommitted work pending... before calling out"*, que no ocurre en producción.

## Pruebas ejecutadas (evidencia)

Deploy dirigido a `RedMotorsSandbox` (`sf project deploy start`) limitado exclusivamente a los 4 archivos modificados, con `--test-level RunSpecifiedTests`:

| Clase de prueba | Métodos | Resultado |
|---|---:|---|
| `precioProductoJSONTest` | 3 (incluye 1 nueva) | 3/3 aprobados |
| `BatchGetCatalogoSoftlandTest` | 16 (incluye 4 nuevas) | 16/16 aprobados |
| **Total** | **19** | **19/19 aprobados, 0 fallos** |

No se ejecutó ningún deploy adicional. No se tocó Production. No se crearon bodegas, territorios ni registros provisionales. No se modificaron Flows, LWC ni Aura.

## Impacto por empresa

- **Bavarian:** sin cambios de comportamiento. Pricebooks y `Bodega__c` siguen resolviéndose exactamente igual que antes (verificado con pruebas dedicadas).
- **Otobai:** sin cambios de comportamiento. Prefijo de `Bodega__c` idéntico al histórico. Los 6 catálogos que nunca sincronizó siguen sin sincronizar (decisión de negocio, no regresión).
- **Peking:** ya no produce error 500 por NPE al actualizar precio. Pricebooks `PEKING Local`/`PEKING Dólares` se resuelven correctamente vía `Empresa__c`. Si en el futuro se habilita su sincronización de Bodega, tendrá clave externa propia sin riesgo de colisión con Bavarian u Otobai.

## Riesgos restantes

1. `EmpresaResolver.resolveByCodigo` no es utilizable hoy para ninguna empresa (Bavarian, Otobai, Peking) porque `Nombre_Legal__c` está vacío en las tres. Cualquier código futuro que dependa de esa utilidad fallará hasta que se pueble ese campo o se ajuste la validación.
2. `precioProductoJSON.cls` puede lanzar error 500 si un payload de precio llega sin `precio_empleado` y no existe aún un `PricebookEntry` local/dólar para el producto (defecto preexistente, no introducido por Pekín, no corregido en este bloque).
3. La sincronización de Bodega para Pekín sigue sin habilitarse (no se tocó `ScheduleGetBodegaSoftland`); cuando se habilite con datos oficiales, la clave externa ya quedará correctamente aislada por compañía gracias a este bloque.

## Listo para el siguiente bloque

Sprint 2 sigue sin cerrarse. Los 5 Flows bloqueados N2/N3/N4, Community/Aura, datos oficiales, textos legales y configuración provisional siguen fuera de alcance hasta autorización explícita de Luis/Diego.
