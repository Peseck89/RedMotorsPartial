@IsTest
private class ReciboUsadosTriggerHandler_Test {
	
    static Integer iTotReg = 1;
    
    static {
        TestDataFactory.datosGenerales();
        
        TestDataFactory.createProducts(iTotReg);
        
        TestDataFactory.createPriceBookEntries(iTotReg, Test.getStandardPricebookId());
        
        TestDataFactory.crearCuentas(iTotReg);
        
        TestDataFactory.crearOportunidades(iTotReg,'Oportunidad Calificada');
        
        TestDataFactory.crearProductosOP(iTotReg);
        
        TestDataFactory.crearReciboUsado(iTotReg);

		TestDataFactory.crearConfigReciboUsadosMotos('BMW');

		TestDataFactory.crearReciboUsadoMotos(iTotReg);

		TestDataFactory.crearConfigReciboUsadosMotos('Otras');

		TestDataFactory.crearReciboUsadoMotosOtras(iTotReg);

		TestDataFactory.crearConfigReciboUsadosMotos('KTM');

		TestDataFactory.crearReciboUsadoMotosKTM(iTotReg);

		TestDataFactory.crearConfigReciboUsadosMotos('POLARIS');

		TestDataFactory.crearReciboUsadoMotosPolaris(iTotReg);

		TestDataFactory.crearConfigReciboUsadosMotos('KAWASAKI');

		TestDataFactory.crearReciboUsadoMotosKawasaki(iTotReg);
    }
    
    static testMethod void actualizarReciboUsado() {
        
        list<ReciboUsado__c> listReciboUsados = new list<ReciboUsado__c>();
        listReciboUsados =  TestDataFactory.MapReciboUsados.values();
        
        for(ReciboUsado__c r: listReciboUsados)
        {
            r.Serecibevehiculo__c = true;
        }
        
        Test.startTest();
        update listReciboUsados;
        
        for(ReciboUsado__c r: listReciboUsados)
        {
            r.Serecibevehiculo__c = false;
        }
        
        update listReciboUsados;
        
        Test.stopTest();
        
        
    }

    
}