@isTest
public class OpportunityExtensionTest {

    @testSetup
    static void setupTestData() {
        Integer num = 1;
                Integer num2 = 1;

       		TestDataFactory.datosGenerales();
List<Opportunity> listOps = new List<Opportunity>();
    	List<OpportunityLineItem> listProd =  new List<OpportunityLineItem>();
    	
        //crear cuenta
        TestDataFactory.crearCuentas(num);
        
        //crear productos
        TestDataFactory.createProducts(num2);
        
        //crear precios
        TestDataFactory.createPriceBookEntries(num2, Test.getStandardPricebookId());
        
        //crear Oportunidad de Negocio
        TestDataFactory.crearOportunidades(num, 'Test Drive');
        
        //crear productos para la Oportunidad de negocio
        TestDataFactory.crearProductosOP(num);
		TestDataFactory.crearProductosOP(num);
        
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        // Crear un ReciboUsado de prueba
        ReciboUsado__c recibo = new ReciboUsado__c(
            Oportunidad__c = opp.Id,
            Name = 'Prueba recibo',
            Ano__c                  =   '2017',
                Marca__c                =   'BMW',
                Modelo__c               =   '2017',
                Placa__c                =   num.format(),
                Serecibevehiculo__c     =   true,
                Color__c                =   'AZUL',
                Combustible__c          =   'GASOLINA',
                EstiloUsado__c          =   'TODO TERRENO',
                Trasmision__c           =   'AUTOMATICA',
                Kilometraje__c          =   2000,
                Traccion__c             =   '4x4',
                N_puertas__c            =   4,                
                Revendedor__c           =   true,
                ValorReciboCliente__c   =   60000.00,
                ReciboJefeUsados__c     =   40000.00,
                Valor_final__c          =   50000.00,
                Valor_inicial__c        =   70000.00,
                Fecha_de_recibo__c      =   Date.today() 
        );
        insert recibo;
    }
    
    @isTest
    static void testOpportunityExtensionMethods() {
        // Recuperar la oportunidad insertada en el test setup
                Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        // Instanciar el controlador estándar con la oportunidad
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        OpportunityExtension ext = new OpportunityExtension(sc);
        
        // Probar getReciboUsado
        Test.startTest();
        ReciboUsado__c reciboUsado = ext.getReciboUsado();
       

        // Probar getOppProduct
       
        OpportunityLineItem oppProduct = ext.getOppProduct();
        
        // Probar getProduct
       
        Product2 product = ext.getProduct();
        Test.stopTest();
        
    }
}