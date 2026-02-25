public with sharing class CT_DisponibilidadBodegaController {
    @AuraEnabled(cacheable=true)
    public static List<CT_DisponibilidadBodegaController.Productos> getProductosDisponibles(Id PresupuestoId) {
        System.debug('PresupuestoId: '+PresupuestoId);
        List<CT_DisponibilidadBodegaController.Productos> productosList = new List<CT_DisponibilidadBodegaController.Productos>();
        List<QuoteLineItem> partidaList = new List<QuoteLineItem>();
        List<ProductoXBodega__c> prodXBodegaList = new List<ProductoXBodega__c>();
        partidaList = [Select Product2Id,Product2.Name,BMW_Bodega__c,BMW_Bodega__r.Name,Quantity From QuoteLineItem Where QuoteId =: PresupuestoId];
        Set<Id> productosIds = new Set<Id>();
        Set<Id> BodegasIds = new Set<Id>();
        if(partidaList.size()>0){
            for(QuoteLineItem qli: partidaList){
                productosIds.add(qli.Product2Id);
                BodegasIds.add(qli.BMW_Bodega__c);
            }
            prodXBodegaList = [Select BodegaNombre__c,Disponible__c,CT_ProductoCode__c,
            CT_ProductoNombre__c, CT_ProductoPrecio__c,Bodega__c,Producto__c
                                From ProductoXBodega__c 
                               Where Producto__c IN: productosIds AND Bodega__c IN: BodegasIds];
            if(prodXBodegaList.size()>0){
                Boolean encontrado = false;
                for(QuoteLineItem qli: partidaList){
                    encontrado = false;
                    for(ProductoXBodega__c pxb : prodXBodegaList){
                        if(qli.Product2Id == pxb.Producto__c && qli.BMW_Bodega__c == pxb.Bodega__c){
                            encontrado = true;
                            CT_DisponibilidadBodegaController.Productos producto = new CT_DisponibilidadBodegaController.Productos();
                            producto.Producto = qli.Product2.Name;
                            producto.Bodega = qli.BMW_Bodega__r.Name;
                            producto.Disponible = pxb.Disponible__c;
                            producto.Seleccionados = qli.Quantity;
                            productosList.add(producto);
                        }
                    }
                    if(encontrado == false){
                        CT_DisponibilidadBodegaController.Productos producto = new CT_DisponibilidadBodegaController.Productos();
                        producto.Producto = qli.Product2.Name;
                        producto.Bodega = qli.BMW_Bodega__r.Name;
                        producto.Disponible = 0;
                        producto.Seleccionados = qli.Quantity;
                        productosList.add(producto);
                    }
                }
            }
            else{
                for(QuoteLineItem qli: partidaList){
                    CT_DisponibilidadBodegaController.Productos producto = new CT_DisponibilidadBodegaController.Productos();
                    producto.Producto = qli.Product2.Name;
                    producto.Bodega = qli.BMW_Bodega__r.Name;
                    producto.Disponible = 0;
                    producto.Seleccionados = qli.Quantity;
                    productosList.add(producto);
                }
            }
        }
        System.debug('productosList: '+productosList);
        return productosList;
    }
    public class Productos{
        @AuraEnabled 
        public String Producto {get;set;}
        @AuraEnabled 
        public String Bodega {get;set;}
        @AuraEnabled 
        public Decimal Disponible {get;set;}
        @AuraEnabled 
        public Decimal Seleccionados {get;set;}
    }
    @AuraEnabled(cacheable=true)
    public static Quote getQuote(Id PresupuestoId) {
        Quote quo = [Select Id, BMW_Advertencias__c From Quote Where Id =: PresupuestoId];
        return quo;
    }

}