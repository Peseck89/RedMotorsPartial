# Laboratorio de cobertura — Bloque 18 (ProductSearcherController)

## Contexto

Bloque 18 permanece pausado por deuda global de cobertura del org en `RunLocalTests`
(no por la regresión externa de tráfico del Bloque 19). Estado previo confirmado:

- `ProductSearcherController`: cobertura enfocada 141/192 = 73.438%.
- Meta mínima: 144/192 = 75%.
- Meta recomendada con margen: 150/192.
- Pruebas enfocadas actuales: 14/14 (sin fallas de aserción).
- `RunLocalTests` no es viable por deuda externa del org (fuera del alcance de este laboratorio).

Este documento registra un análisis de solo pruebas: ningún archivo productivo,
manifest, Record Type, picklist ni permiso fue modificado. Trabajo realizado en:

- Worktree: `C:\Users\dokur\Documents\Repositorios\RedMotors-Bloque18-CoverageLab`
- Rama: `analysis/pc/redmotors-block18-coverage-lab-20260726`
- Base: `origin/wip/pc/redmotors-block18-product-searcher-coverage-20260726` (commits `f1ce045`, `5c287ba`)

## Hallazgo principal (Fase 1)

La rama `vehiculo` de `getProducts()` no completa su recorrido con los fixtures
existentes: `getPricesGroupByModelFantasia(brand, year)` no encuentra ningún
`Pricebook2` cuyo `Name` contenga simultáneamente la marca y el año (solo existe el
Pricebook estándar en el `@TestSetup` actual), por lo que `getProducts()` lanza la
`AuraHandledException` de "No se encontraron precios de fantasia..." antes de
construir el resto de la búsqueda. Esto deja sin ejercitar, con alta probabilidad,
las líneas 81-108, 167-200 y 241-243 de `ProductSearcherController.cls`, además de
la rama de comparación de precio de `getPricesGroupByModelFantasia` (líneas 295-297).

Se descartó, por no aportar líneas nuevas, un escenario adicional para la rama vacía
de `getProductByQuoteId` (la única `Quote` consultada sin `ORDER BY` ya devuelve,
con alta probabilidad, la que sí tiene línea de vehículo, cubriendo esa rama de forma
incidental).

## Prueba agregada (Fase 2-3)

Archivo modificado: `force-app/main/default/classes/ProductSearcherControllerTest.cls`
(única modificación: +104 líneas, 0 eliminaciones, sin tocar ningún otro archivo).

Método nuevo: `testGetProducts_Vehiculo_BMW_FullSearchReturnsExpectedVehicle`.

Reutiliza el vehículo y la Bodega ya insertados por
`TestDataFactory.createQuoteWithItems()` en el `@TestSetup` de la misma clase, y
agrega únicamente registros de datos (no metadata) mediante helpers ya existentes
de `TestDataFactory`:

1. Dos `Product2` "modelo de interés" (mismo modelo, precios distintos: 15000/9000)
   + `Pricebook2`/`PricebookEntry` de fantasía — habilita
   `getPricesGroupByModelFantasia` y ejercita la comparación de precio más alto.
2. `Configuracion_de_ventas__c` + `Pricebook2`/`PricebookEntry` "Softland" —
   habilita `RM_VN_Service.getSoftlandPriceBookId`/`gePBEBavarian` para resolver el
   vehículo real ya existente.
3. `Pricebook2` con nombre exacto `"<marca> - <año>"` + `PricebookEntry` — es el
   nombre literal que `getProducts()` arma para el precio final del vehículo
   (línea ~242, sin comodines de `LIKE`).

Aserciones agregadas verifican: ausencia de `message` de error, `totalRecords == 1`,
el `ProductoXBodega__c` devuelto corresponde al vehículo del `@TestSetup`, el precio
de fantasía conservado es el más alto (15000), el precio Softland pertenece al
vehículo, y el precio final corresponde al `Pricebook2 "<marca> - <año>"` (45000).

## Cobertura teórica estimada

**No confirmada por Tooling API ni por ejecución real.** Estimación basada solo en
lectura estática del código y los fixtores: **~25-40 líneas ejecutables adicionales**
sobre las 141/192 actuales, lo que llevaría el total a un rango aproximado de
**166-181 / 192 (≈86%-94%)** si el fixture funciona como se diseñó — muy por encima
de la meta de 75%, dejando margen incluso si parte del fixture requiere ajustes.

## Riesgos y supuestos a validar

- Cadena de 3 `Pricebook2` con nombres exactos (`"<marca>-<año> ..."` vía `LIKE`,
  y `"<marca> - <año>"` exacto sin comodines) — un error de formato en cualquiera
  rompe la prueba con un fallo de aserción claro, no una pérdida silenciosa de
  cobertura.
- Rama `Product2` `productType='Vehiculo', isVehicle=false` de
  `TestDataFactory.createProduct(...)` no está actualmente ejercitada por ningún
  test existente de este archivo (sí se usa en otras clases del repo) — riesgo bajo
  pero no cero de alguna dependencia de picklist no anticipada.
- `RM_VN_Service.addBrandFilter()` depende de que el usuario de prueba tenga acceso
  al Record Type `BMW` de `Opportunity` — ya asumido por el resto de la suite
  existente, sin cambio de riesgo.
- No se pudo confirmar con Tooling API si las líneas 81-108/167-200/241-243 estaban
  realmente descubiertas antes de este cambio; el análisis es estático.

## Comando de dry-run recomendado (no ejecutado)

```
sf project deploy validate \
  --source-dir force-app/main/default/classes/ProductSearcherController.cls \
  --source-dir force-app/main/default/classes/ProductSearcherControllerTest.cls \
  --source-dir force-app/main/default/classes/ProductSearcherControllerOtobaiTest.cls \
  --tests ProductSearcherControllerTest ProductSearcherControllerOtobaiTest \
  --test-level RunSpecifiedTests \
  --target-org RedMotorsSandbox
```

No se afirma que este parche compile ni que alcance la cobertura estimada hasta que
se valide con este dry-run real.

## Validación real del laboratorio

La validación real se ejecutó contra RedMotorsSandbox / Partial desde el worktree
aislado del laboratorio.

### Dry-run enfocado

Primer intento:

- Deploy ID: `0AfAK000000vu5V0AQ`
- Componentes: 4/4
- Pruebas: 14/15
- Cobertura temporal `ProductSearcherController`: 141/192 = 73.438%
- Falla: `Product2.Modelo_De_Inter_s__c = COOPER-S-VR-COUNT-ALL` no era válido
  para el fixture.
- Org sin modificaciones.

Segundo intento:

- Deploy ID: `0AfAK000000vu770AA`
- Componentes: 4/4
- Pruebas: 14/15
- Cobertura temporal `ProductSearcherController`: 141/192 = 73.438%
- Falla: `Product2.Modelo_De_Inter_s__c = BMW-218-GC-VR-PAQ-M` seguía siendo
  incompatible con la cadena de picklists dependientes creada por el helper.
- Org sin modificaciones.

Corrección aplicada:

- Se confirmó en RedMotorsSandbox una combinación real de `Product2` para BMW:
  `Marca__c = 'BMW'`, `Categor_a_veh_culo__c = 'Sedán'`,
  `Grupo__c = 'Serie'`, `Familia__c = 'Serie 2'`,
  `Modelo_De_Inter_s__c = 'BMW-218-GC-VR-PAQ-M'`.
- El fixture quedó limitado a `ProductSearcherControllerTest.cls`.
- No se reutilizaron IDs reales.
- No se modificó `ProductSearcherController.cls`.

Tercer intento:

- Deploy ID: `0AfAK000000vu8j0AA`
- Componentes: 4/4
- Pruebas: 15/15
- Fallas: 0
- Cobertura `ProductSearcherController`: 182/192 = 94.79%
- Líneas no cubiertas: 86, 101, 256, 272, 296, 317, 318, 332, 333, 334.
- Org sin modificaciones.

### Regresión y deploy

Dry-run de regresión:

- Deploy ID: `0AfAK000000vuAL0AY`
- Componentes: 4/4
- Pruebas: 33/33
- Fallas: 0
- Cobertura `ProductSearcherController`: 182/192 = 94.79%
- Org sin modificaciones.

Deploy real:

- Deploy ID: `0AfAK000000vuBx0AI`
- Componentes: 4/4
- Pruebas: 33/33
- Fallas: 0
- Estado: `Succeeded`
- Org: RedMotorsSandbox / Partial.

Verificación post-deploy:

- Test Run ID: `707AK00000GwtdT`
- Pruebas: 34/34
- Fallas: 0
- Resultado: `Passed`

## Resultado del laboratorio

El laboratorio permitió cerrar el Bloque 18 sin modificar código productivo
adicional. La cobertura final de `ProductSearcherController` quedó en 182/192 =
94.79%, por encima del mínimo de 75% y del objetivo recomendado de 78%.

El Bloque 18 queda completado, validado y desplegado. El cierre se hará en la
rama del laboratorio con el commit `feat(product-search): deploy configurable
company filtering`.
