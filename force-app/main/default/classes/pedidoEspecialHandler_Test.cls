@isTest
public class pedidoEspecialHandler_Test {
           
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
    
    
    
    /* Marca: MINI */

    static testMethod void RTMINI() {
        
        //List<RecordType> RTMINI = [Select r.SobjectType, r.Id, r.DeveloperName From RecordType r where r.SobjectType = 'Opportunity' and r.DeveloperName ='MINI'];

        List<Account> listCuentas = TestDataFactory.MapCuentas.values();

		Id MotorradRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Motorrad').getRecordTypeId();
        Id BMWRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('BMW').getRecordTypeId();
		Id MINIRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('MINI').getRecordTypeId();

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
            RecordTypeId = MINIRecordTypeId,//RTMINI[0].Id,
            AccountId = listCuentas[0].id,
            CloseDate = System.today().AddMonths(3),
            StageName = 'Oportunidad Calificada',
            Campana__c = TestDataFactory.campanna.Id,
            Sucursal__c = sucursal.Name,
            RT_Lead__c = 'MINI'
        );      
        
        
            insert op;

			op.RecordTypeId = MotorradRecordTypeId;
			update op;
			op.RecordTypeId = BMWRecordTypeId;
			update op;
			op.RecordTypeId = MINIRecordTypeId;
			update op;


			
                Pedido_Especial__c Prueba1 = new Pedido_Especial__c();
        Prueba1.marca__c = 'BMW';
        Prueba1.Modelo__c = 'Z4';
        Prueba1.Color__c = 'ROJO';        
        Prueba1.Codigo_Tapiceria__c = '234342';
        Prueba1.Anio__c = '2020';
        Prueba1.Oportunidad__c = op.id;
            
         Test.startTest();
        insert Prueba1;
        Test.stopTest();
    }
    
    
    
    
    /* Marca: Kawasaki */
    
    static testMethod void RTKawasaki() {
        
        List<RecordType> RTKawasaki = [Select r.SobjectType, r.Id, r.DeveloperName From RecordType r where r.SobjectType = 'Opportunity' and r.DeveloperName ='Kawasaki'];
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
            RecordTypeId = RTKawasaki[0].Id,
            AccountId = listCuentas[0].id,
            CloseDate = System.today().AddMonths(3),
            StageName = 'Oportunidad Calificada',
            Campana__c = TestDataFactory.campanna.Id,
            Sucursal__c = sucursal.Name,
            RT_Lead__c = 'Kawasaki'
        );      
        
            insert op;
                Pedido_Especial__c Prueba1 = new Pedido_Especial__c();
        Prueba1.marca__c = 'BMW';
        Prueba1.Modelo__c = 'Z4';
        Prueba1.Color__c = 'ROJO';        
        Prueba1.Codigo_Tapiceria__c = '234342';
        Prueba1.Anio__c = '2020';
        Prueba1.Oportunidad__c = op.id;
            
         Test.startTest();
        insert Prueba1;
        Test.stopTest();
        
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
        
        
            insert op;
                Pedido_Especial__c Prueba1 = new Pedido_Especial__c();
        Prueba1.marca__c = 'BMW';
        Prueba1.Modelo__c = 'Z4';
        Prueba1.Color__c = 'ROJO';        
        Prueba1.Codigo_Tapiceria__c = '234342';
        Prueba1.Anio__c = '2020';
        Prueba1.Oportunidad__c = op.id;
            
         Test.startTest();
        insert Prueba1;
        Test.stopTest();
        
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

        
        op.StageName = 'Oferta';
        op.Enganche_monto__c = 150000;
        op.Enganche_recibo__c = '10000';
        op.Realiza_Test_Drive__c = true;
        update op;
        Pedido_Especial__c Prueba1 = new Pedido_Especial__c();
        Prueba1.marca__c = 'BMW';
        Prueba1.Modelo__c = 'Z4';
        Prueba1.Color__c = 'ROJO';        
        Prueba1.Codigo_Tapiceria__c = '234342';
        Prueba1.Anio__c = '2020';
        Prueba1.Oportunidad__c = op.id;
            
         Test.startTest();
        insert Prueba1;
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
        
        Pedido_Especial__c Prueba1 = new Pedido_Especial__c();
        Prueba1.marca__c = 'BMW';
        Prueba1.Modelo__c = 'Z4';
        Prueba1.Color__c = 'ROJO';        
        Prueba1.Codigo_Tapiceria__c = '234342';
        Prueba1.Anio__c = '2020';
        Prueba1.Oportunidad__c = opp.id;
            
         
        insert Prueba1;
    }
    
    

}