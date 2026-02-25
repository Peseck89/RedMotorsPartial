@isTest
public class actualizarFechaFacturacionVehiculoTest {
    @isTest
    static void testActualizarOportunidadService() {
        // Crear una oportunidad y un producto de oportunidad para la prueba
        // 
        
        Product2 prod = new Product2();
            prod.Name = 'BM101 - X2 - Sdrive 18i Premium';
            prod.modelo__c = 'BM101 - X2 - Sdrive 18i Premium';
            prod.Codigo_de_Producto__c = 'BM101';
            prod.ProductCode = 'BM101';
            prod.IsActive = true;
            prod.Marca__c = 'BMW';
            prod.Description = 'BM101 - X2 - Sdrive 18i Premium';
            prod.NombredePlantilla__c = 'BMWX2AgradecimientoVisita';
            prod.Familia__c = 'X2';
            prod.esVehiculo__c = true;
        	prod.Empresa__c = 'RMBAVARIAN';
            prod.vin__c = 'XYZ789';
        insert prod;
        
        Pricebook2 pb2 = new Pricebook2();
            pb2.Name = 'BMW - 2020';
            pb2.IsActive = true;
        insert pb2;
        
        PricebookEntry pbe = new PricebookEntry();
            pbe.Product2Id = prod.Id;
            pbe.Pricebook2Id = pb2.Id;
            pbe.UnitPrice = 90000;
            pbe.UseStandardPrice = false;
            pbe.IsActive = true;
        insert pbe;
        
        Opportunity Opp = new Opportunity();
            Opp.Name = 'Test';
            Opp.BMW_Compania__c = 'Bavarian';
            Opp.StageName = 'Oportunidad Calificada';
            Opp.CloseDate = Date.today();
            Opp.Pricebook2Id = pb2.Id;
            
        insert Opp;
        
        OpportunityLineItem OppLI = new OpportunityLineItem();
            OppLI.OpportunityId = Opp.Id;
            OppLI.Modelo_De_Inter_s1__c = 'BM101 - X2 - Sdrive 18i Premium';
            OppLI.Reservado__c = false;
            OppLI.Product2Id = prod.Id;
            OppLI.Quantity = 1;
        	OppLI.TotalPrice = pbe.UnitPrice;
        	//OppLI.Producto_Interes__c = prod.Id;
        
         	
        insert OppLI;
        
        Quote Quo = new Quote();
            Quo.Name = 'Test Quote';
            Quo.OpportunityId = Opp.Id;
        	Quo.Pricebook2Id = pb2.Id;
        insert Quo;
        
        QuoteLineItem QuoteLI = new QuoteLineItem();
            QuoteLI.QuoteId = Quo.Id;
            QuoteLI.Product2Id = prod.Id;
        	QuoteLI.PricebookEntryId = pbe.Id;
            QuoteLI.Quantity = 1; 
            QuoteLI.UnitPrice = 2000;
        insert QuoteLI;
        
        Opportunity oppNueva = [SELECT Id, Name, ConsecutivoOportunidad__c FROM Opportunity WHERE Id = :Opp.Id LIMIT 1];
        
        
        
        /*
        OpportunityLineItem opportunityProduct = new OpportunityLineItem(
            OpportunityId = opportunity.Id
            //VINVehiculo__c = 'XYZ789'
        );
        insert opportunityProduct;
        */

		System.debug('Opp consecutivo: ' + oppNueva.ConsecutivoOportunidad__c);
        // Construir el JSON de prueba
        Map<String, Object> jsonMap = new Map<String, Object>{
            'OpportunityId' => oppNueva.ConsecutivoOportunidad__c,
            'FechaDeFacturacion' => String.valueOf(Date.today()),
            'VINVehiculo' => 'XYZ789',
            'Estado' => 'Facturado'
        };
        String requestBody = JSON.serialize(jsonMap);
        
        // Llamar al servicio para actualizar la oportunidad y el producto de oportunidad
        Test.startTest();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.addHeader('Content-Type', 'application/json');
        request.requestUri = '/services/apexrest/actualizarOportunidad';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(requestBody);
        RestContext.request = request;
        RestContext.response= response;
        
        actualizarFechaFacturacionVehiculo.actualizarOportunidad();
        Test.stopTest();

        // Verificar que los campos se hayan actualizado correctamente
        //OpportunityLineItem updatedOpportunityProduct = [SELECT Id, FechaDeFacturacion__c, Estado__c FROM OpportunityLineItem WHERE Id = :OppLI.Id LIMIT 1];
        //System.assertEquals(Date.today(), updatedOpportunityProduct.FechaDeFacturacion__c);
        //System.assertEquals('Facturado', updatedOpportunityProduct.Estado__c);
    }
}