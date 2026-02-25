/*
*       @AUTOR:         JOHN CORTES(IS)
*       @FECHA:         14 de Julio 2017
*       @DESCRIPCION:   Controlador para casignacion de vendedores.
*
*/

public with sharing class ControllerMantenimientoAsignacionVend {

	

	public Boolean showPantalla {get; set;}	
	public List<vendedorOportunidadWrapper> ListVendedorOportunidad;
    public List<vendedorOportunidadWrapper> ListVendedorOportunidadEdit;
    public boolean finalizada{get; set;}
    public boolean edicion{get; set;}
    public boolean insercion{get; set;}
    public boolean agregar{get; set;}
    public Vendedor_Asignaciones__c newOppHistorico{get; set;}

    public List<SelectOption> sucursalList{get; set;}
    public String sucursal{get; set;}
    
    public List<SelectOption> vendedorList{get; set;}
    public String vendedor{get; set;}

	public List<SelectOption> marcaList{get; set;}
    public String marca{get; set;}

	public Date fecha{get; set;}
    

    public String sucursalInput{get; set;}
    public String vendedorInput{get; set;}
    
    public String marcaInput{get; set;}
    public String fechaInput{get; set;}

    public Vendedor_Asignaciones__c vendedorObject{get;set;}
    
		 
		
    public ControllerMantenimientoAsignacionVend() {       
	    edicion = false;
        insercion = false;
        finalizada =true;
        showPantalla = true;
        getSucursalList();
        getVendedorList();
        getMarcasList();
        vendedorObject = new Vendedor_Asignaciones__c();

       	
    }

    public PageReference buscar() {  
	 	PageReference newPage = Page.MantenimientoAsignacionVendedores;
        newPage.getParameters().put('sucursal', sucursal);
        newPage.getParameters().put('vendedor', vendedor);
        newPage.getParameters().put('marca', marca);
        newPage.getParameters().put('fecha',String.valueOf(vendedorObject.Fecha_Asignacion__c));
        return newPage.setRedirect(true);
    }
    


    public List<SelectOption> getSucursalList(){
   		sucursalList = new List<SelectOption>();
		for(Sucursal__c g:[Select Name,Id from 	Sucursal__c]){
			sucursalList.add(new SelectOption(g.Id,g.Name));
			 			
		}     	
    	return sucursalList;
    }

	 public List<SelectOption> getVendedorList(){
   		vendedorList = new List<SelectOption>();
		for(Vendedores__c g:[Select Name,Id from 	Vendedores__c]){
			vendedorList.add(new SelectOption(g.Id,g.Name));
			 			
		}     	
    	return vendedorList;
    }

    public List<SelectOption> getMarcasList()
	{
	  marcaList = new List<SelectOption>();
	        
	   Schema.DescribeFieldResult fieldResult = Vendedores__c.Marcas__c.getDescribe();
	   List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
	        
	   for( Schema.PicklistEntry f : ple)
	   {
	      marcaList.add(new SelectOption(f.getLabel(), f.getValue()));
	   }       
	   return marcaList;
	}

    /*-----------------------------------------------------------------------------------------------------------
        @information: Método seleccionar lista cadena de valores.
    -----------------------------------------------------------------------------------------------------------*/
	public List<vendedorOportunidadWrapper> getListMantenimientoOportunidad() {	

		//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, getQuery()));

        ListVendedorOportunidad = new List<vendedorOportunidadWrapper>();

        String query = getQuery();
            
        for (Vendedor_Asignaciones__c vendedorOportunidadItem: Database.query(query))  {
                vendedorOportunidadWrapper vendedorItemWrapper = new vendedorOportunidadWrapper(false, vendedorOportunidadItem);
                ListVendedorOportunidad.add(vendedorItemWrapper);
        }   
  
		return ListVendedorOportunidad;
	}

    public List<vendedorOportunidadWrapper> getListMantenimientoOportunidadEdit() {      
		//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, getQuery()));

        if (ListVendedorOportunidadEdit == null) {
            ListVendedorOportunidadEdit = new List<vendedorOportunidadWrapper>();

            String query = getQuery();
        
            for (Vendedor_Asignaciones__c vendedorOportunidadItem: Database.query(query))  {
                vendedorOportunidadWrapper vendedorItemWrapper = new vendedorOportunidadWrapper(false, vendedorOportunidadItem);
                ListVendedorOportunidadEdit.add(vendedorItemWrapper);
            }   
        }     

        return ListVendedorOportunidadEdit;
    }


    public String getQuery(){

			String sOqlCondition = '';
         
            String sOQLQuery = 'select id, name,Activo__c,Fecha_Asignacion__c,Vendedor__c,Vendedor__r.Name,Vendedor__r.Sucursal__r.name,Vendedor__r.Marcas__c ,Vendedor__r.Usuario__r.name from Vendedor_Asignaciones__c ';
         
            if(apexpages.currentpage().getparameters().get('sucursal') != null){
           		sucursalInput = apexpages.currentpage().getparameters().get('sucursal');    
	            sOqlCondition += ' Where Vendedor__r.Sucursal__c =\''  + sucursalInput + '\'';
            }

            if(apexpages.currentpage().getparameters().get('vendedor') != null){
           		vendedorInput = apexpages.currentpage().getparameters().get('vendedor');    
           		if (sOqlCondition == ''){
					sOqlCondition += ' Where Vendedor__c =\''  + vendedorInput + '\'';
           		}else{
					sOqlCondition += ' And Vendedor__c =\''  + vendedorInput + '\'';
           		}
	            
            }

            if(apexpages.currentpage().getparameters().get('fecha') != null){
           		fechaInput = apexpages.currentpage().getparameters().get('fecha');    
            	if (sOqlCondition == ''){
					sOqlCondition += ' Where Fecha_Asignacion__c = '  + fechaInput ;
           		}else{
					sOqlCondition += ' And Fecha_Asignacion__c = '  + fechaInput ;
           		}
	            
            }

            if(apexpages.currentpage().getparameters().get('marca') != null){
           		marcaInput = apexpages.currentpage().getparameters().get('marca');    
            	if (sOqlCondition == ''){
					sOqlCondition += ' Where Vendedor__r.Marcas__c  includes (\''  + marcaInput + '\')' ;
           		}else{
					sOqlCondition += ' And Vendedor__r.Marcas__c  includes (\''  + marcaInput + '\')' ;
           		}
	            
            }

             sOqlCondition += ' Order by Vendedor__c,Fecha_Asignacion__c ASC';

             return sOQLQuery + sOqlCondition;

    }

    /*-----------------------------------------------------------------------------------------------------------
        @information: Class Wrapper para cadena de valor.
    -----------------------------------------------------------------------------------------------------------*/
	public class vendedorOportunidadWrapper {
		public Boolean checked {get; set;}
		public Vendedor_Asignaciones__c vendedor {get; set;}

		public vendedorOportunidadWrapper(Boolean check, Vendedor_Asignaciones__c vendedor) {
			this.checked = check;
			this.vendedor = vendedor;
		}
	}
    
   

    /*-----------------------------------------------------------------------------------------------------------
        @information: Método para mostrar la tabla para seleccionar los productos a agregar.
    -----------------------------------------------------------------------------------------------------------*/
	/*public PageReference agregarMantenimiento() {  
        agregar = true;
		insercion = true;  
		showPantalla = false;
		edicion = false;   
		newOppHistorico = new  Vendedor_Asignaciones__c(Activo__c = false,Vendedor__c = null,Fecha_Asignacion__c = null);
		return null;
	}*/

	public PageReference agregarMantenimiento() {  
        //agregar = true;

        agregar = true;
		insercion = true;  
		showPantalla = false;
		edicion = false;   
		newOppHistorico = new  Vendedor_Asignaciones__c(Activo__c = false,Vendedor__c = null,Fecha_Asignacion__c = null);
		return null;
	}

	public PageReference saveHistorico() {  
		try{
           ListVendedorOportunidadEdit = null;
			insercion = false;  
			showPantalla = true;
			edicion = false;     
			Vendedor_Asignaciones__c oppHistorico = new Vendedor_Asignaciones__c(Fecha_Asignacion__c = newOppHistorico.Fecha_Asignacion__c,Vendedor__c = newOppHistorico.Vendedor__c,Activo__c = newOppHistorico.Activo__c);
			insert oppHistorico;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Registro Guardado Satisfactoriamente'));
			return null;

		} catch(Exception e){
			       ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
			       return null;
        }
		
	}


	
    
    public PageReference restarurarPagina() {  
        insercion = false;  
        showPantalla = true;
        edicion = false;    
        ListVendedorOportunidadEdit = null; 
        return null;
    }
    

	public PageReference cancelHistorico() {  
		newOppHistorico = null;
		insercion = false;  
		showPantalla = true;
		edicion = false; 
     	return null;
	}
	

    public PageReference editarMantenimiento() {        
        insercion = false;  
		showPantalla = false;
		edicion = true;    

        return null;
    }

     public PageReference cancelarEdicion() {        
        insercion = false;  
		showPantalla = true;
		edicion = false;  
        return null;
    }

    /*-----------------------------------------------------------------------------------------------------------
        @information: Método para guardar los cambios a los productos de la cadena de valor.
    -----------------------------------------------------------------------------------------------------------*/
    public PageReference guardarCambios() {        
        Savepoint sp = Database.setSavepoint();  
        try {

            list<Vendedor_Asignaciones__c> listVendedor = new list<Vendedor_Asignaciones__c>();
            for (vendedorOportunidadWrapper cvW:  getListMantenimientoOportunidadEdit()) {
                listVendedor.add(cvW.vendedor);
            }

            if (listVendedor.size() >0) {
                //Upsert listVendedor;
                Database.upsert(listVendedor,false);

                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Guardado Satisfactorio'));
            }   

            insercion = false;  
			showPantalla = true;
			edicion = false;             
            
        } catch (System.Exception ex) {
            ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, ex.getdmlMessage(0) );
            ApexPages.addMessage(msg);            
            Database.rollback(sp);
        }
        return null;
    }

    /*-----------------------------------------------------------------------------------------------------------
        @information: Método para eliminar productos guardados en la cadena de valor.
    -----------------------------------------------------------------------------------------------------------*/
    public PageReference eliminarMantenimiento() {
    	insercion = false;  
		showPantalla = true;
		edicion = false;  
        Savepoint sp = Database.setSavepoint(); 
        try {
            list<Vendedor_Asignaciones__c> listVendedorDelete = new list<Vendedor_Asignaciones__c>();
            for (vendedorOportunidadWrapper cvw: getListMantenimientoOportunidadEdit()) {
                if (cvw.checked) {
                    listVendedorDelete.add(cvw.vendedor);
	           }
            }
            if (listVendedorDelete.size() >0) {
                Database.delete(listVendedorDelete,false);
                //delete listVendedorDelete;

                ListVendedorOportunidad = null; 
                ListVendedorOportunidadEdit = null; 
                   ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Eliminación Satisfactoria'));
            }
            
        } catch (System.Exception ex) {
            ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, ex.getdmlMessage(0) );
            ApexPages.addMessage(msg);            
            Database.rollback(sp);
        }          
        return null;
    }

    
	

    
}