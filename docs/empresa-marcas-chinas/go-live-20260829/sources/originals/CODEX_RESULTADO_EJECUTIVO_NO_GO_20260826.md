# Resultado ejecutivo

**NO GO para el pase del sábado en el estado actual.**

El inventario técnico quedó reconciliado en **130 componentes de metadata candidatos**, pero el paquete de Copado no pudo crearse ni validarse porque:

1. No existe acceso verificable a Copado en las sesiones u organizaciones disponibles.
2. La batería dirigida en Partial terminó con **276/303 PASS y 27 fallos**.
3. Producción no contiene los datos maestros PEKING necesarios para una prueba funcional.
4. RQ329 está en Partial pero ausente en Producción y pertenece a una liberación/dependencia separada.
5. Falta reconciliar completamente algunas identidades y asignaciones de seguridad en Producción.

No se ejecutó deploy, Quick Deploy, DML en Producción ni modificación de archivos.

## 1. Inventario definitivo reconciliado

| AlcanceComponentePartialProducciónAcciónCopadoDato/manualEvidencia |                                         |                       |                      |                                              |                    |                          |                                     |
| ------------------------------------------------------------------ | --------------------------------------- | --------------------- | -------------------- | -------------------------------------------- | ------------------ | ------------------------ | ----------------------------------- |
| Sprint 1                                                           | Apex Empresa/Quote/Softland/Work Order  | Presente              | 30 clases diferentes | Promover versión reconciliada y tests        | Sí                 | No                       | Cierre Sprint 1 + comparación real  |
| Sprint 1                                                           | `WorkOrderTrigger`                      | Presente              | Diferente            | Promover                                     | Sí                 | No                       | Comparación real                    |
| Sprint 2                                                           | 17 Flows aplicables                     | Activos               | Versiones anteriores | Promover y activar versión nueva             | Sí                 | No                       | Cierre Sprint 2 + versiones activas |
| Sprint 2                                                           | 3 Flows revisados sin cambio aplicable  | Presente              | Sin cambio requerido | Excluir                                      | No                 | No                       | Matriz Sprint 2                     |
| Sprint 3                                                           | Campos Empresa y 4 reglas de validación | Presente              | Ausentes/diferentes  | Promover                                     | Sí                 | No                       | Cierre Sprint 3 + comparación       |
| Sprint 3                                                           | Approval Processes                      | Diferentes            | Diferentes           | Excluir: no hubo cambio funcional autorizado | No                 | No                       | Reconciliación Sprint 3             |
| Sprint 4                                                           | Record Types OMODA/JAECOO               | Presente              | Ausente              | Promover                                     | Sí                 | No                       | Cierre Sprint 4                     |
| Sprint 4                                                           | GVS `Marca_de_Interes`                  | Incluye OMODA/JAECOO  | No los incluye       | Promover                                     | Sí                 | No                       | Comparación real                    |
| Sprint 4                                                           | Mapeos Lead→Opportunity                 | Presente              | Ausente              | Promover                                     | Sí                 | No                       | Comparación real                    |
| Sprint 4                                                           | LWC                                     | 4 bundles modificados | Versiones anteriores | Promover                                     | Sí                 | No                       | Comparación real                    |
| Sprint 4                                                           | Catálogo/modelos/bodega temporales      | QA                    | Ausentes             | Excluir                                      | No                 | Pendiente oficial        | Cierre Sprint 4 + datos reales      |
| Sprint 5                                                           | Pricebooks/PBE QA                       | Valores provisionales | Ausentes             | Excluir                                      | No                 | Sí                       | `UnitPrice=1`, datos QA             |
| Sprint 5                                                           | Work Order Flows                        | v12/v10               | v9/v7                | Promover                                     | Sí                 | No                       | Fix validado en Partial             |
| Corrección                                                         | `Opportunity_Flow_From_Work_Order`      | v18                   | v15                  | Promover                                     | Sí                 | No                       | Filtro Empresa activa reconciliado  |
| Corrección                                                         | `Empresa_Consulta_Flows`                | FLS corregido         | Ausente/anterior     | Promover                                     | Sí                 | Asignaciones posteriores | Validación 28/28 en Partial         |
| Dependencia                                                        | RQ329                                   | Presente              | Ausente              | Liberación separada y ordenada antes del E2E | No en este paquete | Sí                       | Comparación Tooling API             |

## 2. Total de componentes Copado

**Total reconciliado: 130 componentes de metadata.**

| TipoCantidad             |         |
| ------------------------ | ------- |
| ApexClass                | 69      |
| ApexTrigger              | 1       |
| Flow                     | 17      |
| CustomObject             | 1       |
| CustomField              | 15      |
| RecordType               | 4       |
| CustomMetadata           | 2       |
| GlobalValueSet           | 1       |
| PermissionSet            | 3       |
| ValidationRule           | 4       |
| ListView                 | 8       |
| LightningComponentBundle | 4       |
| Layout                   | 1       |
| **Total**                | **130** |

Este total representa el inventario reconciliado. **No representa un paquete Copado ya creado o validado.**

## 3. Lista exacta por tipo

### Apex — 69 clases

Clases funcionales modificadas:

`BMW_LineaPlantillaEmpresa`, `QuoteSoftlandPedidoService`, `ProductControllerTwo`, `servicioReservas`, `ServicioReservaApartadoArticulosQuote`, `ServicioConsDispBodegaQuoli`, `servicioEliminarReserva`, `ServicioEliminarReservaArticuloQuote`, `ServicioCrearSCQuote`, `QuoteController`, `cT_QuoteCrcPDFController`, `cT_QuoteUsdPDFController`, `UpdateCurrencyScheduler`, `BMW_ChangeCurrencyWOWOLI`, `OpportunityServiceInvoker`, `Registrar_Anticipo_Controller`, `savePDFfile`, `BatchGetCategoriaClienteSoftland`, `BatchGetCentroCostoSoftland`, `BatchGetCondicionPagoSoftland`, `BatchGetCuentaContableSoftland`, `BatchGetImpuestoSoftland`, `BatchGetSubtipoDocumentoSoftland`, `precioProductoJSON`, `productJSON`, `HttpCalloutCreateKit`, `ProductSearcherController`, `QuoteService`, `QuoteSoftlandQueryService`, `RM_VN_CambiarUbicacion_Ctrl`.

Fundación Empresa:

`EmpresaConfigurationException`, `EmpresaContext`, `EmpresaContextTest`, `EmpresaResolver`, `EmpresaResolverTest`, `EmpresaPricebookResolver`, `EmpresaPricebookResolverTest`.

Corrección HTTP:

`http_Helper`, `http_HelperTest`.

Tests modificados/requeridos:

`BMW_LineaPlantillaEmpresa_Test`, `QuoteSoftlandPedidoServiceTest`, `ProductControllerTwoTest`, `servicioReservasTest`, `SRAArticulosQuoteTest`, `ServicioConsDispBodegaQuoliTest`, `servicioEliminarReservaTest`, `ServicioEliminarReservaArticuloQuoteTest`, `ServicioCrearSCQuoteTest`, `QuoteControllerTest`, `cT_QuoteCrcPDFController_test`, `cT_QuoteUsdPDFController_test`, `UpdateCurrencySchedulerTest`, `BMW_ChangeCurrencyWOWOLITest`, `OpportunityServiceInvokerTest`, `Registrar_Anticipo_Controller_Test`, `BatchGetCategoriaClienteSoftlandTest`, `BatchGetCentroCostoSoftlandTest`, `BatchGetCondicionPagoSoftlandTest`, `BatchGetCuentaContableSoftlandTest`, `BatchGetImpuestoSoftlandTest`, `BatchGetSubtipoDocumentoSoftlandTest`, `precioProductoJSONTest`, `productJSONTest`, `HttpCalloutCreateKitTest`, `ProductSearcherControllerTest`, `ProductSearcherControllerOtobaiTest`, `QuoteServiceCompanyBodegaTest`, `RM_VN_CambiarUbicacion_Ctrl_Test`, `WorkOrderTriggerTest`.

Excluidos por ser idénticos en Producción: `BatchGetBodegaSoftland`, `BMWServiceQuoteApprovalEmailInvocable`, `savePDFfileTest`, `QuoteServiceControllerTest`.

### Trigger

- `WorkOrderTrigger`

### Flows — 17

- `AgregarManoObra`
- `aperturaCaseWorOrderEvent`
- `BMW_Gestiona_Listas_de_Precios`
- `BMW_ImportarPlantilla`
- `CreateWoliFromExpense`
- `ct_newCaseWorkOrderEvent`
- `Obtener_PricebookEntry...`
- `Opp_flow_V3`
- `Opp_flow_v4`
- `Opp_Flow_V5`
- `Opp_Flow_v6`
- `Opportunity_Flow`
- `Opportunity_Flow_From_Work_Order`
- `Opportunity_Flow_V2`
- `PlanDeMantenimientoV2`
- `Work_Order_from_Quote`
- `Work_Order_from_Quote_Selective`

Versiones observadas:

| FlowPartial activaProducción activaResultado esperado |           |          |                                           |
| ----------------------------------------------------- | --------- | -------- | ----------------------------------------- |
| `Work_Order_from_Quote`                               | 12        | 9        | Nueva versión activa                      |
| `Work_Order_from_Quote_Selective`                     | 10        | 7        | Nueva versión activa                      |
| `Opportunity_Flow_From_Work_Order`                    | 18        | 15       | Nueva versión activa con `Activa__c=true` |
| `PlanDeMantenimientoV2`                               | 24        | 23       | Nueva versión activa                      |
| Resto de los 13                                       | Posterior | Anterior | Nueva versión activa                      |

Los números definitivos que Salesforce asigne deben comprobarse durante la validación; algunos Flows ya tienen versiones Draft posteriores en Producción.

### Objeto y campos

Objeto:

- `Empresa__c`

Campos:

- `Empresa__c.Activa__c`
- `Empresa__c.Codigo__c`
- `Empresa__c.Codigo_ERP__c`
- `Empresa__c.Nombre_Legal__c`
- `Empresa__c.Tipo_Kit_Softland__c`
- `Opportunity.Empresa_Operadora__c`
- `Opportunity.Flag_Vehiculo_Nuevo_FM__c`
- `WorkOrder.empresaFacturaCP__c`
- `WorkOrder.empresaFactura__c`
- `Pricebook2.Empresa__c`
- `Plantilla_de_Presupuesto__c.Empresa_Operadora__c`
- `ServiceTerritory.Empresa__c`
- `Product2.Empresa__c`
- `TipoDeCargoConManoDeObra__c.Empresa__c`
- `User.Empresa__c`

### Record Types

- `Opportunity.Omoda`
- `Opportunity.Jaecoo`
- `Lead.Omoda`
- `Lead.Jaecoo`

### Custom Metadata

- `RM_RecordTypeMapping.Lead_Omoda_to_Opp`
- `RM_RecordTypeMapping.Lead_Jaecoo_to_Opp`

`RM_Config.Default_Price_List_VN` queda excluido porque la metadata comparada es idéntica.

### Seguridad

- `Empresa_Admin`
- `Empresa_Consulta_Flows`
- `Vehiculos_Nuevos_PS`

### Validaciones

- `Opportunity.Cambiar_a_Finalizado_Descuento`
- `Opportunity.Cambiar_a_Finalizado_Formalizacion`
- `Opportunity.Cambiar_Oportunidad_a_Finalizado_VH`
- `Opportunity.Campo_Gustos_y_aficiones_Obligatorio`

### List Views

- `Oportunidades_abiertas_Jaecoo`
- `Oportunidades_abiertas_Omoda`
- `Oportunidades_ganadas_Jaecoo`
- `Oportunidades_ganadas_Omoda`
- `Oportunidades_Perdidas_Jaecoo`
- `Oportunidades_Perdidas_Omoda`
- `Todas_Oportunidades_Perdidas_Jaecoo`
- `Todas_Oportunidades_Perdidas_Omoda`

### Otros

- GVS: `Marca_de_Interes`
- LWC: `rm_vn_crear_opp_general`, `rm_vn_crear_opp_home`, `rm_vn_crear_opp_home_movil`, `get_record_opp_record_types`
- Layout: `Pricebook2-Price Book Layout`

## 4. Datos/configuración fuera de metadata

| RegistroPartialProducciónTratamiento |                                   |                      |                                                                      |
| ------------------------------------ | --------------------------------- | -------------------- | -------------------------------------------------------------------- |
| Empresa Bavarian                     | Existe                            | Objeto aún no existe | Crear después de metadata con valores aprobados                      |
| Empresa Otobai                       | Existe                            | Objeto aún no existe | Crear después de metadata con valores aprobados                      |
| Empresa PEKING                       | `PEKING QA / NO PRODUCCIÓN`       | No existe            | No copiar; solicitar razón social y `Tipo_Kit_Softland__c` oficiales |
| Pricebook PEKING Local               | CRC, activo                       | No existe            | Crear mediante Data Deploy/manual aprobado                           |
| Pricebook PEKING Dólares             | USD, activo                       | No existe            | Crear mediante Data Deploy/manual aprobado                           |
| PBE OMODA/JAECOO                     | Precio QA                         | No existe            | No copiar; faltan precios oficiales                                  |
| Productos OMODA/JAECOO               | Productos QA                      | No existen           | No copiar; falta catálogo oficial                                    |
| Service Territory PEKING             | Temporal                          | No existe            | No copiar; falta territorio oficial                                  |
| Bodega PEKING                        | Temporal/no producción            | No existe            | No copiar; falta código oficial                                      |
| Centros de costo                     | No reconciliados como definitivos | No confirmados       | Confirmación Softland/negocio                                        |
| PermissionSetAssignment              | 28/28 cubiertos en Partial        | IDs distintos        | Asignación post-deploy por identidad validada                        |

Producción tiene **cero Pricebooks, productos, territorios y bodegas PEKING** detectados.

## 5. Exclusiones QA y componentes dudosos

Exclusiones comprobadas:

- Todos los PBE con `UnitPrice=1`.
- `PEKING TEMPORAL - NO PRODUCCION`.
- `PEKING TEMPORAL - PARTIAL - NO USAR EN PRODUCCION`.
- Productos `OMODA QA 2026`, `JAECOO QA 2026`, `QAOMODA...`, `QAJAECOO...`.
- VIN, Assets, Quotes, QLI, Work Orders y evidencias QA.
- Documentos, logs y cierres técnicos.
- Approval Processes revisados sin cambio funcional autorizado.
- `RM_Config.Default_Price_List_VN`, idéntico.
- `ReciboUsado.Empresa__c`, idéntico.
- Apex idéntico señalado anteriormente.
- `Opportunity_Record_Page_VN`: excluida por decisión pendiente de activación/perfiles.
- Layouts de Opportunity: excluidos porque el diff contiene además la eliminación de `Opportunity_Owner__c`, cambio no reconciliado.
- `rm_vn_crear_opp_inventario`: excluido; no fue desplegado y quedó bloqueado.
- `RQ329_*`: excluido del paquete PEKING; requiere release independiente.

## 6. Dependencias principales

| ConsumidorDependencia |                                                                             |
| --------------------- | --------------------------------------------------------------------------- |
| Flows Empresa         | Objeto `Empresa__c`, campos `Activa__c`, `Codigo__c`, `Codigo_ERP__c`       |
| Usuarios funcionales  | `Empresa_Consulta_Flows` y asignaciones posteriores                         |
| Opportunity/Lead      | RT OMODA/JAECOO, GVS y mapeos CMDT                                          |
| Quote/QLI             | Empresa, Pricebook, PBE, Producto y RQ329                                   |
| Work Order            | Empresa, `empresaFactura__c`, `empresaFacturaCP__c`, bodega y territorio    |
| Apex de Pricebook     | `EmpresaPricebookResolver`, Empresa y Pricebook asociado                    |
| Softland              | Empresa, código ERP, bodega, centros de costo y destino externo certificado |
| LWC de creación       | RT, valores de marca y Apex correspondiente                                 |
| Validaciones          | RT/GVS OMODA/JAECOO                                                         |
| E2E funcional         | Datos oficiales posteriores al deploy                                       |

Orden lógico:

1. Metadata base Empresa/campos/GVS.
2. Record Types y Custom Metadata.
3. Apex y trigger.
4. Permission Sets.
5. Flows.
6. LWC, listas y layout.
7. Datos maestros aprobados.
8. Asignaciones de usuarios.
9. Pruebas funcionales.

## 7. Pruebas Apex

Ejecución dirigida en Partial:

- Run ID: `707AK00000JtNuu`
- Clases de prueba: 36
- Métodos: 303
- PASS: 276
- FAIL: 27
- Resultado: **91% PASS**
- Cobertura informada para la ejecución: **60%**
- Cobertura org-wide informada: **34%**

Fallos:

| ClaseFallosCausa observada        |    |                                                                      |
| --------------------------------- | -- | -------------------------------------------------------------------- |
| `BMW_LineaPlantillaEmpresa_Test`  | 1  | La prueba esperaba `EmpresaConfigurationException`, pero no se lanzó |
| `ProductSearcherControllerTest`   | 15 | Setup: valor restringido `Product2.Categor_a_veh_culo__c = Todos`    |
| `ServicioConsDispBodegaQuoliTest` | 5  | Mismo valor restringido inválido                                     |
| `SRAArticulosQuoteTest`           | 5  | Mismo valor restringido inválido                                     |
| `savePDFfileTest`                 | 1  | `AuraHandledException` en `getRelatedFile`                           |

Las pruebas de fundamento Empresa pasaron:

- `EmpresaContextTest`: 9/9
- `EmpresaResolverTest`: 9/9
- `EmpresaPricebookResolverTest`: 19/19
- `http_HelperTest`: 5/5
- `WorkOrderTriggerTest`: 27/27

Los 27 fallos deben corregirse o formalmente reconciliarse antes de una validación de Producción. No hay evidencia para declarar cobertura de deployment ≥75%.

## 8. Estado del paquete Copado

- Nombre sugerido: `PEKING_Empresa_Marcas_Chinas_Prod_20260829`
- Convención real del proyecto: **no verificable**
- Paquete creado: **NO**
- Componentes cargados: **0**
- Estado: **BLOQUEADO**

No se encontró:

- sesión autenticada abierta de Copado;
- URL de Copado verificable;
- organización Salesforce con objetos Copado;
- alias de organización Copado configurado.

No se inventó una URL ni se intentó reemplazar Copado por otro mecanismo.

## 9. Validación contra Producción

| DatoResultado        |               |
| -------------------- | ------------- |
| Validation/Deploy ID | No generado   |
| Total validado       | 0             |
| Componentes exitosos | No ejecutado  |
| Tests Copado         | No ejecutados |
| Cobertura Copado     | No disponible |
| Deploy real          | No            |
| Quick Deploy         | No            |

La comparación read-only de metadata sí se completó, pero **no equivale a una validación Copado**.

## 10. Bloqueos antes del sábado

1. Resolver los 27 tests fallidos.
2. Proporcionar acceso verificable a Copado y confirmar la convención de paquetes.
3. Crear y ejecutar Validate Only del inventario de 130 componentes.
4. Decidir orden de despliegue de RQ329, ausente en Producción.
5. Obtener datos oficiales PEKING:
   - razón social;
   - tipo de kit Softland;
   - Pricebooks;
   - precios;
   - catálogo;
   - bodega;
   - Service Territory;
   - centros de costo.
6. Reconciliar usuarios de Producción:
   - 27/28 nombres tuvieron coincidencia activa;
   - `Claudia Pérez` no tuvo coincidencia activa exacta;
   - validar la identidad técnica correcta de `Auto Login`.
7. Confirmar que `Opportunity_Record_Page_VN` continuará excluida o aprobar su asignación.
8. Certificar el destino Softland antes de cualquier callout.

## 11. Checklist del sábado, 1:00 p. m.

### Pre-deploy

- 27 fallos resueltos/reconciliados.
- Validate Only Copado exitoso.
- Validation ID vigente.
- Inventario Copado exactamente 130 componentes.
- RQ329 desplegado previamente o plan de orden aprobado.
- Datos oficiales aprobados.
- Identidades de usuarios de Producción reconciliadas.
- SHAs de Sprint 5 y Empresa confirmados.
- Worktrees autoritativos limpios.
- Backup Copado configurado.
- Responsables funcionales disponibles.
- Criterios y responsables de rollback confirmados.

### Deploy

- Ejecutar `Deploy with Backup`.
- Registrar Deploy ID.
- Confirmar 130/130 componentes.
- Confirmar tests y cobertura.
- Revisar versiones activas de los 17 Flows.
- Detener si se activa una versión inesperada.

### Post-deploy

- Crear datos maestros aprobados mediante proceso separado.
- Asignar permisos a usuarios reconciliados.
- Ejecutar pruebas PEKING/OMODA/JAECOO.
- Revisar Flow/Apex errors.
- No llamar Softland sin destino certificado.

## 12. Plan de pruebas post-deploy

1. Empresa PEKING visible, activa y con códigos oficiales.
2. Opportunity OMODA.
3. Opportunity JAECOO.
4. Quote con Pricebook y moneda correctos.
5. QuoteLineItem editable.
6. RQ329 no bloquea línea editable, solo si su release ya entró.
7. RQ329 bloquea Quote origen de solo consulta.
8. Creación de Work Order.
9. Exactamente una WOLI por QLI.
10. `Enviado_a_la_orden__c = true`.
11. Empresa, Pricebook, moneda, bodega y ubicación correctos.
12. Sin duplicados.
13. Acceso funcional a `Activa__c` y `Codigo_ERP__c`.
14. Versiones activas correctas.
15. Revisión de errores posteriores.
16. Factura/Softland queda **NO EJECUTABLE** hasta certificar el destino.

## 13. Plan de rollback

Criterios de rollback:

- error de metadata;
- cobertura o tests no aceptables;
- Flow incorrecto activo;
- error FLS para población funcional;
- contaminación entre empresas;
- duplicación de WOLI;
- Pricebook/moneda/bodega incorrectos;
- regresión transversal en Quote/Work Order.

Ejecución:

1. Restaurar metadata mediante el backup de Copado.
2. Reactivar versiones previas de Flows.
3. Verificar Apex, permisos y Record Types restaurados.
4. Volver a ejecutar pruebas mínimas.
5. Registrar por separado cualquier dato creado.

No son automáticamente reversibles:

- Empresas;
- Pricebooks y PBE;
- productos;
- territorios;
- bodegas;
- asignaciones de Permission Sets.

Estos datos requieren bitácora de IDs y rollback manual previamente aprobado.

## 14. Estado Git final

| WorktreeRamaHEADEstado   |                                                                                |                                            |                                         |
| ------------------------ | ------------------------------------------------------------------------------ | ------------------------------------------ | --------------------------------------- |
| RedMotorsPartial-Sandbox | `feature/pc/redmotors-vn-rq106-anticipo-ui-20260527`                           | `8982dad8e85ede3eeb6202cb50b1f237e2057712` | Limpio, 0/0                             |
| Sprint 2                 | `feature/pc/redmotors-empresa-marcas-chinas-sprint2-flows-components-20260728` | `05bbd1495868389e8eae06096bfd7be29709b471` | Sucio por cambios preexistentes         |
| Sprint 3                 | `feature/pc/redmotors-empresa-marcas-chinas-sprint3-continuidad-20260813`      | `fa51018391280e9589368df663d05474528178b7` | Sucio: `lwc/jsconfig.json` preexistente |
| Sprint 5                 | `feature/pc/redmotors-empresa-marcas-chinas-sprint5-pricebooks-e2e-20260819`   | `52bac0a9eb07a65f904c545f1bb52ca53dc8eb12` | Limpio, 0/0                             |
| Empresa/FLS              | `fix/empresa-fls-flows-partial-20260824`                                       | `c2ca3ef33b945c768ce069ac6ea5c660a153972f` | Limpio, 0/0                             |

El estado sucio de Sprint 2 y Sprint 3 era preexistente y no fue alterado. No se ejecutaron merge, rebase, reset, clean, stash, commit ni push.

**Conclusión exacta:** el alcance de metadata está inventariado, pero el paquete no está preparado ni validado. El pase del sábado debe permanecer en **NO GO** hasta obtener una validación Copado verde, resolver los fallos Apex y completar las decisiones/datos operativos señalados. La notificación ntfy se envió correctamente una sola vez.