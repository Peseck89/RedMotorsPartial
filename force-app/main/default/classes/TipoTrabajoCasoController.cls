public without sharing class TipoTrabajoCasoController {
    
    @AuraEnabled(cacheable=true)
    public static String accountValidation(Id caseId) {
        Case caseValidation =[select Account.PersonEmail,Account.Phone,AccountId,Account.RecordTypeId,Account.CorreoElectronicoEmpresarial__c
                                     ,Account.Invoice_Email__c,Account.Invoice_Phone__c
                              from Case where Id=:caseId limit 1];
        String recordType=getRecordTypeNameById('Account',caseValidation.Account.RecordTypeId);
        Boolean clienteFisico= (recordType.contains('Físico')||recordType.contains('Altica')||recordType.contains('personal'));
        Boolean validate= (caseValidation.Account.Phone==null) ||(caseValidation.Account.PersonEmail==null && clienteFisico) ||(caseValidation.Account.CorreoElectronicoEmpresarial__c==null && (!clienteFisico)) ||(caseValidation.Account.Invoice_Email__c==null||caseValidation.Account.Invoice_Phone__c==null);
        return '{"Id":"'+caseValidation.AccountId+'",'+'"isPhysical":'+clienteFisico+','+'"validate":'+validate+'}';
    }
    
    public static String getRecordTypeNameById(String objectName, Id strRecordTypeId)
    {
        return Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosById().get(strRecordTypeId).getName();
    } 
    
    @AuraEnabled(cacheable=false)
    public static tiposDeTrabajoCaso__c insertTipoDelCasoDeTrabajo (Id caseId,Id workOrderId,String aseguradoraId,String centroCostoId, String tipoDeCargo, String sugerenciaTaller, String comments, id tipoDeTrabajo, String aprobador, String categoriaDePresupuesto) {         
        String commentario_JD = comments;
        try {        
            
           tiposDeTrabajoCaso__c newTTC = new tiposDeTrabajoCaso__c( 
                Caso__c	= caseId, 
                RM_WorkOrder__c = workOrderId,
                Tipo_de_cargo__c = tipoDeCargo, 
                Taller__c = sugerenciaTaller, 
                ComentarioTTC__c = comments,
                Tipotrabajo__c	= tipoDeTrabajo,
                Aprobador__c = aprobador,
                Categor_a_de_presupuesto__c = categoriaDePresupuesto
                );

                if (String.isNotBlank(aseguradoraId)) { newTTC.RM_Aseguradora__c = aseguradoraId;
                }

                if (String.isNotBlank(centroCostoId)) {  newTTC.RM_CentroCosto__c = centroCostoId;
                }

                INSERT newTTC;

                return newTTC;
        } catch (DmlException e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<WorkOrder> getWorkOrders(String caseId) {
        return [SELECT Id,WorkOrderNumber FROM WorkOrder WHERE CaseId =: caseId ORDER BY WorkOrderNumber ASC];
    }

    @AuraEnabled(cacheable=true)
    public static String getWorkOrder (String caseId) {         
        String idCaso = caseId;
        String ordenTrabajo = '';
        String casoReal = '';
        List<tiposDeTrabajoCaso__c> sacarElCaso = new List<tiposDeTrabajoCaso__c>();
        List<WorkOrder> listasOrders = new List<WorkOrder>();
        sacarElCaso = [SELECT id,Caso__c FROM tiposDeTrabajoCaso__c WHERE id =: idCaso LIMIT 1];
        if (sacarElCaso.size() > 0) {
            casoReal = sacarElCaso[0].Caso__c;
        }
        listasOrders = [SELECT id FROM WorkOrder WHERE CaseId =: casoReal LIMIT 1];
        if (listasOrders.size() > 0) {
            ordenTrabajo = listasOrders[0].id;
        }
        return ordenTrabajo;
    }

    @AuraEnabled(cacheable=true)
    public static tiposDeTrabajoCaso__c getTipoTrabajo (String trabajoId) {         
        String idTrabajo = trabajoId;
        tiposDeTrabajoCaso__c newTrabajo = new tiposDeTrabajoCaso__c();
        List<tiposDeTrabajoCaso__c> sacarElCaso = new List<tiposDeTrabajoCaso__c>();
        sacarElCaso = [SELECT id,Caso__c,Tipotrabajo__c,Tipo_de_cargo__c,Nombre_TTC__c FROM tiposDeTrabajoCaso__c WHERE id =: idTrabajo LIMIT 1];
        if (sacarElCaso.size() > 0) {
            newTrabajo = sacarElCaso[0];
        }

        return newTrabajo;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String,Object> getAseguradora(String trabajoId) {
        Map<String,Object> response = new Map<String,Object>();
        tiposDeTrabajoCaso__c trabajoCaso = [
            SELECT Caso__c,RM_WorkOrder__c,RM_Aseguradora__c,RM_CentroCosto__c
            FROM tiposDeTrabajoCaso__c 
            WHERE Id = :trabajoId 
            LIMIT 1
        ];

        response.put('trabajoCaso', trabajoCaso);

        if (trabajoCaso != null) {
            WorkOrder workOrder = [
                SELECT Id, BMW_Aseguradora__c, BMW_CentroDeCosto__c 
                FROM WorkOrder 
                WHERE Id = :trabajoCaso.RM_WorkOrder__c 
                LIMIT 1
            ];
            response.put('workOrder', workOrder);

        }

        return response;
    }
    
    @AuraEnabled(cacheable=false)
    public static Id existsWorkOrder (Id caseId) { 
        
        Id workOrderId = [Select Id from WorkOrder where CaseId=:caseId limit 1].Id;
        System.debug('workOrderId');
        System.debug(workOrderId);
        return workOrderId;

    }

    @AuraEnabled(cacheable=false)
    public static void saveWorkLineItems (string listTosave,Id workorder, Id caseid, Id tipodetrabajoid, Id tipodetrabajocaso, String origin, String tipodecargo, String centrodecosto, String aseguradora, String aliasGenerico) {
        List<WorkOrderLineItem> worklineitems=new List<WorkOrderLineItem>();
        List<Subtipo_de_trabajo_del_caso__c> subtipoTrabajoCaso=new List<Subtipo_de_trabajo_del_caso__c>();

        String Sugerido= 'Sugerido';
        String ManoDeObra='Mano de Obra';
        
        Impuesto__c impuesto0108 =  [SELECT Id FROM Impuesto__c WHERE codigoImpuesto__c='0108' LIMIT 1];
   
        if (impuesto0108 == null) { throw new AuraHandledException('El impuesto codigo 0108 no esta configurado (Impuesto__c), Favor de informar a su administrador de sistemas.');
        }        
        
        Id codigoImpuesto = impuesto0108.Id;

       	List<wrapper> wrappers=( List<wrapper>)JSON.deserialize(listTosave,List<wrapper>.class);

        Map<Id,tiposDeTrabajoCaso__c> mapTiposDeTrabajoCaso = new Map<Id,tiposDeTrabajoCaso__c>([SELECT Id,Caso__c,Horaa__c,RM_ModoTrabajo__c,Taller__c,Taller_Sucursal__c,Tipo_de_cargo__c,Tipotrabajo__c,RM_TipoTrabajoCaso__c,
                                                                                                RM_WorkOrder__c,Paso_de_trabajo__c,Paso_de_trabajo__r.Status
                                                                                                FROM tiposDeTrabajoCaso__c 
                                                                                                WHERE Id =: tipodetrabajocaso]);
        Decimal totalHoras = 0;
        for (wrapper wr : wrappers){
            totalHoras += wr.cantidad;
        }
        Boolean isTrabajoInProgress = false;
        if (mapTiposDeTrabajoCaso.size() > 0) {
            tiposDeTrabajoCaso__c ttc = mapTiposDeTrabajoCaso.get(tipodetrabajocaso);
            if(ttc != null && ttc.Paso_de_trabajo__c != null && ttc.Paso_de_trabajo__r != null && ttc.Paso_de_trabajo__r.Status != null && ttc.Paso_de_trabajo__r.Status != 'Nueva' && ttc.RM_ModoTrabajo__c != null && ttc.RM_ModoTrabajo__c == 'Tarea padre'){
                isTrabajoInProgress = true;
                tiposDeTrabajoCaso__c newTTC = new tiposDeTrabajoCaso__c(
                    Caso__c = ttc.Caso__c,
                    Horaa__c = totalHoras,
                    Taller__c = ttc.Taller__c,
                    Taller_Sucursal__c = ttc.Taller_Sucursal__c,
                    Tipo_de_cargo__c = ttc.Tipo_de_cargo__c,
                    Tipotrabajo__c = ttc.Tipotrabajo__c,
                    RM_WorkOrder__c = ttc.RM_WorkOrder__c,
                    RM_EsTrabajoAdicional__c = true
                );

                INSERT newTTC;

                mapTiposDeTrabajoCaso.put(newTTC.Id,newTTC);

                tipodetrabajocaso = newTTC.Id;
            }
        }
        
        try {
            for (wrapper wr : wrappers){
                WorkOrderLineItem wl=new WorkOrderLineItem();
                String nombre = getSubtrabajoName(wr, aliasGenerico);
                Subtipo_de_trabajo_del_caso__c sbtc = new Subtipo_de_trabajo_del_caso__c(
                    Articulo_Mano_de_Obra__c = null,
                    Tipo_de_trabajo_del_caso__c = tipodetrabajocaso,
                    Caso__c = caseid, 
                    Orden_de_trabajo__c = mapTiposDeTrabajoCaso.get(tipodetrabajocaso)?.RM_WorkOrder__c, 
                    Name = nombre, 
                    Cantidad_de_horas__c = wr.cantidad, 
                    created_From__c = origin
                );    

                System.debug('sbtc '+sbtc);

                Product2 product = [SELECT Id,Mano_de_obra_no_pasa_a_OT__c FROM Product2 WHERE id =:wr.productId];

                if(product.Mano_de_obra_no_pasa_a_OT__c != true){
                    wl.WorkOrderId=workorder;
                    wl.Product__c=wr.productId;
                    wl.PricebookEntryId=wr.priceBookEntry;//pentries.get(wr.productId);
                    wl.aprobado__c=true;
                    wl.UT__c = Decimal.valueOf(wr.UT == null ? '0' : wr.UT) * 5; // 1 UT = 5 Minutes
    
                    //User insert in Grid//
                    wl.Alias_Articulo__c= nombre;
                    wl.Quantity=wr.cantidad;
                    wl.porcentajeDescuento__c=(wr.discount);
                    wl.especificacionesTaller__c=Sugerido;
                    wl.tiposDeTrabajo__c = tipodetrabajoid;
                    wl.Trabajo__c = ManoDeObra;
                    wl.created_From__c=origin;
                    wl.Impuesto__c = codigoImpuesto;
                    
                    worklineitems.add(wl);
                }

                subtipoTrabajoCaso.add(sbtc);
            }
            
            /*
            if(worklineitems.size() > 0){
                upsert worklineitems;     
                for (Subtipo_de_trabajo_del_caso__c sb : subtipoTrabajoCaso){
                    
                   System.debug('worklineitems '+worklineitems);
                    System.debug('worklineitems[0].Id '+worklineitems[0].Id);
                    String iddelwoli = worklineitems[0].Id;
                      System.debug('iddelwoli '+iddelwoli);
                    //if(!String.isBlank(sb.Articulo_Mano_de_Obra__c)){
                      System.debug('iddelwoli2 '+iddelwoli);
                    sb.Articulo_Mano_de_Obra__c = iddelwoli;
                    System.debug('sb Articulo_Mano_de_Obra__c '+sb.Articulo_Mano_de_Obra__c);
                       System.debug('sb '+sb);
                    //}
    
                }
            }*/
            if(worklineitems.size() > 0){
                upsert worklineitems; // Inserta o actualiza los WorkOrderLineItems en la base de datos
            
                // Itera sobre ambas listas en paralelo para asociar cada Subtipo de Trabajo con su WorkOrderLineItem correspondiente
                for (Integer i = 0; i < subtipoTrabajoCaso.size(); i++) {
                    if (i < worklineitems.size()) {
                        Subtipo_de_trabajo_del_caso__c sb = subtipoTrabajoCaso[i];
                        WorkOrderLineItem wlItem = worklineitems[i];
                        
                        // Asocia el WorkOrderLineItem con el Subtipo de Trabajo
                        sb.Articulo_Mano_de_Obra__c = wlItem.Id;
                        System.debug('Asociado Subtipo_de_trabajo_del_caso__c: ' + sb.Id + ' con WorkOrderLineItem: ' + wlItem.Id);
                    }
                }
            }
            


            setInProgress(workorder);
            if(subtipoTrabajoCaso.size() > 0){
                UPSERT subtipoTrabajoCaso;
            }
            
        } catch (DMLException e) { throw new AuraHandledException(e.getMessage());  
        }        
        
        createTipoCargo(worklineitems, tipodecargo, aseguradora, centrodecosto);
    }

    public static String getSubtrabajoName(wrapper wr, String aliasGenerico) {
        if (wr.alias != null && String.isNotBlank(wr.alias)) {
            return wr.alias.length() > 80 ? wr.alias.substring(0, 80) : wr.alias;
        } else if (aliasGenerico != null && aliasGenerico.length() > 8) { return aliasGenerico.length() > 80 ? aliasGenerico.substring(0, 80) : aliasGenerico;
        }
        return aliasGenerico;
    }
    
    
    public static void createTipoCargo (List<WorkOrderLineItem> worklineitems, String tipoCargo, String aseguradora, String centrodecosto) {
        List<tipoCargo__c> tipoCargoList = new List<tipoCargo__c>();
        Set<Id> woliIds = new Set<Id>();
        for (WorkOrderLineItem woli: worklineitems){
            woliIds.add(woli.Id);
        }

        if (woliIds.isEmpty()) {
            return;
        }

        Map<Id,WorkOrderLineItem> wolisMap = new Map<Id,WorkOrderLineItem>([SELECT Id, WorkOrderId,WorkOrder.BMW_Aseguradora__c,WorkOrder.BMW_CentroDeCosto__c FROM WorkOrderLineItem WHERE Id IN :woliIds]);
        System.debug('@wolisMap@');
        System.debug(wolisMap);
        Set<Id> wolisIds = new Set<Id>();
        for (WorkOrderLineItem woli: worklineitems){
            wolisIds.add(woli.Id);
        }
        List<tipoCargo__c> tipoCargoExistentes = new List<tipoCargo__c>();
        tipoCargoExistentes = [Select Id From tipoCargo__c Where Work_Order_Line_Item__c IN: wolisIds];
        if(tipoCargoExistentes.size()>0){ delete tipoCargoExistentes;
        }
        for (WorkOrderLineItem woli: worklineitems){
            tipoCargo__c newTipoCargo = new tipoCargo__c();
            newTipoCargo.Work_Order_Line_Item__c = woli.Id;
            
            WorkOrderLineItem woliAux = wolisMap.get(woli.Id);

            String codTipoCargo;
            switch on tipoCargo{
                    when 'Cliente'{
                    	codTipoCargo = '1';
                    }
                    when 'Garantía' { codTipoCargo = '4';
                    }
                    when 'BSI'{ codTipoCargo = '5';
                    }
                    when 'BSI Interno'{ codTipoCargo = '6';
                    }
                    when 'Aseguradora'{ codTipoCargo = '3';
                        if(String.isNotBlank(aseguradora)){
                            newTipoCargo.Cliente__c = aseguradora;
                        }else if(woliAux.WorkOrder.BMW_Aseguradora__c != null){
                            newTipoCargo.Cliente__c = woliAux.WorkOrder.BMW_Aseguradora__c;
                        }
                    }
                    when 'Interno'{
                    	codTipoCargo = '2';
                        if(String.isNotBlank(centrodecosto)){
                            newTipoCargo.centroCosto__c = centrodecosto;
                            woli.centroCosto__c = centrodecosto;
                        }else if(woliAux.WorkOrder.BMW_CentroDeCosto__c != null){
                            newTipoCargo.centroCosto__c = woliAux.WorkOrder.BMW_CentroDeCosto__c;
                            woli.centroCosto__c = woliAux.WorkOrder.BMW_CentroDeCosto__c;
                        }
                    }
                }
            
            newTipoCargo.tipoCargo__c = codTipoCargo;
            newTipoCargo.porcentaje__c = 100;
            newTipoCargo.CurrencyISOCode = woli.CurrencyIsoCode;
            tipoCargoList.add(newTipoCargo);
        }

        System.debug('@tipoCargoList@');
        System.debug(tipoCargoList);

        try {
            if (tipoCargoList.size() > 0) {                
                INSERT tipoCargoList;
            } 
            if (worklineitems.size() > 0) {
                UPSERT worklineitems;            
            }
        } catch (DmlException e) { throw new AuraHandledException(e.getMessage());  
        }
    }

    public class wrapper {
        //Product Query --> Service Territory
        @AuraEnabled  public Id productId;// Product ID
        @AuraEnabled  public String ProductCode;// Product code
        @AuraEnabled  public String Name;// Product Name
        @AuraEnabled  public decimal precio;// Product Unit price 
        @AuraEnabled public String productType;//tipoProducto__c
        //Service territory
        @AuraEnabled  public String Bodega;//Bodega del NameTest ServiceTerritory
         @AuraEnabled  public String bodegaID;
        @AuraEnabled  public decimal cantidadDisponible;// Cantidad disponible (productoxbodega**)
        //WorkOrderLineItem insert
        @AuraEnabled  public String alias;// validado
        @AuraEnabled public Boolean aprobado;// cambiar boolean check
        @AuraEnabled public double cantidad;// double
        @AuraEnabled public String tipotrabajo;// lookup validado
        @AuraEnabled public String trabajo;// picklist validado
        @AuraEnabled public decimal discount;
        @AuraEnabled public String tax;// picklist validado Impuesto__c No se ve insert 13%
        @AuraEnabled public String priceBookEntry;
        @AuraEnabled public String currencyCode;
        @AuraEnabled public String UT;
    	//Flag to insert in ProductosPorBodega Field (WorkOrderLineItem)
        
        ///porcentajeDescuento__c porcentajeDescuento__c
        
        
        
        public wrapper(Id productId, String ProductCode, String Name, decimal precio,String Bodega,decimal cantidadDisponible,String productType,
                       String alias,String tipotrabajo,String priceBookEntry,String currencyCode,String bodegaID, String trabajo)
        {
            this.productId=productId;
            this.ProductCode=ProductCode;
            this.Name=Name;
            this.precio=precio;
            this.Bodega=Bodega;//Work Order WorkOrder.Owner.Name
            this.cantidadDisponible=cantidadDisponible;//WorkOrder.WorkOrderNumber
            this.productType=productType;
            this.alias=alias;
            this.aprobado=true;
            this.cantidad=1.0000;
            this.tipotrabajo=tipotrabajo;
            this.discount=0;
            this.priceBookEntry=priceBookEntry;
            this.currencyCode=currencyCode;
            this.bodegaID=bodegaID;
            this.trabajo=trabajo;
        }
    }
    
    public static void setInProgress(Id workorder){
        WorkOrder wo = new WorkOrder(Id=workorder,SyncSoftlandFlag__c=false,Etapa_de_flujo_de_trabajo__c = 'En proceso');
        update wo;
        
    }

}