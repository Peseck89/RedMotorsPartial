@IsTest
public with sharing class RM_VN_DataFactoryHelper {

    //Para identificar la convinacion correcta mas rapido, desde la pantalla del usuario intentar agregar un vehiculo, 
    // desde ahi se puede determinar mas rapido una convinacion
    static String brand = 'BMW';
    static String tipo = 'Eléctrico';
    static String grupo = 'BMW i';
    static String family = 'iX';
    static String model = 'BM194 - iX - Sport';
    static String model2 = 'BMW-IX40-VR-ATELIER';
    static String year = '2023';

    public static void createRecordsVN() {
        Marca__c brandObj = TestDataFactory.createBrand('BMW',true);

        Modelo__c modelObj = TestDataFactory.createModel(model,brandObj,false);
        Modelo__c modelObj2 = TestDataFactory.createModel(model2,brandObj,false);
        List<Modelo__c> modelList = new List<Modelo__c>();
        modelList.add(modelObj);
        modelList.add(modelObj2);
        INSERT modelList;

        List<Bodega__c> bodegas = new List<Bodega__c>();
        Bodega__c bodegaUruca = TestDataFactory.createBodega('Uruca',false); 
        bodegaUruca.ID_EXTERNO_BODEGA__c = '01';
        bodegas.add(bodegaUruca);

        Bodega__c bodegaEscazu = TestDataFactory.createBodega('Escazú',false);
        bodegaEscazu.ID_EXTERNO_BODEGA__c = '02';
        bodegas.add(bodegaEscazu);
        INSERT bodegas;

        String pbBavarianName = 'Bavarian Dólar';
        List<Product2> productList = new List<Product2>(); 
        
        //vehiculo 1
        Product2 vehicle = TestDataFactory.createProduct(model, model,tipo,grupo, brand, family, model, year, 'Rojo','Negro','Vehiculo',true, false); 
        Product2 vehicleFantasia = TestDataFactory.createProduct(model, model,tipo,grupo, brand, family, model, year, 'Rojo','Negro','Vehiculo',false, false);
        productList.add(vehicle);
        productList.add(vehicleFantasia);

        //vehiculo 2
        Product2 vehicle2 = TestDataFactory.createProduct(model2, model2,tipo, grupo, brand, family, model2, year, 'Rojo','Negro','Vehiculo',true, false);            
        Product2 vehicleFantasia2 = TestDataFactory.createProduct(model2, model2, tipo, grupo, brand, family, model2, year, 'Rojo','Negro','Vehiculo',false, false);
        productList.add(vehicle2);
        productList.add(vehicleFantasia2);

        INSERT productList;

        // //Mano de obra   
        List<Product2> productExtraList = new List<Product2>();      
        productExtraList.add(TestDataFactory.createProduct('Mano de obra', 'Mano de obra', null,null,brand, null, null, year, 'Rojo','Negro','Mano de Obra',false, false));
        INSERT productExtraList;

        List<ProductoXBodega__c> prodXBodegas = new List<ProductoXBodega__c>();
        for (Bodega__c bodega : bodegas) {
            prodXBodegas.add(TestDataFactory.createProductoXBodega(bodega,productExtraList[0], false));
            prodXBodegas.add(TestDataFactory.createProductoXBodega(bodega,vehicle, false));
            prodXBodegas.add(TestDataFactory.createProductoXBodega(bodega,vehicle2, false));
        }
        INSERT prodXBodegas;

        List<Compatibilidad__c> compList = new List<Compatibilidad__c>();
        for (Product2 prod : productExtraList) {
            compList.add(TestDataFactory.createCompatibilidad(brandObj,modelObj,prod,false));                
        }        
        INSERT compList;

        List<Pricebook2> pbList = new List<Pricebook2>();
        Pricebook2 pbFantasia = TestDataFactory.createPriceBook(brand+'-'+year, false);
        Pricebook2 pbBavarian = TestDataFactory.createPriceBook(pbBavarianName, false);
        pbList.add(pbFantasia);
        pbList.add(pbBavarian);
        INSERT pbList;

        TestDataFactory.createConfiVentas(brand,brand+'-'+year,brand,pbBavarian,true);

        List<PricebookEntry> pbeList = new List<PricebookEntry>();
        
        pbeList.add(TestDataFactory.createPriceBookEntry(pbFantasia, vehicleFantasia, 10000, false));  
        pbeList.add(TestDataFactory.createPriceBookEntry(pbBavarian, vehicle, 10000, false));

        pbeList.add(TestDataFactory.createPriceBookEntry(pbFantasia, vehicleFantasia2, 10000, false));  
        pbeList.add(TestDataFactory.createPriceBookEntry(pbBavarian, vehicle2, 10000, false));
        
        pbeList.add(TestDataFactory.createPriceBookEntry(pbBavarian, productExtraList[0], 10000, false));
        INSERT pbeList;
        System.debug('PricebookEntry: ' + pbeList);

        Account acc = TestDataFactory.createAccount('Account Test Juan C.', true);

        List<RecordType> rtype = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Campaign' AND DeveloperName = 'Campana_Red_Motors'];
        Campaign campaniaTaller = TestDataFactory.createCampanna('Campaña de Taller',rtype[0].Id, true);
        Campaign campaniaAseguradora = TestDataFactory.createCampanna('Campaña Aseguradora',rtype[0].Id, true);
        
        Id pricebookId = Test.getStandardPricebookId();

        //Query the system administrator profile considering the language spanish and english
        Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = 'Administrador del sistema' LIMIT 1];

        User user = TestDataFactory.createUser('test', 'test', 'test', 'test@test.test', 'test.user@pruebas.empresa.com', systemAdminProfile, null, null, null, null, true);
        System.debug('User: ' + user);

        //El nombbre de la sucursal debe ser de acuerdo a valores de un picklist en la oportunidad
        //Escazú
        Sucursal__c sucursal = TestDataFactory.createSurcursal('Escazú',false);
        sucursal.DirectordeVentasBMW__c = user.Id;
        sucursal.GerentedeSucursalBMW__c = user.Id;
        sucursal.JefeseSucursalBMW__c = user.Id;

        sucursal.DirectordeVentasPolaris__c = user.Id;
        sucursal.GerentedeSucursalPolaris__c = user.Id;
        sucursal.JefesdeSucursalPolaris__c = user.Id;

        sucursal.DirectordeVentasMini__c = user.Id;
        sucursal.GerentedeSucursalMini__c = user.Id;
        sucursal.JefesdeSucursalMini__c = user.Id;

        sucursal.DirectordeVentasKTM__c = user.Id;
        sucursal.GerentedeSucursalKTM__c = user.Id;
        sucursal.JefesdeSucursalKTM__c = user.Id;

        sucursal.DirectordeVentasKawasaki__c = user.Id;
        sucursal.GerentedeSucursalKawasaki__c = user.Id;
        sucursal.JefesdeSucursalKawasaki__c = user.Id;

        sucursal.DirectordeVentasMotorrad__c = user.Id;
        sucursal.Gerente_de_SucursalMotorrad__c = user.Id;
        sucursal.JefedeSucursalMotorrad__c = user.Id;

        sucursal.DirectordeVentasHarley__c = user.Id;
        sucursal.GerentedeSucursalHarley__c = user.Id;
        sucursal.JefedeSucursalHarley__c = user.Id;

        INSERT sucursal;

        Opportunity opp = TestDataFactory.createOpportunity(acc, 'Oportunidad Calificada', campaniaTaller, pricebookId, false);
        opp.Sucursal__c = sucursal.Name;
        INSERT opp;

        Oportunidad_Producto_Interes__c oppProdInteres = TestDataFactory.createOportunidadProductoInteres( brand,model, family, year, opp,  true);

        Trigger_control__c trgControl = TestDataFactory.createTriggerControl('aprobacion de descuentos', true);

        // Plan_de_Mantenimiento__c planMtto = TestDataFactory.createPlanMantenimiento('test', true);
        //crear opportunityLineItem
        // OpportunityLineItem oli = TestDataFactory.createOpportunityLineItem(opp, vehicleFantasia, 1, 10000, true);

    }

    public static void createVehiculosNuevos() {
        String brand = 'BMW';
        String year = '2023';
        String model = 'BM166 - X1 sDrive18d';

        String pbBavarianName = 'Bavarian Dólar';
        List<Product2> productList = new List<Product2>();    
        Product2 vehicle = TestDataFactory.createProduct('BM166 - X1 sDrive18d', 'BMW-X1',tipo,grupo, brand, family, 'BM166 - X1 sDrive18d', year, 'Rojo','Negro','Vehiculo',true, false);            
        Product2 vehicleFantasia = TestDataFactory.createProduct('BM166 - X1 sDrive18d', tipo,grupo,'BMW i', brand, family, 'BM166 - X1 sDrive18d', year, 'Rojo','Negro','Vehiculo',false, false);
        productList.add(vehicle);
        productList.add(vehicleFantasia);
        INSERT productList;     

        Bodega__c bodegaUruca = TestDataFactory.createBodega('Uruca',true); 
        System.debug(bodegaUruca);

        ProductoXBodega__c prodXBod = TestDataFactory.createProductoXBodega(bodegaUruca,vehicle, true);

        List<Pricebook2> pbList = new List<Pricebook2>();
        Pricebook2 pbFantasia = TestDataFactory.createPriceBook(brand+'-'+year, false);
        Pricebook2 pbBavarian = TestDataFactory.createPriceBook(pbBavarianName, false);
        pbList.add(pbFantasia);
        pbList.add(pbBavarian);
        INSERT pbList;

        TestDataFactory.createConfiVentas(brand,brand+'-'+year,brand,pbBavarian,true);

        List<PricebookEntry> pbeList = new List<PricebookEntry>();
        pbeList.add(TestDataFactory.createPriceBookEntry(pbFantasia, vehicleFantasia, 10000, false));  
        pbeList.add(TestDataFactory.createPriceBookEntry(pbBavarian, vehicle, 10000, false));
        INSERT pbeList;

        // Account acc = TestDataFactory.createAccount('Account Test Juan C.', true);

        List<RecordType> rtype = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Campaign' AND DeveloperName = 'Campana_Red_Motors'];
        Campaign campaniaTaller = TestDataFactory.createCampanna('Campaña de Taller',rtype[0].Id, true);
        Campaign campaniaAseguradora = TestDataFactory.createCampanna('Campaña Aseguradora',rtype[0].Id, true);
        
        Id pricebookId = Test.getStandardPricebookId();

        //Query the system administrator profile considering the language spanish and english
        Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = 'Administrador del sistema' LIMIT 1];

        User user = TestDataFactory.createUser('test', 'test', 'test', 'test@test.test', 'test.user@pruebas.empresa.com', systemAdminProfile, null, null, null, null, true);
        System.debug('User: ' + user);

        //El nombbre de la sucursal debe ser de acuerdo a valores de un picklist en la oportunidad
        //Escazú
        Sucursal__c sucursal = TestDataFactory.createSurcursal('Escazú',false);
        sucursal.DirectordeVentasBMW__c = user.Id;
        sucursal.GerentedeSucursalBMW__c = user.Id;
        sucursal.JefeseSucursalBMW__c = user.Id;

        sucursal.DirectordeVentasPolaris__c = user.Id;
        sucursal.GerentedeSucursalPolaris__c = user.Id;
        sucursal.JefesdeSucursalPolaris__c = user.Id;

        sucursal.DirectordeVentasMini__c = user.Id;
        sucursal.GerentedeSucursalMini__c = user.Id;
        sucursal.JefesdeSucursalMini__c = user.Id;

        sucursal.DirectordeVentasKTM__c = user.Id;
        sucursal.GerentedeSucursalKTM__c = user.Id;
        sucursal.JefesdeSucursalKTM__c = user.Id;

        sucursal.DirectordeVentasKawasaki__c = user.Id;
        sucursal.GerentedeSucursalKawasaki__c = user.Id;
        sucursal.JefesdeSucursalKawasaki__c = user.Id;

        sucursal.DirectordeVentasMotorrad__c = user.Id;
        sucursal.Gerente_de_SucursalMotorrad__c = user.Id;
        sucursal.JefedeSucursalMotorrad__c = user.Id;

        sucursal.DirectordeVentasHarley__c = user.Id;
        sucursal.GerentedeSucursalHarley__c = user.Id;
        sucursal.JefedeSucursalHarley__c = user.Id;

        INSERT sucursal;
    }
    
}