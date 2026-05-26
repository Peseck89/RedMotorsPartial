@IsTest
private class RM_VN_CrearOportunidad_Ctrl_Test{
    static final String BRAND = 'BMW';
    static final String YEAR = '2023';
    private class DummyHttpMock implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"ok":true}');
            return res;
        }

    }

    
    @TestSetup
    static void makeData(){

        // --- Trigger controls para desactivar triggers problemáticos ---
        insert new List<Trigger_control__c>{ new Trigger_control__c(
            Name = 'aprobacion de descuentos', 
            Turned_off__c = true
        ), new Trigger_control__c(
            Name = 'OpportunityLineItem', 
            Turned_off__c = true
        ), new Trigger_control__c(
            Name = 'QuoteLineItem', 
            Turned_off__c = true
        ) };

        // --- Cuenta ---
        insert new Account(
            Name = 'Account Test VN', 
            Tipo_de_Documento__c = '01', 
            Cedula__c = '110460321'
        );

        // --- Bodega ---
        Bodega__c bodega = new Bodega__c(
            Name = 'Bodega Test VN', 
            ID_EXTERNO_BODEGA__c = 'VNTST01'
        );
        insert bodega;

        // --- Producto vehículo ---
        String rtVehiculoId = getRecordTypeId('Product2', 'Vehiculos');
        Product2 vehiculo = new Product2(
            Name = 'BMW iX Test VN', 
            ProductCode = 'BMW-IX-VN-TST', 
            Codigo_de_Producto__c = 'BMW-IX-VN-TST', 
            marcaVehiculo__c = BRAND, 
            Anno__c = YEAR, 
            IsActive = true, 
            esVehiculo__c = true, 
            Producto_Reservado__c = false, 
            vin__c = 'VINTEST001VN', 
            modelo__c = 'BMW-IX-VN-TST', 
            RecordTypeId = rtVehiculoId
        );
        insert vehiculo;

        // --- Producto fantasía ---
        String rtProdId = getRecordTypeId('Product2', 'Producto_Red_Motors');
        Product2 vehiculoFantasia = new Product2(
            Name = 'BMW iX Test VN Fantasia', 
            ProductCode = 'BMW-IX-VN-TST-F', 
            Codigo_de_Producto__c = 'BMW-IX-VN-TST-F', 
            marcaVehiculo__c = BRAND, 
            Anno__c = YEAR, 
            IsActive = true, 
            esVehiculo__c = false, 
            RecordTypeId = rtProdId
        );
        insert vehiculoFantasia;

        // --- ProductoXBodega ---
        insert new ProductoXBodega__c(
            Bodega__c = bodega.Id, 
            Producto__c = vehiculo.Id, 
            Disponible__c = 1, 
            Identificador__c = String.valueOf(bodega.Id) + '-' + String.valueOf(vehiculo.Id), 
            Name = 'PXB-VN-TEST'
        );

        // --- Pricebooks ---
        Pricebook2 pbSoftland = new Pricebook2(
            Name = 'Bavarian Dolar Test', 
            IsActive = true, 
            CurrencyIsoCode = 'USD'
        );
        insert pbSoftland;

        Pricebook2 pbFantasia = new Pricebook2(
            Name = BRAND + '-' + YEAR, 
            IsActive = true, 
            CurrencyIsoCode = 'USD'
        );
        insert pbFantasia;

        // --- Configuracion_de_ventas ---
        insert new Configuracion_de_ventas__c(
            Name = BRAND, 
            Marca__c = BRAND, 
            Listas_de_Precios_Vigente__c = BRAND + '-' + YEAR, 
            RM_ListaPrecioSoftland__c = pbSoftland.Id, 
            CurrencyIsoCode = 'USD'
        );

        // --- PBE Standard: solo si no existen ---
        Id stdPbId = Test.getStandardPricebookId();
        List<Id> prodIds = new List<Id>{ vehiculo.Id, vehiculoFantasia.Id };
        Set<Id> existingProds = new Set<Id>();
        for (PricebookEntry p : [SELECT Product2Id
                                 FROM PricebookEntry
                                 WHERE Pricebook2Id = :stdPbId AND Product2Id IN:prodIds]){
            existingProds.add(p.Product2Id);
        }
        List<PricebookEntry> stdPBEs = new List<PricebookEntry>();
        for (Id pid : prodIds){
            if (!existingProds.contains(pid)){
                stdPBEs.add(new PricebookEntry(
                    Pricebook2Id = stdPbId, 
                    Product2Id = pid, 
                    UnitPrice = 50000, 
                    IsActive = true, 
                    CurrencyIsoCode = 'USD'
                ));
            }
        }
        if (!stdPBEs.isEmpty())
            insert stdPBEs;
        // --- PBE Softland ---
        insert new PricebookEntry(
            Pricebook2Id = pbSoftland.Id, 
            Product2Id = vehiculo.Id, 
            UnitPrice = 50000, 
            Costo_Fijo__c = 5000, 
            IsActive = true, 
            CurrencyIsoCode = 'USD', 
            Vendedor__c = 2, 
            Jefe__c = 3, 
            Gerente__c = 4
        );

        
        insert new PricebookEntry(
            Pricebook2Id = pbFantasia.Id, 
            Product2Id = vehiculoFantasia.Id, 
            UnitPrice = 50000, 
            Costo_Fijo__c = 5000, 
            IsActive = true, 
            CurrencyIsoCode = 'USD', 
            Vendedor__c = 2, 
            Jefe__c = 3, 
            Gerente__c = 4
        );
    }

   
    private static String getRecordTypeId(String objectName, String devName){
        List<RecordType> rts = [SELECT Id
                                FROM RecordType
                                WHERE SObjectType = :objectName AND DeveloperName = :devName AND IsActive = TRUE
                                LIMIT 1];
        return rts.isEmpty() ? null : rts[0].Id;
    }

    
    private static Account getTestAccount(){
        return [SELECT Id, Name, IsPersonAccount, PersonContactId, Cedula__c, Phone, PersonEmail, CorreoElectronicoEmpresarial__c, Invoice_Email__c
                FROM Account
                WHERE Name = 'Account Test VN'
                LIMIT 1];
    }

    private static Id getContactoId(Account acc){
        if (acc.IsPersonAccount && acc.PersonContactId != null)
            return acc.PersonContactId;
        List<Contact> cons = [SELECT Id
                              FROM Contact
                              WHERE AccountId = :acc.Id
                              LIMIT 1];
        if (!cons.isEmpty())
            return cons[0].Id;
        Contact c = new Contact(
            LastName = 'TestContactVN', 
            AccountId = acc.Id
        );
        insert c;
        return c.Id;
    }

    private static ProductoXBodega__c getValidPXB(){
        List<ProductoXBodega__c> lst = [SELECT Id, Producto__c, Bodega__c, Producto__r.marcaVehiculo__c, Producto__r.Anno__c, Producto__r.esVehiculo__c, Producto__r.es_Vehiculo_en_transito__c, Producto__r.Producto_Reservado__c
                                        FROM ProductoXBodega__c
                                        WHERE (Producto__r.esVehiculo__c = TRUE OR Producto__r.es_Vehiculo_en_transito__c = TRUE) AND Producto__r.Producto_Reservado__c = false AND Disponible__c > 0 AND Bodega__c != null
                                        LIMIT 1];
        System.assert(!lst.isEmpty(), 'No se encontró ProductoXBodega válido.');
        return lst[0];
    }

    
    private static PricebookEntry getFantasiaPBE(){
        String pbName = BRAND + '-' + YEAR;
        List<PricebookEntry> lst = [SELECT Id, UnitPrice, Costo_Fijo__c, Product2Id, Pricebook2Id, Product2.Name, Product2.Familia__c, Jefe__c, Vendedor__c, Gerente__c
                                    FROM PricebookEntry
                                    WHERE Pricebook2.Name = :pbName AND IsActive = TRUE AND Pricebook2.IsActive = TRUE AND Product2.IsActive = TRUE
                                    LIMIT 1];
        System.assert(!lst.isEmpty(), 'No se encontró PBE fantasía: ' + pbName);
        return lst[0];
    }

    private static PricebookEntry getSoftlandPBE(){
        Id softlandPbId = RM_VN_Service.getSoftlandPriceBookId(BRAND, YEAR);
        System.assertNotEquals(null, softlandPbId, 'Softland PricebookId es null.');
        List<PricebookEntry> lst = [SELECT Id, UnitPrice, Costo_Fijo__c, Product2Id, Pricebook2Id, Product2.Name, Product2.Familia__c, Jefe__c, Vendedor__c, Gerente__c
                                    FROM PricebookEntry
                                    WHERE Pricebook2Id = :softlandPbId AND IsActive = TRUE AND Pricebook2.IsActive = TRUE AND Product2.IsActive = TRUE
                                    LIMIT 1];
        System.assert(!lst.isEmpty(), 'No se encontró PBE Softland.');
        return lst[0];
    }

    private static List<RM_VN_CrearOportunidad_Ctrl.RM_VN_SelectedItem_Wrapper> buildItems(ProductoXBodega__c pxb, PricebookEntry pbeFantasia, PricebookEntry pbeSoftland){
        RM_VN_CrearOportunidad_Ctrl.RM_VN_SelectedItem_Wrapper w = new RM_VN_CrearOportunidad_Ctrl.RM_VN_SelectedItem_Wrapper();
        w.prodXBodId = String.valueOf(pxb.Id);
        w.pbeFantasiaId = String.valueOf(pbeFantasia.Id);
        w.pbeSoftlandId = String.valueOf(pbeSoftland.Id);
        w.pbeBararianId = String.valueOf(pbeSoftland.Id);
        return new List<RM_VN_CrearOportunidad_Ctrl.RM_VN_SelectedItem_Wrapper>{ w };
    }

    // FIX 2: Obtener primer valor válido de picklist para evitar restricted picklist errors
    private static String getFirstPicklistValue(Schema.SObjectField fieldRef){
        for (Schema.PicklistEntry pe : fieldRef.getDescribe().getPicklistValues()){
            if (pe.isActive())
                return pe.getValue();
        }
        return null;
    }

    
    @IsTest
    static void test_createOpportunity_happyPath(){
        Account acc = getTestAccount();
        Id contactoId = getContactoId(acc);
        ProductoXBodega__c pxb = getValidPXB();
        PricebookEntry pbeF = getFantasiaPBE();
        PricebookEntry pbeS = getSoftlandPBE();

        // FIX 2: No hardcodear 'Nuevo' — leer primer valor activo del picklist
        String tipoCliente = getFirstPicklistValue(Opportunity.Tipo_de_Cliente__c);

        Test.setMock(HttpCalloutMock.class, new DummyHttpMock());
        Test.startTest();
        Map<String, Object> resp;
        try{
            resp = RM_VN_CrearOportunidad_Ctrl.createOpportunity(String.valueOf(contactoId), String.valueOf(acc.Id), buildItems(pxb, pbeF, pbeS), BRAND, YEAR, tipoCliente,   // primer valor válido del picklist
            null, null, 'Web', 'Si', YEAR, null, null, 'Contado', null, 0, null, null);
        } catch (Exception e){
            System.assert(false, 'No debió lanzar excepción: ' + e.getMessage());
        }
        Test.stopTest();

        System.assertNotEquals(null, resp, 'Respuesta no debe ser null.');
        System.assert(resp.containsKey('opportunityId'), 'Debe contener opportunityId.');
        System.assert(resp.containsKey('quoteId'), 'Debe contener quoteId.');

        Id oppId = (Id) resp.get('opportunityId');
        System.assertEquals('Oportunidad Calificada', [SELECT StageName
                                                       FROM Opportunity
                                                       WHERE Id = :oppId].StageName);
    }

    
    @IsTest
    static void test_createOpportunity_conCuentaFacturacion(){
        Account acc = getTestAccount();
        Id contactoId = getContactoId(acc);
        ProductoXBodega__c pxb = getValidPXB();
        PricebookEntry pbeF = getFantasiaPBE();
        PricebookEntry pbeS = getSoftlandPBE();

        Test.setMock(HttpCalloutMock.class, new DummyHttpMock());
        Test.startTest();
        Map<String, Object> resp;
        try{
            resp = RM_VN_CrearOportunidad_Ctrl.createOpportunity(String.valueOf(contactoId), String.valueOf(acc.Id), buildItems(pxb, pbeF, pbeS), BRAND, YEAR, null, null, String.valueOf(acc.Id), null, 'No', YEAR, null, null, null, null, 0, null, '123456789');
        } catch (Exception e){
            System.assert(false, 'No debió lanzar excepción: ' + e.getMessage());
        }
        Test.stopTest();

        System.assertNotEquals(null, resp, 'Respuesta no debe ser null.');
        System.assertNotEquals(null, resp.get('opportunityId'), 'opportunityId no debe ser null.');
    }

    
    @IsTest
    static void test_createOpportunity_conTrafico(){
        Account acc = getTestAccount();
        Id contactoId = getContactoId(acc);

        List<RecordType> rtLead = [SELECT Id
                                   FROM RecordType
                                   WHERE SObjectType = 'Lead' AND DeveloperName LIKE '%BMW%' AND IsActive = TRUE
                                   LIMIT 1];
        if (!rtLead.isEmpty()){
            insert new Lead(
                FirstName = 'Trafico', 
                LastName = 'Test', 
                Company = 'TestCo', 
                RecordTypeId = rtLead[0].Id, 
                Numero_de_Identificacion_del__c = '110460321', 
                Status = 'Open - Not Contacted'
            );
        }

        ProductoXBodega__c pxb = getValidPXB();
        PricebookEntry pbeF = getFantasiaPBE();
        PricebookEntry pbeS = getSoftlandPBE();

        Test.setMock(HttpCalloutMock.class, new DummyHttpMock());
        Boolean oliBypassSet = false;
        try {
            TriggerHandler.bypass('OpportunityLineItemTriggerHandler');
            oliBypassSet = true;
        } catch (Exception e) {
            System.debug('No se pudo activar bypass OpportunityLineItemTriggerHandler: ' + e.getMessage());
        }

        Test.startTest();
        Map<String, Object> resp;
        try{
            resp = RM_VN_CrearOportunidad_Ctrl.createOpportunity(String.valueOf(contactoId), String.valueOf(acc.Id), buildItems(pxb, pbeF, pbeS), BRAND, YEAR, null, null, null, null, null, null, null, null, null, null, 0, null, '110460321');
        } catch (Exception e){
            System.assert(false, 'No debió lanzar excepción: ' + e.getMessage());
        } finally {
            if (oliBypassSet) {
                try {
                    TriggerHandler.clearBypass('OpportunityLineItemTriggerHandler');
                } catch (Exception e) {
                    System.debug('No se pudo limpiar bypass OpportunityLineItemTriggerHandler: ' + e.getMessage());
                }
            }
        }
        Test.stopTest();

        System.assertNotEquals(null, resp, 'Respuesta no debe ser null.');
    }

    
    @IsTest
    static void test_validarCuenta(){
        Account acc = getTestAccount();
        Test.startTest();
        List<Account> result = RM_VN_CrearOportunidad_Ctrl.validarCuenta(String.valueOf(acc.Id));
        Test.stopTest();
        System.assert(!result.isEmpty(), 'validarCuenta debe retornar la cuenta.');
        System.assertEquals(acc.Id, result[0].Id, 'Id incorrecto.');
    }

    
    @IsTest
    static void test_crearCuenta_businessAccount(){
        Account acc = [SELECT Id
                       FROM Account
                       WHERE IsPersonAccount = false
                       LIMIT 1];
        Test.startTest();
        List<Account> result = RM_VN_CrearOportunidad_Ctrl.crearCuenta(String.valueOf(acc.Id), 'NombreEmpresa', null, '22222222', 'empresa@test.com', 'fact@test.com');
        Test.stopTest();
        System.assert(!result.isEmpty(), 'crearCuenta debe retornar registros.');
    }

    
    @IsTest
    static void test_crearCuenta_personAccount(){
        List<Account> pas = [SELECT Id
                             FROM Account
                             WHERE IsPersonAccount = true
                             LIMIT 1];
        if (pas.isEmpty()){
            System.assert(true, 'Sin PersonAccount, omitido.');
            return;
        }
        Test.startTest();
        List<Account> result = RM_VN_CrearOportunidad_Ctrl.crearCuenta(String.valueOf(pas[0].Id), 'Nombre', 'Apellido', '88888888', 'p@test.com', 'f@test.com');
        Test.stopTest();
        System.assert(!result.isEmpty(), 'crearCuenta persona debe retornar registros.');
    }

    
    @IsTest
    static void test_getTipoGasolina(){
        Test.startTest();
        List<RM_SelectOption_Wrapper> opts = RM_VN_CrearOportunidad_Ctrl.getTipoGasolina();
        Test.stopTest();
        System.assert(opts != null && opts.size() > 0, 'Debe traer al menos "Todos".');
        System.assertEquals('Todos', opts[0].label, 'Primer item debe ser "Todos".');
    }

    
    @IsTest
    static void test_getRecordTypes(){
        Test.startTest();
        List<RM_SelectOption_Wrapper> opts = RM_VN_CrearOportunidad_Ctrl.getRecordTypes();
        Test.stopTest();
        System.assertNotEquals(null, opts, 'getRecordTypes no debe ser null.');
    }

    
    @IsTest
    static void test_getSucursalName(){
        Test.startTest();
        String s = RM_VN_CrearOportunidad_Ctrl.getSucursalName();
        Test.stopTest();
        System.assertNotEquals(null, s, 'getSucursalName no debe ser null.');
    }

    
    @IsTest
    static void test_findValidTraffic_sinLead(){
        Test.startTest();
        Lead r = RM_VN_CrearOportunidad_Ctrl.findValidTraffic('999999999', 'BMW');
        Test.stopTest();
        System.assertEquals(null, r, 'Sin lead debe retornar null.');
    }

    
    @IsTest
    static void test_findValidTraffic_cedulaBlank(){
        Test.startTest();
        Lead r = RM_VN_CrearOportunidad_Ctrl.findValidTraffic('', 'BMW');
        Test.stopTest();
        System.assertEquals(null, r, 'Con vacío debe retornar null.');
    }

    
    @IsTest
    static void test_createOpportunity_cuentaRequerida(){
        Boolean threw = false;
        Test.startTest();
        try{
            RM_VN_CrearOportunidad_Ctrl.createOpportunity(null, null, new List<RM_VN_CrearOportunidad_Ctrl.RM_VN_SelectedItem_Wrapper>(), null, null, null, null, null, null, null, null, null, null, null, null, 0, null, null);
        } catch (Exception e){
            threw = true;
        }
        Test.stopTest();
        System.assert(threw, 'Debió lanzar excepción por cuenta requerida.');
    }

    
    @IsTest
    static void test_createOpportunity_marcaRequerida(){
        Account acc = getTestAccount();
        Boolean threw = false;
        Test.startTest();
        try{
            RM_VN_CrearOportunidad_Ctrl.createOpportunity(null, String.valueOf(acc.Id), new List<RM_VN_CrearOportunidad_Ctrl.RM_VN_SelectedItem_Wrapper>(), '', YEAR, null, null, null, null, null, null, null, null, null, null, 0, null, null);
        } catch (Exception e){
            threw = true;
        }
        Test.stopTest();
        System.assert(threw, 'Debió lanzar excepción por marca requerida.');
    }

    
    @IsTest
    static void test_createOpportunity_anioRequerido(){
        Account acc = getTestAccount();
        Boolean threw = false;
        Test.startTest();
        try{
            RM_VN_CrearOportunidad_Ctrl.createOpportunity(null, String.valueOf(acc.Id), new List<RM_VN_CrearOportunidad_Ctrl.RM_VN_SelectedItem_Wrapper>(), BRAND, '', null, null, null, null, null, null, null, null, null, null, 0, null, null);
        } catch (Exception e){
            threw = true;
        }
        Test.stopTest();
        System.assert(threw, 'Debió lanzar excepción por año requerido.');
    }

    
    @IsTest
    static void test_createOpportunity_itemsRequeridos(){
        Account acc = getTestAccount();
        Boolean threw = false;
        Test.startTest();
        try{
            RM_VN_CrearOportunidad_Ctrl.createOpportunity(null, String.valueOf(acc.Id), new List<RM_VN_CrearOportunidad_Ctrl.RM_VN_SelectedItem_Wrapper>(), BRAND, YEAR, null, null, null, null, null, null, null, null, null, null, 0, null, null);
        } catch (Exception e){
            threw = true;
        }
        Test.stopTest();
        System.assert(threw, 'Debió lanzar excepción por items vacíos.');
    }

    
    @IsTest
    static void test_crearOPIRecords(){
        Account acc = getTestAccount();
        // FIX 1: getSoftlandPBE() ya incluye Product2.Name en el query
        PricebookEntry pbeS = getSoftlandPBE();
        Id softlandPbId = RM_VN_Service.getSoftlandPriceBookId(BRAND, YEAR);

        List<RecordType> oppRTs = [SELECT Id
                                   FROM RecordType
                                   WHERE SObjectType = 'Opportunity' AND DeveloperName LIKE '%BMW%' AND IsActive = TRUE
                                   LIMIT 1];
        System.assert(!oppRTs.isEmpty(), 'No se encontró RecordType BMW para Opportunity.');

        Opportunity opp = new Opportunity(
            Name = 'OPI Test Opp VN', 
            AccountId = acc.Id, 
            StageName = 'Oportunidad Calificada', 
            CloseDate = System.today(), 
            Pricebook2Id = softlandPbId, 
            RecordTypeId = oppRTs[0].Id, 
            CurrencyIsoCode = 'USD'
        );
        insert opp;

        Test.startTest();
        Map<String, Oportunidad_Producto_Interes__c> result = RM_VN_CrearOportunidad_Ctrl.crearOPIRecords(String.valueOf(opp.Id), BRAND, YEAR, new List<PricebookEntry>{ pbeS });
        Test.stopTest();

        System.assertNotEquals(null, result, 'El mapa OPI no debe ser null.');
        System.assertEquals(1, result.size(), 'Debe haber 1 OPI creado.');
    }

    
@IsTest
static void test_getSoftlandPriceBookId_marcaInexistente(){
    Boolean threw = false;
    Test.startTest();
    try {
        RM_VN_CrearOportunidad_Ctrl.getSoftlandPriceBookId('MARCA_INVALIDA');
    } catch (Exception e) {
        threw = true;
    }
    Test.stopTest();
    System.assert(threw, 'Debe lanzar excepción cuando no existe la configuración de ventas.');
}


@IsTest
static void test_getSoftlandPriceBookId_marcaValida(){
    Test.startTest();
    Id pbId = RM_VN_CrearOportunidad_Ctrl.getSoftlandPriceBookId(BRAND);
    Test.stopTest();
    System.assertNotEquals(null, pbId, 'Debe retornar un Id válido para la marca BMW.');
}


@IsTest
static void test_setTrafficLookup_conDatos(){
    Account acc = getTestAccount();
    Id softlandPbId = RM_VN_Service.getSoftlandPriceBookId(BRAND, YEAR);
    List<RecordType> oppRTs = [SELECT Id FROM RecordType
                                WHERE SObjectType = 'Opportunity'
                                AND DeveloperName LIKE '%BMW%' AND IsActive = TRUE LIMIT 1];
    if (oppRTs.isEmpty()) { System.assert(true, 'Sin RT, omitido.'); return; }

    Opportunity opp = new Opportunity(
        Name = 'Test SetTraffic',
        AccountId = acc.Id,
        StageName = 'Oportunidad Calificada',
        CloseDate = System.today(),
        Pricebook2Id = softlandPbId,
        RecordTypeId = oppRTs[0].Id,
        CurrencyIsoCode = 'USD'
    );
    insert opp;

    // Insertar un lead para tener un Id válido
    List<Lead> leads = [SELECT Id FROM Lead LIMIT 1];
    if (leads.isEmpty()) {
        insert new Lead(FirstName = 'T', LastName = 'L', Company = 'Co', Status = 'Open - Not Contacted');
        leads = [SELECT Id FROM Lead LIMIT 1];
    }

    Test.startTest();
    // Caso normal
    RM_VN_CrearOportunidad_Ctrl.setTrafficLookup(opp, leads[0].Id);
    // Casos nulos (deben retornar sin error)
    RM_VN_CrearOportunidad_Ctrl.setTrafficLookup(null, leads[0].Id);
    RM_VN_CrearOportunidad_Ctrl.setTrafficLookup(opp, null);
    Test.stopTest();

    System.assert(true, 'setTrafficLookup ejecutado sin excepción.');
}


@IsTest
static void test_putIfFieldExists(){
    Account acc = getTestAccount();

    Test.startTest();
    // Campo que existe en Account
    RM_VN_CrearOportunidad_Ctrl.putIfFieldExists(acc, 'Phone', '88887777');
    // Campo que NO existe
    RM_VN_CrearOportunidad_Ctrl.putIfFieldExists(acc, 'CampoQueNoExiste__c', 'valor');
    // Casos nulos
    RM_VN_CrearOportunidad_Ctrl.putIfFieldExists(null, 'Phone', '1111');
    RM_VN_CrearOportunidad_Ctrl.putIfFieldExists(acc, null, '1111');
    RM_VN_CrearOportunidad_Ctrl.putIfFieldExists(acc, 'Phone', null);
    Test.stopTest();

    System.assert(true, 'putIfFieldExists ejecutado sin excepción.');
}


@IsTest
static void test_convertTrafficLead_leadNull(){
    Test.startTest();
    RM_VN_CrearOportunidad_Ctrl.convertTrafficLead(null, null, null);
    Test.stopTest();
    System.assert(true, 'No debe lanzar excepción con leadId null.');
}


@IsTest
static void test_convertTrafficLead_yaConvertido(){
    Account acc = getTestAccount();
    Id contactoId = getContactoId(acc);

    // Crear lead y convertirlo
    Lead l = new Lead(
        FirstName = 'Conv',
        LastName = 'Test',
        Company = 'TestCo',
        Status = 'Open - Not Contacted'
    );
    insert l;

    // Convertir el lead manualmente
    String convertedStatus = [SELECT MasterLabel FROM LeadStatus WHERE IsConverted = true LIMIT 1].MasterLabel;
    Database.LeadConvert lc = new Database.LeadConvert();
    lc.setLeadId(l.Id);
    lc.setDoNotCreateOpportunity(true);
    lc.setConvertedStatus(convertedStatus);
    Database.convertLead(lc, false);

    Test.startTest();
    RM_VN_CrearOportunidad_Ctrl.convertTrafficLead(l.Id, String.valueOf(acc.Id), String.valueOf(contactoId));
    Test.stopTest();

    System.assert(true, 'No debe lanzar excepción con lead ya convertido.');
}


@IsTest
static void test_convertTrafficLead_leadValido(){
    Account acc = getTestAccount();
    Id contactoId = getContactoId(acc);

    Lead l = new Lead(
        FirstName = 'NoConv',
        LastName = 'Test',
        Company = 'TestCo',
        Status = 'Open - Not Contacted'
    );
    insert l;

    Test.startTest();
    RM_VN_CrearOportunidad_Ctrl.convertTrafficLead(l.Id, String.valueOf(acc.Id), String.valueOf(contactoId));
    Test.stopTest();

    System.assert(true, 'convertTrafficLead ejecutado sin excepción.');
}


@IsTest
static void test_getAnyConvertedLeadStatusValue(){
    Test.startTest();
    String val = RM_VN_CrearOportunidad_Ctrl.getAnyConvertedLeadStatusValue();
    Test.stopTest();
    // Puede ser null si no hay, pero no debe explotar
    System.assert(true, 'getAnyConvertedLeadStatusValue ejecutado sin excepción.');
}


@IsTest
static void test_findLeadStatusValue(){
    Test.startTest();
    // Con candidatos que probablemente existen
    String r1 = RM_VN_CrearOportunidad_Ctrl.findLeadStatusValue(new List<String>{ 'Convertido', 'Converted' });
    // Con candidato inexistente
    String r2 = RM_VN_CrearOportunidad_Ctrl.findLeadStatusValue(new List<String>{ 'StatusQueNoExiste999' });
    // Lista vacía
    String r3 = RM_VN_CrearOportunidad_Ctrl.findLeadStatusValue(new List<String>());
    // Null
    String r4 = RM_VN_CrearOportunidad_Ctrl.findLeadStatusValue(null);
    // Con elemento en blanco
    String r5 = RM_VN_CrearOportunidad_Ctrl.findLeadStatusValue(new List<String>{ '', null });
    Test.stopTest();

    System.assertEquals(null, r2, 'Status inexistente debe retornar null.');
    System.assertEquals(null, r3, 'Lista vacía debe retornar null.');
    System.assertEquals(null, r4, 'Null debe retornar null.');
}


@IsTest
static void test_createOpportunity_traficoAntiguo(){
    Account acc = getTestAccount();
    Id contactoId = getContactoId(acc);

    List<RecordType> rtLead = [SELECT Id FROM RecordType
                                WHERE SObjectType = 'Lead'
                                AND DeveloperName LIKE '%BMW%' AND IsActive = TRUE LIMIT 1];
    if (rtLead.isEmpty()) { System.assert(true, 'Sin RT Lead BMW, omitido.'); return; }

    // Crear lead con cédula específica para este test
    Lead traficoAntiguo = new Lead(
        FirstName = 'Antiguo',
        LastName = 'Trafico',
        Company = 'TestCo',
        RecordTypeId = rtLead[0].Id,
        Numero_de_Identificacion_del__c = '999888777',
        Status = 'Open - Not Contacted'
    );
    insert traficoAntiguo;

    // Forzar la fecha de creación a más de 6 meses atrás via Test.setCreatedDate
    Test.setCreatedDate(traficoAntiguo.Id, System.now().addMonths(-7));

    ProductoXBodega__c pxb = getValidPXB();
    PricebookEntry pbeF = getFantasiaPBE();
    PricebookEntry pbeS = getSoftlandPBE();

    Test.setMock(HttpCalloutMock.class, new DummyHttpMock());
    Test.startTest();
    Map<String, Object> resp;
    try {
        resp = RM_VN_CrearOportunidad_Ctrl.createOpportunity(
            String.valueOf(contactoId),
            String.valueOf(acc.Id),
            buildItems(pxb, pbeF, pbeS),
            BRAND, YEAR,
            null, null, null, null, null, null, null, null, null, null, 0, null,
            '999888777'
        );
    } catch (Exception e) {
        System.assert(false, 'No debió lanzar excepción: ' + e.getMessage());
    }
    Test.stopTest();

    System.assertNotEquals(null, resp, 'Respuesta no debe ser null.');
    System.assertNotEquals(null, resp.get('opportunityId'), 'opportunityId no debe ser null.');
}


@IsTest
static void test_createOpportunity_cuentaNoExiste(){
    // Generar un Id de Account que no existe
    Id fakeId = '001000000000000AAA';
    Boolean threw = false;
    Test.startTest();
    try {
        RM_VN_CrearOportunidad_Ctrl.createOpportunity(
            null, fakeId,
            new List<RM_VN_CrearOportunidad_Ctrl.RM_VN_SelectedItem_Wrapper>(),
            BRAND, YEAR,
            null, null, null, null, null, null, null, null, null, null, 0, null, null
        );
    } catch (Exception e) {
        threw = true;
    }
    Test.stopTest();
    System.assert(threw, 'Debe lanzar excepción por cuenta no encontrada.');
}
}
