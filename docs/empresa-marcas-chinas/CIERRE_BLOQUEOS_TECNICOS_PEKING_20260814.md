# RedMotors / PEKING — Cierre de bloqueos técnicos

Fecha: 2026-08-14
Rama: `feature/luis/peking-cierre-bloqueos-tecnicos-20260814`
Base solicitada: `feature/pc/redmotors-empresa-marcas-chinas-sprint2-flows-components-20260728`
Base confirmada al crear la rama: `76b104773536193f36d07fa7031dd8fdc947dede`

Nota de integración: después de creada esta rama, la rama base avanzó a `7e95e4835d6feb3fe9686b50f540b331e244b530` con el bloque separado de Sprint 4 aprobado (`Order` RT y picklists). No se integró aquí porque el alcance de este bloque indica no tocar `Order.Omoda`, `Order.Jaecoo` ni los 5 picklists que se integran por separado.

## Matriz ejecutiva

| SPRINT | COMPONENTE | ESTADO ANTES | ACCIÓN | ESTADO FINAL |
| --- | --- | --- | --- | --- |
| Cierre técnico / Softland | `force-app/main/default/classes/http_Helper.cls` + `http_HelperTest.cls` | Bloqueo técnico: `generateOrderJSON` resolvía compañía con ternario binario Bavarian/Otobai y PEKING podía caer mal. | Se corrigió el punto exacto. Ahora `generateOrderJSON` resuelve primero por `Opportunity.Empresa_Operadora__c` usando `EmpresaResolver` y `Codigo_ERP__c`; mantiene compatibilidad legacy Bavarian/Otobai sin fallback silencioso a una empresa equivocada; empresas desconocidas/incompletas fallan con error controlado. Se agregaron tests para Bavarian, Otobai, PEKING por lookup y empresa desconocida. | CORREGIDO EN GIT |
| Sprint 4 / Inventario VN | `force-app/main/default/lwc/rm_vn_crear_opp_inventario/rm_vn_crear_opp_inventario.js`; controllers revisados `RM_VN_CrearOportunidad_Ctrl`, `RM_VN_Inventario_Ctrl`, `ProductSearcherController` | Bloqueo de deploy: el LWC importa `RM_VN_CrearOportunidad_Ctrl.getProducts`, pero esa clase no tiene ese método. | Se revisaron equivalentes. `RM_VN_Inventario_Ctrl.getRecords` existe, pero usa otro nombre de método, otros parámetros (`locationId`, `family`, `reportado`, `numeroPedido`, `vehiculoTransito`, `skipPagination`) y devuelve `preciosSoftland`. `ProductSearcherController.getProducts` existe, pero su contrato también es diferente (`productType`, `productName`, `recordId`, `vehiculoTransito`) y devuelve `products`, no `records`. Cambiar sólo el import no es seguro y reabriría el contrato funcional del LWC. No se implementó un método nuevo porque requeriría definir formalmente entrada/salida. | BLOQUEADO POR DEFINICIÓN DE NEGOCIO |
| Sprint 4 / Búsqueda detallada | `force-app/main/default/classes/BusquedaDetalladaController.cls`; `force-app/main/default/lwc/busquedaDetallada/busquedaDetallada.js` | Bloqueo conocido: búsqueda/visibilidad depende de `User.Sucursal__c` y nombres fijos de sucursal/territorio. | Se confirmó que `getActivePricebooks` decide Bavarian/Otobai por sucursal (`Uruca`, `Pinares`, `Escazú`) y `searchProducts` fuerza territorios `Pinares - Mecánica Rápida`, `Escazú - Mecánica Rápida` o `Uruca - Mecánica Rápida`. No existe en Git una configuración Empresa→Sucursal→Territorio que permita deducir PEKING. Además el LWC importa `BusquedaDetalladaController.updateFreshPriceFromSoftland`, método no presente en el controller recuperado; no se inventó el contrato de actualización de precio. | BLOQUEADO POR DEFINICIÓN DE NEGOCIO |
| Sprint 4 / Case Record Types | `force-app/main/default/objects/Case/recordTypes/*` | Solicitud oficial de réplica Omoda/Jaecoo para Case, con 14 RT activos existentes. | Se revisaron los RT recuperados: `Autos`, `Autos_nuevos`, `Autos_usados`, `BMW_Service`, `Lifestyle_Autos`, `Lifestyle_Motos`, `Motos`, `Motos_nuevos`, `Motos_usados`, `Repuestos_autos`, `Repuestos_motos`, `Solicitudes_contabilidad_y_finanzas`, `Taller_de_Servicio_Autos`, `Taller_de_Servicio_Motos`. El modelo actual segmenta por función/tipo de vehículo, no por marca. Hay más de un baseline de autos posible y no existe equivalente único de marca. | BLOQUEADO POR DEFINICIÓN DE NEGOCIO |
| Sprint 3 / Lightning Page VN | `force-app/main/default/flexipages/Opportunity_Record_Page_VN.flexipage-meta.xml` | Bloqueo residual de asignación/visibilidad para Omoda/Jaecoo. | La página existe y contiene acciones/visibilidad por perfiles actuales (`Admin`, perfiles V2, BMW/MINI, etc.). En Git no hay metadata de activación/asignación por Record Type + perfil, ni perfiles/roles Omoda/Jaecoo definitivos que permitan copiar exactamente una asignación existente sin decisión. No se duplicó metadata a ciegas. | BLOQUEADO POR DATO |
| Sprint 3 / Aprobaciones de descuento / centro de costo | `force-app/main/default/approvalProcesses/Quote.CPAprobacionCargoInternoQuote.approvalProcess-meta.xml`; `WorkOrder.AprobacionCentroDeCostos.approvalProcess-meta.xml` | Posible pendiente de aprobaciones PEKING. | Se confirmó que el proceso de Quote asigna al related user field `CPAprobadorCentroDeCostos__c` y no contiene condición por marca/empresa. El comportamiento es agnóstico a Empresa; no requiere código si el aprobador se resuelve por centro de costo como ya fue definido. Lo único pendiente es dato/responsable real cuando aplique. | BLOQUEADO POR DATO |
| Sprint 3 / Plantillas de presupuesto | `force-app/main/default/objects/Plantilla_de_Presupuesto__c/fields/Empresa_Operadora__c.field-meta.xml`; `force-app/main/default/classes/BMW_LineaPlantillaEmpresa.cls` | Gap documental sobre `Plantilla_de_Presupuesto__c.Empresa_Operadora__c` y plantilla/Quick Action. | El lookup `Empresa_Operadora__c` existe en Git y `BMW_LineaPlantillaEmpresa.getEmpresa` prioriza ese lookup antes del fallback legacy. No hay Quick Action recuperada en Git para modificar. A nivel técnico no se requiere programación adicional; falta crear/probar el registro de plantilla PEKING en Salesforce y validar la acción existente en UI. | QA MANUAL PENDIENTE |
| Extra no autorizado | `ServicioCitas`, `ServicioCitasFieldService` | No forman parte de este cierre. | No se implementaron ni se analizaron como solución de los bloqueos anteriores. Si se requieren después para PEKING, deben tratarse como alcance separado. | TRABAJO EXTRA — NO CONTEMPLADO EN EL ALCANCE/HORAS ORIGINALES |

## Bloqueos eliminados

1. `http_Helper.generateOrderJSON` dejó de depender de un ternario Bavarian/Otobai para enviar `compania` a Softland.
2. Se agregó cobertura específica para:
   - Bavarian legacy;
   - Otobai legacy;
   - PEKING mediante `Empresa_Operadora__c`;
   - empresa desconocida con comportamiento seguro.

## Código preparado

Archivos modificados:

- `force-app/main/default/classes/http_Helper.cls`
- `force-app/main/default/classes/http_HelperTest.cls`

Commits del bloqueo resuelto:

- `dea73058d16e851c7ef6f2d0859813ff0ddeaffd` — `fix http helper company resolution`
- `23ccb551c944d9388b5cbb70a54e8d999906589e` — `test http helper company resolution`

## Bloqueos que permanecen

1. `rm_vn_crear_opp_inventario`: falta definir/implementar un contrato Apex funcional compatible con el LWC. El método esperado es `getProducts`; los equivalentes encontrados no son compatibles 1:1.
2. `BusquedaDetalladaController` / `busquedaDetallada`: falta definición de visibilidad PEKING. Dato exacto faltante: qué sucursales/territorios/listas de precio debe ver PEKING y bajo qué usuario/perfil. Además falta decidir si se habilita la actualización de precio desde Softland y con qué contrato Apex.
3. `Case` Record Types: falta decidir si Omoda/Jaecoo deben tener RT propios o reutilizar el RT funcional existente. El modelo actual no tiene un baseline único de marca.
4. `Opportunity_Record_Page_VN`: faltan perfiles/roles/asignación de página para Omoda/Jaecoo. No hay metadata en Git para copiar una asignación exacta.
5. Aprobaciones: falta dato de responsables/jerarquía cuando el centro de costo requiera aprobador PEKING; no falta lógica técnica por marca.

## Qué ya no requiere programación

1. `http_Helper` para compañía Softland queda listo para deploy/QA.
2. Aprobaciones de descuento/centro de costo no requieren cambio de metadata si el aprobador se sigue resolviendo por `CPAprobadorCentroDeCostos__c`.
3. Plantillas de presupuesto no requieren código adicional para PEKING si se crea el registro con `Empresa_Operadora__c`.
4. No se debe reabrir Sprint 1 ni Sprint 2 por estos puntos.
5. No se debe tocar el bloque separado de `Order` RT/picklists desde esta rama.

## Qué debe hacer Code para integración / deploy / QA

1. Integrar esta rama cuidando que el commit actual de base `7e95e4835d6feb3fe9686b50f540b331e244b530` ya trae metadata Sprint 4 separada.
2. Desplegar únicamente los dos Apex preparados para el bloqueo resuelto:
   - `http_Helper.cls`
   - `http_HelperTest.cls`
3. Ejecutar test recomendado:
   - `http_HelperTest`
4. QA manual recomendado:
   - Generar pedido con Opportunity legacy Bavarian.
   - Generar pedido con Opportunity legacy Otobai.
   - Generar pedido con Opportunity PEKING usando `Empresa_Operadora__c` y `Empresa__c.Codigo_ERP__c = RMPEKING`.
   - Validar que empresa desconocida no cae a Bavarian/Otobai.
5. Antes de intentar deploy de `rm_vn_crear_opp_inventario`, definir si se crea un wrapper Apex `getProducts` con contrato compatible o si se reestructura el LWC al contrato real de `RM_VN_Inventario_Ctrl.getRecords` / `ProductSearcherController.getProducts`.
6. Para `busquedaDetallada`, definir explícitamente visibilidad PEKING por sucursal/territorio/lista de precio antes de modificar código.
7. Para `Case`, decidir modelo: reutilizar RT funcional existente o crear RT por marca.
8. Para plantillas, crear/probar registro PEKING en Partial y validar la Quick Action en UI.

## Validación de restricciones

- Salesforce no fue tocado.
- No se hizo deploy.
- No se hizo DML.
- Production no fue tocado.
- No se modificaron List Views ni Profiles.
- No se modificó `Order.Omoda`, `Order.Jaecoo` ni los picklists del bloque separado.
- No se modificaron datos ni catálogos.
- No se implementó ServicioCitas ni ServicioCitasFieldService.
