# Bloque 10 — Búsqueda detallada y sincronización de precios

## Estado

Bloque reclasificado como dependencia externa comprobada.

No se implementó cambio productivo porque RedMotorsSandbox / Partial no contiene evidencia suficiente para definir una regla única y segura para PEKING en:

- `BusquedaDetalladaController`
- `precioProductoJSON`

## Componentes revisados

- `BusquedaDetalladaController`
- `BusquedaDetalladaHelper`
- `BusquedaDetalladaService`
- `precioProductoJSON`
- `precioProductoWS`
- `busquedaDetallada`
- configuraciones de usuarios, listas de precios, territorios, productos y metadatos relacionados en RedMotorsSandbox / Partial

## Hallazgos sobre `BusquedaDetalladaController`

### Comportamiento actual

`getActivePricebooks()` resuelve listas de precios por `User.Sucursal__c`:

- `Uruca`, `Pinares`, `Escazú` → `Bavarian%`
- cualquier otro valor → `Otobai%`

`searchProducts()` resuelve territorios por nombres fijos:

- `Pinares` → `Pinares - Mecánica Rápida`
- `Escazú` → `Escazú - Mecánica Rápida`
- cualquier otro valor → `Uruca - Mecánica Rápida`

### Evidencia de Partial

Valores activos encontrados en `User.Sucursal__c`:

- vacío;
- `Pinares`;
- `Escazú`;
- `Pavas`;
- `Uruca`;
- `Uruca Otras Marcas`.

No se encontraron usuarios activos con sucursal PEKING, Omoda o Jaecoo.

No se encontraron `ServiceTerritory` activos con nombres PEKING, Omoda o Jaecoo.

Sí existen territorios activos para el patrón actual Bavarian:

- `Uruca - Mecánica Rápida`;
- `Pinares - Mecánica Rápida`;
- `Escazú - Mecánica Rápida`;
- otros territorios operativos de Uruca, Pinares y Escazú.

### Conclusión

No existe en Partial una relación comprobable:

`User.Sucursal__c → Empresa__c → Pricebook / ServiceTerritory`

Por lo tanto, agregar PEKING en esta clase exigiría inventar una sucursal, un territorio o una regla comercial de asignación. Eso queda fuera del alcance seguro del Sprint 1.

## Hallazgos sobre `precioProductoJSON`

### Comportamiento actual

`precioProductoJSON.createProduct()` usa convenciones diferentes por empresa:

- `RMBAVARIAN`: busca `Product2` por `Codigo_de_Producto__c = articulo`;
- `RMOTOBAI`: busca `Product2` por `CodigoProductoInterno__c = articulo + '-' + empresa`.

No existe rama para `RMPEKING`.

### Evidencia de Partial

Pricebooks activos confirmados:

- `Bavarian Local`;
- `Bavarian Dólar`;
- `Otobai Local`;
- `Otobai Dólares`;
- `PEKING Local`;
- `PEKING Dólares`.

Entradas de precio:

- existen entradas para Bavarian y Otobai;
- no existen `PricebookEntry` en `PEKING Local` ni `PEKING Dólares`.

Productos:

- no se encontraron productos con `Product2.Empresa__c = RMPEKING`;
- no se encontraron productos con marca Omoda o Jaecoo en los campos revisados;
- no se encontraron entradas de precio vinculadas a productos Omoda, Jaecoo o RMPEKING.

### Conclusión

No hay evidencia de qué identificador debe usar PEKING para sincronizar precios:

- `Codigo_de_Producto__c`;
- `CodigoProductoInterno__c` compuesto;
- u otra convención.

Implementar una rama `RMPEKING` sin ese contrato podría actualizar productos incorrectos o crear entradas de precio con una llave equivocada.

## Propuesta previa revisada

Se revisó una propuesta previa que agregaba documentación, manifest y pruebas de caracterización.

No se integraron esas pruebas porque registraban como expectativa comportamientos que son deuda funcional:

- selección por descarte hacia Otobai en sucursales no reconocidas;
- error genérico para empresa no soportada en `precioProductoJSON`.

Se decidió conservar únicamente la documentación de la dependencia externa, sin congelar comportamientos defectuosos mediante pruebas nuevas.

## Decisión técnica

El Bloque 10 no queda cerrado funcionalmente.

Queda reclasificado como dependencia externa comprobada hasta que exista definición operativa sobre:

1. relación entre sucursal, empresa, Pricebook y Service Territory para PEKING;
2. convención de identificación de producto para PEKING/Omoda/Jaecoo;
3. carga operativa de productos y entradas de precio PEKING.

## Validación

No se ejecutó dry-run ni deploy porque no se preparó cambio productivo seguro.

No se modificaron:

- Apex productivo;
- metadata;
- datos;
- Pricebooks;
- Service Territories;
- productos;
- integraciones;
- permisos.

## Pendientes

- Definir si PEKING usará una sucursal existente o una nueva sucursal operativa.
- Definir el `ServiceTerritory` aplicable para búsqueda detallada PEKING.
- Confirmar la llave de producto para precios PEKING.
- Cargar productos y `PricebookEntry` PEKING cuando el proceso operativo lo autorice.
- Reabrir el bloque cuando exista una regla única y validable.

## Avance técnico

El bloque no incrementa el avance funcional del Sprint 1.

El Sprint 1 se mantiene en 18/19 bloques funcionales comprometidos cerrados, equivalente a 94.74%.
