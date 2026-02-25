@isTest
public class CaseChecklistControllerTest {

    @TestSetup
    static void makeData(){    
        Account acc = new Account();
        acc.Name='Test account';
        acc.Cedula__c='9876543210';
        acc.Tipo_de_Documento__c='02';
        acc.codigoSoftland__c = '1234';  
        insert acc;

        Contact cont = new Contact(
            FirstName = 'Julio',
            LastName = 'Perez'
        );
        insert cont;

        tiposDeTrabajo__c tipoTrabajo = new tiposDeTrabajo__c(
            Name = 'Mantenimiento'        
        );
        insert tipoTrabajo;

        Asset vehiculo = new Asset(
            Name = 'Car 1',
            AccountId = acc.Id,
            Tipo_de_veh_culo__c = 'Automóvil',
            Kilometros__c = 50000
        );
        insert vehiculo;
        

        WorkOrder workOrder = new WorkOrder(
            AssetId = vehiculo.Id            
        );
        insert workOrder;
        
        Opportunity opp = new Opportunity(
        Name = 'Test Opportunity',
        StageName = 'Prospecting',
        CloseDate = System.today().addDays(10),
        WorkOrder__c = workOrder.Id
    );
    insert opp;
        
    Quote qt = new Quote(
    Name = 'Test Quote',
    OpportunityId = opp.Id
    );
    insert qt;

    }

    @isTest
    public static void testCaseChecklistController() {

        List<tiposDeTrabajo__c> tipoTrabajoList = [SELECT Id,Name FROM tiposDeTrabajo__c LIMIT 1];
        WorkOrder workOrder = [SELECT Id,CaseId FROM WorkOrder LIMIT 1];
        Asset vehiculo = [SELECT Id FROM Asset LIMIT 1];
        System.debug('@@@workOrder@@@'+workOrder);
        
        Case cs = new Case(
            Create_Orders_from_Workorders__c = true,
            AssetId = vehiculo.Id
            );
        insert cs;

        workOrder.CaseId = cs.Id;
        update workOrder;
        
        Cambio_de_Propietario__c cambio = new Cambio_de_Propietario__c(
       Case__c = cs.Id,
       Asset__c = vehiculo.Id,
       //Cuenta_Anterior__c = acc.Id,
      //Cuenta_Nueva__c = acc.Id,
       Estado__c = 'Pendiente'
       );
       insert cambio;

        
        Test.startTest();
        ApexPages.currentPage().getParameters().put('id', cs.Id);
        ApexPages.StandardController controller = new ApexPages.StandardController(cs);
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        CaseChecklistController cntrl = new CaseChecklistController(controller);
        Test.stopTest();
    }
    
    public class ExampleCalloutMock implements HttpCalloutMock{
        public HttpResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');
            res.setStatusCode(200);
            res.setBody('{"access_token":"","token_type":""}');
            return res;
        }
    }
}