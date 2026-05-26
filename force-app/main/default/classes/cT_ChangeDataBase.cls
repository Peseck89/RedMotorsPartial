public with sharing class cT_ChangeDataBase {
    public static Account createAccount(String nombreCuenta, String apellido, String cedula, String telefono, String fechaNacimiento, String correoElectronico, String nombreEncargado, String telefonoEncargado, Boolean esEmpresarial) {
        List<Account> lstAcc = [Select Id,Name,LastName,FirstName,PersonEmail,CorreoElectronicoEmpresarial__c,Phone,Cedula__c From Account Where Cedula__c =:cedula ];

        if(lstAcc.size()>0){
            return lstAcc[0];
        }else{
            Account newAccount = new Account();
            newAccount.RecordTypeId = esEmpresarial ? '0120P000000aqmZQAQ' : '0120P000000aqoLQAQ';
            if(esEmpresarial){
                newAccount.Name = nombreCuenta;
                newAccount.CorreoElectronicoEmpresarial__c = correoElectronico;
                newAccount.NombreEncargadoCuenta__c = nombreEncargado;
                newAccount.TelefonoEncargadoCuenta__c = telefonoEncargado;
            }else{
                newAccount.FirstName = nombreCuenta;
                newAccount.LastName = apellido;
                newAccount.Invoice_Email__c = correoElectronico;
                newAccount.Invoice_Phone__c = telefono;
                newAccount.PersonEmail = correoElectronico;
            }
            newAccount.Cedula__c = cedula;
            newAccount.Phone = telefono;
            insert newAccount;
            return newAccount;
        }
    }
}
