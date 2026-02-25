@isTest
public class WoliGridTest2 {
  	@TestSetup
    static void setupTestData() {
        // Perform setup operations, create test records, etc.
    }
    static testMethod void woliGridTestController(){
        ActividadComercial__c act = new ActividadComercial__c();
        act.Name = 'VENTA DE REPUESTOS NUEVOS PARA AUTOMOVIL';
        insert act;
        Pricebook2 pb = new Pricebook2(Name='Dolar2', IsActive=true);
        insert pb;
        
        condicionPago__c condicionPago = new condicionPago__c(condicionPago__c='0',Descripcion__c='test desc', Name='0');
        insert condicionPago;
        
        Impuesto__c Impuesto = new Impuesto__c(codigoImpuesto__c='0108',descripcion__c='test desc',Impuesto__c=2, Name='test imp', porcentaje__c=3);
        insert Impuesto;
        
        Account acc = new Account(Name='Test account', Cedula__c='9876543210', Tipo_de_Documento__c='02', condicionPago__c=condicionPago.Id, Impuesto__c=Impuesto.Id);
       	insert acc;
        
       	Contact co = new Contact(Firstname='Juan Diego',LastName='Espinoza S1', Email='jesp@abc.com', AccountId=acc.Id);
       	insert co;
        
       	Asset asset = new Asset(Name='BMW X6', ContactId=co.Id, AccountId=acc.Id);
       	insert asset;
        
        
  

        Id pricebookId = pb.Id;
        
        CentroCosto__c cc = new CentroCosto__c();
        insert cc;
        
		OperatingHours oh = new OperatingHours(Name = 'Normal');
        insert oh;
        
        ServiceTerritory st = new ServiceTerritory(Name = 'Uruca - Mecánica General', IsActive = true, OperatingHoursId = oh.id);
        insert st;
        
        WorkOrder wo = new WorkOrder(subject ='title2', Pricebook2Id=pricebookId, tipoDeGasto__c='Cliente', AssetId=asset.Id,AccountId=acc.Id, ServiceTerritoryId=st.id);
        insert wo;
        
        WorkOrder tmp = [Select PriceBook2Id from WorkOrder Where Id = :wo.id];
        //system.assertEquals(pricebookId,tmp.PriceBook2Id,'The workorder price book was modified after it was inserted');
        
        Bodega__c bodega = new Bodega__c(bodega__c = 'BR01', ID_EXTERNO_BODEGA__c = 'BR01', Name = 'BR01');
        insert bodega;
        
        BodegaxTerritorio__c bxt = new BodegaxTerritorio__c(ServiceTerritory__c = st.Id, isPrincipal__c = true, Bodega__c = bodega.Id);
        insert bxt;
        
        //Insert product        
        Product2 prod= new Product2(IsActive=true, Name='Teste product2', ProductCode='L00012', Codigo_de_Producto__c='L00012');
        insert prod;
        
        insert new ProductoXBodega__c(Producto__c = prod.Id, Bodega__c = bodega.Id);
        
        Product2 prodMO= new Product2(IsActive=true, Name='Mano de Obra',tipoProducto__c='Mano de Obra', ProductCode='00012', Codigo_de_Producto__c='0012');
        insert prodMO;

        // Insert PricebookEntry

        //Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];
        PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id =pricebookId, Product2Id = prod.Id, UnitPrice = 2000, IsActive = true);
        insert standardPBE;
        
       

        WorkOrderLineItem woli = new WorkOrderLineItem(workOrderId = wo.Id, description = 'abcd2', Quantity=2, PricebookEntryId=standardPBE.Id, centroCosto__c = cc.Id,Product__c=prod.Id);        
        insert woli;
        
        String woliNumber = [Select WorkOrderNumber from WorkOrder where id =: wo.Id].WorkOrderNumber;
            
        tiposDeTrabajo__c tipotraba = new tiposDeTrabajo__c(Name='Mantenimiento');
        insert tipotraba;
        
         System.debug('Tipo trabajo IDDDDD   ' + tipotraba.Id);
        
        Case caseTest = new Case();
        caseTest.Description='TEst';
        caseTest.Subject = 'Test';
        caseTest.AccountId=acc.Id;
        insert caseTest;
        
        wo.CaseId = caseTest.id;

		
	   tiposDeTrabajoCaso__c tipoDeTrabajoDelCasooooo = new tiposDeTrabajoCaso__c( 
	                                                                                   Caso__c                = caseTest.Id, 
	                                                                                   Tipo_de_cargo__c        = 'Cliente', 
                																		Taller__c             = 'Sugerido', 
	                                                                                   Comment__c        = 'Test',
	                                                                                       Tipotrabajo__c        = tipotraba.Id);
		insert tipoDeTrabajoDelCasooooo;




        tiposDeTrabajoCaso__c tipotrabaCase = tipoDeTrabajoDelCasooooo;

        wo.Etapa_de_flujo_de_trabajo__c='Aprobación de presupuesto';
        wo.AccountId=acc.Id;
        wo.ActividadComercial__c = act.Id;
        wo.Tipo_de_Cargo__c = 'x';
        //update wo;
        
        ProductConsumed pc = new ProductConsumed(WorkorderId = wo.Id,PriceBookEntryId = standardPBE.Id,QuantityConsumed = 1);
        insert pc;
        

    
        ProductController.wrapper wl= new ProductController.wrapper (prod.Id,prod.Id,prod.ProductCode,prod.Name,prod.precio__c,'Test',3,
                                        'Materiales','','',standardPBE.Id,standardPBE.CurrencyIsoCode,null,'-',null);
        
        List<ProductController.wrapper> testW=new  List<ProductController.wrapper>(); 
        testW.add(wl);
       String myJSON = JSON.serialize(wl);
       // myJSON='['+myJSON+']';
        string tester= '['+
          +'{'
           + '"alias": "Aceite",'
           + '"aprobado": true,'
           +' "Bodega": "Bodega segunda de Pavas",'
           + ' "isClosed": true,'
           + '"cantidad": "3",'
           +' "cantidadDisponible": 253432434,'
           +'"currencyCode": "CRC",'
           +' "discount": "0.6",'
          // +'"bodegaID": "",'
           + '"ID": "'+prod.Id+'",';
           tester= tester+'"Name": "ACEITE  DE  MOTOR",'
           + '"precio": 12.21706315,'
           + ' "canEditSalesPrice": true,'
           +'"priceBookEntry": "'+standardPBE.Id+'",';
           tester= tester+ '"productId": "'+prod.Id+'",';
           tester=tester+' "productType": "Materiales",'
           +' "tipotrabajo": "'+tipotraba.Id+'"'; //tipotrabaCase.Id
          tester= tester+' },'
         + '{'
          + ' "alias": "Producto",'
          +  '"aprobado": true,'
          + ' "Bodega": "Bodega segunda de Pavas",'
          + ' "isClosed": false,'
          + ' "cantidad": "1",'
          +  '"cantidadDisponible": 2,'
          +'"currencyCode": "CRC",'
          + ' "discount": "0.9",'
        //   +'"bodegaID": "",'
          +  '"ID": "'+prod.Id+'",';
           tester= tester+ '"Name": "ACEITE BMW 5W-30 L01 GAS/DIESEL LT (550049302)",'
          + ' "precio": 9300,'
          + ' "canEditSalesPrice": true,'
          +'"priceBookEntry": "'+standardPBE.Id+'",';
         tester=tester + ' "productId": "'+prod.Id+'",';
         tester= tester+  ' "productType": "Materiales",'
         +   '"tipotrabajo": "'+tipotraba.Id+'"'; //tipotrabaCase.Id
         tester= tester+ '}'
        +']';
         system.debug('Json TEEEST');
         system.debug(tester);
        string tester2='[ { "alias": "", "aprobado": true, "isClosed": true, "Bodega": "Bodega Central", "bodegaID": "a2b7g000001eAHJAA2", "cantidad": 1, "cantidadDisponible": 5, "currencyCode": "CRC", "discount": 0, "ID": "a2e7g000000edMoAAI", "idExtBodega": "BR01", "locations": [], "Name": "ACEITE BMW 5W-30 L04 DIESEL(550050711)", "precio": 9225, "priceBookEntry": "01u4U00000vk2kYQAQ", "ProductCode": "L00078", "productId": "01t4U000005uplOQAQ", "productType": "Materiales", "quantityByLocation": {}, "softlandQuantities": [], "softlandQuantity": 5, "validated": false }, { "alias": "", "aprobado": true, "Bodega": "Bodega Central", "bodegaID": "a2b7g000001eAHJAA2", "cantidad": 1, "cantidadDisponible": 25, "currencyCode": "CRC", "discount": 0, "ID": "a2e7g000000edOQAAY", "idExtBodega": "BR01", "locations": [], "Name": "DESCARBONIZADOR DE MOTOR BLUECHEM (33018bc)", "precio": 17500, "priceBookEntry": "01u4U00000vk293QAA", "ProductCode": "L000102", "productId": "01t4U000005upwuQAA", "productType": "Materiales", "quantityByLocation": {}, "softlandQuantities": [], "softlandQuantity": 25, "validated": false }, { "alias": "", "aprobado": true, "Bodega": "Bodega Central", "bodegaID": "a2b7g000001eAHJAA2", "cantidad": 1, "cantidadDisponible": 1, "currencyCode": "CRC", "discount": 0, "ID": "a2e7g000000edOLAAY", "idExtBodega": "BR01", "locations": [], "Name": "JGO.PEGAM VID PARABRISAS", "precio": 14850, "priceBookEntry": "01u4U00000vk1nGQAQ", "ProductCode": "L00098", "productId": "01t4U000005uqUsQAI", "productType": "Materiales", "quantityByLocation": {}, "softlandQuantities": [], "softlandQuantity": 1, "validated": false } ]';
       //	Test.startTest();
        String productType='Mano de Obra';
        String productName='Test product2';
        Test.startTest();
        WoliGridController2.searchProducts ('', 'L00012', wo.Id);
        //WoliGridController.saveWolis(tester, wo.Id);
        List <WorkOrderLineItem> wolIds=[Select id from WorkOrderLineItem ];
        List <String> ids= new List <String>();
        for(WorkOrderLineItem wids:wolIds){
            ids.add(wids.Id);
        }
        String jsonString = JSON.serialize(WoliGridController2.getWolis('[]' , wo.Id));
        WoliGridController2.saveQuantities(jsonString, wo.Id);
        WoliGridController2.deleteWolis(ids);
        WoliGridController2.getTiposDeTrabajo(wo.Id);
       
        Test.stopTest();
        
    }
    
    static testMethod void woliGridTestServices(){
         WorkOrder testWorkOrder = new WorkOrder();
        insert testWorkOrder;

        WorkOrderLineItem testLineItem = new WorkOrderLineItem( WorkOrderId = testWorkOrder.Id);
        insert testLineItem;
        
        //
        //
        
        ActividadComercial__c actividad = new ActividadComercial__c(Name = 'VENTA DE REPUESTOS NUEVOS PARA AUTOMOVIL');
        insert actividad;
        
        tiposDeTrabajo__c tiposDeTrabajo = new tiposDeTrabajo__c(Name = 'Mantenimiento');
        insert tiposDeTrabajo;
                
        Product2 prod= new Product2();
        prod.IsActive=true;
        prod.Name='Test product Test';
        prod.ProductCode='0001999';
        prod.Codigo_de_Producto__c='00199999';
        insert prod;
        
        List<PricebookEntry> lstPBE = new List<PricebookEntry>();
        Id stdPriceBook =  Test.getStandardPricebookId();
        PricebookEntry pd1 = new PricebookEntry();
        pd1.UnitPrice = 1;
        pd1.CurrencyIsoCode = 'USD';
        pd1.Product2Id = prod.Id;
        pd1.Pricebook2Id = stdPriceBook;
        pd1.IsActive = true;
        lstPBE.add(pd1);
        
        Bodega__c b = new Bodega__c();
        insert b;
        
        ProductoXBodega__c pxb = new ProductoXBodega__c();
        pxb.Producto__c = prod.Id;
        pxb.Bodega__c = b.Id;
        pxb.Disponible__c = 12;
        insert pxb;

        // Insert PricebookEntry
        PricebookEntry standardPBE = [select id, Pricebook2Id, UnitPrice,IsActive,CurrencyIsoCode 
                                      from PricebookEntry 
                                      where Product2Id =:prod.Id 
                                      and CurrencyIsoCode = 'USD'
                                      limit 1];//new PricebookEntry(Pricebook2Id =pricebookId, Product2Id = prod.Id, UnitPrice = 999, IsActive = true);
        System.debug(standardPBE.CurrencyIsoCode);
        
        Pricebook2 pb = new Pricebook2();
        pb.Name='Dolar';
        pb.IsActive=true;
       
        insert pb;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        WorkOrder wo = new WorkOrder();
        wo.subject ='title';
        wo.Pricebook2Id=standardPBE.Pricebook2Id;
        wo.tipoDeGasto__c='Cliente';
        wo.CurrencyIsoCode = 'USD';
        insert wo;
        
        WorkOrder insertedWO = [SELECT Id, WorkOrderNumber FROM WorkOrder WHERE Id = :wo.Id];
        
        System.debug('WO NUMBEEEER   ' + wo.WorkOrderNumber + wo.Id);
        
        CentroCosto__c cc = new CentroCosto__c();
        insert cc;
        
        CentroCosto__c cc2 = new CentroCosto__c();
        insert cc2;
        
        CentroCosto__c cc3 = new CentroCosto__c();
        insert cc3;
        
        CentroCosto__c cc4 = new CentroCosto__c();
        insert cc4;
        
        WorkOrderLineItem woli = new WorkOrderLineItem();
        woli.workOrderId = wo.Id;
        woli.description = 'abcd';
        woli.Quantity=2;
        woli.PricebookEntryId=standardPBE.Id;
        woli.centroCosto__c = cc.Id;
        woli.Cantidad_devolucion__c =1;
        insert woli;
        
        WorkOrderLineItem woli2 = new WorkOrderLineItem();
        woli2.workOrderId = wo.Id;
        woli2.description = 'abcd';
        woli2.Quantity=3;
        woli2.PricebookEntryId=standardPBE.Id;
        woli2.centroCosto__c = cc.Id;
        insert woli2;
        
        WorkOrderLineItem woli3 = new WorkOrderLineItem();
        woli3.workOrderId = wo.Id;
        woli3.description = 'abcd';
        woli3.Quantity=3;
        woli3.PricebookEntryId=standardPBE.Id;
        woli3.centroCosto__c = cc.Id;
        insert woli3;
        
        WorkOrderLineItem woli4 = new WorkOrderLineItem();
        woli4.workOrderId = wo.Id;
        woli4.description = 'abcd';
        woli4.Quantity=3;
        woli4.PricebookEntryId=standardPBE.Id;
        woli4.centroCosto__c = cc.Id;
        insert woli4;
        
        
        string tester= '['+
          +'{'
           + '"alias": "Aceite",'
           + '"aprobado": true,'
           +' "Bodega": "Bodega segunda de Pavas",'
           + ' "isClosed": true,'
           + '"cantidad": "3",'
           +' "cantidadDisponible": 253432434,'
           +'"currencyCode": "CRC",'
           +' "discount": "0.6",'
          // +'"bodegaID": "",'
           + '"ID": "'+prod.Id+'",';
           tester= tester+'"Name": "ACEITE  DE  MOTOR",'
           + '"precio": 12.21706315,'
           +'"priceBookEntry": "'+standardPBE.Id+'",';
           tester= tester+ '"productId": "'+prod.Id+'",';
           tester=tester+' "productType": "Materiales",'
           +' "tipotrabajo": ""';
          tester= tester+' },'
         + '{'
          + ' "alias": "Producto",'
          +  '"aprobado": true,'
          + ' "Bodega": "Bodega segunda de Pavas",'
          + ' "isClosed": false,'
          + ' "cantidad": "1",'
          +  '"cantidadDisponible": 2,'
          +'"currencyCode": "CRC",'
          + ' "discount": "0.9",'
        //   +'"bodegaID": "",'
          +  '"ID": "'+prod.Id+'",';
           tester= tester+ '"Name": "ACEITE BMW 5W-30 L01 GAS/DIESEL LT (550049302)",'
          + ' "precio": 9300,'
          +'"priceBookEntry": "'+standardPBE.Id+'",';
         tester=tester + ' "productId": "'+prod.Id+'",';
         tester= tester+  ' "productType": "Materiales",'
         +   '"tipotrabajo": ""';
         tester= tester+ '}'
        +']';
        

        List<String> lineItemIds = new List<String>{woli.id,woli2.id,woli3.id,woli4.id};

        Test.startTest();
        WoliGridController2.consultarDisponibilidad(tester, insertedWO.Id ,insertedWO.WorkOrderNumber);
        WoliGridController2.requestDespacho (insertedWO.WorkOrderNumber, new List<String>(), lineItemIds);
        WoliGridController2.requestApartar (insertedWO.WorkOrderNumber, new List<String>(), lineItemIds);
        WoliGridController2.requestDevolucion(insertedWO.WorkOrderNumber, lineItemIds);
        WoliGridController2.sendPDF (wo.Id, 'test@test.com');
        WoliGridController2.Method();
        WoliGridHelper2.Method();
        WoliGridQueryService2.Method();

       // WoliGridQueryService.Method();
        
        Test.stopTest();
    }
    
    
}