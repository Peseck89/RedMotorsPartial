public with sharing class PlantillasTabsContainerVFController {
    
    public List<TabWrapper> data {get; set;}
    
    public PlantillasTabsContainerVFController() {
        wrapData();
    }

    private Pagereference wrapData() {
        data = new List<TabWrapper>();
        List<String> selectedIds = 
            Apexpages.currentPage().getParameters().get('ids').split(',');
        
        String opFinanciamientoId = Apexpages.currentPage().getParameters().get('recordId');

        System.debug('selectedIds:: ' + selectedIds);

        for (Plantilla_Formalizacion__c plantilla : [SELECT Id, Nombre_de_Plantilla__c, plantilla__c 
                                                    FROM Plantilla_Formalizacion__c
                                                    Where Id IN :selectedIds])
        {
            data.add(
                new TabWrapper(
                    plantilla.Nombre_de_Plantilla__c, 
                    plantilla.Id,
                    opFinanciamientoId
                )
            );
        }

        return null;
    }
}