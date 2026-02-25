@isTest (SeeAllData=true)
public class envioCotizacionTrafico_Test {
    @isTest
    private static void testBMW() {
        Id campId = [SELECT Id FROM Campaign LIMIT 1].Id;
        Lead ld2 = [Select id,OwnerId from Lead Where email != null AND Marca__c = 'MINI'and Modelo_De_Inter_s1__c != null AND OwnerId = '0054U000009i0CoQAI' LIMIT 1 ];
        Lead ld = new Lead( OwnerId = ld2.OwnerId,
                            LastName = 'Test',
                            Campana__c = campId,
                            FechaPosibleCompra__c = '3 a 6 meses',
                            Email = 'email@test.com', 
                            Cotizacion_1__c = true, 
                            Cotizacion_2__c = true, 
                            Cotizacion_3__c = true, 
                            Cotizacion_4__c = true,
                            Marca__c = 'BMW', 
                            Marca2__c = 'BMW', 
                            Marca3__c = 'BMW', 
                            Marca4__c = 'BMW', 
                            Familia1__c = 'iX',
                            Familia2__c = 'iX',
                            Familia3__c = 'iX',
                            Familia4__c = 'iX',
                            Modelo_De_Inter_s1__c = 'BMW-IX40-VR-PREMIUM', 
                            Modelo_De_Inter_s2__c = 'BMW-IX40-VR-PREMIUM',
                            Modelo_De_Inter_s3__c = 'BMW-IX40-VR-PREMIUM',
                            Modelo_De_Inter_s4__c = 'BMW-IX40-VR-PREMIUM',
                            Ano1__c = '2024',
                            Ano2__c = '2024',
                            Ano3__c = '2024',
                            Ano4__c = '2024'
                            );
        insert ld;
        //Lead ld = [Select id,OwnerId from Lead Where email != null AND Marca__c = 'BMW' and Modelo_De_Inter_s1__c != null LIMIT 1 ];
	    String resultado = envioCotizacionTrafico.envioCotizacion(ld.Id, ld.OwnerId);
        //MINI
	    String resultado2 = envioCotizacionTrafico.envioCotizacion(ld2.Id, ld2.OwnerId);    
        String resultado3 = envioCotizacionTrafico.envioCotizacionMultimarca(ld2.Id, ld2.OwnerId);
        Lead thisLead = envioCotizacionTrafico.getLead(ld.Id);
        envioCotizacionTrafico.dummy();
    }
    @isTest
    private static void testMINI() {
        Id campId = [SELECT Id FROM Campaign LIMIT 1].Id;
        Lead ld2 = [Select id,OwnerId from Lead Where email != null AND Marca__c = 'MINI' AND OwnerId = '0054U000009i0CoQAI' and Modelo_De_Inter_s1__c = 'COOPER-SE-VR-CR' LIMIT 1 ];
        Lead ld = new Lead( OwnerId = ld2.OwnerId,
                            LastName = 'Test',
                            Campana__c = campId,
                            FechaPosibleCompra__c = '3 a 6 meses',
                            Email = 'email@test.com', 
                            Cotizacion_1__c = true, 
                            Cotizacion_2__c = true, 
                            Cotizacion_3__c = true, 
                            Cotizacion_4__c = true,
                            Marca__c = 'MINI', 
                            Marca2__c = 'MINI', 
                            Marca3__c = 'MINI', 
                            Marca4__c = 'MINI', 
                            Familia1__c = 'ELÉCTRICO',
                            Familia2__c = 'ELÉCTRICO',
                            Familia3__c = 'ELÉCTRICO',
                            Familia4__c = 'ELÉCTRICO',
                            Modelo_De_Inter_s1__c = 'COOPER-SE-VR-CR', 
                            Modelo_De_Inter_s2__c = 'COOPER-SE-VR-CR', 
                            Modelo_De_Inter_s3__c = 'COOPER-SE-VR-CR', 
                            Modelo_De_Inter_s4__c = 'COOPER-SE-VR-CR', 
                            Ano1__c = '2024',
                            Ano2__c = '2024',
                            Ano3__c = '2024',
                            Ano4__c = '2024',
	                        RecordTypeId = '0120P000000arDiQAI'
                            );
        insert ld;
        //Lead ld = [Select id,OwnerId from Lead Where email != null AND Marca__c = 'BMW' and Modelo_De_Inter_s1__c != null LIMIT 1 ];
	    String resultado = envioCotizacionTrafico.envioCotizacion(ld.Id, ld.OwnerId);
        //MINI
	    String resultado2 = envioCotizacionTrafico.envioCotizacion(ld2.Id, ld2.OwnerId);    
        String resultado3 = envioCotizacionTrafico.envioCotizacionMultimarca(ld2.Id, ld2.OwnerId);
        Lead thisLead = envioCotizacionTrafico.getLead(ld.Id);
    }
}