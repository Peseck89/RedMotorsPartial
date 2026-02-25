@isTest(SeeAllData=false)
public class CreateWOLI_FromSubtipoTest {
    
    @isTest(seeAllData=false)
    public static void testCreateWOLI_FromSubtipo(){
        condicionPago__c ConPag = new condicionPago__c(condicionPago__c='0');
        Insert ConPag;
        ActividadComercial__c ActCom = new ActividadComercial__c(Name = 'VENTA DE REPUESTOS NUEVOS PARA AUTOMOVIL');
        Insert ActCom;
        Impuesto__c imp = new Impuesto__c(Name='IVA-Tarifa General 13%');
        Insert imp;
        Account Acc = new Account(Name='Test Acc');
        Acc.Name='Test account';
        Acc.Cedula__c='9876543210';
        Acc.Tipo_de_Documento__c='02';
        Acc.codigoSoftland__c = '1234';
        
        insert Acc;
        Case Caso = new Case(Subject='Test');
        Insert Caso;
        Pricebook2 PriceBook = new Pricebook2(Name='TestPB');
        Insert PriceBook;
        WorkOrder WO = new WorkOrder(CaseId = Caso.Id, Pricebook2Id=PriceBook.Id, AccountId=Acc.Id);
        Insert WO;
        tiposDeTrabajoCaso__c TipoTrabajo = new tiposDeTrabajoCaso__c(Caso__c=Caso.Id);
        Insert TipoTrabajo;
        Product2 Prod = new Product2(Name='Test Prod', Codigo_de_Producto__c='TestProd', tipoProducto__c='Mano de Obra');
        Insert Prod;
        PricebookEntry PBE = new PricebookEntry(Pricebook2Id=PriceBook.Id, Product2Id=Prod.Id, UnitPrice=5, IsActive=true); 
        Insert PBE;
        Subtipo_de_trabajo_del_caso__c subtipo = new Subtipo_de_trabajo_del_caso__c(Name='Test',
                                                                                    Caso__c=Caso.Id,
                                                                                    Orden_de_trabajo__c=WO.Id,
                                                                                    Tipo_de_trabajo_del_caso__c=TipoTrabajo.Id,
                                                                                    Cantidad_de_horas__c = 4);
        test.startTest();
        Insert subtipo;
        test.stopTest();
    }
    
    public static testMethod void testCreateWOLI_FromSubtipoForNullValue(){
        Case Caso = new Case(Subject='Test');
        Insert Caso;
        WorkOrder WO = new WorkOrder(CaseId = Caso.Id, CurrencyIsoCode = '');
        Insert WO;
        tiposDeTrabajoCaso__c TipoTrabajo = new tiposDeTrabajoCaso__c(Caso__c=Caso.Id);
        Insert TipoTrabajo;
        test.startTest();
        Subtipo_de_trabajo_del_caso__c subtipo = new Subtipo_de_trabajo_del_caso__c(Name='Test',Caso__c=null,
                                                                                    Tipo_de_trabajo_del_caso__c=TipoTrabajo.Id);
        insert subtipo;
        test.stopTest();
    }
    
    public static testMethod void testCreateWOLI_FromSubtipoForCatch(){
        test.startTest();
        Boolean exceptionThrown = false;
        try{ 
            Subtipo_de_trabajo_del_caso__c subtipo = new Subtipo_de_trabajo_del_caso__c();
            insert subtipo;
        }
        catch(Exception e){
            exceptionThrown = true;
            Boolean expectedExceptionThrown =  (e.getMessage().contains('revise el caso asociado al tipo ya que no cuenta con orden de trabajo.')) ? true : false; 
            System.AssertEquals(false, expectedExceptionThrown, e.getMessage());
        }
        test.stopTest();
    }
}