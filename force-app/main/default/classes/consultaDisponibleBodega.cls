public class consultaDisponibleBodega {

    private static final String SERVICE_URL = 'http://172.176.136.132:5080/IntegrationServices/softlandAPI/Catalogs/getExistenciaArticuloReserva';
    //private static final String SERVICE_URL = 'http://172.176.136.132:5080/ServiciosSoftlandProductivos/softlandAPI/Catalogs/getExistenciaArticuloReserva';
    
    // Método para consultar la disponibilidad, recibiendo una lista de WoliGridWrapper
    public static List<WoliGridWrapper> consultarDisponibilidad(List<WoliGridWrapper> woliWrappers, String workOrderNumber) {
		
        String url = Label.URLSoftland;
        String ambiente = Label.ambienteSoftland;
        
        WorkOrder workOrder = [SELECT Id, EmpresaFactura__c FROM WorkOrder WHERE WorkOrderNumber = :workOrderNumber LIMIT 1];
        
        // Crear el JSON para la solicitud
        Map<String, Object> requestBody = new Map<String, Object>{
            'orden_salesforce' => workOrderNumber, // Valor por defecto
            'compania' => WorkOrder.EmpresaFactura__c, // Valor por defecto
            'articulos' => new List<Map<String, String>>()
        };

        Map<String, Map<String, String>> uniqueArticulos = new Map<String, Map<String, String>>();

        for (WoliGridWrapper woliWrapper : woliWrappers) {
            if (!uniqueArticulos.containsKey(woliWrapper.ProductCode)) {
                System.debug('JSON TIPO KIT ' + woliWrapper.esKit);
                
                string tipo = 'T';
                
                if(woliWrapper.productType == 'Kit'){
                    tipo = 'K';
                }
                
                
                uniqueArticulos.put(woliWrapper.ProductCode, new Map<String, String>{
                    'tipo' => tipo, // Valor asumido estático
                    'bodega' => woliWrapper.idExtBodega,
                    'articulo' => woliWrapper.ProductCode
                });
            }
        }

        requestBody.put('articulos', new List<Map<String, String>>(uniqueArticulos.values()));
        
        
        System.debug('JSON LLAMADA ' + JSON.serialize(requestBody));
        
        JSON_History__c JsonHistory = new JSON_History__c();
        JsonHistory.Work_Order__c = workOrder.Id;
        JsonHistory.JSON__c = JSON.serialize(requestBody);
        JsonHistory.Name = 'Servicio Reserva Apartado Artículos';
        
        
        HttpResponse res = new HttpResponse();
        
        if (Test.isRunningTest()) {
            
            	WorkOrder insertedWO = [SELECT Id, WorkOrderNumber FROM WorkOrder WHERE WorkOrderNumber = :workOrderNumber];
            
            	List<WorkOrderLineItem> wolis = [SELECT Id,BMW_CodigoDeProducto__c FROM WorkOrderLineItem WHERE workOrderId = :insertedWO.id];
                System.debug('WOLI 1 code  ' + wolis[0].BMW_CodigoDeProducto__c);
                System.debug('WOLI 2 code  ' + wolis[1].BMW_CodigoDeProducto__c);
                String testResponse = '{' +
                                        '"Data":[' +
                                            '{' +
                                                '"articulo":"' + wolis[0].BMW_CodigoDeProducto__c + '",' +
                                                '"bodega":"BR01",' +
                                                '"cantidadDisponible":11,' +
                                                '"reservadoOrden":0,' +
                                                '"existenciasOtrasBodegas":"false"' +
                                            '},' +
                                            '{' +
                                                '"Data":[' +
                                                    '{' +
                                                        '"articulo":"' + wolis[1].BMW_CodigoDeProducto__c + '",' +
                                                        '"bodega":"BR02",' +
                                                        '"cantidadDisponible":1' +
                                                    '},' +
                                                    '{' +
                                                        '"articulo":"' + wolis[1].BMW_CodigoDeProducto__c + '",' +
                                                        '"bodega":"BR03",' +
                                                        '"cantidadDisponible":6' +
                                                    '}' +
                                                '],' +
                                                '"articulo":"' + wolis[1].BMW_CodigoDeProducto__c + '",' +
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
                res.setStatusCode(200); // Mock the status code as 200 (OK)
                res.setBody(testResponse); // Use the predefined test response
            } else {
      
                String tokenAuthentificacion = ExternalAuthService.authenticate();
                
                System.debug('Request Body  ' + requestBody);
        
                // Realizar la autenticación y llamar al servicio externo
                HttpRequest req = new HttpRequest();
                req.setEndpoint(SERVICE_URL);
                req.setMethod('POST');
                req.setHeader('Authorization', 'Bearer ' + tokenAuthentificacion);
                req.setHeader('Content-Type', 'application/json');
                req.setBody(JSON.serialize(requestBody));
                req.setTimeout(120000);
                
                res = new Http().send(req);
                
        } 
                
        System.debug('JSON RESPUESTA  ' + res);
        
        JsonHistory.JSON_Response__c = res.getBody();
        JsonHistory.Error_Message__c = 'Consulta disponible en bodega';
        insert JsonHistory;
        
        // Suponiendo que la respuesta es correcta y deseamos usarla para construir la lista de WOLI
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        
        System.debug('JSON RESPUESTA  ' + res.getBody());
        
        List<Object> data = (List<Object>) responseMap.get('Data');

        List<WOLI> items = new List<WOLI>();
        for (Object dataItem : data) {
            Map<String, Object> itemMap = (Map<String, Object>) dataItem;
            String existenciasOtrasBodegas = (String) itemMap.get('existenciasOtrasBodegas');
            String otherInventoryText = (String) itemMap.get('existenciasOtrasBodegas') == 'true' && itemMap.containsKey('Data') ? getOtherInventoryText((List<Object>) itemMap.get('Data')): '';

            WOLI woli = new WOLI(
                (String) itemMap.get('articulo'),
                (String) itemMap.get('bodega'),
                (Decimal) itemMap.get('cantidadDisponible'),
                (Decimal) itemMap.get('reservadoOrden'),
                (String) itemMap.get('existenciasOtrasBodegas'),
                otherInventoryText
            );
            items.add(woli);
        }
        
        List<WoliGridWrapper> ListaWrapper = actualizarWrappersConDisponibilidad(woliWrappers,items);
        
        System.debug('JSON RESPUESTA  ' + ListaWrapper);
        
        
		return ListaWrapper;     
        
        
    }
    
    public static List<WoliGridWrapper> actualizarWrappersConDisponibilidad(List<WoliGridWrapper> woliWrappers, List<WOLI> items) {
        // Crear un mapa para facilitar la búsqueda de disponibilidad por ProductCode
        Map<String, WOLI> disponibilidadPorCodigo = new Map<String, WOLI>();
        for (WOLI item : items) {
            disponibilidadPorCodigo.put(item.articulo, item);
        }
    
        // Conjunto para rastrear los ProductCodes ya procesados
        Set<String> procesados = new Set<String>();
    
        for (WoliGridWrapper wrapper : woliWrappers) {
            WOLI woliItem = disponibilidadPorCodigo.get(wrapper.ProductCode);
    
            // Si el artículo está presente en la lista de disponibilidad
            if (woliItem != null) {
                wrapper.existenciasOtrasBodegas = woliItem.existenciasOtrasBodegas;
                wrapper.otherInventoryText = woliItem.otherInventoryText;
                // Si el ProductCode ya ha sido procesado, ignorar el reservadoOrden
                if (procesados.contains(wrapper.ProductCode)) {
                    if (wrapper.cantidad <= woliItem.cantidadDisponible) {
                        wrapper.softlandQuantity = woliItem.cantidadDisponible;
                        wrapper.validated = true;
                        wrapper.available = true;
                        System.debug('Linea con cantidad disponible');
                    }else {
                        wrapper.softlandQuantity = woliItem.cantidadDisponible;
                        wrapper.validated = true;
                        wrapper.available = false;
                        }
                } else {
                    // Este es el primer procesamiento para este ProductCode
                    if (wrapper.cantidad - woliItem.reservadoOrden <= woliItem.cantidadDisponible) {
                        wrapper.softlandQuantity = woliItem.cantidadDisponible;
                        wrapper.validated = true;
                        wrapper.available = true;
                    }else {
                        wrapper.softlandQuantity = woliItem.cantidadDisponible;
                        wrapper.validated = true;
                        wrapper.available = false;
                    }
                    // Marcar como procesado
                    procesados.add(wrapper.ProductCode);
                }
            }
        }
        
        
        
        Return woliWrappers;
    }

    public static String getOtherInventoryText(List<Object> otherBodegasData) {
        List<String> otherBodegasList = new List<String>();
        
        for (Object otherBodegaItem : otherBodegasData) {
            Map<String, Object> otherBodegaMap = (Map<String, Object>) otherBodegaItem;
            String otherBodega = (String) otherBodegaMap.get('bodega');
            Decimal otherCantidad = (Decimal) otherBodegaMap.get('cantidadDisponible');
            String formattedCantidad = otherCantidad.setScale(0).format();
            otherBodegasList.add(otherBodega + ':' + formattedCantidad);
        }
        return String.join(otherBodegasList, ' - ');
    }
    
    public class WOLI {
        public String articulo;
        public String bodega;
        public Decimal cantidadDisponible;
        public Decimal reservadoOrden;
        public String existenciasOtrasBodegas; 
        public String otherInventoryText;
        
        public WOLI(String articulo, String bodega, Decimal cantidadDisponible, Decimal reservadoOrden, String existenciasOtrasBodegas, String otherInventoryText) {
            this.articulo = articulo;
            this.bodega = bodega;
            this.cantidadDisponible = cantidadDisponible;
            this.reservadoOrden = reservadoOrden;
            this.existenciasOtrasBodegas = existenciasOtrasBodegas;
            this.otherInventoryText = otherInventoryText;
        }
    }
}