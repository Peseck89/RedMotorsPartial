@isTest
public class TrabajoQuoteControllerTest {

    @isTest
    static void testTrabajoQuoteController() {
        // ====== SETUP BÁSICO ======
        Pricebook2 pb = new Pricebook2(Name='Test PB', IsActive=true);
        insert pb;

        Product2 manoObra = new Product2(Name='MO Test', Family='Servicios', tipoProducto__c='Mano de Obra', IsActive=true, Codigo_de_Producto__c='MO29');
        Product2 manoObra2 = new Product2(Name='MO Test 2', Family='Servicios', tipoProducto__c='Mano de Obra', IsActive=true, Codigo_de_Producto__c='MO30');
        insert new List<Product2>{ manoObra, manoObra2 };

        PricebookEntry pbe  = new PricebookEntry(Product2Id=manoObra.Id,  Pricebook2Id=pb.Id, UnitPrice=100, IsActive=true);
        PricebookEntry pbe2 = new PricebookEntry(Product2Id=manoObra2.Id, Pricebook2Id=pb.Id, UnitPrice=150, IsActive=true);
        insert new List<PricebookEntry>{ pbe, pbe2 };

        tiposDeTrabajo__c tipoTrabajo  = new tiposDeTrabajo__c(Name='TT-1', ManoDeObra__c=manoObra.Id,  UTS__c=12);
        tiposDeTrabajo__c tipoTrabajo2 = new tiposDeTrabajo__c(Name='TT-2', ManoDeObra__c=manoObra2.Id, UTS__c=12);
        insert new List<tiposDeTrabajo__c>{ tipoTrabajo, tipoTrabajo2 };

        Opportunity opp = new Opportunity(
            Name='OppTest',
            StageName='Prospecting',
            CloseDate=Date.today(),
            BMW_Compania__c='Bavarian',
            BMW_TipoDeVehiculo__c='Autos'
        );
        insert opp;

        Quote q = new Quote(Name='QuoteTest', OpportunityId=opp.Id, Pricebook2Id=pb.Id);
        insert q;

        // ====== QLIs para diferentes escenarios ======
        // Par padre-hijo para deleteSubtrabajo (mismo TrabajoARealizar/SubTrabajoARealizar)
        QuoteLineItem qliPadre = new QuoteLineItem(
            QuoteId=q.Id, PricebookEntryId=pbe.Id, Product2Id=manoObra.Id, UnitPrice=100,
            Quantity=2, UTS__c=24, Hora__c=2,
            TrabajoARealizar__c=tipoTrabajo.Id, SubTrabajoARealizar__c=tipoTrabajo.Id, Tarea__c=tipoTrabajo.Id,
            SubTrabajoAlias__c='padre'
        );
        QuoteLineItem qliHijo = new QuoteLineItem(
            QuoteId=q.Id, PricebookEntryId=pbe.Id, Product2Id=manoObra.Id, UnitPrice=100,
            Quantity=1, UTS__c=12, HoraSubtrabajo__c=1,
            TrabajoARealizar__c=tipoTrabajo.Id, SubTrabajoARealizar__c=tipoTrabajo.Id, Tarea__c=tipoTrabajo.Id,
            SubTrabajoAlias__c='hijo'
        );
        insert new List<QuoteLineItem>{ qliPadre, qliHijo };

        // Grupo extra para deleteTrabajo (mismo TrabajoARealizar__c)
        QuoteLineItem qliTrabajoGrupo2_A = new QuoteLineItem(
            QuoteId=q.Id, PricebookEntryId=pbe2.Id, Product2Id=manoObra2.Id, UnitPrice=150,
            Quantity=1,
            TrabajoARealizar__c=tipoTrabajo2.Id, SubTrabajoARealizar__c=tipoTrabajo2.Id, Tarea__c=tipoTrabajo2.Id,
            SubTrabajoAlias__c='g2-A'
        );
        QuoteLineItem qliTrabajoGrupo2_B = new QuoteLineItem(
            QuoteId=q.Id, PricebookEntryId=pbe2.Id, Product2Id=manoObra2.Id, UnitPrice=150,
            Quantity=1,
            TrabajoARealizar__c=tipoTrabajo2.Id, SubTrabajoARealizar__c=tipoTrabajo2.Id, Tarea__c=tipoTrabajo2.Id,
            SubTrabajoAlias__c='g2-B'
        );
        insert new List<QuoteLineItem>{ qliTrabajoGrupo2_A, qliTrabajoGrupo2_B };

        Test.startTest();

        // ====== updateTareaPrioridad ======
        Id tareaUpdate = TrabajoQuoteController.updateTareaPrioridad(q.Id, tipoTrabajo.Id, 'Necesario');

        // ====== getTrabajos (para tarea tipoTrabajo.Id) ======
        List<TrabajoQuoteController.TrabajoWrapper> trabajos =
            TrabajoQuoteController.getTrabajos(q.Id, tipoTrabajo.Id);

        // ====== saveTrabajo (crea/actualiza un trabajo) ======
        TrabajoQuoteController.TrabajoWrapper wrapper = new TrabajoQuoteController.TrabajoWrapper();
        wrapper.id = null;
        wrapper.tipoTrabajo = tipoTrabajo.Id;
        wrapper.alias = 'Alias test';
        wrapper.uts = 2;
        wrapper.tipoCargo = 'Cliente';
        wrapper.aprobador = 'Asesor';
        wrapper.prioridad = 'Necesario';
        Id qliCreadoId = TrabajoQuoteController.saveTrabajo(wrapper, q.Id);

        // ====== getUTSTipoTrabajo ======
        Decimal uts = TrabajoQuoteController.getUTSTipoTrabajo(tipoTrabajo.Id);

        // ====== saveSubtrabajos (agrega sub al trabajo creado) ======
        TrabajoQuoteController.SubtrabajoWrapper st = new TrabajoQuoteController.SubtrabajoWrapper();
        st.id = null;
        st.tipoTrabajo = tipoTrabajo.Id; // usa TT-1 (tiene ManoDeObra y PBE válido)
        st.alias = 'ST Alias';
        st.uts = 2;
        List<TrabajoQuoteController.SubtrabajoWrapper> subs = new List<TrabajoQuoteController.SubtrabajoWrapper>{ st };
        TrabajoQuoteController.saveSubtrabajos(tipoTrabajo.Id, qliCreadoId, tipoTrabajo.Id, subs, q.Id, 'Necesario', 'Cliente');

        // ====== deleteSubtrabajo (sobre el hijo del primer grupo) ======
        TrabajoQuoteController.deleteSubtrabajo(qliHijo.Id, q.Id);

        // ====== deleteTrabajo (borra el A y, si aplica, sus "subtrabajos" del grupo 2) ======
        TrabajoQuoteController.deleteTrabajo(qliTrabajoGrupo2_A.Id, q.Id);

        // ====== archivarTarea (con flag de recordatorio) ======
        Id tareaArchivada = TrabajoQuoteController.archivarTarea(q.Id, tipoTrabajo.Id, true);

        Test.stopTest();
    }

    @isTest
    static void lookupBavarianSelectsBavarianLabor() {
        assertCompanyLaborSelection('RMBAVARIAN', true, null, 'RMBAVARIAN', 'TQC-BAV');
    }

    @isTest
    static void lookupOtobaiSelectsOtobaiLabor() {
        assertCompanyLaborSelection('RMOTOBAI', true, null, 'RMOTOBAI', 'TQC-OTO');
    }

    @isTest
    static void lookupPekingSelectsPekingLabor() {
        assertCompanyLaborSelection('RMPEKING', true, null, 'RMPEKING', 'TQC-PEK');
    }

    @isTest
    static void lookupTakesPriorityOverContradictoryPicklist() {
        assertCompanyLaborSelection('RMPEKING', true, 'Bavarian', 'RMPEKING', 'TQC-PRIORITY');
    }

    @isTest
    static void emptyLookupKeepsBavarianLegacyMapping() {
        assertCompanyLaborSelection(null, null, 'Bavarian', 'RMBAVARIAN', 'TQC-LEG-BAV');
    }

    @isTest
    static void emptyLookupKeepsOtobaiLegacyMapping() {
        assertCompanyLaborSelection(null, null, 'Otobai', 'RMOTOBAI', 'TQC-LEG-OTO');
    }

    @isTest
    static void unknownLegacyCompanyDoesNotFallbackToOtobai() {
        // BMW_Compania__c es un picklist restringido: en datos reales de Partial solo admite
        // 'Bavarian'/'Otobai'/null, por lo que insertar 'PEKING' falla con
        // INVALID_OR_NULL_FOR_RESTRICTED_PICKLIST. Se prueba el resolver puro
        // (TrabajoQuoteController.resolveEmpresaLegacy, @TestVisible) directamente con un
        // Opportunity NO insertado (sin DML) para simular un valor legacy no migrado
        // (p. ej. PEKING/Omoda/Jaecoo) sin violar el picklist restringido en base de datos.
        Opportunity opportunity = new Opportunity(BMW_Compania__c = 'PEKING');

        Boolean controlledExceptionThrown = false;
        try {
            TrabajoQuoteController.resolveEmpresaLegacy(opportunity);
        } catch (EmpresaConfigurationException e) {
            controlledExceptionThrown = true;
        }

        System.assert(
            controlledExceptionThrown,
            'Un valor legacy de BMW_Compania__c no mapeado debe producir una EmpresaConfigurationException controlada, nunca RMOTOBAI.'
        );
    }

    @isTest
    static void inactiveLookupReturnsControlledError() {
        ScenarioData scenario = createScenario(
            'RMPEKING',
            false,
            'Bavarian',
            null,
            'TQC-INACTIVE'
        );

        Boolean controlledExceptionThrown = false;
        Test.startTest();
        try {
            TrabajoQuoteController.saveTrabajo(buildWrapper(scenario.tipoTrabajoId), scenario.quoteId);
        } catch (AuraHandledException e) {
            controlledExceptionThrown = true;
        }
        Test.stopTest();

        System.assert(
            controlledExceptionThrown,
            'Una Empresa inactiva debe producir una AuraHandledException.'
        );
        System.assertEquals(
            0,
            [SELECT COUNT() FROM QuoteLineItem WHERE QuoteId = :scenario.quoteId],
            'El error debe producirse antes de crear la línea.'
        );
    }

    @isTest
    static void nullCompanyDoesNotFallbackToOtobai() {
        ScenarioData scenario = createScenario(
            null,
            null,
            null,
            null,
            'TQC-NULL'
        );

        Boolean controlledExceptionThrown = false;
        Test.startTest();
        try {
            TrabajoQuoteController.saveTrabajo(buildWrapper(scenario.tipoTrabajoId), scenario.quoteId);
        } catch (AuraHandledException e) {
            controlledExceptionThrown = true;
        }
        Test.stopTest();

        System.assert(
            controlledExceptionThrown,
            'Una empresa nula debe producir una AuraHandledException.'
        );
        System.assertEquals(
            0,
            [SELECT COUNT() FROM QuoteLineItem WHERE QuoteId = :scenario.quoteId],
            'Una empresa nula no debe crear líneas mediante fallback.'
        );
    }

    private static void assertCompanyLaborSelection(
        String lookupCode,
        Boolean active,
        String legacyCompany,
        String expectedCompanyCode,
        String uniqueCode
    ) {
        ScenarioData scenario = createScenario(
            lookupCode,
            active,
            legacyCompany,
            expectedCompanyCode,
            uniqueCode
        );

        Test.startTest();
        Id quoteLineItemId = TrabajoQuoteController.saveTrabajo(
            buildWrapper(scenario.tipoTrabajoId),
            scenario.quoteId
        );
        Test.stopTest();

        QuoteLineItem createdLine = [
            SELECT Product2Id, PricebookEntryId, PricebookEntry.Pricebook2Id,
                   Quantity, UnitPrice
            FROM QuoteLineItem
            WHERE Id = :quoteLineItemId
        ];
        System.assertEquals(scenario.productId, createdLine.Product2Id);
        System.assertEquals(scenario.pricebookEntryId, createdLine.PricebookEntryId);
        System.assertEquals(scenario.pricebookId, createdLine.PricebookEntry.Pricebook2Id);
        System.assertEquals(2, createdLine.Quantity);
        System.assertEquals(175, createdLine.UnitPrice);
    }

    private static ScenarioData createScenario(
        String lookupCode,
        Boolean active,
        String legacyCompany,
        String mappingCompanyCode,
        String uniqueCode
    ) {
        Pricebook2 pricebook = new Pricebook2(
            Name = 'Trabajo Quote ' + uniqueCode,
            IsActive = true
        );
        insert pricebook;

        Product2 laborProduct = new Product2(
            Name = 'Mano de obra ' + uniqueCode,
            Family = 'Servicios',
            tipoProducto__c = 'Mano de Obra',
            IsActive = true,
            ProductCode = uniqueCode,
            Codigo_de_Producto__c = uniqueCode
        );
        insert laborProduct;
        ensureStandardPrice(laborProduct.Id);

        PricebookEntry laborEntry = new PricebookEntry(
            Product2Id = laborProduct.Id,
            Pricebook2Id = pricebook.Id,
            UnitPrice = 175,
            IsActive = true
        );
        insert laborEntry;

        tiposDeTrabajo__c workType = new tiposDeTrabajo__c(
            Name = 'Tipo ' + uniqueCode,
            UTS__c = 12
        );
        insert workType;

        if (mappingCompanyCode != null) {
            insert new TipoDeCargoConManoDeObra__c(
                Empresa__c = mappingCompanyCode,
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

        Opportunity opportunity = new Opportunity(
            Name = 'Opportunity ' + uniqueCode,
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            BMW_Compania__c = legacyCompany,
            BMW_TipoDeVehiculo__c = 'Autos',
            Empresa_Operadora__c = companyId
        );
        insert opportunity;

        Quote quoteRecord = new Quote(
            Name = 'Quote ' + uniqueCode,
            OpportunityId = opportunity.Id,
            Pricebook2Id = pricebook.Id
        );
        insert quoteRecord;

        ScenarioData scenario = new ScenarioData();
        scenario.quoteId = quoteRecord.Id;
        scenario.tipoTrabajoId = workType.Id;
        scenario.productId = laborProduct.Id;
        scenario.pricebookEntryId = laborEntry.Id;
        scenario.pricebookId = pricebook.Id;
        return scenario;
    }

    private static TrabajoQuoteController.TrabajoWrapper buildWrapper(Id workTypeId) {
        TrabajoQuoteController.TrabajoWrapper wrapper =
            new TrabajoQuoteController.TrabajoWrapper();
        wrapper.id = null;
        wrapper.tipoTrabajo = workTypeId;
        wrapper.alias = 'Alias empresa';
        wrapper.uts = 2;
        wrapper.tipoCargo = 'Cliente';
        wrapper.aprobador = 'Asesor';
        wrapper.prioridad = 'Necesario';
        return wrapper;
    }

    private static void ensureStandardPrice(Id productId) {
        Id standardPricebookId = Test.getStandardPricebookId();
        List<PricebookEntry> standardEntries = [
            SELECT Id
            FROM PricebookEntry
            WHERE Pricebook2Id = :standardPricebookId
              AND Product2Id = :productId
        ];
        if (standardEntries.isEmpty()) {
            insert new PricebookEntry(
                Product2Id = productId,
                Pricebook2Id = standardPricebookId,
                UnitPrice = 175,
                IsActive = true
            );
        }
    }

    private class ScenarioData {
        Id quoteId;
        Id tipoTrabajoId;
        Id productId;
        Id pricebookEntryId;
        Id pricebookId;
    }
}
