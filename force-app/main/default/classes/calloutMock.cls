@isTest
public class calloutMock{
    public class controllerBusquedaReciboUsadoMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse resp = new HttpResponse();
            resp.setHeader('Content-Type', 'application/json');
            resp.setBody('{"code":"00","description":"0.0","descriptionDollar":"0"}');
            resp.setStatusCode(200);
            return resp;
        }
    }
    
    public class controllerBusquedaReciboUsadoMockInnerElse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse resp = new HttpResponse();
            resp.setHeader('Content-Type', 'application/json');
            resp.setBody('{"code":"00","description":"4.0","descriptionDollar":"8.0"}');
            resp.setStatusCode(200);
            return resp;
        }
    }
    
    public class controllerBusquedaReciboUsadoMockOuterElse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse resp = new HttpResponse();
            resp.setHeader('Content-Type', 'application/json');
            resp.setBody('{"code":"01","description":"0.0","descriptionDollar":"0"}');
            resp.setStatusCode(200);
            return resp;
        }
    }
    
    public class controllerBusquedaReciboUsadoMockCatchBlock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            CalloutException e = (CalloutException)CalloutException.class.newInstance();
            e.setMessage('Unauthorized endpoint, please check Setup->Security->Remote site settings.');
            throw e;
        }
    }
    
    public class controllerBusquedaReciboUsadoMockGetAPIValues implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse resp = new HttpResponse();
            resp.setHeader('Content-Type', 'application/json');
            resp.setBody('{"recibos":[{"recibido":"2550000.000000","marca":"ACURA","modelo":"1995","linea":" INTEGRA","combustible":"Gasolina","transmision":"Automatica/Dual" ,"estilo":"Sedan" ,"recibidodol":"4113.150000"}]}');
            resp.setStatusCode(200);
            return resp;
        }
    }
}