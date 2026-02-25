@isTest
public class QLIGridTest {
    @TestSetup
    static void setupTestData() {
        // Perform setup operations, create test records, etc.
    }

    static testMethod void qliGridTestController() {
        ActividadComercial__c act = new ActividadComercial__c(Name = 'VENTA DE REPUESTOS NUEVOS PARA AUTOMOVIL');
        insert act;

        Pricebook2 pb = new Pricebook2(Name='Dolar2', IsActive=true);
        insert pb;

        condicionPago__c condicionPago = new condicionPago__c(condicionPago__c='0', Descripcion__c='test desc', Name='0');
        insert condicionPago;

        Impuesto__c Impuesto = new Impuesto__c(codigoImpuesto__c='0108', descripcion__c='test desc', Impuesto__c=2, Name='test imp', porcentaje__c=3);
        insert Impuesto;

        Account acc = new Account(
            Name='Test account',
            Cedula__c='9876543210',
            Tipo_de_Documento__c='02',
            condicionPago__c=condicionPago.Id,
            Impuesto__c=Impuesto.Id
        );
        insert acc;

        Contact co = new Contact(FirstName='Juan Diego', LastName='Espinoza S1', Email='jesp@abc.com', AccountId=acc.Id);
        insert co;

        Asset asset = new Asset(Name='BMW X6', ContactId=co.Id, AccountId=acc.Id);
        insert asset;

        Id pricebookId = pb.Id;

        CentroCosto__c cc = new CentroCosto__c();
        insert cc;

        OperatingHours oh = new OperatingHours(Name = 'Normal');
        insert oh;

        ServiceTerritory st = new ServiceTerritory(Name = 'Uruca - Mecánica General', IsActive = true, OperatingHoursId = oh.Id);
        insert st;

        Integer iTotReg = 1;
        TestDataFactory.datosGenerales();
        TestDataFactory.crearCuentas(iTotReg);

        Campaign campanna = new Campaign(Name='Campaign');
        insert campanna;

        TestDataFactory.crearOportunidades(iTotReg,'Oportunidad Calificada');

        WorkOrder wo = new WorkOrder(
            Subject='title2',
            Pricebook2Id=pricebookId,
            tipoDeGasto__c='Cliente',
            AssetId=asset.Id,
            AccountId=acc.Id,
            ServiceTerritoryId=st.Id
        );
        insert wo;

        // Oportunidad (se toma 1 creada por TestDataFactory)
        Opportunity opp = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
        opp.AccountId = acc.Id;
        opp.BMW_TallerDeServicio__c = st.Id;
        update opp;

        Quote qo = new Quote(Name='testqo', Pricebook2Id=pricebookId, OpportunityId=opp.Id);
        insert qo;

        WorkOrder tmp = [SELECT PriceBook2Id FROM WorkOrder WHERE Id = :wo.Id];

        Bodega__c bodega = new Bodega__c(bodega__c='BR01', ID_EXTERNO_BODEGA__c='BR01', Name='BR01');
        insert bodega;

        BodegaxTerritorio__c bxt = new BodegaxTerritorio__c(ServiceTerritory__c=st.Id, isPrincipal__c=true, Bodega__c=bodega.Id);
        insert bxt;

        // Productos
        Product2 prod = new Product2(IsActive=true, Name='Teste product2', ProductCode='L00012', Codigo_de_Producto__c='L00012');
        insert prod;

        insert new ProductoXBodega__c(Producto__c=prod.Id, Bodega__c=bodega.Id);

        Product2 prodMO = new Product2(IsActive=true, Name='Mano de Obra', tipoProducto__c='Mano de Obra', ProductCode='00012', Codigo_de_Producto__c='0012');
        insert prodMO;

        // PBE
        PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id=pricebookId, Product2Id=prod.Id, UnitPrice=2000, IsActive=true);
        insert standardPBE;

        WorkOrderLineItem woli = new WorkOrderLineItem(
            WorkOrderId=wo.Id, Description='abcd2', Quantity=2, PricebookEntryId=standardPBE.Id,
            centroCosto__c=cc.Id, Product__c=prod.Id
        );
        insert woli;

        QuoteLineItem qli = new QuoteLineItem(
            QuoteId=qo.Id, Quantity=2, PricebookEntryId=standardPBE.Id, Product2Id=prod.Id,
            UnitPrice=1, BMW_Bodega__c=bodega.Id
        );
        insert qli;

        QuoteLineItem qli2 = new QuoteLineItem(
            QuoteId=qo.Id, Quantity=3, PricebookEntryId=standardPBE.Id, Product2Id=prodMO.Id,
            UnitPrice=1, BMW_Bodega__c=bodega.Id
        );
        insert qli2;

        String woliNumber = [SELECT WorkOrderNumber FROM WorkOrder WHERE Id = :wo.Id].WorkOrderNumber;

        tiposDeTrabajo__c tipotraba = new tiposDeTrabajo__c(Name='Mantenimiento');
        insert tipotraba;

        Case caseTest = new Case(Description='TEst', Subject='Test', AccountId=acc.Id);
        insert caseTest;

        wo.CaseId = caseTest.Id;

        tiposDeTrabajoCaso__c tipoDeTrabajoDelCasooooo = new tiposDeTrabajoCaso__c(
            Caso__c = caseTest.Id,
            Tipo_de_cargo__c = 'Cliente',
            Taller__c = 'Sugerido',
            Comment__c = 'Test',
            Tipotrabajo__c = tipotraba.Id
        );
        insert tipoDeTrabajoDelCasooooo;

        tiposDeTrabajoCaso__c tipotrabaCase = tipoDeTrabajoDelCasooooo;

        // Usa el quote creado por nosotros (evita LIMIT 1 innecesario)
        List<Quote> quoteList = new List<Quote>{ qo };
        List<QuoteLineItem> qliList = [SELECT Id FROM QuoteLineItem WHERE QuoteId = :qo.Id];

        wo.Etapa_de_flujo_de_trabajo__c = 'Aprobación de presupuesto';
        wo.AccountId = acc.Id;
        wo.ActividadComercial__c = act.Id;
        wo.Tipo_de_Cargo__c = 'x';
        // update wo;  // (si no es necesario para la lógica a cubrir, evitamos DML extra)

        ProductConsumed pc = new ProductConsumed(WorkOrderId=wo.Id, PriceBookEntryId=standardPBE.Id, QuantityConsumed=1);
        insert pc;

        ProductController.wrapper wl = new ProductController.wrapper(
            prod.Id, prod.Id, prod.ProductCode, prod.Name, prod.precio__c, 'Test', 3,
            'Materiales', '', '', standardPBE.Id, standardPBE.CurrencyIsoCode, null, '-', null
        );

        List<ProductController.wrapper> testW = new List<ProductController.wrapper>{ wl };
        String myJSON = JSON.serialize(wl);

        String tester = '['
          + '{'
          + '"alias":"Aceite","aprobado":true,"Bodega":"Bodega segunda de Pavas","isClosed":true,'
          + '"cantidad":"3","cantidadDisponible":253432434,"currencyCode":"CRC","discount":"0.6",'
          + '"ID":"'+prod.Id+'","Name":"ACEITE  DE  MOTOR","precio":12.21706315,"canEditSalesPrice":true,'
          + '"priceBookEntry":"'+standardPBE.Id+'","productId":"'+prod.Id+'","productType":"Materiales",'
          + '"tipotrabajo":"'+tipotraba.Id+'"'   // tipotrabaCase.Id
          + '},'
          + '{'
          + '"alias":"Producto","aprobado":true,"Bodega":"Bodega segunda de Pavas","isClosed":false,'
          + '"cantidad":"1","cantidadDisponible":2,"currencyCode":"CRC","discount":"0.9",'
          + '"ID":"'+prod.Id+'","Name":"ACEITE BMW 5W-30 L01 GAS/DIESEL LT (550049302)",'
          + '"precio":9300,"canEditSalesPrice":true,"priceBookEntry":"'+standardPBE.Id+'",'
          + '"productId":"'+prod.Id+'","productType":"Materiales","tipotrabajo":"'+tipotraba.Id+'"'
          + '}'
          + ']';

        System.debug('Json TEEEST');
        System.debug(tester);

        String tester2 = '[ { "alias": "", "aprobado": true, "isClosed": true, "Bodega": "Bodega Central", "bodegaID": "a2b7g000001eAHJAA2", "cantidad": 1, "cantidadDisponible": 5, "currencyCode": "CRC", "discount": 0, "ID": "a2e7g000000edMoAAI", "idExtBodega": "BR01", "locations": [], "Name": "ACEITE BMW 5W-30 L04 DIESEL(550050711)", "precio": 9225, "priceBookEntry": "01u4U00000vk2kYQAQ", "ProductCode": "L00078", "productId": "01t4U000005uplOQAQ", "productType": "Materiales", "quantityByLocation": {}, "softlandQuantities": [], "softlandQuantity": 5, "validated": false }, { "alias": "", "aprobado": true, "Bodega": "Bodega Central", "bodegaID": "a2b7g000001eAHJAA2", "cantidad": 1, "cantidadDisponible": 25, "currencyCode": "CRC", "discount": 0, "ID": "a2e7g000000edOQAAY", "idExtBodega": "BR01", "locations": [], "Name": "DESCARBONIZADOR DE MOTOR BLUECHEM (33018bc)", "precio": 17500, "priceBookEntry": "01u4U00000vk293QAA", "ProductCode": "L000102", "productId": "01t4U000005upwuQAA", "productType": "Materiales", "quantityByLocation": {}, "softlandQuantities": [], "softlandQuantity": 25, "validated": false }, { "alias": "", "aprobado": true, "Bodega": "Bodega Central", "bodegaID": "a2b7g000001eAHJAA2", "cantidad": 1, "cantidadDisponible": 1, "currencyCode": "CRC", "discount": 0, "ID": "a2e7g000000edOLAAY", "idExtBodega": "BR01", "locations": [], "Name": "JGO.PEGAM VID PARABRISAS", "precio": 14850, "priceBookEntry": "01u4U00000vk1nGQAQ", "ProductCode": "L00098", "productId": "01t4U000005uqUsQAI", "productType": "Materiales", "quantityByLocation": {}, "softlandQuantities": [], "softlandQuantity": 1, "validated": false } ]';

        String productType='Mano de Obra';
        String productName='Test product2';

        // ===== ContentVersion creados por el test =====
        ContentVersion contentVersion  = new ContentVersion(Title='Carrocería#1',  PathOnClient='Penguins.jpg', VersionData=Blob.valueOf('Test Content'),  IsMajorVersion=true);
        ContentVersion contentVersion1 = new ContentVersion(Title='Carrocería#2',  PathOnClient='Penguin.jpg',  VersionData=Blob.valueOf('Test Content'),  IsMajorVersion=true);
        ContentVersion contentVersion2 = new ContentVersion(Title='Carrocería#3',  PathOnClient='Cat.jpg',      VersionData=Blob.valueOf('Test Content'),  IsMajorVersion=true);
        ContentVersion contentVersion3 = new ContentVersion(Title='Carrocería#4',  PathOnClient='Cat1.jpg',     VersionData=Blob.valueOf('Test Content'),  IsMajorVersion=true);
        ContentVersion contentVersion4 = new ContentVersion(Title='Carrocería#5',  PathOnClient='Cat2.jpg',     VersionData=Blob.valueOf('Test Content'),  IsMajorVersion=true);
        insert new List<ContentVersion>{ contentVersion, contentVersion1, contentVersion2, contentVersion3, contentVersion4 };

        // ===== (OPTIMIZACIÓN) Trae ContentDocumentId de los que SÓLO creaste aquí =====
        Set<Id> cvIds = new Set<Id>{ contentVersion.Id, contentVersion1.Id, contentVersion2.Id, contentVersion3.Id, contentVersion4.Id };
        Map<Id, ContentVersion> cvById = new Map<Id, ContentVersion>(
            [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN :cvIds]
        );

        // ===== ContentDocumentLink usando el mapa (sin consultas extra) =====
        ContentDocumentLink cdl  = new ContentDocumentLink(LinkedEntityId=qo.Id, ContentDocumentId=cvById.get(contentVersion.Id).ContentDocumentId,  ShareType='V');
        ContentDocumentLink cdl1 = new ContentDocumentLink(LinkedEntityId=qo.Id, ContentDocumentId=cvById.get(contentVersion1.Id).ContentDocumentId, ShareType='V');
        ContentDocumentLink cdl2 = new ContentDocumentLink(LinkedEntityId=qo.Id, ContentDocumentId=cvById.get(contentVersion2.Id).ContentDocumentId, ShareType='V');
        ContentDocumentLink cdl3 = new ContentDocumentLink(LinkedEntityId=qo.Id, ContentDocumentId=cvById.get(contentVersion3.Id).ContentDocumentId, ShareType='V');
        ContentDocumentLink cdl4 = new ContentDocumentLink(LinkedEntityId=qo.Id, ContentDocumentId=cvById.get(contentVersion4.Id).ContentDocumentId, ShareType='V');
        insert new List<ContentDocumentLink>{ cdl, cdl1, cdl2, cdl3, cdl4 };

        // (ANTES) Aquí consultabas TODO ContentVersion del org. (AHORA) Construimos contentIds SOLO con los creados:
        List<String> contentIds = new List<String>();
        for (Id cvId : cvIds) {
            contentIds.add(cvById.get(cvId).ContentDocumentId);
        }

        // (mantiene tu bloque de ContentDistribution en memoria, sin inserts)
        List<ContentDistribution> contentDistributions = new List<ContentDistribution>();
        for (Id cvId : cvIds) {
            ContentDistribution cd = new ContentDistribution(
                Name='noenviado',
                ContentVersionId=cvId,
                PreferencesAllowViewInBrowser=true,
                PreferencesLinkLatestVersion=true,
                PreferencesNotifyOnVisit=false,
                PreferencesPasswordRequired=false
            );
            contentDistributions.add(cd);
        }
        // insert contentDistributions; // sigues sin insertarlo como en tu versión

        // Más archivos
        ContentVersion contentV1 = new ContentVersion(Title='Carrocería#11', PathOnClient='Penguins.jpg', VersionData=Blob.valueOf('Test Content1'), IsMajorVersion=true);
        ContentVersion contentV2 = new ContentVersion(Title='Carrocería#22', PathOnClient='Penguin.jpg',  VersionData=Blob.valueOf('Test Content2'), IsMajorVersion=true);
        insert new List<ContentVersion>{ contentV1, contentV2 };

        // Agrega a nuestro set y refresca ContentDocumentIds con UNA sola query
        cvIds.add(contentV1.Id);
        cvIds.add(contentV2.Id);
        cvById.putAll(new Map<Id, ContentVersion>(
            [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN :new List<Id>{ contentV1.Id, contentV2.Id }]
        ));

        ContentDocumentLink cdln1 = new ContentDocumentLink(LinkedEntityId=qo.Id, ContentDocumentId=cvById.get(contentV1.Id).ContentDocumentId, ShareType='V');
        ContentDocumentLink cdln2 = new ContentDocumentLink(LinkedEntityId=qo.Id, ContentDocumentId=cvById.get(contentV2.Id).ContentDocumentId, ShareType='V');
        insert new List<ContentDocumentLink>{ cdln1, cdln2 };

        // nuevoscd solo con los que acabamos de crear (sin más queries)
        List<String> nuevoscd = new List<String>{
            cvById.get(contentV1.Id).ContentDocumentId,
            cvById.get(contentV2.Id).ContentDocumentId
        };

        Product2 prodConRelaciones = [
            SELECT Id, Name, ProductCode, Codigo_de_Producto__c, tipoProducto__c,
                   (SELECT Id, UnitPrice, CurrencyIsoCode FROM PricebookEntries),
                   (SELECT Id, Disponible__c, Bodega__r.Name, Bodega__c, Bodega__r.bodega__c FROM Productos_por_Bodega__r)
            FROM Product2
            WHERE Id = :prod.Id
            LIMIT 1
        ];

        Test.startTest();
        QliGridController.searchProducts('', prodConRelaciones.ProductCode, qo.Id);

        List<String> ids = new List<String>();
        for (QuoteLineItem qids : qliList) {
            ids.add(qids.Id);
        }

        String jsonString = JSON.serialize(QliGridController.getQlis('[]', qo.Id));
        QliGridController.saveQuantities(jsonString, qo.Id);
        QliGridController.saveQlis(jsonString, qo.Id);
        QliGridController.deleteQlis(ids);
        QliGridController.findTrabajos(tipotraba.Name);
        QliGridController.setPublicFileWO(contentIds, qo.Id);
        QliGridController.setPublicFile(nuevoscd, qo.Id);
        // WoliGridController.getTiposDeTrabajo(wo.Id);
        WoliGridQueryService.Method();

        // ======================= AÑADIDOS PARA NUEVAS COBERTURAS =======================
        // 1) getTiposTrabajoPorMO: Product2 (MO) -> tiposDeTrabajo__c
        tiposDeTrabajo__c ttMO = new tiposDeTrabajo__c(
            Name = 'TT para MO',
            ManoDeObra__c = prodMO.Id
        );
        insert ttMO;

        Map<Id, Id> moToTipoTrabajo = QLIGridController.getTiposTrabajoPorMO(new List<Id>{ prodMO.Id });
        System.assert(moToTipoTrabajo != null, 'El mapa no debe ser null');
        System.assertEquals(ttMO.Id, moToTipoTrabajo.get(prodMO.Id), 'Debe devolver el TT asociado al Product2 de Mano de Obra');

        // 2) saveQuoliQuantities: actualiza Quantity y Cantidad_devolucion__c
        QuoteLineItem qli3 = new QuoteLineItem(
            QuoteId = qo.Id,
            PricebookEntryId = standardPBE.Id,
            Product2Id = prod.Id,
            Quantity = 1,
            UnitPrice = 10,
            BMW_Bodega__c = bodega.Id
        );
        insert qli3;

        String jsonForQty = '[{"qolId":"' + qli3.Id + '","cantidad":5,"cantidadDevolucion":1}]';
        QliGridDML dmlQty = new QliGridDML(jsonForQty);
        dmlQty.saveQuoliQuantities(qo.Id);

        QuoteLineItem qli3After = [
            SELECT Quantity, Cantidad_devolucion__c
            FROM QuoteLineItem
            WHERE Id = :qli3.Id
        ];
        System.assertEquals(5, qli3After.Quantity, 'Quantity debe actualizarse a 5');
        System.assertEquals(1, qli3After.Cantidad_devolucion__c, 'Cantidad_devolucion__c debe actualizarse a 1');

        // 3) deleteQuoteLineItems: elimina QLIs
        //QliGridDML.deleteQuoteLineItems(new List<String>{ qli3.Id });
        //Integer countAfterDelete = [SELECT COUNT() FROM QuoteLineItem WHERE Id = :qli3.Id];
        //System.assertEquals(0, countAfterDelete, 'El QLI debe haber sido eliminado por deleteQuoteLineItems');

        // 4) toTipoCargoValue: mapeos y bordes
        System.assertEquals('1', QliGridDML.toTipoCargoValue('Cliente'), 'Cliente -> 1');
        System.assertEquals('2', QliGridDML.toTipoCargoValue('2'), 'Valor ya normalizado se preserva');
        System.assertEquals('3', QliGridDML.toTipoCargoValue('Aseguradora'), 'Aseguradora -> 3');
        System.assertEquals('4', QliGridDML.toTipoCargoValue('Garantía'), 'Garantía (acentos) -> 4');
        System.assertEquals('4', QliGridDML.toTipoCargoValue('garantia'), 'garantia (sin acento) -> 4');
        System.assertEquals('5', QliGridDML.toTipoCargoValue('bsi'), 'bsi -> 5 (case-insensitive)');
        System.assertEquals('6', QliGridDML.toTipoCargoValue('BSI interno'), 'BSI interno -> 6');
        System.assertEquals(null, QliGridDML.toTipoCargoValue('Desconocido'), 'Valores no mapeados -> null');
        // ===================== FIN AÑADIDOS PARA NUEVAS COBERTURAS ======================

        Test.stopTest();
    }

}