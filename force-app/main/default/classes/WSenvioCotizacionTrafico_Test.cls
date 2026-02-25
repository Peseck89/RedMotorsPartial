@isTest (SeeAllData=true)
public class WSenvioCotizacionTrafico_Test {
    @isTest
    private static void testBMW() {
        Lead ld = [Select id,OwnerId from Lead Where email != null AND Marca__c = 'BMW' and Modelo_De_Inter_s1__c != null  And Cotizacion_1__c = true LIMIT 1 ];
	    String resultado = WSenvioCotizacionTrafico.envioCotizacion(ld.Id, ld.OwnerId);
        //MINI
        Lead ld2 = [Select id,OwnerId from Lead Where email != null AND Marca__c = 'MINI' and Modelo_De_Inter_s1__c != null  And Cotizacion_1__c = true LIMIT 1 ];
	    String resultado2 = WSenvioCotizacionTrafico.envioCotizacion(ld2.Id, ld2.OwnerId);    
        String resultado3 = WSenvioCotizacionTrafico.envioCotizacionMultimarca(ld2.Id, ld2.OwnerId);    
        //Motorrad
        Lead ld3 = [Select id,OwnerId from Lead Where email != null AND Marca__c = 'Motorrad' and Modelo_De_Inter_s1__c != null and Cotizacion_1__c = true LIMIT 1 ];
	    String resultado4 = WSenvioCotizacionTrafico.envioCotizacion(ld2.Id, ld3.OwnerId);    
        String resultado5 = WSenvioCotizacionTrafico.envioCotizacionMultimarca(ld3.Id, ld3.OwnerId);    
        //Polaris
        Lead ld4 = [Select id,OwnerId from Lead Where email != null AND Marca__c = 'Polaris' and Modelo_De_Inter_s1__c != null And Cotizacion_1__c = true LIMIT 1 ];
	    String resultado6 = WSenvioCotizacionTrafico.envioCotizacion(ld4.Id, ld4.OwnerId);    
        String resultado7 = WSenvioCotizacionTrafico.envioCotizacionMultimarca(ld4.Id, ld4.OwnerId);  
        //Kawasaki
        Lead ld5 = [Select id,OwnerId from Lead Where email != null AND Marca__c = 'Kawasaki' and Modelo_De_Inter_s1__c != null LIMIT 1 ];
	    String resultado8 = WSenvioCotizacionTrafico.envioCotizacion(ld5.Id, ld5.OwnerId);    
        String resultado9 = WSenvioCotizacionTrafico.envioCotizacionMultimarca(ld5.Id, ld5.OwnerId);
        
        Lead ld6 = [Select id,OwnerId from Lead Where email != null AND Marca__c = 'KTM' and Modelo_De_Inter_s1__c != null LIMIT 1 ];
	    String resultado10 = WSenvioCotizacionTrafico.envioCotizacion(ld6.Id, ld6.OwnerId);    
        String resultado11 = WSenvioCotizacionTrafico.envioCotizacionMultimarca(ld6.Id, ld6.OwnerId); 

        WSenvioCotizacionTrafico.dummy();
    }
	
}