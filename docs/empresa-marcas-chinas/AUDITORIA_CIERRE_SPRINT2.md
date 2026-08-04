# Auditoría de cierre técnico — Sprint 2 Empresa / Marcas Chinas

**Fecha de corte:** 2026-08-04  
**Ambiente consultado:** RedMotors Sandbox Partial, alias `RedMotorsSandbox`  
**Rama auditada:** `feature/pc/redmotors-empresa-marcas-chinas-sprint2-flows-components-20260728`  
**Naturaleza:** auditoría; no constituye cierre funcional ni autorización de implementación.

## Resultado ejecutivo

Se auditaron exactamente **20 Flows** y **25 bundles LWC/Aura**. Los 20 Flows existen en Git y Partial. Los 25 bundles existen en Partial, pero dos no están versionados en Git: `kpiSucursales` y `cT_Estadisticas_Inventario_lwc`.

La clasificación consolidada es:

| Clasificación | Flows | Bundles | Total |
|---|---:|---:|---:|
| MODIFICAR | 12 | 3 | 15 |
| SIN CAMBIO TÉCNICO | 6 | 4 | 10 |
| NO APLICA | 2 | 2 | 4 |
| BLOQUEADO | 0 | 16 | 16 |
| **Total** | **20** | **25** | **45** |

**Sprint 2 no está completo.** Compilar, desplegar o estar activo no se tomó como criterio de cierre. Cada fila, incluidas las versiones inactivas, fue evaluada en `MATRIZ_CIERRE_SPRINT2.csv`.

## Método y límites

1. Se verificaron rama y estado Git antes de auditar; el worktree estaba limpio.
2. Se leyeron las fuentes activas de alcance y la lista exacta confirmada por el solicitante.
3. Se inspeccionó el fuente local de cada Flow y bundle, incluyendo referencias a Empresa, compañía, Pricebook, moneda, bodega, sucursal, territorio, Softland y Record Type.
4. Partial se consultó únicamente mediante operaciones de lectura. Para Flows se obtuvo existencia, versión activa y última versión. Para LWC/Aura se comparó cada recurso de fuente de Partial contra el archivo local normalizando saltos de línea.
5. Con autorización explícita posterior, se consultó en Producción únicamente `FlowDefinition` para los 20 nombres: existencia, definición activa, versión/estado activo y última versión/estado. No se consultaron registros de negocio.
6. No se recuperó metadata a disco, no se desplegó, no se ejecutó Apex y no se modificaron datos.
7. Las Permission Sets no se declararon completas sin evidencia: deben validarse junto con campos/Apex afectados durante remediación. La matriz marca los casos con permisos explícitos observados, como `User.RM_PuedeModificarBodega__c`.

## Comparación Git contra Partial

### Flows: Git, Partial y Producción

Evidencia común: consulta Tooling API de solo lectura sobre `FlowDefinition` en `RedMotorsProd`, ejecutada el 2026-08-04. Se consultaron `DeveloperName`, `ActiveVersion.VersionNumber`, `ActiveVersion.Status`, `LatestVersion.VersionNumber` y `LatestVersion.Status`. No se consultaron datos funcionales.

| Flow | Partial | Producción: definición activa | Impacto PEKING | Clasificación | Acción |
|---|---|---|---|---|---|
| `Opportunity_Flow` | activa v28 | `Opportunity_Flow` v25 Active | Ya usa resolución dinámica | SIN CAMBIO TÉCNICO | No modificar; regresión |
| `Opp_flow_v4` | activa v19 | `Opp_flow_v4` v16 Active | Ya usa resolución dinámica | SIN CAMBIO TÉCNICO | No modificar; regresión |
| `BMW_ImportarPlantilla` | activa v16 | `BMW_ImportarPlantilla` v13 Active | Ya evita Pricebook arbitrario | SIN CAMBIO TÉCNICO | No modificar; E2E |
| `BMW_Gestiona_Listas_de_Precios` | activa v7 | `BMW_Gestiona_Listas_de_Precios` v2 Active | Fallback acotado | SIN CAMBIO TÉCNICO | No modificar; medir fallback |
| `Obtener_PricebookEntry_en_Linea_de_Plantilla_de_Presupuesto` | activa v3 | definición v1 Active | Ya valida resolución | SIN CAMBIO TÉCNICO | No modificar; E2E |
| `Opportunity_Flow_From_Work_Order` | activa v16 | definición v15 Active | Ruta PEKING explícita | SIN CAMBIO TÉCNICO | No modificar; confirmar mapeos para QA |
| `PlanDeMantenimientoV2` | activa v23 | definición v23 Active | PricebookEntry sin Empresa demostrada | MODIFICAR | Resolver/validar Pricebook por Empresa |
| `Work_Order_from_Quote_Selective` | activa v7 | definición v7 Active | Bifurcación Bavarian/Otobai | MODIFICAR | Resolución explícita por Empresa |
| `Work_Order_from_Quote` | activa v9 | definición v9 Active | Bifurcación Bavarian/Otobai | MODIFICAR | Resolución explícita por Empresa |
| `SegregateWOLIs` | activa v51 | definición v51 Active | Id fijo y regla Otobai | MODIFICAR | Configuración/DeveloperName; sin default |
| `ReciboUsadosFlow` | activa v3 | definición v3 Active | PEKING no aplica a usados | NO APLICA | No extender para PEKING |
| `Opp_Flow_V5` | activa v29; latest v30 inactiva | definición v29 Active; latest v30 Draft | Pricebooks nominales | MODIFICAR | Trabajar v29 activa; no activar v30 |
| `Opp_flow_V3` | activa v28 | definición v28 Active | Lógica binaria | MODIFICAR | Resolver por Empresa |
| `Opp_Flow_v6` | activa v79; latest v80 inactiva | definición v79 Active; latest v80 Draft | Lógica binaria | MODIFICAR | Trabajar v79 activa; no activar v80 |
| `Opportunity_Flow_V2` | activa v6 | definición v6 Active | Empresa/Pricebook no seguros | MODIFICAR | Gobernar por Empresa de Opportunity |
| `CreateWoliFromExpense` | activa v14 | definición v14 Active | Decision binaria | MODIFICAR | Resolver Empresa del WO |
| `aperturaCaseWorOrderEvent` | activa v20 | definición v20 Active | Compañía/Pricebook fijos | MODIFICAR | Configuración explícita |
| `ct_newCaseWorkOrderEvent` | activa v54 | definición v54 Active | Sin ruta empresarial configurable | MODIFICAR | Derivar Empresa del registro |
| `AgregarManoObra` | activa v1 | definición v1 Active | Assignments Bavarian/Otobai | MODIFICAR | Resolver Pricebook por Empresa |
| `Carga_MO_26_Lavado_a_Caso` | sin activa; latest v4 Obsolete | **sin definición activa**; latest v4 Obsolete | No se evalúa cambio: inactivo | NO APLICA | No trabajar ni reactivar |

Resultado productivo: 19 activos y 1 inactivo. De los activos, 12 requieren modificación, 6 no requieren cambio y 1 es exclusivo de usados (`NO APLICA`). El Flow inactivo tampoco se trabaja.

### Bundles idénticos por recurso

`rm_vu_inventario`, `rm_vn_crear_opp_inventario`, `rm_vn_inventario`, `rm_vn_inventario_movil`, `assetGarantiaLookupLwc`, `rm_vu_crear_opp`, `rm_vn_get_record_opp_record_types`, `rm_vn_crear_opp_home`, `rm_vn_crear_opp_home_movil`, `rm_vn_crear_opp_general`, `localizacionDetails` y `CommunityCalendar` coinciden entre Git y Partial en los recursos comparados.

### Bundles diferentes

| Bundle | Recursos diferentes |
|---|---|
| productSearcher | HTML, JS |
| quoliGridDespacho | HTML, JS |
| woliGridDespacho | HTML, JS |
| busquedaDetallada | HTML, JS |
| qoSearchDetailProduct | HTML, JS |
| woSearchDetailProduct | HTML, JS |
| pricebookReferenceDetails | JS |
| CommunityMenu | CMP, controller, helper, CSS |
| CommunityControl | CMP, controller, helper |
| customerCommunity_lwc | CMP |
| callcenterCommunity_lwc | CMP |

Estos bundles no deben desplegarse desde Git antes de reconciliar el origen de cada diferencia. Hacerlo podría sobrescribir cambios activos en Partial.

### Bundles solo en Partial

- `kpiSucursales`: 4 recursos en Partial; ruta Git esperada `force-app/main/default/lwc/kpiSucursales`, inexistente.
- `cT_Estadisticas_Inventario_lwc`: 3 recursos en Partial; ruta Git esperada `force-app/main/default/lwc/cT_Estadisticas_Inventario_lwc`, inexistente.

## Hallazgos críticos

1. `Work_Order_from_Quote`, `Work_Order_from_Quote_Selective`, `CreateWoliFromExpense`, `aperturaCaseWorOrderEvent` y otros Flows conservan decisiones binarias Bavarian/Otobai. Una Empresa nueva puede caer en una ruta residual incorrecta.
2. `Opp_Flow_V5`, `Opp_flow_V3`, `Opp_Flow_v6` y `Opportunity_Flow_V2` conservan nombres fijos de Pricebooks. Esto contradice la arquitectura vigente.
3. `SegregateWOLIs` contiene un Record Type Id fijo (`0124U00000111E8QAI`) y lógica específica Otobai.
4. Los cuatro bundles de comunidad contienen IDs de usuarios, nombres de sucursales/servicios y restricciones operativas fijas. `CommunityMenu` además contiene texto legal Bavarian. No puede generarse contenido PEKING por analogía.
5. `productSearcher` y `rm_vn_crear_opp_inventario` usan contratos `preciosBavarian`/`pbeBavarian`.
6. `busquedaDetallada` carga Pricebooks activos sin filtro empresarial visible en el cliente.
7. `qoSearchDetailProduct`, `woSearchDetailProduct`, `localizacionDetails` y `pricebookReferenceDetails` dependen de un parámetro ambiguo `empresaFactura`, no demostrado como lookup Empresa o clave ERP estable.
8. La ausencia en Git de dos bundles desplegados impide trazabilidad y cualquier corrección segura.

## Arquitectura evaluada

- `Empresa_Operadora__c`/`Empresa__c` es la fuente principal.
- `BMW_Compania__c` se acepta solo como fallback temporal explícito y acotado.
- No se propone agregar PEKING a picklists legacy.
- No se aceptan nombres ni IDs fijos de Pricebooks en lógica productiva.
- Una empresa desconocida debe producir estado controlado; nunca caer silenciosamente en Bavarian u Otobai.
- Códigos ERP, bodegas, sucursales, territorios, monedas, catálogos, precios, permisos y datos legales quedan bloqueados si no existe definición confirmada.

## Pruebas y videos mínimos para cierre

1. Opportunity/Pricebook: creación desde cada entrada real, para Bavarian, Otobai y PEKING; CRC/USD cuando aplique; empresa ausente y selección ambigua.
2. Plantillas: importación completa y creación de líneas con evidencia de `PricebookEntry.Pricebook2.Empresa__c`.
3. Quote→Work Order: rutas normal y selectiva, WOLI, bodega, territorio y moneda.
4. Gastos/mano de obra: creación de WOLI verificando Product2, PricebookEntry y Empresa del WO.
5. Inventario: flujo real **Ver inventario**, sin crear Opportunities por Apex/CLI; usar VIN/datos completos proporcionados por el equipo.
6. Despacho: reserva, apartado, despacho, devolución y errores Softland en `quoliGridDespacho`/`woliGridDespacho`.
7. Comunidades: navegación, agenda, sucursal, capacidad y consentimiento legal por perfil QA, sin usar al usuario de apoyo como usuario funcional principal.
8. Garantía: Asset válido/no válido por Empresa, sucursal y evento resultante.
9. Búsquedas: aislamiento de Pricebooks, bodegas y referencias Softland por Empresa; intento cruzado debe rechazarse.
10. Versiones inactivas: evidencia de dependencias e invocadores; no activar ninguna durante QA sin aprobación.

Cada video debe mostrar fecha, org Partial, perfil QA, punto de entrada, datos de entrada no sensibles, resultado, campos clave y limpieza/estado final. Un video no sustituye capturas de versiones, configuración y registros resultantes.

## Bloqueos para consulta

### Luis

- Confirmar si `kpiSucursales` y `cT_Estadisticas_Inventario_lwc` deben incorporarse a Git.

Decisiones cerradas: los Flows legacy solo se trabajan si están activos en Producción y tienen impacto PEKING; los procesos/componentes exclusivos de usados no soportan PEKING.

### Diego

- Determinar fuente autoritativa de los 11 bundles con diferencias Git–Partial.
- Confirmar mapeo Empresa↔Record Type y la estrategia para reemplazar el Id fijo de `SegregateWOLIs`.
- Confirmar si `empresaFactura` representa Empresa, código ERP u otro concepto y cómo migrarlo.

### Negocio

- Definir, sin inferencias, monedas, Pricebooks, catálogos/precios, bodegas, sucursales, territorios, permisos y operación Softland de PEKING.
- Entregar textos legales y reglas de servicios/comunidad aprobados.
- Definir garantía, usados, mano de obra, despacho y mantenimiento aplicables a PEKING.

## Seguridad y ambiente

Producción fue consultada exclusivamente en modo lectura para verificar `FlowDefinition` de los 20 Flows autorizados. No se consultaron datos funcionales ni se modificaron datos o metadata. No se hizo deploy, activación, desactivación, cambio de versión, retrieve a disco, staging, commit ni ejecución de Apex. El worktree roto `RedMotors-Empresa-Marcas-Chinas` no fue reparado, eliminado ni modificado.
