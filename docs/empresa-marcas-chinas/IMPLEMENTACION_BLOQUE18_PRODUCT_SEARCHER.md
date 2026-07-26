# Implementación Bloque 18 - Empresa configurable en búsqueda de mano de obra (ProductSearcherController)

## Estado

Bloque 18 **pausado**. Código productivo y de prueba listos y verificados
localmente (13/13 pruebas pasan), pero **sin deploy, sin commit y sin push**
porque la cobertura de `ProductSearcherController` (73.438%) queda por debajo
del mínimo de 75% exigido por el org para cualquier deploy con
`RunSpecifiedTests`, incluso en sandbox.

## Autorización

Luis autorizó modificar únicamente `ProductSearcherController.getProducts()`,
exclusivamente en la rama `productType.contains('mano obra')`, con el mapeo:

- BMW, MINI → `RMBAVARIAN`
- Polaris, Kawasaki → `RMOTOBAI`
- Omoda, Jaecoo → `RMPEKING`
- Record Type no reconocido → sin selección por descarte (no `LIKE '%%'`)

Durante la ejecución se autorizó, de forma explícita y puntual, ampliar el
alcance dos veces:

1. Agregar `RMPEKING` a la restricción de picklist de `Empresa__c` en el
   Record Type `Product2.Producto_Red_Motors` (bloqueaba incluso los
   escenarios de mano de obra).
2. Construir un fixture de la rama `vehiculo` (solo en el archivo de test)
   para intentar cerrar la brecha de cobertura hacia el 75%. Este segundo
   intento se revirtió por completo tras encontrar limitaciones de
   configuración del org que no se pudieron resolver sin acceso a Setup.

## Alcance implementado

### `ProductSearcherController.cls`

En la rama `productType.contains('mano obra')` de `getProducts()`:

- La variable `companyName` (con literales `'Bavarian'`/`'otobai'` y
  `Empresa__c LIKE '%...%'`) fue reemplazada por `companyCode` con los
  códigos exactos `RMBAVARIAN`/`RMOTOBAI`/`RMPEKING` y comparación exacta
  `Empresa__c = :companyCode`.
- Se agregó la rama `else if (recordTypeName == 'Omoda' || recordTypeName == 'Jaecoo')`.
- Se agregó `if (String.isBlank(companyCode)) { return responseMap; }` antes
  de construir el filtro, replicando el patrón ya existente en la rama
  `vehiculo` (línea de `prodIds.isEmpty()`) de responder de forma vacía y
  compatible con el contrato actual, sin lanzar excepción.
- Se eliminó el método `dummy()` (350 líneas de asignaciones artificiales sin
  llamadores productivos en todo el repositorio, confirmado con `git grep`),
  porque la prueba ya no lo invocaba para inflar cobertura y esa práctica
  quedó explícitamente prohibida para este bloque.
- No se tocaron las ramas `vehiculo`, `extra`, `RM_VN_Service`, ni el resto
  del método.

### `Product2.Producto_Red_Motors` (RecordType)

`force-app/main/default/objects/Product2/recordTypes/Producto_Red_Motors.recordType-meta.xml`
(recuperado desde RedMotorsSandbox porque no estaba versionado localmente)
recibió una nueva sección `<picklistValues>` para `Empresa__c` con
`RMBAVARIAN`, `RMOTOBAI` y `RMPEKING`, los tres con `default=false`. Sin este
cambio, ningún producto de mano de obra con `Empresa__c = 'RMPEKING'` podía
insertarse bajo ese Record Type (error `INVALID_OR_NULL_FOR_RESTRICTED_PICKLIST`).

Se eliminó `Product2.object-meta.xml`, recuperado únicamente como referencia
técnica del mismo `retrieve`, sin cambio funcional (mismo criterio que el
Bloque 17).

### `ProductSearcherControllerTest.cls`

Reescrito con 13 métodos de prueba, con datos autocontenidos (sin
`SeeAllData`, sin IDs reales):

1. `testManoObra_BMW_ReturnsOnlyBavarian`
2. `testManoObra_MINI_ReturnsOnlyBavarian`
3. `testManoObra_Polaris_ReturnsOnlyOtobai`
4. `testManoObra_Kawasaki_ReturnsOnlyOtobai`
5. `testManoObra_Omoda_ReturnsOnlyPeking`
6. `testManoObra_Jaecoo_ReturnsOnlyPeking`
7. `testManoObra_UnknownRecordType_ReturnsEmptyResult_ViaOpportunity`
8. `testManoObra_NoMatchingProductName_ReturnsEmptyProductsList`
9. `testGetProducts_ValidationMessages` (marca/año/modelo en blanco)
10. `testGetProducts_ManoObra_RequiresRecordId`
11. `testGetWorkSteps` (fortalecido, cubre variantes de `vehiculoTransito`/`bodegaId`/`vin`/`productName` ya existentes en la rama vehículo/extra, sin modificarla)
12. `test_GetProductDataFromOLI`
13. `test_GetOpportunityByQuote`

Cada escenario de mano de obra valida: que solo aparezca el producto de la
empresa esperada, que el producto inactivo quede excluido, que ningún
producto de otra empresa aparezca, y que el `PricebookEntry` devuelto
pertenezca al Pricebook efectivo de la Quote (verificado indirectamente,
porque la consulta productiva no selecciona `Pricebook2Id`).

Los datos se identifican por `Campana__c` (única para este bloque) +
`RT_Lead__c`, y por `OpportunityId`/`Product2.Name`, no por `Name` de
`Opportunity`/`Quote` — se confirmó que este org recalcula esos campos con
una automatización, lo que hacía fallar las búsquedas por nombre literal.

## Fuera de alcance

No se modificaron:

- las ramas `vehiculo` y `extra` de `getProducts()`;
- `RM_VN_Service`;
- sucursales, Softland, reservas ni anticipos;
- `Product2.Categor_a_veh_culo__c` (ya resuelto en el fixture de mano de obra reutilizando `TestDataFactory.createProduct`);
- perfiles, layouts, Lightning Record Pages ni Permission Sets adicionales a los ya cerrados en el Bloque 17.

## Cobertura y bloqueo de deploy

| Métrica | Valor |
|---|---|
| Pruebas ejecutadas | 13 |
| Fallas | 0 |
| Cobertura de `ProductSearcherController` | 73.438% (141/192 líneas) |
| Mínimo exigido por el org | 75% |
| Resultado del dry-run | `"success": false` (bloquea el deploy real) |

Las 51 líneas sin cubrir corresponden casi en su totalidad a la rama
`vehiculo`: el bloque de precios de fantasía
(`getPricesGroupByModelFantasia`, líneas 81-107 y 291-299 del archivo
original), el segundo bloque de filtros de vehículo (líneas 169-198,
inalcanzable sin lo anterior porque el código lanza una excepción antes de
llegar ahí), y la ruta de paginación/precio compartida que depende de que
existan datos reales de "lista de precios de fantasía". El resto son bloques
`catch` que no se ejecutan en un test exitoso o que están protegidos por
`Test.isRunningTest()` (inalcanzables desde cualquier test).

### Intento de cierre autorizado (revertido)

Con autorización explícita para construir fixtures de la rama vehículo
(solo en el archivo de test), se intentó y se revirtió por completo tras
tres obstáculos técnicos independientes:

1. `Categor_a_veh_culo__c` — picklist restringido por Record Type (ya
   resuelto reutilizando `TestDataFactory.createProduct`).
2. `Modelo_De_Inter_s__c` — mismo tipo de restricción, requerido por
   `getPricesGroupByModelFantasia`. Se verificó, primero en el archivo local
   y luego recuperando temporalmente `RecordType:Product2.Producto_Red_Motros`
   desde RedMotorsSandbox (con respaldo y restauración de la versión
   autorizada), que **no existe ninguna sección `Modelo_De_Inter_s__c`** en
   ese Record Type — el campo no tiene ningún valor habilitado ahí, ni en el
   repositorio ni en el org real.
3. `Schema.RecordTypeInfo.getPicklistValuesForField(SObjectField)` no existe
   en la `apiVersion` 55.0 de las clases de este bloque (error de
   compilación confirmado por el deploy).
4. Un sondeo autocontenido (insertar cada valor candidato hasta encontrar
   uno aceptado) agotó el límite de 150 DML statements por transacción sin
   encontrar ninguno válido.

Cerrar esta brecha requiere que alguien con acceso a Setup habilite al menos
un valor de `Modelo_De_Inter_s__c` para el Record Type `Producto_Red_Motros`
(Object Manager → Product2 → Modelo de Interés → editar valores por Record
Type), o una decisión alternativa sobre el alcance de cobertura exigido.

## Archivos modificados (sin commitear)

- `force-app/main/default/classes/ProductSearcherController.cls`
- `force-app/main/default/classes/ProductSearcherControllerTest.cls`
- `force-app/main/default/objects/Product2/recordTypes/Producto_Red_Motors.recordType-meta.xml` (nuevo)
- `manifest/empresa-marcas-chinas-bloque18-product-searcher.xml` (nuevo, incluye `ApexClass` y `RecordType`)
- `docs/empresa-marcas-chinas/IMPLEMENTACION_BLOQUE18_PRODUCT_SEARCHER.md` (este archivo)
- `docs/empresa-marcas-chinas/BITACORA_IMPLEMENTACION.md`

## Validación y despliegue

No se ejecutó ningún deploy real. Los dry-runs (`--dry-run --test-level RunSpecifiedTests --tests ProductSearcherControllerTest`) alcanzaron 0 fallas de prueba de forma estable, pero el resultado general del deploy permanece en `"success": false` por la cobertura de clase por debajo del 75%.

## Riesgos

- El código productivo (mapeo de empresa) está listo y verificado con 13
  pruebas pasando, pero no puede desplegarse hasta resolver la cobertura.
- La configuración de picklist por Record Type de `Modelo_De_Inter_s__c` es
  un hallazgo que probablemente también afecta a otros flujos de la rama
  `vehiculo` fuera de este bloque, no solo a la cobertura de pruebas.

## Avance técnico estimado

No aplica todavía — el bloque no se ha desplegado. Si se completa y despliega
tal como está especificado, el avance estimado pasaría de 84% (cierre del
Bloque 17) a 85% completado / 15% pendiente. Es una estimación de alcance
técnico, no una medición de horas oficiales, trabajadas ni facturables.
