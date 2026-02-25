public class precioProductoJSON {
    public static String createProduct(String jsonStr) 
    {
        JSONGenerator gen = JSON.createGenerator(False);

        productRequestJSON wrapProductJSON = productRequestJSON.parsePropuesta(jsonStr);
        String articulo = wrapProductJSON.articulo;
        String precio_local = wrapProductJSON.precio_local;
        String precio_dolar = wrapProductJSON.precio_dolar;
        String costo_local = wrapProductJSON.costo_local;
        String costo_dolar = wrapProductJSON.costo_dolar;
        String precio_empleado = wrapProductJSON.precio_empleado;
        String empresa = wrapProductJSON.empresa;
        
        
        String Porcentaje_vendedor = wrapProductJSON.Porcentaje_vendedor;
        String Porcentaje_jefe = wrapProductJSON.Porcentaje_jefe;
        
        try
        {  
            List<Product2> prod;
            if(empresa=='RMBAVARIAN')
            {
            	prod =     [
                                        SELECT Id
                                        FROM Product2
                                        WHERE Codigo_de_Producto__c = :articulo
                                    ];    
            }
            else if(empresa=='RMOTOBAI') {
                String identificador = articulo+'-'+empresa;
                prod =     [
                                        SELECT Id
                                        FROM Product2
                                        WHERE CodigoProductoInterno__c = :identificador
                                    ];
            }
            
            if(prod.size()!=0)
            {
                Product2 actualProduct = prod[0];
                actualProduct.Codigo_de_Producto__c =articulo;
                actualProduct.costoLocal__c =  Decimal.valueOf(precio_local);
                actualProduct.precio__c =  Decimal.valueOf(precio_dolar);
                update actualProduct;
                List<Pricebook2> standardPB = [SELECT Id,Name FROM Pricebook2 WHERE IsStandard=true];
                List<Pricebook2> priceBooksLocal;
                List<Pricebook2> priceBooksDolar;
                
                if(empresa == 'RMBAVARIAN')
                {
					priceBooksLocal = [SELECT Id,Name FROM Pricebook2 WHERE Name='Bavarian Local'];
                    priceBooksDolar = [SELECT Id,Name FROM Pricebook2 WHERE Name='Bavarian Dólar'];                    
                } else if(empresa == 'RMOTOBAI')
                {
                    priceBooksLocal = [SELECT Id,Name FROM Pricebook2 WHERE Name='Otobai Local'];
                    priceBooksDolar = [SELECT Id,Name FROM Pricebook2 WHERE Name='Otobai Dólares'];
                }
                                
                List<PricebookEntry> lstPBE = [SELECT Id FROM PricebookEntry WHERE product2Id = :actualProduct.Id AND Pricebook2Id=:standardPB[0].Id];
                
                if(lstPBE.size()!=0)
                {    
                    lstPBE[0].UnitPrice = Decimal.valueOf(precio_local);
                    update lstPBE;
                } else {
                    PricebookEntry pbe = new PricebookEntry();
                    pbe.UnitPrice = actualProduct.costoLocal__c;
                    pbe.Pricebook2Id = standardPB[0].Id;
                    pbe.product2Id = actualProduct.Id;
                    pbe.isActive = true;
                    pbe.priceBookEntryId__c = standardPB[0].Name+'-'+actualProduct.Id;
                    insert pbe;
                }
                
                List<PricebookEntry> lstPBElocal = [SELECT Id FROM PricebookEntry WHERE product2Id = :actualProduct.Id AND Pricebook2Id=:priceBooksLocal[0].Id];
                List<PricebookEntry> lstPBEDolar = [SELECT Id FROM PricebookEntry WHERE product2Id = :actualProduct.Id AND Pricebook2Id=:priceBooksDolar[0].Id];
                if(lstPBELocal.size()!=0)
                {
                    lstPBELocal[0].UnitPrice = Decimal.valueOf(precio_local);
                    lstPBELocal[0].Costo_Fijo__c = Decimal.valueOf(costo_local);
                    lstPBELocal[0].precio_empleado__c =  Decimal.valueOf(precio_empleado);
                    lstPBELocal[0].Vendedor__c = (Porcentaje_vendedor != null) ? Decimal.valueOf(Porcentaje_vendedor) : 0;
                    lstPBELocal[0].Jefe__c = (Porcentaje_jefe != null) ? Decimal.valueOf(Porcentaje_jefe) : 0;
                    update lstPBELocal;

                    lstPBEDolar[0].UnitPrice = Decimal.valueOf(precio_dolar);
                    lstPBEDolar[0].Costo_Fijo__c = Decimal.valueOf(costo_dolar);
                    lstPBEDolar[0].precio_empleado__c =  Decimal.valueOf(precio_empleado);
                    lstPBEDolar[0].Vendedor__c = (Porcentaje_vendedor != null) ? Decimal.valueOf(Porcentaje_vendedor) : 0;
                    lstPBEDolar[0].Jefe__c = (Porcentaje_jefe != null) ? Decimal.valueOf(Porcentaje_jefe) : 0;
                    update lstPBEDolar;
                } else {
                    PricebookEntry pbe = new PricebookEntry();
                    pbe.UnitPrice = Decimal.valueOf(precio_local);
                    pbe.Costo_Fijo__c = Decimal.valueOf(costo_local);
                    pbe.precio_empleado__c =  Decimal.valueOf(precio_empleado);
                    pbe.Pricebook2Id = priceBooksLocal[0].Id;
                    pbe.product2Id = actualProduct.Id;
                    pbe.isActive = true;
                    pbe.priceBookEntryId__c = priceBooksLocal[0].Name+'-'+actualProduct.Id;
                    pbe.Vendedor__c = (Porcentaje_vendedor != null) ? Decimal.valueOf(Porcentaje_vendedor) : 0;
                    pbe.Jefe__c = (Porcentaje_jefe != null) ? Decimal.valueOf(Porcentaje_jefe) : 0;
                    
                    //newProduct.pasajeros__c=  (pasajeros != null) ? Decimal.valueOf(pasajeros) : 0;
                    // String Porcentaje_vendedor = wrapProductJSON.Porcentaje_vendedor;
        			// String Porcentaje_jefe = wrapProductJSON.Porcentaje_jefe;
                    
                    insert pbe;

                    pbe = new PricebookEntry();
                    pbe.UnitPrice = Decimal.valueOf(precio_dolar);
                    pbe.Costo_Fijo__c = Decimal.valueOf(costo_dolar);
                    pbe.precio_empleado__c =  Decimal.valueOf(precio_empleado);
                    pbe.Pricebook2Id = priceBooksDolar[0].Id;
                    pbe.product2Id = actualProduct.Id;
                    pbe.isActive = true;
                    pbe.priceBookEntryId__c = priceBooksDolar[0].Name+'-'+actualProduct.Id;
                    pbe.Vendedor__c = (Porcentaje_vendedor != null) ? Decimal.valueOf(Porcentaje_vendedor) : 0;
                    pbe.Jefe__c = (Porcentaje_jefe != null) ? Decimal.valueOf(Porcentaje_jefe) : 0;
                    insert pbe;
                }            
                gen.writeStartObject();
                gen.writeFieldName('Solicitud');
                gen.writeStartObject();
                gen.writeStringField('CODIGO', '201');
                gen.writeStringField('RESULT', 'La solicitud fue procesada exitosamente');
                gen.writeEndObject();
                gen.writeEndObject();
            } else {
                gen.writeStartObject();
                gen.writeFieldName('Solicitud');
                gen.writeStartObject();
                gen.writeStringField('CODIGO', '404');
                gen.writeStringField('RESULT', 'No se encontro el articulo '+articulo+' en Salesforce');
                gen.writeEndObject();
                gen.writeEndObject();
            }

        } catch(Exception ex)
        {
            gen = JSON.createGenerator(False);
            gen.writeStartObject();
            gen.writeFieldName('Solicitud');
            gen.writeStartObject();
            gen.writeStringField('CODIGO', '500');
            gen.writeStringField('RESULT', ex.getMessage()+' - '+ex.getLineNumber());
            gen.writeEndObject();
            gen.writeEndObject();
        }

        return gen.getAsString();
    }

    //Deserializador para las nuevas solicitudes
    public class productRequestJSON {
        //Identificador del formulario
        public String articulo;
        public String precio_local;
        public String precio_dolar;
        public String costo_local;
        public String costo_dolar;
        public String empresa;
        public String precio_empleado;
        
        public String Porcentaje_vendedor;
        public String Porcentaje_jefe;
    }

    public static productRequestJSON parsePropuesta(String json) {
        return(productRequestJSON) System.JSON.deserialize(json, productRequestJSON.class);
    }
    
    public static void Method() {
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
        
        }
}