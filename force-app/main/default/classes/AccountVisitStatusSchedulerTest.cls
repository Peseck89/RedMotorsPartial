@IsTest
private class AccountVisitStatusSchedulerTest {

    @IsTest
    static void testRun_EventBranch() {
        Account a1 = new Account(Name = 'EV1');
        insert a1;

        Contact c1 = new Contact(AccountId = a1.Id, LastName = 'C1');
        insert c1;

        Datetime safeFutureDt = Datetime.now().addDays(2);
        Event e1 = new Event(
            WhoId = c1.Id,
            Subject = 'Call',
            StartDateTime = safeFutureDt,
            DurationInMinutes = 60
        );
        insert e1;

        Test.startTest();

        AccountVisitStatusScheduler.TODAY_OVERRIDE = safeFutureDt.date().addMonths(10);
        AccountVisitStatusScheduler.runNow(1);
        Account accRes = [SELECT CPEstatus_visita_al_taller__c FROM Account WHERE Id = :a1.Id];
        System.assertEquals('Visita recurrente', accRes.CPEstatus_visita_al_taller__c);

        AccountVisitStatusScheduler.TODAY_OVERRIDE = safeFutureDt.date().addMonths(20);
        AccountVisitStatusScheduler.runNow(1);
        accRes = [SELECT CPEstatus_visita_al_taller__c FROM Account WHERE Id = :a1.Id];
        System.assertEquals('Prefuga', accRes.CPEstatus_visita_al_taller__c);

        AccountVisitStatusScheduler.TODAY_OVERRIDE = safeFutureDt.date().addMonths(30);
        AccountVisitStatusScheduler.runNow(1);
        accRes = [SELECT CPEstatus_visita_al_taller__c FROM Account WHERE Id = :a1.Id];
        System.assertEquals('Fuga', accRes.CPEstatus_visita_al_taller__c);

        Test.stopTest();
        AccountVisitStatusScheduler.TODAY_OVERRIDE = null;
    }

    @IsTest
    static void testRun_AssetBranch() {
        Account a1 = new Account(Name = 'AS1');
        insert a1;

        Product2 prod = new Product2(
            Name = 'P-1',
            IsActive = true,
            Codigo_de_Producto__c = 'CP-1'
        );
        insert prod;

        Date safePastDate = Date.today();
        Asset asset1 = new Asset(
            Name = 'AS1',
            AccountId = a1.Id,
            Product2Id = prod.Id,
            fecha_facturacion_vehiculo__c = safePastDate
        );
        insert asset1;

        Test.startTest();

        AccountVisitStatusScheduler.TODAY_OVERRIDE = safePastDate.addMonths(10);
        AccountVisitStatusScheduler.runNow(1);
        Account accRes = [SELECT CPEstatus_visita_al_taller__c FROM Account WHERE Id = :a1.Id];
        System.assertEquals('Nuevo', accRes.CPEstatus_visita_al_taller__c);

        AccountVisitStatusScheduler.TODAY_OVERRIDE = safePastDate.addMonths(18);
        AccountVisitStatusScheduler.runNow(1);
        accRes = [SELECT CPEstatus_visita_al_taller__c FROM Account WHERE Id = :a1.Id];
        System.assertEquals('Primera visita', accRes.CPEstatus_visita_al_taller__c);

        AccountVisitStatusScheduler.TODAY_OVERRIDE = safePastDate.addMonths(20);
        AccountVisitStatusScheduler.runNow(1);
        accRes = [SELECT CPEstatus_visita_al_taller__c FROM Account WHERE Id = :a1.Id];
        System.assertEquals('Sin visita', accRes.CPEstatus_visita_al_taller__c);

        Test.stopTest();
        AccountVisitStatusScheduler.TODAY_OVERRIDE = null;
    }

    @IsTest
    static void testRun_DefaultBranch_NoData() {
        Account a1 = new Account(Name = 'DF1');
        insert a1;

        Test.startTest();
        AccountVisitStatusScheduler.runNow(1);
        Test.stopTest();

        Account accRes = [SELECT CPEstatus_visita_al_taller__c FROM Account WHERE Id = :a1.Id];
        System.assertEquals(null, accRes.CPEstatus_visita_al_taller__c);
    }

    @IsTest
    static void testSchedulerExecute() {
        Account a = new Account(Name = 'SCH');
        insert a;

        Contact c = new Contact(AccountId = a.Id, LastName = 'SC');
        insert c;

        Event e = new Event(
            WhoId = c.Id,
            Subject = 'Call',
            StartDateTime = Datetime.now().addDays(2),
            DurationInMinutes = 60
        );
        insert e;

        String jobName = 'AVSS_' + String.valueOf(DateTime.now().getTime());

        Test.startTest();
        String cron = '0 0 0 1 1 ? 2099';
        System.schedule(jobName, cron, new AccountVisitStatusScheduler());
        Test.stopTest();

        List<CronTrigger> jobs = [SELECT Id, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name = :jobName];
        System.assertEquals(1, jobs.size());
    }
}