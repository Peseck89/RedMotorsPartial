/*
    WS para crear traficos provenientes de la web
*/
@RestResource(UrlMapping = '/TraficoBMW/*')
global with sharing class WsBMWIntegracion2 {
@HttpPost
    global static responseWrapper WsBMWIntegracion2() {
        System.debug(' *** Start **** ');

        RestRequest req = RestContext.request;
        responseWrapper responseJSON = new responseWrapper(); 
     //Se valida que el Json contenga informacion     
        System.debug('::::req:::: ' + req);
        
        if(req==null){
            responseJSON.code = '007';
            responseJSON.status = 'error';
            responseJSON.message = 'información entrante nula'; 
            return responseJSON;        
        }
        
        //Se deserealiza el JSON

        Blob bodyBlob = req.requestBody;
        LogTrafico__c JsonLog  = new LogTrafico__c();
        JsonLog.Body_Json__c = bodyBlob.toString();
        insert JsonLog;

        String jsonInput = req.requestBody.toString();
        
        System.debug('::::jsonInput:::: ' + jsonInput);
        //Por medio de una subclase interna de deserealiza el json
        JSONRegional trafico = (JSONRegional) JSON.deserialize(jsonInput, JSONRegional.class);
        
        Map<String, Object> jsonObject = (Map<String, Object>)JSON.deserializeUntyped(jsonInput);

        System.debug('::::trafico:::: ' + trafico);

        System.debug('::::Marca entrante:::: ' + trafico.brand);
        //Se valida la marca del lead entrante
        if(trafico.brand==null||trafico.brand==''){
            responseJSON.code = '001';
            responseJSON.status = 'error';
            responseJSON.message = 'dato de marca inválido';
            return responseJSON;                
        }
        //Se asigna la marca 
        String marca = '';
        marca = trafico.brand.contains('Motorrad')?'Motorrad':trafico.brand;        
        //Se valida que exista la marca
        if(((marca.equals('BMW')||marca.equals('MINI'))&&(trafico.modelo_interes.modelRange==null||trafico.modelo_interes.modelRange==''))||(marca.equals('Motorrad')&&(trafico.modelo_interes.modelCode==null||trafico.modelo_interes.modelCode==''))){
            responseJSON.code = '002';
            responseJSON.status = 'error';
            responseJSON.message = 'modelo regional no está presente en datos de entrada';              
            return responseJSON;        
        }
        //Se valida el tipo de solicitud
        System.debug('::::Solicitud:::: ' + trafico.tipo_de_solicitud);
        if(trafico.tipo_de_solicitud==null || (!trafico.tipo_de_solicitud.equals('TDA') && !trafico.tipo_de_solicitud.equals('RFO') && !trafico.tipo_de_solicitud.equals('RFI'))){
            responseJSON.code = '003';
            responseJSON.status = 'error';
            responseJSON.message = 'tipo de solicitud nulo o diferente a TDA, RFO y RFI';               
            return responseJSON;        
        }
        //Se obtiene el codigo modelo de interes del trafico
        //Este sera utilizado para buscar luego el producto en el CRM
        String modelo = '';
        if(marca.equals('BMW')||marca.equals('MINI'))   modelo = trafico.modelo_interes.modelRange;
        if(marca.equals('Motorrad'))                    modelo = trafico.modelo_interes.modelCode;

        System.debug('::::Marca buscar:::: ' + marca);
        System.debug('::::Modelo regional BMW o MINI:::: ' + trafico.modelo_interes.modelRange);
        System.debug('::::Modelo regional Motorrad:::: ' + trafico.modelo_interes.modelCode);       
       
        //Se valida que exista un estimado de compra
        if(trafico.proxima_compra==null||trafico.proxima_compra.equals('')){
            responseJSON.code = '005';
            responseJSON.status = 'error';
            responseJSON.message = 'falta fecha estimada de compra';
            return responseJSON;                    
        }
        //Se valida que esixta una sucursal 
        if(trafico.local==null||trafico.local.equals('')){
            responseJSON.code = '006';
            responseJSON.status = 'error';
            responseJSON.message = 'falta concesionario o local comercial';
            return responseJSON;            
        }       
        
        list<Group> colaWeb = [select id from Group where name='Cola de Candidatos Web' and type='queue'];
        //Ajuste para poder seleccionar la familia y el modelo de interes que se encuentra en SF
        //Esto con el fin de utilizar el ageCode como identificador unico
        String modelNameNew;
        String familia;
        if(trafico.tipo_de_solicitud.equals('RFO') || (trafico.tipo_de_solicitud.equals('RFO') && test.isRunningTest())){
                System.debug('La marca es: '+marca);
                    if(marca.equals('BMW') || (marca.equals('BMW') && test.isRunningTest())){
                        system.debug('Entro en BMW');
                         if (trafico.version_interes != null && trafico.version_interes.motorizacion!= null) {
                            string agcode = trafico.version_interes.agCode;
                            List<Product2> pro = [SELECT Id,Name,Codigo_de_Producto__c,Modelo_De_Inter_s__c,familia__c from Product2 where Codigo_de_Producto__c=:agcode Limit 1];
                            if(pro.size()>0 || (pro.size()>0 && Test.isRunningTest())){
                                modelNameNew = pro[0].Modelo_De_Inter_s__c ;
                                familia =pro[0].familia__c;
                            }else{
                                 responseJSON.code = '004';
                                 responseJSON.status = 'error';
                                 responseJSON.message = 'no se encuentra disponible el producto relacionado al modelo regional o marca enviado';
                                 return responseJSON;
                            }
                            
                        }
                        else{
                            System.debug('Salio: trafico.version_interes: '+trafico.version_interes+
                                         ' trafico.version_interes.motorizacion: '+trafico.version_interes.motorizacion);
                        }
                        
                    }else{
                        if(marca.equals('Motorrad') || (marca.equals('Motorrad') && Test.isRunningTest())){
                            System.debug('Entro en Motorrad');
                            string agcode = trafico.modelo_interes.modelCode;
                             List<Product2> pro = [SELECT Id,Name,Codigo_de_Producto__c,Modelo_De_Inter_s__c,familia__c  from Product2 where Codigo_de_Producto__c=:agcode Limit 1];
                            if(pro.size()>0 || (pro.size()>0 && Test.isRunningTest())){
                                modelNameNew = pro[0].Modelo_De_Inter_s__c ;
                                familia =pro[0].familia__c;
                            }else{
                                responseJSON.code = '004';
                                     responseJSON.status = 'error';
                                   responseJSON.message = 'no se encuentra disponible el producto relacionado al modelo regional o marca enviado';
                                     return responseJSON;
                            }
                        }else{
                            if(marca.equals('MINI') || (marca.equals('MINI') && Test.isRunningTest())){
                                 System.debug('Entro en Mini');

                                string agcode = '';
                                if (trafico.modelo_interes.versiones[0].agCode == '11DJ' ||trafico.modelo_interes.versiones[0].agCode == '21BS') {
                                    agcode = trafico.modelo_interes.versiones[0].agCode;
                                }else {
                                    agcode = trafico.modelo_interes.modelRange;
                                }

                                List<Product2> pro = [SELECT Id,Name,Codigo_de_Producto__c,Modelo_De_Inter_s__c,familia__c  from Product2 where  Codigo_de_Producto__c=:agcode Limit 1];
                            	if(pro.size()>0 || (pro.size()>0 && Test.isRunningTest())){
                                modelNameNew = pro[0].Modelo_De_Inter_s__c ;
                                familia =pro[0].familia__c;
                                }else{
                                   responseJSON.code = '004';
                                    responseJSON.status = 'error';
                                      responseJSON.message = 'no se encuentra disponible el producto relacionado al modelo regional o marca enviado';
                                      return responseJSON;
                                }
							}
                        }
						}
                    
                }

        

        System.debug('Nombre del modelo : '+modelNameNew);
        // Esta seccion se encarga de realizar los 3 flujos, segun el tipo de solicitud

        Lead traficoWeb = new Lead();
        //Solicitud RFI
        if(trafico.tipo_de_solicitud.equals('RFI') || (trafico.tipo_de_solicitud.equals('RFI') && Test.isRunningTest())){
            system.debug('Entro RFI');
            traficoWeb.OwnerId = colaWeb[0].id;
            traficoWeb.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(marca).getRecordTypeId();
            
            String objectIdValue = (String)jsonObject.get('_id');
            traficoWeb.external_id__c = objectIdValue;
            system.debug('Valor del ID: ' + objectIdValue);
            
            traficoWeb.Sucursal__c = trafico.local;
            traficoWeb.Salutation = trafico.saludo;
            traficoWeb.Firstname = trafico.nombre; 
            traficoWeb.Lastname = trafico.apellido;
            traficoWeb.Email = trafico.email;
            traficoWeb.RFI__c = trafico.tipo_de_solicitud.equals('RFI')?true:false;
            traficoWeb.MobilePhone = trafico.tipo_telefono!=''&&trafico.tipo_telefono!=null&&trafico.telefono!=null?trafico.telefono:null;
            traficoWeb.MobilePhone = trafico.tipo_telefono!=''&&trafico.tipo_telefono!=null&&trafico.telefono!=null?trafico.telefono:null;
            //traficoWeb.Familia1__c = productos[0].Familia__c; 
            //traficoWeb.Modelo_De_Inter_s1_New__c = 'RFI';
            traficoWeb.Marca__c = marca;
            traficoWeb.EsWeb2Lead_del__c = true;
            traficoWeb.LeadSource = 'Página Web';
            traficoWeb.Direccion__c = trafico.ciudad!=null?trafico.ciudad:'';
            traficoWeb.FechaPosibleCompra__c = WSRestW2L.FechaCompra(trafico.proxima_compra);                
                
        }else{
            //Solicitud TDA
            if(trafico.tipo_de_solicitud.equals('TDA') || (trafico.tipo_de_solicitud.equals('TDA') && Test.isRunningTest())){
                system.debug('Entro TDA');
                traficoWeb.OwnerId = colaWeb[0].id;
                traficoWeb.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(marca).getRecordTypeId();

                // string agcode = trafico.version_interes.agCode;
                // List<Product2> pro = [SELECT Id,Name,Codigo_de_Producto__c,Modelo_De_Inter_s__c,familia__c from Product2 where Codigo_de_Producto__c=:agcode Limit 1];
                // modelNameNew = pro[0].Modelo_De_Inter_s__c ;
                // familia =pro[0].familia__c;


                String objectIdValue = (String)jsonObject.get('_id');
                traficoWeb.external_id__c = objectIdValue;
                system.debug('Valor del ID: ' + objectIdValue);
                
                traficoWeb.Sucursal__c = trafico.local;
                traficoWeb.Salutation = trafico.saludo; 
                traficoWeb.Firstname = trafico.nombre;
                traficoWeb.Lastname = trafico.apellido;
                traficoWeb.Email = trafico.email;
                traficoWeb.TDA__c = trafico.tipo_de_solicitud.equals('TDA')?true:false;
                traficoWeb.MobilePhone = trafico.tipo_telefono!=''&&trafico.tipo_telefono!=null&&trafico.telefono!=null?trafico.telefono:null;
                traficoWeb.MobilePhone = trafico.tipo_telefono!=''&&trafico.tipo_telefono!=null&&trafico.telefono!=null?trafico.telefono:null;
                if(trafico.modelo_interes.modelRange != null || trafico.modelo_interes.modelRange != ''){
                    String modeloBusqueda ='';
                    if(marca == 'BMW'){
                        modeloBusqueda= trafico.modelo_interes.versiones[0].agCode;
                    }else{
                        modeloBusqueda = trafico.modelo_interes.modelRange;
                    }                    
                    
                    List<Product2> lstProdMini = [SELECT Id,Name,Codigo_de_Producto__c,Modelo_De_Inter_s__c,familia__c from Product2 where Codigo_de_Producto__c=:modeloBusqueda Limit 1];
                    if(lstProdMini.size()>0){
                        traficoWeb.Familia1__c = lstProdMini[0].familia__c; 
                        traficoWeb.Modelo_De_Inter_s1__c = lstProdMini[0].Modelo_De_Inter_s__c;  
                    }
                    
                }   
				
                //traficoWeb.Familia1__c = productos[0].Familia__c;
                //traficoWeb.Modelo_De_Inter_s1_New__c = 'TDA';
                traficoWeb.Marca__c = marca;
                traficoWeb.EsWeb2Lead_del__c = true;
                traficoWeb.LeadSource = 'Página Web';
                traficoWeb.Direccion__c = trafico.ciudad!=null?trafico.ciudad:'';
                traficoWeb.FechaPosibleCompra__c = WSRestW2L.FechaCompra(trafico.proxima_compra);
             
            }else{
                //Solicitud RFO
                system.debug('Entro RFO');
                traficoWeb.OwnerId = colaWeb[0].id;
                traficoWeb.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(marca).getRecordTypeId();
                traficoWeb.Sucursal__c = trafico.local;
                
                String objectIdValue = (String)jsonObject.get('_id');
                traficoWeb.external_id__c = objectIdValue;
                system.debug('Valor del ID: ' + objectIdValue);
                
                traficoWeb.Salutation = trafico.saludo;	
                traficoWeb.Firstname = trafico.nombre;
                traficoWeb.Lastname = trafico.apellido;
                traficoWeb.Email = trafico.email;
                traficoWeb.RFO__c = trafico.tipo_de_solicitud.equals('RFO')?true:false;
                traficoWeb.MobilePhone = trafico.tipo_telefono!=''&&trafico.tipo_telefono!=null&&trafico.telefono!=null?trafico.telefono:null;
                traficoWeb.MobilePhone = trafico.tipo_telefono!=''&&trafico.tipo_telefono!=null&&trafico.telefono!=null?trafico.telefono:null;
                traficoWeb.Familia1__c = familia;
                traficoWeb.Marca__c = marca;
                traficoWeb.Modelo_De_Inter_s1__c = modelNameNew;
                //traficoWeb.Modelo_De_Inter_s1_New__c = modelNameNew;
                traficoWeb.EsWeb2Lead_del__c = true;
                traficoWeb.LeadSource = 'Página Web';
                traficoWeb.Direccion__c = trafico.ciudad!=null?trafico.ciudad:'';
                traficoWeb.FechaPosibleCompra__c = WSRestW2L.FechaCompra(trafico.proxima_compra);               
            }
        }
               
            system.debug('Trafico insertado: '+traficoWeb);
        try{
            
            insert traficoWeb;

            responseJSON.traficoid = traficoWeb.id;
            responseJSON.message = 'tráfico creado exitosamente';
        
        }catch(DmlException Ex){
            System.debug('Error al crear tráfico ' + ex.getMessage());
            responseJSON.code = '008';
            responseJSON.status = 'error';
            responseJSON.message = 'error interno al crear trafico: ' + ex.getMessage();
            return responseJSON;
        } 
        return responseJSON;

    }

      /***** INICIO: Clases convertidas con Json2Apex *****/
    
      public class Modelo_interes {
        public String familia;
        public String modelo;
        public String modelRange;
        public String modelCode;

        public List<Versiones> versiones;
        public String catalogo_nombre;
        public String catalogo_link;
        public List<String> ruta_showroom;
        public String brand;
    }

    public class Tasks {
        public Task_1 task_1;
        public Task_1 task_dynamics;
        public Task_track task_track;
    }

    public class JSONRegional {
        public String referrer;
        public String window_location_pathname;
        public String tipo_de_solicitud;
        public String language;
        public String formulario;
        public String job;
        public String organization;
        public String brand;
        public Tasks tasks;
        public Boolean aviso_privacidad;
        public String distribuidor;
        public String referrer_param;
        public String origen_param;
        public String origen;
        public String ciudad;
        public String configurator_modelRange;
        public String configurator_agCode;
        public String configurator_configUrl;
        public String configurator_series;
        public String configurator_bodyType;
        public String configurator_vgCode;
        public String configurator_totalprice;
        public String configurator_options;
        public Modelo_interes modelo_interes;
        public String campaign_name;
        public String campaign_model;
        public String campaign_source;
        public String local;
        public String saludo;
        public String nombre;
        public String apellido;
        public String email;
        public String telefono;
        public String tipo_telefono;
        public String proxima_compra;
        public Versiones version_interes;
        public String controller;
        public String created_at;
        public Integer created_at_offset;
        public String domain;
        public String pais;
        public String job_status;
        public String job_started_at;
    }

    public class Task_1 {
        public String email_adresses_list;
        public String template;
    }

    public class Versiones {
        public String agCode;
        public String Vehicle_Model_Family;
        public String motorizacion;
        public String nombre;
    }

    public class Task_track {
        public String event;
    }

    /**** FIN: Clases convertidas con Json2Apex *****/
    
    //wrapper class for the response to an API request
    global class responseWrapper {
        
        global String code {get;set;}
        global String status {get;set;} //status string
        global String traficoid {get;set;} //18 character Lead record id
        global String message {get;set;} //message string
        
        //constructor
        global responseWrapper() {
            //default all values
            this.code = '000';
            this.status = 'éxito';
            this.traficoid = '';
            this.message = '';
        }
    }
    
    public static string FechaCompra(String fechaWS){
        String fecha = '';
            if(fechaWS.equals('')){fecha='';    
            }else if(fechaWS.equals('Antes de 3 meses.')){ fecha = '1 a 3 meses';
            }else if(fechaWS.equals('De 3 a 6 meses.')){ fecha = '4 a 6 meses';
            }else if(fechaWS.equals('Después de 6 meses.')) {fecha = 'Después de 6 meses.';
            }
            
        return fecha;
    }  
    
    public static string getPickListValuesIntoList(String FamiliaEntrante,String Valor2){
       List<String> pickListValuesList= new List<String>();
        String valor = '';
		Schema.DescribeFieldResult fieldResult = Lead.Familia1__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple){
            if( pickListVal.getLabel() ==FamiliaEntrante){
               valor = pickListVal.getLabel(); 
            }else{
               if( pickListVal.getLabel() == Valor2){
               valor = pickListVal.getLabel(); 
            } 
            }
			
		}    
    system.debug('Salida:'+valor);
        return valor;
		
    }
        
}