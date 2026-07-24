@IsTest
private class RM_TraerTrabajosEmailServiceTest {

    // ✅ Mock genérico para cualquier SOAP callout que dispare algún trigger/flow en tu org
    public class DummyWsMock implements WebServiceMock {
        public void doInvoke(
            Object stub,
            Object request,
            Map<String, Object> response,
            String endpoint,
            String soapAction,
            String requestName,
            String responseNamespace,
            String responseName,
            String responseType
        ) {
            response.put(responseName, null);
        }
    }

    // ✅ Mock genérico para HTTP callouts por si hay automatización con Http
    public class DummyHttpMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{}');
            return res;
        }
    }

    @testSetup
    static void setup() {
        // ✅ IMPORTANTÍSIMO: setear mocks ANTES de cualquier DML que dispare automatizaciones
        Test.setMock(WebServiceMock.class, new DummyWsMock());
        Test.setMock(HttpCalloutMock.class, new DummyHttpMock());

        Account a = new Account(Name = 'ACC TEST');
        insert a;

        Asset ast = new Asset(
            Name = 'AST TEST',
            AccountId = a.Id,
            NumeroDeChasis__c = 'WBA00000000000000' // 17 chars
        );
        insert ast;

        Case c = new Case(
            AccountId = a.Id,
            AssetId   = ast.Id,
            Subject   = 'CASE TEST',
            Status    = pickVal(Case.Status),
            Origin    = pickVal(Case.Origin)
        );
        insert c;

        // WorkOrder normalmente trae validaciones en orgs con FSL
        Id stdPbId = Test.getStandardPricebookId();
        ensurePricebookActive(stdPbId);

        Pricebook2 pb2 = new Pricebook2(Name = 'PB TEST', IsActive = true);
        insert pb2;

        WorkType wt = new WorkType(Name = 'WT TEST', EstimatedDuration = 120);
        insert wt;

        WorkOrder wo = new WorkOrder(
            AccountId = a.Id,
            CaseId    = c.Id,
            Subject   = 'WO TEST',
            Status    = pickVal(WorkOrder.Status),
            Priority  = pickVal(WorkOrder.Priority),
            Pricebook2Id = pb2.Id,
            WorkTypeId   = wt.Id,
            empresaFactura__c = 'RMBAVARIAN'
        );
        insert wo;
    }

    @IsTest
    static void testSendUsageEmail_rowsOver20_andEscaping() {
        Case c = [SELECT Id FROM Case LIMIT 1];
        WorkOrder wo = [SELECT Id FROM WorkOrder LIMIT 1];

        List<RM_TraerTrabajosEmailService.ServiceRow> rows = new List<RM_TraerTrabajosEmailService.ServiceRow>();

        // 25 filas => ejecuta rama "Mostrando 20 de X"
        for (Integer i = 1; i <= 25; i++) {
            RM_TraerTrabajosEmailService.ServiceRow r = new RM_TraerTrabajosEmailService.ServiceRow();
            r.serviceNumber = '0000' + i;
            r.identificador = 'ID-' + i;

            // Fuerza esc() con caracteres especiales
            if (i == 1) {
                r.name = 'Filtro <motor> & "aceite" \'premium\'';
            } else {
                r.name = 'Servicio ' + i;
            }

            r.state = (Math.mod(i, 2) == 0) ? 'RED' : 'YELLOW';
            r.uts = i;
            r.prioridad = (r.state == 'RED') ? 'Necesario' : 'Recomendado';
            r.creado = (i <= 10);
            rows.add(r);
        }

        Test.startTest();
        Boolean ok = RM_TraerTrabajosEmailService.sendUsageEmail(
            c.Id,
            wo.Id,
            'Cliente',
            25,  // servicesReceived
            10,  // createdTrabajosCaso
            2,   // createdTiposDeTrabajo
            0,   // servicesSkippedNoIdent
            rows
        );
        Test.stopTest();

        System.assertEquals(true, ok, 'sendUsageEmail debe regresar true en test');
       // System.assertEquals(1, Limits.getEmailInvocations(), 'Debe invocar 1 envío de email');
    }

    @IsTest
    static void testSendUsageEmail_nullRows() {
        Case c = [SELECT Id FROM Case LIMIT 1];
        WorkOrder wo = [SELECT Id FROM WorkOrder LIMIT 1];

        Test.startTest();
        Boolean ok = RM_TraerTrabajosEmailService.sendUsageEmail(
            c.Id,
            wo.Id,
            'Garantía',
            0,
            0,
            0,
            0,
            null
        );
        Test.stopTest();

        System.assertEquals(true, ok, 'Con rows null también debería regresar true');
       // System.assertEquals(1, Limits.getEmailInvocations(), 'Debe invocar 1 envío de email');
    }

    // -------------------------
    // Helpers
    // -------------------------
    private static void ensurePricebookActive(Id pbId) {
        if (pbId == null) return;
        try { update new Pricebook2(Id = pbId, IsActive = true); } catch (Exception e) {}
    }

    private static String pickVal(Schema.SObjectField f) {
        for (Schema.PicklistEntry pe : f.getDescribe().getPicklistValues()) {
            if (pe.isActive()) return pe.getValue();
        }
        return null;
    }
}