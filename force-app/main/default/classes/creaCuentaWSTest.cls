@istest
public class creaCuentaWSTest {
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
        Account  acc = [Select Id,Cedula__c From Account Limit 1];
        acc.Cedula__c = '12345678';
        update acc;
        List<String> cedulas = new List<String>();
        cedulas.add(acc.Cedula__c);
        test.startTest();
        	List<String> respuestaCreaCuenta = creaCuentaWS.creaCuentaSoftland(cedulas);
        test.stopTest();

    }

}