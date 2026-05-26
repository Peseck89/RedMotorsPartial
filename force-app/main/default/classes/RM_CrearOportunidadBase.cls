public with sharing class RM_CrearOportunidadBase {
    public static List<Account> validarCuenta(String cuentaId) {
        return [
            SELECT Id, FirstName, LastName, Name, Phone, PersonEmail, IsPersonAccount,
                   CorreoElectronicoEmpresarial__c, PersonContactId, Invoice_Email__c
            FROM Account
            WHERE Id = :cuentaId
        ];
    }

    public static List<Account> prepararCuenta(String cuentaId, String nombre, String apellido, String telefono, String email, String emailFact) {
        List<Account> lstAcc = [
            SELECT Id, FirstName, Invoice_Email__c, LastName, Name, Phone, PersonEmail,
                   IsPersonAccount, CorreoElectronicoEmpresarial__c
            FROM Account
            WHERE Id = :cuentaId
        ];

        for (Account cuenta : lstAcc) {
            if (cuenta.IsPersonAccount) {
                cuenta.FirstName = nombre;
                cuenta.LastName = apellido;
                cuenta.PersonEmail = email;
            } else {
                cuenta.Name = nombre;
                cuenta.CorreoElectronicoEmpresarial__c = email;
            }
            cuenta.Phone = telefono;
            cuenta.Invoice_Email__c = emailFact;
        }

        return lstAcc;
    }
}
