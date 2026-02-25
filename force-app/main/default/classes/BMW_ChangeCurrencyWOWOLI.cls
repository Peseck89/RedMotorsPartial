public with sharing class BMW_ChangeCurrencyWOWOLI {
  public WorkOrder ot {get;set;}
     public Boolean cambiado { get; set; }
    public Boolean comienzo { get; set; }
    public Boolean cargando { get; set; }
    public Boolean boton { get; set; }

    public BMW_ChangeCurrencyWOWOLI(Apexpages.StandardController controller) {
        comienzo = true;
        cambiado = false;
        boton = true;
        cargando = false;
        String recordId = controller.getId();
        ot = (WorkOrder)controller.getRecord();
    }
    public PageReference changeCurrency() {
        boton = false;
        cargando = true;
        //WorkOrder wo = [Select Id From WorkOrder where id =: ot.Id];
        System.debug('ot moneda1: '+ot.CurrencyIsoCode);
        System.debug('ot pricebook1: '+ot.Pricebook2Id);
        System.debug('ot: '+ot);
        Pricebook2 pbOTinicial = [Select Id, Name From Pricebook2 Where Id =: ot.Pricebook2Id];
        System.debug('pbOTinicial '+pbOTinicial.Name);
        String PriceBookName;
        Decimal dolarColon = 598.13;
        Decimal tipoCambio = 1; 
        if(ot.CurrencyIsoCode == 'CRC'){
            if(pbOTinicial.Name == 'Otobai Local'){
                PriceBookName = 'Otobai Dólares';
            }
            else{
                PriceBookName = 'Bavarian Dólar';
            }
            tipoCambio = 1/dolarColon;
            ot.CurrencyIsoCode = 'USD';
        }
        else{
            if(pbOTinicial.Name == 'Otobai Dólares'){
                PriceBookName = 'Otobai Local';
            }
            else{
                PriceBookName = 'Bavarian Local';
            }
            tipoCambio = dolarColon;
            ot.CurrencyIsoCode = 'CRC';
        }
                System.debug('PriceBookName '+PriceBookName);

        if(!Test.isRunningTest()){
            Pricebook2 pbOTFinal = [Select Id, Name From Pricebook2 Where Name =: PriceBookName];
          ot.Pricebook2Id = pbOTFinal.Id;
        }
        System.debug('ot moneda2: '+ot.CurrencyIsoCode);
        System.debug('ot pricebook2: '+ot.Pricebook2Id);
        //List<WorkOrderLineItem> woliRelated = new List<WorkOrderLineItem>();
        String objectName = 'WorkOrderLineItem'; 
    String query = 'SELECT';
    Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
        for(String s : objectFields.keySet()) {
         query += ' ' + s + ', ';
    }
        System.debug('query ultimo' +query.subString(query.Length()-1,query.Length()));
        if (query.subString(query.Length()-2,query.Length()) == ', '){
            System.debug('query eliminando coma1');
        query = query.subString(0,query.Length()-2);
    }
        query += ' FROM ' + objectName;
    query += ' WHERE WorkOrderId = \''+ot.Id+'\'';
        System.debug('query 1' +(query.subString(query.Length()-100,query.Length())));
    System.debug('query '+query);
        List<WorkOrderLineItem> woliRelated = database.query(query);
        List<WorkOrderLineItem> newWoliRelated = new List<WorkOrderLineItem>();
        Map<Id,Id> mapWoliIdProductId = new Map<Id,Id>();
        Map<Id,Id> mapProductIdPriceBookEntryId = new Map<Id,Id>();
        Map<Id,Decimal> mapProductPrecio = new Map<Id,Decimal>();
        Set<Id> productIds = new Set<Id>();
        if(woliRelated.size() > 0){
            System.debug('woliRelated: '+woliRelated);
            for(WorkOrderLineItem woli : woliRelated){
                mapWoliIdProductId.put(woli.Id,woli.Product2Id);
                productIds.add(woli.Product2Id);
            }
            List<PriceBookEntry> listpbe = [Select Id,Product2Id,UnitPrice From PriceBookEntry Where Product2Id IN: productIds AND Pricebook2Id =: ot.Pricebook2Id];
            System.debug('listpbe '+listpbe);
            for(PriceBookEntry pbe : listpbe){
                mapProductPrecio.put(pbe.Product2Id,pbe.UnitPrice);
                mapProductIdPriceBookEntryId.put(pbe.Product2Id,pbe.Id);
            }
            delete woliRelated;
            update ot;
            System.debug('ot: '+ot);
            for(WorkOrderLineItem woli : woliRelated){
                System.debug('woli: '+woli);
                System.debug('woli currency: '+woli.CurrencyIsoCode);
                WorkOrderLineItem newwoli = new WorkOrderLineItem();
                newwoli.WorkOrderId = ot.Id;
                newwoli.Alias_Articulo__c = woli.Alias_Articulo__c;
                newwoli.Quantity = woli.Quantity;
                newwoli.Bodega__c = woli.Bodega__c;
                newwoli.Description = woli.Description;
                newwoli.aprobado__c = woli.aprobado__c;
                newwoli.Aseguradora__c = woli.Aseguradora__c;
                newwoli.AssetId = woli.AssetId;
                newwoli.AssetWarrantyId = woli.AssetWarrantyId;
                
                newwoli.AvailableQuantity__c = woli.AvailableQuantity__c;
                newwoli.centroCosto__c = woli.centroCosto__c;
                newwoli.City = woli.City;
                newwoli.Comentario__c = woli.Comentario__c;
                newwoli.Country = woli.Country;  
                newwoli.created_From__c = woli.created_From__c;
                newwoli.cuentaContable__c = woli.cuentaContable__c;
                newwoli.Description = woli.Description;
                
                newwoli.Discount = woli.Discount;
                newwoli.Duration = woli.Duration;
                newwoli.DurationType = woli.DurationType;
                newwoli.EndDate = woli.EndDate;
                newwoli.especificacionesTaller__c = woli.especificacionesTaller__c;
                newwoli.FSL__IsFillInCandidate__c = woli.FSL__IsFillInCandidate__c;
                newwoli.FSL__VisitingHours__c = woli.FSL__VisitingHours__c;
                newwoli.GeocodeAccuracy = woli.GeocodeAccuracy;
                newwoli.grupo__c = woli.grupo__c;                
                newwoli.Impuesto2__c = woli.Impuesto2__c;
                newwoli.Impuesto__c = woli.Impuesto__c; 
                
                newwoli.Latitude = woli.Latitude;
                newwoli.Localizacion__c = woli.Localizacion__c;
                newwoli.LocationId = woli.LocationId;
                newwoli.Longitude = woli.Longitude;
                newwoli.MaintenancePlanId = woli.MaintenancePlanId;
                newwoli.MinimumCrewSize = woli.MinimumCrewSize;
                newwoli.OrderId = woli.OrderId;
                newwoli.OriginalOrderItem__c = woli.OriginalOrderItem__c;
                newwoli.ParentWorkOrderLineItemId = woli.ParentWorkOrderLineItemId;
                newwoli.porcentajeCargoAseguradora__c = woli.porcentajeCargoAseguradora__c;
                newwoli.porcentajeCargoCliente__c = woli.porcentajeCargoCliente__c;
                newwoli.porcentajeCargoGarantia__c = woli.porcentajeCargoGarantia__c;
                newwoli.porcentajeCargoInterno__c = woli.porcentajeCargoInterno__c;
                newwoli.porcentajeDescuento__c = woli.porcentajeDescuento__c;
                newwoli.porcentajeTiposDeCargo__c = woli.porcentajeTiposDeCargo__c;
                
                newwoli.PostalCode = woli.PostalCode;
                newwoli.PrecioVenta__c = woli.PrecioVenta__c;
                newwoli.PricebookEntryId = woli.PricebookEntryId;
                newwoli.Priority = woli.Priority;
                newwoli.Product2Id = woli.Product2Id;
                newwoli.Product__c = woli.Product__c;
                newwoli.ProductCode__c = woli.ProductCode__c;
                newwoli.ProductoPorBodega__c = woli.ProductoPorBodega__c;
                newwoli.ProductServiceCampaignItemId = woli.ProductServiceCampaignItemId;
                newwoli.QuoteLineItem__c = woli.QuoteLineItem__c;
                newwoli.RecommendedCrewSize = woli.RecommendedCrewSize;
                newwoli.regalia__c = woli.regalia__c;
                newwoli.ReturnOrderLineItemId = woli.ReturnOrderLineItemId;
                newwoli.ServiceReportTemplateId = woli.ServiceReportTemplateId;
                newwoli.ServiceTerritoryId = woli.ServiceTerritoryId;
                newwoli.StartDate = woli.StartDate;
                newwoli.State = woli.State;
                newwoli.Status = woli.Status;
                newwoli.Street = woli.Street;
                newwoli.Subject = woli.Subject;
                
                newwoli.SuggestedMaintenanceDate = woli.SuggestedMaintenanceDate;               
                newwoli.tipoDeTrabajo__c = woli.tipoDeTrabajo__c;
                newwoli.tiposDeTrabajo__c = woli.tiposDeTrabajo__c;
                newwoli.TipoTrabajoCaso__c = woli.TipoTrabajoCaso__c;
                newwoli.totalItem__c = woli.totalItem__c;                
                newwoli.Trabajo__c = woli.Trabajo__c;
                newwoli.WorkTypeId = woli.WorkTypeId;
                
                 
                //newwoli = woli.clone(false, false, false, false);
                  System.debug('newwoli currency: '+newwoli.CurrencyIsoCode);

                newwoli.Product2Id = null;
                newwoli.PricebookEntryId = mapProductIdPriceBookEntryId.get(woli.Product2Id);
                                System.debug('woli currency2: '+woli.CurrencyIsoCode);
                
                System.debug(' newwoli.ImpuestoReal__c1: '+ newwoli.ImpuestoReal__c);
                //newwoli.Subtotal__c = mapProductPrecio.get(woli.Product2Id)*woli.Quantity;
                                System.debug(' newwoli.Subtotal__c: '+ newwoli.Subtotal__c);

                if(newwoli.ImpuestoReal__c!= null){
                //newwoli.ImpuestoReal__c = woli.ImpuestoReal__c * tipoCambio;
                }
                if(newwoli.Descuento__c!= null){
                //newwoli.Descuento__c = woli.Descuento__c * tipoCambio;
                }
                if(newwoli.Subtotal__c!= null){
                //  newwoli.Subtotal__c = woli.Subtotal__c * tipoCambio; 
                }
                //newwoli.UnitPrice = woli.UnitPrice * tipoCambio; 
                //newwoli.RootWorkOrderLineItemId = null;
                //newwoli.CurrencyIsoCode = ot.CurrencyIsoCode;
                System.debug(' newwoli.ImpuestoReal__c2: '+ newwoli.ImpuestoReal__c);
                System.debug('tipoCambio: '+tipoCambio);

                 System.debug('newwoli: '+newwoli);
                newWoliRelated.add(newwoli);   
            }
            System.debug('woliRelated: '+woliRelated);
            //delete woliRelated;
            System.debug('woliRelated delete:  '+woliRelated);
            //ot.CurrencyIsoCode = workorder.CurrencyIsoCode;
            //ot.Pricebook2Id = workorder.Pricebook2Id;
            //update ot;
            //System.debug('ot: '+ot);
                        System.debug('newWoliRelated: '+newWoliRelated);
      if(!Test.isRunningTest()){
              insert newWoliRelated;
            }
            cargando = false;
            comienzo = false;
          cambiado = true;
            System.debug('newWoliRelated: '+newWoliRelated);
      }
        return null;
    }
    
    

}