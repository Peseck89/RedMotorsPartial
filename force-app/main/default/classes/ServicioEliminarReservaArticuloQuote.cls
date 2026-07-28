public class ServicioEliminarReservaArticuloQuote {
    private static final String SERVICE_URL = 'http://172.176.136.132:5080/ServiciosSoftlandProductivos/softlandAPI/Opportunities/deleteRequest';
    //private static final String SERVICE_URL = 'http://172.176.136.132:5080/IntegrationServices/softlandAPI/Opportunities/deleteRequest;
	private String quoteNumber;
    private List<String> lineItemIds;

    public ServicioEliminarReservaArticuloQuote(String quoteNumber, List<String> lineItemIds) {
        this.quoteNumber = quoteNumber;
        this.lineItemIds = lineItemIds;
    }

    public String eliminarReservaArticulos() {
        String url = Label.URLSoftland;
        String ambiente = Label.ambienteSoftland;
        String estadoFinal = 'Se eliminaron todos los artículos exitosamente.';

        filterLineItemIdsByEstadoReserva();
        
        
        System.debug('Quote number ' + quoteNumber);
        
        Quote quote = [
            SELECT Id, Opportunity.BMW_Compania__c, Opportunity.Empresa_Operadora__c, quote.Opportunity.Id_Oportunidad__c, Opportunity.BMW_PlacaDeVehiculoOElVIN__r.NumeroDeChasis__c, Opportunity.BMW_PlacaDeVehiculoOElVIN__r.NumeroDePlaca__c, Opportunity.Account.codigoSoftland__c
            FROM Quote
            WHERE QuoteNumber = :quoteNumber
            LIMIT 1
        ];

        // Consultar Cantidad_devolucion para cada LineItem
        Map<String, Decimal> lineItemDevolutionQuantities = new Map<String, Decimal>();
        for (String lineItemId : lineItemIds) {
            QuoteLineItem lineItem = [SELECT Id, Cantidad_devolucion__c FROM QuoteLineItem WHERE Id = :lineItemId LIMIT 1];
            lineItemDevolutionQuantities.put(lineItemId, lineItem.Cantidad_devolucion__c);
        }
        QuoteSoftlandApiLogService apiLog = new QuoteSoftlandApiLogService('Eliminar Reserva - Quote', Quote.Id); 
        
		String empresa = resolveCompanyCode(quote);

        // Crear el request body JSON
        Map<String, Object> requestBody = new Map<String, Object>{
            'compania' => empresa,
            'oportunidad' => quote.Opportunity.Id_Oportunidad__c,
            'orden_trabajo' => quoteNumber,
            'vin' => quote.Opportunity.BMW_PlacaDeVehiculoOElVIN__r.NumeroDeChasis__c,
            'placa' => quote.Opportunity.BMW_PlacaDeVehiculoOElVIN__r.NumeroDePlaca__c,
            'cliente' => quote.Opportunity.Account.codigoSoftland__c,
            'articulos' => new List<Object>()
        };

        for (String lineItemId : lineItemIds) {
            Decimal devolutionQuantity = lineItemDevolutionQuantities.get(lineItemId);
            Decimal cantidad = (devolutionQuantity == 0) ? null : devolutionQuantity;

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
                '"orden_trabajo":"' + String.escapeSingleQuotes(quoteNumber) + '",'+
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
        
       
        apiLog.setRequest(JSON.serialize(requestBody));
        
        System.debug('Respuesta ' + JSON.serialize(requestBody));
        
        if (res.getStatusCode() != 200) {
            throw new ExternalServiceException('Error al llamar al servicio externo: ' + res.getBody());
        }

        System.debug('JSON RESPUESTA DEL SERVICIO  ' + res.getBody());
        
        apiLog.setResponse(res.getBody());
        apiLog.saveLog();

        Map<String, Object> responseMap;
        try {
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

                System.debug('detalleRespuesta: ' + detalleRespuesta + 'Id: '+ idLinea);

                if (detalleRespuesta.contains('LINEA ELIMINADA EXITOSAMENTE')) {
                    lineItemIdsToDelete.add(idLinea);
                } else if (detalleRespuesta.contains('SOLICITUD DE DEVOLUCION COMPLETA INGRESADA EXITOSAMENTE')) {
                    actualizarEstadoSoftland(idLinea, 'Pendiente entregar en bodega');
                    estadoFinal = 'Existen artículos que requieren validación.';
                    System.debug('JSON RESPUESTA Devolucion COMPLETA  ');
                } else if (detalleRespuesta.contains('SOLICITUD DE DEVOLUCION PARCIAL INGRESADA EXITOSAMENTE')) {
                    actualizarEstadoSoftlandDevolucionParcial(idLinea, 'Solicitud de devolución parcial ingresada');
                    estadoFinal = 'Existen artículos que requieren validación.';
                    System.debug('JSON RESPUESTA Devolucion Parcial  ');
                } else {
                    actualizarEstadoErrorSoftland(idLinea, detalleRespuesta);
                    estadoFinal = 'Existen artículos que requieren validación.';
                }
            }

            eliminarQuoteLineItems(lineItemIdsToDelete);
            editarQuoteLineItems(lineItemIdsToUpdate);
        } catch (Exception e) {
            System.debug('Error al procesar la respuesta JSON: ' + e.getMessage());
        }

        return estadoFinal;
    }

    private void actualizarEstadoSoftland(String idLinea, String estado) {
        QuoteLineItem lineItem = [SELECT Id FROM QuoteLineItem WHERE Id = :idLinea LIMIT 1];
        if (lineItem != null) {
            lineItem.Estado_softland__c = estado;
            lineItem.Estado_entrega__c = 'Pendiente de devolución';

            update lineItem;
        }
    }
    
    private void actualizarEstadoSoftlandDevolucionParcial(String idLinea, String estado) {
        QuoteLineItem lineItem = [SELECT Id FROM QuoteLineItem WHERE Id = :idLinea LIMIT 1];
        if (lineItem != null) {
            lineItem.Estado_softland__c = estado;
            lineItem.Estado_entrega__c = 'Pendiente devolución parcial';

            update lineItem;
        }
    }

    private void actualizarEstadoErrorSoftland(String idLinea, String detalleRespuesta) {
        QuoteLineItem lineItem = [SELECT Id FROM QuoteLineItem WHERE Id = :idLinea LIMIT 1];
        if (lineItem != null) {
            lineItem.Estado_softland__c = detalleRespuesta;

            update lineItem;
        }
    }

    private void eliminarQuoteLineItems(List<String> idsToDelete) {
        try {
            List<QuoteLineItem> lineItemsToDelete = [SELECT Id FROM QuoteLineItem WHERE Id IN :idsToDelete];
            System.debug('Lista: ' + lineItemsToDelete);

            if (!lineItemsToDelete.isEmpty()) {
                delete lineItemsToDelete;
                System.debug('Eliminados');
            } else {
                System.debug('No se encontraron registros para eliminar.');
            }
        } catch (Exception e) {
            System.debug('Error al eliminar QuoteLineItem: ' + e.getMessage());
        }
    }
    
    private void editarQuoteLineItems(List<String> idsToEdit) {
        try {
            List<QuoteLineItem> lineItemsToEdit = [SELECT Id, Quantity, Cantidad_devolucion__c FROM QuoteLineItem WHERE Id IN :idsToEdit];
            
            if (!lineItemsToEdit.isEmpty()) {
                lineItemsToEdit[0].Quantity = lineItemsToEdit[0].Quantity - lineItemsToEdit[0].Cantidad_devolucion__c;
                lineItemsToEdit[0].Cantidad_devolucion__c = 0;
                update lineItemsToEdit;
                System.debug('actualizar');
            } else {
                System.debug('No se encontraron registros para actualizar.');
            }
        } catch (Exception e) {
            System.debug('Error al editar QuoteLineItem: ' + e.getMessage());
        }
    }
    
    private void filterLineItemIdsByEstadoReserva() {
        List<String> filteredLineItemIds = new List<String>();
        for (String lineItemId : lineItemIds) {
            QuoteLineItem lineItem = [
                SELECT Id, Estado_entrega__c FROM QuoteLineItem WHERE Id = :lineItemId AND Estado_entrega__c != 'Pendiente devolución nota de crédito' LIMIT 1
            ];
            if (lineItem != null) {
                filteredLineItemIds.add(lineItemId);
            }
        }
        lineItemIds = filteredLineItemIds;
    }

    private static String resolveCompanyCode(Quote quote) {
        if (quote.Opportunity.Empresa_Operadora__c != null) {
            return validateSupportedCompany(
                EmpresaResolver.resolve(quote.Opportunity.Empresa_Operadora__c).codigo
            );
        }

        String legacyCompany = quote.Opportunity.BMW_Compania__c;
        if (String.isBlank(legacyCompany)) {
            throw new AuraHandledException('La empresa de la oportunidad es requerida para eliminar reserva de artículos de Quote.');
        }

        String normalizedCompany = legacyCompany.trim().toUpperCase();
        if (normalizedCompany == 'BAVARIAN' || normalizedCompany == 'RMBAVARIAN') {
            return 'RMBAVARIAN';
        }
        if (normalizedCompany == 'OTOBAI' || normalizedCompany == 'RMOTOBAI') {
            return 'RMOTOBAI';
        }

        return validateSupportedCompany(normalizedCompany);
    }

    private static String validateSupportedCompany(String companyCode) {
        if (String.isBlank(companyCode)) {
            throw new AuraHandledException('La empresa de la oportunidad es requerida para eliminar reserva de artículos de Quote.');
        }

        String normalizedCompany = companyCode.trim().toUpperCase();
        if (normalizedCompany == 'RMBAVARIAN' || normalizedCompany == 'RMOTOBAI') {
            return normalizedCompany;
        }
        if (normalizedCompany == 'RMPEKING') {
            throw new AuraHandledException('RMPEKING no tiene configuración de Softland para eliminar reservas de Quote.');
        }

        throw new AuraHandledException('Empresa no soportada para eliminar reservas de Quote: ' + companyCode);
    }
    
    
    public class ExternalServiceException extends Exception {}
}
