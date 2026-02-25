@isTest
private class KilometrajeHandlerTest {

    @isTest static void testKilometrosDecrementoSinFlag() {
    // Crear cuenta de ejemplo
    Account acct = new Account(
        Name = 'Test Account',
        Cedula__c = '905120921',
        Tipo_de_Documento__c = '01'
    );
    insert acct;

    // Crear asset con kilometraje inicial
    Asset asset = new Asset(
        Name = 'Asset Prueba 1',
        AccountId = acct.Id,
        Kilometros__c = 1000
    );
    insert asset;

    // Asegurar que ambas banderas estén desactivadas
    cT_ChangeData_ctrl.isKilometrajeAdjustment = false;
    cT_ChangeData_ctrl.isTestAdminOverride = false;

    // Intentar disminuir el kilometraje y esperar un error
    asset.Kilometros__c = 900;
    Test.startTest();
    Boolean exceptionThrown = false;
    try {
        update asset;
    } catch (DmlException e) {
        exceptionThrown = true;
    }
    Test.stopTest();

    System.assert(exceptionThrown, 'Se esperaba un error al disminuir Kilómetros sin bandera activa.');
  }

    @isTest static void testKilometrosDecrementoConFlag() {
        // Crear cuenta de ejemplo
        Account acct = new Account(
            Name = 'Test Account',
            Cedula__c = '905120921',
            Tipo_de_Documento__c = '01'

        );
        insert acct;
        
        // Crear asset con kilometraje inicial
        Asset asset = new Asset(
            Name = 'Asset Prueba 2',
            AccountId = acct.Id,
            Kilometros__c = 1000
        );
        insert asset;
        
        // Activar la bandera para permitir ajuste de kilometraje
        cT_ChangeData_ctrl.isKilometrajeAdjustment = true;
        
        // Disminuir el kilometraje
        asset.Kilometros__c = 800;
        Test.startTest();
        update asset;
        Test.stopTest();
        
        // Verificar que el kilometraje se haya actualizado correctamente
        Asset updatedAsset = [SELECT Kilometros__c FROM Asset WHERE Id = :asset.Id];
        System.assertEquals(800, updatedAsset.Kilometros__c, 'La disminución del kilometraje debió permitirse cuando la bandera está activa.');
    }
}