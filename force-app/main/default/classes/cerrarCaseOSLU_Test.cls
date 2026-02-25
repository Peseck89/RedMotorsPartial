@isTest
public class cerrarCaseOSLU_Test {

    // Utilidad para crear usuarios
    private static User createUser(String profileName, String alias, String email) {
        Profile p = [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1];
        User u = new User(
            Alias = alias,
            Email = email,
            EmailEncodingKey = 'UTF-8',
            LastName = 'TestUser',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Mexico_City',
            Username = email,
            ProfileId = p.Id
        );
        insert u;
        return u;
    }

    @testSetup
    static void setupData() {
        // Crear un caso base
        Case c1 = new Case(Subject = 'Caso base', Status = 'Abierto');
        insert c1;

        // Crear WorkOrder relacionado
        WorkOrder wo1 = new WorkOrder(CaseId = c1.Id, Subject = 'OT principal');
        insert wo1;

        // Pedido Facturado
        Respuesta_pedido__c pedidoFact = new Respuesta_pedido__c(
            ID_Pedido_Softland__c = 'Pedido Facturado',
            Work_Order__c = wo1.Id,
            Estado__c = 'Facturado'
        );
        insert pedidoFact;
    }

    // 🔹 Caso 1: Bloquea el cierre si el pedido no está facturado (usuario no admin)
    @isTest
    static void testBloqueaCierreNoFacturado() {
        // Crear un nuevo caso y pedido no facturado
        Case c = new Case(Subject = 'Caso no facturado', Status = 'Abierto');
        insert c;

        WorkOrder wo = new WorkOrder(CaseId = c.Id, Subject = 'WO no facturada');
        insert wo;

        Respuesta_pedido__c pedidoNoFact = new Respuesta_pedido__c(
            ID_Pedido_Softland__c = 'Pedido no facturado',
            Work_Order__c = wo.Id,
            Estado__c = 'En proceso' // Usa un valor real diferente de 'Facturado'
        );
        insert pedidoNoFact;

        // Crear usuario no admin
        Profile nonAdminProfile = [SELECT Id, Name FROM Profile WHERE Name != 'System Administrator' LIMIT 1];
        User normalUser = createUser(nonAdminProfile.Name, 'usrnf', 'normal_user@test.com');

        System.runAs(normalUser) {
            Test.startTest();
            c.Status = 'Cerrado';
            try {
                update c;
                System.assert(false, 'Debió lanzar error por pedido no facturado');
            } catch (DmlException e) {
                System.debug('Mensaje de error: ' + e.getMessage());
                System.assert(
                    e.getMessage().contains('pedido relacionado no está facturado'),
                    'El mensaje no coincide con la validación esperada'
                );
            }
            Test.stopTest();
        }
    }

    // 🔹 Caso 2: Permite cierre si el pedido está facturado (usuario no admin)
    @isTest
    static void testPermiteCierreFacturado() {
        // Obtener datos de setup
        Case c = [SELECT Id, Status FROM Case WHERE Subject = 'Caso base' LIMIT 1];

        Test.startTest();
        c.Status = 'Cerrado';
        update c; // No debe lanzar error
        Test.stopTest();

        System.assertEquals('Cerrado', [SELECT Status FROM Case WHERE Id = :c.Id].Status);
    }

    // 🔹 Caso 3: Permite cierre aunque no esté facturado (usuario administrador)
    @isTest
    static void testPermiteCierreAdmin() {
        Profile adminProfile = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User adminUser = createUser(adminProfile.Name, 'admint', 'admin_test@example.com');

        // Crear un caso y pedido no facturado
        Case c2 = new Case(Subject = 'Caso Admin', Status = 'Abierto');
        insert c2;

        WorkOrder wo2 = new WorkOrder(CaseId = c2.Id, Subject = 'WO Admin');
        insert wo2;

        Respuesta_pedido__c pedidoNF = new Respuesta_pedido__c(
            ID_Pedido_Softland__c = 'Pedido Admin',
            Work_Order__c = wo2.Id,
            Estado__c = 'En proceso'
        );
        insert pedidoNF;

        System.runAs(adminUser) {
            Test.startTest();
            c2.Status = 'Cerrado';
            update c2; // No debe lanzar error
            Test.stopTest();
        }

        System.assertEquals('Cerrado', [SELECT Status FROM Case WHERE Id = :c2.Id].Status);
    }
}