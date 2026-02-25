/**
 * @description       : 
 * @author            : martin.alvrz.grcs@gmail.com
 * @group             : 
 * @last modified on  : 01-19-2023
 * @last modified by  : martin.alvrz.grcs@gmail.com
**/
@isTest
private class servicioReservasTest {
    
    @isTest
    static void testGetReservaById(){
        //Create test information (Opportunity).
        Opportunity Opp = new Opportunity(	Name = 'Test', 
                                        	BMW_Compania__c = 'Bavarian',
                                         	StageName = 'Oportunidad Calificada', 
                                          	CloseDate = Date.today());
        insert Opp;
        /*Product2 prod = new Product2();
        prod.Description = 'BM105 - X1 - 45e Premium';
        prod.NombredePlantilla__c = 'BMWX1AgradecimientoVisita';
        prod.Empresa__c = 'RMBAVARIAN';
        prod.Name = 'prod '+x;
        prod.Codigo_de_Producto__c = x.format();
        prod.ProductCode = 'prod '+x;
        prod.Marca__c = 'BMW';
        prod.Grupo__c = 'Serie 1';
        prod.Categor_a_veh_culo__c = 'Todos';
        prod.Familia__c = 'Serie 1';
        prod.IsActive = true;
        prod.Color__c = 'rojo';
        prod.modelo__c = 'prod '+x;
        prod.vin__c = 'prod '+x;
        prod.Anno__c = '2024';
        prod.esVehiculo__c = true;
        insert Prod;*/
        String brand = 'BMW';
        String year = '2025';
        String model = 'BMW-118-VR-PAQ-M';
       Product2 Prod = TestDataFactory.createProduct(model, 'BMW-X1', brand, 'Serie 1', model, year, 'Rojo','Negro','Vehiculo',true, false);            
       insert Prod;
        //Realize Test
        Test.startTest();
        //Set Mock callout class.
        Test.setMock(HttpCalloutMock.class, new servicioReservasMock());
            // This causes a fake response to be sent
            // from the class that implements HttpCalloutMock. 
            Map<String,Object> responseMap = servicioReservas.getReservaById(Opp.Id, Prod.Id);

            //String expected = '{"operationResult":{"code":"00","description":"EL ARTICULO INDICADO ES VALIDO."}';
        Test.stopTest();
        
        // Verify that the response received contains fake values
        System.assertEquals(true, (Boolean)responseMap.get('success'));
    }

}