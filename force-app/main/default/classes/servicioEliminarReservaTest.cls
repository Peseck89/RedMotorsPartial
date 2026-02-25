@isTest
private class servicioEliminarReservaTest {
    
    @isTest
    static void testGetReservaById(){
        //Create test information (Opportunity).
        Opportunity Opp = new Opportunity(	Name = 'Test', 
                                        	BMW_Compania__c = 'Bavarian',
                                         	StageName = 'Oportunidad Calificada', 
                                          	CloseDate = Date.today());
        insert Opp;
        
        Product2 prod = new Product2();
        prod.Name = 'BM105 - X5 - 45e Premium';
        prod.Codigo_de_Producto__c = 'BM105';
        prod.ProductCode = 'BM105';
        prod.IsActive = true;
        prod.Marca__c = 'BMW';
        prod.Description = 'BM105 - X5 - 45e Premium';
        prod.NombredePlantilla__c = 'BMWX5AgradecimientoVisita';
        prod.Familia__c = 'X5';
        prod.Empresa__c = 'RMBAVARIAN';
        insert Prod;
        
        //Realize Test
        Test.startTest();
        //Set Mock callout class.
        Test.setMock(HttpCalloutMock.class, new servicioEliminarReservaMock());
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        String actual = servicioEliminarReserva.getEliminarReservaById(Opp.Id, Prod.Id);
        System.debug('Actual response: ' + actual);
        String expected = '{"operationResult":{"code":"00","description":"EL ARTICULO INDICADO ES VALIDO."}';
        Test.stopTest();
        
        // Verify that the response received contains fake values
        System.assertEquals(expected, actual);
    }

}