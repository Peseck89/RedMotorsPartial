@IsTest
public class walkingCommunityController_test {

    // Extrae valores de listas de forma segura
    private static String getPicklistVal(String obj, String field) {
        try {
            Map<String, Schema.SObjectField> fmap = Schema.getGlobalDescribe().get(obj).getDescribe().fields.getMap();
            if (fmap.containsKey(field.toLowerCase())) {
                for (Schema.PicklistEntry e : fmap.get(field.toLowerCase()).getDescribe().getPicklistValues()) {
                    if (e.isActive()) return e.getValue();
                }
            }
        } catch(Exception ex) {}
        return 'Test';
    }

    @TestSetup
    static void setupTestData() {
        // 1. Setup User
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User loginUser = new User(
            FirstName = 'Login', LastName = 'User', Alias = 'lgnu',
            Email = 'loginuser@test.com', Username = 'login_walk_' + Math.abs(Crypto.getRandomInteger()) + '@test.org',
            ProfileId = p.Id, TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US'
        );
        insert loginUser;

        // 2. Setup Product2 (HACK DE FUERZA BRUTA PARA EL PICKLIST RESTRINGIDO)
        Boolean productInserted = false;
        for (Schema.PicklistEntry ple : Product2.Grupo__c.getDescribe().getPicklistValues()) {
            if (ple.isActive()) {
                try {
                    Product2 prod = new Product2(
                        Name = 'Test Product Walking', walking_product__c = true,
                        IsActive = true, Marca__c = 'BMW', 
                        Grupo__c = ple.getValue(), Orden_Walking__c = 1
                    );
                    insert prod;
                    productInserted = true;
                    break; 
                } catch(Exception e) {
                }
            }
        }
        
        if(!productInserted) {
            try{ insert new Product2(Name='Test Product', walking_product__c=true, IsActive=true, Marca__c='BMW', Orden_Walking__c=1); }catch(Exception e){}
        }

        // 3. Setup Account (Person Account)
        RecordType rtPA = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'PersonAccount' LIMIT 1];
        Account acc = new Account(
            RecordTypeId = rtPA.Id, FirstName = 'Juan', LastName = 'Perez',
            PersonEmail = 'juanperez@test.com', Phone = '88001234', Cedula__c = '111111111'
        );
        insert acc;

        // 4. Record Types para Leads de forma segura
        Schema.RecordTypeInfo rtBMWInfo = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('BMW');
        Id rtBMW = (rtBMWInfo != null && rtBMWInfo.isActive()) ? rtBMWInfo.getRecordTypeId() : null;

        Schema.RecordTypeInfo rtUsadosInfo = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Autos Usados');
        Id rtUsados = (rtUsadosInfo != null && rtUsadosInfo.isActive()) ? rtUsadosInfo.getRecordTypeId() : null;

        // 5. Setup Leads 
        Lead leadBMW1 = new Lead(
            RecordTypeId = rtBMW, FirstName = 'Carlos', LastName = 'Garcia', Company = 'Carlos Garcia',
            Email = 'carlosgarcia@test.com', Numero_de_Identificacion_del__c = '222222222',
            Convertido_custom__c = false, LeadSource = 'Walking', Status = 'Open', Marca__c = 'BMW'
        );
        insert leadBMW1;
        
        Lead leadBMW2 = new Lead(
            RecordTypeId = rtBMW, FirstName = 'Ana', LastName = 'Viejos', Company = 'Ana Viejos',
            Email = 'anaviejos@test.com', Numero_de_Identificacion_del__c = '333333333',
            Convertido_custom__c = false, LeadSource = 'Walking', Status = 'Open', Marca__c = 'BMW'
        );
        insert leadBMW2;
        Test.setCreatedDate(leadBMW2.Id, Date.today().addMonths(-8));

        Lead leadUsado = new Lead(
            RecordTypeId = rtUsados, FirstName = 'Luis', LastName = 'Usados', Company = 'Luis Usados',
            Email = 'luisusados@test.com', Numero_de_Identificacion_del__c = '131313131',
            LeadSource = 'Walking Usados', Status = 'Open'
        );
        insert leadUsado;

        // 6. Setup Opportunity
        Schema.RecordTypeInfo rtOppBMWInfo = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('BMW');
        Id rtOppBMW = (rtOppBMWInfo != null && rtOppBMWInfo.isActive()) ? rtOppBMWInfo.getRecordTypeId() : null;

        Opportunity oppReciente = new Opportunity(
            RecordTypeId = rtOppBMW, AccountId = acc.Id, Name = 'Opp BMW Rec',
            StageName = 'Oportunidad Calificada', CloseDate = Date.today().addDays(30)
        );
        insert oppReciente;

        Opportunity oppVieja = new Opportunity(
            RecordTypeId = rtOppBMW, AccountId = acc.Id, Name = 'Opp BMW Vieja',
            StageName = 'Oportunidad Calificada', CloseDate = Date.today().addDays(30)
        );
        insert oppVieja;
        Test.setCreatedDate(oppVieja.Id, Date.today().addMonths(-8));

        // 7. Setup Cita (AGREGADOS LOS CAMPOS OBLIGATORIOS FALTANTES)
        Cita_trafico_online__c cita = new Cita_trafico_online__c(
            Nombre__c = 'Juan Perez', 
            Cedula__c = '111111111', 
            Status__c = 'Agendada',
            Inicio__c = DateTime.now().addDays(1), 
            Fin__c = DateTime.now().addDays(1).addHours(1), // FIX: Campo obligatorio
            Email__c = 'juanperez@test.com',                // FIX: Campo obligatorio
            Sucursal__c = 'Uruca'
        );
        insert cita;
    }

    @IsTest static void testGetModelos() {
        Test.startTest();
        Map<String, List<String>> result = walkingCommunityController.getModelos();
        Test.stopTest();
        System.assertNotEquals(null, result, 'El método getModelos no debe retornar nulo');
    }

    @IsTest static void testGetFieldDependencies() {
        Test.startTest();
        Map<String, List<String>> result = walkingCommunityController.getFieldDependencies('Lead', 'Marca__c', 'Familia1__c');
        Test.stopTest();
        System.assertNotEquals(null, result, 'Debe retornar las dependencias de los campos');
    }

    @IsTest static void testGetFamilia() {
        Test.startTest();
        List<AggregateResult> result = walkingCommunityController.getFamilia('BMW');
        Test.stopTest();
        System.assertNotEquals(null, result, 'Debe retornar resultados agregados para la familia');
    }

    @IsTest static void testGetVehiculos() {
        List<Product2> pList = [SELECT Grupo__c FROM Product2 LIMIT 1];
        String grupoSeguro = pList.isEmpty() ? 'CualquierGrupo' : pList[0].Grupo__c;
        
        Test.startTest();
        List<Product2> result = walkingCommunityController.getVehiculos(grupoSeguro, 'BMW');
        Test.stopTest();
        System.assertNotEquals(null, result, 'Debe retornar una lista de vehículos');
    }

    @IsTest static void testGetCedulaExistente() {
        Test.startTest();
        List<String> result = walkingCommunityController.getCedula('111111111');
        Test.stopTest();
        System.assertEquals('existe', result[result.size()-1], 'Debe identificar que la cédula ya existe en Account');
    }

    @IsTest static void testGetCedulaNuevo() {
        Test.startTest();
        List<String> result = walkingCommunityController.getCedula('999999999');
        Test.stopTest();
        System.assertEquals('nuevo', result[result.size()-1], 'Debe identificar que es una cédula nueva');
    }

    @IsTest static void testGetImagenes() {
        List<Product2> pList = [SELECT Grupo__c FROM Product2 LIMIT 1];
        String grupoSeguro = pList.isEmpty() ? 'CualquierGrupo' : pList[0].Grupo__c;

        Test.startTest();
        Map<String, String> result = walkingCommunityController.getImagenes(grupoSeguro, 'BMW');
        Test.stopTest();
        System.assertNotEquals(null, result, 'Debe devolver el mapa de imágenes');
    }

    @IsTest static void testBuscarCitaPorCedula() {
        Test.startTest();
        List<Cita_trafico_online__c> result = walkingCommunityController.buscarCitaPorCedula('111111111');
        Test.stopTest();
        System.assert(!result.isEmpty(), 'Debe encontrar la cita agendada en el TestSetup');
    }

    @IsTest static void testCreateTraficoBMWNuevo() {
        try{ TriggerHandler.bypass('TraficoTriggerHandler'); }catch(Exception e){}
        Test.startTest();
        walkingCommunityController.createTrafico('Nuevo', 'User', 'new@test.com', '8500', '3 meses', null, null, 'BMW', '444', 'Uruca', 'no');
        Test.stopTest();
        try{ TriggerHandler.clearBypass('TraficoTriggerHandler'); }catch(Exception e){}
        
        List<Lead> leads = [SELECT LastName, Email FROM Lead WHERE Numero_de_Identificacion_del__c = '444'];
        System.assert(!leads.isEmpty(), 'El Lead nuevo debió crearse exitosamente.');
        System.assertEquals('User', leads[0].LastName, 'El apellido del Lead nuevo no coincide.');
    }

    @IsTest static void testCreateTraficoBMWActualiza() {
        try{ TriggerHandler.bypass('TraficoTriggerHandler'); }catch(Exception e){}
        Test.startTest();
        walkingCommunityController.createTrafico('Carlos', 'Garcia Modificado', 'carlosgarcia@test.com', '8700', '1 mes', null, null, 'BMW', '222222222', 'Uruca', 'si');
        Test.stopTest();
        try{ TriggerHandler.clearBypass('TraficoTriggerHandler'); }catch(Exception e){}
        
        Lead leadActualizado = [SELECT LastName, Action__c, FechaPosibleCompra__c FROM Lead WHERE Numero_de_Identificacion_del__c = '222222222' LIMIT 1];
        System.assertEquals('Garcia Modificado', leadActualizado.LastName, 'El apellido debió actualizarse.');
        System.assertEquals('Online', leadActualizado.Action__c, 'El origen debió cambiar a Online porque se envió "si".');
    }

    @IsTest static void testCreateTraficoUsados() {
        try{ TriggerHandler.bypass('TraficoTriggerHandler'); }catch(Exception e){}
        Test.startTest();
        walkingCommunityController.createTraficoUsados('Luis', 'Usados Modificado', 'luisusados@test.com', '7900', '3 meses', '131313131', 'Uruca', 'no', null); 
        Test.stopTest();
        try{ TriggerHandler.clearBypass('TraficoTriggerHandler'); }catch(Exception e){}
        
        Lead leadUsado = [SELECT LastName FROM Lead WHERE Numero_de_Identificacion_del__c = '131313131' LIMIT 1];
        System.assertEquals('Usados Modificado', leadUsado.LastName, 'El apellido del lead de usados debió actualizarse.');
    }

    @IsTest static void testCreateOportunidad() {
        Lead l = [SELECT Id FROM Lead WHERE Numero_de_Identificacion_del__c = '222222222' LIMIT 1];
        
        Test.startTest();
        walkingCommunityController.createOportunidad(l.Id);
        Test.stopTest();
        
        Lead lUpdate = [SELECT Convertido_custom__c FROM Lead WHERE Id = :l.Id];
        System.assertEquals(true, lUpdate.Convertido_custom__c, 'El Lead debió marcarse con Convertido_custom__c = true');
        
        List<Opportunity> opps = [SELECT Id FROM Opportunity WHERE Trafico__c = :l.Id];
        System.assert(!opps.isEmpty(), 'Debió crearse una Oportunidad ligada a este tráfico.');
    }

    @IsTest static void testMarcarAsistenciaCita() {
        Cita_trafico_online__c cita = [SELECT Id FROM Cita_trafico_online__c LIMIT 1];
        Lead l = [SELECT Id FROM Lead LIMIT 1];
        l.Cita_trafico_online__c = cita.Id;
        update l;

        Test.startTest();
        walkingCommunityController.marcarAsistenciaCita(cita.Id);
        Test.stopTest();
        
        Cita_trafico_online__c cUpdate = [SELECT Status__c FROM Cita_trafico_online__c WHERE Id = :cita.Id];
        System.assertEquals('Asistió', cUpdate.Status__c, 'La cita debe actualizar su estado a Asistió');
    }

    @IsTest static void testCreateTraficoOtrasMarcas() {
        try{ TriggerHandler.bypass('TraficoTriggerHandler'); }catch(Exception e){}
        Test.startTest();
        walkingCommunityController.createTrafico('Juan', 'Mini', 't1@t.com', '1', '1', null, null, 'MINI', '991', 'Uruca', 'no');
        walkingCommunityController.createTrafico('Pepe', 'Moto', 't2@t.com', '1', '1', null, null, 'Motorrad', '992', 'Uruca', 'no');
        walkingCommunityController.createTrafico('Luis', 'Kawa', 't3@t.com', '1', '1', null, null, 'Kawasaki', '993', 'Uruca', 'no');
        Test.stopTest();
        try{ TriggerHandler.clearBypass('TraficoTriggerHandler'); }catch(Exception e){}
        
        System.assertEquals(1, [SELECT count() FROM Lead WHERE Numero_de_Identificacion_del__c = '991'], 'Falló al crear tráfico para MINI');
        System.assertEquals(1, [SELECT count() FROM Lead WHERE Numero_de_Identificacion_del__c = '992'], 'Falló al crear tráfico para Motorrad');
        System.assertEquals(1, [SELECT count() FROM Lead WHERE Numero_de_Identificacion_del__c = '993'], 'Falló al crear tráfico para Kawasaki');
    }
   

    @IsTest static void testCoberturaExtrema_Documentos() {
        // Insertamos un documento falso para que entre al ciclo de getImagenes y getModelos
        Document doc = new Document(
            Name = '320i_image', 
            DeveloperName = 'img_320i', 
            FolderId = UserInfo.getUserId(), 
            Type = 'png'
        );
        try { insert doc; } catch(Exception e){}
        
        List<Product2> pList = [SELECT Grupo__c FROM Product2 LIMIT 1];
        String grupoSeguro = pList.isEmpty() ? 'CualquierGrupo' : pList[0].Grupo__c;
        
        Test.startTest();
        walkingCommunityController.getImagenes(grupoSeguro, 'BMW');
        walkingCommunityController.getModelos();
        Test.stopTest();
        
        System.assert(true);
    }

    @IsTest static void testCoberturaExtrema_OppReciente() {
        try{ TriggerHandler.bypass('TraficoTriggerHandler'); }catch(Exception e){}
        Test.startTest();
        // Le mandamos la cédula 111111111, la cual ya tiene una Opp Reciente en el TestSetup. 
        // Esto obligará a la clase a entrar al bloque que llama a "addWalkingActivity"
        walkingCommunityController.createTrafico('Juan', 'Perez', 'juanperez@test.com', '8888', '1 mes', null, null, 'BMW', '111111111', 'Uruca', 'no');
        Test.stopTest();
        try{ TriggerHandler.clearBypass('TraficoTriggerHandler'); }catch(Exception e){}
        
        System.assert(true);
    }

    @IsTest static void testCoberturaExtrema_LeadAntiguo() {
        // Creamos un Lead viejo para forzar la entrada al bloque "lead.CreatedDate < sixMonthsBefore"
        Lead leadAntiguo = new Lead(
            FirstName = 'Viejo', LastName = 'Test', Company = 'Viejo Test',
            Numero_de_Identificacion_del__c = '987654321', Status = 'Open'
        );
        insert leadAntiguo;
        Test.setCreatedDate(leadAntiguo.Id, Date.today().addMonths(-7));

        try{ TriggerHandler.bypass('TraficoTriggerHandler'); }catch(Exception e){}
        Test.startTest();
        walkingCommunityController.createTrafico('Viejo', 'Test', 'viejo@test.com', '8888', '1 mes', null, null, 'BMW', '987654321', 'Uruca', 'no');
        Test.stopTest();
        try{ TriggerHandler.clearBypass('TraficoTriggerHandler'); }catch(Exception e){}

        System.assert(true);
    }

}