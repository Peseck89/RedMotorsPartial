public class ApiCreditLWCWS {
    public class ResponseWrapper{
        public Boolean error;
        public String mensaje;
        public Data data;
    }
    
    public class Data{
        @AuraEnabled public List<String> correos {get; set;}
        @AuraEnabled public List<String> telefonos {get; set;}
        @AuraEnabled public List<String> profesiones {get; set;}
        @AuraEnabled public String identificacion {get; set;}
        @AuraEnabled public String nombre {get; set;}
        @AuraEnabled public String apellido1 {get; set;}
        @AuraEnabled public String apellido2 {get; set;}
        @AuraEnabled public String fechaNacimiento {get; set;}
        @AuraEnabled public String estadoCivil {get; set;}
    }
    
    @AuraEnabled
    public static String formatearFechaString(String fechaOriginal) {
        if(fechaOriginal == null) return null;
        List<String> partes = fechaOriginal.split(' ');
        String soloFecha = partes[0]; 
        List<String> componentes = soloFecha.split('/');
        Integer mes = Integer.valueOf(componentes[0]);
        Integer dia = Integer.valueOf(componentes[1]);
        Integer anio = Integer.valueOf(componentes[2]);
        Date fechaDate = Date.newInstance(anio, mes, dia);
        return String.valueOf(fechaDate); 
    }
    
    @AuraEnabled(cacheable=true)
    public static Data getInfoCliente(String cedulaCliente) {
        Data respuesta = new Data();
        Integracion__mdt integracionApiCredit = [SELECT MasterLabel,Endpoint__c,Token__c FROM Integracion__mdt WHERE MasterLabel	 = 'ApiCredid' LIMIT 1];
        String endpoint;
        String cedulaEncontrada;
        String cedulaABuscar;
        if(cedulaCliente != null){
            cedulaEncontrada = cedulaCliente;
            if(cedulaEncontrada.contains(',')){
                cedulaEncontrada = cedulaEncontrada.remove(',');
            }
        }
        if(cedulaCliente != null){
            cedulaABuscar = cedulaCliente;
        }
        if(cedulaCliente != null){
            endpoint =   integracionApiCredit.Endpoint__c + cedulaEncontrada;
        }
        List<String> retorno = new List<String>();
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setHeader('Authorization', integracionApiCredit.Token__c);
        request.setHeader('Content-Type', 'application/json');
        request.setEndpoint(endPoint);
        request.setTimeout(120000);
        HttpResponse response = new HttpResponse();
        
        response = new Http().send(request);
                                 
        String resBody = response.getBody(); 
        if(response.getStatusCode()!= 200){
            respuesta = null;
            return respuesta;
        }else{
            ResponseWrapper resWrapp= (ResponseWrapper)JSON.deserialize(response.getBody(), ResponseWrapper.class);
            respuesta = resWrapp.data;
            if(respuesta.estadoCivil != null){
                respuesta.estadoCivil  = respuesta.estadoCivil.remove('(a)');
            }
            if(respuesta.fechaNacimiento != null && respuesta.fechaNacimiento != ''){
                respuesta.fechaNacimiento = formatearFechaString(respuesta.fechaNacimiento);
            }
            return respuesta;
        }
    }
}