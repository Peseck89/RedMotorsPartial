@isTest(seeAllData = true)
public class precioProductoJSONTest {
    @isTest
    public static void testprecioProductoJSONBavarian() {
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
        precioProductoJSON.productRequestJSON cntrl = new precioProductoJSON.productRequestJSON();
        cntrl.articulo = 'test12345';
        cntrl.precio_local = '1234';
        cntrl.precio_dolar = '1234';
        cntrl.costo_local = '1234';
        cntrl.costo_dolar = '1234';
        cntrl.empresa = 'RMBAVARIAN';
        
        jsonStr = JSON.serialize(cntrl);
        precioProductoJSON.createProduct(jsonStr);
        
        Product2 p = new Product2(Name = 'test12345',
                                  Codigo_de_Producto__c = 'test12345');
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
        precioProductoJSON.createProduct(jsonStr);
        
        precioProductoJSON.Method();
        
        Test.stopTest();
    }
    
    @isTest
    public static void testprecioProductoJSONOtobai() {
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
        precioProductoJSON.productRequestJSON cntrl = new precioProductoJSON.productRequestJSON();
        cntrl.articulo = 'test12345';
        cntrl.precio_local = '1234';
        cntrl.precio_dolar = '1234';
        cntrl.costo_local = '1234';
        cntrl.costo_dolar = '1234';
        cntrl.empresa = 'RMOTOBAI';
        
        jsonStr = JSON.serialize(cntrl);
        precioProductoJSON.createProduct(jsonStr);
        
        Product2 p = new Product2(Name = 'test12345',
                                  Codigo_de_Producto__c = 'test12345',CodigoProductoInterno__c = 'test12345-RMOTOBAI');
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
        System.debug(jsonStr);
        precioProductoJSON.createProduct(jsonStr);
        
        Test.stopTest();
    }
    
    @isTest(seeAllData = false)
    public static void testprecioProductoJSONPekingLocal() {
        Id pricebookId = Test.getStandardPricebookId();

        // La clase hereda seeAllData=true del nivel de clase (no se puede desactivar por metodo),
        // por lo que 'PEKING Local'/'PEKING Dolares' ya existen como Pricebook2 reales en el org
        // (confirmados en DECISIONES_DIEGO_20260729.md). Se consultan en vez de insertarse para
        // no colisionar con esos registros reales.
        List<Pricebook2> pekingLocalList = [SELECT Id, Name FROM Pricebook2 WHERE Name = 'PEKING Local'];
        List<Pricebook2> pekingDolaresList = [SELECT Id, Name FROM Pricebook2 WHERE Name = 'PEKING Dólares'];
        System.assert(!pekingLocalList.isEmpty(), 'Debe existir el Pricebook PEKING Local en el org.');
        System.assert(!pekingDolaresList.isEmpty(), 'Debe existir el Pricebook PEKING Dólares en el org.');
        Pricebook2 pekingLocal = pekingLocalList[0];
        Pricebook2 pekingDolares = pekingDolaresList[0];

        Product2 p = new Product2(
            Name = 'test-peking-001',
            Empresa__c = 'RMPEKING',
            Codigo_de_Producto__c = 'test-peking-001',
            CodigoProductoInterno__c = 'test-peking-001-RMPEKING',
            RecordTypeId = getProductoRedMotorsRecordTypeId()
        );
        insert p;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());

        precioProductoJSON.productRequestJSON cntrl = new precioProductoJSON.productRequestJSON();
        cntrl.articulo = 'test-peking-001';
        cntrl.precio_local = '1234';
        cntrl.precio_dolar = '1234';
        cntrl.costo_local = '1234';
        cntrl.costo_dolar = '1234';
        cntrl.precio_empleado = '100';
        cntrl.empresa = 'RMPEKING';

        String jsonStr = JSON.serialize(cntrl);
        String result = precioProductoJSON.createProduct(jsonStr);
        Test.stopTest();

        System.assert(result.contains('"CODIGO":"201"'), 'Debe actualizar el producto RMPEKING existente. Respuesta: ' + result);

        List<PricebookEntry> pbeLocal = [
            SELECT Id, UnitPrice, Pricebook2Id
            FROM PricebookEntry
            WHERE Product2Id = :p.Id AND Pricebook2Id = :pekingLocal.Id
        ];
        System.assertEquals(1, pbeLocal.size(), 'Debe crear/actualizar el PricebookEntry en PEKING Local.');
        System.assertEquals(1234, pbeLocal[0].UnitPrice, 'El PricebookEntry de PEKING Local debe usar precio_local.');
    }

    @isTest(seeAllData = false)
    public static void testprecioProductoJSONPekingDolares() {
        Id pricebookId = Test.getStandardPricebookId();

        // Ver comentario en testprecioProductoJSONPekingLocal: se consultan los Pricebook2
        // reales en lugar de insertarlos para no colisionar con los registros ya existentes.
        List<Pricebook2> pekingLocalList = [SELECT Id, Name FROM Pricebook2 WHERE Name = 'PEKING Local'];
        List<Pricebook2> pekingDolaresList = [SELECT Id, Name FROM Pricebook2 WHERE Name = 'PEKING Dólares'];
        System.assert(!pekingLocalList.isEmpty(), 'Debe existir el Pricebook PEKING Local en el org.');
        System.assert(!pekingDolaresList.isEmpty(), 'Debe existir el Pricebook PEKING Dólares en el org.');
        Pricebook2 pekingLocal = pekingLocalList[0];
        Pricebook2 pekingDolares = pekingDolaresList[0];

        Product2 p = new Product2(
            Name = 'test-peking-002',
            Empresa__c = 'RMPEKING',
            Codigo_de_Producto__c = 'test-peking-002',
            CodigoProductoInterno__c = 'test-peking-002-RMPEKING',
            RecordTypeId = getProductoRedMotorsRecordTypeId()
        );
        insert p;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());

        precioProductoJSON.productRequestJSON cntrl = new precioProductoJSON.productRequestJSON();
        cntrl.articulo = 'test-peking-002';
        cntrl.precio_local = '1500';
        cntrl.precio_dolar = '3000';
        cntrl.costo_local = '1500';
        cntrl.costo_dolar = '3000';
        cntrl.precio_empleado = '200';
        cntrl.empresa = 'RMPEKING';

        String jsonStr = JSON.serialize(cntrl);
        String result = precioProductoJSON.createProduct(jsonStr);
        Test.stopTest();

        System.assert(result.contains('"CODIGO":"201"'), 'Debe actualizar el producto RMPEKING existente. Respuesta: ' + result);

        List<PricebookEntry> pbeDolar = [
            SELECT Id, UnitPrice, Pricebook2Id
            FROM PricebookEntry
            WHERE Product2Id = :p.Id AND Pricebook2Id = :pekingDolares.Id
        ];
        System.assertEquals(1, pbeDolar.size(), 'Debe crear/actualizar el PricebookEntry en PEKING Dólares.');
        System.assertEquals(3000, pbeDolar[0].UnitPrice, 'El PricebookEntry de PEKING Dólares debe usar precio_dolar.');
    }

    @isTest(seeAllData = false)
    public static void testprecioProductoJSONPekingNoColisionaConOtraEmpresa() {
        Id pricebookId = Test.getStandardPricebookId();

        // Ver comentario en testprecioProductoJSONPekingLocal: se consultan los Pricebook2
        // reales en lugar de insertarlos para no colisionar con los registros ya existentes.
        List<Pricebook2> pekingLocalList = [SELECT Id, Name FROM Pricebook2 WHERE Name = 'PEKING Local'];
        List<Pricebook2> pekingDolaresList = [SELECT Id, Name FROM Pricebook2 WHERE Name = 'PEKING Dólares'];
        System.assert(!pekingLocalList.isEmpty(), 'Debe existir el Pricebook PEKING Local en el org.');
        System.assert(!pekingDolaresList.isEmpty(), 'Debe existir el Pricebook PEKING Dólares en el org.');

        String articuloCompartido = 'shared-code-001';

        // Producto distractor de OTRA empresa (RMOTOBAI) cuyo Codigo_de_Producto__c coincide
        // exactamente con el "articulo" que se enviara para RMPEKING (colision real, ver
        // DECISIONES_DIEGO_20260729.md). Es el registro que se encontraria si, por error,
        // RMPEKING buscara por Codigo_de_Producto__c crudo en vez de la llave interna.
        Product2 otroProducto = new Product2(
            Name = 'Producto Otobai',
            Empresa__c = 'RMOTOBAI',
            Codigo_de_Producto__c = articuloCompartido,
            CodigoProductoInterno__c = articuloCompartido + '-RMOTOBAI',
            costoLocal__c = 111
        );
        insert otroProducto;

        // Producto objetivo RMPEKING: Codigo_de_Producto__c DISTINTO del de otroProducto
        // (Partial no permite dos Product2 con el mismo Codigo_de_Producto__c), pero con la
        // llave interna que precioProductoJSON debe usar para encontrarlo.
        Product2 productoPeking = new Product2(
            Name = 'Producto Peking',
            Empresa__c = 'RMPEKING',
            Codigo_de_Producto__c = 'peking-raw-code-001',
            CodigoProductoInterno__c = articuloCompartido + '-RMPEKING',
            costoLocal__c = 50,
            RecordTypeId = getProductoRedMotorsRecordTypeId()
        );
        insert productoPeking;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());

        precioProductoJSON.productRequestJSON cntrl = new precioProductoJSON.productRequestJSON();
        cntrl.articulo = articuloCompartido;
        cntrl.precio_local = '999';
        cntrl.precio_dolar = '999';
        cntrl.costo_local = '999';
        cntrl.costo_dolar = '999';
        cntrl.precio_empleado = '50';
        cntrl.empresa = 'RMPEKING';

        String jsonStr = JSON.serialize(cntrl);
        String result = precioProductoJSON.createProduct(jsonStr);
        Test.stopTest();

        System.assert(result.contains('"CODIGO":"201"'), 'Debe actualizar el producto RMPEKING. Respuesta: ' + result);

        String identificadorPeking = articuloCompartido + '-RMPEKING';
        Product2 encontradoPorLlaveInterna = [
            SELECT Id, costoLocal__c
            FROM Product2
            WHERE CodigoProductoInterno__c = :identificadorPeking
        ];
        Product2 sinCambiosOtobai = [SELECT Id, costoLocal__c FROM Product2 WHERE Id = :otroProducto.Id];

        System.assertEquals(productoPeking.Id, encontradoPorLlaveInterna.Id, 'precioProductoJSON debe encontrar el producto RMPEKING mediante CodigoProductoInterno__c, no por Codigo_de_Producto__c.');
        System.assertEquals(999, encontradoPorLlaveInterna.costoLocal__c, 'El producto RMPEKING debe recibir la actualizacion de precio.');
        System.assertEquals(111, sinCambiosOtobai.costoLocal__c, 'El producto RMOTOBAI (cuyo Codigo_de_Producto__c coincide con el articulo) NO debe modificarse.');
    }

    // "Vehiculos" es el Record Type por defecto de Product2 para el usuario de pruebas
    // (defaultRecordTypeMapping) y solo permite RMBAVARIAN/RMOTOBAI en Empresa__c. RMPEKING
    // unicamente esta habilitado en el Record Type "Producto Red Motors" (DeveloperName
    // Producto_Red_Motors, confirmado en force-app/main/default/objects/Product2/recordTypes/
    // Producto_Red_Motors.recordType-meta.xml). Sin este RecordTypeId explicito, el insert
    // falla con INVALID_OR_NULL_FOR_RESTRICTED_PICKLIST. Ver DECISIONES_DIEGO_20260729.md.
    private static Id getProductoRedMotorsRecordTypeId() {
        List<RecordType> productoRedMotorsRecordTypes = [
            SELECT Id
            FROM RecordType
            WHERE SObjectType = 'Product2'
            AND DeveloperName = 'Producto_Red_Motors'
        ];
        System.assertEquals(
            1,
            productoRedMotorsRecordTypes.size(),
            'Debe existir exactamente un Record Type "Producto Red Motors" (DeveloperName Producto_Red_Motors) para Product2 en el org.'
        );
        return productoRedMotorsRecordTypes[0].Id;
    }

    public static void catchError()
    {
        Test.startTest();
        String requestBdy = '{'+
    '"articulo":"Test",'+
    '"precio_local":"1200",'+
    '"precio_dolar":"5000",'+
            '}';

        precioProductoJSON.createProduct(requestBdy);
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