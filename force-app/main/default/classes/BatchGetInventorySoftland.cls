public class BatchGetInventorySoftland implements Queueable, Database.AllowsCallouts{
    public String groupNumber;
    public String actualCurrency;

    public BatchGetInventorySoftland(String groupNumber, String actualCurrency)
    {
        this.groupNumber = groupNumber;
        this.actualCurrency = actualCurrency;
    }

    public void execute(QueueableContext context)
    {
        String url = Label.URLSoftland;
        String clientId = Label.ClientIdSoftland;
        String clientSecret = Label.clientSecretSoftland;
        try {
            String jsonStr;
            
            HttpCalloutAuth httpAuth = new HttpCalloutAuth(clientId,clientSecret);
            HttpResponse res = httpAuth.getAuth();
            jsonStr = res.getBody();
            cls_AuthorizationJSON auth = cls_AuthorizationJSON.parseAutorizationResponse(jsonStr);
            System.debug('--------- Start Process ---------'); 
            HttpCalloutInventory httpInventory = new HttpCalloutInventory(groupNumber);
            List<Product2> lstInventario = new List<Product2>();
            calloutWS(url,auth.token_type,auth.access_token,1,lstInventario,httpInventory,actualCurrency);
            System.debug('--------- End Process --------');
        }
        catch(System.CalloutException e) {
            System.Debug(e);
        }
    }
    
    public static String calloutWS(String url,String tokenType,String token,Integer actualPage,List<Product2> lstInventario,HttpCalloutInventory httpInventory,String actualCurrency) 
    {
        try 
        {
            HttpResponse res = httpInventory.getInventoryCallout(actualCurrency,tokenType,token,actualPage);
            String jsonStr = res.getBody();
            jsonStr = res.getBody();
            //Pretty print debug
            //Object o = JSON.deserializeUntyped(jsonStr);
            //System.debug(Json.serializePretty(o));
            // //-----------------------------
            if(Test.isRunningTest()) jsonStr = '{"Paging":{"TotalThisViewCount":1,"TotalRecordCount":1,"PageSize":1,"PageNo":1,"PageCount":3},"Data":[{"cant_disponible":"1","precio":"1","porc_descuento":"1","costo_local":"1","porc_margen_min":"1","porc_margen_max":"1","telefono1":null,"provincia":null,"pais":null,"otras_senas":null,"nombre":null,"moneda":null,"id":null,"distrito":null,"contacto":null,"condicionPago":"test","cliente":"df","cargo":null,"canton":null,"barrio":null,"alias":null}]}';
            cls_InventoryJSON Inventory = cls_InventoryJSON.parseInventoryResponse(jsonStr);
            Integer pageCount = Inventory.Paging.PageCount;
                
            for(cls_ProductSoftland product : inventory.Data)
            {
                Product2 actualProducto = new Product2();
                actualProducto.Name = product.descripcion;
                actualProducto.Codigo_de_Producto__c = product.articulo;
                actualProducto.Description = product.descripcion;
                actualProducto.isActive = true;
                actualProducto.Moneda__c = product.moneda;
                actualProducto.procentajeMargenMaximo__c =  Decimal.valueOf(product.porc_margen_max);
                actualProducto.porcentajeMargenMinimo__c =  Decimal.valueOf(product.porc_margen_min);
                actualProducto.costoLocal__c =  product.costo_local!=null?Decimal.valueOf(product.costo_local):0;
                actualProducto.porcentajeDescuento__c =  Decimal.valueOf(product.porc_descuento);
                actualProducto.precio__c =  Decimal.valueOf(product.precio);
                actualProducto.cantidadDisponible__c =  Decimal.valueOf(product.cant_disponible);
                actualProducto.grupo1__c =  product.grupo1;
                actualProducto.codGrupo1__c =  product.cod_grupo1;
                actualProducto.grupo2__c =  product.grupo2;
                actualProducto.codGrupo2__c =  product.cod_grupo2;
                actualProducto.grupo3__c =  product.grupo3;
                actualProducto.codGrupo3__c =  product.cod_grupo3;
                actualProducto.grupo4__c =  product.grupo4;
                actualProducto.codGrupo4__c =  product.cod_grupo4;
                actualProducto.grupo5__c =  product.grupo5;
                actualProducto.codGrupo5__c =  product.cod_grupo5;
                actualProducto.grupo6__c =  product.grupo6;
                actualProducto.codGrupo6__c =  product.cod_grupo6;
                actualProducto.vin__c =  product.vin;
                lstInventario.add(actualProducto);
            }
            if(actualPage < PageCount)
            {
                jsonStr = '';
                System.debug(lstInventario.size());
                if(lstInventario.size() > 3000)
                {
                    Database.executeBatch(new BatchUpsertProduct2(tokenType,token,actualPage,lstInventario,httpInventory,actualCurrency),5);
                    lstInventario = new List<Product2>();
                    return 'Ok';
                }
                if(Test.isRunningTest()) return null;
                
                return calloutWS(url,tokenType,token,actualPage+1,lstInventario,httpInventory,actualCurrency);
            } else {
                Database.executeBatch(new BatchUpsertProduct2(tokenType,token,actualPage,lstInventario,httpInventory,actualCurrency),5);
                return 'Ok';
            }
        }
        catch(System.CalloutException e) {
            System.Debug(e+' '+e.getLineNumber());
            return e.getMessage();
        }
    }
}