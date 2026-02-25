@isTest
public with sharing class AssetValidationController_Test {
    
    @isTest
    public static void testAssetValidationController(){
        Account acc = new Account(
            Name='Test account',
            Cedula__c='9876543210',
            Tipo_de_Documento__c='02',
            codigoSoftland__c = '1234' 
        );  
        insert acc;
        Asset ast = new Asset(
            Name='TEST', 
            AccountId=acc.Id,
            Tipo_de_veh_culo__c='Automóvil',
            Marca_Nvo__c='MINI',
            Modelo_Nvo2__c='COOPER-SE-VR-CLASSIC',
            Anio__c='2020'
        );
        insert ast;
        Case cs = new Case(
            AssetId = ast.Id
        );
        insert cs;
        String result1;
        Boolean result2;
        String AssetWrapper = '{"Id":"' + ast.Id + '","CaseId":"' + cs.Id + '","assetValidateFlag":true,"Asset_Name":"TEST","Asset_Tipo_de_veh_culo":"Automóvil","Asset_Marca_Nvo":"MINI","Asset_Modelo_Nvo":"COOPER","Marca_Otros":null,"Asset_Modelo_Otros":null,"Asset_Anio":"2020","Asset_NumeroDeChasis":"ASDFGH12345678DFL"}';
        Test.startTest();
        result1=AssetValidationController.assetValidation(cs.Id);
        result2=AssetValidationController.assetUpdate(AssetWrapper);
        Test.stopTest();

    }
}