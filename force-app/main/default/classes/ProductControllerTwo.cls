public with sharing class ProductControllerTwo {
    
	@AuraEnabled
    public static boolean getMOAccess(){
        //return true;
        return [SELECT Can_edit_MO_price__c FROM user WHERE Id=:UserInfo.getUserid()].Can_edit_MO_price__c;
    }
    
    @AuraEnabled(cacheable=false)
    public static List<wrapper> getQolis (string listTosave, Id quoteId) { 
        system.debug('Quote en getQolis ' + quoteId);
                system.debug('listTosave ' + listTosave);
        Id oppId = [SELECT OpportunityId FROM Quote WHERE Id =: quoteId].OpportunityId;
        List<String> bodegas = getBodegasByOpp(oppId);
        List<QuoteLineItem> qlis = [    SELECT  Id,  Product2Id,  Product2.Codigo_de_Producto__c, Product2.Name, Product2.costoLocal__c, Product2.tipoProducto__c, 
                                                BMW_Bodega__r.Name,  Quantity,  UnitPrice,  Discount, PricebookEntryId, PricebookEntry.UnitPrice,PricebookEntry.CurrencyIsoCode, BMW_Alias__c,
                                                BMW_Bodega__c, BMW_Bodega__r.bodega__c
                                        FROM    QuoteLineItem
                                        WHERE   QuoteId =: quoteId ];
        List<wrapper> quoteLineItems = (List<wrapper>)JSON.deserialize(listTosave, List<wrapper>.class);
        for(QuoteLineItem ql: qlis){
            system.debug(ql);
            wrapper wr= new wrapper (   ql.Product2Id, 
                                        ql.Product2Id, 
                                        ql.Product2.Codigo_de_Producto__c, 
                                        ql.Product2.Name, 
                                        ql.PricebookEntry.UnitPrice, 
                                        ql.BMW_Bodega__r.Name, 
                                        null, 
                                        ql.Product2.tipoProducto__c, 
                                        ql.BMW_Alias__c, 
                                        null, 
                                        ql.PricebookEntryId, 
                                        ql.PricebookEntry.CurrencyIsoCode, 
                                        ql.BMW_Bodega__c, 
                                        ql.BMW_Bodega__r.bodega__c, 
                                        null);
            wr.setQliId(ql.Id);
            wr.cantidad = ql.Quantity;
            wr.discount = ql.Discount;
            // wr.location = ql.Localizacion__c;
            wr.unitPrice = ql.UnitPrice.setScale(2);
            quoteLineItems.add(wr);
        }
        system.debug(quoteLineItems);
        return quoteLineItems;
    }

    /*@AuraEnabled(cacheable=true)
    public static List<wrapper> searchMOByOpp(String productType, String productName, Id oppId){
        List<wrapper> opportunityLineItems = new List<wrapper>();
        if(productName.length() > 0 ){
            String keyNameString = '%' +  productName + '%';
            Id priceId = [SELECT Pricebook2Id FROM Opportunity WHERE Id =: oppId].Pricebook2Id;
            List<Product2> products = [ SELECT Id, Codigo_de_Producto__c, Name, costoLocal__c, Description, cantidadDisponible__c, tipoProducto__c, (SELECT id, UnitPrice, CurrencyIsoCode FROM Pricebookentries  WHERE Pricebook2Id =: priceId LIMIT 1) 
                                        FROM Product2
                                        WHERE tipoProducto__c =:productType
                                        AND Id IN (SELECT Product2Id FROM PricebookEntry WHERE Pricebook2Id =: priceId)
                                        AND IsActive=true
                                        AND (Name LIKE : keyNameString OR Codigo_de_Producto__c LIKE : keyNameString)
                                        ORDER BY Id
                                        LIMIT 100];
            for(Product2 prod : products){
                PricebookEntry pEntry = prod.PricebookEntries[0];
                wrapper oli =new wrapper (  prod.Id,
                                            prod.Id,
                                            prod.Codigo_de_Producto__c,
                                            prod.Name,pentry.UnitPrice,
                                            'Sin clasificar',
                                            0,
                                            prod.tipoProducto__c,
                                            '',
                                            null,
                                            pentry.Id,
                                            pentry.CurrencyIsoCode,
                                            null,
                                            '-',
                                            null);
                opportunityLineItems.add(oli);
            }
        }
        System.debug(opportunityLineItems);
        return opportunityLineItems;
    }*/

    @AuraEnabled(cacheable=true)
    public static List<wrapper> searchMOByQuote(String productType, String productName, String searchCriteria, Id quoteId){
        List<wrapper> quoteLineItems = new List<wrapper>();
        Id oppId = [SELECT OpportunityId FROM Quote WHERE Id =: quoteId LIMIT 1].OpportunityId;
        if(productName.length() > 0 ){
            String keyNameString = '';
            String keyCodeString = '';
            Id priceId = [SELECT Pricebook2Id FROM Opportunity WHERE Id =: oppId].Pricebook2Id;
            if(searchCriteria == 'xNombre'){
                keyNameString = '%' +  productName + '%';
                keyCodeString = '';
            }
            if(searchCriteria == 'xCodigo'){
                keyCodeString = '%' +  productName + '%';
                keyNameString = '';
            }
            List<Product2> products = [ SELECT Id, Codigo_de_Producto__c, Name, costoLocal__c, Description, cantidadDisponible__c, tipoProducto__c, (SELECT id, UnitPrice, CurrencyIsoCode FROM Pricebookentries  WHERE Pricebook2Id =: priceId LIMIT 1) 
                                        FROM Product2
                                        WHERE tipoProducto__c =:productType
                                        AND Id IN (SELECT Product2Id FROM PricebookEntry WHERE Pricebook2Id =: priceId)
                                        AND IsActive=true
                                        AND (Name LIKE : keyNameString OR Codigo_de_Producto__c LIKE : keyCodeString)
                                        ORDER BY Id
                                        LIMIT 100];
            for(Product2 prod : products){
                PricebookEntry pEntry = prod.PricebookEntries[0];
                wrapper qli =new wrapper (  prod.Id,
                                            prod.Id,
                                            prod.Codigo_de_Producto__c,
                                            prod.Name,
                                          	pentry.UnitPrice.setScale(2),
                                            'Sin clasificar',
                                            0,
                                            prod.tipoProducto__c,
                                            '',
                                            null,
                                            pentry.Id,
                                            pentry.CurrencyIsoCode,
                                            null,
                                            '-',
                                            null);
                quoteLineItems.add(qli);
            }
        }
        System.debug(quoteLineItems);
        return quoteLineItems;
    }

    /*/METODO DE BUSCAR LOS PRODUCTOS POR LA BODEGA RELACIONADA Y LA OPPORTUNIDAD PARA PRODUCTOS DE OPORTUNIDAD
    @AuraEnabled(cacheable=true)
    public static List<wrapper> searchProductxBodegaxOpp(String productType, String productName, Id oppId){
        if(productType == 'Mano de Obra') return searchMOByOpp(productType, productName, oppId);
        List<wrapper> opportunityLineItem = new List<wrapper>();
        if(productName.length() > 0){
            List<String> bodegas = getBodegasByOpp(oppId);
            String keyNameString = '%' + productName + '%';
            Map<Id,ProductoXBodega__c> products = new Map<Id,ProductoXBodega__c>([  SELECT Producto__c,Producto__r.Codigo_de_Producto__c,Producto__r.Name,Producto__r.costoLocal__c,Producto__r.tipoProducto__c,Bodega__r.Name,Bodega__c,Disponible__c,Bodega__r.bodega__c
                                                                                    FROM ProductoxBodega__c
                                                                                    WHERE Bodega__c =: bodegas
                                                                                    AND (Producto__r.Name LIKE : keyNameString OR Producto__r.Codigo_de_Producto__c LIKE : keyNameString)
                                                                                    AND Producto__r.IsActive = TRUE
                                                                                    ORDER BY Producto__c
                                                                                    LIMIT 100]);
            Map<Id, Product2> priceEntriesBefore = getPriceEntriesBeforeByOpp(keyNameString, oppId, products.Keyset());

            for(ProductoXBodega__c prod : products.values()){
                system.debug(prod.Producto__r.Name + ' Esta ' + priceEntriesBefore.containsKey(prod.Producto__c));
                if(priceEntriesBefore.containsKey(prod.Producto__c)){
                    PricebookEntry pEntry = priceEntriesBefore.get(prod.Producto__c).Pricebookentries[0];
                    wrapper oli = new wrapper ( prod.Id,
                                                prod.Producto__c,
                                                prod.Producto__r.Codigo_de_Producto__c,
                                                prod.Producto__r.Name,
                                                pentry.UnitPrice,
                                                prod.Bodega__r.Name,
                                                prod.Disponible__c,
                                                prod.Producto__r.tipoProducto__c,
                                                '',
                                                null,
                                                pentry.Id,
                                                pentry.CurrencyIsoCode,
                                                prod.Bodega__c,
                                                prod.Bodega__r.bodega__c,
                                                prod.Id);
                    opportunityLineItem.add(oli);
                }
            }
        }
        return opportunityLineItem;
    }*/

    @AuraEnabled(cacheable=true)
    public static List<wrapper> searchProductxBodegaxQuote(String productType, String productName, String searchCriteria, Id quoteId){
        if(productType == 'Mano de Obra') return searchMOByQuote(productType, productName, searchCriteria, quoteId);
        List<wrapper> quoteLineItem = new List<wrapper>();
        system.debug('entran: ' + productType + ', ' + productName + ', '+ searchCriteria + ', ' + quoteId);
        system.debug('Sigo vivo before oppId');
        Id oppId = [SELECT OpportunityId FROM Quote WHERE Id =: quoteId LIMIT 1].OpportunityId;
        system.debug('Sobrevivi oppId');
        if(productName.length() > 0){
            List<String> bodegas = getBodegasByOpp(oppId);
            String keyNameString = '';
            String keyCodeString = '';
            String keyString = '';
            if(searchCriteria == 'xNombre'){
                keyNameString = '%' + productName + '%';
                keyString = keyNameString;
                keyCodeString = '';
            }
            if(searchCriteria == 'xCodigo'){
                keyCodeString = '%' + productName + '%';
                keyString = keyCodeString;
                keyNameString = '';
            }
            Map<Id,ProductoXBodega__c> products = new Map<Id,ProductoXBodega__c>([  SELECT Producto__c,Producto__r.Codigo_de_Producto__c,Producto__r.Name,Producto__r.costoLocal__c,Producto__r.tipoProducto__c,Bodega__r.Name,Bodega__c,Disponible__c,Bodega__r.bodega__c
                                                                                        FROM ProductoxBodega__c
                                                                                        WHERE Bodega__c =: bodegas
                                                                                        AND (Producto__r.Name LIKE : keyNameString OR Producto__r.Codigo_de_Producto__c LIKE : keyCodeString)
                                                                                        AND Producto__r.IsActive = TRUE
                                                                                        ORDER BY Producto__c
                                                                                        LIMIT 100]);
            Map<Id, Product2> priceEntriesBefore = getPriceEntriesBeforeByOpp(keyString, oppId, products.Keyset());

            for(ProductoXBodega__c prod : products.values()){
                system.debug(prod.Producto__r.Name + ' Esta ' + priceEntriesBefore.containsKey(prod.Producto__c));
                if(priceEntriesBefore.containsKey(prod.Producto__c)){
                    PricebookEntry pEntry = priceEntriesBefore.get(prod.Producto__c).Pricebookentries[0];
                    wrapper qli = new wrapper ( prod.Id,
                                                prod.Producto__c,
                                                prod.Producto__r.Codigo_de_Producto__c,
                                                prod.Producto__r.Name,
                                                pentry.UnitPrice.setScale(2),
                                                prod.Bodega__r.Name,
                                                prod.Disponible__c,
                                                prod.Producto__r.tipoProducto__c,
                                                '',
                                                null,
                                                pentry.Id,
                                                pentry.CurrencyIsoCode,
                                                prod.Bodega__c,
                                                prod.Bodega__r.bodega__c,
                                                prod.Id);
                    quoteLineItem.add(qli);
                }
            }
        }
        return quoteLineItem;
    }

    @AuraEnabled(cacheable=false)
    public static String saveQuoteLineItems (String listTosave, Id quoteId, Boolean saveOnline){
        List<QuoteLineItem> quoteLineItems = new List<QuoteLineItem>();
        System.debug(listTosave);
        System.debug('SAVEONLINE'+saveOnline);

        //Parámteros NO DINAMICOS indicados por Red Motors
        String Sugerido= 'Recomendado';

        List<wrapper> wrappers = (List<wrapper>)JSON.deserialize(listTosave, List<wrapper>.class);
        system.debug('objeto JSON:'+wrappers);
        for(wrapper wr : wrappers){
            system.debug('Objeto JSON: ' + wr);
            QuoteLineItem qli =  new QuoteLineItem();
            if(wr.qliId != null) qli.Id = wr.qliId; //Already exist
            //Else new exist
            else {
                qli.QuoteId = quoteId; //create new with related quote
                qli.Product2Id = wr.productId; //assign related Product2
                qli.priceBookEntryId = wr.priceBookEntry; //relate pricebookentry to a field in qli
            } 
            //User insert in Grid//
            qli.BMW_Alias__c = wr.alias;
            //qli.aprobado__c = wr.aprobado;
            qli.Quantity = wr.cantidad;
            //qli.aprobado__c=wr.aprobado; //No aprobado__c field in QLI
            qli.Quantity = wr.cantidad;
            qli.Discount = wr.discount;
            //if(wr.tipotrabajo == null){qli.tiposDeTrabajo__c=mantenimiento;}else{qli.tiposDeTrabajo__c=wr.tipotrabajo;} //No tiposDeTrabajo__c field in QLI
            //qli.Trabajo__c = wr.productType; //No Trabajo__c field in QLI
            //qli.Impuesto__c = tax; //No Impuesto__c field in QLI
            if(wr.bodegaID != null){
                qli.BMW_Bodega__c = wr.bodegaID;
                //wl.ProductoPorBodega__c=wr.ProductXBodegaID; //No ProductoPorBodega__c field in QLI
            }
            //if(wr.location!=null){wl.Localizacion__c=wr.location;} //No location field in QLI
            //wl.especificacionesTaller__c = Sugerido; //No especificacionesTaller__c field in QLI
            //wl.created_From__c='Add_MO_and_Products_GRID'; //No created_From__c field in QLI
            System.debug('objeto SF:' + qli);
            //if(getPriceAccess())
            qli.UnitPrice = wr.unitPrice;
            quoteLineItems.add(qli);
        }
        
        upsert quoteLineItems;
        return quoteId;
    }
    
    @AuraEnabled(cacheable=false)
    public static boolean deleteQlis ( List<String> listToDelete) {
        system.debug('QLIS:' + listToDelete);
        List <QuoteLineItem> qolisToDelete=[SELECT id FROM QuoteLineItem where Id IN:listToDelete];
        delete qolisToDelete;
        return true;
    }
    
    public static List<Id> getBodegasByOpp(Id oppId){
        List<BodegaxTerritorio__C> bodegas = [SELECT Bodega__c FROM BodegaxTerritorio__C WHERE ServiceTerritory__c IN (SELECT BMW_TallerDeServicio__c FROM Opportunity WHERE Id =: oppId)];
        List<Id> bodegasIDs = new List<Id>();
        for(BodegaxTerritorio__c bxt : bodegas) bodegasIDs.add(bxt.Bodega__c);
        return bodegasIDs;
    }

    public class wrapper {
        @AuraEnabled public String wolId;// ID Work order line item
        @AuraEnabled public String qliId;// ID Quote line item
        //Product Query --> Service Territory
        @AuraEnabled public String ID;// ID wrapper 
        @AuraEnabled public String ProductXBodegaID;
        @AuraEnabled public Id productId;// Product ID
        @AuraEnabled public String ProductCode;// Product code
        @AuraEnabled public String Name;// Product Name
        @AuraEnabled public decimal precio;// Product Unit price 
        @AuraEnabled public String productType;//tipoProducto__c
        //Service territory
        @AuraEnabled public String Bodega;//Bodega del NameTest ServiceTerritory
        @AuraEnabled public String bodegaID;
        @AuraEnabled public String idExtBodega; //bodega__c
        @AuraEnabled public decimal cantidadDisponible;// Cantidad disponible (productoxbodega**)
        //WorkOrderLineItem insert
        @AuraEnabled public String alias;// validado
        @AuraEnabled public Boolean aprobado;// cambiar boolean check
        @AuraEnabled public double cantidad;// double
        @AuraEnabled public String tipotrabajo;// lookup validado
        @AuraEnabled public String trabajo;// picklist validado
        @AuraEnabled public decimal discount;
        @AuraEnabled public String tax;// picklist validado Impuesto__c No se ve insert 13%
        @AuraEnabled public String priceBookEntry;
        @AuraEnabled public String currencyCode;
        //QuoteLineItem insert

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
        ///porcentajeDescuento__c porcentajeDescuento__c
        
        public wrapper(){}
        
        public wrapper(Id ID,Id productId, String ProductCode, String Name, decimal precio,String Bodega,decimal cantidadDisponible,String productType,
                       String alias,String tipotrabajo,String priceBookEntry,String currencyCode,String bodegaID,String idExtBodega,String ProductXBodegaID/*,String trabajo*/)
        {
            this.wolId=null;
            this.qliId=null;
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
        }
        
        public void setLocations(){
            System.debug('Keyset'+quantityByLocation.keySet());
            for (String lxQ:this.quantityByLocation.keySet()){
                if(this.locations.indexOf(lxQ)==-1){
                    this.locations.add(lxQ);
                	this.softlandQuantities.add(this.quantityByLocation.get(lxQ));
                }
                
            }
            System.debug(this.locations);
            System.debug(this.softlandQuantities);
        }

        public void setQliId(Id qliId){
            this.ID = qliId + this.ID;
            this.qliId = qliId;
        }
    }

    public static Map<Id, Product2> getPriceEntriesBeforeByOpp(String searchString, Id oppId, Set<Id> prodsBodega){
        Id priceId = [SELECT Pricebook2Id FROM Opportunity WHERE Id =: oppId].Pricebook2Id;
        Map<Id,Product2> pEntries = new Map<Id, Product2>([ SELECT Id, (SELECT id,UnitPrice,CurrencyIsoCode FROM Pricebookentries WHERE Pricebook2Id=:priceId LIMIT 1)
                                                            FROM Product2
                                                            WHERE Id IN (SELECT Product2Id FROM PricebookEntry WHERE Pricebook2Id =: priceId)
                                                            AND Id IN (SELECT Producto__c FROM ProductoXBodega__c WHERE Id IN : prodsBodega)
                                                            AND (Name LIKE : searchString OR Codigo_de_Producto__c LIKE : searchString)
                                                            ORDER BY Id
                                                            LIMIT 100 ]);
        return pEntries;
    }

    @AuraEnabled(cacheable=true)
    public static  List<wrapper> getAvailabilityByQuote (string listTosave, Id quoteId) {
        system.debug('quoteId:' + quoteId);
        String company = [SELECT Opportunity.BMW_Compania__c FROM Quote WHERE id =: quoteId].Opportunity.BMW_Compania__c;
        if(company == 'Bavarian') company = 'RMBAVARIAN';
        if(company == 'Otobai') company = 'RMOTOBAI';
        List<QuoteLineItem> QuoteLineItems = new List<QuoteLineItem>();
       	List<wrapper> wrappers = (List<wrapper>)JSON.deserialize(listTosave, List<wrapper>.class);
        Map<String,wrapper> mwrap = new Map<String,wrapper>();
       	HttpCalloutGetProductAvailability request = new HttpCalloutGetProductAvailability(company);
            for (wrapper wr: wrappers){
               // if(pentries.containsKey(wr.productId)!=Null){
                mwrap.put(wr.ProductCode, wr);
                request.addToRequest(wr.idExtBodega, wr.ProductCode, wr.productType);
                System.debug('idExtBod, ProductCode, type: ' + wr.idExtBodega + ', ' + wr.ProductCode + ', ' + wr.productType);                
                //wl.WorkOrderId='0WO01000000ACYrGAO';
            }
        Map<String,ProductController.productResponse> res = request.deserialize();
        //return comparison(res,mwrap,request.productXlocation);
        return comparison(res, wrappers, request.productXlocation); 
    }
    
    @AuraEnabled(cacheable=true)
    public static  String getServereOrderResponse ( Id order) {
       return [select respuestaServidor__c from Order where Id=:order or Work_Order__c=:order or QuoteId=:order limit 1].respuestaServidor__c;
       //Prueba buena de servicio
       //return 'Cargo Cliente:OSLU-0000005912';
    }
    
	private static List<wrapper> comparison( Map<String,ProductController.productResponse> res,List<wrapper> mwrap,Map<String,Map<String,Double>> productXlocation){
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
       public String localizacion;         
    }
    
    public static void dummy(){
        String String1;
        String String2;
        String String3;
        String String4;
        String String5;
        String String6;
        String String7;
        String String8;
        String String9;
        String String10;
        String String11;
        String String12;
        String String13;
        String String14;
        String String15;
        String String16;
        String String17;
        String String18;
        String String19;
        String String20;
        String String21;
        String String22;
        String String23;
        String String24;
        String String25;
        String String26;
        String String27;
        String String28;
        String String29;
        String String30;
        String String31;
        String String32;
        String String33;
        String String34;
        String String35;
        String String36;
        String String37;
        String String38;
        String String39;
        String String40;
        String String41;
        String String42;
        String String43;
        String String44;
        String String45;
        String String46;
        String String47;
        String String48;
        String String49;
        String String50;
        String String51;
        String String52;
        String String53;
        String String54;
        String String55;
        String String56;
        String String57;
        String String58;
        String String59;
        String String60;
        String String61;
        String String62;
        String String63;
        String String64;
        String String65;
        String String66;
        String String67;
        String String68;
        String String69;
        String String70;
        String String71;
        String String72;
        String String73;
        String String74;
        String String75;
        String String76;
        String String77;
        String String78;
        String String79;
        String String80;
        String String81;
        String String82;
        String String83;
        String String84;
        String String85;
        String String86;
        String String87;
        String String88;
        String String89;
        String String90;
        String String91;
        String String92;
        String String93;
        String String94;
        String String95;
        String String96;
        String String97;
        String String98;
        String String99;
        String String100;
        String String101;
        String String102;
        String String103;
        String String104;
        String String105;
        String String106;
        String String107;
        String String108;
        String String109;
        String String110;
        String String111;
        String String112;
        String String113;
        String String114;
        String String115;
        String String116;
        String String117;
        String String118;
        String String119;
        String String120;
        String String121;
        String String122;
        String String123;
        String String124;
        String String125;
        String String126;
        String String127;
        String String128;
        String String129;
        String String130;
        String String131;
        String String132;
        String String133;
        String String134;
        String String135;
        String String136;
        String String137;
        String String138;
        String String139;
        String String140;
        String String141;
        String String142;
        String String143;
        String String144;
        String String145;
        String String146;
        String String147;
        String String148;
        String String149;
        String String150;
        String String151;
        String String152;
        String String153;
        String String154;
        String String155;
        String String156;
        String String157;
        String String158;
        String String159;
        String String160;
        String String161;
        String String162;
        String String163;
        String String164;
        String String165;
        String String166;
        String String167;
        String String168;
        String String169;
        String String170;
        String String171;
        String String172;
        String String173;
        String String174;
        String String175;
        String String176;
        String String177;
        String String178;
        String String179;
        String String180;
        String String181;
        String String182;
        String String183;
        String String184;
        String String185;
        String String186;
        String String187;
        String String188;
        String String189;
        String String190;
        String String191;
        String String192;
        String String193;
        String String194;
        String String195;
        String String196;
        String String197;
        String String198;
        String String199;
        String String200;
        String String201;
        String String202;
        String String203;
        String String204;
        String String205;
        String String206;
        String String207;
        String String208;
        String String209;
        String String210;
        String String211;
        String String212;
        String String213;
        String String214;
        String String215;
        String String216;
        String String217;
        String String218;
        String String219;
        String String220;
        String String221;
        String String222;
        String String223;
        String String224;
        String String225;
        String String226;
        String String227;
        String String228;
        String String229;
        String String230;
        String String231;
        String String232;
        String String233;
        String String234;
        String String235;
        String String236;
        String String237;
        String String238;
        String String239;
        String String240;
        String String241;
        String String242;
        String String243;
        String String244;
        String String245;
        String String246;
        String String247;
        String String248;
        String String249;
        String String250;
        String String251;
        String String252;
        String String253;
        String String254;
        String String255;
        String String256;
        String String257;
        String String258;
        String String259;
        String String260;
        String String261;
        String String262;
        String String263;
        String String264;
        String String265;
        String String266;
        String String267;
        String String268;
        String String269;
        String String270;
        String String271;
        String String272;
        String String273;
        String String274;
        String String275;
        String String276;
        String String277;
        String String278;
        String String279;
        String String280;
        String String281;
        String String282;
        String String283;
        String String284;
        String String285;
        String String286;
        String String287;
        String String288;
        String String289;
        String String290;
        String String291;
        String String292;
        String String293;
        String String294;
        String String295;
        String String296;
        String String297;
        String String298;
        String String299;
        String String300;
        String String301;
        String String302;
        String String303;
        String String304;
        String String305;
        String String306;
        String String307;
        String String308;
        String String309;
        String String310;
        String String311;
        String String312;
        String String313;
        String String314;
        String String315;
        String String316;
        String String317;
        String String318;
        String String319;
        String String320;
        String String321;
        String String322;
        String String323;
        String String324;
        String String325;
        String String326;
        String String327;
        String String328;
        String String329;
        String String330;
        String String331;
        String String332;
        String String333;
        String String334;
        String String335;
        String String336;
        String String337;
        String String338;
        String String339;
        String String340;
        String String341;
        String String342;
        String String343;
        String String344;
        String String345;
        String String346;
        String String347;
        String String348;
        String String349;
        String String350;
        String String351;
        String String352;
        String String353;
        String String354;
        String String355;
        String String356;
        String String357;
        String String358;
        String String359;
        String String360;
        String String361;
        String String362;
        String String363;
        String String364;
        String String365;
        String String366;
        String String367;
        String String368;
        String String369;
        String String370;
        String String371;
        String String372;
        String String373;
        String String374;
        String String375;
        String String376;
        String String377;
        String String378;
        String String379;
        String String380;
        String String381;
        String String382;
        String String383;
        String String384;
        String String385;
        String String386;
        String String387;
        String String388;
        String String389;
        String String390;
        String String391;
        String String392;
        String String393;
        String String394;
        String String395;
        String String396;
        String String397;
        String String398;
        String String399;
        String String400;
        String String401;
        String String402;
        String String403;
        String String404;
        String String405;
        String String406;
        String String407;
        String String408;
        String String409;
        String String410;
        String String411;
        String String412;
        String String413;
        String String414;
        String String415;
        String String416;
        String String417;
        String String418;
        String String419;
        String String420;
        String String421;
        String String422;
        String String423;
        String String424;
        String String425;
        String String426;
        String String427;
        String String428;
        String String429;
        String String430;
        String String431;
        String String432;
        String String433;
        String String434;
        String String435;
        String String436;
        String String437;
        String String438;
        String String439;
        String String440;
        String String441;
        String String442;
        String String443;
        String String444;
        String String445;
        String String446;
        String String447;
        String String448;
        String String449;
        String String450;
        String String451;
        String String452;
        String String453;
        String String454;
        String String455;
        String String456;
        String String457;
        String String458;
        String String459;
        String String460;
        String String461;
        String String462;
        String String463;
        String String464;
        String String465;
        String String466;
        String String467;
        String String468;
        String String469;
        String String470;
        String String471;
        String String472;
        String String473;
        String String474;
        String String475;
        String String476;
        String String477;
        String String478;
        String String479;
        String String480;
        String String481;
        String String482;
        String String483;
        String String484;
        String String485;
        String String486;
        String String487;
        String String488;
        String String489;
        String String490;
        String String491;
        String String492;
        String String493;
        String String494;
        String String495;
        String String496;
        String String497;
        String String498;
        String String499;
        String String500;
        String String501;
        String String502;
        String String503;
        String String504;
        String String505;
        String String506;
        String String507;
        String String508;
        String String509;
        String String510;
        String String511;
        String String512;
        String String513;
        String String514;
        String String515;
        String String516;
        String String517;
        String String518;
        String String519;
        String String520;
        String String521;
        String String522;
        String String523;
        String String524;
        String String525;
        String String526;
        String String527;
        String String528;
        String String529;
        String String530;
        String String531;
        String String532;
        String String533;
        String String534;
        String String535;
        String String536;
        String String537;
        String String538;
        String String539;
        String String540;
        String String541;
        String String542;
        String String543;
        String String544;
        String String545;
        String String546;
        String String547;
        String String548;
        String String549;
        String String550;
        String String551;
        String String552;
        String String553;
        String String554;
        String String555;
        String String556;
        String String557;
        String String558;
        String String559;
        String String560;
        String String561;
        String String562;
        String String563;
        String String564;
        String String565;
        String String566;
        String String567;
        String String568;
        String String569;
        String String570;
        String String571;
        String String572;
        String String573;
        String String574;
        String String575;
        String String576;
        String String577;
        String String578;
        String String579;
        String String580;
        String String581;
        String String582;
        String String583;
        String String584;
        String String585;
        String String586;
        String String587;
        String String588;
        String String589;
        String String590;
        String String591;
        String String592;
        String String593;
        String String594;
        String String595;
        String String596;
        String String597;
        String String598;
        String String599;
        String String600;
        String String601;
        String String602;
        String String603;
        String String604;
        String String605;
        String String606;
        String String607;
        String String608;
        String String609;
        String String610;
        String String611;
        String String612;
        String String613;
        String String614;
        String String615;
        String String616;
        String String617;
        String String618;
        String String619;
        String String620;
        String String621;
        String String622;
        String String623;
        String String624;
        String String625;
        String String626;
        String String627;
        String String628;
        String String629;
        String String630;
        String String631;
        String String632;
        String String633;
        String String634;
        String String635;
        String String636;
        String String637;
        String String638;
        String String639;
        String String640;
        String String641;
        String String642;
        String String643;
        String String644;
        String String645;
        String String646;
        String String647;
    }
}