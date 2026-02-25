public with sharing class BMW_QuotePDFController_2 {
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
    public String TotalTexto {get;set;}
    public List<QuoteLineItem> ordenaTrabajos {get;set;}
    public Account AccountFac {get;set;}
    public Cambio_de_Propietario__c cambioPropietario {get; set;}
    

    public BMW_QuotePDFController_2(Apexpages.StandardController controller) {
        String recordId = controller.getId();
        getData(recordId);
    }
    public void getData(String recordId) {
        
        cot = [select Account.Cedula__c,Account.Phone,Account.PersonMobilePhone,BMW_CodigoDeProducto__c,BMW_VerDisponibilidad__c,
               Cuenta_de_facturaci_n2__r.Name,
               Cuenta_de_facturaci_n2__r.Cedula__c,
               Cuenta_de_facturaci_n2__r.Phone,
               Cuenta_de_facturaci_n2__r.Type,
               
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
        Opportunity.WorkOrder__r.WorkOrderNumber,
        Opportunity.BMW_PlacaDeVehiculoOElVIN__r.marca__c,
        Account.Name,Account.Pais__c,Account.Provincia__pr.Name,
        Account.Canton__r.Name,Account.Distrito__r.Name,Account.Barrio__c,Account.Calle__c,
        Account.Direccion_Residencial__c,Account.Direccion__c,Account.Type,
        id,Email,Description,Discount,ShippingAddress,CurrencyIsoCode,
        AdditionalAddress,ShippingHandling,Status,BillingAddress,Fax,
        ExpirationDate,Tax,AdditionalName,ShippingName,
        BillingName,QuoteToName,Name,QuoteNumber,TotalPrice,QuoteToAddress,
        Subtotal,Phone,GrandTotal,CreatedDate,OwnerId, Orden_De_Trabajo__c,SubWithDiscount__c,SumTotal__c,Cuenta_de_facturaci_n2__c,
        Contact__c, Contact__r.Cedula__c,Contact__r.Phone,Opp_Reccord_Type__c,
        (select id,Quantity,Description,Discount,UnitPrice,TotalPrice,BMW_Producto_Custom__c,
        BMW_TipoDeArticulo__c, Product2.Name,Product2.Codigo_de_Producto__c,BMW_Dispinible__c
                                                                from QuoteLineItems 
                                                                ) 
               from Quote
               where id =: recordId 
               LIMIT 1];
        
        
        ordenaTrabajos = [select id,Quantity,Description,Discount,UnitPrice,TotalPrice,BMW_Producto_Custom__c,
        BMW_TipoDeArticulo__c, Product2.Name,Product2.Codigo_de_Producto__c,BMW_Dispinible__c
                                                                from QuoteLineItem where QuoteId =: recordId  order by createddate ASC];
        
        List<Cambio_de_Propietario__c> cambios = [SELECT Id, Asset__c, Case__c, Cuenta_Anterior__c, Cuenta_Nueva__c, Estado__c 
             FROM Cambio_de_Propietario__c WHERE Asset__c = :cot.Opportunity.BMW_PlacaDeVehiculoOElVIN__c AND Estado__c ='Pendiente'];

          if (!cambios.isEmpty()) {
          cambioPropietario = cambios[0];
          } else {
          cambioPropietario = null;
          }
        
        List<QuoteLineItem> listTipos = [Select Id From QuoteLineItem Where Id =:recordId Order by createddate ASC];
        
        List<WorkOrder> OT = new List<WorkOrder>();
        try {
               OT = [Select Id, AssetId,Kilometros__c From WorkOrder Where AssetId =: cot.Opportunity.BMW_PlacaDeVehiculoOElVIN__c ORDER BY CreatedDate DESC limit 1];
        } catch(DmlException e) {
            
        }
            
                if(OT.size() > 0){
                    if(OT[0].Kilometros__c != null && OT[0].Kilometros__c != 0){kilometros= OT[0].Kilometros__c;}else{kilometros=cot.Opportunity.BMW_PlacaDeVehiculoOElVIN__r.Kilometros__c;}
                }else{kilometros=cot.Opportunity.BMW_PlacaDeVehiculoOElVIN__r.Kilometros__c;}
                if (cot.GrandTotal != null && cot.GrandTotal >= 0) {
                   Decimal centavoDecimal;
               centavoDecimal = (cot.SumTotal__c - Integer.valueOf(cot.SumTotal__c))*100;
               Centavos = Integer.valueOf(centavoDecimal);
                Long n = cot.SumTotal__c.longValue();
                TotalTexto = NumberToWord.english_number(n);
            } else {
                TotalTexto = null;
            }
            
        system.debug('cot'+cot);
        montoMaterial = 0;
        montoManoDeObra = 0;
        montoSubcontrato = 0;
        montoPintura = 0;
        montoVarios = 0;
                montoVarios2 = 0;
        montoPintura2 = 0;

        System.debug('QuoteLineItems '+cot.QuoteLineItems);
        if(cot.QuoteLineItems != null && cot.QuoteLineItems.size()>0){
            for(QuoteLineItem qli : cot.QuoteLineItems){
                System.debug('qli.BMW_TipoDeArticulo__c '+qli.BMW_TipoDeArticulo__c);
                if(qli.BMW_TipoDeArticulo__c == 'Materiales'){montoMaterial = montoMaterial +qli.TotalPrice;
                }
                if(qli.BMW_TipoDeArticulo__c == 'Mano de Obra'){montoManoDeObra = montoManoDeObra +qli.TotalPrice;
                     System.debug('qli.TotalPrice '+qli.TotalPrice);
                    System.debug('montoManoDeObra '+montoManoDeObra);
                }
                if(qli.BMW_TipoDeArticulo__c == 'Subcontrato'){montoSubcontrato = montoSubcontrato +qli.TotalPrice;
                }
                if(qli.BMW_TipoDeArticulo__c == 'Pintura'){montoPintura = montoPintura +qli.TotalPrice;
                }
                if(qli.BMW_TipoDeArticulo__c == 'Varios'){montoVarios = montoVarios +qli.TotalPrice;
                }
            }
        }  
    }
}