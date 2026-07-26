@isTest
public class TrabajoControllerTest {
    @testSetup
    static void setupTestData() {
        // Crear datos de prueba básicos
        Account aseguradora = new Account(Name = 'Test Aseguradora', Tipo_de_Documento__c  = '02', Cedula__c = '0123456789');
        insert aseguradora;
        
        CentroCosto__c centroCosto = new CentroCosto__c(Name = 'Test Centro Costo');
        insert centroCosto;
        
        
        
        Product2 manoDeObra = new Product2(
            Name = 'Test Mano de Obra',
            IsActive = true,
            tipoProducto__c = 'Mano de Obra',
            Codigo_de_Producto__c = 'MO24',
            Mano_de_obra_no_pasa_a_OT__c = false
        );
        insert manoDeObra;
        tiposDeTrabajo__c tipoTrabajo = new tiposDeTrabajo__c(
            Name = 'Test Tipo Trabajo',
            UTS__c = 10,
            ManoDeObra__c = manoDeObra.Id
        );
        insert tipoTrabajo;
        Pricebook2 pb = new Pricebook2(Name = 'Bavarian Local', IsActive = true);
        insert pb;
        
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = pb.Id,
            Product2Id = manoDeObra.Id,
            UnitPrice = 100,
            IsActive = true,
            CurrencyIsoCode = 'CRC'
        );
        insert pbe;
        
        Impuesto__c impuesto = new Impuesto__c(
            Name = 'Test Impuesto',
            codigoImpuesto__c = '0108'
        );
        insert impuesto;
        
        Case testCase = new Case(Subject = 'Test Case');
        insert testCase;
        
        WorkOrder workOrder = new WorkOrder(
            Subject = 'Test Work Order',
            CaseId = testCase.Id,
            Pricebook2Id = pb.Id,
            empresaFactura__c = 'RMBAVARIAN',
            CurrencyIsoCode = 'CRC'
        );
        insert workOrder;
        
        tiposDeTrabajoCaso__c trabajoCaso = new tiposDeTrabajoCaso__c(
            Caso__c = testCase.Id,
            RM_WorkOrder__c = workOrder.Id,
            Tipotrabajo__c = tipoTrabajo.Id,
            RM_Aseguradora__c = aseguradora.Id,
            RM_CentroCosto__c = centroCosto.Id,
            UTS__c = 5
        );
        insert trabajoCaso;
        
        Subtipo_de_trabajo_del_caso__c subtrabajo = new Subtipo_de_trabajo_del_caso__c(
            Tipo_de_trabajo_del_caso__c = trabajoCaso.Id,
            Caso__c = testCase.Id,
            Orden_de_trabajo__c = workOrder.Id,
            Name = 'Test Subtrabajo',
            UTS__c = 2,
            Mano_de_Obra__c = manoDeObra.Id,
            TipoDeTrabajo__c = tipoTrabajo.Id
        );
        insert subtrabajo;
        Test.setMock(HttpCalloutMock.class, new TestEtapasTallerv2_PowerBI.MockHttpResponseGenerator());
    }

    @isTest
    static void testGetWorkOrder() {
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        
        Test.startTest();
        String workOrderId = TrabajoController.getWorkOrder(testCase.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, workOrderId, 'Debería retornar un ID de WorkOrder');
    }

    @isTest
    static void testGetTrabajos() {
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        
        Test.startTest();
        List<TrabajoController.TrabajoWrapper> trabajos = TrabajoController.getTrabajos(testCase.Id);
        Test.stopTest();
        
        System.assert(!trabajos.isEmpty(), 'Debería retornar trabajos');
        System.assert(!trabajos[0].subtrabajos.isEmpty(), 'Debería tener subtrabajos');
    }

    @isTest
    static void testSaveTrabajo() {
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        WorkOrder workOrder = [SELECT Id FROM WorkOrder LIMIT 1];
        tiposDeTrabajo__c tipoTrabajo = [SELECT Id FROM tiposDeTrabajo__c LIMIT 1];
        
        TrabajoController.TrabajoWrapper trabajoWrapper = new TrabajoController.TrabajoWrapper();
        trabajoWrapper.prioridad = 'Sugerido';
        trabajoWrapper.tipoTrabajo = tipoTrabajo.Id;
        trabajoWrapper.tipoCargo = 'Cliente';
        trabajoWrapper.uts = 10;
        
        setHttpMock();
        Test.startTest();
        TrabajoController.saveTrabajo(trabajoWrapper, testCase.Id, workOrder.Id);
        Test.stopTest();
        
        List<tiposDeTrabajoCaso__c> trabajos = [SELECT Id FROM tiposDeTrabajoCaso__c];
        System.assertEquals(2, trabajos.size(), 'Debería haber creado un nuevo trabajo');
    }

    @isTest
    static void testDeleteSubtrabajo() {
        Subtipo_de_trabajo_del_caso__c subtrabajo = [SELECT Id FROM Subtipo_de_trabajo_del_caso__c LIMIT 1];
        
        Test.startTest();
        TrabajoController.deleteSubtrabajo(subtrabajo.Id);
        Test.stopTest();
        
        List<Subtipo_de_trabajo_del_caso__c> subtrabajos = [SELECT Id FROM Subtipo_de_trabajo_del_caso__c];
        System.assertEquals(0, subtrabajos.size(), 'Debería haber eliminado el subtrabajo');
    }

    @isTest
    static void testDeleteTrabajo() {
        tiposDeTrabajoCaso__c trabajo = [SELECT Id FROM tiposDeTrabajoCaso__c LIMIT 1];
        
        Test.startTest();
        TrabajoController.deleteTrabajo(trabajo.Id);
        Test.stopTest();
        
        List<tiposDeTrabajoCaso__c> trabajos = [SELECT Id FROM tiposDeTrabajoCaso__c];
        System.assertEquals(0, trabajos.size(), 'Debería haber eliminado el trabajo');
    }

    @isTest
    static void testGetUTSTipoTrabajo() {
        tiposDeTrabajo__c tipoTrabajo = [SELECT Id, UTS__c FROM tiposDeTrabajo__c LIMIT 1];
        
        Test.startTest();
        Decimal uts = TrabajoController.getUTSTipoTrabajo(tipoTrabajo.Id);
        Test.stopTest();
        
        //System.assertEquals(tipoTrabajo.UTS__c, uts, 'Debería retornar las UTS correctas');
    }

    @isTest
    static void testSaveSubtrabajos() {
        tiposDeTrabajoCaso__c trabajo = [SELECT Id,Name FROM tiposDeTrabajoCaso__c LIMIT 1];
        tiposDeTrabajo__c tipoTrabajo = [SELECT Id,Name FROM tiposDeTrabajo__c LIMIT 1];
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        WorkOrder workOrder = [SELECT Id FROM WorkOrder LIMIT 1];
        Product2 manoDeObra = [SELECT Id FROM Product2 LIMIT 1];
        
        TrabajoController.SubtrabajoWrapper subtrabajoWrapper = new TrabajoController.SubtrabajoWrapper();
        subtrabajoWrapper.id = 'local-1';
        subtrabajoWrapper.nombre = tipoTrabajo.Name;
        subtrabajoWrapper.tipoTrabajo = tipoTrabajo.Id;
        subtrabajoWrapper.manoDeObra = manoDeObra.Id;
        subtrabajoWrapper.uts = 3;
        
        List<TrabajoController.SubtrabajoWrapper> subtrabajos = new List<TrabajoController.SubtrabajoWrapper>{subtrabajoWrapper};
        
        setHttpMock();
        Test.startTest();
        TrabajoController.saveSubtrabajos(
            trabajo.Id,
            tipoTrabajo.Id,
            subtrabajos,
            testCase.Id,
            workOrder.Id,
            'Sugerido',
            'Cliente',
            null,
            null
        );
        Test.stopTest();
        
        List<Subtipo_de_trabajo_del_caso__c> subtrabajosResult = [SELECT Id FROM Subtipo_de_trabajo_del_caso__c];
        System.assertEquals(2, subtrabajosResult.size(), 'Debería haber creado un nuevo subtrabajo');
    }

    @isTest
    static void lookupBavarianSelectsConfiguredLabor() {
        assertSuccessfulCompanySelection('RMBAVARIAN', true, null, 'RMBAVARIAN', 'LOOKUP-BAV');
    }

    @isTest
    static void lookupOtobaiSelectsConfiguredLabor() {
        assertSuccessfulCompanySelection('RMOTOBAI', true, null, 'RMOTOBAI', 'LOOKUP-OTO');
    }

    @isTest
    static void lookupPekingSelectsConfiguredLabor() {
        assertSuccessfulCompanySelection('RMPEKING', true, null, 'RMPEKING', 'LOOKUP-PEK');
    }

    @isTest
    static void lookupPekingTakesPriorityOverLegacyBavarian() {
        assertSuccessfulCompanySelection('RMPEKING', true, 'RMBAVARIAN', 'RMPEKING', 'PRIORITY-PEK');
    }

    @isTest
    static void legacyBavarianIsUsedWhenLookupIsEmpty() {
        assertSuccessfulCompanySelection(null, true, 'RMBAVARIAN', 'RMBAVARIAN', 'LEGACY-BAV');
    }

    @isTest
    static void legacyOtobaiIsUsedWhenLookupIsEmpty() {
        assertSuccessfulCompanySelection(null, true, 'RMOTOBAI', 'RMOTOBAI', 'LEGACY-OTO');
    }

    @isTest
    static void legacyPekingIsUsedWhenLookupIsEmpty() {
        assertSuccessfulCompanySelection(null, true, 'RMPEKING', 'RMPEKING', 'LEGACY-PEK');
    }

    @isTest
    static void inactiveLookupReturnsControlledErrorWithoutLine() {
        assertControlledCompanyError('RMPEKING', false, 'RMOTOBAI', 'INACTIVE');
    }

    @isTest
    static void unsupportedLookupReturnsControlledErrorWithoutLine() {
        assertControlledCompanyError('RMUNKNOWN', true, 'RMBAVARIAN', 'UNKNOWN');
    }

    @isTest
    static void emptyLookupAndLegacyReturnControlledErrorWithoutFallback() {
        assertControlledCompanyError(null, true, null, 'EMPTY');
    }

    private static void assertSuccessfulCompanySelection(
        String lookupCode,
        Boolean active,
        String legacyCompany,
        String mappingCompany,
        String uniqueCode
    ) {
        CompanyScenario scenario = createCompanyScenario(
            lookupCode,
            active,
            legacyCompany,
            mappingCompany,
            uniqueCode
        );

        setHttpMock();
        Test.startTest();
        TrabajoController.saveSubtrabajos(
            scenario.trabajoId,
            scenario.tipoTrabajoId,
            new List<TrabajoController.SubtrabajoWrapper>{
                buildCompanySubtrabajo(scenario.tipoTrabajoId, uniqueCode)
            },
            scenario.caseId,
            scenario.workOrderId,
            'Sugerido',
            'Cliente',
            null,
            null
        );
        Test.stopTest();

        WorkOrderLineItem createdLine = [
            SELECT WorkOrderId, Product__c, PricebookEntryId,
                   PricebookEntry.Pricebook2Id, Quantity, UnitPrice
            FROM WorkOrderLineItem
            WHERE WorkOrderId = :scenario.workOrderId
            LIMIT 1
        ];
        System.assertEquals(scenario.workOrderId, createdLine.WorkOrderId);
        System.assertEquals(scenario.laborProductId, createdLine.Product__c);
        System.assertEquals(scenario.pricebookEntryId, createdLine.PricebookEntryId);
        System.assertEquals(scenario.pricebookId, createdLine.PricebookEntry.Pricebook2Id);
        System.assertEquals(2, createdLine.Quantity);
        System.assertEquals(175, createdLine.UnitPrice);
    }

    private static void assertControlledCompanyError(
        String lookupCode,
        Boolean active,
        String legacyCompany,
        String uniqueCode
    ) {
        CompanyScenario scenario = createCompanyScenario(
            lookupCode,
            active,
            legacyCompany,
            null,
            uniqueCode
        );
        Boolean controlledError = false;

        Test.startTest();
        try {
            TrabajoController.saveSubtrabajos(
                scenario.trabajoId,
                scenario.tipoTrabajoId,
                new List<TrabajoController.SubtrabajoWrapper>{
                    buildCompanySubtrabajo(scenario.tipoTrabajoId, uniqueCode)
                },
                scenario.caseId,
                scenario.workOrderId,
                'Sugerido',
                'Cliente',
                null,
                null
            );
            System.assert(false, 'La resolución inválida debía producir un error controlado.');
        } catch (AuraHandledException expected) {
            controlledError = true;
        }
        Test.stopTest();

        System.assert(controlledError, 'Debe exponerse una AuraHandledException controlada.');
        System.assertEquals(
            0,
            [SELECT COUNT() FROM WorkOrderLineItem WHERE WorkOrderId = :scenario.workOrderId],
            'No debe crearse una línea cuando falla la resolución de empresa.'
        );
    }

    private static CompanyScenario createCompanyScenario(
        String lookupCode,
        Boolean active,
        String legacyCompany,
        String mappingCompany,
        String uniqueCode
    ) {
        Account account = new Account(
            Name = 'Cuenta ' + uniqueCode,
            Tipo_de_Documento__c = '02',
            Cedula__c = '9' + String.valueOf(Math.abs(uniqueCode.hashCode()))
        );
        insert account;

        Asset asset = new Asset(
            Name = 'Vehículo ' + uniqueCode,
            AccountId = account.Id,
            Tipo_de_veh_culo__c = 'Automóvil'
        );
        insert asset;

        Case caseRecord = new Case(
            Subject = 'Caso ' + uniqueCode,
            AccountId = account.Id,
            AssetId = asset.Id
        );
        insert caseRecord;

        String effectiveCompany = lookupCode != null ? lookupCode : legacyCompany;
        Pricebook2 pricebook = getOrCreateScenarioPricebook(
            effectiveCompany,
            uniqueCode
        );

        Product2 laborProduct = new Product2(
            Name = 'Mano de obra ' + uniqueCode,
            IsActive = true,
            tipoProducto__c = 'Mano de Obra',
            Codigo_de_Producto__c = uniqueCode,
            Mano_de_obra_no_pasa_a_OT__c = false
        );
        insert laborProduct;
        ensureStandardPrice(laborProduct.Id);

        PricebookEntry laborEntry = new PricebookEntry(
            Pricebook2Id = pricebook.Id,
            Product2Id = laborProduct.Id,
            UnitPrice = 175,
            IsActive = true,
            CurrencyIsoCode = 'CRC'
        );
        insert laborEntry;

        tiposDeTrabajo__c workType = new tiposDeTrabajo__c(
            Name = 'Tipo ' + uniqueCode,
            UTS__c = 12
        );
        insert workType;

        if (mappingCompany != null) {
            insert new TipoDeCargoConManoDeObra__c(
                Empresa__c = mappingCompany,
                TipoDeCargo__c = 'Cliente',
                TipoDeVehiculo__c = 'Automóvil',
                ManoDeObra__c = laborProduct.Id
            );
        }

        Id companyId;
        if (lookupCode != null) {
            Empresa__c company = new Empresa__c(
                Name = 'Empresa ' + uniqueCode,
                Codigo__c = lookupCode,
                Codigo_ERP__c = lookupCode,
                Nombre_Legal__c = 'Empresa ' + uniqueCode,
                Activa__c = active
            );
            insert company;
            companyId = company.Id;
        }

        WorkOrder workOrder = new WorkOrder(
            Subject = 'WorkOrder ' + uniqueCode,
            CaseId = caseRecord.Id,
            Pricebook2Id = pricebook.Id,
            empresaFacturaCP__c = companyId,
            empresaFactura__c = legacyCompany,
            CurrencyIsoCode = 'CRC'
        );
        insert workOrder;
        if (legacyCompany == null) {
            workOrder.empresaFactura__c = null;
            update workOrder;
        }
        workOrder = [
            SELECT Pricebook2Id
            FROM WorkOrder
            WHERE Id = :workOrder.Id
        ];
        if (
            effectiveCompany == 'RMBAVARIAN' ||
            effectiveCompany == 'RMOTOBAI' ||
            effectiveCompany == 'RMPEKING'
        ) {
            System.assertEquals(
                pricebook.Id,
                workOrder.Pricebook2Id,
                'El WorkOrder debe usar el Pricebook empresarial que contiene la entrada.'
            );
        }

        tiposDeTrabajoCaso__c parentWork = new tiposDeTrabajoCaso__c(
            Caso__c = caseRecord.Id,
            RM_WorkOrder__c = workOrder.Id,
            Tipotrabajo__c = workType.Id,
            UTS__c = 2
        );
        insert parentWork;

        CompanyScenario scenario = new CompanyScenario();
        scenario.caseId = caseRecord.Id;
        scenario.workOrderId = workOrder.Id;
        scenario.trabajoId = parentWork.Id;
        scenario.tipoTrabajoId = workType.Id;
        scenario.laborProductId = laborProduct.Id;
        scenario.pricebookId = pricebook.Id;
        scenario.pricebookEntryId = laborEntry.Id;
        return scenario;
    }

    private static TrabajoController.SubtrabajoWrapper buildCompanySubtrabajo(
        Id tipoTrabajoId,
        String uniqueCode
    ) {
        TrabajoController.SubtrabajoWrapper wrapper =
            new TrabajoController.SubtrabajoWrapper();
        wrapper.id = 'local-' + uniqueCode;
        wrapper.nombre = 'Subtrabajo ' + uniqueCode;
        wrapper.alias = 'Alias ' + uniqueCode;
        wrapper.tipoTrabajo = tipoTrabajoId;
        wrapper.uts = 2;
        return wrapper;
    }

    private static Pricebook2 getOrCreateScenarioPricebook(
        String companyCode,
        String uniqueCode
    ) {
        String pricebookName;
        if (companyCode == 'RMBAVARIAN') {
            pricebookName = 'Bavarian Local';
        } else if (companyCode == 'RMOTOBAI') {
            pricebookName = 'Otobai Local';
        } else if (companyCode == 'RMPEKING') {
            pricebookName = 'PEKING Local';
        } else {
            pricebookName = 'Trabajo WorkOrder ' + uniqueCode;
        }

        List<Pricebook2> existingPricebooks = [
            SELECT Id, Name, IsActive
            FROM Pricebook2
            WHERE Name = :pricebookName
            LIMIT 1
        ];
        if (!existingPricebooks.isEmpty()) {
            return existingPricebooks[0];
        }

        Pricebook2 pricebook = new Pricebook2(
            Name = pricebookName,
            IsActive = true
        );
        insert pricebook;
        return pricebook;
    }

    private static void setHttpMock() {
        Test.setMock(
            HttpCalloutMock.class,
            new TestEtapasTallerv2_PowerBI.MockHttpResponseGenerator()
        );
    }

    private static void ensureStandardPrice(Id productId) {
        Id standardPricebookId = Test.getStandardPricebookId();
        if ([
            SELECT COUNT()
            FROM PricebookEntry
            WHERE Pricebook2Id = :standardPricebookId
              AND Product2Id = :productId
              AND CurrencyIsoCode = 'CRC'
        ] == 0) {
            insert new PricebookEntry(
                Pricebook2Id = standardPricebookId,
                Product2Id = productId,
                UnitPrice = 175,
                IsActive = true,
                CurrencyIsoCode = 'CRC'
            );
        }
    }

    private class CompanyScenario {
        Id caseId;
        Id workOrderId;
        Id trabajoId;
        Id tipoTrabajoId;
        Id laborProductId;
        Id pricebookId;
        Id pricebookEntryId;
    }
}
