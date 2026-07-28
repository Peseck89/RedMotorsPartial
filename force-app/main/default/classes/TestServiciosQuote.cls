@IsTest
public class TestServiciosQuote {

    @IsTest
    static void testRequestSoftlandQuotePedido() {

        QuoteSoftlandPedidoService servicio = new QuoteSoftlandPedidoService(new List<String>());
        System.assertEquals(0, servicio.getAPICalls().size());
        System.assertEquals(0, servicio.getAccountsToUpdate().size());

		}

    @IsTest
    static void testQuoteSoftlandApiLogServiceSaveLog() {
        Id standardPricebookId = Test.getStandardPricebookId();

        Account cuenta = new Account(Name = 'Cuenta Log Softland');
        insert cuenta;

        Opportunity opp = new Opportunity(
            Name = 'Opp Log Softland',
            AccountId = cuenta.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Pricebook2Id = standardPricebookId
        );
        insert opp;

        Quote quote = new Quote(
            Name = 'Quote Log Softland',
            OpportunityId = opp.Id,
            Pricebook2Id = standardPricebookId,
            Status = 'Draft'
        );
        insert quote;

        Test.startTest();
        QuoteSoftlandApiLogService service = new QuoteSoftlandApiLogService('Log Softland Test', quote.Id);
        service.setRequest('{"request":true}');
        service.setResponse('{"response":true}');
        service.saveLog();
        Test.stopTest();

        APIServiceLog__c log = [
            SELECT Name, Quote__c, JSON__c, Response__c, Status__c
            FROM APIServiceLog__c
            WHERE Name = 'Log Softland Test'
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];

        System.assertEquals(quote.Id, log.Quote__c);
        System.assertEquals('{"request":true}', log.JSON__c);
        System.assertEquals('{"response":true}', log.Response__c);
        System.assertEquals('Success', log.Status__c);
    }

    @IsTest
    static void testRequestSoftlandQuotePedidoConLineasReservadas() {
        createEmpresa('RMBAVARIAN', 'RMBAVARIAN');

        condicionPago__c condicionPago = new condicionPago__c(
            Name = 'CONTADO PEDIDO',
            condicionPago__c = '0',
            Descripcion__c = 'Contado'
        );
        insert condicionPago;

        categoriaCliente__c categoria = new categoriaCliente__c(
            Name = 'Comercial Pedido',
            categoriaCliente__c = 'COM',
            descripcion__c = 'Comercial'
        );
        insert categoria;

        Impuesto__c impuesto = new Impuesto__c(
            Name = 'IVA Pedido',
            codigoImpuesto__c = '0108',
            descripcion__c = 'IVA',
            Impuesto__c = 13,
            porcentaje__c = 13
        );
        insert impuesto;

        Provincia__c provincia = new Provincia__c(
            Name = 'San Jose Pedido',
            CodigoProvincia__c = '01'
        );
        insert provincia;
        Canton__c canton = new Canton__c(
            Name = 'Central Pedido',
            CodigoCanton__c = '01',
            Provincia__c = provincia.Id
        );
        insert canton;
        Distrito__c distrito = new Distrito__c(
            Name = 'Catedral Pedido',
            CodigoDistrito__c = '01',
            Provincia__c = provincia.Id,
            Canton__c = canton.Id
        );
        insert distrito;

        Account cuenta = new Account(
            Name = 'Cuenta Pedido Softland',
            Cedula__c = '3101123456',
            Tipo_de_Documento__c = '02',
            condicionPago__c = condicionPago.Id,
            categoriaCliente__c = categoria.Id,
            Impuesto__c = impuesto.Id,
            Provincia__c = provincia.Id,
            Canton__c = canton.Id,
            Distrito__c = distrito.Id,
            Barrio__c = 'Barrio Pedido',
            Direccion__c = 'Direccion Pedido',
            Phone = '22222222',
            CorreoElectronicoEmpresarial__c = 'pedido@test.com'
        );
        insert cuenta;

        Account aseguradora = new Account(
            Name = 'Aseguradora Pedido Softland',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Aseguradora').getRecordTypeId(),
            Cedula__c = '3101654321',
            Tipo_de_Documento__c = '02',
            condicionPago__c = condicionPago.Id,
            categoriaCliente__c = categoria.Id,
            Impuesto__c = impuesto.Id,
            Provincia__c = provincia.Id,
            Canton__c = canton.Id,
            Distrito__c = distrito.Id,
            Barrio__c = 'Barrio Aseguradora',
            Direccion__c = 'Direccion Aseguradora',
            Phone = '22222223',
            CorreoElectronicoEmpresarial__c = 'aseguradora-pedido@test.com'
        );
        insert aseguradora;

        Opportunity opp = new Opportunity(
            Name = 'Opp Pedido Softland',
            AccountId = cuenta.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            bmw_compania__c = 'Bavarian',
            Sucursal__c = 'Uruca',
            CurrencyIsoCode = 'CRC',
            BMW_Aseguradora__c = aseguradora.Id
        );
        insert opp;

        Id pricebookId = Test.getStandardPricebookId();
        Product2 product = new Product2(
            Name = 'Producto Pedido Softland',
            ProductCode = 'PED-001',
            Codigo_de_Producto__c = 'PED-001',
            CurrencyIsoCode = 'CRC',
            IsActive = true
        );
        insert product;

        List<PricebookEntry> existingPbes = [
            SELECT Id
            FROM PricebookEntry
            WHERE Pricebook2Id = :pricebookId
            AND Product2Id = :product.Id
            AND CurrencyIsoCode = 'CRC'
            LIMIT 1
        ];
        PricebookEntry pbe;
        if (existingPbes.isEmpty()) {
            pbe = new PricebookEntry(
                Pricebook2Id = pricebookId,
                Product2Id = product.Id,
                UnitPrice = 100,
                CurrencyIsoCode = 'CRC',
                IsActive = true
            );
            insert pbe;
        } else {
            pbe = existingPbes[0];
        }

        CentroCosto__c centroCosto = new CentroCosto__c(
            Name = 'Centro Pedido',
            centroCosto__c = 'CC-PEDIDO'
        );
        insert centroCosto;

        Quote quote = new Quote(
            Name = 'Quote Pedido Softland',
            OpportunityId = opp.Id,
            Pricebook2Id = pricebookId,
            CurrencyIsoCode = 'CRC',
            Cuenta_de_facturaci_n2__c = cuenta.Id,
            Centro_de_Costo__c = centroCosto.Id,
            CPEstatusDeAprobacion__c = 'Aprobado',
            Canal_origen__c = 'Presencial',
            BMW_Comentarios__c = 'Comentario pedido'
        );
        insert quote;

        QuoteLineItem qli = new QuoteLineItem(
            QuoteId = quote.Id,
            PricebookEntryId = pbe.Id,
            Quantity = 2,
            UnitPrice = 100,
            Discount = 10,
            Estado_reserva__c = 'Reservado',
            BMW_Alias__c = 'Alias Pedido'
        );
        insert qli;

        Test.setMock(HttpCalloutMock.class, new SoftlandPedidoCalloutMock());

        Test.startTest();
        QuoteSoftlandPedidoService servicio = new QuoteSoftlandPedidoService(new List<String>{ quote.Id });
        Test.stopTest();

        System.assertEquals(1, servicio.getAPICalls().size());
        System.assertEquals('POST', servicio.getAPICalls()[0].method);
        System.assertEquals(1, servicio.getAccountsToUpdate().size());
        System.assert(servicio.getAPICalls()[0].payload.contains('Alias Pedido'));
        System.assert(servicio.getAPICalls()[0].payload.contains('"compania":"RMBAVARIAN"'));
    }

    @IsTest
    static void testQuotePedidoLegacyOtobaiUsesConfiguredErp() {
        createEmpresa('RMOTOBAI', 'RMOTOBAI');
        Id quoteId = createPedidoQuote('Otobai', null, 'OTO-PED-001', 'Quote Pedido Otobai');
        Test.setMock(HttpCalloutMock.class, new SoftlandPedidoCalloutMock());

        Test.startTest();
        QuoteSoftlandPedidoService servicio = new QuoteSoftlandPedidoService(new List<String>{ quoteId });
        Test.stopTest();

        System.assertEquals(1, servicio.getAPICalls().size());
        System.assert(servicio.getAPICalls()[0].payload.contains('"compania":"RMOTOBAI"'));
        System.assert(!servicio.getAPICalls()[0].payload.contains('"compania":"RMBAVARIAN"'));
    }

    @IsTest
    static void testQuotePedidoLookupPekingUsesConfiguredErp() {
        Empresa__c peking = createEmpresa('RMPEKING', 'RMPEKING');
        Id quoteId = createPedidoQuote('Bavarian', peking.Id, 'PEK-PED-001', 'Quote Pedido Peking');
        Test.setMock(HttpCalloutMock.class, new SoftlandPedidoCalloutMock());

        Test.startTest();
        QuoteSoftlandPedidoService servicio = new QuoteSoftlandPedidoService(new List<String>{ quoteId });
        Test.stopTest();

        System.assertEquals(1, servicio.getAPICalls().size());
        System.assert(servicio.getAPICalls()[0].payload.contains('"compania":"RMPEKING"'));
        System.assert(!servicio.getAPICalls()[0].payload.contains('"compania":"RMBAVARIAN"'));
        System.assert(!servicio.getAPICalls()[0].payload.contains('"compania":"RMOTOBAI"'));
    }

    @IsTest
    static void testQuotePedidoNullCompanyStopsBeforeCallout() {
        Id quoteId = createPedidoQuote(null, null, 'NULL-PED-001', 'Quote Pedido Sin Empresa');
        Boolean thrown = false;

        Test.startTest();
        try {
            new QuoteSoftlandPedidoService(new List<String>{ quoteId });
        } catch (AuraHandledException e) {
            thrown = true;
        }
        Test.stopTest();

        System.assert(thrown, 'La empresa nula debe detener el pedido sin caer en Otobai.');
    }

    @IsTest
    static void testQuotePedidoUnsupportedLookupStopsBeforeCallout() {
        Empresa__c unsupported = createEmpresa('RMINVALID', 'RMINVALID');
        Id quoteId = createPedidoQuote('Otobai', unsupported.Id, 'BAD-PED-001', 'Quote Pedido Empresa Invalida');
        Boolean thrown = false;

        Test.startTest();
        try {
            new QuoteSoftlandPedidoService(new List<String>{ quoteId });
        } catch (AuraHandledException e) {
            thrown = true;
        }
        Test.stopTest();

        System.assert(thrown, 'Una empresa no soportada debe detener el pedido sin usar Otobai por descarte.');
    }

    @IsTest
    static void testServicioRestActualizarImpuestoCuentaDoPost() {
        Impuesto__c impuesto = new Impuesto__c(
            Name = 'IVA REST Test',
            codigoImpuesto__c = 'REST0108',
            descripcion__c = 'REST test',
            Impuesto__c = 13,
            porcentaje__c = 13
        );
        insert impuesto;

        Account cuenta = new Account(
            Name = 'Cuenta REST Test',
            Cedula__c = '987654321099',
            Tipo_de_Documento__c = '02',
            codigoSoftland__c = 'RESTSOFT001'
        );
        insert cuenta;

        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/actualizarImpuestoCuenta';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
            'codigoSoftland' => cuenta.codigoSoftland__c,
            'identificacion' => cuenta.Cedula__c,
            'impuesto' => impuesto.codigoImpuesto__c
        }));

        RestContext.request = req;
        RestContext.response = new RestResponse();
        Test.setMock(HttpCalloutMock.class, new SoftlandAccountCalloutMock());

        Test.startTest();
        ServicioRestActualizarImpuestoCuenta.doPost();
        Test.stopTest();

        Account cuentaActualizada = [
            SELECT Impuesto__c
            FROM Account
            WHERE Id = :cuenta.Id
        ];
        System.assertEquals(200, RestContext.response.statusCode);
        System.assertEquals(impuesto.Id, cuentaActualizada.Impuesto__c);
    }

    @IsTest
    static void testServicioRestActualizarImpuestoCuentaBadRequest() {
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/actualizarImpuestoCuenta';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
            'impuesto' => 'REST0108'
        }));

        RestContext.request = req;
        RestContext.response = new RestResponse();

        Test.startTest();
        ServicioRestActualizarImpuestoCuenta.doPost();
        Test.stopTest();

        System.assertEquals(400, RestContext.response.statusCode);
    }

    @IsTest
    static void testServicioRestActualizarImpuestoCuentaNotFound() {
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/actualizarImpuestoCuenta';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
            'codigoSoftland' => 'NO_EXISTE',
            'identificacion' => 'NO_EXISTE',
            'impuesto' => 'REST0108'
        }));

        RestContext.request = req;
        RestContext.response = new RestResponse();

        Test.startTest();
        ServicioRestActualizarImpuestoCuenta.doPost();
        Test.stopTest();

        System.assertEquals(404, RestContext.response.statusCode);
    }

    @IsTest
    static void testServicioRestActualizarImpuestoCuentaError() {
        Account cuenta = new Account(
            Name = 'Cuenta REST Error Test',
            Cedula__c = '987654321098',
            Tipo_de_Documento__c = '02',
            codigoSoftland__c = 'RESTSOFTERR001'
        );
        insert cuenta;

        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/actualizarImpuestoCuenta';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
            'codigoSoftland' => cuenta.codigoSoftland__c,
            'identificacion' => cuenta.Cedula__c,
            'impuesto' => 'IMPUESTO_INEXISTENTE'
        }));

        RestContext.request = req;
        RestContext.response = new RestResponse();

        Test.startTest();
        ServicioRestActualizarImpuestoCuenta.doPost();
        Test.stopTest();

        System.assertEquals(500, RestContext.response.statusCode);
    }

    private static Empresa__c createEmpresa(String codigo, String codigoErp) {
        Empresa__c empresa = new Empresa__c(
            Name = 'Empresa ' + codigo,
            Codigo__c = codigo,
            Codigo_ERP__c = codigoErp,
            Nombre_Legal__c = 'Empresa ' + codigo,
            Activa__c = true
        );
        insert empresa;
        return empresa;
    }

    private static Id createPedidoQuote(String legacyCompany, Id empresaOperadoraId, String productCode, String quoteName) {
        condicionPago__c condicionPago = new condicionPago__c(
            Name = 'CONTADO ' + productCode,
            condicionPago__c = '0',
            Descripcion__c = 'Contado'
        );
        insert condicionPago;

        categoriaCliente__c categoria = new categoriaCliente__c(
            Name = 'Comercial ' + productCode,
            categoriaCliente__c = 'COM',
            descripcion__c = 'Comercial'
        );
        insert categoria;

        Impuesto__c impuesto = new Impuesto__c(
            Name = 'IVA ' + productCode,
            codigoImpuesto__c = '0108',
            descripcion__c = 'IVA',
            Impuesto__c = 13,
            porcentaje__c = 13
        );
        insert impuesto;

        Provincia__c provincia = new Provincia__c(
            Name = 'Provincia ' + productCode,
            CodigoProvincia__c = productCode.right(2)
        );
        insert provincia;
        Canton__c canton = new Canton__c(
            Name = 'Canton ' + productCode,
            CodigoCanton__c = productCode.right(2),
            Provincia__c = provincia.Id
        );
        insert canton;
        Distrito__c distrito = new Distrito__c(
            Name = 'Distrito ' + productCode,
            CodigoDistrito__c = productCode.right(2),
            Provincia__c = provincia.Id,
            Canton__c = canton.Id
        );
        insert distrito;

        Account cuenta = new Account(
            Name = 'Cuenta ' + productCode,
            Cedula__c = '3' + String.valueOf(Math.abs(Crypto.getRandomInteger())).left(9),
            Tipo_de_Documento__c = '02',
            condicionPago__c = condicionPago.Id,
            categoriaCliente__c = categoria.Id,
            Impuesto__c = impuesto.Id,
            Provincia__c = provincia.Id,
            Canton__c = canton.Id,
            Distrito__c = distrito.Id,
            Barrio__c = 'Barrio',
            Direccion__c = 'Direccion',
            Phone = '22222222',
            CorreoElectronicoEmpresarial__c = productCode.toLowerCase() + '@test.com'
        );
        insert cuenta;

        Account aseguradora = new Account(
            Name = 'Aseguradora ' + productCode,
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Aseguradora').getRecordTypeId(),
            Cedula__c = '4' + String.valueOf(Math.abs(Crypto.getRandomInteger())).left(9),
            Tipo_de_Documento__c = '02',
            condicionPago__c = condicionPago.Id,
            categoriaCliente__c = categoria.Id,
            Impuesto__c = impuesto.Id,
            Provincia__c = provincia.Id,
            Canton__c = canton.Id,
            Distrito__c = distrito.Id,
            Barrio__c = 'Barrio',
            Direccion__c = 'Direccion',
            Phone = '22222223',
            CorreoElectronicoEmpresarial__c = 'aseg-' + productCode.toLowerCase() + '@test.com'
        );
        insert aseguradora;

        Opportunity opp = new Opportunity(
            Name = 'Opp ' + productCode,
            AccountId = cuenta.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            bmw_compania__c = legacyCompany,
            Empresa_Operadora__c = empresaOperadoraId,
            Sucursal__c = 'Uruca',
            CurrencyIsoCode = 'CRC',
            BMW_Aseguradora__c = aseguradora.Id
        );
        insert opp;

        Id pricebookId = Test.getStandardPricebookId();
        Product2 product = new Product2(
            Name = 'Producto ' + productCode,
            ProductCode = productCode,
            Codigo_de_Producto__c = productCode,
            CurrencyIsoCode = 'CRC',
            IsActive = true
        );
        insert product;

        List<PricebookEntry> existingPbes = [
            SELECT Id
            FROM PricebookEntry
            WHERE Pricebook2Id = :pricebookId
            AND Product2Id = :product.Id
            AND CurrencyIsoCode = 'CRC'
            LIMIT 1
        ];
        PricebookEntry pbe;
        if (existingPbes.isEmpty()) {
            pbe = new PricebookEntry(
                Pricebook2Id = pricebookId,
                Product2Id = product.Id,
                UnitPrice = 100,
                CurrencyIsoCode = 'CRC',
                IsActive = true
            );
            insert pbe;
        } else {
            pbe = existingPbes[0];
        }

        CentroCosto__c centroCosto = new CentroCosto__c(
            Name = 'Centro ' + productCode,
            centroCosto__c = productCode.left(10)
        );
        insert centroCosto;

        Quote quote = new Quote(
            Name = quoteName,
            OpportunityId = opp.Id,
            Pricebook2Id = pricebookId,
            CurrencyIsoCode = 'CRC',
            Cuenta_de_facturaci_n2__c = cuenta.Id,
            Centro_de_Costo__c = centroCosto.Id,
            CPEstatusDeAprobacion__c = 'Aprobado',
            Canal_origen__c = 'Presencial',
            BMW_Comentarios__c = 'Comentario ' + productCode
        );
        insert quote;

        QuoteLineItem qli = new QuoteLineItem(
            QuoteId = quote.Id,
            PricebookEntryId = pbe.Id,
            Quantity = 1,
            UnitPrice = 100,
            Estado_reserva__c = 'Reservado',
            BMW_Alias__c = 'Alias ' + productCode
        );
        insert qli;

        return quote.Id;
    }

    private class SoftlandAccountCalloutMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setStatus('OK');
            response.setBody('{"access_token":"test-token","token_type":"Bearer","operationResult":{"code":"00","description":"OK"},"Data":[]}');
            return response;
        }
    }

    private class SoftlandPedidoCalloutMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setStatus('OK');

            String endpoint = request.getEndpoint();
            if (endpoint.contains('/oauth/token')) {
                response.setBody('{"access_token":"test-token","token_type":"Bearer"}');
            } else if (endpoint.contains('/softlandAPI/getListPaged')) {
                response.setBody('{"Data":[{"cliente":"C-PEDIDO"}]}');
            } else {
                response.setBody('{"operationResult":{"code":"00","description":"C-PEDIDO"}}');
            }

            return response;
        }
    }

	}
