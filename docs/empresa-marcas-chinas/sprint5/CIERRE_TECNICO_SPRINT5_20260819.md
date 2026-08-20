# Cierre técnico Sprint 5 — Pricebooks PEKING + E2E/Regresión (2026-08-19)

## 1. Objetivo y alcance

Sprint 5 cubre las actividades 13 (Pricebooks) y 14 (integración/regresión E2E) del proyecto Empresa /
Marcas Chinas, sobre `RedMotorsSandbox` (Partial Sandbox, Org Id `00DAK000000npFt2AI`). Alcance ejecutado
íntegramente dentro de lo autorizado: los 2 Pricebooks PEKING existentes (`PEKING Dólares`,
`PEKING Local`) y el recorrido `Opportunity → Quote → Work Order → Factura` para OMODA/JAECOO.

## 2. Actividad 13 — Pricebooks

**Estado: COMPLETADA** (para el catálogo QA actualmente disponible; catálogo oficial completo queda
`PENDIENTE DE DATO DE NEGOCIO`, ver sección 8).

- `Pricebook2` verificados sin duplicados: `PEKING Dólares` (`01sAK0000006DXFYA2`, USD, activo) y
  `PEKING Local` (`01sAK0000006DVdYAM`, CRC, activo). No se creó ningún Pricebook2 nuevo.
- Se crearon exactamente 2 `PricebookEntry` nuevos, reconciliando `PEKING Local` con `PEKING Dólares`:
  - `01uAK000000ZeIjYAK` — QAOMODA2026UNIT001 en PEKING Local, CRC, `UnitPrice=1` (provisional QA), activo.
  - `01uAK000000ZeKLYA0` — QAJAECOO2026UNIT001 en PEKING Local, CRC, `UnitPrice=1` (provisional QA), activo.
- Verificado antes de insertar: ausencia de duplicado `Pricebook2Id+Product2Id+CurrencyIsoCode`, Standard
  Price CRC activo para ambos productos, Product2 activo para ambos.
- Verificado después: 6 `PricebookEntry` en PEKING Local (4 previos + 2 nuevos), 4 en PEKING Dólares (sin
  cambios), sin duplicados en ninguno de los 2 Pricebooks.
- Evidencia completa BEFORE/AFTER en `evidencias/ACT13_BEFORE_20260819.md` y
  `evidencias/ACT13_AFTER_20260819.md`.

### Hallazgo fuera de alcance (documentado, no accionado)

Existen 2 Pricebook2 adicionales, `OMODA - 2026` (`01sAK0000007MmzYAE`) y `JAECOO - 2026`
(`01sAK0000007OiLYAU`), creados el 2026-08-15. Durante Actividad 14 se confirmó (invocación real de
`RM_VN_Inventario_Ctrl.getRecords`) que son catálogos legítimos de "precios de fantasía" por marca, usados
por `RM_VN_Service.getPBEFantasiaGroupByModel` — **no son Pricebooks PEKING duplicados**, sino un mecanismo
distinto ya existente en la arquitectura. No estaban mencionados en el alcance autorizado de Sprint 5 y no
se modificaron. Se documentan para que Luis/Diego confirmen si deben incorporarse formalmente a la
documentación del proyecto.

## 3. Actividad 14 — E2E y regresión

**Estado: COMPLETADA EN TODO LO EJECUTABLE — BLOQUEADA EXTERNAMENTE en el tramo QuoteLineItem→WorkOrder→
Factura por el incidente preexistente RQ329.**

Resumen (detalle completo y evidencia en `evidencias/ACT14_E2E_REGRESION_20260819.md` y en la matriz
`MATRIZ_SPRINT5_PRICEBOOKS_E2E_20260819.csv`):

| Tramo | OMODA | JAECOO | Resultado |
|---|---|---|---|
| Opportunity → Quote | PASS | PASS | Empresa, Pricebook y moneda correctos |
| QuoteLineItem | BLOQUEADO EXTERNO | BLOQUEADO EXTERNO | RQ329, reconfirmado con evidencia idéntica |
| Work Order → Factura | BLOQUEADO EXTERNO | BLOQUEADO EXTERNO | Cascada desde RQ329, no alcanzable |
| Inventario / grilla VN | PASS | PASS | Sin regresión tras Actividad 13 |
| Bodega / ubicación | PASS | PASS | Sin regresión |
| Aprobaciones (Centro de Costo) | PASS (inspección) | — | Sin cambios desde Sprint 3 |
| Softland | BLOQUEADO EXTERNO / documentado | — | Config. inspeccionada, callout no ejecutado |
| Regresión arquitectura por Empresa | PASS | — | Sin hardcode binario reintroducido |

### RQ329 — reconfirmación con evidencia adicional

Se reprodujo el mismo error exacto documentado en Sprint 4 (`System.QueryException: Variable does not
exist: tmpVar1` en `RQ329_INS_LockGuard.assertLineChanges`) al intentar insertar `QuoteLineItem` para
OMODA y para JAECOO. Como evidencia adicional de Sprint 5, se probó también con un producto no vehicular
(BSI) en el mismo Quote OMODA, y el mismo error se reprodujo — confirmando que el guard bloquea **cualquier**
inserción de `QuoteLineItem` en ese contexto, no algo específico de OMODA/JAECOO/PEKING. Ninguna de las 3
transacciones dejó datos residuales (rollback completo confirmado por consulta). No se modificó
`RQ329_INS_QuoteLineGuard` ni `RQ329_INS_LockGuard`, conforme a la regla de la sección 14 del prompt de
ejecución.

### Softland

No se ejecutó ningún callout real. El cliente (`RM_SoftlandClient.cls`) apunta a
`http://172.176.136.132:5080` (label `ambienteSoftland=IntegrationServices`), configuración que se
documentó pero no se pudo confirmar con certeza absoluta como aislada de cualquier sistema productivo desde
este entorno; adicionalmente, el punto real donde se dispara el callout (confirmación de Quote/Order) es
posterior al bloqueo de RQ329, por lo que no es alcanzable en este Sprint de todas formas.

## 4. Código / metadata

**No se modificó ningún archivo Apex, Flow ni metadata de configuración en Sprint 5.** Todos los cambios
de Sprint 5 son datos (2 `PricebookEntry`) y documentación. No fue necesario ningún deploy a Partial.

## 5. Datos Salesforce

### Creados

- `PricebookEntry` `01uAK000000ZeIjYAK` (PEKING Local / QAOMODA2026UNIT001 / CRC / UnitPrice=1 / Active).
- `PricebookEntry` `01uAK000000ZeKLYA0` (PEKING Local / QAJAECOO2026UNIT001 / CRC / UnitPrice=1 / Active).

### Modificados

Ninguno.

### NO modificados deliberadamente

- Los 4 `PricebookEntry` preexistentes en PEKING Local (BSI, Subcontratos x2, vehículo BMW) — no se tocaron
  por no ser parte del alcance de reconciliación OMODA/JAECOO.
- Los Pricebook2 `OMODA - 2026` / `JAECOO - 2026` y sus `PricebookEntry` — fuera de alcance (sección 2).
- `RQ329_INS_QuoteLineGuard` / `RQ329_INS_LockGuard` — incidente externo, fuera de alcance.
- `RM_Config__mdt.Bodega_Principal_RMPEKING`, bodega `PKT01`, territorio temporal — datos provisionales ya
  autorizados, sin necesidad de cambio.

### Rollback / evidencia disponible

Los 2 `PricebookEntry` creados son eliminables individualmente por Id sin afectar ningún otro dato (no hay
más de un consumidor conocido). Evidencia BEFORE/AFTER completa en `evidencias/`.

## 6. RQ329

Apareció, se reconfirmó con evidencia idéntica a la ya documentada, y se amplió con una prueba de
aislamiento (producto no vehicular en el mismo Quote) que confirma su naturaleza transversal.
**Clasificación: `BLOQUEADO EXTERNO`.** No modificado.

## 7. Softland

Se pudo probar únicamente la configuración de destino (`URLSoftland`/`ambienteSoftland`), de forma
100% de solo lectura. No se ejecutó ningún callout real por las 2 razones documentadas en la sección 3
(seguridad + bloqueo natural por RQ329). Sin restricciones de acceso encontradas; la limitación es de
alcance seguro, no de permisos.

## 8. Pendientes de negocio

- Catálogo oficial completo de modelos OMODA/JAECOO (más allá de los 2 Product2 QA existentes).
- Precios comerciales reales para OMODA/JAECOO (actualmente `UnitPrice=1` provisional en todos los
  Pricebooks).
- Confirmación de si `OMODA - 2026` / `JAECOO - 2026` (catálogos de precios de fantasía) deben
  formalizarse como parte de la documentación oficial del proyecto PEKING.
- Confirmación de negocio sobre si el endpoint Softland (`172.176.136.132:5080`,
  `ambienteSoftland=IntegrationServices`) es apto para pruebas adicionales sin riesgo productivo.
- Resolución del incidente externo RQ329 (fuera del control del proyecto PEKING).

## 9. Datos provisionales (deberán sustituirse)

- `UnitPrice=1` en los 2 `PricebookEntry` nuevos de Actividad 13 (y en el resto de PricebookEntry QA
  OMODA/JAECOO ya existentes en USD).
- Bodega temporal PEKING `PKT01` (`a2bAK0000000vvxYAA`) y su mapeo en `RM_Config__mdt`.
- Territorio temporal (`0HhAK0000000sbV0AQ`).
- Modelos OMODA/JAECOO (`QA OMODA`, `QA JAECOO`) como placeholders del catálogo real.
- Las 2 Opportunity QA (`006AK00000JOCQ5YAP`, `006AK00000JOCQ6YAP`) y sus Quotes asociados.

## 10. Documentación generada

- `docs/empresa-marcas-chinas/sprint5/evidencias/ACT13_BEFORE_20260819.md` — estado antes de Actividad 13.
- `docs/empresa-marcas-chinas/sprint5/evidencias/ACT13_AFTER_20260819.md` — estado después + cierre Actividad 13.
- `docs/empresa-marcas-chinas/sprint5/evidencias/ACT14_E2E_REGRESION_20260819.md` — evidencia completa E2E/regresión.
- `docs/empresa-marcas-chinas/sprint5/evidencias/scripts/*.apex` — scripts Anonymous Apex usados para regresión (solo lectura).
- `docs/empresa-marcas-chinas/sprint5/MATRIZ_SPRINT5_PRICEBOOKS_E2E_20260819.csv` — matriz de trazabilidad Sprint 5.
- Este documento (`CIERRE_TECNICO_SPRINT5_20260819.md`).

### Nota sobre el reporte general del proyecto (DOCX)

No se modificó `Reporte_Final_Empresa_Marcas_Chinas_RedMotors_20260815.docx` ni el `.docx` de avance
presente en `entregables/` directamente, para evitar el riesgo de corromper un documento binario sin una
herramienta de edición segura verificada en este entorno. La documentación Markdown/CSV de esta carpeta es
la fuente autoritativa del cierre de Sprint 5; el contenido a incorporar al reporte general está resumido
íntegramente en este documento (secciones 1-9) y puede copiarse directamente a la sección correspondiente
del DOCX cuando alguien lo edite manualmente o con una herramienta verificada.

## 11. Git

- Worktree: `C:\Users\dokur\Documents\Repositorios\RedMotors-Sprint5-Pricebooks-E2E`
- Rama: `feature/pc/redmotors-empresa-marcas-chinas-sprint5-pricebooks-e2e-20260819`
- HEAD inicial: `05bbd1495868389e8eae06096bfd7be29709b471`
- Commits Sprint 5: ver `git log` (evidencia Actividad 13 + este cierre documental de Actividad 14/cierre).
- No se hizo merge a `main`. No se hizo force push.

## 12. Conclusión

Sprint 5 queda **técnicamente cerrado en todo lo ejecutable dentro del ambiente Partial Sandbox**:

- Actividad 13 (Pricebooks) está completa para el catálogo QA disponible; lo único pendiente es catálogo/
  precio oficial, que es una definición de negocio, no un defecto técnico.
- Actividad 14 (E2E/regresión) ejecutó todo lo alcanzable: el tramo inicial (`Opportunity → Quote`,
  inventario, bodega, aprobaciones) está en PASS; el tramo `QuoteLineItem → Work Order → Factura` queda
  bloqueado por un incidente externo preexistente (RQ329) ya conocido desde Sprint 4, reconfirmado con
  evidencia adicional en Sprint 5, y fuera del control técnico del proyecto PEKING.
- La integración Softland quedó documentada hasta el punto seguro; no se ejecutó ningún callout real por
  precaución de seguridad y porque el flujo real no es alcanzable de todas formas mientras RQ329 no se
  resuelva.

No hay fallos ocultos ni pendientes ocultos: todos los bloqueos son externos y ya estaban identificados
antes de este Sprint; ningún dato QA se presenta como productivo; ningún catálogo o precio se inventó.
