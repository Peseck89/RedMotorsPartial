@IsTest
public class ServicioEliminarReservaArticuloQuoteTest {

    private class CalloutMock implements HttpCalloutMock {
        private List<String> lineItemIds;

        public CalloutMock(List<String> lineItemIds) {
            this.lineItemIds = lineItemIds;
        }

        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);

            if (req.getEndpoint().contains('oauth')) {
                
                res.setBody('{"access_token":"test-token-abc"}');
            } else {
                
                res.setBody(
                    '{"compania":"RMBAVARIAN","codigo_respuesta":"00",' +
                    '"detalle_respuesta":"Lineas procesadas exitosamente",' +
                    '"articulos":[' +
                        '{"id_linea":"' + lineItemIds[0] + '",' +
                         '"detalle_respuesta":"SOLICITUD DE DEVOLUCION COMPLETA INGRESADA EXITOSAMENTE"},' +
                        '{"id_linea":"' + lineItemIds[1] + '",' +
                         '"detalle_respuesta":"LINEA ELIMINADA EXITOSAMENTE"},' +
                        '{"id_linea":"' + lineItemIds[2] + '",' +
                         '"detalle_respuesta":"SOLICITUD DE DEVOLUCION PARCIAL INGRESADA EXITOSAMENTE"},' +
                        '{"id_linea":"' + lineItemIds[3] + '",' +
                         '"detalle_respuesta":"ERROR EN SOFTLAND"}' +
                    ']}'
                );
            }
            return res;
        }
    }

  
    @TestSetup
    static void setupData() {
        condicionPago__c cp = new condicionPago__c(
            Name             = 'CONTADO',
            condicionPago__c = '0'
        );
        insert cp;

        Impuesto__c imp = new Impuesto__c(
            codigoImpuesto__c = '0108',
            impuesto__c       = 13
        );
        insert imp;

        Account acc = new Account(
            Name              = 'Test Eliminar Reserva',
            Cedula__c         = '9001002000',
            condicionPago__c  = cp.Id,
            impuesto__c       = imp.Id,
            codigoSoftland__c = 'CLI001'
        );
        insert acc;

        Asset ast = new Asset(
            Name              = 'Test Asset Reserva',
            AccountId         = acc.Id,
            NumeroDeChasis__c = 'VINRESERVA001',
            NumeroDePlaca__c  = 'CRC001'
        );
        insert ast;

        Opportunity opp = new Opportunity(
            Name                         = 'Test Opp Reserva',
            AccountId                    = acc.Id,
            StageName                    = 'Prospecting',
            CloseDate                    = Date.today().addDays(30),
            BMW_Compania__c              = 'Bavarian',
            BMW_PlacaDeVehiculoOElVIN__c = ast.Id
        );
        insert opp;

        Id stdPBId = Test.getStandardPricebookId();

        Product2 prod = new Product2(
            Name                  = 'Test Prod Reserva',
            IsActive              = true,
            Codigo_de_Producto__c = 'TEST-PROD-RSV-001'
        );
        insert prod;

     
        List<PricebookEntry> existingPbe = [
            SELECT Id FROM PricebookEntry
            WHERE Pricebook2Id = :stdPBId AND Product2Id = :prod.Id
            LIMIT 1
        ];
        PricebookEntry stdPbe;
        if (existingPbe.isEmpty()) {
            stdPbe = new PricebookEntry(
                Pricebook2Id = stdPBId,
                Product2Id   = prod.Id,
                UnitPrice    = 100,
                IsActive     = true
            );
            insert stdPbe;
        } else {
            stdPbe = existingPbe[0];
        }

        Quote q = new Quote(
            Name           = 'Test Quote Reserva',
            OpportunityId  = opp.Id,
            Status         = 'Draft',
            Pricebook2Id   = stdPBId,
            ExpirationDate = Date.today().addDays(30)
        );
        insert q;

        // 4 QLIs con diferentes Cantidad_devolucion__c para cubrir las 4 ramas del servicio
        insert new List<QuoteLineItem>{
            new QuoteLineItem(
                QuoteId                = q.Id,
                PricebookEntryId       = stdPbe.Id,
                Quantity               = 5,
                UnitPrice              = 100,
                Cantidad_devolucion__c = 1,
                Estado_entrega__c      = 'Pendiente de devolución'
            ),
            new QuoteLineItem(
                QuoteId                = q.Id,
                PricebookEntryId       = stdPbe.Id,
                Quantity               = 5,
                UnitPrice              = 100,
                Cantidad_devolucion__c = 2,
                Estado_entrega__c      = 'Pendiente de devolución'
            ),
            new QuoteLineItem(
                QuoteId                = q.Id,
                PricebookEntryId       = stdPbe.Id,
                Quantity               = 5,
                UnitPrice              = 100,
                Cantidad_devolucion__c = 0,
                Estado_entrega__c      = 'Pendiente de devolución'
            ),
            new QuoteLineItem(
                QuoteId                = q.Id,
                PricebookEntryId       = stdPbe.Id,
                Quantity               = 5,
                UnitPrice              = 100,
                Cantidad_devolucion__c = 1,
                Estado_entrega__c      = 'Pendiente de devolución'
            )
        };
    }

   
    @IsTest
    static void testEliminarReservaArticulos_CuatroRamas() {
        Quote q = [SELECT Id, QuoteNumber FROM Quote LIMIT 1];
        List<QuoteLineItem> qliList = [
            SELECT Id FROM QuoteLineItem
            WHERE QuoteId = :q.Id
            ORDER BY CreatedDate ASC
        ];
        System.assertEquals(4, qliList.size(), 'Deben existir 4 QuoteLineItems para cubrir las 4 ramas.');

        List<String> lineItemIds = new List<String>();
        for (QuoteLineItem qli : qliList) {
            lineItemIds.add(qli.Id);
        }

        Test.setMock(HttpCalloutMock.class, new CalloutMock(lineItemIds));

        Test.startTest();
        ServicioEliminarReservaArticuloQuote svc = new ServicioEliminarReservaArticuloQuote(q.QuoteNumber, lineItemIds);
        String result = svc.eliminarReservaArticulos();
        Test.stopTest();

        System.assertNotEquals(null, result, 'El resultado no debe ser null');

        // El QLE [1] tiene detalle_respuesta "LINEA ELIMINADA EXITOSAMENTE" → se elimina
        List<QuoteLineItem> eliminado = [SELECT Id FROM QuoteLineItem WHERE Id = :qliList[1].Id];
        System.assertEquals(0, eliminado.size(), 'El QLI con LINEA ELIMINADA debe haberse borrado.');
    }

    @IsTest
    static void testEliminarReservaArticulos_CompaniaRMOTOBAI() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        opp.BMW_Compania__c = 'Otobai';
        update opp;

        Quote q = [SELECT Id, QuoteNumber FROM Quote LIMIT 1];
        List<QuoteLineItem> qliList = [
            SELECT Id FROM QuoteLineItem
            WHERE QuoteId = :q.Id
            ORDER BY CreatedDate ASC
        ];

        List<String> lineItemIds = new List<String>();
        for (QuoteLineItem qli : qliList) {
            lineItemIds.add(qli.Id);
        }

        Test.setMock(HttpCalloutMock.class, new CalloutMock(lineItemIds));

        Test.startTest();
        String result = new ServicioEliminarReservaArticuloQuote(q.QuoteNumber, lineItemIds)
            .eliminarReservaArticulos();
        Test.stopTest();

        System.assertNotEquals(null, result, 'Resultado no debe ser null para RMOTOBAI');
    }
}