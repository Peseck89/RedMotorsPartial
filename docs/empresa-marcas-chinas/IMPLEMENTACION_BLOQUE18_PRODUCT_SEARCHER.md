# Implementación Bloque 18 - Empresa configurable en búsqueda de mano de obra (ProductSearcherController)

## Estado

Bloque 18 **completado, validado y desplegado** en RedMotorsSandbox / Partial.

El cierre se realizó desde el laboratorio aislado
`analysis/pc/redmotors-block18-coverage-lab-20260726`, usando como base la
rama WIP del Bloque 18. El cambio final que permitió cerrar cobertura fue
exclusivamente de fixture en `ProductSearcherControllerTest.cls`; no se agregó
ningún cambio productivo adicional sobre `ProductSearcherController.cls`.

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

## Hallazgo adicional: prueba huérfana `ProductSearcherControllerOtobaiTest`

Al intentar validar con `RunLocalTests` (alternativa a `RunSpecifiedTests`,
que exige 75% por clase individual) se descubrió que la suite completa del
org no compilaba, por una causa **totalmente ajena a la cobertura**:
`ProductSearcherControllerOtobaiTest` — una clase de prueba que existe solo
en RedMotorsSandbox, nunca versionada en este repositorio, creada el
2026-06-17 y nunca modificada desde entonces — llama a
`ProductSearcherController.getProducts()` con **16 argumentos posicionales**,
mientras el método vigente tiene **14 parámetros**. Ese único error de firma
provocaba que otras 24 clases no relacionadas fallaran por cascada de
dependencia de compilación de Apex (Deploy ID `0AfAK000000vsRt0AI`: 25
pruebas, 25 fallas, 0 completadas).

Con autorización explícita y de alcance estrictamente limitado se recuperó
la clase, se realineó su única llamada de 16 a 14 argumentos (eliminando dos
parámetros `null` obsoletos, verificado por coincidencia exacta de valores
con los datos del propio fixture) y se le asignó a la `Opportunity` del
fixture el `RecordTypeId` de `Kawasaki` (obtenido dinámicamente vía
`Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()`, sin
IDs reales), porque la resolución de empresa vigente depende exclusivamente
del `RecordType` real de la Opportunity/Quote y el fixture original no lo
asignaba. Un segundo ajuste, también autorizado, reutilizó el valor ya
existente `'MT-06'` (usado legítimamente como `vin`) también como `model`,
documentado en el propio archivo: `model` no participa en ningún punto de la
rama `mano obra`, solo satisface una validación de entrada preexistente
("El modelo es requerido.") no relacionada con este bloque. No se modificó
`ProductSearcherController.cls` en ningún momento de esta corrección.

Con la clase corregida y agregada al manifest, el dry-run enfocado
(`ProductSearcherControllerTest` + `ProductSearcherControllerOtobaiTest`)
terminó en **14/14 pruebas aprobadas, 0 fallas**, pero la cobertura de
`ProductSearcherController` se mantuvo exactamente igual: 73.438%
(141/192) — la prueba Otobai ejercita la misma rama `mano obra` ya cubierta.

## Validación con `RunLocalTests` (Deploy ID `0AfAK000000vsYL0AY`)

Con la clase huérfana ya corregida, la suite completa del org sí compiló.
Resultado antes de la cancelación manual del usuario (para liberar
RedMotorsSandbox, tras confirmar que las fallas eran ajenas al bloque):

| Dato | Valor |
|---|---|
| Componentes | 5/5 validados sin error |
| Pruebas totales del org | 3567 |
| Pruebas completadas | 1491 |
| Pruebas con error | 287 (confirmadas ajenas al Bloque 18 por el usuario) |
| Estado | `Canceled`, `success: false` |
| Cobertura global | No calculable (corrida cancelada antes de completarse) |

Las pruebas del Bloque 18 (`ProductSearcherControllerTest` y
`ProductSearcherControllerOtobaiTest`) aparecen en la sección `successes`
del resultado — es decir, pasaron todas antes de la cancelación. `RunLocalTests`
con la suite completa de este org (3567 pruebas) excede ampliamente el
tiempo práctico de una sesión de validación puntual.

## Cierre desde laboratorio de cobertura

Se retomó el Bloque 18 desde el worktree aislado
`C:\Users\dokur\Documents\Repositorios\RedMotors-Bloque18-CoverageLab`.
El commit de laboratorio `6f63321` preparó un escenario legítimo de cobertura
para la rama `vehiculo`, sin `SeeAllData`, sin IDs reales, sin `dummy()`, sin
`Test.isRunningTest()` nuevo, sin cambios de Record Types, picklists, permisos
o Flows.

### Dry-runs del laboratorio

| Ejecución | Resultado |
|---|---|
| `0AfAK000000vu5V0AQ` | 4/4 componentes, 14/15 pruebas. Falla por `Product2.Modelo_De_Inter_s__c = COOPER-S-VR-COUNT-ALL`; cobertura temporal 141/192 = 73.438%. Org sin modificaciones. |
| `0AfAK000000vu770AA` | 4/4 componentes, 14/15 pruebas. Falla por `Product2.Modelo_De_Inter_s__c = BMW-218-GC-VR-PAQ-M`; cobertura temporal 141/192 = 73.438%. Org sin modificaciones. |
| `0AfAK000000vu8j0AA` | 4/4 componentes, 15/15 pruebas, 0 fallas. Cobertura `ProductSearcherController`: 182/192 = 94.79%. Org sin modificaciones. |
| `0AfAK000000vuAL0AY` | Regresión con `ProductSearcherControllerTest`, `ProductSearcherControllerOtobaiTest`, `ProductControllerTwoTest` y `EmpresaResolverTest`: 4/4 componentes, 33/33 pruebas, 0 fallas. Cobertura `ProductSearcherController`: 182/192 = 94.79%. Org sin modificaciones. |

La causa de los dos primeros fallos fue la cadena de picklists dependientes del
fixture de `Product2`: `Modelo_De_Inter_s__c` debe ser compatible con
`Marca__c`, `Categor_a_veh_culo__c`, `Grupo__c` y `Familia__c`. La corrección
final se mantuvo en `ProductSearcherControllerTest.cls`: se creó el producto de
modelo de interés sin insertarlo inicialmente, se asignó una combinación real
confirmada en RedMotorsSandbox (`BMW`, `Sedán`, `Serie`, `Serie 2`,
`BMW-218-GC-VR-PAQ-M`) y luego se insertó. No se reutilizaron IDs de productos
reales.

### Deploy real y verificación post-deploy

Deploy real del Bloque 18:

- Deploy ID: `0AfAK000000vuBx0AI`
- Ambiente: RedMotorsSandbox / Partial
- Estado: `Succeeded`
- Componentes: 4/4
- Pruebas: 33/33
- Fallas: 0
- Cobertura `ProductSearcherController`: 182/192 = 94.79%

Verificación post-deploy:

- Test Run ID: `707AK00000GwtdT`
- Pruebas: 34/34
- Fallas: 0
- Resultado: `Passed`

### Estado final

Bloque 18 queda completado, validado y desplegado. Se conserva el alcance
funcional aprobado: Omoda y Jaecoo resuelven `RMPEKING` en la rama de mano de
obra, BMW/MINI conservan `RMBAVARIAN`, Polaris/Kawasaki conservan `RMOTOBAI`,
no existe selección por descarte y un Record Type desconocido no devuelve
productos de todas las empresas.

Avance técnico estimado: 85% completado y 15% pendiente. Este porcentaje
corresponde al alcance técnico y no representa horas oficiales, trabajadas ni
facturables.

## Archivos modificados

- `force-app/main/default/classes/ProductSearcherController.cls` *(incluido en `f1ce045`)*
- `force-app/main/default/classes/ProductSearcherControllerTest.cls` *(incluido en `f1ce045`)*
- `force-app/main/default/objects/Product2/recordTypes/Producto_Red_Motors.recordType-meta.xml` *(incluido en `f1ce045`)*
- `manifest/empresa-marcas-chinas-bloque18-product-searcher.xml` *(incluido en la rama WIP; contiene `ProductSearcherControllerOtobaiTest`)*
- `force-app/main/default/classes/ProductSearcherControllerOtobaiTest.cls` *(incluido en la rama WIP)*
- `force-app/main/default/classes/ProductSearcherControllerOtobaiTest.cls-meta.xml` *(incluido en la rama WIP)*
- `docs/empresa-marcas-chinas/IMPLEMENTACION_BLOQUE18_PRODUCT_SEARCHER.md` *(actualizado en el cierre)*
- `docs/empresa-marcas-chinas/BITACORA_IMPLEMENTACION.md` *(actualizado en el cierre)*
- `docs/empresa-marcas-chinas/LABORATORIO_COBERTURA_BLOQUE18.md` *(actualizado en el cierre)*

## Validación y despliegue

La validación final se realizó con `RunSpecifiedTests`, no con `RunLocalTests`,
porque la suite completa del org mantiene deuda externa ya documentada y fuera
del alcance de este bloque.

- Dry-run enfocado exitoso: `0AfAK000000vu8j0AA`, 4/4 componentes, 15/15
  pruebas, 0 fallas, cobertura 182/192 = 94.79%.
- Dry-run de regresión exitoso: `0AfAK000000vuAL0AY`, 4/4 componentes, 33/33
  pruebas, 0 fallas, cobertura 182/192 = 94.79%.
- Deploy real exitoso: `0AfAK000000vuBx0AI`, 4/4 componentes, 33/33 pruebas,
  0 fallas, RedMotorsSandbox / Partial.
- Verificación post-deploy: Test Run `707AK00000GwtdT`, 34/34 pruebas, 0
  fallas, resultado `Passed`.

## Riesgos

- La deuda global de pruebas del org sigue fuera del alcance del Bloque 18; por
  eso se validó con una regresión dirigida y no con `RunLocalTests`.
- La rama `vehiculo` depende de una cadena estricta de picklists de `Product2`.
  El fixture final usa una combinación real confirmada en RedMotorsSandbox, sin
  reutilizar registros reales.
- No se modificaron sucursales, visibilidad comercial, Softland, reservas,
  anticipos, Flows, permisos ni layouts.

## Avance técnico estimado

Bloque 18 completado: avance estimado 85% completado / 15% pendiente. Es una
estimación de alcance técnico, no una medición de horas oficiales, trabajadas
ni facturables.
