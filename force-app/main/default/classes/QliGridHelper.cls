public class QliGridHelper {
    private QliGridQueryService queryService;
    private String objectId;
    
    public QliGridHelper(String quoteId){
        this.queryService = new QliGridQueryService(quoteId);
        this.objectId = quoteId;
        
    }
    
    public QliGridHelper(String quoteId, Boolean isQuote){
        this.queryService = new QliGridQueryService(quoteId, isQuote);
        this.objectId = quoteId;
    }

    public List<QLIGridWrapper> qolisToWrappers(String listTosave) {
        System.debug('listTosave ' + listTosave);
        List<QLIGridWrapper> quoteLineItems = new List<QLIGridWrapper>();
        Map<String, List<QliGridWrapper.Bodegas>> bodegasByProduct =
            setBodegas(queryService.getQuolis());
    
        for (QuoteLineItem ql : queryService.getQuolis()) {
            QLIGridWrapper wr = new QLIGridWrapper(
                ql.ProductoPorBodega__c, ql.Product2Id, ql.Product2.Codigo_de_Producto__c,
                ql.Product2.Name, ql.UnitPrice, ql.BMW_Bodega__r.Name,
                ql.ProductoPorBodega__r.Disponible__c, ql.Product2.TipoProducto__c,ql.Estado_aprobaci_n_service__c,
                ql.BMW_Alias__c, null, ql.PricebookEntryId, ql.PricebookEntry.CurrencyIsoCode,
                ql.BMW_Bodega__c, ql.BMW_Bodega__r.Bodega__c, ql.ProductoPorBodega__c
            );
            wr.setQolId(ql.Id);
            wr.defaultMostrador = ql.DefaultMostrador__c;
            wr.cantidad = ql.Quantity;
            wr.discount = ql.Discount;
            wr.unitPrice = ql.UnitPrice;
            wr.isClosed = false;
            wr.estadoReserva = ql.Estado_reserva__c != null ? ql.Estado_reserva__c : 'Pendiente de reserva';
            wr.estadoEntrega = ql.Estado_entrega__c != null ? ql.Estado_entrega__c : 'Sin Entregar';
            wr.estadoSoftland =ql.Estado_softland__c != null ? ql.Estado_softland__c : '';
            wr.estadoAprobacion = ql.Estado_aprobaci_n_service__c != null ? ql.Estado_aprobaci_n_service__c : '';
            wr.cantidadDevolucion = ql.Cantidad_devolucion__c;
            wr.estadoSolicitudCompra = ql.Estado_solicitud_compra__c;
            wr.solicitudCompraID = ql.Identificador_solicitud_de_compra__c;
            wr.cantidadSC = ql.CantidadSC__c;
            wr.bodegas = bodegasByProduct.get(ql.Product2Id);
            wr.tareaId   = (String) ql.Tarea__c;
            wr.tareaName = ql.Tarea__r != null ? ql.Tarea__r.Name : null;
    		wr.prioridad = ql.Categor_a_de_presupuesto__c;
            wr.tipoCargo  = ql.TipoCargo__c; 
			wr.Aprobador  = ql.Aprobador__c;
            wr.trabajoARealizar     = (String) ql.TrabajoARealizar__c;
			wr.subTrabajoARealizar  = (String) ql.SubTrabajoARealizar__c;
			wr.trabajoARealizarName = (ql.TrabajoARealizar__r != null) ? ql.TrabajoARealizar__r.Name : null;
            quoteLineItems.add(wr);
        }
        return quoteLineItems;
    }

    
   /* public List<QliGridWrapper> searchProductsbyValue(String productType, String queryValue) {
        List<QliGridWrapper> quoteLineItems = new List<QliGridWrapper>();
    
        if (queryValue.length() >= 4) {
            Map<Id, Product2> products = queryService.searchProductsByName(queryValue);
            List<Id> bodegasPrincipales = queryService.getPrincipals();
    
            for (Product2 prod : products.values()) {
                List<QliGridWrapper.Bodegas> bodegaList = new List<QliGridWrapper.Bodegas>();
    
                if (prod.PricebookEntries.size() > 0) { PricebookEntry pentry = prod.PricebookEntries[0];
    
                    for (ProductoXBodega__c pxb : prod.Productos_por_Bodega__r) {
                        QliGridWrapper.Bodegas bodega = new QliGridWrapper.Bodegas();
                        bodega.name = pxb.Bodega__r.Name; bodega.cantidadDisponible = pxb.Disponible__c;
                        bodega.Id = pxb.Bodega__c; bodega.isPrincipal = bodegasPrincipales.contains(bodega.Id);
                        bodegaList.add(bodega);
                    }
    
                    ProductoXBodega__c pxb = prod.Productos_por_Bodega__r[0];
                    QliGridWrapper wl = new QliGridWrapper(
                        pxb.Id, prod.Id, prod.Codigo_de_Producto__c, prod.Name,
                        pentry.UnitPrice, pxb.Bodega__r.Name, pxb.Disponible__c,
                        prod.tipoProducto__c,'', '',
                        null, pentry.Id, pentry.CurrencyIsoCode, bodegasPrincipales.isEmpty() ? null : bodegasPrincipales[0],
                        pxb.Bodega__r.bodega__c, pxb.Id
                    );
    
                    wl.bodegas = bodegaList;
                    wl.isUpdate = false;
                    quoteLineItems.add(wl);
                }
            }
        }
    
        return quoteLineItems;
    }*/
	public List<QliGridWrapper> searchProductsbyValue(String productType, String queryValue) {
        List<QliGridWrapper> quoteLineItems = new List<QliGridWrapper>();
    
        if (queryValue != null && queryValue.length() >= 4) {
            Map<Id, Product2> products = queryService.searchProductsByName(queryValue);
            List<Id> bodegasPrincipales = queryService.getPrincipals();
    
            for (Product2 prod : products.values()) {
                if (prod.PricebookEntries.isEmpty()) continue;
                PricebookEntry pentry = prod.PricebookEntries[0];
    
                List<QliGridWrapper.Bodegas> bodegaList = new List<QliGridWrapper.Bodegas>();
                for (ProductoXBodega__c pxbIt : prod.Productos_por_Bodega__r) {
                    QliGridWrapper.Bodegas b = new QliGridWrapper.Bodegas();
                    b.name = pxbIt.Bodega__r.Name;
                    b.cantidadDisponible = pxbIt.Disponible__c;
                    b.Id = pxbIt.Bodega__c;
                    b.isPrincipal = bodegasPrincipales.contains(b.Id);
                    bodegaList.add(b);
                }
    
                if (!prod.Productos_por_Bodega__r.isEmpty()) {
                    // Camino usual (con bodega)
                    ProductoXBodega__c pxb = prod.Productos_por_Bodega__r[0];
                    QliGridWrapper wl = new QliGridWrapper(
                        pxb.Id, prod.Id, prod.Codigo_de_Producto__c, prod.Name,
                        pentry.UnitPrice, pxb.Bodega__r.Name, pxb.Disponible__c,
                        prod.TipoProducto__c, '', '', null, pentry.Id, pentry.CurrencyIsoCode,
                        bodegasPrincipales.isEmpty() ? null : bodegasPrincipales[0],
                        pxb.Bodega__r.Bodega__c, pxb.Id
                    );
                    wl.bodegas = bodegaList;
                    wl.isUpdate = false;
                    quoteLineItems.add(wl);
                } else {
                    // Mano de Obra sin bodega
                    QliGridWrapper wl = new QliGridWrapper(
                        null, prod.Id, prod.Codigo_de_Producto__c, prod.Name,
                        pentry.UnitPrice, 'Mano de Obra', 1000,
                        prod.TipoProducto__c, '', '', null, pentry.Id, pentry.CurrencyIsoCode,
                        bodegasPrincipales.isEmpty() ? null : bodegasPrincipales[0],
                        null, null
                    );
                    wl.bodegas = new List<QliGridWrapper.Bodegas>();
                    wl.isUpdate = false;
                    quoteLineItems.add(wl);
                }
            }
        }
        return quoteLineItems;
    }

    public String saveAndGetPublicURLFile(List<String> contentIds){
        List<ContentVersion> contentVersions = queryService.getContentVersions(contentIds);
        List <ContentDistribution> contentDistributions = new List<ContentDistribution>();
        for(ContentVersion cv: contentVersions){
            ContentDistribution cd = new ContentDistribution();
            cd.Name = 'noenviado';
            cd.ContentVersionId = cv.id;
            cd.PreferencesAllowViewInBrowser= true;
            cd.PreferencesLinkLatestVersion=true;
            cd.PreferencesNotifyOnVisit=false;
            cd.PreferencesPasswordRequired=false;
            contentDistributions.add(cd);
        }
        insert contentDistributions;
        System.debug('QUOTEFILES');
        System.debug(contentDistributions.size());
        System.debug(contentDistributions);
        String publicURL = queryService.getFileUrl(contentIds[0]);
        Quote quote = new Quote();
        quote.Id = this.objectId;
        quote.Adjunto_Solicitud_Compra__c = publicURL;
        update quote;
        return publicURL;
    }

    public String saveAndGetPublicURLFileWO(List<String> contentIds){
        List<ContentVersion> contentVersions = queryService.getContentVersions(contentIds);
        List <ContentDistribution> contentDistributions = new List<ContentDistribution>();
        for(ContentVersion cv: contentVersions){
            ContentDistribution cd = new ContentDistribution();
            cd.Name = 'noenviado';
            cd.ContentVersionId = cv.id;
            cd.PreferencesAllowViewInBrowser= true;
            cd.PreferencesLinkLatestVersion=true;
            cd.PreferencesNotifyOnVisit=false;
            cd.PreferencesPasswordRequired=false;
            contentDistributions.add(cd);
        }
        insert contentDistributions;
        System.debug('QUOTEFILES');
        System.debug(contentDistributions.size());
        System.debug(contentDistributions);
        String publicURL = queryService.getFileUrl(contentIds[0]);
        Quote qo = new Quote();
        qo.Id = this.objectId;
        update qo;
        return publicURL;
    }

   
    private Map<String, List<QliGridWrapper.Bodegas>> setBodegas(List<QuoteLineItem> qlis) {
        List<Id> bodegasPrincipales = queryService.getPrincipals(); 
        Map<String, List<QliGridWrapper.Bodegas>> bodegasByProduct = new Map<String, List<QliGridWrapper.Bodegas>>();
        Set<String> products = new Set<String>();
    
        for (QuoteLineItem wl : qlis) {
            products.add(wl.Product2Id);
        }
    
        Map<Id, Product2> bodegasProducts = this.queryService.getBodegasOnly(products);
    
        for (Product2 prod : bodegasProducts.values()) {
            for (ProductoXBodega__c pxb : prod.Productos_por_Bodega__r) {
                QliGridWrapper.Bodegas bodega = new QliGridWrapper.Bodegas();
                bodega.name = pxb.Bodega__r.Name;
                bodega.cantidadDisponible = pxb.Disponible__c;
                bodega.Id = pxb.Bodega__c;
                bodega.isPrincipal = bodegasPrincipales.contains(bodega.Id);
    
                if (bodegasByProduct.containsKey(prod.Id)) {  bodegasByProduct.get(prod.Id).add(bodega);
                } else {
                    bodegasByProduct.put(prod.Id, new List<QliGridWrapper.Bodegas>{bodega});
                }
            }
        }
    
        return bodegasByProduct;
    }


}