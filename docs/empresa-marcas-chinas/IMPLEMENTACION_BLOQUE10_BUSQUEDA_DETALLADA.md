# Bloque 10 — Búsqueda detallada (`BusquedaDetalladaController` / `precioProductoJSON`)

Worktree: `C:\Users\dokur\Documents\Repositorios\RedMotors-Bloque10-BusquedaDetallada`
Rama: `feature/pc/redmotors-empresa-marcas-chinas-bloque10-busqueda-detallada-20260726`
Base: `origin/feature/pc/redmotors-empresa-marcas-chinas-sprint1-20260724`

Análisis y preparación local. No se ejecutó `sf`, no se consultó ningún org,
no se hizo deploy ni dry-run. No se modificó código productivo.

## Objetivo

Eliminar la lógica binaria Bavarian/Otobai en `BusquedaDetalladaController` y
`precioProductoJSON` cuando existiera un patrón técnico único ya comprobado
para RMPEKING, sin inventar sucursales, Service Territories, mapeos
comerciales, permisos, perfiles, integraciones ni datos operativos.

## Resultado: ambas clases están bloqueadas por dependencias reales, no por falta de patrón

Tras investigar el código completo de `BusquedaDetalladaController`,
`BusquedaDetalladaHelper`, `BusquedaDetalladaService`, `precioProductoJSON` y
sus pruebas existentes, la conclusión es que **la corrección original de
esta matriz (clasificarlas como "resoluble ahora, mismo patrón que
QuoteController") era incorrecta**. Ambas clases dependen de datos que hoy
no existen y que esta tarea prohíbe inventar. Se documenta aquí con
referencias exactas, y **no se forzó ningún cambio de código productivo**.

### `BusquedaDetalladaController` — bloqueado por `Sucursal__c` sin relación a `Empresa__c`

- `getActivePricebooks()` (líneas 6-22): decide el prefijo de Pricebook
  (`'Bavarian%'` vs `'Otobai%'`) leyendo `User.Sucursal__c` y comparando
  contra los literales `'Uruca'`, `'Pinares'`, `'Escazú'`. No hay ninguna
  relación `Sucursal__c → Empresa__c` en la metadata local (no existe
  siquiera el objeto `Sucursal__c` versionado en `force-app`), y el propio
  Manual de Análisis (§5.2) confirma que esa relación **todavía no existe**
  ("Sucursal__c / ServiceTerritory → Relacionar con Empresa__c" está en la
  arquitectura objetivo, no implementada).
- `searchProducts()` (líneas 32-45): mapea `Sucursal__c` a un
  `ServiceTerritory` por nombre literal (`'Pinares - Mecánica Rápida'`,
  `'Escazú - Mecánica Rápida'`, y **cualquier otra sucursal cae en
  `'Uruca - Mecánica Rápida'` por defecto** — un default silencioso más).
- No existe ninguna sucursal ni `ServiceTerritory` de PEKING en la metadata
  local (`force-app/main/default/objects/Sucursal__c` no existe; no hay
  `ServiceTerritory` versionado). Crearlos está **expresamente prohibido**
  por esta tarea ("No inventar: nuevas sucursales; Service Territories").
- `BusquedaDetalladaHelper` y `BusquedaDetalladaService` (los dos
  colaboradores directos) **no tienen ninguna lógica de empresa propia**:
  reciben `priceBookId`/`serviceTerritoryId` como parámetros y son
  agnósticos de compañía. No requieren cambio.
- `getActiveServiceTerritories()` ya es genérico (devuelve todos los
  territorios activos, sin filtrar por marca): no requiere cambio.

**Conclusión:** sin la relación `Sucursal__c → Empresa__c` (parte de la
"Opción B/C" estratégica del Manual, ya identificada como diferida en
`A.6`/`L.1` de la matriz de trazabilidad), no hay forma de decidir qué
sucursal(es) deberían mostrar Pricebooks/territorios de PEKING sin inventar
datos operativos.

### `precioProductoJSON` — bloqueado por la convención de identificación de producto de Softland

- `createProduct(jsonStr)` (líneas 2-153) recibe un payload JSON con un
  campo `empresa` (`'RMBAVARIAN'` o `'RMOTOBAI'`) — es un endpoint de
  sincronización de precios/costos, consistente con una integración
  **entrante** desde Softland (no hace `HttpCallout` saliente, pero sí es
  parte del mismo dominio de integración que `productJSON`,
  `ProductoLocalizacionHelper` y `HttpCalloutGetProductRefPrices`, ya
  clasificados como bloqueados por contrato Softland en la matriz de
  trazabilidad, ítem `H.5`/`J.1b`).
- Para `RMBAVARIAN`, el producto se busca por `Codigo_de_Producto__c =
  :articulo` (línea 24-28).
- Para `RMOTOBAI`, se busca por `CodigoProductoInterno__c` con una clave
  compuesta `articulo + '-' + empresa` (línea 30-37).
- **Estas dos convenciones son distintas entre sí.** No hay ningún patrón
  técnico único que indique cuál de las dos (o una tercera) debe seguir
  RMPEKING — es exactamente el mismo dato pendiente que bloquea `H.5`
  (confirmar contrato/convención Softland para PEKING) en la matriz de
  trazabilidad. Los nombres de Pricebook (`'PEKING Local'`/`'PEKING
  Dólares'`) sí están ya confirmados y creados (Bloque 2), pero eso no basta
  sin la convención de producto correcta.
- **Hallazgo colateral, sin corregir (fuera de alcance de este bloque):**
  hoy, si `empresa` no es `'RMBAVARIAN'` ni `'RMOTOBAI'`, la variable local
  `prod` (línea 21, `List<Product2> prod;`) queda sin inicializar y
  `prod.size()` (línea 39) lanza una `NullPointerException`, capturada por
  el `catch` genérico (línea 140) y devuelta como `CODIGO: 500` — un error
  de servidor genérico, no un rechazo controlado de "empresa no soportada".
  Esto se **caracterizó con una prueba nueva** (ver abajo), pero no se
  corrigió: hacerlo requeriría decidir el mensaje/código de error deseado, y
  el foco de este bloque es RMPEKING, no el manejo de errores general de
  esta clase.
- El método `Method()` de `precioProductoJSON` y de `BusquedaDetalladaHelper`
  son relleno de cobertura histórico (cientos de asignaciones de enteros sin
  uso), igual al `dummy()` ya retirado en otros bloques. **No se tocaron**:
  no forman parte del objetivo de este bloque y su test asociado los sigue
  invocando (`precioProductoJSONTest.testprecioProductoJSONBavarian`,
  `BusquedaDetalladaTest.testGetActivePricebooks_BavarianBranch`).

## Diseño propuesto para cuando se desbloquee (no implementado)

### `BusquedaDetalladaController.getActivePricebooks()` / `searchProducts()`

```
// Esquema conceptual, una vez exista Sucursal__c.Empresa__c:
User usr = [SELECT Sucursal__c, Sucursal__r.Empresa__c FROM User WHERE Id = :UserInfo.getUserId()];
EmpresaContext ctx = EmpresaResolver.resolve(usr.Sucursal__r.Empresa__c);
String pricebookPrefix = ctx.codigo == 'RMBAVARIAN' ? 'Bavarian%'
                        : ctx.codigo == 'RMOTOBAI'   ? 'Otobai%'
                        : ctx.codigo == 'RMPEKING'    ? 'PEKING%'
                        : null; // null -> EmpresaConfigurationException, nunca un default silencioso
```

Mismo patrón exacto ya usado y probado en `QuoteController`,
`QuoterController` y `BMW_LineaPlantillaEmpresa`. `searchProducts()` seguiría
el mismo esquema para resolver el `ServiceTerritory` correcto vía relación,
no por nombre literal.

### `precioProductoJSON.createProduct()`

```
// Una vez confirmada la convención de producto de RMPEKING con Softland:
if (empresa == 'RMBAVARIAN') { /* Codigo_de_Producto__c, sin cambios */ }
else if (empresa == 'RMOTOBAI') { /* CodigoProductoInterno__c compuesto, sin cambios */ }
else if (empresa == 'RMPEKING') { /* <convención confirmada por Softland> */ }
// else: lanzar EmpresaConfigurationException en vez de dejar `prod` nulo
```

Los nombres de Pricebook `'PEKING Local'`/`'PEKING Dólares'` ya están
confirmados (Bloque 2) y pueden reutilizarse directamente en la rama nueva
una vez se resuelva la convención de producto.

## Pruebas preparadas (test-only, sin `SeeAllData`, sin datos inventados)

- `BusquedaDetalladaTest.testGetActivePricebooks_UnknownSucursalHasNoFailClosedForThirdCompany`:
  caracteriza que, hoy, cualquier sucursal no reconocida cae en la rama
  `Otobai`, nunca en un error controlado ni en una tercera empresa —
  documenta exactamente la brecha que impide agregar RMPEKING sin la
  relación `Sucursal__c → Empresa__c`.
- `precioProductoJSON_PekingGapTest.testCreateProduct_UnknownCompany_ReturnsGenericServerErrorInsteadOfControlledMessage`
  (clase nueva, sin `SeeAllData`): caracteriza que, hoy, `empresa='RMPEKING'`
  produce un `CODIGO: 500` genérico por `NullPointerException`, no un
  rechazo explícito.

Ninguna prueba inventa sucursales, territorios, mapeos comerciales, permisos,
perfiles, integraciones ni datos operativos: ambas usan valores que ya no
existen en el sistema hoy (`'SucursalNoReconocidaPorNingunaEmpresa'`,
`empresa='RMPEKING'`) únicamente para demostrar el comportamiento actual del
código ya desplegado, no para simular una configuración real de negocio.

## Revisiones locales ejecutadas

- `git diff --check`: sin errores de espacio en blanco.
- Búsqueda de `SeeAllData`: ninguna en los archivos nuevos/modificados de
  este bloque (la clase nueva se creó deliberadamente separada de
  `precioProductoJSONTest`, que sí usa `SeeAllData = true`, para no
  heredarlo).
- Búsqueda de IDs reales: ninguno.
- Búsqueda de `Test.isRunningTest`: ninguno agregado.
- Búsqueda de `dummy()`: no se agregó ninguno; los `Method()` históricos de
  relleno de cobertura no se tocaron.
- Revisión de llamadores: se confirmó que `BusquedaDetalladaHelper` y
  `BusquedaDetalladaService` no tienen lógica de empresa propia y no se
  vieron afectados; no se encontraron otros consumidores Apex/LWC/Aura de
  `BusquedaDetalladaController.getActivePricebooks()`/`searchProducts()` ni
  de `precioProductoJSON.createProduct()` más allá de sus propias pruebas.

## Corrección pendiente sobre la matriz de trazabilidad

La matriz (`MATRIZ_TRAZABILIDAD_REQUERIMIENTOS_SPRINT1.md`) clasificaba
`J.1a` (`BusquedaDetalladaController`/`precioProductoJSON`) como "(a)
técnicamente resoluble ahora, sin decisión". Esta investigación demuestra
que esa clasificación fue optimista: ambas clases dependen de decisiones/
datos externos genuinos (relación Sucursal↔Empresa; convención de producto
Softland para PEKING), igual que `H.5`/`J.1b`. Queda como acción pendiente
mover `J.1a` de "(a) resoluble ahora" a "(c) depende de decisión comercial/
proveedor/dato externo" en una futura actualización de esa matriz — no se
modificó en esta tarea porque la Fase 1 de esa matriz ya se cerró y
commiteó por separado.

## Estado de validación

Pendiente (a ejecutar por Codex, fuera de esta tarea):

- dry-run enfocado de `BusquedaDetalladaTest` y `precioProductoJSON_PekingGapTest`;
- regresión seleccionada;
- deploy real a `RedMotorsSandbox` solo si las pruebas pasan;
- verificación post-deploy.

No se afirma que esto compile, que las pruebas pasen en el org real, ni que
esté listo para deploy. No hay cambio de código productivo: todo el
contenido de este bloque es documentación, diseño propuesto y pruebas de
caracterización.
