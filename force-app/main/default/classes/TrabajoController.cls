public with sharing class TrabajoController {
    @AuraEnabled
    public static String getWorkOrder(Id casoId) {
        String WorkOrderId = '';
        try {
            WorkOrder OT = [SELECT Id,WorkOrderNumber FROM WorkOrder WHERE CaseId =: casoId ORDER BY WorkOrderNumber ASC LIMIT 1];
            WorkOrderId = OT.Id;
        } catch (Exception e) {
            throw new AuraHandledException('Error al obtener el WorkOrder: ' + e.getMessage());
        }
        return WorkOrderId;
    }
    
    @AuraEnabled
    public static List<TrabajoWrapper> getTrabajos(Id casoId) {
        try {
            List<TrabajoWrapper> trabajos = new List<TrabajoWrapper>();
            List<tiposDeTrabajoCaso__c> trabajosExistentes = [
                SELECT Id, RM_WorkOrder__c,Alias_Articulo__c,UTS_Real__c, RM_Aseguradora__c, CT_Total_Subtareas_FM__c,TotalDeUTS__c,
                RM_Aseguradora__r.Name, RM_CentroCosto__c,RM_CentroCosto__r.Name, 
                Categor_a_de_presupuesto__c, Tipotrabajo__c,Tipotrabajo__r.UTS__c,Tipotrabajo__r.Cantidad__c,
                Tipotrabajo__r.ManoDeObra__c,Tipotrabajo__r.ManoDeObra__r.Name, 
                Tipo_de_cargo__c, Aprobador__c, UTS__c,NombreDeTrabajo__c,
                (SELECT Id, Name,Alias__c,Paso_de_trabajo__c,Cantidad_de_horas__c,Articulo_Mano_de_Obra__c, Articulo_Mano_de_Obra__r.Product__c,Articulo_Mano_de_Obra__r.Product__r.Name, Mano_de_Obra__c, Mano_de_Obra__r.Name, UTS__c,TipoDeTrabajo__c, TipoDeTrabajo__r.Name,TipoDeTrabajo__r.UTS__c,TipoDeTrabajo__r.Cantidad__c FROM Subtipos_de_trabajos_del_caso__r)
                FROM tiposDeTrabajoCaso__c
                WHERE Caso__c = :casoId
            ];
            for (tiposDeTrabajoCaso__c trabajo : trabajosExistentes) {
                TrabajoWrapper trabajoWrapper = new TrabajoWrapper();
                trabajoWrapper.id = trabajo.Id;
                trabajoWrapper.workOrderId = trabajo.RM_WorkOrder__c;
                trabajoWrapper.aseguradora = trabajo.RM_Aseguradora__c;
                trabajoWrapper.centroDeCostos = trabajo.RM_CentroCosto__c;
                trabajoWrapper.aseguradoraNombre = trabajo.RM_Aseguradora__r.Name;
                trabajoWrapper.centroDeCostosNombre = trabajo.RM_CentroCosto__r.Name;
                trabajoWrapper.nombreTrabajo = trabajo.NombreDeTrabajo__c;
                trabajoWrapper.alias = trabajo.Alias_Articulo__c != null && trabajo.Alias_Articulo__c != '' ? trabajo.Alias_Articulo__c : trabajo.NombreDeTrabajo__c;
                trabajoWrapper.prioridad = trabajo.Categor_a_de_presupuesto__c;
                trabajoWrapper.tipoTrabajo = trabajo.Tipotrabajo__c;
                trabajoWrapper.tipoCargo = trabajo.Tipo_de_cargo__c;
                trabajoWrapper.aprobador = trabajo.Aprobador__c;
                trabajoWrapper.uts = trabajo.UTS__c;
                trabajoWrapper.utsReal = trabajo.UTS_Real__c;
                trabajoWrapper.utsDelTipoDeTrabajo = trabajo.Tipotrabajo__r.Cantidad__c;
                trabajoWrapper.manoDeObra = trabajo.Tipotrabajo__r.ManoDeObra__c;
                trabajoWrapper.manoDeObraNombre = trabajo.Tipotrabajo__r.ManoDeObra__r.Name;
                trabajoWrapper.totalSubtrabajos = trabajo.CT_Total_Subtareas_FM__c;
                trabajoWrapper.totalUts = trabajo.TotalDeUTS__c;
                trabajoWrapper.subtrabajos = new List<SubtrabajoWrapper>();
                for (Subtipo_de_trabajo_del_caso__c subtrabajo : trabajo.Subtipos_de_trabajos_del_caso__r) {
                    SubtrabajoWrapper subtrabajoWrapper = new SubtrabajoWrapper();
                    subtrabajoWrapper.id = subtrabajo.Id;
                    subtrabajoWrapper.nombre = subtrabajo.Name;
                    subtrabajoWrapper.alias = subtrabajo.Alias__c != null && subtrabajo.Alias__c != '' ? subtrabajo.Alias__c : trabajoWrapper.alias;
                    subtrabajoWrapper.horas = subtrabajo.Cantidad_de_horas__c;
                    subtrabajoWrapper.tipoTrabajo = subtrabajo.TipoDeTrabajo__c;
                    subtrabajoWrapper.tipoTrabajoNombre = subtrabajo.TipoDeTrabajo__r.Name;
                    if(subtrabajo.TipoDeTrabajo__r.Cantidad__c != null && subtrabajo.TipoDeTrabajo__r.Cantidad__c != 0){
                        subtrabajoWrapper.uts = subtrabajo.TipoDeTrabajo__r.Cantidad__c;
                    }else{
                        subtrabajoWrapper.uts = subtrabajo.UTS__c;
                    }
                    System.debug('subtrabajoWrapper.uts '+subtrabajoWrapper.uts);
                    subtrabajoWrapper.utsDelTipoDeTrabajo = subtrabajo.TipoDeTrabajo__r.Cantidad__c;
                    if( subtrabajo.Mano_de_Obra__c != null){
                        subtrabajoWrapper.manoDeObra = subtrabajo.Mano_de_Obra__c;
                        subtrabajoWrapper.manoDeObraNombre = subtrabajo.Mano_de_Obra__r.Name;
                    }
                    else{
                        if(subtrabajo.Articulo_Mano_de_Obra__r.Product__c != null){
                            subtrabajoWrapper.manoDeObra = subtrabajo.Articulo_Mano_de_Obra__r.Product__c;
                            subtrabajoWrapper.manoDeObraNombre = subtrabajo.Articulo_Mano_de_Obra__r.Product__r.Name;
                        }
                    }
                    subtrabajoWrapper.pasoDeTrabajo = subtrabajo.Paso_de_trabajo__c;
                    trabajoWrapper.subtrabajos.add(subtrabajoWrapper);
                }
                trabajos.add(trabajoWrapper);
            }
            return trabajos;
        } catch (Exception e) {
            throw new AuraHandledException('Error al obtener los trabajos: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void saveTrabajo(TrabajoWrapper trabajo, Id casoId, Id workOrderId) {
        Boolean crearSubTrabajo = false;
        if(trabajo.Id == null){
            crearSubTrabajo = true;
        }
        try {
            tiposDeTrabajoCaso__c nuevoTrabajo = new tiposDeTrabajoCaso__c(
                id = trabajo.id,
                Categor_a_de_presupuesto__c = trabajo.prioridad,
                Tipotrabajo__c = trabajo.tipoTrabajo,
                Tipo_de_cargo__c = trabajo.tipoCargo,
                Aprobador__c = trabajo.aprobador,
                UTS__c = trabajo.uts,
                UTS_Real__c = trabajo.utsReal,
                Alias_Articulo__c = trabajo.alias,
                RM_Aseguradora__c = trabajo.aseguradora,
                RM_CentroCosto__c = trabajo.centroDeCostos,
                Caso__c = casoId,
                RM_EsTrabajoAdicional__c = true,
                RM_WorkOrder__c = workOrderId
            );
            upsert nuevoTrabajo;
            if(crearSubTrabajo == true){
                tiposDeTrabajo__c tipoDeTrabajo = [Select Id,Name,ManoDeObra__c,ManoDeObra__r.Name,UTS__c,Cantidad__c From tiposDeTrabajo__c Where Id =: nuevoTrabajo.Tipotrabajo__c];
                SubtrabajoWrapper subtrabajo = new SubtrabajoWrapper();
                subtrabajo.id = 'local-100001';
                subtrabajo.nombre = tipoDeTrabajo.Name;
                subtrabajo.alias = trabajo.alias;
                subtrabajo.manoDeObra = tipoDeTrabajo.ManoDeObra__c;
                subtrabajo.manoDeObraNombre = tipoDeTrabajo.ManoDeObra__r.Name;
                subtrabajo.tipoTrabajo = tipoDeTrabajo.Id;
                subtrabajo.tipoTrabajoNombre = tipoDeTrabajo.Name;
                subtrabajo.horas = trabajo.uts;
                subtrabajo.uts = trabajo.uts;
                subtrabajo.utsDelTipoDeTrabajo = tipoDeTrabajo.Cantidad__c;
                List<SubtrabajoWrapper> listSubtrabajos = new List<SubtrabajoWrapper>();
                listSubtrabajos.add(subtrabajo);
                saveSubtrabajos(nuevoTrabajo.Id, nuevoTrabajo.Tipotrabajo__c, listSubtrabajos, casoId, workOrderId, nuevoTrabajo.Categor_a_de_presupuesto__c, nuevoTrabajo.Tipo_de_cargo__c, nuevoTrabajo.RM_Aseguradora__c, nuevoTrabajo.RM_CentroCosto__c);     
            }else{
                if(trabajo.changeAlias == true){
                        tiposDeTrabajo__c tipoDeTrabajo = [Select Id,Name,ManoDeObra__c,ManoDeObra__r.Name,UTS__c,Cantidad__c From tiposDeTrabajo__c Where Id =: nuevoTrabajo.Tipotrabajo__c];
                        WorkOrderLineItem woliChange = [Select Id, Alias_Articulo__c From WorkOrderLineItem
                                                       Where WorkOrderId =: workOrderId AND  Product__c =: tipoDeTrabajo.ManoDeObra__c LIMIT 1 ];
                        woliChange.Alias_Articulo__c = trabajo.Alias;
                    	update woliChange;
                }
                if(trabajo.totalSubtrabajos == 1){
                    Subtipo_de_trabajo_del_caso__c subt = [Select Id, UTS__c From Subtipo_de_trabajo_del_caso__c 
                                                           Where Tipo_de_trabajo_del_caso__c =: trabajo.id LIMIT 1];
                    if(trabajo.UTS != subt.UTS__c){
                        subt.UTS__c = trabajo.UTS;
                        update subt;
                    }
                    
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error al guardar el trabajo: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void deleteSubtrabajo(Id subtrabajoId) {
        try {
            Subtipo_de_trabajo_del_caso__c subtrabajo = [SELECT Tipo_de_trabajo_del_caso__c,Id FROM Subtipo_de_trabajo_del_caso__c WHERE Id = :subtrabajoId];
            String IdTrabajo = subtrabajo.Tipo_de_trabajo_del_caso__c;
            delete subtrabajo;
            tiposDeTrabajoCaso__c trabajoPadre = [Select Id, UTS__c,TotalDeUTS__c From tiposDeTrabajoCaso__c
                                                 Where Id =:IdTrabajo LIMIT 1];
            trabajoPadre.UTS__c = trabajoPadre.TotalDeUTS__c;
            update trabajoPadre;
        } catch (Exception e) {
            throw new AuraHandledException('Error al eliminar el subtrabajo: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void deleteTrabajo(Id trabajoId) {
        try {
            List<Subtipo_de_trabajo_del_caso__c> subtrabajos = [
                SELECT Id FROM Subtipo_de_trabajo_del_caso__c WHERE Tipo_de_trabajo_del_caso__c = :trabajoId
            ];
            if (!subtrabajos.isEmpty()) {
                delete subtrabajos;
            }
            tiposDeTrabajoCaso__c trabajo = [SELECT Id FROM tiposDeTrabajoCaso__c WHERE Id = :trabajoId];
            delete trabajo;
        } catch (Exception e) {
            throw new AuraHandledException('Error al eliminar el trabajo: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Decimal getUTSTipoTrabajo(Id idTipoTrabajo){
        Decimal UTS = 0;
        try {
            tiposDeTrabajo__c tdt = [Select Id,UTS__c,Cantidad__c From tiposDeTrabajo__c Where Id=:idTipoTrabajo limit 1];
            UTS = tdt.Cantidad__c;
        } catch (Exception e) {
            throw new AuraHandledException('Error al obtener el valor de cantidad: ' + e.getMessage());
        }
        return UTS;       
    }
    @AuraEnabled
    public static void saveSubtrabajos(Id trabajoId, Id tipoDeTrabajoId, List<SubtrabajoWrapper> subtrabajos, Id caseId, Id workOrderId, String prioridad, String tipodecargo, String aseguradora, String centrodecosto) {
        Impuesto__c impuesto0108 =  [SELECT Id FROM Impuesto__c WHERE codigoImpuesto__c='0108' LIMIT 1];
        WorkOrder wo = [SELECT Case.Asset.Tipo_de_veh_culo__c, Pricebook2Id, WorkOrderNumber, Pricebook2.Name, empresaFactura__c FROM WorkOrder WHERE Id = :workOrderId];
        String tipoDeVehiculo = (wo.Case.Asset.Tipo_de_veh_culo__c != null && wo.Case.Asset.Tipo_de_veh_culo__c != 'Automóvil') ? 'Motocicleta' : 'Automóvil';
        String empresa = wo.empresaFactura__c;
        Id priceBId = wo.Pricebook2Id;
        String priceBookName = wo.Pricebook2.Name;
        String workOrderName = wo.WorkOrderNumber;

        if (impuesto0108 == null) {
            throw new AuraHandledException('El impuesto codigo 0108 no esta configurado.');
        }

        Id codigoImpuesto = impuesto0108.Id;
        Decimal SumaUTS = 0;

        try {
            List<Subtipo_de_trabajo_del_caso__c> subtrabajosToUpsert = new List<Subtipo_de_trabajo_del_caso__c>();
            List<WorkOrderLineItem> worklineitems = new List<WorkOrderLineItem>();
            Set<Id> idsManoDeObra = new Set<Id>();
            Set<Id> idsTipoTrabajo = new Set<Id>();

            for (SubtrabajoWrapper subtrabajo : subtrabajos) {
                idsTipoTrabajo.add(subtrabajo.tipoTrabajo);
            }

            List<tiposDeTrabajo__c> tiposDeTrabajo = [SELECT Id, ManoDeObra__c FROM tiposDeTrabajo__c WHERE Id IN :idsTipoTrabajo];
            Map<Id, Id> tipoTrabajoIdManoDeObraId = new Map<Id, Id>();
            List<Id> tipoTrabajoSinManoDeObra = new List<Id>();

            for (tiposDeTrabajo__c tdt : tiposDeTrabajo) {
                if (tdt.ManoDeObra__c != null) {
                    tipoTrabajoIdManoDeObraId.put(tdt.Id, tdt.ManoDeObra__c);
                    idsManoDeObra.add(tdt.ManoDeObra__c);
                } else {
                    tipoTrabajoSinManoDeObra.add(tdt.Id);
                }
            }

            if (!tipoTrabajoSinManoDeObra.isEmpty()) {
                List<TipoDeCargoConManoDeObra__c> listTCMO = [SELECT ManoDeObra__c, TipoDeCargo__c FROM TipoDeCargoConManoDeObra__c WHERE Empresa__c = :empresa AND TipoDeCargo__c = :tipodecargo AND TipoDeVehiculo__c = :tipoDeVehiculo];
                if (listTCMO.isEmpty()) {
                    throw new AuraHandledException('Tipo de cargo sin mano de obra definida.');
                }
                for (Id tipoTrabajo : tipoTrabajoSinManoDeObra) {
                    tipoTrabajoIdManoDeObraId.put(tipoTrabajo, listTCMO[0].ManoDeObra__c);
                    idsManoDeObra.add(listTCMO[0].ManoDeObra__c);
                }
            }

            Map<String, WorkOrderLineItem> existingWorkLines = new Map<String, WorkOrderLineItem>();
            for (WorkOrderLineItem woli : [SELECT Id, Product__c, Alias_Articulo__c,CurrencyIsoCode FROM WorkOrderLineItem WHERE WorkOrderId = :workOrderId AND Product__c IN :idsManoDeObra]) {
                String claveUnica = woli.Product__c + '-' + woli.Alias_Articulo__c;
                existingWorkLines.put(claveUnica, woli);
            }

            Map<String, WorkOrderLineItem> woliMap = new Map<String, WorkOrderLineItem>();

            for (SubtrabajoWrapper subtrabajo : subtrabajos) {
                if (tipoTrabajoIdManoDeObraId.containsKey(subtrabajo.tipoTrabajo)) {
                    subtrabajo.manoDeObra = tipoTrabajoIdManoDeObraId.get(subtrabajo.tipoTrabajo);
                }

                Subtipo_de_trabajo_del_caso__c nuevoSubtrabajo = new Subtipo_de_trabajo_del_caso__c(
                    Id = subtrabajo.id != null && subtrabajo.id.startsWith('local-') ? null : subtrabajo.id,
                    Caso__c = caseId,
                    Orden_de_trabajo__c = workOrderId,
                    Name = subtrabajo.nombre != null ? subtrabajo.nombre : 'Subtrabajo',
                    UTS__c = subtrabajo.uts != null ? subtrabajo.uts : 0,
                    Cantidad_de_horas__c = subtrabajo.uts != null ? subtrabajo.uts : 0,
                    TipoDeTrabajo__c = subtrabajo.tipoTrabajo,
                    Mano_de_Obra__c = subtrabajo.manoDeObra,
                    Alias__c = subtrabajo.alias != null && subtrabajo.alias != '' ? subtrabajo.alias : subtrabajo.nombre != null ? subtrabajo.nombre : 'Subtrabajo',
                    created_From__c = 'caseWorkTypes',
                    Tipo_de_trabajo_del_caso__c = trabajoId
                );

                SumaUTS += subtrabajo.uts != null ? subtrabajo.uts : 0;

                String claveUnica = subtrabajo.manoDeObra + '-' + (subtrabajo.alias != null ? subtrabajo.alias : '');
                WorkOrderLineItem woli;
                if (existingWorkLines.containsKey(claveUnica)) {
                    woli = existingWorkLines.get(claveUnica);
                } else {
                    woli = new WorkOrderLineItem();
                    woli.WorkOrderId = workOrderId;
                    woli.Product__c = subtrabajo.manoDeObra;
                }

                woli.Quantity = subtrabajo.uts;
                //woli.Alias_Articulo__c = subtrabajo.nombre != null ? subtrabajo.nombre : 'Subtrabajo';
                woli.Alias_Articulo__c = subtrabajo.alias != null && subtrabajo.alias != '' ? subtrabajo.alias : subtrabajo.nombre != null ? subtrabajo.nombre : 'Subtrabajo';
                woli.PricebookEntryId = [SELECT Id FROM PricebookEntry WHERE Product2Id = :subtrabajo.manoDeObra AND Pricebook2Id = :priceBId LIMIT 1].Id;
                woli.Impuesto__c = codigoImpuesto;
                woli.aprobado__c = true;
                woli.especificacionesTaller__c = prioridad;
                woli.tiposDeTrabajo__c = tipoDeTrabajoId;
                woli.Trabajo__c = 'Mano de Obra';
                woli.created_From__c = 'caseWorkTypes';

                woliMap.put(claveUnica, woli);
                subtrabajosToUpsert.add(nuevoSubtrabajo);
            }

            List<WorkOrderLineItem> worklineitemsFinal = new List<WorkOrderLineItem>(woliMap.values());
            upsert worklineitemsFinal;

            for (Integer i = 0; i < subtrabajosToUpsert.size(); i++) {
                if (i < worklineitemsFinal.size()) {
                    subtrabajosToUpsert[i].Articulo_Mano_de_Obra__c = worklineitemsFinal[i].Id;
                }
            }

            if (!subtrabajosToUpsert.isEmpty()) {
                upsert subtrabajosToUpsert;

                tiposDeTrabajoCaso__c tipoTrabajoCaso = [SELECT Id, UTS__c, Horaa__c FROM tiposDeTrabajoCaso__c WHERE Id = :trabajoId LIMIT 1];
                tipoTrabajoCaso.UTS__c = SumaUTS;
                tipoTrabajoCaso.Horaa__c = SumaUTS;
                update tipoTrabajoCaso;
            }
            TipoTrabajoCasoController.createTipoCargo(worklineitemsFinal, tipodecargo, aseguradora, centrodecosto);
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