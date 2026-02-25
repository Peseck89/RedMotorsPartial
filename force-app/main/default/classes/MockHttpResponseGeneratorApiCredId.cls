@isTest
public class MockHttpResponseGeneratorApiCredId implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        res.setBody('{ "error": false, "mensaje": "Éxito", "data": {"correos": ["correo@ejemplo.com"],"telefonos": ["1234567890"],"profesiones": ["Ingeniero"],"identificacion": "12345567890","nombre": "Juan", "apellido1": "Perez","apellido2": "Lopez","fechaNacimiento": "01/15/1985","estadoCivil": "Casado(a)"}}');
        return res;
    }
}