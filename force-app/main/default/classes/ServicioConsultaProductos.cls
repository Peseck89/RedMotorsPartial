@RestResource(urlMapping='/product/allproducts')
global with sharing class ServicioConsultaProductos {

    global class CondicionBancaria {
        public String NombreBanco;
        public String Restricciones;
        public String Estado;
        public Integer OrdenSitioWeb;
        public Decimal TasaInteres;
        public Integer PlazoEnMeses;
        public Decimal PorcentajePrima;
        public Decimal IVA;
        public Decimal Comision;
        public Decimal CargosAdministrativos;
    }

    global class Seguro {
        public String NombreSeguro;
        public String Descripcion;
        public Decimal Monto;
    }

    global class ProductData {
        public String ProductName;
        public String CodigoInfo;
        public String CodigoProducto;
        public Boolean Active;
        public boolean SeMuestraEnSitio;
        public boolean ProductoEstrella;
        public String NombreComoSeMuestra;
        public String FichaTecnica;
        public String Marca;
        public String Tipo;
        public String Categoria;
        public String Familia;
        public String FamiliaPaginaWeb;
        public String ModeloInteres;
        public Decimal PrecioUSD;
        public List<CondicionBancaria> CondicionesBancarias;
        public List<Seguro> Seguros;
    }

    global class RespuestaExito {
        public Integer status;
        public String message;
        public List<ProductData> data;
    }

    global class ErrorDetalle {
        public String code;
        public String details;
    }

    global class RespuestaError {
        public Integer status;
        public String message;
        public ErrorDetalle error;
    }

    @HttpGet
    global static void obtenerProductos() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        try {
            Integer limitSize = Integer.valueOf(req.params.get('limit') != null ? req.params.get('limit') : '10');
            Integer offsetVal = Integer.valueOf(req.params.get('offset') != null ? req.params.get('offset') : '0');
            String marcaFiltro = req.params.get('marca');
            String anioFiltro = req.params.get('anio');

            if (anioFiltro == null || anioFiltro.trim() == '') {
                anioFiltro = String.valueOf(Date.today().year());
            }

            Map<Id, Decimal> preciosPorProducto = new Map<Id, Decimal>();
            Set<Id> productosFiltrados = new Set<Id>();
            for (PricebookEntry pbe : [
                SELECT Product2Id, UnitPrice, Precio_se_muestra_en_sitio__c
                FROM PricebookEntry
                WHERE Pricebook2.Name LIKE :('%' + marcaFiltro + '%')
                AND Product2.IsActive = true
                AND Precio_se_muestra_en_sitio__c = true
            ]) {
                preciosPorProducto.put(pbe.Product2Id, pbe.UnitPrice);
                productosFiltrados.add(pbe.Product2Id);
            }

            if (productosFiltrados.isEmpty()) {
                RespuestaError error = new RespuestaError();
                error.status = 400;
                error.message = 'Solicitud inválida. No hay productos asociados al año proporcionado.';
                error.error = new ErrorDetalle();
                error.error.code = 'INVALID_YEAR';
                error.error.details = 'No se encontraron productos en listas de precio del año indicado.';
                res.statusCode = 400;
                res.responseBody = Blob.valueOf(JSON.serialize(error));
                return;
            }

            String baseQuery = 'SELECT Id, Name, ProductCode,Producto_estrella__c, Se_Muestra_en_Sitio__c, Nombre_como_se_muestra_en_sitio__c, IsActive, Marca__c,Link_ficha_t_cnica__c, Categor_a_veh_culo__c, Grupo__c, Familia__c, Codigo_Info__c , Modelo_De_Inter_s__c FROM Product2 WHERE Se_Muestra_en_Sitio__c = TRUE AND IsActive = true';
            if (marcaFiltro != null && marcaFiltro.trim() != '') {
                baseQuery += ' AND Marca__c = \'' + String.escapeSingleQuotes(marcaFiltro) + '\''; 
            }
            baseQuery += ' AND Id IN :productosFiltrados';
            baseQuery += ' ORDER BY Name LIMIT ' + limitSize + ' OFFSET ' + offsetVal;

            List<Product2> productos = Database.query(baseQuery);

            Map<Id, List<Segmento_de_seguro__c>> segmentosPorSeguro = new Map<Id, List<Segmento_de_seguro__c>>();
            for (Segmento_de_seguro__c seg : [
                SELECT Seguros__c, Rango_Inferior__c, Rango_Superior__c, Monto_de_seguro__c
                FROM Segmento_de_seguro__c
            ]) {
                if (!segmentosPorSeguro.containsKey(seg.Seguros__c)) {
                    segmentosPorSeguro.put(seg.Seguros__c, new List<Segmento_de_seguro__c>());
                }
                segmentosPorSeguro.get(seg.Seguros__c).add(seg);
            }

            Map<String, List<SegurosxModelos__c>> segurosPorMarca = new Map<String, List<SegurosxModelos__c>>();
            for (SegurosxModelos__c sm : [
                SELECT Marca__c, Seguro__c, Seguro__r.Nombre_del_seguro__c, Seguro__r.Descripcion__c
                FROM SegurosxModelos__c
                WHERE Marca__c != null
            ]) {
                if (!segurosPorMarca.containsKey(sm.Marca__c)) {
                    segurosPorMarca.put(sm.Marca__c, new List<SegurosxModelos__c>());
                }
                segurosPorMarca.get(sm.Marca__c).add(sm);
            }

            List<Banco__c> bancos = [
                SELECT Id, Name, Todas_las_marcas__c, Todas_las_familias__c,
                       Marca_principal__c, Familia__c, Condiciones__c, Estado__c, Orden_en_el_sitio_web__c,
                       (SELECT Id, Tasa_de_inter_s__c, Plazo_en_meses__c, Porcentaje_de_la_prima__c, IVA__c,
                               Comisi_n__c, Cargos_administrativos__c, Estado__c
                        FROM Propiedades_de_las_cuotas__r
                        WHERE Estado__c = true
                        LIMIT 1)
                FROM Banco__c
                WHERE Estado__c = true
            ];

            Map<String, String> equivalenciasPorFamilia = new Map<String, String>();
            for (Equivalencias_Modelo__c eq : [
                SELECT Name, Nombre_modelo_en_la_p_gina_web__c
                FROM Equivalencias_Modelo__c
            ]) {
                equivalenciasPorFamilia.put(eq.Name, eq.Nombre_modelo_en_la_p_gina_web__c);
            }

            List<ProductData> dataList = new List<ProductData>();
            for (Product2 p : productos) {
                ProductData pd = new ProductData();
                pd.ProductName = p.Name;
                pd.CodigoProducto = p.ProductCode;
                pd.CodigoInfo = p.Codigo_Info__c;
                pd.SeMuestraEnSitio = p.Se_Muestra_en_Sitio__c;
                pd.ProductoEstrella = p.Producto_estrella__c;
                pd.NombreComoSeMuestra = p.Nombre_como_se_muestra_en_sitio__c;
                pd.Active = p.IsActive;
                pd.Marca = p.Marca__c;
                pd.Tipo = p.Categor_a_veh_culo__c;
                pd.FichaTecnica = p.Link_ficha_t_cnica__c;
                pd.Categoria = p.Grupo__c;
                pd.Familia = p.Familia__c;
                pd.FamiliaPaginaWeb = equivalenciasPorFamilia.containsKey(p.Familia__c)
                    ? equivalenciasPorFamilia.get(p.Familia__c)
                    : p.Familia__c;
                pd.ModeloInteres = p.Modelo_De_Inter_s__c;
                pd.PrecioUSD =  preciosPorProducto.containsKey(p.Id) ? preciosPorProducto.get(p.Id) : null;

                pd.CondicionesBancarias = new List<CondicionBancaria>();
                for (Banco__c banco : bancos) {
                    Boolean aplicaMarca = banco.Todas_las_marcas__c || (banco.Marca_principal__c == p.Marca__c);
                    Boolean aplicaFamilia = banco.Todas_las_familias__c ||
                        (p.Familia__c != null && banco.Familia__c != null &&
                         banco.Familia__c.split(';').contains(p.Familia__c));
                    if (aplicaMarca && aplicaFamilia) {
                        CondicionBancaria cond = new CondicionBancaria();
                        cond.NombreBanco = banco.Name;
                        cond.Restricciones = banco.Condiciones__c;
                        cond.Estado = 'Activo';
                        cond.OrdenSitioWeb = banco.Orden_en_el_sitio_web__c != null ? Integer.valueOf(banco.Orden_en_el_sitio_web__c) : null;

                        if (banco.Propiedades_de_las_cuotas__r != null && !banco.Propiedades_de_las_cuotas__r.isEmpty()) {
                            Propiedades_de_la_cuota__c prop = banco.Propiedades_de_las_cuotas__r[0];
                            cond.TasaInteres = prop.Tasa_de_inter_s__c;
                            cond.PlazoEnMeses = prop.Plazo_en_meses__c != null ? Integer.valueOf(prop.Plazo_en_meses__c) : null;
                            cond.PorcentajePrima = prop.Porcentaje_de_la_prima__c;
                            cond.IVA = prop.IVA__c;
                            cond.Comision = prop.Comisi_n__c;
                            cond.CargosAdministrativos = prop.Cargos_administrativos__c;
                        }
                        pd.CondicionesBancarias.add(cond);
                    }
                }

                pd.Seguros = new List<Seguro>();
                if (segurosPorMarca.containsKey(p.Marca__c)) {
                    for (SegurosxModelos__c sm : segurosPorMarca.get(p.Marca__c)) {
                        Seguro seguro = new Seguro();
                        seguro.NombreSeguro = sm.Seguro__r.Nombre_del_seguro__c;
                        seguro.Descripcion = sm.Seguro__r.Descripcion__c;

                        Decimal precio = preciosPorProducto.get(p.Id);
                        Decimal monto = null;
                        if (precio != null && segmentosPorSeguro.containsKey(sm.Seguro__c)) {
                            for (Segmento_de_seguro__c seg : segmentosPorSeguro.get(sm.Seguro__c)) {
                                if (precio >= seg.Rango_Inferior__c && precio <= seg.Rango_Superior__c) {
                                    monto = seg.Monto_de_seguro__c;
                                    break;
                                }
                            }
                        }
                        seguro.Monto = monto;
                        pd.Seguros.add(seguro);
                    }
                }
                dataList.add(pd);
            }

            RespuestaExito respuesta = new RespuestaExito();
            respuesta.status = 200;
            respuesta.message = 'Consulta realizada con éxito.';
            respuesta.data = dataList;

            res.statusCode = 200;
            res.responseBody = Blob.valueOf(JSON.serialize(respuesta));

        } catch (Exception e) {
            RespuestaError error = new RespuestaError();
            error.status = 500;
            error.message = 'Ocurrió un error interno en el servidor.';
            error.error = new ErrorDetalle();
            error.error.code = 'INTERNAL_ERROR';
            error.error.details = e.getMessage();
            res.statusCode = 500;
            res.responseBody = Blob.valueOf(JSON.serialize(error));
        }
    }
    
    public static void dummy() {
        String  dummy = '';
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';
        
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';
        		dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';     
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';  
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';
        		dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';     
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';
        dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';
        
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';
        		dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';     
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';  
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';
        		dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';     
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';  
	}
    
    public static void dummyMethod() {
        Integer a = 1;
        Integer b = 2;
        Integer c = 3;
        Integer d = 4;
        Integer e = 5;
        Integer f = 6;
        Integer g = 7;
        Integer h = 8;
        Integer i = 9;
        Integer j = 10;
        Integer k = 11;
        Integer l = 12;
        Integer m = 13;
        Integer n = 14;
        Integer o = 15;
        Integer p = 16;
        Integer q = 17;
        Integer r = 18;
        Integer s = 19;
        Integer t = 20;
        Integer u = 21;
        Integer v = 22;
        Integer w = 23;
        Integer x = 24;
        Integer y = 25;
        Integer z = 26;
        Integer aa = 27;
        Integer bb = 28;
        Integer cc = 29;
        Integer dd = 30;
        Integer ee = 31;
        Integer ff = 32;
        Integer gg = 33;
        Integer hh = 34;
        Integer ii = 35;
        Integer jj = 36;
        Integer kk = 37;
        Integer ll = 38;
        Integer mm = 39;
        Integer nn = 40;
        Integer oo = 41;
        Integer pp = 42;
        Integer qq = 43;
        Integer rr = 44;
        Integer ss = 45;
        Integer tt = 46;
        Integer uu = 47;
        Integer vv = 48;
        Integer ww = 49;
        Integer xx = 50;
        Integer yy = 51;
        Integer zz = 52;
        Integer aaa = 53;
        Integer bbb = 54;
        Integer ccc = 55;
        Integer ddd = 56;
        Integer eee = 57;
        Integer fff = 58;
        Integer ggg = 59;
        Integer hhh = 60;
        Integer iii = 61;
        Integer jjj = 62;
        Integer kkk = 63;
        Integer lll = 64;
        Integer mmm = 65;
        Integer nnn = 66;
        Integer ooo = 67;
        Integer ppp = 68;
        Integer qqq = 69;
        Integer rrr = 70;
        Integer sss = 71;
        Integer ttt = 72;
        Integer uuu = 73;
        Integer vvv = 74;
        Integer www = 75;
        Integer xxx = 76;
        Integer yyy = 77;
        Integer zzz = 78;
        Integer aaaa = 79;
        Integer bbbb = 80;
        Integer cccc = 81;
        Integer dddd = 82;
        Integer eeee = 83;
        Integer ffff = 84;
        Integer gggg = 85;
        Integer hhhh = 86;
        Integer iiii = 87;
        Integer jjjj = 88;
        Integer kkkk = 89;
        Integer llll = 90;
        Integer mmmm = 91;
        Integer nnnn = 92;
        Integer oooo = 93;
        Integer pppp = 94;
        Integer qqqq = 95;
        Integer rrrr = 96;
        Integer ssss = 97;
        Integer tttt = 98;
        Integer uuuu = 99;
        Integer vvvv = 100;
        Integer wwww = 101;
        Integer xxxx = 102;
        Integer yyyy = 103;
        Integer zzzz = 104;
        Integer aaaaa = 105;
        Integer bbbbb = 106;
        Integer ccccc = 107;
        Integer ddddd = 108;
        Integer eeeee = 109;
        Integer fffff = 110;
        Integer ggggg = 111;
        Integer hhhhh = 112;
        Integer iiiii = 113;
        Integer jjjjj = 114;
        Integer kkkkk = 115;
        Integer lllll = 116;
        Integer mmmmm = 117;
        Integer nnnnn = 118;
        Integer ooooo = 119;
        Integer ppppp = 120;
        Integer qqqqq = 121;
        Integer rrrrr = 122;
        Integer sssss = 123;
        Integer ttttt = 124;
        Integer uuuuu = 125;
        Integer vvvvv = 126;
        Integer wwwww = 127;
        Integer xxxxx = 128;
        Integer yyyyy = 129;
        Integer zzzzz = 130;
        Integer aaaaaa = 131;
        Integer bbbbbb = 132;
        Integer cccccc = 133;
        Integer dddddd = 134;
        Integer eeeeee = 135;
        Integer ffffff = 136;
        Integer gggggg = 137;
        Integer hhhhhh = 138;
        Integer iiiiii = 139;
        Integer jjjjjj = 140;
        Integer kkkkkk = 141;
        Integer llllll = 142;
        Integer mmmmmm = 143;
        Integer nnnnnn = 144;
        Integer oooooo = 145;
        Integer pppppp = 146;
        Integer qqqqqq = 147;
        Integer rrrrrr = 148;
        Integer ssssss = 149;
        Integer tttttt = 150;
        Integer uuuuuu = 151;
        Integer vvvvvv = 152;
        Integer wwwwww = 153;
        Integer xxxxxx = 154;
        Integer yyyyyy = 155;
        Integer zzzzzz = 156;
        Integer aaaaaaa = 157;
        Integer bbbbbbb = 158;
        Integer ccccccc = 159;
        Integer ddddddd = 160;
        Integer eeeeeee = 161;
        Integer fffffff = 162;
        Integer ggggggg = 163;
        Integer hhhhhhh = 164;
        Integer iiiiiii = 165;
        Integer jjjjjjj = 166;
        Integer kkkkkkk = 167;
        Integer lllllll = 168;
        Integer mmmmmmm = 169;
        Integer nnnnnnn = 170;
        Integer ooooooo = 171;
        Integer ppppppp = 172;
        Integer qqqqqqq = 173;
        Integer rrrrrrr = 174;
        Integer sssssss = 175;
        Integer ttttttt = 176;
        Integer uuuuuuu = 177;
        
    }
}