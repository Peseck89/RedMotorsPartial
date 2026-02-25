public class ApiCreditWS {
    public class ResponseWrapper{
        public Boolean error;
        public String mensaje;
        public Data data;
    }
    public class Data{
        public List<String> correos;
        public List<String> telefonos;
        public List<String> profesiones;
        public String identificacion;
        public String nombre;
        public String apellido1;
        public String apellido2;
        public String fechaNacimiento;
        public String estadoCivil;
    }
    @InvocableMethod(label='Consulta cedula' description='Consulta la cedula de cliente' category='Account')
    public static List<String> getInfoCliente(List<String> cedulaCliente){
        Integracion__mdt integracionApiCredit = [SELECT MasterLabel,Endpoint__c,Token__c FROM Integracion__mdt WHERE MasterLabel	 = 'ApiCredid' LIMIT 1];
        String endpoint;
        String cedulaEncontrada;
        String cedulaABuscar;
        System.debug('cedulaCliente '+cedulaCliente);
        
        if(cedulaCliente != null){
        	cedulaEncontrada = cedulaCliente[0];
            if(cedulaEncontrada.contains(',')){
            	cedulaEncontrada = cedulaEncontrada.remove(',');
            }
        }
        if(cedulaCliente != null){
       		cedulaABuscar = cedulaCliente[0];
        }
        if(cedulaCliente != null){
        	endpoint =   integracionApiCredit.Endpoint__c + cedulaEncontrada;
        }
        System.debug('endpoint '+endpoint);
        List<String> retorno = new List<String>();
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setHeader('Authorization', integracionApiCredit.Token__c);
        request.setHeader('Content-Type', 'application/json');
        request.setEndpoint(endPoint);
        request.setTimeout(120000);
          HttpResponse response = new HttpResponse();

        if(!Test.isRunningTest()){ response = new Http().send(request);
        }
        String resBody = response.getBody(); 
        System.debug('resBody :: ' + resBody);
        if(response.getStatusCode()!= 200){
            System.debug('falló la integración');
            String nombreRespuesta = 'Datos';
            String apellido1Respuesta = 'No';
            String apellido2Respuesta = 'Encontrados';
            String correoRespuesta = 'cuenta@noecntrada.com';
            String telefonoRespuesta = '0';
            String fecharespuesta = '0000,00,00';
            retorno.add(';;;;;;0000,00,00');
        
        }else{
            ResponseWrapper resWrapp= (ResponseWrapper)JSON.deserialize(response.getBody(), ResponseWrapper.class);
            String fechaNacimiento = resWrapp.data.fechaNacimiento; String fechaNacimiento2;
            List<String> correos = resWrapp.data.correos; List<String> telefonos = resWrapp.data.telefonos; List<String> profesiones = resWrapp.data.profesiones;
            if(fechaNacimiento != null){
                System.debug('fechaNacimiento '+fechaNacimiento);
                if(fechaNacimiento.length()>7){fechaNacimiento2 = fechaNacimiento.substring(0,4)+','+fechaNacimiento.substring(4,6)+','+fechaNacimiento.substring(6,8);
                }
            }
            System.debug('fechaNacimiento2 '+fechaNacimiento2);
            Integer correossize = correos.size();Integer telefonossize = telefonos.size();Integer profesionessize = profesiones.size();

            if(correos.size()==0){correos.add('');}else{correossize = correossize-1;
            }
            if(telefonos.size()==0){telefonos.add('');}else{telefonossize = telefonossize-1;}if(profesiones.size()==0){ profesiones.add('');
            }else{profesionessize = profesionessize-1; }
            retorno.add(resWrapp.data.nombre+';'+resWrapp.data.apellido1+';'+resWrapp.data.apellido2+';'+correos[correossize]+';'+telefonos[telefonossize]+';'+profesiones[profesionessize]+';'+fechaNacimiento2);
        }
        return retorno;
    }
    
}