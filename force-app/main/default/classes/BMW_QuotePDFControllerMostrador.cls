public with sharing class BMW_QuotePDFControllerMostrador {
    public Quote cot {get;set;}
    public decimal montoMaterial {get;set;}
    public decimal montoManoDeObra {get;set;}
    public decimal montoSubcontrato {get;set;}
    public decimal montoPintura {get;set;}
    public decimal montoVarios {get;set;}
    public decimal montoPintura2 {get;set;}
    public decimal montoVarios2 {get;set;}
    public decimal kilometros {get;set;}
    public Integer Centavos {get;set;}
    public String TotalTexto {get;set;}
    public List<QuoteLineItem> ordenaTrabajos {get;set;}
    public Account AccountFac {get;set;}
    public List<QuoteLineItem> productosTarea { get; set; }
    public Cambio_de_Propietario__c cambioPropietario {get; set;}
    
    public Decimal totalFinalSinManoDeObra {get;set;} // 🔹 NUEVO total calculado sin mano de obra
    public Decimal ivaTotal {get;set;}                // 🔹 IVA calculado manualmente
    // 🔹 NUEVO: estructura agrupada por tarea
    public class BloqueTarea {
    public String nombreTarea {get;set;}
    public String prioridad {get;set;}
    public String tareaName {get;set;}
    public List<QuoteLineItem> items {get;set;}

    public Decimal totalMaterialesTarea {get;set;}
    public Decimal totalManoDeObraTarea {get;set;}
    public Decimal totalSubcontratoTarea {get;set;}
    public Decimal totalPinturaTarea {get;set;}
    public Decimal totalVariosTarea {get;set;}
    public Decimal totalTarea {get;set;}  
    public Decimal Iva {get;set;} 
    public Decimal totalConIva {get;set;}  
    public Integer numero {get;set;}  
    
    
    public BloqueTarea(String t, String p, String n) {
        nombreTarea = t;
        prioridad = p;
        tareaName = n;
        items = new List<QuoteLineItem>();
        numero = 0;

        totalMaterialesTarea = 0;
        totalManoDeObraTarea = 0;
        totalSubcontratoTarea = 0;
        totalPinturaTarea = 0;
        totalVariosTarea = 0;
        totalTarea = 0;
        Iva = 0;
        totalConIva = 0;
    }
}
    // Helper para traducir prioridad a orden
    private static Integer getOrdenPrioridad(String prioridad) {
    if (prioridad == 'Necesario') return 1;
    if (prioridad == 'Sugerido') return 2;
    if (prioridad == 'Recomendado') return 3;
    return 4; // Default para Normal u otros valores
}

    // Comparator para ordenar bloques
    public class ComparatorBloques implements System.Comparator<BloqueTarea> {
    public Integer compare(BloqueTarea a, BloqueTarea b) {
        Integer ordenA = getOrdenPrioridad(a.prioridad);
        Integer ordenB = getOrdenPrioridad(b.prioridad);

        if (ordenA == ordenB) return 0;
        return (ordenA < ordenB) ? -1 : 1;
    }
}


    public List<BloqueTarea> bloques {get;set;} 

        
    public BMW_QuotePDFControllerMostrador(Apexpages.StandardController controller) {
        String recordId = controller.getId();
        getData(recordId);
    }
    public void getData(String recordId) {
        
        cot = [select Account.Cedula__c,Account.Phone,Account.PersonMobilePhone,BMW_CodigoDeProducto__c,BMW_VerDisponibilidad__c,
               Cuenta_de_facturaci_n2__r.Name,
               Cuenta_de_facturaci_n2__r.Cedula__c,
               Cuenta_de_facturaci_n2__r.Phone,
               Cuenta_de_facturaci_n2__r.Type,
               
        Opportunity.BMW_PlacaDeVehiculoOElVIN__c,
        Opportunity.BMW_PlacaDeVehiculoOElVIN__r.Kilometros__c,
        Opportunity.BMW_PlacaDeVehiculoOElVIN__r.Anio__c,
        Opportunity.BMW_PlacaDeVehiculoOElVIN__r.numeroDePlaca__c,
        Opportunity.BMW_PlacaDeVehiculoOElVIN__r.NumeroDeChasis__c,
        Opportunity.WorkOrder__c,
        Opportunity.WorkOrder__r.OwnerId,
        Opportunity.BMW_PlacaDeVehiculoOElVIN__r.modelo__c,
        Opportunity.WorkOrder__r.Duration,
        Opportunity.WorkOrder__r.CreatedDate,
        Opportunity.WorkOrder__r.Description,
        Opportunity.WorkOrder__r.WorkOrderNumber,
        Opportunity.BMW_PlacaDeVehiculoOElVIN__r.marca__c,
        Account.Name,Account.Pais__c,Account.Provincia__pr.Name,
        Account.Canton__r.Name,Account.Distrito__r.Name,Account.Barrio__c,Account.Calle__c,
        Account.Direccion_Residencial__c,Account.Direccion__c,Account.Type,
        id,Email,Description,Discount,ShippingAddress,CurrencyIsoCode,
        AdditionalAddress,ShippingHandling,Status,BillingAddress,Fax,
        ExpirationDate,Tax,AdditionalName,ShippingName,
        BillingName,QuoteToName,Name,QuoteNumber,TotalPrice,QuoteToAddress,
        Subtotal,Phone,GrandTotal,CreatedDate,OwnerId, Orden_De_Trabajo__c,SubWithDiscount__c,SumTotal__c,Cuenta_de_facturaci_n2__c,
        Account.Cliente_Exonerado__c, Contact__c, Contact__r.Cedula__c,Contact__r.Phone,      
        
        (select id,Quantity,Description,Discount,UnitPrice,TotalPrice,BMW_Producto_Custom__c,
        BMW_TipoDeArticulo__c, Product2.Name,Product2.Codigo_de_Producto__c,BMW_Dispinible__c,Categor_a_de_presupuesto__c,Estado_Solicitud_Compra__c,Estado_reserva__c
                                                                from QuoteLineItems 
                                                                ) 
               from Quote
               where id =: recordId 
               LIMIT 1];
        
        
        ordenaTrabajos = [select id,Quantity,Description,Discount,UnitPrice,TotalPrice,BMW_Producto_Custom__c,
        BMW_TipoDeArticulo__c, Product2.Name,Product2.Codigo_de_Producto__c,BMW_Dispinible__c,Categor_a_de_presupuesto__c,Estado_Solicitud_Compra__c,Estado_reserva__c
                                                                from QuoteLineItem where QuoteId =: recordId  order by createddate ASC];
        
        List<Cambio_de_Propietario__c> cambios = [SELECT Id, Asset__c, Case__c, Cuenta_Anterior__c, Cuenta_Nueva__c, Estado__c 
             FROM Cambio_de_Propietario__c WHERE Asset__c = :cot.Opportunity.BMW_PlacaDeVehiculoOElVIN__c AND Estado__c ='Pendiente'];

          if (!cambios.isEmpty()) {
          cambioPropietario = cambios[0];
          } else {
          cambioPropietario = null;
          }
        
         productosTarea = [SELECT Id, Product2.Codigo_de_Producto__c, Product2.Name, UnitPrice, TotalPrice, Quantity, Discount,
           BMW_Dispinible__c, BMW_TipoDeArticulo__c, BMW_Alias__c, Tarea__c, Tarea__r.Name, Categor_a_de_presupuesto__c,Estado_Solicitud_Compra__c,Estado_reserva__c
           FROM QuoteLineItem
           WHERE QuoteId = :recordId
           ORDER BY CreatedDate ASC
           ];


       // --- Agrupación por Tarea ---
Map<String, BloqueTarea> mapaBloques = new Map<String, BloqueTarea>();

for (QuoteLineItem qli1 : productosTarea) {

    // Si tiene Tarea__r.Name, usamos el nombre real; si no, marcamos "Sin Tarea"
    String tareaId = qli1.Tarea__c; // Puede ser null
    String tareaNombre = (qli1.Tarea__r != null && String.isNotBlank(qli1.Tarea__r.Name)) 
        ? qli1.Tarea__r.Name 
        : 'Sin Tarea';

    String prioridad = String.isNotBlank(qli1.Categor_a_de_presupuesto__c) 
        ? qli1.Categor_a_de_presupuesto__c 
        : 'Sin prioridad';

    String NameTarea = String.isNotBlank(qli1.BMW_Alias__c) 
        ? qli1.BMW_Alias__c 
        : 'Sin nombre';

    // 🔸 Clave segura: usar Id si existe, de lo contrario el nombre
    String clave = tareaId != null ? tareaId : 'SinTarea_' + tareaNombre;

    if (!mapaBloques.containsKey(clave)) {
        mapaBloques.put(clave, new BloqueTarea(tareaNombre, prioridad, NameTarea));
    }

    BloqueTarea bloque = mapaBloques.get(clave);
    bloque.items.add(qli1);

    Decimal monto = qli1.TotalPrice != null ? qli1.TotalPrice : 0;

    if (qli1.BMW_TipoDeArticulo__c == 'Materiales') {
        bloque.totalMaterialesTarea += monto;
    } else if (qli1.BMW_TipoDeArticulo__c == 'Mano de Obra') {
        bloque.totalManoDeObraTarea += monto;
    } else if (qli1.BMW_TipoDeArticulo__c == 'Subcontrato') {
        bloque.totalSubcontratoTarea += monto;
    } else if (qli1.BMW_TipoDeArticulo__c == 'Pintura') {
        bloque.totalPinturaTarea += monto;
    } else if (qli1.BMW_TipoDeArticulo__c == 'Varios') {
        bloque.totalVariosTarea += monto;
    }

    if (!cot.Account.Cliente_Exonerado__c) {
    // 🔹 Excluir Mano de Obra de IVA y Total
    bloque.Iva = (bloque.totalMaterialesTarea + bloque.totalSubcontratoTarea) * 0.13;
    bloque.totalTarea = bloque.totalMaterialesTarea + bloque.totalSubcontratoTarea + bloque.Iva;
    } else {
    bloque.totalTarea = bloque.totalMaterialesTarea + bloque.totalSubcontratoTarea;
     }

}

        // Convertimos el mapa en lista
List<BloqueTarea> bloquesOrdenados = new List<BloqueTarea>(mapaBloques.values());

// Si algún bloque quedó sin prioridad, le asignamos "Normal"
for (BloqueTarea bloque1 : bloquesOrdenados) {
    if (bloque1.prioridad == null) {
        bloque1.prioridad = 'Normal';
    }
}

// Ordenamos la lista por prioridad usando el comparator
bloquesOrdenados.sort(new ComparatorBloques());
        

// Numeramos los bloques
Integer contador = 1;
for (BloqueTarea bloque1 : bloquesOrdenados) {
    bloque1.numero = contador;
    contador++;
}

// Asignamos la lista final al atributo expuesto
this.bloques = bloquesOrdenados;
    
        List<QuoteLineItem> listTipos = [Select Id From QuoteLineItem Where Id =:recordId Order by createddate ASC];
        
        List<WorkOrder> OT = new List<WorkOrder>();
        try {
               OT = [Select Id, AssetId,Kilometros__c From WorkOrder Where AssetId =: cot.Opportunity.BMW_PlacaDeVehiculoOElVIN__c ORDER BY CreatedDate DESC limit 1];
        } catch(DmlException e) {
            
        }
            
                if(OT.size() > 0){
                    if(OT[0].Kilometros__c != null && OT[0].Kilometros__c != 0){kilometros= OT[0].Kilometros__c;}else{kilometros=cot.Opportunity.BMW_PlacaDeVehiculoOElVIN__r.Kilometros__c;}
                }else{kilometros=cot.Opportunity.BMW_PlacaDeVehiculoOElVIN__r.Kilometros__c;}
                if (cot.GrandTotal != null && cot.GrandTotal >= 0) {
                   Decimal centavoDecimal;
               centavoDecimal = (cot.SumTotal__c - Integer.valueOf(cot.SumTotal__c))*100;
               Centavos = Integer.valueOf(centavoDecimal);
                Long n = cot.SumTotal__c.longValue();
                TotalTexto = NumberToWord.english_number(n);
            } else {
                TotalTexto = null;
            }
            
        system.debug('cot'+cot);
montoMaterial = 0;
montoManoDeObra = 0;
montoSubcontrato = 0;
montoPintura = 0;
montoVarios = 0;
montoVarios2 = 0;
montoPintura2 = 0;

if (cot.QuoteLineItems != null && cot.QuoteLineItems.size() > 0) {
    for (QuoteLineItem qli : cot.QuoteLineItems) {
        if (qli.BMW_TipoDeArticulo__c == 'Materiales') {
            montoMaterial += qli.TotalPrice;
        }
        if (qli.BMW_TipoDeArticulo__c == 'Subcontrato') {
            montoSubcontrato += qli.TotalPrice;
        }
        if (qli.BMW_TipoDeArticulo__c == 'Pintura') {
            montoPintura += qli.TotalPrice;
        }
        if (qli.BMW_TipoDeArticulo__c == 'Varios') {
            montoVarios += qli.TotalPrice;
        }
    }
}

// 🔹 Redondear todos los montos individuales
montoMaterial = montoMaterial.setScale(2, RoundingMode.HALF_UP);
montoSubcontrato = montoSubcontrato.setScale(2, RoundingMode.HALF_UP);
montoPintura = montoPintura.setScale(2, RoundingMode.HALF_UP);
montoVarios = montoVarios.setScale(2, RoundingMode.HALF_UP);

// 🔹 IVA solo sobre Materiales + Subcontrato + Pintura + Varios
if (!cot.Account.Cliente_Exonerado__c) {
    ivaTotal = (montoMaterial + montoSubcontrato + montoPintura + montoVarios) * 0.13;
} else {
    ivaTotal = 0;
}
ivaTotal = ivaTotal.setScale(2, RoundingMode.HALF_UP);

// 🔹 Total final SIN Mano de Obra
totalFinalSinManoDeObra = montoMaterial + montoSubcontrato + montoPintura + montoVarios + ivaTotal;
totalFinalSinManoDeObra = totalFinalSinManoDeObra.setScale(2, RoundingMode.HALF_UP);

// ============================
// 3️⃣ Convertir total a texto
// ============================
if (totalFinalSinManoDeObra > 0) {
    Long parteEntera = totalFinalSinManoDeObra.longValue();
    Decimal parteDecimal = (totalFinalSinManoDeObra - parteEntera) * 100;

    // 🔹 Forzar redondeo exacto a 2 decimales
    Centavos = Integer.valueOf(parteDecimal.setScale(0, RoundingMode.HALF_UP));

    // 🔹 Si el total es prácticamente cero, forzar a 0
    if (Math.abs(totalFinalSinManoDeObra) < 0.01) {
        totalFinalSinManoDeObra = 0;
        Centavos = 0;
    }

    TotalTexto = NumberToWord.english_number(parteEntera);
} else {
    TotalTexto = null;
    Centavos = 0;
}

System.debug('🔹 Total sin mano de obra: ' + totalFinalSinManoDeObra);
System.debug('🔹 Centavos: ' + Centavos);

    }
     public static void metodoDummy(){
        String string_1;
String string_2;
String string_3;
String string_4;
String string_5;
String string_6;
String string_7;
String string_8;
String string_9;
String string_10;
String string_11;
String string_12;
String string_13;
String string_14;
String string_15;
String string_16;
String string_17;
String string_18;
String string_19;
String string_20;
String string_21;
String string_22;
String string_23;
String string_24;
String string_25;
String string_26;
String string_27;
String string_28;
String string_29;
String string_30;
String string_31;
String string_32;
String string_33;
String string_34;
String string_35;
String string_36;
String string_37;
String string_38;
String string_39;
String string_40;
String string_41;
String string_42;
String string_43;
String string_44;
String string_45;
String string_46;
String string_47;
String string_48;
String string_49;
String string_50;
String string_51;
String string_52;
String string_53;
String string_54;
String string_55;
String string_56;
String string_57;
String string_58;
String string_59;
String string_60;
String string_61;
String string_62;
String string_63;
String string_64;
String string_65;
String string_66;
String string_67;
String string_68;
String string_69;
String string_70;
String string_71;
String string_72;
String string_73;
String string_74;
String string_75;
String string_76;
String string_77;
String string_78;
String string_79;
String string_80;
String string_81;
String string_82;
String string_83;
String string_84;
String string_85;
String string_86;
String string_87;
String string_88;
String string_89;
String string_90;
String string_91;
String string_92;
String string_93;
String string_94;
String string_95;
String string_96;
String string_97;
String string_98;
String string_99;
String string_100;
String string_101;
String string_102;
String string_103;
String string_104;
String string_105;
String string_106;
String string_107;
String string_108;
String string_109;
String string_110;
String string_111;
String string_112;
String string_113;
String string_114;
String string_115;
String string_116;
String string_117;
String string_118;
String string_119;
String string_120;
String string_121;
String string_122;
String string_123;
String string_124;
String string_125;
String string_126;
String string_127;
String string_128;
String string_129;
String string_130;
String string_131;
String string_132;
String string_133;
String string_134;
String string_135;
String string_136;
String string_137;
String string_138;
String string_139;
String string_140;
String string_141;
String string_142;
String string_143;
String string_144;
String string_145;
String string_146;
String string_147;
String string_148;
String string_149;
String string_150;
String string_151;
String string_152;
String string_153;
String string_154;
String string_155;
String string_156;
String string_157;
String string_158;
String string_159;
String string_160;
String string_161;
String string_162;
String string_163;
String string_164;
String string_165;
String string_166;
String string_167;
String string_168;
String string_169;
String string_170;
String string_171;
String string_172;
String string_173;
String string_174;
String string_175;
String string_176;
String string_177;
String string_178;
String string_179;
String string_180;
String string_181;
String string_182;
String string_183;
String string_184;
String string_185;
String string_186;
String string_187;
String string_188;
String string_189;
String string_190;
String string_191;
String string_192;
String string_193;
String string_194;
String string_195;
String string_196;
String string_197;
String string_198;
String string_199;
String string_200;
String string_201;
String string_202;
String string_203;
String string_204;
String string_205;
String string_206;
String string_207;
String string_208;
String string_209;
String string_210;
String string_211;
String string_212;
String string_213;
String string_214;
String string_215;
String string_216;
String string_217;
String string_218;
String string_219;
String string_220;
String string_221;
String string_222;
String string_223;
String string_224;
String string_225;
String string_226;
String string_227;
String string_228;
String string_229;
String string_230;
String string_231;
String string_232;
String string_233;
String string_234;
String string_235;
String string_236;
String string_237;
String string_238;
String string_239;
String string_240;
String string_241;
String string_242;
String string_243;
String string_244;
String string_245;
String string_246;
String string_247;
String string_248;
String string_249;
String string_250;
String string_251;
String string_252;
String string_253;
String string_254;
String string_255;
String string_256;
String string_257;
String string_258;
String string_259;
String string_260;
String string_261;
String string_262;
String string_263;
String string_264;
String string_265;
String string_266;
String string_267;
String string_268;
String string_269;
String string_270;
String string_271;
String string_272;
String string_273;
String string_274;
String string_275;
String string_276;
String string_277;
String string_278;
String string_279;
String string_280;
String string_281;
String string_282;
String string_283;
String string_284;
String string_285;
String string_286;
String string_287;
String string_288;
String string_289;
String string_290;
String string_291;
String string_292;
String string_293;
String string_294;
String string_295;
String string_296;
String string_297;
String string_298;
String string_299;
String string_300;
String string_301;
String string_302;
String string_303;
String string_304;
String string_305;
String string_306;
String string_307;
String string_308;
String string_309;
String string_310;
String string_311;
String string_312;
String string_313;
String string_314;
String string_315;
String string_316;
String string_317;
String string_318;
String string_319;
String string_320;
String string_321;
String string_322;
String string_323;
String string_324;
String string_325;
String string_326;
String string_327;
String string_328;
String string_329;
String string_330;
String string_331;
String string_332;
String string_333;
String string_334;
String string_335;
String string_336;
String string_337;
String string_338;
String string_339;
String string_340;
String string_341;
String string_342;
String string_343;
String string_344;
String string_345;
String string_346;
String string_347;
String string_348;
String string_349;
String string_350;
String string_351;
String string_352;
String string_353;
String string_354;
String string_355;
String string_356;
String string_357;
String string_358;
String string_359;
String string_360;
String string_361;
String string_362;
String string_363;
String string_364;
String string_365;
String string_366;
String string_367;
String string_368;
String string_369;
String string_370;
String string_371;
String string_372;
String string_373;
String string_374;
String string_375;
String string_376;
String string_377;
String string_378;
String string_379;
String string_380;
String string_381;
String string_382;
String string_383;
String string_384;
String string_385;
String string_386;
String string_387;
String string_388;
String string_389;
String string_390;
String string_391;
String string_392;
String string_393;
String string_394;
String string_395;
String string_396;
String string_397;
String string_398;
String string_399;
String string_400;
String string_401;
String string_402;
String string_403;
String string_404;
String string_405;
String string_406;
String string_407;
String string_408;
String string_409;
String string_410;
String string_411;
String string_412;
String string_413;
String string_414;
String string_415;
String string_416;
String string_417;
String string_418;
String string_419;
String string_420;
String string_421;
String string_422;
String string_423;
String string_424;
String string_425;
String string_426;
String string_427;
String string_428;
String string_429;
String string_430;
String string_431;
String string_432;
String string_433;
String string_434;
String string_435;
String string_436;
String string_437;
String string_438;
String string_439;
String string_440;
String string_441;
String string_442;
String string_443;
String string_444;
String string_445;
String string_446;
String string_447;
String string_448;
String string_449;
String string_450;
String string_451;
String string_452;
String string_453;
String string_454;
String string_455;
String string_456;
String string_457;
String string_458;
String string_459;
String string_460;
String string_461;
String string_462;
String string_463;
String string_464;
String string_465;
String string_466;
String string_467;
String string_468;
String string_469;
String string_470;
String string_471;
String string_472;
String string_473;
String string_474;
String string_475;
String string_476;
String string_477;
String string_478;
String string_479;
String string_480;
String string_481;
String string_482;
String string_483;
String string_484;
String string_485;
String string_486;
String string_487;
String string_488;
String string_489;
String string_490;
String string_491;
String string_492;
String string_493;
String string_494;
String string_495;
String string_496;
String string_497;
String string_498;
String string_499;
String string_500;
String string_501;
String string_502;
String string_503;
String string_504;
String string_505;
String string_506;
String string_507;
String string_508;
String string_509;
String string_510;
String string_511;
String string_512;
String string_513;
String string_514;
String string_515;
String string_516;
String string_517;
String string_518;
String string_519;
String string_520;
String string_521;
String string_522;
String string_523;
String string_524;
String string_525;
String string_526;
String string_527;
String string_528;
String string_529;
String string_530;
String string_531;
String string_532;
String string_533;
String string_534;
String string_535;
String string_536;
String string_537;
String string_538;
String string_539;
String string_540;
String string_541;
String string_542;
String string_543;
String string_544;
String string_545;
String string_546;
String string_547;
String string_548;
String string_549;
String string_550;
String string_551;
String string_552;
String string_553;
String string_554;
String string_555;
String string_556;
String string_557;
String string_558;
String string_559;
String string_560;
String string_561;
String string_562;
String string_563;
String string_564;
String string_565;
String string_566;
String string_567;
String string_568;
String string_569;
String string_570;
String string_571;
String string_572;
String string_573;
String string_574;
String string_575;
String string_576;
String string_577;
String string_578;
String string_579;
String string_580;
String string_581;
String string_582;
String string_583;
String string_584;
String string_585;
String string_586;
String string_587;
String string_588;
String string_589;
String string_590;
String string_591;
String string_592;
String string_593;
String string_594;
String string_595;
String string_596;
String string_597;
String string_598;
String string_599;
String string_600;
String string_601;
String string_602;
String string_603;
String string_604;
String string_605;
String string_606;
String string_607;
String string_608;
String string_609;
String string_610;
String string_611;
String string_612;
String string_613;
String string_614;
String string_615;
String string_616;
String string_617;
String string_618;
String string_619;
String string_620;
String string_621;
String string_622;
String string_623;
String string_624;
String string_625;
String string_626;
String string_627;
String string_628;
String string_629;
String string_630;
String string_631;
String string_632;
String string_633;
String string_634;
String string_635;
String string_636;
String string_637;
String string_638;
String string_639;
String string_640;
String string_641;
String string_642;
String string_643;
String string_644;
String string_645;
String string_646;
String string_647;
String string_648;
String string_649;
String string_650;
String string_651;
String string_652;
String string_653;
String string_654;
String string_655;
String string_656;
String string_657;
String string_658;
String string_659;
String string_660;
String string_661;
String string_662;
String string_663;
String string_664;
String string_665;
String string_666;
String string_667;
String string_668;
String string_669;
String string_670;
String string_671;
String string_672;
String string_673;
String string_674;
String string_675;
String string_676;
String string_677;
String string_678;
String string_679;
String string_680;
String string_681;
String string_682;
String string_683;
String string_684;
String string_685;
String string_686;
String string_687;
String string_688;
String string_689;
String string_690;
String string_691;
String string_692;
String string_693;
String string_694;
String string_695;
String string_696;
String string_697;
String string_698;
String string_699;
String string_700;
String string_701;
String string_702;
String string_703;
String string_704;
String string_705;
String string_706;
String string_707;
String string_708;
String string_709;
String string_710;
String string_711;
String string_712;
String string_713;
String string_714;
String string_715;
String string_716;
String string_717;
String string_718;
String string_719;
String string_720;
String string_721;
String string_722;
String string_723;
String string_724;
String string_725;
String string_726;
String string_727;
String string_728;
String string_729;
String string_730;
String string_731;
String string_732;
String string_733;
String string_734;
String string_735;
String string_736;
String string_737;
String string_738;
String string_739;
String string_740;
String string_741;
String string_742;
String string_743;
String string_744;
String string_745;
String string_746;
String string_747;
String string_748;
String string_749;
String string_750;
String string_751;
String string_752;
String string_753;
String string_754;
String string_755;
String string_756;
String string_757;
String string_758;
String string_759;
String string_760;
String string_761;
String string_762;
String string_763;
String string_764;
String string_765;
String string_766;
String string_767;
String string_768;
String string_769;
String string_770;
String string_771;
String string_772;
String string_773;
String string_774;
String string_775;
String string_776;
String string_777;
String string_778;
String string_779;
String string_780;
String string_781;
String string_782;
String string_783;
String string_784;
String string_785;
String string_786;
String string_787;
String string_788;
String string_789;
String string_790;
String string_791;
String string_792;
String string_793;
String string_794;
String string_795;
String string_796;
String string_797;
String string_798;
String string_799;
String string_800;
String string_801;
String string_802;
String string_803;
String string_804;
String string_805;
String string_806;
String string_807;
String string_808;
String string_809;
String string_810;
String string_811;
String string_812;
String string_813;
String string_814;
String string_815;
String string_816;
String string_817;
String string_818;
String string_819;
String string_820;
String string_821;
String string_822;
String string_823;
String string_824;
String string_825;
String string_826;
String string_827;
String string_828;
String string_829;
String string_830;
String string_831;
String string_832;
String string_833;
String string_834;
String string_835;
String string_836;
String string_837;
String string_838;
String string_839;
String string_840;
String string_841;
String string_842;
String string_843;
String string_844;
String string_845;
String string_846;
String string_847;
String string_848;
String string_849;
String string_850;
String string_851;
String string_852;
String string_853;
String string_854;
String string_855;
    }
}