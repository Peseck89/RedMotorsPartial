# Siguiente lote de 8 clases — reconciliación Git contra Partial

> **Revisión que invierte la premisa anterior.** La versión previa de este
> documento asumía que las ocho clases estaban pendientes de implementar. La
> comparación contra las versiones recuperadas de Partial demuestra que **las
> ocho ya están implementadas en el org, con soporte explícito de PEKING**, y que
> **Git es la copia atrasada**. El trabajo pendiente no es escribir el cambio sino
> reconciliar Git con Partial y cerrar los puntos que quedaron fail-closed.

Estado: análisis únicamente. No se ejecutó Salesforce CLI, no se desplegó nada, no
se modificó Apex ni tests, y **no se copió ninguna versión de Git sobre Partial**.

Fuentes comparadas:

- Git: `RedMotors-Sprint1-Integracion\force-app\main\default\classes`
- Partial: `RedMotors-Empresa-Marcas-Chinas\tmp-partial\classes`

Hechos de Partial asumidos como ciertos: `Empresa__c` existe con 0 registros y solo
`Codigo__c`; **no existe `Codigo_ERP__c`**; `Opportunity.Empresa_Operadora__c`
existe con 0 registros poblados; `Opportunity.BMW_Compania__c` solo tiene
`Bavarian` y `Otobai` activos; `Product2.Empresa__c` tiene `RMBAVARIAN`,
`RMOTOBAI` y `RMPEKING` pero 0 productos PEKING; existen los Pricebooks
`PEKING Local` y `PEKING Dólares`; no hay bodegas con convención `RMPEKING`.

## 1. Diff semántico

Método: se ignoraron fin de línea, comentarios y líneas en blanco; se extrajeron
las firmas de métodos de cada versión y se compararon por nombre; se revisó a mano
la lógica empresarial. **El tamaño del archivo no se usó como criterio**: casi toda
la diferencia de volumen de Git corresponde a métodos de relleno de cobertura
(`dummy`, `dummyMethod`, `Method`), no a lógica.

| Clase | Líneas de código | Solo en Git | Solo en Partial |
|---|---|---|---|
| `QuoteSoftlandPedidoService` | git 388 / partial 154 | `dummyMethod` | `resolveCompanyErpCode`, `resolveLegacyCompanyCode`, `validateSupportedCompany` |
| `QuoteSoftlandQueryService` | git 251 / partial 18 | `Method` | — |
| `servicioReservas` | git 77 / partial 99 | — | `resolveProductCompany` |
| `servicioEliminarReserva` | git 50 / partial 72 | — | `resolveProductCompany` |
| `OpportunityServiceInvoker` | git 1759 / partial 104 | `dummy`, `dummyMethod` | `resolveCompanyCode`, `resolveLegacyCompanyFromPricebook` |
| `Registrar_Anticipo_Controller` | git 1933 / partial 296 | `dummy`, `dummyMethod` | `resolveCompanyCode`, `resolveLegacyCompanyFromPricebook` |
| `QuoteService` | git 2625 / partial 500 | **`getPricebookName`**, `name` | 12 métodos nuevos (ver 1.7) |
| `productJSON` | git 811 / partial 551 | `dummyMethod` | 10 métodos nuevos (ver 1.8) |

Conclusión transversal: **la base recomendada es Partial en las ocho**. Reemplazar
Partial con Git eliminaría toda la resolución de empresa ya desplegada y
reintroduciría los defaults binarios.

### 1.1 `QuoteSoftlandPedidoService`

- Solo en Git: el binario `if Bavarian → RMBAVARIAN else RMOTOBAI` y `dummyMethod`.
- Solo en Partial: `resolveCompanyErpCode()` prefiere
  `Quote.Opportunity.Empresa_Operadora__c` vía `EmpresaResolver.resolve()`; si es
  nulo cae a `resolveLegacyCompanyCode(BMW_Compania__c)` con tabla explícita
  `BAVARIAN|RMBAVARIAN→RMBAVARIAN`, `OTOBAI|RMOTOBAI→RMOTOBAI`,
  `RMPEKING→RMPEKING`, y lanza `AuraHandledException` en cualquier otro caso.
  `validateSupportedCompany()` vuelve a comprobar antes de usar el código.
- A pesar del nombre del método, usa `context.codigo` (`Codigo__c`), **no**
  `Codigo_ERP__c`. Es coherente con que ese campo no exista.
- Riesgo de reemplazar Partial con Git: alto. Se perdería la resolución completa.
- Base recomendada: **Partial**.

### 1.2 `QuoteSoftlandQueryService`

- Solo en Git: el método de relleno `Method()` con enteros sin uso. Es la totalidad
  de la diferencia de 251 a 18 líneas.
- Partial ya selecciona `opportunity.Empresa_Operadora__c` — la mejora que la
  versión anterior de este documento proponía **ya está hecha**. Además añade
  `CPEstatusDeAprobacion__c`, `Pedido_Interno_es_Plan__c`, `Canal_origen__c`,
  `opportunity.Tipo_de_cliente_mostrador__c` y `opportunity.BMW_Aseguradora__r.Name`.
- **Defecto de la versión Git**: no selecciona `BMW_Aseguradora__r.Name`, pero el
  `QuoteSoftlandPedidoService` de Git sí lo consume. La pareja de Git es
  internamente inconsistente; la de Partial no.
- Riesgo de reemplazar Partial con Git: alto, y rompería el pedido.
- Base recomendada: **Partial**.

### 1.3 `servicioReservas`

- Solo en Partial: `resolveProductCompany(String)` con tabla explícita y
  `EmpresaConfigurationException` si viene vacío; más una compuerta previa al
  callout: si el código resuelto es `RMPEKING`, retorna
  `'No existe configuración confirmada de reserva Softland para RMPEKING.'` y no
  ejecuta el callout.
- Desapareció la mutación en memoria de `thisProduct.Empresa__c` que tenía Git.
- Riesgo de reemplazar Partial con Git: alto.
- Base recomendada: **Partial**.

### 1.4 `servicioEliminarReserva`

- Solo en Partial: el mismo `resolveProductCompany`, y dos compuertas explícitas:
  `RMOTOBAI` y `RMPEKING` retornan mensaje de configuración no confirmada.
- La asimetría que se había detectado en Git —Otobai no puede liberar— **sigue
  existiendo en Partial**, pero ahora es explícita y controlada en vez de un
  silencio: antes el método simplemente no entraba al `if` y devolvía respuesta
  vacía. Es una mejora de diagnóstico, no la corrección funcional.
- Git ya no aporta nada: solo el `//thisProduct.Empresa__c = 'RMBAVARIAN';`
  comentado, que en Partial fue retirado.
- Base recomendada: **Partial**.

### 1.5 `OpportunityServiceInvoker`

- Solo en Partial: `resolveCompanyCode(Opportunity)` prefiere
  `Empresa_Operadora__c`; si es nulo y hay Pricebook, usa
  `resolveLegacyCompanyFromPricebook(Pricebook2.Name)`; si no hay ninguno, lanza
  `AuraHandledException`. Después admite solo `RMBAVARIAN` y `RMOTOBAI`.
- Desaparecieron el `String pricebookname = 'RMBAVARIAN'` inicial, el
  `contains('Otobai')`, la consulta duplicada `opp`/`opp2` y el `catch` que se
  tragaba la excepción.
- Base recomendada: **Partial**.

### 1.6 `Registrar_Anticipo_Controller`

- Solo en Partial: el mismo par `resolveCompanyCode` /
  `resolveLegacyCompanyFromPricebook`, resolviendo una vez y reutilizando el
  resultado en los bloques que en Git estaban duplicados.
- Base recomendada: **Partial**.

### 1.7 `QuoteService` — **única discrepancia bloqueante**

- Solo en Partial (12 métodos): `resolveSupportedCompanyCode`,
  `normalizeCompanyCode`, `ensureCompanyHasConfiguredBodega`, `getBodegaIdByCode`,
  `getDefaultDeliveryBodegaCodeFromQuote`, `resolveDeliveryBodegaIdForQuote`,
  `resolveDeliveryBodegaIdForVehicle`, `isPrincipalBodega`, `usesOtobaiPavasBodega`,
  `isBavarianBrand`, `isMotoBrand`, `isPekingBrand`.
  `resolveSupportedCompanyCode` recibe cuatro señales —lookup, `BMW_Compania__c`,
  RecordType/marca y nombre de Pricebook— y `ensureCompanyHasConfiguredBodega`
  lanza error controlado para `RMPEKING` y para cualquier código no soportado.
- **Solo en Git: `getPricebookName(String oppId)`**, el selector por RecordType
  (`Standard Price Book` / `Venta Consumidor Final`). **No existe en Partial.** Y
  `RM_VN_QuoteController_Test` de Git lo invoca (línea 105). Si ese test sigue
  llamándolo en el org, o no compila contra Partial, o el org tiene una versión
  distinta del test.
- La constante muerta `PRICEBOOK_NAME = 'Bavarian Dólar'` **sobrevive en ambas**.
  Sigue sin estar referenciada por ninguna clase.
- Riesgo: es el único punto donde reemplazar en cualquier dirección puede romper
  algo. Requiere verificación antes de tocar la clase.
- Base recomendada: **Partial**, condicionada a resolver `getPricebookName`.

### 1.8 `productJSON`

- Solo en Partial (10 métodos): `validateSupportedCompany`,
  `validateCompanyCanProcessWarehouses`, `normalizeCompanyCode`,
  `applyCoreProductFields`, `applyVehicleFields`, `applyUsedVehicleComissions`,
  `buildVehicleDescription`, `resolveTipoProducto`, `getOpportunityId`,
  `hasAvailableInventory`.
- `validateSupportedCompany(empresa)` se ejecuta al inicio de `createProduct` y
  acepta los tres códigos; `validateCompanyCanProcessWarehouses(empresa)` se llama
  antes de cada bloque de bodegas, tanto en creación como en actualización. Se
  introdujo `ProductCompanyConfigurationException`.
- El `else` implícito que anteponía `'RMOTOBAI'` al código de bodega ya no puede
  alcanzarse con una empresa no validada.
- Base recomendada: **Partial**.

### 1.9 Pruebas por versión

`tmp-partial` trae también `OpportunityServiceInvokerTest`,
`QuoteServiceControllerTest`, `Registrar_Anticipo_Controller_Test`,
`RegistrarAnticipoCasillasTst`, `TestServiciosQuote`, `productJSONTest`,
`servicioReservasTest`, `servicioEliminarReservaTest` y los dos mocks. Esas son las
pruebas que corresponden a la implementación vigente. Las homónimas de Git
corresponden a las versiones antiguas y **no deben desplegarse sobre Partial**.

## 2. Fuente de Empresa por clase, hoy

Con `Empresa_Operadora__c` en 0 registros y sin `Codigo_ERP__c`, la rama del lookup
existe en el código pero **nunca se ejecuta**. La fuente efectiva es siempre la de
respaldo.

| Clase | Fuente preferida (inactiva hoy) | Fuente efectiva | ¿Alcanza a PEKING? |
|---|---|---|---|
| `QuoteSoftlandPedidoService` | `Opportunity.Empresa_Operadora__c` | `Opportunity.BMW_Compania__c` | **No** — solo tiene Bavarian y Otobai activos |
| `QuoteSoftlandQueryService` | — | provee ambas al consumidor | No aplica |
| `servicioReservas` | — | `Product2.Empresa__c` | Sí en el dato, pero 0 productos PEKING |
| `servicioEliminarReserva` | — | `Product2.Empresa__c` | Igual |
| `OpportunityServiceInvoker` | `Opportunity.Empresa_Operadora__c` | `Pricebook2.Name` | Sí — `PEKING Local` y `PEKING Dólares` existen |
| `Registrar_Anticipo_Controller` | `Opportunity.Empresa_Operadora__c` | `Pricebook2.Name` | Sí — mismos Pricebooks |
| `QuoteService` | `Opportunity.Empresa_Operadora__c` | `BMW_Compania__c`, marca y `Pricebook2.Name` | Parcial — por Pricebook y marca sí |
| `productJSON` | — | `empresa` del payload REST | Sí — es dato externo |

Consecuencia operativa: hoy **PEKING solo es alcanzable por Pricebook, por marca o
por el payload REST**. Ninguna ruta que dependa de `BMW_Compania__c` puede producir
PEKING mientras ese picklist no tenga el valor.

Riesgo latente: `EmpresaResolver.resolve()` consulta `Empresa__c`, que tiene 0
registros. Si `Empresa_Operadora__c` se poblara antes de crear los registros de
`Empresa__c`, todas las rutas que hoy no se ejecutan empezarían a lanzar excepción.
El orden correcto es crear primero los registros de `Empresa__c`.

## 3. Clasificación A/B/C/D

| Clase | Clasificación | Fundamento |
|---|---|---|
| `QuoteSoftlandQueryService` | **A** | Ya completa en Partial. Solo falta versionarla en Git |
| `QuoteSoftlandPedidoService` | **B** | Resolución completa con PEKING reconocido; falla controlada si el código no es soportado |
| `servicioReservas` | **B** | Reconoce `RMPEKING` y se detiene antes del callout por falta de contrato confirmado |
| `productJSON` | **B** | Valida el código recibido y bloquea antes de tocar bodegas |
| `servicioEliminarReserva` | **C** | Bavarian funciona; **Otobai y PEKING quedan bloqueados** por falta de configuración confirmada |
| `OpportunityServiceInvoker` | **C** | Admite solo `RMBAVARIAN` y `RMOTOBAI`; PEKING lanza error |
| `Registrar_Anticipo_Controller` | **C** | Igual que el anterior |
| `QuoteService` | **D** | No debe tocarse hasta aclarar `getPricebookName` y la convención de bodega de PEKING |

Nada queda en A salvo la clase que ya está terminada, porque la limitación no es de
código sino de datos y de definiciones externas.

## 4. Plan por clase

El "cambio mínimo" de este lote es, en casi todos los casos, **traer Partial a Git**
sin modificar lógica. Solo tres clases tienen trabajo funcional pendiente, y las
tres dependen de definiciones externas.

| # | Clase | Base | Cambio mínimo | Test a tocar | Bavarian | Otobai | PEKING | Nula/desconocida |
|---:|---|---|---|---|---|---|---|---|
| 1 | `QuoteSoftlandQueryService` | Partial | Versionar en Git tal cual; opcionalmente retirar `Method()` | `TestServiciosQuote` | Sin cambio | Sin cambio | No aplica | No aplica |
| 2 | `QuoteSoftlandPedidoService` | Partial | Versionar en Git; retirar `dummyMethod` | `TestServiciosQuote` | `RMBAVARIAN` | `RMOTOBAI` | `RMPEKING` solo si llega por lookup | Excepción antes del payload |
| 3 | `servicioReservas` | Partial | Versionar en Git | `servicioReservasTest` | Callout normal | Callout normal | Error controlado, sin callout | Excepción |
| 4 | `servicioEliminarReserva` | Partial | Versionar en Git. **Funcional pendiente**: habilitar Otobai | `servicioEliminarReservaTest` | Callout normal | Hoy bloqueado | Bloqueado | Excepción |
| 5 | `OpportunityServiceInvoker` | Partial | Versionar en Git; retirar `dummy`/`dummyMethod`. **Funcional pendiente**: admitir PEKING | `OpportunityServiceInvokerTest` | Por Pricebook | Por Pricebook | Error controlado | Excepción |
| 6 | `Registrar_Anticipo_Controller` | Partial | Igual que el anterior | `Registrar_Anticipo_Controller_Test`, `RegistrarAnticipoCasillasTst` | Por Pricebook | Por Pricebook | Error controlado | Excepción |
| 7 | `QuoteService` | Partial | **Nada hasta resolver `getPricebookName`** | `QuoteServiceControllerTest`, `RM_VN_QuoteController_Test` | Bodega `BR01` | Bodega Otobai | Error de bodega | Excepción |
| 8 | `productJSON` | Partial | Versionar en Git; retirar `dummyMethod` | `productJSONTest` | Rama propia | Rama propia | Validado y bloqueado antes de bodega | Excepción |

Manifest sugerido, uno por clase, en `manifest/`: `next8-<clase>.xml` con la
`ApexClass` productiva y su test.

## 5. Comandos PowerShell

### 5.1 Verificación previa obligatoria — `QuoteService`

Es lo primero que hay que resolver, antes de cualquier otro paso:

```powershell
# ¿El test del org sigue llamando a getPricebookName?
sf project retrieve start --target-org RedMotorsSandbox `
  --metadata "ApexClass:RM_VN_QuoteController_Test" --output-dir tmp-partial-check

Select-String -Path tmp-partial-check\main\default\classes\RM_VN_QuoteController_Test.cls `
  -Pattern "getPricebookName"

# ¿Alguna otra clase del org lo invoca?
sf data query --use-tooling-api --target-org RedMotorsSandbox --result-format human `
  --query "SELECT Name FROM ApexClass WHERE Name LIKE '%Quote%' ORDER BY Name"
```

Si el test del org **no** lo llama, `getPricebookName` fue retirado a propósito y
Git está atrasado. Si **sí** lo llama, hay una incoherencia en el org que debe
reportarse antes de tocar la clase.

### 5.2 Reconciliar Partial hacia Git

```powershell
$clases = @(
  'QuoteSoftlandPedidoService','QuoteSoftlandQueryService','servicioReservas',
  'servicioEliminarReserva','OpportunityServiceInvoker','Registrar_Anticipo_Controller',
  'productJSON'
)
foreach ($c in $clases) {
  Copy-Item "tmp-partial\classes\$c.cls"          "force-app\main\default\classes\$c.cls"          -Force
  Copy-Item "tmp-partial\classes\$c.cls-meta.xml" "force-app\main\default\classes\$c.cls-meta.xml" -Force
}
git diff --stat -- force-app/main/default/classes
```

`QuoteService` queda deliberadamente fuera de la lista hasta cerrar 5.1.

### 5.3 Pruebas y validación por clase

```powershell
sf apex run test --target-org RedMotorsSandbox --tests <ClaseTest> `
  --result-format human --code-coverage --wait 30

sf project deploy start --target-org RedMotorsSandbox --dry-run `
  --manifest manifest\next8-<clase>.xml `
  --test-level RunSpecifiedTests --tests <ClaseTest> --wait 30

sf project deploy start --target-org RedMotorsSandbox `
  --manifest manifest\next8-<clase>.xml `
  --test-level RunSpecifiedTests --tests <ClaseTest> --wait 30

sf apex run test --target-org RedMotorsSandbox --tests <ClaseTest> `
  --result-format human --code-coverage --wait 30
```

Nota: si Git y Partial ya coinciden tras 5.2, el deploy no cambia el org. El valor
del ciclo es confirmar que la versión versionada compila y pasa pruebas.

### 5.4 Datos que desbloquean las clases en C y D

```powershell
# Registros de Empresa: hoy 0. Deben crearse antes de poblar Empresa_Operadora__c
sf data query --target-org RedMotorsSandbox --result-format human `
  --query "SELECT Id, Name, Codigo__c, Activa__c FROM Empresa__c ORDER BY Name"

# Convención de bodegas: bloquea QuoteService y productJSON
sf data query --target-org RedMotorsSandbox --result-format human `
  --query "SELECT Id, Name, Bodega__c, ID_EXTERNO_BODEGA__c FROM Bodega__c ORDER BY ID_EXTERNO_BODEGA__c"

# Pricebooks PEKING confirmados
sf data query --target-org RedMotorsSandbox --result-format human `
  --query "SELECT Id, Name, IsActive, CurrencyIsoCode FROM Pricebook2 WHERE Name LIKE 'PEKING%'"

# Valores activos del picklist que hoy impide llegar a PEKING por Opportunity
sf sobject describe --sobject Opportunity --target-org RedMotorsSandbox | Out-File describe-Opportunity.json
```

## 6. Qué puede comenzar de inmediato

Reconciliación a Git, sin cambio funcional: `QuoteSoftlandQueryService`,
`QuoteSoftlandPedidoService`, `servicioReservas`, `servicioEliminarReserva`,
`OpportunityServiceInvoker`, `Registrar_Anticipo_Controller`, `productJSON`.

## 7. Qué requiere definición externa

| Tema | Bloquea | Pregunta |
|---|---|---|
| Contrato Softland de eliminación de reserva para Otobai | `servicioEliminarReserva` | ¿Por qué Otobai nunca pudo liberar reservas? ¿El endpoint lo soporta? |
| Contrato Softland de reserva y liberación para PEKING | `servicioReservas`, `servicioEliminarReserva` | ¿Existe contrato para `RMPEKING`? |
| Convención de `ID_EXTERNO_BODEGA__c` para PEKING | `QuoteService`, `productJSON` | ¿Qué prefijo o código usa la bodega de PEKING? |
| Valor PEKING en `Opportunity.BMW_Compania__c` | `QuoteSoftlandPedidoService`, `QuoteService` | ¿Se agrega al picklist o se avanza poblando `Empresa_Operadora__c`? |
| Registros de `Empresa__c` | Todas las rutas del lookup | ¿Cuándo se crean Bavarian, Otobai y PEKING como registros? |
| `getPricebookName` | `QuoteService` | ¿Fue retirado a propósito del org? |
| Anticipos y enlace de pago para PEKING | `OpportunityServiceInvoker`, `Registrar_Anticipo_Controller` | ¿PEKING opera anticipos en este Sprint? |

## 8. Orden final recomendado

1. Verificar `getPricebookName` con los comandos de 5.1.
2. Reconciliar a Git las siete clases de la sección 6 y ejecutar su regresión.
3. Crear los registros de `Empresa__c` para Bavarian, Otobai y PEKING.
4. Resolver la convención de bodega de PEKING.
5. Recién entonces retomar `QuoteService` y el cierre funcional de PEKING en
   anticipos y reservas.

No se declara ninguna clase bloqueada de forma definitiva: las de categoría C y D
tienen el camino identificado y dependen de datos, no de análisis.
