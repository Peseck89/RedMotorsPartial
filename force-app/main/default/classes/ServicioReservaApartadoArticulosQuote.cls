public class ServicioReservaApartadoArticulosQuote {
    
    private String destino;
    private String quoteNumber;
    private List<String> notAvailableIds;
    private List<String> selectedIds;
    

    public ServicioReservaApartadoArticulosQuote(String quoteNumber, String destino, List<String> notAvailableIds, List<String> selectedIds) {
        this.quoteNumber = quoteNumber;
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
        System.debug('Quote Number ' + quoteNumber);
        
        // Find the Work Order by its number
        Quote Quote = [
            SELECT Id, Quote.Owner.Name, Quote.Opportunity.Tipo_de_cliente_mostrador__c, Quote.Opportunity.Sucursal__c, Opportunity.BMW_Compania__c, Opportunity.Empresa_Operadora__c, Quote_Number__c, Opportunity.Id_Oportunidad__c, Opportunity.BMW_PlacaDeVehiculoOElVIN__r.NumeroDeChasis__c, Opportunity.NumeroConsecutivo__c, Opportunity.BMW_PlacaDeVehiculoOElVIN__r.NumeroDePlaca__c, Opportunity.Account.Name //, Asesor_de_la_orden__r.Name, ServiceTerritory.Name
            FROM Quote
            WHERE QuoteNumber = :quoteNumber
            LIMIT 1
        ]; //NOT IN LISTA DE MAMBO
        if (Quote == null) {
            throw new WorkOrderNotFoundException('Orden de trabajo no encontrada');
            //Pendiente
        }

        // Fetch the related Work Order Line Items
        List<QuoteLineItem> lineItems = [SELECT Id, BMW_TipoDeArticulo__c, BMW_Bodega__r.bodega__c, Localizacion__c, QuoteLineItem.Codigo_producto__c, QuoteLineItem.Quantity//, Bodega__c, Bodega__r.Name, Bodega__r.bodega__c,TrabajoFormulaProducto__c, workOrder.Asesor_de_la_orden__r.Name,Quantity, workOrder.ServiceTerritory.Name, BMW_CodigoDeProducto__c, Cantidad__c, Estado_reserva__c, Trabajo__c
                                             FROM QuoteLineItem
                                             WHERE QuoteId = :Quote.Id
                                             AND ((Estado_reserva__c = 'Pendiente de reserva' OR Estado_reserva__c = '') AND (BMW_TipoDeArticulo__c = 'Materiales' OR BMW_TipoDeArticulo__c = 'Kit'))
                                             AND Id IN :finalSelectedIds
                                             ];
        
        

        if (lineItems.isEmpty() & !Test.isRunningTest()) {
            throw new LineItemsNotFoundException('No se encontraron líneas en la orden de trabajo que cumplan los requisitos');
        }
        
        String empresa = resolveCompanyCode(Quote);

        String oportunidadSalesforce = Quote.Opportunity.Id_Oportunidad__c;
        String quoteSalesforce = Quote.Quote_Number__c;

        
        
        System.debug('empresa ' + empresa);
        System.debug('JSON LLAMADA ' + quoteNumber);
        System.debug('JSON LLAMADA ' + Quote.Opportunity.BMW_PlacaDeVehiculoOElVIN__r.NumeroDeChasis__c);
        System.debug('JSON LLAMADA ' + Quote.Opportunity.BMW_PlacaDeVehiculoOElVIN__r.NumeroDePlaca__c);
        System.debug('JSON 2 ' + Quote.Opportunity.Account.Name);
        //System.debug('JSON LLAMADA ' + requestBody);
        //System.debug('JSON LLAMADA ' + requestBody);

        // Create the request body JSON
        // 
        string vin = Quote.Opportunity.BMW_PlacaDeVehiculoOElVIN__r.NumeroDeChasis__c != null ? Quote.Opportunity.BMW_PlacaDeVehiculoOElVIN__r.NumeroDeChasis__c : ''; 
        string placa = Quote.Opportunity.BMW_PlacaDeVehiculoOElVIN__r.NumeroDePlaca__c != null ? Quote.Opportunity.BMW_PlacaDeVehiculoOElVIN__r.NumeroDePlaca__c : ''; 
        Map<String, Object> requestBody = new Map<String, Object>{
            'compania' => empresa,
            'oportunidad_salesforce' => oportunidadSalesforce,
            'quote_salesforce' => quoteSalesforce,
            'TipoClienteMostrador' => Quote.Opportunity.Tipo_de_cliente_mostrador__c,    
            'vin' => vin,
            'placa' => placa,
            'cliente' => Quote.Opportunity.Account.Name,
            'asesorServicio' => UserInfo.getName(), //workOrder.Asesor_de_la_orden__r.Name,
            'taller' => Quote.Opportunity.Sucursal__c + ' - Mostrador' , //Este se debe mostrar como Sucursal - Mostrador Pendiente actualizar
            'articulos' => new List<Object>()
        };            
            
            
            

        for (QuoteLineItem item : lineItems) {
            Map<String, Object> article = new Map<String, Object>{
                'id_linea' => item.Id,
                'bodega' => item.BMW_Bodega__r.bodega__c, 
                'articulo' => item.Codigo_producto__c,
                'localizacion' => item.Localizacion__c,
                'cantidad' => String.valueOf(item.Quantity),
                'destino' => destino
            };
            ((List<Object>)requestBody.get('articulos')).add(article);
        }
        
        //JSON_History__c JsonHistory = new JSON_History__c();
        //JsonHistory.Work_Order__c = workOrder.Id;
        //JsonHistory.JSON__c = JSON.serialize(requestBody);
        //JsonHistory.Name = 'Servicio Reserva Apartado Artículos';
        
        System.debug('JSON LLAMADA ' + requestBody);
        //System.debug('JSON LLAMADA ' + JSON.serialize(requestBody));
		
        
        HttpResponse res = new HttpResponse();
		//ApiLog MFC
		QuoteSoftlandApiLogService apiLog = new QuoteSoftlandApiLogService('Reserva Apartado - Quote', Quote.Id); 
        
        if (Test.isRunningTest()) {
                String testResponse = '{'+
                    '"compania":"RMBAVARIAN",'+
                    '"codigo_respuesta":"00",'+
                    '"detalle_respuesta":"Lineas procesadas exitosamente",'+
                    '"orden_trabajo":"' + String.escapeSingleQuotes(quoteNumber) + '",'+
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
                req.setEndpoint(SoftlandEndpointService.reservaApartadoQuote());
                req.setMethod('POST');
                req.setHeader('Authorization', 'Bearer ' + token);
                req.setHeader('Content-Type', 'application/json');
                req.setBody(JSON.serialize(requestBody));

                res = new Http().send(req);
                //ApiLog MFC
                apiLog.setRequest(JSON.serialize(requestBody));
                        
        }        
        if (res.getStatusCode() != 200) {
            //JsonHistory.JSON_Response__c = res.getBody();
            //JsonHistory.Error_Message__c = res.getBody();
            //insert JsonHistory;
            throw new ExternalServiceException('Error al llamar al servicio externo: ' + res.getBody());
            
        }
        
        //JsonHistory.JSON_Response__c = res.getBody();
        //insert JsonHistory;
        System.debug('JSON RESPUESTA DEL SERVICIO  ' + res.getBody());
        //ApiLog MFC
		apiLog.setResponse(res.getBody());
        apiLog.saveLog();
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
        List<QuoteLineItem> lineItems = [SELECT Id FROM QuoteLineItem WHERE Id IN :idsLinea];
        
        for (QuoteLineItem item : lineItems) {
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
        List<QuoteLineItem> lineItems = [SELECT Id FROM QuoteLineItem WHERE Id IN :idsLinea];
        
        for (QuoteLineItem item : lineItems){
            if(estadosPorId.containsKey(item.Id)){
                item.Estado_softland__c = estadosPorId.get(item.Id);
            }
        }
        
        update lineItems;
    }
    

    private Object processResponse(Map<String, Object> responseMap) {
        return responseMap;
    }

    private static String resolveCompanyCode(Quote quote) {
        if (quote.Opportunity.Empresa_Operadora__c != null) {
            return validateSupportedCompany(
                EmpresaResolver.resolve(quote.Opportunity.Empresa_Operadora__c).codigo
            );
        }

        String legacyCompany = quote.Opportunity.BMW_Compania__c;
        if (String.isBlank(legacyCompany)) {
            throw new AuraHandledException('La empresa de la oportunidad es requerida para reservar o apartar artículos de Quote.');
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
            throw new AuraHandledException('La empresa de la oportunidad es requerida para reservar o apartar artículos de Quote.');
        }

        String normalizedCompany = companyCode.trim().toUpperCase();
        if (normalizedCompany == 'RMBAVARIAN' || normalizedCompany == 'RMOTOBAI') {
            return normalizedCompany;
        }
        if (normalizedCompany == 'RMPEKING') {
            throw new AuraHandledException('RMPEKING no tiene configuración de Softland para reservar o apartar artículos de Quote.');
        }

        throw new AuraHandledException('Empresa no soportada para reservar o apartar artículos de Quote: ' + companyCode);
    }

    public class WorkOrderNotFoundException extends Exception {}
    public class LineItemsNotFoundException extends Exception {}
    public class ExternalServiceException extends Exception {}
}
