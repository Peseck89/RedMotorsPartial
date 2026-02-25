@RestResource(urlMapping='/getAccountInfo')
global class AccountController {
    @HttpPost
    global static String getAccountInfo(String cedula) {
        Account acc;
        try {
            acc = [SELECT FirstName, LastName, Cedula__c, CorreoElectronicoEmpresarial__c,PersonEmail, Phone FROM Account WHERE Cedula__c = :cedula LIMIT 1];
        } catch (QueryException ex) {
            Map<String, Object> error = new Map<String, Object>();
            error.put('error', 'Cuenta no encontrada');
            return JSON.serialize(error);
        }
        Map<String, Object> result = new Map<String, Object>();
        result.put('firstName', acc.FirstName);
        result.put('lastName', acc.LastName);
        result.put('identification', acc.Cedula__c);
         if (acc.CorreoElectronicoEmpresarial__c != null) {
            result.put('email', acc.CorreoElectronicoEmpresarial__c);
        } else {
            result.put('email', acc.PersonEmail);
        }
        result.put('phone', acc.Phone);
        return JSON.serialize(result);
    }
}