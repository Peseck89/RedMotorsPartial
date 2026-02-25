public with sharing class CaseFilesController {
    @AuraEnabled(cacheable=true)
    public static List<ContentDocumentLink> getRelatedFiles(Id caseId) {
        return [
            SELECT ContentDocumentId, ContentDocument.Title, ContentDocument.FileType, ContentDocument.LatestPublishedVersionId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :caseId
        ];
    }
}