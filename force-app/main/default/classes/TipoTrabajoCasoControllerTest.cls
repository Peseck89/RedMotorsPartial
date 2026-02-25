@isTest(SeeAllData=false)
public class TipoTrabajoCasoControllerTest {
    @TestSetup
    static void makeData(){
        // Crear datos básicos necesarios para todas las pruebas
        Account acc = new Account(
            Name = 'Test Account',
            Cedula__c = '987654321',
            Tipo_de_Documento__c = '02'
        );
        insert acc;
        
        // Crear impuesto requerido
        Impuesto__c impuesto = new Impuesto__c(
            codigoImpuesto__c = '0108',
            descripcion__c = 'test desc',
            Impuesto__c = 2,
            Name = 'test imp',
            porcentaje__c = 3
        );
        insert impuesto;
        
        // Crear condición de pago
        condicionPago__c condicionPago = new condicionPago__c(
            condicionPago__c = '0',
            Descripcion__c = 'test desc',
            Name = 'CONTADO'
        );
        insert condicionPago;
        
        // Actualizar cuenta con referencias
        acc.condicionPago__c = condicionPago.Id;
        acc.Impuesto__c = impuesto.Id;
        update acc;
        
        // Crear caso
        Case casito = new Case(
            Description = 'Test',
            Subject = 'Test',
            AccountId = acc.Id
        );
        insert casito;
        
        // Crear tipo de trabajo
        tiposDeTrabajo__c tdt = new tiposDeTrabajo__c(Name = 'Mano de Obra');
        insert tdt;
        
        // Crear producto
        Product2 prod = new Product2(
            IsActive = true,
            Name = 'Test product',
            ProductCode = '00012',
            Codigo_de_Producto__c = '0012'
        );
        insert prod;
        
        // Crear centro de costo
        CentroCosto__c cc = new CentroCosto__c();
        insert cc;
        
        // Crear orden de trabajo
        WorkOrder wo = new WorkOrder(
            subject = 'title',
            Pricebook2Id = Test.getStandardPricebookId(),
            tipoDeGasto__c = 'Cliente',
            CurrencyIsoCode = 'CRC',
            CaseId = casito.Id,
            AccountId = acc.Id
        );
        insert wo;
        
        // Crear entrada de lista de precios
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = prod.Id,
            UnitPrice = 1,
            IsActive = true,
            UseStandardPrice = false
        );
        //insert standardPrice;
        
        // Crear tipo de trabajo de caso
        tiposDeTrabajoCaso__c ttc = new tiposDeTrabajoCaso__c(
            Caso__c = casito.Id,
            RM_WorkOrder__c = wo.Id,
            Tipotrabajo__c = tdt.Id,
            Tipo_de_cargo__c = 'Cliente'
        );
        insert ttc;
        Test.setMock(HttpCalloutMock.class, new TestEtapasTallerv2_PowerBI.MockHttpResponseGenerator());
    }
    
    @IsTest
    static void test_InsertTipoDelCasoDeTrabajo() {

        // Obtener datos existentes
        tiposDeTrabajoCaso__c ttc = [SELECT Id, Caso__c, RM_WorkOrder__c, Tipotrabajo__c 
                                     FROM tiposDeTrabajoCaso__c LIMIT 1];
        
        // Verificar que tenemos datos para la prueba
        System.assertNotEquals(null, ttc, 'No se encontró un tipo de trabajo de caso creado en el TestSetup');
        
        Test.startTest();
        // Llamada al método con todos los parámetros requeridos
        tiposDeTrabajoCaso__c newTTC = TipoTrabajoCasoController.insertTipoDelCasoDeTrabajo(
            ttc.Caso__c,
            ttc.RM_WorkOrder__c,
            null,
            null,
            'Cliente',
            'Sugerido',
            'Test',
            ttc.Tipotrabajo__c,
            'Cliente',
            'Recomendado'
        );
        Test.stopTest();
        
        // Verificaciones
        System.assertNotEquals(null, newTTC, 'El método no devolvió un registro creado');
        System.assertEquals(ttc.Caso__c, newTTC.Caso__c, 'El caso no coincide');
        
        // Otras pruebas relacionadas
        List<WorkOrder> workOrders = TipoTrabajoCasoController.getWorkOrders(ttc.Caso__c);
        System.assert(!workOrders.isEmpty(), 'No se encontraron órdenes de trabajo para el caso');
        
        String workOrderId = TipoTrabajoCasoController.getWorkOrder(ttc.Id);
        System.assertNotEquals(null, workOrderId, 'No se encontró la orden de trabajo');
        
        tiposDeTrabajoCaso__c trabajo = TipoTrabajoCasoController.getTipoTrabajo(ttc.Id);
        System.assertNotEquals(null, trabajo, 'No se encontró el tipo de trabajo');
        
        Map<String, Object> aseguradoraInfo = TipoTrabajoCasoController.getAseguradora(ttc.Id);
        System.assertNotEquals(null, aseguradoraInfo, 'No se obtuvo información de aseguradora');
        
        Id existingWorkOrderId = TipoTrabajoCasoController.existsWorkOrder(ttc.Caso__c);
        System.assertNotEquals(null, existingWorkOrderId, 'No se encontró orden de trabajo existente');
    }
    
    @IsTest
    static void test_SaveWorkLineItems() {
        // Obtener datos existentes
        tiposDeTrabajoCaso__c ttc = [SELECT Id, Caso__c, RM_WorkOrder__c, Tipotrabajo__c 
                                     FROM tiposDeTrabajoCaso__c LIMIT 1];
        Product2 prod = [SELECT Id FROM Product2 LIMIT 1];
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry LIMIT 1];
        
        // Crear JSON para el test
        String tester = '[{' +
            '"alias": "Aceite",' +
            '"UT": "5",' +
            '"aprobado": true,' +
            '"Bodega": "Bodega segunda de Pavas",' +
            '"cantidad": 3,' +
            '"cantidadDisponible": 253432434,' +
            '"currencyCode": "CRC",' +
            '"discount": 0.6,' +
            '"ID": "' + prod.Id + '",' +
            '"Name": "ACEITE DE MOTOR",' +
            '"precio": 12.21706315,' +
            '"priceBookEntry": "' + pbe.Id + '",' +
            '"productId": "' + prod.Id + '",' +
            '"productType": "Materiales",' +
            '"tipotrabajo": "' + ttc.Id + '"' +
            '}]';
        
        Test.startTest();
        // Llamar al método bajo prueba
        TipoTrabajoCasoController.saveWorkLineItems(
            tester,
            ttc.RM_WorkOrder__c,
            ttc.Caso__c,
            ttc.Tipotrabajo__c,
            ttc.Id,
            'caseWorkTypes',
            'Cliente',
            '',
            '',
            'Alias genérico'
        );
        Test.stopTest();
        
        // Verificar que se crearon los registros esperados
        List<WorkOrderLineItem> wolis = [SELECT Id FROM WorkOrderLineItem WHERE WorkOrderId = :ttc.RM_WorkOrder__c];
        System.assert(!wolis.isEmpty(), 'No se crearon líneas de orden de trabajo');
        
        List<Subtipo_de_trabajo_del_caso__c> subtipos = [SELECT Id FROM Subtipo_de_trabajo_del_caso__c WHERE Tipo_de_trabajo_del_caso__c = :ttc.Id];
        System.assert(!subtipos.isEmpty(), 'No se crearon subtipos de trabajo');
    }
    
    @IsTest
    static void test_AccountValidation() {
        Case testCase = [SELECT Id, AccountId FROM Case LIMIT 1];
        
        Test.startTest();
        String validationResult = TipoTrabajoCasoController.accountValidation(testCase.Id);
        Test.stopTest();
        
        // Verificar que el resultado es un JSON válido
        System.assertNotEquals(null, validationResult, 'El resultado de validación es nulo');
        Map<String, Object> resultMap = (Map<String, Object>)JSON.deserializeUntyped(validationResult);
        System.assert(resultMap.containsKey('Id'), 'El resultado no contiene el ID de la cuenta');
    }
    @IsTest
    static void test_GetRecordTypeNameById() {
        // Obtener un recordTypeId existente
        List<RecordTypeInfo> accountRecordTypes = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfos();
        Id recordTypeId = accountRecordTypes[0].getRecordTypeId();
        
        Test.startTest();
        String recordTypeName = TipoTrabajoCasoController.getRecordTypeNameById('Account', recordTypeId);
        Test.stopTest();
        
        System.assertNotEquals(null, recordTypeName, 'El nombre del tipo de registro no debería ser nulo');
    }
    
    @IsTest
    static void test_InsertTipoDelCasoDeTrabajo_Error() {
        // Obtener datos existentes
        tiposDeTrabajoCaso__c ttc = [SELECT Id, Caso__c, RM_WorkOrder__c, Tipotrabajo__c 
                                     FROM tiposDeTrabajoCaso__c LIMIT 1];
        
        Test.startTest();
        try {
            // Provocar error con caseId nulo
            tiposDeTrabajoCaso__c newTTC = TipoTrabajoCasoController.insertTipoDelCasoDeTrabajo(
                null, // caseId nulo para provocar error
                ttc.RM_WorkOrder__c,
                null,
                null,
                'Cliente',
                'Sugerido',
                'Test',
                ttc.Tipotrabajo__c,
                'Cliente',
                'Recomendado'
            );
            System.assert(false, 'Debería haber lanzado una excepción');
        } catch (AuraHandledException e) {
            System.assertNotEquals(null, e.getMessage(), 'Debería haber un mensaje de error');
        }
        Test.stopTest();
    }
    @IsTest
    static void test_GetWorkOrder_NoResults() {
        // Crear un tipo de trabajo de caso sin orden de trabajo asociada
        tiposDeTrabajoCaso__c ttc = new tiposDeTrabajoCaso__c(
            Caso__c = [SELECT Id FROM Case LIMIT 1].Id
        );
        insert ttc;
        
        Test.startTest();
        String result = TipoTrabajoCasoController.getWorkOrder(ttc.Id);
        Test.stopTest();
        
        //System.assertEquals('', result, 'Debería devolver cadena vacía cuando no hay orden de trabajo');
    }
    @IsTest
    static void test_GetTipoTrabajo_NoResults() {
        Test.startTest();
        tiposDeTrabajoCaso__c result = TipoTrabajoCasoController.getTipoTrabajo('001000000000000'); // ID inválido
        Test.stopTest();
        
        System.assertEquals(null, result.Id, 'Debería devolver objeto con Id nulo cuando no hay resultados');
    }
    @IsTest
    static void test_SaveWorkLineItems_WithManoDeObraNoPasa() {
        // Obtener datos existentes
        tiposDeTrabajoCaso__c ttc = [SELECT Id, Caso__c, RM_WorkOrder__c, Tipotrabajo__c 
                                     FROM tiposDeTrabajoCaso__c LIMIT 1];
        Product2 prod = [SELECT Id FROM Product2 LIMIT 1];
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry LIMIT 1];
        
        // Actualizar producto para no pasar a OT
        prod.Mano_de_obra_no_pasa_a_OT__c = true;
        update prod;
        
        // Crear JSON para el test
        String tester = '[{' +
            '"alias": "Aceite",' +
            '"UT": "5",' +
            '"aprobado": true,' +
            '"Bodega": "Bodega segunda de Pavas",' +
            '"cantidad": 3,' +
            '"cantidadDisponible": 253432434,' +
            '"currencyCode": "CRC",' +
            '"discount": 0.6,' +
            '"ID": "' + prod.Id + '",' +
            '"Name": "ACEITE DE MOTOR",' +
            '"precio": 12.21706315,' +
            '"priceBookEntry": "' + pbe.Id + '",' +
            '"productId": "' + prod.Id + '",' +
            '"productType": "Materiales",' +
            '"tipotrabajo": "' + ttc.Id + '"' +
            '}]';
        
        Test.startTest();
        TipoTrabajoCasoController.saveWorkLineItems(
            tester,
            ttc.RM_WorkOrder__c,
            ttc.Caso__c,
            ttc.Tipotrabajo__c,
            ttc.Id,
            'caseWorkTypes',
            'Cliente',
            '',
            '',
            'Alias genérico'
        );
        Test.stopTest();
        
        // Verificar que no se crearon WorkOrderLineItems pero sí Subtipo_de_trabajo_del_caso__c
        List<WorkOrderLineItem> wolis = [SELECT Id FROM WorkOrderLineItem WHERE WorkOrderId = :ttc.RM_WorkOrder__c];
        List<Subtipo_de_trabajo_del_caso__c> subtipos = [SELECT Id FROM Subtipo_de_trabajo_del_caso__c WHERE Tipo_de_trabajo_del_caso__c = :ttc.Id];
        
        System.assertEquals(0, wolis.size(), 'No debería crear WorkOrderLineItem cuando Mano_de_obra_no_pasa_a_OT__c es true');
        System.assertEquals(1, subtipos.size(), 'Debería crear Subtipo_de_trabajo_del_caso__c aun cuando Mano_de_obra_no_pasa_a_OT__c es true');
    }
}