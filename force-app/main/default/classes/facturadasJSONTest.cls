@isTest(seeAllData = true)
public class facturadasJSONTest {
	@isTest
    public static void testFacturadasJSON() {
    	Pricebook2 pb = new Pricebook2();
        pb.Name='Dolar';
        pb.IsActive=true;
        insert pb;
        
        condicionPago__c cp = new condicionPago__c(Name='CONTADO',condicionPago__c='0');
        insert cp; 
        
        categoriaCliente__c cdc = new categoriaCliente__c(categoriaCliente__c = 'COM');
        insert cdc;
        
        Impuesto__c impuesto = new Impuesto__c(impuesto__c = 90,codigoImpuesto__c = '0108');
        insert impuesto;

        
        Account a = new Account();
        a.Name = 'Test Account';
        a.Cedula__c = '1231231232';
        a.condicionPago__c = cp.Id;
        a.categoriaCliente__c = cdc.Id;
        a.impuesto__c = impuesto.Id;
        insert a;
        
        Id pricebookId = Test.getStandardPricebookId();
        CentroCosto__c cc = new CentroCosto__c();
        insert cc;
        WorkOrder wo = new WorkOrder();
        wo.subject ='title';
        wo.Pricebook2Id=pricebookId;
        wo.tipoDeGasto__c='Cliente';
        insert wo;
        WorkOrder tmp = [Select PriceBook2Id from WorkOrder Where Id = :wo.id];
        
        Order o = new Order();
        o.Name = 'Test Order ';
        o.Status = 'Draft';
        o.EffectiveDate = system.today();
        o.EndDate = system.today() + 4;
        o.Pricebook2Id =  pricebookId ;
        o.Work_Order__c = wo.Id;
        o.CurrencyIsoCode = 'CRC';
        o.AccountId = a.id;
        o.Contribuyente__c = a.id;
        insert o;
        
        List<WorkOrder> fact;
            fact =      	[
                				
                				SELECT Id,WorkOrderNumber, Etapa_de_flujo_de_trabajo__c, Fecha_de_facturacion__c, CurrencyIsoCode 
                				FROM WorkOrder 
                				WHERE Id = :wo.Id
                            ];
        
        
    
    	Test.startTest();
        Test.setMock(HttpCalloutMock.class, new facturadaAPICallMock());
        
        String jsonStr = '';
        facturadaJSON.facturadaRequestJSON cntrl = new facturadaJSON.facturadaRequestJSON();
        cntrl.SoftlandCode = o.Id;
        cntrl.OtOriginal = fact[0].WorkOrderNumber ;
        cntrl.Estado = 'F';
        cntrl.TipoCargo = '1';
        System.debug('OtOriginal' + cntrl.OtOriginal);
        
        jsonStr = JSON.serialize(cntrl);
        System.debug(jsonStr);
        facturadaJSON.actualizarFacturada(jsonStr);
        
        System.debug('JsonStr ' + jsonStr);
        
        String jsonStr2 = '';
        facturadaJSON.facturadaRequestJSON cntrl2 = new facturadaJSON.facturadaRequestJSON();
        cntrl2.SoftlandCode = 'ada242qeq';
        cntrl2.OtOriginal = 'asd12321';
        cntrl2.Estado = 'F';
        cntrl2.TipoCargo = '2';
        
        jsonStr2 = JSON.serialize(cntrl2);
        facturadaJSON.actualizarFacturada(jsonStr2);
        
        
        
        Respuesta_pedido__c NuevoPedido = new Respuesta_pedido__c();
        NuevoPedido.ID_Pedido_Softland__c = '12345';
        NuevoPedido.Work_Order__c = wo.Id;
        NuevoPedido.Estado__c = 'Facturado';
        insert NuevoPedido;
        
        
        String jsonStr3 = '';
        facturadaJSON.facturadaRequestJSON cntrl3 = new facturadaJSON.facturadaRequestJSON();
        cntrl3.SoftlandCode = o.Id;
        cntrl3.PedidoID = '12345';
        cntrl3.OtOriginal = fact[0].WorkOrderNumber;
        cntrl3.Estado = 'F';
        cntrl3.TipoCargo = '3';
        
        jsonStr3 = JSON.serialize(cntrl3);
        facturadaJSON.actualizarFacturada(jsonStr3);
        
        
        String jsonStr4 = '';
        facturadaJSON.facturadaRequestJSON cntrl4 = new facturadaJSON.facturadaRequestJSON();
        cntrl4.SoftlandCode = '12345';
        cntrl4.PedidoID = '12345';
        cntrl4.OtOriginal = '12345';
        cntrl4.Estado = 'C';
        
        jsonStr4 = JSON.serialize(cntrl4);
        facturadaJSON.actualizarFacturada(jsonStr4);
        
        facturadaJSON.testClass();
        
        Test.stopTest();
    
    }
    
    public class ExampleCalloutMock implements HttpCalloutMock{
        public HttpResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');
            res.setStatusCode(200);
            res.setBody('{"access_token":"","token_type":""}');
            return res;
        }
    }
}