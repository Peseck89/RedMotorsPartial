/*
*       @AUTOR:         JOHN CORTES(IS)
*       @FECHA:         17 Julio 2017
*       @DESCRIPCION:   Test para Controlador para componente ProductoServicioOportunidad.
*
*/
@isTest
public with sharing class TestControllerMantenimientoAsignaVend {


	 public static testMethod void queryWithoutParamsSucursal(){

	 	ControllerMantenimientoAsignacionVend controller = new  ControllerMantenimientoAsignacionVend();

		Sucursal__c sucursal = new Sucursal__c(Name='Sucursal1');
		insert sucursal;

		Vendedores__c vendedor = new Vendedores__c(	Sucursal__c = sucursal.Id);
		insert vendedor;

		Vendedor_Asignaciones__c vendedorAsig = new Vendedor_Asignaciones__c(Activo__c=true,Fecha_Asignacion__c=Date.today(),Vendedor__c = vendedor.Id);
		insert vendedorAsig;

		
		
		controller.fecha = Date.today();
		controller.sucursalInput ='';
		controller.vendedorInput ='';
		controller.marcaInput ='';
		controller.fechaInput ='';

	 

         test.startTest();
            
            PageReference pageRef = Page.MantenimientoAsignacionVendedores;
        	Test.setCurrentPage(pageRef);
            //ApexPages.CurrentPage().getParameters().put('sucursal', sucursal.id);
            ApexPages.CurrentPage().getParameters().put('vendedor', vendedor.id);
            ApexPages.CurrentPage().getParameters().put('marca', 'BMW');
            ApexPages.CurrentPage().getParameters().put('fecha', DateTime.now().format('yyyy-MM-dd'));

            controller.getQuery();

        test.stopTest();
    }

     public static testMethod void queryWithoutParamsSucursalVendedor(){

	 	ControllerMantenimientoAsignacionVend controller = new  ControllerMantenimientoAsignacionVend();

		Sucursal__c sucursal = new Sucursal__c(Name='Sucursal1');
		insert sucursal;

		Vendedores__c vendedor = new Vendedores__c(	Sucursal__c = sucursal.Id);
		insert vendedor;

		Vendedor_Asignaciones__c vendedorAsig = new Vendedor_Asignaciones__c(Activo__c=true,Fecha_Asignacion__c=Date.today(),Vendedor__c = vendedor.Id);
		insert vendedorAsig;

		
		
		controller.fecha = Date.today();
		controller.sucursalInput ='';
		controller.vendedorInput ='';
		controller.marcaInput ='';
		controller.fechaInput ='';

	 

         test.startTest();
            
            PageReference pageRef = Page.MantenimientoAsignacionVendedores;
        	Test.setCurrentPage(pageRef);
            //ApexPages.CurrentPage().getParameters().put('sucursal', sucursal.id);
            //ApexPages.CurrentPage().getParameters().put('vendedor', vendedor.id);
            ApexPages.CurrentPage().getParameters().put('marca', 'BMW');
            ApexPages.CurrentPage().getParameters().put('fecha', DateTime.now().format('yyyy-MM-dd'));

            controller.getQuery();

        test.stopTest();
    }

     public static testMethod void queryWithoutParamsSucursalVendedorFecha(){

	 	ControllerMantenimientoAsignacionVend controller = new  ControllerMantenimientoAsignacionVend();

		Sucursal__c sucursal = new Sucursal__c(Name='Sucursal1');
		insert sucursal;

		Vendedores__c vendedor = new Vendedores__c(	Sucursal__c = sucursal.Id);
		insert vendedor;

		Vendedor_Asignaciones__c vendedorAsig = new Vendedor_Asignaciones__c(Activo__c=true,Fecha_Asignacion__c=Date.today(),Vendedor__c = vendedor.Id);
		insert vendedorAsig;

		
		
		controller.fecha = Date.today();
		controller.sucursalInput ='';
		controller.vendedorInput ='';
		controller.marcaInput ='';
		controller.fechaInput ='';

	 

         test.startTest();
            
            PageReference pageRef = Page.MantenimientoAsignacionVendedores;
        	Test.setCurrentPage(pageRef);
            //ApexPages.CurrentPage().getParameters().put('sucursal', sucursal.id);
            //ApexPages.CurrentPage().getParameters().put('vendedor', vendedor.id);
            ApexPages.CurrentPage().getParameters().put('marca', 'BMW');
            //ApexPages.CurrentPage().getParameters().put('fecha', DateTime.now().format('yyyy-MM-dd'));

            controller.getQuery();

        test.stopTest();
    }


	 public static testMethod void guardarNuevaWithParams(){

	 	ControllerMantenimientoAsignacionVend controller = new  ControllerMantenimientoAsignacionVend();

		Sucursal__c sucursal = new Sucursal__c(Name='Sucursal1');
		insert sucursal;

		Vendedores__c vendedor = new Vendedores__c(	Sucursal__c = sucursal.Id);
		insert vendedor;

		Vendedor_Asignaciones__c vendedorAsig = new Vendedor_Asignaciones__c(Activo__c=true,Fecha_Asignacion__c=Date.today(),Vendedor__c = vendedor.Id);
		insert vendedorAsig;

		
		
		controller.fecha = Date.today();
		controller.sucursalInput ='';
		controller.vendedorInput ='';
		controller.marcaInput ='';
		controller.fechaInput ='';

	 

         test.startTest();
            
            PageReference pageRef = Page.MantenimientoAsignacionVendedores;
        	Test.setCurrentPage(pageRef);
            ApexPages.CurrentPage().getParameters().put('sucursal', sucursal.id);
            ApexPages.CurrentPage().getParameters().put('vendedor', vendedor.id);
            ApexPages.CurrentPage().getParameters().put('marca', 'BMW');
            ApexPages.CurrentPage().getParameters().put('fecha', DateTime.now().format('yyyy-MM-dd'));

            controller.buscar();
            controller.getSucursalList();
            controller.getVendedorList();
            controller.getMarcasList();
            controller.getListMantenimientoOportunidad();
            controller.getListMantenimientoOportunidadEdit();
            controller.getQuery();
            controller.agregarMantenimiento();
            controller.saveHistorico();
            controller.restarurarPagina();
            controller.cancelHistorico();
            controller.editarMantenimiento();
            controller.cancelarEdicion();
            controller.guardarCambios();
            controller.eliminarMantenimiento();
            



            
        test.stopTest();
    }


     public static testMethod void guardarNuevaWitouhtParams(){

	 	ControllerMantenimientoAsignacionVend controller = new  ControllerMantenimientoAsignacionVend();

		Sucursal__c sucursal = new Sucursal__c(Name='Sucursal1');
		insert sucursal;

		Vendedores__c vendedor = new Vendedores__c(	Sucursal__c = sucursal.Id);
		insert vendedor;

		Vendedor_Asignaciones__c vendedorAsig = new Vendedor_Asignaciones__c(Activo__c=true,Fecha_Asignacion__c=Date.today(),Vendedor__c = vendedor.Id);
		insert vendedorAsig;

		
		
		controller.fecha = Date.today();
		controller.sucursalInput ='';
		controller.vendedorInput ='';
		controller.marcaInput ='';
		controller.fechaInput ='';

	 

         test.startTest();
            
            PageReference pageRef = Page.MantenimientoAsignacionVendedores;
        	Test.setCurrentPage(pageRef);

            controller.buscar();
            controller.getSucursalList();
            controller.getVendedorList();
            controller.getMarcasList();
            controller.getListMantenimientoOportunidad();
            controller.getListMantenimientoOportunidadEdit();
            controller.getQuery();
            controller.agregarMantenimiento();
            controller.saveHistorico();
            controller.restarurarPagina();
            controller.cancelHistorico();
            controller.editarMantenimiento();
            controller.cancelarEdicion();
            controller.guardarCambios();
            controller.eliminarMantenimiento();
            



            
        test.stopTest();
    }

   
}