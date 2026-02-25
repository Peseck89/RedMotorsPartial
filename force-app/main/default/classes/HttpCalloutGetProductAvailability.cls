global class HttpCalloutGetProductAvailability {
    
    public String orden_salesforce;
    List <product> productsToRequest;
    string company;
    public Map<String,ProductController.productResponse> locationXquantity;
    public Map<String,Map<String,Double>> productXlocation;
    public Set<String> productxbodega = new Set<String> ();
    
    public HttpCalloutGetProductAvailability(String company, String workOrderNumber){
        this.productsToRequest = new List <product>();
        this.company = company;
        this.locationXquantity = new Map<String,ProductController.productResponse> ();
        this.productXlocation = new Map<String,Map<String,Double>>();
        this.orden_salesforce = workOrderNumber;
    
    }
    
    public HttpCalloutGetProductAvailability(String company){
        this.productsToRequest = new List <product>();
        this.company = company;
        this.locationXquantity = new Map<String,ProductController.productResponse> ();
        this.productXlocation= new Map<String,Map<String,Double>>();
    
    }
    
    class product{
        string bodega;
        string articulo;
        string tipo;
        
        public product(string bodega, string cod_producto, string productType){
            this.bodega = bodega;
            this.articulo = cod_producto;
            this.tipo = productType=='Kit'? 'K' : 'T';
        }
    
    }
    
    public class productResponse{
        String articulo;
        String bodega;
        Double cantidadDisponible;
        Double reservadoOrden;
        String localizacion;
        
    
    }
    
    public void addToRequest (string bodega, string cod_producto, string productType){
        if(!this.productxbodega.contains(bodega + cod_producto + productType)){
        	this.productxbodega.add(bodega + cod_producto + productType);
            product product= new product(bodega, cod_producto, productType);
            this.productsToRequest.add(product);
        }
    
    }
    
    public String serializeJSONRequest(){
        String request='{"orden_salesforce": "'+this.orden_salesforce+'","compania": "'+this.company+'","articulos":';
        request+=JSON.serialize(this.productsToRequest)+'}';        
        return request;
        
    
    }
    
    public HttpResponse getExistencias(){
        String jsonStr;
        HttpCalloutAuth htppAuth= new HttpCalloutAuth(label.ClientIdSoftland,label.ClientSecretSoftland);//cambiar por custom label
        HttpResponse res = htppAuth.getAuth();
        jsonStr = res.getBody();
        system.debug(Label.URLSoftland+Label.ambienteSoftland);
        system.debug(jsonStr);
        cls_AuthorizationJSON auth = cls_AuthorizationJSON.parseAutorizationResponse(jsonStr);
        String url = Label.URLSoftland;
        String ambiente = Label.ambienteSoftland;
        String fullUrl = url+'/'+ambiente+'/softlandAPI/Catalogs/getExistenciaArticulo';
        system.debug(fullUrl);
        //orderSoftlandWrapper bodyRequest = orderJSONData.getJSONFromOrder(idOrder,cardCode);
        String body = this.serializeJSONRequest();
        // body=getString();
        //system.debug('Body to request');
        system.debug(body);
        //-----------------------------
        HttpCalloutPost test =new HttpCalloutPost();
        HttpResponse rest = test.callRequest(fullUrl,auth.token_type,auth.access_token,body);
        system.debug('Softland response'+rest.getBody());
        return rest;
    
    }
    
    public static String mockResponse(){
        return '{ "Data": [ { "articulo": "L00078", "bodega": "BR01", "cantidadDisponible": 0, "localizacion": "HENRY", "reservadoOrden": 0 }, { "articulo": "L00078", "bodega": "BR01", "cantidadDisponible": 1526.55, "localizacion": "B04_ACEI", "reservadoOrden": 0 }, { "articulo": "L00078", "bodega": "BR01", "cantidadDisponible": 0, "localizacion": "PB16", "reservadoOrden": 0 }, { "articulo": "L00098", "bodega": "BR01", "cantidadDisponible": 0, "localizacion": "PB02_2-3", "reservadoOrden": 0 }, { "articulo": "L00098", "bodega": "BR01", "cantidadDisponible": 20, "localizacion": "PB02_3-3", "reservadoOrden": 0 }, { "articulo": "L00098", "bodega": "BR01", "cantidadDisponible": 0, "localizacion": "MAL_ESTA", "reservadoOrden": 0 }, { "articulo": "L00098", "bodega": "BR01", "cantidadDisponible": 0, "localizacion": "NELSON", "reservadoOrden": 0 }, { "articulo": "L00098", "bodega": "BR01", "cantidadDisponible": 1, "localizacion": "PISO", "reservadoOrden": 0 }, { "articulo": "L000102", "bodega": "BR01", "cantidadDisponible": 2, "localizacion": "PB10_4-4", "reservadoOrden": 0 } ], "Paging": { "PageNo": 1, "PageSize": 100, "PageCount": 1, "TotalRecordCount": 27827, "TotalThisViewCount": 9 } }';
    
    }
    
    public Map<String,ProductController.productResponse>  deserialize(){
        Map<String, Object> results;
        if(Test.isRunningTest()){
            results=(Map<String, Object>) JSON.deserializeUntyped(HttpCalloutGetProductAvailabilityMock.mockResponse());
        }else{
            results=(Map<String, Object>) JSON.deserializeUntyped(this.getExistencias().getBody());
            //results=(Map<String, Object>) JSON.deserializeUntyped(mockResponse());
        }
        /*List<Object> Data = (List<Object>) results.get('Data');
            for(Object articulo: Data) {
            System.debug(articulo);
            }*/
        List<ProductController.productResponse> products=( List<ProductController.productResponse>)JSON.deserialize(JSON.serialize(results.get('Data')),List<ProductController.productResponse>.class);//en controller
        Map<String,ProductController.productResponse> responseJson =new Map<String,ProductController.productResponse> ();
        Map<String,Double> lxQ;
        for(ProductController.productResponse prod: products) {
            prod.reservadoOrden = prod.reservadoOrden == null? 0 : prod.reservadoOrden;
            if(!responseJson.containsKey(prod.articulo)){
                responseJson.put(prod.articulo, prod);
            }else if((responseJson.get(prod.articulo).cantidadDisponible)<prod.cantidadDisponible+prod.reservadoOrden){
                System.debug(responseJson.get(prod.articulo).cantidadDisponible+'<:'+prod.cantidadDisponible);
                System.debug('Se elimina:'+responseJson.get(prod.articulo));
                responseJson.remove(prod.articulo);
                responseJson.put(prod.articulo, prod);
                System.debug('Se agrega:'+prod);
            }
            
            if(this.productXlocation.containsKey(prod.articulo)){
                System.debug('Agregando cantidad:'+prod.cantidadDisponible+' + '+prod.reservadoOrden);
                this.productXlocation.get(prod.articulo).put(prod.localizacion,prod.cantidadDisponible+prod.reservadoOrden);
            }else{
                lxQ= new Map<String,Double> ();
                lxQ.put(prod.localizacion,prod.cantidadDisponible+prod.reservadoOrden);
                this.productXlocation.put(prod.articulo,lxQ);
            }
            lxQ.put(prod.localizacion, prod.cantidadDisponible+prod.reservadoOrden);
            //System.debug(prod.bodega);
        }
        //system.debug(results);
        return responseJson;
        
    
    } 
}