/**
 * @description       : 
 * @author            : alexander@incompany.cr
 * @group             : 
 * @last modified on  : 08-12-2022
 * @last modified by  : esteban@incompany.cr
**/
@isTest
public class ClientesCallout_Test {
    @isTest
    static void sendMovimientoDataOK200()
    {
        ClientesTestData testData = new ClientesTestData();
        Account clientesTest = testData.generateMovimiento(false);
        String actualResponseBody = '{"statusCode": 0}';
        Map<String, String> mapHeaders = new Map<String,String>();
        mapHeaders.put('Content-Type', 'application/json');
        // Set mock callout class 
        ClientesHttpCalloutMock mock = new ClientesHttpCalloutMock(200, 'OK', actualResponseBody, mapHeaders);
        Test.setMock(HttpCalloutMock.class, mock); 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        HttpResponse response = ClientesCallout.enviarDatosClientes(clientesTest,'sad34324AFAFASF3242');
        
        // Verify that the response received contains fake values
        String contentType = response.getHeader('Content-Type');
        String actualValue = response.getBody();
        String expectedValue = actualResponseBody;
        
        System.assert(contentType == 'application/json');
        System.assertEquals(expectedValue, actualValue);
        System.assertEquals(200, response.getStatusCode());
    }

    @isTest
    static void sendMovimientoDataBadRequest400()
    {
        ClientesTestData testData = new ClientesTestData();
        Account clientesTest = testData.generateMovimiento(false);
        String actualResponseBody = '{"type": "string","title": "string","status": 0,"detail": "string","instance": "string","errors": {"property1":[],"property2": []},"property1": null,"property2": null}';
        Map<String, String> mapHeaders = new Map<String,String>();
        mapHeaders.put('Content-Type', 'application/json');
        // Set mock callout class 
        ClientesHttpCalloutMock mock = new ClientesHttpCalloutMock(400, 'Bad Request',actualResponseBody, mapHeaders);
        Test.setMock(HttpCalloutMock.class, mock); 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        HttpResponse response = ClientesCallout.enviarDatosClientes(clientesTest,'sad34324AFAFASF3242');
        
        // Verify that the response received contains fake values
        String contentType = response.getHeader('Content-Type');
        String actualValue = response.getBody();
        String expectedValue = actualResponseBody;
        
        System.assert(contentType == 'application/json');
        System.assertEquals(expectedValue, actualValue);
        System.assertEquals(400, response.getStatusCode());
    }

    @isTest
    static void getClienteDataFromAlticaRequest200()
    {
        Map<String, String> mapHeaders = new Map<String,String>();
        mapHeaders.put('Content-Type', 'application/json');
        // Set mock callout class 
        ClientesHttpCalloutMock mock = new ClientesHttpCalloutMock(200, 'Ok','', mapHeaders);
        Test.setMock(HttpCalloutMock.class, mock); 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        HttpResponse response = ClientesCallout.getClientesDataFromAltica();
        
        //Verify that the response received contains fake values
        String contentType = response.getHeader('Content-Type');
        
        System.assert(contentType == 'application/json');
        System.assertEquals(200, response.getStatusCode());
    }

    // @isTest
    // static void testAccountRelated(){
    //     Account acc = new Account();
    //     acc.Name = 'Test';
    //     acc.numeroIdentificacion__c = '000000564867';
    //     acc.clienteAltica__c = true; 
        
    //     insert acc;

    //     clientesNacionalidades__c clnac =  new ClientesNacionalidades__c();
    //     clnac.cuenta__c = acc.Id;
    //     clnac.nacionalidad__c = '188';

    //     insert clnac;

    //     ClientesUbicaciones__c clubic = new ClientesUbicaciones__c();
    //     clubic.cuenta__c = acc.Id;
    //     clubic.descripcionUbicacion__c = 'Costa Rica';
    //     clubic.divisionTerritorial__c = '1';
    //     clubic.tipoUbicacion__c = '1';

    //     insert clubic;

    //     clientesFATCA__c clFATCA = new clientesFATCA__c();
    //     clFATCA.cuenta__c = acc.Id;
    //     clFATCA.poseeGreenCard__c = 'S';
    //     clFATCA.numeroEIN__c = 'S';
    //     clFATCA.contribuyenteUSA__c = 'S';
    //     clFATCA.numeroTIN__c = '12312';
    //     clFATCA.domicilioExtranjero__c = 'S';
    //     clFATCA.paisDomicilio__c = 506;
    //     clFATCA.detalleDomicilio__c = 'Costa Rica';
    //     clFATCA.poseeTelefonoExtranjero__c = 'S';
    //     clFATCA.telefonoExtranjero__c = '';
    //     clFATCA.poseeProductos__c = 'S';
    //     clFATCA.detalleProductos__c = '';
        
    //     insert clFATCA;

    //     clientesIngresos__c clIng = new clientesIngresos__c();
    //     clIng.cuenta__c = acc.Id;
    //     clIng.nombreEmpresa__c = 'Nombre'; 
    //     clIng.cargo__c = 'Test';
    //     clIng.actividadEconomica__c = 1;
    //     clIng.telefonoCentral__c = '43534';
    //     clIng.telefonoDirecto__c = 'rec.telefonoDirecto__c';
    //     clIng.direccion__c = 'direccion';
    //     clIng.divisionTerritorial__c = 1;
    //     clIng.origenRecursos__c = '1';
    //     clIng.justificacionOrigenRecursos__c = 'rec.justificacionOrigenRecursos__c';
    //     clIng.detalle__c = 'rec.detalle__c';
    //     clIng.sustentoOtraPersonas__c = 'S';
    //     clIng.detalleSustento__c = 'rec.detalleSustento__c';
    //     clIng.monto__c = 1;
    //     clIng.moneda__c = 1;
        
    //     insert clIng;

    //     ClientesSocios__c clSocios = new ClientesSocios__c();
    //     clSocios.cuenta__c = acc.Id;
    //     clSocios.tipoIdentificacionSocio__c = 1;
    //     clSocios.numeroIdentificacionSocio__c = '1';
    //     clSocios.Name = '1';
    //     clSocios.segundoNombre__c = '1';
    //     clSocios.primerApellido__c = '1';
    //     clSocios.segundoApellido__c = '1';
    //     clSocios.conocidoComo__c = '1';
    //     clSocios.genero__c = 'M';
    //     clSocios.fechaNacimiento__c = Date.today();
    //     clSocios.estadoCivil__c = 'S';
    //     clSocios.paisOrigen__c = 1;
    //     clSocios.profesion__c = 1;
    //     clSocios.actividadEconomica__c = 1;
    //     clSocios.esPep__c = 'S';
    //     clSocios.tipoPep__c = 'R';
    //     clSocios.descripcionPep__c = '1';
    //     clSocios.articulo15__c = 'S';
    //     clSocios.participacion__c = 1;
        
    //     insert clSocios;


    //     ClientesRequest.getClientesNacionalidades(acc.Id);
    //     ClientesRequest.getClientesUbicaciones(acc.Id);
    //     ClientesRequest.getClientesFATCA(acc.Id);
    //     ClientesRequest.getClientesIngresos(acc.Id);
        // ClientesRequest.getClientesFondosTerceros(acc.Id);
        // ClientesRequest.getClientesPatrimonio(acc.Id);
        // ClientesRequest.getClientesFuncionesPEP(acc.Id);
        // ClientesRequest.getClientesTransacciones(acc.Id);
        // ClientesRequest.getClientesPolizas(acc.Id);
        // ClientesRequest.getClientesOtrosAtributos(acc.Id);
        // ClientesRequest.getClientesSocios(acc.Id);
        // ClientesRequest.getClientesRelaciones(acc.Id);
        // ClientesRequest.getClientesRepresentantes(acc.Id);
    // }
}