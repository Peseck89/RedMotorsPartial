public with sharing class doCalloutObtenerClienteLagoDatos {
    @AuraEnabled
    public static string getClienteLagoDatos(String oportunidadFinanciamientoId){
        
        
        Oportunidad_de_Financiamiento__c oportunidadFinanciamiento = [SELECT Nombre_Cliente_Altica__r.Cedula__c,comportamiento__c,tipoDeProducto__c,tipoMontoFrecuenciaTransacciones__c,tipoCliente__c FROM Oportunidad_de_Financiamiento__c WHERE Id=:oportunidadFinanciamientoId];
        String cedulaCliente = oportunidadFinanciamiento.Nombre_Cliente_Altica__r.Cedula__c;
        
        
        // Crear una nueva solicitud HTTP
        HttpRequest req = new HttpRequest();

        // Configurar el método, endpoint y cabecera de la solicitud
        req.setMethod('POST');
        req.setEndpoint('https://hooks.zapier.com/hooks/catch/12532064/31skfh1/');
        req.setHeader('Content-Type', 'application/json');

        // Crear un objeto para contener el parámetro y convertirlo a una cadena JSON
        Map<String, String> bodyMap = new Map<String, String>();
        bodyMap.put('identificacion', cedulaCliente);
        bodyMap.put('idWO', oportunidadFinanciamientoId);
        String bodyJson = JSON.serialize(bodyMap);
        
        System.debug(bodyJson);

        // Añadir el cuerpo JSON a la solicitud
        req.setBody(bodyJson);

        // Crear un nuevo objeto Http y enviar la solicitud
        Http http = new Http();
        
        if(!Test.isRunningTest())
            {
                HTTPResponse res = http.send(req);
            }
        
        
        return 'OK, Consultado con éxito';
                
        /*
		//String url = 'http://35.226.4.74/';
        
        Http h = new Http();
        string response = '';

        HttpRequest req = new HttpRequest();
        req.setEndpoint(url+'api/LagoDeDatos/obtenerCliente');
        req.setBody(obtenerClienteJSON.obtenerCliente(cedulaCliente));
        req.setHeader('Content-Type', 'application/json');
        req.setMethod('POST');
        req.setTimeout(20000);
        try {
            String jsonStr;
            if(!Test.isRunningTest())
            {
                HttpResponse res = h.send(req);
                jsonStr = res.getBody();
            }
            else {
                StaticResource resource = [SELECT Id, Body FROM StaticResource WHERE Name = 'clienteResource' LIMIT 1];
                jsonStr = resource.Body.toString();
            }
            response = obtenerClienteJSON.updateCliente(jsonStr, oportunidadFinanciamiento);
				
        }
        catch(System.CalloutException e) {
            System.Debug(e);
            return 'Error, verifique los datos del cliente';
        }
        return response;
		*/
    }
}