/**
    @Autor: David Leon Sanchez IS
    @Fecha creacion:  06/12/2019
    @Proyecto: Altica Gestiones 
**/

@isTest
public class reciboPagoPDFController_Test  {
	
	static{
		TestDataFactory.datosGenerales();
		TestDataFactory.crearCuentasAltica(1);
	}

	@isTest
	private static void test1(){
		PageReference pdf;
		reciboPagoPDFController pagePDF = new reciboPagoPDFController();

		Gestion__c g = new Gestion__c();
		Gestion__c g2 = new Gestion__c();

		g.Name = 'Prueba';
		g.Nombre_Completo__c = TestDataFactory.MapCuentasAltica.get(0).Id;
		g.Numero_Cedula__c = TestDataFactory.MapCuentasAltica.get(0).Cedula__c;
		g.Numero_Operacion__c = 'AF000000';
		g.Placa__c = 'AAA000';
		g.Estado__c = 'Cerrada';
		g.Canal__c = 'Bot';
		g.Fecha_Cancelacion__c = System.today();
		g.Fecha_Pago__c = System.today();
		g.Cuota_Mensual__c = 500;
		g.Email_Cliente__c = 'prueba@prueba.com';
		g.Seguro__c = 20;
		g.Amortizacion__c = 20;
		g.Intereses__c = 20;
		g.Cargos__c = 20;
		g.IVA__c = 20;
		g.Saldo_Inicial__c = 1000;
		g.Saldo_Final__c = 500;
		g.Tipo_Producto__c = 'Prueba';
		g.RecordTypeId = Schema.SObjectType.Gestion__c.getRecordTypeInfosByName().get('Recibo Pago').getRecordTypeId();

		Test.startTest();
			insert g;
			pdf = Page.reciboPagoPDF;
			Test.setCurrentPage(pdf);
				pdf.getParameters().put('Id', g.Id);
				pdf.setRedirect(true);
				g2 = pagePDF.gestion;
		Test.stopTest();
		
	}
}