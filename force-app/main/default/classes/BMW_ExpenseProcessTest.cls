@isTest(SeeAllData=false)
public with sharing class BMW_ExpenseProcessTest {
    @isTest(seeAllData=false)
    public static void testExpenseProcess(){
         ActividadComercial__c actividad = new ActividadComercial__c(Name = 'VENTA DE REPUESTOS NUEVOS PARA AUTOMOVIL');
        insert actividad;
        tiposDeTrabajo__c tiposDeTrabajo = new tiposDeTrabajo__c(Name = 'Mantenimiento');
        insert tiposDeTrabajo;
        Pricebook2 pb2 = new Pricebook2();
        pb2.Name='Bavarian Local';
        pb2.CurrencyIsoCode = 'CRC';
        pb2.IsActive=true;
        insert pb2;
        Product2 prod= new Product2();
        prod.IsActive=true;
        prod.Name='Subcontratos Taller Externo Autos';
        prod.Codigo_de_Producto__c='SUB';
        insert prod;
        
        //Id stdPriceBook =  Test.getStandardPricebookId();
        PricebookEntry pd1 = new PricebookEntry();
        pd1.UnitPrice = 1;
        pd1.CurrencyIsoCode = 'CRC';
        pd1.Product2Id = prod.Id;
        pd1.Pricebook2Id = pb2.Id;
        pd1.IsActive = true;
        insert pd1;

        WorkOrder wo = new WorkOrder();
        wo.subject ='title';
        wo.Pricebook2Id=pb2.Id;
        wo.tipoDeGasto__c='Cliente';
        wo.CurrencyIsoCode = 'CRC';
        insert wo;
        Expense gasto = new Expense();
        gasto.WorkOrderId = wo.Id;
        gasto.Title = 'Test Producto';
        gasto.CurrencyIsoCode = 'USD';
        gasto.ExpenseType = 'Facturable';
        gasto.TransactionDate = System.today();
        gasto.Amount = 1000.0;
        gasto.PrecioCliente__c = 1100.0;
        gasto.CalculoGanancia__c = 'Precio sugerido';
        gasto.Discount = 0;
        Test.startTest();
        	insert gasto;
        Test.stopTest();

    }

}