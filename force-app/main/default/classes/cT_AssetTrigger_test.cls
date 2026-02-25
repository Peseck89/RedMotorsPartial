@isTest(SeeAllData=True)
public class cT_AssetTrigger_test {
    
	private static testmethod void getFilteredDateTest(){ 
        Account Acc = new Account(Name='Test Acc');
        Acc.Name='Test account';
        Acc.Cedula__c='9876543210';
        Acc.Tipo_de_Documento__c='02';
        Acc.codigoSoftland__c = '1234';        
        insert Acc;
        
        Asset newCoche = new Asset();
        newCoche.Anio__c = '2022';
        newCoche.Tipo_de_veh_culo__c = 'Mula';
        newCoche.Marca_Nvo__c = 'Kawasaki Mula';
        newCoche.Modelo_Nvo2__c = 'KW66 - MULE SX™ 4x4 XC FI';
        newCoche.Name = 'CochePrueba123';
        newCoche.AccountId = Acc.id;
        newCoche.NumeroDeChasis__c = 'ASDFGH12345678DDX';
        insert newCoche;
        
        newCoche.Tipo_de_veh_culo__c = 'Motocicleta';
        newCoche.Marca_Nvo__c = 'Polaris Moto';
        newCoche.Modelo_Nvo2__c = 'MN-POLARIS-SPORTMAN-TOU-850';
       	update newCoche;
        
        newCoche.Tipo_de_veh_culo__c = 'Motocicleta';
        newCoche.Marca_Nvo__c = 'BMW Motos';
        newCoche.Modelo_Nvo2__c = 'MN-BMW-ADVENTURE-R1300GS-ADV-ASA';
       	update newCoche;
    }
}