@IsTest
public class CitaTraficoOnlineTriggerHandlerTest {
    private class N8NCalloutMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"status":"ok"}');
            return res;
        }
    }

    private static void setupData() {
        insert createUser('Advisor');
        insert createUser('Owner');
        insert new Lead(
            FirstName = 'Juan',
            LastName = 'Trigger Handler',
            Company = 'Red Motors Test',
            Email = 'cita.trigger@test.com',
            Marca__c = 'BMW'
        );
    }

    private static User createUser(String label) {
        String uniqueValue = String.valueOf(DateTime.now().getTime()) + Math.abs(Crypto.getRandomInteger());
        return new User(
            FirstName = label,
            LastName = 'Cita',
            Alias = (label.left(2) + uniqueValue.right(6)).left(8),
            Email = label.toLowerCase() + uniqueValue + '@test.com',
            Username = label.toLowerCase() + uniqueValue + '@test.com',
            CommunityNickname = label.toLowerCase() + uniqueValue,
            TimeZoneSidKey = 'America/Mexico_City',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = UserInfo.getProfileId()
        );
    }

    private static Lead getLead() {
        return [
            SELECT Id, FirstName, LastName
            FROM Lead
            WHERE LastName = 'Trigger Handler'
            LIMIT 1
        ];
    }

    private static User getAdvisorUser() {
        return [
            SELECT Id, Email, Name
            FROM User
            WHERE FirstName = 'Advisor'
            AND LastName = 'Cita'
            LIMIT 1
        ];
    }

    private static User getNewOwnerUser() {
        return [
            SELECT Id, Email, Name
            FROM User
            WHERE FirstName = 'Owner'
            AND LastName = 'Cita'
            LIMIT 1
        ];
    }

    private static Cita_trafico_online__c buildCita(String suffix, String phone, String status, Id ownerId, Id advisorId) {
        Datetime startDate = Datetime.now().addDays(1);
        return new Cita_trafico_online__c(
            Trafico__c = getLead().Id,
            Telefono__c = phone,
            Inicio__c = startDate,
            Fin__c = startDate.addHours(1),
            Status__c = status,
            Sucursal__c = 'Uruca',
            Cedula__c = 'CED-' + suffix,
            Nombre__c = 'Cita ' + suffix,
            Email__c = suffix + '@test.com',
            OwnerId = ownerId,
            Asesor_de_piso__c = advisorId,
            Notas_del_asesor__c = 'Nota ' + suffix
        );
    }

    private static void createWalkIn(Id traficoId) {
        Opportunity opp = new Opportunity(
            Name = 'Opp Cita ' + String.valueOf(DateTime.now().getTime()),
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
        );
        insert opp;

        insert new Registro_WalkIn__c(
            Trafico__c = traficoId,
            Opportunity__c = opp.Id
        );
    }

    @IsTest
    static void testHandleAfterInsertConTelefono() {
        setupData();
        User advisor = getAdvisorUser();
        String testPhone = '50680001111';

        Test.setMock(HttpCalloutMock.class, new N8NCalloutMock());
        Test.startTest();
        insert buildCita('insert-phone', testPhone, 'Agendada', UserInfo.getUserId(), advisor.Id);
        Test.stopTest();

        N8N__c n8nRecord = [
            SELECT Id, Id__c, Endpoint__c, X2__c
            FROM N8N__c
            WHERE Id__c = :testPhone
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];

        System.assertEquals(testPhone, n8nRecord.Id__c);
        System.assert(n8nRecord.Endpoint__c.contains('trigger-automation'));
    }

    @IsTest
    static void testHandleAfterInsertSinTelefonoYListaVacia() {
        setupData();
        User advisor = getAdvisorUser();

        Test.startTest();
        insert buildCita('insert-no-phone', null, 'Agendada', UserInfo.getUserId(), advisor.Id);
        CitaTraficoOnlineTriggerHandler.handleAfterInsert(new List<Cita_trafico_online__c>());
        Test.stopTest();

        System.assertEquals(
            1,
            [SELECT COUNT() FROM Cita_trafico_online__c WHERE Cedula__c = 'CED-insert-no-phone']
        );
    }

    @IsTest
    static void testHandleAfterUpdateStatusBranches() {
        setupData();
        User advisor = getAdvisorUser();
        Lead lead = getLead();
        createWalkIn(lead.Id);

        List<Cita_trafico_online__c> citas = new List<Cita_trafico_online__c>{
            buildCita('status-a', null, 'Agendada', UserInfo.getUserId(), advisor.Id),
            buildCita('status-b', null, 'Agendada', UserInfo.getUserId(), advisor.Id),
            buildCita('status-c', null, 'Agendada', UserInfo.getUserId(), advisor.Id)
        };
        insert citas;

        citas[0].Status__c = 'Asistió';
        citas[1].Status__c = 'Cancelada';
        citas[2].Status__c = 'Reprogramada';

        Test.startTest();
        update citas;
        Test.stopTest();

        Map<Id, Cita_trafico_online__c> updatedCitas = new Map<Id, Cita_trafico_online__c>([
            SELECT Id, Status__c
            FROM Cita_trafico_online__c
            WHERE Id IN :new Map<Id, Cita_trafico_online__c>(citas).keySet()
        ]);

        System.assertEquals('Asistió', updatedCitas.get(citas[0].Id).Status__c);
        System.assertEquals('Cancelada', updatedCitas.get(citas[1].Id).Status__c);
        System.assertEquals('Reprogramada', updatedCitas.get(citas[2].Id).Status__c);
    }

    @IsTest
    static void testHandleAfterUpdateOwnerChange() {
        setupData();
        User advisor = getAdvisorUser();
        User newOwner = getNewOwnerUser();
        Lead lead = getLead();
        createWalkIn(lead.Id);

        Cita_trafico_online__c cita = buildCita('owner-change', null, 'Agendada', UserInfo.getUserId(), advisor.Id);
        insert cita;

        cita.OwnerId = newOwner.Id;

        Test.startTest();
        update cita;
        Test.stopTest();

        Cita_trafico_online__c updatedCita = [
            SELECT Id, OwnerId
            FROM Cita_trafico_online__c
            WHERE Id = :cita.Id
        ];
        System.assertEquals(newOwner.Id, updatedCita.OwnerId);
    }
}