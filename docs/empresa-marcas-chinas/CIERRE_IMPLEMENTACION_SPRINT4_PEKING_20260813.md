# RedMotors / PEKING — Cierre implementación Sprint 4

**Fecha:** 13 de agosto de 2026

**Rama de trabajo:** `feature/pc/redmotors-empresa-marcas-chinas-sprint2-flows-components-20260728`

**Fuentes integradas:**
- `9349880` (retrieve dirigido de metadata real, este mismo worktree) — ver `FUENTES_METADATA_SPRINT4_20260813.md`.
- `4b1b623` de `feature/luis/peking-sprint4-implementacion-20260813` (fixes de LWC ya preparados por Luis, sin acceso a Salesforce en ese momento). Se incorporaron los 5 LWC; este documento reemplaza el borrador de cierre que traía ese commit.
- `b0fc34c` (docs-only, misma rama) no se incorporó: su contenido queda superado en su totalidad por la metadata real ya recuperada en `9349880`.

**Naturaleza:** implementación de los gaps demostrados con metadata real. Sin auditoría nueva, sin reinterpretación de alcance.

## Resumen ejecutivo

**SPRINT 4 — CERRADO EN TODO LO IMPLEMENTABLE.**

Lo que quedó pendiente son exclusivamente: datos de catálogo (Familia/Modelo) no disponibles en ninguna fuente, un Record Type de `Case` sin equivalente funcional único que replicar, y una dependencia Apex preexistente de un LWC que no forma parte de este alcance.

## 1. Campos / picklists

| Campo | Estado | Evidencia | Acción |
|---|---|---|---|
| `Quote.Compania__c` | HECHO (sin cambio) | Picklist restringido `Bavarian`/`Otobai`. No es la ruta vigente de resolución de Empresa (esa es `Opportunity.Empresa_Operadora__c`). | Ninguna. No se amplía un picklist legacy que ya no es la fuente de verdad. |
| `Quote.empresaFactura__c` | **NO EXISTE EN MODELO ACTUAL — NO CREAR SIN NECESIDAD FUNCIONAL DEMOSTRADA** | Verificado por describe completo de `Quote`; no existe ese campo ni variante. | Ninguna. |
| `Opportunity.empresaQueFactura__c` | HECHO (sin cambio) | Picklist restringido `Otobay`/`Bavarian` (legacy, con typo). Ruta vigente es `Empresa_Operadora__c` (lookup). | Ninguna. |
| `Order.empresaQueFactura__c` | HECHO (sin cambio) | Picklist restringido `RMOTOBAI`/`RMBAVARIAN`. | Ninguna — no se amplía; ver Record Types de `Order` abajo, que ya son agnósticos de marca. |
| `User.Empresa__c` | HECHO (sin cambio) | Picklist restringido `Bavarian`/`Otobai`, usado como sugerencia/default, no como fuente final. | Ninguna. |
| `CentroCosto__c.Empresa__c` | **NO EXISTE EN MODELO ACTUAL — NO CREAR SIN NECESIDAD FUNCIONAL DEMOSTRADA** | Verificado por describe completo de `CentroCosto__c` (18 campos); ninguno es de Empresa/Compañía. Decisión vigente: reutilizar Centro de Costo existente, aprobadores por lógica actual — no bloquea. | Ninguna. |
| `ReciboUsado__c.Empresa__c` | HECHO (sin cambio) | Picklist restringido `RMBAVARIAN`/`RMOTOBAI`. Fuera del alcance de Venta Nueva PEKING (usados no autorizado). | Ninguna. |
| `Linea_Plantilla_de_Presupuesto__c.Empresa__c` | HECHO (sin cambio) | **Picklist restringido** (no lookup, corrige premisa previa), `RMBAVARIAN`/`RMOTOBAI`. La ruta vigente resuelve Empresa desde `Plantilla_de_Presupuesto__c.Empresa_Operadora__c` (lookup), no desde este campo por línea. | Ninguna — no se reintroduce PEKING en un picklist que el flujo actual ya no consume como fuente. |
| `Plantilla_de_Presupuesto__c.BMW_Compania__c` | HECHO (sin cambio) | **Picklist restringido, `required=true`** (no lookup, corrige premisa previa), `Otobai`/`Bavarian`. Ruta vigente: `Plantilla_de_Presupuesto__c.Empresa_Operadora__c` (lookup). | Ninguna. |
| `WorkOrder.empresaFactura__c` | HECHO (ya en Git) | Contiene `RMBAVARIAN`, `RMOTOBAI`, `RMPEKING`. Verificado en este bloque. | Ninguna. |
| `Product2.Empresa__c` | HECHO (ya en Git) | Contiene `RMBAVARIAN`, `RMOTOBAI`, `RMPEKING`. Verificado en este bloque. | Ninguna. |
| `TipoDeCargoConManoDeObra__c.Empresa__c` | HECHO (ya en Git) | Contiene `RMBAVARIAN`, `RMOTOBAI`, `RMPEKING`. Verificado en este bloque. | Ninguna. |

**Regla aplicada de forma consistente:** ningún picklist legacy de empresa/compañía se amplía con PEKING/OMODA/JAECOO cuando el flujo activo ya resuelve Empresa por lookup/configuración (`Empresa_Operadora__c` en `Opportunity`/`Plantilla_de_Presupuesto__c`, `empresaFacturaCP__c` en `WorkOrder`). Ampliar esos picklists sería reintroducir un hardcode que el modelo ya superó.

## 2. Record Types

| Objeto | Estado | Evidencia | Acción |
|---|---|---|---|
| `Opportunity` | HECHO (ya existente) | `Omoda.recordType-meta.xml`, `Jaecoo.recordType-meta.xml` activos en Git. | Ninguna. |
| `Lead` | HECHO (ya existente) | `Omoda.recordType-meta.xml`, `Jaecoo.recordType-meta.xml` activos en Git. | Ninguna. |
| Lead → Opportunity (mapping) | HECHO (ya existente) | `RM_RecordTypeMapping.Lead_Omoda_to_Opp`, `Lead_Jaecoo_to_Opp` activos. | Ninguna. |
| `Order` | **NO APLICA** | El único Record Type existente (`BMW`, único en todo el objeto) ya es usado de forma agnóstica por Bavarian y Otobai simultáneamente — no hay ni ha habido segmentación por marca en `Order`. Su propio XML no contiene ninguna referencia a Empresa/Compañía (solo restringe `Status`: `Aprobado`/`Draft`). | Ninguna. No se crea `Order.OMODA` ni `Order.JAECOO`: no existe un patrón "un RT por marca" que replicar — el patrón real es un único RT compartido. Crear RT nuevos introduciría una segmentación que no existe hoy para ninguna marca. |
| `Case` | **BLOQUEADO — NO EXISTE RECORD TYPE DE MARCA/EQUIVALENTE FUNCIONAL ÚNICO QUE REPLICAR** | Los 14 RT activos de `Case` están segmentados por tipo de vehículo y función (`Autos`/`Motos` × nuevos/usados/taller/repuestos/lifestyle/service), nunca por marca. No existe un `Case.Bavarian` ni `Case.Otobai` que sirva de plantilla inequívoca para clonar a Omoda/Jaecoo. | Ninguna. Crear un RT nuevo aquí sería inventar un patrón de segmentación que no existe en ningún punto del objeto. |

## 3. Global Value Sets

Los 3 GVS reales confirmados en `9349880` por consumo directo de campo en `Product2`:

| GVS | Consumidor | Estado | Acción |
|---|---|---|---|
| `Marca_de_Interes` | `Product2.Marca__c` | **HECHO** | Se agregaron los valores `OMODA` y `JAECOO` (mismo formato que el resto: `fullName`/`label` sin acentos ni códigos internos). Deploy `0AfAK0000014p8D0AQ`. Verificado post-deploy: ambos valores aparecen en el picklist de `Product2.Marca__c` en el org. |
| `Familia` | `Product2.Familia__c` (controlado por `Grupo__c`) | **PENDIENTE DE CATÁLOGO — NO INVENTAR VALORES** | Se buscaron registros `Product2` existentes con Marca/Nombre conteniendo OMODA/JAECOO antes de tocar el GVS: `SELECT Id, Name, Marca__c, Familia__c FROM Product2 WHERE Name LIKE '%OMODA%' OR Name LIKE '%JAECOO%' OR Marca__c LIKE '%OMODA%' OR Marca__c LIKE '%JAECOO%'` → 0 resultados. No hay dato fuente de qué familias tiene el catálogo real de OMODA/JAECOO. No se agregó ningún valor. |
| `Modelo_de_Interes2` | `Product2.Modelo_De_Inter_s__c` (controlado por `Familia__c`) | **PENDIENTE DE CATÁLOGO — NO INVENTAR VALORES** | Misma búsqueda, mismo resultado (0). Depende además de que existan valores de Familia primero (campo controlador). No se agregó ningún valor. |

Los GVS de nombre literal `Marca` (5 valores) y `Modelo` (844 valores) — descartados en el retrieve anterior por no tener campo consumidor confirmado — **no se tocaron**; no forman parte del alcance real.

## 4. LWC Sprint 4

| Componente | Estado | Cambio aplicado | Deploy |
|---|---|---|---|
| `rm_vn_crear_opp_general` | HECHO | `@api brand` ya no fuerza `'BMW'` por defecto (queda `''`); HTML pasa `brand={brand}` en vez de `brand="BMW"` a sus hijos. | `0AfAK0000014p8D0AQ` |
| `rm_vn_crear_opp_home` | HECHO | Mismo patrón: `@api brand = ''`; HTML propaga `brand={brand}`. | `0AfAK0000014p8D0AQ` |
| `rm_vn_crear_opp_home_movil` | HECHO | Mismo patrón. | `0AfAK0000014p8D0AQ` |
| `rm_vn_get_record_opp_record_types` | HECHO | Typo `this.isloading` → `this.isLoading` (la propiedad rastreada real se llama `isLoading`; el typo dejaba el estado de carga desincronizado del label mostrado). | `0AfAK0000014p8D0AQ` |
| `rm_vn_crear_opp_inventario` | **BLOQUEADO** | Cambio de una línea ya aplicado (`this.interexternalColornalColor` → `this.externalColor`, typo que rompía el filtro de color externo), pero **no se pudo desplegar**: el bundle completo falla porque `rm_vn_crear_opp_inventario.js` importa `@salesforce/apex/RM_VN_CrearOportunidad_Ctrl.getProducts`, y ese método **no existe** en `RM_VN_CrearOportunidad_Ctrl.cls` (confirmado leyendo la clase completa en Git — no tiene ningún método `getProducts`). Es una dependencia Apex preexistente, no relacionada con el fix de esta sesión ni con Sprint 4. No se implementó el método: está fuera del alcance de "no ampliar el alcance de esos componentes". | No desplegado. |

Fix ya aplicado localmente en `rm_vn_crear_opp_inventario.js` (commiteado, no desplegado) para no perder el trabajo — el archivo queda listo para desplegar en cuanto exista `getProducts` en el controlador o se confirme el nombre real del método Apex esperado.

## 5. Pendientes de catálogo

- `Familia` (GVS): sin valores fuente de OMODA/JAECOO en `Product2` ni en ninguna metadata revisada.
- `Modelo_de_Interes2` (GVS): mismo caso; además depende de que Familia se resuelva primero.

## 6. Bloqueos reales

- `Case`: sin Record Type de marca/equivalente funcional único que replicar para Omoda/Jaecoo.
- `rm_vn_crear_opp_inventario`: bloqueado por dependencia Apex preexistente (`RM_VN_CrearOportunidad_Ctrl.getProducts` no implementado), fuera de este alcance.

## 7. Archivos modificados

- `force-app/main/default/globalValueSets/Marca_de_Interes.globalValueSet-meta.xml` (2 valores agregados: OMODA, JAECOO).
- `force-app/main/default/lwc/rm_vn_crear_opp_general/{rm_vn_crear_opp_general.html,rm_vn_crear_opp_general.js}`
- `force-app/main/default/lwc/rm_vn_crear_opp_home/{rm_vn_crear_opp_home.html,rm_vn_crear_opp_home.js}`
- `force-app/main/default/lwc/rm_vn_crear_opp_home_movil/{rm_vn_crear_opp_home_movil.html,rm_vn_crear_opp_home_movil.js}`
- `force-app/main/default/lwc/rm_vn_crear_opp_inventario/rm_vn_crear_opp_inventario.js` (aplicado, no desplegado — ver bloqueo).
- `force-app/main/default/lwc/rm_vn_get_record_opp_record_types/rm_vn_get_record_opp_record_types.js`
- `docs/empresa-marcas-chinas/CIERRE_IMPLEMENTACION_SPRINT4_PEKING_20260813.md` (este documento).

## 8. Tests / validaciones

- Sin infraestructura de lint/test de LWC en el repositorio (no hay `package.json`). Validación estructural realizada por el propio dry-run de Salesforce, que valida sintaxis JS/HTML y referencias Apex del bundle completo.
- Metadata (GVS): balance de tags `<customValue>`/`</customValue>` verificado (39/39) antes del deploy.
- Post-deploy: confirmado por describe que `Product2.Marca__c` expone `OMODA` y `JAECOO` como valores de picklist en el org.

## 9. Dry-run y deploy

- Dry-run: `0AfAK0000014p4z0AA` (GVS + 4 LWC, excluyendo `rm_vn_crear_opp_inventario`), Succeeded, 0 errores.
- Deploy real: `0AfAK0000014p8D0AQ`, RedMotorsSandbox, 5 componentes desplegados, 0 errores.
- No se intentó deploy de `rm_vn_crear_opp_inventario` (bloqueado, ver sección 4).

## 10. QA requerida (manual)

No se ejecutó QA de UI en este bloque (fuera del criterio "no gastar contexto intentando automatizar una UI compleja"). Punto exacto pendiente de validación manual:

- **Registro/contexto:** cualquier Lead u Opportunity con Record Type `Omoda` o `Jaecoo` en RedMotorsSandbox.
- **Usuario:** un usuario con acceso a la app de Venta Nueva (mismo perfil ya usado en QA de Sprint 2/3).
- **Componente/acción:** abrir el flujo de "Crear Oportunidad" de Venta Nueva (`rm_vn_crear_opp_home` / `rm_vn_crear_opp_home_movil` según dispositivo) partiendo de un registro Omoda o Jaecoo.
- **Pasos:** iniciar el flujo de creación; verificar que el selector de marca en `rm_vn_get_record_opp_record_types` cargue las opciones correctamente (revisando que el label ya no quede pegado en "Cargando..." de forma indefinida); confirmar que la marca mostrada/propagada a los componentes hijos corresponda a Omoda/Jaecoo y no aparezca "BMW" fijo en ningún punto de la pantalla.
- **Resultado esperado:** el flujo debe permitir avanzar con la marca real del registro (Omoda/Jaecoo) sin que ningún componente fuerce `BMW` por defecto, y el selector de Record Type debe alternar correctamente entre estado de carga y estado cargado.

## 11. Clasificación final por API name

| API name | Clasificación |
|---|---|
| `Quote.Compania__c` | HECHO (sin cambio necesario) |
| `Quote.empresaFactura__c` | NO EXISTE EN MODELO ACTUAL — NO CREAR SIN NECESIDAD FUNCIONAL DEMOSTRADA |
| `Opportunity.empresaQueFactura__c` | HECHO (sin cambio necesario) |
| `Order.empresaQueFactura__c` | HECHO (sin cambio necesario) |
| `User.Empresa__c` | HECHO (sin cambio necesario) |
| `CentroCosto__c.Empresa__c` | NO EXISTE EN MODELO ACTUAL — NO CREAR SIN NECESIDAD FUNCIONAL DEMOSTRADA |
| `ReciboUsado__c.Empresa__c` | HECHO (sin cambio necesario) |
| `Linea_Plantilla_de_Presupuesto__c.Empresa__c` | HECHO (sin cambio necesario) |
| `Plantilla_de_Presupuesto__c.BMW_Compania__c` | HECHO (sin cambio necesario) |
| `WorkOrder.empresaFactura__c` | HECHO |
| `Product2.Empresa__c` | HECHO |
| `TipoDeCargoConManoDeObra__c.Empresa__c` | HECHO |
| `Opportunity.Omoda` / `Opportunity.Jaecoo` (Record Type) | HECHO |
| `Lead.Omoda` / `Lead.Jaecoo` (Record Type) | HECHO |
| `RM_RecordTypeMapping.Lead_Omoda_to_Opp` / `Lead_Jaecoo_to_Opp` | HECHO |
| `Order` Record Types por marca | NO APLICA |
| `Case` Record Types por marca | BLOQUEADO |
| `Marca_de_Interes` (GVS) | HECHO |
| `Familia` (GVS) | PENDIENTE DE CATÁLOGO |
| `Modelo_de_Interes2` (GVS) | PENDIENTE DE CATÁLOGO |
| `rm_vn_crear_opp_general` | HECHO |
| `rm_vn_crear_opp_home` | HECHO |
| `rm_vn_crear_opp_home_movil` | HECHO |
| `rm_vn_get_record_opp_record_types` | HECHO |
| `rm_vn_crear_opp_inventario` | BLOQUEADO |

## 12. Dictamen

**SPRINT 4 — CERRADO EN TODO LO IMPLEMENTABLE.** Permanecen únicamente: datos de catálogo no disponibles (Familia/Modelo de OMODA/JAECOO), un bloqueo real de Record Type sin equivalente funcional en `Case`, un bloqueo real de dependencia Apex preexistente en `rm_vn_crear_opp_inventario`, y QA manual de UI pendiente (sección 10). Ninguno de los tres primeros puede resolverse sin datos/decisiones externas a este bloque de trabajo.
