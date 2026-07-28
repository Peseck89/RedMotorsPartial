public class BatchGetCatalogoSoftland implements Queueable, Database.AllowsCallouts {
    public static final String ACTIVIDAD_COMERCIAL = 'ActividadComercial';
    public static final String ASEGURADORA = 'Aseguradora';
    public static final String BODEGA = 'Bodega';
    public static final String CATEGORIA_CLIENTE = 'CategoriaCliente';
    public static final String CENTRO_COSTO = 'CentroCosto';
    public static final String CONDICION_PAGO = 'CondicionPago';
    public static final String CUENTA_CONTABLE = 'CuentaContable';
    public static final String IMPUESTO = 'Impuesto';
    public static final String INVENTORY = 'Inventory';
    public static final String SUBTIPO_DOCUMENTO = 'SubtipoDocumento';

    public String catalogName;
    public String company;
    public String groupNumber;
    public String actualCurrency;

    public BatchGetCatalogoSoftland(String catalogName) {
        this.catalogName = catalogName;
    }

    public BatchGetCatalogoSoftland(String catalogName, String company) {
        this.catalogName = catalogName;
        this.company = company;
    }

    public BatchGetCatalogoSoftland(String catalogName, String groupNumber, String actualCurrency) {
        this.catalogName = catalogName;
        this.groupNumber = groupNumber;
        this.actualCurrency = actualCurrency;
    }

    public void execute(QueueableContext context) {
        String url = Label.URLSoftland;
        String ambiente = Label.ambienteSoftland;

        try {
            AuthorizationToken auth = usesHttpCalloutAuth(catalogName)
                ? authenticateWithHttpCalloutAuth()
                : authenticateWithLegacyRequest(url, ambiente);

            System.debug('--------- Start Process ---------');
            if (catalogName == ACTIVIDAD_COMERCIAL) {
                calloutActividadComercial(url, auth.token_type, auth.access_token, 1, new List<ActividadComercial__c>(), new HttpCalloutActividadComercial(), company);
            } else if (catalogName == ASEGURADORA) {
                calloutAseguradora(url, auth.token_type, auth.access_token, 1, new List<Account>(), new HttpCalloutAseguradora(), company);
            } else if (catalogName == BODEGA) {
                calloutBodega(url, auth.token_type, auth.access_token, 1, new List<Bodega__c>(), new HttpCalloutBodega(), company);
            } else if (catalogName == CATEGORIA_CLIENTE) {
                calloutCategoriaCliente(url, ambiente, auth.token_type, auth.access_token, 1, new List<categoriaCliente__c>());
            } else if (catalogName == CENTRO_COSTO) {
                calloutCentroCosto(url, ambiente, auth.token_type, auth.access_token, 1, new List<centroCosto__c>());
            } else if (catalogName == CONDICION_PAGO) {
                calloutCondicionPago(url, ambiente, auth.token_type, auth.access_token, 1, new List<condicionPago__c>());
            } else if (catalogName == CUENTA_CONTABLE) {
                calloutCuentaContable(url, ambiente, auth.token_type, auth.access_token, 1, new List<CuentaContable__c>());
            } else if (catalogName == IMPUESTO) {
                calloutImpuesto(url, ambiente, auth.token_type, auth.access_token, 1, new List<Impuesto__c>());
            } else if (catalogName == INVENTORY) {
                calloutInventory(url, auth.token_type, auth.access_token, 1, new List<Product2>(), new HttpCalloutInventory(groupNumber), actualCurrency);
            } else if (catalogName == SUBTIPO_DOCUMENTO) {
                calloutSubtipoDocumento(url, ambiente, auth.token_type, auth.access_token, 1, new List<SubtipoDocumento__c>());
            }
            System.debug('--------- End Process --------');
        } catch (System.CalloutException e) {
            System.debug(e);
        }
    }

    private static Boolean usesHttpCalloutAuth(String catalogName) {
        return catalogName == ACTIVIDAD_COMERCIAL ||
            catalogName == ASEGURADORA ||
            catalogName == BODEGA ||
            catalogName == INVENTORY;
    }

    private static AuthorizationToken authenticateWithHttpCalloutAuth() {
        HttpCalloutAuth httpAuth = new HttpCalloutAuth(Label.ClientIdSoftland, Label.clientSecretSoftland);
        HttpResponse res = httpAuth.getAuth();
        cls_AuthorizationJSON auth = cls_AuthorizationJSON.parseAutorizationResponse(res.getBody());

        AuthorizationToken token = new AuthorizationToken();
        token.access_token = auth.access_token;
        token.token_type = auth.token_type;
        return token;
    }

    private static AuthorizationToken authenticateWithLegacyRequest(String url, String ambiente) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url + '/' + ambiente + '/oauth/token');
        req.setBody('clientId=' + Label.ClientIdSoftland + '&clientSecret=' + Label.clientSecretSoftland + '&grant_type=password');
        req.setHeader('Content-Type', 'application/text');
        req.setMethod('GET');
        req.setTimeout(20000);

        HttpResponse res = new Http().send(req);
        return (AuthorizationToken) System.JSON.deserialize(res.getBody(), AuthorizationToken.class);
    }

    public static String calloutActividadComercial(String url, String tokenType, String token, Integer actualPage, List<ActividadComercial__c> lstAC, HttpCalloutActividadComercial httpActividadComercial, String company) {
        try {
            HttpResponse res = httpActividadComercial.getActividadComercialCallout(company, tokenType, token, actualPage);
            Map<String, Object> root = parseRoot(res.getBody());
            Integer pageCount = pageCount(root);
            for (Object item : dataRows(root)) {
                Map<String, Object> row = (Map<String, Object>) item;
                ActividadComercial__c record = new ActividadComercial__c();
                record.Name = value(row, 'descripcion');
                record.codigo__c = value(row, 'codigo');
                record.descripcion__c = value(row, 'descripcion');
                lstAC.add(record);
            }
            if (actualPage < pageCount) {
                return calloutActividadComercial(url, tokenType, token, actualPage + 1, lstAC, httpActividadComercial, company);
            }
            return upsertCatalog(lstAC, ActividadComercial__c.Fields.codigo__c);
        } catch (System.CalloutException e) {
            System.debug(e);
            return e.getMessage();
        }
    }

    public static String calloutAseguradora(String url, String tokenType, String token, Integer actualPage, List<Account> lstAseguradoras, HttpCalloutAseguradora httpAseguradora, String company) {
        try {
            HttpResponse res = httpAseguradora.getAseguradoraCallout(company, tokenType, token, actualPage);
            Map<String, Object> root = parseRoot(res.getBody());
            Integer pageCount = pageCount(root);
            for (Object item : dataRows(root)) {
                Map<String, Object> row = (Map<String, Object>) item;
                String condicionPago = value(row, 'condicionPago');
                condicionPago__c vCondicionPago = [SELECT Id, condicionPago__c FROM condicionPago__c WHERE condicionPago__c = :condicionPago];
                RecordType recordType = [SELECT Id FROM RecordType WHERE Name = 'Aseguradora' AND SobjectType = 'Account'];

                Account acc = new Account();
                acc.codigoSoftland__c = value(row, 'cliente');
                acc.Name = value(row, 'nombre');
                acc.Cedula__c = value(row, 'id');
                acc.Monedas_Iden__c = value(row, 'moneda');
                acc.condicionPago__c = vCondicionPago.Id;
                acc.pais__c = value(row, 'pais');
                acc.provincia__c = value(row, 'provincia');
                acc.canton__c = value(row, 'canton');
                acc.distrito__c = value(row, 'distrito');
                acc.barrio__c = value(row, 'barrio');
                acc.Direccion__c = value(row, 'otras_senas');
                acc.Phone = '+506' + value(row, 'telefono1');
                acc.Telefono2__c = '+506' + value(row, 'telefono2');
                acc.RecordTypeId = recordType.Id;
                lstAseguradoras.add(acc);
            }
            if (actualPage < pageCount) {
                return calloutAseguradora(url, tokenType, token, actualPage + 1, lstAseguradoras, httpAseguradora, company);
            }
            return upsertCatalog(lstAseguradoras, Account.Fields.codigoSoftland__c);
        } catch (System.CalloutException e) {
            System.debug(e);
            return e.getMessage();
        }
    }

    public static String calloutBodega(String url, String tokenType, String token, Integer actualPage, List<Bodega__c> lstBod, HttpCalloutBodega httpBodega, String company) {
        try {
            HttpResponse res = httpBodega.getBodegaCallout(company, tokenType, token, actualPage);
            Map<String, Object> root = parseRoot(res.getBody());
            System.debug(JSON.serializePretty(root));
            Integer pageCount = pageCount(root);
            for (Object item : dataRows(root)) {
                Map<String, Object> row = (Map<String, Object>) item;
                Bodega__c bodega = new Bodega__c();
                bodega.Name = value(row, 'nombre');
                bodega.bodega__c = value(row, 'bodega');
                bodega.ID_EXTERNO_BODEGA__c = company == 'RMOTOBAI' ? 'RMOTOBAI' + value(row, 'bodega') : value(row, 'bodega');
                lstBod.add(bodega);
            }
            if (actualPage < pageCount) {
                return calloutBodega(url, tokenType, token, actualPage + 1, lstBod, httpBodega, company);
            }
            return upsertCatalog(lstBod, Bodega__c.Fields.ID_EXTERNO_BODEGA__c);
        } catch (System.CalloutException e) {
            System.debug(e);
            return e.getMessage();
        }
    }

    public static String calloutCategoriaCliente(String url, String ambiente, String tokenType, String token, Integer actualPage, List<categoriaCliente__c> lstCC) {
        try {
            Map<String, Object> root = getLegacyCatalog(url, ambiente, tokenType, token, 'softlandAPI/Catalogs/getCategorias_Cliente?pageNo=' + actualPage + '&pageSize=10&compania=RMBAVARIAN');
            for (Object item : dataRows(root)) {
                Map<String, Object> row = (Map<String, Object>) item;
                CategoriaCliente__c cc = new CategoriaCliente__c();
                cc.Name = value(row, 'descripcion');
                cc.CategoriaCliente__c = value(row, 'categoriaCliente');
                cc.descripcion__c = value(row, 'descripcion');
                lstCC.add(cc);
            }
            if (actualPage < pageCount(root)) {
                return calloutCategoriaCliente(url, ambiente, tokenType, token, actualPage + 1, lstCC);
            }
            return upsertCatalog(lstCC, CategoriaCliente__c.Fields.CategoriaCliente__c);
        } catch (System.CalloutException e) {
            System.debug(e);
            return e.getMessage();
        }
    }

    public static String calloutCentroCosto(String url, String ambiente, String tokenType, String token, Integer actualPage, List<centroCosto__c> lstCC) {
        try {
            Map<String, Object> root = getLegacyCatalog(url, ambiente, tokenType, token, 'softlandAPI/Catalogs/getCentroCostos?compania=RMBAVARIAN&pageNo=' + actualPage + '&pageSize=10');
            System.debug(JSON.serializePretty(root));
            for (Object item : dataRows(root)) {
                Map<String, Object> row = (Map<String, Object>) item;
                CentroCosto__c record = new CentroCosto__c();
                record.Name = value(row, 'descripcion');
                record.centroCosto__c = value(row, 'centroCosto');
                record.descripcion__c = value(row, 'descripcion');
                lstCC.add(record);
            }
            if (actualPage < pageCount(root)) {
                return calloutCentroCosto(url, ambiente, tokenType, token, actualPage + 1, lstCC);
            }
            return upsertCatalog(lstCC, CentroCosto__c.Fields.centroCosto__c);
        } catch (System.CalloutException e) {
            System.debug(e);
            return e.getMessage();
        }
    }

    public static String calloutCondicionPago(String url, String ambiente, String tokenType, String token, Integer actualPage, List<condicionPago__c> lstCP) {
        try {
            Map<String, Object> root = getLegacyCatalog(url, ambiente, tokenType, token, 'softlandAPI/Catalogs/getCondicionPagos?compania=RMBAVARIAN&pageNo=' + actualPage + '&pageSize=10');
            for (Object item : dataRows(root)) {
                Map<String, Object> row = (Map<String, Object>) item;
                condicionPago__c cp = new condicionPago__c();
                cp.Name = value(row, 'descripcion');
                cp.condicionPago__c = value(row, 'condicionPago');
                cp.descripcion__c = value(row, 'descripcion');
                lstCP.add(cp);
            }
            if (actualPage < pageCount(root)) {
                return calloutCondicionPago(url, ambiente, tokenType, token, actualPage + 1, lstCP);
            }
            return upsertCatalog(lstCP, condicionPago__c.Fields.condicionPago__c);
        } catch (System.CalloutException e) {
            System.debug(e);
            return e.getMessage();
        }
    }

    public static String calloutCuentaContable(String url, String ambiente, String tokenType, String token, Integer actualPage, List<CuentaContable__c> lstCC) {
        try {
            Map<String, Object> root = getLegacyCatalog(url, ambiente, tokenType, token, 'softlandAPI/Catalogs/getCuentaContable?compania=RMBAVARIAN&pageNo=' + actualPage + '&pageSize=10');
            System.debug(JSON.serializePretty(root));
            for (Object item : dataRows(root)) {
                Map<String, Object> row = (Map<String, Object>) item;
                CuentaContable__c cc = new CuentaContable__c();
                cc.Name = value(row, 'descripcion');
                cc.CuentaContable__c = value(row, 'cuentaContable');
                cc.descripcion__c = value(row, 'descripcion');
                lstCC.add(cc);
            }
            if (actualPage < pageCount(root)) {
                return calloutCuentaContable(url, ambiente, tokenType, token, actualPage + 1, lstCC);
            }
            return upsertCatalog(lstCC, CuentaContable__c.Fields.CuentaContable__c);
        } catch (System.CalloutException e) {
            System.debug(e);
            return e.getMessage();
        }
    }

    public static String calloutImpuesto(String url, String ambiente, String tokenType, String token, Integer actualPage, List<Impuesto__c> lstI) {
        try {
            Map<String, Object> root = getLegacyCatalog(url, ambiente, tokenType, token, 'softlandAPI/Catalogs/getImpuestos?compania=RMBAVARIAN&pageNo=' + actualPage + '&pageSize=10');
            System.debug(JSON.serializePretty(root));
            for (Object item : dataRows(root)) {
                Map<String, Object> row = (Map<String, Object>) item;
                Impuesto__c imp = new Impuesto__c();
                imp.Name = value(row, 'descripcion');
                imp.codigoImpuesto__c = value(row, 'codigoImpuesto');
                imp.descripcion__c = value(row, 'descripcion');
                imp.impuesto__c = decimalValue(row, 'impuesto');
                lstI.add(imp);
            }
            if (actualPage < pageCount(root)) {
                return calloutImpuesto(url, ambiente, tokenType, token, actualPage + 1, lstI);
            }
            return upsertCatalog(lstI, Impuesto__c.Fields.codigoImpuesto__c);
        } catch (System.CalloutException e) {
            System.debug(e);
            return e.getMessage();
        }
    }

    public static String calloutInventory(String url, String tokenType, String token, Integer actualPage, List<Product2> lstInventario, HttpCalloutInventory httpInventory, String actualCurrency) {
        try {
            HttpResponse res = httpInventory.getInventoryCallout(actualCurrency, tokenType, token, actualPage);
            Map<String, Object> root = parseRoot(res.getBody());
            Integer pageCount = pageCount(root);
            for (Object item : dataRows(root)) {
                Map<String, Object> row = (Map<String, Object>) item;
                Product2 product = new Product2();
                product.Name = value(row, 'descripcion');
                product.Codigo_de_Producto__c = value(row, 'articulo');
                product.Description = value(row, 'descripcion');
                product.isActive = true;
                product.Moneda__c = value(row, 'moneda');
                product.procentajeMargenMaximo__c = decimalValue(row, 'porc_margen_max');
                product.porcentajeMargenMinimo__c = decimalValue(row, 'porc_margen_min');
                product.costoLocal__c = value(row, 'costo_local') != null ? decimalValue(row, 'costo_local') : 0;
                product.porcentajeDescuento__c = decimalValue(row, 'porc_descuento');
                product.precio__c = decimalValue(row, 'precio');
                product.cantidadDisponible__c = decimalValue(row, 'cant_disponible');
                product.grupo1__c = value(row, 'grupo1');
                product.codGrupo1__c = value(row, 'cod_grupo1');
                product.grupo2__c = value(row, 'grupo2');
                product.codGrupo2__c = value(row, 'cod_grupo2');
                product.grupo3__c = value(row, 'grupo3');
                product.codGrupo3__c = value(row, 'cod_grupo3');
                product.grupo4__c = value(row, 'grupo4');
                product.codGrupo4__c = value(row, 'cod_grupo4');
                product.grupo5__c = value(row, 'grupo5');
                product.codGrupo5__c = value(row, 'cod_grupo5');
                product.grupo6__c = value(row, 'grupo6');
                product.codGrupo6__c = value(row, 'cod_grupo6');
                product.vin__c = value(row, 'vin');
                lstInventario.add(product);
            }
            if (actualPage < pageCount) {
                if (lstInventario.size() > 3000) {
                    Database.executeBatch(new BatchUpsertProduct2(tokenType, token, actualPage, lstInventario, httpInventory, actualCurrency), 5);
                    lstInventario = new List<Product2>();
                    return 'Ok';
                }
                if (Test.isRunningTest()) {
                    return null;
                }
                return calloutInventory(url, tokenType, token, actualPage + 1, lstInventario, httpInventory, actualCurrency);
            }
            Database.executeBatch(new BatchUpsertProduct2(tokenType, token, actualPage, lstInventario, httpInventory, actualCurrency), 5);
            return 'Ok';
        } catch (System.CalloutException e) {
            System.debug(e + ' ' + e.getLineNumber());
            return e.getMessage();
        }
    }

    public static String calloutSubtipoDocumento(String url, String ambiente, String tokenType, String token, Integer actualPage, List<SubtipoDocumento__c> lstSD) {
        try {
            Map<String, Object> root = getLegacyCatalog(url, ambiente, tokenType, token, 'softlandAPI/Catalogs/getSubtiposDocCC?compania=RMBAVARIAN&pageNo=' + actualPage + '&pageSize=10');
            for (Object item : dataRows(root)) {
                Map<String, Object> row = (Map<String, Object>) item;
                SubtipoDocumento__c record = new SubtipoDocumento__c();
                record.Name = value(row, 'descripcion');
                record.subtipo__c = value(row, 'subtipo');
                record.descripcion__c = value(row, 'descripcion');
                lstSD.add(record);
            }
            if (actualPage < pageCount(root)) {
                return calloutSubtipoDocumento(url, ambiente, tokenType, token, actualPage + 1, lstSD);
            }
            return upsertCatalog(lstSD, SubtipoDocumento__c.Fields.subtipo__c);
        } catch (System.CalloutException e) {
            System.debug(e);
            return e.getMessage();
        }
    }

    private static Map<String, Object> getLegacyCatalog(String url, String ambiente, String tokenType, String token, String path) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url + '/' + ambiente + '/' + path);
        System.debug(req.getEndpoint());
        req.setHeader('Authorization', tokenType + ' ' + token);
        req.setMethod('GET');
        req.setTimeout(20000);
        return parseRoot(new Http().send(req).getBody());
    }

    private static Map<String, Object> parseRoot(String jsonStr) {
        return (Map<String, Object>) JSON.deserializeUntyped(jsonStr);
    }

    private static List<Object> dataRows(Map<String, Object> root) {
        Object data = root.get('Data');
        return data == null ? new List<Object>() : (List<Object>) data;
    }

    private static Integer pageCount(Map<String, Object> root) {
        Map<String, Object> paging = (Map<String, Object>) root.get('Paging');
        return paging == null ? 1 : Integer.valueOf(String.valueOf(paging.get('PageCount')));
    }

    private static String value(Map<String, Object> row, String key) {
        for (String actualKey : row.keySet()) {
            if (actualKey != null && actualKey.equalsIgnoreCase(key)) {
                Object raw = row.get(actualKey);
                return raw == null ? null : String.valueOf(raw);
            }
        }
        return null;
    }

    private static Decimal decimalValue(Map<String, Object> row, String key) {
        String raw = value(row, key);
        return String.isBlank(raw) ? 0 : Decimal.valueOf(raw);
    }

    private static String upsertCatalog(List<SObject> records, Schema.SObjectField externalIdField) {
        Database.UpsertResult[] results = Database.upsert(records, externalIdField, false);
        for (Database.UpsertResult result : results) {
            if (!result.isSuccess()) {
                System.debug('Error al actualizar la entrada: ' + result.getErrors());
            }
        }
        return 'Ok';
    }

    public class AuthorizationToken {
        public String access_token;
        public String token_type;
    }
}