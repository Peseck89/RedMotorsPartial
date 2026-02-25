@isTest
public class llenaImpuestoAlCrearOT_Test {

    @isTest
    static void testOrdenSinImpuestoRelacionado() {
        // Crear una cuenta sin relacionarla a un impuesto
        Account cuenta = new Account(Name = 'Cuenta sin impuesto');
        insert cuenta;

        // Crear una orden relacionada con esa cuenta
        WorkOrder wo = new WorkOrder(
            Subject = 'Orden sin impuesto',
            Status = 'New',
            Cuenta_de_Facturacion__c = cuenta.Id
        );
        insert wo;

        // Verificar que se asignó el impuesto por defecto (13)
        wo = [SELECT Id, Impuesto__c FROM WorkOrder WHERE Id = :wo.Id];
        System.assertEquals(13, wo.Impuesto__c, 'El impuesto debe ser 13 por defecto');
    }

    @isTest
    static void testOrdenSinCuentaDeFacturacion() {
        // Crear una orden de trabajo sin cuenta
        WorkOrder wo = new WorkOrder(
            Subject = 'Orden sin cuenta',
            Status = 'New'
        );
        insert wo;

        // Verificar que se asignó el impuesto por defecto (13)
        wo = [SELECT Id, Impuesto__c FROM WorkOrder WHERE Id = :wo.Id];
        System.assertEquals(13, wo.Impuesto__c, 'El impuesto debe ser 13 si no hay cuenta de facturación');
    }
   

    
}