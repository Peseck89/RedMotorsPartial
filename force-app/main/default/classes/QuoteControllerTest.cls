@isTest
public class QuoteControllerTest {
	  
    static testMethod void workOrderHistoryTest() {
        
        Pricebook2 pb = new Pricebook2(Name='Bavarian Local', IsActive=true);
        insert pb;
        Pricebook2 pb2 = new Pricebook2(Name='Bavarian Dólar', IsActive=true);
        insert pb2;
        condicionPago__c condicionPago = new condicionPago__c(condicionPago__c='0',Descripcion__c='test desc', Name='0');
        insert condicionPago;
        
        Impuesto__c Impuesto = new Impuesto__c(codigoImpuesto__c='0108',descripcion__c='test desc',Impuesto__c=2, Name='test imp', porcentaje__c=3);
        insert Impuesto;
        
        Account acc = new Account(Name='Test account', Cedula__c='9876543210', Tipo_de_Documento__c='02', condicionPago__c=condicionPago.Id, Impuesto__c=Impuesto.Id);
        insert acc;
        
        Contact co = new Contact(Firstname='Juan Diego',LastName='Espinoza S1', Email='jesp@abc.com',Phone='+50611223344', AccountId=acc.Id);
        insert co;
        
        Asset asset = new Asset(Name='BMW X6', ContactId=co.Id, AccountId=acc.Id,NumeroDeChasis__c='1HGCM82633A123456');
        insert asset;
        
        Id pricebookId = pb.Id;
        
        CentroCosto__c cc = new CentroCosto__c();
        insert cc;
        
        WorkOrder wo = new WorkOrder(subject ='title2', CurrencyIsoCode='CRC', Pricebook2Id=pricebookId, tipoDeGasto__c='Cliente', AssetId=asset.Id);
        insert wo;
        
        WorkOrder tmp = [Select PriceBook2Id from WorkOrder Where Id = :wo.Id];
        //system.assertEquals(pricebookId,tmp.PriceBook2Id,'The workorder price book was modified after it was inserted');
        
        //Insert product        
        Product2 prod= new Product2(IsActive=true, Name='Test product2', tipoProducto__c='Mano de Obra', ProductCode='00012', Codigo_de_Producto__c='0012');
        insert prod;
        
        Product2 prodMO= new Product2(IsActive=true, Name='Mano de Obra',tipoProducto__c='Mano de Obra', ProductCode='00012', Codigo_de_Producto__c='0012');
        insert prodMO;
        
        // Insert PricebookEntry
        
        //Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];
        PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id =pricebookId, Product2Id = prod.Id, UnitPrice = 2000, IsActive = true,CurrencyIsoCode='CRC');
        insert standardPBE;
    	
		Product2 manoObra = new Product2(Name='MO Test', Family='Servicios',tipoProducto__c ='Mano de Obra', isActive=true, Codigo_de_Producto__c='MO29');
        insert manoObra;
 		Product2 manoObra2 = new Product2(Name='MO Test2', Family='Servicios',tipoProducto__c ='Mano de Obra', isActive=true, Codigo_de_Producto__c='MO30');
        insert manoObra2;  
        PricebookEntry pbe = new PricebookEntry(
            Product2Id = manoObra.Id,
            Pricebook2Id = pricebookId,
            CurrencyIsoCode = 'CRC',
            UnitPrice = 100,
            IsActive = true
        );
        insert pbe;
		PricebookEntry pbe2 = new PricebookEntry(
            Product2Id = manoObra2.Id,
            Pricebook2Id = pricebookId,
            CurrencyIsoCode = 'CRC',
            UnitPrice = 100,
            IsActive = true
        );
        insert pbe2;
        // Crea tiposDeTrabajo
        tiposDeTrabajo__c tipoTrabajo = new tiposDeTrabajo__c(
            Name='Tipo Trabajo Test',
            ManoDeObra__c = manoObra.Id,
            UTS__c = 12
        );
        insert tipoTrabajo;
		tiposDeTrabajo__c tipoTrabajo2 = new tiposDeTrabajo__c(
            Name='Tipo Trabajo Test2',
            ManoDeObra__c = manoObra2.Id,
            UTS__c = 12
        );
        insert tipoTrabajo2;
       // WorkOrderLineItem woli = new WorkOrderLineItem(workOrderId = wo.Id, description = 'abcd2', Quantity=2, PricebookEntryId=standardPBE.Id, centroCosto__c = cc.Id );        
       // insert woli;
        
        ActividadComercial__c actividad = new ActividadComercial__c(Name = 'VENTA DE REPUESTOS NUEVOS PARA AUTOMOVIL');
        insert actividad;
        
        tiposDeTrabajo__c tipotraba = new tiposDeTrabajo__c(Name='Mantenimiento');
        insert tipotraba;
        
        wo.Etapa_de_flujo_de_trabajo__c='Aprobación de presupuesto';
        wo.AccountId=acc.Id;
        wo.ActividadComercial__c = actividad.Id;
        wo.Tipo_de_Cargo__c = 'x';
        //update wo;
        
        
        //Insert Operating hours
        OperatingHours hours = new OperatingHours();
        hours.Name = 'Test';
        hours.TimeZone = UserInfo.getTimeZone().getId();
        insert hours;
        
        //Insert Service Territory
        ServiceTerritory territory = new ServiceTerritory();
        territory.Name = 'Test';
        territory.OperatingHoursId = hours.Id;
        insert territory;
                
        //Insert Bodega
        Bodega__c bodega = new Bodega__c();
        bodega.Name = 'Test';
        insert bodega;
        
        //Insert BodegaxTerritorio__c
        BodegaxTerritorio__c bodXter = new BodegaxTerritorio__c();
        bodXter.Bodega__c = bodega.Id;
        bodXter.ServiceTerritory__c = territory.Id;
        bodXter.CurrencyIsoCode = 'CRC';
        
        //Insert ProductoXBodega
        ProductoXBodega__c prodXBodega = new ProductoXBodega__c();
        prodXBodega.Name = 'Test';
        prodXBodega.Producto__c = prod.Id;
        prodXBodega.CurrencyIsoCode = 'CRC';
        prodXBodega.Bodega__c = bodega.Id;
        insert prodXBodega;
        
        //Insert Asset, Opportunity & Quote        
        Asset vehiculo = new Asset();
        vehiculo.Name = 'Test';
        vehiculo.AccountId = acc.Id;
        vehiculo.marca__c = 'BMW';
        vehiculo.modelo__c = 'X3';
        vehiculo.NumeroDeChasis__c = '1HGCM82633A123457';
        vehiculo.Anio__c = '2010';
        insert vehiculo;
        
        Opportunity oppt = new Opportunity();
        oppt.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Taller').getRecordTypeId();
        oppt.Name = 'Test';
        oppt.CurrencyIsoCode = 'CRC';
        oppt.BMW_Compania__c = 'Bavarian';
        oppt.BMW_PlacaDeVehiculoOElVIN__c = vehiculo.Id;
        oppt.CloseDate = Date.today();
        oppt.StageName = 'Oferta';
        oppt.BMW_TipoDeVehiculo__c = 'Autos';
        oppt.WorkOrder__c = wo.Id;
        oppt.AccountId = acc.Id;
        oppt.contacto__c = co.Id;
        insert oppt;
        
        Quote quote = new Quote();
        quote.Name = 'Test';
        quote.OpportunityId = oppt.Id;
        quote.CurrencyIsoCode = 'CRC';
        quote.pricebook2Id = pricebookId;
        insert quote;
		 QuoteLineItem qli = new QuoteLineItem(
            QuoteId = quote.Id,
            PricebookEntryId = pbe.Id,
            Product2Id = manoObra.Id,
            Quantity = 1,
            UnitPrice = 100,
            TrabajoARealizar__c = tipoTrabajo.Id,
            Tarea__c = tipoTrabajo.Id,
            SubTrabajoAlias__c = 'prueba2',
            SubTrabajoARealizar__c = tipoTrabajo.Id
        );
        insert qli;
	 QuoteLineItem qli2 = new QuoteLineItem(
            QuoteId = quote.Id,
            PricebookEntryId = pbe2.Id,
            Product2Id = manoObra2.Id,
            Quantity = 1,
            UnitPrice = 100,
            SubTrabajoAlias__c = 'prueba',
            TrabajoARealizar__c = tipoTrabajo2.Id,
            Tarea__c = tipoTrabajo2.Id,
            SubTrabajoARealizar__c = tipoTrabajo.Id
        );
        insert qli2;
        Case caso = new Case(
            Create_Orders_from_Workorders__c = true,
            AssetId = vehiculo.Id,
            AccountId = acc.Id
            );
        INSERT caso;
        
        wo.CaseId = caso.Id;
        wo.Etapa_de_flujo_de_trabajo__c = 'Nuevo';
        update wo;

        //ProductConsumed pc = new ProductConsumed(WorkorderId = wo.Id,PriceBookEntryId = standardPBE.Id,QuantityConsumed = 1);
        //insert pc;
        
        Decimal testPrice = 0.00;
        Decimal testCantidadDisponible = 0.00;
        
        QuoteController.Wrapper wl= new QuoteController.Wrapper();
        //prod.Id, wo.Id, prod.Id, prod.ProductCode, prod.Name, testPrice, 'Materiales', bodega.Id, testCantidadDisponible, 'Alias', tipotraba.Id, standardPBE.Id, standardPBE.CurrencyIsoCode
        
        List<QuoteController.Wrapper> qtest = new  List<QuoteController.Wrapper>(); 
        qtest.add(wl);
        String myJSON = JSON.serialize(wl);
        // myJSON='['+myJSON+']';
        String tester = '['
        + '{'
        + '"alias":"Aceite",'
        + '"aprobado": true,'
        + '"Bodega": "Bodega segunda de Pavas",'
        + '"cantidad": 3,'                          // número, no string
        + '"cantidadDisponible": 253432434,'
        + '"currencyCode": "CRC",'
        + '"discount": 0.6,'                        // número
        + '"wrapperId": "'+ qli.Id +'",'            // <<--- AQUÍ EL CAMBIO
        + '"Name": "ACEITE  DE  MOTOR",'
        + '"precio": 12.21706315,'
        + '"priceBookEntry": "'+ pbe.Id +'",'
        + '"productId": "'+ manoObra.Id +'",'
        + '"productType": "Materiales",'
        + '"tipotrabajo": "'+ tipotraba.Id +'"'
        + '},'
        + '{'
        + '"alias":"Producto",'
        + '"aprobado": true,'
        + '"Bodega": "Bodega segunda de Pavas",'
        + '"cantidad": 1,'
        + '"cantidadDisponible": 2,'
        + '"currencyCode": "CRC",'
        + '"discount": 0.9,'
        + '"wrapperId": "'+ qli2.Id +'",'           // <<--- TAMBIÉN AQUÍ
        + '"Name": "ACEITE BMW 5W-30 L01 GAS/DIESEL LT (550049302)",'
        + '"precio": 9300,'
        + '"priceBookEntry": "'+ pbe2.Id +'",'
        + '"productId": "'+ manoObra2.Id +'",'
        + '"enCaso": true,'                          // opcional; tu lógica usa enviarACaso (parámetro)
        + '"productType": "Materiales",'
        + '"tipotrabajo": "'+ tipotraba.Id +'"'
        + '}'
        + ']';

        system.debug('Json TEEEST');
        system.debug(tester);
        
 
        
        String productType='Mano de Obra';
        String productName='Test product2';
        
        Quote quo = [SELECT Id,CurrencyIsoCode FROM Quote WHERE Id = :quote.Id LIMIT 1];
        Id quoteId = quo.Id;
        system.debug('@@@@@@@@@@@quo@@@@@@@@@@@@@@@'+wo.Id);
        
        QuoteLineItem newQLI = new QuoteLineItem(
            Product2Id = prod.Id,
            PricebookEntryId = standardPBE.Id,
            Quantity = 1,
            QuoteId = quoteId,
            UnitPrice = 2000
        );
        insert newQLI;
       
        Test.startTest();
        QuoteController.saveWorkLineItems(tester, wo.Id,quote.Id,oppt.Id,true);
        // QuoteController.searchProductxBodega('','Aceite',wo.Id);
        // QuoteController.Wrapper wrapper = new QuoteController.Wrapper(wo.Id,null,null,tipotraba.Id);
        Test.stopTest();
    }
     static testMethod void workOrderHistoryTest2() {
        
        Pricebook2 pb = new Pricebook2(Name='Bavarian Local', IsActive=true);
        insert pb;
        Pricebook2 pb2 = new Pricebook2(Name='Bavarian Dólar', IsActive=true);
        insert pb2;
        condicionPago__c condicionPago = new condicionPago__c(condicionPago__c='0',Descripcion__c='test desc', Name='0');
        insert condicionPago;
        
        Impuesto__c Impuesto = new Impuesto__c(codigoImpuesto__c='0108',descripcion__c='test desc',Impuesto__c=2, Name='test imp', porcentaje__c=3);
        insert Impuesto;
        
        Account acc = new Account(Name='Test account', Cedula__c='9876543210', Tipo_de_Documento__c='02', condicionPago__c=condicionPago.Id, Impuesto__c=Impuesto.Id);
        insert acc;
        
        Contact co = new Contact(Firstname='Juan Diego',LastName='Espinoza S1', Email='jesp@abc.com',Phone='+50611223344', AccountId=acc.Id);
        insert co;
        
        Asset asset = new Asset(Name='BMW X6', ContactId=co.Id, AccountId=acc.Id,NumeroDeChasis__c='1HGCM82633A123456');
        insert asset;
        
        Id pricebookId = pb.Id;
        
        CentroCosto__c cc = new CentroCosto__c();
        insert cc;
        
        WorkOrder wo = new WorkOrder(subject ='title2', CurrencyIsoCode='CRC', Pricebook2Id=pricebookId, tipoDeGasto__c='Cliente', AssetId=asset.Id);
        insert wo;
        
        WorkOrder tmp = [Select PriceBook2Id from WorkOrder Where Id = :wo.Id];
        //system.assertEquals(pricebookId,tmp.PriceBook2Id,'The workorder price book was modified after it was inserted');
        
        //Insert product        
        Product2 prod= new Product2(IsActive=true, Name='Test product2', tipoProducto__c='Mano de Obra', ProductCode='00012', Codigo_de_Producto__c='0012');
        insert prod;
        
        Product2 prodMO= new Product2(IsActive=true, Name='Mano de Obra',tipoProducto__c='Mano de Obra', ProductCode='00012', Codigo_de_Producto__c='0012');
        insert prodMO;
        
        // Insert PricebookEntry
        
        //Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];
        PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id =pricebookId, Product2Id = prod.Id, UnitPrice = 2000, IsActive = true,CurrencyIsoCode='CRC');
        insert standardPBE;
    	
		Product2 manoObra = new Product2(Name='MO Test', Family='Servicios',tipoProducto__c ='Mano de Obra', isActive=true, Codigo_de_Producto__c='MO29');
        insert manoObra;
 		Product2 manoObra2 = new Product2(Name='MO Test2', Family='Servicios',tipoProducto__c ='Mano de Obra', isActive=true, Codigo_de_Producto__c='MO30');
        insert manoObra2;  
        PricebookEntry pbe = new PricebookEntry(
            Product2Id = manoObra.Id,
            Pricebook2Id = pricebookId,
            CurrencyIsoCode = 'CRC',
            UnitPrice = 100,
            IsActive = true
        );
        insert pbe;
		PricebookEntry pbe2 = new PricebookEntry(
            Product2Id = manoObra2.Id,
            Pricebook2Id = pricebookId,
            CurrencyIsoCode = 'CRC',
            UnitPrice = 100,
            IsActive = true
        );
        insert pbe2;
        // Crea tiposDeTrabajo
        tiposDeTrabajo__c tipoTrabajo = new tiposDeTrabajo__c(
            Name='Tipo Trabajo Test',
            ManoDeObra__c = manoObra.Id,
            UTS__c = 12
        );
        insert tipoTrabajo;
		tiposDeTrabajo__c tipoTrabajo2 = new tiposDeTrabajo__c(
            Name='Tipo Trabajo Test2',
            ManoDeObra__c = manoObra2.Id,
            UTS__c = 12
        );
        insert tipoTrabajo2;
       // WorkOrderLineItem woli = new WorkOrderLineItem(workOrderId = wo.Id, description = 'abcd2', Quantity=2, PricebookEntryId=standardPBE.Id, centroCosto__c = cc.Id );        
       // insert woli;
        
        ActividadComercial__c actividad = new ActividadComercial__c(Name = 'VENTA DE REPUESTOS NUEVOS PARA AUTOMOVIL');
        insert actividad;
        
        tiposDeTrabajo__c tipotraba = new tiposDeTrabajo__c(Name='Mantenimiento');
        insert tipotraba;
        
        wo.Etapa_de_flujo_de_trabajo__c='Aprobación de presupuesto';
        wo.AccountId=acc.Id;
        wo.ActividadComercial__c = actividad.Id;
        wo.Tipo_de_Cargo__c = 'x';
        //update wo;
        
        
        //Insert Operating hours
        OperatingHours hours = new OperatingHours();
        hours.Name = 'Test';
        hours.TimeZone = UserInfo.getTimeZone().getId();
        insert hours;
        
        //Insert Service Territory
        ServiceTerritory territory = new ServiceTerritory();
        territory.Name = 'Test';
        territory.OperatingHoursId = hours.Id;
        insert territory;
                
        //Insert Bodega
        Bodega__c bodega = new Bodega__c();
        bodega.Name = 'Test';
        insert bodega;
        
        //Insert BodegaxTerritorio__c
        BodegaxTerritorio__c bodXter = new BodegaxTerritorio__c();
        bodXter.Bodega__c = bodega.Id;
        bodXter.ServiceTerritory__c = territory.Id;
        bodXter.CurrencyIsoCode = 'CRC';
        
        //Insert ProductoXBodega
        ProductoXBodega__c prodXBodega = new ProductoXBodega__c();
        prodXBodega.Name = 'Test';
        prodXBodega.Producto__c = prod.Id;
        prodXBodega.CurrencyIsoCode = 'CRC';
        prodXBodega.Bodega__c = bodega.Id;
        insert prodXBodega;
        
        //Insert Asset, Opportunity & Quote        
        Asset vehiculo = new Asset();
        vehiculo.Name = 'Test';
        vehiculo.AccountId = acc.Id;
        vehiculo.marca__c = 'BMW';
        vehiculo.modelo__c = 'X3';
        vehiculo.NumeroDeChasis__c = '1HGCM82633A123457';
        vehiculo.Anio__c = '2010';
        insert vehiculo;
        
        Opportunity oppt = new Opportunity();
        oppt.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Taller').getRecordTypeId();
        oppt.Name = 'Test';
        oppt.CurrencyIsoCode = 'CRC';
        oppt.BMW_Compania__c = 'Bavarian';
        oppt.BMW_PlacaDeVehiculoOElVIN__c = vehiculo.Id;
        oppt.CloseDate = Date.today();
        oppt.StageName = 'Oferta';
        oppt.BMW_TipoDeVehiculo__c = 'Autos';
        oppt.WorkOrder__c = wo.Id;
        oppt.AccountId = acc.Id;
        oppt.contacto__c = co.Id;
        insert oppt;
        
        Quote quote = new Quote();
        quote.Name = 'Test';
        quote.OpportunityId = oppt.Id;
        quote.CurrencyIsoCode = 'CRC';
        quote.pricebook2Id = pricebookId;
        insert quote;
		 QuoteLineItem qli = new QuoteLineItem(
            QuoteId = quote.Id,
            PricebookEntryId = pbe.Id,
            Product2Id = manoObra.Id,
            Quantity = 1,
            UnitPrice = 100,
            TrabajoARealizar__c = tipoTrabajo.Id,
            Tarea__c = tipoTrabajo.Id,
            SubTrabajoAlias__c = 'prueba2',
            SubTrabajoARealizar__c = tipoTrabajo.Id
        );
        insert qli;
	 QuoteLineItem qli2 = new QuoteLineItem(
            QuoteId = quote.Id,
            PricebookEntryId = pbe2.Id,
            Product2Id = manoObra2.Id,
            Quantity = 1,
            UnitPrice = 100,
            SubTrabajoAlias__c = 'prueba',
            TrabajoARealizar__c = tipoTrabajo2.Id,
            Tarea__c = tipoTrabajo2.Id,
            SubTrabajoARealizar__c = tipoTrabajo.Id
        );
        insert qli2;
        Case caso = new Case(
            Create_Orders_from_Workorders__c = true,
            AssetId = vehiculo.Id,
            AccountId = acc.Id
            );
        INSERT caso;
        
        wo.CaseId = caso.Id;
        wo.Etapa_de_flujo_de_trabajo__c = 'Nuevo';
        update wo;

        //ProductConsumed pc = new ProductConsumed(WorkorderId = wo.Id,PriceBookEntryId = standardPBE.Id,QuantityConsumed = 1);
        //insert pc;
        
        Decimal testPrice = 0.00;
        Decimal testCantidadDisponible = 0.00;
        
        QuoteController.Wrapper wl= new QuoteController.Wrapper();
        //prod.Id, wo.Id, prod.Id, prod.ProductCode, prod.Name, testPrice, 'Materiales', bodega.Id, testCantidadDisponible, 'Alias', tipotraba.Id, standardPBE.Id, standardPBE.CurrencyIsoCode
        
        List<QuoteController.Wrapper> qtest = new  List<QuoteController.Wrapper>(); 
        qtest.add(wl);
        String myJSON = JSON.serialize(wl);
        // myJSON='['+myJSON+']';
        string tester= '['+
            +'{'
            + '"alias": "Aceite",'
            + '"aprobado": true,'
            +' "Bodega": "Bodega segunda de Pavas",'
            + '"cantidad": "3",'
            +' "cantidadDisponible": 253432434,'
            +'"currencyCode": "CRC",'
            +' "discount": "0.6",'
            // +'"bodegaID": "",'
            + '"ID": "'+qli.Id+'",';
        tester= tester+'"Name": "ACEITE  DE  MOTOR",'
            + '"precio": 12.21706315,'
            +'"priceBookEntry": "'+pbe.Id+'",';
        tester= tester+ '"productId": "'+manoObra.Id+'",';
        tester=tester+' "productType": "Materiales",'
            +' "tipotrabajo": "'+tipotraba.Id+'"';
        tester= tester+' },'
            + '{'
            + ' "alias": "Producto",'
            +  '"aprobado": true,'
            + ' "Bodega": "Bodega segunda de Pavas",'
            + ' "cantidad": "1",'
            +  '"cantidadDisponible": 2,'
            +'"currencyCode": "CRC",'
            + ' "discount": "0.9",'
            //   +'"bodegaID": "",'
            +  '"ID": "'+qli2.Id+'",';
        tester= tester+ '"Name": "ACEITE BMW 5W-30 L01 GAS/DIESEL LT (550049302)",'
            + ' "precio": 9300,'
            +'"priceBookEntry": "'+pbe2.Id+'",';
        tester=tester + ' "productId": "'+manoObra2.Id+'",';
        tester=tester + ' "enCaso": true,';
        tester= tester+  ' "productType": "Materiales",'
            +   '"tipotrabajo": "'+tipotraba.Id+'"';
        tester= tester+ '}'
            +']';
        system.debug('Json TEEEST');
        system.debug(tester);
        
 
        
        String productType='Mano de Obra';
        String productName='Test product2';
        
        Quote quo = [SELECT Id,CurrencyIsoCode FROM Quote WHERE Id = :quote.Id LIMIT 1];
        Id quoteId = quo.Id;
        system.debug('@@@@@@@@@@@quo@@@@@@@@@@@@@@@'+wo.Id);
        
        QuoteLineItem newQLI = new QuoteLineItem(
            Product2Id = prod.Id,
            PricebookEntryId = standardPBE.Id,
            Quantity = 1,
            QuoteId = quoteId,
            UnitPrice = 2000
        );
        insert newQLI;
       
        Test.startTest();
		QuoteController.getWorkOrderRelated(quoteId);
        QuoteController.getDefaults(quoteId);
        QuoteController.changeCurrencygtQLIs(wo.Id,quoteId);
        QuoteController.getQuoteLineItems(wo.Id, quoteId);
        // QuoteController.searchProductxBodega('','Aceite',wo.Id);
        // QuoteController.Wrapper wrapper = new QuoteController.Wrapper(wo.Id,null,null,tipotraba.Id);
       
        Test.stopTest();
    }
    static testMethod void workOrderHistoryTest3() {
         Test.startTest();
         QuoteController.getSubtrabajoName('probanodo','probanodo');
        QuoteController.getSubtrabajoName('','probanodo');
        QuoteController.getSubtrabajoName('','p');
		QuoteController.getCargo('1');
        Test.stopTest();
        
    }
    
}