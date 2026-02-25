/**
 * @description       : 
 * @author            : alexander@incompany.cr
 * @group             : 
 * @last modified on  : 21-12-2022
 * @last modified by  : esteban@incompany.cr
**/
public with sharing class ClientesHelper {    
    public static String getJSONClientes(Account clienteActual)
    {
        ClientesRequest jsonCliente = new ClientesRequest(clienteActual);
        return jsonCliente.getJSONClientes();
    }

    public static String getJSONAuthorization(String jsonStr)
    {
        AuthorizationJSON wrapAuthorization = AuthorizationJSON.parseAuthInfo(jsonStr);
        return wrapAuthorization.token;
    }

    public static List<Account> getClientesListFromAltica(ClienteParser clientes)
    {
        List<Account> lstClientes = new List<Account>();

        for(ClienteParser.Cliente actualClienteParser: clientes.clientes)
        {
            Account actualCliente = new Account();
            actualCliente.tipoIdentificacion__c = actualClienteParser.tipoIdentificacion;
            actualCliente.cedula__c = actualClienteParser.numeroIdentificacion;
            actualCliente.Name = actualClienteParser.nombreCliente;
            actualCliente.nombreCliente__c = actualClienteParser.nombreCliente;
            actualCliente.segundoNombreCliente__c = actualClienteParser.segundoNombreCliente;
            actualCliente.primerApellido__c = actualClienteParser.primerApellido;
            actualCliente.segundoApellido__c = actualClienteParser.segundoApellido;
            actualCliente.conocidoComo__c = actualClienteParser.sconocidoComo;
            actualCliente.razonSocial__c = actualClienteParser.razonSocial;
            actualCliente.nombreComercial__c = actualClienteParser.nombreComercial;
            actualCliente.descripcionCuenta__c = actualClienteParser.descripcionCuenta;
            actualCliente.numeroIdentificacionEntidad__c = actualClienteParser.numeroIdentificacionEntidad;
            actualCliente.fechaVencimientoIdentificacion__c = Date.valueOf(actualClienteParser.fechaVencimientoIdentificacion);
            actualCliente.lugarExpedicionIdentificacion__c = actualClienteParser.lugarExpedicionIdentificacion;
            actualCliente.fechaUltimaActualizacion__c = actualClienteParser.fechaUltimaActualizacion!=null?Datetime.valueOf(actualClienteParser.fechaUltimaActualizacion):null;
            actualCliente.genero__c = actualClienteParser.genero;
            actualCliente.codigoOficina__c = Decimal.valueOf(actualClienteParser.codigoOficina);
            actualCliente.usuarioRegistro__c = actualClienteParser.usuarioRegistro;
            actualCliente.administFondosTercero__c = actualClienteParser.administFondosTercero;
            actualCliente.estructuraLegal__c = actualClienteParser.estructuraLegal;
            actualCliente.profesion__c =Decimal.valueOf(actualClienteParser.profesion);
            actualCliente.actividadEconomica__c = Decimal.valueOf(actualClienteParser.actividadEconomica);
            actualCliente.sectorPublico__c = actualClienteParser.sectorPublico;
            actualCliente.institucionLabora__c = actualClienteParser.institucionLabora;
            actualCliente.cantidadAnosLaborar__c = Decimal.valueOf(actualClienteParser.cantidadAnosLaborar);
            actualCliente.monedaIngresoMensual__c = actualClienteParser.monedaIngresoMensual;
            actualCliente.montoIngresoMensual__c = Decimal.valueOf(actualClienteParser.montoIngresoMensual);
            actualCliente.esEmpleado__c = actualClienteParser.esEmpleado;
            actualCliente.esPep__c = actualClienteParser.esPep;
            actualCliente.tipoPep__c = actualClienteParser.tipoPep;
            actualCliente.articulo15__c = actualClienteParser.Articulo15;
            actualCliente.origenFondos__c = actualClienteParser.origenFondos;
            actualCliente.inversionInicial__c = Decimal.valueOf(actualClienteParser.inversionInicial);
            actualCliente.residente__c = actualClienteParser.residente;
            actualCliente.fechaCargaCliente__c = Date.valueOf(actualClienteParser.fechaCargaCliente);
            actualCliente.usuario__c = Decimal.valueOf(actualClienteParser.usuario);
            actualCliente.fechaValor__c = Date.valueOf(actualClienteParser.fechaValor);
            actualCliente.fechaRegistro__c = Date.valueOf(actualClienteParser.fechaRegistro);
            actualCliente.descripcionObservaciones__c = actualClienteParser.descripcionObservaciones;
            actualCliente.esApnfd__c = actualClienteParser.esApnfd;
            actualCliente.tipoApnfd__c = actualClienteParser.tipoApnfd;
            actualCliente.fechaRegistroApnfd__c = Date.valueOf(actualClienteParser.fechaRegistroApnfd);
            actualCliente.entidadSupervisora__c = Decimal.valueOf(actualClienteParser.entidadSupervisora);
            actualCliente.esCpe__c = actualClienteParser.esCpe;
            actualCliente.pagaImpuestos__c = actualClienteParser.pagaImpuestos;
            lstClientes.add(actualCliente);
        }

        return lstClientes;
    }

    public static void upsertClientes(List<Account> lstClientes)
    {
        Set<String> setCedulas = new Set<String>();
        for(Account actualCliente : lstClientes)
        {
            setCedulas.add(actualCliente.cedula__c);
        }

        List<Account> lstClientesActuales = [SELECT Id,cedula__c FROM Account WHERE cedula__c IN :setCedulas AND clienteAltica__c = true];
        Map<String,Account> mapClientesActuales = new Map<String,Account>();
        for(Account actualCliente : lstClientesActuales)
        {
            mapClientesActuales.put(actualCliente.cedula__c,actualCliente);
        }

        List<Account> lstClientesUpdate = new List<Account>();
        List<Account> lstClientesInsert = new List<Account>();
        for(Account actualCliente : lstClientes)
        {
            String strName;
            if(actualCliente.genero__c!='X')
            {
                strName = actualCliente.nombreCliente__c+' '+actualCliente.primerApellido__c+' '+actualCliente.segundoApellido__c;
            } else {
                strName = actualCliente.nombreComercial__c;
            }
            System.debug(strName);
            if(mapClientesActuales.containsKey(actualCliente.cedula__c))
            {
                Account updateAccount = mapClientesActuales.get(actualCliente.cedula__c);
                updateAccount.id = mapClientesActuales.get(actualCliente.cedula__c).Id;
                updateAccount.tipoIdentificacion__c = actualCliente.tipoIdentificacion__c;
                updateAccount.cedula__c = actualCliente.cedula__c;
                //updateAccount.Name = strName;
                updateAccount.nombreCliente__c = actualCliente.nombreCliente__c;
                updateAccount.segundoNombreCliente__c = actualCliente.segundoNombreCliente__c;
                updateAccount.primerApellido__c = actualCliente.primerApellido__c;
                updateAccount.segundoApellido__c = actualCliente.segundoApellido__c;
                updateAccount.conocidoComo__c = actualCliente.conocidoComo__c;
                updateAccount.razonSocial__c = actualCliente.razonSocial__c;
                updateAccount.nombreComercial__c = actualCliente.nombreComercial__c;
                updateAccount.descripcionCuenta__c = actualCliente.descripcionCuenta__c;
                updateAccount.numeroIdentificacionEntidad__c = actualCliente.numeroIdentificacionEntidad__c;
                updateAccount.fechaVencimientoIdentificacion__c = actualCliente.fechaVencimientoIdentificacion__c;
                updateAccount.lugarExpedicionIdentificacion__c = actualCliente.lugarExpedicionIdentificacion__c;
                updateAccount.fechaUltimaActualizacion__c = actualCliente.fechaUltimaActualizacion__c;
                updateAccount.genero__c = actualCliente.genero__c;
                updateAccount.codigoOficina__c = actualCliente.codigoOficina__c;
                updateAccount.usuarioRegistro__c = actualCliente.usuarioRegistro__c;
                updateAccount.administFondosTercero__c = actualCliente.administFondosTercero__c;
                updateAccount.estructuraLegal__c = actualCliente.estructuraLegal__c;
                updateAccount.profesion__c =actualCliente.profesion__c;
                updateAccount.actividadEconomica__c = actualCliente.actividadEconomica__c;
                updateAccount.sectorPublico__c = actualCliente.sectorPublico__c;
                updateAccount.institucionLabora__c = actualCliente.institucionLabora__c;
                updateAccount.cantidadAnosLaborar__c = actualCliente.cantidadAnosLaborar__c;
                updateAccount.monedaIngresoMensual__c = actualCliente.monedaIngresoMensual__c;
                updateAccount.montoIngresoMensual__c = actualCliente.montoIngresoMensual__c;
                updateAccount.esEmpleado__c = actualCliente.esEmpleado__c;
                updateAccount.esPep__c = actualCliente.esPep__c;
                updateAccount.tipoPep__c = actualCliente.tipoPep__c;
                updateAccount.articulo15__c = actualCliente.articulo15__c;
                updateAccount.origenFondos__c = actualCliente.origenFondos__c;
                updateAccount.inversionInicial__c = actualCliente.inversionInicial__c;
                updateAccount.residente__c = actualCliente.residente__c;
                updateAccount.fechaCargaCliente__c = actualCliente.fechaCargaCliente__c;
                updateAccount.usuario__c = actualCliente.usuario__c;
                updateAccount.fechaValor__c = actualCliente.fechaValor__c;
                updateAccount.fechaRegistro__c = actualCliente.fechaRegistro__c;
                updateAccount.descripcionObservaciones__c = actualCliente.descripcionObservaciones__c;
                updateAccount.esApnfd__c = actualCliente.esApnfd__c;
                updateAccount.tipoApnfd__c = actualCliente.tipoApnfd__c;
                updateAccount.fechaRegistroApnfd__c = actualCliente.fechaRegistroApnfd__c;
                updateAccount.entidadSupervisora__c = actualCliente.entidadSupervisora__c;
                updateAccount.esCpe__c = actualCliente.esCpe__c;
                updateAccount.pagaImpuestos__c = actualCliente.pagaImpuestos__c;

                lstClientesUpdate.add(updateAccount);
            } else{
                //Get data to send email to Hernan
                lstClientesInsert.add(actualCliente);
            }
        }
        List<Database.SaveResult> updateResults = Database.update(lstClientesUpdate);

        List<Log__c> logs = new List<Log__c>();
        for(Database.SaveResult result : updateResults)
        {
            if(result.isSuccess() != true)
            {
                for(Database.Error err : result.getErrors()) {
                    Log__c log = new Log__c();
                    log.statusCode__c = String.valueOf(err.getStatusCode());
                    log.errorMessage2__c = 'Update: '+err.getMessage();
                    String fields;
                    for(String field : err.getFields())
                    {
                        fields = field+'\n';
                    }
                    log.fieldError__c = fields;

                    logs.add(log);
                }       
            }
        }
        
        update logs;
        
        //Preapre body message to send email
        String message = 'Las siguientes cuentas requieren la revisión manual de los datos que se están recibiendo en Salesforce desde la base de datos de Altica \n\n';
        for(Account actualCliente : lstClientesInsert)
        {
            String strName;
            if(actualCliente.genero__c!='X')
            {
                strName = actualCliente.nombreCliente__c+' '+actualCliente.primerApellido__c+' '+actualCliente.segundoApellido__c;
            } else {
                strName = actualCliente.nombreComercial__c;
            }
            message += 'Nombre: '+strName+', Cedula: '+actualCliente.cedula__c+'\n\n';
        }

        message += 'Saludos.';

        //Send email to Hernan 
        Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
        
        List<String> lstEmailsToAddress = new List<String>();
        lstEmailsToAddress.add('hrojas@grupo823.com');
        lstEmailsToAddress.add('aobando@alticacr.com');
        
        String[] toAddresses = lstEmailsToAddress;
        String subject ='Reporte de clientes no procesados en la sincronización entre la base de datos de Altica y Salesforce';
        email.setSubject(subject);
        email.setToAddresses( toAddresses );
        email.setPlainTextBody(message);
        if(!Test.isRunningTest())
        {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        }
        
    }

    @TestVisible
    private class AuthorizationJSON
    {
        public String token;
    }

    @TestVisible
    private static AuthorizationJSON parseAuthInfo(String json) {
        return(AuthorizationJSON) System.JSON.deserialize(json, AuthorizationJSON.class);
    }
}