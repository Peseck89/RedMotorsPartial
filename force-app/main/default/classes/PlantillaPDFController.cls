public with sharing class PlantillaPDFController {
    public String plantillaHTML {get; set;}

    public PlantillaPDFController() {
        String recordId = Apexpages.currentPage().getParameters().get('recordId');
        getData(recordId);
    }

    private void getData(String recordId) {
        String plantillaId = Apexpages.currentPage().getParameters().get('id');

        List<Plantilla_Formalizacion__c> record = [SELECT Id,plantilla__c 
                                                   FROM Plantilla_Formalizacion__c
                                                   Where Id = :plantillaId
                                                   LIMIT 1];

        if (!record.isEmpty()) {
            OppFinanciamientoCtrl ctrl =  new OppFinanciamientoCtrl();
            plantillaHTML = ctrl.doMergeFields(recordId, record[0].plantilla__c);
                  //  .doMergeFields(recordId, record[0].plantilla__c);
            // plantillaHTML = record[0].plantilla__c;
            // plantillaHTML
        }
    }
}