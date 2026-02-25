public without sharing class RM_VU_Quote_Ctrl {
    public static final String PRICEBOOK_NAME = RM_VU_Service.PRICEBOOK_NAME;
    
    @AuraEnabled
    public static List<Quote> getQuotes(String oppId){
        List<Quote> quoteList = [SELECT Id, Name FROM Quote WHERE OpportunityId =:oppId WITH SECURITY_ENFORCED];
        return quoteList;        
    }

    @AuraEnabled
    public static Map<String,Object> addVehicle(String oppId,String prodXBodegaId,String existingQuoteId){
        Map<String,Object> responseMap = new Map<String,Object>();
        
        if (String.isBlank(oppId)) {
            throw new AuraHandledException('La oportunidad es requerida.');
        }

        if (String.isBlank(prodXBodegaId)) {
            throw new AuraHandledException('El registro de producto por bodega es requerido.');
        }

        List<Opportunity> oppList = [SELECT Id,CurrencyIsoCode, Pricebook2Id,Pricebook2.Name,
                                         (SELECT Id FROM OpportunityLineItems) 
                                         FROM Opportunity 
                                         WHERE Id = :oppId];

        if (oppList.isEmpty()) {
            throw new AuraHandledException('La oportunidad no fue encontrada.');
        } 
        
        if (oppList[0].Pricebook2Id == null) {
            throw new AuraHandledException('La lista de precios en la oportunidad esta vacia.');
        }

        if (oppList[0].CurrencyIsoCode == null) {
            throw new AuraHandledException('El código de la moneda en la oportunidad esta vacio.');
        }   

        List<ProductoXBodega__c> prodXBodList = [SELECT Id,Producto__c,Bodega__c,Disponible__c,Producto__r.Name,Producto__r.vin__c,Producto__r.Marca__c,Producto__r.Modelo_De_Inter_s__c,Producto__r.modelo__c,Producto__r.Anno__c
                                                 FROM ProductoXBodega__c 
                                                 WHERE Id =:prodXBodegaId 
                                                ];
        if (prodXBodList.isEmpty()) {
            throw new AuraHandledException('El registro del producto por bodega no fue encontrado.');
        }   
        
        if (prodXBodList[0].Disponible__c == null || prodXBodList[0].Disponible__c <= 0) {
            throw new AuraHandledException('El vehiculo no cuenta con disponibilidad en inventario.');
        }   
        
        List<Product2> productList = [SELECT Id,
                                        (
                                            SELECT Id, UnitPrice, Gerente__c, Jefe__c, Vendedor__c, Costo_Fijo__c
                                            FROM PricebookEntries
                                            WHERE IsActive = true AND Pricebook2.IsActive = true AND Pricebook2Id = :oppList[0].Pricebook2Id AND CurrencyIsoCode = :oppList[0].CurrencyIsoCode
                                            ORDER BY UnitPrice DESC
                                            LIMIT 1 
                                        )
                                    FROM Product2
                                    WHERE Id = :prodXBodList[0].Producto__c
                                    ];
        if (productList.isEmpty()) {              
            throw new AuraHandledException('El vehiculo no fue encontrado.');         
        } 

        Product2 product = productList[0];
        
        if (product.PricebookEntries.isEmpty()) {
            throw new AuraHandledException('El vehiculo no cuenta con precio configurado para la lista ('+oppList[0].Pricebook2.Name+').');          
        }

        PricebookEntry vehiclePBE = product.PricebookEntries[0];
        try {        

            if (oppList[0].OpportunityLineItems.size() > 0) {
                delete oppList[0].OpportunityLineItems;
            }

            if (String.isBlank(existingQuoteId)) {
                Quote newQuote = new Quote(                           
                    Name = 'Quote Name',
                    OpportunityId = oppId,
                    Pricebook2Id = oppList[0].Pricebook2Id,
                    CurrencyIsoCode = oppList[0].CurrencyIsoCode
                );
                insert newQuote;
                existingQuoteId = newQuote.Id;
                            
                responseMap.put('quoteId', newQuote.Id);
            }else{
                responseMap.put('quoteId', existingQuoteId);
            }

            QuoteLineItem newQLI = new QuoteLineItem(
                QuoteId = existingQuoteId,
                // Product2Id = prodXBodList[0].Producto__c,
                Quantity = 1,
                BMW_Bodega__c = prodXBodList[0].Bodega__c,
                PricebookEntryId = vehiclePBE.Id,                
                UnitPrice = vehiclePBE.UnitPrice,
                ListPrice__c = vehiclePBE.UnitPrice//,
                // Comision_Vendedor_Porcentaje__c = comisionVendedorPorcentaje,
                // Comision_Jefe_Porcentaje__c = comisionJefePorcentaje,
                // Comision_Gerente_Porcentaje__c = comisionGerentePorcentaje
            );
            
            insert newQLI;  

        } catch(Exception e) {
            System.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }         

        return responseMap;        
    }
}