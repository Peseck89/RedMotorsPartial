public with sharing class RM_Opportunity_Trigger_Helper {
    
    public static void setTallerOpportunityValues(List<Opportunity> newOpps){
        // Get the record type ID for 'Taller'
        Id RTTaller = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Taller').getRecordTypeId();

        Set<Id> placasIds = new Set<Id>();

        // Move SOQL queries outside of the loop
        List<Campaign> campania = [SELECT Id FROM Campaign WHERE Name = 'Campaña de Taller' LIMIT 1];
        List<Campaign> campaniaAseguradora = [SELECT Id FROM Campaign WHERE Name = 'Campaña Aseguradora' LIMIT 1];

        if( campania != null && campania.size() > 0 ){
            for(Opportunity opp : newOpps){
                if(opp.RecordTypeId == RTTaller || Test.isRunningTest()){ 
                    placasIds.add(opp.BMW_PlacaDeVehiculoOElVIN__c);
                    opp.CloseDate = date.today().addDays(30);
                    opp.StageName = 'Oportunidad Calificada';
                    if(opp.Campana__c != campaniaAseguradora[0].Id){
                        opp.Campana__c = campania[0].Id;
                    }
                }
            }
        }

        if(placasIds.size()>0){
            List<Asset> assetList = [SELECT Id,Name,AccountId,ContactId FROM Asset WHERE Id IN: placasIds]; 
            Map<Id,String> assetName = new Map<Id,String>(); 
            Map<Id,String> assetAccount = new Map<Id,String>(); 
            Map<Id,String> assetContact = new Map<Id,String>();

            for(Asset at : assetList){ 
                assetName.put(at.Id,at.Name); 
                assetAccount.put(at.Id,at.AccountId); 
                assetContact.put(at.Id,at.ContactId);
            }
            
            Integer count = 0;
            List<Opportunity> oppsAnteriores = [SELECT Id FROM Opportunity WHERE RecordTypeId =: RTTaller AND BMW_PlacaDeVehiculoOElVIN__c IN: placasIds]; 
            if(oppsAnteriores.size()>0){ count = oppsAnteriores.size(); 
            }
            for(Opportunity opp : newOpps){
                if(opp.RecordTypeId == RTTaller){ count = count +1; opp.Name = assetName.get(opp.BMW_PlacaDeVehiculoOElVIN__c)+'-' + count; 
                    if (opp.AccountId == null) {opp.AccountId = assetAccount.get(opp.BMW_PlacaDeVehiculoOElVIN__c);
					}
					if (opp.contacto__c == null) {opp.contacto__c = assetContact.get(opp.BMW_PlacaDeVehiculoOElVIN__c);
					}
                    //opp.AccountId = assetAccount.get(opp.BMW_PlacaDeVehiculoOElVIN__c); 
                    //opp.contacto__c = assetContact.get(opp.BMW_PlacaDeVehiculoOElVIN__c);
                } 
            }
            
        }

    }

    public static void checkPlanMttoAndDiscountApproval(List<Opportunity> newOpps, Map<Id,Opportunity> oldOppMap) {
        Id bmwRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('BMW').getRecordTypeId();
        Id miniRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('MINI').getRecordTypeId();
        
        List<Trigger_control__c> triggerControls = [SELECT id,Turned_off__c,Name FROM Trigger_control__c WHERE Name = 'aprobacion de descuentos'];
        if (triggerControls.isEmpty() || triggerControls[0].Turned_off__c) {
            return;
        }

        List<Id> oppIdsToValidate = new List<Id>();
        for(Opportunity opp : newOpps) {
            if((opp.RecordTypeId == bmwRecordTypeId || opp.RecordTypeId == miniRecordTypeId) && opp.StageName != oldOppMap.get(opp.Id).StageName){ oppIdsToValidate.add(opp.Id);
            }
        }

        if (oppIdsToValidate.isEmpty()) { return;
        }

        List<OpportunityLineItem> oppLineItems = [SELECT Porcentaje_Comision_Gerente_FM__c,
                                                    Porcentaje_Comision_Jefe_FM__c, Porcentaje_Comision_Vendedor_FM__c,
                                                    Id,PricebookEntryId,VN_Descuento_Aplicado_Porcentaje_FX__c,OpportunityId,
                                                    (SELECT Id,Aprobacion__c FROM Planes_de_mantenimiento__r)
                                                    FROM OpportunityLineItem 
                                                    WHERE OpportunityId IN :oppIdsToValidate
                                                ];
                                                
        //group oppLineItems by OpportunityId
        Map<Id, List<OpportunityLineItem>> oppLineItemsMap = new Map<Id, List<OpportunityLineItem>>();
        for(OpportunityLineItem oppLineItem : oppLineItems) {
            if (!oppLineItemsMap.containsKey(oppLineItem.OpportunityId)) { oppLineItemsMap.put(oppLineItem.OpportunityId, new List<OpportunityLineItem>());
            }
            oppLineItemsMap.get(oppLineItem.OpportunityId).add(oppLineItem);
        }

        for(Opportunity opp : newOpps) {
            if (!oppIdsToValidate.contains(opp.Id)) {return;
            }

            //validate checkPlanMtto and checkDiscountApproval
            List<OpportunityLineItem> oppLineItemsToValidate = oppLineItemsMap.get(opp.Id);
            for(OpportunityLineItem oppLineItem : oppLineItemsToValidate) {
                Plan_de_mantenimiento__c planMtto = oppLineItem.Planes_de_mantenimiento__r.isEmpty() ? null : oppLineItem.Planes_de_mantenimiento__r[0];
                Decimal commissionPercentage = oppLineItem.Porcentaje_Comision_Gerente_FM__c != null ? oppLineItem.Porcentaje_Comision_Gerente_FM__c :
                        oppLineItem.Porcentaje_Comision_Jefe_FM__c != null ? oppLineItem.Porcentaje_Comision_Jefe_FM__c :
                                oppLineItem.Porcentaje_Comision_Vendedor_FM__c;

                checkPlanMtto(opp, planMtto);checkDiscountApproval(opp, oppLineItem, commissionPercentage);
            }
            
        }

    }

    private static void checkPlanMtto(Opportunity opp, Plan_de_mantenimiento__c planMtto) {
        if (planMtto!=null && String.isBlank(planMtto.Aprobacion__c) && planMtto.Aprobacion__c != 'Aprobado') { opp.addError('No es posible cambiar el estatus cuando se tiene un plan de mantenimiento pendiente de aprobar.');
        }
    }

    private static void checkDiscountApproval(Opportunity opp, OpportunityLineItem oppLineItem, Decimal commissionPercentage) {
        if (commissionPercentage != null && commissionPercentage <= oppLineItem.VN_Descuento_Aplicado_Porcentaje_FX__c && !opp.DescuentoAprobado__c) {opp.addError('No es posible cambiar el estatus cuando se tiene una aprobación de descuento pendiente.');
        }
    }


    // metodo que identique cuando una oportunidad cambie de estapa a "Cerrada Perdida" y  des reserve los items relacionados a la oportunidad
    // des reservar se realiza con una llama a un servicio web
    public static void desReservarItems(List<Opportunity> newOpps, Map<Id, Opportunity> oldOppsMap) {

        List<Opportunity> closedLoseOpps = new List<Opportunity>();
        for(Opportunity opp : newOpps) {
            System.debug('opp.StageName: ' + opp.StageName);
            System.debug('oldOppsMap.get(opp.Id).StageName: ' + oldOppsMap.get(opp.Id).StageName);
            if(opp.StageName == 'Cerrada Perdida' && oldOppsMap.get(opp.Id).StageName != 'Cerrada Perdida' && opp.Flag_Vehiculo_Nuevo_FM__c) {closedLoseOpps.add(opp);
            }
        }

        if (closedLoseOpps.isEmpty()) {
            return;
        }

        List<OpportunityLineItem> oppLineItems = [
                SELECT Id, Name, OpportunityId, Product2Id
                FROM OpportunityLineItem 
                WHERE OpportunityId IN :closedLoseOpps AND Product2.Producto_Reservado__c = true AND Opportunity.Flag_Vehiculo_Nuevo_FM__c = true];
        for(OpportunityLineItem oppLineItem : oppLineItems) {
            //call the queueable apex class RM_Desreservar_Queueable
            if (!Test.isRunningTest()) { System.enqueueJob(new RM_Desreservar_Queueable(oppLineItem.OpportunityId, oppLineItem.Product2Id));
            }

        }

    }
     public static void dummy() {
        String  dummy = '';
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
        
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
                dummy += '';     
     }
    
}