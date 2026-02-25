public class BusquedaDetalladaService {
     private String workOrderId;
    private String quoteId;
    private String pricebook;
    private String serviceTerritory;
    
    public BusquedaDetalladaService(String workOrderId){
        this.workOrderId = workOrderId;
        //init();
    }

    public BusquedaDetalladaService(String quoteId, Boolean isQuote){
        this.quoteId = quoteId;
        //init();
    }

    private void init(){
        //this.pricebook = getPricebook();
        //this.serviceTerritory = getTerritorry();
    }
    public Id getPrincipal(Id serviceTerritoryId){
        return [SELECT Bodega__c from BodegaxTerritorio__c where isPrincipal__c = true AND ServiceTerritory__c =: serviceTerritoryId].Bodega__c;
    }
    public Map<Id, Product2> searchProductsByName(String queryValue,Id priceBookId, Id serviceTerritoryId){
        String keyValueString = '%' +  queryValue + '%';
        System.debug('keyValueString '+keyValueString);
                System.debug('priceBookId '+priceBookId);
                System.debug('serviceTerritoryId '+serviceTerritoryId);
		String key = (queryValue == null) ? '' : queryValue.trim();
        String como = '%' + key + '%';
        List<Id> bodegas= getBodegas(serviceTerritoryId);
                        System.debug('bodegas '+bodegas);

         /*return new Map<Id, Product2> ([SELECT Id, Codigo_de_Producto__c , Name, costoLocal__c, tipoProducto__c,
                                     	(SELECT Id, Bodega__r.Name, Bodega__c, Disponible__c, Bodega__r.bodega__c from Productos_por_Bodega__r WHERE Bodega__c =: bodegas Order by CreatedDate),
                                        (SELECT Id, UnitPrice, CurrencyIsoCode from PricebookEntries WHERE Pricebook2Id =: priceBookId )
                                      	 FROM Product2 
                                         WHERE (Name LIKE:keyValueString or Codigo_de_Producto__c LIKE :keyValueString)
                                       	 AND (Id IN (SELECT Producto__c FROM ProductoXBodega__c WHERE Bodega__c =: bodegas))
                                         AND IsActive = true
                                         order by Name
                                         limit 100]);*/
            List<Product2> rows = [
            SELECT Id, Codigo_de_Producto__c, Name, CostoLocal__c, TipoProducto__c,
                   (SELECT Id, Bodega__r.Name,Bodega__r.Alias__c, Bodega__c, Disponible__c, Bodega__r.Bodega__c
                    FROM Productos_por_Bodega__r
                    WHERE Bodega__c = :bodegas
                    ORDER BY CreatedDate),
                   (SELECT Id, UnitPrice, CurrencyIsoCode
                    FROM PricebookEntries
                    WHERE Pricebook2Id = :priceBookId)
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
    }
	private List<Id> getBodegas(Id serviceTerritoryId){
        List<BodegaxTerritorio__c> bodegas=[SELECT Bodega__c from BodegaxTerritorio__c where ServiceTerritory__c =: serviceTerritoryId order by isPrincipal__c desc];
        List<Id> bodegaIDs =new List<Id>();
        for(BodegaxTerritorio__c bxt:bodegas){
            bodegaIDs.add(bxt.Bodega__c);
        }
        return bodegaIDs;
    }

}