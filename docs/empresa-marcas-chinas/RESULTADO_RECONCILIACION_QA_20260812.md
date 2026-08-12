# Resultado — reconciliación autoritativa y QA de Flows modificados (Sprint 2)

**Fecha:** 12 de agosto de 2026
**Org:** `RedMotorsSandbox` (Partial)
**Rama:** `feature/pc/redmotors-empresa-marcas-chinas-sprint2-flows-components-20260728`
**Commits base:** `5d34f4c`, `634c143` (ambos confirmados presentes; rama pusheada a origin sin conflicto — ver Fase 0)

Bloque de solo reconciliación, QA y clasificación. **No se modificó ningún Flow ni componente en este bloque** — solo documentación. Sprint 2 sigue sin declararse cerrado.

## Fase 0 — Preservación de avance

| Campo | Valor |
|---|---|
| Remoto | `origin` → `https://github.com/Peseck89/RedMotorsPartial.git` |
| Rama | `feature/pc/redmotors-empresa-marcas-chinas-sprint2-flows-components-20260728` |
| Commits confirmados presentes | `5d34f4c`, `634c143` (HEAD) |
| Resultado del push | Exitoso: `b3a9592..634c143` |
| Ahead/behind posterior | `0 ahead / 0 behind` (rama sincronizada con origin) |

## Fase 1 — Reconciliación de los "20 Flows"

**Fuente autoritativa usada (orden 1-4 del mandato):** `docs/empresa-marcas-chinas/MATRIZ_CIERRE_SPRINT2.csv`, filas `F01`-`F20` — es la matriz formal de cierre de Sprint 2, con 20 Flows exactos (no 21). Cruzada contra metadata actual de `RedMotorsSandbox` (Tooling API) y contra `RESULTADO_LOTE2A_FLOWS_TECNICOS.md` / `RESULTADO_LOTE2D1_FLOWS_OPPORTUNITY.md` / `RESULTADO_LOTE2D2_FLOWS_OPPORTUNITY.md` / `RESULTADO_BLOQUE_N2N3N4_PEKING_20260812.md`.

**Origen exacto de la inconsistencia "21":** la clasificación previa citada en el mandato ("8 modificados/falta QA") contaba 8 donde en realidad son 7 (`PlanDeMantenimientoV2`, `CreateWoliFromExpense`, `AgregarManoObra`, `Opp_flow_V3`, `Opportunity_Flow_V2`, `Opp_Flow_V5`, `Opp_Flow_v6` — ya corregido en `RESULTADO_BLOQUE_N2N3N4_PEKING_20260812.md`). Con 7 (no 8) modificados + 5 bloqueados + 6 sin cambio + 2 no aplican = **20**, exactamente igual a `F01`-`F20` de la matriz formal. No existe un Flow 21; no se amplía el alcance.

### Matriz final — 20 Flows, sin doble conteo

| Flow | Versión Sandbox | Estado previo | Cambios realizados | QA | Estado actual | Bloqueo | Evidencia |
|---|---|---|---|---|---|---|---|
| `Opportunity_Flow` | v25 activa | Autorizado, sin cambio técnico | Ninguno — no usa nombre/Id fijo de Pricebook, no asigna Bavarian por else | No aplica | **Revisado — sin cambio** | Ninguno | `MATRIZ_CIERRE_SPRINT2.csv` F01 |
| `Opp_flow_v4` | v16 activa | Autorizado, sin cambio técnico | Ninguno | No aplica | **Revisado — sin cambio** | Ninguno | F02 |
| `BMW_ImportarPlantilla` | v13 activa | Autorizado, sin cambio técnico | Ninguno | No aplica | **Revisado — sin cambio** | Ninguno | F03 |
| `BMW_Gestiona_Listas_de_Precios` | v2 activa | Migrado (bloque Empresa/Pricebook, 2026-07-30) | Resolución dinámica vía `EmpresaPricebookResolver` | QA funcional con datos reales de Partial (ver `CIERRE_TECNICO_SPRINT2_EMPRESA_PRICEBOOK.md` §10) | **QA OK / técnicamente cerrado** | Ninguno | F04 |
| `Obtener_PricebookEntry_en_Linea_de_Plantilla_de_Presupuesto` | v1 activa | Migrado (mismo bloque) | Resolución dinámica por `$Record.CurrencyIsoCode` | Cubierto por pruebas del resolver | **QA OK / técnicamente cerrado** | Ninguno | F05 |
| `Opportunity_Flow_From_Work_Order` | — | Sin cambio técnico | Ninguno | No aplica | **Revisado — sin cambio** | Ninguno | F06 |
| `PlanDeMantenimientoV2` | v24 activa | Modificado (Lote 2A, 2026-08-04) | `EmpresaPricebookResolver` + guardas | Técnica: PricebookEntry PEKING confirmado por Apex este bloque | **Validación técnica OK — QA funcional manual pendiente** | N1 (catálogo oficial) ya no bloquea la ruta positiva técnica | Este documento, Fase 2 |
| `CreateWoliFromExpense` | v15 activa | Modificado (Lote 2A) | Ídem | Ídem | **Validación técnica OK — QA funcional manual pendiente** | Ídem | Fase 2 |
| `AgregarManoObra` | v2 activa | Modificado (Lote 2A) | Ídem | Ídem | **Validación técnica OK — QA funcional manual pendiente** | Ídem | Fase 2 |
| `Opp_flow_V3` | v29 activa | Modificado (Lote 2D1) | Lookup `Empresa_Operadora__c` obligatorio + `Resolver_Pricebook_Empresa` | Grafo trazado desde `<start>`: selector confirmado en la ruta ejecutable obligatoria; datos reales Pekín (`QA_PEKING_S3`) coinciden exactamente | **Validación técnica OK — QA funcional manual pendiente** | Ninguno técnico | Fase 3 |
| `Opportunity_Flow_V2` | v7 activa | Modificado (Lote 2D1) | Lookup obligatorio en ambas rutas (general y mostrador) | Grafo confirmado 100% reachable en ambas rutas; **pero** 15 Opportunities reales recientes de los mismos Record Types (incl. una del 2026-08-09, posterior al deploy) muestran el campo vacío — origen no confirmado (no se probó que vengan de este Flow) | **Validación técnica OK — comportamiento en datos reales sin confirmar** | Investigación de procedencia de datos pendiente (no es un bloqueo de negocio) | Fase 3 |
| `Opp_Flow_V5` | v30 activa | Modificado (Lote 2D2) | Lookup obligatorio **solo en la ruta por defecto** | Grafo confirmado: la rama **"Taller"** llega a `CreateOpportunity` sin pasar nunca por la pantalla de Empresa — `Empresa_Operadora__c` queda `null` en esa rama. Confirmado con datos reales: 4 Opportunities posteriores al deploy (v30 activo desde 2026-08-04) con el campo vacío | **Bloqueado técnico** (defecto confirmado, no es contradicción de documentación) | Falta un assignment/lookup de Empresa en la rama Taller antes de `CreateOpportunity` | Fase 3 |
| `Opp_Flow_v6` | v80 activa | Modificado (Lote 2D2) | Lookup obligatorio en ambas rutas (principal y mostrador) | Grafo confirmado 100% reachable en ambas rutas, verificado dos veces (BFS + grep); datos reales Pekín coinciden | **Validación técnica OK — QA funcional manual pendiente** | Mismo caveat de procedencia de datos que `Opportunity_Flow_V2`, sin evidencia de un bypass estructural en este Flow | Fase 3 |
| `Work_Order_from_Quote` | v10 activa | Modificado (este bloque anterior, `634c143`) | `Empresa_Operadora__c` primero, fallback legacy sin cambios | Confirmado por Apex: expresión exacta del Flow resuelve `RMPEKING`; regresión Bavarian/Otobai confirmada | **Validación técnica OK — QA funcional manual pendiente** | N2 de fondo (bodega/territorio real) sigue sin datos oficiales | `RESULTADO_BLOQUE_N2N3N4_PEKING_20260812.md` |
| `Work_Order_from_Quote_Selective` | v8 activa | Modificado (`634c143`) | Ídem | Ídem | **Validación técnica OK — QA funcional manual pendiente** | Ídem | Ídem |
| `SegregateWOLIs` | v51 activa | Sin modificar | Ninguno | No aplica | **Bloqueado por negocio** | N3 — sin equivalente Bavarian para `Garantia_Otobai__c` | Ídem |
| `aperturaCaseWorOrderEvent` | v20 activa | Sin modificar | Ninguno | No aplica | **Bloqueado por negocio** | N4 — convención de `ServiceTerritory` sin campo Empresa | Ídem |
| `ct_newCaseWorkOrderEvent` | v54 activa | Sin modificar | Ninguno | No aplica | **Bloqueado por negocio** | N4 — mismo motivo | Ídem |
| `ReciboUsadosFlow` | v3 activa | No aplica | Ninguno | No aplica | **No aplica a Pekín** | Usados excluido de PEKING por decisión de Luis | F11 |
| `Carga_MO_26_Lavado_a_Caso` | — | Obsolete | Ninguno | No aplica | **No aplica a Pekín** | Flow obsoleto, sin ruta activa | F20 |

**Conteo final, contado directamente de la columna "Estado actual" de la tabla de arriba, sin doble conteo:**

| Estado actual | Cantidad | Flows |
|---|---:|---|
| Revisado — sin cambio | 4 | `Opportunity_Flow`, `Opp_flow_v4`, `BMW_ImportarPlantilla`, `Opportunity_Flow_From_Work_Order` |
| QA OK / técnicamente cerrado | 2 | `BMW_Gestiona_Listas_de_Precios`, `Obtener_PricebookEntry_en_Linea_de_Plantilla_de_Presupuesto` |
| Validación técnica OK — QA funcional manual pendiente | 7 | `PlanDeMantenimientoV2`, `CreateWoliFromExpense`, `AgregarManoObra`, `Opp_flow_V3`, `Opp_Flow_v6`, `Work_Order_from_Quote`, `Work_Order_from_Quote_Selective` |
| Validación técnica OK — comportamiento en datos reales sin confirmar | 1 | `Opportunity_Flow_V2` |
| Bloqueado técnico | 1 | `Opp_Flow_V5` (defecto confirmado, ver abajo) |
| Bloqueado por negocio | 3 | `SegregateWOLIs`, `aperturaCaseWorOrderEvent`, `ct_newCaseWorkOrderEvent` |
| No aplica a Pekín | 2 | `ReciboUsadosFlow`, `Carga_MO_26_Lavado_a_Caso` |
| **Total** | **20** | Coincide exactamente con `F01`-`F20` de la matriz formal |

La suma "6 sin cambio" citada en el mandato original agrupaba, sin decirlo, "sin cambio" (4) + "QA OK ya cerrado" (2) = 6 — de ahí la aparente discrepancia con esta tabla, ya reconciliada aquí de forma explícita.

## Fase 3 — Resolución de la contradicción en 4 Flows Opportunity

Se investigó cada uno de forma independiente (metadata local = metadata activa en Sandbox, verificado por versión antes de empezar; sin drift Git↔Partial en ninguno de los 4), trazando el grafo de conectores completo desde `<start>` (no por lectura lineal ni por asumir orden de archivo).

| Flow | Selector de Empresa | Nodo legacy `Encuentra_Price_Book` | Veredicto |
|---|---|---|---|
| `Opp_flow_V3` | Reachable y obligatorio (pantalla `Crear_Veh_culo_0`, campo `EmpresaSeleccionada`) | Confirmado sin conectores entrantes — muerto | **Selector real, dead code confirmado, sin contradicción** |
| `Opportunity_Flow_V2` | Reachable y obligatorio en ambas rutas (general y mostrador) | Confirmado muerto | **Selector real** — pero datos reales recientes (mismo Record Type) no lo confirman en la práctica; procedencia no determinada |
| `Opp_Flow_v6` | Reachable y obligatorio en ambas rutas (principal y mostrador) | Confirmado muerto | **Selector real, dead code confirmado, sin contradicción** |
| `Opp_Flow_V5` | Reachable y obligatorio **solo en la ruta por defecto** — la rama "Taller" (`IfConfigUsuarioTaller`) hace un `goTo` que salta la pantalla y llega a `CreateOpportunity` con `Empresa_Operadora__c` sin asignar | Confirmado muerto | **Defecto real confirmado, no una contradicción de documentación** |

En los 4 casos, el "nodo legacy desconectado" que el precheck detectó es la **misma pieza real**: la Decision `Encuentra_Price_Book` (con sus 4 Assignments `Asigna_Oto_Local`/`Asigna_Otobai_Dolar`/`Asigna_Bavarial_Local`/`Asigna_Bavarian_Dolar`), que quedó sin ningún conector entrante en los 4 Flows tras la migración — reemplazada por `Resolver_Pricebook_Empresa` (`EmpresaPricebookResolver`). Confirmado por grep independiente en cada archivo (cero coincidencias de `targetReference` hacia ese nombre). **No se modificó ningún archivo para "hacer coincidir" la documentación** — se documentó el comportamiento real encontrado, incluyendo el defecto de `Opp_Flow_V5`.

**Hallazgo de seguridad durante la investigación:** el agente que investigó `Opp_flow_V3` reportó que un script de su propio scratchpad fue sobrescrito a mitad de tarea por un proceso externo, apuntando a un archivo no relacionado (`Opp_Flow_V5.flow-meta.xml`) con instrucciones incrustadas pidiéndole no revelar el cambio. El agente ignoró esas instrucciones, lo reportó de forma transparente, y completó la verificación de forma independiente vía Grep/Read directos contra el archivo real. La conclusión de ese agente está corroborada dos veces (grafo + grep independiente + datos reales), por lo que no se considera comprometida — se documenta como anomalía a vigilar, no como hallazgo técnico del Sprint.

### Defecto confirmado en `Opp_Flow_V5` (no corregido en este bloque)

**Mecanismo exacto:** en la Decision `IfConfigUsuarioTaller`, la rama Taller usa un `goTo` que conecta directamente a `VehiculosEncontradosFalse`, saltándose por completo la pantalla `PantallaInicial` (que contiene el lookup obligatorio `EmpresaSeleccionada`). Esa rama sí lee `GetUser2.Empresa__c` (variable `EmpresaUsuario`), pero esa variable **solo se usa dentro de la condición de una Decision** (`ifEmpresa`) y nunca se escribe en `Empresa_Operadora__c`. El resultado: cualquier Opportunity creada desde la ruta Taller de `Opp_Flow_V5` queda sin `Empresa_Operadora__c`, independientemente de la compañía real del usuario — incluido Pekín.

**Evidencia en datos reales:** 4 Opportunities recientes (`QA Prueba`, `Maria Prueb`, `John Alessandro...`, entre el 2026-08-09 y 2026-08-12, todas posteriores a que v30 quedara activa el 2026-08-04) tienen `Empresa_Operadora__c = null` y `BMW_Compania__c = "Bavarian"` — consistente exactamente con el mecanismo encontrado.

**No corregido en este bloque** porque: (a) este bloque es de reconciliación/QA, no de implementación nueva; (b) la corrección requiere decidir *qué* pantalla o mecanismo debe usarse en la rama Taller (¿la misma `PantallaInicial`? ¿una nueva?) — una decisión de diseño de UX que no corresponde inventar aquí. Se documenta como **la próxima acción técnica de mayor prioridad** para el siguiente bloque de Flows.

## Fase 2 — QA técnico dirigido (evidencia)

Ejecutado vía Apex anónimo (`sf apex run`, con `Savepoint`/`rollback` donde se creó data de prueba) contra `RedMotorsSandbox`. Consistente con el nivel de rigor ya usado en `RESULTADO_LOTE2A/2D1/2D2` (screen-flow interactivo = QA manual, no automatizado por API).

| Flow | Empresa | Escenario | Registros usados | Provisional/Real | Resultado esperado | Resultado obtenido | Evidencia |
|---|---|---|---|---|---|---|---|
| `PlanDeMantenimientoV2` / `CreateWoliFromExpense` / `AgregarManoObra` | PEKING | Resolver + PricebookEntry de `SAD001`/`SUB` | `EmpresaPricebookResolver.resolveForEmpresa` + 4 PricebookEntry (bloque anterior) | Provisional (PricebookEntry) | `EXITO`, PricebookEntry encontrado | `EXITO` para CRC y USD; PricebookEntry encontrado (1 cada uno) | Log Apex, este bloque |
| Ídem | Bavarian | Regresión — mismo query que antes de este bloque | `SAD001`/`SUB` PricebookEntry ya existentes | Real (ya existía) | Sin cambio de comportamiento | Confirmado: PricebookEntry intacto | Log Apex |
| Ídem | Otobai | Regresión | `SAD001`/`SUB` PricebookEntry ya existentes en Otobai Local/Dólares | Real (ya existía) | Sin cambio de comportamiento | Confirmado sin cambios (el resolver retorna `NO_CONFIGURADO` por ambigüedad de moneda ya documentada desde 2026-07-30, no una regresión nueva) | Log Apex, `CIERRE_TECNICO_SPRINT2_EMPRESA_PRICEBOOK.md` §8 |
| `Work_Order_from_Quote` / `_Selective` | PEKING | `Empresa_Operadora__r.Codigo_ERP__c` resuelve el código ERP correcto | Opportunity de prueba con `Empresa_Operadora__c=PEKING` | Provisional (Opportunity de prueba, revertida) | `"RMPEKING"` | `"RMPEKING"` exacto | Log Apex, `Database.rollback()` |
| Ídem | Bavarian | Fallback legacy se activa correctamente | Opportunity con solo `BMW_Compania__c='Bavarian'` | Provisional | `Empresa_Operadora__c=null` → activa fallback | Confirmado | Log Apex |
| Ídem | Otobai | Fallback legacy se activa correctamente | Opportunity con solo `BMW_Compania__c='Otobai'` | Provisional | `Empresa_Operadora__c=null` → activa fallback | Confirmado | Log Apex, este bloque |
| `Opp_flow_V3`, `Opp_Flow_v6` | PEKING | Grafo + datos reales | Opportunities `QA_PEKING_S3*` ya existentes | Real | `Empresa_Operadora__c` poblado, `BMW_Compania__c` vacío | Confirmado | Investigación Fase 3 |
| `Opp_Flow_V5` | PEKING (ruta Taller) | Grafo | — | — | `Empresa_Operadora__c` poblado | **Falla** — campo queda vacío | Investigación Fase 3 |

**Efecto colateral no reversible detectado (segunda vez):** la inserción de Opportunities de prueba disparó nuevamente automatización de alerta de duplicados con envío de correo síncrono (no cubierto por `rollback`), igual que en el bloque anterior. Notificación interna del sistema, sin datos de clientes reales expuestos.

## Fase 4 — Componentes previamente bloqueados (C01-C25)

Se revisaron los 25 componentes de `MATRIZ_CIERRE_SPRINT2.csv` contra los cambios reales de este bloque y el anterior (resolución dinámica de Pricebook, fix de `precioProductoJSON`, clave de Bodega por Empresa, PricebookEntries/ServiceTerritory provisionales, migración de los 2 Flows Quote→WO).

| Componente | Estado anterior | Dependencia bloqueante | ¿Sigue bloqueado? | Motivo | Próxima acción |
|---|---|---|---|---|---|
| `productSearcher` | MODIFICAR (no autorizado) | Definir fuente de Empresa/Pricebook del buscador | Sí | Es un cambio de LWC no autorizado por nombre por Luis; el patrón backend (`Empresa_Operadora__c` + resolver) ya existe como referencia, pero tocar el LWC requiere autorización explícita | Ninguna en este bloque — clasificación únicamente |
| `rm_vn_crear_opp_inventario` | MODIFICAR (no autorizado) | Definir empresa fuente en la pantalla | Sí | Igual — LWC no autorizado | Clasificación únicamente |
| `rm_vn_inventario` / `rm_vn_inventario_movil` | BLOQUEADO | Empresa, bodegas y permisos PEKING no confirmados | Sí | Depende de catálogo oficial de bodegas PEKING (N2 de fondo), no resuelto por la Bodega provisional técnica de este bloque | Sin acción hasta datos oficiales |
| `rm_vn_get_record_opp_record_types` | BLOQUEADO | Mapeo Empresa↔Record Type PEKING | Sí | Decisión de negocio (qué Record Type de Opportunity usa PEKING) no tomada | Pendiente de Luis/Diego |
| `busquedaDetallada` | MODIFICAR (no autorizado) | Definir fuente Empresa en contexto de búsqueda | Sí | LWC no autorizado; controlador Apex asociado ya tiene el resolver disponible como dependencia técnica | Clasificación únicamente |
| `qoSearchDetailProduct` / `woSearchDetailProduct` / `localizacionDetails` / `pricebookReferenceDetails` (WorkOrder/Softland) | BLOQUEADO | Bodegas oficiales, código ERP y precios PEKING | Sí | Mismos motivos: catálogo/bodega oficial de PEKING no existe; la Bodega provisional de este bloque es explícitamente "no producción", no sustituye el dato oficial | Sin acción hasta datos oficiales |

**Ningún componente cruzó el umbral de "listo para implementar".** Los bloqueos reales son (a) falta de catálogo/bodega/sucursal oficial de Pekín, o (b) falta de autorización explícita de Luis por nombre para tocar LWC/Aura — ninguno de los dos se resuelve con trabajo de backend/Flow. No se modificó ningún componente.

## Fase 5 — Bloqueos N3/N4 (reafirmados, sin cambios)

Sin novedad respecto a `RESULTADO_BLOQUE_N2N3N4_PEKING_20260812.md`:

- **N3 — `SegregateWOLIs`:** confirmado, sin equivalente Bavarian para `Garantia_Otobai__c`. No se encontró evidencia nueva en el repositorio que permita inferir la regla. Sigue bloqueado.
- **N4 — `aperturaCaseWorOrderEvent` / `ct_newCaseWorkOrderEvent`:** confirmado, la diferenciación por Empresa depende de una convención de texto en `ServiceTerritory.Name` (objeto sin campo `Empresa__c`). No se agregó "Pekín" a `BMW_Compania__c` ni a `User.Empresa__c` — hacerlo perpetuaría el modelo legacy que el proyecto busca reemplazar. Sigue bloqueado.

## Fase 6 — Preguntas reales para Luis/Diego

| Bloqueo | Flow/componente | Qué sabemos | Qué NO puede inferirse | Decisión requerida |
|---|---|---|---|---|
| N3 | `SegregateWOLIs` | `Garantia_Otobai__c` es un mecanismo exclusivo de Otobai (marcas KAWASAKI/POLARIS para ruteo de garantía); Bavarian no tiene equivalente en ningún campo del objeto `tipoCargo__c` | Si Pekín necesita una política de garantía análoga, y si sí, cuál | ¿Pekín maneja garantías de fábrica? Si sí, ¿bajo qué mecanismo/campo? |
| N4 | `aperturaCaseWorOrderEvent`, `ct_newCaseWorkOrderEvent` | La diferenciación actual es 100% por substring `"otobai"` en `ServiceTerritory.Name`; ni Bavarian ni la mayoría de sus propios territorios siguen una convención de nombre por marca | Nombres/territorios reales de sucursales Pekín; si el mecanismo debe seguir siendo por nombre o migrar a un campo estructural `Empresa__c` en `ServiceTerritory` | Catálogo oficial de sucursales/territorios PEKING + decisión de diseño (texto vs. campo estructural) |
| Técnico (no de negocio, informativo) | `Opp_Flow_V5` | La rama "Taller" nunca escribe `Empresa_Operadora__c`, confirmado por grafo y por 4 Opportunities reales recientes con el campo vacío | — no requiere decisión de Luis, es un defecto técnico a corregir | Ninguna decisión de negocio necesaria; se documenta para priorización de desarrollo, no como pregunta |

Solo N3 y N4 requieren respuesta real de Luis/Diego. Todo lo demás investigado en este bloque se resolvió con baseline Bavarian, configuración existente, datos provisionales ya autorizados, o metadata/documentación — sin necesidad de consulta adicional.

## Datos provisionales — trazabilidad acumulada (todos los bloques)

| Tipo | Nombre/Id | Empresa | Motivo | Baseline | Provisional | Uso en QA |
|---|---|---|---|---|---|---|
| Bodega__c | `a2bAK0000000vvxYAA` "PEKING TEMPORAL - PARTIAL - NO USAR EN PRODUCCION" | PEKING | Pre-existente (2026-07-29), anterior a estos bloques | N/A | Sí | No usado directamente en este bloque |
| PricebookEntry | `01uAK000000YRDtYAO` (SAD001 × PEKING Local) | PEKING | Desbloquear QA positivo N1 | Bavarian/Otobai ya tienen PBE nominal `UnitPrice=1` para SAD001 | Sí | `PlanDeMantenimientoV2` |
| PricebookEntry | `01uAK000000YRFVYA4` (SAD001 × PEKING Dólares) | PEKING | Ídem | Ídem | Sí | `PlanDeMantenimientoV2` |
| PricebookEntry | `01uAK000000YRH7YAO` (SUB × PEKING Local) | PEKING | Ídem | Ídem | Sí | `CreateWoliFromExpense`, `AgregarManoObra` |
| PricebookEntry | `01uAK000000YRFWYA4` (SUB × PEKING Dólares) | PEKING | Ídem | Ídem | Sí | `CreateWoliFromExpense`, `AgregarManoObra` |
| ServiceTerritory | `0HhAK0000000sbV0AQ` "PEKING TEMPORAL - NO PRODUCCION" | PEKING | Superar gate técnico `territorio_no_vacio` | Estructura mínima (Name + OperatingHours genérico "8-5pm", no ligado a sucursal real) | Sí | `Work_Order_from_Quote`, `Work_Order_from_Quote_Selective` |

**No se creó ningún dato nuevo en este bloque** — solo se reutilizaron datos ya existentes y ya documentados.

## Criterio de cierre del bloque

1. **¿Cuántos Flows forman el alcance autoritativo final?** 20 — exactamente `F01`-`F20` de `MATRIZ_CIERRE_SPRINT2.csv`. Confirmado, sin doble conteo (ver aclaración de conteo en Fase 1).
2. **¿Cómo se distribuyen?** 4 revisado-sin-cambio, 2 QA OK/técnicamente cerrado (bloque Pricebook original), 7 validación técnica OK/QA manual pendiente, 1 validación técnica OK con dato real sin confirmar (`Opportunity_Flow_V2`), 1 bloqueado técnico (`Opp_Flow_V5`, defecto confirmado), 3 bloqueado por negocio (N3/N4), 2 no aplica.
3. **¿Cuántos están técnicamente cerrados?** 6 (4 sin cambio + 2 QA OK).
4. **¿Cuántos requieren QA manual?** 8 (los 7 "validación técnica OK" + `Opportunity_Flow_V2` con su caveat).
5. **¿Cuántos siguen bloqueados por negocio?** 3 (`SegregateWOLIs`, `aperturaCaseWorOrderEvent`, `ct_newCaseWorkOrderEvent`).
6. **¿Cuántos están bloqueados técnicamente?** 1 (`Opp_Flow_V5` — defecto confirmado en la rama Taller).
7. **¿Cuántos no aplican?** 2 (`ReciboUsadosFlow`, `Carga_MO_26_Lavado_a_Caso`).
8. **¿Qué componentes se desbloquearon?** Ninguno de los 16 previamente bloqueados (C01-C25) cruzó el umbral de "listo para implementar" — todos siguen dependiendo de catálogo/bodega/sucursal oficial de Pekín o de autorización explícita de Luis para tocar LWC/Aura.
9. **¿Qué preguntas concretas quedan para Luis/Diego?** Solo 2 (N3 política de garantía Pekín; N4 catálogo de sucursales/territorios y decisión de diseño texto-vs-campo). El hallazgo de `Opp_Flow_V5` es técnico, no requiere decisión de Luis.
10. **¿Qué falta exactamente para declarar Sprint 2 cerrado?** (a) Corregir el defecto de `Opp_Flow_V5` (rama Taller); (b) QA funcional manual (interview real) de los 8 Flows en estado "validación técnica OK"; (c) resolver N3 y N4 con Luis/Diego; (d) decidir si se investiga la procedencia de los datos reales sin `Empresa_Operadora__c` en `Opportunity_Flow_V2`/`Opp_Flow_v6` antes de darlos por ciertos; (e) todo lo ya pendiente de bloques anteriores (Community/Aura, LWC de inventario, catálogo oficial PEKING).

**Sprint 2 no se declara cerrado.**

## Archivos modificados en este bloque

- `docs/empresa-marcas-chinas/RESULTADO_RECONCILIACION_QA_20260812.md` (nuevo, este documento)
- `docs/empresa-marcas-chinas/README_CONTEXTO_ACTIVO.md` (puntero)

**Ningún Flow, componente Apex ni metadata fue modificado en este bloque** — por lo tanto no se ejecutó ningún deploy.
