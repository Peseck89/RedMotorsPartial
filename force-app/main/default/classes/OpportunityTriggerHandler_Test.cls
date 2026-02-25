@isTest
private class OpportunityTriggerHandler_Test {

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

    static testMethod void RTPolaris() {
        
        List<RecordType> RTPolaris = [Select r.SobjectType, r.Id, r.DeveloperName From RecordType r where r.SobjectType = 'Opportunity' and r.DeveloperName ='Polaris'];
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

        Pricebook2 pb2 = new Pricebook2();
        pb2.Name = 'BMW - 2017';
        pb2.IsActive = true;
        insert pb2;

        Product2 prod = new Product2();
        prod.Name = 'BM35 - X5 - 25d PREMIUM';
        prod.Codigo_de_Producto__c = 'BM36';
        prod.ProductCode = 'BM36';
        prod.IsActive = true;
        prod.Marca__c = 'BMW';
        prod.Description = '25d PAQ M';
        prod.NombredePlantilla__c = 'BMWX5AgradecimientoVisita';
        prod.Familia__c = 'X5';
        
        insert prod;
        System.debug('qqqqq' + prod);

        PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = prod.Id, UnitPrice = 1000, IsActive = true);
        insert standardPBE;

        PricebookEntry pbe = new PricebookEntry();
        pbe.Product2Id = prod.Id;
        pbe.Pricebook2Id = pb2.Id;
        pbe.UnitPrice = 98000;
        pbe.UseStandardPrice = false;
        pbe.IsActive = true;
        System.debug('ppppp' + pbe);
        insert pbe; 
        
        Opportunity op = new Opportunity(
            RecordTypeId = RTPolaris[0].Id,
            AccountId = listCuentas[0].id,
            CloseDate = System.today().AddMonths(3),
            StageName = 'Oportunidad Calificada',
            Campana__c = TestDataFactory.campanna.Id,
            Sucursal__c = sucursal.Name,
            RT_Lead__c = 'Polaris'
        );      
        
        test.startTest();
        
            insert op;
            op.Pricebook2Id = pb2.Id;
            OpportunityLineItem lineItem = new OpportunityLineItem();
            lineItem.Preciodefacturacion__c = 220000;
            lineItem.OpportunityId = op.Id;
            lineItem.Marca__c = prod.Marca__c;
            lineItem.Modelo_De_Inter_s1__c = prod.Modelo_De_Inter_s__c;
            lineItem.Familia1__c = prod.Familia__c;
            lineItem.Quantity = 1;
            lineItem.PricebookEntryId = pbe.Id;
            lineItem.TotalPrice = 225000;
            insert lineItem;
            update op;
        test.stopTest();
        
    }   
    
    
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


			
        
        test.stopTest();
        
    }
    
    /* Marca: KTM */
    
    static testMethod void RTKTM() {
        
        //List<RecordType> RTKTM = [Select r.SobjectType, r.Id, r.DeveloperName From RecordType r where r.SobjectType = 'Opportunity' and r.DeveloperName ='KTM'];
        List<Account> listCuentas = TestDataFactory.MapCuentas.values();

		Id KTMRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('KTM').getRecordTypeId();
		Id PolarisRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Polaris').getRecordTypeId();
        Id KawasakiRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Kawasaki').getRecordTypeId();

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
            RecordTypeId = KTMRecordTypeId,//RTKTM[0].Id,
            AccountId = listCuentas[0].id,
            CloseDate = System.today().AddMonths(3),
            StageName = 'Oportunidad Calificada',
            Campana__c = TestDataFactory.campanna.Id,
            Sucursal__c = sucursal.Name,
            RT_Lead__c = 'KTM'
        );      
        
        test.startTest();
        
            insert op;

			op.RecordTypeId = PolarisRecordTypeId;
			update op;
			op.RecordTypeId = KawasakiRecordTypeId;
			update op;
			op.RecordTypeId = KTMRecordTypeId;
			update op;

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
        update oppList;



        Test.startTest();
            OpportunityService.reasignarOportunidadVendedores(oppList);


            oppList = new List<Opportunity>();
            for(Opportunity oppItem : [Select id,name From Opportunity ]){
                oppItem.OwnerId = u2.Id;
                //oppItem.LeadSource = 'Facebook';
                oppItem.Sucursal__c = sucursalItem;
                oppItem.SucursalId__c = sucursal.Id;
                oppItem.Marca_de_Veh_culo_Actual__c = 'BMW';    
                
                oppList.add(oppItem);
            }
            update oppList;
            OpportunityService.reasignarOportunidadVendedores(oppList);

            Delete[select id From  Opportunity];
            OpportunityService.reasignarOportunidadVendedores(oppList);
        Test.stopTest();
    }
    
    static testMethod void Test1(){
		
	 	Account acct = new Account();
        acct.FirstName = 'Test';
        acct.LastName = 'Test';
        acct.Tipo_de_Documento__c = 'Cedula';
        acct.Cedula__c = '404440444';
        acct.PersonMobilePhone = '+50688553311';
        insert acct;
        
        system.assertEquals([select FirstName from Account where id =: acct.id].FirstName ,'Test');
        
        Pricebook2 pb2 = new Pricebook2();
        pb2.Name = 'BMW - 2017';
        pb2.IsActive = true;
        insert pb2;

        Product2 prod = new Product2();
        prod.Name = 'BM35 - X5 - 25d PREMIUM';
        prod.Codigo_de_Producto__c = 'BM36';
        prod.ProductCode = 'BM36';
        prod.IsActive = true;
        prod.Marca__c = 'BMW';
        prod.Description = '25d PAQ M';
        prod.NombredePlantilla__c = 'BMWX5AgradecimientoVisita';
        prod.Familia__c = 'X5';
        
        insert prod;
        System.debug('qqqqq' + prod);

        PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = prod.Id, UnitPrice = 1000, IsActive = true);
        insert standardPBE;

        PricebookEntry pbe = new PricebookEntry();
        pbe.Product2Id = prod.Id;
        pbe.Pricebook2Id = pb2.Id;
        pbe.UnitPrice = 98000;
        pbe.UseStandardPrice = false;
        pbe.IsActive = true;
        System.debug('ppppp' + pbe);
        insert pbe;
        
        system.assertEquals([select id from PricebookEntry where id =: pbe.id].id ,pbe.id);  
        
        Test.startTest();
            Opportunity op = new Opportunity();
            op.Name = 'Prueba';
            op.Campana__c = TestDataFactory.campanna.Id;
            op.Sucursal__c = 'Pavas';
            op.AccountId = acct.Id;
            op.CloseDate = System.today() + 5;
            op.StageName = 'Test Drive';
            op.UltimaModificacion__c = (System.today()+10) - 3;
            op.Pricebook2Id = pb2.Id;
            op.EnvioAlertaOF__c = false;
            op.Consentimientofinaciero__c = false;
            op.OwnerId = UserInfo.getUserId();
            op.MonedaIngreso__c = SObjectType.Opportunity.Fields.MonedaIngreso__c.PicklistValues[1].getValue(); //Dólares
            op.IngresoAproximado__c = 1500;
            op.RT_Lead__c = 'BMW';
            insert op;
            
            system.assertEquals([select Sucursal__c from Opportunity where id =: op.id].Sucursal__c,'Pavas');
         
            OpportunityLineItem lineItem = new OpportunityLineItem();
            lineItem.Preciodefacturacion__c = 220000;
            lineItem.OpportunityId = op.Id;
            lineItem.Marca__c = prod.Marca__c;
            lineItem.Modelo_De_Inter_s1__c = prod.Modelo_De_Inter_s__c;
            lineItem.Familia1__c = prod.Familia__c;
            lineItem.Quantity = 1;
            lineItem.PricebookEntryId = pbe.Id;
            lineItem.TotalPrice = 225000;
            insert lineItem;
            
            system.assertEquals([select Preciodefacturacion__c from OpportunityLineItem where id =: lineItem.id].Preciodefacturacion__c,220000);  
            
            op.Consentimientofinaciero__c = true;
            update op;
            op.ComentariosFinancieros__c = 'Prueba Prueba Prueba';
            update op;
            
        Test.stopTest();
	}

    static testMethod void testCrearTareasOp() {
        test.startTest();
            TestDataFactory.createProducts(1);
            TestDataFactory.createPriceBookEntries(1, Test.getStandardPricebookId());
            TestDataFactory.crearOportunidades(1,'Oportunidad Calificada');
            TestDataFactory.crearProductosOP(1);

            TestDataFactory.MapOportunidades.get(0).StageName = 'Test Drive';
            update TestDataFactory.MapOportunidades.values();

            TestDataFactory.MapOportunidades.get(0).StageName = 'Oferta';
            TestDataFactory.MapOportunidades.get(0).Realiza_Test_Drive__c = true;
            TestDataFactory.MapOportunidades.get(0).Enganche_recibo__c = '123';
            TestDataFactory.MapOportunidades.get(0).Enganche_monto__c =  15000;
            update TestDataFactory.MapOportunidades.values();

            TestDataFactory.MapOportunidades.get(0).StageName = 'Cerrada Ganada';
            TestDataFactory.MapOportunidades.get(0).OpOferta__c = true;
            update TestDataFactory.MapOportunidades.values();
        test.stopTest();
    }
}