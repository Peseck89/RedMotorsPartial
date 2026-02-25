/*
  Creado por David Leon IS
  Fecha creacion: 13/01/2019
  Descripcion: Web service rest para la creacion de gestiones desde la pagina web de Altica
*/

@RestResource(UrlMapping='/AlticaGestiones/*')
global class wsCrearGestion_Rest{
    
    @HttpPost
    global static responseGestion crearGestion(){
        String idTipoRegistro, idCuentaJuridico, idCuentaFisico, idCuentaCompartida,idCuentaPersonal;
        Boolean match = false;
        RestRequest req = RestContext.request;
        responseGestion response = new responseGestion();
        Gestion__c gestion = new Gestion__c();
        List<Account> listAct = new List<Account>();
        List<Oportunidad_de_Financiamiento__c> listOpF = new List<Oportunidad_de_Financiamiento__c>();
        
        if(req == null){
            response.status = 'error';
            response.message = 'Información entrante nula';
            return response;
        }
        
        String jsonInput = req.requestBody.toString();
        classGestion newGestion = new classGestion();
        newGestion = (classGestion)JSON.deserialize(jsonInput, classGestion.class);
        System.debug(' ** info entrante ** ' + newGestion);
        
        //Se seleccionan los tipos de registro de opF y cuentas
        idCuentaJuridico = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cliente Jurídico').getRecordTypeId();
        idCuentaFisico = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cliente Físico').getRecordTypeId();
        idCuentaCompartida = Schema.SObjectType.Account.getRecordTypeInfosByName().get('RedMotors-Altica').getRecordTypeId();
        idCuentaPersonal= Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cuenta personal').getRecordTypeId();
        
        //Se hace la busqueda del cliente
        listAct = buscarCliente(newGestion.cedula_cliente, idCuentaFisico, idCuentaJuridico, idCuentaCompartida,idCuentaPersonal);
        System.debug(' ** cuenta cliente ** ' + listAct);
        
        System.debug(' ** validacion cliente ** ');
        if(listAct.isEmpty() || listAct.size() < 1){
            System.debug(' ** validacion cliente 2 ** ');
            response.status = 'Error';
            response.message = '001';
            return response;
        }else{//Se hace la validacion en la oportunidad de financiamiento
            System.debug(' ** validacion opF ** ');
            listOpF = buscarOpF(listAct[0]);
            System.debug(' ** lista opF ** ' + listOpF);
            System.debug(' ** lista size opF ** ' + listOpF.size());
            System.debug(' ** numero operacion SAF ** ' + newGestion.numero_operacion);
            if(listOpF.size() > 1){
                for(Oportunidad_de_Financiamiento__c opF : listOpF){
                    System.debug(' ** numero operacion SAF 2 ** ' + opF.Numero_Operacion_Altica__c);
                    if(newGestion.numero_operacion == opF.Numero_Operacion_Altica__c){
                    	match = true;
                        break;
                    }
                }
                if(!match){
					System.debug(' ** validacion opF error ** ');
                    response.status = 'error';
                    response.message = '002';
                    return response;   
                }
            }
        }
        if(newGestion.tipo_gestion.toLowerCase() == 'saldos proyectados'){
            System.debug(' ** saldos proyectados **');
            idTipoRegistro = Schema.SObjectType.Gestion__c.getRecordTypeInfosByName().get('Saldos Proyectos').getRecordTypeId();
            
            gestion.Name = 'Saldos Proyectados';
            gestion.Numero_Cedula__c = newGestion.cedula_cliente;
			gestion.Fecha_de_la_Proyeccion__c = Date.valueOf(newGestion.fecha_proyeccion);
            gestion.Comentarios_por_parte_del_cliente__c = newGestion.comentarios_cliente;
            gestion.RecordTypeId = idTipoRegistro;
			gestion.Estado__c = 'Pendiente';
			gestion.Email_Cliente__c = newGestion.email;
			gestion.Canal__c = 'Formulario Web';
            if(newGestion.numero_operacion.length() > 0){
                gestion.Numero_Operacion__c = newGestion.numero_operacion;
            }else{
                gestion.Numero_Operacion__c = String.valueOf(listOpF[0].Numero_Operacion_SAF__c);
            }
            if(!listAct.isEmpty() && listAct.size() > 0){
                gestion.Nombre_Completo__c = listAct[0].Id;
            }
        }else if(newGestion.tipo_gestion.toLowerCase() == 'tabla pagos'){
            idTipoRegistro = Schema.SObjectType.Gestion__c.getRecordTypeInfosByName().get('Tabla Pagos').getRecordTypeId();
            
            gestion.Name = 'Tabla Pagos';
            gestion.Numero_Cedula__c = newGestion.cedula_cliente;
            gestion.Comentarios_por_parte_del_cliente__c = newGestion.comentarios_cliente;
            gestion.RecordTypeId = idTipoRegistro;
            gestion.Estado__c = 'Pendiente';
			gestion.Email_Cliente__c = newGestion.email;
			gestion.Canal__c = 'Formulario Web';
            if(newGestion.numero_operacion.length() > 0){
                gestion.Numero_Operacion__c = newGestion.numero_operacion;
            }else{
                gestion.Numero_Operacion__c = String.valueOf(listOpF[0].Numero_Operacion_SAF__c);
            }
            if(!listAct.isEmpty() && listAct.size() > 0){
                gestion.Nombre_Completo__c = listAct[0].Id;
            }
        }else if(newGestion.tipo_gestion.toLowerCase() == 'cambio cuenta bancaria'){
            idTipoRegistro = Schema.SObjectType.Gestion__c.getRecordTypeInfosByName().get('Cambio Cuenta Bancaria').getRecordTypeId();
            
            gestion.Name = 'Cambio Cuenta Bancaria';
            gestion.Numero_Cedula__c = newGestion.cedula_cliente;
            gestion.Nuevo_Numero_de_Cuenta__c = newGestion.nuevo_numero_cuenta;
            gestion.Moneda__c = newGestion.moneda;
            gestion.RecordTypeId = idTipoRegistro;
            gestion.Estado__c = 'Pendiente';
			gestion.Email_Cliente__c = newGestion.email;
			gestion.Canal__c = 'Formulario Web';
            if(newGestion.numero_operacion.length() > 0){
                gestion.Numero_Operacion__c = newGestion.numero_operacion;
            }else{
                gestion.Numero_Operacion__c = String.valueOf(listOpF[0].Numero_Operacion_SAF__c);
            }
            if(!listAct.isEmpty() && listAct.size() > 0){
                gestion.Nombre_Completo__c = listAct[0].Id;
            }
        }else if(newGestion.tipo_gestion.toLowerCase() == 'cambio email facturacion'){
            idTipoRegistro = Schema.SObjectType.Gestion__c.getRecordTypeInfosByName().get('Cambio Email Facturación').getRecordTypeId();
            
            gestion.Name = 'Cambio Email Facturación';
            gestion.Numero_Cedula__c = newGestion.cedula_cliente;
            gestion.Nuevo_Correo_Electronico__c = newGestion.nuevo_email;
            gestion.RecordTypeId = idTipoRegistro;
            gestion.Estado__c = 'Pendiente';
			gestion.Email_Cliente__c = newGestion.email;
			gestion.Canal__c = 'Formulario Web';
            if(newGestion.numero_operacion.length() > 0){
                gestion.Numero_Operacion__c = newGestion.numero_operacion;
            }else{
                gestion.Numero_Operacion__c = String.valueOf(listOpF[0].Numero_Operacion_SAF__c);
            }
            if(!listAct.isEmpty() && listAct.size() > 0){
                gestion.Nombre_Completo__c = listAct[0].Id;
            }
        }else if(newGestion.tipo_gestion.toLowerCase() == 'salida pais'){
            idTipoRegistro = Schema.SObjectType.Gestion__c.getRecordTypeInfosByName().get('Salida País').getRecordTypeId();
            
            gestion.Name = 'Salida País';
            gestion.Numero_Cedula__c = newGestion.cedula_cliente;
            gestion.Persona_Autorizada_A_Realizar_Tramite__c = listAct[0].Id;
            gestion.Numero_Cedula_2__c = newGestion.cedula2;
            gestion.Persona_que_Manejarian_el_Activo__c = newGestion.persona_manejaria_activo;
            gestion.Datos_Activo__c = newGestion.datos_activo;
            gestion.Placa__c = newGestion.placa;
            gestion.Pais_al_que_se_dirige__c = newGestion.pais_dirige;
            gestion.Fecha_salida_del_pais__c = Date.valueOf(newGestion.fecha_salida);
            gestion.Fecha_ingreso_al_pais__c = Date.valueOf(newGestion.fecha_ingreso);
            gestion.RecordTypeId = idTipoRegistro;
            gestion.Estado__c = 'Pendiente';
			gestion.Email_Cliente__c = newGestion.email;
			gestion.Canal__c = 'Formulario Web';
            if(newGestion.numero_operacion.length() > 0){
                gestion.Numero_Operacion__c = newGestion.numero_operacion;
            }else{
                gestion.Numero_Operacion__c = String.valueOf(listOpF[0].Numero_Operacion_SAF__c);
            }
            if(!listAct.isEmpty() && listAct.size() > 0){
                gestion.Nombre_Completo__c = listAct[0].Id;
            }
        }else{
            response.status = 'error';
            response.message = 'No se especifico el tipo de gestion a crear';
            return response;
        }
        
        if(listAct[0].PersonEmail != null && listAct[0].PersonEmail != ''){
            gestion.Email_Cliente__c = listAct[0].PersonEmail;
        }else{
            gestion.Email_Cliente__c = listAct[0].CorreoElectronicoEmpresarial__c;
        }

        try{
            System.debug(' ** gestion nueva ** ' + gestion);
            insert gestion;
            response.message = 'Gestión creada exitosamente';
            envioNotificacion(gestion);
            actualizarCliente(listAct[0], newGestion);
        }catch(DmlException ex){
            response.status = 'error';
            response.message = 'Error al intentar crear la gestión en salesforce. ' + ex.getMessage();
            return response;
        }
        return response;
    }
    
    //Metodo para realiar la busqueda del cliente
    public static List<Account> buscarCliente(String ced, String fisico, String juridico, String compartido, String CuentaPersonal){
        List<Account> listTempAct = new List<Account>();
        
        listTempAct = [SELECT Id, Fecha_Nacimiento__c, PersonEmail, Phone, Canton__c, Provincia__c, CorreoElectronicoEmpresarial__c 
                        FROM Account 
                        WHERE Cedula__c =: ced AND (RecordTypeId =: fisico OR RecordTypeId =: juridico OR RecordTypeId =: compartido OR RecordTypeId =: CuentaPersonal) LIMIT 1];
        System.debug(' ** lista cliente ** ' + listTempAct);
        return listTempAct;
    }
    
    //Metodo para realiar la busqueda de oportunidades de financiamiento
    public static List<Oportunidad_de_Financiamiento__c> buscarOpF(Account act){
        List<Oportunidad_de_Financiamiento__c> listTemp = new List<Oportunidad_de_Financiamiento__c>();
        
        listTemp = [SELECT Id, Numero_Operacion_Altica__c 
                    FROM Oportunidad_de_Financiamiento__c 
                    WHERE Nombre_Cliente_Altica__c =: act.Id];
        return listTemp;
    }
    
    //Metodo para enviar la alerta de ingreso de una nueva gestion
    public static void envioNotificacion(Gestion__c gestion){
        System.debug(' ** gestion ** ' + gestion);
        String[] toAddresses = new String[]{};
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        
        System.debug(' ** metodo envio notificacion **');
        //toAddresses.add('david.leon@i-solutionsinc.com');
		toAddresses.add('consultas@alticacr.com');
        email.setSubject('WEB NUEVA GESTION');
        email.setPlainTextBody('Se ha generado una nueva gestión el día ' + System.today().format() +
                             ', proveniente de la página web.' + '\n\n' +
                             'Link https://na37.salesforce.com/' + '/' + gestion.Id);
        email.setHtmlBody('Se ha generado una nueva gestión el día ' + System.today().format() +
                         ', proveniente de la página web.' + '<br><br>' +
                         'Link https://na37.salesforce.com/' + '/' + gestion.Id);
        email.setToAddresses(toAddresses);
        email.setSaveAsActivity(false);
        emails.add(email);
        System.debug(' ** email totales ** ' + emails);
        Messaging.sendEmail(emails);
    }

    //Metodo para actualizar el cliente en salesforce
    public static void actualizarCliente(Account act, classGestion infoGestion){
        act.Fecha_Nacimiento__c = Date.valueOf(infoGestion.fecha_nacimiento); 
        act.PersonEmail = infoGestion.email;
		if(infoGestion.telefono.substring(4, 5) == '8' || infoGestion.telefono.substring(4, 5) == '7' || infoGestion.telefono.substring(4, 5) == '6'){
			act.PersonMobilePhone = infoGestion.telefono;
		}else{
			act.Phone = infoGestion.telefono;
		}
        act.Canton__c = buscarCanton(infoGestion.canton);
        act.Provincia__c = buscarProvincia(infoGestion.provincia);
        try{
            update act;
        }catch(DmlException ex){
            System.debug(' ** Error actualizando informacion ** ' + ex.getMessage());
        }
    }

    //Metodo para buscar el Id del canton
    public static Id buscarCanton(String nombreCanton){
        String Id;

        Id = [SELECT Id FROM Canton__c WHERE Name =: nombreCanton].Id;
        return Id;
    }

    //Metodo para buscar el Id de la provincia
    public static Id buscarProvincia(String nombreProvincia){
        String Id;

        Id = [SELECT Id FROM Provincia__c WHERE Name =: nombreProvincia].Id;
        return Id;
    }
    
    //Clase para manejar el mensaje que se devuelve cuando se consume el metodo httpPost
	global class responseGestion{
    	global String status {get;set;}
    	global String message {get;set;}
    
		global responseGestion() {
      		this.status = 'éxito';
      		this.message = '';
    	}
  	}
    
    //Clase para manejar la informacion de la oportunidad a crear
    public class classGestion{
        public String cedula_cliente;
        public String nombre_completo;
        public String numero_operacion;
        public String fecha_proyeccion;
        public String comentarios_cliente;
        public String tipo_gestion;
        public String nuevo_numero_cuenta;
        public String moneda;
        public String nuevo_email;
        public String fecha_ingreso;
        public String fecha_salida;
        public String pais_dirige;
        public String placa;
        public String datos_activo;
        public String persona_manejaria_activo;
        public String persona_manejaria_activo_2;
        public String cedula2;
        public String cedula3;
        public String cedula4;
        public String persona_realiza_tramite;
        public String fecha_nacimiento;
        public String canton;
        public String provincia;
        public String telefono;
        public String email;
        
        public classGestion(){
            this.cedula_cliente = '';
            this.nombre_completo = '';
            this.numero_operacion = '';
            this.fecha_proyeccion = '';
            this.comentarios_cliente = '';
            this.tipo_gestion = '';
            this.nuevo_numero_cuenta = '';
            this.moneda = '';
            this.nuevo_email = '';
            this.fecha_ingreso = '';
            this.fecha_salida = '';
            this.pais_dirige = '';
            this.placa = '';
            this.datos_activo = '';
            this.persona_manejaria_activo = '';
            this.cedula2 = '';
            this.cedula3 = '';
            this.cedula4 = '';
            this.persona_realiza_tramite = '';
            this.persona_manejaria_activo_2 = '';
            this.fecha_nacimiento = '';
            this.canton = '';
            this.provincia = '';
            this.telefono = '';
            this.email = '';
        }
    }
}