public with sharing class cT_tiempoIproductivo {

    @AuraEnabled(cacheable=true)
    public static List<tiposDeTrabajo__c> getTrabajos() {
        return [SELECT Id,Name FROM tiposDeTrabajo__c];
    }



    @AuraEnabled(cacheable=true)
    public static List<Contact> getContact() {
        Id recordTypeId =
        Schema.SObjectType.Contact.getRecordTypeInfosByName()
        .get('Contacto de Taller').getRecordTypeId();
        return [SELECT Id,Name FROM Contact WHERE RecordTypeId = :recordTypeId];
    }
    
}