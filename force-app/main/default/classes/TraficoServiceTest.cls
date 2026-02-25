@IsTest
public class TraficoServiceTest {

    static{
        TestDataFactory.datosGenerales();
    }
    
//     static testMethod void insertLead1(){
//         //Configuracion Ventas
//         Configuracion_de_Ventas__c cdv = new Configuracion_de_Ventas__c();
//         cdv.Name = 'Configuracion BMW';
//         cdv.Listas_de_Precios_Vigente__c = 'BMW - 2020';
//         cdv.Marca__c = 'BMW';
//         insert cdv;
    
//         //Crear Datos Generales
//         System.debug('datos generales');
//         //TestDataFactory.datosGenerales();
        
//         //Crear Cuentas
//         System.debug('Crear cuenta');
//         Account a = new Account();
//         a.FirstName = 'Test';
//         a.LastName = 'Test';
//         a.Tipo_de_Documento__c = 'Cedula';
//         a.Cedula__c = '117450873';
//         a.PersonMobilePhone = '+50683838383';
//         a.PersonEmail = 'da_ls90@hotmail.es';
//         insert a;
        
//         //Crear Product
//         System.debug('Crear producto');
//         Pricebook2 pb2 = new Pricebook2();
//         pb2.Name = 'BMW - 2020';
//         pb2.IsActive = true;
//         insert pb2;

//         Pricebook2 pb3 = new Pricebook2();
//         pb3.Name = 'BMW - 2019';
//         pb3.IsActive = true;
//         insert pb3;
        

        
//         System.debug('Crear producto2');
//         Product2 prod = new Product2();
//         prod.Name = 'BM105 - X5 - 45e Premium';
//         prod.Codigo_de_Producto__c = 'BM105';
//         prod.ProductCode = 'BM105';
//         prod.IsActive = true;
//         prod.esVehiculo__c = true;
//         prod.Marca__c = 'BMW';
//         prod.Description = 'BM105 - X5 - 45e Premium';
//         prod.NombredePlantilla__c = 'BMWX5AgradecimientoVisita';
//         prod.Familia__c = 'X5';
//         insert prod;
        
//         //+++++++++++++++++++++++++++++++++++++++++
//         System.debug('qqqqq' + prod);
//         Product2 prod2 = new Product2();
//         prod2.Name = 'BM27 - X1 - 1.8d EXECUTIVE';
//         prod2.Codigo_de_Producto__c = 'BM27';
//         prod2.ProductCode = 'BM27';
//         prod2.IsActive = true;
//         prod2.Marca__c = 'BMW';
//         prod2.Description = 'X1 1.8d EXECUTIVE';
//         prod2.NombredePlantilla__c = 'BMWX1AgradecimientoVisita';
//         prod2.Familia__c = 'X1';
//         insert prod2;
        
//         //++++++++++++++++++++++++++++++++++++++++++++++++
//         //Producto 2
//         System.debug('Crear producto3');
//         Product2 prod3 = new Product2();
//         prod3.Name = 'BM52 - X1 - 1.8i Business';
//         prod3.Codigo_de_Producto__c = 'BM52';
//         prod3.ProductCode = 'BM52';
//         prod3.IsActive = true;
//         prod3.Marca__c = 'BMW';
//         prod3.Description = 'BM52 - X1 - 1.8i Business';
//         prod3.NombredePlantilla__c = 'BMWX2AgradecimientoVisita';
//         prod3.Familia__c = 'X1';
//         insert prod3;
//         //+++++++++++++++++++++++++++++++++++++++++++++++++++++++
//         // System.debug('Crear producto3');
//         // PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = prod.Id, UnitPrice = 100000, IsActive = true);
//         // insert standardPBE;
        
//         // PricebookEntry standardPBE2 = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = prod2.Id, UnitPrice = 100000, IsActive = true);
//         // insert standardPBE2;
//         // //NuevoProducto 3
//         // PricebookEntry standardPBE3 = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = prod3.Id, UnitPrice = 100000, IsActive = true);
//         // insert standardPBE3;
        
//         System.debug('Crear producto4');
//         PricebookEntry pbe = new PricebookEntry();
//         pbe.Product2Id = prod.Id;
//         pbe.Pricebook2Id = pb2.Id;
//         pbe.UnitPrice = 90000;
//         pbe.UseStandardPrice = false;
//         pbe.IsActive = true;
//         insert pbe;
        
//         PricebookEntry pbe2 = new PricebookEntry();
//         pbe2.Product2Id = prod2.Id;
//         pbe2.Pricebook2Id = pb3.Id;
//         pbe2.UnitPrice = 90000;
//         pbe2.UseStandardPrice = false;
//         pbe2.IsActive = true;
//         insert pbe2;
        
//         PricebookEntry pbe3 = new PricebookEntry();
//         pbe3.Product2Id = prod3.Id;
//         pbe3.Pricebook2Id = pb3.Id;
//         pbe3.UnitPrice = 90000;
//         pbe3.UseStandardPrice = false;
//         pbe3.IsActive = true;
//         insert pbe3;
        
//         //Select tipo de registro 
//         System.debug('Buscar tipo registro');
//         Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Lead;
//         Map<String,Schema.RecordTypeInfo> LeadRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
//         Id rtId = LeadRecordTypeInfo.get('BMW').getRecordTypeId();
        
//         //Crear documentos doc1.FolderId = '00l0P000000SxfpQAC'
//         Document doc1 = new Document();
//         doc1.Name = 'Test 1';
//         doc1.DeveloperName = 'BM105a';
//         doc1.FolderId = UserInfo.getUserId();
//         insert doc1;

// 		Document doc2 = new Document();
//         doc2.Name = 'Test 2';
//         doc2.DeveloperName = 'BM52a';
//         doc2.FolderId = UserInfo.getUserId();
//         insert doc2;

// 		Document doc3 = new Document();
//         doc3.Name = 'Test 3';
//         doc3.DeveloperName = 'BM27a';
//         doc3.FolderId = UserInfo.getUserId();
//         insert doc3;       
    
    
//         System.debug('start test'); 
//         test.startTest();
//             //Crear Lead para el Test
//             Lead leadTest = new Lead();
//             leadTest.FirstName = 'TestPrueba';
//             leadTest.LastName = 'testPrueba';
//             leadTest.Email = 'da_ls90@hotmail.es';
//             leadTest.Phone = '+50622626262';
//             leadTest.MobilePhone = '+50683838383';
//             leadTest.Sucursal__c = 'Escazú';
//             leadTest.FechaPosibleCompra__c = '1 a 3 meses';
//             leadTest.Campana__c = TestDataFactory.campanna.Id;
//             leadTest.Status = 'Calificado';
//             leadTest.LeadSource = 'Eventos';
//             leadTest.Tipo_de_Identificaci_n__c = 'Cedula';
//             leadTest.Numero_de_Identificacion_del__c = '117450873';
//             leadTest.RecordTypeId = rtId;
//         	leadTest.RFO__c = true;
// //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++=       
//             leadTest.Marca__c = 'BMW';
//             leadTest.Familia1__c = 'X5';
//             leadTest.Modelo_De_Inter_s1__c = 'BM105 - X5 - 45e Premium';
//             leadTest.Codigo_de_producto__c = pbe2.Id;
// //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++=
      
//             leadTest.Marca2__c = 'BMW';       
//             leadTest.Familia2__c = 'X1';
//             leadTest.Modelo_De_Inter_s2__c = 'BM52 - X1 - 1.8i Business';
//             leadTest.Codigo_de_producto2__c = pbe2.Id;
// //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++=        
//             leadTest.Marca3__c = 'BMW';
//             leadTest.Familia3__c = 'X1';
//             leadTest.Modelo_De_Inter_s3__c = 'BM27 - X1 - 1.8d EXECUTIVE';
//             leadTest.Codigo_de_producto3__c = pbe2.Id;
// //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++=  
//             leadTest.Marca4__c = 'BMW';
//             leadTest.Familia4__c = 'X1';
//             leadTest.Modelo_De_Inter_s4__c = 'BM27 - X1 - 1.8d EXECUTIVE';
//             leadTest.Codigo_de_producto4__c = pbe2.Id;
//             leadTest.Ano1__c = '2020';
//             leadTest.Ano2__c = '2019';
//             leadTest.Ano3__c = '2019';
//             leadTest.Ano4__c = '2019';
            
//             System.debug('insert lead');
//             insert leadTest;
        
//         	WsConvertirTrafico.convertirLead(String.valueOf(leadTest.Id));
//         test.stopTest();
//         system.debug('stop test');
//     }
    
//     static testMethod void test0(){
//         Test.StartTest();
//         Configuracion_de_ventas__c cdv = new Configuracion_de_ventas__c();
//         cdv.Name = 'Configuración BMW';
//         cdv.Listas_de_Precios_Vigente__c = 'BMW - 2020';
//         cdv.Marca__c = 'BMW';
//         insert cdv;

//         RecordType rtype = [Select Id,DeveloperName,SObjectType From RecordType where developerName = 'Campana_Red_Motors'];
//         Campaign camp = new Campaign();
//         camp.Name = 'Campaña de Taller';
//         camp.IsActive = true;
//         camp.RecordTypeId = rtype.Id;
//         camp.Type = 'Evento';
//         camp.Description = 'Campaña de Taller';
//         camp.Status = 'En progreso';
//         camp.StartDate = date.today()-30;
//         camp.EndDate = date.today();
//         insert camp;

//         Pricebook2 pb2 = new Pricebook2();
//         pb2.Name = 'BMW - 2020';
//         pb2.IsActive = true;
//         insert pb2;

//         Product2 prod = new Product2();
//         prod.Name = 'BM101 - X2 - Sdrive 18i Premium';
//         prod.Codigo_de_Producto__c = 'BM101';
//         prod.ProductCode = 'BM101';
//         prod.IsActive = true;
//         prod.Marca__c = 'BMW';
//         prod.Description = 'BM101 - X2 - Sdrive 18i Premium';
//         prod.NombredePlantilla__c = 'BMWX2AgradecimientoVisita';
//         prod.Familia__c = 'X2';
//         insert prod;
//         System.debug('qqqqq' + prod);

//         // PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = prod.Id, UnitPrice = 1000, IsActive = true);
//         // insert standardPBE;

//         PricebookEntry pbe = new PricebookEntry();
//         pbe.Product2Id = prod.Id;
//         pbe.Pricebook2Id = pb2.Id;
//         pbe.UnitPrice = 98000;
//         pbe.UseStandardPrice = false;
//         pbe.IsActive = true;
//         System.debug('ppppp' + pbe);
//         insert pbe;

//         Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Lead;
//         Map<String,Schema.RecordTypeInfo> LeadRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
//         Id rtId = LeadRecordTypeInfo.get('BMW').getRecordTypeId();
//         System.debug('hhhhh' + rtId);

//         Lead ld = new Lead();
//         ld.RecordTypeId = rtId;
//         ld.FirstName  = 'Juan';
//         ld.LastName = 'Test1';
//         ld.MobilePhone = '+50688776655';
//         ld.Sucursal__c = 'Pinares';
//         ld.FechaPosibleCompra__c = '1 a 3 meses';
//         ld.Status = 'Nuevo';
//         ld.LeadSource = 'Facebook';
//         ld.Marca__c = 'BMW';
//         ld.Familia1__c = 'X2';
//         ld.EsWeb2Lead_del__c = false;
//         ld.Modelo_De_Inter_s1__c = 'BM101 - X2 - Sdrive 18i Premium';
//         ld.Ano1__c = '2020';
//         ld.Campana__c = TestDataFactory.campanna.Id;
//         insert ld;

//         Test.StopTest();
//     }

//     static testMethod void test1(){
//         Test.StartTest();
//         Configuracion_de_ventas__c cdv = new Configuracion_de_ventas__c();
//         cdv.Name = 'Configuración BMW';
//         cdv.Listas_de_Precios_Vigente__c = 'BMW - 2020';
//         cdv.Marca__c = 'BMW';
//         insert cdv;

//         Campaign camp = new Campaign();
//         camp.Name = 'Expomovil 2017';
//         camp.IsActive = true;
//         camp.Type = 'Evento';
//         camp.Description = 'Expomovil 2017';
//         camp.Status = 'En progreso';
//         camp.StartDate = date.today()-30;
//         camp.EndDate = date.today();
//         insert camp;

//         Pricebook2 pb2 = new Pricebook2();
//         pb2.Name = 'BMW - 2020';
//         pb2.IsActive = true;
//         insert pb2;

//         Product2 prod = new Product2();
//         prod.Name = 'BM101 - X2 - Sdrive 18i Premium';
//         prod.Codigo_de_Producto__c = 'BM101';
//         prod.ProductCode = 'BM101';
//         prod.IsActive = true;
//         prod.Marca__c = 'BMW';
//         prod.Description = 'BM101 - X2 - Sdrive 18i Premium';
//         prod.NombredePlantilla__c = 'BMWX2AgradecimientoVisita';
//         prod.Familia__c = 'X2';
//         insert prod;
//         System.debug('qqqqq' + prod);

//         // PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = prod.Id, UnitPrice = 1000, IsActive = true);
//         // insert standardPBE;

//         PricebookEntry pbe = new PricebookEntry();
//         pbe.Product2Id = prod.Id;
//         pbe.Pricebook2Id = pb2.Id;
//         pbe.UnitPrice = 98000;
//         pbe.UseStandardPrice = false;
//         pbe.IsActive = true;
//         System.debug('ppppp' + pbe);
//         insert pbe;

//         Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Lead;
//         Map<String,Schema.RecordTypeInfo> LeadRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
//         Id rtId = LeadRecordTypeInfo.get('BMW').getRecordTypeId();
//         System.debug('hhhhh' + rtId);

//         Lead ld = new Lead();
//         ld.RecordTypeId = rtId;
//         ld.FirstName  = 'Juan';
//         ld.LastName = 'Test1';
//         ld.MobilePhone = '+50688776655';
//         ld.Sucursal__c = 'Pinares';
//         ld.FechaPosibleCompra__c = '1 a 3 meses';
//         ld.Status = 'Nuevo';
//         ld.LeadSource = 'Facebook';
//         ld.Marca__c = 'BMW';
//         ld.Familia1__c = 'X2';
//         ld.EsWeb2Lead_del__c = false;
//         ld.Modelo_De_Inter_s1__c = 'BM101 - X2 - Sdrive 18i Premium';
//         ld.Ano1__c = '2020';
//         ld.Campana__c = TestDataFactory.campanna.Id;
//         insert ld;

//         Test.StopTest();
//     }

//     static testMethod void test2(){

//         Test.StartTest();
//         Configuracion_de_ventas__c cdv = new Configuracion_de_ventas__c();
//         cdv.Name = 'Configuración BMW';
//         cdv.Listas_de_Precios_Vigente__c = 'BMW - 2020';
//         cdv.Marca__c = 'BMW';
//         insert cdv;

//         RecordType rtype = [Select Id,DeveloperName,SObjectType From RecordType where developerName = 'Campana_Red_Motors'];
//         Campaign camp = new Campaign();
//         camp.Name = 'Campaña de W2L';
//         camp.IsActive = true;
//         camp.Type = 'Evento';
//         camp.Description = 'Campaña de W2L';
//         camp.Status = 'En progreso';
//         camp.StartDate = date.today()-30;
//         camp.EndDate = date.today();
//         camp.recordTypeId = rtype.id;
//         insert camp;

//         Pricebook2 pb2 = new Pricebook2();
//         pb2.Name = 'BMW - 2020';
//         pb2.IsActive = true;
//         insert pb2;

//         Product2 prod2 = new Product2();
//         prod2.Name = 'BM101 - X2 - Sdrive 18i Premium';
//         prod2.Codigo_de_Producto__c = 'BM101';
//         prod2.ProductCode = 'BM101';
//         prod2.IsActive = true;
//         prod2.Marca__c = 'BMW';
//         prod2.Description = 'BM101 - X2 - Sdrive 18i Premium';
//         prod2.NombredePlantilla__c = 'BMWX2AgradecimientoVisita';
//         prod2.Familia__c = 'X2';
//         insert prod2;

//         // PricebookEntry standardPBE2 = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = prod2.Id, UnitPrice = 1000, IsActive = true);
//         // insert standardPBE2;

//         PricebookEntry pbe2 = new PricebookEntry();
//         pbe2.Product2Id = prod2.Id;
//         pbe2.Pricebook2Id = pb2.Id;
//         pbe2.UnitPrice = 85000;
//         pbe2.UseStandardPrice = false;
//         pbe2.IsActive = true;
//         insert pbe2;


//         Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Lead;
//         Map<String,Schema.RecordTypeInfo> LeadRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
//         Id rtId = LeadRecordTypeInfo.get('BMW').getRecordTypeId();
//         System.debug('hhhhh' + rtId);

//         Lead ld = new Lead();
//         ld.RecordTypeId = rtId;
//         ld.FirstName  = 'Juan';
//         ld.LastName = 'Test1';
//         ld.MobilePhone = '+50688776655';
//         ld.Sucursal__c = 'Pinares';
//         ld.FechaPosibleCompra__c = '1 a 3 meses';
//         ld.Status = 'Nuevo';
//         ld.LeadSource = 'Facebook';
//         ld.Marca__c = 'BMW';
//         ld.Familia1__c = 'X2';
//         ld.Modelo_De_Inter_s1__c = 'BM101 - X2 - Sdrive 18i Premium';
//         ld.Ano1__c = '2020';
//         ld.Marca2__c = 'BMW';
//         ld.Familia2__c = 'X2';
//         ld.Modelo_De_Inter_s2__c = 'BM101 - X2 - Sdrive 18i Premium';
//         ld.Ano2__c = '2020';
//         ld.Marca3__c = 'BMW';
//         ld.Familia3__c = 'X2';
//         ld.Modelo_De_Inter_s3__c = 'BM101 - X2 - Sdrive 18i Premium';
//         ld.Ano3__c = '2020';
//         ld.Marca4__c = 'BMW';
//         ld.Familia4__c = 'X2';
//         ld.Modelo_De_Inter_s4__c = 'BM101 - X2 - Sdrive 18i Premium';
//         ld.Ano4__c = '2020';
//         ld.EsWeb2Lead_del__c = true;
//         ld.Campana__c = camp.Id;
//         ld.Modelo_De_Inter_s1_New__c = 'BM101 - X2 - Sdrive 18i Premium';
//         System.debug('TestDataFactory.campanna'+TestDataFactory.campanna);
//         insert ld;

//         List<Lead> llist = new List<Lead>{ld};
//         TraficoService.EnviarCotizacion(llist);
//         TraficoService.enviarCotizacionCustom(llist);
        
//         Test.StopTest();
//     }

//     static testMethod void test3(){

//         Test.StartTest();

//         Configuracion_de_ventas__c cdv = new Configuracion_de_ventas__c();
//         cdv.Name = 'Configuración BMW';
//         cdv.Listas_de_Precios_Vigente__c = 'BMW - 2020';
//         cdv.Marca__c = 'BMW';
//         insert cdv;

//         Campaign camp = new Campaign();
//         camp.Name = 'Expomovil 2017';
//         camp.IsActive = true;
//         camp.Type = 'Evento';
//         camp.Description = 'Expomovil 2017';
//         camp.Status = 'En progreso';
//         camp.StartDate = date.today()-30;
//         camp.EndDate = date.today();
//         insert camp;

//         Pricebook2 pb2 = new Pricebook2();
//         pb2.Name = 'BMW - 2020';
//         pb2.IsActive = true;
//         insert pb2;

//         Product2 prod = new Product2();
//         prod.Name = 'BM101 - X2 - Sdrive 18i Premium';
//         prod.Codigo_de_Producto__c = 'BM101';
//         prod.ProductCode = 'BM101';
//         prod.IsActive = true;
//         prod.Marca__c = 'BMW';
//         prod.Description = 'BM101 - X2 - Sdrive 18i Premium';
//         prod.NombredePlantilla__c = 'BMWX2AgradecimientoVisita';
//         prod.Familia__c = 'X2';
//         insert prod;
//         System.debug('qqqqq' + prod);

//         // PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = prod.Id, UnitPrice = 1000, IsActive = true);
//         // insert standardPBE;

//         PricebookEntry pbe = new PricebookEntry();
//         pbe.Product2Id = prod.Id;
//         pbe.Pricebook2Id = pb2.Id;
//         pbe.UnitPrice = 98000;
//         pbe.UseStandardPrice = false;
//         pbe.IsActive = true;
//         System.debug('ppppp' + pbe);
//         insert pbe;

//         Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Lead;
//         Map<String,Schema.RecordTypeInfo> LeadRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
//         Id rtId = LeadRecordTypeInfo.get('BMW').getRecordTypeId();
//         System.debug('hhhhh' + rtId);

//         Lead ld = new Lead();
//         ld.RecordTypeId = rtId;
//         ld.FirstName  = 'Juan';
//         ld.LastName = 'Test1';
//         ld.MobilePhone = '+50688776655';
//         ld.Sucursal__c = 'Pinares';
//         ld.FechaPosibleCompra__c = '1 a 3 meses';
//         ld.Status = 'Nuevo';
//         ld.LeadSource = 'Facebook';
//         ld.Marca__c = 'BMW';
//         ld.Familia1__c = 'X2';
//         ld.EsWeb2Lead_del__c = false;
//         ld.Modelo_De_Inter_s1__c = 'BM101 - X2 - Sdrive 18i Premium';
//         ld.Ano1__c = '2020';
//         ld.Campana__c = camp.Id;
//         ld.Codigo_de_producto__c = pbe.Id;

//         try {
//           if(Test.isRunningTest()) {
//               insert ld;
//           }
//         }
//         catch (DMLException e) {
//           System.debug(e.getMessage());
//         }

//         Test.StopTest();
//     }

//     static testMethod void test4(){

//         Test.StartTest();
//         Configuracion_de_ventas__c cdv = new Configuracion_de_ventas__c();
//         cdv.Name = 'Configuración BMW';
//         cdv.Listas_de_Precios_Vigente__c = 'BMW - 2020';
//         cdv.Marca__c = 'BMW';
//         insert cdv;

//         Campaign camp = new Campaign();
//         camp.Name = 'Expomovil 2017';
//         camp.IsActive = true;
//         camp.Type = 'Evento';
//         camp.Description = 'Expomovil 2017';
//         camp.Status = 'En progreso';
//         camp.StartDate = date.today()-30;
//         camp.EndDate = date.today();
//         insert camp;

//         Pricebook2 pb2 = new Pricebook2();
//         pb2.Name = 'BMW - 2020';
//         pb2.IsActive = true;
//         insert pb2;

//         Product2 prod = new Product2();
//         prod.Name = 'BM101 - X2 - Sdrive 18i Premium';
//         prod.Codigo_de_Producto__c = 'BM101';
//         prod.ProductCode = 'BM101';
//         prod.IsActive = true;
//         prod.Marca__c = 'BMW';
//         prod.Description = 'BM101 - X2 - Sdrive 18i Premium';
//         prod.NombredePlantilla__c = 'BMWX2AgradecimientoVisita';
//         prod.Familia__c = 'X2';
//         insert prod;
//         System.debug('qqqqq' + prod);

//         // PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = prod.Id, UnitPrice = 98000, IsActive = true);
//         // insert standardPBE;

//         PricebookEntry pbe = new PricebookEntry();
//         pbe.Product2Id = prod.Id;
//         pbe.Pricebook2Id = pb2.Id;
//         pbe.UnitPrice = 98000;
//         pbe.UseStandardPrice = false;
//         pbe.IsActive = true;
//         System.debug('ppppp' + pbe);
//         insert pbe;

//         Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Lead;
//         Map<String,Schema.RecordTypeInfo> LeadRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
//         Id rtId = LeadRecordTypeInfo.get('BMW').getRecordTypeId();
//         System.debug('hhhhh' + rtId);

//         Lead ld = new Lead();
//         ld.RecordTypeId = rtId;
//         ld.FirstName  = 'Juan';
//         ld.LastName = 'Test';
//         ld.MobilePhone = '+50688776655';
//         ld.Sucursal__c = 'Pinares';
//         ld.FechaPosibleCompra__c = '1 a 3 meses';
//         ld.Status = 'Nuevo';
//         ld.LeadSource = 'Facebook';
//         ld.Marca__c = 'BMW';
//         ld.Familia1__c = 'X2';
//         ld.EsWeb2Lead_del__c = false;
//         ld.Modelo_De_Inter_s1__c = 'BM101 - X2 - Sdrive 18i Premium';
//         ld.Ano1__c = '2020';
//         ld.Email = 'test1@xyz.com';
//         ld.Campana__c = TestDataFactory.campanna.Id;
//         ld.Codigo_de_producto__c = pbe.Id;
//         ld.Tipo_de_Identificaci_n__c = 'Cedula';
//         ld.Numero_de_Identificacion_del__c = '112233445';
//         insert ld;

//         Database.LeadConvert lc = new database.LeadConvert();
//         lc.setLeadId(ld.Id);
//         lc.setDoNotCreateOpportunity(false);
//         lc.setConvertedStatus('Qualified');
//         Database.LeadConvertResult lcr = Database.convertLead(lc);
//         System.assert(lcr.isSuccess());

//         Test.StopTest();
//     }

//     static testMethod void test5(){

//         Test.StartTest();
//         Configuracion_de_ventas__c cdv = new Configuracion_de_ventas__c();
//         cdv.Name = 'Configuración BMW';
//         cdv.Listas_de_Precios_Vigente__c = 'BMW - 2020';
//         cdv.Marca__c = 'BMW';
//         insert cdv;

//         Campaign camp = new Campaign();
//         camp.Name = 'Campaña de W2L';
//         camp.IsActive = true;
//         camp.Type = 'Evento';
//         camp.Description = 'Campaña de W2L';
//         camp.Status = 'En progreso';
//         camp.StartDate = date.today()-30;
//         camp.EndDate = date.today();
//         insert camp;

//         Pricebook2 pb2 = new Pricebook2();
//         pb2.Name = 'BMW - 2020';
//         pb2.IsActive = true;
//         insert pb2;

//         Product2 prod = new Product2();
//         prod.Name = 'BM101 - X2 - Sdrive 18i Premium';
//         prod.Codigo_de_Producto__c = 'BM101';
//         prod.ProductCode = 'BM101';
//         prod.IsActive = true;
//         prod.Marca__c = 'BMW';
//         prod.Description = 'BM101 - X2 - Sdrive 18i Premium';
//         prod.NombredePlantilla__c = 'BMWX2AgradecimientoVisita';
//         prod.Familia__c = 'X2';
//         insert prod;
//         System.debug('qqqqq' + prod);

//         // PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = prod.Id, UnitPrice = 1000, IsActive = true);
//         // insert standardPBE;

//         PricebookEntry pbe = new PricebookEntry();
//         pbe.Product2Id = prod.Id;
//         pbe.Pricebook2Id = pb2.Id;
//         pbe.UnitPrice = 90000;
//         pbe.UseStandardPrice = false;
//         pbe.IsActive = true;
//         insert pbe;

//         Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Lead;
//         Map<String,Schema.RecordTypeInfo> LeadRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
//         Id rtId = LeadRecordTypeInfo.get('BMW').getRecordTypeId();
//         System.debug('hhhhh' + rtId);

//         Lead ld = new Lead();
//         ld.RecordTypeId = rtId;
//         ld.FirstName  = 'Juan';
//         ld.LastName = 'Test1';
//         ld.Tipo_de_Identificaci_n__c = 'Cedula';
//         ld.Numero_de_Identificacion_del__c = '112233445';
//         ld.MobilePhone = '+50688776655';
//         ld.Sucursal__c = 'Pinares';
//         ld.FechaPosibleCompra__c = '1 a 3 meses';
//         ld.Status = 'Nuevo';
//         ld.LeadSource = 'Facebook';
//         ld.EsWeb2Lead_del__c = false;
//         ld.Marca__c = 'BMW';
//         ld.Familia1__c = 'X2';
//         ld.Modelo_De_Inter_s1__c = 'BM101 - X2 - Sdrive 18i Premium';
//         ld.Marca2__c = 'BMW';
//         ld.Familia2__c = 'X2';
//         ld.Modelo_De_Inter_s2__c = 'BM101 - X2 - Sdrive 18i Premium';
//         ld.Campana__c = TestDataFactory.campanna.Id;
//         ld.Ano1__c = '2020';
//         ld.Ano2__c = '2020';
//         insert ld;

//         Database.LeadConvert lc = new database.LeadConvert();
//         lc.setLeadId(ld.Id);
//         lc.setDoNotCreateOpportunity(false);
//         lc.setConvertedStatus('Qualified');
//         Database.LeadConvertResult lcr = Database.convertLead(lc);
//         System.assert(lcr.isSuccess());


//         Test.StopTest();
//     }

//     static testMethod void test6(){

//         Test.StartTest();
//         Configuracion_de_ventas__c cdv = new Configuracion_de_ventas__c();
//         cdv.Name = 'Configuración BMW';
//         cdv.Listas_de_Precios_Vigente__c = 'BMW - 2020';
//         cdv.Marca__c = 'BMW';
//         insert cdv;

//         Campaign camp = new Campaign();
//         camp.Name = 'Campaña de W2L';
//         camp.IsActive = true;
//         camp.Type = 'Evento';
//         camp.Description = 'Campaña de W2L';
//         camp.Status = 'En progreso';
//         camp.StartDate = date.today()-30;
//         camp.EndDate = date.today();
//         insert camp;

//         Pricebook2 pb2 = new Pricebook2();
//         pb2.Name = 'BMW - 2020';
//         pb2.IsActive = true;
//         insert pb2;

//         Product2 prod = new Product2();
//         prod.Name = 'BM101 - X2 - Sdrive 18i Premium';
//         prod.Codigo_de_Producto__c = 'BM101';
//         prod.ProductCode = 'BM101';
//         prod.IsActive = true;
//         prod.Marca__c = 'BMW';
//         prod.Description = 'BM101 - X2 - Sdrive 18i Premium';
//         prod.NombredePlantilla__c = 'BMWX2AgradecimientoVisita';
//         prod.Familia__c = 'X2';
//         insert prod;
//         System.debug('qqqqq' + prod);

//         // PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = prod.Id, UnitPrice = 1000, IsActive = true);
//         // insert standardPBE;

//         PricebookEntry pbe = new PricebookEntry();
//         pbe.Product2Id = prod.Id;
//         pbe.Pricebook2Id = pb2.Id;
//         pbe.UnitPrice = 90000;
//         pbe.UseStandardPrice = false;
//         pbe.IsActive = true;
//         insert pbe;

//         Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Lead;
//         Map<String,Schema.RecordTypeInfo> LeadRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
//         Id rtId = LeadRecordTypeInfo.get('BMW').getRecordTypeId();
//         System.debug('hhhhh' + rtId);

//         Lead ld = new Lead();
//         ld.RecordTypeId = rtId;
//         ld.FirstName  = 'Juan';
//         ld.LastName = 'Test1';
//         ld.MobilePhone = '+50688776655';
//         ld.Sucursal__c = 'Pinares';
//         ld.FechaPosibleCompra__c = '1 a 3 meses';
//         ld.Status = 'Nuevo';
//         ld.LeadSource = 'Facebook';
//         ld.EsWeb2Lead_del__c = false;
//         ld.Tipo_de_Identificaci_n__c = 'Cedula';
//         ld.Numero_de_Identificacion_del__c = '112233445';

//         ld.Marca__c = 'BMW';
//         ld.Familia1__c = 'X2';
//         ld.Modelo_De_Inter_s1__c = 'BM101 - X2 - Sdrive 18i Premium';
//         ld.Ano1__c = '2020';

//         ld.Marca2__c = 'BMW';
//         ld.Familia2__c = 'X2';
//         ld.Modelo_De_Inter_s2__c = 'BM101 - X2 - Sdrive 18i Premium';
//         ld.Ano2__c = '2020';

//         ld.Marca3__c = 'BMW';
//         ld.Familia3__c = 'X2';
//         ld.Modelo_De_Inter_s3__c = 'BM101 - X2 - Sdrive 18i Premium';
//         ld.Ano3__c = '2020';

//         ld.Campana__c = TestDataFactory.campanna.Id;
//         ld.Codigo_de_producto__c = pbe.Id;
//         ld.Codigo_de_producto2__c = pbe.Id;
//         ld.Codigo_de_producto3__c = pbe.Id;

//         insert ld;

//         Database.LeadConvert lc = new database.LeadConvert();
//         lc.setLeadId(ld.Id);
//         lc.setDoNotCreateOpportunity(false);
//         lc.setConvertedStatus('Qualified');
//         Database.LeadConvertResult lcr = Database.convertLead(lc);
//         System.assert(lcr.isSuccess());


//         Test.StopTest();
//     }
  
   

//     static testMethod void test7(){
//         //TestDataFactory.datosGenerales();
//         Test.StartTest();
//             Pricebook2 pb = new Pricebook2();
//             pb.Name = 'BMW - 2020';
//             pb.IsActive = true;
//             insert pb;

//             Product2 prod = new Product2();
//             prod.Name = 'BM101 - X2 - Sdrive 18i Premium';
//             prod.Codigo_de_Producto__c = 'BM101';
//             prod.ProductCode = 'BM101';
//             prod.IsActive = true;
//             prod.Marca__c = 'BMW';
//             prod.Description = 'BM101 - X2 - Sdrive 18i Premium';
//             prod.NombredePlantilla__c = 'BMWX2AgradecimientoVisita';
//             prod.Familia__c = 'X2';
//             insert prod;

//             // PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = prod.Id, UnitPrice = 1000, IsActive = true);
//             // insert standardPBE;

//             PricebookEntry pbe = new PricebookEntry();
//             pbe.Product2Id = prod.Id;
//             pbe.Pricebook2Id = pb.Id;
//             pbe.UnitPrice = 90000;
//             pbe.UseStandardPrice = false;
//             pbe.IsActive = true;
//             insert pbe;

//             Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Lead;
//             Map<String,Schema.RecordTypeInfo> LeadRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
//             Id rtId = LeadRecordTypeInfo.get('BMW').getRecordTypeId();

//             Lead ld = new Lead();
//             ld.RecordTypeId = rtId;
//             ld.FirstName  = 'Juan';
//             ld.LastName = 'Test1';
//             ld.Tipo_de_Identificaci_n__c = 'Cedula';
//             ld.Numero_de_Identificacion_del__c = '112233445';
//             ld.MobilePhone = '+50688776655';
//             ld.Sucursal__c = 'Pinares';
//             ld.FechaPosibleCompra__c = '1 a 3 meses';
//             ld.Status = 'Nuevo';
//             ld.LeadSource = 'Facebook';
//             ld.EsWeb2Lead_del__c = false;
//             ld.Campana__c = TestDataFactory.campanna.Id;

//             ld.Marca__c = 'BMW';
//             ld.Familia1__c = 'X2';
//             ld.Modelo_De_Inter_s1__c = 'BM101 - X2 - Sdrive 18i Premium';
//             ld.Ano1__c = '2020';

//             ld.Marca2__c = 'BMW';
//             ld.Familia2__c = 'X2';
//             ld.Modelo_De_Inter_s2__c = 'BM101 - X2 - Sdrive 18i Premium';
//             ld.Ano2__c = '2020';

//             insert ld;

//             Database.LeadConvert lc = new database.LeadConvert();
//             lc.setLeadId(ld.Id);
//             lc.setDoNotCreateOpportunity(false);
//             lc.setConvertedStatus('Qualified');
//             Database.LeadConvertResult lcr = Database.convertLead(lc);
//             System.assert(lcr.isSuccess());
//         Test.StopTest();
//     }


    @IsTest
    static void testConversionTraficoUsados(){
         TraficoService.dummy();
         LeadTriggerHandler.isAlreadyProcessed = true;
        TraficoTriggerHandler.dummy();
        RM_Lead_Trigger_Helper.name();
        // Test.startTest();
        // System.runAs(contextuser){
            
        // }
        // Test.stopTest();
        
    }
}