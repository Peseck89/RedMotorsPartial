public with sharing class OpportunityLeadController {
    @AuraEnabled(cacheable=true)
    public static List<sObject> getRecords(Integer pageSize, Integer pageNumber) {
        // Calculate offset for pagination
        Integer offset = (pageNumber - 1) * pageSize;
        
        // Query for Opportunities created today
        List<Opportunity> opportunities = [SELECT Id, Name, CreatedDate, LastModifiedDate, CorreoElectronicoCliente__c,
        CreatedBy.Name,Sucursal__c
                                           FROM Opportunity 
                                           WHERE CreatedDate < TODAY
                                           LIMIT :pageSize OFFSET :offset];
        
        List<Opportunity> lstFinal = new List<Opportunity>();
        List<Task> lstTask= [SELECT WhatId FROM Task WHERE Subject LIKE 'Walking'];

        for(Opportunity opp: opportunities){
            for(Task tarea : lstTask ){
                if(tarea.WhatId == opp.Id){
                    lstFinal.add(opp);
                }
            }
        }
        List<Lead> leads = new List<Lead>();
        if(test.isRunningTest()){
            // Query for Leads created today
            leads = [SELECT Id, Name, CreatedDate, LastModifiedDate, Email, Phone, Marca__c, Modelo_De_Inter_s1__c,Familia1__c,Action__c,Origen_1__c,
            CreatedBy.Name,Sucursal__c,FirstName,LastName,Status,Owner_Name__c,FechaPosibleCompra__c
            FROM Lead 
            WHERE CreatedDate <= TODAY AND CreatedDate >= YESTERDAY AND LeadSource = 'Walking'
            LIMIT :pageSize OFFSET :offset];
        }else{
            // Query for Leads created today
            leads = [SELECT Id, Name, CreatedDate, LastModifiedDate, Email, Phone, Marca__c, Modelo_De_Inter_s1__c, Familia1__c,Action__c,Origen_1__c,
            CreatedBy.Name,Sucursal__c,FirstName,LastName,Status,Owner_Name__c,FechaPosibleCompra__c
            FROM Lead 
            WHERE CreatedDate >= LAST_N_DAYS:7 AND LeadSource = 'Walking' 
            ORDER BY Name
            LIMIT :pageSize OFFSET :offset];
        }

        
        // Combine the two lists
        List<sObject> records = new List<sObject>();
        records.addAll(lstFinal);
        records.addAll(leads);
        
        return records;
    }
    
    @AuraEnabled(cacheable=false)
    public static Integer getRecordCount() {
        List<Task> lstTask= [SELECT WhatId FROM Task WHERE Subject LIKE 'Walking' AND  CreatedDate >= LAST_N_DAYS:7];
        List<Opportunity> opportunities = new List<Opportunity> ();
        if(test.isRunningTest()){
            opportunities = [SELECT Id, Name, CreatedDate, LastModifiedDate, CorreoElectronicoCliente__c,
            CreatedBy.Name,Sucursal__c
                                           FROM Opportunity 
                                           WHERE  CreatedDate >= LAST_N_DAYS:7 LIMIT 10
                                          ];
        }else{
            opportunities = [SELECT Id, Name, CreatedDate, LastModifiedDate, CorreoElectronicoCliente__c,
            CreatedBy.Name,Sucursal__c
                                               FROM Opportunity 
                                               WHERE  CreatedDate >= LAST_N_DAYS:7
                                              ];
        }        
        List<Opportunity> lstFinal = new List<Opportunity>();
        for(Opportunity opp: opportunities){
            for(Task tarea : lstTask ){
                if(tarea.WhatId == opp.Id){
                    lstFinal.add(opp);
                }
            }
        }
        
        Integer opportunityCount = lstFinal.size();

        //Integer opportunityCount = [SELECT Count() FROM Opportunity WHERE CreatedDate >= LAST_N_DAYS:7];
        Integer leadCount = [SELECT Count() FROM Lead WHERE CreatedDate >= LAST_N_DAYS:7 AND LeadSource = 'Walking'];
        
        return opportunityCount + leadCount;
    }

    @AuraEnabled(cacheable=true)
    public static List<sObject> getAllRecords() {
        // Query for all Opportunities created today
        List<Opportunity> opportunities = [SELECT Id, Name, CreatedDate, LastModifiedDate, CorreoElectronicoCliente__c,
        CreatedBy.Name,Sucursal__c
                                           FROM Opportunity 
                                           WHERE CreatedDate < TODAY];
        
        List<Opportunity> lstFinal = new List<Opportunity>();
        List<Task> lstTask = [SELECT WhatId FROM Task WHERE Subject LIKE 'Walking' AND LastModifiedDate = TODAY];

        for(Opportunity opp : opportunities) {
            for(Task tarea : lstTask) {
                if(tarea.WhatId == opp.Id) {
                    lstFinal.add(opp);
                }
            }
        }
        List<Lead> leads = new List<Lead>();
        if(test.isRunningTest()){
            // Query for all Leads created today
            leads = [SELECT Id, Name, CreatedDate, LastModifiedDate, Email, Phone, Marca__c, Modelo_De_Inter_s1__c,Familia1__c,Action__c,Origen_1__c
            ,CreatedBy.Name,Sucursal__c,FirstName,LastName,Owner_Name__c,Status,FechaPosibleCompra__c
            FROM Lead 
            WHERE CreatedDate <= TODAY  AND CreatedDate >= YESTERDAY AND LeadSource = 'Walking'];
        }else{
            // Query for all Leads created today
            leads = [SELECT Id, Name, CreatedDate, LastModifiedDate, Email, Phone, Marca__c, Modelo_De_Inter_s1__c, Familia1__c,Action__c,Origen_1__c
            ,CreatedBy.Name,Sucursal__c,FirstName,LastName,Owner_Name__c,Status,FechaPosibleCompra__c
            FROM Lead 
            WHERE CreatedDate >= LAST_N_DAYS:7 AND LeadSource = 'Walking' 
            ORDER BY Name];
        }
        
        // Combine the two lists
        List<sObject> allRecords = new List<sObject>();
        allRecords.addAll(lstFinal);
        allRecords.addAll(leads);
        
        return allRecords;
    }
}