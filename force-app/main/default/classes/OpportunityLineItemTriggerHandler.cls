public without sharing class OpportunityLineItemTriggerHandler extends TriggerHandler {
    
    private Map<Id, OpportunityLineItem> newRecordMap;
    private List<OpportunityLineItem> newRecordList;
    
    private Map<Id, OpportunityLineItem> oldRecordMap;
    private List<OpportunityLineItem> oldRecordList;

    public static Boolean isUpdateOpportunityProductNameRun = false;
    /** Evita una actualización intermedia de Opportunity durante reemplazos de productos. */
    public static Boolean bypassDeleteFieldUpdate = false;
    
    public OpportunityLineItemTriggerHandler() {
        this.newRecordMap = (Map<Id, OpportunityLineItem>) Trigger.newMap;
        this.newRecordList = (List<OpportunityLineItem>) Trigger.New;
        this.oldRecordMap = (Map<Id, OpportunityLineItem>) Trigger.oldMap;
        this.oldRecordList = (List<OpportunityLineItem>) Trigger.Old;
    }
    
    public override void afterInsert(){       
        List<Opportunity> ops = Util.actualizaAprobador(newRecordList);
        //List<Trigger_control__c> triggerControlList = [SELECT id,Turned_off__c,Name FROM Trigger_control__c WHERE Name = 'aprobacion de descuentos' ];
        List<TriggerControl__mdt> triggerControlList = [SELECT MasterLabel,Turned_off__c FROM TriggerControl__mdt WHERE MasterLabel	 = 'aprobacion de descuentos'];

        List<Opportunity> listOp = new List<Opportunity>();
        List<Id> productIds = new List<Id>();
        String idOp;
        Integer accion = 1;
        
        if(ops!=null && ops.size()>0  && triggerControlList.size()>0 && triggerControlList[0].Turned_Off__c == true){
            update ops;
        }

        for(OpportunityLineItem oppT : newRecordList){
            productIds.add(oppT.Product2Id);
            idOp = oppT.OpportunityId;
        }
        util.updateFieldOp(productIds, idOp);
        
        listOp = [SELECT OFCreada__c FROM Opportunity WHERE Id =: newRecordList[0].OpportunityId ];
        if(listOp.size() > 0 && listOp[0].OFCreada__c){
            OpportunityLineItemService.actualizarProductosOF(newRecordList[0].OpportunityId, accion, '');
        }

        updateOpportunityProductName(
            newRecordMap,
            null,
            extractOppIds(newRecordMap)
        );
    }
    
    public override void afterUpdate(){
        // updateUnitPrice();

        //List<Trigger_control__c> triggerControlList = [SELECT id,Turned_off__c,Name FROM Trigger_control__c WHERE Name = 'aprobacion de descuentos'];
        List<TriggerControl__mdt> triggerControlList = [SELECT MasterLabel,Turned_off__c FROM TriggerControl__mdt WHERE MasterLabel	 = 'aprobacion de descuentos'];
		List<OpportunityLineItem> olisWithUnitPriceChanges = new List<OpportunityLineItem>();
        for(OpportunityLineItem oli : newRecordList) {
        	OpportunityLineItem oldOli = oldRecordMap.get(oli.Id);
        	if(oli.UnitPrice != oldOli.UnitPrice) {
            	olisWithUnitPriceChanges.add(oli);
        	}
   		}
        List<Opportunity> ops = new List<Opportunity>();
        if(olisWithUnitPriceChanges.size()>0){
       		ops = Util.actualizaAprobador(newRecordList);
        }
        List<Opportunity> listOp = new List<Opportunity>();
        Integer accion = 2;
        
        if(ops.size()>0){
            Opportunity opp2 = [SELECT Id, stageName FROM Opportunity WHERE Id =: ops[0].Id  LIMIT 1 ];
            System.debug('ops[0] '+ops[0]);
                        System.debug('ops[0]1 '+ops[0].stageName);
                        System.debug('ops[2] '+opp2.StageName);

            if(opp2.stageName == 'Cerrada Ganada'){
                ops = null;
            }
        }
        if(ops!=null&&ops.size()>0 && triggerControlList.size()>0 && triggerControlList[0].Turned_off__c == true){
            update ops;
        }
        
        System.debug('****************' + newRecordList);
        listOp = [SELECT OFCreada__c FROM Opportunity WHERE Id =: newRecordList[0].OpportunityId];
        if(listOp.size() > 0 && listOp[0].OFCreada__c){
            OpportunityLineItemService.actualizarProductosOF(newRecordList[0].OpportunityId, accion, newRecordList[0].Id);
        }

        Set<Id> oppIds = new Set<Id>();
        for (OpportunityLineItem oli : newRecordList) {
            if(oli.Reservado__c == false){
            	oppIds.add(oli.OpportunityId);
            }
        }
        if (oppIds.size() > 0) {
            actualizarTotalesVN(oppIds);
        }

        Set<Id> oppIdsDetalle = new Set<Id>();
        for (OpportunityLineItem oli : newRecordList) {
            OpportunityLineItem oldOli = oldRecordMap.get(oli.Id);
            if (oli.Quantity != oldOli.Quantity || oli.UnitPrice != oldOli.UnitPrice || oli.Product2Id != oldOli.Product2Id) {
                oppIdsDetalle.add(oli.OpportunityId);
            }
        }
        if (!isUpdateOpportunityProductNameRun || !oppIdsDetalle.isEmpty()) {
            updateOpportunityProductName(newRecordMap, oldRecordMap, oppIdsDetalle);
        }
    }
    
    /**
    * @description Actualiza totales de descuento (Monto y Porcentaje a nivel de la oportunidad)
    * @author marcohernandezhp@gmail.com | 05-11-2023 
    * @param oppIds Ids de la oportunidad
    **/
    @future
    public static void actualizarTotalesVN(Set<Id> oppIds) {        
        List<Opportunity> oppList = [SELECT Id, VN_Descuento_Aplicado_Monto__c,VN_Descuento_Aplicado_Porcentaje__c, (SELECT Id,VN_Descuento_Aplicado_Monto_FX__c,VN_Descuento_Aplicado_Porcentaje_FX__c FROM OpportunityLineItems) FROM Opportunity WHERE Id IN:oppIds ];

        for (Opportunity opp : oppList) {
            Decimal totalDescuentoMonto = 0;
            Decimal totalDescuentoPorcentaje = 0;            
            for (OpportunityLineItem oli : opp.OpportunityLineItems) {
                totalDescuentoMonto += oli.VN_Descuento_Aplicado_Monto_FX__c;
                totalDescuentoPorcentaje += oli.VN_Descuento_Aplicado_Porcentaje_FX__c;
            }
            opp.VN_Descuento_Aplicado_Monto__c = totalDescuentoMonto;
            opp.VN_Descuento_Aplicado_Porcentaje__c = totalDescuentoPorcentaje;
        }
        if (oppList.size() > 0) {
            update oppList;
        }
    }

    public override void afterDelete(){
        List<Opportunity> listOp = new List<Opportunity>();
        List<OpportunityLineItem> listProd = new List<OpportunityLineItem>();
        String idOp;
        Integer accion = 3;
        
        for(OpportunityLineItem oppT : oldRecordList){
            idOp = oppT.OpportunityId;
        }
        if (!bypassDeleteFieldUpdate) {
            util.updateFieldOp(idOp);
        } else {
            System.debug(LoggingLevel.DEBUG, '[WALKING_OJ] Se omite Util.updateFieldOp durante reemplazo. Opportunity=' + idOp);
        }
        
        listOp = [SELECT OFCreada__c, (SELECT Id, Name FROM OpportunityLineItems) FROM Opportunity WHERE Id =: oldRecordList[0].OpportunityId ];
        for(Opportunity op : listOp){
            for(OpportunityLineItem prod : op.OpportunityLineItems){
                listProd.add(prod);
            }
        }
        System.debug('******* listProd size ***** ' + listProd.size());
        if(listOp.size() > 0 && listOp[0].OFCreada__c){
            System.debug('entra al metodo');
            OpportunityLineItemService.actualizarProductosOF(oldRecordList[0].OpportunityId, accion, '');
        }

        Set<Id> oppIds = new Set<Id>();
        for (OpportunityLineItem oli : oldRecordList) {
            oppIds.add(oli.OpportunityId);
        }
        if (oppIds.size() > 0) {
            actualizarTotalesVN(oppIds);
        }

        OpportunityDetalleProductosService.actualizarDetalle(oppIds);
    }  

    public override void afterUndelete(){
        OpportunityDetalleProductosService.actualizarDetalle(extractOppIds(newRecordMap));
    }
    
    public override void beforeDelete(){

    // Obtener los Product2 relacionados
    Set<Id> productIds = new Set<Id>();
    for (OpportunityLineItem oli : oldRecordList) {
        productIds.add(oli.Product2Id);
    }

    Map<Id, Product2> productMap = new Map<Id, Product2>(
        [SELECT Id, Producto_Reservado__c, OportunidadReserva__c 
         FROM Product2 
         WHERE Id IN :productIds]
    );

    for (OpportunityLineItem oli : oldRecordList) {

        Product2 prod = productMap.get(oli.Product2Id);

        if (prod != null && 
            prod.Producto_Reservado__c == true &&
            prod.OportunidadReserva__c == oli.OpportunityId) {

            oli.addError('Para eliminar la línea, por favor primero elimine la reserva del vehículo.');
        }
    }
}

    
    public override void beforeInsert(){
        string produId ='';
        for(OpportunityLineItem oppT : newRecordList){
            produId = oppT.Product2Id;
        }
        //List<Opportunity> opp = [SELECT Id,Name FROM Opportunity WHERE Id =: newRecordList[0].OpportunityId];
        List<Product2> prod = [SELECT Id,Name FROM Product2 WHERE Id =:produId ];
        //List<OpportunityLineItem> oppItem = [SELECT Id,Product2.Name,CreatedDate FROM OpportunityLineItem WHERE Id =: newRecordList[0].ID order by CreatedDate Desc];
        Opportunity opp1 = new Opportunity();
        opp1.Id = newRecordList[0].OpportunityId;
        //opp1.NombreProducto__c = prod[0].Name;

        update opp1;

        Set<Id> oppIds = new Set<Id>();
        for (OpportunityLineItem oli : newRecordList) {
            oppIds.add(oli.OpportunityId);
        }
        if (oppIds.size() > 0) {
            actualizarTotalesVN(oppIds);
        }        
    }

    // public void updateUnitPrice(){
    //     List<QuoteLineItem> qliToUpdate = new List<QuoteLineItem>();
    //     for (OpportunityLineItem oli : newRecordList) {
    //         if (oli.UnitPrice != oldRecordMap.get(oli.Id).UnitPrice && oli.Quote_Line_Item__c != null) {
    //             QuoteLineItem qli = new QuoteLineItem(
    //                 Id = oli.Quote_Line_Item__c,
    //                 UnitPrice = oli.UnitPrice
    //             );
    //             qliToUpdate.add(qli);
    //         }
    //     }
    //     if (qliToUpdate.size()>0) {
    //         update qliToUpdate;
    //     }
    // }

    private Set<Id> extractOppIds(Map<Id, OpportunityLineItem> newMap) {
        Set<Id> oppIds = new Set<Id>();
        for (OpportunityLineItem oli : newMap.values()) {
            oppIds.add(oli.OpportunityId);
        }
        return oppIds;
    }

    //obtener los ids de los vehiculos
    private Set<Id> getVehiculoIds(Map<Id, OpportunityLineItem> recordMap) {
        Set<Id> vehiculoIds = new Set<Id>();
        for (OpportunityLineItem oli : recordMap.values()) {
                vehiculoIds.add(oli.Product2Id);
        }
        return vehiculoIds;
    }

    public void updateOpportunityProductName(Map<Id, OpportunityLineItem> newMap, Map<Id, OpportunityLineItem> oldMap) {
        Set<Id> opportunityIdsDetalle = newMap != null
            ? extractOppIds(newMap)
            : extractOppIds(oldMap);
        updateOpportunityProductName(newMap, oldMap, opportunityIdsDetalle);
    }

    private void updateOpportunityProductName(
        Map<Id, OpportunityLineItem> newMap,
        Map<Id, OpportunityLineItem> oldMap,
        Set<Id> opportunityIdsDetalle
    ) {
        Boolean actualizarNombreProducto = !isUpdateOpportunityProductNameRun;

        //obtener los ids de los vehiculos
        Set<Id> vehiculoIds =  new Set<Id>();

        Map<Id, OpportunityLineItem> recordMap;

        // Identify Opportunity IDs affected
        Set<Id> opportunityIds = new Set<Id>();
        if (newMap != null) {
            opportunityIds.addAll(extractOppIds(newMap));
            if (actualizarNombreProducto) {
                vehiculoIds.addAll(getVehiculoIds(newMap));
            }
            recordMap = newMap;
        }

        if (oldMap != null) {
            opportunityIds.addAll(extractOppIds(oldMap));
            if (actualizarNombreProducto) {
                vehiculoIds.addAll(getVehiculoIds(oldMap));
            }
            recordMap = oldMap;
        }

        //ir por los productos que son vehiculos
        Map<Id,Product2> vehiculoMap = new Map<Id,Product2>();
        if (actualizarNombreProducto) {
            vehiculoMap = new Map<Id,Product2>([SELECT Id,Name,esVehiculo__c,es_Vehiculo_usado__c,Modelo_De_Inter_s__c,modelo__c FROM Product2 WHERE Id IN :vehiculoIds]);
        }

        // Query OpportunityLineItems and concatenate Names
        Map<Id, String> oppIdToProductName = new Map<Id, String>();
        Set<Id> idsSetOpps = new Set<Id>();
        Map<Id, String> oppIdStageName = new Map<Id, String>();
        // List<OpportunityLineItem> opplineitems = [SELECT Id, Name,Product2.modelo__c,Product2.Name,OpportunityId FROM OpportunityLineItem WHERE OpportunityId IN :opportunityIds AND (Product2.esVehiculo__c=true OR Product2.es_Vehiculo_usado__c = true)];
        
        Set<String> modelos = new Set<String>();
        if (actualizarNombreProducto) {
            for(Product2 product2 : vehiculoMap.values()){
                if (product2.esVehiculo__c) {
                    modelos.add(product2.modelo__c);
                }
            }
        }

        System.debug('modelos:'+modelos);

        List<Product2> productosFantasia = new List<Product2>();
        if (actualizarNombreProducto && !modelos.isEmpty()) {
            productosFantasia = [SELECT Id,Name,Modelo_De_Inter_s__c FROM Product2 WHERE Modelo_De_Inter_s__c IN :modelos AND Modelo_De_Inter_s__c != null AND Product2.esVehiculo__c = false];
        }
        
        System.debug('productosFantasia:'+productosFantasia);

        Map<String, String> modeloNombreProductoFantasiaMap = new Map<String, String>();
        for (Product2 productoFantasia : productosFantasia) {
            //modeloNombreProductoFantasiaMap.put(productoFantasia.Modelo_De_Inter_s__c, productoFantasia.Name);
            modeloNombreProductoFantasiaMap.put(productoFantasia.Modelo_De_Inter_s__c.toLowerCase(), productoFantasia.Name);
        }
        
        System.debug('modeloNombreProductoFantasiaMap:'+modeloNombreProductoFantasiaMap);

        if (actualizarNombreProducto) {
            for (OpportunityLineItem oli : recordMap.values()) {
                idsSetOpps.add(oli.OpportunityId);
                if (!oppIdToProductName.containsKey(oli.OpportunityId)) {
                    oppIdToProductName.put(oli.OpportunityId, '');
                }

                String productName = '';

                //Product2 base
                Product2 product2 = vehiculoMap.get(oli.Product2Id);

                //Es vehiculo de rebeca
                if ((product2.Modelo_De_Inter_s__c != null && !product2.esVehiculo__c) || product2.es_Vehiculo_usado__c) {
                    productName = product2.Name;
                }else if (product2.esVehiculo__c) {
                    String modelo = product2.modelo__c;
                    //productName = modeloNombreProductoFantasiaMap.get(modelo);
                    productName = modeloNombreProductoFantasiaMap.get(product2.modelo__c.toLowerCase());

                }

                if (String.isNotBlank(productName)) {
                    String existingProductName = oppIdToProductName.get(oli.OpportunityId);
                    existingProductName = existingProductName + (String.isNotBlank(existingProductName) ? ',' : '') + productName;
                    
                    oppIdToProductName.put(oli.OpportunityId, existingProductName);
                }
            }
        }

        System.debug('oppIdToProductName:'+oppIdToProductName);

        // Update Opportunities
        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
        Map<Id,String> oppIdNombreProducto = new Map<Id,String>();
        List<Opportunity> listoppToUpdate = [
            SELECT Id, NombreProducto__c, StageName, Detalle_de_Productos__c, CurrencyIsoCode,
                   (SELECT Id, Name, Quantity, UnitPrice, Product2.Name
                    FROM OpportunityLineItems
                    ORDER BY CreatedDate ASC)
            FROM Opportunity
            WHERE Id IN :opportunityIds
        ];
        for(Opportunity opp : listoppToUpdate){
            oppIdNombreProducto.put(opp.Id,opp.NombreProducto__c);
            oppIdStageName.put(opp.Id,opp.StageName);
        }
        for (Id oppId : oppIdToProductName.keySet()) {
            if(oppIdStageName.get(oppId) != 'Cerrada Ganada'){
                String productName = oppIdToProductName.get(oppId).trim();
                if (productName.length() >= 255) {
                    productName = productName.substring(0, 252) + '...';
                }
                if(productName != oppIdNombreProducto.get(oppId)){
                    Opportunity opp = new Opportunity(Id = oppId, NombreProducto__c = productName);
                    opportunitiesToUpdate.add(opp);
                }
            }
        }

        OpportunityDetalleProductosService.integrarDetalle(
            opportunityIdsDetalle,
            listoppToUpdate,
            opportunitiesToUpdate
        );
        
        if (opportunitiesToUpdate.size() > 0) {
            update opportunitiesToUpdate;
        }
        System.debug('opportunitiesToUpdate:'+opportunitiesToUpdate);

        isUpdateOpportunityProductNameRun = true;
        
        
        
  
    }
     
}
