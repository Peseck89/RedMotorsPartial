/*
  Creado por David Leon IS
  Fecha creacion: 09/01/2019
  Descripcion: Web service rest para la creacion de oportunidades de financiamiento desde la pagina web de Altica
*/

@RestResource(UrlMapping = '/Altica/*')
global class wsCrearOpF_Rest{
	    
    @HttpPost
    global static responseOpF crearOpF(){
        String idTipoRegistro, idCuentaJuridico, idCuentaFisico, idCuentaCompartida,idCuentaPersonal;
        List<Account> listAct = new List<Account>();
        Oportunidad_de_Financiamiento__c newOpF = new Oportunidad_de_Financiamiento__c();
        RestRequest req = RestContext.request;
        responseOpF response = new responseOpF();
        
        System.debug(' ** request ** ' + req);
        if(req == null){
            response.status = 'error';
            response.message = 'Información entrante nula';
            return response;
        }
        
        String jsonInput = req.requestBody.toString();
        classOpF opInfo = new classOpF();
        opInfo = (classOpF)JSON.deserialize(jsonInput, classOpF.class);
        System.debug(' ** info entrante ** ' + opInfo);
        
        //Se seleccionan los tipos de registro de opF y cuentas
		idTipoRegistro = Schema.SObjectType.Oportunidad_de_Financiamiento__c.getRecordTypeInfosByName().get('Altica').getRecordTypeId();
        idCuentaJuridico = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cliente Jurídico').getRecordTypeId();
        idCuentaFisico = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cliente Físico').getRecordTypeId();
        idCuentaCompartida = Schema.SObjectType.Account.getRecordTypeInfosByName().get('RedMotors-Altica').getRecordTypeId();
        idCuentaPersonal= Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cuenta personal').getRecordTypeId();
        //Se hace la busqueda del cliente
        listAct = buscarCliente(opInfo.cedula, idCuentaFisico, idCuentaJuridico, idCuentaCompartida,idCuentaPersonal);
        System.debug(' ** cuenta cliente ** ' + listAct);
        List<User> usId = [Select Id,Name From User Where Alias = 'Elopez'];
        //Se inicia el proceso de creacion de la oportunidad de financiamiento
        newOpF.OwnerId = usId[0].Id;
        newOpF.RecordTypeId = idTipoRegistro;
        newOpF.Etapa__c = 'Cotizado y aprobado.';
        newOpF.Valor_Altica__c = Decimal.valueOf(opInfo.valorVehiculo);
        newOpF.Marca_Altica__c = opInfo.marca;
        newOpF.Modelo_Altica__c = opInfo.modelo;
        newOpF.Ano__c = opInfo.anno;
        newOpF.FechaInicioOF__c = System.today();
		newOpF.Origen__c = 'Sitio Web';
        if(listAct.size() == 0 || listAct.isEmpty()){
            Account newAct = new Account();
            if(opInfo.cedula.length() == 9){
             	newAct.RecordTypeId = idCuentaFisico;
                newAct.FirstName = opInfo.nombre;
                newAct.LastName = opInfo.primerApellido + ' ' + opInfo.segundoApellido;
                newAct.Tipo_de_Documento__c = 'Cédula Fisica';
                newAct.Cedula__c = opInfo.cedula;
                newAct.Vendedorasignado__c = '0050P000007SBdc';
                newAct.PersonEmail = opInfo.email;
				System.debug(' ** numero ** ' + opInfo.telefono.substring(4, 5));
				if(opInfo.telefono.substring(4, 5) == '8' || opInfo.telefono.substring(4, 5) == '7' || opInfo.telefono.substring(4, 5) == '6'){
					newAct.PersonMobilePhone = opInfo.telefono;
				}else{
					newAct.Phone = opInfo.telefono;
				}
                newAct.Monedas_Iden__c = 'Colones';
                newAct.Monto_Ingreso__c = 1;   
            }else{
                newAct.RecordTypeId = idCuentaJuridico;
                newAct.Name = opInfo.nombre;
                newAct.Tipo_de_Documento__c = 'Cédula Jurídica';
                newAct.Cedula__c = opInfo.cedula;
                newAct.Vendedorasignado__c = '0050P000007SBdc';
                newAct.CorreoElectronicoEmpresarial__c = opInfo.email;
				if(opInfo.telefono.substring(4, 5) == '8' || opInfo.telefono.substring(4, 5) == '7' || opInfo.telefono.substring(4, 5) == '6'){
					newAct.Mobile_Business__c = opInfo.telefono;
				}else{
					newAct.Phone = opInfo.telefono;
				}
            }
            try{
                insert newAct;
            }catch(DmlException ex){
                response.status = 'error';
                response.message = 'Error al intentar crear el cliente en salesforce. ' + ex.getMessage();
                return response;
			}
            System.debug(' ** cuenta nueva ** ' + newAct);
            System.debug(' ** cuenta nueva nombre ** ' + newAct.Name);
            if(opInfo.cedula.length() == 9){
				newOpF.Name = newAct.FirstName + ' ' + newAct.LastName + '-' + opInfo.marca + '-' + System.today().format();     
            }else{
				 newOpF.Name = newAct.Name + '-' + opInfo.marca + '-' + System.today().format();   
            }
			newOpF.Nombre_Cliente_Altica__c = newAct.Id;
        	newOpF.Numero_de_Identificacion_Altica__c = opInfo.cedula;
            newOpF.Movil_Altica__c = opInfo.telefono;
            newOpF.Email__c = opInfo.email;
        }else{
            newOpF.Name = listAct[0].Name + '-' + opInfo.marca + '-' + System.today().format();
            newOpF.Nombre_Cliente_Altica__c = listAct[0].Id;
        	newOpF.Numero_de_Identificacion_Altica__c = opInfo.cedula;
            newOpF.Movil_Altica__c = opInfo.telefono;
            newOpF.Email__c = opInfo.email;
        }
        System.debug(' ** nueva oportunidad de financiamiento ** ' + newOpF);
        try{
            insert newOpF;
            response.message = 'Oportunidad de financiamiento creada exitosamente.';
            envioNotificacion(newOpF);
        }catch(DmlException ex){
            response.status = 'error';
            response.message = 'Error al intentar crear la oportunidad de financiamiento en salesforce. ' + ex.getMessage();
            return response;
        }
        return response;
    }
    
    //Metodo para realiar la busqueda del cliente
    public static List<Account> buscarCliente(String ced, String fisico, String juridico, String compartido,String CuentaPersonal){
        List<Account> listTempAct = new List<Account>();
        
        listTempAct = [SELECT Id, Name FROM Account WHERE Cedula__c =: ced AND (RecordTypeId =: fisico OR RecordTypeId =: juridico OR RecordTypeId =: compartido OR RecordTypeId =: CuentaPersonal) LIMIT 1];
        return listTempAct;
    }
    
    //Metodo para enviar la alerta de ingreso de nueva oportunidad de financiamiento
    public static void envioNotificacion(Oportunidad_de_Financiamiento__c opF){
        String[] toAddresses = new String[]{};
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        
        System.debug(' ** metodo envio notificacion **');
        //toAddresses.add('david.leon@i-solutionsinc.com');
        toAddresses.add('consultas@alticacr.com');
        email.setSubject('WEB OPORTUNIDAD DE FINANCIAMIENTO');
        email.setPlainTextBody('Se ha generadox una nueva Oportunidad de Financiamiento con el nombre ' + opF.Name + ' el día ' + System.today().format() +
                             ', proveniente de la página web.' + '\n\n' +
                             'Link https://na37.salesforce.com/' + '/' + opF.Id);
        email.setHtmlBody('Se ha generado una nueva Oportunidad de Financiamiento con el nombre ' + opF.Name + ' el día ' + System.today().format() +
                         ', proveniente de la página web.' + '<br><br>' +
                         'Link https://na37.salesforce.com/' + '/' + opF.Id);
        email.setToAddresses(toAddresses);
        email.setSaveAsActivity(false);
        emails.add(email);
        System.debug(' ** email totales ** ' + emails);
        Messaging.sendEmail(emails);
    }
    
    //Clase para manejar el mensaje que se devuelve cuando se consume el metodo httpPost
	global class responseOpF{
    	global String status {get;set;}
    	global String message {get;set;}
    
		global responseOpF() {
      		this.status = 'éxito';
      		this.message = '';
    	}
  	}
    
    //Clase para manejar la informacion de la oportunidad a crear
    public class classOpF{
        public String cedula;
        public String nombre;
        public String primerApellido;
        public String segundoApellido;
        public String email;
        public String telefono;
        public String valorVehiculo;
        public String marca;
        public String modelo;
        public String anno;
        
        public classOpF(){
            this.cedula = '';
            this.nombre = '';
            this.primerApellido = '';
            this.segundoApellido = '';
            this.email = '';
            this.telefono = '';
            this.valorVehiculo = '';
            this.marca = '';
            this.modelo = '';
            this.anno = '';
        }
    }
}