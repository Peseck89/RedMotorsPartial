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
