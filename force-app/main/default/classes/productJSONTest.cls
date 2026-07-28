@isTest
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
        
        // Insertamos la bodega para que el código entre al bloque de ProductoXBodega__c
        Bodega__c testBodega = new Bodega__c();
        testBodega.Name = 'Bodega Test';
        testBodega.ID_EXTERNO_BODEGA__c = 'BOD1';
        testBodega.Bodega__c = 'B01';
        insert testBodega;

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
        
        // Mapeamos la bodega para que coincida con el ID_EXTERNO de testBodega
        List<productJSON.Disponible_Bodega> disponible_bodega = new List<productJSON.Disponible_Bodega>();
        productJSON.Disponible_Bodega b = new productJSON.Disponible_Bodega();
        b.bodega = 'BOD1'; // ID que hace match
        b.disponible = 5;
        disponible_bodega.add(b);
        
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
        
        PricebookEntry standardPrice = new PricebookEntry();
        standardPrice.Pricebook2Id = pricebookId;
        standardPrice.Product2Id = p.Id;
        standardPrice.UnitPrice = 1;
        standardPrice.IsActive = true;
        standardPrice.UseStandardPrice = false;
        
        jsonStr = JSON.serialize(cntrl);
        productJSON.createProduct(jsonStr);
        
        Test.stopTest();
    }

    @isTest
    public static void testReingresoUsadoCierraReservaPorVin() {
        Opportunity opp = new Opportunity();
        opp.Name = 'Reserva previa VU';
        opp.BMW_Compania__c = 'Bavarian';
        opp.StageName = 'Oportunidad Calificada';
        opp.CloseDate = Date.today();
        insert opp;

        Product2 product = new Product2();
        product.Name = 'Vehiculo usado reservado';
        product.ProductCode = 'OLD-RQ50';
        product.Codigo_de_Producto__c = 'OLD-RQ50';
        product.CodigoProductoInterno__c = 'OLD-RQ50-RMBAVARIAN';
        product.vin__c = 'VIN-RQ50-001';
        product.es_Vehiculo_usado__c = true;
        product.Producto_Reservado__c = true;
        product.OportunidadReserva__c = opp.Id;
        insert product;

        productJSON.productRequestJSON request = new productJSON.productRequestJSON();
        request.articulo = 'NEW-RQ50';
        request.descripcion = 'Vehiculo usado reingresado';
        request.precio = '1000';
        request.costo_local = '900';
        request.porc_margen_max = '10';
        request.porc_margen_min = '1';
        request.porc_descuento = '0';
        request.cant_disponible = '1';
        request.moneda = 'USD';
        request.empresa = 'RMBAVARIAN';
        request.activo = 'true';
        request.esUsado = 'true';
        request.vin = 'VIN-RQ50-001';
        request.marca = 'BMW';
        request.modelo = 'X1';
        request.especificaciones = 'Test';
        request.color = 'Negro';
        request.colorInterior = 'Negro';
        request.colorExterior = 'Blanco';
        request.anno = '2024';
        request.combustible = 'Gasolina';
        request.Numero_Motor = 'MOTOR-RQ50';
        request.cubicaje = '2000';
        request.Cantidad_Cilindros = '4';
        request.pasajeros = '5';
        request.Carroceria = 'SUV';
        request.Peso = '1500';
        request.traccion = '4x2';
        request.BL = 'BL-RQ50';
        request.Valor_exonerado = '0';
        request.tapiceria = 'Cuero';
        request.transmision = 'automático';
        request.Tipo_vehiculo = 'A';
        request.Porcentaje_vendedor = '0';
        request.Porcentaje_jefe = '0';
        request.disponible_bodega = new List<productJSON.Disponible_Bodega>();

        Test.startTest();
        String response = productJSON.createProduct(JSON.serialize(request));
        Test.stopTest();

        System.assert(response.contains('"CODIGO":"201"'), 'El producto existente debe actualizarse por VIN. Respuesta: ' + response);

        Product2 updatedProduct = [
            SELECT Codigo_de_Producto__c, Producto_Reservado__c, OportunidadReserva__c
            FROM Product2
            WHERE Id = :product.Id
        ];
        System.assertEquals('NEW-RQ50', updatedProduct.Codigo_de_Producto__c);
    }

    @isTest
    public static void testTipoProductoMappings() {
        Map<String, String> expectedByType = new Map<String, String>{
            'T' => 'Materiales',
            'K' => 'Kit',
            'S' => null
        };

        Test.startTest();
        for (String tipoProducto : expectedByType.keySet()) {
            productJSON.productRequestJSON request = new productJSON.productRequestJSON();
            request.articulo = 'MAP-' + tipoProducto + '-' + DateTime.now().getTime();
            request.descripcion = 'Producto mapeo ' + tipoProducto;
            request.precio = '100';
            request.costo_local = '80';
            request.porc_margen_max = '10';
            request.porc_margen_min = '1';
            request.porc_descuento = '0';
            request.cant_disponible = '0';
            request.moneda = 'USD';
            request.empresa = 'RMBAVARIAN';
            request.activo = 'true';
            request.tipo_producto = tipoProducto;
            request.disponible_bodega = new List<productJSON.Disponible_Bodega>();

            String response = productJSON.createProduct(JSON.serialize(request));
            System.assert(response.contains('"CODIGO":"200"'), 'Debe crear producto. Respuesta: ' + response);
        }
        Test.stopTest();

        for (Product2 product : [
            SELECT ProductCode, tipoProducto__c
            FROM Product2
            WHERE ProductCode LIKE 'MAP-%'
        ]) {
            String tipoProducto = product.ProductCode.split('-')[1];
            System.assertEquals(expectedByType.get(tipoProducto), product.tipoProducto__c);
        }
    }

    @isTest
    public static void testVehiculoTransitoOtobai() {
        productJSON.productRequestJSON request = new productJSON.productRequestJSON();
        request.articulo = 'OTO-TRANS-' + DateTime.now().getTime();
        request.descripcion = 'Motocicleta en transito';
        request.precio = '1000';
        request.costo_local = '800';
        request.porc_margen_max = '10';
        request.porc_margen_min = '1';
        request.porc_descuento = '0';
        request.cant_disponible = '0';
        request.moneda = 'USD';
        request.empresa = 'RMOTOBAI';
        request.activo = 'false';
        request.esVehiculoentransito = 'true';
        request.vin = 'VIN-OTO-' + DateTime.now().getTime();
        request.marca = 'BMW';
        request.modelo = 'GS';
        request.especificaciones = 'Adventure';
        request.colorInterior = 'Negro';
        request.colorExterior = 'Azul';
        request.anno = '2026';
        request.combustible = 'Gasolina';
        request.Numero_Motor = 'MOTOR-OTO';
        request.cubicaje = '1250';
        request.Cantidad_Cilindros = '2';
        request.pasajeros = '2';
        request.Carroceria = 'Moto';
        request.Peso = '250';
        request.traccion = 'Cadena';
        request.BL = 'BL-OTO';
        request.Valor_exonerado = '0';
        request.tapiceria = 'Cuero';
        request.transmision = 'Manual';
        request.Tipo_vehiculo = 'M';
        request.disponible_bodega = new List<productJSON.Disponible_Bodega>();

        Test.startTest();
        String createdResponse = productJSON.createProduct(JSON.serialize(request));
        String updatedResponse = productJSON.createProduct(JSON.serialize(request));
        Test.stopTest();

        System.assert(createdResponse.contains('"CODIGO":"200"'), 'Debe crear producto Otobai. Respuesta: ' + createdResponse);
        System.assert(updatedResponse.contains('"CODIGO":"201"'), 'Debe actualizar producto Otobai. Respuesta: ' + updatedResponse);

        String codigoInterno = request.articulo + '-RMOTOBAI';
        Product2 product = [
            SELECT esVehiculo__c, es_Vehiculo_en_transito__c, Tipo_vehiculo__c, CodigoProductoInterno__c
            FROM Product2
            WHERE CodigoProductoInterno__c = :codigoInterno
            LIMIT 1
        ];
        System.assertEquals(true, product.esVehiculo__c);
        System.assertEquals(true, product.es_Vehiculo_en_transito__c);
        System.assertEquals('Motocicleta', product.Tipo_vehiculo__c);
    }

    @isTest
    public static void testVehiculoUsadoValidacionCompleta() {
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());

        // Insertamos la bodega en Salesforce para que las consultas la encuentren y entre al IF
        Bodega__c testBodega = new Bodega__c();
        testBodega.Name = 'Bodega Usados';
        testBodega.ID_EXTERNO_BODEGA__c = 'BOD1';
        testBodega.Bodega__c = 'B01';
        insert testBodega;

        productJSON.productRequestJSON request = new productJSON.productRequestJSON();
        request.articulo = 'USED-TEST-999';
        request.descripcion = 'Vehiculo Usado Validacion Test';
        request.precio = '15000';
        request.costo_local = '12000';
        request.porc_margen_max = '20';
        request.porc_margen_min = '5';
        request.porc_descuento = '0';
        request.cant_disponible = '1';
        request.moneda = 'USD';
        request.empresa = 'RMBAVARIAN';
        request.activo = 'false';
        request.esUsado = 'true';
        request.marca = 'BMW';
        request.modelo = 'Serie 3';
        request.especificaciones = 'Sport';
        request.color = 'Negro';
        request.colorInterior = 'Blanco';
        request.anno = '2020';
        request.combustible = 'Gasolina';
        request.Numero_Motor = 'MOT-12345';
        request.cubicaje = '2000';
        request.Cantidad_Cilindros = '4';
        request.pasajeros = '5';
        request.Carroceria = 'Sedan';
        request.Peso = '1600';
        request.traccion = '4x2';
        request.BL = 'BL-123';
        request.Valor_exonerado = '0';
        request.tapiceria = 'Tela';
        request.transmision = 'automático';
        request.Tipo_vehiculo = 'A';
        request.vin = 'VIN-USED-COMPLETE-999';
        request.Porcentaje_vendedor = '3';
        request.Porcentaje_jefe = '2';

        // Enviamos en el Request la misma bodega
        List<productJSON.Disponible_Bodega> bodegas = new List<productJSON.Disponible_Bodega>();
        productJSON.Disponible_Bodega b = new productJSON.Disponible_Bodega();
        b.bodega = 'BOD1'; // Esto hara match en el SOQL
        b.disponible = 1;
        bodegas.add(b);
        request.disponible_bodega = bodegas;

        List<productJSON.Detalle_Costo> costos = new List<productJSON.Detalle_Costo>();
        productJSON.Detalle_Costo c = new productJSON.Detalle_Costo();
        c.rubro = 'Mantenimiento Usado';
        c.monto_local = 150000;
        c.monto_dolar = 300;
        c.id_linea_gasto = 'LG-2';
        costos.add(c);
        request.detalle_costo = costos;

        Test.startTest();
        String response = productJSON.createProduct(JSON.serialize(request));
        Test.stopTest();

        System.assert(response.contains('"CODIGO":"200"'), 'Debe crear el vehiculo usado con exito.');

        Product2 prod = [
            SELECT Id, Name, es_Vehiculo_usado__c, vin__c, Porcentaje_vendedor__c, Porcentaje_jefe__c
            FROM Product2
            WHERE Codigo_de_Producto__c = 'USED-TEST-999'
            LIMIT 1
        ];

        System.assertEquals(true, prod.es_Vehiculo_usado__c, 'El check de vehiculo usado (es_Vehiculo_usado__c) debe ser verdadero.');
        System.assertEquals('VIN-USED-COMPLETE-999', prod.vin__c, 'El VIN debe guardarse correctamente.');
        System.assertEquals(3, prod.Porcentaje_vendedor__c, 'La comision de vendedor debe calcularse bien.');
        System.assertEquals(2, prod.Porcentaje_jefe__c, 'La comision de jefe debe calcularse bien.');
        
        // Verificación extra para asegurar que se insertó el ProductoXBodega__c
        List<ProductoXBodega__c> pxbList = [SELECT Id, Producto__c, Bodega__c FROM ProductoXBodega__c WHERE Producto__c = :prod.Id];
        System.assert(pxbList.size() > 0, 'Debe existir al menos un registro de ProductoXBodega__c asociado al producto.');
    }

    @isTest
    public static void testPekingDetieneAntesDeCrearProductoSinBodegaConfirmada() {
        productJSON.productRequestJSON request = buildBaseRequest('PEK-PROD-' + DateTime.now().getTime(), 'RMPEKING');
        request.marca = 'Omoda';
        request.modelo = 'C5';
        request.disponible_bodega = new List<productJSON.Disponible_Bodega>();
        productJSON.Disponible_Bodega bodega = new productJSON.Disponible_Bodega();
        bodega.bodega = 'BR01';
        bodega.disponible = 1;
        request.disponible_bodega.add(bodega);

        Test.startTest();
        String response = productJSON.createProduct(JSON.serialize(request));
        Test.stopTest();

        System.assert(response.contains('"CODIGO":"500"'), 'PEKING debe detenerse con error controlado. Respuesta: ' + response);
        System.assert(
            response.contains('No existe bodega principal confirmada para RMPEKING'),
            'El error debe indicar la falta de bodega PEKING confirmada. Respuesta: ' + response
        );
        String codigoInternoPeking = request.articulo + '-RMPEKING';
        System.assertEquals(
            0,
            [SELECT COUNT() FROM Product2 WHERE CodigoProductoInterno__c = :codigoInternoPeking],
            'No debe crear productos parciales para RMPEKING sin bodega confirmada.'
        );
    }

    @isTest
    public static void testEmpresaDesconocidaNoCaeEnBavarianNiOtobai() {
        productJSON.productRequestJSON request = buildBaseRequest('UNK-PROD-' + DateTime.now().getTime(), 'RMUNKNOWN');
        request.disponible_bodega = new List<productJSON.Disponible_Bodega>();

        Test.startTest();
        String response = productJSON.createProduct(JSON.serialize(request));
        Test.stopTest();

        System.assert(response.contains('"CODIGO":"500"'), 'Empresa desconocida debe detenerse con error controlado. Respuesta: ' + response);
        System.assert(
            response.contains('No existe empresa soportada'),
            'El error debe indicar empresa no soportada. Respuesta: ' + response
        );
        System.assertEquals(
            0,
            [SELECT COUNT() FROM Product2 WHERE Codigo_de_Producto__c = :request.articulo],
            'No debe crear productos para una empresa no soportada.'
        );
    }

    private static productJSON.productRequestJSON buildBaseRequest(String articulo, String empresa) {
        productJSON.productRequestJSON request = new productJSON.productRequestJSON();
        request.articulo = articulo;
        request.descripcion = 'Producto ' + articulo;
        request.precio = '1000';
        request.costo_local = '800';
        request.porc_margen_max = '10';
        request.porc_margen_min = '1';
        request.porc_descuento = '0';
        request.cant_disponible = '1';
        request.moneda = 'USD';
        request.empresa = empresa;
        request.activo = 'true';
        request.tipo_producto = 'T';
        return request;
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
