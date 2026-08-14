# RedMotors / PEKING — Recuperación histórica de dependencias Apex

Fecha: 2026-08-14

Rama de trabajo: `feature/luis/peking-recuperacion-dependencias-apex-20260814`

Rama base revisada: `feature/pc/redmotors-empresa-marcas-chinas-sprint2-flows-components-20260728`

HEAD base usado: `8c0a9d3da9df78bee8eb0f7e4705359f91237e4b`

## Alcance

Este documento revisa únicamente la recuperación histórica de dos dependencias Apex faltantes:

1. `RM_VN_CrearOportunidad_Ctrl.getProducts`, usado por `rm_vn_crear_opp_inventario`.
2. `BusquedaDetalladaController.updateFreshPriceFromSoftland`, usado por `busquedaDetallada`.

No se implementó código, no se modificó metadata funcional y no se tocó Salesforce.

La revisión se hizo contra el historial completo del repositorio, usando un mirror local de Git con todas las ramas disponibles al momento de la revisión. El mirror contiene 72 refs de rama.

## Resultado ejecutivo

| ID | Dependencia | Consumidor | Estado | Evidencia histórica | Código recuperable | Acción recomendada |
| --- | --- | --- | --- | --- | --- | --- |
| D1 | `RM_VN_CrearOportunidad_Ctrl.getProducts` | `force-app/main/default/lwc/rm_vn_crear_opp_inventario/rm_vn_crear_opp_inventario.js` | BLOQUEADO | El LWC importa el método desde el commit inicial `35fe2e1`, y el test histórico deja una llamada comentada, pero no existe ningún método Apex con ese nombre en `RM_VN_CrearOportunidad_Ctrl` en todo el historial revisado. | NO | No recuperar por copia. Definir implementación nueva o adaptar el LWC a un servicio existente, con contrato explícito y pruebas. |
| D2 | `BusquedaDetalladaController.updateFreshPriceFromSoftland` | `force-app/main/default/lwc/busquedaDetallada/busquedaDetallada.js` | BLOQUEADO | El import aparece en LWC en `106918c`, junto con imports equivalentes en `qoSearchDetailProduct` y `woSearchDetailProduct`, pero no existe implementación Apex histórica en `BusquedaDetalladaController`, `WoliGridController` ni `WoliGridController2`. | NO | No recuperar por copia. Crear wrapper nuevo si el equipo decide habilitar la actualización de precio fresco. Debe quedar PEKING-safe y probado. |

## D1 — `RM_VN_CrearOportunidad_Ctrl.getProducts`

### Evidencia encontrada

En el commit inicial `35fe2e1 Initial commit`, el LWC `rm_vn_crear_opp_inventario` ya contiene:

- import a `@salesforce/apex/RM_VN_CrearOportunidad_Ctrl.getProducts`;
- llamada `@wire(getProducts, ...)`;
- consumo de una respuesta tipo mapa.

El test histórico `RM_VN_CrearOportunidad_Ctrl_Test.cls` contiene una llamada comentada:

`RM_VN_CrearOportunidad_Ctrl.getProducts(brand, year, productCode, bodegaId, vin, internalColor, externalColor, model, tipoCombustible, pageNumber)`

Sin embargo, al revisar el historial completo no aparece una implementación Apex real de `getProducts` dentro de `RM_VN_CrearOportunidad_Ctrl.cls`.

### Contrato inferido por el LWC

El LWC llama el método con estos parámetros nombrados:

- `productCode`
- `bodegaId`
- `year`
- `vin`
- `brand`
- `internalColor`
- `externalColor`
- `model`
- `tipoCombustible`
- `pageNumber`

El LWC espera una respuesta con estas llaves:

- `records`
- `preciosFantasia`
- `preciosBavarian`
- `totalRecords`
- `pageSize`

Y usa `records` como lista de inventario relacionada con `ProductoXBodega__c` / `Producto__r`.

### Implementaciones parecidas, pero no equivalentes

Se encontraron métodos históricos parecidos, pero ninguno es una recuperación segura:

1. `ProductSearcherController.getProducts(...)`

   Existe en Apex, pero su contrato es diferente. Recibe más parámetros, incluyendo `productType`, `productName`, `family`, `recordId` y `vehiculoTransito`. Además la respuesta usa llaves como `products`, `prices`, `preciosBavarian` y `preciosFantasia`, no el contrato exacto esperado por `rm_vn_crear_opp_inventario`.

2. `RM_VN_Inventario_Ctrl.getRecords(...)`

   Es funcionalmente cercano porque devuelve inventario paginado con `records`, `totalRecords` y `pageSize`, pero no es el método esperado por el LWC. También usa `preciosSoftland`, no `preciosBavarian`, y su firma incluye filtros adicionales como `locationId`, `family`, `reportado`, `numeroPedido`, `vehiculoTransito` y `skipPagination`.

Por lo tanto, copiar o redirigir sin rediseño puede romper el contrato visual del LWC o cambiar la semántica de precios.

### Dictamen

`RM_VN_CrearOportunidad_Ctrl.getProducts` no es recuperable desde Git como implementación histórica completa.

El siguiente paso correcto no es recuperar código, sino decidir una implementación nueva:

- opción A: crear `getProducts` en `RM_VN_CrearOportunidad_Ctrl` respetando exactamente el contrato esperado por `rm_vn_crear_opp_inventario`;
- opción B: refactorizar el LWC para usar explícitamente `RM_VN_Inventario_Ctrl.getRecords`, adaptando contrato, nombres de llaves y pruebas;
- opción C: reutilizar `ProductSearcherController.getProducts` sólo si se acepta cambiar el contrato del LWC y se valida que la búsqueda de inventario de VN siga siendo equivalente.

Cualquiera de las tres opciones debe tratarse como implementación nueva, no como recuperación histórica.

## D2 — `BusquedaDetalladaController.updateFreshPriceFromSoftland`

### Evidencia encontrada

En el commit `106918c chore(sprint2): reconcile lwc aura bundles with partial`, aparecen imports LWC para `updateFreshPriceFromSoftland` en:

- `busquedaDetallada`, apuntando a `BusquedaDetalladaController.updateFreshPriceFromSoftland`;
- `qoSearchDetailProduct`, apuntando a `WoliGridController2.updateFreshPriceFromSoftland`;
- `woSearchDetailProduct`, apuntando a `WoliGridController.updateFreshPriceFromSoftland`.

Ese commit sólo concilia bundles Aura/LWC y documentación. No agrega clases Apex ni métodos Apex.

La búsqueda en todo el historial no encontró implementación de `updateFreshPriceFromSoftland` en:

- `BusquedaDetalladaController.cls`
- `WoliGridController.cls`
- `WoliGridController2.cls`
- otra clase Apex del repositorio

### Contrato inferido por los LWC

`busquedaDetallada` llama el método con:

- `productCode`
- `empresaFactura`
- `pricebookEntryId`

Y espera una respuesta tipo objeto con:

- `success`
- `newUnitPrice`
- `fecha`
- `message`

Cuando `success = true`, el LWC muestra el nuevo precio y refresca `pricebookReferenceDetails`.

Los componentes `qoSearchDetailProduct` y `woSearchDetailProduct` usan el mismo patrón de parámetros y respuesta, pero apuntan a otros controladores.

### Implementación relacionada, pero incompleta

Existe `HttpCalloutGetProductFreshRefPrices.cls`, introducida en `2b9d850 chore(empresa): sync sprint 1 apex baseline from partial`.

Ese código expone un método de bajo nivel:

`getProductFreshRefPricesPOST(String articulo, String compania)`

Pero no es equivalente al contrato esperado por los LWC porque:

- devuelve un `HttpResponse`, no un objeto `{ success, newUnitPrice, fecha, message }`;
- no parsea la respuesta de Softland;
- no actualiza `PricebookEntry`;
- no valida `pricebookEntryId`;
- no confirma moneda/lista/precio objetivo;
- contiene fallback a `RMBAVARIAN` cuando `compania` viene vacío.

Ese fallback no es seguro para PEKING y no debe reutilizarse como base directa sin refactor.

### Dictamen

`updateFreshPriceFromSoftland` no es recuperable desde Git como implementación histórica completa.

El siguiente paso correcto es implementación nueva y explícita si el equipo decide habilitar esa acción:

- crear el método en el controlador real que consume cada LWC;
- definir si se centraliza en un helper común para `BusquedaDetalladaController`, `WoliGridController` y `WoliGridController2`;
- resolver empresa de manera PEKING-safe, sin default Bavarian;
- llamar a `HttpCalloutGetProductFreshRefPrices` sólo después de corregir su fallback;
- parsear la respuesta de Softland;
- actualizar únicamente el `PricebookEntry` recibido y validado;
- devolver exactamente `{ success, newUnitPrice, fecha, message }`;
- cubrir con tests Bavarian, Otobai, PEKING, empresa faltante y respuesta Softland inválida.

## Riesgos si se copia código parecido sin rediseño

1. Copiar `ProductSearcherController.getProducts` no cumple el contrato de `rm_vn_crear_opp_inventario` y puede romper la pantalla por nombres de llaves distintos.
2. Redirigir a `RM_VN_Inventario_Ctrl.getRecords` sin adaptar respuesta puede romper `preciosBavarian` / `preciosSoftland` y filtros esperados.
3. Usar `HttpCalloutGetProductFreshRefPrices` directamente no actualiza el `PricebookEntry` ni devuelve el contrato esperado por el LWC.
4. El fallback actual a `RMBAVARIAN` en precio fresco puede enviar PEKING a Bavarian si llega empresa vacía.
5. La actualización de `PricebookEntry` tiene efecto funcional real; debe quedar cubierta por test y QA, no sólo por compilación.

## Archivos que Code debería revisar si se implementa después

Para `getProducts`:

- `force-app/main/default/classes/RM_VN_CrearOportunidad_Ctrl.cls`
- `force-app/main/default/classes/RM_VN_CrearOportunidad_Ctrl_Test.cls`
- `force-app/main/default/lwc/rm_vn_crear_opp_inventario/rm_vn_crear_opp_inventario.js`
- `force-app/main/default/classes/RM_VN_Inventario_Ctrl.cls`, sólo como referencia funcional
- `force-app/main/default/classes/ProductSearcherController.cls`, sólo como referencia funcional

Para `updateFreshPriceFromSoftland`:

- `force-app/main/default/classes/BusquedaDetalladaController.cls`
- `force-app/main/default/classes/BusquedaDetalladaControllerTest.cls`, si existe o si se crea cobertura nueva
- `force-app/main/default/classes/WoliGridController.cls`
- `force-app/main/default/classes/WoliGridController2.cls`
- `force-app/main/default/classes/HttpCalloutGetProductFreshRefPrices.cls`
- `force-app/main/default/lwc/busquedaDetallada/busquedaDetallada.js`
- `force-app/main/default/lwc/woSearchDetailProduct/woSearchDetailProduct.js`
- `force-app/main/default/lwc/qoSearchDetailProduct/qoSearchDetailProduct.js`

## Cierre

No hay implementación histórica recuperable para ninguna de las dos dependencias.

El resultado correcto de este bloque es documentar el bloqueo y evitar una recuperación falsa.

Estado final:

- Código Apex modificado: NO
- LWC modificado: NO
- Metadata funcional modificada: NO
- Salesforce tocado: NO
- Deploy ejecutado: NO
- DML ejecutado: NO
- Producción tocada: NO
