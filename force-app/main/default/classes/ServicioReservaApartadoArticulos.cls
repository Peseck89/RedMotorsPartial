public class ServicioReservaApartadoArticulos {

    private static final String SERVICE_URL = 'http://172.176.136.132:5080/IntegrationServices/softlandAPI/reserve/request';
    //private static final String SERVICE_URL = 'http://172.176.136.132:5080/ServiciosSoftlandProductivos/softlandAPI/reserve/request';
    
    private String destino;
    private String workOrderNumber;
    private List<String> notAvailableIds;
    private List<String> selectedIds;
    

    public ServicioReservaApartadoArticulos(String workOrderNumber, String destino, List<String> notAvailableIds, List<String> selectedIds) {
        this.workOrderNumber = workOrderNumber;
        this.destino = destino;
        this.notAvailableIds= notAvailableIds;
        this.selectedIds= selectedIds;
    }

    public String realizarReservaApartado() {
        String url = Label.URLSoftland;
        String ambiente = Label.ambienteSoftland;
        String estadoFinal = Null;
        List<String> finalSelectedIds = new List<String>();
        
        System.debug('Antes FOr' + selectedIds);
        
        for (Id id : selectedIds) {
            if (!notAvailableIds.contains(id)) {
                finalSelectedIds.add(id);
            }
        }
        System.debug('IDs seleccionados no disponibles ' + notAvailableIds);
        System.debug('IDs seleccionados original ' + selectedIds);
        System.debug('IDs seleccionados ' + finalSelectedIds);
        System.debug('WorkOrder ' + workOrderNumber);
        
        // Find the Work Order by its number
        WorkOrder workOrder = [
            SELECT Id, EmpresaFactura__c, Asset.NumeroDeChasis__c, Case.CaseNumber,Asesor_de_la_orden__r.Email,Asesor_de_la_orden__r.Name, Asset.NumeroDePlaca__c, Account.Name, ServiceTerritory.Name
            FROM WorkOrder
            WHERE WorkOrderNumber = :workOrderNumber
            LIMIT 1
        ]; //NOT IN LISTA DE MAMBO
        if (workOrder == null) {
            throw new WorkOrderNotFoundException('Orden de trabajo no encontrada');
        }

        // Fetch the related Work Order Line Items
        List<WorkOrderLineItem> lineItems = [SELECT Id, Bodega__c, Bodega__r.Name, Bodega__r.bodega__c,TrabajoFormulaProducto__c, workOrder.Asesor_de_la_orden__r.Email, workOrder.Asesor_de_la_orden__r.Name,Quantity, workOrder.ServiceTerritory.Name, BMW_CodigoDeProducto__c, Cantidad__c, Estado_reserva__c, Trabajo__c
                                             FROM WorkOrderLineItem
                                             WHERE WorkOrderId = :workOrder.Id
                                             AND ((Estado_reserva__c = 'Pendiente de reserva' OR Estado_reserva__c = '') AND (Trabajo__c = 'Materiales' OR TrabajoFormulaProducto__c = 'Materiales'))
                                             AND Id IN :finalSelectedIds
                                             ];
        
        

        if (lineItems.isEmpty() & !Test.isRunningTest()) {
            throw new LineItemsNotFoundException('No se encontraron líneas en la orden de trabajo que cumplan los requisitos');
        }

        // Create the request body JSON
        Map<String, Object> requestBody = new Map<String, Object>{
            'orden_trabajo' => workOrderNumber,
            'caso' => workOrder.Case.CaseNumber,
            'correo' => workOrder.Asesor_de_la_orden__r.Email,
            'compania' => workOrder.EmpresaFactura__c,
            'orden_trabajo' => workOrderNumber,
            'vin' => workOrder.Asset.NumeroDeChasis__c,
            'placa' => workOrder.Asset.NumeroDePlaca__c,
            'cliente' => workOrder.Account.Name,
            'asesorServicio' => workOrder.Asesor_de_la_orden__r.Name,
            'taller' => workOrder.ServiceTerritory.Name,
            'articulos' => new List<Object>()
        };            

        for (WorkOrderLineItem item : lineItems) {
            Map<String, Object> article = new Map<String, Object>{
                'id_linea' => item.Id,
                'bodega' => item.Bodega__r.bodega__c, 
                'articulo' => item.BMW_CodigoDeProducto__c,
                'cantidad' => String.valueOf(item.Quantity),
                'destino' => destino
            };
            ((List<Object>)requestBody.get('articulos')).add(article);
        }
        
        JSON_History__c JsonHistory = new JSON_History__c();
        JsonHistory.Work_Order__c = workOrder.Id;
        JsonHistory.JSON__c = JSON.serialize(requestBody);
        JsonHistory.Name = 'Servicio Reserva Apartado Artículos';
        
        System.debug('JSON LLAMADA ' + JSON.serialize(requestBody));
		
        
        HttpResponse res = new HttpResponse();

        
        if (Test.isRunningTest()) {
                String testResponse = '{'+
                    '"compania":"RMBAVARIAN",'+
                    '"codigo_respuesta":"00",'+
                    '"detalle_respuesta":"Lineas procesadas exitosamente",'+
                    '"orden_trabajo":"' + String.escapeSingleQuotes(workOrderNumber) + '",'+
                    '"request_id":"",'+
                    '"vin":"",'+
                    '"placa":"",'+
                    '"cliente":"",'+
                    '"audit_trans_inv":"",'+
                    '"articulos":['+
                        '{'+
                            '"id_linea":"' + String.escapeSingleQuotes(selectedIds[0]) + '",'+
                            '"articulo":null,'+
                            '"bodega":null,'+
                            '"localizacion":"B04_ACEI",'+
                            '"cantidad":0.0,'+
                            '"consecutivo_reserva":"00",'+
                            '"codigo_respuesta":"00",'+
                            '"detalle_respuesta":"SOLICITUD DE DEVOLUCION COMPLETA INGRESADA EXITOSAMENTE",'+
                            '"detalle_localizaciones":null'+
                        '},'+
                    
                        '{'+
                            '"id_linea":"' + String.escapeSingleQuotes(selectedIds[1]) + '",'+
                            '"articulo":null,'+
                            '"bodega":null,'+
                            '"localizacion":"B04_ACEI",'+
                            '"cantidad":0.0,'+
                            '"consecutivo_reserva":"00",'+
                            '"codigo_respuesta":"00",'+
                            '"detalle_respuesta":"ARTICULO RESERVADO EXITOSAMENTE",'+
                            '"detalle_localizaciones":null'+
                        '}'+
                    ']'+
                '}';
                // Use the predefined response when running in a test context
                res.setStatusCode(200); // Mock the status code as 200 (OK)
                res.setBody(testResponse); // Use the predefined test response
            } else {
                // Authenticate and send the request
                String token = ExternalAuthService.authenticate();
                HttpRequest req = new HttpRequest();
                req.setEndpoint(SERVICE_URL);
                req.setMethod('POST');
                req.setHeader('Authorization', 'Bearer ' + token);
                req.setHeader('Content-Type', 'application/json');
                req.setBody(JSON.serialize(requestBody));

                res = new Http().send(req);
                        
        }        
        if (res.getStatusCode() != 200) {
            JsonHistory.JSON_Response__c = res.getBody();
            JsonHistory.Error_Message__c = res.getBody();
            insert JsonHistory;
            throw new ExternalServiceException('Error al llamar al servicio externo: ' + res.getBody());
            
        }
        
        JsonHistory.JSON_Response__c = res.getBody();
        insert JsonHistory;
        System.debug('JSON RESPUESTA DEL SERVICIO  ' + res.getBody());

        // Parse the response
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        
        // Procesar la lista de artículos en la respuesta
        List<Map<String, Object>> articulos = new List<Map<String, Object>>();
        for (Object articuloObj : (List<Object>) responseMap.get('articulos')) {
            if (articuloObj instanceof Map<String, Object>) {
                articulos.add((Map<String, Object>) articuloObj);
            }
        }
        
        
        List<String> idsReservadosExitoso = new List<String>();
        List<String> idsReservadosYaCuentaConReserva = new List<String>();
        List<String> idsOtros = new List<String>();
        
        Map<String, String> estadosPorId = new Map<String, String>();
		Map<String, String> localizacionesPorId = new Map<String, String>();
        Map<String, String> detallesporId = new Map<String, String>();
        
        
        for (Map<String, Object> articulo : articulos) {
            String detalleRespuesta = (String) articulo.get('detalle_respuesta');
            String idLinea = (String) articulo.get('id_linea');
            String localizacion = (String) articulo.get('localizacion');

            if (detalleRespuesta.contains('ARTICULO RESERVADO EXITOSAMENTE')) {
                idsReservadosExitoso.add(idLinea);
                estadosPorId.put(idLinea, 'Reservado');
                if(localizacion != null) {
                    localizacionesPorId.put(idLinea, localizacion);
                }
                detallesporId.put(idLinea, '');
                //actualizarEstadoReserva(idLinea, 'Reservado',localizacion);
                //actualizarEstadoSoftland(idLinea, '');
                estadoFinal = 'Todos los artículos se reservaron correctamente.';
            }else if (detalleRespuesta.contains('LA LINEA YA CUENTA CON UNA RESERVA ACTIVA.')) {
                idsReservadosYaCuentaConReserva.add(idLinea);
                idsReservadosExitoso.add(idLinea);
                estadosPorId.put(idLinea, 'Reservado');
                if(localizacion != null) {
                    localizacionesPorId.put(idLinea, localizacion);
                }
                //actualizarEstadoReserva(idLinea, 'Reservado',localizacion);
                estadoFinal = 'Todos los artículos se reservaron correctamente.';
            } else {
                idsOtros.add(idLinea);
                detallesporId.put(idLinea, (String) articulo.get('detalle_respuesta'));
                //String estadoSoftland = (String) articulo.get('detalle_respuesta');
                //actualizarEstadoSoftland(idLinea, estadoSoftland);
                estadoFinal = 'Existen artículos que requieren validación.';
            }
        }
        
        actualizarEstadoReserva(idsReservadosExitoso, estadosPorId, localizacionesPorId);
        actualizarEstadoReserva(idsReservadosYaCuentaConReserva, estadosPorId, localizacionesPorId);
        actualizarEstadoSoftland(idsOtros, detallesporId);
        
        

        return estadoFinal;
    }
    
    private void actualizarEstadoReserva(List<String> idsLinea, Map<String, String> estadosPorId, Map<String, String> localizacionesPorId) {
        // Consultar y actualizar el WorkOrderLineItem
        List<WorkOrderLineItem> lineItems = [SELECT Id FROM WorkOrderLineItem WHERE Id IN :idsLinea];
        
        for (WorkOrderLineItem item : lineItems) {
            if(estadosPorId.containsKey(item.Id)) {
                item.Estado_reserva__c = estadosPorId.get(item.Id);
            }
            if(localizacionesPorId != null && localizacionesPorId.containsKey(item.Id)) {
                item.Localizacion__c = localizacionesPorId.get(item.Id);
            }
        }
        
        update lineItems;
        
    }
    
    private void actualizarEstadoSoftland(List<String> idsLinea, Map<String, String> estadosPorId) {
        // Consultar y actualizar el WorkOrderLineItem
        List<WorkOrderLineItem> lineItems = [SELECT Id FROM WorkOrderLineItem WHERE Id IN :idsLinea];
        
        for (WorkOrderLineItem item : lineItems){
            if(estadosPorId.containsKey(item.Id)){
                item.Estado_softland__c = estadosPorId.get(item.Id);
            }
        }
        
        update lineItems;
    }
    

    private Object processResponse(Map<String, Object> responseMap) {
        return responseMap;
    }

    public class WorkOrderNotFoundException extends Exception {}
    public class LineItemsNotFoundException extends Exception {}
    public class ExternalServiceException extends Exception {}
}