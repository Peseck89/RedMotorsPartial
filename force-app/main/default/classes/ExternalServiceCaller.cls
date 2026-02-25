public class ExternalServiceCaller {

    private static final String AUTH_URL = 'http://172.176.136.132:5080/ServiciosSoftlandProductivos/oauth/token';
    private static final String SERVICE_URL = 'http://172.176.136.132:5080/ServiciosSoftlandProductivos/softlandAPI/products/addProductUsados';
	
    public static String authenticate() {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(AUTH_URL);
        req.setMethod('GET');
        req.setBody('clientId=interfaz&clientSecret=1nt3gr@c1on&grant_type=password');
        HttpResponse res = new Http().send(req);
        
        // Parse the response to get the access token
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        
        System.debug('Service AccessToken: ' + responseMap.get('access_token'));
        
        return (String) responseMap.get('access_token');
    }

    public static String sendToExternalService(Id recordId) {
        ReciboUsado__c record = [SELECT Marca__c,Empresa__c,RecordTypeId, Oportunidad__r.ConsecutivoOportunidad__c,Motor__c,Modelo__c, Estilo__c, Ano__c,ReciboJefeUsados__c, Color__c, Combustible__c,ValorReciboGibsson__c,Valor_sugerido_de_recibo__c,Valor_inicial__c, EstiloUsado__c, Traccion__c, Trasmision__c, N_puertas__c, Kilometraje__c, Cilindraje__c, Placa__c, ValorReciboCliente__c, ValorReciboBruto__c, MontoSoporte__c, VIN__c FROM ReciboUsado__c WHERE Id = :recordId LIMIT 1];
		Id recordTypeIdAuto = Schema.SObjectType.ReciboUsado__c.getRecordTypeInfosByName().get('Automóvil').getRecordTypeId();
		Id recordTypeIdMoto = Schema.SObjectType.ReciboUsado__c.getRecordTypeInfosByName().get('Motocicleta').getRecordTypeId();
        
        string TipoVehiculo = '';
        
        If(record.RecordTypeId == recordTypeIdAuto){
            TipoVehiculo = 'A';
        }
        else{
            TipoVehiculo = 'M';
        }
        
        Map<String, Object> requestBody = new Map<String, Object>{
            'Marca' => record.Marca__c,
            'Modelo' => record.Modelo__c,
            'Estilo' => record.Estilo__c,
            'Anio' => record.Ano__c,
            'Color' => record.Color__c,
            'Puertas' => record.N_puertas__c,
            'Combustible' => record.Combustible__c,
            'Traccion' => record.Traccion__c,
            'Transmision' => record.Trasmision__c,
            'Carroceria' => record.EstiloUsado__c, 
            'Kilometraje' => record.Kilometraje__c,    
            'Cilindraje' => record.Cilindraje__c,
            'Placa' => record.Placa__c,
            'Avaluo' => record.ValorReciboCliente__c,
            'Recibo' => record.ReciboJefeUsados__c,
            'Soporte' => record.MontoSoporte__c,
            'Motor' => record.Motor__c,
            'OportunidadOrigen' => record.Oportunidad__r.ConsecutivoOportunidad__c,
            'compania' => record.Empresa__c,
            'tipo_vehiculo' => TipoVehiculo,
            'VIN' => record.VIN__c
        };
		System.debug('Service Body: ' + requestBody);
            //puertas' => record.
       
            
        HttpRequest req = new HttpRequest();
        req.setEndpoint(SERVICE_URL);
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + authenticate());
        req.setHeader('Content-Type', 'application/json');
        req.setBody(JSON.serialize(requestBody));
        
        HttpResponse res = new Http().send(req);
        
        System.debug('Service Response: ' + res);
        
        // Handle the response
        if (res.getStatusCode() == 200) {
            return res.getBody() + 'Llamada exitosa';
        } else {
            return 'HTTP Error: ' + res.getStatusCode();
        }
        // Handle the response, e.g., check if the external service call was successful
    }
}