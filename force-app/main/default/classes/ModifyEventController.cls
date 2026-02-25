public without sharing class ModifyEventController {
	@AuraEnabled
    public static List<RecordsData> fetchRecords(String searchString, String value) {
        try {
            List<RecordsData> recordsDataList = new List<RecordsData>();
            String query = 'SELECT Id,name FROM Asset';
            
            if(String.isNotBlank(value)) {
                query += ' WHERE Id = \''+ value + '\' LIMIT 1';
            } else if(searchString == '') {
                 query += ' ORDER BY LastModifiedDate DESC NULLS LAST LIMIT 5';
            } else {
                query += ' WHERE name LIKE ' + '\'' + String.escapeSingleQuotes(searchString.trim()) + '%\' LIMIT 5';
            }
         for(SObject s : Database.query(query)) {
             recordsDataList.add( new RecordsData((String)s.get('name'), (String)s.get('id')) );
         }
            return recordsDataList;
     } catch (Exception err) {
      if ( String.isNotBlank( err.getMessage() ) && err.getMessage().contains( 'error:' ) ) {
                throw new AuraHandledException(err.getMessage().split('error:')[1].split(':')[0] + '.');
            } else {
                throw new AuraHandledException(err.getMessage());
            }
     }
    }
    
    @AuraEnabled
    public static EventData fetchEventDetail(String recordId) {
        try {
            EventData recordsDataList;
            String query = 'SELECT Id,Activo__c,tipoCargoCliente__c,tipoCargoAseguradora__c,tipoCargoGarantia__c,tipoCargoBci__c FROM Event WHERE Id = \''+ recordId + '\' LIMIT 1';
             for(SObject s : Database.query(query)) {
                 recordsDataList = new EventData((String)s.get('Activo__c'),(Boolean)s.get('tipoCargoCliente__c'),(Boolean)s.get('tipoCargoAseguradora__c'),(Boolean)s.get('tipoCargoGarantia__c'),(Boolean)s.get('tipoCargoBci__c'));
             }
            return recordsDataList;
     } catch (Exception err) {
      if ( String.isNotBlank( err.getMessage() ) && err.getMessage().contains( 'error:' ) ) {
                throw new AuraHandledException(err.getMessage().split('error:')[1].split(':')[0] + '.');
            } else {
                throw new AuraHandledException(err.getMessage());
            }
     }
    }
    
    @AuraEnabled
    public static RecordsData updateEventDetail(String recordId,String Activo,Boolean tipoCargoCliente,Boolean tipoCargoAseguradora,Boolean tipoCargoGarantia,Boolean tipoCargoBci) {
        try {
            Event ev = [SELECT Id,Activo__c,tipoCargoCliente__c,tipoCargoAseguradora__c,tipoCargoGarantia__c,tipoCargoBci__c FROM Event WHERE Id =:recordId  LIMIT 1];
            if(Activo == ''){
                Activo = null;
            }
            ev.Activo__c = (Id) Activo;
            ev.tipoCargoCliente__c = (Boolean) tipoCargoCliente;
            ev.tipoCargoAseguradora__c = (Boolean) tipoCargoAseguradora;
            ev.tipoCargoGarantia__c = (Boolean) tipoCargoGarantia;
            ev.tipoCargoBci__c = (Boolean) tipoCargoBci;
            update(ev);
            RecordsData recordsData= new RecordsData('Updated','Updated');
            return recordsData;
     } catch (Exception err) {
      if ( String.isNotBlank( err.getMessage() ) && err.getMessage().contains( 'error:' ) ) {
                throw new AuraHandledException(err.getMessage().split('error:')[1].split(':')[0] + '.');
            } else {
                throw new AuraHandledException(err.getMessage());
            }
     }
    }
    
    public class EventData {
        @AuraEnabled public String Activo;
        @AuraEnabled public Boolean tipoCargoCliente;
        @AuraEnabled public Boolean tipoCargoAseguradora;
        @AuraEnabled public Boolean tipoCargoGarantia;
        @AuraEnabled public Boolean tipoCargoBci;

        public EventData(String Activo,Boolean tipoCargoCliente,Boolean tipoCargoAseguradora,Boolean tipoCargoGarantia,Boolean tipoCargoBci) {
            this.Activo = Activo;
            this.tipoCargoCliente = tipoCargoCliente;
            this.tipoCargoAseguradora = tipoCargoAseguradora;
            this.tipoCargoGarantia = tipoCargoGarantia;
            this.tipoCargoBci = tipoCargoBci;

        }
    }
    
    public class RecordsData {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        public RecordsData(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }
}