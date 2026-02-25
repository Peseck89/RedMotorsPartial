@isTest
global class HttpCalloutGetProductAvailabilityMock implements HttpCalloutMock {
	global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody(mockResponse());
        response.setStatusCode(200);
        return response; 
    }
    public static String mockResponse(){
        return '{"Data":[{"articulo":"L00078","bodega":"BR01","cantidadDisponible":0,"localizacion":"HENRY"},{"articulo":"L00078","bodega":"BR01","cantidadDisponible":1526.55,"localizacion":"B04_ACEI"},{"articulo":"L00078","bodega":"BR01","cantidadDisponible":0,"localizacion":"PB16"},{"articulo":"L00098","bodega":"BR01","cantidadDisponible":0,"localizacion":"PB02_2-3"},{"articulo":"L00098","bodega":"BR01","cantidadDisponible":20,"localizacion":"PB02_3-3"},{"articulo":"L00098","bodega":"BR01","cantidadDisponible":0,"localizacion":"MAL_ESTA"},{"articulo":"L00098","bodega":"BR01","cantidadDisponible":0,"localizacion":"NELSON"},{"articulo":"L00098","bodega":"BR01","cantidadDisponible":1,"localizacion":"PISO"},{"articulo":"L000102","bodega":"BR01","cantidadDisponible":2,"localizacion":"PB10_4-4"}],"Paging":{"PageNo":1,"PageSize":100,"PageCount":1,"TotalRecordCount":27827,"TotalThisViewCount":9}}';
    }
}