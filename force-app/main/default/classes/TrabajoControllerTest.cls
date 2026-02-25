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
        Pricebook2 pb = new Pricebook2(Name = 'Test Pricebook', IsActive = true);
        insert pb;
        
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = pb.Id,
            Product2Id = manoDeObra.Id,
            UnitPrice = 100,
            IsActive = true
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
            Pricebook2Id = pb.Id
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

    
}