public class OpportunityTriggerHandler extends TriggerHandler {

    private List<Opportunity> newRecordList;
    private Map<Id, Opportunity> newRecordMap;
    
    private List<Opportunity> oldRecordList;
    private Map<Id, Opportunity> oldRecordMap;
    
    public OpportunityTriggerHandler() {
        this.newRecordList = (List<Opportunity>) Trigger.New; 
        this.newRecordMap = (Map<Id, Opportunity>) Trigger.newMap;
        this.oldRecordList = (List<Opportunity>) Trigger.Old;
        this.oldRecordMap = (Map<Id, Opportunity>) Trigger.oldMap;
    }
    
    public override void beforeInsert(){

        set<String> accountIds = new set<String>();
        set<String> sucursalesNombres = new set<String>();
        Map<String,Account> accountMap = new map<String,Account>();
        Map<ID,Schema.RecordTypeInfo> rt_Map = Opportunity.sObjectType.getDescribe().getRecordTypeInfosById();
        Map<string,Sucursal__c> mapSucursales = new map<string,Sucursal__c>();
        list<Opportunity> oportunidadesReasignacion = new list<Opportunity>();
        
		System.debug('****** RTMap ***** ' + rt_Map);
        for(Opportunity opp:newRecordList){
        
            system.debug(':::OWNER 1:  ' + opp.OwnerId);

            opp.UltimaModificacion__c = System.now();
            opp.FechaUltimoCambioEtapa__c = System.now();

            if(opp.AccountId!=null){
                accountIds.add(opp.AccountId);
            }
            
            if(opp.Sucursal__c!=null){
                system.debug('sucursal Op:  ' + opp.Sucursal__c);
                sucursalesNombres.add(opp.Sucursal__c);
            }
            
            if(opp.LeadSource!=null && (opp.LeadSource.equals('Facebook') || opp.LeadSource.equals('Página Web'))){
                oportunidadesReasignacion.add(opp);
            }          

            system.debug(':::OWNER 2:  ' + opp.OwnerId);
        }
        
        if(!oportunidadesReasignacion.isEmpty()){
            OpportunityService.reasignarOportunidadVendedores(oportunidadesReasignacion);
        }
	
		System.debug('****** accounts Ids ***** ' + accountIds);
        if (accountIds!=null&&accountIds.size()>0) {
        	System.debug('****** entro 1 ******');
			System.debug('***** lista acounts ids ***** ' + accountIds);
            Util.llenarDatosAccount(accountIds);
            accountMap = Util.mapaAccounts;             
            
        }
        
        if(sucursalesNombres!=null&&sucursalesNombres.size()>0){
            for(Sucursal__c suc:[SELECT Id,Name, Marca__c, 
                    DirectordeVentasBMW__c,
                    GerentedeSucursalBMW__c, 
                    JefeseSucursalBMW__c, 
                    DirectordeVentasPolaris__c, 
                    GerentedeSucursalPolaris__c, 
                    JefesdeSucursalPolaris__c, 
                    DirectordeVentasMini__c,
                    GerentedeSucursalMini__c,
                    JefesdeSucursalMini__c, 
                    DirectordeVentasKTM__c,
                    GerentedeSucursalKTM__c, 
                    JefesdeSucursalKTM__c, 
                    DirectordeVentasKawasaki__c,
                    GerentedeSucursalKawasaki__c, 
                    JefesdeSucursalKawasaki__c, 
                    DirectordeVentasMotorrad__c,
                    Gerente_de_SucursalMotorrad__c, 
                    JefedeSucursalMotorrad__c,
                    DirectordeVentasHarley__c,
                    GerentedeSucursalHarley__c,
                    JefedeSucursalHarley__c
                FROM Sucursal__c
                WHERE Name IN: sucursalesNombres]){
                    mapSucursales.put(suc.Name,suc);
            }
        }
        
        system.debug('mapa sucursal:  ' + mapSucursales.values());

        for (Opportunity opp:newRecordList) {
            
            system.debug(':::OWNER 3:  ' + opp.OwnerId);
        
            if(accountMap!=null&&accountMap.containsKey(opp.AccountId)){
				System.debug('****** entro 2 ******');
				System.debug('****** RecordType ***** ' + opp.RecordTypeId);
				System.debug('***** nombre rt lead *** ' + opp.RT_Lead__c);
                opp.Name = accountMap.get(opp.AccountId).Name + '-' + rt_map.get(opp.recordTypeID).getName() + '-' + System.today().format();   
                System.debug('********* NOMBRE OP ****** ' + opp.Name);    
                opp.CorreoElectronicoCliente__c = accountMap.get(opp.AccountId).IsPersonAccount?accountMap.get(opp.AccountId).PersonEmail:accountMap.get(opp.AccountId).CorreoElectronicoEmpresarial__c;
            }
            
            if(mapSucursales!=null&&mapSucursales.containsKey(opp.Sucursal__c)){
                
                opp.SucursalId__c = mapSucursales.get(opp.Sucursal__c).Id;
                //Marca: BMW
                if(rt_map.get(opp.recordTypeID).getName().equals('BMW')){
                    system.debug(rt_map.get(opp.recordTypeID).getName() + '| Director: ' + mapSucursales.get(opp.Sucursal__c).DirectordeVentasBMW__c + '| Gerente: ' + mapSucursales.get(opp.Sucursal__c).GerentedeSucursalBMW__c + '| Jefe: ' + mapSucursales.get(opp.Sucursal__c).JefeseSucursalBMW__c);
                    
                    if(mapSucursales.get(opp.Sucursal__c).DirectordeVentasBMW__c!=null)
                        opp.DirectorVentas__c = mapSucursales.get(opp.Sucursal__c).DirectordeVentasBMW__c;
                        
                    if(mapSucursales.get(opp.Sucursal__c).GerentedeSucursalBMW__c!=null)
                        opp.GerenteSucursal__c = mapSucursales.get(opp.Sucursal__c).GerentedeSucursalBMW__c;
                        
                    if(mapSucursales.get(opp.Sucursal__c).JefeseSucursalBMW__c!=null)
                        opp.JefeSucursal__c = mapSucursales.get(opp.Sucursal__c).JefeseSucursalBMW__c;                      
                     
                }
                //Marca: Polaris
                if(rt_map.get(opp.recordTypeID).getName().equals('Polaris')){
                    system.debug(rt_map.get(opp.recordTypeID).getName() + '| Director: ' + mapSucursales.get(opp.Sucursal__c).DirectordeVentasPolaris__c + '| Gerente: ' + mapSucursales.get(opp.Sucursal__c).GerentedeSucursalPolaris__c + '| Jefe: ' + mapSucursales.get(opp.Sucursal__c).JefesdeSucursalPolaris__c);
                    
                    if(mapSucursales.get(opp.Sucursal__c).DirectordeVentasPolaris__c!=null) opp.DirectorVentas__c = mapSucursales.get(opp.Sucursal__c).DirectordeVentasPolaris__c;
                        
                    if(mapSucursales.get(opp.Sucursal__c).GerentedeSucursalPolaris__c!=null) opp.GerenteSucursal__c = mapSucursales.get(opp.Sucursal__c).GerentedeSucursalPolaris__c;
                        
                    if(mapSucursales.get(opp.Sucursal__c).JefesdeSucursalPolaris__c!=null) opp.JefeSucursal__c = mapSucursales.get(opp.Sucursal__c).JefesdeSucursalPolaris__c;                     
                     
                }
                //Marca: MINI
                if(rt_map.get(opp.recordTypeID).getName().equals('MINI')){
                    system.debug(rt_map.get(opp.recordTypeID).getName() + '| Director: ' + mapSucursales.get(opp.Sucursal__c).DirectordeVentasMini__c + '| Gerente: ' + mapSucursales.get(opp.Sucursal__c).GerentedeSucursalMini__c + '| Jefe: ' + mapSucursales.get(opp.Sucursal__c).JefesdeSucursalMini__c);
                    
                    if(mapSucursales.get(opp.Sucursal__c).DirectordeVentasMini__c!=null)
                        opp.DirectorVentas__c = mapSucursales.get(opp.Sucursal__c).DirectordeVentasMini__c;
                        
                    if(mapSucursales.get(opp.Sucursal__c).GerentedeSucursalMini__c!=null)
                        opp.GerenteSucursal__c = mapSucursales.get(opp.Sucursal__c).GerentedeSucursalMini__c;
                        
                    if(mapSucursales.get(opp.Sucursal__c).JefesdeSucursalMini__c!=null)
                        opp.JefeSucursal__c = mapSucursales.get(opp.Sucursal__c).JefesdeSucursalMini__c;                        
                     
                }
                //Marca: KTM
                // if(rt_map.get(opp.recordTypeID).getName().equals('KTM')){
                //     system.debug(rt_map.get(opp.recordTypeID).getName() + '| Director: ' + mapSucursales.get(opp.Sucursal__c).DirectordeVentasKTM__c + '| Gerente: ' + mapSucursales.get(opp.Sucursal__c).GerentedeSucursalKTM__c + '| Jefe: ' + mapSucursales.get(opp.Sucursal__c).JefesdeSucursalKTM__c);
                    
                //     if(mapSucursales.get(opp.Sucursal__c).DirectordeVentasKTM__c!=null) opp.DirectorVentas__c = mapSucursales.get(opp.Sucursal__c).DirectordeVentasKTM__c;
                        
                //     if(mapSucursales.get(opp.Sucursal__c).GerentedeSucursalKTM__c!=null) opp.GerenteSucursal__c = mapSucursales.get(opp.Sucursal__c).GerentedeSucursalKTM__c;
                        
                //     if(mapSucursales.get(opp.Sucursal__c).JefesdeSucursalKTM__c!=null) opp.JefeSucursal__c = mapSucursales.get(opp.Sucursal__c).JefesdeSucursalKTM__c;                     
                     
                // }
                //Marca: Kawasaki
                if(rt_map.get(opp.recordTypeID).getName().equals('Kawasaki')){
                    system.debug(rt_map.get(opp.recordTypeID).getName() + '| Director: ' + mapSucursales.get(opp.Sucursal__c).DirectordeVentasKawasaki__c + '| Gerente: ' + mapSucursales.get(opp.Sucursal__c).GerentedeSucursalKawasaki__c + '| Jefe: ' + mapSucursales.get(opp.Sucursal__c).JefesdeSucursalKawasaki__c);
                    
                    if(mapSucursales.get(opp.Sucursal__c).DirectordeVentasKawasaki__c!=null)
                        opp.DirectorVentas__c = mapSucursales.get(opp.Sucursal__c).DirectordeVentasKawasaki__c;
                        
                    if(mapSucursales.get(opp.Sucursal__c).GerentedeSucursalKawasaki__c!=null)
                        opp.GerenteSucursal__c = mapSucursales.get(opp.Sucursal__c).GerentedeSucursalKawasaki__c;
                        
                    if(mapSucursales.get(opp.Sucursal__c).JefesdeSucursalKawasaki__c!=null)
                        opp.JefeSucursal__c = mapSucursales.get(opp.Sucursal__c).JefesdeSucursalKawasaki__c;                        
                     
                }               
                //Marca: Motorrad
                if(rt_map.get(opp.recordTypeID).getName().equals('Motorrad')){
                    system.debug(rt_map.get(opp.recordTypeID).getName() + '| Director: ' + mapSucursales.get(opp.Sucursal__c).DirectordeVentasMotorrad__c + '| Gerente: ' + mapSucursales.get(opp.Sucursal__c).Gerente_de_SucursalMotorrad__c + '| Jefe: ' + mapSucursales.get(opp.Sucursal__c).JefedeSucursalMotorrad__c);
                    
                    if(mapSucursales.get(opp.Sucursal__c).DirectordeVentasMotorrad__c!=null)
                        opp.DirectorVentas__c = mapSucursales.get(opp.Sucursal__c).DirectordeVentasMotorrad__c;
                        
                    if(mapSucursales.get(opp.Sucursal__c).Gerente_de_SucursalMotorrad__c!=null)
                        opp.GerenteSucursal__c = mapSucursales.get(opp.Sucursal__c).Gerente_de_SucursalMotorrad__c;
                        
                    if(mapSucursales.get(opp.Sucursal__c).JefedeSucursalMotorrad__c!=null)
                        opp.JefeSucursal__c = mapSucursales.get(opp.Sucursal__c).JefedeSucursalMotorrad__c;                     
                     
                } 
                //Marca: Harley Davidson
                System.debug('******* nombre tipo de registro ****** ' + rt_map.get(opp.recordTypeID).getName());
                if(rt_map.get(opp.recordTypeID).getName().equals('Harley-Davidson')){
                    system.debug(rt_map.get(opp.recordTypeID).getName() + '| Director: ' + mapSucursales.get(opp.Sucursal__c).DirectordeVentasHarley__c + '| Gerente: ' + mapSucursales.get(opp.Sucursal__c).GerentedeSucursalHarley__c + '| Jefe: ' + mapSucursales.get(opp.Sucursal__c).JefedeSucursalHarley__c);
                    
                    if(mapSucursales.get(opp.Sucursal__c).DirectordeVentasHarley__c != null) opp.DirectorVentas__c = mapSucursales.get(opp.Sucursal__c).DirectordeVentasHarley__c;
                        
                    if(mapSucursales.get(opp.Sucursal__c).GerentedeSucursalHarley__c != null) opp.GerenteSucursal__c = mapSucursales.get(opp.Sucursal__c).GerentedeSucursalHarley__c;
                        
                    if(mapSucursales.get(opp.Sucursal__c).JefedeSucursalHarley__c != null) opp.JefeSucursal__c = mapSucursales.get(opp.Sucursal__c).JefedeSucursalHarley__c;                     
                }              
                                                                
            }
            system.debug(':::OWNER 4:  ' + opp.OwnerId);   
        }

        RM_Opportunity_Trigger_Helper.setTallerOpportunityValues(newRecordList);

    }
    
    public override void beforeUpdate(){
        
        RM_Opportunity_Trigger_Helper.checkPlanMttoAndDiscountApproval(newRecordList, oldRecordMap);

        set<String> sucursalesNombres = new set<String>();
        Map<ID,Schema.RecordTypeInfo> rt_Map = Opportunity.sObjectType.getDescribe().getRecordTypeInfosById();
        Map<string,Sucursal__c> mapSucursales = new map<string,Sucursal__c>();
        set<String> accountIds = new set<String>();     
        Map<String,Account> accountMap = new map<String,Account>();
        
        for(Opportunity opp:newRecordList){
            system.debug(':::OWNER 5:  ' + opp.OwnerId);
            //Actualiza el campo UltimaModificacion__c con la fecha en la que se cambio la Etapa de la Oportunidad
            if(opp.StageName != null && opp.StageName != oldRecordMap.get(opp.Id).StageName){
                opp.UltimaModificacion__c = System.now();
            }     
            
            System.debug('opp.recordtypeId '+ opp.recordtypeId);
            System.debug('oldRecordMap.get(opp.id).recordtypeId ' + oldRecordMap.get(opp.id).recordtypeId);
            
            if(opp.recordtypeId != oldRecordMap.get(opp.id).recordtypeId){
                system.debug('SI cambió el tipo de registro');
                if(opp.AccountId!=null){
                    accountIds.add(opp.AccountId);
                }               
                
                if(opp.Sucursal__c!=null){
                    system.debug('sucursal Op:  ' + opp.Sucursal__c);
                    sucursalesNombres.add(opp.Sucursal__c);
                }           
            }
            
            if(opp.Importetotaldelnegocio__c != null && opp.Importetotaldelnegocio__c > 0 && opp.Importetotaldelnegocio__c != oldRecordMap.get(opp.Id).Importetotaldelnegocio__c){ opp.Prima__c = (opp.Importetotaldelnegocio__c * Integer.valueOf(System.Label.PorcentajeDefaultPrima)) / 100;
            }
            system.debug(':::OWNER 6:  ' + opp.OwnerId);
        }//for(Opportunity opp:newRecordList)
        
        if (accountIds!=null&&accountIds.size()>0) {
            Util.llenarDatosAccount(accountIds);
            accountMap = Util.mapaAccounts;             
            
        }       
        
        if(sucursalesNombres != null && sucursalesNombres.size() > 0){
            for(Sucursal__c suc:[SELECT Id,Name, Marca__c, 
                    DirectordeVentasBMW__c,
                    GerentedeSucursalBMW__c, 
                    JefeseSucursalBMW__c, 
                    DirectordeVentasPolaris__c, 
                    GerentedeSucursalPolaris__c, 
                    JefesdeSucursalPolaris__c, 
                    DirectordeVentasMini__c,
                    GerentedeSucursalMini__c,
                    JefesdeSucursalMini__c, 
                    DirectordeVentasKTM__c,
                    GerentedeSucursalKTM__c, 
                    JefesdeSucursalKTM__c, 
                    DirectordeVentasKawasaki__c,
                    GerentedeSucursalKawasaki__c, 
                    JefesdeSucursalKawasaki__c, 
                    DirectordeVentasMotorrad__c,
                    Gerente_de_SucursalMotorrad__c, 
                    JefedeSucursalMotorrad__c,
                    DirectordeVentasHarley__c,
                    GerentedeSucursalHarley__c,
                    JefedeSucursalHarley__c
                FROM Sucursal__c
                WHERE Name IN: sucursalesNombres]){
                    mapSucursales.put(suc.Name,suc);
            }
        }
        
        system.debug('mapa sucursal:  ' + mapSucursales.values());

        for (Opportunity opp : newRecordList) {
            system.debug(':::OWNER 7:  ' + opp.OwnerId);
            if(accountMap != null && accountMap.containsKey(opp.AccountId)){
				System.debug('******* recordType 2 ***** ' + opp.RecordTypeId);
                opp.Name = accountMap.get(opp.AccountId).Name + '-' + rt_map.get(opp.recordTypeID).getName() + '-' + System.today().format();       
                System.debug('***** NOMBRE OP 2 ***** ' + opp.Name);
                opp.CorreoElectronicoCliente__c = accountMap.get(opp.AccountId).IsPersonAccount?accountMap.get(opp.AccountId).PersonEmail:accountMap.get(opp.AccountId).CorreoElectronicoEmpresarial__c;
            }
                        
            if(mapSucursales != null && mapSucursales.containsKey(opp.Sucursal__c)){
                
                opp.SucursalId__c = mapSucursales.get(opp.Sucursal__c).Id;
                //Marca: BMW
                if(rt_map.get(opp.recordTypeID).getName().equals('BMW')){
                    system.debug(rt_map.get(opp.recordTypeID).getName() + '| Director: ' + mapSucursales.get(opp.Sucursal__c).DirectordeVentasBMW__c + '| Gerente: ' + mapSucursales.get(opp.Sucursal__c).GerentedeSucursalBMW__c + '| Jefe: ' + mapSucursales.get(opp.Sucursal__c).JefeseSucursalBMW__c);
                    
                    if(mapSucursales.get(opp.Sucursal__c).DirectordeVentasBMW__c!=null)
                        opp.DirectorVentas__c = mapSucursales.get(opp.Sucursal__c).DirectordeVentasBMW__c;
                        
                    if(mapSucursales.get(opp.Sucursal__c).GerentedeSucursalBMW__c!=null)
                        opp.GerenteSucursal__c = mapSucursales.get(opp.Sucursal__c).GerentedeSucursalBMW__c;
                        
                    if(mapSucursales.get(opp.Sucursal__c).JefeseSucursalBMW__c!=null)
                        opp.JefeSucursal__c = mapSucursales.get(opp.Sucursal__c).JefeseSucursalBMW__c;                      
                     
                }else if(rt_map.get(opp.recordTypeID).getName().equals('Polaris')){//Marca: Polaris
                    system.debug(rt_map.get(opp.recordTypeID).getName() + '| Director: ' + mapSucursales.get(opp.Sucursal__c).DirectordeVentasPolaris__c + '| Gerente: ' + mapSucursales.get(opp.Sucursal__c).GerentedeSucursalPolaris__c + '| Jefe: ' + mapSucursales.get(opp.Sucursal__c).JefesdeSucursalPolaris__c);
                    
                    if(mapSucursales.get(opp.Sucursal__c).DirectordeVentasPolaris__c!=null) opp.DirectorVentas__c = mapSucursales.get(opp.Sucursal__c).DirectordeVentasPolaris__c;
                        
                    if(mapSucursales.get(opp.Sucursal__c).GerentedeSucursalPolaris__c!=null) opp.GerenteSucursal__c = mapSucursales.get(opp.Sucursal__c).GerentedeSucursalPolaris__c;
                        
                    if(mapSucursales.get(opp.Sucursal__c).JefesdeSucursalPolaris__c!=null) opp.JefeSucursal__c = mapSucursales.get(opp.Sucursal__c).JefesdeSucursalPolaris__c;                     
                     
                }else if(rt_map.get(opp.recordTypeID).getName().equals('MINI')){//Marca: MINI
                    system.debug(rt_map.get(opp.recordTypeID).getName() + '| Director: ' + mapSucursales.get(opp.Sucursal__c).DirectordeVentasMini__c + '| Gerente: ' + mapSucursales.get(opp.Sucursal__c).GerentedeSucursalMini__c + '| Jefe: ' + mapSucursales.get(opp.Sucursal__c).JefesdeSucursalMini__c);
                    
                    if(mapSucursales.get(opp.Sucursal__c).DirectordeVentasMini__c!=null)
                        opp.DirectorVentas__c = mapSucursales.get(opp.Sucursal__c).DirectordeVentasMini__c;
                        
                    if(mapSucursales.get(opp.Sucursal__c).GerentedeSucursalMini__c!=null)
                        opp.GerenteSucursal__c = mapSucursales.get(opp.Sucursal__c).GerentedeSucursalMini__c;
                        
                    if(mapSucursales.get(opp.Sucursal__c).JefesdeSucursalMini__c!=null)
                        opp.JefeSucursal__c = mapSucursales.get(opp.Sucursal__c).JefesdeSucursalMini__c;                        
                     
                }
                else if(rt_map.get(opp.recordTypeID).getName().equals('KTM')){ //Marca: KTM
                    // system.debug(rt_map.get(opp.recordTypeID).getName() + '| Director: ' + mapSucursales.get(opp.Sucursal__c).DirectordeVentasKTM__c + '| Gerente: ' + mapSucursales.get(opp.Sucursal__c).GerentedeSucursalKTM__c + '| Jefe: ' + mapSucursales.get(opp.Sucursal__c).JefesdeSucursalKTM__c);
                    
                    // if(mapSucursales.get(opp.Sucursal__c).DirectordeVentasKTM__c!=null) opp.DirectorVentas__c = mapSucursales.get(opp.Sucursal__c).DirectordeVentasKTM__c;
                        
                    // if(mapSucursales.get(opp.Sucursal__c).GerentedeSucursalKTM__c!=null)  opp.GerenteSucursal__c = mapSucursales.get(opp.Sucursal__c).GerentedeSucursalKTM__c;
                        
                    // if(mapSucursales.get(opp.Sucursal__c).JefesdeSucursalKTM__c!=null)  opp.JefeSucursal__c = mapSucursales.get(opp.Sucursal__c).JefesdeSucursalKTM__c;                     
                     
                }else if(rt_map.get(opp.recordTypeID).getName().equals('Kawasaki')){//Marca: Kawasaki
                    system.debug(rt_map.get(opp.recordTypeID).getName() + '| Director: ' + mapSucursales.get(opp.Sucursal__c).DirectordeVentasKawasaki__c + '| Gerente: ' + mapSucursales.get(opp.Sucursal__c).GerentedeSucursalKawasaki__c + '| Jefe: ' + mapSucursales.get(opp.Sucursal__c).JefesdeSucursalKawasaki__c);
                    
                    if(mapSucursales.get(opp.Sucursal__c).DirectordeVentasKawasaki__c!=null)  opp.DirectorVentas__c = mapSucursales.get(opp.Sucursal__c).DirectordeVentasKawasaki__c;
                        
                    if(mapSucursales.get(opp.Sucursal__c).GerentedeSucursalKawasaki__c!=null) opp.GerenteSucursal__c = mapSucursales.get(opp.Sucursal__c).GerentedeSucursalKawasaki__c;
                        
                    if(mapSucursales.get(opp.Sucursal__c).JefesdeSucursalKawasaki__c!=null) opp.JefeSucursal__c = mapSucursales.get(opp.Sucursal__c).JefesdeSucursalKawasaki__c;                        
                     
                }else if(rt_map.get(opp.recordTypeID).getName().equals('Motorrad')){//Marca: Motorrad
                    system.debug(rt_map.get(opp.recordTypeID).getName() + '| Director: ' + mapSucursales.get(opp.Sucursal__c).DirectordeVentasMotorrad__c + '| Gerente: ' + mapSucursales.get(opp.Sucursal__c).Gerente_de_SucursalMotorrad__c + '| Jefe: ' + mapSucursales.get(opp.Sucursal__c).JefedeSucursalMotorrad__c);
                    
                    if(mapSucursales.get(opp.Sucursal__c).DirectordeVentasMotorrad__c!=null)
                        opp.DirectorVentas__c = mapSucursales.get(opp.Sucursal__c).DirectordeVentasMotorrad__c;
                        
                    if(mapSucursales.get(opp.Sucursal__c).Gerente_de_SucursalMotorrad__c!=null)
                        opp.GerenteSucursal__c = mapSucursales.get(opp.Sucursal__c).Gerente_de_SucursalMotorrad__c;
                        
                    if(mapSucursales.get(opp.Sucursal__c).JefedeSucursalMotorrad__c!=null)
                        opp.JefeSucursal__c = mapSucursales.get(opp.Sucursal__c).JefedeSucursalMotorrad__c;                     
                     
                }else if(rt_map.get(opp.recordTypeID).getName().equals('Harley-Davidson')){//Marca: Harley Davidson
                	System.debug('****** entro harley davidson *******');
                    system.debug(rt_map.get(opp.recordTypeID).getName() + '| Director: ' + mapSucursales.get(opp.Sucursal__c).DirectordeVentasHarley__c + '| Gerente: ' + mapSucursales.get(opp.Sucursal__c).GerentedeSucursalHarley__c + '| Jefe: ' + mapSucursales.get(opp.Sucursal__c).JefedeSucursalHarley__c);
                    
                    if(mapSucursales.get(opp.Sucursal__c).DirectordeVentasHarley__c != null) opp.DirectorVentas__c = mapSucursales.get(opp.Sucursal__c).DirectordeVentasHarley__c;
                        
                    if(mapSucursales.get(opp.Sucursal__c).GerentedeSucursalHarley__c != null)  opp.GerenteSucursal__c = mapSucursales.get(opp.Sucursal__c).GerentedeSucursalHarley__c;
                        
                    if(mapSucursales.get(opp.Sucursal__c).JefedeSucursalHarley__c != null) opp.JefeSucursal__c = mapSucursales.get(opp.Sucursal__c).JefedeSucursalHarley__c;                     
                }              
                                                                
            }  
            system.debug(':::OWNER 8:  ' + opp.OwnerId);     
        }               
    }
    
    public override void afterInsert(){
        System.debug('***************************** INICIA AFTER INSERT **************************');
        Map<Id, Opportunity> MapOppNews = new Map<Id, Opportunity>();
        Set<Id> setOppNews = new Set<Id>();
        
        for(Opportunity op : newRecordList){
            System.debug('******************* RT LEAD *************' + op.RT_Lead__c + ' ' + op.Name + ' ' + op.RecordTypeId);
            system.debug(':::OWNER 9:  ' + op.OwnerId);
            if(op.AccountId != null){
                System.debug('******************** OP Encontrada ********************' + op.RT_Lead__c + ' ' + op.Name);
                if(!MapOppNews.containsKey(Op.AccountId)){
                    MapOppNews.put(op.AccountId, op); //Se cargan todas las oportunidades existentes
                }
                setOppNews.add(op.Id); //Se carga la oportunidad actual
            }
            system.debug(':::OWNER 10:  ' + op.OwnerId);
        }
        
        if(MapOppNews != null && MapOppNews.values().size() > 0){
            System.debug('*********************************** LLAMA AL METODO ENVIO DE ALERTA ****************************');
            OpportunityService.envioAlertaOppDuplicada(MapOppNews, setOppNews);
        }
        System.debug('***************************** FINALIZA AFTER INSERT **************************');
    }
    
    public override void afterUpdate(){
        System.debug('***************************** INICIA AFTER UPDATE **************************');
        Map<Id, Opportunity> MapOppNews = new Map<Id, Opportunity>();
        Map<Id, String>  mapOp = new Map<Id, String>();
        Set<Id> setOppNews = new Set<Id>();
        Set<Id> idsOpTasks = new Set<Id>();
        Set<Id> actOpTasks = new Set<Id>();
        
        for(Opportunity op : newRecordList){
            System.debug('******************* RT LEAD *************' + op.RT_Lead__c + ' ' + op.Name + ' ' + op.RecordTypeId);
            system.debug(':::OWNER 11:  ' + op.OwnerId);
            if(op.AccountId != null && op.AccountId != oldRecordMap.get(op.Id).AccountId){
                System.debug('******************** OP Encontrada ********************' + op.RT_Lead__c + ' ' + op.Name);
                if(!MapOppNews.containsKey(Op.AccountId)){ MapOppNews.put(op.AccountId, op);
                }
                setOppNews.add(op.Id);
            }
            if(op.ComentariosFinancieros__c != oldRecordMap.get(op.id).ComentariosFinancieros__c){
                mapOp.put(op.Id, op.ComentariosFinancieros__c);          
            }
            system.debug(':::OWNER 12:  ' + op.OwnerId);
            System.debug(' ** nombre etapa ** ' + op.StageName);
            if(op.StageName == 'Cerrada Ganada' && op.StageName != oldRecordMap.get(op.id).StageName){
                BMW_OppCloseWonCreateAccount.createAccountSoftland(op.AccountId);
            }
            if(op.StageName == 'Cerrada Ganada'){
                idsOpTasks.add(op.Id);
                actOpTasks.add(op.AccountId);
            }
        }

        System.debug('************************* MAPA OP ************************* ' + MapOppNews);
        if(MapOppNews != null && MapOppNews.values().size() > 0){
            System.debug('*********************************** LLAMA AL METODO ENVIO DE ALERTA ****************************');
            OpportunityService.envioAlertaOppDuplicada(MapOppNews, setOppNews);
        }

        if(!mapOp.isEmpty()){
            OpportunityService.updateFieldOF(mapOp);
        }

        System.debug(' ** set ids op ** ' + idsOpTasks);
        if(!idsOpTasks.isEmpty() && idsOpTasks.size() > 0){
            System.debug(' ** llama al metodo crearTareasOportunidad ** ');
            OpportunityService.crearTareasOportunidad(idsOpTasks, actOpTasks);
        }

        RM_Opportunity_Trigger_Helper.desReservarItems(newRecordList, oldRecordMap);

    }

    

}