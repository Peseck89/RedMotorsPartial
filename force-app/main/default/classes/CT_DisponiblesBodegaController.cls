public with sharing class CT_DisponiblesBodegaController {
    @AuraEnabled(cacheable=true)
    public static List<ProductoXBodega__c> getProductosBodega(Id PresupuestoId) {
        System.System.debug('PresupuestoId '+PresupuestoId);
        List<ProductoXBodega__c> prodXBodegaList = new List<ProductoXBodega__c>();
        List<QuoteLineItem> partidaList = new List<QuoteLineItem>();
        partidaList = [Select Product2Id From QuoteLineItem Where QuoteId =: PresupuestoId];
        System.System.debug('partidaList '+partidaList);
        Set<Id> productosIds = new Set<Id>();
        if(partidaList.size()>0){
            for(QuoteLineItem qli: partidaList){
                productosIds.add(qli.Product2Id);
            }
            System.System.debug('productosIds '+productosIds);

            prodXBodegaList = [Select BodegaNombre__c,Disponible__c,CT_ProductoCode__c,
            CT_ProductoNombre__c, CT_ProductoPrecio__c
                                From ProductoXBodega__c 
                               Where Producto__c IN: productosIds AND Disponible__c >0];
        }
        System.System.debug('prodXBodegaList '+prodXBodegaList);
        return prodXBodegaList;
    }
}