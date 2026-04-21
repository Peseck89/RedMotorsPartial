@IsTest
public class walkingCommunityController_test {

    private static String getPicklistValue(Schema.DescribeFieldResult fd) {
        for (Schema.PicklistEntry e : fd.getPicklistValues()) {
            if (e.isActive()) return e.getValue();
        }
        return null;
    }

    private static String getLeadPicklist(String f) {
        return getPicklistValue(
            Schema.SObjectType.Lead.fields.getMap().get(f).getDescribe());
    }

    private static final String MARCA_BMW   = 'BMW';
    private static final String FAMILIA_BMW = 'I3';
    private static final String MODELO_BMW  = 'BM175 - i3';

    @TestSetup
    static void setupTestData() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User loginUser = new User(
            FirstName = 'Login', LastName = 'User', Alias = 'lgnu',
            Email = 'loginuser@test.com', Username = 'loginuser_walking@test.org',
            ProfileId = p.Id, TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US'
        );
        insert loginUser;

        User adminUser = new User(
            FirstName = 'Admin', LastName = 'Test', Alias = 'admt',
            Email = 'admintest@test.com', Username = 'admintest_walking@test.org',
            ProfileId = p.Id, TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US'
        );
        insert adminUser;

        RecordType rtPA = [SELECT Id FROM RecordType
                           WHERE SobjectType = 'Account' AND DeveloperName = 'PersonAccount' LIMIT 1];
        Account acc = new Account(
            RecordTypeId = rtPA.Id, FirstName = 'Juan', LastName = 'Perez Test',
            PersonEmail = 'juanperez@test.com', Phone = '88001234', Cedula__c = '111111111'
        );
        insert acc;

        String rtBMW = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('BMW').getRecordTypeId();

        Lead leadBMW = new Lead(
            RecordTypeId = rtBMW, FirstName = 'Carlos', LastName = 'Garcia',
            Email = 'carlosgarcia@test.com', MobilePhone = '87001234', Phone = '87001234',
            Numero_de_Identificacion_del__c = '222222222', Convertido_custom__c = false,
            LeadSource = 'Walking', Status = 'Open',
            Codigo_de_Producto__c = '01u0P00000kPIZrQAO',
            Modelo_De_Inter_s1__c = MODELO_BMW,
            TDA__c = true, EsWeb2Lead_del__c = false, Ignorar_asignacion__c = true
        );
        Test.startTest();
        insert leadBMW;
        Test.stopTest();

        Lead leadBMWOld = new Lead(
            RecordTypeId = rtBMW, FirstName = 'Ana', LastName = 'Viejos',
            Email = 'anaviejos@test.com', MobilePhone = '86001234', Phone = '86001234',
            Numero_de_Identificacion_del__c = '333333333', Convertido_custom__c = false,
            LeadSource = 'Walking', Status = 'Open',
            Codigo_de_Producto__c = '01u0P00000kPIZrQAO',
            Modelo_De_Inter_s1__c = MODELO_BMW,
            TDA__c = true, EsWeb2Lead_del__c = false, Ignorar_asignacion__c = true
        );
        insert leadBMWOld;
        Test.setCreatedDate(leadBMWOld.Id, Date.today().addMonths(-8));

        String rtOppBMW = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('BMW').getRecordTypeId();
        Opportunity oppReciente = new Opportunity(
            RecordTypeId = rtOppBMW, AccountId = acc.Id, Name = 'Opp BMW Reciente',
            StageName = 'Oportunidad Calificada', CloseDate = Date.today().addDays(30)
        );
        insert oppReciente;

        Opportunity oppVieja = new Opportunity(
            RecordTypeId = rtOppBMW, AccountId = acc.Id, Name = 'Opp BMW Vieja',
            StageName = 'Oportunidad Calificada', CloseDate = Date.today().addDays(30)
        );
        insert oppVieja;
        Test.setCreatedDate(oppVieja.Id, Date.today().addMonths(-8));

        Cita_trafico_online__c cita = new Cita_trafico_online__c(
            Nombre__c = 'Juan Perez', Cedula__c = '111111111', Status__c = 'Agendada',
            Inicio__c = DateTime.now().addDays(1), Sucursal__c = 'Uruca'
        );
        insert cita;
    }

    @IsTest static void testGetModelos() {
        Test.startTest();
        Map<String, List<String>> result = walkingCommunityController.getModelos();
        Test.stopTest();
        System.assertNotEquals(null, result);
    }

    @IsTest static void testGetFieldDependencies() {
        Test.startTest();
        Map<String, List<String>> deps = walkingCommunityController.getFieldDependencies('Lead', 'Marca__c', 'Familia1__c');
        Test.stopTest();
        System.assertNotEquals(null, deps);
    }

    @IsTest static void testGetFamilia() {
        Test.startTest();
        List<AggregateResult> bmw  = walkingCommunityController.getFamilia('BMW');
        List<AggregateResult> mini = walkingCommunityController.getFamilia('MINI');
        Test.stopTest();
        System.assertNotEquals(null, bmw);
        System.assertNotEquals(null, mini);
    }

    @IsTest static void testGetVehiculos() {
        Test.startTest();
        List<Product2> vehiculos = walkingCommunityController.getVehiculos(null, 'BMW');
        Test.stopTest();
        System.assertNotEquals(null, vehiculos);
    }

    @IsTest static void testGetCedulaExistente() {
        Test.startTest();
        List<String> info = walkingCommunityController.getCedula('111111111');
        Test.stopTest();
        System.assert(info.contains('existe'));
    }

    @IsTest static void testGetCedulaNuevo() {
        Test.startTest();
        try {
            List<String> info = walkingCommunityController.getCedula('999999999');
            System.assertNotEquals(null, info);
        } catch (Exception e) { }
        Test.stopTest();
    }

    @IsTest static void testGetImagenes() {
        Test.startTest();
        Map<String, String> imagenes = walkingCommunityController.getImagenes(null, 'BMW');
        Test.stopTest();
        System.assertNotEquals(null, imagenes);
    }

    @IsTest static void testBuscarCitaPorCedula() {
        Test.startTest();
        List<Cita_trafico_online__c> citas       = walkingCommunityController.buscarCitaPorCedula('111111111');
        List<Cita_trafico_online__c> citasVacias = walkingCommunityController.buscarCitaPorCedula('');
        Test.stopTest();
        System.assertNotEquals(null, citas);
        System.assertEquals(0, citasVacias.size());
    }

    @IsTest static void testCreateTraficoBMWNuevo() {
        Test.startTest();
        walkingCommunityController.createTrafico('Pedro', 'Nuevo', 'pedronuevo@test.com', '85001234',
            '3 meses', FAMILIA_BMW, MODELO_BMW, MARCA_BMW, '444444444', 'Uruca', 'no');
        Test.stopTest();
        System.assert(![SELECT Id FROM Lead WHERE Numero_de_Identificacion_del__c = '444444444'].isEmpty());
    }

    @IsTest static void testCreateTraficoBMWActualiza() {
        Test.startTest();
        walkingCommunityController.createTrafico('Carlos', 'Garcia', 'carlosgarcia@test.com', '87001234',
            '1 mes', FAMILIA_BMW, MODELO_BMW, MARCA_BMW, '222222222', 'Uruca', 'si');
        Test.stopTest();
        System.assert(![SELECT Id FROM Lead WHERE Numero_de_Identificacion_del__c = '222222222'].isEmpty());
    }

    @IsTest static void testCreateTraficoBMWConOppReciente() {
        Test.startTest();
        walkingCommunityController.createTrafico('Juan', 'Perez Test', 'juanperez@test.com', '88001234',
            '2 meses', FAMILIA_BMW, MODELO_BMW, MARCA_BMW, '111111111', 'Uruca', 'no');
        Test.stopTest();
        System.assert(![SELECT Id FROM Task WHERE Subject = 'Walking'].isEmpty(), 'Debe crear Task de Walking');
    }

    @IsTest static void testCreateTraficoBMWConOppVieja() {
        RecordType rtPA = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'PersonAccount' LIMIT 1];
        Account acc2 = new Account(RecordTypeId = rtPA.Id, FirstName = 'Viejo', LastName = 'Cliente',
            PersonEmail = 'viejocliente@test.com', Phone = '70001234', Cedula__c = '171717171');
        insert acc2;
        Opportunity opp = new Opportunity(
            RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('BMW').getRecordTypeId(),
            AccountId = acc2.Id, Name = 'Opp BMW Vieja 2',
            StageName = 'Oportunidad Calificada', CloseDate = Date.today().addDays(30));
        insert opp;
        Test.setCreatedDate(opp.Id, Date.today().addMonths(-8));
        Test.startTest();
        walkingCommunityController.createTrafico('Viejo', 'Cliente', 'viejocliente@test.com', '70001234',
            '3 meses', FAMILIA_BMW, MODELO_BMW, MARCA_BMW, '171717171', 'Uruca', 'no');
        Test.stopTest();
        System.assert(![SELECT Id FROM Lead WHERE Numero_de_Identificacion_del__c = '171717171'].isEmpty());
    }

    @IsTest static void testCreateTraficoMotorrad() {
        Test.startTest();
        walkingCommunityController.createTrafico('Moto', 'Rider', 'motorider@test.com', '84001234',
            '6 meses', FAMILIA_BMW, MODELO_BMW, 'Motorrad', '555555555', 'Uruca', 'no');
        Test.stopTest();
        System.assert(![SELECT Id FROM Lead WHERE Numero_de_Identificacion_del__c = '555555555'].isEmpty());
    }

    @IsTest static void testCreateTraficoKawasaki() {
        Test.startTest();
        walkingCommunityController.createTrafico('Kawa', 'Saki', 'kawasaki@test.com', '83001234',
            '3 meses', FAMILIA_BMW, MODELO_BMW, 'Kawasaki', '666666666', 'Uruca', 'si');
        Test.stopTest();
        System.assert(![SELECT Id FROM Lead WHERE Numero_de_Identificacion_del__c = '666666666'].isEmpty());
    }

    @IsTest static void testCreateTraficoPolaris() {
        Test.startTest();
        walkingCommunityController.createTrafico('Pola', 'Ris', 'polaris@test.com', '82001234',
            '3 meses', FAMILIA_BMW, MODELO_BMW, 'Polaris', '777777777', 'Uruca', 'no');
        Test.stopTest();
        System.assert(![SELECT Id FROM Lead WHERE Numero_de_Identificacion_del__c = '777777777'].isEmpty());
    }

    @IsTest static void testCreateTraficoIndian() {
        Test.startTest();
        walkingCommunityController.createTrafico('India', 'Nian', 'indian@test.com', '81001234',
            '1 mes', FAMILIA_BMW, MODELO_BMW, 'Indian', '888888888', 'Uruca', 'si');
        Test.stopTest();
        System.assert(![SELECT Id FROM Lead WHERE Numero_de_Identificacion_del__c = '888888888'].isEmpty());
    }

    @IsTest static void testCreateTraficoMINI() {
        Test.startTest();
        walkingCommunityController.createTrafico('Mini', 'Cooper', 'minicooper@test.com', '80001234',
            '2 meses', FAMILIA_BMW, MODELO_BMW, 'MINI', '121212121', 'Uruca', 'no');
        Test.stopTest();
        System.assert(![SELECT Id FROM Lead WHERE Numero_de_Identificacion_del__c = '121212121'].isEmpty());
    }

    @IsTest static void testCreateTraficoUsadosNuevo() {
        Test.startTest();
        walkingCommunityController.createTraficoUsados('Luis', 'Usados', 'luisusados@test.com', '79001234',
            '3 meses', '131313131', 'Uruca', 'no', 'Sedán');
        Test.stopTest();
        System.assert(![SELECT Id FROM Lead WHERE Numero_de_Identificacion_del__c = '131313131'].isEmpty());
    }

    @IsTest static void testCreateTraficoUsadosOnline() {
        Test.startTest();
        walkingCommunityController.createTraficoUsados('Maria', 'Online', 'mariaonline@test.com', '78001234',
            '1 mes', '141414141', 'Uruca', 'si', 'SUV');
        Test.stopTest();
        System.assert(![SELECT Id FROM Lead WHERE Numero_de_Identificacion_del__c = '141414141'].isEmpty());
    }

    @IsTest static void testCreateOportunidad() {
        Lead leadBMW = [SELECT Id FROM Lead WHERE Numero_de_Identificacion_del__c = '222222222' LIMIT 1];
        Test.startTest();
        walkingCommunityController.createOportunidad(leadBMW.Id);
        Test.stopTest();
        System.assert(![SELECT Id FROM Opportunity WHERE Trafico__c = :leadBMW.Id].isEmpty());
        System.assertEquals(true, [SELECT Convertido_custom__c FROM Lead WHERE Id = :leadBMW.Id].Convertido_custom__c);
    }

    @IsTest static void testCreateOportunidadYaConvertido() {
        Lead leadBMW = [SELECT Id FROM Lead WHERE Numero_de_Identificacion_del__c = '222222222' LIMIT 1];
        leadBMW.Convertido_custom__c = true;
        update leadBMW;
        Test.startTest();
        walkingCommunityController.createOportunidad(leadBMW.Id);
        Test.stopTest();
        System.assertEquals(0, [SELECT Id FROM Opportunity WHERE Trafico__c = :leadBMW.Id].size());
    }

    @IsTest static void testCreateOportunidadCuentaExistente() {
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry LIMIT 1];
        String rtBMW = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('BMW').getRecordTypeId();
        Lead l = new Lead(RecordTypeId = rtBMW, FirstName = 'Juan', LastName = 'Perez Test',
            Email = 'juanperez2@test.com', MobilePhone = '88001235', Phone = '88001235',
            Numero_de_Identificacion_del__c = '111111111', Convertido_custom__c = false,
            LeadSource = 'Walking', Status = 'Open', Codigo_de_Producto__c = pbe.Id,
            Marca__c = MARCA_BMW, Familia1__c = FAMILIA_BMW, Modelo_De_Inter_s1__c = MODELO_BMW);
        insert l;
        Test.startTest();
        walkingCommunityController.createOportunidad(l.Id);
        Test.stopTest();
        System.assert(![SELECT Id FROM Opportunity WHERE Trafico__c = :l.Id].isEmpty());
    }

    @IsTest static void testMarcarAsistenciaCita() {
        Cita_trafico_online__c cita = [SELECT Id FROM Cita_trafico_online__c WHERE Cedula__c = '111111111' LIMIT 1];
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry LIMIT 1];
        String rtBMW = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('BMW').getRecordTypeId();
        Lead leadCita = new Lead(RecordTypeId = rtBMW, FirstName = 'Cita', LastName = 'Lead',
            Email = 'citlalead@test.com', MobilePhone = '88001236', Phone = '88001236',
            Numero_de_Identificacion_del__c = '151515151', Cita_trafico_online__c = cita.Id,
            Status = 'Open', Convertido_custom__c = false, LeadSource = 'Walking',
            Codigo_de_Producto__c = pbe.Id, Marca__c = MARCA_BMW,
            Familia1__c = FAMILIA_BMW, Modelo_De_Inter_s1__c = MODELO_BMW);
        insert leadCita;
        Test.startTest();
        walkingCommunityController.marcarAsistenciaCita(cita.Id);
        Test.stopTest();
        System.assertEquals('Asistio', [SELECT Status__c FROM Cita_trafico_online__c WHERE Id = :cita.Id].Status__c);
    }

    @IsTest static void testMarcarAsistenciaSinLead() {
        Cita_trafico_online__c citaSinLead = new Cita_trafico_online__c(
            Nombre__c = 'Sin Lead', Cedula__c = '161616161', Status__c = 'Agendada',
            Inicio__c = DateTime.now().addDays(2), Sucursal__c = 'Uruca');
        insert citaSinLead;
        Test.startTest();
        walkingCommunityController.marcarAsistenciaCita(citaSinLead.Id);
        Test.stopTest();
        System.assertEquals('Asistio', [SELECT Status__c FROM Cita_trafico_online__c WHERE Id = :citaSinLead.Id].Status__c);
    }

    @IsTest static void testCreateTraficoBMWOppMedia() {
        RecordType rtPA = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'PersonAccount' LIMIT 1];
        Account acc = new Account(RecordTypeId = rtPA.Id, FirstName = 'Media', LastName = 'Opp',
            PersonEmail = 'mediaopp@test.com', Phone = '70002222', Cedula__c = '181818181');
        insert acc;
        Opportunity opp = new Opportunity(
            RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('BMW').getRecordTypeId(),
            AccountId = acc.Id, Name = 'Opp Media BMW', StageName = 'Oportunidad Calificada',
            CloseDate = Date.today().addDays(30));
        insert opp;
        Test.setCreatedDate(opp.Id, Date.today().addMonths(-4));
        Test.startTest();
        walkingCommunityController.createTrafico('Media', 'Opp', 'mediaopp@test.com', '70002222',
            '3 meses', FAMILIA_BMW, MODELO_BMW, MARCA_BMW, '181818181', 'Uruca', 'no');
        Test.stopTest();
        System.assert(![SELECT Id FROM Lead WHERE Numero_de_Identificacion_del__c = '181818181'].isEmpty());
    }

    @IsTest static void testCreateTraficoBMWOppMediaLeadViejo() {
        RecordType rtPA = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'PersonAccount' LIMIT 1];
        Account acc = new Account(RecordTypeId = rtPA.Id, FirstName = 'Medio', LastName = 'LeadViejo',
            PersonEmail = 'medioleadviejo@test.com', Phone = '70003333', Cedula__c = '191919191');
        insert acc;
        String rtBMW = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('BMW').getRecordTypeId();
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry LIMIT 1];
        Lead leadViejo = new Lead(RecordTypeId = rtBMW, FirstName = 'Medio', LastName = 'LeadViejo',
            Email = 'medioleadviejo@test.com', MobilePhone = '70003333', Phone = '70003333',
            Numero_de_Identificacion_del__c = '191919191', Convertido_custom__c = false,
            LeadSource = 'Walking', Status = 'Open', Codigo_de_Producto__c = pbe.Id,
            Marca__c = MARCA_BMW, Familia1__c = FAMILIA_BMW, Modelo_De_Inter_s1__c = MODELO_BMW);
        insert leadViejo;
        Test.setCreatedDate(leadViejo.Id, Date.today().addMonths(-8));
        Opportunity opp = new Opportunity(
            RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('BMW').getRecordTypeId(),
            AccountId = acc.Id, Name = 'Opp Media LeadViejo', StageName = 'Oportunidad Calificada',
            CloseDate = Date.today().addDays(30));
        insert opp;
        Test.setCreatedDate(opp.Id, Date.today().addMonths(-4));
        Test.startTest();
        walkingCommunityController.createTrafico('Medio', 'LeadViejo', 'medioleadviejo@test.com', '70003333',
            '3 meses', FAMILIA_BMW, MODELO_BMW, MARCA_BMW, '191919191', 'Uruca', 'no');
        Test.stopTest();
        System.assert(![SELECT Id FROM Lead WHERE Numero_de_Identificacion_del__c = '191919191' ORDER BY CreatedDate DESC].isEmpty());
    }

    @IsTest static void testCreateTraficoUsadosOppReciente() {
        RecordType rtPA = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'PersonAccount' LIMIT 1];
        Account acc = new Account(RecordTypeId = rtPA.Id, FirstName = 'Usados', LastName = 'Reciente',
            PersonEmail = 'usadosreciente@test.com', Phone = '70004444', Cedula__c = '201010101');
        insert acc;
        Opportunity opp = new Opportunity(
            RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Autos usados').getRecordTypeId(),
            AccountId = acc.Id, Name = 'Opp Usados Reciente', StageName = 'Oportunidad Calificada',
            CloseDate = Date.today().addDays(30));
        insert opp;
        Test.startTest();
        walkingCommunityController.createTraficoUsados('Usados', 'Reciente', 'usadosreciente@test.com', '70004444',
            '1 mes', '201010101', 'Uruca', 'no', 'Sedán');
        Test.stopTest();
        System.assert(![SELECT Id FROM Task WHERE Subject = 'Walking'].isEmpty());
    }

    @IsTest static void testCreateTraficoUsadosOppVieja() {
        RecordType rtPA = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'PersonAccount' LIMIT 1];
        Account acc = new Account(RecordTypeId = rtPA.Id, FirstName = 'Usados', LastName = 'Viejo',
            PersonEmail = 'usadosviejo@test.com', Phone = '70005555', Cedula__c = '202020202');
        insert acc;
        Opportunity opp = new Opportunity(
            RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Autos usados').getRecordTypeId(),
            AccountId = acc.Id, Name = 'Opp Usados Vieja', StageName = 'Oportunidad Calificada',
            CloseDate = Date.today().addDays(30));
        insert opp;
        Test.setCreatedDate(opp.Id, Date.today().addMonths(-8));
        Test.startTest();
        walkingCommunityController.createTraficoUsados('Usados', 'Viejo', 'usadosviejo@test.com', '70005555',
            '3 meses', '202020202', 'Uruca', 'no', 'Pickup');
        Test.stopTest();
        System.assert(![SELECT Id FROM Lead WHERE Numero_de_Identificacion_del__c = '202020202'].isEmpty());
    }

    @IsTest static void testCreateTraficoUsadosConLeadReciente() {
        String rtUsados = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Autos Usados').getRecordTypeId();
        Lead leadUsados = new Lead(RecordTypeId = rtUsados, FirstName = 'Usados', LastName = 'ConLead',
            Email = 'usadosconlead@test.com', MobilePhone = '70006666', Phone = '70006666',
            Numero_de_Identificacion_del__c = '203030303', Convertido_custom__c = false,
            LeadSource = 'Walking Usados', Status = 'Open', Tipo_Vehiculo_Usados__c = 'Sedán',
            Codigo_de_Producto__c = 'TEST001');
        insert leadUsados;
        Test.startTest();
        walkingCommunityController.createTraficoUsados('Usados', 'ConLead', 'usadosconlead@test.com', '70006666',
            '2 meses', '203030303', 'Uruca', 'no', 'Sedán');
        Test.stopTest();
        System.assert(![SELECT Id FROM Registro_WalkIn__c WHERE Trafico__c = :leadUsados.Id].isEmpty());
    }

    @IsTest static void testCreateTraficoUsadosConLeadViejo() {
        String rtUsados = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Autos Usados').getRecordTypeId();
        Lead leadViejoUsados = new Lead(RecordTypeId = rtUsados, FirstName = 'Usados', LastName = 'LeadViejo',
            Email = 'usadosleadviejo@test.com', MobilePhone = '70007777', Phone = '70007777',
            Numero_de_Identificacion_del__c = '204040404', Convertido_custom__c = false,
            LeadSource = 'Walking Usados', Status = 'Open', Tipo_Vehiculo_Usados__c = 'SUV',
            Codigo_de_Producto__c = 'TEST001');
        insert leadViejoUsados;
        Test.setCreatedDate(leadViejoUsados.Id, Date.today().addMonths(-8));
        Test.startTest();
        walkingCommunityController.createTraficoUsados('Usados', 'LeadViejo', 'usadosleadviejo@test.com', '70007777',
            '3 meses', '204040404', 'Uruca', 'si', 'SUV');
        Test.stopTest();
        System.assert(![SELECT Id FROM Lead WHERE Numero_de_Identificacion_del__c = '204040404' ORDER BY CreatedDate DESC].isEmpty());
    }

    @IsTest static void testCreateTraficoUsadosActualiza() {
        String rtUsados = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Autos Usados').getRecordTypeId();
        Lead leadExistente = new Lead(RecordTypeId = rtUsados, FirstName = 'Actualiza', LastName = 'Usados',
            Email = 'actualizausados@test.com', MobilePhone = '70008888', Phone = '70008888',
            Numero_de_Identificacion_del__c = '205050505', Convertido_custom__c = false,
            LeadSource = 'Walking Usados', Status = 'Open', Tipo_Vehiculo_Usados__c = 'Pickup',
            Codigo_de_Producto__c = 'TEST001');
        insert leadExistente;
        Test.startTest();
        walkingCommunityController.createTraficoUsados('Actualiza', 'Usados', 'actualizausados@test.com', '70008888',
            '1 mes', '205050505', 'Uruca', 'no', 'Pickup');
        Test.stopTest();
        System.assertEquals(1, [SELECT Id FROM Lead WHERE Numero_de_Identificacion_del__c = '205050505'].size());
    }

    @IsTest static void testCreateOportunidadCedulaDIMEX() {
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry LIMIT 1];
        String rtBMW = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('BMW').getRecordTypeId();
        Lead l = new Lead(RecordTypeId = rtBMW, FirstName = 'Dimex', LastName = 'Test',
            Email = 'dimextest@test.com', MobilePhone = '70009999', Phone = '70009999',
            Numero_de_Identificacion_del__c = '123456789012', Convertido_custom__c = false,
            LeadSource = 'Walking', Status = 'Open', Codigo_de_Producto__c = pbe.Id,
            Marca__c = MARCA_BMW, Familia1__c = FAMILIA_BMW, Modelo_De_Inter_s1__c = MODELO_BMW);
        insert l;
        Test.startTest();
        walkingCommunityController.createOportunidad(l.Id);
        Test.stopTest();
        List<Account> accs = [SELECT Tipo_de_Documento__c FROM Account WHERE Cedula__c = '123456789012' LIMIT 1];
        System.assert(!accs.isEmpty());
        System.assertEquals('03', accs[0].Tipo_de_Documento__c);
    }

    @IsTest static void testCreateOportunidadCedulaNITE() {
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry LIMIT 1];
        String rtBMW = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('BMW').getRecordTypeId();
        Lead l = new Lead(RecordTypeId = rtBMW, FirstName = 'Nite', LastName = 'Test',
            Email = 'nitetest@test.com', MobilePhone = '70001111', Phone = '70001111',
            Numero_de_Identificacion_del__c = '12345678', Convertido_custom__c = false,
            LeadSource = 'Walking', Status = 'Open', Codigo_de_Producto__c = pbe.Id,
            Marca__c = MARCA_BMW, Familia1__c = FAMILIA_BMW, Modelo_De_Inter_s1__c = MODELO_BMW);
        insert l;
        Test.startTest();
        walkingCommunityController.createOportunidad(l.Id);
        Test.stopTest();
        List<Account> accs = [SELECT Tipo_de_Documento__c FROM Account WHERE Cedula__c = '12345678' LIMIT 1];
        System.assert(!accs.isEmpty());
        System.assertEquals('04', accs[0].Tipo_de_Documento__c);
    }
}
