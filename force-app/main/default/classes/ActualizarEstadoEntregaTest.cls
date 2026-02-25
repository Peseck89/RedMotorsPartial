@isTest
public class ActualizarEstadoEntregaTest {
    @isTest static void testDoPost() {
        
        Test.startTest();
        
        ActividadComercial__c actividad = new ActividadComercial__c(Name = 'VENTA DE REPUESTOS NUEVOS PARA AUTOMOVIL');
        insert actividad;
        
        tiposDeTrabajo__c tiposDeTrabajo = new tiposDeTrabajo__c(Name = 'Mantenimiento');
        insert tiposDeTrabajo;
                
        Product2 prod= new Product2();
        prod.IsActive=true;
        prod.Name='Test product Test';
        prod.ProductCode='0001999';
        prod.Codigo_de_Producto__c='00199999';
        insert prod;
        
        List<PricebookEntry> lstPBE = new List<PricebookEntry>();
        Id stdPriceBook =  Test.getStandardPricebookId();
        PricebookEntry pd1 = new PricebookEntry();
        pd1.UnitPrice = 1;
        pd1.CurrencyIsoCode = 'USD';
        pd1.Product2Id = prod.Id;
        pd1.Pricebook2Id = stdPriceBook;
        pd1.IsActive = true;
        lstPBE.add(pd1);
        
        Bodega__c b = new Bodega__c();
        insert b;
        
        ProductoXBodega__c pxb = new ProductoXBodega__c();
        pxb.Producto__c = prod.Id;
        pxb.Bodega__c = b.Id;
        pxb.Disponible__c = 12;
        insert pxb;

        // Insert PricebookEntry
        PricebookEntry standardPBE = [select id, Pricebook2Id, UnitPrice,IsActive,CurrencyIsoCode 
                                      from PricebookEntry 
                                      where Product2Id =:prod.Id 
                                      and CurrencyIsoCode = 'USD'
                                      limit 1];//new PricebookEntry(Pricebook2Id =pricebookId, Product2Id = prod.Id, UnitPrice = 999, IsActive = true);
        System.debug(standardPBE.CurrencyIsoCode);
        
        Pricebook2 pb = new Pricebook2();
        pb.Name='Dolar';
        pb.IsActive=true;
       
        insert pb;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        WorkOrder wo = new WorkOrder();
        wo.subject ='title';
        wo.Pricebook2Id=standardPBE.Pricebook2Id;
        wo.tipoDeGasto__c='Cliente';
        wo.CurrencyIsoCode = 'USD';
        insert wo;
        
        CentroCosto__c cc = new CentroCosto__c();
        insert cc;
        
        CentroCosto__c cc2 = new CentroCosto__c();
        insert cc2;
        
        CentroCosto__c cc3 = new CentroCosto__c();
        insert cc3;
        
        CentroCosto__c cc4 = new CentroCosto__c();
        insert cc4;
        
        WorkOrderLineItem woli = new WorkOrderLineItem();
        woli.workOrderId = wo.Id;
        woli.description = 'abcd';
        woli.Quantity=2;
        woli.PricebookEntryId=standardPBE.Id;
        woli.centroCosto__c = cc.Id;
        insert woli;
        
        
        WorkOrderLineItem woli2 = new WorkOrderLineItem();
        woli2.workOrderId = wo.Id;
        woli2.description = 'abcd';
        woli2.Quantity=3;
        woli2.PricebookEntryId=standardPBE.Id;
        woli2.centroCosto__c = cc.Id;
        insert woli2;
        
        categoriaCliente__c cet = new categoriaCliente__c();
        cet.categoriaCliente__c = 'COM';
        insert cet;
        
        condicionPago__c condicionPago = new condicionPago__c();
        condicionPago.condicionPago__c='0';
        condicionPago.Descripcion__c='test desc';
        condicionPago.Name='test cp';
        insert condicionPago;

        Impuesto__c Impuesto = new Impuesto__c();
        Impuesto.codigoImpuesto__c='0108';
        Impuesto.descripcion__c='test desc';
        Impuesto.Impuesto__c=2;
        Impuesto.Name='IVA-Tarifa General 13%';
        Impuesto.porcentaje__c=3;
        insert Impuesto;
        
        Account acc= new Account();
        acc.Name='Test account';
        acc.Cedula__c='9876543210';
        acc.Tipo_de_Documento__c='02';
        acc.condicionPago__c=condicionPago.Id;
        acc.Impuesto__c=Impuesto.Id;
        insert acc;
        
        //wo.AccountId=acc.Id;
        
        WorkOrder tmp1 = [Select Id, WorkOrderNumber, PriceBook2Id from WorkOrder Where Id = :wo.id];
        WorkOrderLineItem tmp2 = [Select Id, PricebookEntry.pricebook2Id from WorkOrderLineItem Where Id = :woli.id];
        WorkOrderLineItem tmp3 = [Select Id, PricebookEntry.pricebook2Id from WorkOrderLineItem Where Id = :woli2.id];
        
        
        String numeroDeOrden3 = 'aaaa';
        String pedido3 = 'P-123';
        String identificadorLineaOrdenTrabajo3 = '123aqsd';
        String codigoArticulo3 = 'ART-789';
        String estado3 = 'Entregado';
        
        Map<String, Object> jsonMap3 = new Map<String, Object>{
            'numeroDeOrden' => numeroDeOrden3,
            'pedido' => pedido3,
            'identificadorLineaOrdenTrabajo' => identificadorLineaOrdenTrabajo3,
            'codigoArticulo' => codigoArticulo3,
            'estado' => estado3    
        };
        
        
        // Definir los parámetros del método
        String numeroDeOrden1 = tmp1.WorkOrderNumber;
        String pedido1 = 'P-123';
        String identificadorLineaOrdenTrabajo1 = tmp2.id;
        String codigoArticulo1 = 'ART-789';
        String estado1 = 'Entregado';
        
        Map<String, Object> jsonMap1 = new Map<String, Object>{
            'numeroDeOrden' => numeroDeOrden1,
            'pedido' => pedido1,
            'identificadorLineaOrdenTrabajo' => identificadorLineaOrdenTrabajo1,
            'codigoArticulo' => codigoArticulo1,
            'estado' => estado1    
        };
            
        // Definir los parámetros del método para la segunda línea de la orden de trabajo
        String numeroDeOrden2 = tmp1.WorkOrderNumber; // suponemos que estos datos provienen de alguna otra parte de tu test
        String pedido2 = 'P-124';
        String identificadorLineaOrdenTrabajo2 = tmp2.id; // suponemos que estos datos provienen de alguna otra parte de tu test
        String codigoArticulo2 = 'ART-790';
        String estado2 = 'Entregado';
        
        Map<String, Object> jsonMap2 = new Map<String, Object>{
            'numeroDeOrden' => numeroDeOrden2,
            'pedido' => pedido2,
            'identificadorLineaOrdenTrabajo' => identificadorLineaOrdenTrabajo2,
            'codigoArticulo' => codigoArticulo2,
            'estado' => estado2    
        };
        
        // Ahora colocamos ambas líneas en una lista
        List<Map<String, Object>> jsonArray = new List<Map<String, Object>>{jsonMap1, jsonMap2};
        
            
        String requestBody = JSON.serialize(jsonArray);

        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.addHeader('Content-Type', 'application/json');
        request.requestUri = '/services/apexrest/actualizarOportunidad';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(requestBody);
        RestContext.request = request;
        RestContext.response= response;
        
        //actualizarFechaFacturacionVehiculo.actualizarOportunidad();
        
        ActualizarEstadoEntrega.woliEntregado();
        
        
        
        List<Map<String, Object>> jsonArray2 = new List<Map<String, Object>>{jsonMap3};
        
            
        String requestBody2 = JSON.serialize(jsonArray2);

        
        RestRequest request2 = new RestRequest();
        RestResponse response2 = new RestResponse();
        request2.addHeader('Content-Type', 'application/json');
        request2.requestUri = '/services/apexrest/actualizarOportunidad';
        request2.httpMethod = 'POST';
        request2.requestBody = Blob.valueOf(requestBody2);
        RestContext.request = request2;
        RestContext.response= response2;
        System.debug('Error level message' + requestBody2);
        ActualizarEstadoEntrega.woliEntregado();
        
        
        Test.stopTest();

      

    }


}