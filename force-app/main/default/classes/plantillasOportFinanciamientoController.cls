public class plantillasOportFinanciamientoController {

    public List<PlantillasWrapper> getData{ get; set; }
    public boolean getSelectAll{ get; set; }

    Apexpages.StandardController mainController;

    public plantillasOportFinanciamientoController(Apexpages.StandardController controller) {
        mainController = controller;
        Id recordId = (Id)controller.getId();
        getSelectAll = false;
        getDataPlantillas(recordId);
    }

    private void getDataPlantillas(Id recordId) {
        List<Plantilla_Formalizacion__c>  recordsList = getRawData(recordId);

        if (!recordsList.isEmpty()) {
            wrapData(recordsList);
        }
    }

    private List<Plantilla_Formalizacion__c> getRawData(Id recordId) {
        Map<Id, Oportunidad_de_Financiamiento__c> opFinanRecord = new Map<Id, Oportunidad_de_Financiamiento__c>(
            [Select Id, Categoria__c, Subcategoria__c, TipoProducto__c,Tipo_Cargo__c
                FROM Oportunidad_de_Financiamiento__c
                WHERE  Id = :recordId
                LIMIT 1]
        );

        Map<Id, Maestro_Plantillas__c> maestroPlantillaRecord = new Map<Id, Maestro_Plantillas__c>(
            [Select Id, (Select Id, Name, Nombre_de_Plantilla__c FROM Plantillas_Formalizaci_n__r order by Name)
                FROM Maestro_Plantillas__c
                WHERE Categoria__c = :opFinanRecord.values().Categoria__c
                AND Sub_Categoria__c = :opFinanRecord.values().Subcategoria__c
                AND Producto__c = :opFinanRecord.values().TipoProducto__c
                //AND Tipo_Cargo__c =:opFinanRecord.values().Tipo_Cargo__c
                LIMIT 1]
        );

        List<Plantilla_Formalizacion__c>  recordsList = new List<Plantilla_Formalizacion__c>();
        if (!maestroPlantillaRecord.isEmpty()) {
            for (Maestro_Plantillas__c maestroRecord : maestroPlantillaRecord.values()) {
                if (maestroRecord.Plantillas_Formalizaci_n__r != null) {
                   // if(opFinanRecord.values().Tipo_Cargo__c == '')
                    recordsList.addAll(maestroRecord.Plantillas_Formalizaci_n__r);
                }
            }
        } 

        return recordsList;
    }

    private void wrapData(List<Plantilla_Formalizacion__c> records) {
        getData = new List<PlantillasWrapper>();

        for (Plantilla_Formalizacion__c plantilla : records) {
            getData.add(new PlantillasWrapper(false, plantilla));
        }
    }

    public Pagereference generatePDF() {
        List<String> selectedIds = getSelectedIds();

        Pagereference resultRef = Page.PlantillasTabsContainerVF;
        resultRef.getParameters().put('recordId', (Id)mainController.getId());
        resultRef.getParameters().put('ids', String.join(selectedIds, ','));
        resultRef.setRedirect(true);

        return resultRef;
    }

    public Pagereference downloadPDFs() {
        List<String> selectedIds = getSelectedIds();
        List<Attachment> newAttachments = new List<Attachment>();
        Id parentId = (Id)mainController.getId();

        Map<Id, Plantilla_Formalizacion__c> dataMap = new Map<Id, Plantilla_Formalizacion__c>(
            getRawData(parentId)
        );

        for (String plantillaId : selectedIds) {
            Id currentPlantillaId = Id.valueOf(plantillaId);

            if (dataMap.containsKey(currentPlantillaId)) {
                Pagereference currentPage = Page.PlantillaPDFVF;
                currentPage.getParameters().put('id', plantillaId);
                currentPage.getParameters().put('recordId', parentId);

                blob bo = blob.valueOf('');
                if(Test.isRunningTest()) {
                    bo = blob.valueOf('Unit.Test');
                }else{
                    bo = currentPage.getContentAsPDF() ;
                }
                newAttachments.add( 
                    new Attachment (
                        parentId = parentId,
                        Name = dataMap.get(currentPlantillaId).Nombre_de_Plantilla__c+'.pdf',
                        Body = bo                  
                    )
                );
            }
        }

        if (!newAttachments.isEmpty()) {
            try {
                insert newAttachments;
                Apexpages.addMessage(
                    new Apexpages.Message(
                        ApexPages.severity.INFO,
                        'Plantillas agregadas con exito'
                    )
                );
            } catch(DmlException ex) {
                Apexpages.addMessage(
                    new Apexpages.Message(
                        ApexPages.severity.ERROR,
                        ex.getMessage()
                    )
                );
            }
        }

        return null;
    }

    private List<String> getSelectedIds() {
        List<String> selectedIds = new List<String>();

        for (PlantillasWrapper plantillaWrapper : getData) {
            if (plantillaWrapper.isSelected) {
                selectedIds.add(plantillaWrapper.plantilla.Id);
            }
        }

        return selectedIds;
    }

    public class PlantillasWrapper {
        public Boolean isSelected {get; set;}
        public Plantilla_Formalizacion__c plantilla {get; private set;}

        public PlantillasWrapper(Boolean isSelected, Plantilla_Formalizacion__c plantilla) {
            this.isSelected = isSelected;
            this.plantilla = plantilla;
        }
    }
    
    public Pagereference SelectAll(){
        if(getSelectAll)
            getSelectAll = false;
        else
            getSelectAll = true;
        
         for (PlantillasWrapper plantillaWrapper : getData) {
            plantillaWrapper.isSelected = getSelectAll;
        }
        	return null;
    }
}