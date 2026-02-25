/*
  Creado por: David Leon Sanchez IS
  fecha: 22/11/2019
  Descripcion: clase para imprimir el recibo de pago de Altica
*/

public with sharing class reciboPagoPDFController {
    
    public reciboPagoPDFController(){}
    
    public Gestion__c gestion{
        get{
            if(ApexPages.currentPage().getParameters().get('Id') != null){
                gestion = getReciboPago();
            }
            return gestion;
        }
        set;
    }
    
    public Gestion__c getReciboPago(){
        System.debug(' ** ID GESTION RECIBO PAGO ** ' + ApexPages.currentPage().getParameters().get('Id'));
        Gestion__c gestion = new Gestion__c();
        
        gestion = [SELECT Nombre_Completo__r.Name, Numero_Cedula__c, Numero_Operacion__c, Email_Cliente__c, Fecha_Cancelacion__c,
                   Amortizacion__c, Intereses__c, IVA__c, Seguro__c, Cargos__c, Cuota_Mensual__c, Moneda__c, Tipo_Producto__c, Saldo_Inicial__c,
				   Saldo_Final__c
                   FROM Gestion__c 
                   WHERE Id =: ApexPages.currentPage().getParameters().get('Id')];
        System.debug(' ** GESTION ENCONTRADA ** ' + gestion);
        return gestion;
    }
}