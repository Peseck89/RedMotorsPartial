@isTest
private class OpportunityProcessTest {

    static Integer iTotReg = 1;
    static Sucursal__c sucursal;
    static Campaign campanna;       
    
    static {

        TestDataFactory.datosGenerales();
        
        TestDataFactory.crearCuentas(iTotReg);
        
        //Crear campaña.
        campanna = new Campaign
        (
            Name='Campaign'
        );
        
        insert campanna;        
        
    }

    static testMethod void RTAsignadoDefecto() {
        
        test.startTest();
        
            TestDataFactory.crearOportunidades(iTotReg,'Oportunidad Calificada');
        
        test.stopTest();

    }
    
    /* Marca: Polaris */

    
    
    /* Marca: MINI */

    static testMethod void RTMINI() {
        
        //List<RecordType> RTMINI = [Select r.SobjectType, r.Id, r.DeveloperName From RecordType r where r.SobjectType = 'Opportunity' and r.DeveloperName ='MINI'];

        List<Account> listCuentas = TestDataFactory.MapCuentas.values();

		Id MotorradRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Motorrad').getRecordTypeId();
        Id BMWRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('BMW').getRecordTypeId();
		Id MINIRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('MINI').getRecordTypeId();

        //Crear sucursales.
        sucursal = new Sucursal__c(
            Name='Avenida Escazú', 
            DirectordeVentasMotorrad__c=UserInfo.getUserId(),
            DirectordeVentasMini__c=UserInfo.getUserId(),
            DirectordeVentasKTM__c=UserInfo.getUserId(),
            DirectordeVentasKawasaki__c=UserInfo.getUserId(),
            DirectordeVentasBMW__c=UserInfo.getUserId(),
            DirectordeVentasPolaris__c=UserInfo.getUserId(),
            Gerente_de_SucursalMotorrad__c=UserInfo.getUserId(),
            GerentedeSucursalMini__c=UserInfo.getUserId(),
            GerentedeSucursalKTM__c=UserInfo.getUserId(),
            GerentedeSucursalKawasaki__c=UserInfo.getUserId(),
            GerentedeSucursalBMW__c=UserInfo.getUserId(),
            GerentedeSucursalPolaris__c=UserInfo.getUserId(),
            JefedeSucursalMotorrad__c=UserInfo.getUserId(),
            JefesdeSucursalMini__c=UserInfo.getUserId(),
            JefesdeSucursalKTM__c=UserInfo.getUserId(),
            JefesdeSucursalKawasaki__c=UserInfo.getUserId(),
            JefeseSucursalBMW__c=UserInfo.getUserId(),
            JefesdeSucursalPolaris__c=UserInfo.getUserId()
        );
        
        insert sucursal;            
        
        Opportunity op = new Opportunity(
            RecordTypeId = MINIRecordTypeId,//RTMINI[0].Id,
            AccountId = listCuentas[0].id,
            CloseDate = System.today().AddMonths(3),
            StageName = 'Oportunidad Calificada',
            Campana__c = TestDataFactory.campanna.Id,
            Sucursal__c = sucursal.Name,
            RT_Lead__c = 'MINI'
        );      
        
        test.startTest();
        
            insert op;

			op.RecordTypeId = MotorradRecordTypeId;
			update op;
			op.RecordTypeId = BMWRecordTypeId;
			update op;
			op.RecordTypeId = MINIRecordTypeId;
			update op;
			op.StageName = 'Oferta';
        	op.entregado__c = System.today();
			op.fechaentrega__c = System.today();
        	op.fechafactura__c = System.today();
        	op.facturado__c = System.today();
         op.Enganche_monto__c = 150000;
        op.Enganche_recibo__c = '10000';
        op.Realiza_Test_Drive__c = true;
        update op;
			op.StageName = 'Cerrada Ganada';
			// update op;
        
        test.stopTest();
        
    }
          
static testMethod void testCrearTareasOp() {
    contact con = new contact ();
        con.FirstName='test';
        con.LastName='test';
        insert con;
        test.startTest();
            TestDataFactory.createProducts(1);
            //TestDataFactory.createPriceBookEntries(1, Test.getStandardPricebookId());
            TestDataFactory.crearOportunidades(1,'Oportunidad Calificada');
            //TestDataFactory.crearProductosOP(1);

            TestDataFactory.MapOportunidades.get(0).StageName = 'Test Drive';
            update TestDataFactory.MapOportunidades.values();

            TestDataFactory.MapOportunidades.get(0).StageName = 'Oferta';
            TestDataFactory.MapOportunidades.get(0).Realiza_Test_Drive__c = true;
            TestDataFactory.MapOportunidades.get(0).Enganche_recibo__c = '123';
            TestDataFactory.MapOportunidades.get(0).Enganche_monto__c =  15000;
            update TestDataFactory.MapOportunidades.values();

            TestDataFactory.MapOportunidades.get(0).StageName = 'Cerrada Ganada';
            TestDataFactory.MapOportunidades.get(0).OpOferta__c = true;
            TestDataFactory.MapOportunidades.get(0).entregado__c = system.today();
                TestDataFactory.MapOportunidades.get(0).fechaentrega__c =  system.today();
            TestDataFactory.MapOportunidades.get(0).fechafactura__c =  system.today();
            TestDataFactory.MapOportunidades.get(0).facturado__c =  system.today();
		TestDataFactory.MapOportunidades.get(0).contacto__c =  con.Id;
            update TestDataFactory.MapOportunidades.values();
        test.stopTest();
    }    
    
    /* Marca: Kawasaki */
    
    static testMethod void RTKawasaki() {
        
        List<RecordType> RTKawasaki = [Select r.SobjectType, r.Id, r.DeveloperName From RecordType r where r.SobjectType = 'Opportunity' and r.DeveloperName ='Kawasaki'];
        List<Account> listCuentas = TestDataFactory.MapCuentas.values();
        
        //Crear sucursales.
        sucursal = new Sucursal__c(
            Name='Curridabat', 
            DirectordeVentasMotorrad__c=UserInfo.getUserId(),
            DirectordeVentasMini__c=UserInfo.getUserId(),
            DirectordeVentasKTM__c=UserInfo.getUserId(),
            DirectordeVentasKawasaki__c=UserInfo.getUserId(),
            DirectordeVentasBMW__c=UserInfo.getUserId(),
            DirectordeVentasPolaris__c=UserInfo.getUserId(),
            Gerente_de_SucursalMotorrad__c=UserInfo.getUserId(),
            GerentedeSucursalMini__c=UserInfo.getUserId(),
            GerentedeSucursalKTM__c=UserInfo.getUserId(),
            GerentedeSucursalKawasaki__c=UserInfo.getUserId(),
            GerentedeSucursalBMW__c=UserInfo.getUserId(),
            GerentedeSucursalPolaris__c=UserInfo.getUserId(),
            JefedeSucursalMotorrad__c=UserInfo.getUserId(),
            JefesdeSucursalMini__c=UserInfo.getUserId(),
            JefesdeSucursalKTM__c=UserInfo.getUserId(),
            JefesdeSucursalKawasaki__c=UserInfo.getUserId(),
            JefeseSucursalBMW__c=UserInfo.getUserId(),
            JefesdeSucursalPolaris__c=UserInfo.getUserId()
        );
        
        insert sucursal;            
        
        Opportunity op = new Opportunity(
            RecordTypeId = RTKawasaki[0].Id,
            AccountId = listCuentas[0].id,
            CloseDate = System.today().AddMonths(3),
            StageName = 'Oportunidad Calificada',
            Campana__c = TestDataFactory.campanna.Id,
            Sucursal__c = sucursal.Name,
            RT_Lead__c = 'Kawasaki'
        );      
        
        test.startTest();
        
            insert op;
        
        test.stopTest();
        
    }   
    
    /* Marca: Motorrad */
    
    static testMethod void RTMotorrad() {
        
        List<RecordType> RTMotorrad = [Select r.SobjectType, r.Id, r.DeveloperName From RecordType r where r.SobjectType = 'Opportunity' and r.DeveloperName ='Motorrad'];
        List<Account> listCuentas = TestDataFactory.MapCuentas.values();
        
        //Crear sucursales.
        sucursal = new Sucursal__c(
            Name='Pavas', 
            DirectordeVentasMotorrad__c=UserInfo.getUserId(),
            DirectordeVentasMini__c=UserInfo.getUserId(),
            DirectordeVentasKTM__c=UserInfo.getUserId(),
            DirectordeVentasKawasaki__c=UserInfo.getUserId(),
            DirectordeVentasBMW__c=UserInfo.getUserId(),
            DirectordeVentasPolaris__c=UserInfo.getUserId(),
            Gerente_de_SucursalMotorrad__c=UserInfo.getUserId(),
            GerentedeSucursalMini__c=UserInfo.getUserId(),
            GerentedeSucursalKTM__c=UserInfo.getUserId(),
            GerentedeSucursalKawasaki__c=UserInfo.getUserId(),
            GerentedeSucursalBMW__c=UserInfo.getUserId(),
            GerentedeSucursalPolaris__c=UserInfo.getUserId(),
            JefedeSucursalMotorrad__c=UserInfo.getUserId(),
            JefesdeSucursalMini__c=UserInfo.getUserId(),
            JefesdeSucursalKTM__c=UserInfo.getUserId(),
            JefesdeSucursalKawasaki__c=UserInfo.getUserId(),
            JefeseSucursalBMW__c=UserInfo.getUserId(),
            JefesdeSucursalPolaris__c=UserInfo.getUserId()
        );
        
        insert sucursal;            
        
        Opportunity op = new Opportunity(
            RecordTypeId = RTMotorrad[0].Id,
            AccountId = listCuentas[0].id,
            CloseDate = System.today().AddMonths(3),
            StageName = 'Oportunidad Calificada',
            Campana__c = TestDataFactory.campanna.Id,
            Sucursal__c = sucursal.Name,
            RT_Lead__c = 'Motorrad'
        );      
        
        test.startTest();
        
            insert op;
        
        test.stopTest();
        
    }   

    //Este metodo verifica que el campo llamado Ultima Modificacion se actualize cuando la etapa de la Oportunidad cambie
    Static testmethod void updateField(){
        List<Account> listCuentas = TestDataFactory.MapCuentas.values();

        Opportunity op = new Opportunity();
        op.Name = 'Prueba';
        op.Sucursal__c = TestDataFactory.sucursal.Name;
        op.AccountId = listCuentas[0].Id;
        op.CloseDate = System.today() + 5;
        op.StageName = 'Test Drive';
        op.Campana__c = TestDataFactory.campanna.Id;
        op.RT_Lead__c = 'BMW';
        insert op;

        Test.startTest();
        op.StageName = 'Oferta';
        op.Enganche_monto__c = 150000;
        op.Enganche_recibo__c = '10000';
        op.Realiza_Test_Drive__c = true;
        update op;
        Test.stopTest();
    }

    /*
    
    Metodo para hacer el test al metodo envioAlertaOppDuplicada de la clase OpportunityService, Test1

     */
    @isTest static void testEnvioAlertaOppDuplicada1() {

        //TestDataFactory.datosGenerales();

        //Crear Cuenta
        Account acct = new Account(
            FirstName = 'Test', 
            LastName = 'Test', 
            Tipo_de_Documento__c = 'Cedula', 
            Cedula__c = '404440444', 
            PersonEmail = 'da_ls90@hotmail.es', 
            PersonMobilePhone = '+50683838383');
        insert acct;

        //Crear sucursales.
        Sucursal__c sucursal = new Sucursal__c(
            Name='Pavas',
            DirectordeVentasBMW__c = UserInfo.getUserId(),
            GerentedeSucursalBMW__c = UserInfo.getUserId(),
            JefeseSucursalBMW__c = UserInfo.getUserId()
        );
        insert sucursal;

        Opportunity opp = new Opportunity();
        opp.OwnerId = UserInfo.getUserId();
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('BMW').getRecordTypeId();
        opp.Name = 'Prueba1';
        opp.Campana__c = TestDataFactory.campanna.Id;
        opp.LeadSource = 'Facebook';
        opp.Sucursal__c = sucursal.Name;
        opp.SucursalId__c = sucursal.Id;
        opp.CloseDate = system.today();
        opp.StageName = 'Oferta';
        opp.AccountId = acct.Id;
        opp.Enganche_monto__c = 150000;
        opp.Enganche_recibo__c = '10000';
        opp.Realiza_Test_Drive__c = true;
        opp.RT_Lead__c = 'BMW';
        insert opp;

        Test.startTest();
            Opportunity opp1 = new Opportunity();
            opp1.OwnerId = UserInfo.getUserId();
            opp1.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('BMW').getRecordTypeId();
            opp1.Name = 'Prueba1';
            opp1.Campana__c = TestDataFactory.campanna.Id;
            opp1.LeadSource = 'Facebook';
            opp1.Sucursal__c = sucursal.Name;
            opp1.SucursalId__c = sucursal.Id;
            opp1.CloseDate = system.today();
            opp1.StageName = 'Oferta';
            opp1.AccountId = acct.Id;
            opp1.Enganche_monto__c = 150000;
            opp1.Enganche_recibo__c = '10000';
            opp1.Realiza_Test_Drive__c = true;
            opp1.RT_Lead__c = 'BMW';
            insert opp1;    

        Test.stopTest();
    }

    /*
    Metodo para hacer el test al metodo envioAlertaOppDuplicada de la clase OpportunityService, Test2
    */

    @isTest static void testEnvioAlertaOppDuplicada2() {

        //TestDataFactory.datosGenerales();

        //Crear Cuenta
        Account acct = new Account(
            FirstName = 'Test', 
            LastName = 'Test', 
            Tipo_de_Documento__c = 'Cedula', 
            Cedula__c = '404440444', 
            PersonEmail = 'da_ls90@hotmail.es', 
            PersonMobilePhone = '+50683838383');
        insert acct;

        //Crear sucursales.
        Sucursal__c sucursal = new Sucursal__c(
            Name='Pavas',
            DirectordeVentasBMW__c = UserInfo.getUserId(),
            GerentedeSucursalBMW__c = UserInfo.getUserId(),
            JefeseSucursalBMW__c = null
        );
        insert sucursal;

        //Crear primera Oportunidad
        Opportunity opp = new Opportunity();
        opp.OwnerId = UserInfo.getUserId();
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('BMW').getRecordTypeId();
        opp.Name = 'Prueba1';
        opp.Campana__c = TestDataFactory.campanna.Id;
        opp.LeadSource = 'Facebook';
        opp.Sucursal__c = sucursal.Name;
        opp.SucursalId__c = sucursal.Id;
        opp.CloseDate = system.today();
        opp.StageName = 'Oferta';
        opp.AccountId = acct.Id;
        opp.Enganche_monto__c = 150000;
        opp.Enganche_recibo__c = '10000';
        opp.Realiza_Test_Drive__c = true;
        opp.RT_Lead__c = 'BMW';
        insert opp;

        Test.startTest();
            //Crear segunda oportunidad
            Opportunity opp1 = new Opportunity();
            opp1.OwnerId = UserInfo.getUserId();
            opp1.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('BMW').getRecordTypeId();
            opp1.Name = 'Prueba1';
            opp1.Campana__c = TestDataFactory.campanna.Id;
            opp1.LeadSource = 'Facebook';
            opp1.Sucursal__c = sucursal.Name;
            opp1.SucursalId__c = sucursal.Id;
            opp1.CloseDate = system.today();
            opp1.StageName = 'Oferta';
            opp1.AccountId = acct.Id;
            opp1.Enganche_monto__c = 150000;
            opp1.Enganche_recibo__c = '10000';
            opp1.Realiza_Test_Drive__c = true;
            opp1.RT_Lead__c = 'BMW';
            insert opp1;    

        Test.stopTest();
    }

    /*
    Metodo para hacer el test al metodo envioAlertaOppDuplicada de la clase OpportunityService, Test3
    */

    @isTest static void testEnvioAlertaOppDuplicada3() {

        //TestDataFactory.datosGenerales();

        //Crear Cuenta
        Account acct = new Account(
            FirstName = 'Test', 
            LastName = 'Test', 
            Tipo_de_Documento__c = 'Cedula', 
            Cedula__c = '404440444', 
            PersonEmail = 'da_ls90@hotmail.es', 
            PersonMobilePhone = '+50683838383');
        insert acct;

        //Crear sucursales.
        Sucursal__c sucursal = new Sucursal__c(
            Name='Pavas',
            DirectordeVentasBMW__c = UserInfo.getUserId(),
            GerentedeSucursalBMW__c = null,
            JefeseSucursalBMW__c = null
        );
        insert sucursal;

        //Crear primera Oportunidad
        Opportunity opp = new Opportunity();
        opp.OwnerId = UserInfo.getUserId();
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('BMW').getRecordTypeId();
        opp.Name = 'Prueba1';
        opp.Campana__c = TestDataFactory.campanna.Id;
        opp.LeadSource = 'Facebook';
        opp.Sucursal__c = sucursal.Name;
        opp.SucursalId__c = sucursal.Id;
        opp.CloseDate = system.today();
        opp.StageName = 'Oferta';
        opp.AccountId = acct.Id;
        opp.Enganche_monto__c = 150000;
        opp.Enganche_recibo__c = '10000';
        opp.Realiza_Test_Drive__c = true;
        opp.RT_Lead__c = 'BMW';
        insert opp;

        Test.startTest();
            //Crear segunda oportunidad
            Opportunity opp1 = new Opportunity();
            opp1.OwnerId = UserInfo.getUserId();
            opp1.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('BMW').getRecordTypeId();
            opp1.Name = 'Prueba1';
            opp1.Campana__c = TestDataFactory.campanna.Id;
            opp1.LeadSource = 'Facebook';
            opp1.Sucursal__c = sucursal.Name;
            opp1.SucursalId__c = sucursal.Id;
            opp1.CloseDate = system.today();
            opp1.StageName = 'Oferta';
            opp1.AccountId = acct.Id;
            opp1.Enganche_monto__c = 150000;
            opp1.Enganche_recibo__c = '10000';
            opp1.Realiza_Test_Drive__c = true;
            opp1.RT_Lead__c = 'BMW';
            insert opp1;    

        Test.stopTest();
    }

    /*
    Metodo para hacer el test al metodo envioAlertaOppDuplicada de la clase OpportunityService, Test4
    */ 

    @isTest static void testEnvioAlertaOppDuplicada4() {

        //TestDataFactory.datosGenerales();

        //Crear Cuenta
        Account acct = new Account(
            FirstName = 'Test', 
            LastName = 'Test', 
            Tipo_de_Documento__c = 'Cedula', 
            Cedula__c = '404440444', 
            PersonEmail = 'da_ls90@hotmail.es', 
            PersonMobilePhone = '+50683838383');
        insert acct;

        //Crear sucursales.
        Sucursal__c sucursal = new Sucursal__c(
            Name='Pavas',
            DirectordeVentasBMW__c = null,
            GerentedeSucursalBMW__c = null,
            JefeseSucursalBMW__c = null
        );
        insert sucursal;

        //Crear primera Oportunidad
        Opportunity opp = new Opportunity();
        opp.OwnerId = UserInfo.getUserId();
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('BMW').getRecordTypeId();
        opp.Name = 'Prueba1';
        opp.Campana__c = TestDataFactory.campanna.Id;
        opp.LeadSource = 'Facebook';
        opp.Sucursal__c = sucursal.Name;
        opp.SucursalId__c = sucursal.Id;
        opp.CloseDate = system.today();
        opp.StageName = 'Oferta';
        opp.AccountId = acct.Id;
        opp.Enganche_monto__c = 150000;
        opp.Enganche_recibo__c = '10000';
        opp.Realiza_Test_Drive__c = true;
        opp.RT_Lead__c = 'BMW';
        insert opp;

        Test.startTest();
            //Crear segunda oportunidad
            Opportunity opp1 = new Opportunity();
            opp1.OwnerId = UserInfo.getUserId();
            opp1.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('BMW').getRecordTypeId();
            opp1.Name = 'Prueba1';
            opp1.Campana__c = TestDataFactory.campanna.Id;
            opp1.LeadSource = 'Facebook';
            opp1.Sucursal__c = sucursal.Name;
            opp1.SucursalId__c = sucursal.Id;
            opp1.CloseDate = system.today();
            opp1.StageName = 'Oferta';
            opp1.AccountId = acct.Id;
            opp1.Enganche_monto__c = 150000;
            opp1.Enganche_recibo__c = '10000';
            opp1.Realiza_Test_Drive__c = true;
            opp1.RT_Lead__c = 'BMW';
            insert opp1;    

        Test.stopTest();
    }

    /*
    Metodo para hacer el test al metodo envioAlertaOppDuplicada de la clase OpportunityService, Test5
    */ 

    @isTest static void testEnvioAlertaOppDuplicada5() {

        //TestDataFactory.datosGenerales();

        //Crear Cuenta
        Account acct = new Account(
            FirstName = 'Test', 
            LastName = 'Test', 
            Tipo_de_Documento__c = 'Cedula', 
            Cedula__c = '404440444', 
            PersonEmail = 'da_ls90@hotmail.es', 
            PersonMobilePhone = '+50683838383');
        insert acct;

        //Crear sucursal
        Sucursal__c sucursal = new Sucursal__c(
            Name='Pavas',
            DirectordeVentasBMW__c = UserInfo.getUserId(),
            GerentedeSucursalBMW__c = UserInfo.getUserId(),
            JefeseSucursalBMW__c = UserInfo.getUserId()
        );
        insert sucursal;

        //Crear segunda sucursal
        Sucursal__c sucursal1 = new Sucursal__c(
            Name='Uruca',
            DirectordeVentasBMW__c = UserInfo.getUserId(),
            GerentedeSucursalBMW__c = UserInfo.getUserId(),
            JefeseSucursalBMW__c = UserInfo.getUserId()
        );
        insert sucursal1;

        //Crear primera Oportunidad
        Opportunity opp = new Opportunity();
        opp.OwnerId = UserInfo.getUserId();
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('BMW').getRecordTypeId();
        opp.Name = 'Prueba1';
        opp.Campana__c = TestDataFactory.campanna.Id;
        opp.LeadSource = 'Facebook';
        opp.Sucursal__c = sucursal.Name;
        opp.SucursalId__c = sucursal.Id;
        opp.CloseDate = system.today();
        opp.StageName = 'Oferta';
        opp.AccountId = acct.Id;
        opp.Enganche_monto__c = 150000;
        opp.Enganche_recibo__c = '10000';
        opp.Realiza_Test_Drive__c = true;
        opp.RT_Lead__c = 'BMW';
        insert opp;

        Test.startTest();
            //Crear segunda oportunidad
            Opportunity opp1 = new Opportunity();
            opp1.OwnerId = UserInfo.getUserId();
            opp1.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('BMW').getRecordTypeId();
            opp1.Name = 'Prueba1';
            opp1.Campana__c = TestDataFactory.campanna.Id;
            opp1.LeadSource = 'Facebook';
            opp1.Sucursal__c = sucursal1.Name;
            opp1.SucursalId__c = sucursal1.Id;
            opp1.CloseDate = system.today();
            opp1.StageName = 'Oferta';
            opp1.AccountId = acct.Id;
            opp1.Enganche_monto__c = 150000;
            opp1.Enganche_recibo__c = '10000';
            opp1.Realiza_Test_Drive__c = true;
            opp1.RT_Lead__c = 'BMW';
            insert opp1;    

        Test.stopTest();
    }

    /*
    Metodo para hacer el test al metodo envioAlertaOppDuplicada de la clase OpportunityService, Test6
    */

    @isTest static void testEnvioAlertaOppDuplicada6() {

        //TestDataFactory.datosGenerales();

        //Crear Cuenta
        Account acct = new Account(
            FirstName = 'Test', 
            LastName = 'Test', 
            Tipo_de_Documento__c = 'Cedula', 
            Cedula__c = '404440444', 
            PersonEmail = 'da_ls90@hotmail.es', 
            PersonMobilePhone = '+50683838383');
        insert acct;

        //Crear sucursal
        Sucursal__c sucursal = new Sucursal__c(
            Name='Pavas',
            DirectordeVentasBMW__c = UserInfo.getUserId(),
            GerentedeSucursalBMW__c = UserInfo.getUserId(),
            JefeseSucursalBMW__c = null
        );
        insert sucursal;

        //Crear segunda sucursal
        Sucursal__c sucursal1 = new Sucursal__c(
            Name='Uruca',
            DirectordeVentasBMW__c = UserInfo.getUserId(),
            GerentedeSucursalBMW__c = UserInfo.getUserId(),
            JefeseSucursalBMW__c = null
        );
        insert sucursal1;

        //Crear primera Oportunidad
        Opportunity opp = new Opportunity();
        opp.OwnerId = UserInfo.getUserId();
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('BMW').getRecordTypeId();
        opp.Name = 'Prueba1';
        opp.Campana__c = TestDataFactory.campanna.Id;
        opp.LeadSource = 'Facebook';
        opp.Sucursal__c = sucursal.Name;
        opp.SucursalId__c = sucursal.Id;
        opp.CloseDate = system.today();
        opp.StageName = 'Oferta';
        opp.AccountId = acct.Id;
        opp.Enganche_monto__c = 150000;
        opp.Enganche_recibo__c = '10000';
        opp.Realiza_Test_Drive__c = true;
        opp.RT_Lead__c = 'BMW';
        insert opp;

        Test.startTest();
            //Crear segunda oportunidad
            Opportunity opp1 = new Opportunity();
            opp1.OwnerId = UserInfo.getUserId();
            opp1.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('BMW').getRecordTypeId();
            opp1.Name = 'Prueba1';
            opp1.Campana__c = TestDataFactory.campanna.Id;
            opp1.LeadSource = 'Facebook';
            opp1.Sucursal__c = sucursal1.Name;
            opp1.SucursalId__c = sucursal1.Id;
            opp1.CloseDate = system.today();
            opp1.StageName = 'Oferta';
            opp1.AccountId = acct.Id;
            opp1.Enganche_monto__c = 150000;
            opp1.Enganche_recibo__c = '10000';
            opp1.Realiza_Test_Drive__c = true;
            opp1.RT_Lead__c = 'BMW';
            insert opp1;    

        Test.stopTest();
    }

    /*
    Metodo para hacer el test al metodo envioAlertaOppDuplicada de la clase OpportunityService, Test7
    */ 

    @isTest static void testEnvioAlertaOppDuplicada7() {

        //TestDataFactory.datosGenerales();

        //Crear Cuenta
        Account acct = new Account(
            FirstName = 'Test', 
            LastName = 'Test', 
            Tipo_de_Documento__c = 'Cedula', 
            Cedula__c = '404440444', 
            PersonEmail = 'da_ls90@hotmail.es', 
            PersonMobilePhone = '+50683838383');
        insert acct;

        //Crear sucursal
        Sucursal__c sucursal = new Sucursal__c(
            Name='Pavas',
            DirectordeVentasBMW__c = UserInfo.getUserId(),
            GerentedeSucursalBMW__c = null,
            JefeseSucursalBMW__c = null
        );
        insert sucursal;

        //Crear segunda sucursal
        Sucursal__c sucursal1 = new Sucursal__c(
            Name='Uruca',
            DirectordeVentasBMW__c = UserInfo.getUserId(),
            GerentedeSucursalBMW__c = null,
            JefeseSucursalBMW__c = null
        );
        insert sucursal1;

        //Crear primera Oportunidad
        Opportunity opp = new Opportunity();
        opp.OwnerId = UserInfo.getUserId();
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('BMW').getRecordTypeId();
        opp.Name = 'Prueba1';
        opp.Campana__c = TestDataFactory.campanna.Id;
        opp.LeadSource = 'Facebook';
        opp.Sucursal__c = sucursal.Name;
        opp.SucursalId__c = sucursal.Id;
        opp.CloseDate = system.today();
        opp.StageName = 'Oferta';
        opp.AccountId = acct.Id;
        opp.Enganche_monto__c = 150000;
        opp.Enganche_recibo__c = '10000';
        opp.Realiza_Test_Drive__c = true;
        opp.RT_Lead__c = 'BMW';
        insert opp;

        Test.startTest();
            //Crear segunda oportunidad
            Opportunity opp1 = new Opportunity();
            opp1.OwnerId = UserInfo.getUserId();
            opp1.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('BMW').getRecordTypeId();
            opp1.Name = 'Prueba1';
            opp1.Campana__c = TestDataFactory.campanna.Id;
            opp1.LeadSource = 'Facebook';
            opp1.Sucursal__c = sucursal1.Name;
            opp1.SucursalId__c = sucursal1.Id;
            opp1.CloseDate = system.today();
            opp1.StageName = 'Oferta';
            opp1.AccountId = acct.Id;
            opp1.Enganche_monto__c = 150000;
            opp1.Enganche_recibo__c = '10000';
            opp1.Realiza_Test_Drive__c = true;
            opp1.RT_Lead__c = 'BMW';
            insert opp1;    

        Test.stopTest();
    }

    /*
    Metodo para hacer el test al metodo envioAlertaOppDuplicada de la clase OpportunityService, Test8
    */ 

    @isTest static void testEnvioAlertaOppDuplicada8() {

        //TestDataFactory.datosGenerales();

        //Crear Cuenta
        Account acct = new Account(
            FirstName = 'Test', 
            LastName = 'Test', 
            Tipo_de_Documento__c = 'Cedula', 
            Cedula__c = '404440444', 
            PersonEmail = 'da_ls90@hotmail.es', 
            PersonMobilePhone = '+50683838383');
        insert acct;

        //Crear sucursal
        Sucursal__c sucursal = new Sucursal__c(
            Name='Pavas',
            DirectordeVentasBMW__c = null,
            GerentedeSucursalBMW__c = null,
            JefeseSucursalBMW__c = null
        );
        insert sucursal;

        //Crear segunda sucursal
        Sucursal__c sucursal1 = new Sucursal__c(
            Name='Uruca',
            DirectordeVentasBMW__c = null,
            GerentedeSucursalBMW__c = null,
            JefeseSucursalBMW__c = null
        );
        insert sucursal1;

        //Crear primera Oportunidad
        Opportunity opp = new Opportunity();
        opp.OwnerId = UserInfo.getUserId();
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('BMW').getRecordTypeId();
        opp.Name = 'Prueba1';
        opp.Campana__c = TestDataFactory.campanna.Id;
        opp.LeadSource = 'Facebook';
        opp.Sucursal__c = sucursal.Name;
        opp.SucursalId__c = sucursal.Id;
        opp.CloseDate = system.today();
        opp.StageName = 'Oferta';
        opp.AccountId = acct.Id;
        opp.Enganche_monto__c = 150000;
        opp.Enganche_recibo__c = '10000';
        opp.Realiza_Test_Drive__c = true;
        opp.RT_Lead__c = 'BMW';
        insert opp;

        Test.startTest();
            //Crear segunda oportunidad
            Opportunity opp1 = new Opportunity();
            opp1.OwnerId = UserInfo.getUserId();
            opp1.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('BMW').getRecordTypeId();
            opp1.Name = 'Prueba1';
            opp1.Campana__c = TestDataFactory.campanna.Id;
            opp1.LeadSource = 'Facebook';
            opp1.Sucursal__c = sucursal1.Name;
            opp1.SucursalId__c = sucursal1.Id;
            opp1.CloseDate = system.today();
            opp1.StageName = 'Oferta';
            opp1.AccountId = acct.Id;
            opp1.Enganche_monto__c = 150000;
            opp1.Enganche_recibo__c = '10000';
            opp1.Realiza_Test_Drive__c = true;
            opp1.RT_Lead__c = 'BMW';
            insert opp1;    

        Test.stopTest();
    }
    
    /*
    Este metodo se usa para hacer el test del metodo reasignarOportunidadVendedores
     */
    @isTest static void testReasignarOportunidadVendedores() {

        //TestDataFactory.datosGenerales();
        TestDataFactory.crearCuentas(10);
        TestDataFactory.crearOportunidades(10,'Oferta');

        Profile p = [SELECT Id FROM Profile WHERE Name='Jefe de Ventas BMW']; 
        
        User u1 = new User(Alias = 'aStBCR16', Email='auseStadBCRInte111016@testorg.com',
            EmailEncodingKey='UTF-8', LastName='auseStadBCRInte111016', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='auseStadBCRInte111016@testorg.com');
        insert u1;

        User u2 = new User(Alias = 'sStBCR16', Email='aaseStadBCRInte111016@testorg.com',
            EmailEncodingKey='UTF-8', LastName='saaeStadBCRInte111016', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='buseStadBCRInte111016@testorg.com');
        insert u2;



        Schema.DescribeFieldResult studentStatus = Opportunity.Sucursal__c.getDescribe();
        List<Schema.PicklistEntry> studentStatusValues = studentStatus.getPicklistValues();
        String sucursalItem = '';

        for (Schema.PicklistEntry a : studentStatusValues){
           sucursalItem = a.getValue();
        }



        Sucursal__c sucursal = new Sucursal__c(Name=sucursalItem);
        insert sucursal;

        Vendedores__c vendedor1 = new Vendedores__c(    Usuario__c =u1.Id,Sucursal__c = sucursal.Id,Marcas__c = 'BMW');
        insert vendedor1;

        Vendedores__c vendedor2 = new Vendedores__c(    Usuario__c =u2.Id,Sucursal__c = sucursal.Id,Marcas__c = 'BMW');
        insert vendedor2;

        Vendedor_Asignaciones__c vendedorAsig1 = new Vendedor_Asignaciones__c(Activo__c=true,Fecha_Asignacion__c=Date.today(),Vendedor__c = vendedor1.Id);
        insert vendedorAsig1;

        Vendedor_Asignaciones__c vendedorAsig2 = new Vendedor_Asignaciones__c(Activo__c=true,Fecha_Asignacion__c=Date.today(),Vendedor__c = vendedor2.Id);
        insert vendedorAsig2;

        List<Opportunity> oppList = new List<Opportunity>();
        Boolean isFirst = true;
        for(Opportunity oppItem : [Select id,name From Opportunity ]){
            oppItem.OwnerId = u2.Id;
            if(isFirst){
                isFirst =false;
                oppItem.OwnerId = u1.Id;
            }
            //oppItem.LeadSource = 'Facebook';
            oppItem.Sucursal__c = sucursalItem;
            oppItem.SucursalId__c = sucursal.Id;
            oppItem.Marca_de_Veh_culo_Actual__c = 'BMW';    
            
            oppList.add(oppItem);
        }
        //update oppList;



        Test.startTest();
            OpportunityService.reasignarOportunidadVendedores(oppList);


            oppList = new List<Opportunity>();
            for(Opportunity oppItem : [Select id,name From Opportunity ]){
                oppItem.OwnerId = u2.Id;
                //oppItem.LeadSource = 'Facebook';
               // oppItem.Sucursal__c = sucursalItem;
               // oppItem.SucursalId__c = sucursal.Id;
                oppItem.Marca_de_Veh_culo_Actual__c = 'BMW';    
                
                oppList.add(oppItem);
            }
            update oppList;
            OpportunityService.reasignarOportunidadVendedores(oppList);

            Delete[select id From  Opportunity];
            OpportunityService.reasignarOportunidadVendedores(oppList);
        Test.stopTest();
    }
    
    

    
}