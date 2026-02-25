/*
	Creado por: David Leon Sanche IS
	Fecha: 13/03/2018
	Descripcion: Clase para la funcionalidad del objeto Account
*/

public class AccountTriggerHandler extends TriggerHandler {

	private Map<Id, Account> newAcctMap;
    private List<Account> ListNewAccts;
    
    private Map<Id, Account> MapOldAccts;
    private List<Account> ListOldAccts;
    
    public AccountTriggerHandler() {
        this.newAcctMap = (Map<Id, Account>) Trigger.newMap;
        this.ListNewAccts = (List<Account>) Trigger.New;
        this.ListOldAccts = (List<Account>) Trigger.Old;
        this.MapOldAccts = (Map<Id, Account>) Trigger.oldMap;         
        
    }

	public override void beforeInsert(){
		String cedula = '';
		String idClienteFisico, idClienteJuridico;

		idClienteFisico = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cliente Físico').getRecordTypeId();
		idClienteJuridico = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cliente Jurídico').getRecordTypeId();
		System.debug('**** cuenta ***** ' + ListNewAccts);
		//if(ListNewAccts[0].RecordTypeId == idClienteFisico || ListNewAccts[0].RecordTypeId == idClienteJuridico){
			cedula = ListNewAccts[0].Cedula__c;
		//}
        String emailOld = '';
        if(ListNewAccts[0].PersonEmail != null && ListNewAccts[0].PersonEmail != '' ){
            emailOld = ListNewAccts[0].PersonEmail;
        }else if( ListNewAccts[0].CorreoElectronicoEmpresarial__c != null &&  ListNewAccts[0].CorreoElectronicoEmpresarial__c != ''){
            emailOld = ListNewAccts[0].CorreoElectronicoEmpresarial__c;
        }else{
            emailOld = '';
        }
        if(emailOld.length() > 0 && emailOld != '' && emailOld != null){
            if(emailOld != 'n/a@redmotorscr.com'){
                Account[] act = [SELECT Name 
							FROM Account 
							WHERE PersonEmail =: emailOld LIMIT 1];
                System.debug(' ** cuentas encontradas ** ' + act);
                if(act.size() > 0){
                    ListNewAccts[0].addError('El cliente con el correo ' + emailOld + ' ya existe en salesforce. Por favor verificar.');
                }
            }            
        }
		if(String.isNotBlank(cedula)){
			// if(AccountServices.buscarClientes(cedula)){
			// 	ListNewAccts[0].addError('El cliente con el nombre ' + ListNewAccts[0].FirstName + ' ' + ListNewAccts[0].LastName + ' ya existe en salesforce. Por favor verificar.');
			// }
            Account[] act = [SELECT Name 
							FROM Account 
							WHERE Cedula__c =: cedula LIMIT 1];
            System.debug(' ** cuentas encontradas ** ' + act);
            if(act.size() > 0){
                ListNewAccts[0].addError('El cliente con la cedula ' + cedula + ' ya existe en salesforce. Por favor verificar.');
            }
		}
        
        //Esteban Segura Benvavides
        //18-01-2022
        
        if(ListNewAccts[0].Impuesto__c!=null)
        {
            Impuesto__c impuesto = [SELECT Id FROM Impuesto__c WHERE codigoImpuesto__c = '0108' LIMIT 1];
            ListNewAccts[0].Impuesto__c = impuesto.Id;
        }
       	System.debug(ListNewAccts[0].condicionPago__c);
        if(ListNewAccts[0].condicionPago__c!=null)
        {
        	condicionPago__c condicionPago = [SELECT Id FROM condicionPago__c WHERE condicionPago__c = '0' LIMIT 1];
        	ListNewAccts[0].condicionPago__c = condicionPago.Id;
        }
        System.debug(ListNewAccts[0].categoriaCliente__c);
        if(ListNewAccts[0].categoriaCliente__c!=null)
        {
            categoriaCliente__c categoriaCliente = [SELECT Id FROM categoriaCliente__c WHERE categoriaCliente__c = 'COM' LIMIT 1];
            ListNewAccts[0].categoriaCliente__c = categoriaCliente.Id;
        }
	}
}