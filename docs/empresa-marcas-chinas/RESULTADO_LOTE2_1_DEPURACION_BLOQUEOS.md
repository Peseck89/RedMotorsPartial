# Resultado Lote 2.1 — depuración de bloqueos de Flows

## Resultado ejecutivo

La revisión documental y técnica de los doce Flows separó tres recursos **ejecutables técnicamente** de nueve que todavía requieren una decisión externa. La vigencia productiva de los doce está resuelta con evidencia; no debe volver a preguntarse. Tampoco deben reabrirse la arquitectura de Empresa/Pricebook ni la exclusión de usados.

Primer sublote recomendado: `PlanDeMantenimientoV2`, `CreateWoliFromExpense` y `AgregarManoObra`. Su refactor puede usar `EmpresaPricebookResolver` y detenerse ante configuración ausente, sin inventar catálogo, productos o precios. El cierre funcional positivo seguirá pendiente de negocio.

## Evidencia utilizada

- Documento original de alcance, especialmente páginas 1, 4–6 y 9–10.
- Matriz de cierre y lotes vigentes.
- Remediación documentada de Luis del 31 de julio: hallazgos de Pricebook, versiones, UX y datos pendientes.
- Definiciones posteriores de Luis: solo Flows activos; usados fuera de PEKING.
- Lotes 0–1: equivalencia Git–Partial y contrato común de resolución ya desplegado.
- Consulta previa de solo lectura en Partial sobre versiones activas/latest.
- Inspección local de los doce XML, sin modificarlos.

## Depuración Flow por Flow

| Flow | Bloqueo exacto anterior | Evidencia/resolución | Cambio técnico requerido | ¿Sin otra decisión? | Clasificación actual | Pregunta pendiente y responsable | Sublote |
|---|---|---|---|---|---|---|---|
| `PlanDeMantenimientoV2` | Pricebook y catálogo PEKING | La vigencia v23 y el resolver están confirmados. El XML conserva un `Pricebook2Id` literal. | Derivar Empresa del registro, resolver Pricebook, validar PBE y detener estados no exitosos. | Sí para refactor y pruebas negativas; no para QA positivo. | `EJECUTABLE_TÉCNICAMENTE` | Negocio: catálogo/precios PEKING para prueba positiva, sin bloquear el refactor. | 2A |
| `CreateWoliFromExpense` | Mapeo de gastos/productos/Pricebooks | El XML usa decisión `BavarianOrOtobai` y cuatro búsquedas nominales. La API común ya existe. | Resolver Empresa desde WorkOrder, Pricebook y PBE; eliminar default binario; detener sin PBE. | Sí para refactor y negativos. | `EJECUTABLE_TÉCNICAMENTE` | Negocio: productos/precios de gastos para QA positivo. | 2A |
| `AgregarManoObra` | Catálogo/precios de mano de obra | El XML contiene cuatro IDs de Pricebook. No se requiere conocer precios para retirar IDs y controlar ausencia. | Resolver Empresa/Pricebook del WorkOrder, buscar PBE compatible y detener resultados no exitosos. | Sí para refactor y negativos. | `EJECUTABLE_TÉCNICAMENTE` | Negocio: catálogo y precios de MO para QA positivo. | 2A |
| `Work_Order_from_Quote_Selective` | Bodega, territorio y despacho PEKING | Vigencia v7 resuelta; el default Otobai→Bavarian y campos operativos siguen presentes. | Lookup Empresa principal, fallback acotado, eliminar default binario y conservar Pricebook de Quote solo si es compatible. | No: la ruta crea WO/WOLI con bodega/territorio. | `REQUIERE_NEGOCIO` | Negocio: reglas oficiales de bodega, territorio, reserva y despacho PEKING. | 2B |
| `Work_Order_from_Quote` | Operación PEKING | Vigencia v9 resuelta; comparte el patrón y dependencias del selectivo. | Mismo contrato empresarial y guardas; conservar rutas B/O. | No. | `REQUIERE_NEGOCIO` | Negocio: misma definición operativa Quote→WO para PEKING. | 2B |
| `SegregateWOLIs` | Garantía/segregación y Record Type Id | Vigencia v51 resuelta; XML confirma `Garant_a_Otobai__c` e Id literal. | Resolver Record Type sin Id fijo y definir política por Empresa. | No. | `REQUIERE_NEGOCIO` | Negocio: política PEKING de garantía/segregación. Diego: mecanismo de Record Type por DeveloperName/configuración. | 2C |
| `Opp_Flow_V5` | Vigencia y versión | La vigencia está resuelta: v29 activa; v30 Draft. El bloqueo de “si sigue vigente” queda eliminado. Falta base editable y UX. | Migrar la versión autorizada al lookup Empresa/resolver y retirar Pricebooks nominales. | No. | `REQUIERE_DIEGO` | Diego: confirmar si la base de cambio será v29 activa o v30 Draft y cómo preservar diferencias. Luis: UX de selección empresarial si la versión elegida usa choices legacy. | 2D2 |
| `Opp_flow_V3` | Vigencia frente a v4/v6 | Resuelto: v28 está activa y Luis indicó trabajar activos con impacto. La evidencia de Luis confirma choices B/O y creación sin lookup. | Reemplazar selección legacy por lookup Empresa/resolver y guardar `Empresa_Operadora__c`. | No: falta decisión UX. | `REQUIERE_LUIS` | Luis: usar selector de Empresa o derivación contextual; no agregar PEKING al picklist legacy. | 2D1 |
| `Opp_Flow_v6` | Autoridad v79/v80 | Vigencia resuelta; v79 activa y v80 Draft. La divergencia sí requiere decisión técnica de base. | Migrar versión autorizada y guardar lookup Empresa; resolver Pricebook dinámico. | No. | `REQUIERE_DIEGO` | Diego: base v79 o v80 y conciliación de cambios; Luis: UX de Empresa. | 2D2 |
| `Opportunity_Flow_V2` | Vigencia y regla usuario↔Empresa | Vigencia v6 resuelta. Luis documentó que copia usuario/choices y carece de infraestructura Empresa. | Portar lookup/resolver, guardar Empresa y evitar que usuario sobreescriba selección. | No. | `REQUIERE_LUIS` | Luis: fuente UX de Empresa y precedencia entre Empresa elegida y Empresa del usuario. | 2D1 |
| `aperturaCaseWorOrderEvent` | Agenda/sucursal/Pricebook y creación de Opportunity | Vigencia v20 resuelta. Luis confirmó creación sin `Empresa_Operadora__c` y decisión UX pendiente. | Resolver Empresa/Pricebook, guardar lookup y eliminar rutas default; luego configurar evento. | No. | `REQUIERE_LUIS` | Luis: UX/fuente de Empresa. Negocio: agenda, servicio y sucursal PEKING. | 2E |
| `ct_newCaseWorkOrderEvent` | Servicio/evento PEKING | Vigencia v54 resuelta; XML conserva evento/territorio y códigos empresariales B/O. | Lookup Empresa principal, fallback temporal y rutas controladas por configuración. | No. | `REQUIERE_NEGOCIO` | Negocio: servicios, agenda y territorios aplicables a PEKING. | 2E |

## Bloqueos resueltos con evidencia

1. **Vigencia:** los doce Flows tienen versión activa confirmada. No se pregunta si deben revisarse por estar activos.
2. **Arquitectura:** Empresa lookup primero; fallback legacy solo Bavarian/Otobai; resolver común disponible.
3. **Fuente Git–Partial:** los Flow XML fueron conciliados semánticamente en Lote 0; no existe deriva para latest recuperado.
4. **Usados:** no aplica a este lote y no debe reabrirse.
5. **Bundles faltantes/conflictos generales:** resueltos o acotados en Lote 0.1; no bloquean el sublote 2A.

## Sublotes propuestos

### 2A — Pricebook/PBE con guardas seguras

`PlanDeMantenimientoV2`, `CreateWoliFromExpense`, `AgregarManoObra`.

Puede ejecutarse primero. Implementación sin datos inventados; pruebas negativas completas y positivas B/O con datos existentes. PEKING positivo queda pendiente de catálogo/PBE oficial.

### 2B — Quote→Work Order

`Work_Order_from_Quote`, `Work_Order_from_Quote_Selective`.

Requiere N2: bodega, territorio y operación de despacho/taller.

### 2C — Segregación y garantía

`SegregateWOLIs`.

Requiere política de negocio y mecanismo técnico de Record Type confirmado por Diego.

### 2D1 — Opportunity sin divergencia de versión

`Opp_flow_V3`, `Opportunity_Flow_V2`.

Requiere decisión de Luis sobre selección/precedencia de Empresa.

### 2D2 — Opportunity con active/latest distintos

`Opp_Flow_V5`, `Opp_Flow_v6`.

Requiere primero decisión de Diego sobre versión base y luego decisión UX de Luis cuando aplique.

### 2E — Caso, Work Order y evento

`aperturaCaseWorOrderEvent`, `ct_newCaseWorkOrderEvent`.

Requiere UX para el primero y configuración operativa de negocio para ambos.

## Conclusión

El sublote **2A** es el único recomendado para implementación inmediata mediante una autorización separada. Esta depuración no autoriza cambios de Flow ni resuelve los datos comerciales necesarios para evidencia positiva PEKING.

No se consultó Producción, no se modificó metadata ni datos y no se hizo deploy.
