@isTest(seeAllData = true)
public class productJSONTest {
    @isTest
    public static void testproductJSON() {
        Account acc= new Account();
        acc.Name='Test account';
        acc.Cedula__c='9876543210';
        acc.Tipo_de_Documento__c='02';
        acc.codigoSoftland__c = '1234';
        
        insert acc;
        
        condicionPago__c cp = new condicionPago__c(condicionPago__c = 'test');
        insert cp;
        
        categoriaCliente__c cc = new categoriaCliente__c(categoriaCliente__c = 'test');
        insert cc;
        
        impuesto__c impuesto = new impuesto__c(codigoImpuesto__c = 'test');
        insert impuesto;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        
        String jsonStr = '';
        productJSON.productRequestJSON cntrl = new productJSON.productRequestJSON();
        cntrl.articulo = 'test12345';
        cntrl.precio = '1234';
        cntrl.costo_local = '1234';
        cntrl.porc_margen_max = '1234';
        cntrl.porc_margen_min = '1234';
        cntrl.costo_local = '1234';
        cntrl.porc_descuento = '1234';
        cntrl.precio = '1234';
        cntrl.cant_disponible = '1234';
        cntrl.descripcion = 'wer2342';
        cntrl.moneda = 'USD';
        cntrl.empresa = 'RMBAVARIAN';
        cntrl.activo = 'true';
        cntrl.esVehiculo = 'true';
        cntrl.marca='bmw';
        cntrl.especificaciones='blanco';
        cntrl.color='blanco';
        cntrl.anno ='2022';
        
        
        String jsonStr2 = '';
        productJSON.productRequestJSON cntrl2 = new productJSON.productRequestJSON();
        cntrl2.articulo = 'test12345';
        cntrl2.precio = '1234';
        cntrl2.costo_local = '1234';
        cntrl2.porc_margen_max = '1234';
        cntrl2.porc_margen_min = '1234';
        cntrl2.costo_local = '1234';
        cntrl2.porc_descuento = '1234';
        cntrl2.precio = '1234';
        cntrl2.cant_disponible = '1234';
        cntrl2.descripcion = 'wer2342';
        cntrl2.moneda = 'USD';
        cntrl2.empresa = 'RMBAVARIAN';
        cntrl2.activo = 'false';
        cntrl2.esVehiculo = 'true';
        cntrl2.marca='bmw';
        cntrl2.especificaciones='blanco';
        cntrl2.color='blanco';
        cntrl2.anno ='2022';
        
        cntrl2.combustible ='Gasolina';
        cntrl2.Numero_Motor ='123123123';
        cntrl2.cubicaje ='1231';
        cntrl2.Cantidad_Cilindros ='12';
        cntrl2.pasajeros ='6';
        cntrl2.Carroceria ='Negro';
        cntrl2.Peso ='1231';
        cntrl2.traccion ='Doble';
        cntrl2.BL ='Test';
        cntrl2.Valor_exonerado ='123123';
        cntrl2.tapiceria ='Cuero';
        cntrl2.transmision ='automático';
        
        String jsonStr3 = '';
        productJSON.productRequestJSON cntrl3 = new productJSON.productRequestJSON();
        cntrl3.articulo = 'test12345';
        cntrl3.precio = '1234';
        cntrl3.costo_local = '1234';
        cntrl3.porc_margen_max = '1234';
        cntrl3.porc_margen_min = '1234';
        cntrl3.costo_local = '1234';
        cntrl3.porc_descuento = '1234';
        cntrl3.precio = '1234';
        cntrl3.cant_disponible = '1234';
        cntrl3.descripcion = 'wer2342';
        cntrl3.moneda = 'USD';
        cntrl3.empresa = 'RMBAVARIAN';
        cntrl3.activo = 'false';
        cntrl3.esUsado = 'true';
        cntrl3.marca='bmw';
        cntrl3.especificaciones='blanco';
        cntrl3.color='blanco';
        cntrl3.anno ='2022';
        
        cntrl3.combustible ='Gasolina';
        cntrl3.Numero_Motor ='123123123';
        cntrl3.cubicaje ='1231';
        cntrl3.Cantidad_Cilindros ='12';
        cntrl3.pasajeros ='6';
        cntrl3.Carroceria ='Negro';
        cntrl3.Peso ='1231';
        cntrl3.traccion ='Doble';
        cntrl3.BL ='Test';
        cntrl3.Valor_exonerado ='123123';
        cntrl3.tapiceria ='Cuero';
        cntrl3.transmision ='automático';
        
        
        
        List<productJSON.Disponible_Bodega> disponible_bodega = new List<productJSON.Disponible_Bodega>();
        disponible_bodega.add(new productJSON.Disponible_Bodega());
        
        cntrl.disponible_bodega = disponible_bodega;
        cntrl2.disponible_bodega = disponible_bodega;
        cntrl3.disponible_bodega = disponible_bodega;
        
        List<productJSON.Detalle_Costo> detalle_costo = new List<productJSON.Detalle_Costo>();
        productJSON.Detalle_Costo detalleCosto = new productJSON.Detalle_Costo();
        detalleCosto.rubro= 'RTV';
        detalleCosto.monto_local =1239860;
        detalleCosto.monto_dolar =2000;
        detalleCosto.id_linea_gasto='1';
        detalle_costo.add(detalleCosto);
        cntrl2.detalle_costo = detalle_costo;
        cntrl3.detalle_costo = detalle_costo;
        
        jsonStr2 = JSON.serialize(cntrl2);
        productJSON.createProduct(jsonStr2);
        
        jsonStr3 = JSON.serialize(cntrl3);
        productJSON.createProduct(jsonStr3);
        
        jsonStr = JSON.serialize(cntrl);
        productJSON.createProduct(jsonStr);
        productJSON.createProduct(jsonStr);
        productJSON.createProduct(jsonStr2);
        
        Product2 p = new Product2(Name = 'test1234567',
                                  Codigo_de_Producto__c = 'test1234567');
        insert p;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        // Insert PricebookEntry
        
        PricebookEntry standardPrice = new PricebookEntry();
        standardPrice.Pricebook2Id = pricebookId;
        standardPrice.Product2Id = p.Id;
        standardPrice.UnitPrice = 1;
        standardPrice.IsActive = true;
        standardPrice.UseStandardPrice = false;
        //insert standardPrice ;
        
        jsonStr = JSON.serialize(cntrl);
        productJSON.createProduct(jsonStr);
        
        productJSON.dummyMethod();
        
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