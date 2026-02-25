@isTest
public class DeleteCaseComments_Test {
    
    // Método utilitario para crear usuarios de prueba válidos
    private static User createUser(String alias, String email, Id profileId, String nombrePerfil) {
        User u = new User(
            Alias = alias,
            Email = email,
            EmailEncodingKey = 'UTF-8',
            LastName = 'Test',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Mexico_City',
            Username = email,
            ProfileId = profileId
            
        );
        insert u;
        return u;
    }

    @isTest
    static void testAdminCanDeleteCaseComment() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User adminUser = createUser('admusr', 'adminuser987@test.com', p.Id, 'PT1'); // PT1 = permitido

        System.runAs(adminUser) {
            Case testCase = new Case(Subject = 'Caso Admin', Status = 'Nuevo', Origin = 'Email');
            insert testCase;

            CaseComment comment = new CaseComment(ParentId = testCase.Id, CommentBody = 'Comentario admin');
            insert comment;

            // Este delete debe pasar sin error
            delete comment;
        }
    }

    @isTest
    static void testNonAdminCannotDeleteCaseComment() {
       Profile pNonAdmin = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User nonAdminUser = new User(
            Lastname = 'nonadmin',
            Username = 'KSFPrueba@crexample.com',
            Email = 'nonadmin@example.com',
            Alias = 'nonadmin',
            ProfileId = pNonAdmin.Id,
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert nonAdminUser;

        System.runAs(nonAdminUser) {
            Case testCase = new Case(Subject = 'Caso normal', Status = 'Nuevo', Origin = 'Email');
            insert testCase;

            CaseComment comment = new CaseComment(ParentId = testCase.Id, CommentBody = 'Comentario normal');
            insert comment;

            // Este delete debe lanzar error
            try {
                delete comment;
                System.assert(false, 'Debió lanzar error por falta de permisos');
            } catch (DmlException e) {
                System.assert(
                    e.getMessage().contains('No tienes permiso'),
                    'El mensaje no coincide con la validación esperada'
                );
            }
        }
    }
}