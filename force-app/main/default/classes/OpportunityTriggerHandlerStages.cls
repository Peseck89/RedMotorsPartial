public with sharing class OpportunityTriggerHandlerStages {
    
    public static  void handleTrigger(List<Opportunity> TriggerNew){
        String opp1;
        String opp2;
        String opp3;
        String opp4;
        String opp5;
        String opp6;
        String opp7;
        String opp8;
        String opp9;
        String opp10;
        for(Opportunity opp: TriggerNew){
            List<OpportunityLineItem> lstOppItm = [SELECT Porcentaje_Comision_Gerente_FM__c,
                                                   Porcentaje_Comision_Jefe_FM__c,
                                                   Porcentaje_Comision_Vendedor_FM__c,
                                                   Id,PricebookEntryId,VN_Descuento_Aplicado_Porcentaje_FX__c FROM OpportunityLineItem WHERE OpportunityId = : opp.id];
            if(lstOppItm.size()>0){
                for( OpportunityLineItem oppLineItem  : lstOppItm){
                    List<Plan_de_mantenimiento__c> lstPlanMant = [SELECT Id,Aprobacion__c FROM Plan_de_mantenimiento__c WHERE Opportunity_Product__c =: oppLineItem.id];
                    if(lstPlanMant.size() > 0 ){
                        if(lstPlanMant[0].Aprobacion__c != 'Aprobado'){
                            opp.addError('No es posible cambiar el estatus cuando se tiene un plan de mantenimiento pendiente de aprobar.');
                        }
                    }
                    
                    if(oppLineItem.Porcentaje_Comision_Gerente_FM__c != null){
                        if(oppLineItem.Porcentaje_Comision_Gerente_FM__c <= oppLineItem.VN_Descuento_Aplicado_Porcentaje_FX__c && opp.DescuentoAprobado__c != true){
                            opp.addError('No es posible cambiar el estatus cuando se tiene una aprobación de descuento pendiente.');
                        }
                    }
                    if(oppLineItem.Porcentaje_Comision_Jefe_FM__c != null){
                        if(oppLineItem.Porcentaje_Comision_Jefe_FM__c <= oppLineItem.VN_Descuento_Aplicado_Porcentaje_FX__c  && opp.DescuentoAprobado__c != true ){
                            opp.addError('No es posible cambiar el estatus cuando se tiene una aprobación de descuento pendiente.');
                        }
                    }
                    if(oppLineItem.Porcentaje_Comision_Vendedor_FM__c != null){
                        if(oppLineItem.Porcentaje_Comision_Vendedor_FM__c <= oppLineItem.VN_Descuento_Aplicado_Porcentaje_FX__c  && opp.DescuentoAprobado__c != true){
                            opp.addError('No es posible cambiar el estatus cuando se tiene una aprobación de descuento pendiente.');
                        }
                    }
                    
                }
            }
        }
    }
    
}