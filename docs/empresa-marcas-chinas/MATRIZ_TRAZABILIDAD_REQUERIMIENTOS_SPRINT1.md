# Matriz maestra de trazabilidad — Sprint 1 Empresa / Marcas Chinas

Worktree: `C:\Users\dokur\Documents\Repositorios\RedMotors-Sprint1-Trazabilidad`
Rama: `analysis/pc/redmotors-empresa-marcas-chinas-sprint1-trazabilidad-20260726`
Base de la rama: `origin/feature/pc/redmotors-empresa-marcas-chinas-sprint1-20260724` @ `a623f54`

**Actualización 26/07/2026:** `sprint1` avanzó desde `a623f54` hasta `c8b89fb`
(commits `1d83228` → `f8155f4` merge → `c8b89fb`), incorporando el cierre real
del Bloque 20. Esta actualización se hizo leyendo esa evidencia directamente
del historial de `git` y de `BITACORA_IMPLEMENTACION.md` en `sprint1`
(`git show c8b89fb:docs/...`), sin adelantar la rama de esta matriz ni tocar
la rama de Bloque 20.

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
| `IMPLEMENTACION_BLOQUE20_LEAD_PEKING.md` y `BITACORA_IMPLEMENTACION.md` §31 en `sprint1` @ `c8b89fb` | Cierre real del Bloque 20 (deploy, regresión, Test Run) |
| `IMPLEMENTACION_BLOQUE21_OPORTUNIDAD_UI.md` | Cierre real del Bloque 21: experiencia declarativa de Opportunity Omoda/Jaecoo desplegada |
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
3. **Componentes:** `Opportunity_Record_Page_VN` (FlexiPage), 8 List Views de Opportunity para Omoda/Jaecoo.
4. **Bloque:** 21.
5. **Estado:** Completado.
6. **Evidencia:** commit `67c180b` (`feat(opportunity-ui): add Omoda and Jaecoo declarative experience`), merge a `sprint1` `52e1ef1`; dry-run declarativo `0AfAK000000vtcU0AQ` (9/9 componentes, 0 fallas); deploy real `0AfAK000000vuTh0AI` (9/9 componentes, 0 fallas, `Succeeded`); verificación post-deploy de 8 List Views y `Opportunity_Record_Page_VN`.
7. **Riesgo pendiente:** ninguno propio del bloque desplegado; decisiones futuras de sucursales/territorios/visibilidad comercial PEKING quedan fuera del Sprint 1.
8. **Acción faltante:** ninguna para el alcance de Sprint 1.
9. **Responsable de decisión:** No aplica.
10. **Confirmación:** no se creó ninguna List View, Layout ni Quick Action inventada sin patrón local verificable — todo se copió del patrón BMW ya existente, confirmado en el propio documento del bloque.

---

## C. Lead / Potencial

### C.1 Record Types `Lead.Omoda` y `Lead.Jaecoo` + mapeo Lead→Opportunity

1. **Fuente:** `PENDIENTES_DECISION_BLOQUE20.md` (preguntas 1-3); PDF original §2 ("Lead: Replicar 2 RT nuevos... para que el mapeo Lead→Opportunity funcione").
2. **Requerimiento:** Record Types de Lead para Omoda/Jaecoo y su mapeo a los Record Types de Opportunity ya existentes.
3. **Componentes:** `Lead.Omoda`, `Lead.Jaecoo`, `RM_RecordTypeMapping.Lead_Omoda_to_Opp`, `RM_RecordTypeMapping.Lead_Jaecoo_to_Opp`, `RM_Lead_Trigger_Helper_Test`.
4. **Bloque:** 20 (Codex).
5. **Estado:** Completado.
6. **Evidencia:** commit `1d83228` (`feat(lead): add PEKING traffic mappings`); merge a `sprint1` en `f8155f4`; `BITACORA_IMPLEMENTACION.md` §31 (`sprint1` @ `c8b89fb`). Validación: dry-run enfocado `0AfAK000000vuNF0AY` (5/5, 3/3, 0 fallas); regresión seleccionada `0AfAK000000vuOr0AI` (5/5, **53/53**, 0 fallas); deploy real `0AfAK000000vuQT0AY` (5/5, 53/53, 0 fallas, Succeeded); verificación post-deploy Test Run `707AK00000GxONW` (3/3, 0 fallas). `Lead.Omoda` y `Lead.Jaecoo` confirmados activos; mappings `Lead.Omoda→Opportunity.Omoda` y `Lead.Jaecoo→Opportunity.Jaecoo` confirmados activos.
7. **Riesgo pendiente:** ninguno propio — el único riesgo detectado (anomalía `Lead.BMW→Opportunity.Polaris`) es preexistente y se documenta aparte en C.2, no se introdujo ni se corrigió en este bloque.
8. **Acción faltante:** ninguna para lo cerrado.
9. **Responsable de decisión:** No aplica (ya cerrado; la autonomía para ejecutarlo ya la había dado Luis: "dale tú sin miedo a los ajustes").
10. **Confirmación:** no se modificó `Lead.BMW→Opportunity.Polaris`, `RM_Config__mdt` ni la lógica productiva de `RM_Lead_Trigger_Helper`; no se tocaron Softland, reservas, anticipos, finanzas, branding, sucursales, Flows, LWC, layouts ni permisos — confirmado en `BITACORA_IMPLEMENTACION.md` §31.

### C.2 Anomalía `Lead.BMW` → `Opportunity.Polaris`

1. **Fuente:** `IMPLEMENTACION_BLOQUE20_LEAD_PEKING.md`, evidencia técnica ("La configuración BMW → Polaris se documenta como anomalía existente").
2. **Requerimiento implícito:** confirmar si el mapeo `Lead.BMW → Opportunity.Polaris` es correcto o es un error de configuración heredado.
3. **Componentes:** `RM_RecordTypeMapping__mdt` (registro existente, no tocado).
4. **Bloque:** Detectado en 20, no corregido.
5. **Estado:** Pendiente decisión.
6. **Evidencia:** `PENDIENTES_DECISION_BLOQUE20.md`, pregunta 4 ("¿El mapping actual BMW → Polaris es correcto?"); reconfirmado en el cierre real del bloque (`BITACORA_IMPLEMENTACION.md` §31, `sprint1` @ `c8b89fb`): "`Lead_BMW_to_Opp` apunta actualmente a `Opportunity.Polaris`... se documenta como anomalía existente y no se modifica en este bloque."
7. **Riesgo pendiente:** si es un error, Leads de marca BMW se están convirtiendo hoy en Opportunities de Polaris — un riesgo funcional real, ajeno a este Sprint. No hay ningún registro local (Custom Metadata no versionado, sin comentarios ni historial) que revele si fue intencional o un error de captura.
8. **Acción faltante:** confirmación de Luis/Diego sobre si corregir. No es resoluble por evidencia: no existe un único patrón técnico que indique intención — se mantiene como Pendiente decisión tras revisión explícita.
9. **Responsable de decisión:** Luis/Diego.
10. **Confirmación:** no se tocó este mapeo en ningún bloque, incluyendo el cierre real del Bloque 20.

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
6. **Evidencia:** análisis `ANALISIS_QUOTE_EMPRESA_FACTURA.md`: `Quote.empresaFactura__c` existe como fórmula `TEXT(Opportunity.empresaQueFactura__c)`; `Opportunity.empresaQueFactura__c` es picklist restringido con valores `Bavarian` y `Otobay`; `Quote.Compania__c` es picklist restringido con `Bavarian` y `Otobai`; consumidores aparecen en Flows, búsquedas y procesos relacionados con órdenes/integraciones.
7. **Riesgo pendiente:** cambiar la fórmula o el picklist heredado puede impactar Flows y procesos existentes; además existe discrepancia `Otobay`/`Otobai`.
8. **Acción faltante:** decidir si `empresaQueFactura__c` se mantiene, se migra hacia `Empresa_Operadora__c`, se retira o se corrige como compatibilidad heredada.
9. **Responsable de decisión:** Luis/Diego.
10. **Confirmación:** no se modificó Quote, Opportunity, Apex, Flow ni metadata funcional; solo se documentó el bloqueo.

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
5. **Estado:** Pendiente decisión — depende del mismo dato/contrato externo que H.5 y J.1b, no de prioridad de agenda (recategorizado en esta actualización para no mezclarlo con trabajo diferido por presupuesto).
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
5. **Estado:** Pendiente decisión (el bloqueo primario es la falta de datos legales aprobados, no solo presupuesto de horas).
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
5. **Estado:** Pendiente decisión — depende de dato/proveedor externo (contrato Softland), no de una preferencia interna de Luis/Diego.
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

### J.1a `BusquedaDetalladaController` y `precioProductoJSON` — selección de Pricebook por nombre, sin integración externa

1. **Fuente:** `PLAN_IMPLEMENTACION_SPRINT1.md` §5 (matriz de 41 clases); Manual de Análisis, Anexo A.1.
2. **Requerimiento:** Reemplazar el filtro `Bavarian%`/`Otobai%` por selección basada en relación/código de empresa — exactamente el mismo patrón ya aplicado en `QuoteController`, `QuoterController` y `BMW_LineaPlantillaEmpresa`.
3. **Componentes:** `BusquedaDetalladaController.getActivePricebooks()`, `precioProductoJSON`.
4. **Bloque:** Ninguno.
5. **Estado:** Pendiente decisión.
6. **Evidencia:** `IMPLEMENTACION_BLOQUE10_BUSQUEDA_DETALLADA.md` y bitácora §33: `BusquedaDetalladaController` depende de `User.Sucursal__c` y nombres fijos de sucursal/territorio; en Partial no se encontraron usuarios, sucursales ni `ServiceTerritory` PEKING/Omoda/Jaecoo. `precioProductoJSON` usa convenciones distintas de llave de producto para Bavarian (`Codigo_de_Producto__c`) y Otobai (`CodigoProductoInterno__c` compuesto); en Partial no se encontraron productos ni `PricebookEntry` PEKING/Omoda/Jaecoo.
7. **Riesgo pendiente:** alto si se inventa una regla; podría exponer Pricebooks/territorios incorrectos o actualizar productos con una llave de integración equivocada.
8. **Acción faltante:** definir relación sucursal/empresa/Pricebook/Service Territory para PEKING y la llave de producto RMPEKING/Softland.
9. **Responsable de decisión:** Luis/Diego y, para la llave de producto, el contrato/proceso Softland correspondiente.
10. **Confirmación:** no se modificó código productivo ni se integraron pruebas de caracterización que congelaran comportamientos defectuosos.

### J.1b `productJSON`, `ProductoLocalizacionHelper`, `HttpCalloutGetProductRefPrices`/`Fresh` — integración Softland real

1. **Fuente:** `PLAN_IMPLEMENTACION_SPRINT1.md` §5; Manual de Análisis, Anexo A.1 y A.3.1 (nombres con `HttpCallout`, "construcción de request" a Softland).
2. **Requerimiento:** Resolver empresa/bodega antes de cada consulta/callout de precios o localización.
3. **Componentes:** `productJSON.cls`, `ProductoLocalizacionHelper.cls`, `HttpCalloutGetProductRefPrices.cls`, `HttpCalloutGetProductFreshRefPrices.cls`.
4. **Bloque:** Ninguno.
5. **Estado:** Pendiente decisión — depende del mismo dato/contrato externo que H.5 (Softland), no de prioridad de agenda.
6. **Evidencia:** `INVENTARIO_APEX_SPRINT1.md` §7.4 y §6.4 confirman que las cuatro hacen callout o construyen payload de integración real, a diferencia de J.1a.
7. **Riesgo pendiente:** crítico (mismo R4 del Manual) — no resoluble sin confirmar el código/contrato ERP de PEKING.
8. **Acción faltante:** ver H.5 — comparten el mismo bloqueo.
9. **Responsable de decisión:** Luis/Diego, con apoyo de integración (mismo que H.5).
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

## Corrección aplicada en esta actualización (Fase 1)

La entrega anterior declaraba **Total: 39** pero sus propios estados
(23+3+9+5+4) sumaban **44**. Causa raíz: el "Resumen A" listaba 23 puntos
narrativos que **no correspondían 1:1** con las secciones `### ID` reales —
algunas secciones (p. ej. `E.1`, que cubre Bloques 4 y 5 en una sola fila)
se describían con dos bullets narrativos distintos en el resumen, inflando
el conteo textual sin que existiera una segunda fila real. La causa no fue
una recategorización de contenido: fue que los resúmenes se redactaban de
forma narrativa en vez de derivarse mecánicamente de las filas.

**Corrección de método:** a partir de ahora, la única fuente de verdad es la
**Tabla de control** de abajo, construida programáticamente leyendo el campo
`5. **Estado:**` de cada una de las secciones `### ID` del documento. Todos
los resúmenes narrativos siguientes se derivan de esa tabla, no al revés.

También se incorpora en esta corrección el cierre real de `B.4`
(Bloque 21): se desplegó la experiencia declarativa de Omoda/Jaecoo
(FlexiPage + 8 List Views, commit `67c180b`, dry-run
`0AfAK000000vtcU0AQ`, deploy `0AfAK000000vuTh0AI`). `B.4` pasa a
**Completado** — ver el detalle en su propia sección más arriba.

## Tabla de control (fuente única de verdad — 39 filas, 1 estado exclusivo cada una)

| ID | Estado | Bloque | Evidencia (resumen) |
|---|---|---|---|
| A.1 | Completado | 1 | Commit `7f8b919`; Deploy `0AfAK000000vhrR0AQ` |
| A.2 | Completado | 1 | Commit `7f8b919`; Deploy `0AfAK000000vhrR0AQ` |
| A.3 | Completado | 1 | Commit `cc1614c`; Deploy `0AfAK000000viHF0AY` |
| A.4 | Completado | Decisión previa a Bloque 2 | `BITACORA` §4, hito 6 (Diego) |
| A.5 | Completado | 2 (datos) | `PEKING Local`/`PEKING Dólares` activos en Sandbox |
| A.6 | Diferido | Ninguno | Manual §5.2/Anexo E — Opción B/C, sin asignar |
| B.1 | Completado | 6 | Commit `ae6e0e6` |
| B.2 | Completado | 8 | Commit `a137b19`; dry-run `0AfAK000000vouX0AQ` |
| B.3 | Completado | 17 | Commit `2e1c733`; deploy `0AfAK000000vrNl0AI` |
| B.4 | Completado | 21 | Commit `67c180b`; dry-run `0AfAK000000vtcU0AQ`; deploy `0AfAK000000vuTh0AI` |
| C.1 | Completado | 20 | Commit `1d83228`; deploy `0AfAK000000vuQT0AY`, regresión 53/53 |
| C.2 | Pendiente decisión | Detectado en 20, no corregido | `BITACORA` §31 — anomalía documentada, sin corregir |
| C.3 | Pendiente decisión | Ninguno | `PENDIENTES_DECISION_BLOQUE20.md` pregunta 5 |
| D.1 | Fuera de alcance | Ninguno | Nunca asignado; Softland real |
| E.1 | Completado | 4 y 5 | Commits `67410e3`, `b427ab6`; deploys `...vnon0AA`, `...vo4v0AA` |
| E.2 | Pendiente decisión | Detectado en análisis de Bloque 21 | `IMPLEMENTACION_BLOQUE21...md` Fase 5 |
| E.3 | Completado | 13 y 14 | Commits `57d1880`, `2f8a923` |
| E.4 | Completado | 15 | Commit `1b9e859` |
| F.1 | Completado | 2 | Commit `9669237`; deploy `0AfAK000000vlTd0AI` |
| F.2 | Completado | 16 | Commit `3e7232a` |
| F.3 | Completado | 11 y 12 | Commits `4b127b3`, `86ab781` |
| F.4 | Pendiente decisión | Ninguno | Fórmula heredada desde `Opportunity.empresaQueFactura__c`; requiere definición funcional |
| G.1 | Completado | 2 y 3 | Commits `9669237`, `2d5fab4`; deploy `0AfAK000000vllN0AQ` |
| G.2 | Pendiente decisión | Ninguno | Bloqueo externo Softland, igual que H.5 |
| H.1 | Completado | 18 | Commit `37af27a`; deploy `0AfAK000000vuBx0AI` |
| H.2 | Pendiente decisión | Ninguno | Manual Anexo E pregunta 9 — datos legales |
| H.3 | Diferido | Ninguno | Plan S30/S44, sin ejecutar |
| H.4 | Diferido | Ninguno | Plan S30/S44, sin ejecutar |
| H.5 | Pendiente decisión | Ninguno | Manual pregunta pendiente 4 — contrato Softland |
| I.1 | Fuera de alcance | Ninguno | Nunca asignado a Sprint 1 |
| J.1a | Pendiente decisión | Ninguno | Bloque 10 reclasificado por dependencia sucursal/territorio y llave de producto |
| J.1b | Pendiente decisión | Ninguno | Mismo bloqueo externo que H.5 |
| J.2 | Pendiente decisión | Ninguno | `PLAN_IMPLEMENTACION_SPRINT1.md` §11.2 |
| J.3 | Completado | 19 | Commits `fe432cd`, `a993eee`; deploy `0AfAK000000vtnl0AA` |
| K.1 | Diferido | Ninguno | Sin infraestructura Jest en el repo |
| K.2 | Fuera de alcance | Ninguno | Agenda/sucursales/territorios, excluido en 18/20/21 |
| L.1 | Fuera de alcance | Ninguno | Manual Opción B/C — arquitectura, no Sprint 1 |
| L.2 | Pendiente decisión | 17 tocó solo `Vehiculos_Nuevos_PS` | Decisión de tiempo, ligada a otra iniciativa |
| L.3 | Pendiente técnico | Ninguno | `DESFASE_GIT_PARTIAL_TEST_TRAFICO.md` — 1 de 46 casos investigado |

**Verificación de la tabla:** 39 filas, 39 IDs únicos, un estado exclusivo
por fila. Conteo por estado (recuento directo de la columna Estado):
Completado = 19, En progreso = 0, Pendiente técnico = 1, Pendiente decisión
= 11, Diferido = 4, Fuera de alcance = 4. **19+0+1+11+4+4 = 39.**

## Resumen A — Requerimientos completados (19, derivado de la tabla)

1. `Empresa__c` con campos mínimos — A.1 (Bloque 1).
2. `EmpresaResolver`/`EmpresaContext`/`EmpresaConfigurationException` — A.2 (Bloque 1).
3. Permission Set `Empresa_Admin` — A.3 (Bloque 1).
4. Código `RMPEKING` y marcas Omoda/Jaecoo confirmados — A.4.
5. Pricebooks `PEKING Local`/`PEKING Dólares` — A.5 (Bloque 2).
6. `Opportunity.Empresa_Operadora__c` + `ProductControllerTwo` — B.1 (Bloque 6).
7. Réplica de permisos en 146 perfiles — B.2 (Bloque 8).
8. Record Types `Opportunity.Omoda`/`Jaecoo` + `Product2.Empresa__c=RMPEKING` — B.3 (Bloque 17).
9. Experiencia declarativa de Opportunity Omoda/Jaecoo — B.4 (Bloque 21).
10. `Lead.Omoda`/`Lead.Jaecoo` + mapeos `RM_RecordTypeMapping` — C.1 (Bloque 20).
11. `WorkOrder.empresaFacturaCP__c` + `WorkOrderTrigger` (3 empresas, fix Garantía) — E.1 (Bloques 4-5).
12. `TrabajoController`/`TrabajoQuoteController` — E.3 (Bloques 13-14).
13. `BMWVinScanTrabajoGenerator` — E.4 (Bloque 15).
14. `QuoteController` sin default a Bavarian — F.1 (Bloque 2).
15. `QuoterController` — F.2 (Bloque 16).
16. `cT_QuoteUsdPDFController`/`cT_QuoteCrcPDFController` — F.3 (Bloques 11-12).
17. `BMW_ChangeCurrencyWOWOLI` + `UpdateCurrencyScheduler` — G.1 (Bloques 2-3).
18. `ProductSearcherController` mano de obra por empresa — H.1 (Bloque 18).
19. `RM_VN_CrearOppModeloInteres_Ctrl` — J.3 (Bloque 19).

**Total: 19 requerimientos completados y desplegados**, todos con Deploy ID
confirmado en `BITACORA_IMPLEMENTACION.md`.

## Resumen B — Requerimientos pendientes, separados por tipo de bloqueo

### Dentro del Sprint 1 comprometido, aún no cerrado (0)

No quedan requerimientos pendientes dentro del Sprint 1 comprometido.

### Fuera del Sprint 1 comprometido — nunca fueron parte del subconjunto de 44 horas (20)

**Pendiente técnico — investigación, no decisión de negocio (1):**
- L.3 Reconciliación RedPartial↔redProd — 1 de 46 diferencias investigada.

**Pendiente decisión — comercial, proveedor o dato externo (11):**
- C.2 anomalía `Lead.BMW→Opportunity.Polaris`.
- C.3 alcance de "usados" en Lead/tráfico.
- E.2 comportamiento de `empresaFacturaCP__c` ante empresa vacía.
- F.4 `Quote.empresaFactura__c` — fórmula heredada y discrepancia `Otobay`/`Otobai`.
- G.2 batches/schedulers Softland de catálogo.
- H.2 branding legal/PDF.
- H.5 contrato Softland para PEKING.
- J.1a `BusquedaDetalladaController`/`precioProductoJSON` — sucursal/territorio y llave de producto PEKING.
- J.1b `productJSON`/`ProductoLocalizacionHelper`/`HttpCalloutGetProductRefPrices`/`Fresh`.
- J.2 propósito de los triggers de Account.
- L.2 perfiles/Permission Sets dedicados de marca.

**Diferido — sin presupuesto asignado, sin pregunta abierta específica (4):**
- A.6 modelo relacional completo.
- H.3 reservas.
- H.4 anticipos.
- J.1a `BusquedaDetalladaController`/`precioProductoJSON` (con la salvedad: técnicamente resoluble ahora, ver Resumen D).
- K.1 LWC/Aura de inventario.

**Fuera de alcance — pertenece a otro objeto/fase, nunca al Sprint 1 (4):**
- D.1 `Order.empresaQueFactura__c`.
- I.1 Flows.
- K.2 componentes Aura de Community (agenda/territorios).
- L.1 seguridad completa (OWD/sharing/Experience Cloud).

`Diferido` y `Fuera de alcance` se mantienen como categorías separadas en
esta corrección: `Diferido` = no hay pregunta abierta específica, solo falta
presupuesto; `Fuera de alcance` = pertenece a otro dominio/fase por
definición (ej. seguridad completa es la Opción B/C del Manual, un proyecto
propio; Order/Flows/Community nunca estuvieron en los 41 componentes
directos del `PLAN_IMPLEMENTACION_SPRINT1.md`).

## Resumen C — Trabajo técnico adicional realizado únicamente para calidad, pruebas, respaldo o documentación

Esto **no se cuenta como funcionalidad nueva** en los totales de A/B:

- Cobertura ampliada de `ProductSearcherController` de 73.438 % a 94.79 % (Bloque 18, laboratorio de cobertura).
- Corrección de la clase de test huérfana `ProductSearcherControllerOtobaiTest` (realineación de firma, Bloque 18).
- Documentación de desfase Git↔Partial (`DESFASE_GIT_PARTIAL_TEST_TRAFICO.md`).
- Matriz de pendientes previa (`MATRIZ_PENDIENTES_SPRINT1_20260726.md`).
- Ramas de respaldo (`backup/pc/redmotors-before-bloque18...`, `backup/pc/redmotors-before-bloque19...`, `backup/pc/redmotors-sprint1-before-opportunity...`, etc.).
- Worktrees de análisis aislados (Bloque 18 coverage lab, pendientes Sprint 1, Bloque 21, este mismo de trazabilidad).
- Reconstrucción de `RM_Lead_Trigger_Helper_Test` con aserciones reales (Bloque 20) — parte del propio Bloque 20, no una funcionalidad adicional del alcance.
- Este mismo documento de trazabilidad, incluida esta corrección.

## Resumen D — Clasificación de los 21 requerimientos no completados por tipo de resolución

| Categoría | IDs | Cantidad |
|---|---|---:|
| (a) Técnicamente resoluble ahora, sin decisión | J.1a | 1 |
| (b) Requiere investigación adicional (técnica, no comercial) | F.4, L.3 | 2 |
| (c) Depende de decisión comercial, proveedor o dato externo | C.2, C.3, E.2, G.2, H.2, H.5, J.1b, J.2, L.2 | 9 |
| (d) Pertenece a fase posterior, no al Sprint 1 | A.6, H.3, H.4, K.1, D.1, I.1, K.2, L.1 | 8 |
| (en progreso, ya en ejecución dentro del Sprint) | B.4 | 1 |
| **Total no completado** | | **21** |

(a) **J.1a** (`BusquedaDetalladaController`, `precioProductoJSON`): mismo
patrón de selección de Pricebook por relación/código ya aplicado y probado
tres veces en este Sprint (`QuoteController`, `QuoterController`,
`BMW_LineaPlantillaEmpresa`); ninguna hace callout externo.

(b) **F.4**: falta describe/FLS del org. **L.3**: falta investigar
sistemáticamente 45 de 46 diferencias reportadas por el Manual.

(c) **C.2** intención ambigua; **C.3** alcance de negocio; **E.2** dos
reglas de ingeniería válidas; **G.2/H.5/J.1b** mismo contrato Softland
pendiente; **H.2** datos legales aprobados; **J.2** propósito de negocio de
los triggers; **L.2** decisión de tiempo ligada a otra iniciativa.

(d) **A.6/L.1** Opción B/C estratégica del Manual; **H.3/H.4** reservas y
anticipos sin presupuesto; **D.1** Order nunca asignado; **I.1** Flows nunca
asignado; **K.1/K.2** LWC/Aura nunca asignado.

---

## Cifras finales (verificadas contra la tabla de control)

| Estado | Cantidad |
|---|---:|
| Completado | 19 |
| En progreso | 0 |
| Pendiente técnico | 1 |
| Pendiente decisión | 11 |
| Diferido | 4 |
| Fuera de alcance | 4 |
| **Total** | **39** |

**Porcentaje sobre el alcance total documentado:** 19 / 39 = **48.72 %
completado** (contando por requerimiento único; `En progreso` no se cuenta
como completado).

### Métrica 1 — Avance del Sprint 1 comprometido

Requerimientos efectivamente asignados a un bloque ejecutado (1 a 21):
A.1, A.2, A.3, A.4, A.5, B.1, B.2, B.3, B.4, C.1, E.1, E.3, E.4, F.1, F.2,
F.3, G.1, H.1, J.3 — **19 requerimientos**.

De esos 19: **19 Completados, 0 En progreso**.

**Avance del Sprint 1 comprometido: 19 / 19 = 100 %.**

### Métrica 2 — Avance del alcance total documentado (PDF + Manual de Análisis)

Los 39 requerimientos de esta matriz, incluyendo todo lo que el Manual de
Análisis identificó como necesario para una solución completa (Softland
real, reservas, anticipos, seguridad/sharing completo, Flows, LWC/Aura,
PDF/branding legal, modelo relacional completo) — la mayoría de lo cual
nunca estuvo dentro del presupuesto de 44 horas aprobado.

**Avance del alcance total documentado: 19 / 39 = 48.72 %.**

### Trabajo pendiente dentro del Sprint vs. explícitamente fuera del Sprint

- **Dentro del Sprint comprometido:** no quedan requerimientos pendientes.
- **Explícitamente fuera del Sprint (20 de 39 totales):** los 20 restantes
  nunca formaron parte de los 19 comprometidos — 1 pendiente técnico, 11
  pendiente decisión, 4 diferidos, 4 fuera de alcance, según el desglose de
  Resumen B.

### Por qué hay dos métricas y no una

El 100 % mide el cierre de lo que el Sprint 1 **efectivamente comprometió**
hacer. El 48.72 % mide qué tan cerca está el
proyecto de la solución **completa** que describe el Manual de Análisis
(Opción B/C, "Estratégica"), que el propio Manual estima en 55-85
personas-semana — varias veces el presupuesto de 44 horas de este Sprint.
Ambas cifras son correctas para lo que miden; ninguna sustituye a la otra.

### Diferencia frente al estimado interno de 86 % / 14 %

El 86-87 % registrado en `BITACORA_IMPLEMENTACION.md` (Bloques 18 y 20) y en
`IMPLEMENTACION_BLOQUE21_OPORTUNIDAD_UI.md` ("87% si se valida y despliega")
es una **estimación de alcance técnico acumulado sobre los bloques
efectivamente trabajados** — conceptualmente el más cercano a la
**Métrica 1** de esta matriz (100 %), aunque no coincide exactamente
porque la bitácora no desglosa su porcentaje en requerimientos discretos
verificables uno por uno; es una estimación cualitativa acumulada por
bloque, no un cociente auditable como el de esta matriz.

La **Métrica 2** (48.72 %) mide algo que la bitácora nunca pretendió medir:
el avance contra **todo** el hallazgo del Manual de Análisis técnico. La
diferencia entre ~86-87 % (lo comprometido) y 48.72 % (lo documentado en
total) no es una contradicción — el propio `PLAN_IMPLEMENTACION_SPRINT1.md`
ya lo advertía: *"Las 41 clases son el alcance técnico directo confirmado.
Los escenarios de 30 y 44 horas son subconjuntos ejecutables, no una
redefinición del hallazgo."*

## Lista priorizada — los siguientes tres trabajos que más aumentan el cumplimiento explícito

1. **Definir `J.1a` (`BusquedaDetalladaController`, `precioProductoJSON`).**
   Requiere relación sucursal/empresa/Pricebook/Service Territory para PEKING
   y llave de producto RMPEKING/Softland; no debe implementarse por descarte.
2. **Definir `Quote.empresaFactura__c` (F.4).** Requiere decisión sobre el
   picklist heredado `Opportunity.empresaQueFactura__c`, su relación con
   `Empresa_Operadora__c` y la discrepancia `Otobay`/`Otobai`.
3. **Retomar componentes Softland/reservas/anticipos diferidos** solo cuando
   exista contrato o convención externa confirmada para PEKING.

Los tres requieren definición externa o funcional antes de implementación. No
deben ejecutarse por descarte ni como saneamiento técnico aislado.

## Puntos que pudimos haber omitido o interpretado de forma incompleta

- **Corrección propia (esta actualización):** el total anterior de 39 no
  coincidía con la suma de sus propios estados (44); la causa fue que los
  resúmenes narrativos no se derivaban mecánicamente de las filas reales.
  Se corrige agregando la Tabla de control como fuente única de verdad.
- El Manual de Análisis identifica **campos homónimos** (`Contact.Empresa__c`,
  `Account.Empresas__c`, `Maestro_de_Errores__c.Empresa__c`) como falsos
  positivos explícitos — se excluyeron correctamente de esta matriz.
- El Anexo B del Manual (78 permission sets, 50 profiles candidatos) no se
  trazó componente por componente — se resumió temáticamente (L.1/L.2).
- `B.4` avanzó de "Pendiente técnico" a "Completado" por trabajo real
  registrado en la rama de Bloque 21 (commit `67c180b`), con dry-run y deploy
  declarativo confirmados — no es una suposición de esta actualización.
- No se intentó recalcular el 86-87 % desde cero por bloque individual; en
  su lugar se explica la diferencia metodológica y se propone la Métrica 1
  como el número conceptualmente más cercano.

## Confirmación de alcance de esta tarea

No se ejecutó Salesforce CLI, no se consultó ningún org, no se modificó
código ni metadata, no hubo deploy. No se tocó ninguna rama de Bloques 18, 19,
20 ni 21: la evidencia del cierre real del Bloque 20 se leyó con `git log`/
`git show` contra el historial ya existente de `sprint1` (que otro proceso
avanzó de `a623f54` a `c8b89fb` de forma independiente a esta tarea), sin
hacer checkout, merge ni commit sobre esa rama ni sobre la rama propia de
Bloque 20. No se eliminó ningún worktree. La rama de esta matriz
(`analysis/pc/redmotors-empresa-marcas-chinas-sprint1-trazabilidad-20260726`)
permanece basada en `a623f54`, sin adelantarse a `sprint1`.
