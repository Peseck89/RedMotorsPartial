@isTest
public class HttpCalloutAddOrderTest {
    @testSetup
    static void setup()
    {
        Impuesto__c Impuesto = new Impuesto__c();
        Impuesto.codigoImpuesto__c='0108';
        Impuesto.descripcion__c='test desc';
        Impuesto.Impuesto__c=2;
        Impuesto.Name='test imp';
        Impuesto.porcentaje__c=3;
        insert Impuesto;
        
        Case cs = new Case();
        insert cs;
        
        
        condicionPago__c condicionPago = new condicionPago__c();
        condicionPago.condicionPago__c='test cp';
        condicionPago.Descripcion__c='test desc';
        condicionPago.Name='CONTADO';
        insert condicionPago;
        
        categoriaCliente__c cet = new categoriaCliente__c();
        cet.categoriaCliente__c = 'COM';
        insert cet;
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Cedula__c = '3102416518';
        insert acc;
        
        ActividadComercial__c act = new ActividadComercial__c();
        act.Name = 'VENTA DE REPUESTOS NUEVOS PARA AUTOMOVIL';
        insert act;
        Id pricebookId = Test.getStandardPricebookId();
        
        CentroCosto__c cc = new CentroCosto__c();
        insert cc;
        
        WorkOrder wo = new WorkOrder();
        wo.subject ='title';
        wo.Pricebook2Id=pricebookId;
        wo.tipoDeGasto__c='Cliente';
        wo.AccountId=acc.Id;
        wo.CaseId=cs.Id;
        //wo.Etapa_de_flujo_de_trabajo__c='Aprobación de presupuesto';
        
        insert wo;

        Order actualOrder = new Order();
        actualOrder.Status = 'Draft';
        actualOrder.Name = 'Test';
        actualOrder.Work_Order__c = wo.Id;
        actualOrder.AccountId = acc.Id;
        actualOrder.EffectiveDate = Date.today();
        insert actualOrder;
        
        
    }
    @isTest
    public static void testHttpCalloutAddOrder() {
        String strJson = '{  "actividad_comercial" : "503004",  "cargo" : "0",  "cod_cliente" : "C081537",  "comentarioCXC" : "",  "compania" : "RMBAVARIAN",  "condicion_pago" : "0",  "kilometros" : "",  "linea" : "",  "lineas" : [ {    "cantidad" : "1.00",    "centro_costo" : "01-RE-000-000",    "cod_articulo" : "36112287346",    "cod_bodega" : null,    "cod_impuesto" : "0108",    "comentario" : "Mano de Obra~",    "cuenta_contable" : null,    "desc_articulo" : "LLANTA 175/60/19 -CONV- 86Q BRIDGESTONE ECOPIA EP5",    "monto_descuento" : "0",    "porc_descuento" : "0",    "precio_unitario" : "426.9854825",    "tipoCargos" : [ {      "centro_costo" : null,      "cliente" : "",      "porcentage" : "1.00",      "tipo_cargo" : "3",      "total_a_facturar" : "35520.20",      "total_descuento" : "0.00",      "total_impuesto" : "35520.20",      "total_mercaderia" : "0.00"    } ],    "total_a_facturar" : "482.4987",    "total_descuento" : "0",    "total_impuesto" : "55.5087","total_mercaderia" : "426.985482500"} ],"marca" : "BMW","matricula" : "WB10E2106N6E75622","modelo" : "S1000RR","moneda" : "D","monto_descuento1" : "0.00","monto_descuento2" : "0","num_Presupuesto" : "00000671","observaciones" : "Escazú - Mecánica Rápida~","orden_trabajo" : "801750000004csJAAQ","porc_descuento1" : "0","porc_descuento2" : "0","recibo" : "0","subtipo_documento" : "","tipo_pedido" : "N","total_a_facturar" : "482.4954825","total_impuesto1" : "55.51","total_impuesto2" : "0","total_mercaderia" : "426.9854825","vin" : ""}';
        orderSoftlandWrapper.parse(strJson);
        
        condicionPago__c cp = new condicionPago__c(condicionPago__c = 'test');
        insert cp;
        
        Order o = [SELECT Id FROM Order WHERE Name='Test'];
        HttpCalloutAddOrder bgv = new HttpCalloutAddOrder();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        bgv.getAddOrderCallout(o.Id,'','','','');
        Test.stopTest();
    }
    @isTest
    public static void testHttpCalloutAddOrder2() {
        String strJson = '{  "actividad_comercial" : "503004",  "cargo" : "0",  "cod_cliente" : "C081537",  "comentarioCXC" : "",  "compania" : "RMBAVARIAN",  "condicion_pago" : "0",  "kilometros" : "",  "linea" : "",  "lineas" : [ {    "cantidad" : "1.00",    "centro_costo" : "01-RE-000-000",    "cod_articulo" : "36112287346",    "cod_bodega" : null,    "cod_impuesto" : "0108",    "comentario" : "Mano de Obra~",    "cuenta_contable" : null,    "desc_articulo" : "LLANTA 175/60/19 -CONV- 86Q BRIDGESTONE ECOPIA EP5",    "monto_descuento" : "0",    "porc_descuento" : "0",    "precio_unitario" : "426.9854825",    "tipoCargos" : [ {      "centro_costo" : null,      "cliente" : "",      "porcentage" : "1.00",      "tipo_cargo" : "3",      "total_a_facturar" : "35520.20",      "total_descuento" : "0.00",      "total_impuesto" : "35520.20",      "total_mercaderia" : "0.00"    } ],    "total_a_facturar" : "482.4987",    "total_descuento" : "0",    "total_impuesto" : "55.5087","total_mercaderia" : "426.985482500"} ],"marca" : "BMW","matricula" : "WB10E2106N6E75622","modelo" : "S1000RR","moneda" : "D","monto_descuento1" : "0.00","monto_descuento2" : "0","num_Presupuesto" : "00000671","observaciones" : "Escazú - Mecánica Rápida~","orden_trabajo" : "801750000004csJAAQ","porc_descuento1" : "0","porc_descuento2" : "0","recibo" : "0","subtipo_documento" : "","tipo_pedido" : "N","total_a_facturar" : "482.4954825","total_impuesto1" : "55.51","total_impuesto2" : "0","total_mercaderia" : "426.9854825","vin" : ""}';
        orderSoftlandWrapper.parse(strJson);
        
        condicionPago__c cp = new condicionPago__c(condicionPago__c = 'test');
        insert cp;
        
        Order o = [SELECT Id FROM Order WHERE Name='Test'];
        WorkOrder wo = [SELECT Id FROM WorkOrder limit 1];
        HttpCalloutAddOrder bgv = new HttpCalloutAddOrder();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        bgv.getAddOrderCallout(o.Id,'','','',wo.id);
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