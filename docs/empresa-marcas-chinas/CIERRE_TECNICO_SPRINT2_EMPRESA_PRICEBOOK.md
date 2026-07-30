# Cierre técnico — Sprint 2 Empresa/Pricebook (PEKING), 2026-07-30

## Estado: BLOQUEADO (parcial)

Trabajo ejecutado de forma autónoma hasta un bloqueo arquitectónico genuino, previsto explícitamente por el mandato de esta tarea (Sección 1, regla de detención #1, y Sección 3). Se completó toda la investigación, reconciliación de drift, corrección de datos sin dependencias y documentación posibles sin invertir metadata ni datos legales. No se modificó ningún Flow, LWC ni clase Apex de lógica de negocio. No se tocó Producción.

## 1. Worktree, rama, HEAD

- Worktree base: `C:\Users\dokur\Documents\Repositorios\RedMotors-Sprint2-Flows-Components`, rama `feature/pc/redmotors-empresa-marcas-chinas-sprint2-flows-components-20260728`, HEAD `d7345ed` (coincide con el HEAD esperado, limpio salvo `force-app/main/default/lwc/jsconfig.json` modificado localmente sin commit, no tocado en esta tarea).
- Worktree aislado creado: `C:\Users\dokur\Documents\Repositorios\RedMotors-Sprint2-Cierre-Empresa-Pricebook`, rama nueva `feature/pc/redmotors-sprint2-cierre-empresa-pricebook-20260730`, creada desde `d7345ed`.
- Org: `RedMotorsSandbox` (`peseck89@gmail.com.partial.redmotors`, `https://redmotors--partial.sandbox.my.salesforce.com`), perfil `System Administrator`, confirmado antes de cualquier operación.

## 2. Drift local vs. Partial (componentes inspeccionados)

| Componente | Local | Partial (activo) | Drift | Decisión |
|---|---|---|---|---|
| `Opportunity_Flow`, `Opp_flow_v4`, `BMW_ImportarPlantilla` | Ya reconciliados contra Partial en la pasada 2026-07-29 (ver `EVIDENCIA_PRICEBOOK_FLOWS_PEKING_20260729.md`) | Sin cambios desde entonces | Ninguno nuevo | No se volvió a comparar; no se modificaron |
| `Empresa__c` (objeto + 4 campos) | 4 campos en Git desde commit `7f8b919` (2026-07-24): `Codigo__c`, `Codigo_ERP__c`, `Nombre_Legal__c`, `Activa__c` | Solo `Codigo__c` visible por SOQL/describe antes de esta pasada | **Sí — drift de permisos, no de metadata** (ver sección 4) | Reconciliado: se asignó el Permission Set `Empresa_Admin` ya existente en Git/Partial al usuario conectado. Los 4 campos ya eran queryables después. No se creó ni modificó metadata nueva. |
| `Pricebook2` (PEKING Local / PEKING Dólares) | N/A (Pricebook2 no tiene carpeta en Git) | `PEKING Local` = USD (incorrecto), `PEKING Dólares` = USD (correcto), ambos activos, 0 dependencias | Sí, ya conocido | Corregido: `PEKING Local` → CRC (ver sección 5) |
| `Pricebook2` (relación con `Empresa__c`) | No existe ningún campo/objeto | No existe ningún campo custom en `Pricebook2` | N/A — nunca existió | **Bloqueo arquitectónico** (ver sección 6) |
| `EmpresaResolver` / `EmpresaContext` (+ tests) | Deployados en el commit `7f8b919` | Confirmados deployados vía Tooling API (`SELECT Name FROM ApexClass`) | Ninguno | No modificados — ya implementan resolución de Empresa por Id/código; no tienen ningún concepto de Pricebook todavía |
| `CambiarPricebook` | — | — | — | Inspeccionado, sin dependencia de Empresa/Pricebook, candidato limpio de regresión, sin cambios |

## 3. Decisiones de Luis y Diego aplicadas

Recibidas en la conversación de trabajo activa (fuente rango 1, ver `SPRINT2_FUENTES_AUTORITATIVAS.md`):

- Empresa_Operadora__c (lookup ya existente en `Opportunity`/`Plantilla_de_Presupuesto__c` → `Empresa__c`) es la fuente principal de compañía.
- `Empresa.Codigo_ERP__c` es el código estable para integraciones; código de PEKING = `RMPEKING` (Diego confirma que usa la misma infraestructura Softland que Bavarian/Otobai).
- `BMW_Compania__c` solo como fallback temporal, comentado, cuando el lookup esté vacío.
- Pricebooks deben resolverse por Empresa + `CurrencyIsoCode` + `IsActive` (+ año/canal solo si el proceso ya los usa) — nunca por nombre ni Id hardcodeado.
- PEKING debe quedar activa en Partial.

Estas decisiones **sustituyen** la pregunta pendiente documentada el 2026-07-29 sobre qué valor darle a `BMW_Compania__c` para PEKING (`EVIDENCIA_PRICEBOOK_FLOWS_PEKING_20260729.md` §7) — ya no aplica, porque el mecanismo deja de depender de ese picklist restringido.

## 4. Reconciliación de drift de permisos (Empresa__c)

Al verificar la premisa técnica de la nueva decisión se encontró que `Empresa__c` en Partial solo exponía `Codigo__c` vía SOQL/describe; `Codigo_ERP__c`, `Nombre_Legal__c` y `Activa__c` devolvían `INVALID_FIELD: No such column`, pese a estar en Git desde el 2026-07-24 junto con `EmpresaResolver`/`EmpresaContext` (que ya los consultan). Antes de concluir que eran campos nunca deployados, se verificó vía Tooling API (`SELECT ... FROM CustomField WHERE Id = '00NAK000000PzbO2AS'`) que el campo **sí existe** en el org, con el mismo `label`/`length`/`TableEnumOrId` que el metadata de Git — descartando que fuera un campo faltante.

Causa raíz confirmada: el Permission Set `Empresa_Admin` (ya en Git y ya deployado en Partial, diseñado exactamente para dar Field-Level Security de esos 3 campos) no estaba asignado al usuario conectado, y Salesforce no otorga FLS automático a System Administrator para campos deployados vía Metadata API sin una entrada explícita de permisos — de ahí el error "No such column" en vez de un error de permisos.

**Acción tomada** (ajuste mínimo de permisos, autorizado sin consulta por el mandato de esta tarea): `sf org assign permset --name Empresa_Admin --target-org RedMotorsSandbox`. Verificado después: la consulta `SELECT Id, Codigo__c, Codigo_ERP__c, Nombre_Legal__c, Activa__c FROM Empresa__c` ya no da error (`totalSize: 0`, objeto vacío como estaba documentado). `Empresa__c` queda completamente funcional a nivel de esquema.

## 5. Corrección de Pricebooks PEKING

Verificadas dependencias antes de modificar (solo lectura, `PEKING Local` Id `01sAK0000006DVdYAM`): 0 `PricebookEntry`, 0 `Opportunity`, 0 `Quote`, 0 `Order` referenciándolo. Sin dependencias incompatibles. Se respaldó el estado previo de ambos Pricebooks (`Id`, `Name`, `IsActive`, `CurrencyIsoCode`, `CreatedDate`, `LastModifiedDate`) antes del cambio. Se actualizó `CurrencyIsoCode` de `PEKING Local` de `USD` a `CRC` mediante `sf data update record`. Verificado después:

| Pricebook | IsActive | CurrencyIsoCode (antes) | CurrencyIsoCode (después) |
|---|---|---|---|
| PEKING Local (`01sAK0000006DVdYAM`) | true | USD | **CRC** |
| PEKING Dólares (`01sAK0000006DXFYA2`) | true | USD | USD (sin cambio, ya correcto) |

No se crearon ni modificaron `PricebookEntry` — no había ninguno, y crear datos de producto/precio reales u oficiales no fue autorizado ni necesario para esta corrección puntual.

## 6. Bloqueo arquitectónico — relación Pricebook2 ↔ Empresa__c

### 6.1 Evidencia de que no existe ninguna relación válida

Búsqueda exhaustiva realizada antes de detener el bloque, tal como exige el mandato:

- **Metadata local:** `force-app/main/default/objects/` contiene exactamente 7 carpetas: `Empresa__c`, `Lead`, `Opportunity`, `Plantilla_de_Presupuesto__c`, `Product2`, `TipoDeCargoConManoDeObra__c`, `WorkOrder`. No existe carpeta `Pricebook2` (cero campos custom trackeados). No existe ningún objeto junction. No existe ningún `*__mdt` (Custom Metadata Type) en el repositorio.
- **Partial (Tooling API + describe, solo lectura):** `sf sobject describe --sobject Pricebook2` devuelve cero campos con `custom: true`. `Empresa__c` (después de la reconciliación de permisos) tiene exactamente 4 campos custom: `Codigo__c`, `Codigo_ERP__c`, `Nombre_Legal__c`, `Activa__c` — ninguno referencia `Pricebook2`.
- **Clases ya deployadas (`EmpresaResolver`, `EmpresaContext`):** resuelven `Empresa__c` por `Id` o por `Codigo__c`; no tienen ningún método, campo ni SOQL relacionado con `Pricebook2`.
- **Custom Settings / objetos de configuración:** no se encontró ningún `Empresa_Config__mdt` ni equivalente en Git ni en Partial.
- **Convención de nombres:** los Pricebooks existentes (`Bavarian Local`, `Bavarian Dólar`, `Otobai Local`, `Otobai Dólares`, `PEKING Local`, `PEKING Dólares`) codifican la Empresa únicamente en el `Name` — explícitamente prohibido como mecanismo de resolución para la lógica nueva (decisión de Luis #7 y #8).

**Conclusión: no existe ninguna relación ni configuración entre `Pricebook2` y `Empresa__c`, ni en Git ni en Partial.** Esto corresponde exactamente a la regla de detención #1 del mandato de esta tarea: decidir qué nuevo campo, junction o Custom Metadata crear es una decisión de arquitectura que no puede resolverse sin autorización explícita, porque implica elegir un nombre de API, un tipo de campo y (en el caso de un objeto nuevo) un modelo de datos que persistirá en el org.

### 6.2 Dos opciones técnicas

**Opción A — Lookup directo en `Pricebook2` hacia `Empresa__c` (recomendada).**

Agregar un campo `Empresa_Operadora__c` (Lookup a `Empresa__c`) directamente en `Pricebook2`, con el mismo nombre y patrón ya usado en `Opportunity.Empresa_Operadora__c` y `Plantilla_de_Presupuesto__c.Empresa_Operadora__c`. Cardinalidad natural (una Empresa tiene muchos Pricebooks; un Pricebook pertenece a una sola Empresa) — coincide exactamente con cómo Luis describe el filtro requerido ("Pricebooks activos de la Empresa de la Opportunity"). Es el cambio mínimo: un campo, sin objeto nuevo, sin duplicar el patrón de nomenclatura ya establecido. El resolver (`EmpresaPricebookResolver` o nombre equivalente, ver Sección 7) simplemente agrega `WHERE Empresa_Operadora__c = :empresaId AND CurrencyIsoCode = :currency AND IsActive = true` a la consulta de `Pricebook2`.

**Opción B — Objeto junction `Empresa_Pricebook__c`.**

Crear un objeto nuevo con dos relaciones: `Empresa__c` (Lookup) y una referencia a `Pricebook2`. Permite cardinalidad muchos-a-muchos, que ninguna decisión de Luis/Diego pide — todas las reglas dadas (`8`, `10`) asumen que cada Pricebook pertenece a una sola Empresa. Además, para referenciar `Pricebook2` desde un objeto junction custom se necesitaría o bien un Lookup nativo a `Pricebook2` (a validar si la plataforma lo permite en este org — no verificado en esta pasada) o bien almacenar el `Id` de `Pricebook2` como texto, lo cual violaría explícitamente la regla de Luis "no almacenar IDs específicos del org... en Custom Metadata". Añade un objeto, una relación más para mantener, y no resuelve ningún requisito que la Opción A no resuelva ya.

**Recomendación: Opción A.** Es el cambio de menor superficie, reutiliza el patrón de nomenclatura y relación ya validado y en producción (`Empresa_Operadora__c`), no introduce ambigüedad de cardinalidad, y no choca con la prohibición de IDs/nombres hardcodeados. Requiere: (1) crear el campo `Pricebook2.Empresa_Operadora__c` (Lookup, `Empresa__c`) en Git y deployarlo, (2) poblarlo para los 6 Pricebooks existentes una vez existan los registros de `Empresa__c` (ver Sección 7), (3) construir el resolver sobre ese campo.

**Esta decisión no fue tomada por este agente** — se detiene aquí porque crear un campo/objeto nuevo en el modelo de datos del org es exactamente la decisión que el mandato de esta tarea reserva para Luis/Diego (Sección 1, regla de detención #1).

## 7. Bloqueo de datos — Nombre_Legal__c (razón social)

Independiente del bloqueo de la Sección 6: aunque `Empresa__c` ya es funcional a nivel de esquema (Sección 4), no se crearon registros para Bavarian/Otobai/PEKING. `EmpresaContext` (ya deployado) exige `Nombre_Legal__c` no vacío en su constructor — lanza `EmpresaConfigurationException` si falta — es decir, aunque el campo no es `required` a nivel de metadata, la lógica de negocio ya escrita lo trata como obligatorio para que una Empresa cuente como "configurada". Ninguna fuente disponible (las decisiones de Luis/Diego de esta sesión, el documento original, el Manual) confirma la razón social de Bavarian, Otobai o PEKING. Es un dato legal — el mandato de esta tarea prohíbe explícitamente inventarlo (Sección 4). Los códigos (`Codigo__c`/`Codigo_ERP__c` = `RMBAVARIAN`/`RMOTOBAI`/`RMPEKING`) sí están confirmados y listos para usarse en cuanto se resuelva este punto.

## 8. Candidatos adicionales encontrados fuera de alcance (no modificados)

Búsqueda de solo lectura sobre todos los Flows del repositorio (fuera de los 5 + `CambiarPricebook` ya inventariados) encontró 12 Flows con dependencia directa y activa de `BMW_Compania__c` y/o `Pricebook2Id` hardcodeado, ninguno nombrado por Luis o Diego: `AgregarManoObra`, `BMW_Importar_Plantilla_Orden_de_Trabajo`, `CreateWoliFromExpense`, `Llena_Porcentaje_de_Usados`, `Opp_Flow_V5`, `Opp_Flow_v6`, `Opp_flow_V3`, `Opportunity_Flow_V2`, `Opportunity_Flow_From_Work_Order`, `Work_Order_from_Quote`, `Work_Order_from_Quote_Selective`, `FlowOppMostrador`. Por la regla de alcance del proyecto (`REGLAS_ALCANCE_AUTORIZADO.md`, regla 1: "el alcance autorizado prevalece sobre discovery"), quedan registrados como **candidatos fuera del alcance confirmado** — no se tocan, no cuentan como avance de Sprint 2, y requieren confirmación explícita por nombre antes de cualquier trabajo adicional. Detalle de cada dependencia en `REGLAS_ALCANCE_AUTORIZADO.md` y `EVIDENCIA_PRICEBOOK_FLOWS_PEKING_20260729.md` §10.5.

`CambiarPricebook` fue inspeccionado y confirmado como candidato limpio de regresión — no decide por Empresa/Pricebook, solo verifica si la Opportunity existe y ofrece un selector de año. No requiere cambios.

## 9. Qué NO se hizo y por qué

- No se modificó ningún Flow (`Opportunity_Flow`, `Opp_flow_v4`, `BMW_ImportarPlantilla`, `BMW_Gestiona_Listas_de_Precios`, `Obtener_PricebookEntry_en_Linea_de_Plantilla_de_Presupuesto`, `CambiarPricebook`) — todos dependen, directa o indirectamente, de la relación Pricebook2–Empresa__c bloqueada en la Sección 6, o siguen `PENDIENTE DE CONFIRMACIÓN` de alcance.
- No se creó ninguna clase Apex resolver de Pricebook (`EmpresaPricebookResolver` o equivalente) — no hay campo sobre el cual construirlo.
- No se modificó `rm_vu_inventario` ni `RM_VU_Inventario_Ctrl` — mismo bloqueo, más el hecho de que su cambio funcional exacto sigue sin extraerse (`REGLAS_ALCANCE_AUTORIZADO.md`, Fase 3).
- No se crearon registros de `Empresa__c` — bloqueado por `Nombre_Legal__c` (Sección 7).
- No se crearon productos ni `PricebookEntry` de prueba — no hay Pricebook-Empresa que probar todavía; hacerlo ahora sería configuración sin uso real.
- No se tocaron los 12 Flows adicionales encontrados (Sección 8) — fuera de alcance autorizado.
- No se tocó Producción en ningún momento.

## 10. Pregunta pendiente (una sola, dos opciones, con recomendación)

> Para conectar `Pricebook2` con `Empresa__c` (requisito de las decisiones de Luis sobre resolución dinámica de Pricebooks): ¿se autoriza crear el campo `Pricebook2.Empresa_Operadora__c` (Lookup a `Empresa__c`, Opción A de la Sección 6.2) — la recomendación técnica de este cierre — o se prefiere un objeto junction `Empresa_Pricebook__c` (Opción B)? Y, en paralelo: ¿cuál es la razón social (`Nombre_Legal__c`) de Bavarian, Otobai y PEKING que debe registrarse en `Empresa__c`?

## 11. Producción

No se ejecutó ninguna operación (lectura ni escritura) contra Producción en ningún momento de esta tarea. Todas las consultas y el único DML (corrección de moneda de `PEKING Local`) se ejecutaron exclusivamente contra `RedMotorsSandbox` (Partial).
