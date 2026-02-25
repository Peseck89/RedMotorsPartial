@RestResource(UrlMapping = '/TraficoRM/*')
global class  WSRestW2L {

    @HttpPost
    global static responseWrapper crearTraficoPost() {

        System.debug(' *** Start **** ');

        RestRequest req = RestContext.request;
        responseWrapper responseJSON = new responseWrapper(); 
        
        System.debug('::::req:::: ' + req);
        
        if(req==null){
            responseJSON.code = '001';
            responseJSON.status = 'error';
            responseJSON.message = 'información entrante nula'; 
            return responseJSON;        
        }
        
        Blob bodyBlob = req.requestBody;
        LogTrafico__c JsonLog  = new LogTrafico__c();
        JsonLog.Body_Json__c = bodyBlob.toString();
        insert JsonLog;
            
        String jsonInput = req.requestBody.toString();
        
        System.debug('::::jsonInput:::: ' + jsonInput);
        
        JSONRegional trafico = (JSONRegional) JSON.deserialize(jsonInput, JSONRegional.class);

        System.debug('::::trafico:::: ' + trafico);

        System.debug('::::Marca entrante:::: ' + trafico.brand);
        if(trafico.brand==null||trafico.brand==''){
            responseJSON.code = '001';
            responseJSON.status = 'error';
            responseJSON.message = 'dato de marca inválido';
            return responseJSON;                
        }
        
        String marca = '';
        marca = trafico.brand.contains('Motorrad')?'Motorrad':trafico.brand;        

        if(((marca.equals('BMW')||marca.equals('MINI'))&&(trafico.modelo_interes.modelRange==null||trafico.modelo_interes.modelRange==''))||(marca.equals('Motorrad')&&(trafico.modelo_interes.modelCode==null||trafico.modelo_interes.modelCode==''))){
            responseJSON.code = '002';
            responseJSON.status = 'error';
            responseJSON.message = 'modelo regional no está presente en datos de entrada';              
            return responseJSON;        
        }
            
        System.debug('::::Solicitud:::: ' + trafico.tipo_de_solicitud);
        if(trafico.tipo_de_solicitud==null || (!trafico.tipo_de_solicitud.equals('TDA') && !trafico.tipo_de_solicitud.equals('RFO') && !trafico.tipo_de_solicitud.equals('RFI'))){
            responseJSON.code = '003';
            responseJSON.status = 'error';
            responseJSON.message = 'tipo de solicitud nulo o diferente a TDA, RFO y RFI';               
            return responseJSON;        
        }

        String modelo = '';
        if(marca.equals('BMW')||marca.equals('MINI'))   modelo = trafico.modelo_interes.modelRange;
        if(marca.equals('Motorrad'))                    modelo = trafico.modelo_interes.modelCode;

        System.debug('::::Marca buscar:::: ' + marca);
        System.debug('::::Modelo regional BMW o MINI:::: ' + trafico.modelo_interes.modelRange);
        System.debug('::::Modelo regional Motorrad:::: ' + trafico.modelo_interes.modelCode);       
        
        List<Product2> productos = [select Id,Familia__c from Product2 WHERE Codigo_Info__c=:modelo and Marca__c=:marca];

        if(productos.isEmpty()){
            responseJSON.code = '004';
            responseJSON.status = 'error';
            responseJSON.message = 'no se encuentra disponible el producto relacionado al modelo regional o marca enviado';
            return responseJSON;            
        }
        
        if(trafico.proxima_compra==null||trafico.proxima_compra.equals('')){
            responseJSON.code = '005';
            responseJSON.status = 'error';
            responseJSON.message = 'falta fecha estimada de compra';
            return responseJSON;                    
        }
        
        if(trafico.local==null||trafico.local.equals('')){
            responseJSON.code = '006';
            responseJSON.status = 'error';
            responseJSON.message = 'falta concesionario o local comercial';
            return responseJSON;            
        }       
        
        list<Group> colaWeb = [select id from Group where name='Cola de Candidatos Web' and type='queue'];
        //Ajuste Mario Mora, segun la marca el sistema realiza 2 procesos diferentes
        // Code Added By Mayur Rachhadiya for Model Issue :: START
        Schema.SObjectField theField = Lead.Modelo_De_Inter_s1_New__c;
        Schema.SObjectField ctrlField = Lead.Familia1__c;
        Map<String, List<String>> values = HL_FieldDescribeUtil.getDependentOptionsImpl(theField, ctrlField);
        String familier1 = productos[0].Familia__c;
        System.debug('familier1 :: ' + familier1);
        String modelNameNew;
        for (String familyName : values.keySet()) {
            if (familyName == familier1) {
                System.debug('La marca es: '+marca);
                    if(marca.equals('BMW')){
                        system.debug('Entro en BMW');
                        for (String modelName : values.get(familyName)) {
                    System.debug('Name1: '+modelName);
                         if (trafico.version_interes != null && trafico.version_interes.motorizacion!= null && modelName.containsIgnoreCase(trafico.version_interes.motorizacion)) {
                            string agcode = trafico.version_interes.agCode;
                            List<Product2> pro = [SELECT Id,Name,Codigo_de_Producto__c from Product2 where familia__c =:familier1 AND Codigo_de_Producto__c=:agcode Limit 1];
                            if(pro.size()>0){
                                modelNameNew = pro[0].Name;
                            }else{
                                 System.debug('Producto no existe');
                            }
                            
                        }
                        else{
                            System.debug('Salio: trafico.version_interes: '+trafico.version_interes+
                                         ' trafico.version_interes.motorizacion: '+trafico.version_interes.motorizacion+
                                         ' modelName.containsIgnoreCase(trafico.version_interes.motorizacion): '+modelName.containsIgnoreCase(trafico.version_interes.motorizacion));
                        }
                        }
                    }else{
                        if(marca.equals('Motorrad')){
                            System.debug('Entro en Motorrad');
                            string agcode = trafico.modelo_interes.modelCode;
                             List<Product2> pro = [SELECT Id,Name,Codigo_de_Producto__c from Product2 where familia__c =:familier1 AND Codigo_de_Producto__c=:agcode Limit 1];
                            if(pro.size()>0){
                                modelNameNew = pro[0].Name;
                            }else{
                                 System.debug('Producto no existe');
                            }
                        }else{
                            if(marca.equals('MINI')){
                                 System.debug('Entro en Mini');
                                string agcode = trafico.modelo_interes.modelRange;
                               List<Product2> pro = [SELECT Id,Name,Codigo_de_Producto__c from Product2 where familia__c =:familier1 AND Codigo_de_Producto__c=:agcode Limit 1];
                            	if(pro.size()>0){
                                modelNameNew = pro[0].Name;
                                }else{
                                    System.debug('Producto no existe');
                                }
							}
                        }
						}
                    
                }
            }
        
        System.debug('Nombre del modelo : '+modelNameNew);
        // Code Added By Mayur Rachhadiya for Model Issue :: END

            Lead traficoWeb = new Lead ( 
                OwnerId = colaWeb[0].id,
                RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(marca).getRecordTypeId(), 
                Sucursal__c = trafico.local, 
                Salutation = trafico.saludo, 
                Firstname = trafico.nombre, 
                Lastname = trafico.apellido,
                Email = trafico.email,
                RFI__c = trafico.tipo_de_solicitud.equals('RFI')?true:false,
                RFO__c = trafico.tipo_de_solicitud.equals('RFO')?true:false,
                TDA__c = trafico.tipo_de_solicitud.equals('TDA')?true:false,
                MobilePhone = trafico.tipo_telefono!=''&&trafico.tipo_telefono!=null&&trafico.telefono!=null&&trafico.tipo_telefono.equals('Móvil')?trafico.telefono:null,
                Phone = trafico.tipo_telefono!=''&&trafico.tipo_telefono!=null&&trafico.telefono!=null&&!trafico.tipo_telefono.equals('Móvil')?trafico.telefono:null,
                Familia1__c = productos[0].Familia__c, 
                Marca__c = marca, 
                Modelo_De_Inter_s1_New__c = modelNameNew,
                EsWeb2Lead_del__c = true,
                LeadSource = 'Página Web',
                Direccion__c = trafico.ciudad!=null?trafico.ciudad:'',
                FechaPosibleCompra__c = WSRestW2L.FechaCompra(trafico.proxima_compra)                
            );      
            
        try{
            
            insert traficoWeb;

            responseJSON.traficoid = traficoWeb.id;
            responseJSON.message = 'tráfico creado exitosamente';
        
        }catch(DmlException Ex){
            System.debug('Error al crear tráfico ' + ex.getMessage());
            responseJSON.code = '999';
            responseJSON.status = 'error';
            responseJSON.message = 'error interno al crear trafico: ' + ex.getMessage();
            return responseJSON;
        } 
        return responseJSON;

    }
    
    /***** INICIO: Clases convertidas con Json2Apex *****/
    
    public class Modelo_interes {
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
        public String motorizacion;
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
        
}