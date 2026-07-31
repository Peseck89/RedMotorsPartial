@isTest(SeeAllData=false)
public class WorkOrderTriggerTest {
    private static final String INITIAL_PRICEBOOK = 'WO Precio inicial';

    @testSetup
    static void setupConfiguration() {
        // Empresa__c primero: el trigger ahora resuelve Pricebook2Id vía Pricebook2.Empresa__c +
        // CurrencyIsoCode + IsActive (EmpresaPricebookResolver), no por Name (remediación
        // hallazgo Luis #9, 2026-07-31). RMUNKNOWN queda sin Pricebooks asociados a propósito
        // (escenario "cero opciones"). RMMULTI queda con 2 Pricebooks activos en la misma moneda
        // a propósito (escenario "múltiples opciones" / SELECCION_REQUERIDA).
        List<Empresa__c> empresas = new List<Empresa__c>{
            createEmpresa('RMBAVARIAN'),
            createEmpresa('RMOTOBAI'),
            createEmpresa('RMPEKING'),
            createEmpresa('RMUNKNOWN'),
            createEmpresa('RMMULTI')
        };
        insert empresas;

        Map<String, Id> empresaIdByCodigo = new Map<String, Id>();
        for (Empresa__c empresa : empresas) {
            empresaIdByCodigo.put(empresa.Codigo__c, empresa.Id);
        }

        insert new List<Pricebook2>{
            new Pricebook2(Name = 'Bavarian Local', IsActive = true, CurrencyIsoCode = 'CRC', Empresa__c = empresaIdByCodigo.get('RMBAVARIAN')),
            new Pricebook2(Name = 'Bavarian Dólar', IsActive = true, CurrencyIsoCode = 'USD', Empresa__c = empresaIdByCodigo.get('RMBAVARIAN')),
            new Pricebook2(Name = 'Otobai Local', IsActive = true, CurrencyIsoCode = 'CRC', Empresa__c = empresaIdByCodigo.get('RMOTOBAI')),
            new Pricebook2(Name = 'Otobai Dólares', IsActive = true, CurrencyIsoCode = 'USD', Empresa__c = empresaIdByCodigo.get('RMOTOBAI')),
            new Pricebook2(Name = 'PEKING Local', IsActive = true, CurrencyIsoCode = 'CRC', Empresa__c = empresaIdByCodigo.get('RMPEKING')),
            new Pricebook2(Name = 'PEKING Dólares', IsActive = true, CurrencyIsoCode = 'USD', Empresa__c = empresaIdByCodigo.get('RMPEKING')),
            new Pricebook2(Name = 'Multi Opcion A', IsActive = true, CurrencyIsoCode = 'USD', Empresa__c = empresaIdByCodigo.get('RMMULTI')),
            new Pricebook2(Name = 'Multi Opcion B', IsActive = true, CurrencyIsoCode = 'USD', Empresa__c = empresaIdByCodigo.get('RMMULTI')),
            new Pricebook2(Name = INITIAL_PRICEBOOK, IsActive = true)
        };
    }

    @isTest
    static void selectsBavarianLocalOnInsert() {
        assertLookupSelection('RMBAVARIAN', 'CRC', 'Bavarian Local');
    }

    @isTest
    static void selectsBavarianDolarOnInsert() {
        assertLookupSelection('RMBAVARIAN', 'USD', 'Bavarian Dólar');
    }

    @isTest
    static void selectsOtobaiLocalOnInsert() {
        assertLookupSelection('RMOTOBAI', 'CRC', 'Otobai Local');
    }

    @isTest
    static void selectsOtobaiDolaresOnInsert() {
        assertLookupSelection('RMOTOBAI', 'USD', 'Otobai Dólares');
    }

    @isTest
    static void selectsPekingLocalOnInsert() {
        assertLookupSelection('RMPEKING', 'CRC', 'PEKING Local');
    }

    @isTest
    static void selectsPekingDolaresOnInsert() {
        assertLookupSelection('RMPEKING', 'USD', 'PEKING Dólares');
    }

    @isTest
    static void lookupTakesPrecedenceOverLegacyPicklist() {
        WorkOrder workOrder = baseWorkOrder('WO precedencia lookup', 'CRC');
        workOrder.empresaFacturaCP__c = getEmpresaId('RMPEKING');
        workOrder.empresaFactura__c = 'RMBAVARIAN';

        Test.startTest();
        insert workOrder;
        Test.stopTest();

        assertStoredPricebook(workOrder.Id, 'PEKING Local');
    }

    @isTest
    static void emptyLookupUsesLegacyPicklist() {
        WorkOrder workOrder = baseWorkOrder(
            'WO compatibilidad heredada',
            'USD'
        );
        workOrder.empresaFacturaCP__c = null;
        workOrder.empresaFactura__c = 'RMOTOBAI';

        Test.startTest();
        insert workOrder;
        Test.stopTest();

        assertStoredPricebook(workOrder.Id, 'Otobai Dólares');
    }

    @isTest
    static void bothCompanyFieldsEmptyPreservePricebook() {
        assertPricebookPreserved(null, null, 'CRC');
    }

    // "Cero opciones": RMUNKNOWN no tiene ningún Pricebook2.Empresa__c asociado -> resolver
    // devuelve NO_CONFIGURADO -> el trigger no elige nada, conserva el Pricebook existente.
    @isTest
    static void unknownLookupCodeDoesNotFallbackToPicklist() {
        assertPricebookPreserved('RMUNKNOWN', 'RMBAVARIAN', 'CRC');
    }

    // "Múltiples opciones": RMMULTI tiene 2 Pricebooks activos en la misma moneda (USD) ->
    // resolver devuelve SELECCION_REQUERIDA -> el trigger no elige arbitrariamente entre los 2,
    // conserva el Pricebook existente (no hay pantalla en este contexto para pedir selección).
    @isTest
    static void multipleValidPricebooksDoesNotChooseArbitrarily() {
        assertPricebookPreserved('RMMULTI', null, 'USD');
    }

    @isTest
    static void usesDefaultUsdWhenCurrencyIsOmitted() {
        assertLookupSelection('RMBAVARIAN', null, 'Bavarian Dólar');
    }

    @isTest
    static void selectsPekingDolaresOnUpdate() {
        WorkOrder workOrder = baseWorkOrder('WO selección update', 'USD');
        workOrder.empresaFacturaCP__c = null;
        workOrder.empresaFactura__c = null;
        insert workOrder;

        workOrder.empresaFacturaCP__c = getEmpresaId('RMPEKING');
        Test.startTest();
        update workOrder;
        Test.stopTest();

        assertStoredPricebook(workOrder.Id, 'PEKING Dólares');
    }

    @isTest
    static void selectsPricebooksInBulk() {
        Map<String, Id> expectedPricebooks = getPricebooksByCombination();
        Map<String, Id> empresaIds = getEmpresaIdsByCodigo();
        List<String> combinations = new List<String>(
            expectedPricebooks.keySet()
        );
        Id initialPricebookId = getPricebookId(INITIAL_PRICEBOOK);
        List<WorkOrder> workOrders = new List<WorkOrder>();
        for (Integer index = 0; index < 200; index++) {
            List<String> values = combinations[
                Math.mod(index, combinations.size())
            ].split('-');
            workOrders.add(new WorkOrder(
                Subject = 'WO bulk ' + index,
                Pricebook2Id = initialPricebookId,
                tipoDeGasto__c = 'Cliente',
                empresaFacturaCP__c = empresaIds.get(values[0]),
                empresaFactura__c = null,
                CurrencyIsoCode = values[1]
            ));
        }

        Test.startTest();
        insert workOrders;
        Test.stopTest();

        Set<Id> workOrderIds = new Map<Id, WorkOrder>(workOrders).keySet();
        List<WorkOrder> storedWorkOrders = [
            SELECT Pricebook2Id, empresaFacturaCP__r.Codigo__c,
                CurrencyIsoCode
            FROM WorkOrder
            WHERE Id IN :workOrderIds
        ];
        System.assertEquals(200, storedWorkOrders.size());
        for (WorkOrder storedWorkOrder : storedWorkOrders) {
            String combination =
                storedWorkOrder.empresaFacturaCP__r.Codigo__c + '-' +
                storedWorkOrder.CurrencyIsoCode;
            System.assertEquals(
                expectedPricebooks.get(combination),
                storedWorkOrder.Pricebook2Id,
                'Pricebook incorrecto para ' + combination
            );
        }
    }

    @isTest
    static void updatesHistoricalFacturationState() {
        WorkOrder workOrder = baseWorkOrder(
            'WO actualización histórica',
            'CRC'
        );
        workOrder.empresaFacturaCP__c = null;
        workOrder.empresaFactura__c = null;
        insert workOrder;

        Account account = new Account(
            Name = 'Cuenta facturación histórica',
            Cedula__c = '9876543210',
            Tipo_de_Documento__c = '02'
        );
        insert account;

        workOrder.Etapa_de_flujo_de_trabajo__c = 'Facturada';
        workOrder.AccountId = account.Id;
        workOrder.Realizar_encuesta__c = 'Si';
        workOrder.SyncSoftlandFlag__c = true;
        workOrder.tipoDeGasto__c = 'BCI';

        Test.startTest();
        update workOrder;
        Test.stopTest();

        WorkOrder storedWorkOrder = [
            SELECT Etapa_de_flujo_de_trabajo__c, AccountId,
                tipoDeGasto__c
            FROM WorkOrder
            WHERE Id = :workOrder.Id
        ];
        System.assertEquals(
            'Facturada',
            storedWorkOrder.Etapa_de_flujo_de_trabajo__c
        );
        System.assertEquals(account.Id, storedWorkOrder.AccountId);
        System.assertEquals('BCI', storedWorkOrder.tipoDeGasto__c);
    }

    @isTest
    static void updatesWorkOrderWithSingleLine() {
        WorkOrder workOrder = baseWorkOrder('WO con una línea', 'CRC');
        workOrder.empresaFacturaCP__c = null;
        workOrder.empresaFactura__c = null;
        insert workOrder;

        Product2 product = new Product2(
            Name = 'Producto WO línea única',
            ProductCode = 'WO-LINE-ONE',
            Codigo_de_Producto__c = 'WO-LINE-ONE',
            IsActive = true
        );
        insert product;
        PricebookEntry entry = createPricebookEntryForWorkOrder(
            product.Id,
            workOrder.Pricebook2Id,
            'CRC'
        );
        WorkOrderLineItem line = new WorkOrderLineItem(
            WorkOrderId = workOrder.Id,
            Description = 'Línea mínima',
            Quantity = 1,
            PricebookEntryId = entry.Id
        );
        insert line;

        workOrder.tipoDeGasto__c = 'BCI';
        Test.startTest();
        update workOrder;
        Test.stopTest();

        System.assertEquals(
            1,
            [SELECT COUNT() FROM WorkOrderLineItem
             WHERE WorkOrderId = :workOrder.Id]
        );
        System.assertEquals(
            'BCI',
            [SELECT tipoDeGasto__c FROM WorkOrder
             WHERE Id = :workOrder.Id].tipoDeGasto__c
        );
    }

    @isTest
    static void allowsCancellationWithoutInvoicedLines() {
        WorkOrder workOrder = baseWorkOrder(
            'WO anulación sin facturación',
            'CRC'
        );
        workOrder.empresaFacturaCP__c = null;
        workOrder.empresaFactura__c = null;
        insert workOrder;
        workOrder.Etapa_de_flujo_de_trabajo__c = 'Anulado';

        Test.startTest();
        update workOrder;
        Test.stopTest();

        System.assertEquals(
            'Anulado',
            [SELECT Etapa_de_flujo_de_trabajo__c FROM WorkOrder
             WHERE Id = :workOrder.Id].Etapa_de_flujo_de_trabajo__c
        );
    }

    @isTest
    static void unlockRestoresProcessStage() {
        WorkOrder workOrder = baseWorkOrder('WO para desbloquear', 'CRC');
        workOrder.empresaFacturaCP__c = null;
        workOrder.empresaFactura__c = null;
        workOrder.isLocked__c = true;
        workOrder.Etapa_de_flujo_de_trabajo__c = 'Listo';
        insert workOrder;

        workOrder.isLocked__c = false;
        Test.startTest();
        update workOrder;
        Test.stopTest();

        WorkOrder storedWorkOrder = [
            SELECT isLocked__c, Etapa_de_flujo_de_trabajo__c
            FROM WorkOrder
            WHERE Id = :workOrder.Id
        ];
        System.assertEquals(false, storedWorkOrder.isLocked__c);
        System.assertEquals(
            'Proceso',
            storedWorkOrder.Etapa_de_flujo_de_trabajo__c
        );
    }

    @isTest
    static void rejectsCancellationWithInvoicedLine() {
        WorkOrder workOrder = baseWorkOrder(
            'WO anulación con línea facturada',
            'CRC'
        );
        workOrder.empresaFacturaCP__c = null;
        workOrder.empresaFactura__c = null;
        insert workOrder;
        createSingleLine(workOrder, 'WO-CANCEL-FACT', 'Facturado');

        workOrder.Etapa_de_flujo_de_trabajo__c = 'Anulado';
        Test.startTest();
        Database.SaveResult result = Database.update(workOrder, false);
        Test.stopTest();

        System.assertEquals(false, result.isSuccess());
        System.assert(
            result.getErrors()[0].getMessage().contains(
                'líneas facturadas'
            ),
            result.getErrors()[0].getMessage()
        );
        System.assertNotEquals(
            'Anulado',
            [SELECT Etapa_de_flujo_de_trabajo__c FROM WorkOrder
             WHERE Id = :workOrder.Id].Etapa_de_flujo_de_trabajo__c
        );
    }

    @isTest
    static void updatesTipoCargoForBciExpense() {
        WorkOrder workOrder = baseWorkOrder('WO actualiza tipo cargo', 'CRC');
        workOrder.empresaFacturaCP__c = null;
        workOrder.empresaFactura__c = null;
        insert workOrder;
        WorkOrderLineItem line = createSingleLine(
            workOrder,
            'WO-TIPO-CARGO',
            null
        );
        prepareCargoForLine(line.Id);

        workOrder.tipoDeGasto__c = 'BCI';
        Test.startTest();
        update workOrder;
        Test.stopTest();

        assertCargoMapping(line.Id, '5', null, null);
    }

    @isTest
    static void updatesTipoCargoForClientExpense() {
        assertTipoCargoMapping(
            'BCI',
            'Cliente',
            '1',
            null,
            null,
            'WO-CARGO-CLIENT'
        );
    }

    @isTest
    static void updatesTipoCargoForWarrantyExpense() {
        assertTipoCargoMapping(
            'Cliente',
            'Garantia',
            '4',
            null,
            null,
            'WO-CARGO-WARRANTY'
        );
    }

    @isTest
    static void updatesTipoCargoForBsiInternalExpense() {
        assertTipoCargoMapping(
            'Cliente',
            'BSI Interno',
            '6',
            null,
            null,
            'WO-CARGO-BSI'
        );
    }

    @isTest
    static void updatesTipoCargoForInsurerExpense() {
        Account insurer = new Account(
            Name = 'Aseguradora prueba tipo cargo',
            Cedula__c = '9876543211',
            Tipo_de_Documento__c = '02'
        );
        insert insurer;
        assertTipoCargoMapping(
            'Cliente',
            'Aseguradora',
            '3',
            insurer.Id,
            null,
            'WO-CARGO-INSURER'
        );
    }

    @isTest
    static void updatesTipoCargoForInternalExpense() {
        CentroCosto__c costCenter = new CentroCosto__c();
        insert costCenter;
        assertTipoCargoMapping(
            'Cliente',
            'Interno',
            '2',
            null,
            costCenter.Id,
            'WO-CARGO-INTERNAL'
        );
    }

    @isTest
    static void budgetRequestCreatesCommunityUser() {
        String uniqueEmail =
            'wo-budget-' + DateTime.now().getTime() + '@example.test';
        Account account = new Account(Name = 'Cuenta presupuesto portal');
        insert account;
        Contact contact = new Contact(
            AccountId = account.Id,
            FirstName = 'Cliente',
            LastName = 'Presupuesto',
            Email = uniqueEmail
        );
        insert contact;
        WorkOrder workOrder = baseWorkOrder(
            'WO envío presupuesto',
            'USD'
        );
        workOrder.empresaFacturaCP__c = null;
        workOrder.empresaFactura__c = null;
        workOrder.ContactId = contact.Id;
        workOrder.Enviar_presupuesto_a_service__c = false;
        insert workOrder;

        workOrder.Enviar_presupuesto_a_service__c = true;
        Test.startTest();
        update workOrder;
        Test.stopTest();

        WorkOrder storedWorkOrder = [
            SELECT Enviar_presupuesto_a_service__c, ContactId
            FROM WorkOrder
            WHERE Id = :workOrder.Id
        ];
        System.assertEquals(
            true,
            storedWorkOrder.Enviar_presupuesto_a_service__c
        );
        System.assertEquals(contact.Id, storedWorkOrder.ContactId);
        List<User> createdUsers = [
            SELECT ContactId, Username, Email, FirstName, LastName
            FROM User
            WHERE ContactId = :contact.Id
        ];
        System.assertEquals(1, createdUsers.size());
        System.assertEquals(contact.Id, createdUsers[0].ContactId);
        System.assertEquals(uniqueEmail, createdUsers[0].Username);
        System.assertEquals(uniqueEmail, createdUsers[0].Email);
        System.assertEquals('Cliente', createdUsers[0].FirstName);
        System.assertEquals('Presupuesto', createdUsers[0].LastName);

        List<Peticion_de_envio__c> createdPetitions = [
            SELECT Email__c, First_Name__c, Last_Name__c
            FROM Peticion_de_envio__c
            WHERE Email__c = :uniqueEmail
        ];
        System.assertEquals(1, createdPetitions.size());
        System.assertEquals(uniqueEmail, createdPetitions[0].Email__c);
        System.assertEquals('Cliente', createdPetitions[0].First_Name__c);
        System.assertEquals(
            'Presupuesto',
            createdPetitions[0].Last_Name__c
        );
    }

    private static void assertTipoCargoMapping(
        String initialExpense,
        String targetExpense,
        String expectedCargoCode,
        Id insurerId,
        Id costCenterId,
        String productCode
    ) {
        WorkOrder workOrder = baseWorkOrder(
            'WO mapeo ' + targetExpense,
            'CRC'
        );
        workOrder.empresaFacturaCP__c = null;
        workOrder.empresaFactura__c = null;
        workOrder.tipoDeGasto__c = initialExpense;
        insert workOrder;
        WorkOrderLineItem line = createSingleLine(
            workOrder,
            productCode,
            null
        );
        prepareCargoForLine(line.Id);

        workOrder.tipoDeGasto__c = targetExpense;
        workOrder.BMW_Aseguradora__c = insurerId;
        workOrder.BMW_CentroDeCosto__c = costCenterId;
        Test.startTest();
        update workOrder;
        Test.stopTest();

        assertCargoMapping(
            line.Id,
            expectedCargoCode,
            insurerId,
            costCenterId
        );
    }

    private static tipoCargo__c prepareCargoForLine(Id lineId) {
        List<tipoCargo__c> cargos = [
            SELECT Id, tipoCargo__c, porcentaje__c
            FROM tipoCargo__c
            WHERE Work_Order_Line_Item__c = :lineId
            ORDER BY CreatedDate
        ];
        if (cargos.isEmpty()) {
            tipoCargo__c cargo = new tipoCargo__c(
                Work_Order_Line_Item__c = lineId,
                tipoCargo__c = '1',
                porcentaje__c = 100
            );
            insert cargo;
            cargos.add(cargo);
        }

        Decimal totalPercentage = 0;
        for (tipoCargo__c cargo : cargos) {
            totalPercentage += cargo.porcentaje__c == null
                ? 0
                : cargo.porcentaje__c;
        }
        System.assert(
            totalPercentage <= 100,
            'La suma de porcentajes debe ser menor o igual a 100'
        );
        return cargos[0];
    }

    private static void assertCargoMapping(
        Id lineId,
        String expectedCargoCode,
        Id expectedClientId,
        Id expectedCostCenterId
    ) {
        List<tipoCargo__c> cargos = [
            SELECT tipoCargo__c, Cliente__c, centroCosto__c, porcentaje__c
            FROM tipoCargo__c
            WHERE Work_Order_Line_Item__c = :lineId
        ];
        System.assert(!cargos.isEmpty(), 'Debe existir al menos un cargo');
        Decimal totalPercentage = 0;
        for (tipoCargo__c cargo : cargos) {
            System.assertEquals(expectedCargoCode, cargo.tipoCargo__c);
            System.assertEquals(expectedClientId, cargo.Cliente__c);
            System.assertEquals(expectedCostCenterId, cargo.centroCosto__c);
            totalPercentage += cargo.porcentaje__c == null
                ? 0
                : cargo.porcentaje__c;
        }
        System.assert(
            totalPercentage <= 100,
            'La suma de porcentajes debe ser menor o igual a 100'
        );
    }

    private static void assertLookupSelection(
        String companyCode,
        String currencyIsoCode,
        String expectedPricebookName
    ) {
        WorkOrder workOrder = baseWorkOrder(
            'WO ' + companyCode + ' ' + currencyIsoCode,
            currencyIsoCode
        );
        workOrder.empresaFacturaCP__c = getEmpresaId(companyCode);
        workOrder.empresaFactura__c = null;

        Test.startTest();
        insert workOrder;
        Test.stopTest();

        assertStoredPricebook(workOrder.Id, expectedPricebookName);
    }

    private static void assertPricebookPreserved(
        String lookupCompanyCode,
        String legacyCompanyCode,
        String currencyIsoCode
    ) {
        Id initialPricebookId = getPricebookId(INITIAL_PRICEBOOK);
        WorkOrder workOrder = baseWorkOrder(
            'WO conserva Pricebook',
            currencyIsoCode
        );
        workOrder.empresaFacturaCP__c = lookupCompanyCode == null
            ? null
            : getEmpresaId(lookupCompanyCode);
        workOrder.empresaFactura__c = legacyCompanyCode;

        Test.startTest();
        insert workOrder;
        Test.stopTest();

        System.assertEquals(
            initialPricebookId,
            [SELECT Pricebook2Id FROM WorkOrder WHERE Id = :workOrder.Id]
                .Pricebook2Id
        );
    }

    private static WorkOrder baseWorkOrder(
        String subject,
        String currencyIsoCode
    ) {
        return new WorkOrder(
            Subject = subject,
            Pricebook2Id = getPricebookId(INITIAL_PRICEBOOK),
            tipoDeGasto__c = 'Cliente',
            CurrencyIsoCode = currencyIsoCode
        );
    }

    private static Empresa__c createEmpresa(String codigo) {
        return new Empresa__c(
            Name = 'Empresa ' + codigo,
            Codigo__c = codigo,
            Codigo_ERP__c = codigo,
            Nombre_Legal__c = 'Empresa ' + codigo,
            Activa__c = true
        );
    }

    private static Id getEmpresaId(String codigo) {
        return [
            SELECT Id
            FROM Empresa__c
            WHERE Codigo__c = :codigo
            LIMIT 1
        ].Id;
    }

    private static Map<String, Id> getEmpresaIdsByCodigo() {
        Map<String, Id> result = new Map<String, Id>();
        for (Empresa__c empresa : [
            SELECT Id, Codigo__c
            FROM Empresa__c
            WHERE Codigo__c IN (
                'RMBAVARIAN',
                'RMOTOBAI',
                'RMPEKING'
            )
        ]) {
            result.put(empresa.Codigo__c, empresa.Id);
        }
        return result;
    }

    private static Id getPricebookId(String pricebookName) {
        return [
            SELECT Id
            FROM Pricebook2
            WHERE Name = :pricebookName
            LIMIT 1
        ].Id;
    }

    private static Map<String, Id> getPricebooksByCombination() {
        Map<String, Id> pricebooksByName = new Map<String, Id>();
        for (Pricebook2 pricebook : [
            SELECT Id, Name
            FROM Pricebook2
            WHERE Name IN (
                'Bavarian Local',
                'Bavarian Dólar',
                'Otobai Local',
                'Otobai Dólares',
                'PEKING Local',
                'PEKING Dólares'
            )
        ]) {
            pricebooksByName.put(pricebook.Name, pricebook.Id);
        }
        return new Map<String, Id>{
            'RMBAVARIAN-CRC' => pricebooksByName.get('Bavarian Local'),
            'RMBAVARIAN-USD' => pricebooksByName.get('Bavarian Dólar'),
            'RMOTOBAI-CRC' => pricebooksByName.get('Otobai Local'),
            'RMOTOBAI-USD' => pricebooksByName.get('Otobai Dólares'),
            'RMPEKING-CRC' => pricebooksByName.get('PEKING Local'),
            'RMPEKING-USD' => pricebooksByName.get('PEKING Dólares')
        };
    }

    private static void assertStoredPricebook(
        Id workOrderId,
        String expectedPricebookName
    ) {
        System.assertEquals(
            getPricebookId(expectedPricebookName),
            [SELECT Pricebook2Id FROM WorkOrder WHERE Id = :workOrderId]
                .Pricebook2Id
        );
    }

    private static PricebookEntry createPricebookEntryForWorkOrder(
        Id productId,
        Id workOrderPricebookId,
        String currencyIsoCode
    ) {
        Id standardPricebookId = Test.getStandardPricebookId();
        Set<Id> pricebookIds = new Set<Id>{
            standardPricebookId,
            workOrderPricebookId
        };
        Map<String, PricebookEntry> entriesByKey =
            new Map<String, PricebookEntry>();
        for (PricebookEntry entry : [
            SELECT Id, Pricebook2Id, Product2Id, CurrencyIsoCode
            FROM PricebookEntry
            WHERE Product2Id = :productId
            AND Pricebook2Id IN :pricebookIds
            AND CurrencyIsoCode = :currencyIsoCode
        ]) {
            entriesByKey.put(
                pricebookEntryKey(entry.Pricebook2Id, entry.CurrencyIsoCode),
                entry
            );
        }

        String standardKey = pricebookEntryKey(
            standardPricebookId,
            currencyIsoCode
        );
        if (!entriesByKey.containsKey(standardKey)) {
            PricebookEntry standardEntry = new PricebookEntry(
                Pricebook2Id = standardPricebookId,
                Product2Id = productId,
                UnitPrice = 1000,
                IsActive = true,
                CurrencyIsoCode = currencyIsoCode
            );
            insert standardEntry;
            entriesByKey.put(standardKey, standardEntry);
        }

        String workOrderKey = pricebookEntryKey(
            workOrderPricebookId,
            currencyIsoCode
        );
        if (!entriesByKey.containsKey(workOrderKey)) {
            PricebookEntry workOrderEntry = new PricebookEntry(
                Pricebook2Id = workOrderPricebookId,
                Product2Id = productId,
                UnitPrice = 1000,
                IsActive = true,
                UseStandardPrice = false,
                CurrencyIsoCode = currencyIsoCode
            );
            insert workOrderEntry;
            entriesByKey.put(workOrderKey, workOrderEntry);
        }
        return entriesByKey.get(workOrderKey);
    }

    private static WorkOrderLineItem createSingleLine(
        WorkOrder workOrder,
        String productCode,
        String lineStatus
    ) {
        Product2 product = new Product2(
            Name = 'Producto ' + productCode,
            ProductCode = productCode,
            Codigo_de_Producto__c = productCode,
            IsActive = true
        );
        insert product;
        PricebookEntry entry = createPricebookEntryForWorkOrder(
            product.Id,
            workOrder.Pricebook2Id,
            workOrder.CurrencyIsoCode
        );
        WorkOrderLineItem line = new WorkOrderLineItem(
            WorkOrderId = workOrder.Id,
            Description = 'Línea ' + productCode,
            Quantity = 1,
            PricebookEntryId = entry.Id,
            Estado__c = lineStatus
        );
        insert line;
        return line;
    }

    private static String pricebookEntryKey(
        Id pricebookId,
        String currencyIsoCode
    ) {
        return String.valueOf(pricebookId) + '|' + currencyIsoCode;
    }
}
