# Resultado Lote 2 — Flows activos no bloqueados

## Resultado ejecutivo

La intersección de criterios autorizada produjo **cero Flows elegibles**. Los doce Flows asignados al Lote 2 están activos en Producción y clasificados `MODIFICAR`, pero todos conservan un bloqueo explícito en `MATRIZ_CIERRE_SPRINT2.csv`. En consecuencia, no se modificó ni desplegó metadata.

No se reinterpretó un bloqueo como autorización técnica. La clasificación funcional de las 45 filas se mantuvo porque esta revisión no aportó una decisión funcional nueva.

## Criterios aplicados

Cada Flow debía cumplir simultáneamente:

1. activo en Producción;
2. clasificación `MODIFICAR`;
3. asignado expresamente al Lote 2;
4. sin bloqueo funcional pendiente;
5. no exclusivo de usados;
6. sin dependencia de despacho.

Los primeros tres criterios se cumplen en los doce candidatos. Ninguno cumple el cuarto; además, los dos Flows Quote→Work Order dependen de definiciones de despacho.

## Revisión por Flow

| Flow | Versión anterior/actual en Partial | Estado | Problema y comportamiento anterior | Modificación | Resolver/estados/fallback | Evidencia y bloqueo | Prueba/video requerido |
|---|---|---|---|---|---|---|---|
| `PlanDeMantenimientoV2` | v23 activa | Activo | PricebookEntry sin contexto empresarial suficiente | Omitido | Pendiente adopción; no se alteró | Falta Pricebook y catálogo PEKING aplicable | Mantenimiento para tres Empresas; PricebookEntry correcto |
| `Work_Order_from_Quote_Selective` | v7 activa | Activo | Bifurcación Bavarian/Otobai y dependencias operativas | Omitido | Pendiente adopción; no se alteró | Faltan bodega, territorio y reglas de despacho PEKING | Quote→WO selectivo, bodega/territorio y trazabilidad |
| `Work_Order_from_Quote` | v9 activa | Activo | Patrón binario y operación PEKING indefinida | Omitido | Pendiente adopción; no se alteró | Falta definición operativa y tiene dependencia de despacho | Quote→WO y regresión completa |
| `SegregateWOLIs` | v51 activa | Activo | Record Type Id fijo y garantía Otobai | Omitido | Resolver no sustituye la política de segregación | Faltan garantía/segregación PEKING y mecanismo de Record Type | WOLI/cargos/garantía sin Id fijo |
| `Opp_Flow_V5` | v29 activa; v30 Draft | Activo/Draft | Pricebooks nominales; fuente local corresponde a Draft | Omitido | No se modificó ni activó v30 | La matriz conserva decisión de vigencia/retiro; no se puede tratar Draft como activa | Oportunidad por Empresa/moneda sobre versión autorizada |
| `Opp_flow_V3` | v28 activa | Activo | Pricebooks y compañía nominales | Omitido | Pendiente adopción; no se alteró | La matriz conserva confirmación de vigencia frente a v4/v6 | Oportunidad para tres Empresas y monedas |
| `Opp_Flow_v6` | v79 activa; v80 Draft | Activo/Draft | Pricebooks nominales y versiones divergentes | Omitido | No se modificó ni activó v80 | Falta autoridad de versión en la matriz | Regresión v79 y validación aislada de Draft autorizada |
| `Opportunity_Flow_V2` | v6 activa | Activo | Empresa del usuario puede gobernar selección | Omitido | Pendiente adopción; no se alteró | Falta regla usuario↔Empresa y confirmación de vigencia | Usuario y Empresa cruzados sin sobrescritura |
| `CreateWoliFromExpense` | v14 activa | Activo | Decisión Bavarian/Otobai y búsquedas duplicadas | Omitido | Pendiente adopción; no se alteró | Faltan mapeos de gastos, productos y Pricebooks PEKING | Gasto→WOLI para tres Empresas y errores controlados |
| `aperturaCaseWorOrderEvent` | v20 activa | Activo | Evento binario y Pricebook nominal | Omitido | Pendiente adopción; no se alteró | Faltan agenda, sucursal y Pricebook PEKING | Caso→WO/Event por Empresa |
| `ct_newCaseWorkOrderEvent` | v54 activa | Activo | Evento condicionado a Otobai/códigos legacy | Omitido | Pendiente adopción; no se alteró | Falta definición de servicio/evento PEKING | Caso→WO/Event y rutas negativas |
| `AgregarManoObra` | v1 activa | Activo | Assignments Bavarian/Otobai y selección de PBE | Omitido | Pendiente adopción; no se alteró | Faltan catálogo y precios de mano de obra PEKING | Mano de obra para tres Empresas y múltiples monedas |

## Consultas y validación técnica

- Se consultó únicamente `RedMotorsSandbox` mediante Tooling API de solo lectura.
- Se confirmó `ActiveVersion`, `LatestVersion` y estado para los doce candidatos.
- No se consultó Producción; su estado ya estaba documentado.
- No hubo Flow autorizado que justificara retrieve, edición XML, análisis de conexiones, dry-run o deploy.
- Un dry-run con paquete vacío no aporta evidencia técnica y no se ejecutó.

## Pruebas, cobertura y despliegue

- Flows modificados: 0.
- Pruebas Apex del lote: no aplican; no hubo metadata candidata.
- Cobertura nueva: no aplica.
- Id de dry-run: no aplica.
- Id de deploy: no aplica.
- Versiones desplegadas: ninguna.
- Versiones activadas/desactivadas: ninguna.

## Preguntas y bloqueos

Las preguntas necesarias ya existen consolidadas en `PREGUNTAS_BLOQUEOS_SPRINT2.md`, principalmente N1 (configuración comercial), N2 (bodega/despacho/taller), N3 (garantía/segregación) y D3 (Record Types). La matriz contiene además las decisiones de versión/vigencia de los cuatro Flows legacy. No se agregó una pregunta duplicada.

## Evidencias y videos pendientes

- Mantenimiento con Pricebook/PricebookEntry empresarial.
- Quote→WO normal y selectivo.
- Segregación de WOLI/cargos y garantía.
- Gasto→WOLI y mano de obra.
- Caso→WO/Event.
- Oportunidades en las versiones legacy autorizadas.
- En todos: Bavarian, Otobai, PEKING explícito, lookup vacío con fallback permitido, desconocido, sin Pricebook, varias opciones y resultado no exitoso sin continuar con Id nulo.

## Confirmaciones

No se modificaron Flows, Apex, LWC/Aura, recursos de usados, despacho, datos ni configuración. No se hizo deploy y Producción no fue consultada ni tocada.

## Recomendación

No iniciar un lote funcional siguiente. Primero deben resolverse por escrito los bloqueos de los Flows que se pretendan ejecutar y corregirse la matriz para que exista una lista no vacía. Después debe autorizarse un sublote pequeño por dominio, comenzando por el Flow que no dependa de despacho ni de catálogo no confirmado.
