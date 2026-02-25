@isTest
public class BMW_LineaPlantillaEmpresa_Test {
	static testMethod void TestGetEmpresa() {
        Plantilla_de_Presupuesto__c plantilla = new Plantilla_de_Presupuesto__c();
        plantilla.Nombre__c = 'test';
        plantilla.BMW_Compania__c = 'Bavarian';
        insert plantilla;
		test.startTest();
        BMW_LineaPlantillaEmpresa.getEmpresa(plantilla.Id);
		test.stopTest();        
    }
}