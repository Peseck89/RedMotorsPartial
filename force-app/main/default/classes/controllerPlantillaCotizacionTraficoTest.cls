@isTest 
private class controllerPlantillaCotizacionTraficoTest {
    
    static{
        TestDataFactory.datosGenerales();
    }
    
    @isTest
    private static void testBMW() {
        //Se crea la configuración de venta para establecer la lista de precio vigente
        Configuracion_de_ventas__c cdv = new Configuracion_de_ventas__c();
        cdv.Name = 'Configuración BMW';
        cdv.Listas_de_Precios_Vigente__c = 'BMW - 2018';
        cdv.Marca__c = 'BMW';
        insert cdv;
        
        //Se crea la campaña
        Campaign camp = new Campaign();
        camp.Name = 'Expomovil 2017';
        camp.IsActive = true;
        insert camp;
        
        //Se crea la lista de precios
        Pricebook2 pb2 = new Pricebook2();
        pb2.Name = 'BMW - 2018';
        pb2.IsActive = true;
        insert pb2;
        
        //Se crean los productos
        Product2 prod = new Product2();
        prod.Name = 'BM101 - X2 - Sdrive 18i Premium';
        prod.Codigo_de_Producto__c = 'BM101';
        prod.ProductCode = 'BM101';
        prod.IsActive = true;
        prod.Marca__c = 'BMW';
        prod.Description = 'X2 - Sdrive 18i Premium';
        prod.NombredePlantilla__c = 'BMWX2AgradecimientoVisita';
        prod.Familia__c = 'X2';
        insert prod;
        
        //Se crean las listas de precios standard
        PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = prod.Id, UnitPrice = 35000, IsActive = true);
        //insert standardPBE;
        
        //Se agregan los productos a la listas de precios que se crearon anteriormente
        PricebookEntry pbe = new PricebookEntry();
        pbe.Product2Id = prod.Id;
        pbe.Pricebook2Id = pb2.Id;
        pbe.UnitPrice = 35000;
        pbe.UseStandardPrice = false;
        pbe.IsActive = true;
        insert pbe;
        
        //Se trae al propietario del Lead
        User u = new User();
        u = [SELECT Id, Name FROM User WHERE Name =: 'Intellect Solutions'];
        
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Lead;
        Map<String,Schema.RecordTypeInfo> LeadRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
        Id rtId = LeadRecordTypeInfo.get('BMW').getRecordTypeId();
        System.debug('hhhhh' + rtId);
        List<Lead> leadlist = new List<Lead>();
        Lead ld = new Lead();
        ld.RecordTypeId = rtId;
        ld.FirstName  = 'David';
        ld.LastName = 'Leon Sanchez';
        ld.Email = 'david.leon@i-solutionsinc.com';
        ld.MobilePhone = '88888888';
        ld.Sucursal__c = 'Escazú';
        ld.FechaPosibleCompra__c = '1 a 3 meses';
        ld.Campana__c = TestDataFactory.campanna.Id;
        ld.Status = 'Nuevo';
        ld.LeadSource = 'Trade Show';
        ld.Tipo_de_Identificaci_n__c = 'Cedula';
        ld.Numero_de_Identificacion_del__c = '402080760';
        ld.Marca__c = prod.Marca__c;
        ld.Familia1__c = prod.Familia__c;
        ld.Modelo_De_Inter_s1__c = prod.Name;
        ld.Marca2__c = prod.Marca__c;
        ld.Familia2__c = prod.Familia__c;
        ld.Modelo_De_Inter_s2__c = prod.Name;
        ld.Marca3__c = prod.Marca__c;
        ld.Familia3__c = prod.Familia__c;
        ld.Modelo_De_Inter_s3__c = prod.Name;
        ld.Marca4__c = prod.Marca__c;
        ld.Familia4__c = prod.Familia__c;
        ld.Modelo_De_Inter_s4__c = prod.Name;
        ld.EsWeb2Lead_del__c = false;
        ld.Precio1__c = 45454542.04;
        ld.Precio2__c = 45454542.04;
        ld.Precio3__c = 45454542.04;
        ld.Precio4__c = 45454542.04;
        ld.OwnerId = u.Id;
        Test.startTest();
        TriggerHandler.bypass('TraficoTriggerHandler');
        
        insert ld;
        
            
        TriggerHandler.clearBypass('TraficoTriggerHandler');
        
        ld.Cotizacion_1__c = true;
        ld.Cotizacion_2__c = true;
        ld.Cotizacion_3__c = true;
        ld.Cotizacion_4__c = true;
        TriggerHandler.bypass('TraficoTriggerHandler');
        update ld;
        TriggerHandler.clearBypass('TraficoTriggerHandler');
        
        String resultado = WSenvioCotizacionTrafico.envioCotizacion(ld.Id, ld.OwnerId);
        
        TraficoTriggerHandler traficoTrgHand = new TraficoTriggerHandler();
        traficoTrgHand.newInvs = leadlist;
        traficoTrgHand.beforeInsert();
        traficoTrgHand.beforeUpdate();
        traficoTrgHand.afterInsert();
        traficoTrgHand.afterUpdate();
        Test.stopTest();
    }
    
    @isTest
    private static void testBMW2() {
        //Se crea la configuración de venta para establecer la lista de precio vigente
        Configuracion_de_ventas__c cdv = new Configuracion_de_ventas__c();
        cdv.Name = 'Configuración BMW';
        cdv.Listas_de_Precios_Vigente__c = 'BMW - 2018';
        cdv.Marca__c = 'BMW';
        insert cdv;
        
        //Se crea la campaña
        Campaign camp = new Campaign();
        camp.Name = 'Expomovil 2017';
        camp.IsActive = true;
        insert camp;
        
        //Se crea la lista de precios
        Pricebook2 pb2 = new Pricebook2();
        pb2.Name = 'BMW - 2018';
        pb2.IsActive = true;
        insert pb2;
        
        //Se crean los productos
        Product2 prod = new Product2();
        prod.Name = 'BM101 - X2 - Sdrive 18i Premium';
        prod.Codigo_de_Producto__c = 'BM101';
        prod.ProductCode = 'BM101';
        prod.IsActive = true;
        prod.Marca__c = 'BMW';
        prod.Description = 'X2 - Sdrive 18i Premium';
        prod.NombredePlantilla__c = 'BMWX2AgradecimientoVisita';
        prod.Familia__c = 'X2';
        insert prod;
        
        //Se crean las listas de precios standard
        //PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = prod.Id, UnitPrice = 35000, IsActive = true);
        //insert standardPBE;
        
        //Se agregan los productos a la listas de precios que se crearon anteriormente
        PricebookEntry pbe = new PricebookEntry();
        pbe.Product2Id = prod.Id;
        pbe.Pricebook2Id = pb2.Id;
        pbe.UnitPrice = 35000;
        pbe.UseStandardPrice = false;
        pbe.IsActive = true;
        insert pbe;
        
        //Se trae al propietario del Lead
        User u = new User();
        u = [SELECT Id, Name FROM User WHERE Name =: 'Intellect Solutions'];
        
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Lead;
        Map<String,Schema.RecordTypeInfo> LeadRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
        Id rtId = LeadRecordTypeInfo.get('BMW').getRecordTypeId();
        System.debug('hhhhh' + rtId);
        
        Lead ld = new Lead();
        ld.RecordTypeId = rtId;
        ld.FirstName  = 'David';
        ld.LastName = 'Leon Sanchez';
        ld.Email = 'david.leon@i-solutionsinc.com';
        ld.MobilePhone = '88888888';
        ld.Sucursal__c = 'Escazú';
        ld.FechaPosibleCompra__c = '1 a 3 meses';
        ld.Campana__c = TestDataFactory.campanna.Id;
        ld.Status = 'Nuevo';
        ld.LeadSource = 'Página Web';
        ld.Tipo_de_Identificaci_n__c = 'Cedula';
        ld.Numero_de_Identificacion_del__c = '402080760';
        ld.Marca__c = prod.Marca__c;
        ld.Familia1__c = prod.Familia__c;
        ld.Modelo_De_Inter_s1__c = prod.Name;
        ld.Marca2__c = prod.Marca__c;
        ld.Familia2__c = prod.Familia__c;
        ld.Modelo_De_Inter_s2__c = prod.Name;
        ld.Marca3__c = prod.Marca__c;
        ld.Familia3__c = prod.Familia__c;
        ld.Modelo_De_Inter_s3__c = prod.Name;
        ld.Marca4__c = prod.Marca__c;
        ld.Familia4__c = prod.Familia__c;
        ld.Modelo_De_Inter_s4__c = prod.Name;
        ld.EsWeb2Lead_del__c = false;
        ld.OwnerId = u.Id;
        ld.Precio1__c = 45454542.04;
        ld.Precio2__c = 45454542.04;
        ld.Precio3__c = 45454542.04;
        ld.Precio4__c = 45454542.04;
        TriggerHandler.bypass('TraficoTriggerHandler');
        insert ld;
        TriggerHandler.clearBypass('TraficoTriggerHandler');
        
        Test.startTest();
        String resultado = WSenvioCotizacionTrafico.envioCotizacion(ld.Id, ld.OwnerId);
        //User u2 = controllerPlantillaCotizacionTrafico.user();
        controllerPlantillaCotizacionTrafico.datosLogoMarca datosLogo = new controllerPlantillaCotizacionTrafico.datosLogoMarca();
        datosLogo.height = 20;
        datosLogo.source = 'fuente';
        datosLogo.width = 10;
        Test.stopTest();
    }
    @isTest
    private static void testBMW3() {
        
        //Se crea la configuración de venta para establecer la lista de precio vigente
        Configuracion_de_ventas__c cdv = new Configuracion_de_ventas__c();
        cdv.Name = 'Configuración BMW';
        cdv.Listas_de_Precios_Vigente__c = 'BMW - 2018';
        cdv.Marca__c = 'BMW';
        insert cdv;
        
        //Se crea la campaña
        Campaign camp = new Campaign();
        camp.Name = 'Expomovil 2017';
        camp.IsActive = true;
        insert camp;
        
        //Se crea la lista de precios
        Pricebook2 pb2 = new Pricebook2();
        pb2.Name = 'BMW - 2018';
        pb2.IsActive = true;
        insert pb2;
        
        //Se crean los productos
        Product2 prod = new Product2();
        prod.Name = 'BM101 - X2 - Sdrive 18i Premium';
        prod.Codigo_de_Producto__c = 'BM101';
        prod.ProductCode = 'BM101';
        prod.IsActive = true;
        prod.Marca__c = 'BMW';
        prod.Description = 'X2 - Sdrive 18i Premium';
        prod.NombredePlantilla__c = 'BMWX2AgradecimientoVisita';
        prod.Familia__c = 'X2';
        insert prod;
        
        //Se crean las listas de precios standard
        //PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = prod.Id, UnitPrice = 35000, IsActive = true);
        //insert standardPBE;
        
        //Se agregan los productos a la listas de precios que se crearon anteriormente
        PricebookEntry pbe = new PricebookEntry();
        pbe.Product2Id = prod.Id;
        pbe.Pricebook2Id = pb2.Id;
        pbe.UnitPrice = 35000;
        pbe.UseStandardPrice = false;
        pbe.IsActive = true;
        insert pbe;
        
        //Se trae al propietario del Lead
        User u = new User();
        u = [SELECT Id, Name FROM User WHERE Name =: 'Intellect Solutions'];
        
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Lead;
        Map<String,Schema.RecordTypeInfo> LeadRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
        Id rtId = LeadRecordTypeInfo.get('BMW').getRecordTypeId();
        System.debug('hhhhh' + rtId);
        
        Lead ld = new Lead();
        ld.RecordTypeId = rtId;
        ld.FirstName  = 'David';
        ld.LastName = 'Leon Sanchez';
        ld.Email = 'david.leon1@i-solutionsinc.com';
        ld.MobilePhone = '88888888';
        ld.Sucursal__c = 'Escazú';
        ld.FechaPosibleCompra__c = '1 a 3 meses';
        ld.Campana__c = TestDataFactory.campanna.Id;
        ld.Status = 'Nuevo';
        ld.LeadSource = 'Página Web';
        ld.Tipo_de_Identificaci_n__c = 'Cedula';
        ld.Numero_de_Identificacion_del__c = '402080760';
        ld.Marca__c = prod.Marca__c;
        ld.Familia1__c = prod.Familia__c;
        ld.Modelo_De_Inter_s1__c = prod.Name;
        ld.EsWeb2Lead_del__c = false;
        ld.OwnerId = u.Id;
        ld.Precio1__c = 2;
        insert ld;
    }
}