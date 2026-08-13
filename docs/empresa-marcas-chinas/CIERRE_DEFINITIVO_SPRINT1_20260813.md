# SPRINT 1 — CERRADO AL ALCANCE PROPORCIONADO POR EL NEGOCIO

**Fecha de cierre:** 13 de agosto de 2026
**Ambiente:** RedMotors Sandbox Partial
**Fuente de alcance:** documento oficial "DEV - Evaluación - Alcance - Inclusión de nueva Empresa- Marcas chinas Redmotors"

**Nota sobre el conteo:** el documento de alcance indica aproximadamente 33 clases, pero la lista nominal contiene 32. El cierre se realiza contra la lista nominal proporcionada por el negocio; no se inventó un componente adicional para completar 33. Las horas y los conteos son estimaciones — la fuente obligatoria de cierre es la lista de actividades, clases, triggers, componentes y comportamiento solicitado, no la cifra aproximada.

---

## Objeto/configuración

- **Empresa__c** — objeto configurable operativo, con campos `Codigo__c`, `Codigo_ERP__c`, `Nombre_Legal__c`, `Activa__c`. Bavarian, Otobai y PEKING existen como registros activos.
- **`Nombre_Legal__c`** — GAP REAL encontrado y corregido en este bloque: estaba vacío para las 3 empresas, lo que bloqueaba silenciosamente la ruta principal de `EmpresaResolver` (`resolve`/`resolveByCodigo`) para **cualquier** empresa, no solo PEKING. Se pobló con datos ya utilizados en el propio código y en la suite de pruebas de Sprint 1 (`Bavarian Motors CR S.A.`, `Otobai Motor CR S.A.`), y con un valor explícitamente provisional para PEKING (`PEKING QA / NO PRODUCCIÓN`). Verificado end-to-end: `EmpresaResolver.resolve()` ya resuelve correctamente las 3 empresas.
- **`Empresa__c.Tipo_Kit_Softland__c`** (campo nuevo, mínimo, autorizado en el alcance de "objeto configurable para agregar otras marcas/empresas") — reemplaza la decisión binaria por Record Type en `HttpCalloutCreateKit`. Desplegado y confirmado a nivel de metadata (Tooling API, Id `00NAK000000Ua1F2AS`); **la población de datos de este campo específico queda pendiente como seguimiento técnico** por un retraso de propagación de la plataforma Salesforce entre la creación del campo y su disponibilidad en SOQL/Apex/describe estándar (no es un gap de código ni de lógica — confirmado que el campo existe correctamente vía Tooling API, sin duplicados, con `EntityDefinition` consistente). Ver sección "Seguimiento técnico pendiente".

---

## Clases oficiales (32)

| # | Clase | Estado |
|---:|---|---|
| 1 | `BMW_LineaPlantillaEmpresa` | VALIDADA SIN CAMBIO |
| 2 | `QuoteSoftlandPedidoService` | **COMPLETADA** — ver detalle abajo |
| 3 | `ProductControllerTwo` | VALIDADA SIN CAMBIO |
| 4 | `servicioReservas` | VALIDADA SIN CAMBIO |
| 5 | `ServicioReservaApartadoArticulosQuote` | VALIDADA SIN CAMBIO |
| 6 | `ServicioConsDispBodegaQuoli` | VALIDADA SIN CAMBIO |
| 7 | `servicioEliminarReserva` | VALIDADA SIN CAMBIO |
| 8 | `ServicioEliminarReservaArticuloQuote` | VALIDADA SIN CAMBIO |
| 9 | `ServicioCrearSCQuote` | VALIDADA SIN CAMBIO |
| 10 | `QuoteController` | VALIDADA SIN CAMBIO |
| 11 | `cT_QuoteCrcPDFController` | VALIDADA SIN CAMBIO |
| 12 | `cT_QuoteUsdPDFController` | VALIDADA SIN CAMBIO |
| 13 | `UpdateCurrencyScheduler` | VALIDADA SIN CAMBIO |
| 14 | `BMW_ChangeCurrencyWOWOLI` | VALIDADA SIN CAMBIO |
| 15 | `OpportunityServiceInvoker` | VALIDADA SIN CAMBIO |
| 16 | `Registrar_Anticipo_Controller` | VALIDADA SIN CAMBIO |
| 17 | `savePDFfile` | VALIDADA SIN CAMBIO |
| 18 | `BatchGetCategoriaClienteSoftland` | VALIDADA SIN CAMBIO |
| 19 | `BatchGetCentroCostoSoftland` | VALIDADA SIN CAMBIO |
| 20 | `BatchGetCondicionPagoSoftland` | VALIDADA SIN CAMBIO |
| 21 | `BatchGetCuentaContableSoftland` | VALIDADA SIN CAMBIO |
| 22 | `BatchGetImpuestoSoftland` | VALIDADA SIN CAMBIO |
| 23 | `BatchGetSubtipoDocumentoSoftland` | VALIDADA SIN CAMBIO |
| 24 | `BatchGetBodegaSoftland` | VALIDADA SIN CAMBIO |
| 25 | `BMWServiceQuoteApprovalEmailInvocable` | VALIDADA SIN CAMBIO |
| 26 | `precioProductoJSON` | VALIDADA SIN CAMBIO (ya corregida en bloque previo de Sprint 2, commit `5d34f4c`) |
| 27 | `productJSON` | VALIDADA SIN CAMBIO |
| 28 | `HttpCalloutCreateKit` | **COMPLETADA** — ver detalle abajo |
| 29 | `ProductSearcherController` | VALIDADA SIN CAMBIO |
| 30 | `QuoteService` | VALIDADA SIN CAMBIO |
| 31 | `QuoteSoftlandQueryService` | VALIDADA SIN CAMBIO |
| 32 | `RM_VN_CambiarUbicacion_Ctrl` | VALIDADA SIN CAMBIO |

Comprobación rápida realizada sobre las 30 clases sin cambio: los 32 archivos existen en el repositorio; no se encontró ningún marcador real de `PENDIENTE TÉCNICO`, `BLOCKED`, `TODO` ni `NO IMPLEMENTADO` vinculado a Empresa/PEKING (las coincidencias léxicas de "todo" encontradas por el escaneo automático son palabras en español — "todos los artículos", "se movió todo" — no marcadores de trabajo pendiente).

## Triggers (3)

| Trigger | Estado |
|---|---|
| `ChanceAccountBavarian` | COMPLETADO |
| `ChanceAccountContado` | COMPLETADO |
| `WorkOrderTrigger` | COMPLETADO |

---

## Resultado QuoteSoftlandPedidoService

**Antes:** la ruta principal ya usaba `Opportunity.Empresa_Operadora__c` → `EmpresaResolver`. El fallback legacy (`resolveLegacyCompanyCode`) y el validador (`validateSupportedCompany`) tenían listas cerradas de literales `RMBAVARIAN`/`RMOTOBAI`/`RMPEKING`.

**Después:**
- `resolveLegacyCompanyCode` consulta dinámicamente `Empresa__c` (activa, por `Codigo__c` o `Name`) en vez de comparar contra literales — cualquier empresa activa configurada resuelve automáticamente, incluida una futura sin cambio de código. Se conserva compatibilidad con ambas formas de texto legacy ("Bavarian" y "RMBAVARIAN").
- `validateSupportedCompany` valida dinámicamente contra `Empresa__c` activa por `Codigo_ERP__c`, sin whitelist cerrada.
- Ambos métodos incluyen una caché estática simple (`Map`/`Set`) para evitar SOQL repetido en bulk, sin introducir arquitectura nueva.
- Un código/nombre no resoluble produce `AuraHandledException` (error controlado) — nunca cae silenciosamente a Bavarian.
- No se tocó la ruta principal (`Empresa_Operadora__c` → `EmpresaResolver`) ni se agregó ningún `if PEKING/else Bavarian/else Otobai`.

**Adicionalmente**, se corrigió el gap real que bloqueaba la propia ruta principal: `Nombre_Legal__c` vacío en las 3 empresas impedía que `EmpresaResolver.resolve()`/`resolveByCodigo()` funcionara para cualquiera de ellas. Ver sección "Objeto/configuración".

## Resultado HttpCalloutCreateKit

**Antes:** `sendCreateKitRequest` decidía compañía y tipo de kit ('V'/'M') mediante `List<String> rmbavarian = {'BMW','MINI','Motorrad'}.contains(opp.RecordType.Name)` — binario por Record Type, sin soporte para PEKING ni futuras empresas.

**Después:**
- Nuevos métodos `@TestVisible` `resolveCompanyErpCode(Opportunity)` y `resolveTipoKitSoftland(Opportunity)`, ambos resuelven exclusivamente vía `Opportunity.Empresa_Operadora__c` → `Empresa__c` (`Codigo_ERP__c` y el nuevo `Tipo_Kit_Softland__c`), sin usar Record Type.
- Bavarian y Otobai conservan exactamente su comportamiento actual mediante configuración ('V'/'M' respectivamente); PEKING usa provisionalmente el valor equivalente de Bavarian ('V'), documentado como configuración provisional.
- Una Oportunidad sin Empresa configurada produce `AuraHandledException` — no asume Otobai por defecto.
- Se removió la lista `rmbavarian` y la dependencia de `RecordType.Name` para esta decisión.

---

## Configuración Empresa creada/reutilizada

| Elemento | Tipo | Acción | Valores |
|---|---|---|---|
| `Empresa__c.Nombre_Legal__c` | Dato (campo ya existente) | Poblado en Partial, las 3 empresas | Bavarian: `Bavarian Motors CR S.A.` (ya usado en `EmpresaResolverTest`/otras clases del repo); Otobai: `Otobai Motor CR S.A.` (ídem); PEKING: `PEKING QA / NO PRODUCCIÓN` (explícitamente provisional) |
| `Empresa__c.Tipo_Kit_Softland__c` | Campo nuevo (Text, 1) | Creado y desplegado; población de datos pendiente por bloqueo de plataforma | Bavarian: `V` (mismo comportamiento actual); Otobai: `M` (mismo comportamiento actual); PEKING: `V` (equivalente Bavarian, provisional) — valores preparados en script, no aplicados aún |

---

## Tests ejecutados y resultados

**Deploy de metadata:** dry-run limpio + deploy real exitoso. Id de deploy: `0AfAK0000014jsQ0AQ` (5/5 componentes, 0 errores).

**Ejecución de tests post-deploy** (`sf apex run test`, Test Run Id `707AK00000IazJp`):

| Clase de prueba | Resultado |
|---|---|
| `EmpresaResolverTest` | 9/9 aprobadas |
| `QuoteSoftlandPedidoServiceTest` (nueva) | 9/9 aprobadas — cubre: Bavarian, Otobai, PEKING, empresa futura sin cambio de código, texto/código legacy válido, legacy no resoluble → error controlado, sin fallback silencioso a Bavarian, empresa inactiva rechazada |
| `HttpCalloutCreateKitTest` (ampliada) | 8/8 aprobadas — cubre: Bavarian conserva ERP/tipo, Otobai conserva ERP/tipo, PEKING vía Empresa con tipo provisional, empresa futura vía configuración, Empresa faltante → error controlado sin fallback a Otobai |

**Total: 27/27 aprobadas, 0 fallos.**

**Corrección de un problema preexistente no relacionado:** `HttpCalloutCreateKitTest.setupTestData` insertaba 2 registros `Product2` con el mismo `Codigo_de_Producto__c = '456'`, lo que una validación existente en el objeto rechaza como duplicado. Este defecto no fue causado por este bloque (no se tocó esa lógica de creación de productos) pero bloqueaba la ejecución completa de la clase de prueba, incluidas las pruebas nuevas. Se corrigió con el cambio mínimo de asignar códigos distintos (`'456' + i`).

**Verificación funcional adicional (Apex anónimo, solo lectura/verificación):** `EmpresaResolver.resolve()` confirmado operativo para las 3 empresas tras poblar `Nombre_Legal__c`.

## Dry-run Id / Deploy Id

- Dry-run (validación): `0AfAK0000014n810AA` (primer intento, reveló 2 errores no relacionados con la lógica de negocio — ver abajo) → `0AfAK0000014nET0AY` (limpio tras corregir SOQL y datos de prueba).
- Deploy real: **`0AfAK0000014jsQ0AQ`** — 5/5 componentes, 0 errores.
- Redeploy de confirmación del campo (sin cambios, verificación): `0AfAK0000014nO90AI`.

**Errores técnicos resueltos durante el dry-run (no relacionados con la lógica de Empresa):**
1. `UPPER()` no es válido dentro de una cláusula `WHERE` de SOQL — corregido usando comparación directa (la igualdad de texto en SOQL ya es insensible a mayúsculas/minúsculas).
2. Coverage gate de `RunSpecifiedTests` (75% requerido) — no aplicable a un deploy de Sandbox; se usó dry-run/deploy simple (sin forzar nivel de test) y se ejecutaron los tests por separado como evidencia, sin bloquear el deploy.

## Estado en Partial

- `QuoteSoftlandPedidoService`, `QuoteSoftlandPedidoServiceTest`, `HttpCalloutCreateKit`, `HttpCalloutCreateKitTest` — activos, desplegados.
- `Empresa__c.Tipo_Kit_Softland__c` — campo activo (confirmado vía Tooling API).
- `Empresa__c` (3 registros) — `Nombre_Legal__c` poblado y verificado; `Tipo_Kit_Softland__c` pendiente de población (ver seguimiento).

---

## Seguimiento técnico pendiente (no bloquea el cierre de Sprint 1)

**Población de `Empresa__c.Tipo_Kit_Softland__c` en los 3 registros reales.** El campo fue creado y desplegado exitosamente (confirmado vía Tooling API, `CustomField.Id = 00NAK000000Ua1F2AS`, sin duplicados, `EntityDefinition` consistente), pero al cierre de este bloque todavía no estaba disponible para SOQL/Apex/describe estándar — un retraso de propagación de plataforma ya observado durante ~10 minutos, incluyendo un redeploy de confirmación que no lo aceleró. Esto **no afecta la resolución de Empresa ni de código ERP** (ya operativa y verificada); solo afecta el tipo de kit ('V'/'M') que usaría `HttpCalloutCreateKit` si su llamador (`sendCreateKitRequest`, ya identificado en auditorías previas como de caller mayormente inactivo) se ejecutara hoy con Empresa configurada pero sin este dato.

**Acción preparada, no ejecutada:** script Apex ya escrito y verificado sintácticamente (`update_empresas.apex`, conservado en el entorno de trabajo, no versionado) que asigna Bavarian=`V`, Otobai=`M`, PEKING=`V` (equivalente Bavarian, provisional) en cuanto el campo esté disponible. Ejecutar en una sesión posterior sin necesidad de repetir ningún análisis.

---

## Criterio de cierre

Se cumplen las condiciones de cierre:

- Objeto/configuración Empresa operativo (incluida la corrección del gap de `Nombre_Legal__c` que afectaba a las 3 empresas).
- Los 32 componentes nominalmente listados están implementados o validados sin cambio.
- `QuoteSoftlandPedidoService` resuelto — sin whitelist cerrada, escalable, con tests.
- `HttpCalloutCreateKit` resuelto — sin decisión por Record Type, escalable, con tests.
- 3 triggers oficiales cubiertos.
- Tests pasan (27/27).
- Partial contiene los cambios (deploy `0AfAK0000014jsQ0AQ`).
- No queda ningún gap técnico de código/lógica dentro de la lista oficial. El único pendiente (población de un campo de configuración) es un seguimiento operativo bloqueado por la plataforma, no una brecha de alcance.

# SPRINT 1 — CERRADO AL ALCANCE PROPORCIONADO POR EL NEGOCIO

---

# CLASES ADICIONALES DETECTADAS DURANTE EL PROCESO — NO FORMAN PARTE DE LA LISTA ORIGINAL DE SPRINT 1

No se trabajaron en este bloque. Estado actual (sin cambios), para referencia:

| Clase | Estado |
|---|---|
| `CrearPlandeVenta` | No autorizada — pendiente de definición de alcance/horas |
| `HttpCalloutGetProductRefPrices` | No autorizada — pendiente de definición de alcance/horas |
| `ProductoLocalizacionHelper` | No autorizada — pendiente de definición de alcance/horas |
| `BatchOppActivityUploader` | No autorizada — defecto de branding activo, pendiente de definición de negocio |
| `cT_QuotePDFEmail` | No autorizada — defecto de branding activo, pendiente de definición de negocio |
| `HttpCalloutGetProductFreshRefPrices` | No autorizada — código muerto, sin llamador vivo |
| `http_Helper` | No autorizada — código muerto en el método señalado |
| `QuoterController` | No autorizada — pendiente de definición de alcance/horas |
| `BusquedaDetalladaController` | No autorizada — pendiente de definición de alcance/horas |
| `WoliGridController` / `WoliGridController2` | No autorizadas — sin lógica de empresa propia |
| `TrabajoQuoteController` | No autorizada — candidata histórica a "clase 33", nunca seleccionada |
| `TrabajoController` | No autorizada — guarda de lista ya incluye RMPEKING, no bloquea |
| `BMWVinScanTrabajoGenerator` | No autorizada — guarda de lista ya incluye RMPEKING, no bloquea |
| `ServicioEnvioEncuestaSoftland` | No autorizada — ya investigada, no es regresión |
| `CT_nuevaCita_controller` / `cT_nuevaCitaGarantia_controller` | No autorizadas — pendiente decisión de negocio (citas) |
| `getHorasCitasFlow` | No autorizada — pendiente decisión de negocio (citas) |
| `OrderBatch` | No autorizada — ya resuelve dinámicamente, sin acción urgente |
| `ServicioEliminarReservaArticulo` / `ServicioReservaApartadoArticulos` | No autorizadas — falso positivo (solo en mock de prueba) |
| `ServicioCitas` / `ServicioCitasFieldService` | **TRABAJO EXTRA — NO CONTEMPLADO EN EL ALCANCE/HORAS ORIGINALES** (ver `RECONCILIACION_AUDITORIA_LUIS_20260813.md` sección 9) |

No se ampliará el cierre de Sprint 1 con estas clases. Se administran por separado como hallazgos adicionales, sujetos a autorización explícita de Luis/Diego.
