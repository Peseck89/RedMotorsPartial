public with sharing class SignedWorkOrderPDFController {
    public String recordId { get; private set; }
    public String visualforceName { get; private set; }
    public Firma__c firma { get; private set; }
    public Boolean firmaEncontrada { get; private set; }
    public String firmaImagen { get; private set; }

    public SignedWorkOrderPDFController(ApexPages.StandardController controller) {
        this.recordId = controller.getId();
        this.visualforceName = 'CaseChecklistPDFBeta';
        loadFirma();
    }

    private void loadFirma() {
        Map<String, String> mapTipoVehiculoVisualforce = new Map<String, String>{
    	'Automóvil' => 'CaseChecklistPDFBeta',
    	'Motocicleta' => 'ChecklistMotosPDFBeta',
    	'Mula' => 'ChecklistMulaPDF',
    	'Cuadraciclo' => 'ChecklistCuadraPDF'
		};
         System.debug('recordId '+recordId);
        Case caso = [Select Id,Marca__c, AssetId, Asset.Tipo_de_veh_culo__c From Case Where Id =: recordId];
           System.debug('caso.Asset.Tipo_de_veh_culo__c '+caso.Asset.Tipo_de_veh_culo__c);
            if(caso.Asset.Tipo_de_veh_culo__c != null){
                visualforceName = mapTipoVehiculoVisualforce.get(caso.Asset.Tipo_de_veh_culo__c);
            }
        // Buscar el último registro de Firma__c relacionado con la WorkOrder y la Visualforce específica
        System.debug('visualforceName' +visualforceName);
        System.debug('recordId' +recordId);
        List<Firma__c> firmas = [
            SELECT Id, Nombre__c, (SELECT ContentDocumentId FROM ContentDocumentLinks LIMIT 1)
            FROM Firma__c
            WHERE Case__c = :recordId
            AND Visualforce__c = :visualforceName
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];

        if (!firmas.isEmpty()) {firma = firmas[0]; firmaEncontrada = true;
            // Obtener la imagen de la firma
            if (firma.ContentDocumentLinks.isEmpty()) { firmaImagen = null;
            } else { ContentVersion cv = [SELECT VersionData FROM ContentVersion WHERE ContentDocumentId = :firma.ContentDocumentLinks[0].ContentDocumentId ORDER BY CreatedDate DESC LIMIT 1]; firmaImagen = '/sfc/servlet.shepherd/version/download/' + cv.Id;
            }
        } else {
            firmaEncontrada = false;
        }
    }
}