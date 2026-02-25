public without sharing class WorkorderLineItemController {
    
    public String woId;
    public String pricebook2Id {get;set;}
    public string serviceTerritoryId {get;set;}
    public String productId {get;set;}
    public WorkOrderLineItem wli {get;set;}
    public List<ProductoXBodega__c> bodegaList {get;set;}
    public String selectedBodegaId {get; set;}
    
    public WorkorderLineItemController(ApexPages.StandardController controller) {
        woId = ApexPages.currentPage().getParameters().get('WorkOrder_lkid');
        pricebook2Id = [SELECT Pricebook2Id FROM Workorder WHERE Id =: woId].Pricebook2Id;
        
        
        wli = new WorkorderLineItem();
        wli.Impuesto__c = [SELECT Id FROM Impuesto__c WHERE Name = 'IVA-Tarifa General 13%'].Id;
        wli.especificacionesTaller__c = 'Recomendado';
        wli.WorkorderId = woId;
        wli.Trabajo__c = 'Materiales';
        tiposDeTrabajo__c tipoTrabajo = [SELECT Id,Name FROM tiposDeTrabajo__c WHERE Name = 'Mantenimiento' LIMIT 1];
        wli.tiposDeTrabajo__c = tipoTrabajo.id;
        bodegaList = new List<ProductoXBodega__c>();
    }
    
    @RemoteAction
    public static List<Product2> searchProducts(String productStr, String pricebook2Id)
    {
        List<Product2> productList = new List<Product2>();
        
        if(String.isNotBlank(productStr))
        {
            productStr = productStr + '%';
            
            Set<String> productIds = new Set<String>();
            Map<Id, Decimal> mapIdDecimal = new Map<Id, Decimal>();
            Map<Id, String> mapIdCurrency = new Map<Id, String>();
            List<PricebookEntry> pbeList = [SELECT Product2Id, UnitPrice, CurrencyIsoCode 
                                            FROM PricebookEntry
                                            WHERE (Product2.Name like : productStr
                                            OR Product2.ProductCode like : productStr
                                            OR Product2.Codigo_de_Producto__c like : productStr)
                                            AND Pricebook2Id =: pricebook2Id
                                            ORDER BY Name];
            
            for(PricebookEntry pbe : pbeList)
            {
                productIds.add(pbe.Product2Id);mapIdDecimal.put(pbe.Product2Id, pbe.UnitPrice); mapIdCurrency.put(pbe.Product2Id, pbe.CurrencyIsoCode);
            }
            productList = [SELECT id, Name, Description, Codigo_de_Producto__c 
                           FROM Product2 
                           WHERE Id in : productIds
                           ORDER BY Name];
            for(Product2 pd : productList)
            {
                pd.precio__c = mapIdDecimal.get(pd.Id).setScale(2); pd.Modelo_Altica__c	 = mapIdCurrency.get(pd.Id);
            }
        }
        
        return productList;
    }
    
    public String error {get;set;}
    public void saveWLI()
    {
        try
        {
            List<PriceBookEntry> pbeList = [SELECT Id 
                                            FROM PriceBookEntry
                                            WHERE Product2.Id =: productId
                                            AND Pricebook2Id =: pricebook2Id];
            
            if(pbeList.size() > 0) wli.PricebookEntryId = pbeList[0].Id;
            System.debug('Bodega a guardar: '+wli.Bodega__c);
            wli.Quantity = wli.Cantidad__c;
            insert wli;
            
            error = '';//return new PageReference('/'+woId).setRedirect(true);
        }
        catch(Exception ex){
            System.debug(ex.getMessage());
            error = 'Error: ' + ex.getMessage();
            apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR, error));
        }
    }
    
    //user us = [Select Id, name from user limit 1];
    // 	0Hh8H000000GmlDSAS
    
    
    public void getBodegas()
    {
      serviceTerritoryId = [SELECT ServiceTerritoryId FROM Workorder WHERE Id =: woId].ServiceTerritoryId;
        if(ServiceTerritoryId == '0Hh4U0000010wUCSAY' || ServiceTerritoryId == '0Hh4U0000010wVQSAY'){//ESCAZU-mecania rapida
            bodegaList = [SELECT id, Name, Producto__c, Producto__r.Name, Disponible__c, Bodega__c, Bodega__r.Name, Bodega__r.bodega__c 
                      FROM ProductoXBodega__c
                      WHERE Producto__c =: productId and Bodega__c = 'a2b4U000007SH7iQAG'];
        }else if(ServiceTerritoryId == '0Hh4U0000010wWcSAI' || ServiceTerritoryId == '0Hh4U0000010wVFSAY' || ServiceTerritoryId == '0Hh4U0000010wURSAY'){//URUCA-mecanica rapida
        bodegaList = [SELECT id, Name, Producto__c, Producto__r.Name, Disponible__c, Bodega__c, Bodega__r.Name, Bodega__r.bodega__c 
                      FROM ProductoXBodega__c
                      WHERE Producto__c =: productId and Bodega__c = 'a2b4U000007SH7hQAG'];
        }else if(ServiceTerritoryId == '0Hh4U0000010wU7SAI' || ServiceTerritoryId == '0Hh4U0000010wVLSAY' || ServiceTerritoryId == '0Hh4U0000010wVPSAY'){//pavas
            bodegaList = [SELECT id, Name, Producto__c, Producto__r.Name, Disponible__c, Bodega__c, Bodega__r.Name, Bodega__r.bodega__c 
                      FROM ProductoXBodega__c
                      WHERE Producto__c =: productId and (Bodega__c = 'a2b4U000007SH7vQAG' OR Bodega__c = 'a2b4U000007SP2hQAG')];
        }else if(ServiceTerritoryId == '0Hh4U0000010wUHSAY' || ServiceTerritoryId == '0Hh4U0000010wVKSAY'){//pinares
            bodegaList = [SELECT id, Name, Producto__c, Producto__r.Name, Disponible__c, Bodega__c, Bodega__r.Name, Bodega__r.bodega__c 
                      FROM ProductoXBodega__c
                      WHERE Producto__c =: productId and Bodega__c = 'a2b4U000007SH7jQAG'];
        }
   
    }
    
    public void setWliBodega()
    {
        System.debug('Bodega: '+selectedBodegaId);
        wli.Bodega__c = selectedBodegaId;
    }
    
}