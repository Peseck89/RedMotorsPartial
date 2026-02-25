@isTest()
public class CotizacionPDFControllerTest {
		private static testmethod void validated(){  
        
        Maestro_Plantillas__c mp = new Maestro_Plantillas__c();
        mp.Categoria__c='Automóvil';
        mp.Producto__c ='Leasing operativo en función financiera';
        mp.Sub_Categoria__c = 'Nuevo';
        insert mp;
        
        Plantilla_Formalizacion__c pf = new Plantilla_Formalizacion__c();
        pf.Plantilla__c = 'test body';
        pf.Maestro_Plantillas__c = mp.Id;
        pf.Nombre_de_Plantilla__c = 'test';
        insert pf;
        
        Oportunidad_de_Financiamiento__c opf = new Oportunidad_de_Financiamiento__c();
        opf.Categoria__c = 'Automóvil';
        opf.Subcategoria__c = 'Nuevo'; 
        opf.TipoProducto__c = 'Leasing operativo en función financiera';
        insert opf;
            
        Cotizacion__c ct = new Cotizacion__c();
        ct.Oportunidad_de_Financiamiento__c = opf.id;
        ct.Estado__c = 'Aceptada';
        insert ct;
        
        Tabla_Pagos__c tp = new Tabla_Pagos__c();
        tp.Cotizacion__c = ct.id;
        tp.Index__c = 1;
        insert tp;
        
            tp = new Tabla_Pagos__c();
        tp.Cotizacion__c = ct.id;
        tp.Index__c = 25;
        insert tp;
            
        cargo__c ca = new cargo__c();
        ca.Descripcion_Cargo__c = 'Comisión_Sin_IVA';
            ca.Cotizacion__c = ct.id;
        insert ca;    
            
        Distribucion__c dis = new Distribucion__c();
        dis.Mes_Final__c = 1;
        dis.Mes_Inicial__c = 25;
        dis.Porcentaje_Tasa_Base__c = 10;
        dis.Variable_Tasa_Base__c = 100;
        dis.Cotizacion__c = ct.id;
        dis.Variable_Tasa_Base__c = 1;
        insert dis;
            
        dis = new Distribucion__c();
        dis.Mes_Final__c = 1;
        dis.Mes_Inicial__c = 25;
        dis.Porcentaje_Tasa_Base__c = 10;
        dis.Variable_Tasa_Base__c = 100;
        dis.Cotizacion__c = ct.id;
        dis.Variable_Tasa_Base__c = 0;
        insert dis;
        
            test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(ct);
        //PageReference pageRef = Page.CotizacionPDF;
        //pageRef.getParameters().put('Id', String.valueOf(ct.Id));
        //Test.setCurrentPage(pageRef);
        CotizacionPDFController pfc = new CotizacionPDFController(sc);
            test.stopTest();
    }
}