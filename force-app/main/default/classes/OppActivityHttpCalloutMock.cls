@isTest
global class OppActivityHttpCalloutMock implements HttpCalloutMock{
global HTTPResponse respond(HTTPRequest request) {
        System.assertEquals('POST', request.getMethod());
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        //response.setBody('{"data": [{"TipoActividad": "TAREAS","idActividad": "FECC082E-E875-EA11-A811-000D3AC179A6","IdOportunidad": "8039355F-E675-EA11-A811-000D3AC17207","NombreOportunidad": "Auto-MINI-MINI-Cooper S 5-puertas-Salt AT 2020","idOportunidadUsuario": "A70D90C7-5B92-E711-80FF-E0071B6E4C81","FechaCreacionContacto": "03/04/2020 12:00:00 a. m.","IdUsuario": "A70D90C7-5B92-E711-80FF-E0071B6E4C81","NombreUsuario": "Carolina Ramirez","NombreVitrina": "Autonorte Calle 197","Marca": "MINI","FechaEstimadadeCompra": "De 3 a 6 meses","EstadoSeguimiento": "Ganada","EstadoOportunidad": "Ganado","fechaentrega": "03/02/2020"}]}');
        response.setStatusCode(200);
        return response; 
    }
}