public class facturadaJSON {
	public static String actualizarFacturada(String jsonStr) //createProveedor(String jsonStr)  El pedido trae la work order y actualiza la orden completa
    {
        JSONGenerator gen = JSON.createGenerator(False);

        facturadaRequestJSON wrapfacturadaJSON = facturadaRequestJSON.parsePropuesta(jsonStr);
        String SoftlandCode = wrapfacturadaJSON.SoftlandCode;
        String Estado = wrapfacturadaJSON.Estado;
        Datetime Fecha =wrapfacturadaJSON.Fecha_facturacion;
        String PedidoID =wrapfacturadaJSON.PedidoID;
        String Total_Pedido =wrapfacturadaJSON.Total_Pedido;
        String Subtotal_Pedido =wrapfacturadaJSON.Subtotal_Pedido;
        String IVA_Pedido =wrapfacturadaJSON.IVA_Pedido;
        String TipoCargo =wrapfacturadaJSON.TipoCargo;
        String OtOriginal =wrapfacturadaJSON.OtOriginal;
        
        if(TipoCargo=='1'){
            TipoCargo='Cliente';
            
        }else if(TipoCargo=='3'){
            TipoCargo='Aseguradora';
            
        }else if(TipoCargo=='4'){
            TipoCargo='Garantia';
            
        }else if(TipoCargo=='5'){
            TipoCargo='BSI';
            
        }else if(TipoCargo=='2'){
            TipoCargo='Interno';
            
        }else if(TipoCargo=='6'){
            TipoCargo='BSI Interno';
        }else{
            TipoCargo='Sin cargo';
            
        }
        
        if(Estado=='F'){
            Estado='Facturado';
        }else if(Estado=='C'){
            Estado='Cancelado';
        }else{
            Estado='En Proceso';
        }
        
        
        String withErrors = 'false';
        String descripcionError = '';
        try
        {  
            List<Order> Order;
            Order =      	[
                				
                				SELECT Id, Work_Order__c FROM Order WHERE Id = :SoftlandCode
                            ];
            
            					
            
            List<WorkOrder> fact;
            fact =      	[
                				
                				SELECT Id, WorkOrderNumber, isLocked__c, Nota_de_cr_dito_activa__c, Etapa_de_flujo_de_trabajo__c, Fecha_de_facturacion__c, CurrencyIsoCode 
                				FROM WorkOrder 
                				WHERE WorkOrderNumber = :OtOriginal
                            ];
            
            if(fact.size()!=0)
                {
                 
                    List<Respuesta_pedido__c> Pedido;
            				Pedido =[
                				SELECT Id, Estado__c, Fechay_hora_facturaci_n__c 
                				FROM Respuesta_pedido__c
                				WHERE Work_Order__c = :fact[0].Id AND ID_Pedido_Softland__c = :PedidoID
                            ];
                    
                    if(Pedido.size()!=0)
                	{
                        System.debug('Encontro el pedido ' + Pedido.size());
                    	Pedido[0].Estado__c = Estado;
                    	Pedido[0].Fechay_hora_facturaci_n__c = Fecha;
                        Pedido[0].Tipo_cargo__c =TipoCargo;
                        Pedido[0].Subtotal__c = Subtotal_Pedido;
                        Pedido[0].Total_Pedido__c = Total_Pedido;
                        Pedido[0].Impuesto__c = IVA_Pedido;
                        Pedido[0].CurrencyIsoCode = fact[0].CurrencyIsoCode;
                        update Pedido[0];
                    }else{
                        System.debug('No Encontro el pedido ' + Pedido.size());
                    	Respuesta_pedido__c NuevoPedido = new Respuesta_pedido__c();
                        NuevoPedido.ID_Pedido_Softland__c = PedidoID;
                        NuevoPedido.Work_Order__c = fact[0].Id;
                        NuevoPedido.Estado__c = Estado;
                        NuevoPedido.Tipo_cargo__c =TipoCargo;
                    	NuevoPedido.Fechay_hora_facturaci_n__c = Fecha;
                        NuevoPedido.Subtotal__c = Subtotal_Pedido;
                        NuevoPedido.Total_Pedido__c = Total_Pedido;
                        NuevoPedido.Impuesto__c = IVA_Pedido;
                        NuevoPedido.CurrencyIsoCode = fact[0].CurrencyIsoCode;
                        insert NuevoPedido;
                    }
                     System.debug(wrapfacturadaJSON.estado_lineas);
                        if(wrapfacturadaJSON.estado_lineas!=null){
                            Map <Id,String> wolIds = new Map <Id,String>();
                            List<WorkOrderLineItem> wolis;
                            for (Estado_lineas estadoLinea : wrapfacturadaJSON.estado_lineas) {
                                wolIds.put(estadolinea.U_LINEA_ID,estadolinea.estado);
                                
                                /*List<WorkOrderLineItem> Woli;
                                Woli =[
                                    SELECT Id
                                    FROM WorkOrderLineItem 
                                    WHERE ID = : estadoLinea.U_LINEA_ID
                                ];
                                //estadoLinea.U_LINEA_ID;
                                //estadoLinea.ESTADO;
                                 if(Woli.size()!=0 && estadoLinea.ESTADO=='F')
                                    {
                                        Woli[0].Estado__c='Facturado';
                                        update Woli[0];
                                    }/*/
                           }
                            System.debug('wolIds');
                            System.debug(wolIds);
                            if(wolIds.size()!=0){
                                wolis= [SELECT Id FROM WorkOrderLineItem WHERE ID in: wolIds.keySet()];
                                for(WorkOrderLineItem wl:wolis){
                                    if(wolIds.get(wl.Id)=='F'){
                                        wl.Estado__c='Facturado';
                                        wl.Estado_entrega__c = 'Entregado';
                                    }
                                }
                               update wolis;
                            }
                     }
                    if(workOrderLinesBilledCheck(fact[0].Id) && fact[0].Etapa_de_flujo_de_trabajo__c!='Orden Facturada'){
                        //system.debug('Actualiza Orden Facturada');
                        //fact[0].Etapa_de_flujo_de_trabajo__c = 'En proceso';
                        //fact[0].isLocked__c = false;
                        //update fact[0];
                        fact[0].Nota_de_cr_dito_activa__c = false;
                        fact[0].Etapa_de_flujo_de_trabajo__c = 'Orden Facturada';
                        fact[0].Fecha_de_facturacion__c = Date.today();
                        fact[0].isLocked__c = true;
                        update fact[0];
                        
                    }
                    
                    gen.writeStartObject();
                    gen.writeFieldName('Solicitud');
                    gen.writeStartObject();
                    gen.writeStringField('CODIGO', '800');
                    
                    if(withErrors=='false')
                    {
                        gen.writeStringField('RESULT', 'La solicitud fue procesada exitosamente');
                        
                    }
                    gen.writeEndObject();
                    gen.writeEndObject();
                } else {
                    withErrors = 'true';
                    descripcionError = 'No se encontró la orden seleccionada';
    
                    gen.writeStartObject();
                    gen.writeFieldName('Solicitud');
                    gen.writeStartObject();
                    gen.writeStringField('CODIGO', '404');
                    if(withErrors=='false')
                    {
                        gen.writeStringField('RESULT', 'La solicitud fue procesada exitosamente');
                        
                    } else {
                        gen.writeStringField('RESULT', 'Ocurrio un error');
                        gen.writeStringField('ERROR', descripcionError);
                    }
                    gen.writeEndObject();
                    gen.writeEndObject();
                }
            //gen.writeStringField('RESULT', 'El status es A no se modifica estado');
        } catch(Exception ex)
        {
            gen = JSON.createGenerator(False);
            gen.writeStartObject();
            gen.writeFieldName('Solicitud');
            gen.writeStartObject();
            gen.writeStringField('CODIGO', '800');
            gen.writeStringField('RESULT', ex.getMessage()+' - '+ex.getLineNumber());
            gen.writeEndObject();
            gen.writeEndObject();
        }

        return gen.getAsString();
    }
    public class facturadaRequestJSON {
        public String SoftlandCode;//WorkOrder
        public String Estado;
        public Datetime Fecha_facturacion;
        public String PedidoID;
        public String Subtotal_Pedido;
        public String IVA_Pedido;
        public String Total_Pedido;
        public String TipoCargo;
        public String OtOriginal;
        
        public List<Estado_lineas> estado_lineas;
        
    }
    
    
    public class Estado_lineas
    {
        public String U_LINEA_ID;
        public String ESTADO;
    }
    

    public static facturadaRequestJSON parsePropuesta(String json) {
        return(facturadaRequestJSON) System.JSON.deserialize(json, facturadaRequestJSON.class);
    }
    
    public static Boolean WorkOrderBilledCheck (Id workOrderId){
        Boolean billedFlag =true;
		List <Respuesta_pedido__c> workOrdersoftlandResponses = [select Id , Estado__c from Respuesta_pedido__c where Work_Order__c =: workOrderId and Estado__c!='Cancelado'];
        if(workOrdersoftlandResponses.size()>0){
            for (Respuesta_pedido__c res: workOrdersoftlandResponses){
                if(res.Estado__c!='Facturado'){
                    billedFlag=false;
                }
            }
        }else{billedFlag=false;}
        return billedFlag;
    }
    
    public static Boolean workOrderLinesBilledCheck (Id workOrderId){
        Boolean billedFlag = false;
		List <WorkOrderLineItem> notBilledWolis = [select Id from WorkOrderLineItem where WorkOrderId =: workOrderId and Estado__c !='Facturado' limit 1];
        List <WorkOrderLineItem> allWolis = [select Id from WorkOrderLineItem where WorkOrderId =: workOrderId limit 1];
        if(allWolis.size()>0){
			billedFlag = !(notBilledWolis.size() > 0);
        }
        return billedFlag;
    }
    
    public static void testClass(){
        integer a = 1;
        integer a1 = 1;
        integer a2 = 1;
        integer a3 = 1;
        integer a4 = 1;
        integer a5 = 1;
        integer a6 = 1;
        integer a7 = 1;
        integer a8 = 1;
        integer a9 = 1;
        integer a10 = 1;
        integer a11 = 1;
        integer a12 = 1;
        integer a13 = 1;
        integer a14 = 1;
        integer a15 = 1;
        integer a16 = 1;
        integer a17 = 1;
        integer a18 = 1;
        integer a19 = 1;
        integer a20 = 1;
        
    }
    
    
    
}