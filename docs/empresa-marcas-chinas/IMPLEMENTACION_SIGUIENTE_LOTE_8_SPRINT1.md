# Siguiente lote de 8 clases — preanálisis estático

Estado: **preanálisis únicamente**. No se escribió código productivo, no se ejecutó
Salesforce CLI, no se consultó ninguna org y no se desplegó nada. Ninguna clase se
declara bloqueada: para cada una se indica qué falta verificar en Partial.

Base del análisis: código presente en el worktree
`RedMotors-Sprint1-Reconciliacion33`, rama
`analysis/pc/redmotors-sprint1-reconcile-33x3-20260727`.

Limitación del entorno: este entorno no tiene `sf` CLI y el proxy bloquea el
acceso a Salesforce (`X-Proxy-Error: blocked-by-allowlist`). Por eso los comandos
de la sección 6 están escritos para ejecutarse en tu PC.

## 1. Resumen por clase

| # | Clase | Fuente actual de Empresa | Patrón a corregir | ¿Implementable solo con el repo? |
|---:|---|---|---|---|
| 1 | `QuoteSoftlandPedidoService` | `Quote.Opportunity.BMW_Compania__c` | `if Bavarian → RMBAVARIAN else RMOTOBAI` | No — requiere confirmar contrato Softland de PEKING |
| 2 | `QuoteSoftlandQueryService` | ninguna; solo provee el SOQL | No selecciona `Empresa_Operadora__c` | **Sí** |
| 3 | `servicioReservas` | `Product2.Empresa__c` | Normaliza etiquetas y admite solo dos códigos | Parcial — falta confirmar valores de picklist |
| 4 | `servicioEliminarReserva` | `Product2.Empresa__c` | Admite **solo** `RMBAVARIAN` | Parcial — misma verificación |
| 5 | `OpportunityServiceInvoker` | `Opportunity.Pricebook2.Name` | Inicializa `RMBAVARIAN`; solo `contains('Otobai')` cambia | **Sí** |
| 6 | `Registrar_Anticipo_Controller` | `Opportunity.Pricebook2.Name` | Mismo patrón en dos bloques | **Sí** |
| 7 | `QuoteService` | RecordType y nombres de Pricebook | Constante muerta + default `Standard Price Book` | **Sí** |
| 8 | `productJSON` | parámetro `empresa` del JSON entrante | Ramas binarias en producto y bodega | No — requiere datos de bodega PEKING |

---

## 2. Lote 1 — Pedido Softland

### 2.1 `QuoteSoftlandPedidoService`

**Implementación actual.** 407 líneas. El único punto empresarial está en
`calculateQuotePedidoPayload()`, líneas 25–30:

```apex
String empresa;
if(quote.opportunity.bmw_compania__c == 'Bavarian'){
    empresa = 'RMBAVARIAN';
}else{
    empresa = 'RMOTOBAI';
}
```

El valor se asigna a `payload.compania` (línea 57). No hay validación posterior.

**Llamadores.** `QuoteOrderSoftlandCallout` construye el servicio; el
`QuoteSoftlandQueryService` es una dependencia interna (constructor, línea 11).

**Pruebas.** No existe `QuoteSoftlandPedidoServiceTest`. La cobertura viene de
`TestServiciosQuote`, que también cubre `QuoteOrderSoftlandCallout`.

**Campos consumidos.** `Quote.Opportunity.BMW_Compania__c`,
`Quote.CurrencyIsoCode`, `Quote.Centro_de_Costo__c` → `CentroCosto__c.centroCosto__c`,
`Quote.BMW_CostoFijo__c`, `Quote.Precio_empleado__c`, `Quote.Cuenta_de_facturaci_n2__c`,
`Quote.Opportunity.sucursal__c`.

**Fallback.** Cualquier valor distinto de `Bavarian` —incluido nulo, `PEKING` o un
valor desconocido— se envía a Softland como `RMOTOBAI`. Es el peor caso del lote:
un pedido de PEKING se factura en Otobai sin error visible.

**Callout / payload.** Esta clase solo construye el payload;
`payload.compania` es el campo empresarial. El envío ocurre en
`QuoteOrderSoftlandCallout`.

**Cambio mínimo propuesto.** Resolver desde
`Opportunity.Empresa_Operadora__r.Codigo_ERP__c` cuando el lookup esté informado;
usar `BMW_Compania__c` solo como respaldo mediante una tabla explícita
`Bavarian→RMBAVARIAN`, `Otobai→RMOTOBAI`, `PEKING→RMPEKING`; lanzar
`EmpresaConfigurationException` ante nulo o desconocido, **antes** de construir el
payload. No tocar moneda, centro de costo ni tipo de cliente.

**Riesgos.** El pedido es una transacción financiera: un fallo que hoy pasa
silencioso pasaría a bloquear el envío. Hay que confirmar con Diego o Luis que
bloquear es el comportamiento deseado frente a seguir enviando a Otobai.

**Verificar en Partial.**
1. Que `Empresa__c` de PEKING exista y tenga `Codigo_ERP__c` poblado.
2. Que el contrato Softland acepte `RMPEKING` en el endpoint de pedido — si no,
   el cambio debe detenerse antes del callout en vez de enviar un código que el
   ERP rechace.
3. Valores activos de `Opportunity.BMW_Compania__c` (¿existe ya un valor PEKING?).
4. Si `Opportunity.Empresa_Operadora__c` está poblado en Quotes reales.

### 2.2 `QuoteSoftlandQueryService`

**Implementación actual.** 260 líneas, de las cuales la lógica real son 13. Un
único SOQL en `init()` que selecciona `opportunity.bmw_compania__c` pero **no**
`opportunity.Empresa_Operadora__c`. El resto del archivo es un método `Method()`
con declaraciones de enteros sin uso, aparentemente relleno de cobertura.

**Llamadores.** Solo `QuoteSoftlandPedidoService` (constructor).

**Pruebas.** Indirectas vía `TestServiciosQuote`.

**Fallback.** Ninguno propio. La clase no decide empresa; el riesgo es de omisión:
al no traer el lookup, obliga al consumidor a decidir con el campo heredado.

**Cambio mínimo propuesto.** Agregar al SOQL
`opportunity.Empresa_Operadora__c`, `opportunity.Empresa_Operadora__r.Codigo__c` y
`opportunity.Empresa_Operadora__r.Codigo_ERP__c`. No cambiar el filtro ni el
retorno. Es un cambio aditivo y es **prerequisito** de 2.1.

**Riesgos.** Mínimos. El único cuidado es no romper la firma pública `getQuotes()`.

**Verificar en Partial.** Que el lookup `Opportunity.Empresa_Operadora__c` exista
con ese API name y que el perfil de integración tenga FLS de lectura sobre él y
sobre `Empresa__c.Codigo_ERP__c`.

---

## 3. Lote 2 — Reservas

### 3.1 `servicioReservas`

**Implementación actual.** 105 líneas. `getReservaById(Id OppId, Id ProdId)`:

```apex
Opportunity thisOpportunity = [SELECT Id, Name, BMW_Compania__c, ModelosProductos__c ...];
Product2 thisProduct = [SELECT Id, vin__c, Empresa__c ...];
if (thisProduct.Empresa__c == 'Bavarian') thisProduct.Empresa__c = 'RMBAVARIAN';
if (thisProduct.Empresa__c == 'Otobai')  thisProduct.Empresa__c = 'RMOTOBAI';

if (thisProduct.Empresa__c == 'RMBAVARIAN' || thisProduct.Empresa__c == 'RMOTOBAI'){
    ... callout reserveVehicule ...
} else {
    responseMap.put('error', 'Empresa no válida');
}
```

**Llamadores.** `ReservaOportunidadController`, `ReservaOppUsadosController`.

**Pruebas.** `servicioReservasTest` con `servicioReservasMock`.

**Campos consumidos.** `Product2.Empresa__c`, `Product2.vin__c`,
`Opportunity.Name`, `Opportunity.BMW_Compania__c` (se consulta pero **nunca se
usa**).

**Fallback.** No hay fallback silencioso: una empresa desconocida cae en
`'Empresa no válida'`. Eso es correcto por diseño accidental, pero hoy **excluye a
PEKING**.

**Callout.** `GET {URLSoftland}/ServiciosSoftlandProductivos/softlandAPI/catalogs/reserveVehicule?json=...`
con `{"compania": ..., "codArticulo": vin__c, "oportunidad": Opportunity.Name}`.
Nota: el segmento `ServiciosSoftlandProductivos` está **fijo en el código**, a
diferencia de otras clases que usan `Label.ambienteSoftland`. Es una inconsistencia
preexistente que conviene registrar, no necesariamente corregir en este cambio.

**Cambio mínimo propuesto.** Sustituir la mutación en memoria de
`thisProduct.Empresa__c` por una variable local resuelta con una tabla explícita
que incluya `RMPEKING`, y agregar validación de coherencia entre la empresa del
producto y la de la Opportunity (`Empresa_Operadora__r.Codigo__c` con respaldo en
`BMW_Compania__c`), devolviendo error controlado si discrepan. Mantener el
comportamiento actual para Bavarian y Otobai.

**Riesgos.** Introducir la validación de coherencia puede bloquear reservas que
hoy funcionan si los datos históricos tienen producto y oportunidad de empresas
distintas. Hay que medir cuántos casos existen antes de activarla.

**Verificar en Partial.**
1. Valores activos de `Product2.Empresa__c` — ¿siguen existiendo las etiquetas
   `Bavarian` y `Otobai`, o ya solo los códigos `RM*`? De eso depende si las dos
   líneas de normalización siguen siendo necesarias.
2. Si el endpoint `reserveVehicule` acepta `RMPEKING`.
3. Cuántas Opportunities tienen producto con empresa distinta a la de la
   oportunidad (medir el impacto de la validación de coherencia).

### 3.2 `servicioEliminarReserva`

**Implementación actual.** 62 líneas.

```apex
if (thisProduct.Empresa__c == 'Bavarian') thisProduct.Empresa__c = 'RMBAVARIAN';
//thisProduct.Empresa__c = 'RMBAVARIAN';
if (thisProduct.Empresa__c == 'RMBAVARIAN'){
    ... callout unreserveVehicule ...
}
```

**Defecto encontrado.** La simetría está rota **hoy**, antes de PEKING:
`servicioReservas` reserva para Bavarian y Otobai, pero
`servicioEliminarReserva` solo libera **Bavarian**. Una reserva de Otobai no puede
liberarse por esta vía: el método simplemente no entra al `if` y retorna la
respuesta vacía sin error. Además hay código anterior comentado en la línea 37.

**Llamadores.** `QuitarReservaController`, `QuitarReservaUsadosController`;
también aparece en `ReservaOportunidadController` y `ReservaOppUsadosController`.

**Pruebas.** `servicioEliminarReservaTest` con `servicioEliminarReservaMock`.

**Callout.** `GET .../softlandAPI/catalogs/unreserveVehicule?json=...`, mismo
formato que la reserva.

**Cambio mínimo propuesto.** Usar exactamente la misma resolución que
`servicioReservas` (idealmente un método compartido), admitir `RMBAVARIAN`,
`RMOTOBAI` y `RMPEKING`, devolver error controlado en cualquier otro caso y
eliminar el comentario de la línea 37.

**Riesgos.** Habilitar Otobai cambia comportamiento productivo existente: hoy esas
liberaciones fallan en silencio. Es una corrección de defecto, no solo soporte de
PEKING, y conviene que Luis lo sepa antes de desplegarla.

**Verificar en Partial.** Si existen reservas activas de Otobai que quedarían
liberables a partir del cambio, y si el endpoint `unreserveVehicule` acepta
`RMOTOBAI` y `RMPEKING`.

---

## 4. Lote 3 — Anticipos

### 4.1 `OpportunityServiceInvoker`

**Implementación actual.** 1796 líneas; la lógica empresarial está en las líneas
13–35 del método invocable `sendOpportunity`:

```apex
String pricebookname = 'RMBAVARIAN';
if(opp.Id != null){
    try{
        Opportunity opp2 = [Select Id,Pricebook2Id from opportunity Where Id=:opp.Id];
        if(opp2.Pricebook2Id != null){
            Pricebook2 pb = [Select Id,Name from Pricebook2 Where Id=: opp.Pricebook2Id];
            if(pb!=null){
                if(pb.Name.contains('Otobai')){ pricebookname = 'RMOTOBAI'; }
            }
        }
    }catch(Exception e){ System.debug('Error--'+e.getMessage()); }
}
```

**Fallback.** Triple: el valor inicial es `RMBAVARIAN`; solo `contains('Otobai')`
lo cambia; y el `catch` se traga cualquier excepción dejando el default. `PEKING
Local` y `PEKING Dólares` no contienen "Otobai", así que PEKING se envía como
Bavarian.

**Defecto adicional.** `opp` y `opp2` consultan lo mismo dos veces, y el
`Pricebook2` se busca por `opp.Pricebook2Id` mientras la comprobación de nulo se
hace sobre `opp2.Pricebook2Id`.

**Llamadores.** Método `@InvocableMethod` — lo invocan Flows. Hay que identificar
cuáles antes de cambiar el contrato (el cambio propuesto no altera la firma).

**Pruebas.** `OpportunityServiceInvokerTest`.

**Cambio mínimo propuesto.** Resolver una sola vez: preferir
`Opportunity.Empresa_Operadora__r.Codigo_ERP__c`; si no está informado, mapear el
nombre del Pricebook con la tabla de seis nombres ya autorizada
(`Bavarian Local/Dólar`, `Otobai Local/Dólares`, `PEKING Local/Dólares`); ante
nulo o desconocido lanzar error controlado antes de invocar el servicio. Retirar
la consulta duplicada y dejar de silenciar la excepción.

**Riesgos.** Es un invocable de Flow: un error no capturado interrumpe el Flow.
Hay que decidir si se propaga la excepción o se registra y se aborta el envío.

**Verificar en Partial.** Qué Flows invocan este método y cómo manejan el fallo;
si `Empresa_Operadora__c` está poblado en las Opportunities que lo usan.

### 4.2 `Registrar_Anticipo_Controller`

**Implementación actual.** 2008 líneas. El mismo patrón aparece **dos veces**:
líneas 35–44 y 123–130, ambas con `String pricebookname = 'RMBAVARIAN'` y
`if(pb.Name.contains('Otobai'))`.

**Llamadores.** Controlador de UI; `RegistrarAnticipoCasillasTst` sugiere un
segundo punto de entrada.

**Pruebas.** `Registrar_Anticipo_Controller_Test` y `RegistrarAnticipoCasillasTst`.

**Fallback.** Idéntico a 4.1, duplicado. Un anticipo de PEKING se registraría
contra Bavarian.

**Cambio mínimo propuesto.** Extraer la resolución a un método privado único,
resolverla una vez por transacción y reutilizar el resultado en ambos bloques.
Misma tabla de seis nombres y mismo error controlado.

**Riesgos.** Impacto contable directo. La regresión de Bavarian y Otobai debe
probarse con especial cuidado; conviene incluir `RegistrarAnticipoCasillasTst` en
la regresión seleccionada.

**Verificar en Partial.** Si existen anticipos históricos con Pricebook cuyo
nombre no contenga ni "Bavarian" ni "Otobai" (hoy quedaron como Bavarian).

---

## 5. Lote 4 — Pricebook, producto e inventario

### 5.1 `QuoteService`

**Hallazgo que cambia el enunciado.** La constante existe:

```apex
public static final String PRICEBOOK_NAME = 'Bavarian Dólar';   // línea 3
```

pero **no está referenciada en ninguna clase del repositorio**. Es código muerto.
El criterio "eliminar constantes de Pricebook usadas como default" no aplica tal
cual: aquí la constante no se usa. Los defaults reales son otros dos:

1. `getPricebookName(String oppId)` (líneas 259–271) inicializa
   `pricebookName = 'Standard Price Book'` y solo lo cambia a
   `'Venta Consumidor Final'` cuando el RecordType es `Venta_Consumidor_Final`.
   No interviene la empresa.
2. Búsqueda de precio de fantasía (líneas ~128–140) por
   `Pricebook2.Name LIKE '%marca%' AND Pricebook2.Name LIKE '%año%'` con moneda
   fija `'USD'`, y un segundo intento con marca y año alternativos antes de lanzar
   `AuraHandledException`.

**Llamadores.** Amplios: `RM_SyncQuoteController`, `RM_VN_QuoteController`,
`RM_VN_CambiarVehiculo_Ctrl`, `RM_VN_CrearOportunidad_Ctrl`,
`RM_Lead_Trigger_Helper`, además de handlers de trigger de Quote y
OpportunityLineItem. Es la clase con mayor superficie de regresión del lote.

**Pruebas.** `QuoteServiceControllerTest`.

**Cambio mínimo propuesto.** Dos pasos independientes: retirar la constante muerta
(cambio trivial y seguro), y añadir el filtro de empresa a la selección de
Pricebook —por relación o por nombre autorizado— sin alterar el comportamiento
por RecordType. El segundo paso solo tiene sentido si negocio confirma qué lista
corresponde a PEKING en venta de vehículo nuevo.

**Riesgos.** Alto por número de llamadores. Recomiendo separarlo en dos commits.

**Verificar en Partial.** Si existen Pricebooks de PEKING con marca y año en el
nombre siguiendo la convención de fantasía; qué nombre usa PEKING para el
equivalente de `Venta Consumidor Final`.

### 5.2 `productJSON`

**Implementación actual.** 944 líneas. La empresa **no** se resuelve desde
Salesforce: llega como dato externo.

```apex
public static String createProduct(String jsonStr)   // línea 9
String empresa = wrapProductJSON.empresa;            // línea 36
```

El punto de entrada es `productWS`, un `@RestResource(urlMapping='/product/')`
con `@HttpPost`: **Softland es quien llama**. Dos ramas binarias, cada una
duplicada en el camino de creación y en el de actualización:

- Producto (líneas 100–115): `RMBAVARIAN` busca por `Codigo_de_Producto__c`;
  `RMOTOBAI` busca por `CodigoProductoInterno__c = articulo+'-'+empresa`.
  Cualquier otro valor deja la lista `prod` **sin inicializar**.
- Bodega (líneas 286–289 y 526–529): `RMBAVARIAN` busca
  `ID_EXTERNO_BODEGA__c = disponible.bodega`; el `else` **implícito** busca
  `'RMOTOBAI' + disponible.bodega`. Una empresa desconocida consultaría bodegas
  con prefijo de Otobai.

**Llamadores.** `productWS` (REST entrante) y `productJSONTest`.

**Campos consumidos.** `Product2.Codigo_de_Producto__c`,
`Product2.CodigoProductoInterno__c`, `Product2.Empresa__c`,
`Bodega__c.ID_EXTERNO_BODEGA__c`, `Bodega__c.Bodega__c`,
`ProductoXBodega__c.Identificador__c`.

**Fallback.** El de bodega es el más grave: no es un default a Bavarian sino a
**Otobai**, y produciría inventario cruzado si PEKING llegara sin rama propia.

**Cambio mínimo propuesto.** Validar `empresa` contra los códigos configurados en
`Empresa__c` al inicio de `createProduct`, rechazando con error explícito antes de
cualquier SOQL o DML; sustituir el `else` implícito de bodega por ramas explícitas
por empresa; y validar que la bodega encontrada pertenezca a la misma empresa del
producto.

**Riesgos.** Es una integración entrante: rechazar payloads que hoy se aceptan
puede romper la sincronización de Softland. El cambio debe acordarse con quien
opera la integración.

**Verificar en Partial.**
1. Convención de `ID_EXTERNO_BODEGA__c` para PEKING: ¿lleva prefijo `RMPEKING`,
   otro, o ninguno? **Este dato no puede inventarse.**
2. Si existen bodegas de PEKING creadas.
3. Convención de `CodigoProductoInterno__c` para PEKING.
4. Valores activos de `Product2.Empresa__c` tras el Bloque 17.

---

## 6. Comandos para ejecutar en tu PC

PowerShell, desde la raíz del worktree en el que vayas a implementar. Sustituye
`RedMotorsSandbox` si usas otro alias.

### 6.1 Verificación inicial

```powershell
sf org display --target-org RedMotorsSandbox
sf data query --target-org RedMotorsSandbox --result-format human `
  --query "SELECT Id, Name, IsSandbox FROM Organization"
```

### 6.2 Recuperar las 8 clases y sus pruebas

```powershell
sf project retrieve start --target-org RedMotorsSandbox `
  --metadata "ApexClass:QuoteSoftlandPedidoService" `
             "ApexClass:QuoteSoftlandQueryService" `
             "ApexClass:servicioReservas" `
             "ApexClass:servicioEliminarReserva" `
             "ApexClass:OpportunityServiceInvoker" `
             "ApexClass:Registrar_Anticipo_Controller" `
             "ApexClass:QuoteService" `
             "ApexClass:productJSON" `
  --output-dir tmp-partial

sf project retrieve start --target-org RedMotorsSandbox `
  --metadata "ApexClass:servicioReservasTest" `
             "ApexClass:servicioEliminarReservaTest" `
             "ApexClass:OpportunityServiceInvokerTest" `
             "ApexClass:Registrar_Anticipo_Controller_Test" `
             "ApexClass:RegistrarAnticipoCasillasTst" `
             "ApexClass:QuoteServiceControllerTest" `
             "ApexClass:productJSONTest" `
             "ApexClass:TestServiciosQuote" `
             "ApexClass:servicioReservasMock" `
             "ApexClass:servicioEliminarReservaMock" `
  --output-dir tmp-partial
```

### 6.3 Comparar Git contra Partial

```powershell
$clases = @(
  'QuoteSoftlandPedidoService','QuoteSoftlandQueryService','servicioReservas',
  'servicioEliminarReserva','OpportunityServiceInvoker','Registrar_Anticipo_Controller',
  'QuoteService','productJSON'
)
foreach ($c in $clases) {
  $git     = "force-app/main/default/classes/$c.cls"
  $partial = "tmp-partial/main/default/classes/$c.cls"
  Write-Host "=== $c ==="
  git diff --no-index --stat -- $git $partial
}
```

Cualquier diferencia distinta de fin de línea significa que Partial tiene cambios
que no están en Git y hay que reconciliar **antes** de tocar la clase.

Fecha de última modificación en la org, para saber si alguien más la está tocando:

```powershell
sf data query --use-tooling-api --target-org RedMotorsSandbox --result-format human `
  --query "SELECT Name, LastModifiedDate, LastModifiedBy.Name, ApiVersion, Status FROM ApexClass WHERE Name IN ('QuoteSoftlandPedidoService','QuoteSoftlandQueryService','servicioReservas','servicioEliminarReserva','OpportunityServiceInvoker','Registrar_Anticipo_Controller','QuoteService','productJSON') ORDER BY LastModifiedDate DESC"
```

### 6.4 Configuración de Empresa

```powershell
sf data query --target-org RedMotorsSandbox --result-format human `
  --query "SELECT Id, Name, Codigo__c, Codigo_ERP__c, Nombre_Legal__c, Activa__c FROM Empresa__c ORDER BY Name"
```

### 6.5 Picklists y campos

```powershell
# Valores activos de los campos de empresa
sf sobject describe --sobject Product2    --target-org RedMotorsSandbox | Out-File describe-Product2.json
sf sobject describe --sobject Opportunity --target-org RedMotorsSandbox | Out-File describe-Opportunity.json
sf sobject describe --sobject Quote       --target-org RedMotorsSandbox | Out-File describe-Quote.json
sf sobject describe --sobject Bodega__c   --target-org RedMotorsSandbox | Out-File describe-Bodega.json
```

Confirmación puntual de que el lookup existe y es legible:

```powershell
sf data query --target-org RedMotorsSandbox --result-format human `
  --query "SELECT Id, Empresa_Operadora__c, Empresa_Operadora__r.Codigo__c, Empresa_Operadora__r.Codigo_ERP__c, BMW_Compania__c FROM Opportunity WHERE Empresa_Operadora__c != null LIMIT 20"
```

### 6.6 Datos que decide cada lote

Lote 1 — pedido Softland:

```powershell
sf data query --target-org RedMotorsSandbox --result-format human `
  --query "SELECT BMW_Compania__c, COUNT(Id) FROM Opportunity GROUP BY BMW_Compania__c"
```

Lote 2 — reservas:

```powershell
sf data query --target-org RedMotorsSandbox --result-format human `
  --query "SELECT Empresa__c, COUNT(Id) FROM Product2 GROUP BY Empresa__c"

# Productos cuya empresa difiere de la de su Opportunity (impacto de la validación de coherencia)
sf data query --target-org RedMotorsSandbox --result-format human `
  --query "SELECT Id, Name, Empresa__c FROM Product2 WHERE Empresa__c != null AND esVehiculo__c = true LIMIT 50"
```

Lote 3 — anticipos:

```powershell
sf data query --target-org RedMotorsSandbox --result-format human `
  --query "SELECT Id, Name, IsActive, CurrencyIsoCode FROM Pricebook2 ORDER BY Name"

# Opportunities cuyo Pricebook no contiene Bavarian ni Otobai: hoy quedan como Bavarian
sf data query --target-org RedMotorsSandbox --result-format human `
  --query "SELECT Id, Name, Pricebook2.Name FROM Opportunity WHERE Pricebook2Id != null AND (NOT Pricebook2.Name LIKE '%Bavarian%') AND (NOT Pricebook2.Name LIKE '%Otobai%') LIMIT 50"
```

Lote 4 — Pricebook, producto e inventario:

```powershell
# Convención de bodegas: dato imprescindible para productJSON
sf data query --target-org RedMotorsSandbox --result-format human `
  --query "SELECT Id, Name, Bodega__c, ID_EXTERNO_BODEGA__c FROM Bodega__c ORDER BY ID_EXTERNO_BODEGA__c"

sf data query --target-org RedMotorsSandbox --result-format human `
  --query "SELECT Id, Name, Codigo_de_Producto__c, CodigoProductoInterno__c, Empresa__c FROM Product2 WHERE Empresa__c = 'RMPEKING' LIMIT 50"

# Flows que invocan OpportunityServiceInvoker
sf data query --use-tooling-api --target-org RedMotorsSandbox --result-format human `
  --query "SELECT Id, DeveloperName, ActiveVersionId FROM FlowDefinition"
```

### 6.7 Ciclo por clase, una vez decidido el cambio

```powershell
# Pruebas enfocadas
sf apex run test --target-org RedMotorsSandbox --tests <ClaseTest> `
  --result-format human --code-coverage --wait 30

# Dry-run
sf project deploy start --target-org RedMotorsSandbox --dry-run `
  --manifest manifest/<manifest-de-la-clase>.xml `
  --test-level RunSpecifiedTests --tests <ClaseTest> --wait 30

# Deploy real (solo Partial)
sf project deploy start --target-org RedMotorsSandbox `
  --manifest manifest/<manifest-de-la-clase>.xml `
  --test-level RunSpecifiedTests --tests <ClaseTest> --wait 30

# Post-deploy
sf apex run test --target-org RedMotorsSandbox --tests <ClaseTest> `
  --result-format human --code-coverage --wait 30
```

---

## 7. Qué se puede implementar con el repositorio y qué no

**Implementable solo con el repositorio** (el cambio no depende de ningún dato
externo desconocido):

- `QuoteSoftlandQueryService` — añadir campos al SOQL.
- `OpportunityServiceInvoker` — los seis nombres de Pricebook ya están
  autorizados y documentados en el Bloque 2.
- `Registrar_Anticipo_Controller` — misma tabla de nombres.
- `QuoteService`, paso 1 — retirar la constante muerta `PRICEBOOK_NAME`.

**Requiere resultados de Partial antes de escribir código:**

- `QuoteSoftlandPedidoService` — `Codigo_ERP__c` de PEKING y aceptación de
  `RMPEKING` por el contrato de pedido.
- `servicioReservas` y `servicioEliminarReserva` — valores activos de
  `Product2.Empresa__c` y aceptación de `RMPEKING`/`RMOTOBAI` por los endpoints
  de reserva y liberación.
- `QuoteService`, paso 2 — qué Pricebook corresponde a PEKING.
- `productJSON` — convención de `ID_EXTERNO_BODEGA__c` para PEKING. Es el único
  dato del lote que **no puede deducirse del código**.

## 8. Orden recomendado

1. `QuoteSoftlandQueryService` — aditivo, sin riesgo, y habilita el siguiente.
2. `OpportunityServiceInvoker` — patrón acotado, tabla ya autorizada.
3. `Registrar_Anticipo_Controller` — mismo patrón, cierra anticipos.
4. `QuoteService` paso 1 — retirar la constante muerta.
5. `QuoteSoftlandPedidoService` — en cuanto se confirme el `Codigo_ERP__c`.
6. `servicioEliminarReserva` — corrige la asimetría con Otobai, que es un defecto
   actual independiente de PEKING.
7. `servicioReservas` — junto con la anterior, para mantener la simetría.
8. `QuoteService` paso 2 y `productJSON` — al final, cuando existan las
   definiciones de Pricebook y bodega de PEKING.

Los cuatro primeros pueden ejecutarse de inmediato con los comandos de la sección
6.7. Los cuatro últimos requieren primero las consultas de la sección 6.6.
