public with sharing class RM_CT_GestionMecanicos_Ctrl {

    public static Set<Id> getContactIds(String territoryId){
        Set<Id> contactIds = new Set<Id>();
        String filtroTaller = String.isNotBlank(territoryId) ? 'RM_Taller__c = :territoryId AND' : '';
        String userId = UserInfo.getUserId();
        String query = 'SELECT RM_Mecanico__c FROM RM_MecanicoTaller__c WHERE '+filtroTaller+' RM_Mecanico__r.Activo__c = true AND RM_Taller__c IN (SELECT FSL__ServiceTerritory__c FROM FSL__User_Territory__c WHERE FSL__User__c = :userId)';
        List<RM_MecanicoTaller__c> mecanicosTallers = (List<RM_MecanicoTaller__c>) Database.query(query);
        for (RM_MecanicoTaller__c mecanicoTaller : mecanicosTallers) {
            contactIds.add(mecanicoTaller.RM_Mecanico__c);
        }
        System.debug('contactIds: '+contactIds);
        return contactIds;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String,Object> getData(String territoryId,Integer pageSize, Integer pageNumber){
        try {
            Map<String,Object> result = new Map<String,Object>();
            pageSize = 200;
            pageNumber = 1;
            Integer offset = (pageNumber - 1) * pageSize;
            List<Contact> contacts = new List<Contact>();
            Set<Id> contactIds = getContactIds(territoryId);
            if (contactIds.isEmpty()) {
                result.put('contacts',contacts);
                return result;
            }
            String soqlWhere = ' AND Id IN :contactIds ';
            String query = 'SELECT Id, Name,(SELECT Id, RM_Caso__c, RM_Caso__r.CaseNumber, RM_Paso__c, RM_Paso__r.Status, RM_Paso__r.Name, RM_Orden__c, RM_Orden__r.WorkOrderNumber, RM_Tipo__c,RM_Taller__c, RM_Taller__r.Name, RM_FechaHoraInicio__c FROM Actividades_Mecanicos__r ORDER BY CreatedDate DESC LIMIT 1) FROM Contact WHERE RecordType.DeveloperName = \'Contacto_de_Taller\' AND Activo__c = true '+soqlWhere+' ORDER BY Name ASC LIMIT :pageSize OFFSET :offset ';
            contacts = Database.query(query);
            result.put('contacts', contacts);
            return result;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static Map<String,Object> getTerritoriesByUserId(String userId){
        Map<String,Object> result = new Map<String,Object>();
        try {
            List<Id> territoryIds = new List<Id>();
            for(FSL__User_Territory__c ut : [SELECT FSL__ServiceTerritory__c FROM FSL__User_Territory__c WHERE FSL__User__c =: userId] ){
                territoryIds.add(ut.FSL__ServiceTerritory__c);
            }
            result.put('territories',[SELECT Id,Name FROM ServiceTerritory WHERE Id IN :territoryIds]);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return result;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String,Object> getTerritoriesByContactId(String contactId){
        Map<String,Object> result = new Map<String,Object>();
        try {
            Set<Id> tallerIds = new Set<Id>();
            for(RM_MecanicoTaller__c mt : [SELECT RM_Taller__c FROM RM_MecanicoTaller__c WHERE RM_Mecanico__c =: contactId] ){
                tallerIds.add(mt.RM_Taller__c);
            }
            result.put('territories',[SELECT Id,Name FROM ServiceTerritory WHERE Id IN :tallerIds]);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return result;
    }

    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getTipoValues() {
        List<Map<String, String>> picklistValues = new List<Map<String, String>>();
        
        try {
            Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get('Horas_improductivas_por_mec_nico__c');
            if (sObjectType != null) {
                Schema.DescribeSObjectResult describeSObjectResult = sObjectType.getDescribe();
                Schema.SObjectField sObjectField = describeSObjectResult.fields.getMap().get('Tipo__c');
        
                if (sObjectField != null) {
                    Schema.DescribeFieldResult describeFieldResult = sObjectField.getDescribe();
                    for (Schema.PicklistEntry picklistEntry : describeFieldResult.getPicklistValues()) {
                        Map<String, String> picklistValue = new Map<String, String>();
                        picklistValue.put('name', picklistEntry.getValue());
                        picklistValue.put('label', picklistEntry.getLabel());
                        picklistValues.add(picklistValue);
                    }
                }
            }   
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        return picklistValues;
    }


    @AuraEnabled
    public static Map<String,Object> crearActividad(String mechanicId,String tallerId,String tipo){
        try {
            Map<String,Object> result = new Map<String,Object>();
            RM_ActividadMecanico__c actividad = new RM_ActividadMecanico__c();
            actividad.Name = tipo;
            actividad.RM_Mecanico__c = mechanicId;
            actividad.RM_Taller__c = tallerId;
            actividad.RM_FechaHoraInicio__c = System.now();
            actividad.RM_Tipo__c = tipo;
            if (tipo == 'Salida Taller') {
                actividad.RM_FechaHoraFin__c = System.now();
            }

            INSERT actividad;
            result.put('registro', actividad);
            return result;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

}