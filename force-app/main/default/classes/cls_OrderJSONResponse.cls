public without sharing class cls_OrderJSONResponse {
	public String code;
    public String detail;
    public String Total_Pedido;
    public String Subtotal;
    public String Impuesto;
    public String Estado;
    public String tipoCargo;
    public String request_id;
    public String fecha_facturacion;
    public List<cls_OrderJSONResponse> Data;
    public String errorCode;

    public static cls_OrderJSONResponse parseOrderResponseJSON(String json) {
        return(cls_OrderJSONResponse) System.JSON.deserialize(json, cls_OrderJSONResponse.class);
    }
    
    public static void createResponses(cls_OrderJSONResponse response,Id workOrder){
        String currencyISO=[select CurrencyIsoCode from WorkOrder where id=:workOrder].CurrencyIsoCode;
        Map<String,Respuesta_pedido__c> responsesList = new Map<String,Respuesta_pedido__c>();
        WorkOrder currentWO = new workOrder(id = workOrder);
		String requestID;
		integer facturadas=0;
        for(cls_OrderJSONResponse res: response.Data){
            string CodeSoftland ='';
            Datetime fechaFacturacion;
            requestID = (res.request_id);
            System.debug('Code Arreglado'+res.code);
            if(res.Estado=='F'){
                CodeSoftland='Facturado';
                fechaFacturacion = Datetime.parse(res.fecha_facturacion);
                facturadas+=1;
            }else if(res.Estado=='C'){
                CodeSoftland='Cancelado';
            }else{
                CodeSoftland='En Proceso';
            }
            System.debug('Code '+res.code+' Detalle'+res.detail+' estado '+res.Estado);
            Respuesta_pedido__c responseSF = new Respuesta_pedido__c();
            responseSF.ID_Pedido_Softland__c=res.detail;
            responseSF.Estado__c=CodeSoftland;
            responseSF.Fechay_hora_facturaci_n__c=fechaFacturacion;
            responseSF.Work_Order__c=workOrder;
            responseSF.Total_Pedido__c= res.Total_Pedido;
            responseSF.Subtotal__c=res.Subtotal;
            responseSF.Impuesto__c=res.Impuesto;
            responseSF.Tipo_Cargo__c= res.getTipoCargoFromPickList(res.tipoCargo);
            responseSF.CurrencyIsoCode=currencyISO;
            responsesList.put(responseSF.ID_Pedido_Softland__c,responseSF);
        }
       	APIServiceLog sofltanFindLog = new APIServiceLog(requestID);
        if(sofltanFindLog.logExists()){
            sofltanFindLog.setResponse(STRING.valueOf(response));
        }
        /*System.debug('WORORDER STATUS FACTURADA ? '+isFacturada);
        List<Respuesta_pedido__c> deleteActualResponses = new List<Respuesta_pedido__c>();
        for(Respuesta_pedido__c actualResponsesSF :[select Id,ID_Pedido_Softland__c,Estado__c from Respuesta_pedido__c where Work_Order__c =: workOrder]){

            if(responsesList.containsKey(actualResponsesSF.ID_Pedido_Softland__c) && actualResponsesSF.Estado__c == 'Facturado'){
                responsesList.remove(actualResponsesSF.ID_Pedido_Softland__c);
            }else if(actualResponsesSF.Estado__c !='Facturado'){
                deleteActualResponses.add(actualResponsesSF);
            }
        }

        //Incidente Ajuste para respuesta de oslu duplicados 20230324 MFC
       // Map <String,Respuesta_pedido__c> actualResponsesSF= new Map <String,Respuesta_pedido__c>();
       /* List<Respuesta_pedido__c> actualResponsesSF=[select Id,ID_Pedido_Softland__c from Respuesta_pedido__c where ID_Pedido_Softland__c=:responsesList.keySet() and Estado__c='Facturado'];
        for(Respuesta_pedido__c actual:actualResponsesSF){
            if(responsesList.containsKey(actual.ID_Pedido_Softland__c)){
                responsesList.remove(actual.ID_Pedido_Softland__c);
            }
        }
        List<Respuesta_pedido__c> deleteActualResponses=[select Id from Respuesta_pedido__c where Work_Order__c=:workOrder and Estado__c!='Facturado'];*/
        //delete deleteActualResponses;
        deleteRespones(workOrder);
        insert responsesList.values();
        ProductController.setSoftlandConfirmation('response',requestID,workOrder);
        //Cambio por incidencia deadlock softland
        //if(response.Data.size()==facturadas && facturadas>0 ){
        if(facturadaJSON.workOrderLinesBilledCheck(workOrder)){
            currentWO.Etapa_de_flujo_de_trabajo__c = 'Orden Facturada';
            currentWO.isLocked__c = true;
            update currentWO;
        }
        
    }
    
    public string getTipoCargoFromPickList(String apiValue){
        List<Schema.PicklistEntry> values = tipoCargo__c.tipoCargo__c.getDescribe().getPicklistValues();
        Map<String,String> statusApiToLabelMap = new Map<String,String>();
        system.debug(values);
        For(Schema.PicklistEntry sp : values){
            //Map to hold Picklist API as Key and Picklist Label as Value
            statusApiToLabelMap.put(sp.getValue(),sp.getLabel());
        }
        System.debug(statusApiToLabelMap.get(apiValue));
        return statusApiToLabelMap.get(apiValue);
    }
    
    public static void deleteRespones(id workOrder){
        List<Respuesta_pedido__c> actualResponsesSF=[select Id from Respuesta_pedido__c where Work_Order__c =: workOrder];
        delete actualResponsesSF;
	}
    
}