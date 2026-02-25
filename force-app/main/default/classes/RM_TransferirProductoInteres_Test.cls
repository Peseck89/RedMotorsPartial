/**
 * Clase de prueba que valida la creacion del producto de interes despues de crear la opportunidad
 * @author Redmotors
 * @since 2024
 * @version 1.0
 */
@IsTest
public with sharing class RM_TransferirProductoInteres_Test {
    
    @TestSetup
    static void makeData(){

        List<Product2> productList = new List<Product2>();  
        Product2 fantasiaBM166X1sDrive18d = TestDataFactory.createProduct('BMW-128-TI-VR-TI', 'BMW-X1', 'BMW', 'Serie 1', 'BMW-128-TI-VR-TI', '2024', 'Rojo','Negro','fantasia',false, false);

        productList.add(fantasiaBM166X1sDrive18d);

        INSERT productList;

        //crear la lista de precio
        Pricebook2 newPB = new Pricebook2(Name = 'BMW - 2024',IsActive = true);
        INSERT newPB;

        //CREAR PRICEBOOKENTRY
        PricebookEntry newPBE = new PricebookEntry(
            Pricebook2Id = newPB.Id,
            Product2Id = fantasiaBM166X1sDrive18d.Id,
            UnitPrice = 100,
            IsActive = true
        );
        INSERT newPBE;

        Lead newLead = new Lead(
            FirstName = 'FirstNameTest001', 
            LastName = 'LastNameTest001',
            Marca__c = 'BMW',
            Modelo_De_Inter_s1__c = 'BMW-128-TI-VR-TI',
            Familia1__c = 'Serie 1',
            Ano1__c = '2024'
            );
        INSERT newLead;

        Account acc = TestDataFactory.createAccount('Account Test Juan C.', false);
        acc.Cedula__c = '123456789012';
        INSERT acc;

        String rtId = TestDataFactory.getRecordTypeId('Campaign','Campana_Red_Motors');
        Campaign campanna = TestDataFactory.createCampanna('Campaign JC',rtId, true); 
    
        Lead oLead = [SELECT Codigo_de_producto__c FROM Lead WHERE Id = :newLead.Id];

        PricebookEntry pbe = [SELECT Id, Pricebook2Id FROM PricebookEntry WHERE Id = :oLead.Codigo_de_producto__c];

        Opportunity opp = TestDataFactory.createOpportunity(acc, 'Oportunidad Calificada', campanna, pbe.Pricebook2Id, true);

    }

    @IsTest
    static void tansfiereProductoInteresDesdeTraficoAOportunidadTest(){
        List<Lead> leads = [SELECT Id, FirstName, LastName, Marca__c, Modelo_De_Inter_s1__c, Familia1__c, Ano1__c, Precio1__c, Codigo_de_producto__c FROM Lead WHERE FirstName = 'FirstNameTest001' AND LastName = 'LastNameTest001'];
        List<PricebookEntry> pbes = [SELECT Id, Pricebook2Id FROM PricebookEntry WHERE Id = :leads[0].Codigo_de_producto__c];
        List<Opportunity> opps = [SELECT Id, Name, AccountId, Pricebook2Id FROM Opportunity WHERE Pricebook2Id = :pbes[0].Pricebook2Id LIMIT 1];
        System.debug('opps: ' + opps);

        RM_TransferirProductoInteres.inputTransferirProductoInteres input = new RM_TransferirProductoInteres.inputTransferirProductoInteres();
        input.leadId = leads[0].Id;
        input.oppId = opps[0].Id;
        List<RM_TransferirProductoInteres.inputTransferirProductoInteres> inputList = new List<RM_TransferirProductoInteres.inputTransferirProductoInteres>();
        inputList.add(input);

        Test.startTest();
            RM_TransferirProductoInteres.transferirProductoInteres(inputList);
        Test.stopTest();
        
        //consultar si el producto de interes fue transferido
        List<OpportunityLineItem> olis = [SELECT Id, Product2Id, PricebookEntryId, UnitPrice, OpportunityId, Modelo_De_Inter_s1__c, Marca__c, Familia1__c, Quantity, PricebookEntry.Vendedor__c, PricebookEntry.Gerente__c, PricebookEntry.Costo_Fijo__c, PricebookEntry.Jefe__c, Anio_Interes__c FROM OpportunityLineItem WHERE OpportunityId = :opps[0].Id];
        //Assert > 0
        Assert.areEqual(1, olis.size());

        List<Oportunidad_Producto_Interes__c> opis = [SELECT Id FROM Oportunidad_Producto_Interes__c WHERE Oportunidad__c = :opps[0].Id];
        //Assert > 0
        Assert.areEqual(1, opis.size());
    }
}