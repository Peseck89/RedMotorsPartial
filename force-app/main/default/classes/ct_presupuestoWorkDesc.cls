public with sharing class ct_presupuestoWorkDesc {
    
    public String workorderId {get;set;}
    public Workorder worder {get;set;}
    public Quote quotePresu {get;set;}
    public Opportunity oppActual {get;set;}
    public List<ProductConsumed> pcList {get;set;}
    public List<ProductsConsumedWrapper> pcwList {get;set;}
    public List<WorkorderLIGroupWrapper> wliList {get;set;}
    public List<WorkorderGroupWrapper> wtList {get;set;}
    public List<tipoCargo__c> tipoCargo {get;set;}
    
    public Double serviciosAdicionales {get;set;}  
    public Double manodeObra {get;set;}  
    public Double subcontrato {get;set;}  
    public Double materiales  {get;set;}  
    public Double descuento {get;set;}  
    public Double subtotal {get;set;}  
    public Double IV {get;set;}  
    public Double moneda {get;set;}  
    public Double total {get;set;}
    public String TotalTexto {get;set;}
    public Integer Centavos {get;set;}
    public Decimal kilometros {get;set;}
    public Cambio_de_Propietario__c cambioPropietario {get; set;}
    
    // Para el PDF separado por tipo de trabajo
    public List<ProductsConsumedWrapper> itemsWO_MT {get; set;}
    public List<ProductsConsumedWrapper> itemsWO_MO {get; set;}
    public List<ProductsConsumedWrapper> itemsWO_SUB {get; set;}
    
    // ===================== BLOQUES POR TAREA =====================
    public class BloqueTarea {
        public String nombreTarea {get;set;}
        public String prioridad   {get;set;}
        public String tareaName   {get;set;}
        public List<WorkorderLineItem> items {get;set;}
        
        public Decimal totalMaterialesTarea   {get;set;}
        public Decimal totalManoDeObraTarea   {get;set;}
        public Decimal totalSubcontratoTarea  {get;set;}
        public Decimal totalPinturaTarea      {get;set;}
        public Decimal totalVariosTarea       {get;set;}
        public Decimal totalTarea             {get;set;}
        public Decimal Iva                    {get;set;}
        public Decimal totalConIva            {get;set;}
        public String  trabajo                {get;set;}    
        public Integer numero                 {get; set;}    
    
        public BloqueTarea(String t, String p, String n) {
            nombreTarea = t;
            prioridad   = p;
            tareaName   = n;
            items       = new List<WorkorderLineItem>();
            numero      = 0;
            
            totalMaterialesTarea  = 0;
            totalManoDeObraTarea  = 0;
            totalSubcontratoTarea = 0;
            totalPinturaTarea     = 0;
            totalVariosTarea      = 0;
            totalTarea            = 0;
            Iva                   = 0;
            totalConIva           = 0;
        }
    }
    
    public class ComparatorBloques implements System.Comparator<BloqueTarea> {
        public Integer compare(BloqueTarea a, BloqueTarea b) {
            Integer ordenA = getOrdenPrioridad(a.prioridad);
            Integer ordenB = getOrdenPrioridad(b.prioridad);
            
            if (ordenA == ordenB) return 0;
            return (ordenA < ordenB) ? -1 : 1;
        }
    }
    
    // helper prioridad
    private static Integer getOrdenPrioridad(String prioridad) {
        if (prioridad == 'Necesario')   return 1;
        if (prioridad == 'Sugerido')    return 2;
        if (prioridad == 'Recomendado') return 3;
        return 4;
    }
    
    public List<BloqueTarea> bloques {get;set;}
    
    // ======================================================================
    // CONSTRUCTOR
    // ======================================================================
    public ct_presupuestoWorkDesc(ApexPages.StandardController controller) {
        
        workorderId = ApexPages.currentPage().getParameters().get('id');
        
        itemsWO_MT  = new List<ProductsConsumedWrapper>();
        itemsWO_MO  = new List<ProductsConsumedWrapper>();
        itemsWO_SUB = new List<ProductsConsumedWrapper>();
        
        // ================== WORK ORDER PRINCIPAL ==================
        worder = [
            SELECT Id, LocationId, Asesor_de_la_orden__c, MecanicoLider__c, tipoVenta__c, Address, BMW_CodigoDeProducto__c,
                   AssetId, OwnerId, Cedula_Propietario__c, Direccion_propietario__c, Telefono_del_contacto__c, Subtotal__c,
                   CurrencyISOCode, Marca__c, Modelo__c, VIN__c, Matricula__c,MarcaFormula__c, Duration, Tipo_de_Cargo__c,
                   WorkOrderNumber, CreatedDate, totalFinal__c,
                   Asset.ContactId, Asset.Account.Cedula__c, Asset.Account.ShippingStreet, Asset.Account.Type,
                   Asset.Account.Phone, Asset.Account.PersonMobilePhone, Asset.Account.Name,Asset.Account.Pais__c,
                   Asset.Account.Provincia__pr.Name, Asset.Account.Canton__r.Name, Asset.Account.Distrito__r.Name,
                   Asset.Account.Barrio__c, Asset.Account.Calle__c, Asset.Account.Direccion_Residencial__c,
                   Asset.Account.Direccion__c, Asset.marca__c, Asset.modelo__c, Asset.NumeroDeChasis__c,
                   Asset.numeroDePlaca__c, Nombre_del_propietario__c,Asset.Account.Description,
                   Asset.Anio__c, Description, Original_Order__c, montoManoDeObra__c, montoMateriales__c,
                   montoVarios__c, Enderezado__c, montoSubcontrato__c,Presupuesto__c, Kilometros__c,
                   Kilometros2__c,Combustible__c,montoPintura__c, IVA__c,Fecha_de_entrega_estimada__c ,
                   Fecha_prevista_de_entrega__c, Fecha_Cita__c, Fecha_de_Apertura__c, Fecha_de_Entrada__c,EndDate ,
                   Fecha_de_inscrpcion__c, Tipo_de_servicio__c, F_Impresi_n__c ,Ampliaci_n__c,Pinturas__c,Eq_Interior__c ,
                   Cambio__c, Motor__c, Comp_Seguros__c , Observaciones__c, Tipo_de_recepci_n__c,
                   Asset.Color__c, ContactId, Contact.Email, Contact.Name, ServiceTerritoryId, Tasas__c , B_I__c ,
                   Fecha_de_di_gnostico__c, CaseId,tipoDeGasto__c, GrandTotal, Account.Cliente_Exonerado__c,
                   AccountId, Account.Impuesto__r.Impuesto__c,Impuesto__c,Presupuesto_est_ndar_sin_PE__c,
                   Contact.Cedula__c,Account.Cedula__c,Contact.Phone,Cuenta_de_Facturacion__r.Name,Account.Phone,
                   (SELECT Id, Description, Discount, ListPrice, PricebookEntryId, ProductConsumedNumber,
                           QuantityConsumed, QuantityUnitOfMeasure, Subtotal, TotalPrice, UnitPrice,
                           WorkOrderLineItemId, Aprobar__c
                    FROM ProductsConsumed),
                   (SELECT Id, Description, Duration,  Discount, ListPrice, PricebookEntryId, Quantity,
                           Product2.tipoProducto__c, grupo__c, tiposDeTrabajo__c, tiposDeTrabajo__r.Name,
                           Subtotal, TotalPrice, UnitPrice, aprobado__c, Product2.tipoDeTrabajo__c,
                           Product2.Name, Alias_Articulo__c, Producto_OR_Alias__c,  tipoDeTrabajo__c,
                           porcentajeDescuento__c, especificacionesTaller__c, Trabajo__c,
                           Estado_Solicitud_Compra__c,Estado_reserva__c,TareaQuote__c,
                           BMW_CodigoDeProducto__c,Prioridad_de_tarea__c, Precio_Final_Cambio_de_Moneda__c
                    FROM WorkorderLineItems
                    ORDER BY tiposDeTrabajo__c, especificacionesTaller__c, Trabajo__c)
            FROM Workorder
            WHERE Id =: workorderId
        ];
        
        WorkOrder OT = [
            SELECT Id, AssetId,Kilometros__c
            FROM WorkOrder
            WHERE AssetId =: worder.AssetId
              AND CaseId  =: worder.CaseId
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        kilometros = OT.Kilometros__c;
        
        List<Cambio_de_Propietario__c> cambios = [
            SELECT Id, Asset__c, Case__c, Cuenta_Anterior__c, Cuenta_Nueva__c, Estado__c
            FROM Cambio_de_Propietario__c
            WHERE (Case__c = :worder.CaseId OR Asset__c = :worder.AssetId)
              AND Estado__c ='Pendiente'
        ];
        cambioPropietario = cambios.isEmpty() ? null : cambios[0];
        
        Opportunity[] oportunidades = [
            SELECT Id
            FROM Opportunity
            WHERE WorkOrder__c = :workorderId
        ];
        if (!oportunidades.isEmpty()) {
            oppActual  = oportunidades[0];
            quotePresu = [
                SELECT Id,QuoteNumber
                FROM Quote
                WHERE OpportunityId = :oppActual.Id
                LIMIT 1
            ];
        }
        
        serviciosAdicionales = manodeObra = subcontrato =
        materiales         = descuento  = subtotal =
        IV                 = moneda     = total    = 0;
        
        // mapa tipo de cargo (1 = Cliente, 2 = Interno, ...)
        Map<String,String> tipoCargoMap = new Map<String,String>{
            '1' => 'Cliente',
            '2' => 'Interno',
            '3' => 'Aseguradora',
            '4' => 'Garantia',
            '5' => 'BSI',
            '6' => 'BSI Interno'
        };
        
        // ==================================================================
        // MATERIAL (usa totalMercaderia2__c - totalDescuento2__c)
        // ==================================================================
        Decimal montoMaterialTotal   = 0;
        Decimal montoMaterialesExcl  = 0;
        
        for (tipoCargo__c tcMat : [
            SELECT tipoCargo__c,totalDescuento2__c, totalMercaderia2__c,
                   Work_Order_Line_Item__r.Quantity,
                   Work_Order_Line_Item__r.Descuento_Formula__c,
                   Work_Order_Line_Item__r.Localizacion__c,
                   Work_Order_Line_Item__r.CurrencyIsoCode,
                   Work_Order_Line_Item__r.Product2.Codigo_de_Producto__c,
                   Work_Order_Line_Item__r.Producto_OR_Alias__c,
                   Work_Order_Line_Item__r.Estado_Solicitud_Compra__c,
                   Work_Order_Line_Item__r.Estado_reserva__c
            FROM tipoCargo__c
            WHERE Work_Order_Line_Item__r.WorkOrderId = :workorderId
              AND Work_Order_Line_Item__r.Trabajo__c  <> 'Mano de Obra'
              AND Work_Order_Line_Item__r.Trabajo__c  <> 'Subcontrato'
        ]) {
            String tcNombre = tipoCargoMap.get(tcMat.tipoCargo__c);
            if (tcNombre != null &&
                worder.tipoDeGasto__c != null &&
                tcNombre.equalsIgnoreCase(worder.tipoDeGasto__c)) {
                    
                Decimal montoLinea = tcMat.totalMercaderia2__c - tcMat.totalDescuento2__c;
                Decimal unitPrice  = (tcMat.Work_Order_Line_Item__r.Quantity != 0)
                                     ? tcMat.totalMercaderia2__c / tcMat.Work_Order_Line_Item__r.Quantity
                                     : 0;
                
                montoMaterialTotal += montoLinea;
                
                Boolean debeExcluir =
                    tcMat.Work_Order_Line_Item__r.Estado_Solicitud_Compra__c != null &&
                    tcMat.Work_Order_Line_Item__r.Estado_Solicitud_Compra__c != 'Recibido en bodega' &&
                    tcMat.Work_Order_Line_Item__r.Estado_reserva__c           != 'Reservado';
                if (debeExcluir) {
                    montoMaterialesExcl += montoLinea;
                }
                
                itemsWO_MT.add(new ProductsConsumedWrapper(
                    null,
                    null,
                    tcMat.Work_Order_Line_Item__r.Producto_OR_Alias__c,
                    tcMat.Work_Order_Line_Item__r.CurrencyIsoCode,
                    tcMat.Work_Order_Line_Item__r.Quantity,
                    unitPrice,
                    tcMat.Work_Order_Line_Item__r.Descuento_Formula__c,
                    montoLinea,
                    false,
                    tcMat.Work_Order_Line_Item__r.Localizacion__c,
                    tcMat.Work_Order_Line_Item__r.Product2.Codigo_de_Producto__c,
                    tcMat.Work_Order_Line_Item__r.Estado_Solicitud_Compra__c,
                    tcMat.Work_Order_Line_Item__r.Estado_reserva__c
                ));
            }
        }
        
        if (worder.Presupuesto_est_ndar_sin_PE__c) {
            materiales = (montoMaterialTotal - montoMaterialesExcl);
        } else {
            materiales = montoMaterialTotal;
        }
        
        // ==================================================================
        // MANO DE OBRA (usa Precio_Final_Cambio_de_Moneda__c si existe)
        // ==================================================================
        for (tipoCargo__c tcMO : [
            SELECT tipoCargo__c, totalDescuento2__c, totalMercaderia2__c,
                   Work_Order_Line_Item__r.Quantity,
                   Work_Order_Line_Item__r.Descuento_Formula__c,
                   Work_Order_Line_Item__r.Localizacion__c,
                   Work_Order_Line_Item__r.CurrencyIsoCode,
                   Work_Order_Line_Item__r.Product2.Codigo_de_Producto__c,
                   Work_Order_Line_Item__r.Producto_OR_Alias__c,
                   Work_Order_Line_Item__r.Estado_Solicitud_Compra__c,
                   Work_Order_Line_Item__r.Estado_reserva__c,
                   Work_Order_Line_Item__r.Precio_Final_Cambio_de_Moneda__c
            FROM tipoCargo__c
            WHERE Work_Order_Line_Item__r.WorkOrderId = :workorderId
              AND (Work_Order_Line_Item__r.Trabajo__c           = 'Mano de Obra'
                   OR Work_Order_Line_Item__r.BMW_CodigoDeProducto__c = 'MO')
        ]) {
            String tcNombre = tipoCargoMap.get(tcMO.tipoCargo__c);
            if (tcNombre != null &&
                worder.tipoDeGasto__c != null &&
                tcNombre.equalsIgnoreCase(worder.tipoDeGasto__c)) {
                    
                Decimal unitPrice;
                if (tcMO.Work_Order_Line_Item__r.Precio_Final_Cambio_de_Moneda__c != null) {
                    unitPrice = tcMO.Work_Order_Line_Item__r.Precio_Final_Cambio_de_Moneda__c;
                } else {
                    unitPrice = (tcMO.Work_Order_Line_Item__r.Quantity != 0)
                                ? tcMO.totalMercaderia2__c / tcMO.Work_Order_Line_Item__r.Quantity
                                : 0;
                }
                
                Decimal montoLinea;
                if (tcMO.Work_Order_Line_Item__r.Precio_Final_Cambio_de_Moneda__c != null) {
                    montoLinea = unitPrice * tcMO.Work_Order_Line_Item__r.Quantity;
                } else {
                    montoLinea = tcMO.totalMercaderia2__c - tcMO.totalDescuento2__c;
                }
                
                manodeObra += Double.valueOf(montoLinea);
                
                itemsWO_MO.add(new ProductsConsumedWrapper(
                    null,
                    null,
                    tcMO.Work_Order_Line_Item__r.Producto_OR_Alias__c,
                    tcMO.Work_Order_Line_Item__r.CurrencyIsoCode,
                    tcMO.Work_Order_Line_Item__r.Quantity,
                    unitPrice,
                    tcMO.Work_Order_Line_Item__r.Descuento_Formula__c,
                    montoLinea,
                    false,
                    tcMO.Work_Order_Line_Item__r.Localizacion__c,
                    tcMO.Work_Order_Line_Item__r.Product2.Codigo_de_Producto__c,
                    tcMO.Work_Order_Line_Item__r.Estado_Solicitud_Compra__c,
                    tcMO.Work_Order_Line_Item__r.Estado_reserva__c
                ));
            }
        }
        
        // ==================================================================
        // SUBCONTRATO
        // ==================================================================
        for (tipoCargo__c tcSUB : [
            SELECT tipoCargo__c, totalDescuento2__c, totalMercaderia2__c,
                   Work_Order_Line_Item__r.Quantity,
                   Work_Order_Line_Item__r.Descuento_Formula__c,
                   Work_Order_Line_Item__r.Localizacion__c,
                   Work_Order_Line_Item__r.CurrencyIsoCode,
                   Work_Order_Line_Item__r.Product2.Codigo_de_Producto__c,
                   Work_Order_Line_Item__r.Producto_OR_Alias__c,
                   Work_Order_Line_Item__r.Estado_Solicitud_Compra__c,
                   Work_Order_Line_Item__r.Estado_reserva__c
            FROM tipoCargo__c
            WHERE Work_Order_Line_Item__r.WorkOrderId = :workorderId
              AND (Work_Order_Line_Item__r.Trabajo__c = 'Subcontrato'
                   OR Work_Order_Line_Item__r.BMW_CodigoDeProducto__c = 'SUB')
        ]) {
            String tcNombre = tipoCargoMap.get(tcSUB.tipoCargo__c);
            if (tcNombre != null &&
                worder.tipoDeGasto__c != null &&
                tcNombre.equalsIgnoreCase(worder.tipoDeGasto__c)) {
                    
                Decimal montoLinea = tcSUB.totalMercaderia2__c - tcSUB.totalDescuento2__c;
                Decimal unitPrice  = (tcSUB.Work_Order_Line_Item__r.Quantity != 0)
                                     ? tcSUB.totalMercaderia2__c / tcSUB.Work_Order_Line_Item__r.Quantity
                                     : 0;
                
                subcontrato += Double.valueOf(montoLinea);
                
                itemsWO_SUB.add(new ProductsConsumedWrapper(
                    null,
                    null,
                    tcSUB.Work_Order_Line_Item__r.Producto_OR_Alias__c,
                    tcSUB.Work_Order_Line_Item__r.CurrencyIsoCode,
                    tcSUB.Work_Order_Line_Item__r.Quantity,
                    unitPrice,
                    tcSUB.Work_Order_Line_Item__r.Descuento_Formula__c,
                    montoLinea,
                    false,
                    tcSUB.Work_Order_Line_Item__r.Localizacion__c,
                    tcSUB.Work_Order_Line_Item__r.Product2.Codigo_de_Producto__c,
                    tcSUB.Work_Order_Line_Item__r.Estado_Solicitud_Compra__c,
                    tcSUB.Work_Order_Line_Item__r.Estado_reserva__c
                ));
            }
        }
        
        // ==================================================================
        // ProductsConsumedWrapper normales
        // ==================================================================
        pcList = worder.ProductsConsumed;
        pcwList = new List<ProductsConsumedWrapper>();
        for (ProductConsumed pc : pcList) {
            pcwList.add(new ProductsConsumedWrapper(
                pc.Id,
                pc.ProductConsumedNumber,
                null,
                null,
                pc.QuantityConsumed,
                pc.UnitPrice,
                pc.Discount,
                pc.TotalPrice,
                pc.Aprobar__c,
                'NA',
                'NA',
                'NA',
                'NA'
            ));
        }
        
        // ==================================================================
        // Agrupaciones originales (para la pantalla VF)
        // ==================================================================
        wliList = new List<WorkorderLIGroupWrapper>();
        wtList  = new List<WorkorderGroupWrapper>();
        
        Map<String, List<WorkorderLineItem>> wliMap     = new Map<String, List<WorkorderLineItem>>();
        Map<String, List<WorkorderLineItem>> wliWrapMap = new Map<String, List<WorkorderLineItem>>();
        
        for (WorkorderLineItem wli : worder.WorkorderLineItems) {
            List<WorkorderLineItem> tempList = wliMap.get(wli.Product2.tipoProducto__c);
            if (tempList == null) tempList = new List<WorkorderLineItem>();
            tempList.add(wli);
            wliMap.put(wli.Product2.tipoProducto__c, tempList);
            
            String keyWrap = wli.tiposDeTrabajo__r.Name + '~~~' + wli.especificacionesTaller__c;
            List<WorkorderLineItem> tempWList = wliWrapMap.get(keyWrap);
            if (tempWList == null) tempWList = new List<WorkorderLineItem>();
            tempWList.add(wli);
            wliWrapMap.put(keyWrap, tempWList);
        }
        
        // ==================================================================
        // BLOQUES POR TAREA usando BMW_Total_de_Mercaderia__c del tipo de gasto
        // ==================================================================
        bloques = new List<BloqueTarea>();
        Map<String,BloqueTarea> tareasMap = new Map<String,BloqueTarea>();
        
        List<tipoCargo__c> cargosWO = [
            SELECT Id, tipoCargo__c, BMW_Total_de_Mercaderia__c, Work_Order_Line_Item__c
            FROM tipoCargo__c
            WHERE Work_Order_Line_Item__r.WorkOrderId = :workorderId
        ];
        
        Map<Id, List<tipoCargo__c>> cargosPorWoli = new Map<Id, List<tipoCargo__c>>();
        for (tipoCargo__c tc : cargosWO) {
            if (!cargosPorWoli.containsKey(tc.Work_Order_Line_Item__c)) {
                cargosPorWoli.put(tc.Work_Order_Line_Item__c, new List<tipoCargo__c>());
            }
            cargosPorWoli.get(tc.Work_Order_Line_Item__c).add(tc);
        }
        
        for (WorkorderLineItem wli : worder.WorkorderLineItems) {
            List<tipoCargo__c> cargos = cargosPorWoli.get(wli.Id);
            if (cargos == null || cargos.isEmpty()) continue;
            
            tipoCargo__c cargoSeleccionado = null;
            for (tipoCargo__c tc : cargos) {
                String nombreTipo = tipoCargoMap.get(tc.tipoCargo__c);
                if (nombreTipo == worder.tipoDeGasto__c) {
                    cargoSeleccionado = tc;
                    break;
                }
            }
            if (cargoSeleccionado == null) {
                continue;
            }
            
            String keyTarea   = (wli.TareaQuote__c == null) ? 'SIN TAREA' : String.valueOf(wli.TareaQuote__c);
            String tareaName  = (wli.TareaQuote__c != null) ? wli.TareaQuote__c : 'Sin Tarea';
            BloqueTarea bloque = tareasMap.get(keyTarea);
            if (bloque == null) {
                bloque = new BloqueTarea(tareaName, null, keyTarea);
                tareasMap.put(keyTarea, bloque);
            }
            
            if (wli.Trabajo__c == 'Mano de Obra' && String.isNotBlank(wli.Prioridad_de_tarea__c)) {
                bloque.prioridad = wli.Prioridad_de_tarea__c;
            }
            if (bloque.prioridad == null) {
                bloque.prioridad = 'Sin prioridad';
            }
            
            bloque.items.add(wli);
            
            Decimal monto = (cargoSeleccionado.BMW_Total_de_Mercaderia__c != null)
                            ? cargoSeleccionado.BMW_Total_de_Mercaderia__c
                            : 0;
            if (wli.Trabajo__c == 'Materiales') {
                bloque.totalMaterialesTarea += monto;
            } else if (wli.Trabajo__c == 'Mano de Obra') {
                bloque.totalManoDeObraTarea += monto;
            } else if (wli.Trabajo__c == 'Subcontrato') {
                bloque.totalSubcontratoTarea += monto;
            } else if (wli.Trabajo__c == 'Pintura') {
                bloque.totalPinturaTarea += monto;
            } else if (wli.Trabajo__c == 'Varios') {
                bloque.totalVariosTarea += monto;
            }
        }
        
        // IVA y total por bloque
        for (BloqueTarea bt : tareasMap.values()) {
            Decimal baseTarea = bt.totalMaterialesTarea +
                                bt.totalManoDeObraTarea +
                                bt.totalSubcontratoTarea;
            if (worder.Account != null && !worder.Account.Cliente_Exonerado__c) {
                if (worder.tipoDeGasto__c == 'Cliente') {
                    if (worder.Impuesto__c != null) {
                        bt.Iva = (baseTarea * worder.Impuesto__c / 100);
                    }
                    bt.totalTarea = baseTarea + bt.Iva;
                } else {
                    bt.Iva = baseTarea * 0.13;
                    bt.totalTarea = baseTarea + bt.Iva;
                }
            } else {
                bt.totalTarea = baseTarea;
            }
        }
        
        // ordenar bloques
        List<BloqueTarea> bloquesOrdenados = new List<BloqueTarea>(tareasMap.values());
        for (BloqueTarea b : bloquesOrdenados) {
            if (b.prioridad == null) b.prioridad = 'Normal';
        }
        bloquesOrdenados.sort(new ComparatorBloques());
        Integer contador = 1;
        for (BloqueTarea b : bloquesOrdenados) {
            b.numero = contador++;
        }
        bloques = bloquesOrdenados;
        
        // ================================
        // SUMA DE TODOS LOS BLOQUES
        // ================================
        Decimal totalMO  = 0;
        Decimal totalMAT = 0;
        Decimal totalSUB = 0;
        Decimal totalIVA = 0;
        Decimal totalGen = 0;
        
        for (BloqueTarea bt : bloques) {
            totalMO  += bt.totalManoDeObraTarea;
            totalMAT += bt.totalMaterialesTarea;
            totalSUB += bt.totalSubcontratoTarea;
            totalIVA += bt.Iva;
            totalGen += bt.totalTarea;
        }
        
        manodeObra  = Double.valueOf(totalMO);
        materiales  = Double.valueOf(totalMAT);
        subcontrato = Double.valueOf(totalSUB);
        IV          = Double.valueOf(totalIVA);
        total       = Double.valueOf(totalGen);
        
        if (total >= 0) {
            Decimal cent = (total - Integer.valueOf(total)) * 100;
            Centavos = Integer.valueOf(cent);
            Long n = total.longValue();
            TotalTexto = NumberToWord.english_number(n);
        } else {
            TotalTexto = null;
        }
        
        // wrappers de grupos para la VF
        for (String s : wliMap.keySet()) {
            wliList.add(new WorkorderLIGroupWrapper(s, wliMap.get(s)));
        }
        
        for (String s : wliWrapMap.keySet()) {
            List<String> sList = s.split('~~~');
            List<WorkorderTrabajoWrapper> wliTempList = new List<WorkorderTrabajoWrapper>();
            List<WorkorderLineItem>      wliRecList  = new List<WorkorderLineItem>();
            String trabajo;
            
            for (WorkorderLineItem wli : wliWrapMap.get(s)) {
                if (trabajo != null && trabajo != wli.Trabajo__c) {
                    wliTempList.add(new WorkorderTrabajoWrapper(wliRecList[0].Trabajo__c, sList[1], wliRecList));
                    wliRecList = new List<WorkorderLineItem>();
                    wliRecList.add(wli);
                } else {
                    wliRecList.add(wli);
                }
                trabajo = wli.Trabajo__c;
            }
            
            if (!wliRecList.isEmpty()) {
                wliTempList.add(new WorkorderTrabajoWrapper(trabajo, sList[1], wliRecList));
            }
            
            wtList.add(new WorkorderGroupWrapper(sList[0], sList[1], wliTempList));
        }
    }
    
    // ======================================================================
    // ACCIONES VF
    // ======================================================================
    public PageReference saveProductsConsumed() {
        update pcList;
        List<WorkorderLineItem> wliUpdateList = new List<WorkorderLineItem>();
        
        for (WorkorderGroupWrapper rec : wtList) {
            for (WorkorderTrabajoWrapper wlt : rec.wliList) {
                for (WorkorderLineItem wli : wlt.wliList) {
                    wliUpdateList.add(wli);
                }
            }
        }
        if (!wliUpdateList.isEmpty()) {
            update wliUpdateList;
        }
        
        return new PageReference('/' + workorderId).setRedirect(true);
    }
    
    public void submit() {
        List<WorkorderLineItem> wliUpdateList = new List<WorkorderLineItem>();
        for (WorkorderGroupWrapper rec : wtList) {
            for (WorkorderTrabajoWrapper wlt : rec.wliList) {
                for (WorkorderLineItemWrapper wli : wlt.wliwList) {
                    wli.wli.aprobado__c = wli.aprobar;
                    wliUpdateList.add(wli.wli);
                }
            }
        }
        if (!wliUpdateList.isEmpty()) {
            update wliUpdateList;
        }
    }
    
    // ======================================================================
    // WRAPPERS
    // ======================================================================
    public class WorkorderLIGroupWrapper {
        public String tipoDeTrabajo {get;set;}
        public Decimal groupTotal {get;set;}
        public List<WorkorderLineItem> wliList {get;set;}
        public List<WorkorderLineItemWrapper> wliwList {get;set;}
        
        public WorkorderLIGroupWrapper(String tipoDeTrabajo,
                                       List<WorkorderLineItem> wliList) {
            this.tipoDeTrabajo = tipoDeTrabajo;
            this.wliList = wliList;
            this.groupTotal = 0;
            this.wliwList = new List<WorkorderLineItemWrapper>();
            
            for (WorkorderLineItem woli : wliList) {
                if (woli.TotalPrice != null)
                    groupTotal += woli.TotalPrice;
                
                wliwList.add(new WorkorderLineItemWrapper(woli, woli.aprobado__c));
            }
        }
    }
    
    public class WorkorderGroupWrapper {
        public String groupName {get;set;}
        public String className {get;set;}
        public Decimal groupTotal {get;set;}
        public List<WorkorderTrabajoWrapper> wliList {get;set;}
        
        public WorkorderGroupWrapper(String groupName,
                                     String className,
                                     List<WorkorderTrabajoWrapper> wliList) {
            this.groupName = groupName;
            this.className = className;
            this.wliList = wliList;
            this.groupTotal = 0;
        }
    }
    
    public class WorkorderTrabajoWrapper {
        public String trabajoName {get;set;}
        public String className {get;set;}
        public Decimal trabajoTotal {get;set;}
        public List<WorkorderLineItem> wliList {get;set;}
        public List<WorkorderLineItemWrapper> wliwList {get;set;}
        
        public WorkorderTrabajoWrapper(String trabajoName,
                                       String className,
                                       List<WorkorderLineItem> wliList) {
            this.trabajoName = trabajoName;
            this.className = className;
            this.wliList = wliList;
            this.trabajoTotal = 0;
            this.wliwList = new List<WorkorderLineItemWrapper>();
            
            for (WorkorderLineItem woli : wliList) {
                if (woli.TotalPrice != null)
                    trabajoTotal += woli.TotalPrice;
                
                wliwList.add(new WorkorderLineItemWrapper(woli, woli.aprobado__c));
            }
        }
    }
    
    public class WorkorderLineItemWrapper {
        public WorkorderLineItem wli {get;set;}
        public Boolean aprobar {get;set;}
        
        public WorkorderLineItemWrapper(WorkorderLineItem wli,
                                        Boolean aprobar) {
            this.wli = wli;
            this.aprobar = aprobar;
        }
    }
    
    public class ProductsConsumedWrapper {
        public String  productConsumedId      {get;set;}
        public String  productConsumedNumber  {get;set;}
        public Decimal quantityConsumed       {get;set;}
        public String  description            {get;set;}
        public String  currencyCode           {get;set;}
        public Decimal unitPrice              {get;set;}
        public Decimal discount               {get;set;}
        public Decimal totalPrice             {get;set;}
        public Boolean aprobar                {get;set;}
        public String  localizacion           {get;set;}
        public String  codigoDeProductoCustom {get;set;}
        public String  estadoSolicitudCompra  {get;set;}
        public String  estadoReserva          {get;set;}
        
        public ProductsConsumedWrapper(String productConsumedId,
                                       String productConsumedNumber,
                                       String description,
                                       String currencyCode,
                                       Decimal quantityConsumed,
                                       Decimal unitPrice,
                                       Decimal discount,
                                       Decimal totalPrice,
                                       Boolean aprobar,
                                       String localizacion,
                                       String codigoDeProductoCustom,
                                       String estadoSolicitudCompra,
                                       String estadoReserva) {
            this.productConsumedId      = productConsumedId;
            this.productConsumedNumber  = productConsumedNumber;
            this.description            = description;
            this.currencyCode           = currencyCode;
            this.quantityConsumed       = quantityConsumed;
            this.unitPrice              = unitPrice;
            this.discount               = discount;
            this.totalPrice             = totalPrice;
            this.aprobar                = aprobar;
            this.localizacion           = localizacion;
            this.codigoDeProductoCustom = codigoDeProductoCustom;
            this.estadoSolicitudCompra  = estadoSolicitudCompra;
            this.estadoReserva          = estadoReserva;
        }
    }
    
    // Dummy para compatibilidad
    public static void metodoDummy() {
        String s = 'dummy';
    }
}