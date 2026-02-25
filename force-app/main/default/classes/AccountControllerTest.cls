@isTest
private class AccountControllerTest {
    @isTest
    static void testGetAccountInfo() {
        // Escenario de cuenta encontrada
        Test.startTest();
        Account acc = new Account(Cedula__c = '123456789');
        acc.FirstName = 'Juan';
        acc.LastName = 'Pérez';
        acc.CorreoElectronicoEmpresarial__c = 'juan.perez@empresa.com';
        acc.PersonEmail = 'juan.perez@personal.com';
        acc.Phone = '88348834';
        insert acc;

        String result = AccountController.getAccountInfo('123456789');
        

        Map<String, Object> jsonResult = (Map<String, Object>) JSON.deserializeUntyped(result);
        System.assertEquals('Juan', jsonResult.get('firstName'));
        System.assertEquals('Pérez', jsonResult.get('lastName'));
        System.assertEquals('123456789', jsonResult.get('identification'));
        System.assertEquals('juan.perez@empresa.com', jsonResult.get('email'));
        System.assertEquals('88348834', jsonResult.get('phone'));

        // Escenario de cuenta no encontrada
        
        result = AccountController.getAccountInfo('987654321');
        

        jsonResult = (Map<String, Object>) JSON.deserializeUntyped(result);
        System.assertEquals('Cuenta no encontrada', jsonResult.get('error'));
        
        Test.stopTest();
    }
}