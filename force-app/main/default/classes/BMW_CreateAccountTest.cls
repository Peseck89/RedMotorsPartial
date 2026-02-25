@istest
public class BMW_CreateAccountTest {
        
    static Integer iTotReg = 1;
    static Sucursal__c sucursal;
    static Campaign campanna;       
    
    static {

        TestDataFactory.datosGenerales();
        
        TestDataFactory.crearCuentas(iTotReg);
        
        //Crear campaña.
        campanna = new Campaign
        (
            Name='Campaign'
        );
        
        insert campanna;   
        condicionPago__c cp = new condicionPago__c(condicionPago__c = 'test');
        insert cp;

        
    }

    static testMethod void CrearCliente() {
        Account  acc = [Select Id From Account Limit 1];
        BMW_CreateAccount creaCuenta = new BMW_CreateAccount(new ApexPages.StandardController(acc));
    	ApexPages.currentPage().getParameters().put('Id',acc.Id);
        test.startTest();
        	creaCuenta.callSofltandProcessAccount();
        test.stopTest();

    }
    
        
    

}