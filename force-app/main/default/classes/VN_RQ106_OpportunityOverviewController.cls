public with sharing class VN_RQ106_OpportunityOverviewController {
    private static final Set<String> APPROVED_OR_APPLIED_STATUSES = new Set<String>{
        'Aplicado',
        'Vehículo reservado'
    };
    private static final String STATUS_CONFIRMADA_TESORERIA = 'Confirmada por Tesorería';
    private static final String STATUS_ANTICIPO_CREADO = 'Anticipo creado';
    private static final String ESTADO_PRODUCTO_PENDIENTE = 'Pendiente';
    private static final String ESTADO_PRODUCTO_RECHAZADA = 'Rechazada';
    private static final String TIPO_RESERVA = 'Reserva de vehículo';

    @AuraEnabled(cacheable=true)
    public static Overview getOverview(Id opportunityId) {
        if (opportunityId == null) {
            throw new AuraHandledException('La oportunidad es requerida.');
        }

        Opportunity opp = [
            SELECT Id, Name, AccountId, Account.Name, StageName, OwnerId, Owner.Name,
                JefeSucursal__c, GerenteSucursal__c,
                CurrencyIsoCode, Valor_Total_Oportunidad_FX__c,
                Total_Anticipos_Aprobados__c, Saldo_Pendiente__c, Estado_Anticipo__c,
                Tiene_Vehiculos_Reservados__c, Vehiculos_Reservados__c
            FROM Opportunity
            WHERE Id = :opportunityId
            LIMIT 1
        ];

        Overview overview = new Overview();
        overview.opportunityId = opp.Id;
        overview.opportunityName = opp.Name;
        overview.accountId = opp.AccountId;
        overview.accountName = opp.Account == null ? null : opp.Account.Name;
        overview.stageName = opp.StageName;
        overview.ownerId = opp.OwnerId;
        overview.ownerName = opp.Owner == null ? null : opp.Owner.Name;
        overview.jefeSucursalId = opp.JefeSucursal__c;
        overview.gerenteSucursalId = opp.GerenteSucursal__c;
        overview.currencyIsoCode = opp.CurrencyIsoCode;
        overview.valorTotalOportunidad = opp.Valor_Total_Oportunidad_FX__c;
        overview.totalAnticiposAprobados = opp.Total_Anticipos_Aprobados__c;
        overview.saldoPendiente = opp.Saldo_Pendiente__c;
        overview.estadoAnticipo = opp.Estado_Anticipo__c;
        overview.tieneVehiculosReservados = opp.Tiene_Vehiculos_Reservados__c;
        overview.vehiculosReservados = opp.Vehiculos_Reservados__c;
        overview.pdfStatus = 'PDF Softland pendiente de generación';
        overview.retryStatus = 'No disponible todavía';
        overview.vehicles = getVehicles(opportunityId);
        overview.anticipos = getAnticipos(opportunityId, opp);
        overview.solicitudes = new List<AnticipoSummary>();
        overview.anticiposAprobados = new List<AnticipoSummary>();
        overview.historial = new List<HistorySummary>();

        Boolean hasCorrection = false;
        Boolean hasIntegrationError = false;
        String latestStatus;
        for (AnticipoSummary anticipo : overview.anticipos) {
            overview.solicitudes.add(anticipo);
            if (anticipo.isApprovedOrApplied) {
                overview.anticiposAprobados.add(anticipo);
            }
            if (latestStatus == null) {
                latestStatus = anticipo.estatus;
            }
            if (anticipo.estatus == 'Corrección requerida por Tesorería') {
                hasCorrection = true;
            }
            if (anticipo.estatus == 'Error de integración') {
                hasIntegrationError = true;
            }

            HistorySummary event = new HistorySummary();
            event.anticipoId = anticipo.id;
            event.anticipoName = anticipo.name;
            event.estatus = anticipo.estatus;
            event.comentario = String.isBlank(anticipo.comentariosAprobacionRechazo)
                ? anticipo.comentariosAsesor
                : anticipo.comentariosAprobacionRechazo;
            event.fecha = anticipo.lastModifiedDate;
            event.usuario = anticipo.lastModifiedByName;
            overview.historial.add(event);
        }

        overview.estadoAnticipoActual = String.isBlank(latestStatus)
            ? (String.isBlank(overview.estadoAnticipo) ? 'Sin solicitudes registradas' : overview.estadoAnticipo)
            : latestStatus;
        overview.reservaStatus = buildReservaStatus(opp, overview.vehicles);
        overview.correccionSolicitada = hasCorrection;
        overview.errorIntegracion = hasIntegrationError;
        overview.reintentoAutorizado = false;
        return overview;
    }

    private static List<VehicleSummary> getVehicles(Id opportunityId) {
        List<VehicleSummary> vehicles = new List<VehicleSummary>();
        for (OpportunityLineItem item : [
            SELECT Id, Product2Id, Product2.Name, Product2.vin__c,
                Product2.Producto_Reservado__c
            FROM OpportunityLineItem
            WHERE OpportunityId = :opportunityId
                AND Product2Id != null
            ORDER BY CreatedDate ASC
            LIMIT 20
        ]) {
            VehicleSummary vehicle = new VehicleSummary();
            vehicle.opportunityLineItemId = item.Id;
            vehicle.productId = item.Product2Id;
            vehicle.name = item.Product2 == null ? null : item.Product2.Name;
            vehicle.vin = item.Product2 == null ? null : item.Product2.vin__c;
            vehicle.reserved = item.Product2 == null ? null : item.Product2.Producto_Reservado__c;
            vehicles.add(vehicle);
        }
        return vehicles;
    }

    private static List<AnticipoSummary> getAnticipos(Id opportunityId, Opportunity opp) {
        List<Anticipo__c> records = [
            SELECT Id, Name, Estatus__c, Monto__c, CurrencyIsoCode, Fecha_Ingreso__c,
                Tipo_Ingreso__c, Referencia_Comprobante__c, Depositante__c,
                Comentarios_Asesor__c, Comentarios_Aprobacion_Rechazo__c,
                Estado_Aprobacion_Producto__c, Identificador_Helios__c,
                Producto__c, Producto__r.Name, Producto__r.vin__c,
                CreatedDate, LastModifiedDate, CreatedBy.Name, LastModifiedBy.Name
            FROM Anticipo__c
            WHERE Oportunidad__c = :opportunityId
            ORDER BY CreatedDate DESC
            LIMIT 50
        ];

        Boolean isAuthorizedManager = canManageReservationApproval(opp != null ? opp.JefeSucursal__c : null);
        Set<Id> anticipoIds = new Set<Id>();
        for (Anticipo__c record : records) {
            anticipoIds.add(record.Id);
        }

        Map<Id, Integer> evidenceCounts = new Map<Id, Integer>();
        if (!anticipoIds.isEmpty()) {
            for (AggregateResult result : [
                SELECT LinkedEntityId entityId, COUNT(Id) total
                FROM ContentDocumentLink
                WHERE LinkedEntityId IN :anticipoIds
                GROUP BY LinkedEntityId
            ]) {
                evidenceCounts.put((Id) result.get('entityId'), (Integer) result.get('total'));
            }
        }

        List<AnticipoSummary> anticipos = new List<AnticipoSummary>();
        for (Anticipo__c record : records) {
            AnticipoSummary summary = new AnticipoSummary();
            summary.id = record.Id;
            summary.name = record.Name;
            summary.estatus = record.Estatus__c;
            summary.monto = record.Monto__c;
            summary.currencyIsoCode = record.CurrencyIsoCode;
            summary.fechaIngreso = record.Fecha_Ingreso__c;
            summary.tipoIngreso = record.Tipo_Ingreso__c;
            summary.referenciaComprobante = record.Referencia_Comprobante__c;
            summary.depositante = record.Depositante__c;
            summary.comentariosAsesor = record.Comentarios_Asesor__c;
            summary.comentariosAprobacionRechazo = record.Comentarios_Aprobacion_Rechazo__c;
            summary.estadoAprobacionProducto = record.Estado_Aprobacion_Producto__c;
            summary.comentariosDisplay = String.isBlank(summary.comentariosAprobacionRechazo)
                ? summary.comentariosAsesor
                : summary.comentariosAprobacionRechazo;
            summary.productoId = record.Producto__c;
            summary.productoName = record.Producto__r == null ? null : record.Producto__r.Name;
            summary.vin = record.Producto__r == null ? null : record.Producto__r.vin__c;
            summary.createdDate = record.CreatedDate;
            summary.lastModifiedDate = record.LastModifiedDate;
            summary.createdByName = record.CreatedBy == null ? null : record.CreatedBy.Name;
            summary.lastModifiedByName = record.LastModifiedBy == null ? null : record.LastModifiedBy.Name;
            summary.identificadorHelios = record.Identificador_Helios__c;
            summary.evidenceCount = evidenceCounts.containsKey(record.Id) ? evidenceCounts.get(record.Id) : 0;
            summary.evidenceStatus = summary.evidenceCount > 0 ? 'Con evidencia' : 'Sin evidencia';
            summary.approverName = APPROVED_OR_APPLIED_STATUSES.contains(record.Estatus__c)
                ? summary.lastModifiedByName
                : null;
            summary.isApprovedOrApplied = APPROVED_OR_APPLIED_STATUSES.contains(record.Estatus__c);
            Boolean isPendingProductApproval =
                String.isBlank(record.Estado_Aprobacion_Producto__c) ||
                record.Estado_Aprobacion_Producto__c == ESTADO_PRODUCTO_PENDIENTE;
            summary.canApproveReservation =
                isAuthorizedManager &&
                record.Tipo_Ingreso__c == TIPO_RESERVA &&
                isReadyForProductApproval(record) &&
                isPendingProductApproval;
            summary.canRejectReservation = summary.canApproveReservation;
            summary.canResendReservation =
                isAuthorizedManager &&
                record.Tipo_Ingreso__c == TIPO_RESERVA &&
                record.Estado_Aprobacion_Producto__c == ESTADO_PRODUCTO_RECHAZADA;
            anticipos.add(summary);
        }
        return anticipos;
    }

    private static Boolean canManageReservationApproval(Id jefeSucursalId) {
        if (jefeSucursalId == null) {
            return false;
        }
        return String.valueOf(jefeSucursalId) == UserInfo.getUserId();
    }

    @TestVisible
    private static Boolean isReadyForProductApproval(Anticipo__c solicitud) {
        if (solicitud == null) {
            return false;
        }
        if (solicitud.Estatus__c == STATUS_CONFIRMADA_TESORERIA) {
            return true;
        }
        return solicitud.Estatus__c == STATUS_ANTICIPO_CREADO &&
            !String.isBlank(solicitud.Identificador_Helios__c);
    }

    private static String buildReservaStatus(Opportunity opp, List<VehicleSummary> vehicles) {
        if (opp.Tiene_Vehiculos_Reservados__c == true) {
            return String.isBlank(opp.Vehiculos_Reservados__c)
                ? 'Reserva disponible'
                : opp.Vehiculos_Reservados__c;
        }
        for (VehicleSummary vehicle : vehicles) {
            if (vehicle.reserved == true) {
                return String.isBlank(vehicle.name) ? 'Vehículo reservado' : vehicle.name;
            }
        }
        return 'Reserva VN pendiente/producto disponible';
    }

    public class Overview {
        @AuraEnabled public Id opportunityId { get; set; }
        @AuraEnabled public String opportunityName { get; set; }
        @AuraEnabled public Id accountId { get; set; }
        @AuraEnabled public String accountName { get; set; }
        @AuraEnabled public String stageName { get; set; }
        @AuraEnabled public Id ownerId { get; set; }
        @AuraEnabled public String ownerName { get; set; }
        @AuraEnabled public Id jefeSucursalId { get; set; }
        @AuraEnabled public Id gerenteSucursalId { get; set; }
        @AuraEnabled public String currencyIsoCode { get; set; }
        @AuraEnabled public Decimal valorTotalOportunidad { get; set; }
        @AuraEnabled public Decimal totalAnticiposAprobados { get; set; }
        @AuraEnabled public Decimal saldoPendiente { get; set; }
        @AuraEnabled public String estadoAnticipo { get; set; }
        @AuraEnabled public String estadoAnticipoActual { get; set; }
        @AuraEnabled public Boolean tieneVehiculosReservados { get; set; }
        @AuraEnabled public String vehiculosReservados { get; set; }
        @AuraEnabled public String reservaStatus { get; set; }
        @AuraEnabled public String pdfStatus { get; set; }
        @AuraEnabled public String retryStatus { get; set; }
        @AuraEnabled public Boolean correccionSolicitada { get; set; }
        @AuraEnabled public Boolean errorIntegracion { get; set; }
        @AuraEnabled public Boolean reintentoAutorizado { get; set; }
        @AuraEnabled public List<VehicleSummary> vehicles { get; set; }
        @AuraEnabled public List<AnticipoSummary> anticipos { get; set; }
        @AuraEnabled public List<AnticipoSummary> solicitudes { get; set; }
        @AuraEnabled public List<AnticipoSummary> anticiposAprobados { get; set; }
        @AuraEnabled public List<HistorySummary> historial { get; set; }
    }

    public class VehicleSummary {
        @AuraEnabled public Id opportunityLineItemId { get; set; }
        @AuraEnabled public Id productId { get; set; }
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public String vin { get; set; }
        @AuraEnabled public Boolean reserved { get; set; }
    }

    public class AnticipoSummary {
        @AuraEnabled public Id id { get; set; }
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public String estatus { get; set; }
        @AuraEnabled public Decimal monto { get; set; }
        @AuraEnabled public String currencyIsoCode { get; set; }
        @AuraEnabled public Date fechaIngreso { get; set; }
        @AuraEnabled public String tipoIngreso { get; set; }
        @AuraEnabled public String referenciaComprobante { get; set; }
        @AuraEnabled public String depositante { get; set; }
        @AuraEnabled public String comentariosAsesor { get; set; }
        @AuraEnabled public String comentariosAprobacionRechazo { get; set; }
        @AuraEnabled public String comentariosDisplay { get; set; }
        @AuraEnabled public String estadoAprobacionProducto { get; set; }
        @AuraEnabled public Id productoId { get; set; }
        @AuraEnabled public String productoName { get; set; }
        @AuraEnabled public String vin { get; set; }
        @AuraEnabled public Datetime createdDate { get; set; }
        @AuraEnabled public Datetime lastModifiedDate { get; set; }
        @AuraEnabled public String createdByName { get; set; }
        @AuraEnabled public String lastModifiedByName { get; set; }
        @AuraEnabled public Integer evidenceCount { get; set; }
        @AuraEnabled public String evidenceStatus { get; set; }
        @AuraEnabled public String approverName { get; set; }
        @AuraEnabled public Boolean isApprovedOrApplied { get; set; }
        @AuraEnabled public String identificadorHelios { get; set; }
        @AuraEnabled public Boolean canApproveReservation { get; set; }
        @AuraEnabled public Boolean canRejectReservation { get; set; }
        @AuraEnabled public Boolean canResendReservation { get; set; }
    }

    public class HistorySummary {
        @AuraEnabled public Id anticipoId { get; set; }
        @AuraEnabled public String anticipoName { get; set; }
        @AuraEnabled public String estatus { get; set; }
        @AuraEnabled public String comentario { get; set; }
        @AuraEnabled public Datetime fecha { get; set; }
        @AuraEnabled public String usuario { get; set; }
    }
}
