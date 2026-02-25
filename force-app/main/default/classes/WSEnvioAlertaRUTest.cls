/**
	@Autor: David Leon Sanchez
	@Fecha creacion: 04/10/2017 
	@Proyecto: Red Motor
	@Proposito: Clase test para probar la funcionalidad de la clase WSEnvioAlertaRU
 */
 
@isTest
private class WSEnvioAlertaRUTest {
	static Integer iTo = 1;
	
	static{
		TestDataFactory.datosGenerales();
		TestDataFactory.crearCuentas(iTo);
		TestDataFactory.crearOportunidades(iTo, 'Oportunidad Calificada');
	}
	
    static testMethod void testVehiculo() {
    	List<RecordType> RTBMW = [Select r.SobjectType, r.Id, r.DeveloperName 
    								From RecordType r where r.SobjectType = 'Opportunity' and r.DeveloperName ='BMW'];
		
		//Creacion de la Oportunidad
		List<Opportunity> opp = TestDataFactory.MapOportunidades.values();
		opp[0].RecordTypeId = RTBMW[0].Id;
		update opp;
		
		//Creacion de Recibo de Usado
		TestDataFactory.crearReciboUsado(iTo);
		List<ReciboUsado__c> recU = TestDataFactory.MapReciboUsados.values();
		
		test.startTest();
			String resultado = WSEnvioAlertaRU.envioEmailRU(recU[0].Id);
		test.stopTest();
    }
    
    static testMethod void testMoto() {
    	List<RecordType> RTKTM = [Select r.SobjectType, r.Id, r.DeveloperName 
    								From RecordType r where r.SobjectType = 'Opportunity' and r.DeveloperName ='KTM'];
		
		//Creacion de la Oportunidad
		List<Opportunity> opp = TestDataFactory.MapOportunidades.values();
		opp[0].RecordTypeId = RTKTM[0].Id;
		update opp;
		
		//Creacion de Recibo de Usado
		TestDataFactory.crearReciboUsado(iTo);
		List<ReciboUsado__c> recU = TestDataFactory.MapReciboUsados.values();
		
		test.startTest();
			String resultado = WSEnvioAlertaRU.envioEmailRU(recU[0].Id);
		test.stopTest();
    }
}