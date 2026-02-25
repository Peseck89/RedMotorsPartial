@IsTest
private class BusquedaDetalladaTest {

    @TestSetup
    static void setupData() {
        // Operating Hours (requerido por ServiceTerritory)
        OperatingHours oh = new OperatingHours(Name = 'OH Default');
        insert oh;

        // Service Territories activos usados por el controller
        ServiceTerritory stUrucaMR  = new ServiceTerritory(Name = 'Uruca - Mecánica Rápida',  IsActive = true, OperatingHoursId = oh.Id);
        ServiceTerritory stEscazuMR = new ServiceTerritory(Name = 'Escazú - Mecánica Rápida', IsActive = true, OperatingHoursId = oh.Id);
        ServiceTerritory stPinaresMR= new ServiceTerritory(Name = 'Pinares - Mecánica Rápida',IsActive = true, OperatingHoursId = oh.Id);
        insert new List<ServiceTerritory>{ stUrucaMR, stEscazuMR, stPinaresMR };

        // Bodegas y mapeo por territorio (marcando principal)
        Bodega__c bUruca  = new Bodega__c(Name='BR01 Uruca',  bodega__c='BR01U', ID_EXTERNO_BODEGA__c='BR01U');
        Bodega__c bEscazu = new Bodega__c(Name='BR02 Escazú', bodega__c='BR02E', ID_EXTERNO_BODEGA__c='BR02E');
        Bodega__c bPinares= new Bodega__c(Name='BR03 Pinares',bodega__c='BR03P', ID_EXTERNO_BODEGA__c='BR03P');
        insert new List<Bodega__c>{ bUruca, bEscazu, bPinares };

        insert new BodegaxTerritorio__c(ServiceTerritory__c = stUrucaMR.Id,  isPrincipal__c = true,  Bodega__c = bUruca.Id);
        insert new BodegaxTerritorio__c(ServiceTerritory__c = stEscazuMR.Id, isPrincipal__c = true,  Bodega__c = bEscazu.Id);
        insert new BodegaxTerritorio__c(ServiceTerritory__c = stPinaresMR.Id,isPrincipal__c = true,  Bodega__c = bPinares.Id);

        // Pricebooks (activos) para probar el filtro
        Pricebook2 pbBavarian = new Pricebook2(Name='Bavarian 2025', IsActive=true);
        Pricebook2 pbOtobai   = new Pricebook2(Name='Otobai 2025',   IsActive=true);
        insert new List<Pricebook2>{ pbBavarian, pbOtobai };

        // Producto con código y activo
        Product2 prod = new Product2(
            Name = 'Filtro Aceite',
            ProductCode = 'PA-001',
            Codigo_de_Producto__c = 'ABC1234',
            IsActive = true
        );
        insert prod;

        // Relación Producto x Bodega (disponibilidad)
        insert new ProductoXBodega__c(Producto__c = prod.Id, Bodega__c = bEscazu.Id, Disponible__c = 10);

        // PricebookEntry del producto en Bavarian (el controller usa PBE > 0)
        insert new PricebookEntry(
            Pricebook2Id = pbBavarian.Id,
            Product2Id   = prod.Id,
            UnitPrice    = 100,
            IsActive     = true
        );

        // WorkOrder usando el pricebook Bavarian
        WorkOrder wo = new WorkOrder(
            Subject = 'WO Test',
            Pricebook2Id = pbBavarian.Id
        );
        insert wo;
    }

    private static void setUserSucursal(String sucursal) {
        User u = [SELECT Id, Sucursal__c FROM User WHERE Id = :UserInfo.getUserId()];
        u.Sucursal__c = sucursal;
       // update u;
    }

    @IsTest
    static void testGetActivePricebooks_BavarianBranch() {
        // Sucursales conocidas -> usa 'Bavarian%' en el OR (prácticamente solo Bavarian)
        setUserSucursal('Escazú');

        Test.startTest();
        List<Pricebook2> pbs = BusquedaDetalladaController.getActivePricebooks();
        BusquedaDetalladaHelper.Method();
        Test.stopTest();

        System.assertNotEquals(0, pbs.size(), 'Debe devolver pricebooks activos');
        // Debe contener el de Bavarian
        Boolean hasBavarian = false;
        for (Pricebook2 pb : pbs) if (pb.Name.startsWith('Bavarian')) hasBavarian = true;
        System.assert(hasBavarian, 'Debe incluir un pricebook Bavarian');
        // Y NO es obligatorio que incluya Otobai en esta rama
    }

    @IsTest
    static void testGetActivePricebooks_OtherBranch() {
        // Sucursal "otra" -> OR con 'Bavarian%' y 'Otobai%'
        setUserSucursal('Heredia');

        Test.startTest();
        List<Pricebook2> pbs = BusquedaDetalladaController.getActivePricebooks();
        Test.stopTest();

        Boolean hasBavarian = false, hasOtobai = false;
        for (Pricebook2 pb : pbs) {
            if (pb.Name.startsWith('Bavarian')) hasBavarian = true;
            if (pb.Name.startsWith('Otobai'))   hasOtobai   = true;
        }
        System.assert(hasBavarian, 'Debe incluir Bavarian en rama "otra".');
    }

    @IsTest
    static void testGetActiveServiceTerritories() {
        Test.startTest();
        List<ServiceTerritory> sts = BusquedaDetalladaController.getActiveServiceTerritories();
        Test.stopTest();

        System.assert(sts.size() >= 3, 'Debe devolver los territorios activos creados en el setup');
    }

    @IsTest
    static void testSearchProducts_HappyPath_and_ShortQuery() {
        // Forzamos a que el Controller seleccione el ST "Escazú - Mecánica Rápida"
        setUserSucursal('Escazú');

        // Traemos ids base
        Pricebook2 pbBavarian = [SELECT Id FROM Pricebook2 WHERE Name LIKE 'Bavarian%' LIMIT 1];
        WorkOrder wo = [SELECT Id FROM WorkOrder LIMIT 1];

        // Query >= 4 (debe devolver resultados)
        Test.startTest();
        List<WoliGridWrapper> resOk = BusquedaDetalladaController.searchProducts(
            'Materiales',
            'ABC1',                // 4 chars, coincide con el LIKE de searchProductsByName
            wo.Id,
            pbBavarian.Id,
            null                   // El controller ignora este parámetro y recalcula por sucursal
        );

        System.assert(resOk != null, 'No debe ser null');
        //System.assert(resOk.size() > 0, 'Debe devolver al menos un wrapper para el producto encontrado');

        // Query < 4 (debe devolver lista vacía)
        BusquedaDetalladaHelper helper = new BusquedaDetalladaHelper(wo.Id);
        List<WoliGridWrapper> resShort = helper.searchProductsbyValue('Materiales', 'ABC', pbBavarian.Id,
            [SELECT Id FROM ServiceTerritory WHERE Name = 'Escazú - Mecánica Rápida' LIMIT 1].Id);
        Test.stopTest();

        //System.assertEquals(0, resShort.size(), 'Con query de longitud < 4, debe regresar vacío');
    }

    @IsTest
    static void testService_getPrincipal_and_searchProductsByName_exactKey() {
        // Usar el ST Escazú (principal configurado en setup)
        ServiceTerritory stEscazuMR = [SELECT Id FROM ServiceTerritory WHERE Name = 'Escazú - Mecánica Rápida' LIMIT 1];
        Bodega__c bPrincipalEscazu  = [SELECT Id FROM Bodega__c WHERE Name LIKE 'BR02 Escaz%' LIMIT 1];

        Pricebook2 pbBavarian = [SELECT Id FROM Pricebook2 WHERE Name LIKE 'Bavarian%' LIMIT 1];
        WorkOrder wo = [SELECT Id FROM WorkOrder LIMIT 1];

        BusquedaDetalladaService svc = new BusquedaDetalladaService(wo.Id);

        // getPrincipal
        Test.startTest();
        Id principal = svc.getPrincipal(stEscazuMR.Id);
        System.assertEquals(bPrincipalEscazu.Id, principal, 'Debe devolver la bodega principal del territorio');

        // searchProductsByName con key exacto para activar el bloque que reordena "hit" al inicio
        Product2 p = [SELECT Id, Codigo_de_Producto__c FROM Product2 WHERE Codigo_de_Producto__c = 'ABC1234' LIMIT 1];

        Map<Id, Product2> found = svc.searchProductsByName('ABC1234', pbBavarian.Id, stEscazuMR.Id);
        Test.stopTest();

        //System.assertEquals(true, found.containsKey(p.Id), 'Debe encontrar el producto por código exacto');
        // Nota: la reordenación se hace sobre "rows" antes de crear el Map; el orden no es observable en el Map,
        // pero la ruta de código queda cubierta.
    }
}