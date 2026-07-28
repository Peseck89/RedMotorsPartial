@IsTest
public class RM_VN_QuoteController_Test {

    @TestSetup
    static void makeData(){
        RM_VN_DataFactoryHelper.createRecordsVN();
        insert new List<Bodega__c>{
            new Bodega__c(Name = 'BR01 Test', bodega__c = 'BR01', ID_EXTERNO_BODEGA__c = 'BR01'),
            new Bodega__c(Name = 'BR03 Test', bodega__c = 'BR03', ID_EXTERNO_BODEGA__c = 'BR03'),
            new Bodega__c(Name = 'RM01 Test', bodega__c = 'RM01', ID_EXTERNO_BODEGA__c = 'RM01')
        };
    }

    @IsTest
    static void test_AgregarInventarioParametrosNull(){
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Oportunidad_Producto_Interes__c opi = [
            SELECT Id
            FROM Oportunidad_Producto_Interes__c
            LIMIT 1
        ];
        ProductoXBodega__c pxb = [
            SELECT Id
            FROM ProductoXBodega__c
            WHERE Producto__r.esVehiculo__c = true
              AND Producto__r.IsActive = true
            LIMIT 1
        ];

        assertControllerFailure(null, opi.Id, pxb.Id, null);
        assertControllerFailure(opp.Id, null, pxb.Id, null);
        assertControllerFailure(opp.Id, opi.Id, null, null);
        assertControllerFailure(opp.Id, opi.Id, '001000000000000AAA', null);
        assertControllerFailure(opp.Id, '001000000000000AAA', pxb.Id, null);
        assertControllerFailure('001000000000000AAA', opi.Id, pxb.Id, null);
    }

    @IsTest
    static void test_AgregarInventarioMismoModeloYLineItems(){
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Oportunidad_Producto_Interes__c opi = [
            SELECT Id, Modelo_Interes__c, Oportunidad__c
            FROM Oportunidad_Producto_Interes__c
            WHERE Oportunidad__c = :opp.Id
            LIMIT 1
        ];
        ProductoXBodega__c vehiclePxb = [
            SELECT Id, Producto__c
            FROM ProductoXBodega__c
            WHERE Producto__r.modelo__c = :opi.Modelo_Interes__c
              AND Producto__r.esVehiculo__c = true
              AND Producto__r.IsActive = true
            LIMIT 1
        ];
        
        Test.startTest();
        Map<String, Object> vehicleResult = RM_VN_QuoteController.addVehicle(
            opp.Id,
            opi.Id,
            vehiclePxb.Id,
            null
        );
        Test.stopTest();

        System.assertEquals(true, vehicleResult.get('success'));
        System.assertEquals(false, RM_VN_QuoteController.getQuotes(opp.Id).isEmpty());

        QuoteLineItem vehicleQli = [
            SELECT Id, QuoteId
            FROM QuoteLineItem
            WHERE Product2.esVehiculo__c = true
            LIMIT 1
        ];
        Product2 laborProduct = [
            SELECT Id
            FROM Product2
            WHERE tipoProducto__c = 'Mano de Obra'
              AND IsActive = true
            LIMIT 1
        ];
        ProductoXBodega__c laborPxb = [
            SELECT Id
            FROM ProductoXBodega__c
            WHERE Producto__c = :laborProduct.Id
            LIMIT 1
        ];

        Map<String, Object> invalidQuantity = QuoteService.addLineItem(
            vehicleQli.QuoteId,
            laborProduct.Id,
            vehicleQli.Id,
            true,
            false,
            'mano obra',
            'mano obra',
            0,
            100
        );
        System.assertEquals(false, invalidQuantity.get('success'));

        Map<String, Object> invalidPrice = QuoteService.addLineItem(
            vehicleQli.QuoteId,
            laborProduct.Id,
            vehicleQli.Id,
            true,
            false,
            'mano obra',
            'mano obra',
            1,
            0
        );
        System.assertEquals(false, invalidPrice.get('success'));

        Map<String, Object> laborResult = RM_VN_QuoteController.addLineItem(
            vehicleQli.QuoteId,
            laborProduct.Id,
            vehicleQli.Id,
            false,
            false,
            'mano obra',
            'mano obra',
            1,
            100
        );
        System.assertEquals(true, laborResult.get('success'));

        Map<String, Object> extraResult = QuoteService.addLineItem(
            vehicleQli.QuoteId,
            laborPxb.Id,
            vehicleQli.Id,
            true,
            true,
            'extra',
            'extra',
            1,
            100
        );
        System.assertEquals(true, extraResult.get('success'));
    }

    @IsTest
    static void test_AgregarInventarioDiferenteModeloDeInteres(){
        Oportunidad_Producto_Interes__c opi = [
            SELECT Id, Modelo_Interes__c, Oportunidad__c
            FROM Oportunidad_Producto_Interes__c
            WHERE Marca__c != null
              AND Oportunidad__c != null
            LIMIT 1
        ];
        ProductoXBodega__c pxb = [
            SELECT Id
            FROM ProductoXBodega__c
            WHERE Producto__r.modelo__c != :opi.Modelo_Interes__c
              AND Producto__r.esVehiculo__c = true
              AND Producto__r.IsActive = true
            LIMIT 1
        ];
        
        Test.startTest();
        Map<String, Object> result = QuoteService.addVehicle(
            opi.Oportunidad__c,
            opi.Id,
            pxb.Id,
            null
        );
        Test.stopTest();

        System.assertEquals(true, result.get('success'));
    }

    @IsTest
    static void test_MetodosAuxiliaresPublicos(){
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Product2 product = [
            SELECT Id, marcaVehiculo__c, modelo__c, Anno__c
            FROM Product2
            WHERE esVehiculo__c = true
            LIMIT 1
        ];
        PricebookEntry pbe = [
            SELECT Id, Product2Id, UnitPrice, Costo_Fijo__c, Vendedor__c, Gerente__c, Jefe__c
            FROM PricebookEntry
            WHERE Product2Id != :product.Id
              AND Product2.esVehiculo__c = false
            LIMIT 1
        ];
        Oportunidad_Producto_Interes__c opi = new Oportunidad_Producto_Interes__c(
            Marca__c = 'OTRA',
            Anio__c = '1999',
            Modelo_Interes__c = 'OTRO'
        );
        ProductoXBodega__c pxb = new ProductoXBodega__c(
            Producto__r = product
        );

        System.assertEquals(true, QuoteService.checkIfDifferentModel(opi, pxb));

        Oportunidad_Producto_Interes__c createdOpi =
            QuoteService.crearOportunidadProductoInteresDiferenteModelo(opp.Id, product, pbe);
        System.assertNotEquals(null, createdOpi.Id);

        Oportunidad_Producto_Interes__c existingOpi =
            QuoteService.crearOportunidadProductoInteresDiferenteModelo(opp.Id, product, pbe);
        System.assertEquals(createdOpi.Id, existingOpi.Id);
    }

    private static void assertControllerFailure(
        String oppId,
        String oppProdIntId,
        String prodXBodegaId,
        String existingQuoteId
    ) {
        Boolean thrown = false;
        try {
            RM_VN_QuoteController.addVehicle(oppId, oppProdIntId, prodXBodegaId, existingQuoteId);
        } catch (Exception e) {
            thrown = true;
        }
        System.assertEquals(true, thrown, 'La llamada debia fallar con parametros invalidos.');
    }
}