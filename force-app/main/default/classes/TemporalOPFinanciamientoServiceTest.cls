@isTest
private class TemporalOPFinanciamientoServiceTest {
    
    /*static{
        TestDataFactory.datosGenerales();
    }
    
    static testMethod void test1() {
        
        //Se crea una campana
        Campaign camp = new Campaign();
        camp.Name = 'Feria Aima';
        insert camp;
        
        //Se crea una cuenta
        Account act = new Account();
        act.FirstName = 'David';
        act.LastName = 'Leon Sanchez';
        act.Tipo_de_Documento__c = 'Cedula';
        act.Cedula__c = '402080760';
        insert act;
        
        //Se crea la lista de precio y el producto
        Pricebook2 pb2 = new Pricebook2();
        pb2.Name = 'Precios - Nuevos dummy';
        pb2.IsActive = true;
        insert pb2;

        Product2 prod = new Product2();
        prod.Name = 'Nuevo - Dummy';
        prod.Codigo_de_Producto__c = 'Nuevo';
        prod.ProductCode = 'Nuevo';
        prod.IsActive = true;
        prod.Marca__c = 'MINI';
        prod.Description = 'Nuevo';
        
        insert prod;
        System.debug('qqqqq' + prod);

        PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = prod.Id, UnitPrice = 1000, IsActive = true);
        insert standardPBE;

        PricebookEntry pbe = new PricebookEntry();
        pbe.Product2Id = prod.Id;
        pbe.Pricebook2Id = pb2.Id;
        pbe.UnitPrice = 98000;
        pbe.UseStandardPrice = false;
        pbe.IsActive = true;
        System.debug('ppppp' + pbe);
        insert pbe;
        
        test.startTest();
            TemporalOPFinanciamiento__c reg = new TemporalOPFinanciamiento__c();
            reg.Name = 'prueba';
            reg.OwnerId = [SELECT Id FROM User WHERE Name =: 'Intellect Solutions'].Id;
            System.debug('****** OwnerId ****** ' + reg.OwnerId);
            reg.anovehiculo__c = '2018';
            reg.AprobadorAltica__c = [SELECT Name FROM User WHERE Name =: 'Intellect Solutions'].Name;
            System.debug('****** Aprobador altica ***** ' + reg.AprobadorAltica__c);
            reg.Cambiapropietario__c = false;
            reg.Campana__c = TestDataFactory.campanna.Id;
            reg.Categor_a__c = 'Automóvil';
            reg.CodigoideVehiculo__c = 'NO DISPONIBLE';
            reg.Comentarios_Financieros__c = 'prueba';
            reg.ComentariosInternos__c = 'prueba';
            reg.Correoelectronico__c = 'david.leon@i-solutionsinc.com';
            reg.Creado_por__c = 'no disponible';
            reg.Cuotatotal__c = 1000;
            reg.EstadoOpF__c = 'Denegado';
            reg.EsUsado__c = false;
            reg.Etapa_Oportunidad__c = 'Cotizado y pre aprobado';
            reg.FechaInicioOpF__c = System.today();
            reg.FechaFinOpF__c = System.today();
            reg.Identificacioncliente__c = '402080760';
            reg.Ingreso__c = 10000;
            reg.Listapreasignada__c = true;
            reg.Marcavehiculo__c = prod.Marca__c;
            reg.Modelovehiculo__c = 'NO DISPONIBLE';
            reg.Moneda__c = 'Colones';
            reg.Monedaingreso__c = 'Colones';
            reg.Montoafinanciar__c = 30000;
            reg.Nombrecliente__c = act.FirstName + ' ' + act.LastName;
            reg.Origen_candidato__c = 'Walking';
            reg.Plazo__c = '24';
            reg.Primavehiculo__c = 2500;
            reg.Productofinanciero__c = 'Leasing operativo en función financiera';
            reg.Propietario__c = [SELECT Name FROM User WHERE Name =: 'Intellect Solutions'].Name;
            System.debug('****** Propietario ****** ' + reg.Propietario__c);
            reg.Razondeperdidafinanciamiento__c = 'Tasa';
            reg.Score__c = 900;
            reg.SubCategoria__c = 'Nuevo';
            reg.Sucursal__c = 'Escazú';
            reg.Telefonomovil__c = '83082728';
            reg.Valorfinanciamiento__c = 25000;
            reg.Llave__c = '1';
            insert reg;
        test.stopTest();
    }
    
    static testMethod void test2() {
        //Se crea una campana
        Campaign camp = new Campaign();
        camp.Name = 'Feria Aima';
        insert camp;
        
        //Se crea la lista de precio y el producto
        Pricebook2 pb2 = new Pricebook2();
        pb2.Name = 'Precios - Usados dummy';
        pb2.IsActive = true;
        insert pb2;

        Product2 prod = new Product2();
        prod.Name = 'Usado - Dummy';
        prod.Codigo_de_Producto__c = 'Usado';
        prod.ProductCode = 'Usado';
        prod.IsActive = true;
        prod.Marca__c = 'MINI';
        prod.Description = 'Usado';
        
        insert prod;
        System.debug('qqqqq' + prod);

        PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = prod.Id, UnitPrice = 1000, IsActive = true);
        insert standardPBE;

        PricebookEntry pbe = new PricebookEntry();
        pbe.Product2Id = prod.Id;
        pbe.Pricebook2Id = pb2.Id;
        pbe.UnitPrice = 98000;
        pbe.UseStandardPrice = false;
        pbe.IsActive = true;
        System.debug('ppppp' + pbe);
        insert pbe;
        
        test.startTest();
            TemporalOPFinanciamiento__c reg = new TemporalOPFinanciamiento__c();
            reg.Name = 'prueba';
            reg.OwnerId = [SELECT Id FROM User WHERE Name =: 'Intellect Solutions'].Id;
            System.debug('****** OwnerId ****** ' + reg.OwnerId);
            reg.anovehiculo__c = '2018';
            reg.AprobadorAltica__c = [SELECT Name FROM User WHERE Name =: 'Intellect Solutions'].Name;
            System.debug('****** Aprobador altica ***** ' + reg.AprobadorAltica__c);
            reg.Cambiapropietario__c = false;
            reg.Campana__c = TestDataFactory.campanna.Id;
            reg.Categor_a__c = 'Automóvil';
            reg.CodigoideVehiculo__c = 'NO DISPONIBLE';
            reg.Comentarios_Financieros__c = 'prueba';
            reg.ComentariosInternos__c = 'prueba';
            reg.Correoelectronico__c = 'david.leon@i-solutionsinc.com';
            reg.Creado_por__c = 'isolu';
            reg.Cuotatotal__c = 1000;
            reg.EstadoOpF__c = 'Denegado';
            reg.EsUsado__c = true;
            reg.Etapa_Oportunidad__c = 'Cotizado y pre aprobado';
            reg.FechaInicioOpF__c = System.today();
            reg.FechaFinOpF__c = System.today();
            reg.Identificacioncliente__c = '402080760';
            reg.Ingreso__c = 10000;
            reg.Listapreasignada__c = true;
            reg.Marcavehiculo__c = prod.Marca__c;
            reg.Modelovehiculo__c = 'NO DISPONIBLE';
            reg.Moneda__c = 'Colones';
            reg.Monedaingreso__c = 'Colones';
            reg.Montoafinanciar__c = 30000;
            reg.Nombrecliente__c = 'David Leon Sanchez';
            reg.Origen_candidato__c = 'Walking';
            reg.Plazo__c = '24';
            reg.Primavehiculo__c = 2500;
            reg.Productofinanciero__c = 'Leasing operativo en función financiera';
            reg.Propietario__c = [SELECT Name FROM User WHERE Name =: 'Intellect Solutions'].Name;
            System.debug('****** Propietario ****** ' + reg.Propietario__c);
            reg.Razondeperdidafinanciamiento__c = 'Tasa';
            reg.Score__c = 900;
            reg.SubCategoria__c = 'Usado';
            reg.Sucursal__c = 'Escazú';
            reg.Telefonomovil__c = '83082728';
            reg.Valorfinanciamiento__c = 25000;
            reg.Llave__c = '1';
            insert reg;
        test.stopTest();
        
    }
    
    static testMethod void test3() {
        //Se crea una campana
        Campaign camp = new Campaign();
        camp.Name = 'Feria Aima';
        insert camp;
        
        //Se crea la lista de precio y el producto
        Pricebook2 pb2 = new Pricebook2();
        pb2.Name = 'MINI - 2017';
        pb2.IsActive = true;
        insert pb2;

        Product2 prod = new Product2();
        prod.Name = 'MI2 - COOPER 3PTS (AT)';
        prod.Codigo_de_Producto__c = 'MI2';
        prod.ProductCode = 'MI2';
        prod.IsActive = true;
        prod.Marca__c = 'MINI';
        prod.Description = 'MINI';
        
        insert prod;
        System.debug('qqqqq' + prod);

        PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = prod.Id, UnitPrice = 1000, IsActive = true);
        insert standardPBE;

        PricebookEntry pbe = new PricebookEntry();
        pbe.Product2Id = prod.Id;
        pbe.Pricebook2Id = pb2.Id;
        pbe.UnitPrice = 98000;
        pbe.UseStandardPrice = false;
        pbe.IsActive = true;
        System.debug('ppppp' + pbe);
        insert pbe;
        
        test.startTest();
            TemporalOPFinanciamiento__c reg = new TemporalOPFinanciamiento__c();
            reg.Name = 'prueba';
            reg.OwnerId = [SELECT Id FROM User WHERE Name =: 'Intellect Solutions'].Id;
            System.debug('****** OwnerId ****** ' + reg.OwnerId);
            reg.anovehiculo__c = '2017';
            reg.AprobadorAltica__c = [SELECT Name FROM User WHERE Name =: 'Intellect Solutions'].Name;
            System.debug('****** Aprobador altica ***** ' + reg.AprobadorAltica__c);
            reg.Cambiapropietario__c = false;
            reg.Campana__c = TestDataFactory.campanna.Id;
            reg.Categor_a__c = 'Moto';
            reg.CodigoideVehiculo__c = 'MI2';
            reg.Comentarios_Financieros__c = 'prueba';
            reg.ComentariosInternos__c = 'prueba';
            reg.Correoelectronico__c = 'david.leon@i-solutionsinc.com';
            reg.Creado_por__c = 'Hroja';
            reg.Cuotatotal__c = 1000;
            reg.EstadoOpF__c = 'Denegado';
            reg.EsUsado__c = true;
            reg.Etapa_Oportunidad__c = 'Cotizado y pre aprobado';
            reg.FechaInicioOpF__c = System.today();
            reg.FechaFinOpF__c = System.today();
            reg.Identificacioncliente__c = '402080760';
            reg.Ingreso__c = 10000;
            reg.Listapreasignada__c = false;
            reg.Marcavehiculo__c = prod.Marca__c;
            reg.Modelovehiculo__c = 'MI2 - COOPER 3PTS (AT)';
            reg.Moneda__c = 'Colones';
            reg.Monedaingreso__c = 'Colones';
            reg.Montoafinanciar__c = 30000;
            reg.Nombrecliente__c = 'David Leon Sanchez';
            reg.Origen_candidato__c = 'Walking';
            reg.Plazo__c = '24';
            reg.Primavehiculo__c = 2500;
            reg.Productofinanciero__c = 'Leasing operativo en función financiera';
            reg.Propietario__c = [SELECT Name FROM User WHERE Name =: 'Intellect Solutions'].Name;
            System.debug('****** Propietario ****** ' + reg.Propietario__c);
            reg.Razondeperdidafinanciamiento__c = 'Tasa';
            reg.Score__c = 900;
            reg.SubCategoria__c = 'Alta Cilindrada';
            reg.Sucursal__c = 'Escazú';
            reg.Telefonomovil__c = '83082728';
            reg.Valorfinanciamiento__c = 25000;
            reg.Llave__c = '1';
            insert reg;
        test.stopTest();
        
    }*/
}