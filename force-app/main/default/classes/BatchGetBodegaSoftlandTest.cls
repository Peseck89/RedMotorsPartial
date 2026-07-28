@isTest
public class BatchGetBodegaSoftlandTest {
    
    @isTest
    static void testBatchGetBodegaSoftland() {
        Bodega__c bodegaExistente = new Bodega__c(
            Name                 = 'Registro Test',
            bodega__c            = 'BOD001',
            ID_EXTERNO_BODEGA__c = 'BOD001'
        );
        insert bodegaExistente;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        System.enqueueJob(new BatchGetBodegaSoftland('companyTest'));
        Test.stopTest();
        
        List<Bodega__c> resultados = [
            SELECT Id, Name, bodega__c 
            FROM Bodega__c 
            WHERE bodega__c = 'BOD001'
        ];
        
        System.assertEquals(1, resultados.size());
        System.assertEquals('BOD001', resultados[0].bodega__c);
    }
    
    public class ExampleCalloutMock implements HttpCalloutMock {
        public HttpResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');
            res.setStatusCode(200);
            
            String endpoint = req.getEndpoint();
            
            if (endpoint != null && endpoint.containsIgnoreCase('oauth/token')) {
                res.setBody('{"access_token":"token","token_type":"Bearer"}');
            } else {
                res.setBody('{"Paging":{"TotalThisViewCount":1,"TotalRecordCount":1,"PageSize":1,"PageNo":1,"PageCount":1},"Data":[{"codigo":"AC001","descripcion":"Registro Test","cliente":"ASEG001","nombre":"Aseguradora Test","alias":"ASEG","contacto":"Contacto","cargo":"Cargo","id":"123456","moneda":"CRC","condicionPago":"test","pais":null,"provincia":null,"canton":null,"distrito":null,"barrio":null,"otras_senas":"Direccion Test","telefono1":"22222222","telefono2":"22222223","bodega":"BOD001","categoriaCliente":"test","centroCosto":"CC001","CuentaContable":"CTA001","impuesto":"1","codigoImpuesto":"IMP001","subtipo":"SUB001","articulo":"ART001","cant_disponible":"1","precio":"1","porc_descuento":"1","costo_local":"1","porc_margen_min":"1","porc_margen_max":"1","lista_precio":"LP","grupo1":"G1","cod_grupo1":"G1","grupo2":"G2","cod_grupo2":"G2","grupo3":"G3","cod_grupo3":"G3","grupo4":"G4","cod_grupo4":"G4","grupo5":"G5","cod_grupo5":"G5","grupo6":"G6","cod_grupo6":"G6","vin":"VIN001"}]}');
            }
            return res;
        }
    }
}