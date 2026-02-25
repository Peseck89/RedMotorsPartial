public with sharing class QuoteController {
    public QuoteController() {}

    @AuraEnabled(cacheable=true)
    public static Map<Id,String> getWorkOrderRelated(Id quoteId){
        Map<Id,String> responseMap1 = new Map<Id,String>();
        List<Quote> quoteList = [SELECT Opportunity.WorkOrder__c,Opportunity.Id,Opportunity.StageName,Opportunity.recordType.Name FROM Quote WHERE Id =: quoteId LIMIT 1];
        String workOrderId = '';        
        workOrderId = quoteList[0].Opportunity.WorkOrder__c;
        WorkOrder worder = [Select Id,CaseId From WorkOrder Where Id =: workOrderId LIMIT 1];
        List<WorkOrder> woList = [Select Id,WorkOrderNumber From WorkOrder Where CaseId =: worder.CaseId];
        for(WorkOrder wo : woList){
            responseMap1.put(wo.Id,wo.WorkOrderNumber);
        }
        return responseMap1;
    }

    private static final Map<String, String> cargoMap = new Map<String, String>{
        '1' => 'Cliente',
        '2' => 'Interno',
        '3' => 'Aseguradora',
        '4' => 'Garantia',
        '5' => 'BSI',
        '6' => 'BSI Interno',
        '7' => 'En proceso',
        '8' => 'Sincronice nuevamente'
    };
    
    public static String getCargo(String api) {
        if (String.isBlank(api)) {
            return null;
        }
        return cargoMap.containsKey(api) ? cargoMap.get(api) : null;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String,Object> getDefaults(Id quoteId){
        Map<String,Object> responseMap = new Map<String,Object>();
        List<Wrapper> quoteLineItemsWrapper = new List<Wrapper>();
        List<Quote> workOrderList = [SELECT Opportunity.WorkOrder__c,Opportunity.Id,Opportunity.StageName,Opportunity.recordType.Name FROM Quote WHERE Id =: quoteId LIMIT 1];
        String workOrderId = '';        
        workOrderId = workOrderList[0].Opportunity.WorkOrder__c;
        String priceCurrency = '';      
        String pricebook = '';  

        List<WorkOrder> workOrderItem = [SELECT Id,CurrencyIsoCode,Pricebook2Id FROM WorkOrder WHERE Id =:workOrderId];
        System.debug('workOrderItem '+workOrderItem);
        if(workOrderItem.size()>0){
            priceCurrency = workOrderItem[0].CurrencyIsoCode;
            pricebook = workOrderItem[0].Pricebook2Id;
            System.debug('pricebook '+pricebook);

            responseMap.put('opprecord',workOrderList[0].Opportunity.recordType.Name);
            responseMap.put('oppId',workOrderList[0].Opportunity.Id);
            responseMap.put('oppStage',workOrderList[0].Opportunity.StageName);
            responseMap.put('hasWorkOrder',String.isNotBlank(workOrderList[0].Opportunity.WorkOrder__c));
            System.debug(workOrderId);
            System.debug(priceCurrency);

            Id priceId = [SELECT Pricebook2Id FROM WorkOrder WHERE Id =: workOrderId].Pricebook2Id;

            if(workOrderId != null && workOrderId != '') {
                Id priceBookId = [SELECT Pricebook2Id FROM WorkOrder WHERE Id =: workOrderId].Id;
                List<String> bodegasList = getBodegas(workOrderId);

                List<QuoteLineItem> quoteLineItemList = [
                    SELECT Product2Id,ListPrice,UnitPrice,BMW_Alias__c,
                           Product2.Codigo_de_Producto__c, Product2.Name,Product2.tipoProducto__c,
                           Quantity,BMW_Bodega__c,BMW_Bodega__r.Name,BMW_Dispinible__c,
                           CurrencyIsoCode,Enviado_a_la_orden__c,Discount,
                           Tarea__c, Tarea__r.Name, Categor_a_de_presupuesto__c
                      FROM QuoteLineItem
                     WHERE QuoteId =: quoteId
                ];
                    
                List<CurrencyType> moneda = [SELECT Id, ConversionRate FROM CurrencyType WHERE IsoCode = 'CRC']; 
                System.debug('Moneda Cambio' + moneda);
                Double tipoCambio = moneda[0].ConversionRate ;
                    
                List<Id> quoteLineProductIdsList = new List<Id>();
                for(QuoteLineItem quoteLineItem : quoteLineItemList) {
                    quoteLineProductIdsList.add(quoteLineItem.Product2Id);
                }
                System.debug('quoteLineProductIdsList ' + quoteLineProductIdsList);

                List<PricebookEntry> listPriceBook = [
                    SELECT Id,CurrencyIsoCode, Product2Id, Pricebook2Id
                      FROM PricebookEntry
                     WHERE Product2Id IN :quoteLineProductIdsList
                       AND Pricebook2Id = :pricebook
                ]; 
                System.debug('listPriceBook ' +listPriceBook);

                for (QuoteLineItem quoteLineItem : quoteLineItemList) {
                    System.debug('quoteLineItem ' + quoteLineItem);
                        
                    String pricebookEntryId;
                    System.debug('pricebookEntryId ' +pricebookEntryId);

                    String currencyCode;

                    for (PricebookEntry actualEntry : listPriceBook) {
                        System.debug('Moneda ' + priceCurrency);
                        System.debug('Moneda2 ' + quoteLineItem.CurrencyIsoCode);
                        if(quoteLineItem.Product2Id == actualEntry.Product2Id){
                            System.debug('entro ' );
                            pricebookEntryId = actualEntry.Id;
                            System.debug('pricebookEntryId2 ' +pricebookEntryId);

                            if(priceCurrency == quoteLineItem.CurrencyIsoCode){
                                currencyCode = priceCurrency;
                            }else {     
                                System.debug( quoteLineItem.CurrencyIsoCode + ' monedas '+ priceCurrency); 
                                System.debug('Tipo Cambio ' + tipoCambio);                                         
                                if(quoteLineItem.CurrencyIsoCode == 'USD' && priceCurrency =='CRC'){ 
                                    quoteLineItem.UnitPrice = quoteLineItem.UnitPrice * tipoCambio;
                                    System.debug('CRC ' + quoteLineItem.UnitPrice);
                                }else if(quoteLineItem.CurrencyIsoCode == 'CRC' && priceCurrency =='USD'){   
                                    quoteLineItem.UnitPrice = quoteLineItem.UnitPrice / tipoCambio;
                                    System.debug('USD ' + quoteLineItem.UnitPrice);
                                }
                                currencyCode = priceCurrency;
                            }
                        }
                    }
                    quoteLineItemsWrapper.add(new Wrapper(workOrderId,quoteLineItem,pricebookEntryId,currencyCode));                  
                }
            }
        }
        System.debug('quoteLineItemsWrapper: ' + quoteLineItemsWrapper);
        responseMap.put('items',quoteLineItemsWrapper);
        return responseMap;
    }

    @AuraEnabled(cacheable=false)
    public static Map<String,Object> changeCurrencygtQLIs(Id workOrder, Id quoteId){
        Map<String,Object> responseMap = new Map<String,Object>();
        List<Wrapper> quoteLineItemsWrapper = new List<Wrapper>();
        List<Quote> workOrderList = [SELECT Opportunity.WorkOrder__c,Opportunity.Id,Opportunity.StageName,Opportunity.recordType.Name FROM Quote WHERE Id =: quoteId LIMIT 1];
        String workOrderId = '';        
        workOrderId = workOrder;
        String priceCurrency = '';      
        String pricebook = '';  
        Boolean tieneReservados = false;

        List<WorkOrder> workOrderItem = [SELECT Id,CurrencyIsoCode,Pricebook2Id FROM WorkOrder WHERE Id =:workOrderId];
        if(workOrderItem.size()>0){
            List<WorkOrderLineItem> woliList = [Select Id,Estado_reserva__c From WorkOrderLineItem Where WorkOrderId =: workOrderId];
            if(woliList.size()>0){
                delete woliList;
            }
            pricebook = workOrderItem[0].Pricebook2Id;
            PriceBook2 pb1 = [Select Id, Name From PriceBook2 Where Id =:pricebook limit 1];
            String pricebookBusqueda = 'Bavarian Local';
            if(pb1.Name == 'Otobai Local'){
                pricebookBusqueda = 'Otobai Dólares	';
            }
            if(pb1.Name == 'Otobai Dólares'){
                pricebookBusqueda = 'Otobai Local';
            }
            if(pb1.Name == 'Bavarian Local'){
                pricebookBusqueda = 'Bavarian Dólar';
            }
            if(pb1.Name == 'Bavarian Dólar'){
                pricebookBusqueda = 'Bavarian Local';
            }
            System.debug('pricebookBusqueda '+pricebookBusqueda);
            Pricebook2 pb2 = [Select Id, Name From Pricebook2 Where Name =:pricebookBusqueda];
            workOrderItem[0].Pricebook2Id=pb2.Id;
            if(workOrderItem[0].CurrencyIsoCode == 'CRC'){
                workOrderItem[0].CurrencyIsoCode = 'USD';
            }
            else{
                workOrderItem[0].CurrencyIsoCode = 'CRC';
            }
            update workOrderItem;
            priceCurrency = workOrderItem[0].CurrencyIsoCode;
            pricebook = workOrderItem[0].Pricebook2Id;
                
            responseMap.put('opprecord',workOrderList[0].Opportunity.recordType.Name);
            responseMap.put('oppId',workOrderList[0].Opportunity.Id);
            responseMap.put('priceCurrency',priceCurrency);
            responseMap.put('oppStage',workOrderList[0].Opportunity.StageName);
            responseMap.put('hasWorkOrder',String.isNotBlank(workOrderList[0].Opportunity.WorkOrder__c));
            System.debug(workOrderId);
            System.debug(priceCurrency);

            Id priceId = [SELECT Pricebook2Id FROM WorkOrder WHERE Id =: workOrderId].Pricebook2Id;

            if(workOrderId != null && workOrderId != '') {
                responseMap.put('tieneReservados',tieneReservados);   
                Id priceBookId = [SELECT Pricebook2Id FROM WorkOrder WHERE Id =: workOrderId].Id;
                List<String> bodegasList = getBodegas(workOrderId);

                List<QuoteLineItem> quoteLineItemList = [
                    SELECT Product2Id,ListPrice,UnitPrice,BMW_Alias__c,
                           Product2.Codigo_de_Producto__c, Product2.Name,Product2.tipoProducto__c,
                           Quantity,BMW_Bodega__c,BMW_Bodega__r.Name,BMW_Dispinible__c,
                           CurrencyIsoCode,Enviado_a_la_orden__c,Discount,
                           Tarea__c, Tarea__r.Name, Categor_a_de_presupuesto__c
                      FROM QuoteLineItem
                     WHERE QuoteId =: quoteId
                ];
                    
                List<CurrencyType> moneda = [SELECT Id, ConversionRate FROM CurrencyType WHERE IsoCode = 'CRC']; 
                System.debug('Moneda Cambio' + moneda);
                Double tipoCambio = moneda[0].ConversionRate ;
                    
                List<Id> quoteLineProductIdsList = new List<Id>();
                for(QuoteLineItem quoteLineItem : quoteLineItemList) {
                    quoteLineProductIdsList.add(quoteLineItem.Product2Id);
                }

                // ⇩⇩⇩ FIX: declarar primero y luego hacer debug ⇩⇩⇩
                List<PricebookEntry> listPriceBook = [
                    SELECT Id,CurrencyIsoCode, Product2Id, Pricebook2Id
                      FROM PricebookEntry
                     WHERE Product2Id IN :quoteLineProductIdsList
                       AND Pricebook2Id = :pricebook
                ];
                System.debug(listPriceBook);
                // ⇧⇧⇧ FIN FIX ⇧⇧⇧

                for (QuoteLineItem quoteLineItem : quoteLineItemList) {
                    System.debug('quoteLineItem ' + quoteLineItem);
                        
                    String pricebookEntryId;
                    String currencyCode;

                    for (PricebookEntry actualEntry : listPriceBook) {
                        System.debug('Moneda ' + priceCurrency);
                        System.debug('Moneda2 ' + quoteLineItem.CurrencyIsoCode);
                        if(quoteLineItem.Product2Id == actualEntry.Product2Id){
                            System.debug('entro ' );
                            pricebookEntryId = actualEntry.Id;
                            if(priceCurrency == quoteLineItem.CurrencyIsoCode){
                                currencyCode = priceCurrency;
                            }else {     
                                System.debug( quoteLineItem.CurrencyIsoCode + ' monedas '+ priceCurrency); 
                                System.debug('Tipo Cambio ' + tipoCambio);                                         
                                if(quoteLineItem.CurrencyIsoCode == 'USD' && priceCurrency =='CRC'){     
                                    quoteLineItem.UnitPrice = quoteLineItem.UnitPrice * tipoCambio;
                                    System.debug('CRC ' + quoteLineItem.UnitPrice);
                                }else if(quoteLineItem.CurrencyIsoCode == 'CRC' && priceCurrency =='USD'){   
                                    quoteLineItem.UnitPrice = quoteLineItem.UnitPrice / tipoCambio;
                                    System.debug('USD ' + quoteLineItem.UnitPrice);
                                }
                                currencyCode = priceCurrency;
                            }
                        }
                    }
                    quoteLineItemsWrapper.add(new Wrapper(workOrderId,quoteLineItem,pricebookEntryId,currencyCode));                  
                }
            }
        }
        System.debug('quoteLineItemsWrapper: ' + quoteLineItemsWrapper);
        responseMap.put('items',quoteLineItemsWrapper);
        return responseMap;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String,Object> getQuoteLineItems(Id workOrder, Id quoteId){
        Map<String,Object> responseMap = new Map<String,Object>();
        List<Wrapper> quoteLineItemsWrapper = new List<Wrapper>();
        List<Quote> workOrderList = [SELECT Opportunity.WorkOrder__c,Opportunity.Id,Opportunity.StageName,Opportunity.recordType.Name FROM Quote WHERE Id =: quoteId LIMIT 1];
        String workOrderId = '';        
        workOrderId = workOrder;
        String priceCurrency = '';    
        String pricebook = '';  
        Boolean tieneReservados = false;

        List<WorkOrder> workOrderItem = [SELECT Id,CurrencyIsoCode,Pricebook2Id FROM WorkOrder WHERE Id =:workOrderId];
        System.debug('workOrderItem save '+workOrderItem);
        if(workOrderItem.size()>0){
            priceCurrency = workOrderItem[0].CurrencyIsoCode;
            pricebook = workOrderItem[0].Pricebook2Id;
            System.debug('save pricebook '+pricebook);

            responseMap.put('opprecord',workOrderList[0].Opportunity.recordType.Name);
            responseMap.put('oppId',workOrderList[0].Opportunity.Id);
            responseMap.put('priceCurrency',priceCurrency);
            responseMap.put('oppStage',workOrderList[0].Opportunity.StageName);
            responseMap.put('hasWorkOrder',String.isNotBlank(workOrderList[0].Opportunity.WorkOrder__c));
            System.debug(workOrderId);
            System.debug(priceCurrency);

            Id priceId = [SELECT Pricebook2Id FROM WorkOrder WHERE Id =: workOrderId].Pricebook2Id;

            if(workOrderId != null && workOrderId != '') {
                List<WorkOrderLineItem> woliList = [Select Id,Estado_reserva__c From WorkOrderLineItem Where WorkOrderId =: workOrderId];
                if(woliList.size()>0){
                    for(WorkOrderLineItem woli : woliList){
                        if(woli.Estado_reserva__c != null && woli.Estado_reserva__c != ''){
                            System.debug(woli.Id);
                            System.debug(woli.Estado_reserva__c);
                            tieneReservados = true;
                        }
                    }
                }
                responseMap.put('tieneReservados',tieneReservados);   
                Id priceBookId = [SELECT Pricebook2Id FROM WorkOrder WHERE Id =: workOrderId].Id;
                List<String> bodegasList = getBodegas(workOrderId);

                List<QuoteLineItem> quoteLineItemList = [
                    SELECT Product2Id,ListPrice,UnitPrice,BMW_Alias__c,
                           Product2.Codigo_de_Producto__c, Product2.Name,Product2.tipoProducto__c,
                           Quantity,BMW_Bodega__c,BMW_Bodega__r.Name,BMW_Dispinible__c,
                           CurrencyIsoCode,Enviado_a_la_orden__c,Discount,
                           Tarea__c, Tarea__r.Name, Categor_a_de_presupuesto__c
                      FROM QuoteLineItem
                     WHERE QuoteId =: quoteId
                ];
                    
                List<CurrencyType> moneda = [SELECT Id, ConversionRate FROM CurrencyType WHERE IsoCode = 'CRC']; 
                System.debug('Moneda Cambio' + moneda);
                Double tipoCambio = moneda[0].ConversionRate ;
                    
                List<Id> quoteLineProductIdsList = new List<Id>();
                for(QuoteLineItem quoteLineItem : quoteLineItemList) {
                    quoteLineProductIdsList.add(quoteLineItem.Product2Id);
                }
                System.debug('quoteLineProductIdsList ' + quoteLineProductIdsList);

                List<PricebookEntry> listPriceBook = [
                    SELECT Id,CurrencyIsoCode, Product2Id, Pricebook2Id
                      FROM PricebookEntry
                     WHERE Product2Id IN :quoteLineProductIdsList
                       AND Pricebook2Id = :pricebook
                ]; 
                System.debug(listPriceBook);

                for (QuoteLineItem quoteLineItem : quoteLineItemList) {
                    System.debug('quoteLineItem ' + quoteLineItem);
                        
                    String pricebookEntryId;
                    String currencyCode;

                    for (PricebookEntry actualEntry : listPriceBook) {
                        System.debug('Moneda ' + priceCurrency);
                        System.debug('Moneda2 ' + quoteLineItem.CurrencyIsoCode);
                        if(quoteLineItem.Product2Id == actualEntry.Product2Id){
                            System.debug('entro ' );
                            pricebookEntryId = actualEntry.Id;
                            if(priceCurrency == quoteLineItem.CurrencyIsoCode){
                                currencyCode = priceCurrency;
                            }else {     
                                System.debug( quoteLineItem.CurrencyIsoCode + ' monedas '+ priceCurrency); 
                                System.debug('Tipo Cambio ' + tipoCambio);                                         
                                if(quoteLineItem.CurrencyIsoCode == 'USD' && priceCurrency =='CRC'){     
                                    quoteLineItem.UnitPrice = quoteLineItem.UnitPrice * tipoCambio;
                                    System.debug('CRC ' + quoteLineItem.UnitPrice);
                                }else if(quoteLineItem.CurrencyIsoCode == 'CRC' && priceCurrency =='USD'){   
                                    quoteLineItem.UnitPrice = quoteLineItem.UnitPrice / tipoCambio;
                                    System.debug('USD ' + quoteLineItem.UnitPrice);
                                }
                                currencyCode = priceCurrency;
                            }
                        }
                    }
                    quoteLineItemsWrapper.add(new Wrapper(workOrderId,quoteLineItem,pricebookEntryId,currencyCode));                  
                }
            }
        }
        System.debug('quoteLineItemsWrapper: ' + quoteLineItemsWrapper);
        responseMap.put('items',quoteLineItemsWrapper);
        return responseMap;
    }

    public static List<Id> getBodegas(Id workOrderId) {
        List<BodegaxTerritorio__c> bodegas = [SELECT Bodega__c FROM BodegaxTerritorio__c WHERE ServiceTerritory__c IN (SELECT ServiceTerritoryId FROM WorkOrder WHERE Id =: workOrderId)];
        List<Id> bodegaIdList = new List<Id>();
        for(BodegaxTerritorio__c bodegaXTerritorio : bodegas){
            bodegaIdList.add(bodegaXTerritorio.Bodega__c);
        }
        return bodegaIdList;
    }

    public static Map<Id, Product2> getPriceEntriesBefore(Id workOrderId, Set<Id> productosXBodega){
        Id priceId = [SELECT Pricebook2Id FROM WorkOrder WHERE Id =: workOrderId].Pricebook2Id;
        Map<Id, Product2> productEntries = new Map<Id, Product2>([
            SELECT Id, 
                   (SELECT Id, UnitPrice, CurrencyIsoCode FROM Pricebookentries WHERE Pricebook2Id =: priceId LIMIT 1) 
              FROM Product2 
             WHERE Id IN (SELECT Product2Id FROM PricebookEntry WHERE Pricebook2Id =: priceId)
               AND Id IN (SELECT Producto__c FROM ProductoXBodega__c WHERE Id IN : productosXBodega )
             ORDER BY Id
        ]);
        System.debug('priceId' + priceId);
        system.debug('workOrderId' + workOrderId);        
        system.debug('productosXBodega' + productosXBodega);                                        
        system.debug('PRODUCT ENTRIES: ' + productEntries);
        return productEntries;                        
    }

    @AuraEnabled(cacheable=false)
    public static void saveWorkLineItems (String listTosave, Id workOrder,Id quoteId,Id oppId, Boolean enviarACaso) {
        String tipoTrabajoId = '123453452524525';
        System.debug('WorkLineItemsList: ' + listTosave);
        System.debug('WorkOrder: ' + workOrder);
        System.debug('tipoTrabajoId: ' + tipoTrabajoId);

        List<WorkOrderLineItem> workLineItems = new List<WorkOrderLineItem>();
        
        //Parámteros NO DINAMICOS indicados por Red Motors
        System.debug('Antes de mantenimiento');
        Id mantenimiento = [SELECT Id FROM tiposDeTrabajo__c WHERE Name = 'Mantenimiento' LIMIT 1].Id; //Quitando los mantenimientos temporalmente
        System.debug('Despues de mantenimiento');
        Id tax = [SELECT Id FROM Impuesto__c WHERE codigoImpuesto__c = '0108' LIMIT 1 ].Id;
        System.debug('Despues de Tax');
        String sugerido = 'Recomendado';

        List<QuoteLineItem> listaProds = [SELECT Id,Product2Id FROM QuoteLineItem WHERE QuoteId =:quoteId];

        List<QuoteLineItem> listaActProds = new List<QuoteLineItem>();

        List<Wrapper> wrappers = (List<Wrapper>)JSON.deserialize(listTosave,List<Wrapper>.class);
        System.debug('Despues de deserialize wrapper');

        //obtener total de horas
        Decimal totalHoras = 0;
        Boolean enviarCaso = false;
        Set<Id> qliIds = new Set<id>();
        Map<Id,Wrapper> wrappersMap = new Map<Id,Wrapper>();
        System.debug('wrappers '+wrappers);
        for (Wrapper wr : wrappers) {
            if(String.isNotBlank(tipoTrabajoId)) {
                enviarCaso = true;
                totalHoras += (wr.cantidad != null) ? wr.cantidad : 0; 
                wrappersMap.put(wr.wrapperId,wr);
            } 
            qliIds.add(wr.wrapperId);
            System.debug('wr.cantidad '+wr.cantidad);
            System.debug('wr.wrapperId '+wr.wrapperId);
            System.debug('wr.enCaso: ' + wr.enCaso);
        }
        System.debug('totalHoras ' +totalHoras);
        System.debug('wrappersMap ' +wrappersMap);
        System.debug('enviarCaso: ' + enviarCaso);

        List<WorkOrder> workOrders = [SELECT Id,CaseId FROM WorkOrder WHERE Id =: workOrder];
        if(workOrders.size()>0 && workOrders[0].CaseId == null) {
            throw new AuraHandledException('La order de trabajo no tiene un caso asignado, por favor contacte al administrador');
        }

        tiposDeTrabajoCaso__c newTTC;

        List<QuoteLineItem> trabajosARealizar = new List<QuoteLineItem>();
        List<tiposDeTrabajoCaso__c> listTrabajosARealizarNuevos = new List<tiposDeTrabajoCaso__c>();
        List<Subtipo_de_trabajo_del_caso__c> listSubtrabajosNuevos = new List<Subtipo_de_trabajo_del_caso__c>();
        
        Map<Id,WorkorderLineItem> wolisMapInserted = new Map<Id,WorkorderLineItem>();

        for (Wrapper wr : wrappers) {
            System.debug('objeto JSON:'+wr);
            System.debug('objeto JSON:'+ wr.discount);

            WorkOrderLineItem wl = new WorkOrderLineItem();                
            wl.WorkOrderId = workOrder;
            wl.Product__c = wr.productId;
            wl.PricebookEntryId = wr.pricebookEntry;
            System.debug('wr.pricebookEntry '+wr.pricebookEntry);

            //User insert in Grid//
            wl.Alias_Articulo__c = wr.alias;
            wl.aprobado__c = wr.aprobado;
            wl.Quantity = wr.cantidad;
            wl.porcentajeDescuento__c = (wr.discount);
            if(wr.tipoTrabajo == null) { wl.tiposDeTrabajo__c = mantenimiento; } else { wl.tiposDeTrabajo__c = wr.tipoTrabajo; }
            wl.Trabajo__c = wr.productType; //PROBAR
            wl.Impuesto__c = tax;
            System.debug('PRECIO VENTA--------------- ' + wr.precioVenta);
            wl.PrecioVenta__c = wr.precioVenta;
            wl.UnitPrice = wr.precioVenta;

            wl.TareaQuote__c = wr.tareaQuote; // si tu modelo guarda el nombre
            // Si tienes un lookup real a Tarea en WOLI, podrías usar:
            // wl.Tarea__c = wr.tareaId;

            wl.Prioridad_de_tarea__c = wr.prioridadTarea;

            if(wr.bodegaId != null) {
                wl.Bodega__c = wr.bodegaId;
            }
            wl.especificacionesTaller__c = sugerido;
            System.debug('objeto SF:' + wl);
            System.debug('Wrapper TareaId: ' + wr.tareaId);
            System.debug('Wrapper TareaQuote (Name): ' + wr.tareaQuote);

            workLineItems.add(wl);

            if(wr.enCaso != null && wr.enCaso){
                wolisMapInserted.put(wr.wrapperId,wl);
            }

            System.debug('WL: ' + wl);
        }

        for (WorkOrderLineItem wlItem : workLineItems) {
            for (QuoteLineItem quoteItem : listaProds) {
                if (wlItem.Product__c ==  quoteItem.Product2Id) {
                    quoteItem.Enviado_a_la_orden__c = true;
                }
            }
        }

        try {
            upsert listaProds;
        } catch (Exception e) {
            System.debug(e);
        }

        System.debug('@@@@@@@@@@@@@@@@@@'+workLineItems); 
        
        try {            
            upsert workLineItems;

            List<Subtipo_de_trabajo_del_caso__c> subtipoTrabajoCaso = new List<Subtipo_de_trabajo_del_caso__c>();

            if (subtipoTrabajoCaso.size() > 0 && !Test.isRunningTest()) {
                //insert subtipoTrabajoCaso;
            }

            Map<Id,Id> ManoDeObraIdWoliId = new Map<Id,Id>();
            List<WorkOrderLineItem> listWoliNews = [Select Id, Product__c From WorkOrderLineItem Where WorkOrderId =: workOrder];
            for(WorkOrderLineItem woli : listWoliNews){
                ManoDeObraIdWoliId.put(woli.Product__c,woli.Id);
            }

            trabajosARealizar = [
                Select Id,
                       TrabajoARealizar__c, TrabajoARealizar__r.Name, TrabajoARealizar__r.UTS__c, TrabajoARealizar__r.Cantidad__c,
                       TrabajoARealizar__r.ManoDeObra__r.Name, TrabajoARealizar__r.ManoDeObra__c,
                       SubTrabajoAlias__c, Quantity,
                       SubTrabajoARealizar__c, SubTrabajoARealizar__r.Name, SubTrabajoARealizar__r.UTS__c, SubTrabajoARealizar__r.Cantidad__c,
                       SubTrabajoARealizar__r.ManoDeObra__c, SubTrabajoARealizar__r.ManoDeObra__r.Name,
                       BMW_Alias__c, tipoCargo__c, Aprobador__c, UTS__c, Hora__c, HoraSubtrabajo__c, Categor_a_de_presupuesto__c 
                  From QuoteLineItem
                 Where QuoteId =:quoteId
                   AND TrabajoARealizar__c != null
                   AND Id IN :qliIds
            ];
            System.debug('qliIds '+qliIds);
            System.debug('quoteId '+quoteId);
            System.debug('trabajosARealizar '+trabajosARealizar);

            if(trabajosARealizar.size() >0 && enviarACaso){
                List<tiposDeTrabajoCaso__c> listTrabajosARealizarNuevosLoc = new List<tiposDeTrabajoCaso__c>();
                for(QuoteLineItem trabajo : trabajosARealizar){
                    if(trabajo.TrabajoARealizar__c == trabajo.SubTrabajoARealizar__c){
                        tiposDeTrabajoCaso__c trabajoARealizarNuevo = new tiposDeTrabajoCaso__c();
                        trabajoARealizarNuevo.Tipotrabajo__c = trabajo.TrabajoARealizar__c;
                        trabajoARealizarNuevo.RM_WorkOrder__c = workOrder;
                        trabajoARealizarNuevo.Caso__c = workOrders[0].caseId;
                        trabajoARealizarNuevo.Alias_Articulo__c = trabajo.BMW_Alias__c;
                        trabajoARealizarNuevo.Aprobador__c  = trabajo.Aprobador__c;
                        trabajoARealizarNuevo.UTS__c  = trabajo.Hora__c;
                        trabajoARealizarNuevo.Categor_a_de_presupuesto__c  = trabajo.Categor_a_de_presupuesto__c;
                        trabajoARealizarNuevo.Horaa__c   = trabajo.Hora__c;
                        trabajoARealizarNuevo.Tipo_de_cargo__c  = getCargo(trabajo.tipoCargo__c);
                        trabajoARealizarNuevo.UTS_Real__c = trabajo.UTS__c;
                        listTrabajosARealizarNuevosLoc.add(trabajoARealizarNuevo);
                    }
                }
                if(listTrabajosARealizarNuevosLoc.size()>0){
                    insert listTrabajosARealizarNuevosLoc;
                    List<Subtipo_de_trabajo_del_caso__c> listSubtrabajosNuevosLoc = new List<Subtipo_de_trabajo_del_caso__c>();
                    for(tiposDeTrabajoCaso__c trabajoCaso : listTrabajosARealizarNuevosLoc){
                        for(QuoteLineItem trabajo : trabajosARealizar){
                            if(trabajoCaso.Tipotrabajo__c == trabajo.TrabajoARealizar__c){
                                Subtipo_de_trabajo_del_caso__c subtrabajo = new Subtipo_de_trabajo_del_caso__c();
                                subtrabajo.Tipo_de_trabajo_del_caso__c = trabajoCaso.Id;
                                subtrabajo.TipoDeTrabajo__c = trabajo.SubTrabajoARealizar__c;
                                subtrabajo.Alias__c = trabajo.SubTrabajoAlias__c;
                                subtrabajo.Mano_de_Obra__c  = trabajo.SubTrabajoARealizar__r.ManoDeObra__c;
                                subtrabajo.Name = trabajo.SubTrabajoAlias__c != NULL ? trabajo.SubTrabajoAlias__c : trabajo.SubTrabajoARealizar__r.ManoDeObra__r.Name;
                                subtrabajo.Articulo_Mano_de_Obra__c = ManoDeObraIdWoliId.get(trabajo.SubTrabajoARealizar__r.ManoDeObra__c);
                                subtrabajo.UTS__c = trabajo.UTS__c;
                                subtrabajo.Cantidad_de_horas__c = trabajo.HoraSubtrabajo__c;
                                subtrabajo.Caso__c = workOrders[0].caseId;
                                subtrabajo.Orden_de_trabajo__c = workOrder;
                                listSubtrabajosNuevosLoc.add(subtrabajo);
                            }
                        }
                    }
                    insert listSubtrabajosNuevosLoc;
                }
            }        

            system.debug('workLineItems');
            List<Opportunity> oppList = [SELECT StageName FROM Opportunity WHERE Id =: oppId LIMIT 1];
            if (oppList.size()>0) {
                oppList[0].StageName = 'Cerrada Ganada';
                update oppList;
            }
            system.debug('oppList');
            List<Quote> quoteList = [SELECT Status FROM Quote WHERE Id =: quoteId LIMIT 1];
            if (quoteList.size()>0) {
                quoteList[0].Status = 'Accepted';
                update quoteList;
            }   
            system.debug('quoteList');
        } catch (DmlException e) {
            system.debug(e);
            throw new AuraHandledException(e.getMessage());
        }     
    }

    public static String getSubtrabajoName(String alias, String aliasGenerico) {
        if (alias != null && String.isNotBlank(alias)) {
            return alias.length() > 80 ? alias.substring(0, 80) : alias;
        } else if (aliasGenerico != null && aliasGenerico.length() > 8) {
            return aliasGenerico.length() > 80 ? aliasGenerico.substring(0, 80) : aliasGenerico;
        }
        return aliasGenerico;
    }

    public class Wrapper {
        //Product Query --> Service Territory
        @AuraEnabled public Id wrapperId;
        @AuraEnabled public Id workOrderId;
        @AuraEnabled public Id productId;
        @AuraEnabled public String productCode;
        @AuraEnabled public String name;
        @AuraEnabled public decimal price;
        @AuraEnabled public String productType;

        //Service territory
        @AuraEnabled public String bodega;
        @AuraEnabled public String bodegaId;
        @AuraEnabled public decimal cantidadDisponible;

        //WorkOrderLineItem insert
        @AuraEnabled public String alias;
        @AuraEnabled public double cantidad;
        @AuraEnabled public double precioVenta;
        @AuraEnabled public String tareaQuote { get; set; }
        @AuraEnabled public String prioridadTarea { get; set; }

        @AuraEnabled public Id tareaId;
        @AuraEnabled public String tareaName;

        //Otros
        @AuraEnabled public Boolean aprobado;
        @AuraEnabled public String tipoTrabajo;
        @AuraEnabled public String trabajo;
        @AuraEnabled public decimal discount;
        @AuraEnabled public String tax;
        @AuraEnabled public String pricebookEntry;
        @AuraEnabled public String currencyCode;
        @AuraEnabled public String currencyCodeProd;
        @AuraEnabled public Boolean enOrden;
        @AuraEnabled public Boolean enCaso;
        @AuraEnabled public String tipoTrabajoId;
        @AuraEnabled public String tipoTrabajoCasoId;
        @AuraEnabled public String productURL;

        public Wrapper(){}
        
        public Wrapper(Id workOrderId, QuoteLineItem quoteLineItem, String pricebookEntry, String currencyCode){
            this.workOrderId = workOrderId; 
            this.enCaso = false;
            this.tipoTrabajoId = null;
            this.tipoTrabajoCasoId = null;

            this.enOrden = (quoteLineItem != null) ? quoteLineItem.Enviado_a_la_orden__c : null;      
            this.wrapperId = (quoteLineItem != null) ? quoteLineItem.Id : null;         
            this.productId = (quoteLineItem != null) ? quoteLineItem.Product2Id : null; 
            this.productURL = (quoteLineItem != null) ? '/lightning/r/Product2/'+quoteLineItem.Product2Id+'/view' : null;
            this.productCode = (quoteLineItem != null) ? quoteLineItem.Product2.Codigo_de_Producto__c : ''; 
            this.name = (quoteLineItem != null) ? quoteLineItem.Product2.Name : ''; 
            this.price = (quoteLineItem != null) ? quoteLineItem.ListPrice : 0; 
            this.precioVenta = (quoteLineItem != null) ? quoteLineItem.UnitPrice : 0; 
            this.productType = (quoteLineItem != null) ? quoteLineItem.Product2.tipoProducto__c : ''; 
            this.bodega = (quoteLineItem != null && quoteLineItem.BMW_Bodega__r.Name != null) ? quoteLineItem.BMW_Bodega__r.Name : '-';
            this.bodegaId = (quoteLineItem != null && quoteLineItem.BMW_Bodega__c != null) ? quoteLineItem.BMW_Bodega__c : null;
            
            if(quoteLineItem != null && quoteLineItem.Product2.tipoProducto__c == 'Mano de Obra') {
                this.cantidadDisponible = 1;
            }
            this.alias = (quoteLineItem != null) ? quoteLineItem.BMW_Alias__c : ''; 
            this.cantidad = (quoteLineItem != null) ? quoteLineItem.Quantity : 0.0; 
            this.aprobado = true; 
            this.tipoTrabajo = null; 
            this.discount = (quoteLineItem != null) ? quoteLineItem.Discount : 0; 
            this.pricebookEntry = (pricebookEntry != null) ? pricebookEntry : null ; 
            this.currencyCode = currencyCode;
            this.currencyCodeProd = (quoteLineItem != null && quoteLineItem.CurrencyIsoCode != null) ? quoteLineItem.CurrencyIsoCode : '';

            // Datos de Tarea
            this.tareaId   = (quoteLineItem != null) ? quoteLineItem.Tarea__c : null;
            this.tareaName = (quoteLineItem != null && quoteLineItem.Tarea__r != null) ? quoteLineItem.Tarea__r.Name : null;
            this.tareaQuote = (quoteLineItem != null && quoteLineItem.Tarea__r != null) ? quoteLineItem.Tarea__r.Name : null;

            this.prioridadTarea = (quoteLineItem != null && quoteLineItem.Categor_a_de_presupuesto__c != null) ? quoteLineItem.Categor_a_de_presupuesto__c : null;
        }
    }
}