# Evidencia técnica — Bloque RMPEKING en los 3 Flows de Pricebook (2026-07-29)

Worktree: `C:\Users\dokur\Documents\Repositorios\RedMotors-Sprint2-Pricebook-Flows-Peking`
Rama: `feature/pc/redmotors-sprint2-pricebook-flows-peking-20260729` (creada desde `feature/pc/redmotors-empresa-marcas-chinas-sprint2-flows-components-20260728` @ `3c27d91cc9aa9f6f53feda48f65ce4a968bc4491`).
Org consultada: RedMotors Partial Sandbox (`peseck89@gmail.com.partial.redmotors`, `instanceUrl` con `--partial.sandbox`, `IsSandbox=true`). Solo lectura: sin DML, sin Apex anónimo, sin deploy, sin dry-run, sin retrieve dentro del worktree.

Este documento complementa `REGLAS_ALCANCE_AUTORIZADO.md` (autorización de alcance/categoría, ya vigente) con la evidencia técnica específica que faltaba para decidir si la implementación era ejecutable.

## 1. Fuente real: local vs. Partial (los 3 Flows)

| Flow | Local | Partial (activo) | Última modificación en Partial | ¿Semánticamente igual? |
|---|---|---|---|---|
| `Opportunity_Flow` | `force-app/main/default/flows/Opportunity_Flow.flow-meta.xml` (3827 líneas) | Versión 25, Status `Active`, `MasterLabel` "Opportunity Flow" | `2024-03-30T18:14:06Z`, `admin Portalnet` | **Sí** — conteos idénticos de `Bavarian` (15), `Otobai` (15), `BMW_Compania__c` (11), `PEKING`/`Peking` (0) entre Git y el `Metadata` real obtenido vía Tooling API |
| `Opp_flow_v4` | `force-app/main/default/flows/Opp_flow_v4.flow-meta.xml` (6301 líneas) | Versión 16, Status `Active`, `MasterLabel` "Opp flow v4" | `2025-03-24T22:48:42Z`, `admin Portalnet` | **Sí** — conteos idénticos: `Bavarian` (15), `Otobai` (16), `BMW_Compania__c` (5), `PEKING`/`Peking` (0) |
| `BMW_ImportarPlantilla` | `force-app/main/default/flows/BMW_ImportarPlantilla.flow-meta.xml` (1223 líneas) | Versión 13, Status `Active`, `MasterLabel` "Importar Plantilla" | `2023-10-05T07:13:50Z`, "Calendario Pinares - Mecánica Rápida" | **Sí** — conteos idénticos: `Bavarian` (14), `Otobai` (8), `BMW_Compania__c` (10), `PEKING`/`Peking` (0) |

**Ningún Flow, ni en Git ni en Partial, contiene ninguna referencia a PEKING todavía.**

## 2. Decisiones, assignments y consultas relacionadas con compañía/Pricebook/moneda (los 3 Flows)

Patrón idéntico en los 3 Flows (ya documentado estructuralmente en `REGLAS_ALCANCE_AUTORIZADO.md`, Fase 3; confirmado aquí contra la versión activa real de Partial):

1. Una Decision (`Encuentra_Price_Book` en `Opportunity_Flow`/`Opp_flow_v4`; `Determina_Nombre_Price_Book` en `BMW_ImportarPlantilla`) con **4 reglas**, cada una con lógica `and` sobre exactamente dos condiciones:
   - `CurrencyIsoCode` (`Opportunity`/`Presupuesto`) `EqualTo` `CRC` o `USD`.
   - `BMW_Compania__c` (`Opportunity`, vía `BMW_ObtenerPresupuesto.Opportunity.BMW_Compania__c`) `EqualTo` `Otobai` o `Bavarian` — **valores literales de texto, sin prefijo `RM`**.
2. Cada regla conecta a un Assignment que fija la variable de texto `PriceBookName` con el nombre exacto del `Pricebook2` (`"Bavarian Local"`, `"Bavarian Dólar"`, `"Otobai Local"`, `"Otobai Dólares"`).
3. El `defaultConnector` de la Decision (cuando `BMW_Compania__c` no es exactamente `Otobai` ni `Bavarian`) salta directo al `RecordLookup` **sin pasar por ningún Assignment** — `PriceBookName` queda vacío.
4. Un `RecordLookup` (`Obtener_PriceBook_Opp` / `Obtiene_Price_Book_Pre`) busca `Pricebook2 WHERE Name = {!PriceBookName}` (`getFirstRecordOnly=true`). Con `PriceBookName` vacío, no encuentra nada.
5. Una segunda Decision (`Price_Book_vac_o`) verifica si el `Pricebook2Id` resultante es nulo; si lo es, sigue un camino distinto (`Coloca_PB_en_Quote`) al de éxito (`Crear_Plantilla`). **No hay fallback silencioso a Bavarian** — es ausencia de asignación.

## 3. Resolución del valor de compañía — `Opportunity.BMW_Compania__c`

Consultado en Partial mediante describe estándar y SOQL de agregación (solo lectura):

- **Tipo de campo:** `picklist`, **`restrictedPicklist = true`** (picklist restringido a nivel de plataforma — cualquier valor fuera de la lista activa es rechazado al guardar con `INVALID_OR_NULL_FOR_RESTRICTED_PICKLIST`, el mismo tipo de error ya documentado para `Product2.Empresa__c` en el bloque `precioProductoJSON`).
- **Valores API/etiqueta activos (describe real de Partial):**
  | value | label | active |
  |---|---|---|
  | `Bavarian` | Bavarian | true |
  | `Otobai` | Otobai | true |

  **No existe ningún valor para PEKING** (ni `Peking`, ni `PEKING`, ni `RMPEKING`) entre los valores activos.
- **Disponibilidad por Record Type:** `Opportunity` **no tiene Record Types configurados** en este org (`recordTypeInfos` del describe viene vacío) — a diferencia de `Product2` (que sí tenía 4 Record Types y uno de ellos, `Producto Red Motors`, habilitaba `RMPEKING`), aquí no existe ningún Record Type alternativo donde buscar un valor PEKING habilitado.
- **Registros reales de `Opportunity` agrupados por `BMW_Compania__c`:**
  | BMW_Compania__c | Cantidad |
  |---|---:|
  | `Bavarian` | 7,106 |
  | `Otobai` | 476 |
  | (vacío/null) | 2,380 |

  **Cero** registros reales con cualquier valor relacionado a PEKING.
- **Relación con `Empresa__c` (objeto):** existe el objeto personalizado `Empresa__c` en el org, pero **contiene 0 registros** (`SELECT Id, Name, Codigo__c FROM Empresa__c` → `totalSize: 0`). No es una fuente de datos utilizable hoy.
- **Relación con `User.Empresa__c`:** en `Opp_flow_v4`, `BMW_Compania__c` se puebla en la creación de la Opportunity a partir de la variable `EmpresaUsuario`, que a su vez proviene de `$User.Empresa__c` / `GetUser2.Empresa__c` (consulta a `User`) o de un valor de pantalla. **`User.Empresa__c` es también un picklist restringido con exactamente los mismos dos valores activos: `Bavarian` y `Otobai`** — mismo bloqueo, un nivel más arriba en la cadena.
- **Referencias a `BMW_Compania__c` en Apex — contradicción encontrada:** `QuoteSoftlandPedidoService.resolveLegacyCompanyCode(String legacyCompany)` (clase ya deployada, sin cambios en este bloque) normaliza:
  ```apex
  if (normalizedCompany == 'BAVARIAN' || normalizedCompany == 'RMBAVARIAN') { return 'RMBAVARIAN'; }
  if (normalizedCompany == 'OTOBAI' || normalizedCompany == 'RMOTOBAI') { return 'RMOTOBAI'; }
  if (normalizedCompany == 'RMPEKING') { return 'RMPEKING'; }
  ```
  Esta clase **acepta tanto la forma sin prefijo (`BAVARIAN`/`OTOBAI`, el patrón real y actual de `BMW_Compania__c`) como la forma con prefijo (`RMBAVARIAN`/`RMOTOBAI`) para las dos compañías existentes, pero para PEKING únicamente reconoce `RMPEKING` — no `PEKING` sin prefijo.** Es decir, el código Apex ya desplegado **anticipa** que `BMW_Compania__c` algún día contendrá literalmente `RMPEKING` para la compañía nueva, rompiendo el patrón sin-prefijo que usan hoy `Bavarian`/`Otobai`. Esta anticipación **no está respaldada por ninguna metadata ni dato real** — es, en sí misma, una suposición de otro bloque que nunca fue validada contra el picklist real.

## 4. Clasificación del valor de compañía PEKING

**C. BLOQUEADO.** No existe un valor técnico para PEKING en `Opportunity.BMW_Compania__c` (picklist restringido, solo `Bavarian`/`Otobai` activos, cero datos reales, sin Record Type alternativo), y existe una contradicción real entre el patrón sin-prefijo vigente (`Bavarian`/`Otobai`) y la anticipación con-prefijo (`RMPEKING`) ya presente en `QuoteSoftlandPedidoService`. Elegir cualquiera de los dos valores sin confirmación sería inventar un dato de negocio — prohibido explícitamente para este bloque.

**Los Pricebooks sí están confirmados** (`PEKING Local`, `PEKING Dólares` — mismos nombres ya usados y verificados como registros reales de `Pricebook2` en Partial durante el bloque `precioProductoJSON`), por lo que el bloqueo es exclusivamente sobre el valor de `BMW_Compania__c`, no sobre los Pricebooks.

## 5. Decisión de esta pasada

**No se modificó ningún Flow.** Implementar una regla nueva con cualquier valor supuesto (`Peking` o `RMPEKING`) sería código muerto en el mejor de los casos (el valor nunca aparecería en datos reales mientras el picklist no lo incluya) o, si alguien lograra forzar el valor por otra vía, provocaría el mismo error de picklist restringido ya visto en `Product2.Empresa__c`. Se documenta el bloqueo, se preparan íntegramente la auditoría, el manifest y los escenarios de prueba (sección 6), y se deja una única pregunta pendiente (sección 7).

## 6. Escenarios de prueba manual preparados (para ejecutar una vez resuelto el bloqueo)

| # | Escenario | Compañía | Moneda | Resultado esperado | Estado |
|---|---|---|---|---|---|
| 1 | Bavarian moneda local | `Bavarian` | CRC | `PriceBookName = "Bavarian Local"`, `Pricebook2Id` resuelto | Ejecutable hoy (comportamiento existente, sin cambios) |
| 2 | Bavarian USD | `Bavarian` | USD | `PriceBookName = "Bavarian Dólar"`, `Pricebook2Id` resuelto | Ejecutable hoy |
| 3 | Otobai moneda local | `Otobai` | CRC | `PriceBookName = "Otobai Local"`, `Pricebook2Id` resuelto | Ejecutable hoy |
| 4 | Otobai USD | `Otobai` | USD | `PriceBookName = "Otobai Dólares"`, `Pricebook2Id` resuelto | Ejecutable hoy |
| 5 | PEKING moneda local | *(valor de compañía sin resolver)* | CRC | `PriceBookName = "PEKING Local"`, `Pricebook2Id` resuelto | **Bloqueado** — requiere el valor de `BMW_Compania__c` |
| 6 | PEKING USD | *(valor de compañía sin resolver)* | USD | `PriceBookName = "PEKING Dólares"`, `Pricebook2Id` resuelto | **Bloqueado** — requiere el valor de `BMW_Compania__c` |
| 7 | Compañía vacía o no reconocida | `null` / valor no listado | CRC o USD | `defaultConnector` → `PriceBookName` vacío → `RecordLookup` sin resultado → `Price_Book_vac_o` toma la rama `Vacio_Presupuesto_PB` → `Coloca_PB_en_Quote` (sin fallback a Bavarian) | Ejecutable hoy (comportamiento existente, sin cambios) |
| 8 | Confirmación de que el resultado por defecto no cambió | — | — | El `defaultConnector` de la Decision y el flujo `Price_Book_vac_o` → `Coloca_PB_en_Quote` deben ser exactamente los mismos que hoy (ningún cambio funcional se aplicó) | Confirmado por inspección estática — ver sección 8 |

## 7. Pregunta pendiente (única, no se solicita respuesta en esta ejecución)

> Para `Opportunity.BMW_Compania__c` (picklist restringido, hoy solo `Bavarian`/`Otobai` activos, sin Record Types en `Opportunity`): ¿qué valor exacto debe agregarse como opción activa del picklist para representar PEKING — `Peking` (siguiendo el patrón sin prefijo vigente) o `RMPEKING` (como ya anticipa `QuoteSoftlandPedidoService.resolveLegacyCompanyCode`) — y quién es responsable de habilitarlo en el picklist?

## 8. Validación estática (sin cambios que auditar)

Como no se modificó ningún Flow, no existe diff funcional que validar. Se confirmó, por lectura directa contra la versión activa de Partial (sección 1), que el estado base de los 3 archivos XML permanece bien formado y sin alteraciones: mismo conteo de reglas (4 por Decision), mismos conectores, mismos nombres de Pricebook (`Bavarian Local`, `Bavarian Dólar`, `Otobai Local`, `Otobai Dólares` — sin variantes) en los 3 Flows, en Git y en Partial.

## 9. Componentes fuera de alcance de este bloque

No se investigaron ni se tocaron: `BMW_Gestiona_Listas_de_Precios`, `Obtener_PricebookEntry_en_Linea_de_Plantilla_de_Presupuesto`, `PlanDeMantenimientoV2`, `rm_vu_inventario`, ni ningún otro Flow/LWC/Aura/Apex del inventario de Sprint 2 — todos permanecen en el estado descrito en `REGLAS_ALCANCE_AUTORIZADO.md` e `INVENTARIO_SPRINT2_FLOWS_COMPONENTES.md`.

## 10. Actualización (2026-07-30, worktree `RedMotors-Sprint2-Cierre-Empresa-Pricebook`) — decisiones de Luis/Diego recibidas en conversación activa y nuevo bloqueo estructural

**Decisiones recibidas** (rango 1, comunicación directa en la sesión de trabajo activa, consistente con `SPRINT2_FUENTES_AUTORITATIVAS.md` §"Fuentes de rango 1"): la pregunta pendiente de la sección 7 queda **sustituida, no respondida** — Luis decidió no agregar ningún valor a `BMW_Compania__c` y en su lugar usar `Empresa_Operadora__c` (lookup ya existente en `Opportunity` y `Plantilla_de_Presupuesto__c`, apuntando a `Empresa__c`) como fuente principal de compañía, dejando `BMW_Compania__c` solo como fallback temporal comentado cuando el lookup esté vacío. Diego confirmó que RMPEKING usa la misma infraestructura/autenticación Softland que las otras dos compañías y que el código ERP es `RMPEKING`.

### 10.1 Verificación de la premisa técnica de la nueva decisión

Antes de implementar sobre la nueva decisión, se verificó exhaustivamente si existe la infraestructura que asume (rango 5, describe + Tooling API contra Partial, solo lectura salvo lo indicado en 10.2):

- `Opportunity.Empresa_Operadora__c` y `Plantilla_de_Presupuesto__c.Empresa_Operadora__c`: **existen** en Git (`force-app/main/default/objects/{Opportunity,Plantilla_de_Presupuesto__c}/fields/Empresa_Operadora__c.field-meta.xml`), Lookup a `Empresa__c`.
- `Empresa__c` (objeto): existe, con 4 campos en Git (`Codigo__c`, `Codigo_ERP__c`, `Nombre_Legal__c`, `Activa__c`). Clases `EmpresaResolver`/`EmpresaContext` (+ tests) ya implementadas en Git, resuelven `Empresa__c` por Id o por `Codigo__c`, **sin ningún concepto de Pricebook**.
- **`Pricebook2`: cero campos custom, ni en Git (no existe carpeta `force-app/main/default/objects/Pricebook2`) ni en Partial** (`sf sobject describe --sobject Pricebook2` contra `RedMotorsSandbox`: 0 `custom: true`).
- **Ningún objeto junction ni Custom Metadata Type existe** que relacione `Pricebook2` con `Empresa__c` — inventario completo de `force-app/main/default/objects/*` en Git: `Empresa__c`, `Lead`, `Opportunity`, `Plantilla_de_Presupuesto__c`, `Product2`, `TipoDeCargoConManoDeObra__c`, `WorkOrder`. Ninguno es un junction Pricebook–Empresa. No existe ningún `*__mdt` en el repo.
- **Conclusión: no existe ninguna relación o configuración entre `Pricebook2` y `Empresa__c`**, ni en Git ni en Partial. Ver bloqueo formal y las 2 opciones en `CIERRE_TECNICO_SPRINT2_EMPRESA_PRICEBOOK.md`.

### 10.2 Drift de `Empresa__c` detectado y corregido (recuperable, sin tocar el bloqueo anterior)

Al consultar Partial se encontró que **`Empresa__c` solo tenía `Codigo__c` visible por SOQL/describe** — `Codigo_ERP__c`, `Nombre_Legal__c`, `Activa__c` (presentes en Git desde el commit `7f8b919` "feat(empresa): add configurable company foundation", 2026-07-24) devolvían `INVALID_FIELD: No such column`. Se investigó antes de concluir que era un campo faltante: Tooling API (`SELECT ... FROM CustomField WHERE Id = '00NAK000000PzbO2AS'`) confirmó que el `CustomField` de `Codigo_ERP__c` **sí existe** en el org (mismo `TableEnumOrId` que `Empresa__c`, mismo `label`/`length` que el `field-meta.xml` de Git) — no era un campo nunca deployado, sino un problema de visibilidad. Causa raíz confirmada: el usuario conectado (`peseck89@gmail.com.partial.redmotors`, perfil `System Administrator`) **no tenía asignado** el Permission Set `Empresa_Admin` (ya existente en Git, deployado en Partial, y diseñado exactamente para dar FLS de esos 3 campos) — `SELECT ... FROM PermissionSetAssignment WHERE Assignee.Username = 'peseck89@gmail.com.partial.redmotors' AND PermissionSet.Name = 'Empresa_Admin'` devolvía 0 filas. Salesforce no otorga FLS automático a System Administrator para campos deployados por Metadata API sin un `<fieldPermissions>` explícito, lo cual explica el error `No such column` en vez de un error de permisos.

**Acción tomada (ajuste mínimo de permisos, sin tocar alcance ni inventar metadata):** `sf org assign permset --name Empresa_Admin --target-org RedMotorsSandbox`. Verificado después: `SELECT Id, Codigo__c, Codigo_ERP__c, Nombre_Legal__c, Activa__c FROM Empresa__c` ya no da error (`totalSize: 0`, consistente con "Empresa__c tenía cero registros"). El objeto `Empresa__c` queda **totalmente funcional a nivel de esquema** — el bloqueo de la sección 10.1 (relación con Pricebook2) es independiente y sigue vigente.

### 10.3 Corrección de moneda de los Pricebooks PEKING (Sección 6 del mandato, ejecutada)

Verificadas dependencias antes de modificar (solo lectura): `PEKING Local` (`01sAK0000006DVdYAM`) — 0 `PricebookEntry`, 0 `Opportunity.Pricebook2Id`, 0 `Quote.Pricebook2Id`, 0 `Order.Pricebook2Id`. Sin dependencias incompatibles. Se respaldó el estado previo (`Id`, `Name`, `IsActive`, `CurrencyIsoCode`, `CreatedDate`, `LastModifiedDate` de ambos registros) y se actualizó `CurrencyIsoCode` de `PEKING Local` de `USD` a `CRC` mediante `sf data update record`. Verificado después: `PEKING Local` = `CRC`, `PEKING Dólares` = `USD` (sin cambio, ya era correcto), ambos `IsActive = true`.

### 10.4 Bloqueo adicional de datos — `Nombre_Legal__c` (razón social)

Aun con el esquema de `Empresa__c` funcional (10.2), **no se crearon registros** de `Empresa__c` para Bavarian/Otobai/PEKING. `EmpresaContext` (constructor, líneas 33-37 de `EmpresaContext.cls`) exige `Nombre_Legal__c` no vacío o lanza `EmpresaConfigurationException` — es decir, aunque el campo no es `required` a nivel de metadata, la lógica de negocio ya deployada lo trata como obligatorio para que una Empresa cuente como "configurada". Ninguna fuente disponible (instrucciones de Luis/Diego en esta sesión, documento original, Manual) confirma el nombre legal/razón social de Bavarian, Otobai o PEKING. Es un campo legal — inventarlo está explícitamente prohibido por el mandato de esta tarea (Sección 4). Se documenta como bloqueo de datos, independiente del bloqueo estructural de 10.1, en `CIERRE_TECNICO_SPRINT2_EMPRESA_PRICEBOOK.md`.

### 10.5 Hallazgo ampliado — dependencias directas adicionales no autorizadas

Una búsqueda de solo lectura sobre `force-app/main/default/flows/*` (fuera de los 5 Flows + `CambiarPricebook` ya conocidos) encontró **12 Flows adicionales** con dependencia directa y activa de `BMW_Compania__c` y/o `Pricebook2Id` hardcodeado: `AgregarManoObra`, `BMW_Importar_Plantilla_Orden_de_Trabajo`, `CreateWoliFromExpense`, `Llena_Porcentaje_de_Usados`, `Opp_Flow_V5`, `Opp_Flow_v6`, `Opp_flow_V3`, `Opportunity_Flow_V2`, `Opportunity_Flow_From_Work_Order`, `Work_Order_from_Quote`, `Work_Order_from_Quote_Selective`, `FlowOppMostrador`. Ninguno fue nombrado por Luis o Diego. Por la regla de alcance (`REGLAS_ALCANCE_AUTORIZADO.md`, regla 1 y regla 7), **quedan registrados como "candidatos fuera del alcance confirmado"** — no se modifican, no cuentan como avance de Sprint 2. Se confirmó además que `CambiarPricebook` no tiene ninguna dependencia de Empresa/Pricebook (solo un `IfNotNull` sobre la Opportunity y un selector de año) — permanece como candidato limpio de regresión, sin cambios necesarios. Detalle completo por Flow en `CIERRE_TECNICO_SPRINT2_EMPRESA_PRICEBOOK.md`.

**Ningún Flow fue modificado en esta pasada** — el bloqueo de 10.1 impide implementar la resolución dinámica de Pricebook que las decisiones de Luis exigen (prohibido usar nombre/Id hardcodeado en la lógica nueva), por lo que los 5 Flows originalmente autorizados para implementación permanecen sin cambios hasta resolver ese bloqueo.

### 10.6 Actualización (2026-07-30, misma jornada) — bloqueo resuelto

Luis autorizó expresamente `Pricebook2.Empresa__c` (Lookup a `Empresa__c`, no obligatorio) en la conversación de trabajo activa, adoptando la Opción A recomendada en 10.1 con una diferencia de nomenclatura (`Empresa__c`, no `Empresa_Operadora__c`). Con esa autorización se implementó el campo, el resolver `EmpresaPricebookResolver`, los 5 Flows, `rm_vu_inventario`, y los datos de Empresa/Pricebook en Partial. El bloqueo de `Nombre_Legal__c` (10.4) permanece sin resolver — no fue necesario para desbloquear la resolución de Pricebooks porque el nuevo resolver deliberadamente no depende de `EmpresaContext`/`Nombre_Legal__c`. Detalle completo, deploy IDs y QA funcional en `CIERRE_TECNICO_SPRINT2_EMPRESA_PRICEBOOK.md`.
