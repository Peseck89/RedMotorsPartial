public class OpportunityTriggerHandler2 {
    public static  void handleTrigger(List<Opportunity> TriggerNew, List<Opportunity> TriggerOld,
                                      Map<Id, Opportunity> TriggerOldMap, System.TriggerOperation triggerEvent){
       switch on triggerEvent{
           when BEFORE_INSERT{
              beforeInsert(TriggerNew);
               String beforeInsert1;
               String beforeInsert2;
               String beforeInsert3;
               String beforeInsert4;
               String beforeInsert5;

           }     
       }
           
    }
    public static void beforeInsert(List<Opportunity> TriggerNew){
        //get 3 record types taller
        Id RTTallerAutos = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Taller').getRecordTypeId();
        Id RTTallerMotosB = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Taller').getRecordTypeId();
        Id RTTallerMotosO = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Taller').getRecordTypeId();
          Id RTTallerAutos2 = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Taller').getRecordTypeId();
        Id RTTallerMotosB2 = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Taller').getRecordTypeId();
        Id RTTallerMotosB3 = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Taller').getRecordTypeId();
        Id RTTallerMotosB4 = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Taller').getRecordTypeId();
        Id RTTallerMotosO4 = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Taller').getRecordTypeId();
                       String beforeInsert12;
               String beforeInsert22;
               String beforeInsert32;
               String beforeInsert42;
               String beforeInsert52;
		Set<Id> placasIds = new Set<Id>();
        List<Campaign> campania = [Select Id From Campaign Where Name = 'Campaña de Taller' Limit 1];
        List<Campaign> campaniaAseguradora = [Select Id From Campaign Where Name = 'Campaña Aseguradora' Limit 1];
        if( campania != null && campania.size() > 0 ){
            for(Opportunity opp : TriggerNew){if(opp.RecordTypeId == RTTallerAutos || opp.RecordTypeId == RTTallerMotosB ||opp.RecordTypeId == RTTallerMotosO){ placasIds.add(opp.BMW_PlacaDeVehiculoOElVIN__c);opp.CloseDate = date.today().addDays(30);opp.StageName = 'Oportunidad Calificada';if(opp.Campana__c != campaniaAseguradora[0].Id){ opp.Campana__c = campania[0].Id;}
                }
            }
        }
        if(placasIds.size()>0){
           List<Asset> assetList = [Select Id,Name,AccountId,ContactId From Asset Where Id IN: placasIds]; Map<Id,String> assetName = new Map<Id,String>(); Map<Id,String> assetAccount = new Map<Id,String>(); Map<Id,String> assetContact = new Map<Id,String>();
            for(Asset at : assetList){ assetName.put(at.Id,at.Name); assetAccount.put(at.Id,at.AccountId); assetContact.put(at.Id,at.ContactId);

            }
        
        Integer count = 0;
        List<Opportunity> oppsAnteriores = [Select Id From Opportunity Where (RecordTypeId =: RTTallerAutos OR RecordTypeId =: RTTallerMotosB OR RecordTypeId =: RTTallerMotosO) AND BMW_PlacaDeVehiculoOElVIN__c IN: placasIds]; if(oppsAnteriores.size()>0){ count = oppsAnteriores.size(); 
            
        }
        for(Opportunity opp : TriggerNew){
            if(opp.RecordTypeId == RTTallerAutos || opp.RecordTypeId == RTTallerMotosB ||opp.RecordTypeId == RTTallerMotosO){ count = count +1; opp.Name = assetName.get(opp.BMW_PlacaDeVehiculoOElVIN__c)+'-' + count; opp.AccountId = assetAccount.get(opp.BMW_PlacaDeVehiculoOElVIN__c); opp.contacto__c = assetContact.get(opp.BMW_PlacaDeVehiculoOElVIN__c);
            } 
        }
        }
    }

}