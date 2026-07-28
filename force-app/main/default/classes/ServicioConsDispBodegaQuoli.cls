public class ServicioConsDispBodegaQuoli {
    
    // Método para consultar la disponibilidad, recibiendo una lista de WoliGridWrapper
    public static List<WoliGridWrapper> consultarDisponibilidad(List<WoliGridWrapper> woliWrappers, String quoteNumber) {
		
        String url = Label.URLSoftland;
        String ambiente = Label.ambienteSoftland;
        
        Quote quote = [
            SELECT Id, Name, Quote_Number__c,
                Opportunity.BMW_Compania__c,
                Opportunity.Empresa_Operadora__c,
                Opportunity.Id_Oportunidad__c,
                Opportunity.NumeroConsecutivo__c
            FROM Quote
            WHERE QuoteNumber = :quoteNumber
            LIMIT 1
        ];
        
        String empresa = resolveCompanyCode(quote);
        
        String oportunidadSalesforce = quote.Opportunity.Id_Oportunidad__c;
        String quoteSalesforce = quote.Quote_Number__c;

        // Crear el JSON para la solicitud
        Map<String, Object> requestBody = new Map<String, Object>{
            'oportunidad_salesforce' => oportunidadSalesforce,
            'quote_salesforce' => quoteSalesforce,
            'compania' => empresa, 
            'articulos' => new List<Map<String, String>>()
        };

        Map<String, Map<String, String>> uniqueArticulos = new Map<String, Map<String, String>>();

        for (WoliGridWrapper woliWrapper : woliWrappers) {
            if (!uniqueArticulos.containsKey(woliWrapper.ProductCode)) {
                System.debug('JSON TIPO KIT ' + woliWrapper.esKit);
                
                string tipo = 'T';
                 Product2 prod = [
                    SELECT Id, TipoProducto__c 
                    FROM Product2 
                    WHERE ProductCode = :woliWrapper.ProductCode 
                    LIMIT 1
                ];
            
                // Si es kit según la tabla de producto, forzar tipo = K
                if (prod.TipoProducto__c == 'Kit') {
                    tipo = 'K';
                }else{
                    tipo = 'T';
                }
                
                
                
                uniqueArticulos.put(woliWrapper.ProductCode, new Map<String, String>{
                    'tipo' => tipo, 
                    'bodega' => woliWrapper.idExtBodega,
                    'articulo' => woliWrapper.ProductCode
                });
            }
        }

        requestBody.put('articulos', new List<Map<String, String>>(uniqueArticulos.values()));
        
        
       
        
        Quote insertedquote = [SELECT Id, quoteNumber FROM Quote WHERE QuoteNumber = :quoteNumber];
        HttpResponse res = new HttpResponse();
        ///APILog MFC
        QuoteSoftlandApiLogService apiLog = new QuoteSoftlandApiLogService('Consulta disponible en bodega - Quote', insertedquote.Id); 
        
        if (Test.isRunningTest()) {
            	
            	//WorkOrder insertedWO = [SELECT Id, WorkOrderNumber FROM WorkOrder WHERE WorkOrderNumber = :workOrderNumber];
            
            	List<QuoteLineItem> quolis = [SELECT Id, Codigo_producto__c FROM QuoteLineItem WHERE QuoteId = :insertedquote.id];
                
                String testResponse = '{' +
                                        '"Data":[' +
                                            '{' +
                                                '"articulo":"' + quolis[0].Codigo_producto__c + '",' +
                                                '"bodega":"BR01",' +
                                                '"cantidadDisponible":11,' +
                                                '"reservadoOrden":0,' +
                                                '"existenciasOtrasBodegas":"false"' +
                                            '},' +
                                            '{' +
                                                '"Data":[' +
                                                    '{' +
                                                        '"articulo":"' + quolis[1].Codigo_producto__c + '",' +
                                                        '"bodega":"BR02",' +
                                                        '"cantidadDisponible":1' +
                                                    '},' +
                                                    '{' +
                                                        '"articulo":"' + quolis[1].Codigo_producto__c + '",' +
                                                        '"bodega":"BR03",' +
                                                        '"cantidadDisponible":6' +
                                                    '}' +
                                                '],' +
                                                '"articulo":"' + quolis[1].Codigo_producto__c + '",' +
                                                '"bodega":"BR01",' +
                                                '"cantidadDisponible":0,' +
                                                '"reservadoOrden":0,' +
                                                '"existenciasOtrasBodegas":"true"' +
                                            '}' +
                                        '],' +
                                        '"Paging":{' +
                                            '"PageNo":1,' +
                                            '"PageSize":100,' +
                                            '"PageCount":1,' +
                                            '"TotalRecordCount":69833,' +
                                            '"TotalThisViewCount":3' +
                                        '}' +
                                    '}';

                // Use the predefined response when running in a test context
                //apiLog.setRequest('TEST');
                //apiLog.setResponse(testResponse);
                res.setStatusCode(200); // Mock the status code as 200 (OK)
                res.setBody(testResponse); // Use the predefined test response
            } else {
      
                String tokenAuthentificacion = ExternalAuthService.authenticate();
                
                System.debug('Request Body  ' + JSON.serialize(requestBody));
                apiLog.setRequest(JSON.serialize(requestBody));
                // Realizar la autenticación y llamar al servicio externo
                HttpRequest req = new HttpRequest();
                req.setEndpoint(SoftlandEndpointService.existenciaArticuloOportunidad());
                req.setMethod('POST');
                req.setHeader('Authorization', 'Bearer ' + tokenAuthentificacion);
                req.setHeader('Content-Type', 'application/json');
                req.setBody(JSON.serialize(requestBody));
                req.setTimeout(120000);
                
                res = new Http().send(req);
                
        } 
        
        System.debug('JSON RESPUESTA  ' + res);
        apiLog.setResponse(res.getBody());
        apiLog.saveLog();
        //JsonHistory.JSON_Response__c = res.getBody();
        //JsonHistory.Error_Message__c = 'Consulta disponible en bodega';
        //insert JsonHistory;
        //string test = '{ "Data": [ { "articulo": "L00078", "bodega": "BR01", "cantidadDisponible": 11, "reservadoOrden": 0, "existenciasOtrasBodegas": "false" }, { "Data": [ { "articulo": "61279487464", "bodega": "BR03", "cantidadDisponible": 1 }, { "articulo": "61279487464", "bodega": "BR02", "cantidadDisponible": 6 } ], "articulo": "61279487464", "bodega": "BR01", "cantidadDisponible": 0, "reservadoOrden": 0, "existenciasOtrasBodegas": "true" }, { "articulo": "11138580110", "bodega": "BR01", "cantidadDisponible": 11, "reservadoOrden": 0, "existenciasOtrasBodegas": "false" } ], "Paging": { "PageNo": 1, "PageSize": 100, "PageCount": 1, "TotalRecordCount": 69833, "TotalThisViewCount": 3 } }';
        // Suponiendo que la respuesta es correcta y deseamos usarla para construir la lista de WOLI
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        System.debug('JSON RESPUESTA  ' + res.getBody());
        
        List<Object> data = (List<Object>) responseMap.get('Data');

        List<QUOLI> items = new List<QUOLI>();
        for (Object dataItem : data) {
            Map<String, Object> itemMap = (Map<String, Object>) dataItem;
            String existenciasOtrasBodegas = (String) itemMap.get('existenciasOtrasBodegas');
            String otherInventoryText = (String) itemMap.get('existenciasOtrasBodegas') == 'true' && itemMap.get('Data') instanceof List<Object>
                ? consultaDisponibleBodega.getOtherInventoryText((List<Object>) itemMap.get('Data'))
                : '';
            
            QUOLI quoli = new QUOLI(
                (String) itemMap.get('articulo'),
                (String) itemMap.get('bodega'),
                toDecimal(itemMap.get('cantidadDisponible')),
                toDecimal(itemMap.get('reservadoOrden')),
                (String) itemMap.get('existenciasOtrasBodegas'),
                otherInventoryText,
                getBodegasDisponibles(itemMap),
                getLocalizacionesDisponibles(itemMap)
            );
            items.add(quoli);
        }
        
        List<WoliGridWrapper> ListaWrapper = actualizarWrappersConDisponibilidad(woliWrappers, items);
        
        System.debug('JSON RESPUESTA  ' + ListaWrapper);
        
        
        return ListaWrapper;     
        
        
    }
    
    public static List<WoliGridWrapper> actualizarWrappersConDisponibilidad(List<WoliGridWrapper> woliWrappers, List<QUOLI> items) {
        // Crear un mapa para facilitar la búsqueda de disponibilidad por ProductCode
        Map<String, QUOLI> disponibilidadPorCodigo = new Map<String, QUOLI>();
        for (QUOLI item : items) {
            disponibilidadPorCodigo.put(item.articulo, item);
        }
    
        // Conjunto para rastrear los ProductCodes ya procesados
        Set<String> procesados = new Set<String>();
    
        for (WoliGridWrapper wrapper : woliWrappers) {
            QUOLI quoliItem = disponibilidadPorCodigo.get(wrapper.ProductCode);
    
            // Si el artículo está presente en la lista de disponibilidad
            if (quoliItem != null) {
                wrapper.existenciasOtrasBodegas = quoliItem.existenciasOtrasBodegas;
                wrapper.otherInventoryText = quoliItem.otherInventoryText;
                wrapper.bodegasDisponibles = quoliItem.bodegasDisponibles;
                wrapper.localizacionesDisponibles = quoliItem.localizacionesDisponibles;
                // Si el ProductCode ya ha sido procesado, ignorar el reservadoOrden
                if (procesados.contains(wrapper.ProductCode)) {
                    if (wrapper.cantidad <= quoliItem.cantidadDisponible) {
                        wrapper.softlandQuantity = quoliItem.cantidadDisponible;
                        wrapper.validated = true;
                        wrapper.available = true;
                        System.debug('Linea con cantidad disponible');
                    }else {
                        wrapper.softlandQuantity = quoliItem.cantidadDisponible;
                        wrapper.validated = true;
                        wrapper.available = false;
                    }
                } else {
                    // Este es el primer procesamiento para este ProductCode
                    if (wrapper.cantidad - quoliItem.reservadoOrden <= quoliItem.cantidadDisponible) {
                        wrapper.softlandQuantity = quoliItem.cantidadDisponible;
                        wrapper.validated = true;
                        wrapper.available = true;
                    }else {
                        wrapper.softlandQuantity = quoliItem.cantidadDisponible;
                        wrapper.validated = true;
                        wrapper.available = false;
                    }
                    // Marcar como procesado
                    procesados.add(wrapper.ProductCode);
                }
            }
        }
        
        return woliWrappers;
    }

    private static String resolveCompanyCode(Quote quote) {
        if (quote.Opportunity.Empresa_Operadora__c != null) {
            return validateSupportedCompany(
                EmpresaResolver.resolve(quote.Opportunity.Empresa_Operadora__c).codigo
            );
        }

        String legacyCompany = quote.Opportunity.BMW_Compania__c;
        if (String.isBlank(legacyCompany)) {
            throw new AuraHandledException('La empresa de la oportunidad es requerida para consultar disponibilidad.');
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
            throw new AuraHandledException('La empresa de la oportunidad es requerida para consultar disponibilidad.');
        }

        String normalizedCompany = companyCode.trim().toUpperCase();
        if (normalizedCompany == 'RMBAVARIAN' || normalizedCompany == 'RMOTOBAI') {
            return normalizedCompany;
        }
        if (normalizedCompany == 'RMPEKING') {
            throw new AuraHandledException('RMPEKING no tiene configuración de Softland para consulta de disponibilidad de Quote.');
        }

        throw new AuraHandledException('Empresa no soportada para consulta de disponibilidad de Quote: ' + companyCode);
    }

    private static Decimal toDecimal(Object value) {
        if (value == null) {
            return 0;
        }

        if (value instanceof Decimal) {
            return (Decimal) value;
        }

        String valueAsString = String.valueOf(value);
        return String.isBlank(valueAsString) || valueAsString == 'null'
            ? 0
            : Decimal.valueOf(valueAsString);
    }

    private static List<WoliGridWrapper.BodegaDisponibilidad> getBodegasDisponibles(Map<String, Object> itemMap) {
        List<WoliGridWrapper.BodegaDisponibilidad> bodegas = new List<WoliGridWrapper.BodegaDisponibilidad>();
        addBodegaDisponible(bodegas, itemMap);

        for (String collectionKey : new List<String>{ 'bodegas', 'Bodegas', 'existenciasBodegas', 'ExistenciasBodegas', 'Data' }) {
            if (itemMap.containsKey(collectionKey) && itemMap.get(collectionKey) instanceof List<Object>) {
                for (Object row : (List<Object>) itemMap.get(collectionKey)) {
                    if (row instanceof Map<String, Object>) {
                        addBodegaDisponible(bodegas, (Map<String, Object>) row);
                    }
                }
            }
        }

        return bodegas;
    }

    private static void addBodegaDisponible(List<WoliGridWrapper.BodegaDisponibilidad> bodegas, Map<String, Object> source) {
        if (source == null || !source.containsKey('bodega')) {
            return;
        }

        WoliGridWrapper.BodegaDisponibilidad bodega = new WoliGridWrapper.BodegaDisponibilidad();
        bodega.articulo = source.containsKey('articulo') ? (String) source.get('articulo') : null;
        bodega.bodega = (String) source.get('bodega');
        bodega.cantidadDisponible = toDecimal(source.get('cantidadDisponible'));
        bodega.reservadoOrden = toDecimal(source.get('reservadoOrden'));
        bodega.existenciasOtrasBodegas = source.containsKey('existenciasOtrasBodegas')
            ? (String) source.get('existenciasOtrasBodegas')
            : null;

        bodegas.add(bodega);
    }

    private static List<WoliGridWrapper.LocalizacionDisponibilidad> getLocalizacionesDisponibles(Map<String, Object> itemMap) {
        List<WoliGridWrapper.LocalizacionDisponibilidad> localizaciones = new List<WoliGridWrapper.LocalizacionDisponibilidad>();
        addLocalizacionDisponible(localizaciones, itemMap);

        for (String collectionKey : new List<String>{
            'localizaciones',
            'Localizaciones',
            'existenciasLocalizacion',
            'ExistenciasLocalizacion',
            'existenciasPorLocalizacion',
            'ExistenciasPorLocalizacion'
        }) {
            if (itemMap.containsKey(collectionKey) && itemMap.get(collectionKey) instanceof List<Object>) {
                for (Object row : (List<Object>) itemMap.get(collectionKey)) {
                    if (row instanceof Map<String, Object>) {
                        addLocalizacionDisponible(localizaciones, (Map<String, Object>) row);
                    }
                }
            }
        }

        return localizaciones;
    }

    private static void addLocalizacionDisponible(List<WoliGridWrapper.LocalizacionDisponibilidad> localizaciones, Map<String, Object> source) {
        if (source == null || !source.containsKey('localizacion')) {
            return;
        }

        Decimal cantidadDisponible = toDecimal(source.get('cantidadDisponible'));
        Decimal reservadoOrden = toDecimal(source.get('reservadoOrden'));
        WoliGridWrapper.LocalizacionDisponibilidad localizacion = new WoliGridWrapper.LocalizacionDisponibilidad();
        localizacion.articulo = source.containsKey('articulo') ? (String) source.get('articulo') : null;
        localizacion.bodega = source.containsKey('bodega') ? (String) source.get('bodega') : null;
        localizacion.localizacion = (String) source.get('localizacion');
        localizacion.cantidadDisponible = cantidadDisponible;
        localizacion.reservadoOrden = reservadoOrden;
        localizacion.cantidadTotal = cantidadDisponible + reservadoOrden;

        localizaciones.add(localizacion);
    }
    
    public class QUOLI {
        public String articulo;
        public String bodega;
        public Decimal cantidadDisponible;
        public Decimal reservadoOrden;
        public String existenciasOtrasBodegas;
        public String otherInventoryText;
        public List<WoliGridWrapper.BodegaDisponibilidad> bodegasDisponibles;
        public List<WoliGridWrapper.LocalizacionDisponibilidad> localizacionesDisponibles;
        
        public QUOLI(
            String articulo,
            String bodega,
            Decimal cantidadDisponible,
            Decimal reservadoOrden,
            String existenciasOtrasBodegas,
            String otherInventoryText,
            List<WoliGridWrapper.BodegaDisponibilidad> bodegasDisponibles,
            List<WoliGridWrapper.LocalizacionDisponibilidad> localizacionesDisponibles
        ) {
            this.articulo = articulo;
            this.bodega = bodega;
            this.cantidadDisponible = cantidadDisponible;
            this.reservadoOrden = reservadoOrden;
            this.existenciasOtrasBodegas = existenciasOtrasBodegas;
            this.otherInventoryText = otherInventoryText;
            this.bodegasDisponibles = bodegasDisponibles == null
                ? new List<WoliGridWrapper.BodegaDisponibilidad>()
                : bodegasDisponibles;
            this.localizacionesDisponibles = localizacionesDisponibles == null
                ? new List<WoliGridWrapper.LocalizacionDisponibilidad>()
                : localizacionesDisponibles;
        }
    }
    
    

}
