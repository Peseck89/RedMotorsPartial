public with sharing class BMW_QuotePDFController {
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

        
    public BMW_QuotePDFController(Apexpages.StandardController controller) {
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
        BMW_TipoDeArticulo__c, Product2.Name,Product2.Codigo_de_Producto__c,BMW_Dispinible__c,Categor_a_de_presupuesto__c
                                                                from QuoteLineItems 
                                                                ) 
               from Quote
               where id =: recordId 
               LIMIT 1];
        
        
        ordenaTrabajos = [select id,Quantity,Description,Discount,UnitPrice,TotalPrice,BMW_Producto_Custom__c,
        BMW_TipoDeArticulo__c, Product2.Name,Product2.Codigo_de_Producto__c,BMW_Dispinible__c,Categor_a_de_presupuesto__c
                                                                from QuoteLineItem where QuoteId =: recordId  order by createddate ASC];
        
        List<Cambio_de_Propietario__c> cambios = [SELECT Id, Asset__c, Case__c, Cuenta_Anterior__c, Cuenta_Nueva__c, Estado__c 
             FROM Cambio_de_Propietario__c WHERE Asset__c = :cot.Opportunity.BMW_PlacaDeVehiculoOElVIN__c AND Estado__c ='Pendiente'];

          if (!cambios.isEmpty()) {
          cambioPropietario = cambios[0];
          } else {
          cambioPropietario = null;
          }
        
         productosTarea = [SELECT Id, Product2.Codigo_de_Producto__c, Product2.Name, UnitPrice, TotalPrice, Quantity, Discount,
           BMW_Dispinible__c, BMW_TipoDeArticulo__c, BMW_Alias__c, Tarea__c, Tarea__r.Name, Categor_a_de_presupuesto__c
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
        bloque.Iva = (bloque.totalMaterialesTarea + bloque.totalManoDeObraTarea + bloque.totalSubcontratoTarea) * 0.13;
        bloque.totalTarea = bloque.totalMaterialesTarea + bloque.totalManoDeObraTarea + bloque.totalSubcontratoTarea + bloque.Iva;
    } else {
        bloque.totalTarea += monto;
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
            
        montoMaterial = 0;
        montoManoDeObra = 0;
        montoSubcontrato = 0;
        montoPintura = 0;
        montoVarios = 0;
        montoVarios2 = 0;
        montoPintura2 = 0;

        if(cot.QuoteLineItems != null && cot.QuoteLineItems.size()>0){
            for(QuoteLineItem qli : cot.QuoteLineItems){
                if(qli.BMW_TipoDeArticulo__c == 'Materiales'){montoMaterial = montoMaterial +qli.TotalPrice;
                }
                if(qli.BMW_TipoDeArticulo__c == 'Mano de Obra'){montoManoDeObra = montoManoDeObra +qli.TotalPrice;
                }
                if(qli.BMW_TipoDeArticulo__c == 'Subcontrato'){montoSubcontrato = montoSubcontrato +qli.TotalPrice;
                }
                if(qli.BMW_TipoDeArticulo__c == 'Pintura'){montoPintura = montoPintura +qli.TotalPrice;
                }
                if(qli.BMW_TipoDeArticulo__c == 'Varios'){montoVarios = montoVarios +qli.TotalPrice;
                }
            }
        }  
    }
}