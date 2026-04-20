public with sharing class TipoCargoApprovalController {

    // ====== DTO para la tabla ======
    public class RowDTO {
        @AuraEnabled public Id id;
        @AuraEnabled public String aliasProducto;
        @AuraEnabled public String centroCostoName;
        @AuraEnabled public Id centroCostoId;
        @AuraEnabled public Decimal precio;
        @AuraEnabled public String estadoAprobacion;
        @AuraEnabled public String currencyIsoCode;
        @AuraEnabled public List<Id> tipoCargoIds;
        @AuraEnabled public Boolean disableCheck;
    }
    @AuraEnabled(cacheable=true)
    public static Boolean hasPendingCentroCostoApproval(Id workOrderId) {
        if (workOrderId == null) {
            return false;
        }
         WorkOrder wo = [
            SELECT Aprobador_Centro_de_Costos__c
            FROM WorkOrder
            WHERE Id = :workOrderId
            LIMIT 1
        ];
    
        return (wo.Aprobador_Centro_de_Costos__c != null);
    }

    // ====== Obtener filas para la tabla ======
    @AuraEnabled(cacheable=true)
    public static List<RowDTO> getInternalTiposCargo(Id workOrderId) {
        if (workOrderId == null) return new List<RowDTO>();

        String internoValue = '2';

        List<TipoCargo__c> tcs = [
            SELECT
                Id,
                Alias_Producto__c,
                Precio__c,
                CentroCosto__c,
                CentroCosto__r.Name,
                CurrencyIsoCode,
                Work_Order_Line_Item__c,
                Work_Order_Line_Item__r.Cantidad__c,
                Work_Order_Line_Item__r.tiposDeTrabajo__c,
                Work_Order_Line_Item__r.tiposDeTrabajo__r.Name,
                Work_Order_Line_Item__r.Estado_aprobaci_n_CC__c
            FROM TipoCargo__c
            WHERE TipoCargo__c = :internoValue
            AND Work_Order_Line_Item__c IN (
                SELECT Id
                FROM WorkOrderLineItem
                WHERE WorkOrderId = :workOrderId
            )
        ];

        // key = Id del tipo de trabajo (Work_Order_Line_Item__r.tiposDeTrabajo__c)
        Map<String, RowDTO> grouped = new Map<String, RowDTO>();

        for (TipoCargo__c tc : tcs) {
            if (tc.Work_Order_Line_Item__r == null ||
                tc.Work_Order_Line_Item__r.tiposDeTrabajo__c == null) {
                // si por alguna razón no tiene tipo de trabajo, lo puedes saltar o manejar aparte
                continue;
            }

            String tipoTrabajoId = (String)tc.Work_Order_Line_Item__r.tiposDeTrabajo__c;
            RowDTO row = grouped.get(tipoTrabajoId);

            // Monto de este renglón: Precio * Cantidad
            Decimal lineAmount =
                (tc.Precio__c == null ? 0 : tc.Precio__c) *
                (tc.Work_Order_Line_Item__r.Cantidad__c == null ? 1 : tc.Work_Order_Line_Item__r.Cantidad__c);

            String estado = String.isBlank(tc.Work_Order_Line_Item__r.Estado_aprobaci_n_CC__c)
                ? '-'
                : tc.Work_Order_Line_Item__r.Estado_aprobaci_n_CC__c;

            if (row == null) {
                row = new RowDTO();
                row.id              = tc.Id; // primer TipoCargo del grupo, solo para key
                row.aliasProducto   = tc.Work_Order_Line_Item__r.tiposDeTrabajo__r.Name;
                row.centroCostoId   = tc.CentroCosto__c;
                row.centroCostoName = (tc.CentroCosto__r != null ? tc.CentroCosto__r.Name : null);
                row.precio          = lineAmount;
                row.currencyIsoCode = tc.CurrencyIsoCode;
                row.tipoCargoIds    = new List<Id>{ tc.Id };
                row.estadoAprobacion = estado;
                row.disableCheck    = (estado != '-' && estado != 'Requiere envío a aprobación');
                grouped.put(tipoTrabajoId, row);
            } else {
                // sumamos el monto
                row.precio += lineAmount;
                row.tipoCargoIds.add(tc.Id);

                // si alguno está En Proceso, la fila queda En Proceso y deshabilitada
                if (estado == 'En Proceso') {
                    row.estadoAprobacion = 'En Proceso';
                    row.disableCheck = true;
                } else if (row.estadoAprobacion == '-' && estado != '-') {
                    // si antes era '-' y ahora hay un estado real, lo tomamos
                    row.estadoAprobacion = estado;
                }
            }
        }

        return grouped.values();
    }


    // ====== Enviar a aprobación ======
    @AuraEnabled
    public static void submitForApproval(
        Id workOrderId,
        List<Id> selectedTipoCargoIds,
        String comment
    ) {
        if (workOrderId == null) {
            throw new AuraHandledException('Falta el Id de la Work Order.');
        }
        if (selectedTipoCargoIds == null || selectedTipoCargoIds.isEmpty()) { throw new AuraHandledException('Selecciona al menos un tipo de cargo.');
        }
        if (String.isBlank(comment)) { throw new AuraHandledException('El comentario del solicitante es obligatorio.');
        }

        List<TipoCargo__c> tcs = [
            SELECT Id, Precio__c, CentroCosto__c, CentroCosto__r.Aprobador__c,
                   Work_Order_Line_Item__c
            FROM TipoCargo__c
            WHERE Id IN :selectedTipoCargoIds
        ];
        if (tcs.isEmpty()) { throw new AuraHandledException('No se encontraron los tipos de cargo seleccionados.');
        }

        // Total de los checks
        Decimal total = 0;
        Set<Id> woliIds = new Set<Id>();
        for (TipoCargo__c tc : tcs) {
            total += (tc.Precio__c == null ? 0 : tc.Precio__c);
            if (tc.Work_Order_Line_Item__c != null) woliIds.add(tc.Work_Order_Line_Item__c);
        }

        // Primer seleccionado define el Centro de Costo y su aprobador
        TipoCargo__c first = tcs[0];
        if (first.CentroCosto__c == null) { throw new AuraHandledException('El Tipo de cargo seleccionado no tiene Centro de Costo configurado.');
        }

        // Cargar WorkOrder para tomar el número y revisar lookups
        WorkOrder woRec = [
            SELECT Id, WorkOrderNumber,Comentarios_aprobaci_n_centro_de_costos__c,
                   Aprobador_Centro_de_Costos__c,Monto_Aprobaci_n_centro_de_costos__c,
                   CentroDeCostoAprobacion__c
            FROM WorkOrder
            WHERE Id = :workOrderId
            LIMIT 1
        ];
		
        // Generar identificador (único)
        // Ej.: CCA-00012345-1731181234567
        String identifier = 'CCA-' +
            (woRec.WorkOrderNumber != null ? woRec.WorkOrderNumber : String.valueOf(workOrderId).left(8)) +
            '-' + String.valueOf(Datetime.now().getTime());

        // Actualizar TODAS las WOLIs involucradas con el mismo total y comentario
        if (!woliIds.isEmpty()) {
            List<WorkOrderLineItem> wolis = [
                SELECT Id,
                       Comentarios_aprobaci_n_centro_de_costos__c,
                       Monto_Aprobaci_n_centro_de_costos__c,
                       Identificador_Aprobaci_n_centro_de_costo__c,Estado_aprobaci_n_CC__c
                FROM WorkOrderLineItem
                WHERE Id IN :woliIds
            ];
            for (WorkOrderLineItem w : wolis) {
                w.Comentarios_aprobaci_n_centro_de_costos__c = comment;
                w.Monto_Aprobaci_n_centro_de_costos__c = total;
                w.Identificador_Aprobaci_n_centro_de_costo__c  = identifier;
                w.Estado_aprobaci_n_CC__c = 'En Proceso';
            }
            if (!wolis.isEmpty()) update wolis;
        }

        // Actualizar WorkOrder: comentarios, monto y (si procede) aprobador/centro de costo
        WorkOrder woUpd = new WorkOrder(
            Id = workOrderId
        );
		Set<Id> centros = new Set<Id>();
        for (TipoCargo__c tc : tcs) {
            centros.add(tc.CentroCosto__c);
        }
        if (centros.size() > 1) {
            throw new AuraHandledException(
                'No se puede enviar a aprobación tipos de cargo de distintos centros de costo.'
            );
        }
        // Si ya tiene ambos lookups, se considera que hay una aprobación en curso/configurada y no reescribimos
        Boolean lookupsSet = (woRec.Aprobador_Centro_de_Costos__c != null && woRec.CentroDeCostoAprobacion__c != null);

        if (!lookupsSet) {
            woUpd.Aprobador_Centro_de_Costos__c = first.CentroCosto__r.Aprobador__c; woUpd.CentroDeCostoAprobacion__c    = first.CentroCosto__c;
            woUpd.Comentarios_aprobaci_n_centro_de_costos__c = comment; woUpd.Monto_Aprobaci_n_centro_de_costos__c = total;woUpd.Identificador_Aprobaci_n_centro_de_costo__c = identifier; update woUpd;
        }

    }
}