# Matriz maestra de trazabilidad — Sprint 1 Empresa / Marcas Chinas

Worktree: `C:\Users\dokur\Documents\Repositorios\RedMotors-Sprint1-Trazabilidad`
Rama: `analysis/pc/redmotors-empresa-marcas-chinas-sprint1-trazabilidad-20260726`
Base: `origin/feature/pc/redmotors-empresa-marcas-chinas-sprint1-20260724` @ `a623f54`

Análisis local. No se ejecutó `sf`, no se consultó ningún org, no se modificó
código ni metadata, no hubo deploy. No se tocaron las ramas de Bloques 18, 19,
20 ni 21 (solo lectura de su documentación versionada). No se eliminó ningún
worktree.

## Fuentes documentales usadas

| Fuente | Naturaleza |
|---|---|
| `DEV Evaluación - Alcance - Inclusión de nueva Empresa- Marchas chinas Redmotors.docx.pdf` | Documento original de alcance (Portalnet), 10 páginas |
| `Manual_Analisis_Empresa_RedMotors_2026-07-22.docx` | Análisis técnico complementario contra `redProd` (Tooling API de solo lectura), 22-jul-2026 — la fuente más rica en decisiones pendientes y definición de terminado |
| `CONTEXTO_CODEX_EMPRESA_MARCAS_CHINAS.md` | Contexto y alcance del Sprint 1 |
| `INVENTARIO_APEX_SPRINT1.md` | Inventario Apex confirmado (74 clases, 4 triggers) |
| `PLAN_IMPLEMENTACION_SPRINT1.md` | Clasificación de 41 clases directas y plan por bloques |
| `BITACORA_IMPLEMENTACION.md` | Registro de commits, Deploy IDs y Test Run IDs de los Bloques 1-19 |
| `IMPLEMENTACION_BLOQUE20_LEAD_PEKING.md` (worktree de Codex, solo lectura) | Estado en progreso del Bloque 20 |
| `IMPLEMENTACION_BLOQUE21_OPORTUNIDAD_UI.md` (este mismo trabajo, Bloque 21) | Hallazgo: sin cambio declarativo seguro para implementar |
| `PENDIENTES_DECISION_BLOQUE20.md` | Preguntas pendientes de Bloque 20 (resueltas parcialmente por autonomía autorizada) |
| Historial de `git log` en `sprint1` hasta `a623f54` | Evidencia de commits |

## Cómo leer esta matriz

- **Completado**: implementado, con evidencia de dry-run y/o deploy exitoso en `RedMotorsSandbox`/Partial, registrada en la bitácora, y ya integrado a `sprint1`.
- **En progreso**: implementado localmente en una rama propia, sin dry-run/deploy confirmado todavía, o pendiente de validación.
- **Pendiente técnico**: no depende de una decisión de negocio, pero no se pudo cerrar por falta de metadata local, de acceso al org, o de un artefacto que replicar.
- **Pendiente decisión**: bloqueado exclusivamente por una respuesta de Luis o Diego.
- **Diferido**: identificado en la documentación de alcance, deliberadamente fuera del presupuesto de 44 horas del Sprint 1, sin fecha de retomar.
- **Fuera de alcance**: excluido explícitamente del Sprint 1 (otro proyecto, otra fase, u objeto no tocado).

No se marca nada como Completado solo por haber sido analizado. Pruebas,
worktrees y documentación no se cuentan como funcionalidad nueva (ver Resumen
C).

---

## A. Objeto Empresa y clases de soporte

### A.1 Crear objeto `Empresa__c` como maestro con clave estable

1. **Fuente:** Manual de Análisis, §5.1 y §3 ("Crear Empresa__c es correcto como base... resolver por códigos estables"); PDF original, implícito en toda la tabla de campos.
2. **Requerimiento:** Objeto `Empresa__c` con `Codigo__c` (Unique/External Id), no depender de `Name`.
3. **Componentes:** `Empresa__c` (objeto), campos `Name`, `Codigo__c`, `Codigo_ERP__c`, `Nombre_Legal__c`, `Activa__c`.
4. **Bloque:** 1.
5. **Estado:** Completado.
6. **Evidencia:** commit `7f8b919` (`feat(empresa): add configurable company foundation`); Deploy ID `0AfAK000000vhrR0AQ` (10/10 componentes, 18/18 pruebas, 0 fallas); `IMPLEMENTACION_BLOQUE1.md`.
7. **Riesgo pendiente:** ninguno propio; el modelo relacional completo recomendado por el Manual (`Empresa_Padre__c`, `Cuenta_Facturacion__c`, `Politica_Documental__c`) no se implementó — ver A.6.
8. **Acción faltante:** ninguna para el alcance mínimo de Sprint 1.
9. **Responsable de decisión:** No aplica (ya decidido y desplegado).
10. **Confirmación:** solo se crearon los 4 campos mínimos aprobados; no se agregó ningún campo adicional del modelo completo del Manual sin autorización.

### A.2 `EmpresaResolver`, `EmpresaContext`, `EmpresaConfigurationException` — resolución fail-closed

1. **Fuente:** Manual de Análisis, §5.1 y §7.1 ("servicio de resolución único, bulkificado... default lanza excepción funcional"); PDF original, riesgo "empresa desconocida cae en Bavarian".
2. **Requerimiento:** Resolver empresa por Id/código, bulkificado, sin fallback silencioso a Bavarian.
3. **Componentes:** `EmpresaResolver.cls`, `EmpresaContext.cls`, `EmpresaConfigurationException.cls`, `EmpresaResolverTest.cls`, `EmpresaContextTest.cls`.
4. **Bloque:** 1.
5. **Estado:** Completado.
6. **Evidencia:** commit `7f8b919`; Deploy ID `0AfAK000000vhrR0AQ`; 18/18 pruebas incluyendo casos negativos (nulo, desconocido, inactivo, código/nombre legal faltante).
7. **Riesgo pendiente:** los métodos bulk (`resolveAll`, `resolveAllByCodigo`) están probados, pero no todos los 41 consumidores directos del inventario los usan todavía (ver secciones de Softland/reservas/anticipos, diferidas).
8. **Acción faltante:** ninguna para lo ya implementado.
9. **Responsable de decisión:** No aplica.
10. **Confirmación:** el resolver no incorpora ninguna regla de negocio no solicitada (no resuelve por `Name`, como pedía el Manual).

### A.3 Permission Set de administración de Empresa

1. **Fuente:** `PLAN_IMPLEMENTACION_SPRINT1.md` §8.1 ("permisos mínimos para perfiles de administración").
2. **Requerimiento:** Permission Set para gestionar `Empresa__c` sin exponer `View All`/`Modify All`.
3. **Componentes:** `Empresa_Admin` (Permission Set).
4. **Bloque:** 1.
5. **Estado:** Completado.
6. **Evidencia:** commit `cc1614c`; dry-run `0AfAK000000viCP0AY`, deploy `0AfAK000000viHF0AY` (1/1, 0 fallas). Fallo previo documentado: `0AfAK000000vi9B0AQ` (Salesforce rechazó `fieldPermissions` sobre `Codigo__c` obligatorio), corregido omitiendo ese campo.
7. **Riesgo pendiente:** asignación real de usuarios y confirmación de si `ReadWrite` es el sharing definitivo — sigue pendiente (ver Pendientes §12.1 de la bitácora).
8. **Acción faltante:** asignar `Empresa_Admin` a usuarios autorizados; confirmar sharing definitivo.
9. **Responsable de decisión:** Luis/Diego (sharing definitivo de `Empresa__c`).
10. **Confirmación:** sin `Modify All`/`View All`/eliminación, tal como se pidió.

### A.4 Tercera empresa: código `RMPEKING`, marcas Omoda/Jaecoo

1. **Fuente:** `BITACORA_IMPLEMENTACION.md` §4, hito 6 ("Luis confirmó 30 horas Apex + 14 horas... Diego: nueva empresa PEKING, marcas Omoda y Jaecoo").
2. **Requerimiento:** Definir código estable y marcas de la tercera empresa.
3. **Componentes:** Decisión funcional, sin componente propio.
4. **Bloque:** Decisión previa a Bloque 2.
5. **Estado:** Completado.
6. **Evidencia:** `BITACORA_IMPLEMENTACION.md` §4, fila "Nueva empresa: PEKING" y "Marcas: Omoda y Jaecoo", confirmadas por Diego.
7. **Riesgo pendiente:** ninguno sobre la decisión en sí.
8. **Acción faltante:** ninguna.
9. **Responsable de decisión:** ya resuelto (Diego).
10. **Confirmación:** no aplica (es una decisión, no una funcionalidad).

### A.5 Pricebooks `PEKING Local` y `PEKING Dólares`

1. **Fuente:** `BITACORA_IMPLEMENTACION.md` §4.1.
2. **Requerimiento:** Crear los dos Pricebooks activos de PEKING con los nombres autorizados.
3. **Componentes:** `Pricebook2` (datos, no metadata desplegable).
4. **Bloque:** 2 (preparación de datos).
5. **Estado:** Completado.
6. **Evidencia:** `PEKING Local` (`01sAK0000006DVdYAM`), `PEKING Dólares` (`01sAK0000006DXFYA2`), ambos activos, USD, creados en `RedMotorsSandbox` — operación de datos autorizada, no deploy de metadata.
7. **Riesgo pendiente:** **no tienen `PricebookEntry` ni productos cargados** — la empresa PEKING no está operativa de punta a punta.
8. **Acción faltante:** cargar `PricebookEntry` y productos autorizados; crear registros operativos de `Empresa__c` para PEKING.
9. **Responsable de decisión:** Luis/Diego (qué productos y precios cargar).
10. **Confirmación:** no se cargaron productos ni `PricebookEntry` sin autorización — se dejó explícitamente vacío hasta la decisión de negocio.

### A.6 Modelo relacional completo recomendado (Producto_Empresa, Bodega.Empresa, Sucursal/ServiceTerritory, Usuario_Empresa, Empresa_Padre)

1. **Fuente:** Manual de Análisis, §5.2 y Anexo E ("Empresa_Padre__c", "Producto_Empresa__c junction", "Bodega__c: agregar Empresa__c", "Sucursal__c/ServiceTerritory: relacionar con Empresa__c", "Usuario_Empresa__c junction").
2. **Requerimiento:** Modelo relacional completo, no solo picklists/lookups puntuales.
3. **Componentes:** `Producto_Empresa__c` (nuevo), `Bodega__c.Empresa__c` (nuevo), `Sucursal__c`/`ServiceTerritory` relacionados a `Empresa__c`, `Usuario_Empresa__c` (nuevo), `User.Empresa_Predeterminada__c`.
4. **Bloque:** Ninguno — no asignado a Sprint 1.
5. **Estado:** Diferido.
6. **Evidencia:** no hay commit ni Deploy ID; no forma parte de las 41 clases directas del `PLAN_IMPLEMENTACION_SPRINT1.md` ni de ningún bloque cerrado.
7. **Riesgo pendiente:** sin este modelo, la exclusividad Producto↔Empresa, Bodega↔Empresa y Usuario↔Empresa sigue dependiendo de picklists (`Product2.Empresa__c`, etc.), exactamente el patrón que el Manual pide reemplazar.
8. **Acción faltante:** diseño y aprobación de alcance con Luis/Diego; no es una extensión menor, es la "Opción B — Estratégica" del Manual (55-85 personas-semana).
9. **Responsable de decisión:** Luis/Diego — el propio Manual lo marca como decisión de alcance ("Opción A táctica" vs "B estratégica" vs "C por dominios"), no como tarea técnica lista para ejecutar.
10. **Confirmación:** no se implementó nada de este modelo — se documenta como brecha reconocida, no como trabajo en curso.

---

## B. Opportunity

### B.1 `Opportunity.Empresa_Operadora__c` (lookup) y consumidor representativo

1. **Fuente:** `BITACORA_IMPLEMENTACION.md` §18 (Bloque 6); Manual de Análisis §6, fila `Opportunity.BMW_Compania__c → Empresa_Operadora__c/Empresa_Facturadora__c (Lookup)`.
2. **Requerimiento:** Lookup de Opportunity a `Empresa__c`, con precedencia sobre el picklist heredado, sin selección por descarte.
3. **Componentes:** `Opportunity.Empresa_Operadora__c`, `ProductControllerTwo.getAvailabilityByQuote()`.
4. **Bloque:** 6.
5. **Estado:** Completado.
6. **Evidencia:** commit `ae6e0e6` (`feat(opportunity): add configurable company lookup`); checkpoint `b427ab6`; backup `backup/pc/redmotors-sprint1-before-opportunity-20260725`.
7. **Riesgo pendiente:** permisos y migración de datos históricos de `Opportunity.Empresa_Operadora__c` — pendientes al cierre del Bloque 6.
8. **Acción faltante:** migración de Opportunities existentes al lookup nuevo.
9. **Responsable de decisión:** No aplica para lo ya hecho; la migración histórica sí requiere decisión (ver B.4).
10. **Confirmación:** no se tocaron Flows, integraciones, reservas, Quote, Product2 ni `Plantilla_de_Presupuesto__c` en este bloque, tal como registra la bitácora.

### B.2 Replicar permisos de `Empresa_Operadora__c` sobre el modelo de perfiles vigente

1. **Fuente:** `BITACORA_IMPLEMENTACION.md` §20 (Bloque 8).
2. **Requerimiento:** Igualar el acceso de `Empresa_Operadora__c` al de `BMW_Compania__c` en los perfiles existentes, sin crear seguridad nueva.
3. **Componentes:** 146 archivos de perfil.
4. **Bloque:** 8.
5. **Estado:** Completado.
6. **Evidencia:** commit `a137b19` (`feat(opportunity): replicate company lookup permissions`); dry-run `0AfAK000000vouX0AQ` (146/147 componentes válidos, 146/146 perfiles aceptados).
7. **Riesgo pendiente:** 2 perfiles quedaron elevados de solo lectura a lectura/edición (`Asesor de Taller V2`, `Jefe de Ventas Usados Motos A1`) — cambio de alcance menor, ya documentado, sin objeción registrada.
8. **Acción faltante:** ninguna.
9. **Responsable de decisión:** No aplica.
10. **Confirmación:** 0 cambios colaterales en los XML de perfil fuera del campo objetivo, según la propia bitácora.

### B.3 Record Types `Opportunity.Omoda` y `Opportunity.Jaecoo`

1. **Fuente:** `BITACORA_IMPLEMENTACION.md` §28 (Bloque 17); PDF original §2 ("Los 2 RT nuevos de marca... siguiendo el mismo patrón").
2. **Requerimiento:** Record Types activos para Omoda y Jaecoo, mismo patrón que BMW (Sales Process, Compact Layout, picklist values).
3. **Componentes:** `Opportunity.Omoda`, `Opportunity.Jaecoo` (Record Types), `Product2.Empresa__c=RMPEKING`, `Vehiculos_Nuevos_PS`.
4. **Bloque:** 17.
5. **Estado:** Completado.
6. **Evidencia:** commit `2e1c733` (`feat(empresa): add PEKING product and opportunity metadata`); dry-run final `0AfAK000000vquk0AA` (4/4, NoTestRun); deploy real `0AfAK000000vrNl0AI` (4/4, sin fallas). Confirmado en este mismo análisis (Bloque 21): ambos RT locales son idénticos entre sí y coinciden con lo documentado.
7. **Riesgo pendiente:** ninguno sobre el Record Type en sí.
8. **Acción faltante:** ninguna.
9. **Responsable de decisión:** No aplica.
10. **Confirmación:** no se modificó Apex, Flows, perfiles ni FlexiPages en este bloque (confirmado en la propia bitácora y re-confirmado en el análisis de Bloque 21).

### B.4 Experiencia declarativa de Opportunity para Omoda/Jaecoo (Layouts, Lightning Record Pages, List Views, Quick Actions)

1. **Fuente:** PDF original §6 ("Layouts... Duplicar como plantilla para los 2 RT nuevos"; "List Views... crear el set equivalente"); Manual de Análisis §7.8 y Anexo A ("38 layouts, 70 list views candidatas por marca/sucursal").
2. **Requerimiento:** Layout, Lightning Record Page, Compact Layout, List Views y Quick Actions equivalentes a BMW para Omoda/Jaecoo.
3. **Componentes:** Layouts de Opportunity, FlexiPages, List Views, Quick Actions.
4. **Bloque:** 21 (investigado, sin cambio).
5. **Estado:** Pendiente técnico.
6. **Evidencia:** `IMPLEMENTACION_BLOQUE21_OPORTUNIDAD_UI.md` — ningún Layout, FlexiPage, List View ni Quick Action de Opportunity está versionado localmente para ninguna marca (ni siquiera BMW), por lo que no hay patrón local que replicar sin consultar el org (prohibido en ese bloque).
7. **Riesgo pendiente:** Omoda/Jaecoo pueden no tener una página de registro o vistas de lista utilizables en la práctica, aunque el Record Type ya exista.
8. **Acción faltante:** retrieve dirigido de Layouts/FlexiPages/List Views de BMW (fuera del alcance de análisis puramente local) para poder compararlos y replicarlos con evidencia.
9. **Responsable de decisión:** técnico (requiere acceso al org), no una decisión de negocio en sí misma.
10. **Confirmación:** no se creó ninguna List View, Layout ni Quick Action inventada sin patrón local verificable.

---

## C. Lead / Potencial

### C.1 Record Types `Lead.Omoda` y `Lead.Jaecoo` + mapeo Lead→Opportunity

1. **Fuente:** `PENDIENTES_DECISION_BLOQUE20.md` (preguntas 1-3); PDF original §2 ("Lead: Replicar 2 RT nuevos... para que el mapeo Lead→Opportunity funcione").
2. **Requerimiento:** Record Types de Lead para Omoda/Jaecoo y su mapeo a los Record Types de Opportunity ya existentes.
3. **Componentes:** `Lead.Omoda`, `Lead.Jaecoo`, `RM_RecordTypeMapping.Lead_Omoda_to_Opp`, `RM_RecordTypeMapping.Lead_Jaecoo_to_Opp`, `RM_Lead_Trigger_Helper_Test`.
4. **Bloque:** 20 (Codex, en curso).
5. **Estado:** En progreso.
6. **Evidencia:** `IMPLEMENTACION_BLOQUE20_LEAD_PEKING.md` (worktree `RedMotors-Bloque20-LeadPeking`, rama `feature/pc/redmotors-empresa-marcas-chinas-bloque20-lead-peking-20260726`) — implementado localmente, replicando `Lead.BMW` como plantilla técnica. **Sin dry-run, sin regresión, sin deploy todavía** (pendientes explícitos del propio documento).
7. **Riesgo pendiente:** todo lo propio de un cambio no validado: compilación, cobertura, regresión sobre `RM_Lead_Trigger_Helper`/`TraficoTriggerHandler`.
8. **Acción faltante:** dry-run enfocado, regresión seleccionada, deploy condicionado a pruebas en verde, verificación post-deploy (las cuatro explícitamente listadas por Codex).
9. **Responsable de decisión:** ya autorizado por Luis bajo criterio de autonomía ("dale tú sin miedo a los ajustes"); pendiente de validación técnica, no de nueva decisión de negocio.
10. **Confirmación:** trabajo de Codex, no de esta tarea; no se duplicó ni se tocó este worktree.

### C.2 Anomalía `Lead.BMW` → `Opportunity.Polaris`

1. **Fuente:** `IMPLEMENTACION_BLOQUE20_LEAD_PEKING.md`, evidencia técnica ("La configuración BMW → Polaris se documenta como anomalía existente").
2. **Requerimiento implícito:** confirmar si el mapeo `Lead.BMW → Opportunity.Polaris` es correcto o es un error de configuración heredado.
3. **Componentes:** `RM_RecordTypeMapping__mdt` (registro existente, no tocado).
4. **Bloque:** Detectado en 20, no corregido.
5. **Estado:** Pendiente decisión.
6. **Evidencia:** `PENDIENTES_DECISION_BLOQUE20.md`, pregunta 4 ("¿El mapping actual BMW → Polaris es correcto?"); confirmado como anomalía real por consulta a la configuración activa.
7. **Riesgo pendiente:** si es un error, Leads de marca BMW se están convirtiendo hoy en Opportunities de Polaris — un riesgo funcional real, ajeno a este Sprint.
8. **Acción faltante:** confirmación de Luis/Diego sobre si corregir.
9. **Responsable de decisión:** Luis/Diego.
10. **Confirmación:** no se tocó este mapeo en ningún bloque.

### C.3 Flujo de tráfico/reservas para "usados" y decisiones de alcance de Lead

1. **Fuente:** `PENDIENTES_DECISION_BLOQUE20.md`, pregunta 5 ("¿Qué Pricebook debe usarse para usados según empresa?"); `PLAN_IMPLEMENTACION_SPRINT1.md` §7 (`RM_Lead_Trigger_Helper`: "¿Usados/Lead forman parte del Sprint 1?").
2. **Requerimiento:** Definir si "usados" entra al alcance de PEKING.
3. **Componentes:** `RM_Lead_Trigger_Helper`, `RM_VU_Inventario_Ctrl`, `RM_VU_Service`.
4. **Bloque:** Ninguno.
5. **Estado:** Pendiente decisión.
6. **Evidencia:** preguntas explícitas en ambos documentos, sin respuesta registrada.
7. **Riesgo pendiente:** si "usados" entra al alcance más adelante, ningún componente de esa cadena tiene todavía soporte PEKING.
8. **Acción faltante:** respuesta de Luis/Diego.
9. **Responsable de decisión:** Luis/Diego.
10. **Confirmación:** no se implementó nada de usados en ningún bloque.

---

## D. Order

### D.1 `Order.empresaQueFactura__c` para tres empresas

1. **Fuente:** PDF original §1 ("Order.empresaQueFactura__c... Agregar nueva"); Manual de Análisis §4 (tabla de distribución: `RMBAVARIAN 39.981; RMOTOBAI 1.304; nulo 2`) y §6.
2. **Requerimiento:** Extender `Order.empresaQueFactura__c` a `RMPEKING` y resolver por `EmpresaResolver` en los consumidores (`OrderBatch`, `orderJSONData`, `doCalloutCancelarPedidoSoftland`).
3. **Componentes:** `Order.empresaQueFactura__c`, `OrderBatch.cls`, `orderJSONData.cls`, `doCalloutCancelarPedidoSoftland.cls`.
4. **Bloque:** Ninguno.
5. **Estado:** Fuera de alcance (Sprint 1).
6. **Evidencia:** no aparece en ningún bloque de la bitácora; los tres consumidores son integración Softland real, excluida explícitamente del criterio de autonomía de los Bloques 18/20/21.
7. **Riesgo pendiente:** `Order` sigue sin soporte PEKING; cualquier pedido generado para PEKING heredaría el mismo problema binario que Quote/WorkOrder tenían antes del Sprint 1.
8. **Acción faltante:** todo — no se ha iniciado.
9. **Responsable de decisión:** Luis/Diego (alcance de integración Softland para PEKING) antes de asignar horas técnicas.
10. **Confirmación:** no se tocó `Order` en ningún bloque de este Sprint.

---

## E. Work Order

### E.1 `WorkOrder.empresaFacturaCP__c` (lookup) y `WorkOrderTrigger`

1. **Fuente:** `BITACORA_IMPLEMENTACION.md` §16 (Bloque 4); Manual de Análisis §6 (`WorkOrder.empresaFactura__c → Empresa_Facturadora__c`).
2. **Requerimiento:** Lookup de WorkOrder a `Empresa__c`, selección de Pricebook por las 3 empresas × 2 monedas, sin selección por descarte.
3. **Componentes:** `WorkOrder.empresaFacturaCP__c`, `WorkOrder.empresaFactura__c` (compatibilidad), `WorkOrderTrigger.trigger`, `WorkOrderTriggerTest.cls`.
4. **Bloque:** 4 y 5.
5. **Estado:** Completado.
6. **Evidencia:** commit `67410e3` (Bloque 4), commit `b427ab6` (fix Garantía, Bloque 5); Deploy ID `0AfAK000000vnon0AA` (4/4, 50/50 pruebas, Bloque 4); Deploy ID `0AfAK000000vo4v0AA` (2/2, 51/51 pruebas, Bloque 5).
7. **Riesgo pendiente:** ver E.2 — comportamiento ante empresa vacía/desconocida sigue "temporal, pendiente de confirmación final de Diego" según la propia bitácora (hito 31/36).
8. **Acción faltante:** confirmación final de Diego sobre el comportamiento ante empresa no resuelta; migración de WorkOrders históricos al lookup nuevo; retiro futuro de `empresaFactura__c`.
9. **Responsable de decisión:** Diego (comportamiento ante empresa vacía), Luis/Diego (migración histórica).
10. **Confirmación:** solo se corrigió el literal `Garantía`→`Garantia` (defecto real, autorizado explícitamente por Luis) — no se tocó ninguna otra regla de negocio del trigger.

### E.2 Comportamiento de `empresaFacturaCP__c` ante empresa vacía/desconocida — inconsistencia entre consumidores

1. **Fuente:** Análisis independiente de esta misma tarea (Bloque 21, Fase 5), sobre evidencia de `WorkOrderTrigger.trigger`, `TrabajoController.cls` y `BMWVinScanTrabajoGenerator.cls`.
2. **Requerimiento implícito:** una única política de fallback para todo consumidor de `empresaFacturaCP__c`.
3. **Componentes:** los tres archivos citados.
4. **Bloque:** Detectado en el análisis de Bloque 21, no en un bloque de implementación.
5. **Estado:** Pendiente decisión.
6. **Evidencia:** `IMPLEMENTACION_BLOQUE21_OPORTUNIDAD_UI.md`, sección "Fase 5" — `WorkOrderTrigger` conserva el Pricebook en silencio ante empresa no resuelta; `TrabajoController`/`BMWVinScanTrabajoGenerator` (Bloques 14/15) lanzan `EmpresaConfigurationException`. Ambas reglas están deliberadamente implementadas, no son un olvido de código.
7. **Riesgo pendiente:** dos comportamientos distintos ante el mismo dato vacío, en el mismo objeto.
8. **Acción faltante:** decisión de Diego sobre si `WorkOrderTrigger` debe alinearse al patrón fail-closed de los otros dos, considerando el riesgo distinto de romper guardados automáticos de WorkOrders históricos.
9. **Responsable de decisión:** Diego.
10. **Confirmación:** no se implementó ningún cambio sobre este campo, siguiendo la instrucción de no actuar cuando hay más de una regla comercial válida.

### E.3 `TrabajoController` y `TrabajoQuoteController` — empresa configurable en trabajos

1. **Fuente:** `BITACORA_IMPLEMENTACION.md` §24-25 (Bloques 13-14); Manual de Análisis, Anexo A.1 (ambas clases listadas como prioritarias).
2. **Requerimiento:** Resolver empresa desde el lookup antes de crear trabajos/subtrabajos de WorkOrder y Quote.
3. **Componentes:** `TrabajoQuoteController.saveTrabajo()`, `TrabajoController.saveSubtrabajos()`.
4. **Bloque:** 13 y 14.
5. **Estado:** Completado.
6. **Evidencia:** commits `57d1880` (Bloque 13), `2f8a923` (Bloque 14); cobertura confirmada 93.38 % (`TrabajoQuoteController`) según bitácora.
7. **Riesgo pendiente:** ninguno propio distinto del ya cubierto en E.2.
8. **Acción faltante:** ninguna.
9. **Responsable de decisión:** No aplica.
10. **Confirmación:** no se modificaron impuestos, tipos de cargo, `PricebookEntry` ni integraciones — solo la resolución de empresa, según la bitácora.

### E.4 `BMWVinScanTrabajoGenerator` — VIN Scan

1. **Fuente:** `BITACORA_IMPLEMENTACION.md` §26 (Bloque 15); Manual de Análisis, Anexo A.1.
2. **Requerimiento:** Resolver empresa antes de crear trabajos/subtrabajos vía VIN Scan.
3. **Componentes:** `BMWVinScanTrabajoGenerator.cls` (dos recorridos).
4. **Bloque:** 15.
5. **Estado:** Completado.
6. **Evidencia:** commit `1b9e859`.
7. **Riesgo pendiente:** ninguno propio distinto de E.2.
8. **Acción faltante:** ninguna.
9. **Responsable de decisión:** No aplica.
10. **Confirmación:** sin cambios de metadata, tipos de trabajo ni UTS fuera de la resolución de empresa.

---

## F. Quote

### F.1 `QuoteController` — selección de Pricebook sin default

1. **Fuente:** `BITACORA_IMPLEMENTACION.md` §7 (Bloque 2); Manual de Análisis, Anexo A.1 y §7.1 (clase de mayor prioridad).
2. **Requerimiento:** Eliminar el default a `Bavarian Local`, soportar las 6 combinaciones empresa×moneda.
3. **Componentes:** `QuoteController.cls`, `QuoteControllerTest.cls`.
4. **Bloque:** 2.
5. **Estado:** Completado.
6. **Evidencia:** commit `9669237`; Deploy ID `0AfAK000000vlTd0AI` (4/4, 22/22 pruebas, 0 fallas).
7. **Riesgo pendiente:** ninguno propio.
8. **Acción faltante:** ninguna.
9. **Responsable de decisión:** No aplica.
10. **Confirmación:** no se modificaron `UpdateCurrencyScheduler`, `WorkOrderTrigger`, Softland, reservas, anticipos ni inventario en este bloque (bitácora explícita).

### F.2 `QuoterController` — sin default global a Bavarian Dólar

1. **Fuente:** `BITACORA_IMPLEMENTACION.md` §27 (Bloque 16); `PLAN_IMPLEMENTACION_SPRINT1.md` §7 (antes clasificada "requiere validación funcional").
2. **Requerimiento:** Resolver `Opportunity.Empresa_Operadora__c` en vez de seleccionar globalmente `Bavarian Dólar`.
3. **Componentes:** `QuoterController.createQuote()`, `addLineItem()`.
4. **Bloque:** 16.
5. **Estado:** Completado.
6. **Evidencia:** commit `3e7232a`.
7. **Riesgo pendiente:** ninguno propio.
8. **Acción faltante:** ninguna.
9. **Responsable de decisión:** No aplica.
10. **Confirmación:** se retiraron 7 bloques de `Test.isRunningTest()` que ocultaban errores en pruebas, según bitácora — corrección de calidad, no funcionalidad nueva.

### F.3 `cT_QuoteUsdPDFController` / `cT_QuoteCrcPDFController` — PEKING en PDF de cotización

1. **Fuente:** `BITACORA_IMPLEMENTACION.md` §22-23 (Bloques 11-12); Manual de Análisis §7.4 (riesgo legal de PDF).
2. **Requerimiento:** Mapear `PEKING Local`/`PEKING Dólares` en la conversión de moneda del PDF de cotización.
3. **Componentes:** `cT_QuoteUsdPDFController.cls`, `cT_QuoteCrcPDFController.cls`.
4. **Bloque:** 11 y 12.
5. **Estado:** Completado.
6. **Evidencia:** commits `4b127b3` (USD), `86ab781` (CRC).
7. **Riesgo pendiente:** esto **no** cubre la identidad legal/razón social del PDF (ver H.2, diferido) — solo el mapeo de Pricebook/moneda.
8. **Acción faltante:** ninguna para el mapeo de moneda; la identidad legal completa sigue diferida.
9. **Responsable de decisión:** No aplica para lo hecho.
10. **Confirmación:** no se tocó la plantilla visual, logo ni razón social del PDF en estos bloques.

### F.4 `Quote.empresaFactura__c` — semántica y FLS dudosos

1. **Fuente:** Manual de Análisis §3.1 y §6 ("Quote.empresaFactura__c existe en metadata de redProd, pero no fue visible en el describe del usuario de auditoría; validar FLS y uso antes de asumir equivalencia con Compania__c").
2. **Requerimiento:** Confirmar si este campo es equivalente a `Quote.Compania__c` antes de migrarlo.
3. **Componentes:** `Quote.empresaFactura__c`.
4. **Bloque:** Ninguno.
5. **Estado:** Pendiente decisión.
6. **Evidencia:** hallazgo textual del Manual, sin seguimiento posterior en la bitácora de ningún bloque.
7. **Riesgo pendiente:** si se asume equivalencia sin validar, se podría migrar sobre una base incorrecta.
8. **Acción faltante:** validar FLS y uso real de este campo (requiere consulta al org, no realizada en Sprint 1).
9. **Responsable de decisión:** técnico primero (validación), luego Luis/Diego si hay ambigüedad de negocio.
10. **Confirmación:** no se asumió equivalencia ni se migró nada de este campo.

---

## G. Pricebooks y moneda (transversal)

### G.1 `BMW_ChangeCurrencyWOWOLI` y `UpdateCurrencyScheduler`

1. **Fuente:** `BITACORA_IMPLEMENTACION.md` §7 y §16 (Bloques 2 y 3); Manual de Análisis, Anexo A.1 (ambas prioritarias).
2. **Requerimiento:** Conversión bidireccional CRC/USD para las 3 empresas, sin fallback; scheduler que procese las 3 empresas.
3. **Componentes:** `BMW_ChangeCurrencyWOWOLI.cls`, `UpdateCurrencyScheduler.cls`.
4. **Bloque:** 2 y 3.
5. **Estado:** Completado.
6. **Evidencia:** commit `9669237` (Bloque 2, Deploy `0AfAK000000vlTd0AI`); commit `2d5fab4` (Bloque 3, Deploy `0AfAK000000vllN0AQ`, 2/2, 7/7 pruebas).
7. **Riesgo pendiente:** el riesgo heredado de "eliminar antes de reinsertar" en el scheduler permanece sin corregir por no estar autorizado (registrado explícitamente en la bitácora, hito 30).
8. **Acción faltante:** autorización explícita para corregir ese riesgo heredado, si se decide hacerlo.
9. **Responsable de decisión:** Luis/Diego, si se quiere ampliar el alcance de esta corrección.
10. **Confirmación:** no se corrigió el riesgo heredado sin autorización — se documentó y se dejó igual.

### G.2 Batches/schedulers Softland de catálogo con literal único `RMBAVARIAN`

1. **Fuente:** PDF original §3 y §9; Manual de Análisis §7.7 y Anexo A.1 (`BatchGetCategoriaClienteSoftland` y 5 clases hermanas, `BatchGetBodegaSoftland`, `ScheduleGetActividadComercialSoftland`, `ScheduleGetAseguradoraSoftland`, `ScheduleGetBodegaSoftland`).
2. **Requerimiento:** Iterar por empresas activas en vez de un literal fijo `RMBAVARIAN`.
3. **Componentes:** 6 `BatchGet*Softland`, `BatchGetBodegaSoftland`, 3 `ScheduleGet*Softland`.
4. **Bloque:** Ninguno.
5. **Estado:** Diferido.
6. **Evidencia:** `INVENTARIO_APEX_SPRINT1.md` §6.4, `PLAN_IMPLEMENTACION_SPRINT1.md` §5 (todas marcadas "No"/"No" en S30/S44).
7. **Riesgo pendiente:** hoy estos batches **ni siquiera consultan Otobai**, mucho menos PEKING — es deuda preexistente, no introducida por este Sprint, pero tampoco cerrada por él.
8. **Acción faltante:** todo el trabajo — requiere confirmar contrato Softland antes de tocar código (ver sección Softland).
9. **Responsable de decisión:** Luis/Diego (alcance de integración Softland).
10. **Confirmación:** no se tocó ninguno de estos componentes.

---

## H. Productos / Inventario, PDFs, Reservas, Anticipos, Softland (diferidos por riesgo)

### H.1 `ProductSearcherController` — mano de obra por empresa

1. **Fuente:** `BITACORA_IMPLEMENTACION.md` §30 (Bloque 18); PDF original §5 (LWC/inventario).
2. **Requerimiento:** Resolver empresa por `RecordType` para Omoda/Jaecoo en la búsqueda de mano de obra, sin selección por descarte.
3. **Componentes:** `ProductSearcherController.cls`, `ProductSearcherControllerTest.cls`, `ProductSearcherControllerOtobaiTest.cls`, RT `Producto_Red_Motors` (picklist `Empresa__c`).
4. **Bloque:** 18.
5. **Estado:** Completado.
6. **Evidencia:** commit `37af27a`, merge `a623f54`; deploy real `0AfAK000000vuBx0AI` (4/4, 33/33 pruebas, 0 fallas); cobertura final 182/192 = 94.79 %.
7. **Riesgo pendiente:** ninguno propio — la rama `vehiculo`/`extra` de esta misma clase (fuera del alcance de mano de obra) no se tocó.
8. **Acción faltante:** ninguna para lo cerrado.
9. **Responsable de decisión:** No aplica.
10. **Confirmación:** la cobertura agregada (182/192) fue trabajo de calidad/pruebas, no funcionalidad nueva — se cuenta en Resumen C, no aquí.

### H.2 PDF/branding legal completo (razón social, logo, identificación fiscal)

1. **Fuente:** Manual de Análisis §7.4 (62 páginas `renderAs=PDF`, 48 con identidad/empresa/precios); PDF original, "Notas reunión 10 de julio": "Incluir el manejo de PDFs dinámicos para las nuevas marcas".
2. **Requerimiento:** `DocumentBrandingService`/`DocumentContext`, razón social/logo/identificación fiscal correctos por empresa en todos los documentos legales.
3. **Componentes:** `cT_QuotePDFEmail.cls`, `savePDFfile.cls`, 48 páginas Visualforce con identidad/empresa/precios.
4. **Bloque:** Ninguno.
5. **Estado:** Diferido / Pendiente decisión.
6. **Evidencia:** `PLAN_IMPLEMENTACION_SPRINT1.md` §5 (ambas clases marcadas "No"/"No" en S30/S44, "PDF diferido"); Manual de Análisis, riesgo R2 (crítico).
7. **Riesgo pendiente:** crítico según el propio Manual — "documento con razón social/logo equivocado" está clasificado como riesgo crítico (R2) sin control implementado todavía para PEKING.
8. **Acción faltante:** razón social, identificación tributaria, logo y términos aprobados de PEKING (decisión de negocio) antes de cualquier desarrollo.
9. **Responsable de decisión:** Luis/Diego — el Manual lo marca expresamente como pregunta pendiente #9 ("¿Cuáles son razón social, identificación fiscal, cuentas bancarias, términos y logos aprobados?").
10. **Confirmación:** no se generó ningún PDF ni identidad de marca para PEKING.

### H.3 Reservas (Quote y WorkOrder)

1. **Fuente:** PDF original §3; Manual de Análisis, Anexo A.1 (`servicioReservas`, `servicioEliminarReserva`, `ServicioConsDispBodegaQuoli`, `ServicioReservaApartadoArticulosQuote`, `ServicioEliminarReservaArticuloQuote`, etc.).
2. **Requerimiento:** Resolver empresa en cada operación de reserva/liberación/consulta de disponibilidad, sin binario Bavarian/Otobai.
3. **Componentes:** ~10 clases de reserva (Quote y WorkOrder).
4. **Bloque:** Ninguno.
5. **Estado:** Diferido.
6. **Evidencia:** `PLAN_IMPLEMENTACION_SPRINT1.md` §5, todas marcadas "No"/"Sí" o "No"/"No" según S30/S44 — ninguna llegó a ejecutarse en la práctica.
7. **Riesgo pendiente:** crítico — "reserva o bodega cruzada" (riesgo del `PLAN_IMPLEMENTACION_SPRINT1.md` y del Manual, R3) sigue sin control para PEKING.
8. **Acción faltante:** todo el trabajo de esta familia.
9. **Responsable de decisión:** Luis/Diego (alcance y prioridad).
10. **Confirmación:** no se tocó ninguna clase de reserva.

### H.4 Anticipos

1. **Fuente:** PDF original, tabla de Apex; Manual de Análisis, Anexo A.1 (`OpportunityServiceInvoker`, `Registrar_Anticipo_Controller`).
2. **Requerimiento:** Resolver empresa antes de registrar/consultar anticipos, sin fallback a Bavarian.
3. **Componentes:** `OpportunityServiceInvoker.cls`, `Registrar_Anticipo_Controller.cls`.
4. **Bloque:** Ninguno.
5. **Estado:** Diferido.
6. **Evidencia:** `PLAN_IMPLEMENTACION_SPRINT1.md` §5 (ambas "No" en S30, "Sí" en S44 — pero el S44 nunca se ejecutó para estas dos).
7. **Riesgo pendiente:** "anticipo en empresa equivocada" (riesgo financiero explícito del plan).
8. **Acción faltante:** todo el trabajo.
9. **Responsable de decisión:** Luis/Diego.
10. **Confirmación:** no se tocó ninguna de las dos clases.

### H.5 Integración Softland (contrato, códigos, batches de pedidos/catálogo)

1. **Fuente:** Manual de Análisis §7.7 (contrato debe incluir `Codigo_Empresa`, no `Name`); PDF original §3 y §9.
2. **Requerimiento:** Confirmar contrato Softland para PEKING (mismo endpoint o instancia distinta) y propagar el código de empresa explícito en cada integración.
3. **Componentes:** ~20 clases (`QuoteSoftlandPedidoService`, `HttpCalloutCreateKit`, `OrderBatch`, `RM_VN_CambiarUbicacion_Ctrl`, etc.).
4. **Bloque:** Ninguno.
5. **Estado:** Pendiente decisión (bloquea) → Diferido (ejecución).
6. **Evidencia:** Manual de Análisis, pregunta pendiente #4 ("¿Softland usa el mismo endpoint/contrato...?"); ninguna clase de esta familia aparece en ningún bloque cerrado.
7. **Riesgo pendiente:** crítico (R4 del Manual) — "Softland mezcla códigos/inventario" sin control para PEKING.
8. **Acción faltante:** respuesta de negocio/integración antes de cualquier desarrollo.
9. **Responsable de decisión:** Luis/Diego, con apoyo de integración.
10. **Confirmación:** no se tocó ninguna clase ni integración Softland real en todo el Sprint 1 (se verificó explícitamente en el Bloque 21 que `RM_VN_CambiarUbicacion_Ctrl` sí hace callout real y por eso quedó excluido).

---

## I. Flows

### I.1 Subflow común de resolución de empresa/Pricebook/moneda en Flows

1. **Fuente:** Manual de Análisis §7.2 ("Crear un subflow reutilizable que resuelva Empresa, lista de precios, moneda... Agregar fault paths").
2. **Requerimiento:** Ningún Flow debe caer en una rama Bavarian/Otobai binaria; debe existir manejo de fallo explícito.
3. **Componentes:** `Opportunity_Flow`, `Opp_flow_v4`, `Opp_Flow_V5`, `Opp_Flow_v6`, `BMW_ImportarPlantilla`, `Work_Order_from_Quote(_Selective)`, `ReciboUsadosFlow`, y ~9 más listados en el Anexo C del Manual (14 Flows dependientes de `Opportunity.BMW_Compania__c`).
4. **Bloque:** Ninguno.
5. **Estado:** Fuera de alcance (Sprint 1).
6. **Evidencia:** Manual de Análisis, Anexo C (14 Flows dependientes confirmados vía `MetadataComponentDependency`) y Anexo A.3 (47 Flows candidatos, con nota de que `Opp Flow V5`/`Opp Flow v6` tienen versiones activas distintas a la última local).
7. **Riesgo pendiente:** alto — ningún Flow fue modificado ni auditado en su versión activa durante este Sprint; el patrón binario documentado en el PDF original sigue exactamente igual.
8. **Acción faltante:** retrieve de la versión activa real de cada Flow (no solo la última localmente recuperada) y rediseño con subflow común — trabajo no iniciado.
9. **Responsable de decisión:** Luis/Diego (prioridad y alcance; no es una decisión de negocio en el sentido de "qué responder", sino de asignación de un bloque futuro).
10. **Confirmación:** ningún Flow fue creado, modificado ni desplegado en ningún bloque de este Sprint 1 — confirmado explícitamente también en el análisis de Bloque 21.

---

## J. Apex — resolución transversal restante

### J.1 Clases directas del `PLAN_IMPLEMENTACION_SPRINT1.md` no tocadas (`BusquedaDetalladaController`, `precioProductoJSON`, `productJSON`, `ProductoLocalizacionHelper`, `HttpCalloutGetProductRefPrices`/`Fresh`, `RM_Lead_Trigger_Helper`)

1. **Fuente:** `PLAN_IMPLEMENTACION_SPRINT1.md` §5 (matriz de 41 clases); Manual de Análisis, Anexo A.1.
2. **Requerimiento:** Resolver empresa/precio/bodega/integración en cada una, sin fallback.
3. **Componentes:** las 6 clases nombradas (representativas; hay más en la misma categoría, ver `MATRIZ_PENDIENTES_SPRINT1_20260726.md` de la rama de análisis previa).
4. **Bloque:** Ninguno.
5. **Estado:** Diferido / Fuera de alcance (según el caso — `RM_Lead_Trigger_Helper` es Pendiente decisión, propiedad de Bloque 20).
6. **Evidencia:** ninguna de estas 6 aparece en ningún commit del Sprint 1.
7. **Riesgo pendiente:** variable por clase; documentado individualmente en `PLAN_IMPLEMENTACION_SPRINT1.md` §5.
8. **Acción faltante:** todo el trabajo restante.
9. **Responsable de decisión:** Luis/Diego para priorización; `RM_Lead_Trigger_Helper` específicamente es propiedad de Codex/Bloque 20.
10. **Confirmación:** ninguna se tocó en este Sprint.

### J.2 Triggers de Account (`ChanceAccountBavarian`, `ChanceAccountContado`, `ChanceAccountOtobai`)

1. **Fuente:** `PLAN_IMPLEMENTACION_SPRINT1.md` §11.2; Manual de Análisis, Anexo A.2 (solo lista 2 de los 3; el PDF original lista los 4 con el discrepante `ChanceAccountOtobai` confirmado luego solo en sandbox).
2. **Requerimiento:** Determinar si las cuentas protegidas representan empresas facturadoras o cuentas técnicas antes de decidir cómo extenderlas a PEKING.
3. **Componentes:** los 3-4 triggers de Account.
4. **Bloque:** Ninguno.
5. **Estado:** Pendiente decisión.
6. **Evidencia:** `PLAN_IMPLEMENTACION_SPRINT1.md` §11.2 ("no se recomienda crear un trigger adicional para PEKING"; "decisión pendiente: confirmar si las cuentas son empresas facturadoras, cuentas técnicas protegidas o ambas").
7. **Riesgo pendiente:** si PEKING necesita protección de cuenta equivalente, hoy no la tiene.
8. **Acción faltante:** respuesta de Luis/Diego.
9. **Responsable de decisión:** Luis/Diego.
10. **Confirmación:** ningún trigger de Account fue modificado.

### J.3 `RM_VN_CrearOppModeloInteres_Ctrl` — Empresa Operadora desde modelo de interés

1. **Fuente:** `BITACORA_IMPLEMENTACION.md` §29 (Bloque 19).
2. **Requerimiento:** Asignar `Opportunity.Empresa_Operadora__c` al crear una Opportunity desde modelo de interés, mapeando marca→empresa explícitamente (incluyendo Omoda/Jaecoo→RMPEKING).
3. **Componentes:** `RM_VN_CrearOppModeloInteres_Ctrl.cls`, su test, `EmpresaResolver.resolveByCodigo`.
4. **Bloque:** 19.
5. **Estado:** Completado.
6. **Evidencia:** commits `fe432cd`, `a993eee`; merge `eede33e`; Deploy real `0AfAK000000vtnl0AA` (2/2 componentes, 48/48 pruebas, 0 fallas, según cierre técnico registrado en la bitácora).
7. **Riesgo pendiente:** la regresión externa (`RM_VN_CrearOportunidad_Ctrl_Test.test_createOpportunity_conTrafico`) que bloqueó inicialmente el deploy fue diagnosticada y corregida por separado (rama `fix/pc/redmotors-regression-traffic-test-20260726`), documentada en `DESFASE_GIT_PARTIAL_TEST_TRAFICO.md` — no forma parte de Bloque 19, es deuda externa preexistente.
8. **Acción faltante:** ninguna para Bloque 19 en sí; el hotfix de tráfico sigue preservado sin integrar (decisión ya tomada explícitamente: mantenerlo separado).
9. **Responsable de decisión:** No aplica para lo ya cerrado.
10. **Confirmación:** no se modificaron `Pricebook2Id`, `OpportunityLineItem`, tráfico, Account, Softland, reservas, inventario, permisos ni `ProductSearcherController` en este bloque (bitácora explícita).

---

## K. LWC / Aura

### K.1 Arrays hardcodeados `preciosBavarian`/`preciosFantasia` en LWC de inventario

1. **Fuente:** PDF original §5 y §10 ("productSearcher, rm_vn_crear_opp_inventario, rm_vn_inventario, rm_vn_inventario_movil: arrays hardcodeados... refactorizar para n compañías"); Manual de Análisis §7.3.
2. **Requerimiento:** El servidor debe devolver un DTO "company-aware"; el LWC no debe construir listas separadas por nombre de empresa.
3. **Componentes:** `productSearcher.js`, `rm_vn_crear_opp_inventario.js`, `rm_vn_inventario.js`, `rm_vn_inventario_movil.js`, `rm_vn_inventario_fantasia.js`.
4. **Bloque:** Ninguno (evaluado y descartado como candidato en el análisis previo de Bloque 18/coverage lab).
5. **Estado:** Diferido.
6. **Evidencia:** `MATRIZ_PENDIENTES_SPRINT1_20260726.md` (rama de análisis previa) — se descartó como candidato porque el repositorio no tiene ninguna infraestructura Jest (`0` archivos `*.test.js`, sin `jest.config.js`); agregar pruebas autocontenidas implicaría introducir infraestructura nueva, no un cambio acotado.
7. **Riesgo pendiente:** aunque `Product2.Empresa__c=RMPEKING` ya existe (Bloque 17) y `ProductSearcherController` ya resuelve mano de obra por empresa (Bloque 18), la UI de inventario de vehículos puede seguir sin mostrar PEKING si estos arrays no se generalizan.
8. **Acción faltante:** decidir si se invierte en infraestructura de pruebas Jest antes de tocar estos componentes, o si se acepta el riesgo y se modifica sin pruebas automatizadas (no recomendado).
9. **Responsable de decisión:** Luis/Diego (prioridad) más una decisión técnica sobre invertir en Jest.
10. **Confirmación:** no se modificó ningún LWC en ningún bloque de este Sprint.

### K.2 Componentes Aura de Community con rama Otobai embebida

1. **Fuente:** PDF original §5; Manual de Análisis §7.3 ("CommunityCalendar contiene opciones/IDs embebidos y una rama Otobai; debe usar ServiceTerritory relacionado a Empresa").
2. **Requerimiento:** Reemplazar la rama fija por relación a `Empresa__c`/`ServiceTerritory`.
3. **Componentes:** `CommunityCalendar`, `CommunityControl`, `CommunityMenu`, `customerCommunity_lwc`, `callcenterCommunity_lwc`.
4. **Bloque:** Ninguno.
5. **Estado:** Fuera de alcance (agenda/sucursales/territorios, explícitamente excluido de todos los criterios de autonomía usados en Bloques 18/20/21).
6. **Evidencia:** ningún commit los toca.
7. **Riesgo pendiente:** portal/community sigue sin ruta para PEKING.
8. **Acción faltante:** todo el trabajo, condicionado a la decisión de si PEKING comparte o no Experience Cloud (pregunta pendiente #6 del Manual).
9. **Responsable de decisión:** Luis/Diego.
10. **Confirmación:** no se tocó ningún componente Aura de Community.

---

## L. Perfiles / permisos y separación de información por empresa

### L.1 Seguridad completa (OWD, sharing rules, Experience Cloud) por empresa

1. **Fuente:** Manual de Análisis §7.6 y Anexo E ("El modelo de acceso impide visibilidad cruzada no autorizada, incluso en Experience Cloud").
2. **Requerimiento:** Definir OWD y sharing por `Empresa__c`; `Usuario_Empresa__c` para pertenencia real.
3. **Componentes:** OWD de objetos núcleo, sharing rules, `Usuario_Empresa__c` (no existe).
4. **Bloque:** Ninguno (Bloque 8 solo replicó *field-level permissions*, no sharing).
5. **Estado:** Fuera de alcance (Sprint 1).
6. **Evidencia:** `PLAN_IMPLEMENTACION_SPRINT1.md` §13 ("sharing y permisos: `ReadWrite` y asignaciones siguen pendientes"); Manual de Análisis, riesgo R3 (crítico, "datos visibles entre empresas").
7. **Riesgo pendiente:** crítico — sin este control, no hay garantía técnica de que un usuario de PEKING no vea datos de Bavarian/Otobai o viceversa.
8. **Acción faltante:** diseño de modelo de sharing — no iniciado.
9. **Responsable de decisión:** Luis/Diego (alcance de seguridad, tratado explícitamente como decisión de arquitectura en el Manual, no como tarea técnica lista).
10. **Confirmación:** no se creó ningún sharing rule, OWD ni modelo de acceso nuevo — coherente con la instrucción reiterada en todos los bloques de "no crear seguridad nueva".

### L.2 Perfiles/Permission Sets específicos de marca para Omoda/Jaecoo

1. **Fuente:** PDF original §8 ("35 profiles ya tienen nombre de marca... Existe otra tarea para simplificar la forma en que trabajan los perfiles por marca").
2. **Requerimiento:** Confirmar si Omoda/Jaecoo necesitan un perfil o Permission Set dedicado, replicando el patrón de marca existente.
3. **Componentes:** Perfiles con nombre de marca (`Asesor de Ventas BMW`, etc.), `Vehiculos_Nuevos_PS`.
4. **Bloque:** 17 cubrió únicamente `Vehiculos_Nuevos_PS` (recordTypeVisibilities); ningún perfil nuevo de marca fue creado.
5. **Estado:** Pendiente decisión.
6. **Evidencia:** el propio PDF advierte que existe "otra tarea" de simplificación de perfiles en curso, cuyo resultado condiciona si conviene crear perfiles nuevos ahora o esperar.
7. **Riesgo pendiente:** los vendedores de PEKING podrían no tener hoy un perfil dedicado con la configuración correcta (más allá de la visibilidad de Record Type ya cubierta en `Vehiculos_Nuevos_PS`).
8. **Acción faltante:** decisión de Luis/Diego sobre si crear perfiles de marca para Omoda/Jaecoo ahora o esperar la simplificación de perfiles mencionada.
9. **Responsable de decisión:** Luis/Diego.
10. **Confirmación:** no se creó ningún perfil ni Permission Set nuevo de marca — solo se reutilizó y extendió `Vehiculos_Nuevos_PS` (Bloque 17) y se replicaron field permissions existentes (Bloque 8), sin inventar seguridad nueva.

### L.3 Reconciliación RedPartial ↔ redProd

1. **Fuente:** Manual de Análisis §8 ("RedPartial no debe tomarse como línea base hasta reconciliarlo... 46 diferentes y 7 ausentes").
2. **Requerimiento:** Congelar ventana de cambios y reconciliar diferencias antes de construir sobre RedPartial.
3. **Componentes:** Todo el espejo local vs. `redProd`.
4. **Bloque:** Ninguno formal, pero el desfase se documentó puntualmente en `DESFASE_GIT_PARTIAL_TEST_TRAFICO.md` para un caso concreto (`RM_VN_CrearOportunidad_Ctrl_Test`).
5. **Estado:** Pendiente técnico (parcial).
6. **Evidencia:** `DESFASE_GIT_PARTIAL_TEST_TRAFICO.md` (un caso resuelto); el Manual reporta 46 diferencias y 7 ausencias a nivel de todo el proyecto, de las cuales solo una fue investigada y corregida en este Sprint.
7. **Riesgo pendiente:** alto — quedan potencialmente ~45 diferencias sin investigar entre el espejo local y `redProd`/Partial, cualquiera de las cuales podría repetir el mismo patrón de sorpresa que el caso de tráfico.
8. **Acción faltante:** reconciliación sistemática completa (fuera del alcance práctico de un Sprint de 44 horas, según el propio Manual).
9. **Responsable de decisión:** Luis/Diego (asignar tiempo dedicado a esta reconciliación).
10. **Confirmación:** no se hizo ninguna reconciliación masiva; solo se documentó el caso puntual ya resuelto.

---

## Resumen A — Requerimientos explícitos completados

1. Objeto `Empresa__c` con campos mínimos (Bloque 1).
2. `EmpresaResolver`/`EmpresaContext`/`EmpresaConfigurationException` fail-closed (Bloque 1).
3. Permission Set `Empresa_Admin` (Bloque 1).
4. Código `RMPEKING` y marcas Omoda/Jaecoo confirmados por Diego.
5. Pricebooks `PEKING Local`/`PEKING Dólares` creados y activos.
6. `BMW_ChangeCurrencyWOWOLI` con soporte PEKING (Bloque 2).
7. `QuoteController` sin default a Bavarian (Bloque 2).
8. `UpdateCurrencyScheduler` con las 6 combinaciones (Bloque 3).
9. `WorkOrder.empresaFacturaCP__c` + `WorkOrderTrigger` con 3 empresas (Bloques 4-5).
10. Corrección `Garantía`/`Garantia` en `WorkOrderTrigger` (Bloque 5).
11. `Opportunity.Empresa_Operadora__c` + `ProductControllerTwo` (Bloque 6).
12. `CrearPlandeVenta` propaga `Empresa_Operadora__c` (Bloque 7).
13. Réplica de permisos en 146 perfiles (Bloque 8).
14. `BMW_LineaPlantillaEmpresa` sin default a Otobai (Bloque 9).
15. `cT_QuoteUsdPDFController`/`cT_QuoteCrcPDFController` con PEKING (Bloques 11-12).
16. `TrabajoQuoteController` (Bloque 13).
17. `TrabajoController` (Bloque 14).
18. `BMWVinScanTrabajoGenerator` (Bloque 15).
19. `QuoterController` (Bloque 16).
20. Record Types `Opportunity.Omoda`/`Opportunity.Jaecoo` + `Product2.Empresa__c=RMPEKING` (Bloque 17).
21. `ProductSearcherController` mano de obra por empresa (Bloque 18).
22. `RM_VN_CrearOppModeloInteres_Ctrl` Empresa Operadora desde modelo de interés (Bloque 19).

**Total: 22 requerimientos explícitos completados y desplegados**, todos con Deploy ID confirmado en `BITACORA_IMPLEMENTACION.md`.

## Resumen B — Requerimientos explícitos todavía pendientes

**Pendiente decisión (Luis/Diego):**
- Anomalía `Lead.BMW → Opportunity.Polaris`.
- Alcance de "usados" en Lead/tráfico.
- Comportamiento final de `empresaFacturaCP__c` ante empresa vacía (`WorkOrderTrigger` vs. patrón fail-closed).
- Semántica y FLS de `Quote.empresaFactura__c`.
- Contrato Softland para PEKING (mismo endpoint o instancia distinta).
- Alcance de branding legal/PDF (razón social, identificación fiscal, logo).
- Propósito funcional de los triggers de Account.
- Perfiles/Permission Sets dedicados de marca para Omoda/Jaecoo.
- Modelo relacional completo (Producto_Empresa, Bodega.Empresa, Usuario_Empresa, Sucursal/Territory).
- Seguridad completa (OWD, sharing, Experience Cloud) por empresa.

**Pendiente técnico (sin decisión de negocio, pero sin cerrar):**
- Experiencia declarativa de Opportunity (Layouts/LRP/List Views/Quick Actions) para Omoda/Jaecoo — no hay artefacto local que replicar.
- Reconciliación completa RedPartial ↔ redProd (46 diferencias, 7 ausencias, solo 1 caso investigado).

**En progreso:**
- Lead/Tráfico PEKING (Bloque 20, Codex): implementado localmente, sin dry-run/deploy.

**Diferido (fuera del presupuesto de 44 horas, sin decisión bloqueante pero sin ejecutar):**
- Reservas (~10 clases).
- Anticipos (2 clases).
- Batches/schedulers Softland de catálogo (9 componentes).
- Integración Softland general (~20 componentes).
- Flows (14 dependientes confirmados + 33 más candidatos).
- LWC/Aura de inventario y Community (9+ componentes).
- `Order.empresaQueFactura__c` y sus consumidores.
- PDF/branding legal completo.

## Resumen C — Trabajo técnico adicional realizado únicamente para calidad, pruebas, respaldo o documentación

Esto **no se cuenta como funcionalidad nueva** en los totales de A/B:

- Cobertura ampliada de `ProductSearcherController` de 73.438 % a 94.79 % (Bloque 18, laboratorio de cobertura).
- Corrección de la clase de test huérfana `ProductSearcherControllerOtobaiTest` (realineación de firma, Bloque 18).
- Documentación de desfase Git↔Partial (`DESFASE_GIT_PARTIAL_TEST_TRAFICO.md`).
- Matriz de pendientes previa (`MATRIZ_PENDIENTES_SPRINT1_20260726.md`).
- Análisis de Bloque 21 sin cambio (`IMPLEMENTACION_BLOQUE21_OPORTUNIDAD_UI.md`).
- Ramas de respaldo (`backup/pc/redmotors-before-bloque18...`, `backup/pc/redmotors-before-bloque19...`, `backup/pc/redmotors-sprint1-before-opportunity...`, etc.).
- Worktrees de análisis aislados (Bloque 18 coverage lab, pendientes Sprint 1, este mismo de trazabilidad).
- Reconstrucción de `RM_Lead_Trigger_Helper_Test` con aserciones reales (Bloque 20, en progreso — parte del propio Bloque 20, no una funcionalidad adicional del alcance).
- Este mismo documento de trazabilidad.

---

## Cifras finales (calculadas desde esta matriz)

Conteo de requerimientos únicos identificados y clasificados en esta matriz
(no de archivos individuales — un requerimiento puede afectar varios
componentes):

| Estado | Cantidad |
|---|---:|
| Completado | 22 |
| En progreso | 1 (Lead/Tráfico PEKING, Bloque 20) |
| Pendiente técnico | 2 (experiencia declarativa Opportunity; reconciliación RedPartial) |
| Pendiente decisión | 10 |
| Diferido | 8 |
| **Total de requerimientos únicos identificados** | **43** |

**Porcentaje calculado desde esta matriz:** 22 / 43 = **51.16 % completado** por
conteo de requerimientos únicos (no por líneas de código ni por horas).

### Diferencia frente al estimado interno de 86 % / 14 %

El 86 % (o 85 %, según el cierre más reciente de Bloque 18) registrado en
`BITACORA_IMPLEMENTACION.md` es una **estimación de alcance técnico
acumulado sobre los bloques efectivamente trabajados**, no una fracción del
inventario completo de requerimientos de los dos documentos de origen. Esta
matriz mide algo distinto: la fracción de **todos** los requerimientos
explícitos detectados en el PDF original y en el Manual de Análisis técnico
(incluyendo Softland, reservas, anticipos, seguridad completa, Flows,
LWC/Aura, PDF/branding, y el modelo relacional completo), muchos de los
cuales nunca estuvieron dentro del presupuesto de 44 horas aprobado.

La diferencia (86 % de "lo trabajado" frente a 51 % de "todo lo pedido") no es
una contradicción: ambas cifras son correctas para lo que miden. El propio
`PLAN_IMPLEMENTACION_SPRINT1.md` ya advertía esto explícitamente: *"Las 41
clases son el alcance técnico directo confirmado. Los escenarios de 30 y 44
horas son subconjuntos ejecutables, no una redefinición del hallazgo."* El 86%
mide el avance del subconjunto ejecutable ya iniciado; el 51% de esta matriz
mide el avance contra el hallazgo completo del Manual de Análisis, que es
sustancialmente más amplio que el subconjunto de 44 horas.

## Puntos que pudimos haber omitido o interpretado de forma incompleta

- El Manual de Análisis identifica **campos homónimos** (`Contact.Empresa__c`,
  `Account.Empresas__c`, `Maestro_de_Errores__c.Empresa__c`) como falsos
  positivos explícitos — se excluyeron correctamente de esta matriz, pero se
  documentan aquí para que quede constancia de que **no fueron omitidos por
  descuido**, sino por clasificación explícita de la fuente.
- El Anexo B del Manual (78 permission sets, 50 profiles candidatos) no se
  trazó componente por componente — se resumió temáticamente (L.1/L.2) porque
  hacerlo a nivel de archivo individual (128 filas adicionales) excedería el
  propósito de una matriz de requerimientos y duplicaría el detalle ya
  existente en el propio Manual, Anexo B.
- No pudimos confirmar con evidencia local si la clase `Quote.empresaFactura__c`
  fue tocada o no fuera de este Sprint — se documentó como pendiente de
  decisión (F.4) en vez de asumir que está fuera de alcance.
- El estado del Bloque 20 (Lead/Tráfico) puede cambiar entre el momento de
  esta matriz y su lectura, porque es trabajo en curso de Codex en una rama
  separada que esta tarea no debía tocar ni adelantar.
- No se intentó recalcular el 86%/14% desde cero por bloque individual
  (habría requerido reconstruir la métrica original línea por línea de la
  bitácora); en su lugar se explica la diferencia metodológica, que es la
  pregunta real detrás del punto solicitado.

## Confirmación de alcance de esta tarea

No se ejecutó Salesforce CLI, no se consultó ningún org, no se modificó
código ni metadata, no hubo deploy. No se tocaron las ramas de Bloques 18, 19,
20 ni 21 (solo se leyó su documentación ya publicada, sin modificarla). No se
eliminó ningún worktree.
