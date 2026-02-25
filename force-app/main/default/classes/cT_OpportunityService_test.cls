@isTest()
public class cT_OpportunityService_test {
    
    static Integer iTotReg = 1;
    static Sucursal__c sucursal;
    static Campaign campanna;    
	
    
    static {

        TestDataFactory.datosGenerales();
        

        
        //Crear campaña.
        campanna = new Campaign
        (
            Name='Campaign'
        );
        
        insert campanna;   
                //Crear sucursales.
        sucursal = new Sucursal__c(
            Name='Taller Uruca', 
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
        
                list<Account> listAccs = new list<Account>();
        for (Integer x=0;x<iTotReg;x++){
            
            Account a = new Account
            (             
                FirstName = 'Test',
                LastName    =   'test',
                PersonEmail = 'correotest'+x+'@email.com',
                Tipo_de_Documento__c = 'Cedula',
                Cedula__c = '222222222',
                PersonMobilePhone = '+50611223344',
                Sucursal__c = sucursal.Name,
                Telefono_Altica__c = '+50611223344',
                Telefono2__c = '+50611223344',
                Numero_Telefonico_Representante_Legal__c = '+50611223344',
                Phone = '+50611223344'
            );
            listAccs.add(a);
        }
		insert listAccs;
        
        list<Opportunity> listOps = new list<Opportunity>();
        for (Integer x=0;x<iTotReg;x++){
            Opportunity op = new Opportunity(
                AccountId = listAccs[0].id,
                CloseDate = System.today().AddMonths(3),
                StageName = 'Oportunidad Calificada',
                Sucursal__c = 'Uruca',
                tareasCreadas__c = false,
                //MonedaIngreso__c = 'Colones',
                IngresoAproximado__c = 1500,
                RT_Lead__c = 'Polaris'
            );
            
            listOps.add(op);
        }
        insert listOps;
        
        TestDataFactory.createProducts(iTotReg);
        TestDataFactory.createPriceBookEntries(0,Test.getStandardPricebookId());
        
    }
    
    private static testmethod void validated(){  
        List<RecordType> RTPolaris = [Select r.SobjectType, r.Id, r.DeveloperName From RecordType r where r.SobjectType = 'Opportunity' and r.DeveloperName ='Polaris'];

        List<Account> listCuentas = [Select Id From Account];
        
  

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

        //PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = prod.Id, UnitPrice = 1000, IsActive = true);
        //insert standardPBE;

        PricebookEntry pbe = new PricebookEntry();
        pbe.Product2Id = prod.Id;
        pbe.Pricebook2Id = pb2.Id;
        pbe.UnitPrice = 98000;
        pbe.UseStandardPrice = false;
        pbe.IsActive = true;
        System.debug('ppppp' + pbe);
        insert pbe; 
		id oppTaller = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Taller').getRecordTypeId();
		Opportunity op = new Opportunity(
            RecordTypeId = oppTaller,
            AccountId = listCuentas[0].id,
            CloseDate = System.today().AddMonths(3),
            StageName = 'Oportunidad Calificada',
            Campana__c = TestDataFactory.campanna.Id,
            Sucursal__c = 'Uruca',
            GerenteSucursal__c = UserInfo.getUserId(),
            RT_Lead__c = 'Polaris',
            Name = 'WITHDRAWAL TEST',
            alertEmail__c = false,
            tareasCreadas__c = false
        );   
        insert op;
        id oppTaller2 = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('BMW').getRecordTypeId();
        Opportunity op2 = new Opportunity(
            RecordTypeId = oppTaller2,
            AccountId = listCuentas[0].id,
            CloseDate = System.today().AddMonths(3),
            StageName = 'Oportunidad Calificada',
            Campana__c = TestDataFactory.campanna.Id,
            Sucursal__c = 'Uruca',
            RT_Lead__c = 'Polaris',
            JefeSucursal__c = UserInfo.getUserId(),
            Name = 'WITHDRAWAL TEST',
            alertEmail__c = false,
            tareasCreadas__c = false
        );   
        insert op2;
		Map<ID, Opportunity> m = new Map<ID, Opportunity>();
        m.put(op.AccountId, op);
        Set<Id> myStringSet = new Set<Id>();
        myStringSet.add(op.Id);
        list<Opportunity> listaOp = new list<Opportunity>();
        listaOp.add(op);
        
        Contact ctc = new Contact();
    	ctc.AccountId = listCuentas[0].id;
        ctc.FirstName = 'contacto';
        ctc.LastName = 'prueba';
        
		OpportunityService.envioAlertaOppDuplicada(m,myStringSet);
		
        
        OpportunityService.reasignarOportunidadVendedores(listaOp);
        Set<Id> idsOpTasks = new Set<Id>();
        Set<Id> actOpTasks = new Set<Id>();
        idsOpTasks.add(op.Id);
        idsOpTasks.add(op2.Id);
        actOpTasks.add(op.AccountId);
        actOpTasks.add(op2.AccountId);
        OpportunityService.crearTareasOportunidad(idsOpTasks,actOpTasks);
        
        Oportunidad_de_Financiamiento__c oppFin = new Oportunidad_de_Financiamiento__c();
        oppFin.Name = 'test Opp';
        insert oppFin;
        Map<ID, String> m2 = new Map<ID, String>();
        m2.put(oppFin.Id, 'op');
        OpportunityService.updateFieldOF(m2);
    }
    
	private static testmethod void validated2(){
        id oppTaller2 = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('BMW').getRecordTypeId();

		Account a2 = new Account
            (             
                FirstName = 'Test',
                LastName    =   'test',
                PersonEmail = 'correotest2@email.com',
                Tipo_de_Documento__c = 'Cedula',
                Cedula__c = '222222222',
                PersonMobilePhone = '+50611223344',
                Sucursal__c = 'Taller Escazú',
                Telefono_Altica__c = '+50611223344',
                Telefono2__c = '+50611223344',
                Numero_Telefonico_Representante_Legal__c = '+50611223344',
                Phone = '+50611223344'
            );
		insert a2;  
        
        Opportunity op = new Opportunity(
                AccountId = a2.id,
                CloseDate = System.today().AddMonths(3),
                StageName = 'Oportunidad Calificada',
                Sucursal__c = 'Uruca',
                tareasCreadas__c = false,
                //MonedaIngreso__c = 'Colones',
                IngresoAproximado__c = 1500,
                RT_Lead__c = 'Polaris'
            );
        insert op;
        
        Opportunity op3 = new Opportunity(
            RecordTypeId = oppTaller2,
            AccountId = a2.id,
            CloseDate = System.today().AddMonths(3),
            StageName = 'Oportunidad Calificada',
            Campana__c = TestDataFactory.campanna.Id,
            Sucursal__c = 'Pinares',
            RT_Lead__c = 'Polaris',
            JefeSucursal__c = UserInfo.getUserId(),
            Name = 'WITHDRAWAL TEST',
            alertEmail__c = false,
            tareasCreadas__c = false
        );   
        insert op3;

        Opportunity op4 = new Opportunity(
            RecordTypeId = oppTaller2,
            AccountId = a2.id,
            CloseDate = System.today().AddMonths(3),
            StageName = 'Oportunidad Calificada',
            Campana__c = TestDataFactory.campanna.Id,
            Sucursal__c = 'Pinares',
            RT_Lead__c = 'Polaris',
            GerenteSucursal__c = UserInfo.getUserId(),
            Name = 'WITHDRAWAL TEST',
            alertEmail__c = false,
            tareasCreadas__c = false
        );   
        insert op4;
   
        Set<Id> myStringSet = new Set<Id>();
        myStringSet.add(op3.Id);
        Map<ID, Opportunity> m3 = new Map<ID, Opportunity>();
        m3.put(op3.AccountId, op);
        OpportunityService.envioAlertaOppDuplicada(m3,myStringSet);
    }
    
    private static testmethod void validated3(){
        id oppTaller2 = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('BMW').getRecordTypeId();

		Account a2 = new Account
            (             
                FirstName = 'Test',
                LastName    =   'test',
                PersonEmail = 'correotest2@email.com',
                Tipo_de_Documento__c = 'Cedula',
                Cedula__c = '222222222',
                PersonMobilePhone = '+50611223344',
                Sucursal__c = 'Taller Escazú',
                Telefono_Altica__c = '+50611223344',
                Telefono2__c = '+50611223344',
                Numero_Telefonico_Representante_Legal__c = '+50611223344',
                Phone = '+50611223344'
            );
		insert a2;  
        
        Opportunity op = new Opportunity(
                AccountId = a2.id,
                CloseDate = System.today().AddMonths(3),
                StageName = 'Oportunidad Calificada',
                Sucursal__c = 'Uruca',
                tareasCreadas__c = false,
                //MonedaIngreso__c = 'Colones',
                IngresoAproximado__c = 1500,
                RT_Lead__c = 'Polaris'
            );
        insert op;
        
        Opportunity op3 = new Opportunity(
            RecordTypeId = oppTaller2,
            AccountId = a2.id,
            CloseDate = System.today().AddMonths(3),
            StageName = 'Oportunidad Calificada',
            Campana__c = TestDataFactory.campanna.Id,
            Sucursal__c = 'Pinares',
            RT_Lead__c = 'Polaris',
            GerenteSucursal__c = UserInfo.getUserId(),
            Name = 'WITHDRAWAL TEST',
            alertEmail__c = false,
            tareasCreadas__c = false
        );   
        insert op3;

        Opportunity op4 = new Opportunity(
            RecordTypeId = oppTaller2,
            AccountId = a2.id,
            CloseDate = System.today().AddMonths(3),
            StageName = 'Oportunidad Calificada',
            Campana__c = TestDataFactory.campanna.Id,
            Sucursal__c = 'Pinares',
            RT_Lead__c = 'Polaris',
            GerenteSucursal__c = UserInfo.getUserId(),
            Name = 'WITHDRAWAL TEST',
            alertEmail__c = false,
            tareasCreadas__c = false
        );   
        insert op4;
   
        Set<Id> myStringSet = new Set<Id>();
        myStringSet.add(op3.Id);
        Map<ID, Opportunity> m3 = new Map<ID, Opportunity>();
        m3.put(op3.AccountId, op);
        OpportunityService.envioAlertaOppDuplicada(m3,myStringSet);
    }
    
}