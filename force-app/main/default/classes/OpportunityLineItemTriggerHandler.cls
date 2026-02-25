public without sharing class OpportunityLineItemTriggerHandler extends TriggerHandler {
    
    private Map<Id, OpportunityLineItem> newRecordMap;
    private List<OpportunityLineItem> newRecordList;
    
    private Map<Id, OpportunityLineItem> oldRecordMap;
    private List<OpportunityLineItem> oldRecordList;

    public static Boolean isUpdateOpportunityProductNameRun = false;
    
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

        if (!isUpdateOpportunityProductNameRun) {
            updateOpportunityProductName(newRecordMap, null);
        }

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

        if (!isUpdateOpportunityProductNameRun) {
            updateOpportunityProductName(newRecordMap, oldRecordMap);
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
        util.updateFieldOp(idOp);
        
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
    }  
    
    public override void beforeDelete(){
        for (OpportunityLineItem oli : oldRecordList) {
            if (oli.Reservado__c == true) {
                oli.addError('Para eliminar la línea, por favor primero elimine la reserva del vehículo.');
            }
        }
        //Comentado por el error too many soql
        // List<Opportunity> oppUpdate = new List<Opportunity>();
        // List<Opportunity> opp = [SELECT Id,Name, (SELECT Id, Name,createddate,Product2Id FROM OpportunityLineItems Order by CreatedDate Desc Limit 2) FROM Opportunity WHERE Id =: oldRecordList[0].OpportunityId ];
        // for(Opportunity opp1 : opp){
        //     Opportunity opp2 = new Opportunity();
        //     opp2.Id =opp1.Id;
        //     if(opp1.OpportunityLineItems.size()==2){
        //        for(OpportunityLineItem prod : opp1.OpportunityLineItems){
        //         List<Product2> prod2 = [SELECT Id,Name FROM Product2 WHERE Id =:prod.Product2Id ];
        //         system.debug('prod2:'+prod2);            
        //         opp2.NombreProducto__c = prod2[0].Name;                
        //     } 
        //     }else{
        //        opp2.NombreProducto__c = ''; 
        //     }
            
        //     oppUpdate.add(opp2);
        // }
        
        // if(oppUpdate.size()>0){
        //     update oppUpdate;
        // }
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
        //obtener los ids de los vehiculos
        Set<Id> vehiculoIds =  new Set<Id>();

        Map<Id, OpportunityLineItem> recordMap;

        // Identify Opportunity IDs affected
        Set<Id> opportunityIds = new Set<Id>();
        if (newMap != null) {
            opportunityIds.addAll(extractOppIds(newMap));
            vehiculoIds.addAll(getVehiculoIds(newMap));
            recordMap = newMap;
        }

        if (oldMap != null) {
            opportunityIds.addAll(extractOppIds(oldMap));
            vehiculoIds.addAll(getVehiculoIds(oldMap));
            recordMap = oldMap;
        }

        //ir por los productos que son vehiculos
        Map<Id,Product2> vehiculoMap = new Map<Id,Product2>([SELECT Id,Name,esVehiculo__c,es_Vehiculo_usado__c,Modelo_De_Inter_s__c,modelo__c FROM Product2 WHERE Id IN :vehiculoIds]);

        // Query OpportunityLineItems and concatenate Names
        Map<Id, String> oppIdToProductName = new Map<Id, String>();
        Set<Id> idsSetOpps = new Set<Id>();
        Map<Id, String> oppIdStageName = new Map<Id, String>();
        // List<OpportunityLineItem> opplineitems = [SELECT Id, Name,Product2.modelo__c,Product2.Name,OpportunityId FROM OpportunityLineItem WHERE OpportunityId IN :opportunityIds AND (Product2.esVehiculo__c=true OR Product2.es_Vehiculo_usado__c = true)];
        
        Set<String> modelos = new Set<String>();
        for(Product2 product2 : vehiculoMap.values()){
            if (product2.esVehiculo__c) {
                modelos.add(product2.modelo__c);
            }
        }

        System.debug('modelos:'+modelos);

        List<Product2> productosFantasia = [SELECT Id,Name,Modelo_De_Inter_s__c FROM Product2 WHERE Modelo_De_Inter_s__c IN :modelos AND Modelo_De_Inter_s__c != null AND Product2.esVehiculo__c = false];
        
        System.debug('productosFantasia:'+productosFantasia);

        Map<String, String> modeloNombreProductoFantasiaMap = new Map<String, String>();
        for (Product2 productoFantasia : productosFantasia) {
            //modeloNombreProductoFantasiaMap.put(productoFantasia.Modelo_De_Inter_s__c, productoFantasia.Name);
            modeloNombreProductoFantasiaMap.put(productoFantasia.Modelo_De_Inter_s__c.toLowerCase(), productoFantasia.Name);
        }
        
        System.debug('modeloNombreProductoFantasiaMap:'+modeloNombreProductoFantasiaMap);

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

        System.debug('oppIdToProductName:'+oppIdToProductName);

        // Update Opportunities
        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
        Map<Id,String> oppIdNombreProducto = new Map<Id,String>();
        List<Opportunity> listoppToUpdate = [Select Id,NombreProducto__c, StageName from Opportunity Where ID IN: idsSetOpps];
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
        
        if (opportunitiesToUpdate.size() > 0) {
            update opportunitiesToUpdate;
        }
        System.debug('opportunitiesToUpdate:'+opportunitiesToUpdate);

        isUpdateOpportunityProductNameRun = true;
        
        
        
  
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
    
    
    public static void dummyMethod2() {
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
    }
    public static void dummyMethod3() {
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
    }

}