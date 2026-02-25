@isTest
public class noCerradaFacturadaOt_test {

    static Profile getProfileByName(String name) {
        return [SELECT Id FROM Profile WHERE Name = :name LIMIT 1];
    }

    static User createUser(String alias, String email, String profileName) {
        Profile prof = getProfileByName(profileName);
        return new User(
            Username = alias + '@test1.com',
            LastName = 'Test',
            Email = email,
            Alias = alias,
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = prof.Id
        );
    }

    @testSetup
    static void setupTestData() {
        // Crear cuenta
        Account acc = new Account(Name = 'Cliente Test');
        insert acc;

        // Crear orden
        WorkOrder wo = new WorkOrder(
            AccountId = acc.Id,
            Subject = 'Orden inicial',
            Status = 'Borrador'
        );
        insert wo;

        // Líneas de trabajo: una facturada, una pendiente
        List<WorkOrderLineItem> lines = new List<WorkOrderLineItem>{
            new WorkOrderLineItem(
                WorkOrderId = wo.Id,
                Description = 'Trabajo 1',
                Estado__c = 'Facturado'
            ),
            new WorkOrderLineItem(
                WorkOrderId = wo.Id,
                Description = 'Trabajo 2',
                Estado__c = 'Pendiente'
            )
        };
        insert lines;
    }

    @isTest
    static void testBloqueoParaUsuarioNoAdmin() {
        // Crear usuario con perfil estándar
        User stdUser = createUser('stduser', 'std@test.com', 'Standard User');
        insert stdUser;

        System.runAs(stdUser) {
    WorkOrder wo = [SELECT Id, Etapa_de_flujo_de_trabajo__c FROM WorkOrder LIMIT 1];
    wo.Etapa_de_flujo_de_trabajo__c = 'Orden Cerrada';

    Test.startTest();
    try {
        update wo;
        System.assert(false, 'Debería lanzar error porque hay líneas no facturadas');
    } catch (DmlException e) {
    System.assert(true, 'Se lanzó DmlException como se esperaba');
}

    Test.stopTest();
}

    }

    @isTest
    static void testPermitirParaAdmin() {
        // Crear usuario administrador
        User adminUser = createUser('admnuser', 'admin@test.com', 'System Administrator');
        insert adminUser;

        System.runAs(adminUser) {
    WorkOrder wo = [SELECT Id, Etapa_de_flujo_de_trabajo__c FROM WorkOrder LIMIT 1];
    wo.Etapa_de_flujo_de_trabajo__c = 'Orden Cerrada';

    Test.startTest();
    update wo; // No debe lanzar error
    Test.stopTest();
}

    }

    @isTest
static void testCambioPermitidoSiTodoFacturado() {
    // Crear usuario no admin
    User stdUser = createUser('stduser2', 'std2@test.com', 'Standard User');
    insert stdUser;

    System.runAs(stdUser) {
        // Crear datos bajo el mismo usuario para evitar problemas de acceso
        Account acc = new Account(Name = 'Cuenta del usuario');
        insert acc;

        WorkOrder wo = new WorkOrder(
            AccountId = acc.Id,
            Subject = 'Orden del usuario',
            Etapa_de_flujo_de_trabajo__c = 'Nuevo'
        );
        insert wo;

        List<WorkOrderLineItem> lines = new List<WorkOrderLineItem>{
            new WorkOrderLineItem(
                WorkOrderId = wo.Id,
                Description = 'Trabajo 1',
                Estado__c = 'Facturado'
            ),
            new WorkOrderLineItem(
                WorkOrderId = wo.Id,
                Description = 'Trabajo 2',
                Estado__c = 'Facturado'
            )
        };
        insert lines;

        // Intentar cambiar el estado ahora que todo está facturado
        wo.Etapa_de_flujo_de_trabajo__c = 'Orden Facturada';

        Test.startTest();
        update wo; // ✅ No debe lanzar error ahora
        Test.stopTest();
    }
}

}