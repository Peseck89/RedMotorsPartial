public class TrabajoQuoteController {
    @AuraEnabled
	public static Id archivarTarea(Id quoteId, Id tareaId, Boolean recordatorio) {
        List<QuoteLineItem> quoteLineItemsExistentes = [
                SELECT Id,
                       TrabajoARealizar__c, TrabajoARealizar__r.Name, TrabajoARealizar__r.UTS__c, TrabajoARealizar__r.Cantidad__c,
                       TrabajoARealizar__r.ManoDeObra__r.Name, TrabajoARealizar__r.ManoDeObra__c,
                       SubTrabajoAlias__c,UnitPrice,Discount,Quantity,Product2Id,Codigo_producto__c,
                       SubTrabajoARealizar__c, SubTrabajoARealizar__r.Name, SubTrabajoARealizar__r.UTS__c, SubTrabajoARealizar__r.Cantidad__c,
                       SubTrabajoARealizar__r.ManoDeObra__c, SubTrabajoARealizar__r.ManoDeObra__r.Name,
                       BMW_Alias__c, tipoCargo__c, Aprobador__c, UTS__c, Hora__c, HoraSubtrabajo__c, Categor_a_de_presupuesto__c
                FROM QuoteLineItem
                WHERE QuoteId = :quoteId
                  AND Tarea__c =: tareaId
            ];
        List<Archivo_lineas_rechazadas__c> lineasArchivadas = new List< Archivo_lineas_rechazadas__c>();
        DateTime ahora = System.now();
        for(QuoteLineItem qli : quoteLineItemsExistentes){
            Archivo_lineas_rechazadas__c linea = new Archivo_lineas_rechazadas__c();
            linea.Quote__c = quoteId;
            linea.Cantidad__c = qli.Quantity;
            linea.Alias__c  = qli.BMW_Alias__c != '' ? qli.BMW_Alias__c : qli.SubTrabajoAlias__c != '' ? qli.SubTrabajoAlias__c : qli.TrabajoARealizar__c != null ? qli.TrabajoARealizar__r.Name : '';
            linea.Codigo_producto__c = qli.Codigo_producto__c;
            linea.Descuento__c = qli.Discount;
            linea.Fecha_y_hora_rechazado__c = ahora;
            linea.Precio__c = qli.UnitPrice;
            linea.Product__c = qli.Product2Id;
            linea.Recordatorio__c = recordatorio;
            linea.PN_TipoTrabajo__c = qli.TrabajoARealizar__c;
            linea.PN_Aprobador__c = qli.Aprobador__c;
            linea.PN_CategoriaPresupuesto__c = null;
            linea.PN_Hora__c = qli.TrabajoARealizar__r.Cantidad__c;
            linea.PN_TipoCargo__c =  TIPO_CARGO_VALUE_TO_LABEL.get(qli.tipoCargo__c);
            linea.PN_UTS__c = qli.TrabajoARealizar__r.UTS__c;
            linea.PN_SubtrabajoRealizar__c = qli.SubTrabajoARealizar__c;
            linea.PN_SubtrabajoAlias__c = qli.SubTrabajoARealizar__r.Name;
            linea.PN_HorasSubtrabajo__c = qli.SubTrabajoARealizar__r.Cantidad__c; 

            lineasArchivadas.add(linea);
        }
        insert lineasArchivadas;
        delete quoteLineItemsExistentes;
        return tareaId;
    }
    @AuraEnabled
	public static Id updateTareaPrioridad(Id quoteId, Id tareaId, String prioridad) {
        List<QuoteLineItem> listQliUpdatePrioridad = [Select Id, Categor_a_de_presupuesto__c From QuoteLineItem
                                                     Where QuoteId =: quoteId AND Tarea__c =: tareaId];
        for(QuoteLineItem qli : listQliUpdatePrioridad){
            qli.Categor_a_de_presupuesto__c = prioridad;
        }
        update listQliUpdatePrioridad;
        return tareaId;
    }
    @AuraEnabled
    public static List<TrabajoWrapper> getTrabajos(Id quoteId, Id tareaId) {
        try {
            List<TrabajoWrapper> trabajos = new List<TrabajoWrapper>();
    
            List<QuoteLineItem> trabajosExistentes = [
                SELECT Id,DefaultMostrador__c,
                       TrabajoARealizar__c, TrabajoARealizar__r.Name, TrabajoARealizar__r.UTS__c, TrabajoARealizar__r.Cantidad__c,
                       TrabajoARealizar__r.ManoDeObra__r.Name, TrabajoARealizar__r.ManoDeObra__c,
                       SubTrabajoAlias__c,Quantity,
                       SubTrabajoARealizar__c, SubTrabajoARealizar__r.Name, SubTrabajoARealizar__r.UTS__c, SubTrabajoARealizar__r.Cantidad__c,
                       SubTrabajoARealizar__r.ManoDeObra__c, SubTrabajoARealizar__r.ManoDeObra__r.Name,
                       BMW_Alias__c, tipoCargo__c, Aprobador__c, UTS__c, Hora__c, HoraSubtrabajo__c, Categor_a_de_presupuesto__c
                FROM QuoteLineItem
                WHERE QuoteId = :quoteId
                  AND TrabajoARealizar__c != NULL
                  AND Tarea__c =: tareaId
                ORDER BY TrabajoARealizar__c
            ];
    
            Id currentTrabajo = null;
            Integer totalsubtrabajos = 0;
    
            for (QuoteLineItem trabajo : trabajosExistentes) {
                if (trabajo.TrabajoARealizar__c != currentTrabajo) {
                    totalsubtrabajos = 0;
    
                    TrabajoWrapper trabajoWrapper = new TrabajoWrapper();
                    trabajoWrapper.id                   = trabajo.Id;
                    trabajoWrapper.nombreTrabajo        = (trabajo.TrabajoARealizar__r != null) ? trabajo.TrabajoARealizar__r.Name : null;
                    trabajoWrapper.alias                = (trabajo.BMW_Alias__c != null && trabajo.BMW_Alias__c != '') ? trabajo.BMW_Alias__c : trabajoWrapper.nombreTrabajo;
                    trabajoWrapper.prioridad            = trabajo.Categor_a_de_presupuesto__c;
                    trabajoWrapper.tipoTrabajo          = trabajo.TrabajoARealizar__c;
                    trabajoWrapper.tipoCargo            = trabajo.tipoCargo__c;
                    trabajoWrapper.aprobador            = trabajo.Aprobador__c;
                    trabajoWrapper.uts                  = trabajo.Quantity;
                    trabajoWrapper.utsReal              = trabajo.UTS__c; // (verifica si aquí querías Hora__c*12)
                    trabajoWrapper.utsDelTipoDeTrabajo  = (trabajo.TrabajoARealizar__r != null) ? trabajo.TrabajoARealizar__r.Cantidad__c : null;
                    trabajoWrapper.manoDeObra           = (trabajo.TrabajoARealizar__r != null) ? trabajo.TrabajoARealizar__r.ManoDeObra__c : null;
                    trabajoWrapper.manoDeObraNombre     = (trabajo.TrabajoARealizar__r != null && trabajo.TrabajoARealizar__r.ManoDeObra__r != null)
                                                            ? trabajo.TrabajoARealizar__r.ManoDeObra__r.Name : null;
                    trabajoWrapper.totalUts             = trabajo.HoraSubtrabajo__c;
    
                    // 🔧 Inicializa la lista
                    trabajoWrapper.subtrabajos = new List<SubtrabajoWrapper>();
    
                    // Recorre todos los QLI del mismo TrabajoARealizar
                    for (QuoteLineItem subtrabajo : trabajosExistentes) {
                        if (subtrabajo.TrabajoARealizar__c == trabajo.TrabajoARealizar__c) {
    
                            // 🔐 Guarda: puede no haber subtrabajo
                            if (subtrabajo.SubTrabajoARealizar__c == null) { continue;
                            }
    
                            totalsubtrabajos++;
    
                            SubtrabajoWrapper st = new SubtrabajoWrapper();
                            st.id                = subtrabajo.Id;
                            st.nombre            = (subtrabajo.SubTrabajoARealizar__r != null) ? subtrabajo.SubTrabajoARealizar__r.Name : null;
                            st.alias             = (subtrabajo.SubTrabajoAlias__c != null && subtrabajo.SubTrabajoAlias__c != '')
                                                   ? subtrabajo.SubTrabajoAlias__c
                                                   : trabajoWrapper.alias;
                            st.horas             = subtrabajo.HoraSubtrabajo__c;
                            st.tipoTrabajo       = subtrabajo.SubTrabajoARealizar__c;
                            st.tipoTrabajoNombre = (subtrabajo.SubTrabajoARealizar__r != null) ? subtrabajo.SubTrabajoARealizar__r.Name : null;
    
                            // UTS del subtrabajo: primero el de tipo, si no existe, calcula de horas
                            if (subtrabajo.SubTrabajoARealizar__r != null &&
                                subtrabajo.SubTrabajoARealizar__r.Cantidad__c != null &&
                                subtrabajo.SubTrabajoARealizar__r.Cantidad__c != 0) {
                                st.uts = subtrabajo.SubTrabajoARealizar__r.Cantidad__c;
                            } else { st.uts = (subtrabajo.HoraSubtrabajo__c != null) ? subtrabajo.HoraSubtrabajo__c * 12 : 0;
                            }
    
                            st.utsDelTipoDeTrabajo = (subtrabajo.SubTrabajoARealizar__r != null)
                                                        ? subtrabajo.SubTrabajoARealizar__r.Cantidad__c : null;
    
                            if (subtrabajo.SubTrabajoARealizar__r != null &&
                                subtrabajo.SubTrabajoARealizar__r.ManoDeObra__c != null) {
                                st.manoDeObra       = subtrabajo.SubTrabajoARealizar__r.ManoDeObra__c;
                                st.manoDeObraNombre = (subtrabajo.SubTrabajoARealizar__r.ManoDeObra__r != null)
                                                        ? subtrabajo.SubTrabajoARealizar__r.ManoDeObra__r.Name : null;
                            }
    
                            trabajoWrapper.subtrabajos.add(st);
                        }
                    }
    
                    trabajoWrapper.totalSubtrabajos = totalsubtrabajos;
                    trabajos.add(trabajoWrapper);
                    currentTrabajo = trabajo.TrabajoARealizar__c;
                }
            }
    
            return trabajos;
    
        } catch (Exception e) {            throw new AuraHandledException('Error al obtener los trabajos: ' + e.getMessage());
        }
    }
    
    
    @AuraEnabled
	public static Id saveTrabajo(TrabajoWrapper trabajo, Id quoteId) {
        List<QuoteLineItem> qliListTarea = new List<QuoteLineItem>();
    try {
        System.debug('trabajo '+trabajo);
        if(trabajo.Id == null){
            System.debug('trabajo.Id');
            System.debug('tareaSelected '+trabajo.tarea);
            String tareaSelected = trabajo.tarea != null && trabajo.tarea != '' ? trabajo.tarea : trabajo.tipoTrabajo;
                    System.debug('tareaSelected '+tareaSelected);

            qliListTarea = [Select Id,Quote.Opportunity.BMW_Compania__c, Quote.Opportunity.BMW_TipoDeVehiculo__c  From QuoteLineItem Where Tarea__c =: tareaSelected AND QuoteId =: quoteId];
            System.debug('qliListTarea '+qliListTarea);
            if(qliListTarea.size()>0){
                //return trabajo.Id;
            }
        }
        Quote quo = [SELECT Opportunity.BMW_Compania__c, Id, Opportunity.BMW_TipoDeVehiculo__c  From Quote Where Id =: quoteId Limit 1];
        String label = (trabajo.tipoCargo == null || trabajo.tipoCargo == 'Cliente') ? '1' : trabajo.tipoCargo.trim();
        String apiValue = (label != null) ? TIPO_CARGO_LABEL_TO_VALUE.get(label) : null;
		System.debug('trabajo '+trabajo);
        System.debug('trabajo.tipoTrabajo '+trabajo.tipoTrabajo);
        System.debug('label1 '+label);

        tiposDeTrabajo__c tipoTrabajo = [
            SELECT Id, Name, ManoDeObra__c, ManoDeObra__r.Name,UTS__c,Cantidad__c
            FROM tiposDeTrabajo__c
            WHERE Id = :trabajo.tipoTrabajo
            LIMIT 1
        ];
        Quote q = [
            SELECT Id, Pricebook2Id
            FROM Quote
            WHERE Id = :quoteId
            LIMIT 1
        ];
        String manoDeObra;
        String empresa;
         String tipodecargo = label;
        String tipoDeVehiculo;
        if(quo.Opportunity.BMW_Compania__c == 'Bavarian' || quo.Opportunity.BMW_Compania__c == 'RMBavarian'){
            empresa = 'RMBAVARIAN';
        }else{
             empresa = 'RMOTOBAI';
        }
        if(quo.Opportunity.BMW_TipoDeVehiculo__c == 'Autos'){
            tipoDeVehiculo = 'Automóvil';
        }
        else{
            tipoDeVehiculo = 'Motocicleta';
        }
       System.debug('empresa '+empresa);
       System.debug('tipoDeVehiculo '+tipoDeVehiculo);
       System.debug('tipodecargo '+tipodecargo);
        if(tipodecargo == '1')tipodecargo = 'Cliente';
               System.debug('tipodecargo '+tipodecargo);

        if(tipoTrabajo.ManoDeObra__c == null){
          List<TipoDeCargoConManoDeObra__c> listTCMO = [SELECT ManoDeObra__c, TipoDeCargo__c FROM TipoDeCargoConManoDeObra__c WHERE Empresa__c = :empresa AND TipoDeCargo__c = :tipodecargo AND TipoDeVehiculo__c = :tipoDeVehiculo];
            if(listTCMO.size()>0){
                manoDeObra = listTCMO[0].ManoDeObra__c;
            }

        }else{
            manoDeObra = tipoTrabajo.ManoDeObra__c;
        }
                       System.debug('manoDeObra '+manoDeObra);

        PricebookEntry pbe = [
            SELECT Id, UnitPrice, IsActive
            FROM PricebookEntry
            WHERE Product2Id = :manoDeObra
              AND Pricebook2Id = :q.Pricebook2Id
              AND IsActive = true
            LIMIT 1
        ];
                               System.debug('pbe '+pbe);

        if(trabajo.uts == -1){ trabajo.uts =tipoTrabajo.Cantidad__c;
        }
        QuoteLineItem nuevoTrabajo = new QuoteLineItem(
            Id                  = trabajo.id,
            QuoteId             = quoteId,
            PricebookEntryId    = pbe.Id,
            Product2Id          = manoDeObra,
            UnitPrice           = pbe.UnitPrice,
            Quantity            = (trabajo.uts != null && trabajo.uts != 0 ? trabajo.uts : 1),
            BMW_Alias__c        = trabajo.alias,
            // ===== Campos de tarea =====
            Tarea__c            = trabajo.tarea != null && trabajo.tarea != '' ? trabajo.tarea : trabajo.tipoTrabajo,
            TrabajoARealizar__c = trabajo.tipoTrabajo,
            SubTrabajoARealizar__c = trabajo.tipoTrabajo,
            // ===== Otros campos =====
            tipoCargo__c        = QliGridDML.toTipoCargoValue(label),
            Aprobador__c        = trabajo.aprobador,
            Hora__c             = (trabajo.uts != null && trabajo.uts != 0 ? trabajo.uts : 1),
            UTS__c              = (trabajo.uts != null && trabajo.uts != 0 ? trabajo.uts * 12 : null),
            HoraSubtrabajo__c   = trabajo.uts,
            Categor_a_de_presupuesto__c = trabajo.prioridad
        );

        upsert nuevoTrabajo;
        return nuevoTrabajo.Id; // <-- DEVUELVE ALGO
    } catch (Exception e) { throw new AuraHandledException('Error al guardar el Quote Line Item: ' + e.getMessage());
    }
}
	private static final Map<String, String> TIPO_CARGO_VALUE_TO_LABEL = new Map<String, String>{
    '1' => 'Cliente',
    '3' => 'Aseguradora',
    '4' => 'Garantia',
    '5' => 'BSI',
    '2' => 'Interno',
    '6' => 'BSI Interno',
    '7' => 'En proceso',
    '8' => 'Sincronice nuevamente'
};
    private static final Map<String, String> TIPO_CARGO_LABEL_TO_VALUE = new Map<String, String>{
        'Cliente'            => '1',
        'Aseguradora'        => '3',
        'Garantia'           => '4',
        'BSI'                => '5',
        'Interno'            => '2',
        'BSI Interno'        => '6',
        'En proceso'         => '7',
        'Sincronice nuevamente' => '8'
    };

    @AuraEnabled
    public static void deleteSubtrabajo(Id subtrabajoId, Id quoteId) {
        System.debug('subtrabajoId '+subtrabajoId);
        try {
            QuoteLineItem subtrabajo = [SELECT TrabajoArealizar__c, SubTrabajoARealizar__c,Id,HoraSubtrabajo__c 
                                        FROM QuoteLineItem WHERE Id = :subtrabajoId];
            String IdTrabajo = subtrabajo.TrabajoArealizar__c;
            Decimal HoraSub = subtrabajo.HoraSubtrabajo__c != NULL ? subtrabajo.HoraSubtrabajo__c : 0;
            System.debug('HoraSub '+HoraSub);
            QuoteLineItem trabajoPadre = [Select Id, UTS__c, Quantity, Hora__c From QuoteLineItem
                                                  Where TrabajoArealizar__c =:IdTrabajo AND Id !=: subtrabajoId 
                                                   AND SubTrabajoARealizar__c =: IdTrabajo
                                                  AND QuoteId =: quoteId LIMIT 1];
                        System.debug('trabajoPadre '+trabajoPadre);

            
            if(trabajoPadre != null){
            	trabajoPadre.UTS__c = trabajoPadre.UTS__c -(HoraSub*12);
                trabajoPadre.Quantity = trabajoPadre.Quantity - HoraSub;
                trabajoPadre.Hora__c = trabajoPadre.Hora__c - HoraSub;
                update trabajoPadre;
            }
            delete subtrabajo;
        } catch (Exception e) {
            throw new AuraHandledException('Error al eliminar el subtrabajo: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void deleteTrabajo(Id trabajoId, Id quoteId) {
        QuoteLineItem qli = [Select Id, TrabajoArealizar__c From QuoteLineItem Where Id =: trabajoId];
        List<QuoteLineItem> subtrabajos = new List<QuoteLineItem>();
        try {
            subtrabajos = [
                SELECT Id FROM QuoteLineItem WHERE TrabajoArealizar__c = :qli.TrabajoArealizar__c AND ID !=:trabajoId AND QuoteId =:quoteId
            ];
            if (subtrabajos.size()>0) {
                delete subtrabajos;
            }
            if(qli != null){
                delete qli;
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error al eliminar el trabajo: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Decimal getUTSTipoTrabajo(Id idTipoTrabajo){
        Decimal UTS = 0;
        System.debug('idTipoTrabajo '+idTipoTrabajo);
        if(idTipoTrabajo != null){
                    System.debug('idTipoTrabajo1 '+idTipoTrabajo);

            try {
                tiposDeTrabajo__c tdt = [Select Id,UTS__c,Cantidad__c From tiposDeTrabajo__c Where Id=:idTipoTrabajo limit 1];
                UTS = tdt.Cantidad__c;
            } catch (Exception e) { throw new AuraHandledException('Error al obtener el valor de cantidad: ' + e.getMessage());
            }
        }
        return UTS;       
    }
    @AuraEnabled
    public static void saveSubtrabajos(Id tareaId, Id trabajoId, Id tipoDeTrabajoId, List<SubtrabajoWrapper> subtrabajos, Id quoteId, String prioridad, String tipodecargo) {
        Decimal SumaUTS = 0; 
        System.debug('trabajoId '+trabajoId);
        try {
            List<QuoteLineItem> subtrabajosToUpsert = new List<QuoteLineItem>();
            QuoteLineItem trabajoPadre = [SELECT Id, TipoCargo__c FROM QuoteLineItem WHERE Id = :trabajoId LIMIT 1];
            Set<Id> idsManoDeObra = new Set<Id>();
            Set<Id> idsTipoTrabajo = new Set<Id>();
            for (SubtrabajoWrapper subtrabajo : subtrabajos) {
                idsTipoTrabajo.add(subtrabajo.tipoTrabajo);
            }
                                        System.debug('trabajoId '+trabajoId);
                                        System.debug('tipoDeTrabajoId '+tipoDeTrabajoId);

            List<tiposDeTrabajo__c> tiposDeTrabajo = [SELECT Id, ManoDeObra__c FROM tiposDeTrabajo__c WHERE Id IN :idsTipoTrabajo];
            Map<Id, Id> tipoTrabajoIdManoDeObraId = new Map<Id, Id>();
            List<Id> tipoTrabajoSinManoDeObra = new List<Id>();
            for (tiposDeTrabajo__c tdt : tiposDeTrabajo) {
                if (tdt.ManoDeObra__c != null) {
                    tipoTrabajoIdManoDeObraId.put(tdt.Id, tdt.ManoDeObra__c);
                    idsManoDeObra.add(tdt.ManoDeObra__c);
                } else { tipoTrabajoSinManoDeObra.add(tdt.Id);
                }
            } 
             Quote q = [
                SELECT Id, Pricebook2Id
                FROM Quote
                WHERE Id = :quoteId
                LIMIT 1
            ];
             List<PricebookEntry> pbeList = [
                SELECT Id, UnitPrice, IsActive, Product2Id
                FROM PricebookEntry
                WHERE Product2Id IN :idsManoDeObra
                  AND Pricebook2Id = :q.Pricebook2Id
                  AND IsActive = true
            ];
            Map<Id,Id> manoDeObraPBEMap = new Map<Id,Id>();
            Map<Id,Decimal> manoDeObraUnitPriceMap = new Map<Id,Decimal>();
            for(PricebookEntry pbe : pbeList){
                manoDeObraPBEMap.put(pbe.Product2Id, pbe.Id);
                manoDeObraUnitPriceMap.put(pbe.Product2Id, pbe.UnitPrice);
            }
            for (SubtrabajoWrapper subtrabajo : subtrabajos) {
                if (tipoTrabajoIdManoDeObraId.containsKey(subtrabajo.tipoTrabajo)) {
                    subtrabajo.manoDeObra = tipoTrabajoIdManoDeObraId.get(subtrabajo.tipoTrabajo);
                }
                            System.debug('subtrabajo.tipoTrabajo '+subtrabajo.tipoTrabajo);
                            System.debug('subtrabajo.id '+subtrabajo.id);

                QuoteLineItem nuevoSubtrabajo = new QuoteLineItem(
                    Id = subtrabajo.id != null && subtrabajo.id.startsWith('local-sub-') ? null : subtrabajo.id,
                    QuoteId = quoteId,
                    Tarea__c = tareaId,
                    TipoCargo__c = trabajoPadre.TipoCargo__c,
                    TrabajoARealizar__c = tipoDeTrabajoId,
                    Product2Id = tipoTrabajoIdManoDeObraId.get(subtrabajo.tipoTrabajo),
                    PricebookEntryId = manoDeObraPBEMap.get(tipoTrabajoIdManoDeObraId.get(subtrabajo.tipoTrabajo)),
                    //Name = subtrabajo.nombre != null ? subtrabajo.nombre : 'Subtrabajo',
                    UTS__c = subtrabajo.uts != null ? subtrabajo.uts : 0,
                    UnitPrice = manoDeObraUnitPriceMap.get(tipoTrabajoIdManoDeObraId.get(subtrabajo.tipoTrabajo)),
                    Quantity = subtrabajo.uts != null ? subtrabajo.uts : 0,
                    HoraSubtrabajo__c = subtrabajo.uts != null ? subtrabajo.uts : 0,
                    SubTrabajoARealizar__C = subtrabajo.tipoTrabajo,
                    //Mano_de_Obra__c = subtrabajo.manoDeObra,
                    SubTrabajoAlias__c = subtrabajo.alias != null && subtrabajo.alias != '' ? subtrabajo.alias : subtrabajo.nombre != null ? subtrabajo.nombre : 'Subtrabajo'
                    //created_From__c = 'caseWorkTypes',
                    //Tipo_de_trabajo_del_caso__c = trabajoId
                );
                
                SumaUTS += subtrabajo.uts != null ? subtrabajo.uts : 0;
                System.debug('SumaUTS1 '+SumaUTS);

                String claveUnica = subtrabajo.manoDeObra + '-' + (subtrabajo.alias != null ? subtrabajo.alias : '');      
                subtrabajosToUpsert.add(nuevoSubtrabajo);
            }
            
            
            
            System.debug('SumaUTS '+SumaUTS);
            if (subtrabajosToUpsert.size()>0) {
                upsert subtrabajosToUpsert;
                
                QuoteLineItem tipoTrabajoCaso = [SELECT Id, UTS__c, Hora__c, Quantity FROM QuoteLineItem WHERE Id = :trabajoId LIMIT 1];
                tipoTrabajoCaso.UTS__c = SumaUTS * 12;
                tipoTrabajoCaso.Hora__c = SumaUTS;
                tipoTrabajoCaso.Quantity = SumaUTS;
                update tipoTrabajoCaso;
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error al guardar los subtrabajos: ' + e.getMessage());
        }
    }
    public class TrabajoWrapper {
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String workOrderId { get; set; }
        @AuraEnabled public String aseguradora { get; set; }
        @AuraEnabled public String aseguradoraNombre { get; set; }
        @AuraEnabled public String centroDeCostos { get; set; }
        @AuraEnabled public String centroDeCostosNombre { get; set; }
        @AuraEnabled public String nombreTrabajo { get; set; }
        @AuraEnabled public String alias { get; set; }
        @AuraEnabled public Boolean changeAlias { get; set; }
        @AuraEnabled public String prioridad { get; set; }
        @AuraEnabled public String tipoTrabajo { get; set; }
        @AuraEnabled public String tarea { get; set; }
        @AuraEnabled public String tipoCargo { get; set; }
        @AuraEnabled public String aprobador { get; set; }
        @AuraEnabled public String manoDeObra { get; set; }
        @AuraEnabled public String manoDeObraNombre { get; set; }
        @AuraEnabled public Decimal uts { get; set; }
        @AuraEnabled public Decimal utsReal { get; set; }
        @AuraEnabled public Decimal totalUts { get; set; }
        @AuraEnabled public Decimal totalSubtrabajos { get; set; }
        @AuraEnabled public Decimal utsDelTipoDeTrabajo { get; set; }
        @AuraEnabled public List<SubtrabajoWrapper> subtrabajos { get; set; }
    }
    
    public class SubtrabajoWrapper {
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String nombre { get; set; }
        @AuraEnabled public String alias { get; set; }
        @AuraEnabled public String manoDeObra { get; set; }
        @AuraEnabled public String manoDeObraNombre { get; set; }
        @AuraEnabled public String pasoDeTrabajo { get; set; }
        @AuraEnabled public String tipoTrabajo {get;set; }
        @AuraEnabled public String tipoTrabajoNombre {get;set; }
        @AuraEnabled public Decimal horas { get; set; }
        @AuraEnabled public Decimal uts { get; set; }
        @AuraEnabled public Decimal utsDelTipoDeTrabajo { get; set; }
        
    }
}