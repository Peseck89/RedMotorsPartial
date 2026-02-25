public with sharing class ProductController {
    @AuraEnabled
    public static void actualizaAseguradora (String recordId, String aseguradoraId) { 
        System.debug('aseguradoraId '+aseguradoraId);
        List<WorkOrderLineItem> woliList = [Select Id From WorkOrderLineItem Where WorkOrderId =: recordId];
        Set<Id> woliAse = new Set<Id>();
        if(woliList.size()>0){
            for(WorkOrderLineItem woli : woliList){
                woliAse.add(woli.Id);
            }
            List<tipoCargo__c> tipoCargoList = [Select Id,Cliente__c,tipoCargo__c From tipoCargo__c Where Work_Order_Line_Item__c IN: woliAse];
            if(tipoCargoList.size()>0){
                for(tipoCargo__c tc : tipoCargoList){
                    if(tc.Cliente__c == null && tc.tipoCargo__c == '3'){
                        tc.Cliente__c = aseguradoraId;
                    }
                }
            }
            update tipoCargoList;
        }
    }
    @AuraEnabled
    public static void actualizaCentroCostos (String recordId, String centroCostosId) {
         System.debug('centroCostosId '+centroCostosId);
        List<WorkOrderLineItem> woliList2 = [Select Id,centroCosto__c From WorkOrderLineItem Where WorkOrderId =: recordId];
        Set<Id> woliCen = new Set<Id>();
        if(woliList2.size()>0){
            for(WorkOrderLineItem woli : woliList2){
                woliCen.add(woli.Id);
            }
            List<tipoCargo__c> tipoCargoList = [Select Id,centroCosto__c,tipoCargo__c From tipoCargo__c Where Work_Order_Line_Item__c IN: woliCen];
            if(tipoCargoList.size()>0){
                for(tipoCargo__c tc : tipoCargoList){
                    if(tc.centroCosto__c == null && tc.tipoCargo__c == '2'){
                        tc.centroCosto__c = centroCostosId;
                    }
                }
            }
            update tipoCargoList;
        }
    }
    @AuraEnabled
    public static boolean consultaAseguradora (String recordId) { 
        WorkOrder woB = [Select Id, tipoDeGasto__c, BMW_Aseguradora__c  from workorder where id=:recordId];
        Boolean FaltaAseguradora = false;
        if(woB.tipoDeGasto__c == 'Aseguradora' && woB.BMW_Aseguradora__c == null){
            FaltaAseguradora = true;
        }
        List<WorkOrderLineItem> woliList = [Select Id From WorkOrderLineItem Where WorkOrderId =: recordId];
        Set<Id> woliAse = new Set<Id>();
        if(woliList.size()>0){
            for(WorkOrderLineItem woli : woliList){
                woliAse.add(woli.Id);
            }
            List<tipoCargo__c> tipoCargoList = [Select Id,Cliente__c,tipoCargo__c From tipoCargo__c Where Work_Order_Line_Item__c IN: woliAse];
            if(tipoCargoList.size()>0){
                for(tipoCargo__c tc : tipoCargoList){
                    if(tc.Cliente__c == null && tc.tipoCargo__c == '3'){
                        FaltaAseguradora = true;
                    }
                }
            }
        }
        return FaltaAseguradora;
    }
    @AuraEnabled
    public static boolean consultaCentroDeCostos (String recordId) { 
        WorkOrder woB = [Select Id, tipoDeGasto__c, BMW_CentroDeCosto__c   from workorder where id=:recordId];
        Boolean FaltaCentroDeCostos = false;
        if(woB.tipoDeGasto__c == 'Interno' && woB.BMW_CentroDeCosto__c  == null){
            FaltaCentroDeCostos = true;
        }
        List<WorkOrderLineItem> woliList2 = [Select Id,centroCosto__c From WorkOrderLineItem Where WorkOrderId =: recordId];
        Set<Id> woliCen = new Set<Id>();
        if(woliList2.size()>0){
            for(WorkOrderLineItem woli : woliList2){
                woliCen.add(woli.Id);
            }
            List<tipoCargo__c> tipoCargoList = [Select Id,centroCosto__c,tipoCargo__c From tipoCargo__c Where Work_Order_Line_Item__c IN: woliCen];
            if(tipoCargoList.size()>0){
                for(tipoCargo__c tc : tipoCargoList){
                    if(tc.centroCosto__c == null && tc.tipoCargo__c == '2'){
                        FaltaCentroDeCostos = true;
                    }
                }
            }
        }
        return FaltaCentroDeCostos;
    }
    @AuraEnabled(cacheable=true)
    public static boolean getPriceAccess () { 
        return [select Can_edit_sale_price__c from user where Id=:UserInfo.getUserId()].Can_edit_sale_price__c;
    }
    @AuraEnabled(cacheable=true)
    public static boolean getBetaAccess () { 
        return [select is_Beta_Tester__c from user where Id=:UserInfo.getUserId()].is_Beta_Tester__c;
    }
    @AuraEnabled(cacheable=false)
    public static List<wrapper> getWolis (string listTosave,Id workorder) { 
        //workorder='0WO7g000000oTZOGA2';//UnComment for preview LWC locally with a WO.ID
        List<String> bodegas= getBodegas(workorder);
        List<WorkOrderLineItem> wolis=[SELECT Id,Product__c,Product__r.Codigo_de_Producto__c,Product__r.Name,Product__r.costoLocal__c,Product__r.tipoProducto__c,
                                       Bodega__r.Name,Bodega__c,ProductoPorBodega__c,ProductoPorBodega__r.Disponible__c,Bodega__r.bodega__c,
                                       PricebookEntryId,PricebookEntry.UnitPrice,PricebookEntry.CurrencyIsoCode,
                                       Alias_Articulo__c,Quantity,porcentajeDescuento__c,Localizacion__c,UnitPrice,Estado__c
                                       FROM WorkOrderLineItem 
                                       WHERE WorkOrderId=:workorder order by LineItemNumber desc];
        List<wrapper> worklineitems=(List<wrapper>)JSON.deserialize(listTosave,List<wrapper>.class); 
        for (WorkOrderLineItem wl: wolis){            
            wrapper wr= new wrapper (wl.ProductoPorBodega__c,wl.Product__c,wl.Product__r.Codigo_de_Producto__c,wl.Product__r.Name,wl.PricebookEntry.UnitPrice,wl.Bodega__r.Name,wl.ProductoPorBodega__r.Disponible__c,
                                     wl.Product__r.tipoProducto__c,wl.Alias_Articulo__c,null,wl.PricebookEntryId,wl.PricebookEntry.CurrencyIsoCode,wl.Bodega__c,wl.Bodega__r.bodega__c,wl.ProductoPorBodega__c);
            wr.setWolId(wl.Id);
            wr.cantidad=wl.Quantity;
            wr.discount=wl.porcentajeDescuento__c;
            wr.location=wl.Localizacion__c;
            wr.unitPrice=wl.UnitPrice;
            wr.isClosed=wl.Estado__c=='Facturado';
            worklineitems.add(wr);
        }
        return worklineitems;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<wrapper> searchMO (String productType, String productName,Id workOrder ) {
        //system.debug('Paramertos'+productType+'  '+productName);
        List<wrapper> worklineitems=new  List<wrapper>(); 
        if(productName.length()>=4){
            String keyNameString = '%' +  productName + '%';
            ID priceId=[select Pricebook2Id from WorkOrder where id=:workorder].Pricebook2Id;
            List<Product2> products=[SELECT Id, Codigo_de_Producto__c, Name, costoLocal__c, Description, cantidadDisponible__c,tipoProducto__c,
                                     (select id,UnitPrice,CurrencyIsoCode from Pricebookentries  where Pricebook2Id=:priceId limit 1) FROM Product2 
                                     WHERE tipoProducto__c=:productType
                                     and Id in (select Product2Id from PricebookEntry where Pricebook2Id=:priceId)
                                     and IsActive=true
                                     and (Name LIKE:keyNameString or Codigo_de_Producto__c LIKE:keyNameString) order by Id limit 100];
            
            for (Product2 prod: products){
                PricebookEntry pentry=prod.Pricebookentries[0];
                wrapper wl= new wrapper (prod.Id,prod.Id,prod.Codigo_de_Producto__c,prod.Name,pentry.UnitPrice,'Sin clasificar',0,
                                         prod.tipoProducto__c,'',null,pentry.Id,pentry.CurrencyIsoCode,null,'-',null);
                worklineitems.add(wl);
                
            }
        }
        return worklineitems;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<wrapper> searchProductxBodega (String productType, String productName,Id workOrder) { 
        //system.debug('Productos'+productName);
        //workOrder='0WO7g000000eJsQGAU';//UnComment for preview LWC locally with a WO.ID
        if(productType=='Mano de Obra'){
            return searchMO(productType,productName, workOrder);
        }
        
        List<wrapper> worklineitems=new  List<wrapper>(); 
        if(productName.length()>=4){
            List<String> bodegas= getBodegas(workOrder);
            String keyNameString = '%' +  productName + '%';
            Map<Id,ProductoXBodega__c> products=new Map<Id,ProductoXBodega__c>([SELECT Producto__c,Producto__r.Codigo_de_Producto__c,Producto__r.Name,Producto__r.costoLocal__c,Producto__r.tipoProducto__c,
                                                                                Bodega__r.Name,Bodega__c,Disponible__c,Bodega__r.bodega__c FROM ProductoXBodega__c 
                                                                                WHERE Bodega__c=:bodegas and (Producto__r.Name LIKE:keyNameString or Producto__r.Codigo_de_Producto__c LIKE:keyNameString)
                                                                                and Producto__r.IsActive=true
                                                                                order by Producto__c
                                                                                limit 100]);
            
            Map<ID,Product2> priceEntriesBefore=getPriceEntriesBefore(keyNameString,workOrder,products.keySet());
            
            for (ProductoXBodega__c prod: products.values()){              
                if(priceEntriesBefore.containsKey(prod.Producto__c)){
                    PricebookEntry pentry=priceEntriesBefore.get(prod.Producto__c).Pricebookentries[0];
                    wrapper wl= new wrapper (prod.Id,prod.Producto__c,prod.Producto__r.Codigo_de_Producto__c,prod.Producto__r.Name,pentry.UnitPrice,prod.Bodega__r.Name,prod.Disponible__c,
                                             prod.Producto__r.tipoProducto__c,'',null,pentry.Id,pentry.CurrencyIsoCode,prod.Bodega__c,prod.Bodega__r.bodega__c,prod.Id);
                    worklineitems.add(wl);
                }
            }
        }
        return worklineitems;
    }
    
    @AuraEnabled(cacheable=false)
    public static String saveWorkLineItems ( string listTosave,Id workorder,boolean saveOnline) {
        List<workorderlineitem> worklineitems=new List<workorderlineitem>();
        //Parámteros NO DINAMICOS indicados por Red Motors
        Id mantenimiento=[SELECT ID FROM tiposDeTrabajo__c WHERE Name='Mantenimiento' limit 1].Id;
        Id tax=[select id from Impuesto__c where codigoImpuesto__c='0108' limit 1 ].Id;
        String Sugerido= 'Recomendado';
        Boolean priceAccess = getPriceAccess();
        
        List<wrapper> wrappers=( List<wrapper>)JSON.deserialize(listTosave,List<wrapper>.class);
        for (wrapper wr: wrappers){
            WorkOrderLineItem wl=new WorkOrderLineItem();                
            if(wr.wolId!=null) {wl.Id=wr.wolId;} else{wl.WorkOrderId=workorder;}
            wl.Product__c=wr.productId;
            wl.PricebookEntryId=wr.priceBookEntry;
            //User insert in Grid//
            wl.Alias_Articulo__c=wr.alias;
            wl.aprobado__c=wr.aprobado;
            wl.Quantity=wr.cantidad;
            wl.porcentajeDescuento__c=(wr.discount);
            if(wr.tipotrabajo==null){wl.tiposDeTrabajo__c=mantenimiento;}else{wl.tiposDeTrabajo__c=wr.tipotrabajo;}
            wl.Trabajo__c= wr.productType=='Kit' ? 'Materiales' : wr.productType;
            wl.Impuesto__c=tax;
            if(wr.bodegaID!=null){
                wl.Bodega__c=wr.bodegaID;
                wl.ProductoPorBodega__c=wr.ProductXBodegaID;
            }
            if(wr.location!=null){
                wl.Localizacion__c=wr.location;
            }
            wl.especificacionesTaller__c=Sugerido;
            wl.created_From__c='Add_MO_and_Products_GRID';
            if(priceAccess){wl.UnitPrice=wr.unitPrice;}
            if(!wr.isClosed){worklineitems.add(wl);}
            //}
        }
        upsert worklineitems;
        if(saveOnline){
            return automaticOrderRequest(workorder);          
        }
        return workorder;
    }
    
    @AuraEnabled(cacheable=false)
    public static boolean deleteWolis ( List<String> listToDelete) {
        system.debug('WOLIS:'+listToDelete);
        List<String> idWolis;
        id workorder;
        String message = UserInfo.getName()+' ha eliminado: ('+listToDelete.size()+') Líneas de la orden.\n Detalle de Líneas:\n\n';
        List <WorkOrderLineItem> wolisToDelete= new List <WorkOrderLineItem>();
        for(WorkOrderLineItem wl: [select Id,Product__r.Codigo_de_Producto__c,Product__r.Name, Alias_Articulo__c, Quantity,Estado__c, WorkOrderId, UnitPrice, TotalPrice  from WorkOrderLineItem where Id IN:listToDelete]){
            workorder = wl.WorkOrderId;
            wolisToDelete.add(new WorkOrderLineItem(Id = wl.Id) );
            message += 'Id: ' + wl.Id + ', Product Code: ' + wl.Product__r.Codigo_de_Producto__c + ', Product Name: ' +wl.Product__r.Name +',Price: '+ wl.UnitPrice +', Total Price: '+wl.TotalPrice +  + ', Article Alias: ' + wl.Alias_Articulo__c + ', Quantity: ' + wl.Quantity + ', Status: ' + wl.Estado__c + '\n\n';
        }
        JSON_History__c deleteLog = new JSON_History__c(Error_Message__c=UserInfo.getName()+' ha eliminado: ('+listToDelete.size()+') Líneas de la orden.',Work_Order__c = workorder, JSON__c= message);
        delete wolisToDelete;
        insert deleteLog;
        return true;
        
        
    }
    public static List<Id> getBodegas(Id workorder){
        List<BodegaxTerritorio__c> bodegas=[SELECT Bodega__c from BodegaxTerritorio__c where ServiceTerritory__c in (select ServiceTerritoryId from WorkOrder where id=:workorder)];
        List<Id> bodegaIDs =new List<Id>();
        for(BodegaxTerritorio__c bxt:bodegas){
            bodegaIDs.add(bxt.Bodega__c);
        }
        return bodegaIDs;
    }
    
    public class wrapper {
        @AuraEnabled  public String wolId;// ID wrapper
        //Product Query --> Service Territory
        @AuraEnabled  public String ID;// ID wrapper 
        @AuraEnabled public String ProductXBodegaID;
        @AuraEnabled  public Id productId;// Product ID
        @AuraEnabled  public String ProductCode;// Product code
        @AuraEnabled  public String Name;// Product Name
        @AuraEnabled  public decimal precio;// Product Unit price 
        @AuraEnabled public String productType;//tipoProducto__c
        //Service territory
        @AuraEnabled  public String Bodega;//Bodega del NameTest ServiceTerritory
        @AuraEnabled  public String bodegaID;
        @AuraEnabled  public String idExtBodega; //bodega__c
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
        //Flag to insert in ProductosPorBodega Field (WorkOrderLineItem)
        //Flag servicio softland
        @AuraEnabled public Boolean validated;
        @AuraEnabled public Boolean available;
        @AuraEnabled public double softlandQuantity;
        @AuraEnabled public String location;
        @AuraEnabled public List<String> locations;
        @AuraEnabled public List<double> softlandQuantities;
        @AuraEnabled public Map<String,Double> quantityByLocation;
        @AuraEnabled public decimal unitPrice;
        @AuraEnabled public boolean isClosed;
        ///porcentajeDescuento__c porcentajeDescuento__c
        
        
        
        public wrapper(Id ID,Id productId, String ProductCode, String Name, decimal precio,String Bodega,decimal cantidadDisponible,String productType,
                       String alias,String tipotrabajo,String priceBookEntry,String currencyCode,String bodegaID,String idExtBodega,String ProductXBodegaID/*,String trabajo*/)
        {
            this.wolId=null;
            this.ID=ID;
            this.productId=productId;
            this.ProductCode=ProductCode;
            this.Name=Name;
            this.precio=precio;
            this.Bodega=Bodega;//Work Order WorkOrder.Owner.Name
            this.idExtBodega=idExtBodega; //bodega__c
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
            this.validated=false;
            this.available=null;
            this.softlandQuantity=this.cantidadDisponible;
            this.location=null;
            if(this.productType=='Mano de Obra'){
                this.softlandQuantity=1000;
            }
            this.locations=new List<String>();
            this.softlandQuantities= new List <double>();
            this.quantityByLocation = new Map<String,Double>();
            this.ProductXBodegaID= ProductXBodegaID;
            this.unitPrice=this.precio;
            this.isClosed= false;
        }
        
        public void setLocations(){
            System.debug('Keyset'+quantityByLocation.keySet());
            if(this.productType != 'Kit'){
                for (String lxQ:this.quantityByLocation.keySet()){
                    if(this.locations.indexOf(lxQ)==-1){
                        this.locations.add(lxQ);
                        this.softlandQuantities.add(this.quantityByLocation.get(lxQ));
                    }
                }
            }else{
                this.locations.add('NO DEFINIDA');
                this.location='NO DEFINIDA';
                this.softlandQuantities.add(this.softlandQuantity);
                this.quantityByLocation.clear();
                this.quantityByLocation.put('NO DEFINIDA', this.softlandQuantity);
            }
            
        }
        public void setWolId(ID woli){
            this.ID=woli+this.ID;
            this.wolId=woli;
        }
    }
    
    public static Map<ID,Product2> getPriceEntriesBefore(string searchString,Id workorder,set<Id> prodsbodega){
        ID priceId=[select Pricebook2Id from WorkOrder where id=:workorder].Pricebook2Id;
        Map<ID,Product2> pentries= new Map<ID, Product2>([select id, (select id,UnitPrice,CurrencyIsoCode from Pricebookentries  where Pricebook2Id=:priceId limit 1) from Product2 
                                                          where Id in (select Product2Id from PricebookEntry where Pricebook2Id=:priceId)
                                                          and Id in (select Producto__c from ProductoXBodega__c where id IN :prodsbodega )
                                                          and (Name LIKE :searchString or Codigo_de_Producto__c LIKE :searchString) order by Id
                                                          limit 100]);
        return pentries;
        
    }
    
    @AuraEnabled(cacheable=false)
    public static void syncOrderWithSoftland(Id workorder){
        automaticOrderRequest(workorder);
    }
    
    @AuraEnabled(cacheable=false)
    public static void setSyncFlag(Id workorder,Boolean validate){
        WorkOrder wo = new WorkOrder(Id=workorder,SyncSoftlandFlag__c=validate);
        update wo;
    }
    
    private static String automaticOrderRequest(Id workorder){
        String newOrder='';
        deleteSoftlandOrders(workorder);
        WorkOrder wo= new WorkOrder();
        System.debug(wo.Etapa_de_flujo_de_trabajo__c);
        wo.Id=workorder;
        wo.Etapa_de_flujo_de_trabajo__c='Nuevo';// Se actualiza a Nuevo por petición del cliente para volver a enviar reserva a Softland
        update wo;
        System.debug(wo.Etapa_de_flujo_de_trabajo__c);
        wo.Etapa_de_flujo_de_trabajo__c='En proceso';
        setSyncFlag(workorder,false);
        wo.isValidated__c=true;
        update wo;
        System.debug(wo.Etapa_de_flujo_de_trabajo__c);
        if(!Test.isRunningTest()){
            Order order= [select id from Order where Work_Order__c=:workorder and isValidated__c=true and Status='Draft' limit 1];
            order.Status='Aprobado';
            update order;
            newOrder=order.Id;
        }
        return newOrder;       
    }
    public static void deleteSoftlandOrders(Id workorder){
        List<Order> orders=[select id from Order where Work_Order__c=:workorder];
        for (Order o:orders){
            o.Status='Draft';
        }
        update orders;
        delete orders;
    }
    
    @AuraEnabled(cacheable=false)
    public static  List<wrapper> getAvailability ( string listTosave, Id workorder, String workOrderNumber) {
        //workorder='0WO7g000000eJsQGAU';//UnComment for preview LWC locally with a WO.ID
        system.debug('WO:'+workorder);
        String company=[select empresaFactura__c from WorkOrder where id=:workorder].empresaFactura__c;
        List<workorderlineitem> worklineitems=new List<workorderlineitem>();
        List<wrapper> wrappers=( List<wrapper>)JSON.deserialize(listTosave,List<wrapper>.class);
        Map<String,wrapper> mwrap=new Map<String,wrapper>();
        HttpCalloutGetProductAvailability request = new HttpCalloutGetProductAvailability(company, workOrderNumber);
        for (wrapper wr: wrappers){
            //if(!wr.isClosed){
            mwrap.put(wr.ProductCode,wr);
            request.addToRequest(wr.idExtBodega,wr.ProductCode,wr.productType);                
            // wl.WorkOrderId='0WO01000000ACYrGAO';
            //}
        }
        Map<String,productResponse> res=request.deserialize();
        //return comparison(res,mwrap,request.productXlocation);
        return comparison(res,wrappers,request.productXlocation); 
    }
    
    @AuraEnabled(cacheable=true)
    public static  String getServereOrderResponse ( Id order) {
        return [select respuestaServidor__c from Order where Id=:order or Work_Order__c=:order limit 1].respuestaServidor__c;
        //Prueba buena de servicio
        //return 'Cargo Cliente:OSLU-0000005912';
    }
    
    private static List<wrapper> comparison( Map<String,productResponse> res,List<wrapper> mwrap,Map<String,Map<String,Double>> productXlocation){
        List<wrapper> wrappers=new List<wrapper>();        
        system.debug(res);
        for(wrapper wr:mwrap){
            if(res.containsKey(wr.ProductCode)){
                system.debug('Comparando:'+wr.ProductCode+' '+res.get(wr.ProductCode).cantidadDisponible+'>='+wr.cantidad);
                if(res.get(wr.ProductCode).cantidadDisponible>=wr.cantidad){
                    wr.available=true;
                }else{wr.available=false;}
                //wr.alias='Validado';
                wr.validated=true;
                wr.softlandQuantity=res.get(wr.ProductCode).cantidadDisponible;
                if(wr.location==null||wr.location=='NO DEFINIDA'){wr.location=res.get(wr.ProductCode).localizacion;}
                //wr.locations=productXlocation.get(keyProd).keySet();
                //wr.softlandQuantities= productXlocation.get(keyProd).values();
                wr.quantityByLocation=productXlocation.get(wr.ProductCode);
                wr.setLocations();
            }
            wrappers.add(wr);
        }
        
        return wrappers;
    }    
    public class productResponse{
        public String articulo;
        public String bodega;
        public Double cantidadDisponible;
        public Double reservadoOrden;
        public String localizacion;
        
    }
    
    @AuraEnabled(cacheable=false)
    public static String lastSyncDate(Id WorkorderId){
        List<Respuesta_pedido__c> lastResponse = [select Id, createdDate,Work_Order__r.Softland_Confirmation__c from Respuesta_pedido__c where Work_Order__c =: WorkorderId order by createdDate desc limit 1 ];
        String formattedDate = null;
        boolean softlandConfirmation = false;
        if(lastResponse.size()>0){
            DateTime createdDate = lastResponse[0].CreatedDate;
            formattedDate = createdDate.format('dd/MM/yyyy hh:mm a', UserInfo.getTimeZone().getID());
            softlandConfirmation = lastResponse[0].Work_Order__r.Softland_Confirmation__c;
        }
        return '{ "LastSoftlandResponse": "'+formattedDate+'", "SoftlandConfirmation":'+softlandConfirmation+' }';
    } 
    
    @AuraEnabled(cacheable=false)
    public static boolean getLastResponses(String orderNumber, String compania, Id workOrder){
        String request_id = String.valueOf(workOrder) +DateTime.now().getTime();
        String bodyRequest = '{"num_Presupuesto": "' + orderNumber + '", "compania": "' + compania + '"}';
        HttpResponse response = HttpCalloutGetOrderLastResponses.getOrderLastResponses(orderNumber, compania,workOrder);
        APIServiceLog requestLog = new APIServiceLog(request_id, APIServiceLogConstants.CONSULTAR_SOFTLAND_API_SERVICE_TYPE,
                                                     APIServiceLogConstants.SOFTLAND_API_SERVICE_RELATED_OBJECT,
                                                     workOrder, APIServiceLogConstants.APILOG_WORKORDER_FIELD_REFERENCE);
        requestLog.setRequest(bodyRequest);
        requestLog.setResponse(response.getBody());
        return [select Softland_Confirmation__c from WorkOrder where id=:workOrder].Softland_Confirmation__c;
    } 
    
    @AuraEnabled(cacheable=false)
    public static boolean setSoftlandConfirmation(String updateType, String value,String workOrder){
        WorkOrder wo = new WorkOrder();
        wo.Id=workOrder;
        if(updateType.toUpperCase()=='REQUEST'){
            wo.Last_Softland_Request__c=value;
        }else if(updateType.toUpperCase()=='RESPONSE'){
            wo.Last_Softland_Response__c=value;
        }
        update wo;
        return true;
    }
    
    @AuraEnabled(cacheable=true)
    public static WorkOrderSetting__mdt getWorkOrderDataTableSetting(String developerName) {
        WorkOrderSettingService dataGridConfig = new WorkOrderSettingService(developerName);
        return dataGridConfig.getWorkOrderSetting();
    }
}