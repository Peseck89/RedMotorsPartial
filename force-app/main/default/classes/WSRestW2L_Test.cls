/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest

//https://developer.salesforce.com/forums/?id=9060G000000XdDoQAK

private class WSRestW2L_Test {

    static Integer iTotReg = 1;
    static Product2 productoTestF15;

    static {

        TestDataFactory.datosGenerales();

        productoTestF15 = new Product2(

            Name='BM56 - X5 - 25d PREMIUM SMART',
            Codigo_Info__c='F15',
            ProductCode = 'BM56',
            Marca__c = 'BMW',
            Codigo_de_Producto__c = 'BM56'
        );
        insert productoTestF15;

    }

    static testMethod void NoSucursal() {

        String JsonMsg = '{ "_id" : "59a6dea1ab9303ca19bd23ef","referrer" : "https://www.bmw.co.cr/es/ssl/solicitud-de-catalogo.html","window_location_pathname" : "/solicitud_catalogo/","tipo_de_solicitud" : "RFI","language" : "es","formulario" : "Solicitud de Catálogo","job" : "default","organization" : "LATAM","brand" : "BMW","tasks" : {"task_1" : {"email_adresses_list" : "bmw_list_1","template" : "default"},"task_dynamics" : {"email_adresses_list" : "dynamics_emails_list","template" : "solicitud_catalogo"},"task_track" : {"event" : "Lead Generation"}},"aviso_privacidad" : true,"distribuidor" : null,"referrer_param" : null,"origen_param" : "http://www.bmw.co.cr","origen" : "http://www.bmw.co.cr","ciudad" : "San Jose","configurator_modelRange" : "${urlParameter.modelRange}","configurator_agCode" : null,"configurator_configUrl" : null,"configurator_series" : null,"configurator_bodyType" : null,"configurator_vgCode" : null,"configurator_totalprice" : null,"configurator_options" : null,"modelo_interes" : {"modelo" : "BMW X5","modelRange" : "F15","versiones" :[{"agCode" :"KR01","motorizacion" :"X5 xDrive35i"},{"agCode" :"KR61","motorizacion" :"X5 xDrive50i"},{"agCode" :"KT41","motorizacion" :"X5 sDrive25d"},{"agCode" :"KS41","motorizacion" :"X5 xDrive30d"}],"catalogo_nombre" : "catálogo","catalogo_link" : "http://www.bmw.com.mx/content/dam/bmw/marketMX/bmw_com_mx/Descargas/ModelosX/X5-2013/Catalogo_BMW_X5_ESP.pdf.asset.0.pdf","ruta_showroom" :[    "",    ""   ],"brand" : "BMW"},"campaign_name" : null,"campaign_model" : null,"campaign_source" : null,"local" : "","saludo" : "Sr.","nombre" : "RFI","apellido" : "BMW4","email" : "saraya.olmos@gmail.com","telefono" : "","tipo_telefono" : "","proxima_compra" : "Antes de 3 meses.","controller" : "leads-controller.js","created_at" : "2017-08-30T15:49:53.617Z","created_at_offset" : 300,"domain" : "bmw.co.cr","pais" : "Costa Rica","job_status" : "processing","job_started_at" : "2017-08-30T15:49:55.513Z"}';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/TraficoRM/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JsonMsg);

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        WSRestW2L.responseWrapper results = WSRestW2L.crearTraficoPost();
        Test.stopTest();
    }


    static testMethod void NoProximaCompra() {

        String JsonMsg = '{ "_id" : "59a6dea1ab9303ca19bd23ef","referrer" : "https://www.bmw.co.cr/es/ssl/solicitud-de-catalogo.html","window_location_pathname" : "/solicitud_catalogo/","tipo_de_solicitud" : "RFI","language" : "es","formulario" : "Solicitud de Catálogo","job" : "default","organization" : "LATAM","brand" : "BMW","tasks" : {"task_1" : {"email_adresses_list" : "bmw_list_1","template" : "default"},"task_dynamics" : {"email_adresses_list" : "dynamics_emails_list","template" : "solicitud_catalogo"},"task_track" : {"event" : "Lead Generation"}},"aviso_privacidad" : true,"distribuidor" : null,"referrer_param" : null,"origen_param" : "http://www.bmw.co.cr","origen" : "http://www.bmw.co.cr","ciudad" : "San Jose","configurator_modelRange" : "${urlParameter.modelRange}","configurator_agCode" : null,"configurator_configUrl" : null,"configurator_series" : null,"configurator_bodyType" : null,"configurator_vgCode" : null,"configurator_totalprice" : null,"configurator_options" : null,"modelo_interes" : {"modelo" : "BMW X5","modelRange" : "F15","versiones" :[{"agCode" :"KR01","motorizacion" :"X5 xDrive35i"},{"agCode" :"KR61","motorizacion" :"X5 xDrive50i"},{"agCode" :"KT41","motorizacion" :"X5 sDrive25d"},{"agCode" :"KS41","motorizacion" :"X5 xDrive30d"}],"catalogo_nombre" : "catálogo","catalogo_link" : "http://www.bmw.com.mx/content/dam/bmw/marketMX/bmw_com_mx/Descargas/ModelosX/X5-2013/Catalogo_BMW_X5_ESP.pdf.asset.0.pdf","ruta_showroom" :[    "",    ""   ],"brand" : "BMW"},"campaign_name" : null,"campaign_model" : null,"campaign_source" : null,"local" : "Pinares","saludo" : "Sr.","nombre" : "RFI","apellido" : "BMW4","email" : "saraya.olmos@gmail.com","telefono" : "","tipo_telefono" : "","proxima_compra" : "","controller" : "leads-controller.js","created_at" : "2017-08-30T15:49:53.617Z","created_at_offset" : 300,"domain" : "bmw.co.cr","pais" : "Costa Rica","job_status" : "processing","job_started_at" : "2017-08-30T15:49:55.513Z"}';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/TraficoRM/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JsonMsg);

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        WSRestW2L.responseWrapper results = WSRestW2L.crearTraficoPost();
        Test.stopTest();
    }

    static testMethod void NoProducto() {

        String JsonMsg = '{ "_id" : "59a6dea1ab9303ca19bd23ef","referrer" : "https://www.bmw.co.cr/es/ssl/solicitud-de-catalogo.html","window_location_pathname" : "/solicitud_catalogo/","tipo_de_solicitud" : "RFI","language" : "es","formulario" : "Solicitud de Catálogo","job" : "default","organization" : "LATAM","brand" : "BMW","tasks" : {"task_1" : {"email_adresses_list" : "bmw_list_1","template" : "default"},"task_dynamics" : {"email_adresses_list" : "dynamics_emails_list","template" : "solicitud_catalogo"},"task_track" : {"event" : "Lead Generation"}},"aviso_privacidad" : true,"distribuidor" : null,"referrer_param" : null,"origen_param" : "http://www.bmw.co.cr","origen" : "http://www.bmw.co.cr","ciudad" : "San Jose","configurator_modelRange" : "${urlParameter.modelRange}","configurator_agCode" : null,"configurator_configUrl" : null,"configurator_series" : null,"configurator_bodyType" : null,"configurator_vgCode" : null,"configurator_totalprice" : null,"configurator_options" : null,"modelo_interes" : {"modelo" : "BMW X5","modelRange" : "F1500","versiones" :[{"agCode" :"KR01","motorizacion" :"X5 xDrive35i"},{"agCode" :"KR61","motorizacion" :"X5 xDrive50i"},{"agCode" :"KT41","motorizacion" :"X5 sDrive25d"},{"agCode" :"KS41","motorizacion" :"X5 xDrive30d"}],"catalogo_nombre" : "catálogo","catalogo_link" : "http://www.bmw.com.mx/content/dam/bmw/marketMX/bmw_com_mx/Descargas/ModelosX/X5-2013/Catalogo_BMW_X5_ESP.pdf.asset.0.pdf","ruta_showroom" :[    "",    ""   ],"brand" : "BMW"},"campaign_name" : null,"campaign_model" : null,"campaign_source" : null,"local" : "Pinares","saludo" : "Sr.","nombre" : "RFI","apellido" : "BMW4","email" : "saraya.olmos@gmail.com","telefono" : "","tipo_telefono" : "","proxima_compra" : "Antes de 3 meses.","controller" : "leads-controller.js","created_at" : "2017-08-30T15:49:53.617Z","created_at_offset" : 300,"domain" : "bmw.co.cr","pais" : "Costa Rica","job_status" : "processing","job_started_at" : "2017-08-30T15:49:55.513Z"}';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/TraficoRM/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JsonMsg);

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        WSRestW2L.responseWrapper results = WSRestW2L.crearTraficoPost();
        Test.stopTest();
    }

    static testMethod void NoTDABMW() {

        String JsonMsg = '{ "_id" : "59a6dea1ab9303ca19bd23ef","referrer" : "https://www.bmw.co.cr/es/ssl/solicitud-de-catalogo.html","window_location_pathname" : "/solicitud_catalogo/","tipo_de_solicitud" : "RFI","language" : "es","formulario" : "Solicitud de Catálogo","job" : "default","organization" : "LATAM","brand" : "BMW","tasks" : {"task_1" : {"email_adresses_list" : "bmw_list_1","template" : "default"},"task_dynamics" : {"email_adresses_list" : "dynamics_emails_list","template" : "solicitud_catalogo"},"task_track" : {"event" : "Lead Generation"}},"aviso_privacidad" : true,"distribuidor" : null,"referrer_param" : null,"origen_param" : "http://www.bmw.co.cr","origen" : "http://www.bmw.co.cr","ciudad" : "San Jose","configurator_modelRange" : "${urlParameter.modelRange}","configurator_agCode" : null,"configurator_configUrl" : null,"configurator_series" : null,"configurator_bodyType" : null,"configurator_vgCode" : null,"configurator_totalprice" : null,"configurator_options" : null,"modelo_interes" : {"modelo" : "BMW X5","modelRange" : "F15","versiones" :[{"agCode" :"KR01","motorizacion" :"X5 xDrive35i"},{"agCode" :"KR61","motorizacion" :"X5 xDrive50i"},{"agCode" :"KT41","motorizacion" :"X5 sDrive25d"},{"agCode" :"KS41","motorizacion" :"X5 xDrive30d"}],"catalogo_nombre" : "catálogo","catalogo_link" : "http://www.bmw.com.mx/content/dam/bmw/marketMX/bmw_com_mx/Descargas/ModelosX/X5-2013/Catalogo_BMW_X5_ESP.pdf.asset.0.pdf","ruta_showroom" :[    "",    ""   ],"brand" : "BMW"},"campaign_name" : null,"campaign_model" : null,"campaign_source" : null,"local" : "Pinares","saludo" : "Sr.","nombre" : "RFI","apellido" : "BMW4","email" : "saraya.olmos@gmail.com","telefono" : "","tipo_telefono" : "","proxima_compra" : "Antes de 3 meses.","controller" : "leads-controller.js","created_at" : "2017-08-30T15:49:53.617Z","created_at_offset" : 300,"domain" : "bmw.co.cr","pais" : "Costa Rica","job_status" : "processing","job_started_at" : "2017-08-30T15:49:55.513Z"}';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/TraficoRM/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JsonMsg);

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        WSRestW2L.responseWrapper results = WSRestW2L.crearTraficoPost();
        Test.stopTest();
    }


    static testMethod void NoBody() {

        String JsonMsg = '{}';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/TraficoRM/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JsonMsg);

        //RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        WSRestW2L.responseWrapper results = WSRestW2L.crearTraficoPost();
        Test.stopTest();
    }


    static testMethod void NoBrand() {

        String JsonMsg = '{ "_id" : "59a6dea1ab9303ca19bd23ef","referrer" : "https://www.bmw.co.cr/es/ssl/solicitud-de-catalogo.html","window_location_pathname" : "/solicitud_catalogo/","tipo_de_solicitud" : "RFI","language" : "es","formulario" : "Solicitud de Catálogo","job" : "default","organization" : "LATAM","tasks" : {"task_1" : {"email_adresses_list" : "bmw_list_1","template" : "default"},"task_dynamics" : {"email_adresses_list" : "dynamics_emails_list","template" : "solicitud_catalogo"},"task_track" : {"event" : "Lead Generation"}},"aviso_privacidad" : true,"distribuidor" : null,"referrer_param" : null,"origen_param" : "http://www.bmw.co.cr","origen" : "http://www.bmw.co.cr","ciudad" : "San Jose","configurator_modelRange" : "${urlParameter.modelRange}","configurator_agCode" : null,"configurator_configUrl" : null,"configurator_series" : null,"configurator_bodyType" : null,"configurator_vgCode" : null,"configurator_totalprice" : null,"configurator_options" : null,"modelo_interes" : {"modelo" : "BMW X5","modelRange" : "F1500","versiones" :[{"agCode" :"KR01","motorizacion" :"X5 xDrive35i"},{"agCode" :"KR61","motorizacion" :"X5 xDrive50i"},{"agCode" :"KT41","motorizacion" :"X5 sDrive25d"},{"agCode" :"KS41","motorizacion" :"X5 xDrive30d"}],"catalogo_nombre" : "catálogo","catalogo_link" : "http://www.bmw.com.mx/content/dam/bmw/marketMX/bmw_com_mx/Descargas/ModelosX/X5-2013/Catalogo_BMW_X5_ESP.pdf.asset.0.pdf","ruta_showroom" :[    "",    ""   ],"brand" : "BMW"},"campaign_name" : null,"campaign_model" : null,"campaign_source" : null,"local" : "Pinares","saludo" : "Sr.","nombre" : "RFI","apellido" : "BMW4","email" : "saraya.olmos@gmail.com","telefono" : "","tipo_telefono" : "","proxima_compra" : "Antes de 3 meses.","controller" : "leads-controller.js","created_at" : "2017-08-30T15:49:53.617Z","created_at_offset" : 300,"domain" : "bmw.co.cr","pais" : "Costa Rica","job_status" : "processing","job_started_at" : "2017-08-30T15:49:55.513Z"}';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/TraficoRM/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JsonMsg);

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        WSRestW2L.responseWrapper results = WSRestW2L.crearTraficoPost();
        Test.stopTest();
    }


    static testMethod void BmwNoModelRange() {

        String JsonMsg = '{ "_id" : "59a6dea1ab9303ca19bd23ef","referrer" : "https://www.bmw.co.cr/es/ssl/solicitud-de-catalogo.html","window_location_pathname" : "/solicitud_catalogo/","tipo_de_solicitud" : "RFI","language" : "es","formulario" : "Solicitud de Catálogo","job" : "default","organization" : "LATAM","brand" : "BMW","tasks" : {"task_1" : {"email_adresses_list" : "bmw_list_1","template" : "default"},"task_dynamics" : {"email_adresses_list" : "dynamics_emails_list","template" : "solicitud_catalogo"},"task_track" : {"event" : "Lead Generation"}},"aviso_privacidad" : true,"distribuidor" : null,"referrer_param" : null,"origen_param" : "http://www.bmw.co.cr","origen" : "http://www.bmw.co.cr","ciudad" : "San Jose","configurator_modelRange" : "${urlParameter.modelRange}","configurator_agCode" : null,"configurator_configUrl" : null,"configurator_series" : null,"configurator_bodyType" : null,"configurator_vgCode" : null,"configurator_totalprice" : null,"configurator_options" : null,"modelo_interes" : {"modelo" : "BMW X5","versiones" :[{"agCode" :"KR01","motorizacion" :"X5 xDrive35i"},{"agCode" :"KR61","motorizacion" :"X5 xDrive50i"},{"agCode" :"KT41","motorizacion" :"X5 sDrive25d"},{"agCode" :"KS41","motorizacion" :"X5 xDrive30d"}],"catalogo_nombre" : "catálogo","catalogo_link" : "http://www.bmw.com.mx/content/dam/bmw/marketMX/bmw_com_mx/Descargas/ModelosX/X5-2013/Catalogo_BMW_X5_ESP.pdf.asset.0.pdf","ruta_showroom" :[    "",    ""   ],"brand" : "BMW"},"campaign_name" : null,"campaign_model" : null,"campaign_source" : null,"local" : "","saludo" : "Sr.","nombre" : "RFI","apellido" : "BMW4","email" : "saraya.olmos@gmail.com","telefono" : "","tipo_telefono" : "","proxima_compra" : "Antes de 3 meses.","controller" : "leads-controller.js","created_at" : "2017-08-30T15:49:53.617Z","created_at_offset" : 300,"domain" : "bmw.co.cr","pais" : "Costa Rica","job_status" : "processing","job_started_at" : "2017-08-30T15:49:55.513Z"}';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/TraficoRM/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JsonMsg);

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        WSRestW2L.responseWrapper results = WSRestW2L.crearTraficoPost();
        Test.stopTest();
    }

    static testMethod void ValorInvalidoTipoSolicitud() {

        String JsonMsg = '{ "_id" : "59a6dea1ab9303ca19bd23ef","referrer" : "https://www.bmw.co.cr/es/ssl/solicitud-de-catalogo.html","window_location_pathname" : "/solicitud_catalogo/","tipo_de_solicitud" : "RFIYXM","language" : "es","formulario" : "Solicitud de Catálogo","job" : "default","organization" : "LATAM","brand" : "BMW","tasks" : {"task_1" : {"email_adresses_list" : "bmw_list_1","template" : "default"},"task_dynamics" : {"email_adresses_list" : "dynamics_emails_list","template" : "solicitud_catalogo"},"task_track" : {"event" : "Lead Generation"}},"aviso_privacidad" : true,"distribuidor" : null,"referrer_param" : null,"origen_param" : "http://www.bmw.co.cr","origen" : "http://www.bmw.co.cr","ciudad" : "San Jose","configurator_modelRange" : "${urlParameter.modelRange}","configurator_agCode" : null,"configurator_configUrl" : null,"configurator_series" : null,"configurator_bodyType" : null,"configurator_vgCode" : null,"configurator_totalprice" : null,"configurator_options" : null,"modelo_interes" : {"modelo" : "BMW X5","modelRange" : "F15","versiones" :[{"agCode" :"KR01","motorizacion" :"X5 xDrive35i"},{"agCode" :"KR61","motorizacion" :"X5 xDrive50i"},{"agCode" :"KT41","motorizacion" :"X5 sDrive25d"},{"agCode" :"KS41","motorizacion" :"X5 xDrive30d"}],"catalogo_nombre" : "catálogo","catalogo_link" : "http://www.bmw.com.mx/content/dam/bmw/marketMX/bmw_com_mx/Descargas/ModelosX/X5-2013/Catalogo_BMW_X5_ESP.pdf.asset.0.pdf","ruta_showroom" :[    "",    ""   ],"brand" : "BMW"},"campaign_name" : null,"campaign_model" : null,"campaign_source" : null,"local" : "","saludo" : "Sr.","nombre" : "RFI","apellido" : "BMW4","email" : "saraya.olmos@gmail.com","telefono" : "","tipo_telefono" : "","proxima_compra" : "Antes de 3 meses.","controller" : "leads-controller.js","created_at" : "2017-08-30T15:49:53.617Z","created_at_offset" : 300,"domain" : "bmw.co.cr","pais" : "Costa Rica","job_status" : "processing","job_started_at" : "2017-08-30T15:49:55.513Z"}';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/TraficoRM/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JsonMsg);

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        WSRestW2L.responseWrapper results = WSRestW2L.crearTraficoPost();
        Test.stopTest();
    }

    static testMethod void ValorNuloTipoSolicitud() {

        String JsonMsg = '{ "_id" : "59a6dea1ab9303ca19bd23ef","referrer" : "https://www.bmw.co.cr/es/ssl/solicitud-de-catalogo.html","window_location_pathname" : "/solicitud_catalogo/","language" : "es","formulario" : "Solicitud de Catálogo","job" : "default","organization" : "LATAM","brand" : "BMW","tasks" : {"task_1" : {"email_adresses_list" : "bmw_list_1","template" : "default"},"task_dynamics" : {"email_adresses_list" : "dynamics_emails_list","template" : "solicitud_catalogo"},"task_track" : {"event" : "Lead Generation"}},"aviso_privacidad" : true,"distribuidor" : null,"referrer_param" : null,"origen_param" : "http://www.bmw.co.cr","origen" : "http://www.bmw.co.cr","ciudad" : "San Jose","configurator_modelRange" : "${urlParameter.modelRange}","configurator_agCode" : null,"configurator_configUrl" : null,"configurator_series" : null,"configurator_bodyType" : null,"configurator_vgCode" : null,"configurator_totalprice" : null,"configurator_options" : null,"modelo_interes" : {"modelo" : "BMW X5","modelRange" : "F15","versiones" :[{"agCode" :"KR01","motorizacion" :"X5 xDrive35i"},{"agCode" :"KR61","motorizacion" :"X5 xDrive50i"},{"agCode" :"KT41","motorizacion" :"X5 sDrive25d"},{"agCode" :"KS41","motorizacion" :"X5 xDrive30d"}],"catalogo_nombre" : "catálogo","catalogo_link" : "http://www.bmw.com.mx/content/dam/bmw/marketMX/bmw_com_mx/Descargas/ModelosX/X5-2013/Catalogo_BMW_X5_ESP.pdf.asset.0.pdf","ruta_showroom" :[    "",    ""   ],"brand" : "BMW"},"campaign_name" : null,"campaign_model" : null,"campaign_source" : null,"local" : "","saludo" : "Sr.","nombre" : "RFI","apellido" : "BMW4","email" : "saraya.olmos@gmail.com","telefono" : "","tipo_telefono" : "","proxima_compra" : "Antes de 3 meses.","controller" : "leads-controller.js","created_at" : "2017-08-30T15:49:53.617Z","created_at_offset" : 300,"domain" : "bmw.co.cr","pais" : "Costa Rica","job_status" : "processing","job_started_at" : "2017-08-30T15:49:55.513Z"}';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/TraficoRM/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JsonMsg);

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        WSRestW2L.responseWrapper results = WSRestW2L.crearTraficoPost();
        Test.stopTest();
    }


    static testMethod void FechaCompra3A6Meses() {

        String JsonMsg = '{ "_id" : "59a6dea1ab9303ca19bd23ef","referrer" : "https://www.bmw.co.cr/es/ssl/solicitud-de-catalogo.html","window_location_pathname" : "/solicitud_catalogo/","tipo_de_solicitud" : "RFI","language" : "es","formulario" : "Solicitud de Catálogo","job" : "default","organization" : "LATAM","brand" : "BMW","tasks" : {"task_1" : {"email_adresses_list" : "bmw_list_1","template" : "default"},"task_dynamics" : {"email_adresses_list" : "dynamics_emails_list","template" : "solicitud_catalogo"},"task_track" : {"event" : "Lead Generation"}},"aviso_privacidad" : true,"distribuidor" : null,"referrer_param" : null,"origen_param" : "http://www.bmw.co.cr","origen" : "http://www.bmw.co.cr","ciudad" : "San Jose","configurator_modelRange" : "${urlParameter.modelRange}","configurator_agCode" : null,"configurator_configUrl" : null,"configurator_series" : null,"configurator_bodyType" : null,"configurator_vgCode" : null,"configurator_totalprice" : null,"configurator_options" : null,"modelo_interes" : {"modelo" : "BMW X5","modelRange" : "F15","versiones" :[{"agCode" :"KR01","motorizacion" :"X5 xDrive35i"},{"agCode" :"KR61","motorizacion" :"X5 xDrive50i"},{"agCode" :"KT41","motorizacion" :"X5 sDrive25d"},{"agCode" :"KS41","motorizacion" :"X5 xDrive30d"}],"catalogo_nombre" : "catálogo","catalogo_link" : "http://www.bmw.com.mx/content/dam/bmw/marketMX/bmw_com_mx/Descargas/ModelosX/X5-2013/Catalogo_BMW_X5_ESP.pdf.asset.0.pdf","ruta_showroom" :[    "",    ""   ],"brand" : "BMW"},"campaign_name" : null,"campaign_model" : null,"campaign_source" : null,"local" : "Pinares","saludo" : "Sr.","nombre" : "RFI","apellido" : "BMW4","email" : "saraya.olmos@gmail.com","telefono" : "","tipo_telefono" : "","proxima_compra" : "De 3 a 6 meses.","controller" : "leads-controller.js","created_at" : "2017-08-30T15:49:53.617Z","created_at_offset" : 300,"domain" : "bmw.co.cr","pais" : "Costa Rica","job_status" : "processing","job_started_at" : "2017-08-30T15:49:55.513Z"}';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/TraficoRM/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JsonMsg);

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        WSRestW2L.responseWrapper results = WSRestW2L.crearTraficoPost();
        Test.stopTest();
    }

    static testMethod void FechaCompraDespues6Meses() {

        String JsonMsg = '{ "_id" : "59a6dea1ab9303ca19bd23ef","referrer" : "https://www.bmw.co.cr/es/ssl/solicitud-de-catalogo.html","window_location_pathname" : "/solicitud_catalogo/","tipo_de_solicitud" : "RFI","language" : "es","formulario" : "Solicitud de Catálogo","job" : "default","organization" : "LATAM","brand" : "BMW","tasks" : {"task_1" : {"email_adresses_list" : "bmw_list_1","template" : "default"},"task_dynamics" : {"email_adresses_list" : "dynamics_emails_list","template" : "solicitud_catalogo"},"task_track" : {"event" : "Lead Generation"}},"aviso_privacidad" : true,"distribuidor" : null,"referrer_param" : null,"origen_param" : "http://www.bmw.co.cr","origen" : "http://www.bmw.co.cr","ciudad" : "San Jose","configurator_modelRange" : "${urlParameter.modelRange}","configurator_agCode" : null,"configurator_configUrl" : null,"configurator_series" : null,"configurator_bodyType" : null,"configurator_vgCode" : null,"configurator_totalprice" : null,"configurator_options" : null,"modelo_interes" : {"modelo" : "BMW X5","modelRange" : "F15","versiones" :[{"agCode" :"KR01","motorizacion" :"X5 xDrive35i"},{"agCode" :"KR61","motorizacion" :"X5 xDrive50i"},{"agCode" :"KT41","motorizacion" :"X5 sDrive25d"},{"agCode" :"KS41","motorizacion" :"X5 xDrive30d"}],"catalogo_nombre" : "catálogo","catalogo_link" : "http://www.bmw.com.mx/content/dam/bmw/marketMX/bmw_com_mx/Descargas/ModelosX/X5-2013/Catalogo_BMW_X5_ESP.pdf.asset.0.pdf","ruta_showroom" :[    "",    ""   ],"brand" : "BMW"},"campaign_name" : null,"campaign_model" : null,"campaign_source" : null,"local" : "Pinares","saludo" : "Sr.","nombre" : "RFI","apellido" : "BMW4","email" : "saraya.olmos@gmail.com","telefono" : "","tipo_telefono" : "","proxima_compra" : "Después de 6 meses.","controller" : "leads-controller.js","created_at" : "2017-08-30T15:49:53.617Z","created_at_offset" : 300,"domain" : "bmw.co.cr","pais" : "Costa Rica","job_status" : "processing","job_started_at" : "2017-08-30T15:49:55.513Z"}';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/TraficoRM/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JsonMsg);

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        WSRestW2L.responseWrapper results = WSRestW2L.crearTraficoPost();
        system.debug('--Lead--'+[select Id,Modelo_De_Inter_s1__c from Lead]);
        Test.stopTest();
    }

}