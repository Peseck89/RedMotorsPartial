public with sharing class ct_closeOldOpp_batch implements Database.Batchable<sObject>,Database.Stateful {

    public Database.QueryLocator start(Database.BatchableContext bc) {
		if (test.isRunningTest()) {
            return Database.getQueryLocator(
                'Select Id, fechaentrega__c, CheckCerrar__c,FechaEstimadaEntrega__c, StageName,DiasCreada__c, Departamento__c, RazonVentaPerdida__c, Tipo_de_Cliente__c, Days_Changed__c,RecordType.name  From Opportunity WHERE ((DiasCreada__c >= 180 AND Days_Changed__c >= 180) OR (DiasCreada__c = 180 AND Days_Changed__c = null)) AND RecordType.name IN (\'BMW\',\'MINI\') AND StageName != \'Cerrada Ganada\' AND StageName != \'Cerrada Perdida\' LIMIT 1 '
            );
        }else{
            return Database.getQueryLocator(
                'Select Id, fechaentrega__c, CheckCerrar__c,FechaEstimadaEntrega__c, StageName, DiasCreada__c, Departamento__c, RazonVentaPerdida__c, Tipo_de_Cliente__c, Days_Changed__c,RecordType.name  From Opportunity WHERE ((DiasCreada__c >= 180 AND Days_Changed__c >= 180) OR (DiasCreada__c = 180 AND Days_Changed__c = null)) AND RecordType.name IN (\'BMW\',\'MINI\') AND StageName != \'Cerrada Ganada\' AND StageName != \'Cerrada Perdida\' LIMIT 15 '
        );
    }        
    }

    public void execute(Database.BatchableContext bc, List<Opportunity> scope){
        // process each batch of records
 
        for (Opportunity opp : scope) {
            opp.StageName = 'Cerrada Perdida';
            opp.fechaentrega__c = null;
            opp.FechaEstimadaEntrega__c = null;
            opp.CheckCerrar__c  = true;          
            opp.RazonVentaPerdida__c = 'Cierre automatico';
        }
        update scope;
    }

    public void finish(Database.BatchableContext bc){

        // call some utility to send email
    }

}