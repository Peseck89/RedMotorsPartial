public class PlanDeNegocioPDFGenerator {
    @InvocableMethod
    public static List<ContentVersion> generatePDFPlanDeNegocio(List<Id> opportunityIds) {
        List<ContentVersion> contentVersions = new List<ContentVersion>();
        Opportunity opp = [Select Id,name,BMW_PlacaDeVehiculoOElVIN__c,RecordTypeName__c from Opportunity Where Id=: opportunityIds[0]];
        for (Id oppId : opportunityIds) {
            PageReference pageRef = new PageReference('/');
            if(opp.RecordTypeName__c == 'Autos usados' || opp.RecordTypeName__c == 'Motos usados'){
                pageRef = Page.cT_newPlanNegocioUsado;
            }
            else{
                pageRef = Page.cT_newPlanNegocio;
            }
            pageRef.getParameters().put('id', oppId);
            Blob pdfBlob;
            if (Test.isRunningTest()) {
                pdfBlob = Blob.valueOf('Test PDF Content');
            } else {
                pdfBlob = pageRef.getContentAsPDF();
            }
            ContentVersion contentVersion = new ContentVersion();
            contentVersion.VersionData = pdfBlob;
            contentVersion.Title = 'Plan de Negocio';
            contentVersion.PathOnClient = 'Plan_de_Negocio.pdf';
            contentVersion.FirstPublishLocationId = opp.BMW_PlacaDeVehiculoOElVIN__c;
            contentVersions.add(contentVersion);
        }
        insert contentVersions;
        return contentVersions;
    }
}