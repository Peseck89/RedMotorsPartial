public class ServicioEliminarReservaArticulo {

    //private static final String SERVICE_URL = 'http://172.176.136.132:5080/IntegrationServices/softlandAPI/reserve/delete';
    private static final String SERVICE_URL = 'http://172.176.136.132:5080/ServiciosSoftlandProductivos/softlandAPI/reserve/delete';
    private String workOrderNumber;
    private List<String> lineItemIds;

    public ServicioEliminarReservaArticulo(String workOrderNumber, List<String> lineItemIds) {
        this.workOrderNumber = workOrderNumber;
        this.lineItemIds = lineItemIds;
        
    }

    public String eliminarReservaArticulos() {
        String url = Label.URLSoftland;
        String ambiente = Label.ambienteSoftland;
        String estadoFinal = 'Se eliminaron todos los artículos exitosamente.';

        filterLineItemIdsByEstadoEntrega();
        
        WorkOrder workOrder = [
            SELECT Id, EmpresaFactura__c, Asset.NumeroDeChasis__c, Asset.NumeroDePlaca__c, Account.codigoSoftland__c
            FROM WorkOrder
            WHERE WorkOrderNumber = :workOrderNumber
            LIMIT 1
        ];

        // Consultar Cantidad_devolucion para cada LineItem
        Map<String, Decimal> lineItemDevolutionQuantities = new Map<String, Decimal>();
        for (String lineItemId : lineItemIds) {
            WorkOrderLineItem lineItem = [SELECT Id, Cantidad_devolucion__c FROM WorkOrderLineItem WHERE Id = :lineItemId LIMIT 1];
            lineItemDevolutionQuantities.put(lineItemId, lineItem.Cantidad_devolucion__c);
        }

        // Crear el request body JSON
        Map<String, Object> requestBody = new Map<String, Object>{
            'compania' => workOrder.EmpresaFactura__c,
            'orden_trabajo' => workOrderNumber,
            'vin' => workOrder.Asset.NumeroDeChasis__c,
            'placa' => workOrder.Asset.NumeroDePlaca__c,
            'cliente' => workOrder.Account.codigoSoftland__c,
            'articulos' => new List<Object>()
        };

        for (String lineItemId : lineItemIds) {
            Decimal devolutionQuantity = lineItemDevolutionQuantities.get(lineItemId);
            Decimal cantidad;
            // Comprueba si la cantidad de devolución es 0
            // 
            if(devolutionQuantity == 0){
                cantidad = null;
                
            }else{
                cantidad = devolutionQuantity;
            }
        
            Map<String, Object> article = new Map<String, Object>{
                'id_linea' => lineItemId,
                'cantidad' => cantidad  // Establece la cantidad o null
            };
            ((List<Object>)requestBody.get('articulos')).add(article);
        }


        System.debug('JSON LLAMADA SERVICIO ' + JSON.serialize(requestBody));
		HttpResponse res = new HttpResponse();

        
        if (Test.isRunningTest()) {
            String testResponse = '{'+
                '"compania":"RMBAVARIAN",'+
                '"codigo_respuesta":"00",'+
                '"detalle_respuesta":"Lineas procesadas exitosamente",'+
                '"orden_trabajo":"' + String.escapeSingleQuotes(workOrderNumber) + '",'+
                '"request_id":null,'+
                '"vin":"12312321",'+
                '"placa":"Cocheprueba",'+
                '"cliente":"Luis Antonio Dorantes Pérez",'+
                '"audit_trans_inv":"",'+
                '"articulos":['+
                    '{'+
                        '"id_linea":"' + String.escapeSingleQuotes(lineItemIds[0]) + '",'+
                        '"articulo":"L00078",'+
                        '"bodega":"BR01",'+
                        '"localizacion":"B04_ACEI",'+
                        '"cantidad":1.0,'+
                        '"consecutivo_reserva":"ARTICULO RESERVADO EXITOSAMENTE.",'+
                        '"codigo_respuesta":"00",'+
                        '"detalle_respuesta":"SOLICITUD DE DEVOLUCION COMPLETA INGRESADA EXITOSAMENTE",'+
                        '"detalle_localizaciones":['+
                            '{'+
                                '"localizacion":"B04_ACEI",'+
                                '"cantidad":1.0'+
                            '}'+
                        ']'+
                    '},'+
                	'{'+
                        '"id_linea":"' + String.escapeSingleQuotes(lineItemIds[1]) + '",'+
                        '"articulo":"L00078",'+
                        '"bodega":"BR01",'+
                        '"localizacion":"B04_ACEI",'+
                        '"cantidad":1.0,'+
                        '"consecutivo_reserva":"ARTICULO RESERVADO EXITOSAMENTE.",'+
                        '"codigo_respuesta":"00",'+
                        '"detalle_respuesta":"LINEA ELIMINADA EXITOSAMENTE",'+
                        '"detalle_localizaciones":['+
                            '{'+
                                '"localizacion":"B04_ACEI",'+
                                '"cantidad":1.0'+
                            '}'+
                        ']'+
                    '},'+
                	'{'+
                        '"id_linea":"' + String.escapeSingleQuotes(lineItemIds[2]) + '",'+
                        '"articulo":"L00078",'+
                        '"bodega":"BR01",'+
                        '"localizacion":"B04_ACEI",'+
                        '"cantidad":1.0,'+
                        '"consecutivo_reserva":"ARTICULO RESERVADO EXITOSAMENTE.",'+
                        '"codigo_respuesta":"00",'+
                        '"detalle_respuesta":"SOLICITUD DE DEVOLUCION PARCIAL INGRESADA EXITOSAMENTE",'+
                        '"detalle_localizaciones":['+
                            '{'+
                                '"localizacion":"B04_ACEI",'+
                                '"cantidad":1.0'+
                            '}'+
                        ']'+
                    '},'+
                    '{'+
                        '"id_linea":"' + String.escapeSingleQuotes(lineItemIds[3]) + '",'+
                        '"articulo":"L00078",'+
                        '"bodega":"BR01",'+
                        '"localizacion":"B04_ACEI",'+
                        '"cantidad":1.0,'+
                        '"consecutivo_reserva":"ARTICULO RESERVADO EXITOSAMENTE.",'+
                        '"codigo_respuesta":"00",'+
                        '"detalle_respuesta":"ERROR EN SOFTLAND",'+
                        '"detalle_localizaciones":['+
                            '{'+
                                '"localizacion":"B04_ACEI",'+
                                '"cantidad":1.0'+
                            '}'+
                        ']'+
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
        
        JSON_History__c JsonHistory = new JSON_History__c();
        JsonHistory.Work_Order__c = workOrder.Id;
        JsonHistory.JSON__c = JSON.serialize(requestBody);
        JsonHistory.Name = 'Servicio Eliminar Reserva Apartado Artículos';
        JsonHistory.JSON_Response__c = res.getBody();
        
        System.debug('Respuesta ' + JSON.serialize(requestBody));
        
        if (res.getStatusCode() != 200) {
            throw new ExternalServiceException('Error al llamar al servicio externo: ' + res.getBody());
        }

        System.debug('JSON RESPUESTA DEL SERVICIO  ' + res.getBody());

        Map<String, Object> responseMap;
        try {
            // Parse the response
            responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());

            List<Map<String, Object>> articulos = new List<Map<String, Object>>();
            List<Object> articulosAny = (List<Object>) responseMap.get('articulos');
            
            System.debug('Articulos  ' + articulosAny);

            List<String> lineItemIdsToDelete = new List<String>();
            List<String> lineItemIdsToUpdate = new List<String>();

            for (Object item : articulosAny) {
                Map<String, Object> articuloMap = (Map<String, Object>) item;
                System.debug('ArticuloMap: ' + articuloMap );
                String detalleRespuesta = (String) articuloMap.get('detalle_respuesta');
                String idLinea = (String) articuloMap.get('id_linea');
                String codigoRespuesta = (String) articuloMap.get('codigo_respuesta');

                System.debug('detalleRespuesta: ' + detalleRespuesta + 'Id: '+ idLinea);

                if (detalleRespuesta.contains('LINEA ELIMINADA EXITOSAMENTE')) {
                    // Agregar el id_linea a la lista de IDs a eliminar
                    lineItemIdsToDelete.add(idLinea);
                } else if (detalleRespuesta.contains('SOLICITUD DE DEVOLUCION COMPLETA INGRESADA EXITOSAMENTE')) {
                    // Actualizar el WorkOrderLineItem con Estado_softland   
                    actualizarEstadoSoftland(idLinea, 'Pendiente entregar en bodega');
                    estadoFinal = 'Existen artículos que requieren validación.';
                    System.debug('JSON RESPUESTA Devolucion COMPLETA  ');
                } else if (detalleRespuesta.contains('SOLICITUD DE DEVOLUCION PARCIAL INGRESADA EXITOSAMENTE')) {
                    // Actualizar el WorkOrderLineItem con Estado_softland   ----   SOLICITUD DE DEVOLUCION INGRESADA EXITOSAMENTE
                    actualizarEstadoSoftlandDevolucionParcial(idLinea, 'Solicitud de devolución parcial ingresada');
                    estadoFinal = 'Existen artículos que requieren validación.';
                    System.debug('JSON RESPUESTA Devolucion Parcial  ');
                }else if (detalleRespuesta.contains('DEVOLUCION PARCIAL INGRESADA EXITOSAMENTE')) {
                    // Agregar el id_linea a la lista de IDs a eliminar
                    lineItemIdsToUpdate.add(idLinea);
                }else {
                    // Actualizar el WorkOrderLineItem con Estado_softland
                    actualizarEstadoErrorSoftland(idLinea, detalleRespuesta);
                    estadoFinal = 'Existen artículos que requieren validación.';
                }
            }

            // Realizar la eliminación de los WorkOrderLineItem
            eliminarWorkOrderLineItems(lineItemIdsToDelete);
            editarWorkOrderLineItems(lineItemIdsToUpdate);
        } catch (Exception e) {
            // Manejar la excepción en caso de error
            System.debug('Error al procesar la respuesta JSON: ' + e.getMessage());
        }

        return estadoFinal;
    }

    private void actualizarEstadoSoftland(String idLinea, String estado) {
        // Consultar y actualizar el WorkOrderLineItem con Estado_softland
        WorkOrderLineItem lineItem = [SELECT Id FROM WorkOrderLineItem WHERE Id = :idLinea LIMIT 1];
        if (lineItem != null) {
            lineItem.Estado_softland__c = estado;
            lineItem.Estado_entrega__c = 'Pendiente de devolución';

            update lineItem;
        }
    }
    
    private void actualizarEstadoSoftlandDevolucionParcial(String idLinea, String estado) {
        // Consultar y actualizar el WorkOrderLineItem con Estado_softland
        WorkOrderLineItem lineItem = [SELECT Id FROM WorkOrderLineItem WHERE Id = :idLinea LIMIT 1];
        if (lineItem != null) {
            lineItem.Estado_softland__c = estado;
            lineItem.Estado_entrega__c = 'Pendiente devolución parcial';

            update lineItem;
        }
    }

    private void actualizarEstadoErrorSoftland(String idLinea, String detalleRespuesta) {
        // Consultar y actualizar el WorkOrderLineItem con Estado_softland
        WorkOrderLineItem lineItem = [SELECT Id FROM WorkOrderLineItem WHERE Id = :idLinea LIMIT 1];
        if (lineItem != null) {
            lineItem.Estado_softland__c = detalleRespuesta;

            update lineItem;
        }
    }

    private void eliminarWorkOrderLineItems(List<String> idsToDelete) {
        try {
            // Eliminar los WorkOrderLineItem
            List<WorkOrderLineItem> lineItemsToDelete = [SELECT Id FROM WorkOrderLineItem WHERE Id IN :idsToDelete];
            System.debug('Lista: ' + lineItemsToDelete);

            if (!lineItemsToDelete.isEmpty()) {
                delete lineItemsToDelete;
                System.debug('Eliminados');
            } else {
                System.debug('No se encontraron registros para eliminar.');
            }
        } catch (Exception e) {
            System.debug('Error al eliminar WorkOrderLineItem: ' + e.getMessage());
        }
    }
    
    private void editarWorkOrderLineItems(List<String> idsToEdit) {
        try {
            List<WorkOrderLineItem> lineItemsToEdit = [SELECT Id, Quantity, Cantidad_devolucion__c FROM WorkOrderLineItem WHERE Id IN :idsToEdit];
            
            if (!lineItemsToEdit.isEmpty()) {
                lineItemsToEdit[0].Quantity = lineItemsToEdit[0].Quantity - lineItemsToEdit[0].Cantidad_devolucion__c;
                lineItemsToEdit[0].Cantidad_devolucion__c = 0;
                System.debug('actualizar');
            } else {
                System.debug('No se encontraron registros para actualizar.');
            }
        } catch (Exception e) {
            System.debug('Error al eliminar WorkOrderLineItem: ' + e.getMessage());
        }
    }
    
    private void filterLineItemIdsByEstadoEntrega() {
        List<String> filteredLineItemIds = new List<String>();
        for (String lineItemId : lineItemIds) {
            WorkOrderLineItem lineItem = [
                SELECT Id, Estado_entrega__c FROM WorkOrderLineItem WHERE Id = :lineItemId AND Estado_entrega__c != 'Pendiente devolución nota de crédito' LIMIT 1
            ];
            if (lineItem != null) {
                filteredLineItemIds.add(lineItemId);
            }
        }
        lineItemIds = filteredLineItemIds;
    }

    

    public class ExternalServiceException extends Exception {}
}