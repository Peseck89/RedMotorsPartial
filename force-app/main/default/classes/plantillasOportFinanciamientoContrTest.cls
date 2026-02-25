@isTest()
public class plantillasOportFinanciamientoContrTest {
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
        
        ApexPages.StandardController sc = new ApexPages.StandardController(opf);
        PageReference pageRef = Page.PlantillasOpFinanciamientoContainer;
        pageRef.getParameters().put('id', String.valueOf(opf.Id));
        Test.setCurrentPage(pageRef);        
        plantillasOportFinanciamientoController pfc = new plantillasOportFinanciamientoController(sc);  
        pfc.SelectAll();
        pfc.downloadPDFs();
        pfc.generatePDF();
    }
}