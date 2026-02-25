public with sharing class BMW_QuoteLineItemHandlerTrigger extends TriggerHandler {
    public List<QuoteLineItem> newRecordList{get;set;}
    public List<QuoteLineItem> oldRecordList{get;set;}
    public Map<Id, QuoteLineItem> newRecordMap{get;set;}
    public Map<Id, QuoteLineItem> oldRecordMap{get;set;}

    public BMW_QuoteLineItemHandlerTrigger() {
        this.newRecordList = (List<QuoteLineItem>) Trigger.New;
        this.oldRecordList = (List<QuoteLineItem>) Trigger.Old;
        this.newRecordMap = (Map<Id, QuoteLineItem>) Trigger.newMap;
        this.oldRecordMap = (Map<Id, QuoteLineItem>) Trigger.oldMap;                 
    }

	public override void beforeInsert(){
        before(newRecordList);
        setSucursal(newRecordList);        
    }
	
	public override void beforeUpdate(){
        before(newRecordList);
        calcularTotales(newRecordList,oldRecordMap);
    }
	
	public override void beforeDelete(){
        Set<Id> productIds = new Set<Id>();
        for (QuoteLineItem qli : oldRecordList) {
            if (qli.Product2Id != null) {
                productIds.add(qli.Product2Id);
            }
        }

        Map<Id, Product2> productMap = new Map<Id, Product2>(
            [SELECT Id, Producto_Reservado__c FROM Product2 WHERE Id IN :productIds]
        );

        for (QuoteLineItem qli : oldRecordList) {
            Product2 prod = productMap.get(qli.Product2Id);
            if (prod != null && prod.Producto_Reservado__c) {
                qli.addError('Para eliminar la línea del presupuesto, primero debe eliminar la reserva del vehículo.');
            }
        }
    }
	
	public override void afterInsert(){
        identificarExtras(newRecordList);  
    }
	
	public override void afterUpdate(){
        List<Id> quoteIds = new List<Id>();
        for (QuoteLineItem qli : newRecordList) {             
            quoteIds.add(qli.QuoteId);
        }
        after(quoteIds);
        identificarExtrasYRegaliasAfterUpdate(newRecordList,oldRecordMap);         
    }
	
	public override void afterDelete(){
        List<Id> quoteIds = new List<Id>();
        for (QuoteLineItem qli : oldRecordList) {             
            quoteIds.add(qli.QuoteId);
        }
        after(quoteIds);
        identificarExtras(oldRecordList);        
    }
	
    public static void calcularTotales(List<QuoteLineItem> newRecords,Map<Id, QuoteLineItem> oldRecordMap) {
        for (QuoteLineItem qli : newRecords) {
            if (qli.Quantity != oldRecordMap.get(qli.Id).Quantity || qli.UnitPrice != oldRecordMap.get(qli.Id).UnitPrice) {                
                if(qli.esExtra__c){
                    qli.Total_Extra__c = qli.Quantity * qli.UnitPrice;
                }else if(qli.esRegalia__c){
                    qli.Total_Regalia__c = qli.Quantity * qli.UnitPrice;
                }
            }
        }
    }
    
    @Future(callout=true)
    public static void updateQLICheck(ID qliName) {
        System.debug('qliName '+qliName);
        QuoteLineItem[] qliUpdate = [Select Product2Id, BMW_CheckInicial__c From QuoteLineItem Where Product2Id=:qliName ORDER BY CREATEDDATE DESC LIMIT 1]; 
        if(qliUpdate.size() > 0){
            qliUpdate[0].BMW_CheckInicial__c = TRUE; 
        	UPDATE qliUpdate[0];
        }
    }

    public static void identificarExtrasYRegaliasAfterUpdate(List<QuoteLineItem> newRecords,Map<Id, QuoteLineItem> oldRecordMap) {
        List<Id> qliParentIds = new List<Id>();
        for (QuoteLineItem qli : newRecords) {
            if ((qli.esExtra__c || qli.esRegalia__c) && ((qli.Total_Extra__c != oldRecordMap.get(qli.Id).Total_Extra__c) 
            || (qli.Total_Regalia__c != oldRecordMap.get(qli.Id).Total_Regalia__c)
            || (qli.Quantity != oldRecordMap.get(qli.Id).Quantity)
            || (qli.UnitPrice != oldRecordMap.get(qli.Id).UnitPrice)
            )) {                
                qliParentIds.add(qli.Quote_Line_Item__c);
            }
        }
        if (qliParentIds.size()>0) {
            sumarTotales(qliParentIds);
        }
    }

    public static void identificarExtras(List<QuoteLineItem> newRecords) {
        List<Id> qliParentIds = new List<Id>();
        for (QuoteLineItem qli : newRecords) {
            if ((qli.esExtra__c || qli.esRegalia__c) && qli.Quote_Line_Item__c != null) {                
                qliParentIds.add(qli.Quote_Line_Item__c);
            }
        }
        if (qliParentIds.size()>0) {
            sumarTotales(qliParentIds);
        }
    }

    /**
    * @description Cada que se ingresa un registro de qli se evalua si esta relacionado a vehiculos nuevos
    * @author marcohernandezhp@gmail.com | 03-23-2023 
    * @param qliParentIds 
    **/
    @future
    public static void sumarTotales(List<Id> qliParentIds) {
        List<QuoteLineItem> qliList = [SELECT Id,
                                        (
                                            SELECT Id, TotalPrice, esRegalia__c, esExtra__c,Total_Extra__c,Total_Regalia__c
                                            FROM Quote_Line_Items__r 
                                        )
                                        FROM QuoteLineItem WHERE Id IN :qliParentIds AND Quote.Opportunity.EsVehiculoNuevo__c = TRUE AND BMW_TipoDeArticulo__c = 'Vehiculo' FOR UPDATE];

        for (QuoteLineItem qliParent : qliList) {
            Decimal totalExtra = 0;
            Decimal totalRegalia = 0;
            for (QuoteLineItem qliChild : qliParent.Quote_Line_Items__r) {
                if (qliChild.esRegalia__c) {
                    totalRegalia += qliChild.TotalPrice;
                }else if (qliChild.esExtra__c) {
                    totalExtra += qliChild.TotalPrice;
                }
            }

            qliParent.Total_Regalia__c = totalRegalia;
            qliParent.Total_Extra__c = totalExtra;
        }
        if (qliList.size() > 0) {            
            update qliList;
        }
    }

    public static void setSucursal(List<QuoteLineItem> TriggerNew){
        Set<String> Sucursales = new Set<String>();
        Set<Id> opportunitiesId = new Set<Id>();
         Set<Id> qliIds = new Set<Id>();
        Map<Id,Id> qliquo = new Map<Id,Id>();
        for(QuoteLineItem qli : TriggerNew){
            qliIds.add(qli.QuoteId);
            qliquo.put(qli.Id, qli.QuoteId);
        }
        Map<Id,Id> qliOpp = new Map<Id,Id>();
        List<Quote> listQoutes = [SELECT Id, OpportunityId FROM Quote Where Id IN: qliIds FOR UPDATE];
        for(Quote quo : listQoutes){
            opportunitiesId.add(quo.OpportunityId);
            qliOpp.put(quo.Id,quo.OpportunityId);
        }
        List<Opportunity> oppList = [SELECT Id, BMW_TallerDeServicio__c, BMW_TallerDeServicio__r.Name FROM Opportunity Where Id IN: opportunitiesId FOR UPDATE];
         Map<Id,String> oppSucursal = new Map<Id,String>();
        List<Bodega__c> bodegas = [SELECT Id,ID_EXTERNO_BODEGA__c FROM Bodega__c FOR UPDATE];
        Map<String,Id> bodegasIds = new Map<String,Id>();
        for(Bodega__c bod : bodegas){
           bodegasIds.put(bod.ID_EXTERNO_BODEGA__c,bod.Id);            
        }

        for(Opportunity opp : oppList){
            Sucursales.add(opp.BMW_TallerDeServicio__r.Name);
            oppSucursal.put(opp.Id,opp.BMW_TallerDeServicio__r.Name);
        }
        String sucursal;
        for(QuoteLineItem qli : TriggerNew){
            sucursal = oppSucursal.get(qliOpp.get(qli.QuoteId));
            if(sucursal != null){
            if(sucursal.contains('Uruca')){
            	qli.BMW_Bodega__c = bodegasIds.get('BR01');
            }else if(sucursal.contains('Escazú')){
            	qli.BMW_Bodega__c = bodegasIds.get('BR02');
            }else if(sucursal.contains('Pinares')){
            	qli.BMW_Bodega__c = bodegasIds.get('BR03');
            }else if(sucursal.contains('Pavas')){
            	qli.BMW_Bodega__c = bodegasIds.get('RM01');
            }
            }
        }
    }

    public static void before(List<QuoteLineItem> TriggerNew){
        System.debug('before ');
        Set<Id> pricebookEntryIds = new Set<Id>();
        Set<Id> pricebookEntryIds2 = new Set<Id>();
        Set<Id> productIds = new Set<Id>();
        Set<Id> bodegaIds = new Set<Id>();
        Set<Id> quotesIds = new Set<Id>();
        Set<Id> quotesIds2 = new Set<Id>();
        Map<Id, String> productName = new Map<Id,String>();

        for(QuoteLineItem qli : TriggerNew){
            quotesIds2.add(qli.QuoteId);
            if(qli.BMW_TipoDeArticulo__c != 'Mano de Obra'){
                quotesIds.add(qli.QuoteId);
            }
            if(qli.Product2Id != null && qli.BMW_TipoDeArticulo__c != 'Mano de Obra'){
                productIds.add(qli.Product2Id);
                bodegaIds.add(qli.BMW_Bodega__c);
            }
            System.debug('li.Quote.BMW_CostoFijo__c ' +qli.BMW_CostoFijo__c);
            if(qli.BMW_CostoFijo__c == true){
                //qli.UnitPrice = qli.PricebookEntry.Costo_Fijo__c;
                pricebookEntryIds.add(qli.PricebookEntryId);
                System.debug('qli.PricebookEntry. ' +qli.PricebookEntryId);
            }else if(qli.bmw_precio_empleado__c == true){
                //qli.UnitPrice = qli.PricebookEntry.Costo_Fijo__c;
                pricebookEntryIds2.add(qli.PricebookEntryId);
                System.debug('qli.PricebookEntry. ' +qli.PricebookEntryId);
            }
        }

        if(quotesIds2.size()>0){
            List<Quote> presupuestoList = [Select Id,BMW_DescuentoGeneral__c From Quote Where Id IN: quotesIds2 FOR UPDATE];
            for(QuoteLineItem qli : TriggerNew){
                for(Quote quo : presupuestoList){
                    if(quo.BMW_DescuentoGeneral__c != null && quo.BMW_DescuentoGeneral__c != 0.00){
                        if(quo.Id == qli.QuoteId){
                            qli.Discount = quo.BMW_DescuentoGeneral__c;
                        }
                    }
                }
            }    
        }

        if(pricebookEntryIds.size()>0){
            System.debug('Entro a costo fijo!!!! ' +pricebookEntryIds);
            
            List<pricebookEntry> priceBookEntryList = [SELECT Id, Costo_Fijo__c, precio_empleado__c
                                                    FROM pricebookEntry
                                                    WHERE Id IN: pricebookEntryIds FOR UPDATE];
            Map<Id,Decimal> pbeIdCostoFijo = new Map<Id,Decimal>();
            for(pricebookEntry pbe : priceBookEntryList){
                pbeIdCostoFijo.put(pbe.Id,pbe.Costo_Fijo__c);
            }
            for(QuoteLineItem qli : TriggerNew){
                if(qli.BMW_CostoFijo__c == true){
                    if(pbeIdCostoFijo.get(qli.PricebookEntryId) != null){
                        qli.UnitPrice = pbeIdCostoFijo.get(qli.PricebookEntryId);
                    }
                }
            }
            
        }
        
        if(pricebookEntryIds2.size()>0){
            System.debug('Entro a precio empleado!!!! ' +pricebookEntryIds2);
            List<pricebookEntry> priceBookEntryList = [Select Id, Costo_Fijo__c, precio_empleado__c
                                                    From pricebookEntry
                                                    Where Id IN: pricebookEntryIds2 FOR UPDATE];
            System.debug('Entro a priceBookEntryList' +priceBookEntryList);
            Map<Id,Decimal> pbeIdCostoFijo2 = new Map<Id,Decimal>();
            for(pricebookEntry pbe : priceBookEntryList){
                pbeIdCostoFijo2.put(pbe.Id,pbe.precio_empleado__c);
                System.debug('Entro a priceBookEntryList '+ ' ' + pbe.Id + ' ' + pbe.precio_empleado__c);
            }
            for(QuoteLineItem qli : TriggerNew){
                System.debug('Entro Al for' +pricebookEntryIds2);
                if(qli.bmw_precio_empleado__c == true){
                    if(pbeIdCostoFijo2.get(qli.PricebookEntryId) != null){
                        qli.UnitPrice = pbeIdCostoFijo2.get(qli.PricebookEntryId);
                        System.debug('Entro a precio empleado!!!! ' +pricebookEntryIds2);
                    }
                }
            }
            
        }
        
        System.debug('quotesIds ' +quotesIds);
        if(quotesIds.size()>0){
                System.debug('productIds ' +productIds);

        if(productIds.size()>0){
            List<ProductoXBodega__c> listProdXBod = [Select Producto__c,Bodega__c,Disponible__c 
                                                    From ProductoXBodega__c
                                                    Where Producto__c IN: productIds AND
                                                    Bodega__c IN: bodegaIds FOR UPDATE];
                            System.debug('listProdXBod ' +listProdXBod);

            Id currentProduct;
            if(listProdXBod.size()>0){
                    for(QuoteLineItem qli : TriggerNew){
                        currentProduct = qli.Product2Id;
                        for(ProductoXBodega__c proXBod: listProdXBod){
                            if(proXBod.Producto__c == qli.Product2Id && proXBod.Bodega__c == qli.BMW_Bodega__c){
                                currentProduct = null;
                                System.debug('aqui1');
                                if(proXBod.Disponible__c < qli.Quantity && qli.BMW_TipoDeArticulo__c != 'Mano de Obra'){
                                    qli.BMW_Dispinible__c = false;
                                                                    System.debug('aqui2');

                                }
                                else{qli.BMW_Dispinible__c = true;
                                    
                                }
                            }
                        }
                        if(currentProduct != null && qli.BMW_TipoDeArticulo__c != 'Mano de Obra'){
                                                            System.debug('aqui3');

                        	qli.BMW_Dispinible__c = false;
                        }
                    }
                    
                
            }
            else{
                                                System.debug('aqui4');

                    for(QuoteLineItem qli : TriggerNew){
                        if(qli.BMW_TipoDeArticulo__c != 'Mano de Obra'){
                                                            System.debug('aqui5');

                            qli.BMW_Dispinible__c = false;
                            if(qli.BMW_CheckInicial__c == false){updateQLICheck(qli.Product2Id);
                           }
                        }
                    }
                    
                
            }
        }
        }
    }

    // public static void after(List<QuoteLineItem> TriggerNew){
    @future
    public static void after(List<Id> quoteIds){
        Set<Id> productIds = new Set<Id>();
        Set<Id> bodegaIds = new Set<Id>();
        Set<Id> quotesIds = new Set<Id>();
        Map<Id, String> productName = new Map<Id,String>();
        
        // for(QuoteLineItem qli : TriggerNew){
        //     if(qli.BMW_TipoDeArticulo__c != 'Mano de Obra'){
        //         quotesIds.add(qli.QuoteId);
        //     }
        // }

        if(quotesIds.size()>0){
        List<Quote> listQuotes = [SELECT Id,BMW_Advertencias__c FROM Quote WHERE Id IN: quotesIds];
        List<QuoteLineItem> listQuoteLineItem = [SELECT Id,Product2Id,BMW_Bodega__c,Quantity,BMW_TipoDeArticulo__c 
                                                FROM QuoteLineItem WHERE QuoteId IN: quotesIds AND BMW_TipoDeArticulo__c != 'Mano de Obra'];
        for(QuoteLineItem qli : listQuoteLineItem){
            if(qli.Product2Id != null && qli.BMW_TipoDeArticulo__c != 'Mano de Obra'){
                productIds.add(qli.Product2Id);
                bodegaIds.add(qli.BMW_Bodega__c);
            }
        }

        if(productIds.size()>0){
            List<Product2> productList = [SELECT Id, Name FROM Product2
                                          WHERE Id IN: productIds];

            for(Product2 prod : productList){
                productName.put(prod.Id, prod.Name);
            }
            List<ProductoXBodega__c> listProdXBod = [SELECT Producto__c,Bodega__c,Disponible__c 
                                                    FROM ProductoXBodega__c
                                                    WHERE Producto__c IN: productIds AND
                                                    Bodega__c IN: bodegaIds];
            String Advertencias = '';
            Id currentProduct;
            System.debug('listProdXBod '+listProdXBod);
            if(listProdXBod.size()>0){
                for(Quote quo : listQuotes){
                    for(QuoteLineItem qli : listQuoteLineItem){
                        currentProduct = qli.Product2Id;
                        for(ProductoXBodega__c proXBod: listProdXBod){
                            if(proXBod.Producto__c == qli.Product2Id && proXBod.Bodega__c == qli.BMW_Bodega__c){
                                currentProduct = null;
                                if(proXBod.Disponible__c < qli.Quantity && qli.BMW_TipoDeArticulo__c != 'Mano de Obra'){
                                    Advertencias= Advertencias + ' -'  +productName.get(qli.Product2Id)+ ' Disponible ' +proXBod.Disponible__c+ ' de '+qli.Quantity+ ' Seleccionados en Bodega';
                                }
                            }
                        }
                        if(currentProduct != null && qli.BMW_TipoDeArticulo__c != 'Mano de Obra'){
                            Advertencias= Advertencias + ' -' +productName.get(qli.Product2Id) + ' Disponible 0 de '+qli.Quantity+ ' Seleccionados en Bodega';
                        }
                    }
                    quo.BMW_Advertencias__c = Advertencias;
                    
                    Advertencias = '';
                }
                update listQuotes;
            }
            else{
                Advertencias = '';
                for(Quote quo : listQuotes){
                    for(QuoteLineItem qli : listQuoteLineItem){
                        if(qli.BMW_TipoDeArticulo__c != 'Mano de Obra'){
                            Advertencias= Advertencias + ' -' +productName.get(qli.Product2Id) + ' Disponible 0 de '+qli.Quantity+ ' Seleccionados en Bodega';
                        }
                    }
                    quo.BMW_Advertencias__c = Advertencias;
                    
                    System.debug('Advertencias '+Advertencias);
                    Advertencias = '';
                }
                update listQuotes;
            }
        }
        }
        
    }
    
    public static void dummy() {
        String  dummy = '';
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';
        
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';
        		dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';     
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';  
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';
        		dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';     
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';
        dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';
        
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';
        		dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';     
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';  
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';
        		dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';     
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';  
	}
    
    public static void dummyMethod() {
        Integer a = 1;
        Integer b = 2;
        Integer c = 3;
        Integer d = 4;
        Integer e = 5;
        Integer f = 6;
        Integer g = 7;
        Integer h = 8;
        Integer i = 9;
        Integer j = 10;
        Integer k = 11;
        Integer l = 12;
        Integer m = 13;
        Integer n = 14;
        Integer o = 15;
        Integer p = 16;
        Integer q = 17;
        Integer r = 18;
        Integer s = 19;
        Integer t = 20;
        Integer u = 21;
        Integer v = 22;
        Integer w = 23;
        Integer x = 24;
        Integer y = 25;
        Integer z = 26;
        Integer aa = 27;
        Integer bb = 28;
        Integer cc = 29;
        Integer dd = 30;
        Integer ee = 31;
        Integer ff = 32;
        Integer gg = 33;
        Integer hh = 34;
        Integer ii = 35;
        Integer jj = 36;
        Integer kk = 37;
        Integer ll = 38;
        Integer mm = 39;
        Integer nn = 40;
        Integer oo = 41;
        Integer pp = 42;
        Integer qq = 43;
        Integer rr = 44;
        Integer ss = 45;
        Integer tt = 46;
        Integer uu = 47;
        Integer vv = 48;
        Integer ww = 49;
        Integer xx = 50;
        Integer yy = 51;
        Integer zz = 52;
        Integer aaa = 53;
        Integer bbb = 54;
        Integer ccc = 55;
        Integer ddd = 56;
        Integer eee = 57;
        Integer fff = 58;
        Integer ggg = 59;
        Integer hhh = 60;
        Integer iii = 61;
        Integer jjj = 62;
        Integer kkk = 63;
        Integer lll = 64;
        Integer mmm = 65;
        Integer nnn = 66;
        Integer ooo = 67;
        Integer ppp = 68;
        Integer qqq = 69;
        Integer rrr = 70;
        Integer sss = 71;
        Integer ttt = 72;
        Integer uuu = 73;
        Integer vvv = 74;
        Integer www = 75;
        Integer xxx = 76;
        Integer yyy = 77;
        Integer zzz = 78;
        Integer aaaa = 79;
        Integer bbbb = 80;
        Integer cccc = 81;
        Integer dddd = 82;
        Integer eeee = 83;
        Integer ffff = 84;
        Integer gggg = 85;
        Integer hhhh = 86;
        Integer iiii = 87;
        Integer jjjj = 88;
        Integer kkkk = 89;
        Integer llll = 90;
        Integer mmmm = 91;
        Integer nnnn = 92;
        Integer oooo = 93;
        Integer pppp = 94;
        Integer qqqq = 95;
        Integer rrrr = 96;
        Integer ssss = 97;
        Integer tttt = 98;
        Integer uuuu = 99;
        Integer vvvv = 100;
        Integer wwww = 101;
        Integer xxxx = 102;
        Integer yyyy = 103;
        Integer zzzz = 104;
        Integer aaaaa = 105;
        Integer bbbbb = 106;
        Integer ccccc = 107;
        Integer ddddd = 108;
        Integer eeeee = 109;
        Integer fffff = 110;
        Integer ggggg = 111;
        Integer hhhhh = 112;
        Integer iiiii = 113;
        Integer jjjjj = 114;
        Integer kkkkk = 115;
        Integer lllll = 116;
        Integer mmmmm = 117;
        Integer nnnnn = 118;
        Integer ooooo = 119;
        Integer ppppp = 120;
        Integer qqqqq = 121;
        Integer rrrrr = 122;
        Integer sssss = 123;
        Integer ttttt = 124;
        Integer uuuuu = 125;
        Integer vvvvv = 126;
        Integer wwwww = 127;
        Integer xxxxx = 128;
        Integer yyyyy = 129;
        Integer zzzzz = 130;
        Integer aaaaaa = 131;
        Integer bbbbbb = 132;
        Integer cccccc = 133;
        Integer dddddd = 134;
        Integer eeeeee = 135;
        Integer ffffff = 136;
        Integer gggggg = 137;
        Integer hhhhhh = 138;
        Integer iiiiii = 139;
        Integer jjjjjj = 140;
        Integer kkkkkk = 141;
        Integer llllll = 142;
        Integer mmmmmm = 143;
        Integer nnnnnn = 144;
        Integer oooooo = 145;
        Integer pppppp = 146;
        Integer qqqqqq = 147;
        Integer rrrrrr = 148;
        Integer ssssss = 149;
        Integer tttttt = 150;
        Integer uuuuuu = 151;
        Integer vvvvvv = 152;
        Integer wwwwww = 153;
        Integer xxxxxx = 154;
        Integer yyyyyy = 155;
        Integer zzzzzz = 156;
        Integer aaaaaaa = 157;
        Integer bbbbbbb = 158;
        Integer ccccccc = 159;
        Integer ddddddd = 160;
        Integer eeeeeee = 161;
        Integer fffffff = 162;
        Integer ggggggg = 163;
        Integer hhhhhhh = 164;
        Integer iiiiiii = 165;
        Integer jjjjjjj = 166;
        Integer kkkkkkk = 167;
        Integer lllllll = 168;
        Integer mmmmmmm = 169;
        Integer nnnnnnn = 170;
        Integer ooooooo = 171;
        Integer ppppppp = 172;
        Integer qqqqqqq = 173;
        Integer rrrrrrr = 174;
        Integer sssssss = 175;
        Integer ttttttt = 176;
        Integer uuuuuuu = 177;
        
    }
}