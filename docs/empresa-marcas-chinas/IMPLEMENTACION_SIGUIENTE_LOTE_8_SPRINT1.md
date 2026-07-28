# Implementación siguiente lote 8 Sprint 1

- Las ocho clases productivas fueron reconciliadas desde la fuente exacta de Partial ubicada en `_partial_snapshot/classes`.
- No se introdujo ningún cambio funcional nuevo; la versión de Partial fue la única fuente de verdad para esta reconciliación.
- Se reemplazaron las siguientes clases y sus archivos `.cls-meta.xml` cuando correspondía:
  - `QuoteSoftlandPedidoService`
  - `QuoteSoftlandQueryService`
  - `servicioReservas`
  - `servicioEliminarReserva`
  - `OpportunityServiceInvoker`
  - `Registrar_Anticipo_Controller`
  - `QuoteService`
  - `productJSON`
- Se reconciliaron pruebas y mocks desde Partial solo cuando eran diferentes:
  - `TestServiciosQuote`
  - `servicioReservasTest`
  - `servicioReservasMock`
  - `servicioEliminarReservaTest`
  - `servicioEliminarReservaMock`
  - `OpportunityServiceInvokerTest`
  - `Registrar_Anticipo_Controller_Test`
  - `RegistrarAnticipoCasillasTst`
  - `QuoteServiceControllerTest`
  - `RM_VN_QuoteController_Test`
  - `productJSONTest`
- Se confirmó especialmente que:
  - `QuoteSoftlandQueryService` conserva `BMW_Aseguradora__r.Name` y `Empresa_Operadora__c`.
  - `QuoteSoftlandPedidoService` mantiene la resolución explícita de empresa.
  - `servicioReservas` conserva el bloqueo controlado de `RMPEKING`.
  - `servicioEliminarReserva` conserva los bloqueos explícitos de `RMOTOBAI` y `RMPEKING`.
  - `OpportunityServiceInvoker` y `Registrar_Anticipo_Controller` no recuperan el default `RMBAVARIAN` de manera no autorizada.
  - `QuoteService` no recupera `getPricebookName`.
  - `RM_VN_QuoteController_Test` no llama `getPricebookName`.
  - `productJSON` conserva la validación previa de empresa y bodega.
- Se descartó el cambio en `force-app/main/default/lwc/jsconfig.json`.
- `_partial_snapshot` fue eliminado completamente antes del commit.
- `Partial` no está incluido en el commit final.

## Limitaciones pendientes

- Siguen pendientes las limitaciones externas relacionadas con reservas, bodegas, anticipos y los registros de `Empresa__c`.
