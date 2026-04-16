@isTest
public class CaseChecklistControllerTest {

    @TestSetup
    static void makeData() {
        Account acc = new Account();
        acc.Name = 'Test account';
        acc.Cedula__c = '9876543210';
        acc.Tipo_de_Documento__c = '02';
        acc.codigoSoftland__c = '1234';
        insert acc;

        Contact cont = new Contact(
            FirstName = 'Julio',
            LastName  = 'Perez'
        );
        insert cont;

        tiposDeTrabajo__c tipoTrabajo = new tiposDeTrabajo__c(
            Name = 'Mantenimiento'
        );
        insert tipoTrabajo;

        Asset vehiculo = new Asset(
            Name                = 'Car 1',
            AccountId           = acc.Id,
            Tipo_de_veh_culo__c = 'Automóvil',
            Kilometros__c       = 50000
        );
        insert vehiculo;

        WorkOrder workOrder = new WorkOrder(
            AssetId = vehiculo.Id
        );
        insert workOrder;

        Opportunity opp = new Opportunity(
            Name          = 'Test Opportunity',
            StageName     = 'Prospecting',
            CloseDate     = System.today().addDays(10),
            WorkOrder__c  = workOrder.Id
        );
        insert opp;

        Quote qt = new Quote(
            Name          = 'Test Quote',
            OpportunityId = opp.Id
        );
        insert qt;
    }

    @isTest
    static void testCaseChecklistController() {
        List<tiposDeTrabajo__c> tipoTrabajoList = [SELECT Id, Name FROM tiposDeTrabajo__c LIMIT 1];
        WorkOrder workOrder = [SELECT Id, CaseId FROM WorkOrder LIMIT 1];
        Asset vehiculo = [SELECT Id FROM Asset LIMIT 1];

        Case cs = new Case(
            Create_Orders_from_Workorders__c = true,
            AssetId = vehiculo.Id
        );
        insert cs;

        // Setear Kilometros__c para cubrir la rama if(OT[0].Kilometros__c != null && != 0)
        workOrder.CaseId = cs.Id;
        workOrder.Kilometros__c = 5000;
        update workOrder;

        Cambio_de_Propietario__c cambio = new Cambio_de_Propietario__c(
            Case__c   = cs.Id,
            Asset__c  = vehiculo.Id,
            Estado__c = 'Pendiente'
        );
        insert cambio;

        // Crear tiposDeTrabajoCaso__c para cubrir la rama listTipos.size()>0 y la query de subtipos
        tiposDeTrabajoCaso__c ttc = new tiposDeTrabajoCaso__c(
            Caso__c          = cs.Id,
            Tipotrabajo__c   = tipoTrabajoList[0].Id,
            Status__c        = 'Abierta',
            Tipo_de_cargo__c = 'Cliente',
            Horaa__c         = 4
        );
        insert ttc;

        Test.startTest();
        ApexPages.currentPage().getParameters().put('id', cs.Id);
        ApexPages.StandardController controller = new ApexPages.StandardController(cs);
        CaseChecklistController cntrl = new CaseChecklistController(controller);
        Test.stopTest();

        System.assertEquals(true,  cntrl.infoInComplete,     'Case sin datos completos debe tener infoInComplete = true');
        System.assertNotEquals(null, cntrl.cambioPropietario, 'Debe encontrar el cambio de propietario pendiente');
        System.assertNotEquals(null, cntrl.quoteNumber,       'Debe encontrar el quote relacionado via WorkOrder → Opportunity');
        System.assertEquals(5000,  cntrl.kilometros,          'Debe usar Kilometros__c del WorkOrder cuando es != 0');
        System.assertNotEquals(null, cntrl.listTipos,         'listTipos no debe ser null');
        System.assertEquals(1,     cntrl.listTipos.size(),    'Debe encontrar el tiposDeTrabajoCaso__c insertado');
        System.assertNotEquals(null, cntrl.ordenesTrabajo,    'ordenesTrabajo (propiedad de clase) no debe ser null');
        System.assertEquals(false, cntrl.firmaEncontrada,     'No hay Firma__c en los datos de prueba');
        System.assertEquals(false, cntrl.hayDibujo,           'No hay DibujoVehiculo__c en los datos de prueba');
    }
}
