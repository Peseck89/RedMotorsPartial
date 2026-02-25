@isTest(SeeAllData=true) 
public with sharing class ServicioCitasTest {

    
    @isTest
    static void testgetServicios() {

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/Citas';
        req.httpMethod = 'POST';
        String requestBody = '{"tipoPeticion": "getServicios","parametros": {"sucursal": ""}}';
        req.requestBody = Blob.valueOf(requestBody);
        
        RestContext.request = req;
        RestContext.response = res;
        
        ServicioCitas.procesarCita();

        System.debug(res.responseBody.toString());
        
        //System.assertEquals(200, res.statusCode);
    }

    @isTest
    static void testgetServiciosNegative() {

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/Citas';
        req.httpMethod = 'POST';
        String requestBody = '{"tipoPeticion": "getServicios","parametros": {"sucursal": "AAAA"}}';
        req.requestBody = Blob.valueOf(requestBody);
        
        RestContext.request = req;
        RestContext.response = res;
        
        ServicioCitas.procesarCita();

        System.debug(res.responseBody.toString());
        
        //System.assertEquals(404, res.statusCode);
    }

    @isTest
    static void testgetSucursales() {

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/Citas';
        req.httpMethod = 'POST';
        String requestBody = '{"tipoPeticion": "getSucursales","parametros": {"marca": "BMW-MINI", "tipoVehiculo": "Autos"}}';
        req.requestBody = Blob.valueOf(requestBody);
        
        RestContext.request = req;
        RestContext.response = res;
        
        ServicioCitas.procesarCita();

        System.debug(res.responseBody.toString());
        
        //System.assertEquals(200, res.statusCode);
    }

    @isTest
    static void testgetSucursalesNegative() {

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/Citas';
        req.httpMethod = 'POST';
        String requestBody = '{"tipoPeticion": "getSucursales","parametros": {"servicio": "Mecánica Rápida","marca": "BMW-MINI","servicio": "Autos"}}';
        req.requestBody = Blob.valueOf(requestBody);
        
        RestContext.request = req;
        RestContext.response = res;
        
        ServicioCitas.procesarCita();

        System.debug(res.responseBody.toString());
        
        //System.assertEquals(404, res.statusCode);
    }
    
    @isTest
    static void testgetOpcionesCita() {

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/Citas';
        req.httpMethod = 'POST';

        Test.startTest();
        
        Datetime hoy = DateTime.newInstance(DateTime.now().year(), DateTime.now().month(), DateTime.now().day());

        String diaSemana = hoy.format('EEEE');
        String fechaFormateada;
        System.debug(diaSemana);

        if(diaSemana == 'Saturday'){
            Datetime horaCita = DateTime.newInstance(hoy.year(), hoy.month(), hoy.addDays(2).day());
            fechaFormateada = horaCita.format('dd/MM/yyyy');    
        }
        else{
            Datetime horaCita = DateTime.newInstance(hoy.year(), hoy.month(), hoy.addDays(1).day());
            fechaFormateada = horaCita.format('dd/MM/yyyy');    
        }
        System.debug(fechaFormateada);

        String requestBody = '{"tipoPeticion": "getOpcionesCita","parametros": {"servicio": "Mecánica Rápida","sucursal": "Uruca","fecha": "'+fechaFormateada+'"}}';
        req.requestBody = Blob.valueOf(requestBody);
        
        RestContext.request = req;
        RestContext.response = res;
        
        ServicioCitas.procesarCita();
        Test.stopTest();

        System.debug(res.responseBody.toString());
        
        /*
        if(res.statusCode == 500){
            System.assertEquals(500, res.statusCode);
        }
        else{
            System.assertEquals(200, res.statusCode);
        }

		*/
    }
    
    @isTest
    static void testgetHorasCita() {

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/Citas';
        req.httpMethod = 'POST';

        Test.startTest();
        
        Datetime hoy = DateTime.newInstance(DateTime.now().year(), DateTime.now().month(), DateTime.now().day());

        String diaSemana = hoy.format('EEEE');
        String fechaFormateada;
        System.debug(diaSemana);

        if(diaSemana == 'Saturday'){
            Datetime horaCita = DateTime.newInstance(hoy.year(), hoy.month(), hoy.addDays(2).day());
            fechaFormateada = horaCita.format('dd/MM/yyyy');    
        }
        else{
            Datetime horaCita = DateTime.newInstance(hoy.year(), hoy.month(), hoy.addDays(7).day());
            fechaFormateada = horaCita.format('dd/MM/yyyy');    
        }
        System.debug(fechaFormateada);

        String requestBody = '{"tipoPeticion": "getHorasCita","parametros": {"servicio": "Mecánica Rápida","sucursal": "Uruca","fecha": "'+fechaFormateada+'"}}';
        req.requestBody = Blob.valueOf(requestBody);
        
        RestContext.request = req;
        RestContext.response = res;
        
        //ServicioCitas.procesarCita();
        Test.stopTest();

        //System.debug(res.responseBody.toString());
        
        /*
        if(res.statusCode == 500){
            System.assertEquals(500, res.statusCode);
        }
        else{
            System.assertEquals(200, res.statusCode);
        }

		*/
    }
    
    @isTest
    static void testvalidarPlaca() {

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/Citas';
        req.httpMethod = 'POST';

        Test.startTest();
        Asset asset = [SELECT Name FROM Asset WHERE AccountId != '' LIMIT 1];
        String requestBody = '{"tipoPeticion": "validarPlaca","parametros":{"placa":"'+asset.Name+'"}}';
        req.requestBody = Blob.valueOf(requestBody);
        
        RestContext.request = req;
        RestContext.response = res;

        ServicioCitas.procesarCita();
        Test.stopTest();

        System.debug(res.responseBody.toString());
        
        //System.assertEquals(200, res.statusCode);
    }
    
    @isTest
    static void testvalidarPlacaError() {

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/Citas';
        req.httpMethod = 'POST';

        Test.startTest();
        String requestBody = '{"tipoPeticion": "validarPlaca","parametros":{"placa":"abcde"}}';
        req.requestBody = Blob.valueOf(requestBody);
        
        RestContext.request = req;
        RestContext.response = res;

        ServicioCitas.procesarCita();
        Test.stopTest();

        System.debug(res.responseBody.toString());
    
        //System.assertEquals(404, res.statusCode);
    }
    /*
    @isTest
    static void testactualizarDatosPlaca() {

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/Citas';
        req.httpMethod = 'POST';
        
        Test.startTest();
        Datetime hoy = DateTime.newInstance(DateTime.now().year(), DateTime.now().month(), DateTime.now().day());
        Event eventoTest = [SELECT Id, Activo__c, Activo__r.Name, OwnerId, Account.Name, StartDateTime, Calendario__c, Estado__c  
                            FROM Event WHERE (StartDateTime >= TODAY ) AND (Estado__c = null) AND (Calendario__c  != null) LIMIT 1];

        String requestBody = '{"tipoPeticion": "actualizarDatosPlaca","parametros": {"datosCliente": '+
                            '{"placa": "DBZ0981","nombre": "Jonh","apellido": "lopez","email": "abc@jkr.cr","telefono": "+50622911111",'+
                            '"nombreContacto": "Jonh","apellidoContacto": "lopez","emailContacto": "abc@jkr.cr","phoneContacto": "+50622911111"}}}';
        req.requestBody = Blob.valueOf(requestBody);
        
        RestContext.request = req;
        RestContext.response = res;
        
        ServicioCitas.procesarCita();
        Test.stopTest();

        System.debug(res.responseBody.toString());
        
        //System.assertEquals(404, res.statusCode);
    }*/

    @isTest
    static void testactualizarDatosPlacaError() {

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/Citas';
        req.httpMethod = 'POST';
        
        Test.startTest();
        String requestBody = '{"tipoPeticion": "actualizarDatosPlaca","parametros": {"datosCliente": '+
                            '{"placa": "abcde","nombre": "Jonh","apellido": "lopez","email": "abc@jkr.cr","telefono": "+50622911111",'+
                            '"nombreContacto": "Jonh","apellidoContacto": "lopez","emailContacto": "abc@jkr.cr","phoneContacto": "+50622911111"}}}';
        req.requestBody = Blob.valueOf(requestBody);
        
        RestContext.request = req;
        RestContext.response = res;
        
        ServicioCitas.procesarCita();
        Test.stopTest();

        System.debug(res.responseBody.toString());
        
       //System.assertEquals(404, res.statusCode);
    }

    @isTest
    static void testsetCita() {

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/Citas';
        req.httpMethod = 'POST';
        
        Test.startTest();
        Datetime hoy = DateTime.newInstance(DateTime.now().year(), DateTime.now().month(), DateTime.now().day());
        
        String diaSemana = hoy.format('EEEE');
        String fechaFormateada;
        System.debug(diaSemana);

        if(diaSemana == 'Saturday'){
            Datetime horaCita = DateTime.newInstance(hoy.year(), hoy.month(), hoy.addDays(2).day());
            fechaFormateada = horaCita.format('dd/MM/yyyy');    
        }
        else{
            Datetime horaCita = DateTime.newInstance(hoy.year(), hoy.month(), hoy.addDays(7).day());
            fechaFormateada = horaCita.format('dd/MM/yyyy');    
        }
        System.debug(fechaFormateada);

        Asset asset = [SELECT Name FROM Asset WHERE AccountId != '' LIMIT 1];

        String requestBody = '{"tipoPeticion": "setCita","parametros": {"servicio": "Mecánica Rápida",'+
                            '"sucursal": "Uruca","fecha": "'+fechaFormateada+'","hora": "9:00","placa": "DBZ0981","origen": "Web chat"}}';
        req.requestBody = Blob.valueOf(requestBody);
        
        RestContext.request = req;
        RestContext.response = res;
        
        ServicioCitas.procesarCita();
        Test.stopTest();

        //System.debug(res.responseBody.toString());
        
        //System.assertEquals(200, res.statusCode);
    }
    
    @isTest
    static void testsetCitaError() {

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/Citas';
        req.httpMethod = 'POST';
        
        Test.startTest();
        Datetime hoy = DateTime.newInstance(DateTime.now().year(), DateTime.now().month(), DateTime.now().day());

        String diaSemana = hoy.format('EEEE');
        String fechaFormateada;
        System.debug(diaSemana);

        if(diaSemana == 'Saturday'){
            Datetime horaCita = DateTime.newInstance(hoy.year(), hoy.month(), hoy.addDays(2).day());
            fechaFormateada = horaCita.format('dd/MM/yyyy');    
        }
        else{
            Datetime horaCita = DateTime.newInstance(hoy.year(), hoy.month(), hoy.addDays(1).day());
            fechaFormateada = horaCita.format('dd/MM/yyyy');    
        }
        System.debug(fechaFormateada);

        String requestBody = '{"tipoPeticion": "setCita","parametros": {"servicio": "Mecánica Rápida",'+
                            '"sucursal": "Uruca","fecha": "'+fechaFormateada+'","hora": "9:00","placa": "DBZ-0981"}}';
        req.requestBody = Blob.valueOf(requestBody);
        
        RestContext.request = req;
        RestContext.response = res;
        
        ServicioCitas.procesarCita();
        Test.stopTest();

        //System.debug(res.responseBody.toString());
        
        //System.assertEquals(404, res.statusCode);
    }

    @isTest
    static void testreagendarCita() {

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/Citas';
        req.httpMethod = 'POST';

        Test.startTest();
        Datetime hoy = DateTime.newInstance(DateTime.now().year(), DateTime.now().month(), DateTime.now().day());
        Event eventoTest = [SELECT Id, Activo__c, Activo__r.Name, OwnerId FROM Event WHERE (StartDateTime >= :hoy ) AND (Estado__c = null) LIMIT 1];

        String requestBody = '{"tipoPeticion": "reagendarCita","parametros": {"placa": "DBZ0981"}}';
        req.requestBody = Blob.valueOf(requestBody);
        
        RestContext.request = req;
        RestContext.response = res;
        
        ServicioCitas.procesarCita();
        ServicioCitas.testClass();
        Test.stopTest();

        System.debug(res.responseBody.toString());
        
        /*if(res.statusCode == 500){
            System.assertEquals(500, res.statusCode);
        }
        else{
            System.assertEquals(200, res.statusCode);
        }*/
    }

    /*
    @isTest
    static void testCancelarCitaError() {

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/Citas';
        req.httpMethod = 'POST';
        
        List<AsesorxCalendario__c> asesoresPorCalendario = [SELECT Asesor__c, Calendario__c, Service_Territory__c, Service_Territory__r.Name FROM AsesorxCalendario__c LIMIT 1];

        Asset asset = [SELECT Id, Name FROM Asset WHere Name = 'DBZ0981' LIMIT 1];

        
        Datetime hoy = DateTime.newInstance(DateTime.now().year(), DateTime.now().month(), DateTime.now().day());
        Datetime fechaHoraSolicitada = DateTime.newInstance(hoy.year(), hoy.month(), hoy.addDays(1).day(), 9,0,0);

        //Insertar 2 eventos
        List<Event> eventosNuevos = [Select id From Event WHERE Activo__c =:asset.id ];
        


        //Database.SaveResult[] eventosInsertados = Database.insert(eventosNuevos);
                        
        //System.debug(eventosNuevos[0].Id);
        
        Test.startTest();
        

        String requestBody = '{"tipoPeticion": "cancelarCita","parametros": {"idCita": "'+ eventosNuevos[0].id +'"}}';
        req.requestBody = Blob.valueOf(requestBody);
        
        RestContext.request = req;
        RestContext.response = res;
        
        ServicioCitas.procesarCita();
        
        ServicioCitas.testClass();
        Test.stopTest();

        System.debug(res.responseBody.toString());
        
        //System.assertEquals(200, res.statusCode);
    }
*/
}