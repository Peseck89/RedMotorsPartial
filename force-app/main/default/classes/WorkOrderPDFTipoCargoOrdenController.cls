public with sharing class WorkOrderPDFTipoCargoOrdenController {
    String workOrderId;
    public Workorder workOrder {get;set;}
    public List<tiposDeTrabajoCaso__c> tiposDeTrabajoCaso {get;set;}
    public Map<String,WorkTypeWrapper> works {get;set;}
    public List<String> workList {get;set;}
    public decimal kilometros {get;set;}
	public List<tipoCargo__c> tipoCargos {get;set;}
    public decimal montoManoDeObraReporte {get;set;}
    public decimal montoMaterialesReporte {get;set;}
    public decimal montoSubcontratoReporte {get;set;}
    public decimal montoPinturaReporte {get;set;}
    public decimal montoVariosReporte {get;set;}
    public decimal montoIVAReporte {get;set;}
    public decimal montoTotalReporte {get;set;}
    public Cambio_de_Propietario__c cambioPropietario {get; set;}
    
    public static Map<String,String> tipoActividadMap = new Map<String,String>{
        'recomendado' => '#50b81e',
        'sugerido' => '#f5d52b',
        'necesario' => '#fd0e01'
    };

    public WorkOrderPDFTipoCargoOrdenController(ApexPages.StandardController controller) {
        workOrderId = ApexPages.currentPage().getParameters().get('id');
        works = getWorkTypeList(workOrderId);
        workList = new List<String>();
        workList.addAll(works.keySet());
        workList.sort();
    }

    public Map<String,WorkTypeWrapper> getWorkTypeList(Id workOrderId) {
        Map<String,WorkTypeWrapper> workTypeWrapperMap = new Map<String,WorkTypeWrapper>();

        workOrder = [SELECT Id,CaseId,MarcaFormula__c, BMW_CodigoDeProducto__c,AssetId, OwnerId, Cedula_Propietario__c, Direccion_propietario__c, Telefono_del_contacto__c, Subtotal__c, CurrencyISOCode,
        Marca__c, Modelo__c, VIN__c, Matricula__c, Duration, Tipo_de_Cargo__c, tipoDeGasto__c, WorkOrderNumber, CreatedDate, totalFinal__c,
        Asset.ContactId, Asset.Account.Cedula__c, Asset.Account.ShippingStreet, Asset.Account.Type,Asset.Account.Phone, Asset.Account.PersonMobilePhone,
        Asset.Account.Name,Asset.Account.Pais__c, Asset.Account.Provincia__pr.Name, Asset.Account.Canton__r.Name, Asset.Account.Distrito__r.Name,
        Asset.Account.Barrio__c, Asset.Account.Calle__c, Asset.Account.Direccion_Residencial__c, Asset.Account.Direccion__c,
        Asset.marca__c, Asset.modelo__c, Asset.NumeroDeChasis__c, Asset.numeroDePlaca__c, Nombre_del_propietario__c,Asset.Account.Description,
        Asset.Anio__c, Description, Original_Order__c, montoManoDeObra__c, montoMateriales__c, montoVarios__c, Enderezado__c,
        montoSubcontrato__c,Presupuesto__c, Kilometros__c, Kilometros2__c,Combustible__c,montoPintura__c, IVA__c,Fecha_de_entrega_estimada__c ,Fecha_prevista_de_entrega__c, Fecha_Cita__c, Fecha_de_Apertura__c,
        Fecha_de_Entrada__c,EndDate ,Fecha_de_inscrpcion__c  , Tipo_de_servicio__c, F_Impresi_n__c ,Ampliaci_n__c,Pinturas__c,Eq_Interior__c ,Cambio__c, Motor__c, Comp_Seguros__c , Observaciones__c, Tipo_de_recepci_n__c,
        Asset.Color__c, ContactId, Contact.Email, Contact.Name, ServiceTerritoryId, Tasas__c , B_I__c , Fecha_de_di_gnostico__c, Account.Cliente_Exonerado__c,
       (SELECT Id, Description,CurrencyIsoCode, Duration, Discount, ListPrice, PricebookEntryId, Quantity, Product2.tipoProducto__c, grupo__c, tiposDeTrabajo__c,Product2.CurrencyIsoCode,TipoTrabajoCaso__c,Subtotal,Product2.Name, TotalPrice, aprobado__c, Product2.tipoDeTrabajo__c, Alias_Articulo__c, Producto_OR_Alias__c,  tipoDeTrabajo__c, porcentajeDescuento__c,  especificacionesTaller__c, Trabajo__c,Product2.Codigo_de_Producto__c,UnitPrice,Priority,TotalDescuento__c
        FROM WorkorderLineItems ORDER BY tiposDeTrabajo__c, especificacionesTaller__c, Trabajo__c)
        FROM Workorder
        WHERE Id =: workorderId];

        if (workOrder == null) {
            return workTypeWrapperMap;
        }

        WorkOrder lastWorkOrder = [Select Id, AssetId, Kilometros__c,Kilometros2__c  From WorkOrder Where AssetId =: workOrder.AssetId AND CaseId =: workOrder.CaseId ORDER BY CreatedDate DESC limit 1];
        kilometros = lastWorkOrder.Kilometros__c;
        
        List<Cambio_de_Propietario__c> cambios = [SELECT Id, Asset__c, Case__c, Cuenta_Anterior__c, Cuenta_Nueva__c, Estado__c
        FROM Cambio_de_Propietario__c WHERE Case__c = :workOrder.CaseId OR Asset__c = :workOrder.AssetId LIMIT 1];

        if (!cambios.isEmpty()) {
         cambioPropietario = cambios[0];
         } else {
         cambioPropietario = null;
         }

        montoManoDeObraReporte = 0.00;
        montoMaterialesReporte = 0.00;
        montoSubcontratoReporte = 0.00;
        montoVariosReporte = 0.00;
        montoPinturaReporte = 0.00;
        String key = '';                
        for (WorkOrderLineItem workOrderLineItem : workOrder.WorkorderLineItems) {
            tipoCargos = [SELECT Id,tipoCargo__c FROM tipoCargo__c WHERE Work_Order_Line_Item__c =: workOrderLineItem.Id
                          AND Tipo_de_Cargo_Formula__c =: workOrder.tipoDeGasto__c];
            if(tipoCargos.size() > 0) {
            tiposDeTrabajoCaso = [SELECT Id, Nombre_TTC__c FROM tiposDeTrabajoCaso__c WHERE Id =: workOrderLineItem.TipoTrabajoCaso__c LIMIT 1];
            	if(tiposDeTrabajoCaso.size() > 0) {
                	key =  tiposDeTrabajoCaso[0].Nombre_TTC__c+ '_' + workOrderLineItem.especificacionesTaller__c;
                	if (!workTypeWrapperMap.containsKey(key)) {
                	workTypeWrapperMap.put(key,new WorkTypeWrapper(tiposDeTrabajoCaso[0].Nombre_TTC__c,tipoActividadMap.get((String) workOrderLineItem.especificacionesTaller__c.toLowercase())));
                	}

                	WorkTypeWrapper workTypeWrapper = workTypeWrapperMap.get(key);
                	if (!workTypeWrapper.workMap.containsKey(workOrderLineItem.Trabajo__c)) {
                    	workTypeWrapper.workMap.put(workOrderLineItem.Trabajo__c, new List<WorkOrderLineItemWrapper>());
                	}
                	List<WorkOrderLineItemWrapper> existingWOLIWrapperList = workTypeWrapper.workMap.get(workOrderLineItem.Trabajo__c);
                	existingWOLIWrapperList.add(new WorkOrderLineItemWrapper(
                    	workOrderLineItem.Producto_OR_Alias__c,                
                    	workOrderLineItem.Priority != null ? workOrderLineItem.Priority : '-',                
                    	workOrderLineItem.Quantity != null ?workOrderLineItem.Quantity : 0,
                    	workOrderLineItem.porcentajeDescuento__c != null ? workOrderLineItem.porcentajeDescuento__c : 0,
                    	workOrderLineItem.TotalPrice != null ?workOrderLineItem.TotalPrice : 0,
                    	workOrderLineItem.Product2.CurrencyIsoCode,
                        workOrderLineItem.Trabajo__c,
                        workOrderLineItem.TotalDescuento__c != null ?workOrderLineItem.TotalDescuento__c : 0
                	));
                	workTypeWrapper.workMap.put(workOrderLineItem.Trabajo__c,existingWOLIWrapperList);
                	workTypeWrapperMap.put(key,workTypeWrapper);
                    if (workOrderLineItem.Trabajo__c == 'Mano de Obra'){
                		montoManoDeObraReporte = montoManoDeObraReporte + workOrderLineItem.TotalDescuento__c;    
                	} else if (workOrderLineItem.Trabajo__c == 'Materiales'){
                		montoMaterialesReporte = montoMaterialesReporte + workOrderLineItem.TotalDescuento__c;    
                	} else if (workOrderLineItem.Trabajo__c == 'Subcontrato'){
                		montoSubcontratoReporte = montoSubcontratoReporte + workOrderLineItem.TotalDescuento__c;    
                	} else if (workOrderLineItem.Trabajo__c == 'Pintura'){
                		montoPinturaReporte = montoPinturaReporte + workOrderLineItem.TotalDescuento__c;    
                	} else if (workOrderLineItem.Trabajo__c == 'Varios'){
                		montoVariosReporte = montoVariosReporte + workOrderLineItem.TotalDescuento__c;    
                	} 
            	}
        	}    
        }
        if( !workOrder.Account.Cliente_Exonerado__c )montoIVAReporte = (montoManoDeObraReporte + montoMaterialesReporte + montoSubcontratoReporte + montoPinturaReporte + montoVariosReporte) * 0.13;
        else montoIVAReporte = 0;
        montoTotalReporte = montoManoDeObraReporte + montoMaterialesReporte + montoSubcontratoReporte + montoPinturaReporte + montoVariosReporte + montoIVAReporte; 
        return workTypeWrapperMap;
    }

    class WorkTypeWrapper {
        public String name {get;set;}
        public String color {get;set;}
        public Map<String,List<WorkOrderLineItemWrapper>> workMap {get;set;}
        WorkTypeWrapper(String name,String color){
            this.name = name;
            this.color = color;
            this.workMap = new Map<String,List<WorkOrderLineItemWrapper>>();
        }
    }
    
    class WorkOrderLineItemWrapper {
        public String productCode {get;set;}
        public String description {get;set;}
        public String priority {get;set;}
        // public String priority {get;set;}
        public Decimal quantity {get;set;}
        public Decimal unitPrice {get;set;}
        public Decimal discount {get;set;}
        public String availability {get;set;}
        public String currencyIsoCode {get;set;}
        public Decimal total {get;set;}
        public String trabajo {get;set;} 
        public Decimal totalDesc{get;set;}

        WorkOrderLineItemWrapper(){

        }

        WorkOrderLineItemWrapper(String description,String priority,Decimal quantity,Decimal discount,Decimal total,String currencyIsoCode,String trabajo,Decimal totalDesc){
            this.description = description;
            this.priority = priority;
            this.quantity = quantity;
            this.unitPrice = total/quantity;
            this.discount = discount;
            this.currencyIsoCode = currencyIsoCode;
            this.total = total;
            this.trabajo = trabajo; 
            this.totalDesc = totalDesc;
        }
    }
    /*public static void metodoDummy(){
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
    }*/
}