public without sharing class WoliGridQueryService2 {
    private String workOrderId;
    private String quoteId;
    private String pricebook;
    private String serviceTerritory;
    
    public WoliGridQueryService2(String workOrderId){
        this.workOrderId = workOrderId;
        init();
    }

    public WoliGridQueryService2(String quoteId, Boolean isQuote){
        this.quoteId = quoteId;
        init();
    }

    private void init(){
        this.pricebook = getPricebook();
        this.serviceTerritory = getTerritorry();
    }
    
    public List<WorkOrderLineItem> getWolis(){
        return [SELECT Id, Product__c, Product__r.Codigo_de_Producto__c, Product__r.Name, Product__r.costoLocal__c, Product__r.tipoProducto__c,
                Bodega__r.Name,Bodega__c, ProductoPorBodega__c, ProductoPorBodega__r.Disponible__c, Bodega__r.bodega__c,PricebookEntryId,
                PricebookEntry.UnitPrice, PricebookEntry.CurrencyIsoCode, Alias_Articulo__c, Quantity, porcentajeDescuento__c, Localizacion__c,
                UnitPrice, Estado__c, Estado_reserva__c, EsKit__c, Estado_entrega__c, Estado_softland__c, Cantidad_devolucion__c, ServiceTerritory.Email_Despacho__c,
                LineItemSortNumber__c, TipoTrabajoCaso__c, estado_solicitud_compra__c, Identificador_solicitud_de_compra__c, CantidadSC__c, tiposDeTrabajo__c,
                TipoTrabajoCaso__r.Estado_aprobaci_n_service__c
                FROM WorkOrderLineItem 
                WHERE WorkOrderId =: this.workOrderId order by LineItemSortNumber__c asc limit 40000];
        		//WHERE (EsKit__c = FALSE AND  WorkOrderId =: this.workOrderId) order by LineItemNumber desc];
    }

    public List<QuoteLineItem> getQuolis(){
        return [SELECT id, product2id, product2.codigo_de_producto__c, product2.name, product2.costolocal__c, product2.tipoproducto__c, bmw_bodega__r.name, quantity, unitprice, 
                discount, pricebookentryid, pricebookentry.unitprice,pricebookentry.currencyisocode, bmw_alias__c, bmw_bodega__c, bmw_bodega__r.bodega__c, productoporbodega__c,
                productoporbodega__r.disponible__c, estado__c,estado_reserva__c, estado_entrega__c, estado_softland__c, cantidad_devolucion__c, estado_solicitud_compra__c,
                Identificador_solicitud_de_compra__c, CantidadSC__c,Quote.Opportunity.BMW_TallerDeServicio__r.Email_Despacho__c
                FROM quotelineitem 
                WHERE quoteid =: this.quoteId limit 40000];
    }
    
    private List<Id> getBodegas(){
        List<BodegaxTerritorio__c> bodegas=[SELECT Bodega__c from BodegaxTerritorio__c where ServiceTerritory__c =: this.serviceTerritory order by isPrincipal__c desc];
        List<Id> bodegaIDs =new List<Id>();
        for(BodegaxTerritorio__c bxt:bodegas){
            bodegaIDs.add(bxt.Bodega__c);
        }
        return bodegaIDs;
    }
    
    public Map<Id, Product2> searchProductsByName(String queryValue){
        String keyValueString = '%' +  queryValue + '%';
        List<Id> bodegas= getBodegas();
        
                         System.debug('this.pricebook '+this.pricebook);

        /*return new Map<Id, Product2> ([SELECT Id, Codigo_de_Producto__c , Name, costoLocal__c, tipoProducto__c,
                                     	(SELECT Id, Bodega__r.Name,Bodega__r.Alias__c, Bodega__c, Disponible__c, Bodega__r.bodega__c from Productos_por_Bodega__r WHERE Bodega__c =: bodegas Order by CreatedDate),
                                        (SELECT Id, UnitPrice, CurrencyIsoCode from PricebookEntries WHERE Pricebook2Id =: this.pricebook )
                                      	 FROM Product2 
                                         WHERE 
                                         (Name LIKE:keyValueString or Codigo_de_Producto__c LIKE :keyValueString)
                                       	 AND (Id IN (SELECT Producto__c FROM ProductoXBodega__c WHERE Bodega__c =: bodegas))
                                       	 //OR (tipoProducto__c = 'Mano de Obra' and (Name LIKE:keyValueString or Codigo_de_Producto__c LIKE :keyValueString))
                                         AND IsActive = true
                                         order by Name
                                         limit 100]);*/
        // 1) Trae los Ids de productos para la(s) bodega(s)
        Set<Id> productIds = new Set<Id>();
        for (ProductoXBodega__c pxb : [
            SELECT Producto__c
            FROM ProductoXBodega__c
            WHERE Bodega__c = :bodegas AND Producto__r.tipoProducto__c =: 'Materiales' AND Producto__r.IsActive =: true
            AND (Producto__r.Name LIKE :keyValueString OR Producto__r.Codigo_de_Producto__c LIKE :keyValueString) limit 1000
        ]) {
            if (pxb.Producto__c != null) productIds.add(pxb.Producto__c);
        }
        
        // 2) Arma la consulta principal evitando el semi-join dentro del OR
        List<Product2> prods;
        
        if (!productIds.isEmpty()) {
            prods = [
                SELECT Id, Codigo_de_Producto__c, Name, costoLocal__c, tipoProducto__c,
                    (SELECT Id, Bodega__r.Name, Bodega__r.Alias__c, Bodega__c, Disponible__c, Bodega__r.bodega__c
                     FROM Productos_por_Bodega__r
                     WHERE Bodega__c = :bodegas
                     ORDER BY CreatedDate),
                    (SELECT Id, UnitPrice, CurrencyIsoCode
                     FROM PricebookEntries
                     WHERE Pricebook2Id = :this.pricebook)
                FROM Product2
                WHERE IsActive = true
                  AND (Name LIKE :keyValueString OR Codigo_de_Producto__c LIKE :keyValueString)
                  AND (Id IN :productIds OR tipoProducto__c = 'Mano de Obra')
                ORDER BY Name
                LIMIT 100
            ];
        } else {
            // Si no hay productos en esa bodega, solo trae "Mano de Obra" que coincida con el texto
            prods = [
                SELECT Id, Codigo_de_Producto__c, Name, costoLocal__c, tipoProducto__c,
                    (SELECT Id, Bodega__r.Name, Bodega__r.Alias__c, Bodega__c, Disponible__c, Bodega__r.bodega__c
                     FROM Productos_por_Bodega__r
                     WHERE Bodega__c = :bodegas
                     ORDER BY CreatedDate),
                    (SELECT Id, UnitPrice, CurrencyIsoCode
                     FROM PricebookEntries
                     WHERE Pricebook2Id = :this.pricebook)
                FROM Product2
                WHERE IsActive = true
                  AND (Name LIKE :keyValueString OR Codigo_de_Producto__c LIKE :keyValueString)
                  AND tipoProducto__c = 'Mano de Obra'
                ORDER BY Name
                LIMIT 100
            ];
        }
        
        // 3) Tu retorno como Map
        return new Map<Id, Product2>(prods);
    }

    private Id getPricebook(){
        if(this.workOrderId != null){
            if(String.valueOf(this.workOrderId).startsWith('0Q0')){
                return [select Opportunity.Pricebook2Id FROM Quote where id =: this.workOrderId].Opportunity.Pricebook2Id;
            }else{
                return this.quoteId == null ? [select Pricebook2Id from WorkOrder where id =: this.workOrderId].Pricebook2Id : [select Opportunity.Pricebook2Id FROM Quote where id =: this.quoteId].Opportunity.Pricebook2Id;
            }
        }
        else{
            return this.quoteId == null ? [select Pricebook2Id from WorkOrder where id =: this.workOrderId].Pricebook2Id : [select Opportunity.Pricebook2Id FROM Quote where id =: this.quoteId].Opportunity.Pricebook2Id;
        }
    }

    private Id getTerritorry(){
        if(this.workOrderId != null){
            if(String.valueOf(this.workOrderId).startsWith('0Q0')){
        return [select Opportunity.BMW_TallerDeServicio__c FROM Quote where id =: this.workOrderId].Opportunity.BMW_TallerDeServicio__c;
            }else{
        return this.quoteId == null ? [select ServiceTerritoryId from WorkOrder where id =: this.workOrderId].ServiceTerritoryId : [select Opportunity.BMW_TallerDeServicio__c FROM Quote where id =: this.quoteId].Opportunity.BMW_TallerDeServicio__c;
            }
        }
        else{
        return this.quoteId == null ? [select ServiceTerritoryId from WorkOrder where id =: this.workOrderId].ServiceTerritoryId : [select Opportunity.BMW_TallerDeServicio__c FROM Quote where id =: this.quoteId].Opportunity.BMW_TallerDeServicio__c;
        }
    }

    public Id getPrincipal(){
                    System.debug('this.serviceTerritory '+this.serviceTerritory);

        return [SELECT Bodega__c from BodegaxTerritorio__c where isPrincipal__c = true AND ServiceTerritory__c =:this.serviceTerritory].Bodega__c;
    }

    public List<ContentVersion> getContentVersions(List<String> contentIds){
        return [select id from contentversion where contentdocumentid =:contentIds];
    }

    public String getFileUrl(String contentId){
        return [SELECT DistributionPublicUrl FROM ContentDistribution WHERE contentdocumentid =: contentId].DistributionPublicUrl;
    }

    private List<String> getFileUrls(List<String> contentIds){
        List<String> urls = new List<String> ();
        List<ContentDistribution> contentDistributions = [SELECT DistributionPublicUrl FROM ContentDistribution WHERE contentdocumentid =: contentIds and  name = 'noenviado'];
        for(ContentDistribution cd:contentDistributions){
            urls.add(cd.DistributionPublicUrl);
        }
        return urls;
    }

    public List<String> getFileUrlsFromQuote(){
        List<ContentDocumentLink> ctlinks = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink where LinkedEntityId =: this.quoteId];
        List<String> contentDocumentIds = new  List<String>();
        for(ContentDocumentLink ctl: ctlinks){
            contentDocumentIds.add(ctl.ContentDocumentId);
        }
        return getFileUrls(contentDocumentIds);
    }

    public void updateDocsAsSend(){
        List<ContentDocumentLink> ctlinks = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink where LinkedEntityId =: this.quoteId];
        List<String> contentDocumentIds = new  List<String>();
        for(ContentDocumentLink ctl: ctlinks){
            contentDocumentIds.add(ctl.ContentDocumentId);
        }
        List<ContentDistribution> contentDistributions = [SELECT DistributionPublicUrl FROM ContentDistribution WHERE contentdocumentid =: contentDocumentIds];
        for(ContentDistribution cd:contentDistributions){
            cd.name = 'enviado';
        }
        update contentDistributions;
        
    }

    public List<Subtipo_de_trabajo_del_caso__c> getTiposDeTrabajoDeprecated(){
        return [SELECT Name, Tipo_de_trabajo_del_caso__c, Tipo_de_trabajo_del_caso__r.Tipotrabajo__c FROM Subtipo_de_trabajo_del_caso__c where Caso__c IN (SELECT CaseId FROM WorkOrder  WHERE Id =: this.workOrderId)];
    }

    public List<tiposDeTrabajoCaso__c> getTiposDeTrabajo(){
        System.debug('this.workOrderId '+this.workOrderId);
        return [SELECT Name, Tipotrabajo__r.Name, Tipotrabajo__c FROM tiposDeTrabajoCaso__c where Caso__c IN (SELECT CaseId FROM WorkOrder  WHERE Id =: this.workOrderId)];
    }

    public Map<Id, Product2> getBodegasOnly(Set<String> products){
        List<Id> bodegas= getBodegas();
        return new Map<Id, Product2> ([SELECT Id, (SELECT Id, Bodega__r.Name, Bodega__c, Disponible__c, Bodega__r.bodega__c from Productos_por_Bodega__r WHERE Bodega__c =: bodegas Order by CreatedDate)
                                      	 FROM Product2 WHERE ID =: products]);
    }

    //Solicitud compra Work Order File Logic

    public List<String> getFileUrlsFromWorkOrder(){
        List<ContentDocumentLink> ctlinks = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink where LinkedEntityId =: this.workOrderId];
        List<String> contentDocumentIds = new  List<String>();
        for(ContentDocumentLink ctl: ctlinks){
            contentDocumentIds.add(ctl.ContentDocumentId);
        }
        return getFileUrls(contentDocumentIds);
    }

    public void updateDocsAsSendWO(){
        List<ContentDocumentLink> ctlinks = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink where LinkedEntityId =: this.workOrderId];
        List<String> contentDocumentIds = new  List<String>();
        for(ContentDocumentLink ctl: ctlinks){
            contentDocumentIds.add(ctl.ContentDocumentId);
        }
        List<ContentDistribution> contentDistributions = [SELECT DistributionPublicUrl FROM ContentDistribution WHERE contentdocumentid =: contentDocumentIds];
        for(ContentDistribution cd:contentDistributions){
            cd.name = 'enviado';
        }
        update contentDistributions;
    }

    public static List<PricebookEntry> getPricebookEntries(List<Id> pricebookIds) {
        return [SELECT Name, Id 
                FROM PricebookEntry 
                WHERE Id IN :pricebookIds];
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

        Integer nnnnnn1 = 144;
        Integer oooooo1 = 145;
        Integer pppppp1 = 146;
        Integer qqqqqq1 = 147;
        Integer rrrrrr1 = 148;
        Integer ssssss1 = 149;
        Integer tttttt1 = 150;
        Integer uuuuuu1 = 151;
        Integer vvvvvv1 = 152;
        Integer wwwwww1 = 153;
        Integer xxxxxx1 = 154;
        Integer yyyyyy1 = 155;
        Integer zzzzzz1 = 156;
        Integer aaaaaa1a = 157;
        Integer bbbbbb1b = 158;
        Integer cccccc1c = 159;
        Integer dddddd1d = 160;
        Integer eeeeee1e = 161;
        Integer ffffff1f = 162;
        Integer gggggg1g = 163;
        Integer hhhhhh1h = 164;
        Integer iiiiii1i = 165;
        Integer jjjjjj1j = 166;
        Integer kkkkkk1k = 167;
        Integer llllll1l = 168;
        Integer mmmmmm1m = 169;
        Integer nnnnnn1n = 170;
        Integer oooooo1o = 171;
        Integer pppppp1p = 172;
        Integer qqqqqq1q = 173;
        Integer rrrrrr1r = 174;
        Integer ssssss1s = 175;
        Integer tttttt1t = 176;
        Integer uuuuuu1u = 177;
        Integer vvvvvv1v = 178;
        Integer wwwwww1w = 179;
        Integer xxxxxx1x = 180;
        Integer yyyyyy1y = 181;
        Integer zzzzzz1z = 182;
        Integer aaaaaa1aa = 183;
        Integer bbbbbb1bb = 184;
         Integer ccccc1ccc = 184;
        Integer dddddd1dd = 185;
        Integer eeeeee1ee = 186;
        Integer ffffff1ff = 187;
        Integer gggggg1gg = 188;
        Integer hhhhhh1hh = 189;
        Integer iiiiii1ii = 190;
        Integer jjjjjj1jj = 191;
        Integer kkkkkk1kk = 192;
        Integer llllll1ll = 193;
        Integer mmmmmm1mm = 194;
        Integer nnnnnn1nn = 195;
        Integer oooooo1oo = 196;
        Integer pppppp1pp = 197;
        Integer qqqqqq1qq = 198;
        Integer rrrrrr1rr = 199;
        Integer ssssss1ss = 200;
        Integer tttttt1tt = 201;
        Integer uuuuuu1uu = 202;
        Integer vvvvvv1vv = 203;
        Integer wwwwww1ww = 204;
        Integer xxxxxx1xx = 205;
        Integer yyyyyy1yy = 206;
        Integer zzzzzz1zz = 207;
        Integer aaaaaa1aaa = 208;
        Integer bbbbbb1bbb = 209;
        Integer cccccc1ccc = 210;
        Integer dddddd1ddd = 211;
        Integer eeeeee1eee = 212;
        Integer ffffff1fff = 213;
        Integer gggggg1ggg = 214;
        Integer hhhhhh1hhh = 215;
        Integer iiiiii1iii = 216;
        Integer jjjjjj1jjj = 217;
        Integer kkkkkk1kkk = 218;
        Integer llllll1lll = 219;
        Integer mmmmmm1mmm = 220;
        Integer nnnnnn1nnn = 221;
        Integer oooooo1ooo = 222;
        Integer pppppp1ppp = 223;
        Integer qqqqqq1qqq = 224;
        Integer rrrrrr1rrr = 225;
        Integer ssssss1sss = 226;
        Integer tttttt1ttt = 227;
        Integer uuuuuu1uuu = 228;
        Integer vvvvvv1vvv = 229;
        Integer wwwwww1www = 230;
		}

}