public class QliGridQueryService {
    private String quoteId;
    private String pricebook;
    private String serviceTerritory;
    
    public QliGridQueryService(String quoteId){
        this.quoteId = quoteId;
        init();
    }

    public QliGridQueryService(String quoteId, Boolean isQuote){
        this.quoteId = quoteId;
        init();
    }

    private void init(){
        this.pricebook = getPricebook();
        this.serviceTerritory = getTerritorry();
    }
    

    public List<QuoteLineItem> getQuolis(){
        return [SELECT Id, Product2Id, Tarea__c, Tarea__r.Name, Categor_a_de_presupuesto__c,DefaultMostrador__c,
                       Product2.Codigo_de_Producto__c, Product2.Name, Product2.CostoLocal__c,
                       Product2.TipoProducto__c, BMW_Bodega__r.Name, Quantity, UnitPrice,
                       Discount, PricebookEntryId, PricebookEntry.UnitPrice, PricebookEntry.CurrencyIsoCode,
                       BMW_Alias__c, BMW_Bodega__c, BMW_Bodega__r.Bodega__c, ProductoPorBodega__c,
                       ProductoPorBodega__r.Disponible__c,Estado_aprobaci_n_service__c,
                       Estado_reserva__c, Estado_entrega__c, Estado_softland__c, Cantidad_devolucion__c,
                       Estado_solicitud_compra__c, Identificador_solicitud_de_compra__c, CantidadSC__c,
                 	   TipoCargo__c, Aprobador__c,TrabajoARealizar__c,TrabajoARealizar__r.Name,
					   SubTrabajoARealizar__c, SubTrabajoARealizar__r.Name
                FROM QuoteLineItem
                WHERE QuoteId = :this.quoteId
                ORDER BY Tarea__r.Name NULLS LAST, Product2.TipoProducto__c NULLS LAST];
    }
    
    private List<Id> getBodegas(){
        System.debug('this.serviceTerritory '+this.serviceTerritory);
        List<BodegaxTerritorio__c> bodegas=[SELECT Bodega__c from BodegaxTerritorio__c where ServiceTerritory__c =: this.serviceTerritory order by isPrincipal__c desc];
        List<Id> bodegaIDs =new List<Id>();
        for(BodegaxTerritorio__c bxt:bodegas){
            bodegaIDs.add(bxt.Bodega__c);
        }
        return bodegaIDs;
    }
    
    /*public Map<Id, Product2> searchProductsByName(String queryValue){
        String keyValueString = '%' +  queryValue + '%';
        String key = (queryValue == null) ? '' : queryValue.trim();
        String como = '%' + key + '%';
        List<Id> bodegas= getBodegas();
        String bodega1;
        String bodega2;*/
        /*return new Map<Id, Product2> ([SELECT Id, Codigo_de_Producto__c , Name, costoLocal__c, tipoProducto__c,
                                     	(SELECT Id, Bodega__r.Name, Bodega__c, Disponible__c, Bodega__r.bodega__c from Productos_por_Bodega__r WHERE Bodega__c =: bodegas Order by CreatedDate),
                                        (SELECT Id, UnitPrice, CurrencyIsoCode from PricebookEntries WHERE Pricebook2Id =: this.pricebook )
                                      	 FROM Product2 
                                         WHERE (Name LIKE:keyValueString or Codigo_de_Producto__c LIKE :keyValueString)
                                       	 AND (Id IN (SELECT Producto__c FROM ProductoXBodega__c WHERE Bodega__c =: bodegas))
                                         AND IsActive = true
                                         order by Name
                                         limit 100]);*/
      /*      List<Product2> rows = [
            SELECT Id, Codigo_de_Producto__c, Name, CostoLocal__c, TipoProducto__c,
                   (SELECT Id, Bodega__r.Name, Bodega__c, Disponible__c, Bodega__r.Bodega__c
                    FROM Productos_por_Bodega__r
                    WHERE Bodega__c = :bodegas
                    ORDER BY CreatedDate),
                   (SELECT Id, UnitPrice, CurrencyIsoCode
                    FROM PricebookEntries
                    WHERE Pricebook2Id = :this.pricebook)
            FROM Product2
            WHERE (Name LIKE :como OR Codigo_de_Producto__c LIKE :como)
              AND IsActive = true
              AND Id IN (SELECT Producto__c FROM ProductoXBodega__c WHERE Bodega__c = :bodegas)
            ORDER BY Name
            LIMIT 100
        ];
    
        if (key != '') {
            Integer hitIdx = -1;
            for (Integer i = 0; i < rows.size(); i++) { String code = rows[i].Codigo_de_Producto__c; if (code != null && code.equalsIgnoreCase(key)) { hitIdx = i; break; }
            }
            if (hitIdx > 0) { Product2 hit = rows.remove(hitIdx); rows.add(0, hit);
            }
        }
    
        return new Map<Id, Product2>(rows);
    }*/
    public Map<Id, Product2> searchProductsByName(String queryValue){
        String key = (queryValue == null) ? '' : queryValue.trim();
        String likeKey = '%' + key + '%';
        List<Id> bodegas = getBodegas();
    
        // 1) Productos que sí existen en la(s) bodega(s)
        Set<Id> productIds = new Set<Id>();
        for (ProductoXBodega__c pxb : [
            SELECT Producto__c
            FROM ProductoXBodega__c
            WHERE Bodega__c IN :bodegas AND Producto__r.tipoProducto__c =: 'Materiales' AND Producto__r.IsActive =: true
            AND (Producto__r.Name LIKE :likeKey OR Producto__r.Codigo_de_Producto__c LIKE :likeKey) limit 1000
        ]) {
            if (pxb.Producto__c != null) productIds.add(pxb.Producto__c);
        }
    
        // 2) Consulta principal: aceptar también Mano de Obra aunque no esté en bodega
        List<Product2> rows = [
            SELECT Id, Codigo_de_Producto__c, Name, CostoLocal__c, TipoProducto__c,
                   (SELECT Id, Bodega__r.Name, Bodega__c, Disponible__c, Bodega__r.Bodega__c
                    FROM Productos_por_Bodega__r
                    WHERE Bodega__c IN :bodegas
                    ORDER BY CreatedDate),
                   (SELECT Id, UnitPrice, CurrencyIsoCode
                    FROM PricebookEntries
                    WHERE Pricebook2Id = :this.pricebook)
            FROM Product2
            WHERE IsActive = true
              AND (Name LIKE :likeKey OR Codigo_de_Producto__c LIKE :likeKey)
              AND (Id IN :productIds OR TipoProducto__c = 'Mano de Obra')
            ORDER BY Name
            LIMIT 100
        ];
    
        // 3) Si el usuario tecleó el código exacto lo coloca al inicio
        if (key != '') {
            Integer hitIdx = -1;
            for (Integer i = 0; i < rows.size(); i++) {
                String code = rows[i].Codigo_de_Producto__c; if (code != null && code.equalsIgnoreCase(key)) { hitIdx = i; break; }
            }
            if (hitIdx > 0) { Product2 hit = rows.remove(hitIdx); rows.add(0, hit);
            }
        }
    
        return new Map<Id, Product2>(rows);
    }



    private Id getPricebook(){
        return this.quoteId == null ? null : [select Opportunity.Pricebook2Id FROM Quote where id =: this.quoteId].Opportunity.Pricebook2Id;
    }

    private Id getTerritorry(){
        System.debug('quoteId '+quoteId);
        return this.quoteId == null ? null : [select Opportunity.BMW_TallerDeServicio__c FROM Quote where id =: this.quoteId].Opportunity.BMW_TallerDeServicio__c;
    }

    public Id getPrincipal(){ return [SELECT Bodega__c from BodegaxTerritorio__c where isPrincipal__c = true AND ServiceTerritory__c =:this.serviceTerritory].Bodega__c;
    }
    public List<Id> getPrincipals(){
        List<BodegaxTerritorio__c> bodegaRel = [
            SELECT Bodega__c 
            FROM BodegaxTerritorio__c 
            WHERE (isPrincipal__c = true OR PrimarioMultiple__c = true)
              AND ServiceTerritory__c = :this.serviceTerritory
        ];
        List<Id> ids = new List<Id>();
        for (BodegaxTerritorio__c b : bodegaRel) {
            ids.add(b.Bodega__c);
        }
        return ids;
    }
    public List<ContentVersion> getContentVersions(List<String> contentIds){
        return [select id from contentversion where contentdocumentid =:contentIds];
    }

    public String getFileUrl(String contentId){
        return [SELECT DistributionPublicUrl FROM ContentDistribution WHERE contentdocumentid =: contentId].DistributionPublicUrl;
    }

    private List<String> getFileUrls(List<String> contentIds){  List<String> urls = new List<String> ();List<ContentDistribution> contentDistributions = [SELECT DistributionPublicUrl FROM ContentDistribution WHERE contentdocumentid =: contentIds and  name = 'noenviado'];for(ContentDistribution cd:contentDistributions){ urls.add(cd.DistributionPublicUrl);
        }
        return urls;
    }

    public List<String> getFileUrlsFromQuote(){
        List<ContentDocumentLink> ctlinks = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink where LinkedEntityId =: this.quoteId]; List<String> contentDocumentIds = new  List<String>();for(ContentDocumentLink ctl: ctlinks){ contentDocumentIds.add(ctl.ContentDocumentId);
        }
        return getFileUrls(contentDocumentIds);
    }

    public void updateDocsAsSend(){
        List<ContentDocumentLink> ctlinks = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink where LinkedEntityId =: this.quoteId]; List<String> contentDocumentIds = new  List<String>();for(ContentDocumentLink ctl: ctlinks){ contentDocumentIds.add(ctl.ContentDocumentId);
        }
        List<ContentDistribution> contentDistributions = [SELECT DistributionPublicUrl FROM ContentDistribution WHERE contentdocumentid =: contentDocumentIds];for(ContentDistribution cd:contentDistributions){ cd.name = 'enviado';
        }
        update contentDistributions;
        
    }

    

    public Map<Id, Product2> getBodegasOnly(Set<String> products){
        List<Id> bodegas= getBodegas();
        String producto1;
        String product2;
        String bodega1;
        String bodega2;
         String bodega3;
        String bodega4;
        
        String paroduct2;
        String boadega1;
        String bodaega2;
         String bodaega3;
        String bodegaa4;
        return new Map<Id, Product2> ([SELECT Id, (SELECT Id, Bodega__r.Name, Bodega__c, Disponible__c, Bodega__r.bodega__c from Productos_por_Bodega__r WHERE Bodega__c =: bodegas Order by CreatedDate)
                                       FROM Product2 WHERE ID =: products]);
    }


}