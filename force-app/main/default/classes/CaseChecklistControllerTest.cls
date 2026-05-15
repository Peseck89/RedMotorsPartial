@IsTest
public class CaseChecklistControllerTest {

    @TestSetup
    static void makeData() {
        Account acc = new Account(
            Name = 'Test account',
            Cedula__c = '9876543210',
            Tipo_de_Documento__c = '02',
            codigoSoftland__c = '1234'
        );
        insert acc;

        Contact cont = new Contact(
            FirstName = 'Julio',
            LastName  = 'Perez',
            AccountId = acc.Id
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

        Case cs = new Case(
            AccountId = acc.Id,
            ContactId = cont.Id,
            AssetId = vehiculo.Id,
            Create_Orders_from_Workorders__c = true
        );
        insert cs;

        WorkOrder workOrder = new WorkOrder(
            AssetId = vehiculo.Id,
            CaseId = cs.Id,
            Kilometros__c = 5000
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

        Cambio_de_Propietario__c cambio = new Cambio_de_Propietario__c(
            Case__c   = cs.Id,
            Asset__c  = vehiculo.Id,
            Estado__c = 'Pendiente'
        );
        insert cambio;

        tiposDeTrabajoCaso__c ttc = new tiposDeTrabajoCaso__c(
            Caso__c          = cs.Id,
            Tipotrabajo__c   = tipoTrabajo.Id,
            Status__c        = 'Abierta',
            Tipo_de_cargo__c = 'Cliente',
            Horaa__c         = 4
        );
        insert ttc;
    }

    @IsTest
    static void testCaseChecklistController() {
        Case cs = [SELECT Id FROM Case LIMIT 1];

        Test.startTest();
        
        PageReference pageRef = Page.CaseChecklistPDFBeta; 
        pageRef.getParameters().put('id', cs.Id);
        Test.setCurrentPage(pageRef);

        ApexPages.StandardController stdController = new ApexPages.StandardController(cs);
        CaseChecklistController cntrl = new CaseChecklistController(stdController);
        
        Test.stopTest();

        System.assertEquals(true, cntrl.infoInComplete);
        System.assertNotEquals(null, cntrl.cambioPropietario);
        System.assertNotEquals(null, cntrl.quoteNumber);
        System.assertEquals(5000, cntrl.kilometros);
        System.assertNotEquals(null, cntrl.listTipos);
        System.assertEquals(1, cntrl.listTipos.size());
        System.assertEquals(false, cntrl.firmaEncontrada);
        System.assertEquals(false, cntrl.hayDibujo);
    }
}