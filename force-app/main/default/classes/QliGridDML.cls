public class QliGridDML {
     private String jsonString;
    private List<QliGridWrapper> quoteLineItemsWrappers;
    
    public QliGridDML(String jsonString){
        this.quoteLineItemsWrappers = (List<QliGridWrapper>)JSON.deserialize(jsonString, List<QliGridWrapper>.class);
    }
    

    
    public void saveQuantities (Id quote) {
        //Boolean priceAccess = getPriceAccess();
        List<QuoteLineItem> quotelineitems = new List<QuoteLineItem>();
        for (QliGridWrapper wr: this.quoteLineItemsWrappers){
            QuoteLineItem wl=new QuoteLineItem();
            wl.id = wr.qolId;
            wl.Quantity=wr.cantidad;
            wl.Cantidad_devolucion__c=wr.cantidadDevolucion;
            quotelineitems.add(wl);
        }
         System.debug('SAVIIING quotelineitems');
        System.debug(quotelineitems);
        update quotelineitems;
    }

    public void saveQuoliQuantities(Id quoteId){
         //Boolean priceAccess = getPriceAccess();
         List<QuoteLineItem> quotelineitems = new List<QuoteLineItem>();for (QliGridWrapper wr: this.quoteLineItemsWrappers){ QuoteLineItem ql = new QuoteLineItem(); ql.id = wr.qolId;ql.Quantity=wr.cantidad;ql.Cantidad_devolucion__c=wr.cantidadDevolucion;quotelineitems.add(ql);
         }
         System.debug('Saving QuoteLines');
         System.debug(quotelineitems);
         update quotelineitems;
    }
    
    public static void deleteQuoteLineItems (List<String> quoteIds) {
        List<QuoteLineItem> deleteQuoteIds = [Select id,QuoteId  FROM QuoteLineItem WHERE ID =: quoteIds]; String message = UserInfo.getName()+' ha eliminado: ('+deleteQuoteIds.size()+') Líneas del presupuesto.\n Detalle de Líneas:\n\n';JSON_History__c deleteLog = new JSON_History__c(Error_Message__c=UserInfo.getName()+' ha eliminado: ('+deleteQuoteIds.size()+') Líneas de la orden.',Work_Order__c = deleteQuoteIds[0].QuoteId, JSON__c= message);
        System.debug(deleteQuoteIds);
        delete deleteQuoteIds;insert deleteLog;
    }

	public static String toTipoCargoValue(String s) {
        if (s == null) return null;
        String k = s.trim();
        // si ya viene como valor API
        if (k == '1' || k == '2' || k == '3' || k == '4' || k == '5' || k == '6') return k;
    
        // normalizar a minúsculas y manejar acentos
        String k2 = k.toLowerCase();
        if (k2 == 'cliente')       return '1';
        if (k2 == 'interno')       return '2';
        if (k2 == 'aseguradora')   return '3';
        if (k2 == 'garantía' || k2 == 'garantia') return '4';
        if (k2 == 'bsi')           return '5';
        if (k2 == 'bsi interno' || k2 == 'bsi-interno') return '6';
        return null; // si no mapea, no asignamos para evitar INVALID_OR_NULL_FOR_RESTRICTED_PICKLIST
    }
    public void saveQuoteLineItems (Id quoteId){
        List<QuoteLineItem> quoteLineItems = new List<QuoteLineItem>();
        String Sugerido= 'Recomendado';
    
        for (QliGridWrapper wr : this.quoteLineItemsWrappers){
            QuoteLineItem qli = new QuoteLineItem();
    	
            if (wr.qolId != null) {
                qli.Id = wr.qolId; // update
            } else {
                qli.QuoteId = quoteId; qli.Product2Id = wr.productId; qli.PricebookEntryId = wr.priceBookEntry;
            }
    
            // ===== NUEVO: tarea desde el wrapper =====
            if (String.isNotBlank(wr.tareaId)) { qli.Tarea__c = wr.tareaId;
            } else {
                // opcional: limpiar si quieres permitir dejarla en blanco al editar
                // qli.Tarea__c = null;
            }
    		if (wr.tipoCargo != null) {
                qli.TipoCargo__c = toTipoCargoValue(wr.tipoCargo);
            }
            if (wr.Aprobador != null) {
                qli.Aprobador__c = wr.Aprobador;
            }
            // Campos existentes
            qli.BMW_Alias__c = wr.alias;
            qli.Quantity     = wr.cantidad;
            qli.Discount     = wr.discount;
    
            if (wr.bodegaID != null){
                qli.BMW_Bodega__c      = wr.bodegaID;
                qli.ProductoPorBodega__c = wr.ProductXBodegaID;
            }
    		 if (wr.trabajoARealizar != null)    qli.TrabajoARealizar__c    = wr.trabajoARealizar;
        if (wr.subTrabajoARealizar != null) qli.SubTrabajoARealizar__c = wr.subTrabajoARealizar;
            qli.UnitPrice = wr.unitPrice;
            quoteLineItems.add(qli);
        }
    
        upsert quoteLineItems;
    }

    public static void deleteQlis (List<String> quoteIds) {
        List<QuoteLineItem> deleteWorkorderIds = [Select id  FROM QuoteLineItem WHERE ID =: quoteIds];
        System.debug(deleteWorkorderIds);
        delete deleteWorkorderIds;
    }

}