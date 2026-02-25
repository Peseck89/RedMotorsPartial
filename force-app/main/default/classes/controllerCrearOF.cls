/*
    creado por : David Leon Sanchez IS
    fecha: 05/03/2018
    descripcion: controlador para el funcionamiento del visualforce crearOF
    *
    modificado por : K Rojas 
    fecha: 07/03/2018
    descripcion: metodo de buscar sucurcal segun vendedor, cambio en nombre del cliente
*/
public class controllerCrearOF  {
    
    public final Oportunidad_de_Financiamiento__c  opF{get;set;}
    public Id idTipoRegistro, idTipoRegistroProducto, IdTipoRegistroFisico, IdTipoRegistroJuridico; 
    public String Marca{get;set;}
    public String Modelo{get;set;}
    public List<SelectOption> listMarcas{get;set;}
    public List<SelectOption> listModelos{get;set;} 
    public Account act = new Account();

    public controllerCrearOF(ApexPages.StandardController stdController){
        opF = new Oportunidad_de_Financiamiento__c();
        idTipoRegistro = Schema.SObjectType.Oportunidad_de_Financiamiento__c.getRecordTypeInfosByName().get('Altica').getRecordTypeId();
        idTipoRegistroProducto = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Producto Altica').getRecordTypeId();
        IdTipoRegistroFisico = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cliente Físico').getRecordTypeId();
        IdTipoRegistroJuridico = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cliente Jurídico').getRecordTypeId();
        System.debug('**** id tipo registro ***** ' + idTipoRegistro);
        System.debug('**** id tipo producto ***** ' + idTipoRegistroProducto);
        getListMarcas();
    }

    //Metodo para mostrar las marcas
    public List<SelectOption> getListMarcas(){
        List<Product2> listTemp = new List<Product2>();
        Set<String> listTemp2 = new Set<String>();

        listMarcas = new List<SelectOption>();
        listTemp = [SELECT Name FROM Product2 WHERE RecordTypeId =: idTipoRegistroProducto ORDER BY Name ASC];
        if(!listTemp.isEmpty()){
            for(Product2 prod : listTemp){
                if(!listTemp2.contains(prod.Name)){
                    listTemp2.add(prod.Name);
                }
            }
            for(String str : listTemp2){
                listMarcas.add(new SelectOption(str, str));
            }
        }
        return listMarcas;  
    }

    //Metodo para llamar al getListModelos
    public void actualizarModelos(){
        getListModelos();
    }

    //Metodo para obtener los modelos de acuerdo a la marca seleccionada
    public List<SelectOption> getListModelos(){
        List<Product2> listTemp = new List<Product2>();
        Set<String> listTemp2 = new Set<String>();

        listModelos = new List<SelectOption>();
        listTemp = [SELECT Modelo_Altica__c FROM Product2 WHERE Name =: Marca ORDER BY Modelo_Altica__c ASC];
        if(!listTemp.isEmpty()){
            for(Product2 prod : listTemp){
                if(!listTemp2.contains(prod.Modelo_Altica__c)){
                    listTemp2.add(prod.Modelo_Altica__c);
                }
            }
            for(String str : listTemp2){
                listModelos.add(new SelectOption(str, str));
            }
        }
        return listModelos; 
    }

    //Metodo para guardar la oportunidad de financiammiento
    public PageReference guardar(){
        PageReference page;
        if(!validaciones()){
            ApexPages.addMessage(New ApexPages.Message(ApexPages.Severity.INFO, 'La sección Producto tiene que estar completa'));
        }else{
            try{
                opF.RecordTypeId = idTipoRegistro;
                opF.Modelo_Altica__c = Modelo;
                opF.Marca_Altica__c = Marca;
                
                if(opF.TipoProducto__c=='Marchamo'||opF.TipoProducto__c=='Accesorios'){
                    opF.Name = act.Name + '-' + opF.TipoProducto__c + '-' + System.today().format();
                }else{
                	opF.Name = act.Name + '-' + Marca + '-' + System.today().format();    
                }
                
                opF.Excepcion__c = 'No';
                TriggerHandler.bypass('OpportunityTriggerHandler');
                System.debug('**** OF ***** ' + opF);
                insert opF;
                TriggerHandler.clearBypass('OpportunityTriggerHandler');
                page = new ApexPages.StandardController(opF).view();
                page.setRedirect(true);
                //showRecordNew(opF.Id);
            }catch(DMLException ex){
                ApexPages.addMessage(New ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            }
        }
        return page;
    }
    
    public PageReference showRecordNew(String id){
        System.debug('**** metodo registro **** ' + id);
        PageReference page = new PageReference('/' + id);
        page.setRedirect(true);
        return page;
    }
    
    public boolean validaciones(){
        System.debug('**** metodo validaciones **** ');
        System.debug('*** datos *** ' + Modelo + ' ' + Marca + ' ' + opF.Ano__c);
        if(Modelo == null || Marca == null || opF.Ano__c == null){
            return false;
        }else{
            return true;
        }
    }

    //Metodo para buscar informacion del cliente
    public void buscarCliente(){
        if(opF.Nombre_Cliente_Altica__c != null){
            act = [SELECT Name, Cedula__c, PersonMobilePhone, Phone, PersonEmail, CorreoElectronicoEmpresarial__c, Monedas_Iden__c, Monto_Ingreso__c, RecordTypeId
                    FROM Account WHERE Id =: opF.Nombre_Cliente_Altica__c];
            if(act.PersonEmail != null){
                opF.Email__c = act.PersonEmail;
            }else{
                opF.Email__c = act.CorreoElectronicoEmpresarial__c;
            }
            if(act.PersonMobilePhone != null){
                opF.Movil_Altica__c = act.PersonMobilePhone;
            }else{
                opF.Movil_Altica__c = act.Phone;
            }
            opF.Numero_de_Identificacion_Altica__c = act.Cedula__c;
            opF.ModenaIngreso__c = act.Monedas_Iden__c;
            opF.Ingreso__c = act.Monto_Ingreso__c;
        }
    }
    
    //Busca la sucursal y email del vendedor seleccionado
    public void buscarSucursalVendedor(){
        //String suc;

        if(opF.Vendedor_Altica__c != null){
            Vendedores__c[] suc = [SELECT Sucursal__r.Name FROM Vendedores__c WHERE Usuario__c =: opF.Vendedor_Altica__c];
            if(suc.size() > 0){
                opF.Sucursal_Altica__c = suc[0].Sucursal__r.Name;
                opF.EmailVendedorOP__c = [SELECT Email FROM User WHERE Id =: opF.Vendedor_Altica__c LIMIT 1].Email;
            }else{
                System.debug('*** muestra alerta *** ');
                ApexPages.addMessage(New ApexPages.Message(ApexPages.Severity.INFO, 'Usuario no existe como vendedor en salesforce'));
            }
            //opF.Sucursal_Altica__c = ven.Sucursal__c;
        }
    }
}