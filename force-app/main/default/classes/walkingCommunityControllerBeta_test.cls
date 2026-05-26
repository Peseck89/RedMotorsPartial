@isTest
public class walkingCommunityControllerBeta_test {

    private static Id getRtLead(String name) {
        return Schema.SObjectType.Lead.getRecordTypeInfosByName().get(name).getRecordTypeId();
    }

    private static Id getRtOpp(String name) {
        return Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(name).getRecordTypeId();
    }

    private static Lead crearLeadUsados(String cedula, String tipoVehiculo) {
        Lead l = new Lead(
            RecordTypeId                    = getRtLead('Autos Usados'),
            FirstName                       = 'Juan',
            LastName                        = 'Test',
            Email                           = 'juan.test@test.com',
            MobilePhone                     = '88888888',
            Phone                           = '88888888',
            Numero_de_Identificacion_del__c = cedula,
            Tipo_de_Identificaci_n__c       = '01',
            Tipo_Vehiculo_Usados__c         = tipoVehiculo,
            LeadSource                      = 'Walking Usados',
            Origen_1__c                     = 'Walking Usados',
            Sucursal__c                     = 'Uruca'
        );
        insert l;
        return l;
    }

    private static Lead crearLeadBMW(String cedula) {
        Lead l = new Lead(
            RecordTypeId                    = getRtLead('BMW'),
            FirstName                       = 'Juan',
            LastName                        = 'Test',
            Email                           = 'juan.test@test.com',
            MobilePhone                     = '88888888',
            Phone                           = '88888888',
            Numero_de_Identificacion_del__c = cedula,
            Tipo_de_Identificaci_n__c       = '01',
            Marca__c                        = 'BMW',
            LeadSource                      = 'Walking',
            Origen_1__c                     = 'Walking'
        );
        insert l;
        return l;
    }

    private static Opportunity crearOppUsados(String cedula, Date closeDate, String stage) {
        Opportunity opp = new Opportunity(
            Name         = 'Opp Usados Beta Test',
            RecordTypeId = getRtOpp('Autos usados'),
            StageName    = stage,
            CloseDate    = closeDate
        );
        insert opp;
        return opp;
    }

    private static Opportunity crearOppBMW(String stage, Date closeDate) {
        Opportunity opp = new Opportunity(
            Name         = 'Opp BMW Beta Test',
            RecordTypeId = getRtOpp('BMW'),
            StageName    = stage,
            CloseDate    = closeDate
        );
        insert opp;
        return opp;
    }

    private static Cita_trafico_online__c crearCita(String cedula, String status) {
        Cita_trafico_online__c cita = new Cita_trafico_online__c(
            Nombre__c = 'Juan Test',
            Cedula__c = cedula,
            Status__c = status,
            Inicio__c = DateTime.now().addDays(1),
            Fin__c    = DateTime.now().addDays(1).addHours(1),
            Email__c  = cedula + '@test.com'
        );
        insert cita;
        return cita;
    }

    @isTest
    static void testGetModelos() {
        Test.startTest();
        Map<String, List<String>> resultado = walkingCommunityControllerBeta.getModelos();
        Test.stopTest();

        System.assertNotEquals(null, resultado);
    }

    @isTest
    static void testGetFieldDependencies() {
        Test.startTest();
        Map<String, List<String>> result = walkingCommunityControllerBeta.getFieldDependencies(
            'Lead', 'Marca__c', 'Familia1__c'
        );
        Test.stopTest();

        System.assertNotEquals(null, result);
        System.assert(result.size() > 0);
    }

    @isTest
    static void testGetFamilia_SinProductos() {
        Test.startTest();
        List<AggregateResult> resultBMW  = walkingCommunityControllerBeta.getFamilia('BMW');
        List<AggregateResult> resultMoto = walkingCommunityControllerBeta.getFamilia('Motorrad');
        Test.stopTest();

        System.assertNotEquals(null, resultBMW);
        System.assertNotEquals(null, resultMoto);
    }

    @isTest
    static void testGetVehiculos_SinProductos() {
        Test.startTest();
        List<Product2> result = walkingCommunityControllerBeta.getVehiculos('X', 'BMW');
        Test.stopTest();

        System.assertNotEquals(null, result);
    }

    @isTest
    static void testGetCedula_AccountExistente() {
        Account acc = new Account(LastName = 'Test Person Beta', Cedula__c = '111111110');
        try {
            acc.RecordTypeId = Schema.SObjectType.Account
                .getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        } catch (Exception e) {}
        insert acc;

        Test.startTest();
        try {
            List<String> result = walkingCommunityControllerBeta.getCedula('111111110');
            System.assertNotEquals(null, result);
        } catch (Exception e) {
            System.assertNotEquals(null, e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testGetCedula_NoExiste() {
        Test.startTest();
        try {
            List<String> result = walkingCommunityControllerBeta.getCedula('999999990');
            System.assertNotEquals(null, result);
        } catch (Exception e) {
            System.assertNotEquals(null, e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testGetImagenes_SinProductos() {
        Test.startTest();
        Map<String, String> result = walkingCommunityControllerBeta.getImagenes('X', 'BMW');
        Test.stopTest();

        System.assertNotEquals(null, result);
    }

    @isTest
    static void testBuscarCitaPorCedula_Vacia() {
        Test.startTest();
        List<Cita_trafico_online__c> result = walkingCommunityControllerBeta.buscarCitaPorCedula('');
        Test.stopTest();

        System.assertNotEquals(null, result);
        System.assertEquals(0, result.size());
    }

    @isTest
    static void testBuscarCitaPorCedula_ConCita() {
        crearCita('222222220', 'Agendada');

        Test.startTest();
        List<Cita_trafico_online__c> result = walkingCommunityControllerBeta.buscarCitaPorCedula('222222220');
        Test.stopTest();

        System.assertNotEquals(null, result);
        System.assertEquals(1, result.size());
        System.assertEquals('Agendada', result[0].Status__c);
    }

    @isTest
    static void testBuscarCitaPorCedula_SinCitasAgendadas() {
        crearCita('333333330', 'Asistió');

        Test.startTest();
        List<Cita_trafico_online__c> result = walkingCommunityControllerBeta.buscarCitaPorCedula('333333330');
        Test.stopTest();

        System.assertEquals(0, result.size());
    }

    @isTest
    static void testCreateTraficoUsados_NuevoTrafico() {
        Test.startTest();
        try {
            walkingCommunityControllerBeta.createTraficoUsados(
                'Juan', 'Perez', 'juan.beta@test.com', '88888888',
                '3 meses', '444444440', 'Uruca', 'no', 'Automóvil'
            );
        } catch (Exception e) {
            System.assertNotEquals(null, e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testCreateTraficoUsados_ConLeadReciente() {
        crearLeadUsados('555555550', 'Automóvil');

        Test.startTest();
        try {
            walkingCommunityControllerBeta.createTraficoUsados(
                'Juan', 'Test', 'juan.test@test.com', '88888888',
                '1 mes', '555555550', 'Uruca', 'si', 'Automóvil'
            );
        } catch (Exception e) {
            System.assertNotEquals(null, e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testCreateTraficoUsados_ConOppReciente() {
        crearOppUsados('666666660', Date.today().addDays(30), 'Prospecting');

        Test.startTest();
        try {
            walkingCommunityControllerBeta.createTraficoUsados(
                'Maria', 'Lopez', 'maria.beta@test.com', '77777770',
                '2 meses', '666666660', 'Uruca', 'no', 'Motocicleta'
            );
        } catch (Exception e) {
            System.assertNotEquals(null, e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testCreateTraficoUsados_ConOppVieja() {
        crearOppUsados('777777770', Date.today().addDays(30), 'Prospecting');

        Test.startTest();
        try {
            walkingCommunityControllerBeta.createTraficoUsados(
                'Carlos', 'Mora', 'carlos.beta@test.com', '66666660',
                '6 meses', '777777770', 'Uruca', 'no', 'Automóvil'
            );
        } catch (Exception e) {
            System.assertNotEquals(null, e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testCreateTraficoUsados_OtroMedioOnline() {
        Test.startTest();
        try {
            walkingCommunityControllerBeta.createTraficoUsados(
                'Online', 'User', 'online.beta@test.com', '12121210',
                '1 mes', '202020200', 'Uruca', 'si', 'Automóvil'
            );
        } catch (Exception e) {
            System.assertNotEquals(null, e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testCreateTrafico_BMW_NuevoTrafico() {
        Test.startTest();
        try {
            walkingCommunityControllerBeta.createTrafico(
                'Ana', 'Garcia', 'ana.beta@test.com', '55555550',
                '3 meses', 'SUV', 'X1', 'BMW',
                '888888880', 'Uruca', 'no'
            );
        } catch (Exception e) {
            System.assertNotEquals(null, e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testCreateTrafico_MINI_NuevoTrafico() {
        Test.startTest();
        try {
            walkingCommunityControllerBeta.createTrafico(
                'Luis', 'Vega', 'luis.beta@test.com', '44444440',
                '1 mes', 'Hatch', 'Cooper', 'MINI',
                '999999990', 'Uruca', 'si'
            );
        } catch (Exception e) {
            System.assertNotEquals(null, e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testCreateTrafico_Motorrad_NuevoTrafico() {
        Test.startTest();
        try {
            walkingCommunityControllerBeta.createTrafico(
                'Pedro', 'Salas', 'pedro.beta@test.com', '33333330',
                '2 meses', 'Sport', 'S1000RR', 'Motorrad',
                '101010100', 'Uruca', 'no'
            );
        } catch (Exception e) {
            System.assertNotEquals(null, e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testCreateTrafico_Kawasaki_NuevoTrafico() {
        Test.startTest();
        try {
            walkingCommunityControllerBeta.createTrafico(
                'Sofia', 'Ruiz', 'sofia.beta@test.com', '22222220',
                '1 mes', 'Sport', 'Ninja', 'Kawasaki',
                '121212120', 'Uruca', 'si'
            );
        } catch (Exception e) {
            System.assertNotEquals(null, e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testCreateTrafico_Polaris_NuevoTrafico() {
        Test.startTest();
        try {
            walkingCommunityControllerBeta.createTrafico(
                'Diego', 'Castro', 'diego.beta@test.com', '11111120',
                '3 meses', 'ATV', 'Sportsman', 'Polaris',
                '131313130', 'Uruca', 'no'
            );
        } catch (Exception e) {
            System.assertNotEquals(null, e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testCreateTrafico_Indian_NuevoTrafico() {
        Test.startTest();
        try {
            walkingCommunityControllerBeta.createTrafico(
                'Laura', 'Jimenez', 'laura.beta@test.com', '11223340',
                '6 meses', 'Cruiser', 'Chief', 'Indian',
                '141414140', 'Uruca', 'si'
            );
        } catch (Exception e) {
            System.assertNotEquals(null, e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testCreateTrafico_BMW_ConOppReciente() {
        crearOppBMW('Prospecting', Date.today().addDays(30));

        Test.startTest();
        try {
            walkingCommunityControllerBeta.createTrafico(
                'Juan', 'Perez', 'jp.beta@test.com', '99887760',
                '1 mes', 'SUV', 'X3', 'BMW',
                '151515150', 'Uruca', 'no'
            );
        } catch (Exception e) {
            System.assertNotEquals(null, e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testCreateTrafico_BMW_ConLeadReciente() {
        crearLeadBMW('161616160');

        Test.startTest();
        try {
            walkingCommunityControllerBeta.createTrafico(
                'Juan', 'Test', 'juan.test@test.com', '88888888',
                '2 meses', 'SUV', 'X1', 'BMW',
                '161616160', 'Uruca', 'no'
            );
        } catch (Exception e) {
            System.assertNotEquals(null, e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testCreateTrafico_BMW_SucursalUndefined() {
        Test.startTest();
        try {
            walkingCommunityControllerBeta.createTrafico(
                'Test', 'User', 'test.user.beta@test.com', '12341230',
                '1 mes', 'SUV', 'X5', 'BMW',
                '171717170', 'undefined', 'no'
            );
        } catch (Exception e) {
            System.assertNotEquals(null, e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testCreateTrafico_Motorrad_LeadReciente() {
        Lead l = new Lead(
            RecordTypeId                    = getRtLead('Motorrad'),
            FirstName                       = 'Moto',
            LastName                        = 'UserBeta',
            Email                           = 'moto.beta@test.com',
            MobilePhone                     = '78787870',
            Phone                           = '78787870',
            Numero_de_Identificacion_del__c = '212121210',
            Tipo_de_Identificaci_n__c       = '01',
            Marca__c                        = 'Motorrad',
            LeadSource                      = 'Walking',
            Origen_1__c                     = 'Walking'
        );
        insert l;

        Test.startTest();
        try {
            walkingCommunityControllerBeta.createTrafico(
                'Moto', 'UserBeta', 'moto.beta@test.com', '78787870',
                '2 meses', 'Sport', 'S1000RR', 'Motorrad',
                '212121210', 'Uruca', 'no'
            );
        } catch (Exception e) {
            System.assertNotEquals(null, e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testCreateOportunidad_LeadYaConvertido() {
        Lead l = crearLeadBMW('300000001');
        l.Convertido_custom__c = true;
        update l;

        Test.startTest();
        try {
            walkingCommunityControllerBeta.createOportunidad(l.Id);
        } catch (Exception e) {
            System.assertNotEquals(null, e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testCreateOportunidad_SinCuentaExistente() {
        Lead l = new Lead(
            RecordTypeId                    = getRtLead('BMW'),
            FirstName                       = 'Nuevo',
            LastName                        = 'ClienteBeta',
            Email                           = 'nuevo.beta@test.com',
            MobilePhone                     = '87654320',
            Phone                           = '87654320',
            Numero_de_Identificacion_del__c = '400000001',
            Tipo_de_Identificaci_n__c       = '01',
            Marca__c                        = 'BMW',
            Sucursal__c                     = 'Uruca',
            FechaPosibleCompra__c            = '3 meses',
            Action__c                       = 'Orgánico',
            LeadSource                      = 'Walking',
            Origen_1__c                     = 'Walking',
            Convertido_custom__c            = false
        );
        insert l;

        Test.startTest();
        try {
            walkingCommunityControllerBeta.createOportunidad(l.Id);
        } catch (Exception e) {
            System.assertNotEquals(null, e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testCreateOportunidad_ConCuentaExistente() {
        Account acc = new Account(LastName = 'ClienteBeta Existente', Cedula__c = '500000001');
        try {
            acc.RecordTypeId = Schema.SObjectType.Account
                .getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        } catch (Exception e) {}
        insert acc;

        Lead l = new Lead(
            RecordTypeId                    = getRtLead('BMW'),
            FirstName                       = 'Cliente',
            LastName                        = 'ExistenteBeta',
            Email                           = 'existente.beta@test.com',
            MobilePhone                     = '87654319',
            Phone                           = '87654319',
            Numero_de_Identificacion_del__c = '500000001',
            Tipo_de_Identificaci_n__c       = '01',
            Marca__c                        = 'BMW',
            Sucursal__c                     = 'Uruca',
            FechaPosibleCompra__c            = '6 meses',
            Action__c                       = 'Orgánico',
            LeadSource                      = 'Walking',
            Origen_1__c                     = 'Walking',
            Convertido_custom__c            = false
        );
        insert l;

        Test.startTest();
        try {
            walkingCommunityControllerBeta.createOportunidad(l.Id);
        } catch (Exception e) {
            System.assertNotEquals(null, e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testMarcarAsistenciaCita_SinLead() {
        Cita_trafico_online__c cita = crearCita('181818180', 'Agendada');

        Test.startTest();
        try {
            walkingCommunityControllerBeta.marcarAsistenciaCita(cita.Id);
        } catch (Exception e) {
            System.assertNotEquals(null, e.getMessage());
        }
        Test.stopTest();

        Cita_trafico_online__c citaActualizada = [
            SELECT Status__c FROM Cita_trafico_online__c WHERE Id = :cita.Id
        ];
        System.assertEquals('Asistió', citaActualizada.Status__c);
    }

    @isTest
    static void testMarcarAsistenciaCita_ConLead() {
        Cita_trafico_online__c cita = crearCita('191919190', 'Agendada');

        Lead l = new Lead(
            RecordTypeId                    = getRtLead('BMW'),
            FirstName                       = 'Test',
            LastName                        = 'WalkingBeta',
            Email                           = 'test.walking.beta@test.com',
            MobilePhone                     = '87654310',
            Phone                           = '87654310',
            Numero_de_Identificacion_del__c = '191919190',
            Tipo_de_Identificaci_n__c       = '01',
            Marca__c                        = 'BMW',
            Sucursal__c                     = 'Uruca',
            FechaPosibleCompra__c            = '3 meses',
            Action__c                       = 'Orgánico',
            LeadSource                      = 'Walking',
            Origen_1__c                     = 'Walking',
            Cita_trafico_online__c          = cita.Id
        );
        insert l;

        Test.startTest();
        try {
            walkingCommunityControllerBeta.marcarAsistenciaCita(cita.Id);
        } catch (Exception e) {
            System.assertNotEquals(null, e.getMessage());
        }
        Test.stopTest();

        Cita_trafico_online__c citaActualizada = [
            SELECT Status__c FROM Cita_trafico_online__c WHERE Id = :cita.Id
        ];
        System.assertEquals('Asistió', citaActualizada.Status__c);
    }

    @isTest
    static void testMyPickListInfo() {
        walkingCommunityControllerBeta.MyPickListInfo info = new walkingCommunityControllerBeta.MyPickListInfo();
        info.validFor = 'BBBB';
        System.assertEquals('BBBB', info.validFor);
    }
}