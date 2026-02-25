@isTest
public class ProductControllerTwoTest {
    
    	static testMethod void ProductControllerTwoTest() {
       		
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
        
        Opportunity opp = new Opportunity(Name = 'Opportunity name', StageName = 'Draft', CloseDate = System.today());
        insert opp;

        Quote quo = new Quote(Pricebook2Id = pricebookId, Name = 'Name', OpportunityId = opp.id);
        insert quo;
        
        //system.assertEquals(pricebookId,tmp.PriceBook2Id,'The workorder price book was modified after it was inserted');

        //Insert product        
        Product2 prod= new Product2(IsActive=true, Name='Test product2', ProductCode='00012', Codigo_de_Producto__c='0012');
        insert prod;
        
        Product2 prodMO= new Product2(IsActive=true, Name='Mano de Obra',tipoProducto__c='Mano de Obra', ProductCode='00012', Codigo_de_Producto__c='0012');
        insert prodMO;

        // Insert PricebookEntry

        //Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];
        PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id =pricebookId, Product2Id = prod.Id, UnitPrice = 2000, IsActive = true);
        insert standardPBE;
        
        QuoteLineItem qli = new QuoteLineItem(QuoteId = quo.id, priceBookEntryId = standardPBE.Id, BMW_Alias__c = 'Alias uno', Quantity = 2, UnitPrice = 10);
        insert qli;
        
        tiposDeTrabajo__c tipotraba = new tiposDeTrabajo__c(Name='Mantenimiento');
        insert tipotraba;
        
        ProductControllerTwo.wrapper wl= new ProductControllerTwo.wrapper (prod.Id,
                                                                     prod.Id,
                                                                     prod.ProductCode,
                                                                     prod.Name,
                                                                     prod.precio__c,
                                                                     'Test',
                                                                     3,
                                                                     'Materiales',
                                                                     '',
                                                                     '',
                                                                     standardPBE.Id,
                                                                     standardPBE.CurrencyIsoCode,
                                                                     null,
                                                                     '-',
                                                                     null);
        List<ProductControllerTwo.wrapper> test = new List<ProductControllerTwo.wrapper>(); 
        test.add(wl);
       	String myJSON = JSON.serialize(wl);
       	// myJSON='['+myJSON+']';
        String 	tester = 		'['
                                + '{'
                                + '"alias": "Aceite",'
                                + '"aprobado": true,'
                                + '"Bodega": "Bodega segunda de Pavas",'
                                + '"cantidad": "3",'
                                + '"cantidadDisponible": 253432434,'
                                + '"currencyCode": "CRC",'
                                + '"discount": "0.6",'
                                // +'"bodegaID": "",'
                                + '"ID": "'+prod.Id+'",';
                tester = tester + '"Name": "ACEITE  DE  MOTOR",'
                                + '"precio": 12.21706315,'
                                + '"priceBookEntry": "'+standardPBE.Id+'",';
                tester = tester + '"productId": "'+prod.Id+'",';
                tester = tester + '"productType": "Materiales",'
                    			+ '"tipotrabajo": "'+tipotraba.Id+'"';
                tester = tester + ' },'
         						+ '{'
                                + '"alias": "Producto",'
                                + '"aprobado": true,'
                                + '"Bodega": "Bodega segunda de Pavas",'
                                + '"cantidad": "1",'
                                + '"cantidadDisponible": 2,'
                                + '"currencyCode": "CRC",'
                                + '"discount": "0.9",'
                                //   +'"bodegaID": "",'
                                + '"ID": "'+prod.Id+'",';
           		tester = tester + '"Name": "ACEITE BMW 5W-30 L01 GAS/DIESEL LT (550049302)",'
                                + '"precio": 9300,'
                                + '"priceBookEntry": "'+standardPBE.Id+'",';
         		tester = tester + '"productId": "'+prod.Id+'",';
         		tester = tester + '"productType": "Materiales",'
         						+ '"tipotrabajo": "' + tipotraba.Id+'"';
         		tester = tester + '}'
        						+ ']';
        system.debug('Json TEEEST');
        system.debug(tester);
        String tester2='[ { "alias": "", "aprobado": true, "Bodega": "Bodega Central", "bodegaID": "a2b7g000001eAHJAA2", "cantidad": 1, "cantidadDisponible": 5, "currencyCode": "CRC", "discount": 0, "ID": "a2e7g000000edMoAAI", "idExtBodega": "BR01", "locations": [], "Name": "ACEITE BMW 5W-30 L04 DIESEL(550050711)", "precio": 9225, "priceBookEntry": "01u4U00000vk2kYQAQ", "ProductCode": "L00078", "productId": "01t4U000005uplOQAQ", "productType": "Materiales", "quantityByLocation": {}, "softlandQuantities": [], "softlandQuantity": 5, "validated": false }, { "alias": "", "aprobado": true, "Bodega": "Bodega Central", "bodegaID": "a2b7g000001eAHJAA2", "cantidad": 1, "cantidadDisponible": 25, "currencyCode": "CRC", "discount": 0, "ID": "a2e7g000000edOQAAY", "idExtBodega": "BR01", "locations": [], "Name": "DESCARBONIZADOR DE MOTOR BLUECHEM (33018bc)", "precio": 17500, "priceBookEntry": "01u4U00000vk293QAA", "ProductCode": "L000102", "productId": "01t4U000005upwuQAA", "productType": "Materiales", "quantityByLocation": {}, "softlandQuantities": [], "softlandQuantity": 25, "validated": false }, { "alias": "", "aprobado": true, "Bodega": "Bodega Central", "bodegaID": "a2b7g000001eAHJAA2", "cantidad": 1, "cantidadDisponible": 1, "currencyCode": "CRC", "discount": 0, "ID": "a2e7g000000edOLAAY", "idExtBodega": "BR01", "locations": [], "Name": "JGO.PEGAM VID PARABRISAS", "precio": 14850, "priceBookEntry": "01u4U00000vk1nGQAQ", "ProductCode": "L00098", "productId": "01t4U000005uqUsQAI", "productType": "Materiales", "quantityByLocation": {}, "softlandQuantities": [], "softlandQuantity": 1, "validated": false } ]';
       	String tester3='[ { "alias": "Producto nuevo", "cantidad": 1, "cantidadDisponible": 5, "currencyCode" : "CRC", "discount" : 0, "ID": "a2e7g000000edMoAAI", "idExtBodega": "BR01", "Name": "ACEITE BMW 5W-30 L04 DIESEL(550050711)", "unitPrice": 9225, "priceBookEntry": "' + standardPBE.Id + '", "ProductCode": "L00078", "productId": "' + prod.Id + '", "productType": "Materiales", "quantityByLocation": {}, "softlandQuantities": [], "softlandQuantity": 5, "validated": false }]';

      	//Test.startTest();
        String productType='Mano de Obra';
        String productName='Test product2';
        ProductControllerTwo.getAvailabilityByQuote(tester, quo.Id);
		ProductControllerTwo.searchProductxBodegaxQuote(productType,productName,'xName',quo.Id);
		//ProductControllerTwo.searchProductxBodegaxQuote('','Aceite','xName',quo.Id);        
        //ProductControllerTwo.saveQuoteLineItems(tester3, quo.Id, false);
        ProductControllerTwo.getQolis(tester, quo.Id);
        ProductControllerTwo.getMOAccess();
        List <QuoteLineItem> qlis = [SELECT id FROM QuoteLineItem];
        List <String> ids= new List <String>();
        List <String> qIds = new List<String>();
        for(QuoteLineItem q : qlis) qIds.add(q.Id);
        ProductControllerTwo.deleteQlis(qIds);
       	ProductControllerTwo.dummy();
       	//Test.stopTest();
        }
}