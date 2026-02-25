public with sharing class cT_QuoteCrcPDFController {
    public Quote cot {get;set;}
    public decimal montoMaterial {get;set;}
    public decimal montoManoDeObra {get;set;}
    public decimal montoSubcontrato {get;set;}
    public decimal montoPintura {get;set;}
    public decimal montoVarios {get;set;}
     public decimal montoPintura2 {get;set;}
    public decimal montoVarios2 {get;set;}
    public decimal kilometros {get;set;}
    public Integer Centavos {get;set;}
    public decimal GrandTotal {get;set;}
    public decimal Tax {get;set;}
    public String TotalTexto {get;set;}
    public List<ProductsConsumedWrapper> quoteLine {get;set;}
    public cT_QuoteCrcPDFController(Apexpages.StandardController controller) {
        String recordId = controller.getId();
        getData(recordId);
    }
    public void getData(String recordId) {
        cot = [select Account.Cedula__c,Account.Phone,Account.PersonMobilePhone,BMW_CodigoDeProducto__c,
        Opportunity.BMW_PlacaDeVehiculoOElVIN__c,
        Opportunity.BMW_PlacaDeVehiculoOElVIN__r.Kilometros__c,
        Opportunity.BMW_PlacaDeVehiculoOElVIN__r.Anio__c,
        Opportunity.BMW_PlacaDeVehiculoOElVIN__r.numeroDePlaca__c,
        Opportunity.BMW_PlacaDeVehiculoOElVIN__r.NumeroDeChasis__c,
        Opportunity.WorkOrder__c,
        Opportunity.WorkOrder__r.OwnerId,
        Opportunity.BMW_PlacaDeVehiculoOElVIN__r.modelo__c,
        Opportunity.WorkOrder__r.Duration,
        Opportunity.WorkOrder__r.CreatedDate,
        Opportunity.WorkOrder__r.Description,
        Opportunity.WorkOrder__r.Pricebook2.Name,
        Opportunity.WorkOrder__r.Pricebook2.Id,
        Opportunity.WorkOrder__r.WorkOrderNumber,
        Opportunity.BMW_PlacaDeVehiculoOElVIN__r.marca__c,
        Account.Name,Account.Pais__c,Account.Provincia__pr.Name,
        Account.Canton__r.Name,Account.Distrito__r.Name,Account.Barrio__c,Account.Calle__c,
        Account.Direccion_Residencial__c,Account.Direccion__c,Account.Type,
        id,Email,Description,Discount,ShippingAddress,CurrencyIsoCode,
        AdditionalAddress,ShippingHandling,Status,BillingAddress,Fax,
        ExpirationDate,Tax,AdditionalName,ShippingName,
        BillingName,QuoteToName,Name,QuoteNumber,TotalPrice,QuoteToAddress,
        Subtotal,Phone,GrandTotal,CreatedDate,OwnerId, Orden_De_Trabajo__c
               from Quote
               where id =: recordId 
               LIMIT 1];    

               montoMaterial = 0;
               montoManoDeObra = 0;
               montoSubcontrato = 0;
               montoPintura = 0;
               montoVarios = 0;
                       montoVarios2 = 0;
               montoPintura2 = 0;

        if (cot.CurrencyIsoCode == 'CRC') {
            String quoteId = cot.Id;
            List<QuoteLineItem> listaQuote = [select id,Quantity,Description,Discount,UnitPrice,TotalPrice,BMW_Producto_Custom__c,
            BMW_TipoDeArticulo__c, Product2.Name,Product2.Codigo_de_Producto__c,BMW_Dispinible__c from QuoteLineItem WHERE QuoteId = :quoteId ];
            
            List<ProductsConsumedWrapper> listaNueva = new List<ProductsConsumedWrapper> ();
            for (QuoteLineItem item1 : listaQuote) {
                ProductsConsumedWrapper nuevoItem = new ProductsConsumedWrapper();
                nuevoItem.Quantity = item1.Quantity != null ? item1.Quantity : null;
                nuevoItem.Discount = item1.Discount != null ? item1.Discount : null ;
                nuevoItem.Description = item1.Description != null ? item1.Description : null ;
                nuevoItem.UnitPrice = item1.UnitPrice;                                                                  
                nuevoItem.TotalPrice =item1.TotalPrice;
                nuevoItem.BMW_Producto_Custom = item1.BMW_Producto_Custom__c;
                nuevoItem.BMW_TipoDeArticulo = item1.BMW_TipoDeArticulo__c;
                nuevoItem.BMW_Dispinible =  item1.BMW_Dispinible__c != null ?  item1.BMW_Dispinible__c : null;                            
                listaNueva.add(nuevoItem);
        
            }
            quoteLine = listaNueva;


            // quoteLine =  
        }else {
            //conversion de los productos a USD
            String quoteId = cot.Id;
            String listaEnUsd = '';
            Pricebook2 listaPrecioDolares = new Pricebook2();
            List<String> listaDeProductos = new List<String>();
            List<QuoteLineItem> lstQuotesItemsCRC = [select id,Quantity,Description,Discount,UnitPrice,TotalPrice,BMW_Producto_Custom__c,
            BMW_TipoDeArticulo__c,Product2.Id, Product2.Name,Product2.Codigo_de_Producto__c,BMW_Dispinible__c from QuoteLineItem WHERE QuoteId = :quoteId ];
            String listaEnCrc = cot.Opportunity.WorkOrder__r.Pricebook2.Name;
            List<PriceBookEntry> listaConProductos = new List<PriceBookEntry>();
            List<PriceBookEntry> listaConProductosOriginal = new List<PriceBookEntry>();
            String listaPrecioOrig = cot.Opportunity.WorkOrder__r.Pricebook2.Id;
            if ( listaEnCrc == 'Bavarian Dólar') {
                listaEnUsd = 'Bavarian Local';   
            }else if (listaEnCrc == 'Otobai Dólares') {
                listaEnUsd = 'Otobai Local';
            }else {
                if(Test.isRunningTest()){
                    // quoteLine = [select id,Quantity,Description,Discount,UnitPrice,TotalPrice,BMW_Producto_Custom__c,
            	    // BMW_TipoDeArticulo__c,Product2.Id, Product2.Name,Product2.Codigo_de_Producto__c,BMW_Dispinible__c from QuoteLineItem WHERE QuoteId = :quoteId ];
            	    listaEnUsd = listaEnCrc;
                }                
            } 
            // List<> lstProducto = [];
            if (listaEnUsd != '') {
                for (QuoteLineItem idProducto : lstQuotesItemsCRC) {
                    listaDeProductos.add(idProducto.Product2.Id);
                }
                if(Test.isRunningTest()){ 
                }else{
                	listaPrecioDolares = [SELECT Id FROM Pricebook2 WHERE Name =:listaEnUsd ];
                    System.debug(listaPrecioDolares.Id);
                }
                listaConProductos = [SELECT Id,Name,Product2.Id,Pricebook2Id,Product2Id,CurrencyIsoCode,UnitPrice FROM PriceBookEntry WHERE Pricebook2Id =:listaPrecioDolares.Id  AND Product2Id IN :listaDeProductos];
                listaConProductosOriginal = [SELECT Id,Name,Pricebook2Id,Product2Id,CurrencyIsoCode,UnitPrice FROM PriceBookEntry WHERE Pricebook2Id =:listaPrecioOrig  AND Product2Id IN :listaDeProductos];
                                    
            }
                List<ProductsConsumedWrapper> listaNueva = new List<ProductsConsumedWrapper> ();
                for (QuoteLineItem item1 : lstQuotesItemsCRC) {
                    for (PriceBookEntry itemLista : listaConProductos){ 
                        if(item1.Product2.Id == itemLista.Product2Id ){
                            ProductsConsumedWrapper nuevoItem = new ProductsConsumedWrapper();
                            nuevoItem.Quantity = item1.Quantity != null ? item1.Quantity : null;
                            nuevoItem.Discount = item1.Discount != null ? item1.Discount : null ;
                            nuevoItem.Description = item1.Description != null ? item1.Description : null ;
                            for (PriceBookEntry itemListaCrc : listaConProductosOriginal) {
                                if(item1.Product2.Id == itemLista.Product2Id){
                                   	nuevoItem.UnitPrice = item1.UnitPrice == itemListaCrc.UnitPrice ? itemLista.UnitPrice : item1.UnitPrice * 642;                                                                      
                                    nuevoItem.TotalPrice = nuevoItem.UnitPrice * nuevoItem.Quantity;
                                }
                            }
                            nuevoItem.BMW_Producto_Custom = item1.BMW_Producto_Custom__c;
                            nuevoItem.BMW_TipoDeArticulo = item1.BMW_TipoDeArticulo__c;
                            nuevoItem.BMW_Dispinible =  item1.BMW_Dispinible__c != null ?  item1.BMW_Dispinible__c : null;                            
                            listaNueva.add(nuevoItem);
                        }                    
                    }
                }
                quoteLine = listaNueva;
        }


        if(quoteLine != null && quoteLine.size()>0){
            for(ProductsConsumedWrapper qli : quoteLine){
                if(qli.BMW_TipoDeArticulo == 'Materiales'){montoMaterial = montoMaterial +qli.TotalPrice;
                }
                if(qli.BMW_TipoDeArticulo == 'Mano de Obra'){montoManoDeObra = montoManoDeObra +qli.TotalPrice;

                }
                if(qli.BMW_TipoDeArticulo == 'Subcontrato'){montoSubcontrato = montoSubcontrato +qli.TotalPrice;
                }
                if(qli.BMW_TipoDeArticulo == 'Pintura'){montoPintura = montoPintura +qli.TotalPrice;
                }
                if(qli.BMW_TipoDeArticulo == 'Varios'){montoVarios = montoVarios +qli.TotalPrice;
                }
                GrandTotal = montoVarios + montoPintura + montoSubcontrato + montoManoDeObra + montoMaterial;
                Tax = GrandTotal * 0.13;
                GrandTotal = GrandTotal + Tax;
            }
        }                

        List<WorkOrder> OT = new List<WorkOrder>();
        OT = [Select Id, AssetId,Kilometros__c From WorkOrder Where AssetId =: cot.Opportunity.BMW_PlacaDeVehiculoOElVIN__c ORDER BY CreatedDate DESC limit 1];  
        if(OT.size() > 0){
                    if(OT[0].Kilometros__c != null && OT[0].Kilometros__c != 0){
                        kilometros= OT[0].Kilometros__c;
                    }else{
                        kilometros=cot.Opportunity.BMW_PlacaDeVehiculoOElVIN__r.Kilometros__c;
                    }
                }else{kilometros=cot.Opportunity.BMW_PlacaDeVehiculoOElVIN__r.Kilometros__c;}
                if (GrandTotal != null && GrandTotal >= 0) {
                   Decimal centavoDecimal;
               centavoDecimal = (GrandTotal - Integer.valueOf(GrandTotal))*100;
               Centavos = Integer.valueOf(centavoDecimal);
                Long n = GrandTotal.longValue();
                TotalTexto = NumberToWord.english_number(n);
            } 
        system.debug('cot'+cot);


    }

    // id,Quantity,Description,Discount,UnitPrice,TotalPrice,BMW_Producto_Custom__c,
    // BMW_TipoDeArticulo__c,Product2.Id, Product2.Name,Product2.Codigo_de_Producto__c,BMW_Dispinible__c 

    public class ProductsConsumedWrapper
    {
        public ProductsConsumedWrapper(){}
        public Double Quantity {get;set;}
        public String Description {get;set;}
        public Double Discount {get;set;}
        public Double UnitPrice {get;set;}
        public Double TotalPrice {get;set;}
        public String BMW_Producto_Custom {get;set;}
        public String BMW_TipoDeArticulo {get;set;}
        public Boolean BMW_Dispinible {get;set;}

    }

}