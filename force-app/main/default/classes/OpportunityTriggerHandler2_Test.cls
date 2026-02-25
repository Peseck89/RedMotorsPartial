@isTest
private class OpportunityTriggerHandler2_Test {
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


}