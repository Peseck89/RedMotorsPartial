@IsTest
private class UpdateAvaluoOnOpportunityChangeTest {

    // Método para crear datos de prueba comunes
    @TestSetup
    static void setupTestData() {
        // Crear 2 avalúos
        List<Avaluo__c> avaluos = new List<Avaluo__c>{
            new Avaluo__c(Name = 'Avalúo 1'),
            new Avaluo__c(Name = 'Avalúo 2')
        };
        insert avaluos;

        // Crear oportunidad vinculada al primer avalúo
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            Avaluo_Vinculado__c = avaluos[0].Id
        );
        insert opp;
    }

    // Prueba 1: Eliminar avalúo de oportunidad
    @IsTest
    static void testClearAvaluoRelationship() {
        Opportunity opp = [SELECT Id, Avaluo_Vinculado__c FROM Opportunity LIMIT 1];
        Avaluo__c originalAvaluo = [SELECT Id, Opportunity__c FROM Avaluo__c WHERE Id = :opp.Avaluo_Vinculado__c];
        
        Test.startTest();
        // Eliminar la relación
        opp.Avaluo_Vinculado__c = null;
        update opp;
        Test.stopTest();

        // Verificar actualización
        Avaluo__c updatedAvaluo = [SELECT Id, Opportunity__c FROM Avaluo__c WHERE Id = :originalAvaluo.Id];
        System.assertEquals(null, updatedAvaluo.Opportunity__c, 'El avalúo debería tener Opportunity__c en null');
    }

    // Prueba 2: Cambiar a otro avalúo (no debería afectar al original)
    // @IsTest
    // static void testChangeToDifferentAvaluo() {
    //     List<Avaluo__c> avaluos = [SELECT Id FROM Avaluo__c ORDER BY Name];
    //     Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
    //     Avaluo__c newAvaluo = avaluos[1];
        
    //     Test.startTest();
    //     opp.Avaluo_Vinculado__c = newAvaluo.Id;
    //     update opp;
    //     Test.stopTest();
        
    //     // Verificar nuevo avalúo
    //     Avaluo__c updatedNewAvaluo = [SELECT Opportunity__c FROM Avaluo__c WHERE Id = :newAvaluo.Id];
    //     System.assertEquals(opp.Id, updatedNewAvaluo.Opportunity__c, 'El nuevo avalúo debería estar vinculado');
    // }

    // Prueba 3: Actualización masiva (200 registros)
    @IsTest
    static void testBulkUpdate() {
        List<Opportunity> opps = new List<Opportunity>();
        List<Avaluo__c> avaluos = new List<Avaluo__c>();
        
        // Crear 200 avalúos
        for(Integer i = 0; i < 200; i++) {
            avaluos.add(new Avaluo__c(Name = 'Avalúo Test ' + i));
        }
        insert avaluos;
        
        // Crear 200 oportunidades vinculadas
        for(Integer i = 0; i < 200; i++) {
            opps.add(new Opportunity(
                Name = 'Test Opp ' + i,
                StageName = 'Prospecting',
                CloseDate = Date.today().addDays(30),
                Avaluo_Vinculado__c = avaluos[i].Id
            ));
        }
        insert opps;

        Test.startTest();
        // Eliminar todas las relaciones
        for(Opportunity opp : opps) {
            opp.Avaluo_Vinculado__c = null;
        }
        update opps;
        Test.stopTest();

        // Verificar todos los avalúos
        List<Avaluo__c> updatedAvaluos = [SELECT Opportunity__c FROM Avaluo__c WHERE Id IN :avaluos];
        for(Avaluo__c av : updatedAvaluos) {
            System.assertEquals(null, av.Opportunity__c, 'Todos los avalúos deberían tener Opportunity__c en null');
        }
    }

    // Prueba 4: Actualización sin cambios (no debería hacer nada)
    // @IsTest
    // static void testNoChanges() {
    //     Opportunity opp = [SELECT Id, Avaluo_Vinculado__c FROM Opportunity LIMIT 1];
    //     Avaluo__c originalAvaluo = [SELECT Id, Opportunity__c FROM Avaluo__c WHERE Id = :opp.Avaluo_Vinculado__c];
        
    //     Test.startTest();
    //     // Actualizar sin cambios
    //     update opp;
    //     Test.stopTest();
        
    //     Avaluo__c unchangedAvaluo = [SELECT Opportunity__c FROM Avaluo__c WHERE Id = :originalAvaluo.Id];
    //     System.assertEquals(opp.Id, unchangedAvaluo.Opportunity__c, 'La relación debería mantenerse igual');
    // }
}