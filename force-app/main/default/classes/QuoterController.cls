/**
 * @description       : 
 * @author            : marcohernandezhp@gmail.com
 * @group             : 
 * @last modified on  : 03-28-2023
 * @last modified by  : marcohernandezhp@gmail.com
**/
public without sharing class QuoterController {

    private static final Map<String, String> USD_PRICEBOOK_BY_COMPANY = new Map<String, String>{
        'RMBAVARIAN' => 'Bavarian Dólar',
        'RMOTOBAI' => 'Otobai Dólares',
        'RMPEKING' => 'PEKING Dólares'
    };
    
    @AuraEnabled
    public static Map<String,Object> createQuote(String oppProdInteresId,String prodXBodegaId,Boolean flagNewQuote,String quoteId){
        
        Map<String,Object> responseMap = new Map<String,Object>();
        
        List<ProductoXBodega__c> prodXBodList = [SELECT Id,Producto__c,Bodega__c,Disponible__c,Producto__r.Name,Producto__r.vin__c,Producto__r.Marca__c,Producto__r.Modelo_De_Inter_s__c FROM ProductoXBodega__c WHERE Id =:prodXBodegaId LIMIT 1];
        if (prodXBodList.isEmpty()) {
            throw new AuraHandledException('No se encontro el producto');
        }

        List<Oportunidad_Producto_Interes__c> opiList = [
            SELECT Id, Producto__c, Marca__c, Modelo_Interes__c, Familia__c,
                   Precio_Unitario__c, Oportunidad__c,
                   Oportunidad__r.Pricebook2Id,
                   Oportunidad__r.Empresa_Operadora__c,
                   Oportunidad__r.BMW_Compania__c,
                   Costo_Fijo__c, Comision_Porcentaje_Vendedor__c,
                   Comision_Porcentaje_Jefe__c, Comision_Porcentaje_Gerente__c
            FROM Oportunidad_Producto_Interes__c
            WHERE Id = :oppProdInteresId
            LIMIT 1
        ];
        if (opiList.isEmpty() || opiList[0].Oportunidad__c == null) {
            throw new AuraHandledException('No se encontro la oportunidad relacionada.');
        }

        String companyCode = resolveCompanyCode(
            opiList[0].Oportunidad__r.Empresa_Operadora__c,
            opiList[0].Oportunidad__r.BMW_Compania__c
        );
        Pricebook2 expectedPricebook = getActivePricebook(companyCode);
        List<PricebookEntry> pricebookEntryList = [
            SELECT Id, UnitPrice, CurrencyIsoCode, Pricebook2Id,
                   Pricebook2.CurrencyIsoCode
            FROM PricebookEntry
            WHERE IsActive = true
            AND Pricebook2Id = :expectedPricebook.Id
            AND Product2Id = :prodXBodList[0].Producto__c
        ];
        if (pricebookEntryList.size() != 1) {
            throw new AuraHandledException(
                pricebookEntryList.isEmpty()
                    ? 'No se encontro el precio relacionado al producto en ' + expectedPricebook.Name + '.'
                    : 'Se encontro mas de un precio relacionado al producto en ' + expectedPricebook.Name + '.'
            );
        }

        try {
            //REVISAR PRICEBOOK DE LA OPORTUNIDAD
            if (opiList.size() > 0) {
                if(opiList[0].Oportunidad__c != null && opiList[0].Oportunidad__r.Pricebook2Id != null && opiList[0].Oportunidad__r.Pricebook2Id != pricebookEntryList[0].Pricebook2Id){
                    List<Opportunity> oppToUpdate = [SELECT Id,Pricebook2Id,(SELECT Id FROM OpportunityLineItems) FROM Opportunity WHERE Id =:opiList[0].Oportunidad__c];
                    if (oppToUpdate.size() > 0) {
                        delete oppToUpdate[0].OpportunityLineItems;
                    }

                    //setting the dolar local pricebook
                    oppToUpdate[0].Pricebook2Id = pricebookEntryList[0].Pricebook2Id;
                    update oppToUpdate[0];
                }
            }

            List<Quote> quoteList = [SELECT Id FROM Quote WHERE OpportunityId = :opiList[0].Oportunidad__c LIMIT 1];

            if (quoteList.isEmpty() || !flagNewQuote) {
                Quote newQuote = new Quote(       
                    Name = prodXBodList[0].Producto__r.Name,
                    OpportunityId = opiList[0].Oportunidad__c,
                    Pricebook2Id = pricebookEntryList[0].Pricebook2Id,
                    CurrencyIsoCode = pricebookEntryList[0].Pricebook2.CurrencyIsoCode
                );
                insert newQuote;
                quoteId = newQuote.Id;
            }
            
            QuoteLineItem newQLI = new QuoteLineItem(
                QuoteId = quoteId,
                Product2Id = prodXBodList[0].Producto__c,
                Quantity = 1,
                BMW_Bodega__c = prodXBodList[0].Bodega__c,
                PricebookEntryId = pricebookEntryList[0].Id,                
                UnitPrice = opiList[0].Precio_Unitario__c,
                Oportunidad_Producto_Interes__c = opiList[0].Id,
                // Costo_Fijo_Inicial__c = opiList[0].Costo_Fijo__c,
                Comision_Vendedor__c = ((opiList[0].Comision_Porcentaje_Vendedor__c != null && opiList[0].Precio_Unitario__c != null) ? ((opiList[0].Comision_Porcentaje_Vendedor__c * opiList[0].Precio_Unitario__c)/100) : 0),
                Comision_Jefe__c = ((opiList[0].Comision_Porcentaje_Jefe__c != null && opiList[0].Precio_Unitario__c != null) ? ((opiList[0].Comision_Porcentaje_Jefe__c * opiList[0].Precio_Unitario__c)/100) : 0),
                Comision_Gerente__c = ((opiList[0].Comision_Porcentaje_Gerente__c != null && opiList[0].Precio_Unitario__c != null) ? ((opiList[0].Comision_Porcentaje_Gerente__c * opiList[0].Precio_Unitario__c)/100) : 0)
            );            
            insert newQLI;

        } catch (DmlException e) {
            throw new AuraHandledException(e.getMessage());
        }
        return responseMap;
    }
    

    @AuraEnabled
    public static Map<String,Object> addLineItem(String quoteId,String prodXBodId,String qliId,Boolean esRegalia,Boolean esExtra,String productType,String productAlias,Decimal productQuantity,Decimal productUnitPrice){
        Map<String,Object> responseMap = new Map<String,Object>();

        if (productType == 'mano obra' && (productQuantity == null || productQuantity <=0)) {
            throw new AuraHandledException('La cantidad tiene que ser mayor a 0.');
        }

        if (productType == 'mano obra' && (productUnitPrice == null || productUnitPrice <=0)) {
            throw new AuraHandledException('El precio tiene que ser mayor a 0.');
        } 
        
        // if (productType == 'mano obra' && String.isBlank(productAlias)) {
        //     if(!Test.isRunningTest()){
        //         throw new AuraHandledException('Para los items mano de obra debe especificar el alias.');
        //     }
        // }        

        String productId;
        String bodegaId;
        // Decimal unitPrice = 0;
        // Decimal quantity = 0;
        // System.debug('@ @'+productType);
        if (productType == 'mano obra') {
            productId = prodXBodId;
        }else {
            List<ProductoXBodega__c> prodXBodList = [SELECT Id,Producto__c,Bodega__c,Disponible__c,Producto__r.vin__c,Producto__r.Marca__c,Producto__r.Modelo_De_Inter_s__c FROM ProductoXBodega__c WHERE Id =:prodXBodId LIMIT 1];
            if (prodXBodList.isEmpty()) {
                throw new AuraHandledException('No se encontro el producto');
            }else{
                productId = prodXBodList[0].Producto__c;
                bodegaId = prodXBodList[0].Bodega__c;
            }
            // System.debug('@prodXBodList@'+prodXBodList);
        }

        List<Quote> quoteList = [
            SELECT Id, Pricebook2Id, Opportunity.Empresa_Operadora__c,
                   Opportunity.BMW_Compania__c
            FROM Quote
            WHERE Id = :quoteId
            LIMIT 1
        ];
        if (quoteList.isEmpty()) {
            throw new AuraHandledException('No se encontro la cotizacion.');
        }

        String companyCode = resolveCompanyCode(
            quoteList[0].Opportunity.Empresa_Operadora__c,
            quoteList[0].Opportunity.BMW_Compania__c
        );
        Pricebook2 expectedPricebook = getActivePricebook(companyCode);
        if (quoteList[0].Pricebook2Id != expectedPricebook.Id) {
            throw new AuraHandledException('El Pricebook de la cotizacion no corresponde a la empresa configurada.');
        }

        List<PricebookEntry> pricebookEntryList = [
            SELECT Id, UnitPrice, Product2.Name, CurrencyIsoCode, Pricebook2Id,
                   Pricebook2.CurrencyIsoCode, Costo_Fijo__c
            FROM PricebookEntry
            WHERE IsActive = true
            AND Pricebook2Id = :quoteList[0].Pricebook2Id
            AND Product2Id = :productId
        ];
        if (pricebookEntryList.size() != 1) {
            throw new AuraHandledException(
                pricebookEntryList.isEmpty()
                    ? 'No se encontro el precio relacionado al producto.'
                    : 'Se encontro mas de un precio relacionado al producto.'
            );
        }else{
            if (productType == 'extra') {
                productUnitPrice = esRegalia ? pricebookEntryList[0].Costo_Fijo__c : pricebookEntryList[0].UnitPrice;
            }
            // else if (productType == 'mano obra') {
            //     productAlias = productAlias == null ? pricebookEntryList[0].Product2.Name : productAlias;
            // }
        }
        
        productQuantity = productQuantity == null ? 1 : productQuantity;  
        
        Decimal total = productQuantity * productUnitPrice;

        try {  
            QuoteLineItem newQLI = new QuoteLineItem(
                QuoteId = quoteId,
                Product2Id = productId,
                BMW_Alias__c = productAlias,
                Quantity = productQuantity,
                PricebookEntryId = pricebookEntryList[0].Id,
                UnitPrice = productUnitPrice,
                esRegalia__c = esRegalia,
                esExtra__c = esExtra,
                Quote_Line_Item__c = qliId,
                BMW_Bodega__c = bodegaId,
                Total_Extra__c = esExtra ? total : 0,
                Total_Regalia__c = esRegalia ? total : 0
            );
            
            insert newQLI;
        } catch (DmlException e) {
            throw new AuraHandledException(e.getMessage());
        }
        return responseMap;
    }

    private static String resolveCompanyCode(Id companyId, String legacyCompany) {
        String companyCode;
        if (companyId != null) {
            companyCode = EmpresaResolver.resolve(companyId).codigo;
        } else if (legacyCompany == 'Bavarian') {
            companyCode = 'RMBAVARIAN';
        } else if (legacyCompany == 'Otobai') {
            companyCode = 'RMOTOBAI';
        }

        if (!USD_PRICEBOOK_BY_COMPANY.containsKey(companyCode)) {
            throw new EmpresaConfigurationException(
                String.isBlank(companyCode)
                    ? 'La empresa de la oportunidad es requerida.'
                    : 'La empresa de la oportunidad no esta soportada: ' + companyCode + '.'
            );
        }
        return companyCode;
    }

    private static Pricebook2 getActivePricebook(String companyCode) {
        String pricebookName = USD_PRICEBOOK_BY_COMPANY.get(companyCode);
        List<Pricebook2> pricebooks = [
            SELECT Id, Name, CurrencyIsoCode
            FROM Pricebook2
            WHERE Name = :pricebookName
            AND IsActive = true
        ];
        if (pricebooks.size() != 1) {
            throw new AuraHandledException(
                pricebooks.isEmpty()
                    ? 'No se encontro el Pricebook activo ' + pricebookName + '.'
                    : 'Se encontro mas de un Pricebook activo ' + pricebookName + '.'
            );
        }
        return pricebooks[0];
    }

}
