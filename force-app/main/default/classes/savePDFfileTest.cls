@isTest
public class savePDFfileTest {
    public static testmethod void testAttachPDFinCase(){
        OperatingHours oh = new OperatingHours();
        oh.CurrencyIsoCode ='CRC';
        oh.Name = 'Horario Regular 34';
        oh.TimeZone = 'America/Costa_Rica';
        insert oh;
        ServiceTerritory st = new ServiceTerritory();
        st.Name = 'TesteoUruca - Mecánica General';     
        st.OperatingHoursId = oh.Id;
        insert st;
        Pricebook2 pb = new Pricebook2(Name='Dolar2', IsActive=true);
        insert pb;
        Account acc = new Account(Name='Test account', Cedula__c='9876543210', Tipo_de_Documento__c='02');
       	insert acc;
        
       	Contact co = new Contact(Firstname='Juan Diego',LastName='Espinoza S1', Email='jesp@abc.com', AccountId=acc.Id);
       	insert co;
        
       	Asset asset = new Asset(Name='BMW X6', ContactId=co.Id, AccountId=acc.Id);
       	insert asset;

        Id pricebookId = pb.Id;

        WorkOrder wo = new WorkOrder(subject ='title2', Pricebook2Id=pricebookId, tipoDeGasto__c='Cliente', AssetId=asset.Id,AccountId=acc.Id);
        insert wo;

        //------------------ new
        Case cs = new Case(
            Type = 'Mecánica General',
            categoria__c = 'Interno',
            StatusDetail__c = 'Recibido',
            Priority = 'Alta',//Media,Baja
            AccountId = acc.Id,
            ContactId = co.Id,
            AssetId = asset.Id,
            Service_Territory1__c = st.Id
        );
        insert cs;
        Opportunity op = new Opportunity(contacto__c = co.Id,AccountId = acc.id, CloseDate = System.today().AddMonths(3), StageName = 'Oportunidad Calificada', DescuentoAprobado__c = true);   
        insert op;

        String ot = 'Orden de trabajo';
        String otMotos = 'Orden de trabajo motos';
        String otCuadra = 'Orden de trabajo cuadra';
        String otMula = 'Orden de trabajo mula';
        String result, url, fileID;
        Boolean descuentoAprobado;
        Boolean hasContact;
        Boolean vehiculoReservado;
        Boolean envioFormalizacion;
        Quote qo =  new Quote(Name ='testqo',Pricebook2Id=pricebookId,OpportunityId=op.Id);
        insert qo;
        Bodega__c bodega = new Bodega__c(bodega__c = 'BR01', ID_EXTERNO_BODEGA__c = 'BR01', Name = 'BR01');
        insert bodega;
        
        BodegaxTerritorio__c bxt = new BodegaxTerritorio__c(ServiceTerritory__c = st.Id, isPrincipal__c = true, Bodega__c = bodega.Id);
        insert bxt;
        
        //Insert product        
        Product2 prod= new Product2(IsActive=true, Name='Teste product2',tipoProducto__c='Materiales', ProductCode='L00012', Codigo_de_Producto__c='L00012');
        insert prod;
        
        insert new ProductoXBodega__c(Producto__c = prod.Id, Bodega__c = bodega.Id);
        
        Product2 prodMO= new Product2(IsActive=true, Name='Mano de Obra',tipoProducto__c='Mano de Obra', ProductCode='00012', Codigo_de_Producto__c='0012');
        insert prodMO;

        // Insert PricebookEntry
        //Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];
        PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id =pricebookId, Product2Id = prod.Id, UnitPrice = 2000, IsActive = true);
        insert standardPBE;

        QuoteLineItem qli = new QuoteLineItem();
        qli.QuoteId = qo.Id;
        qli.Quantity = 2;
        qli.PricebookEntryId = standardPBE.Id;
        qli.Product2Id = prod.Id;
        qli.UnitPrice = 1;
        qli.BMW_Bodega__c = bodega.Id;
        insert qli;
        Test.startTest();
        String prueba = savePDFfile.getRecipientEmail(st.Id);
        String prueba2 = savePDFfile.attachPDFinWO(wo.Id, 'test', 'vftest',true,true,'test@gmail.com');
        String prueba3 = savePDFfile.attachPDFinQuote(qo.Id, 'test', 'vftest',true,true,'test@gmail.com');
        result = savePDFfile.attachPDFinCase(cs.Id, ot, null);
        System.assertEquals('Success', result, 'Error: error in attachPDFinCase in case ' + ot );
        result = savePDFfile.attachPDFinCase(cs.Id, otMotos, null);
        System.assertEquals('Success', result, 'Error: error in attachPDFinCase in case ' + otMotos );
        result = savePDFfile.attachPDFinCase(cs.Id, otCuadra, null);
        System.assertEquals('Success', result, 'Error: error in attachPDFinCase in case ' + otCuadra );
        result = savePDFfile.attachPDFinCase(cs.Id, otMula, null);
        System.assertEquals('Success', result, 'Error: error in attachPDFinCase in case ' + otMula );
        url = savePDFfile.getURL();
        System.assertEquals(System.URL.getSalesforceBaseUrl().toExternalForm(), url, 'Error: error in getURL method');
        descuentoAprobado = savePDFfile.getDescuentoAprobado(op.Id);
        hasContact = savePDFfile.getHasContact(op.Id);
        vehiculoReservado = savePDFfile.getVehiculoReservado(op.Id);
        envioFormalizacion = savePDFfile.getEnvioFormalizacion(op.Id);
        fileID = savePDFfile.getRelatedFile(cs.Id, otMula);
        result = savePDFfile.attachPDFinOpportunity(op.Id, 'test', 'vftest', true, false, 'test@email.com');
        // String s = 'AlbaranCargoSeleccionadoPDF?id='+wo.Id;
        // savePDFfile.attachPDFinWO(wo.Id, 'Despacho de repuestos por tipo de cargo', s, true, 'email@emial.com');
        //System.assertEquals('Success', result, 'Error: error in attachPDFinWO in case ' + 'Despacho de repuestos por tipo de cargo' );
        Test.stopTest();
    }
}