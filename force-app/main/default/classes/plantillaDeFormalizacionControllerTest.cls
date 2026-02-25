@isTest()
public class plantillaDeFormalizacionControllerTest {
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
        
        ApexPages.StandardController sc = new ApexPages.StandardController(pf);
        PageReference pageRef = Page.PlantillaDeFormalizacion;
        pageRef.getParameters().put('id', String.valueOf(pf.Id));
        Test.setCurrentPage(pageRef);
        
        plantillaDeFormalizacionController pfc = new plantillaDeFormalizacionController();
        pfc = new plantillaDeFormalizacionController(sc);
        pfc.setpar('tetsPar');
        plantillaDeFormalizacionController.updateFieldValue(pf.Id, 'Plantilla__c', 'test', 'name');
    }
}