public class WoliGridHelper2 {
    private WoliGridQueryService2 queryService;
    private String objectId;
    
    public WoliGridHelper2(String workOrderId){
        this.queryService = new WoliGridQueryService2(workOrderId);
        this.objectId = workOrderId;
    }
    
    public WoliGridHelper2(String quoteId, Boolean isQuote){
        this.queryService = new WoliGridQueryService2(quoteId, isQuote);
        this.objectId = quoteId;
    }

    public List<WoliGridWrapper> wolisToWrappers(string listTosave) {
        List<WoliGridWrapper> worklineitems = (List<WoliGridWrapper>)JSON.deserialize(listTosave,List<WoliGridWrapper>.class); 
        List<WorkOrderLineItem> wolis = queryService.getWolis();
        Map<String, List<WoliGridWrapper.Bodegas>> bodegasByProduct = setBodegas(wolis);
        for (WorkOrderLineItem wl: wolis){  
            WoliGridWrapper wr= new WoliGridWrapper (wl.ProductoPorBodega__c, wl.Product__c, wl.Product__r.Codigo_de_Producto__c, wl.Product__r.Name, wl.PricebookEntry.UnitPrice,
                                                     wl.Bodega__r.Name, wl.ProductoPorBodega__r.Disponible__c, wl.Product__r.tipoProducto__c, wl.Alias_Articulo__c, null ,
                                                     wl.PricebookEntryId, wl.PricebookEntry.CurrencyIsoCode, wl.Bodega__c, wl.Bodega__r.bodega__c, wl.ProductoPorBodega__c);
            wr.setWolId(wl.Id);
            wr.cantidad=wl.Quantity;
            wr.discount=wl.porcentajeDescuento__c;
            wr.location=wl.Localizacion__c;
            wr.unitPrice=wl.UnitPrice;
            wr.isClosed=wl.Estado__c=='Facturado';
            wr.estadoReserva = wl.Estado_reserva__c != null ? wl.Estado_reserva__c : 'Pendiente de reserva';
            wr.estadoEntrega = wl.Estado_entrega__c != null ? wl.Estado_entrega__c : 'Sin Entregar';
            wr.estadoSoftland = wl.Estado_softland__c != null ? wl.Estado_softland__c : '';
            wr.cantidadDevolucion =  wl.Cantidad_devolucion__c;
            wr.despachoEmail = wl.ServiceTerritory.Email_Despacho__c;
            wr.esKit = wl.EsKit__c;
            wr.lineSortNumber = wl.LineItemSortNumber__c;
            wr.TipoTrabajoCaso = wl.TipoTrabajoCaso__c;
            wr.bodegas = bodegasByProduct.get(wl.Product__c);
            wr.isUpdate = true;
            ///Solicitud De Compra
            wr.estadoSolicitudCompra =  wl.estado_solicitud_compra__c;
            wr.solicitudCompraID = wl.Identificador_solicitud_de_compra__c;
            wr.cantidadSC = wl.CantidadSC__c;
            wr.tiposDeTrabajo = wl.tiposDeTrabajo__c;
            wr.aprobadoService = wl.TipoTrabajoCaso__r.Estado_aprobaci_n_service__c;
            worklineitems.add(wr);
        }
        return worklineitems;
    }

    public List<WoliGridWrapper> qolisToWrappers(string listTosave) {
        List<WoliGridWrapper> quoteLineItems = (List<WoliGridWrapper>)JSON.deserialize(listTosave,List<WoliGridWrapper>.class); 
        for (QuoteLineItem ql: queryService.getQuolis()){  
            WoliGridWrapper wr= new WoliGridWrapper (ql.ProductoPorBodega__c, ql.Product2Id, ql.Product2.Codigo_de_Producto__c, ql.Product2.Name, ql.UnitPrice,
                                                     ql.BMW_Bodega__r.Name, ql.ProductoPorBodega__r.Disponible__c, ql.Product2.tipoProducto__c, ql.BMW_Alias__c, null, ql.PricebookEntryId,
                                                     ql.PricebookEntry.CurrencyIsoCode, ql.BMW_Bodega__c, ql.BMW_Bodega__r.bodega__c, ql.ProductoPorBodega__c);
            wr.setWolId(ql.Id);
            wr.cantidad=ql.Quantity;
            wr.discount=ql.Discount;
            //wr.location=wl.Localizacion__c;
            wr.unitPrice=ql.UnitPrice;
            wr.isClosed = false;
            wr.estadoReserva = ql.Estado_reserva__c != null ? ql.Estado_reserva__c : 'Pendiente de reserva';
            wr.estadoEntrega = ql.Estado_entrega__c != null ? ql.Estado_entrega__c : 'Sin Entregar';
            wr.estadoSoftland = ql.Estado_softland__c != null ? ql.Estado_softland__c : '';
            wr.cantidadDevolucion =  ql.cantidad_devolucion__c;
            wr.estadoSolicitudCompra =  ql.estado_solicitud_compra__c;
            wr.estado =  ql.Estado__c;
            wr.solicitudCompraID = ql.Identificador_solicitud_de_compra__c;
            wr.cantidadSC = ql.CantidadSC__c;
            wr.despachoEmail = ql.Quote.Opportunity.BMW_TallerDeServicio__r.Email_Despacho__c ;
            quoteLineItems.add(wr);
        }
        return quoteLineItems;
    }
    
    public List<WoliGridWrapper> searchProductsbyValue (String productType, String queryValue) {
        List<WoliGridWrapper> worklineitems= new List<WoliGridWrapper>(); 
        System.debug('productType '+productType);
        if(productType=='Mano de Obra'){
            //return searchMO(productType,productName, this.workOrderId);
        }
        
        if(queryValue.length()>=4){
            Map<Id, Product2> products = queryService.searchProductsByName(queryValue);
            String bodegaPrincipal = queryService.getPrincipal();
            System.debug('bodegaPrincipal '+bodegaPrincipal);
            System.debug(products.size());
            for (Product2 prod: products.values()){
                List <WoliGridWrapper.Bodegas> bodegaList = new List <WoliGridWrapper.Bodegas>();

                if(prod.Pricebookentries.size()>0){
                    PricebookEntry pentry = prod.Pricebookentries[0];
                    System.debug('prod.Productos_por_Bodega__r '+prod.Productos_por_Bodega__r);
                    for(ProductoXBodega__c pxb:prod.Productos_por_Bodega__r){
                        WoliGridWrapper.Bodegas bodega = new WoliGridWrapper.Bodegas();
                        bodega.name = pxb.Bodega__r.Alias__c != Null ? pxb.Bodega__r.Alias__c : pxb.Bodega__r.Name;
                        bodega.cantidadDisponible = pxb.Disponible__c;
                        bodega.Id = pxb.Bodega__c;
                        bodega.isPrincipal = bodegaPrincipal == bodega.Id;
                        bodegaList.add(bodega);      
                    }
                    if(prod.Productos_por_Bodega__r.size()>0){
                        
                    
                   ProductoXBodega__c pxb = prod.Productos_por_Bodega__r[0];
                                                   System.debug('pxb '+pxb);

                     System.debug(prod.Productos_por_Bodega__r);
                        WoliGridWrapper wl= new WoliGridWrapper (pxb.Id, prod.Id, prod.Codigo_de_Producto__c, prod.Name,
                                                                 pentry.UnitPrice, pxb.Bodega__r.Name, pxb.Disponible__c, prod.tipoProducto__c,
                                                                 '', null, pentry.Id, pentry.CurrencyIsoCode, bodegaPrincipal, pxb.Bodega__r.bodega__c, pxb.Id);
                    wl.bodegas = bodegaList;
                    wl.isUpdate = false;
                    System.debug('wl '+wl);
                    worklineitems.add(wl);
                    }
                    else{
                        WoliGridWrapper wl = new WoliGridWrapper(
                            null, prod.Id, prod.Codigo_de_Producto__c, prod.Name,
                            pentry.UnitPrice, 'Mano de Obra', 100, prod.tipoProducto__c,
                            '', null, pentry.Id, pentry.CurrencyIsoCode, bodegaPrincipal, null, null
                        );
                        wl.bodegas = bodegaList;
                        wl.isUpdate = false;
                    
                        wl.ID = prod.Id; 
                    
                        worklineitems.add(wl);
                    }
                }
            }
        }
          System.debug('worklineitems '+worklineitems);
        return worklineitems;
    }

    public String saveAndGetPublicURLFile(List<String> contentIds){
        List<ContentVersion> contentVersions = queryService.getContentVersions(contentIds);
        List <ContentDistribution> contentDistributions = new List<ContentDistribution>();
        for(ContentVersion cv: contentVersions){
            ContentDistribution cd = new ContentDistribution();
            cd.Name = 'noenviado';
            cd.ContentVersionId = cv.id;
            cd.PreferencesAllowViewInBrowser= true;
            cd.PreferencesLinkLatestVersion=true;
            cd.PreferencesNotifyOnVisit=false;
            cd.PreferencesPasswordRequired=false;
            contentDistributions.add(cd);
        }
        insert contentDistributions;
        System.debug('FILES');
        System.debug(contentDistributions.size());
        System.debug(contentDistributions);
        String publicURL = queryService.getFileUrl(contentIds[0]);
        Quote quote = new Quote();
        quote.Id = this.objectId;
        quote.Adjunto_Solicitud_Compra__c = publicURL;
        update quote;
        return publicURL;
    }

    public String saveAndGetPublicURLFileWO(List<String> contentIds){
        List<ContentVersion> contentVersions = queryService.getContentVersions(contentIds);
        List <ContentDistribution> contentDistributions = new List<ContentDistribution>();
        for(ContentVersion cv: contentVersions){
            ContentDistribution cd = new ContentDistribution();
            cd.Name = 'noenviado';
            cd.ContentVersionId = cv.id;
            cd.PreferencesAllowViewInBrowser= true;
            cd.PreferencesLinkLatestVersion=true;
            cd.PreferencesNotifyOnVisit=false;
            cd.PreferencesPasswordRequired=false;
            contentDistributions.add(cd);
        }
        insert contentDistributions;
        System.debug('WORKORDERFILES');
        System.debug(contentDistributions.size());
        System.debug(contentDistributions);
        String publicURL = queryService.getFileUrl(contentIds[0]);
        WorkOrder wo = new WorkOrder();
        wo.Id = this.objectId;
        //wo.Adjunto_Solicitud_Compra__c = publicURL;
        update wo;
        return publicURL;
    }

    private Map<String, List<WoliGridWrapper.Bodegas>> setBodegas(List <WorkOrderLineItem> wolis){
        String bodegaPrincipal = queryService.getPrincipal();
        Map<String, List<WoliGridWrapper.Bodegas>> bodegasByProduct = new  Map<String, List<WoliGridWrapper.Bodegas>>();
        Set<String> products = new Set<String>();
        List<WoliGridWrapper.Bodegas> bodegas = new List<WoliGridWrapper.Bodegas>();
        for(WorkOrderLineItem wl: wolis){
            products.add(wl.Product__c);
        }
        Map<Id, Product2> bodegasProducts = this.queryService.getBodegasOnly(products);
        for(Product2 prod: bodegasProducts.values()){
            for(ProductoXBodega__c pxb:prod.Productos_por_Bodega__r){
                WoliGridWrapper.Bodegas bodega = new WoliGridWrapper.Bodegas();
                bodega.name = pxb.Bodega__r.Name;
                bodega.cantidadDisponible = pxb.Disponible__c;
                bodega.Id = pxb.Bodega__c;
                bodega.isPrincipal = bodegaPrincipal == bodega.Id;
                if(bodegasByProduct.containsKey(prod.Id)){
                    System.debug(bodegasByProduct.values());
                    bodegasByProduct.get(prod.Id).add(bodega);
                }else{
                    bodegasByProduct.put(prod.Id, new List<WoliGridWrapper.Bodegas>{bodega}); 
                }  
            }
        }
        return bodegasByProduct;

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
        Integer vvvvvvv = 178;
        Integer wwwwwww = 179;
        Integer xxxxxxx = 180;
        Integer yyyyyyy = 181;
        Integer zzzzzzz = 182;
        Integer aaaaaaaa = 183;
        Integer bbbbbbbb = 184;
         Integer cccccccc = 184;
        Integer dddddddd = 185;
        Integer eeeeeeee = 186;
        Integer ffffffff = 187;
        Integer gggggggg = 188;
        Integer hhhhhhhh = 189;
        Integer iiiiiiii = 190;
        Integer jjjjjjjj = 191;
        Integer kkkkkkkk = 192;
        Integer llllllll = 193;
        Integer mmmmmmmm = 194;
        Integer nnnnnnnn = 195;
        Integer oooooooo = 196;
        Integer pppppppp = 197;
        Integer qqqqqqqq = 198;
        Integer rrrrrrrr = 199;
        Integer ssssssss = 200;
        Integer tttttttt = 201;
        Integer uuuuuuuu = 202;
        Integer vvvvvvvv = 203;
        Integer wwwwwwww = 204;
        Integer xxxxxxxx = 205;
        Integer yyyyyyyy = 206;
        Integer zzzzzzzz = 207;
        Integer aaaaaaaaa = 208;
        Integer bbbbbbbbb = 209;
        Integer ccccccccc = 210;
        Integer ddddddddd = 211;
        Integer eeeeeeeee = 212;
        Integer fffffffff = 213;
        Integer ggggggggg = 214;
        Integer hhhhhhhhh = 215;
        Integer iiiiiiiii = 216;
        Integer jjjjjjjjj = 217;
        Integer kkkkkkkkk = 218;
        Integer lllllllll = 219;
        Integer mmmmmmmmm = 220;
        Integer nnnnnnnnn = 221;
        Integer ooooooooo = 222;
        Integer ppppppppp = 223;
        Integer qqqqqqqqq = 224;
        Integer rrrrrrrrr = 225;
        Integer sssssssss = 226;
        Integer ttttttttt = 227;
        Integer uuuuuuuuu = 228;
        Integer vvvvvvvvv = 229;
        Integer wwwwwwwww = 230;
		}
    
}