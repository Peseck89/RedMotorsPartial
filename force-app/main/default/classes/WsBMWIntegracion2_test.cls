@isTest
public class WsBMWIntegracion2_test {
 @TestSetup
    static void setup(){
        Product2 product = new Product2();
        product.Name ='BMW1';
        product.Codigo_de_Producto__c ='10000';
        
        product.Familia__c ='X1';
        product.Marca__c = 'BMW';
        insert product;
        
        Product2 product2 = new Product2();
        product2.Name ='BMW1';
        product2.Codigo_de_Producto__c ='100003';
        
        product2.Familia__c ='X1';
        product2.Marca__c = 'MINI';
        insert product2;
    }  
  
  @isTest
    public static void Caso1(){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/TraficoBMW/'; 
        req.httpMethod = 'Post';
        String body ='{"_id": "64adb05853e5381782712414","referrer": "https://www.bmw.co.cr/es/ssl/solicitud-de-oferta.html","window_location_pathname": "/solicitud_cotizacion/","tipo_de_solicitud": "RFO","language": "es","formulario": "Solicitud de Cotización","job": "default","organization": "LATAM","brand": "BMW","tasks": {"task_1": {"email_adresses_list": "bmw_list_1","template": "default"},"task_dynamics": {"email_adresses_list": "dynamics_emails_list","template": "solicitud_cotizacion"},"task_track": {"event": "Lead Generation"}},"userAgent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/85.0.4183.83 Safari/537.36","F": "3","distribuidor": null,"referrer_param": null,"origen_param": "http://www.bmw.co.cr","aviso_privacidad": true,"origen": "http://www.bmw.co.cr","ciudad": "San Jose","configurator_modelRange": "${urlParameter.modelRange}","configurator_agCode": "${urlParameter.agCode}","configurator_configUrl": null,"configurator_series": null,"configurator_bodyType": "${urlParameter.bodyType}","configurator_vgCode": "${urlParameter.vgCode}","configurator_totalprice": "${urlParameter.totalprice}","configurator_options": "${urlParameter.options}","param_dealer": null,"modelo_interes": {"familia": "Serie 3","modelo": "BMW Serie 3 Sedán","modelRange": "G20","versiones": [{"agCode": "5F31","motorizacion": "320i"},{"agCode": "5R11","motorizacion": "330i"}],"catalogo_nombre": "catálogo","catalogo_link": "cocrBMW_G","ruta_showroom": ["",""],"brand": "BMW","tipo": ["Sedán"]},"campaign_name": null,"campaign_model": null,"campaign_source": null,"label_tel": "Teléfono","tipo_telefono": "Móvil","version_interes": {"agCode": "10000","motorizacion": "320i"},"local": "Escazú","saludo": "Sr.","nombre": "TeteMArioIncompany","apellido": "TeteMArioIncompany","email": "mario@incompany.cr","telefono": "8913847","proxima_compra": "Antes de 3 meses.","controller": "leads-irc-controller.js","created_at": "2020-09-11T03:42:02.873Z","created_at_offset": 300,"domain": "bmw.co.cr","ip": "201.191.106.93","pais": "Costa Rica","job_started_at": "2020-09-11T03:42:05.471Z","job_status": "processing","configurator_options_arr": [{"code": "${urlParameter.options}","description": ""}]}';
        
        req.requestBody = Blob.valueOf(body);
        req.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req;
        RestContext.response = res; 
        
        Test.startTest();
        WsBMWIntegracion2.WsBMWIntegracion2();
        Test.stopTest();  
    }
    
    
    @isTest
    public static void Caso2(){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/TraficoBMW/'; 
        req.httpMethod = 'Post';
        String body ='{"_id": "5f5af20a78246674f529f3bb","referrer": "https://www.bmw.co.cr/es/ssl/solicitud-de-oferta.html","window_location_pathname": "/solicitud_cotizacion/","tipo_de_solicitud": "RFI","language": "es","formulario": "Solicitud de Cotización","job": "default","organization": "LATAM","brand": "BMW","tasks": {"task_1": {"email_adresses_list": "bmw_list_1","template": "default"},"task_dynamics": {"email_adresses_list": "dynamics_emails_list","template": "solicitud_cotizacion"},"task_track": {"event": "Lead Generation"}},"userAgent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/85.0.4183.83 Safari/537.36","F": "3","distribuidor": null,"referrer_param": null,"origen_param": "http://www.bmw.co.cr","aviso_privacidad": true,"origen": "http://www.bmw.co.cr","ciudad": "San Jose","configurator_modelRange": "${urlParameter.modelRange}","configurator_agCode": "${urlParameter.agCode}","configurator_configUrl": null,"configurator_series": null,"configurator_bodyType": "${urlParameter.bodyType}","configurator_vgCode": "${urlParameter.vgCode}","configurator_totalprice": "${urlParameter.totalprice}","configurator_options": "${urlParameter.options}","param_dealer": null,"modelo_interes": {"familia": "Serie 3","modelo": "BMW Serie 3 Sedán","modelRange": "G20","versiones": [{"agCode": "5F31","motorizacion": "320i"},{"agCode": "5R11","motorizacion": "330i"}],"catalogo_nombre": "catálogo","catalogo_link": "cocrBMW_G","ruta_showroom": ["",""],"brand": "BMW","tipo": ["Sedán"]},"campaign_name": null,"campaign_model": null,"campaign_source": null,"label_tel": "Teléfono","tipo_telefono": "Móvil","version_interes": {"agCode": "10000","motorizacion": "320i"},"local": "Escazú","saludo": "Sr.","nombre": "TeteMArioIncompany","apellido": "TeteMArioIncompany","email": "mario@incompany.cr","telefono": "8913847","proxima_compra": "Antes de 3 meses.","controller": "leads-irc-controller.js","created_at": "2020-09-11T03:42:02.873Z","created_at_offset": 300,"domain": "bmw.co.cr","ip": "201.191.106.93","pais": "Costa Rica","job_started_at": "2020-09-11T03:42:05.471Z","job_status": "processing","configurator_options_arr": [{"code": "${urlParameter.options}","description": ""}]}';
        
        req.requestBody = Blob.valueOf(body);
        req.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req;
        RestContext.response = res; 
        
        Test.startTest();
        WsBMWIntegracion2.WsBMWIntegracion2();
        Test.stopTest();  
    }
    
    
     @isTest
    public static void Caso3(){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/TraficoBMW/'; 
        req.httpMethod = 'Post';
        String body ='{"_id": "5f5af20a78246674f529f3bb","referrer": "https://www.bmw.co.cr/es/ssl/solicitud-de-oferta.html","window_location_pathname": "/solicitud_cotizacion/","tipo_de_solicitud": "TDA","language": "es","formulario": "Solicitud de Cotización","job": "default","organization": "LATAM","brand": "BMW","tasks": {"task_1": {"email_adresses_list": "bmw_list_1","template": "default"},"task_dynamics": {"email_adresses_list": "dynamics_emails_list","template": "solicitud_cotizacion"},"task_track": {"event": "Lead Generation"}},"userAgent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/85.0.4183.83 Safari/537.36","F": "3","distribuidor": null,"referrer_param": null,"origen_param": "http://www.bmw.co.cr","aviso_privacidad": true,"origen": "http://www.bmw.co.cr","ciudad": "San Jose","configurator_modelRange": "${urlParameter.modelRange}","configurator_agCode": "${urlParameter.agCode}","configurator_configUrl": null,"configurator_series": null,"configurator_bodyType": "${urlParameter.bodyType}","configurator_vgCode": "${urlParameter.vgCode}","configurator_totalprice": "${urlParameter.totalprice}","configurator_options": "${urlParameter.options}","param_dealer": null,"modelo_interes": {"familia": "Serie 3","modelo": "BMW Serie 3 Sedán","modelRange": "G20","versiones": [{"agCode": "5F31","motorizacion": "320i"},{"agCode": "5R11","motorizacion": "330i"}],"catalogo_nombre": "catálogo","catalogo_link": "cocrBMW_G","ruta_showroom": ["",""],"brand": "BMW","tipo": ["Sedán"]},"campaign_name": null,"campaign_model": null,"campaign_source": null,"label_tel": "Teléfono","tipo_telefono": "Móvil","version_interes": {"agCode": "10000","motorizacion": "320i"},"local": "Escazú","saludo": "Sr.","nombre": "TeteMArioIncompany","apellido": "TeteMArioIncompany","email": "mario@incompany.cr","telefono": "8913847","proxima_compra": "Antes de 3 meses.","controller": "leads-irc-controller.js","created_at": "2020-09-11T03:42:02.873Z","created_at_offset": 300,"domain": "bmw.co.cr","ip": "201.191.106.93","pais": "Costa Rica","job_started_at": "2020-09-11T03:42:05.471Z","job_status": "processing","configurator_options_arr": [{"code": "${urlParameter.options}","description": ""}]}';
        
        req.requestBody = Blob.valueOf(body);
        req.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req;
        RestContext.response = res; 
        
        Test.startTest();
        WsBMWIntegracion2.WsBMWIntegracion2();
        Test.stopTest();  
    }
    
    
         @isTest
    public static void Caso4(){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/TraficoBMW/'; 
        req.httpMethod = 'Post';
        String body ='{}';        
        req.requestBody = Blob.valueOf(body);
        req.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req;
        RestContext.response = res; 
        
        Test.startTest();
        WsBMWIntegracion2.WsBMWIntegracion2();
        Test.stopTest();  
    }
         @isTest
    public static void Caso5(){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/TraficoBMW/'; 
        req.httpMethod = 'Post';
        String body ='{"_id": "5f5af20a78246674f529f3bb","referrer": "https://www.bmw.co.cr/es/ssl/solicitud-de-oferta.html","window_location_pathname": "/solicitud_cotizacion/","tipo_de_solicitud": "TDA","language": "es","formulario": "Solicitud de Cotización","job": "default","organization": "LATAM","brand": "","tasks": {"task_1": {"email_adresses_list": "bmw_list_1","template": "default"},"task_dynamics": {"email_adresses_list": "dynamics_emails_list","template": "solicitud_cotizacion"},"task_track": {"event": "Lead Generation"}},"userAgent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/85.0.4183.83 Safari/537.36","F": "3","distribuidor": null,"referrer_param": null,"origen_param": "http://www.bmw.co.cr","aviso_privacidad": true,"origen": "http://www.bmw.co.cr","ciudad": "San Jose","configurator_modelRange": "${urlParameter.modelRange}","configurator_agCode": "${urlParameter.agCode}","configurator_configUrl": null,"configurator_series": null,"configurator_bodyType": "${urlParameter.bodyType}","configurator_vgCode": "${urlParameter.vgCode}","configurator_totalprice": "${urlParameter.totalprice}","configurator_options": "${urlParameter.options}","param_dealer": null,"modelo_interes": {"familia": "Serie 3","modelo": "BMW Serie 3 Sedán","modelRange": "G20","versiones": [{"agCode": "5F31","motorizacion": "320i"},{"agCode": "5R11","motorizacion": "330i"}],"catalogo_nombre": "catálogo","catalogo_link": "cocrBMW_G","ruta_showroom": ["",""],"brand": "BMW","tipo": ["Sedán"]},"campaign_name": null,"campaign_model": null,"campaign_source": null,"label_tel": "Teléfono","tipo_telefono": "Móvil","version_interes": {"agCode": "10000","motorizacion": "320i"},"local": "Escazú","saludo": "Sr.","nombre": "TeteMArioIncompany","apellido": "TeteMArioIncompany","email": "mario@incompany.cr","telefono": "8913847","proxima_compra": "Antes de 3 meses.","controller": "leads-irc-controller.js","created_at": "2020-09-11T03:42:02.873Z","created_at_offset": 300,"domain": "bmw.co.cr","ip": "201.191.106.93","pais": "Costa Rica","job_started_at": "2020-09-11T03:42:05.471Z","job_status": "processing","configurator_options_arr": [{"code": "${urlParameter.options}","description": ""}]}';
        
        req.requestBody = Blob.valueOf(body);
        req.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req;
        RestContext.response = res; 
        
        Test.startTest();
        WsBMWIntegracion2.WsBMWIntegracion2();
        Test.stopTest();  
    }
    
  @isTest
    public static void Caso6(){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/TraficoBMW/'; 
        req.httpMethod = 'Post';
        String body ='{"_id": "5f5af20a78246674f529f3bb","referrer": "https://www.bmw.co.cr/es/ssl/solicitud-de-oferta.html","window_location_pathname": "/solicitud_cotizacion/","tipo_de_solicitud": "","language": "es","formulario": "Solicitud de Cotización","job": "default","organization": "LATAM","brand": "BMW","tasks": {"task_1": {"email_adresses_list": "bmw_list_1","template": "default"},"task_dynamics": {"email_adresses_list": "dynamics_emails_list","template": "solicitud_cotizacion"},"task_track": {"event": "Lead Generation"}},"userAgent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/85.0.4183.83 Safari/537.36","F": "3","distribuidor": null,"referrer_param": null,"origen_param": "http://www.bmw.co.cr","aviso_privacidad": true,"origen": "http://www.bmw.co.cr","ciudad": "San Jose","configurator_modelRange": "${urlParameter.modelRange}","configurator_agCode": "${urlParameter.agCode}","configurator_configUrl": null,"configurator_series": null,"configurator_bodyType": "${urlParameter.bodyType}","configurator_vgCode": "${urlParameter.vgCode}","configurator_totalprice": "${urlParameter.totalprice}","configurator_options": "${urlParameter.options}","param_dealer": null,"modelo_interes": {"familia": "Serie 3","modelo": "BMW Serie 3 Sedán","modelRange": "G20","versiones": [{"agCode": "5F31","motorizacion": "320i"},{"agCode": "5R11","motorizacion": "330i"}],"catalogo_nombre": "catálogo","catalogo_link": "cocrBMW_G","ruta_showroom": ["",""],"brand": "BMW","tipo": ["Sedán"]},"campaign_name": null,"campaign_model": null,"campaign_source": null,"label_tel": "Teléfono","tipo_telefono": "Móvil","version_interes": {"agCode": "10000","motorizacion": "320i"},"local": "Escazú","saludo": "Sr.","nombre": "TeteMArioIncompany","apellido": "TeteMArioIncompany","email": "mario@incompany.cr","telefono": "8913847","proxima_compra": "Antes de 3 meses.","controller": "leads-irc-controller.js","created_at": "2020-09-11T03:42:02.873Z","created_at_offset": 300,"domain": "bmw.co.cr","ip": "201.191.106.93","pais": "Costa Rica","job_started_at": "2020-09-11T03:42:05.471Z","job_status": "processing","configurator_options_arr": [{"code": "${urlParameter.options}","description": ""}]}';
        
        req.requestBody = Blob.valueOf(body);
        req.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req;
        RestContext.response = res; 
        
        Test.startTest();
        WsBMWIntegracion2.WsBMWIntegracion2();
        Test.stopTest();  
    }
      @isTest
    public static void Caso7(){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/TraficoBMW/'; 
        req.httpMethod = 'Post';
       String body ='{"_id": "5f5af20a78246674f529f3bb","referrer": "https://www.bmw.co.cr/es/ssl/solicitud-de-oferta.html","window_location_pathname": "/solicitud_cotizacion/","tipo_de_solicitud": "RFO","language": "es","formulario": "Solicitud de Cotización","job": "default","organization": "LATAM","brand": "MINI","tasks": {"task_1": {"email_adresses_list": "bmw_list_1","template": "default"},"task_dynamics": {"email_adresses_list": "dynamics_emails_list","template": "solicitud_cotizacion"},"task_track": {"event": "Lead Generation"}},"userAgent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/85.0.4183.83 Safari/537.36","F": "3","distribuidor": null,"referrer_param": null,"origen_param": "http://www.bmw.co.cr","aviso_privacidad": true,"origen": "http://www.bmw.co.cr","ciudad": "San Jose","configurator_modelRange": "${urlParameter.modelRange}","configurator_agCode": "${urlParameter.agCode}","configurator_configUrl": null,"configurator_series": null,"configurator_bodyType": "${urlParameter.bodyType}","configurator_vgCode": "${urlParameter.vgCode}","configurator_totalprice": "${urlParameter.totalprice}","configurator_options": "${urlParameter.options}","param_dealer": null,"modelo_interes": {"familia": "Serie 3","modelo": "BMW Serie 3 Sedán","modelRange": "G20","versiones": [{"agCode": "5F31","motorizacion": "320i"},{"agCode": "5R11","motorizacion": "330i"}],"catalogo_nombre": "catálogo","catalogo_link": "cocrBMW_G","ruta_showroom": ["",""],"brand": "BMW","tipo": ["Sedán"]},"campaign_name": null,"campaign_model": null,"campaign_source": null,"label_tel": "Teléfono","tipo_telefono": "Móvil","version_interes": {"agCode": "10000","motorizacion": "320i"},"local": "Escazú","saludo": "Sr.","nombre": "TeteMArioIncompany","apellido": "TeteMArioIncompany","email": "mario@incompany.cr","telefono": "8913847","proxima_compra": "Antes de 3 meses.","controller": "leads-irc-controller.js","created_at": "2020-09-11T03:42:02.873Z","created_at_offset": 300,"domain": "bmw.co.cr","ip": "201.191.106.93","pais": "Costa Rica","job_started_at": "2020-09-11T03:42:05.471Z","job_status": "processing","configurator_options_arr": [{"code": "${urlParameter.options}","description": ""}]}';
        
        req.requestBody = Blob.valueOf(body);
        req.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req;
        RestContext.response = res; 
        
        Test.startTest();
        WsBMWIntegracion2.WsBMWIntegracion2();
        Test.stopTest();  
    }
    
          @isTest
    public static void Caso8(){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/TraficoBMW/'; 
        req.httpMethod = 'Post';
       String body ='{"_id": "5f5af20a78246674f529f3bb","referrer": "https://www.bmw.co.cr/es/ssl/solicitud-de-oferta.html","window_location_pathname": "/solicitud_cotizacion/","tipo_de_solicitud": "RFO","language": "es","formulario": "Solicitud de Cotización","job": "default","organization": "LATAM","brand": "Motorrad","tasks": {"task_1": {"email_adresses_list": "bmw_list_1","template": "default"},"task_dynamics": {"email_adresses_list": "dynamics_emails_list","template": "solicitud_cotizacion"},"task_track": {"event": "Lead Generation"}},"userAgent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/85.0.4183.83 Safari/537.36","F": "3","distribuidor": null,"referrer_param": null,"origen_param": "http://www.bmw.co.cr","aviso_privacidad": true,"origen": "http://www.bmw.co.cr","ciudad": "San Jose","configurator_modelRange": "${urlParameter.modelRange}","configurator_agCode": "${urlParameter.agCode}","configurator_configUrl": null,"configurator_series": null,"configurator_bodyType": "${urlParameter.bodyType}","configurator_vgCode": "${urlParameter.vgCode}","configurator_totalprice": "${urlParameter.totalprice}","configurator_options": "${urlParameter.options}","param_dealer": null,"modelo_interes": {"familia": "Serie 3","modelo": "BMW Serie 3 Sedán","modelRange": "G20","versiones": [{"agCode": "5F31","motorizacion": "320i"},{"agCode": "5R11","motorizacion": "330i"}],"catalogo_nombre": "catálogo","catalogo_link": "cocrBMW_G","ruta_showroom": ["",""],"brand": "BMW","tipo": ["Sedán"]},"campaign_name": null,"campaign_model": null,"campaign_source": null,"label_tel": "Teléfono","tipo_telefono": "Móvil","version_interes": {"agCode": "10000","motorizacion": "320i"},"local": "Escazú","saludo": "Sr.","nombre": "TeteMArioIncompany","apellido": "TeteMArioIncompany","email": "mario@incompany.cr","telefono": "8913847","proxima_compra": "Antes de 3 meses.","controller": "leads-irc-controller.js","created_at": "2020-09-11T03:42:02.873Z","created_at_offset": 300,"domain": "bmw.co.cr","ip": "201.191.106.93","pais": "Costa Rica","job_started_at": "2020-09-11T03:42:05.471Z","job_status": "processing","configurator_options_arr": [{"code": "${urlParameter.options}","description": ""}]}';
        
        req.requestBody = Blob.valueOf(body);
        req.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req;
        RestContext.response = res; 
        
        Test.startTest();
        WsBMWIntegracion2.WsBMWIntegracion2();
        Test.stopTest();  
    }
    
    
      @isTest
    public static void Caso9(){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/TraficoBMW/'; 
        req.httpMethod = 'Post';
       String body ='{"_id": "5f5af20a78246674f529f3bb","referrer": "https://www.bmw.co.cr/es/ssl/solicitud-de-oferta.html","window_location_pathname": "/solicitud_cotizacion/","tipo_de_solicitud": "RFO","language": "es","formulario": "Solicitud de Cotización","job": "default","organization": "LATAM","brand": "BMW","tasks": {"task_1": {"email_adresses_list": "bmw_list_1","template": "default"},"task_dynamics": {"email_adresses_list": "dynamics_emails_list","template": "solicitud_cotizacion"},"task_track": {"event": "Lead Generation"}},"userAgent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/85.0.4183.83 Safari/537.36","F": "3","distribuidor": null,"referrer_param": null,"origen_param": "http://www.bmw.co.cr","aviso_privacidad": true,"origen": "http://www.bmw.co.cr","ciudad": "San Jose","configurator_modelRange": "${urlParameter.modelRange}","configurator_agCode": "${urlParameter.agCode}","configurator_configUrl": null,"configurator_series": null,"configurator_bodyType": "${urlParameter.bodyType}","configurator_vgCode": "${urlParameter.vgCode}","configurator_totalprice": "${urlParameter.totalprice}","configurator_options": "${urlParameter.options}","param_dealer": null,"modelo_interes": {"familia": "Serie 3","modelo": "BMW Serie 3 Sedán","modelRange": "G20","versiones": [{"agCode": "5F31","motorizacion": "320i"},{"agCode": "5R11","motorizacion": "330i"}],"catalogo_nombre": "catálogo","catalogo_link": "cocrBMW_G","ruta_showroom": ["",""],"brand": "BMW","tipo": ["Sedán"]},"campaign_name": null,"campaign_model": null,"campaign_source": null,"label_tel": "Teléfono","tipo_telefono": "Móvil","version_interes": {"agCode": "100x00","motorizacion": "320i"},"local": "Escazú","saludo": "Sr.","nombre": "TeteMArioIncompany","apellido": "TeteMArioIncompany","email": "mario@incompany.cr","telefono": "8913847","proxima_compra": "Antes de 3 meses.","controller": "leads-irc-controller.js","created_at": "2020-09-11T03:42:02.873Z","created_at_offset": 300,"domain": "bmw.co.cr","ip": "201.191.106.93","pais": "Costa Rica","job_started_at": "2020-09-11T03:42:05.471Z","job_status": "processing","configurator_options_arr": [{"code": "${urlParameter.options}","description": ""}]}';
        
        req.requestBody = Blob.valueOf(body);
        req.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req;
        RestContext.response = res; 
        
        Test.startTest();
        WsBMWIntegracion2.WsBMWIntegracion2();
        Test.stopTest();  
    }
    
 	@isTest
    public static void Caso10(){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/TraficoBMW/'; 
        req.httpMethod = 'Post';
        String body ='{"_id": "64adb05853e5381782712414","referrer": "https://www.bmw.co.cr/es/ssl/solicitud-de-oferta.html","window_location_pathname": "/solicitud_cotizacion/","tipo_de_solicitud": "RFO","language": "es","formulario": "Solicitud de Cotización","job": "default","organization": "LATAM","brand": "BMW","tasks": {"task_1": {"email_adresses_list": "bmw_list_1","template": "default"},"task_dynamics": {"email_adresses_list": "dynamics_emails_list","template": "solicitud_cotizacion"},"task_track": {"event": "Lead Generation"}},"userAgent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/85.0.4183.83 Safari/537.36","F": "3","distribuidor": null,"referrer_param": null,"origen_param": "http://www.bmw.co.cr","aviso_privacidad": true,"origen": "http://www.bmw.co.cr","ciudad": "San Jose","configurator_modelRange": "${urlParameter.modelRange}","configurator_agCode": "${urlParameter.agCode}","configurator_configUrl": null,"configurator_series": null,"configurator_bodyType": "${urlParameter.bodyType}","configurator_vgCode": "${urlParameter.vgCode}","configurator_totalprice": "${urlParameter.totalprice}","configurator_options": "${urlParameter.options}","param_dealer": null,"modelo_interes": {"familia": "Serie 3","modelo": "BMW Serie 3 Sedán","modelRange": "G20","versiones": [{"agCode": "5F31","motorizacion": "320i"},{"agCode": "5R11","motorizacion": "330i"}],"catalogo_nombre": "catálogo","catalogo_link": "cocrBMW_G","ruta_showroom": ["",""],"brand": "BMW","tipo": ["Sedán"]},"campaign_name": null,"campaign_model": null,"campaign_source": null,"label_tel": "Teléfono","tipo_telefono": "Móvil","version_interes": {"agCode": "10000","motorizacion": "320i"},"local": "Escazú","saludo": "Sr.","nombre": "TeteMArioIncompany","apellido": "TeteMArioIncompany","email": "mario@incompany.cr","telefono": "8913847","proxima_compra": "","controller": "leads-irc-controller.js","created_at": "2020-09-11T03:42:02.873Z","created_at_offset": 300,"domain": "bmw.co.cr","ip": "201.191.106.93","pais": "Costa Rica","job_started_at": "2020-09-11T03:42:05.471Z","job_status": "processing","configurator_options_arr": [{"code": "${urlParameter.options}","description": ""}]}';
        
        req.requestBody = Blob.valueOf(body);
        req.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req;
        RestContext.response = res; 
        
        Test.startTest();
        WsBMWIntegracion2.WsBMWIntegracion2();
        Test.stopTest();  
    }
    
}