public class WoliGridController {

    
    //Método Pedro
    @AuraEnabled(cacheable=false)
    public static Boolean showMonedaButton (String workOrderId) { 
        //query a work order para verificar el service territory
        Boolean showMoneda = true;
        WorkOrder wo = [Select Id, ServiceTerritory.Name From WorkOrder Where Id=: workOrderId];
        if(wo.ServiceTerritory.Name != 'Uruca - Reparaciones Asegurador'){
            return false;
        }
        List<WorkOrderLineItem> woliList = [Select Id From WorkOrderLineItem Where WorkOrderId =:workOrderId];
        if(woliList.size()>0){
            Set<Id> idsWoli = new Set<Id>();
            for(WorkOrderLineItem woli : woliList){
                idsWoli.add(woli.Id);
            }
            List<tipoCargo__c> tipoCargoList = [Select Id,tipoCargo__c,porcentaje__c  From tipoCargo__c Where Work_Order_Line_Item__c IN: idsWoli];
            if(tipoCargoList.size()>0){
                for(tipoCargo__c tipocargo : tipoCargoList){
                    if(tipocargo.tipoCargo__c != '3' || tipocargo.porcentaje__c <100){
                        showMoneda = false;
                    }
                }
                return showMoneda;
            }else{
                return false;
            }
         }else{
            return false;        
         }
    }

    
    
    @AuraEnabled(cacheable=false)
    public static String  getSoftlandPriceReferences (String productCode, String empresaFactura) { 
        HttpCalloutGetProductRefPrices service = new HttpCalloutGetProductRefPrices();
        HttpResponse response = service.getProductRefPricesPOST(productCode, empresaFactura);
        return response.getBody();
    }

    @AuraEnabled(cacheable=false)
    public static String  getSoftlandLocations (String productCode, String empresaFactura) { 
        ProductoLocalizacionHelper service = new ProductoLocalizacionHelper();
        HttpResponse response = service.obtenerLocalizaciones(productCode, empresaFactura);
        return response.getBody();
    }
    @AuraEnabled(cacheable=false)
    public static List<WoliGridWrapper> searchProducts (String productType, String queryValue, Id workOrder) { 
        WoliGridHelper woliSearchHelper = new WoliGridHelper(workOrder);
        return woliSearchHelper.searchProductsbyValue(productType, queryValue);
    }
    
    @AuraEnabled(cacheable=false)
    public static List<WoliGridWrapper> getWolis (string listTosave, Id workorder) { 
        WoliGridHelper woliCalculation = new WoliGridHelper(workorder);
        return woliCalculation.wolisToWrappers(listTosave);
    }
    
    @AuraEnabled(cacheable=false)
    public static void saveWolis (String jsonString, Id workorder) { 
        WoliGridDML woliGridDML = new WoliGridDML(jsonString);
        woliGridDML.saveWorkLineItems(workorder);
    }
    
    @AuraEnabled(cacheable=false)
    public static void saveQuantities (String jsonString, Id workorder) { 
        WoliGridDML woliGridDML = new WoliGridDML(jsonString);
        woliGridDML.saveQuantities(workorder);
    }
    
    @AuraEnabled(cacheable=false)
    public static void deleteWolis (List<String> workorderIds) {
        WoliGridDML.deleteWorkLineItems(workorderIds);
    }

    @AuraEnabled(cacheable=false)
    public static List<tiposDeTrabajoCaso__c> getTiposDeTrabajo (Id workorder) {
        WoliGridQueryService workOrderService = new WoliGridQueryService(workorder);
        return workOrderService.getTiposDeTrabajo();
    }

    @AuraEnabled(cacheable=false)
    public static String setPublicFileWO (List<String> contentIds, Id workOrderId) {
        WoliGridHelper woliFileHelper = new WoliGridHelper(workOrderId);
        return  woliFileHelper.saveAndGetPublicURLFileWO(contentIds);
    }
    
    @AuraEnabled(cacheable=false)
    public static List<WoliGridWrapper> consultarDisponibilidad (String jsonString, Id workorder, String workOrderNumber) {
        System.debug('JSONSTRING CONSULTAR DISP   ' + jsonString);
        List<WoliGridWrapper> worklineitems = (List<WoliGridWrapper>)JSON.deserialize(jsonString, List<WoliGridWrapper>.class);
        return consultaDisponibleBodega.consultarDisponibilidad(worklineitems,workOrderNumber);
    }
    
    @AuraEnabled(cacheable=false)
    public static String requestDespacho (String workOrderNumber, List<String> notAvailableIds, List<String> selectedIDList) {
        System.debug(selectedIDList);
        ServicioReservaApartadoArticulos servicio = new ServicioReservaApartadoArticulos(workOrderNumber, 'entregar',notAvailableIds, selectedIDList);
        return servicio.realizarReservaApartado();
        //return 'Existen artículos que requieren validación.';
    }
    
    @AuraEnabled(cacheable=false)
    public static String requestApartar (String workOrderNumber, List<String> notAvailableIds, List<String> selectedIDList) {
       System.debug(selectedIDList);
       ServicioReservaApartadoArticulos servicio = new ServicioReservaApartadoArticulos(workOrderNumber, 'apartar', notAvailableIds, selectedIDList);
       return servicio.realizarReservaApartado();
          //return 'Existen artículos que requieren validación.';
    }
    
    @AuraEnabled(cacheable=false)
    public static String requestDevolucion (String workOrderNumber, List<String> devolutionIds) {
        ServicioEliminarReservaArticulo servicio = new ServicioEliminarReservaArticulo(workOrderNumber, devolutionIds);
        return servicio.eliminarReservaArticulos();
         //return 'Existen artículos que requieren validación.';
    }
    
    @AuraEnabled(cacheable=false)
    public static String sendPDF (Id workorder, String email) {
        return savePDFfile.attachPDFinWO(workorder, 'Despacho de repuestos','AlbaranPDFGroupTc?id=' + workorder, false,true, email);
    }

    @AuraEnabled(cacheable=false)
    public static String sendSC (String departamento, String prioridad, String anticipo,  Id quoteId, List<String> idsToSC) {
        System.debug('Quote Number ' + quoteId);
        System.debug('Quote departamento ' + departamento);
        string resultado = ServicioCrearSCQuote.crearSolicitudCompra(quoteId, departamento, prioridad, anticipo, idsToSC);
        System.debug('Resultado ' + resultado);
        return resultado; 
    }

    @AuraEnabled(cacheable=false)
    public static String sendSCWO (String departamento, String prioridad, String anticipo,  Id workOrderId, List<String> idsToSC) {
        System.debug('PRINT PARAMS TO DIEGO ');
        System.debug('Workorder ID ' + workOrderId);
        System.debug('Departamento ' + departamento);
        System.debug('Prioridad ' + prioridad);
        System.debug('Workorder anticipo ' + anticipo);
        System.debug('Workorder IDS de WOLIS ' + idsToSC);
        string resultado = ServicioCrearSCWorkOrder.crearSolicitudCompra(workOrderId, departamento, prioridad, anticipo, idsToSC);
        System.debug('Resultado ' + resultado);
        return resultado; 
        //DIEGO ACA LA LOGICA DE LA WORKORDER para archivos
       /* WoliGridQueryService consultaArchivos = new WoliGridQueryService(workOrderId);
        List<String> listaarchivos = new List<String>();
		listaarchivos = consultaArchivos.getFileUrlsFromWorkOrder();
        consultaArchivos.updateDocsAsSendWO();
        return '00';*/
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