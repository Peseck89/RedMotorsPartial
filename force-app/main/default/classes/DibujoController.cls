public with sharing class DibujoController {

    @AuraEnabled(cacheable=true)
    public static List<DibujoWrapper> getDibujosByCase(Id caseId) {
        List<DibujoWrapper> resultados = new List<DibujoWrapper>();
    
        for (DibujoVehiculo__c dibujo : [
            SELECT Id, CreatedDate, CreatedBy.Name,
                (SELECT ContentDocument.LatestPublishedVersionId 
                 FROM ContentDocumentLinks)
            FROM DibujoVehiculo__c
            WHERE Case__c = :caseId
            ORDER BY CreatedDate DESC
        ]) {
            String versionId = dibujo.ContentDocumentLinks.isEmpty() ? null :
                dibujo.ContentDocumentLinks[0].ContentDocument.LatestPublishedVersionId;
    
            resultados.add(new DibujoWrapper(
                dibujo.Id,
                dibujo.CreatedDate,
                versionId,
                dibujo.CreatedBy != null ? dibujo.CreatedBy.Name : null
            ));
        }
    
        return resultados;
    }
    
    public class DibujoWrapper {
        @AuraEnabled public Id dibujoId;
        @AuraEnabled public DateTime createdDate;
        @AuraEnabled public String versionId;
        @AuraEnabled public String creadoPor;
        public DibujoWrapper(Id dibujoId, DateTime createdDate, String versionId, String creadoPor) {
            this.dibujoId = dibujoId;
            this.createdDate = createdDate;
            this.versionId = versionId;
            this.creadoPor = creadoPor;
    	}
    }

}