public with sharing class VN_RQ106_AnticipoController {
    private static final String STATUS_BORRADOR = 'Borrador';
    private static final String STATUS_EN_VALIDACION_TESORERIA = 'En validación de Tesorería';
    private static final String TIPO_RESERVA = 'Reserva de vehículo';

    @AuraEnabled(cacheable=true)
    public static OpportunityContext getOpportunityContext(Id opportunityId) {
        if (opportunityId == null) {
            throw new AuraHandledException('La oportunidad es requerida.');
        }

        Opportunity opp = [
            SELECT Id, Name, AccountId, Account.Name, OwnerId, Owner.Name,
                RecordType.DeveloperName, JefeSucursal__c, JefeSucursal__r.Name,
                GerenteSucursal__c, GerenteSucursal__r.Name, SucursalId__c,
                SucursalId__r.Name, Sucursal__c, Synced_Quote__c, CurrencyIsoCode,
                Valor_Total_Oportunidad_FX__c, Total_Anticipos_Aprobados__c,
                Saldo_Pendiente__c
            FROM Opportunity
            WHERE Id = :opportunityId
            LIMIT 1
        ];

        OpportunityContext context = new OpportunityContext();
        context.opportunityId = opp.Id;
        context.opportunityName = opp.Name;
        context.accountId = opp.AccountId;
        context.accountName = opp.Account == null ? null : opp.Account.Name;
        context.ownerId = opp.OwnerId;
        context.ownerName = opp.Owner == null ? null : opp.Owner.Name;
        context.recordTypeDeveloperName = opp.RecordType == null ? null : opp.RecordType.DeveloperName;
        context.jefeSucursalId = opp.JefeSucursal__c;
        context.jefeSucursalName = opp.JefeSucursal__r == null ? null : opp.JefeSucursal__r.Name;
        context.gerenteSucursalId = opp.GerenteSucursal__c;
        context.gerenteSucursalName = opp.GerenteSucursal__r == null ? null : opp.GerenteSucursal__r.Name;
        context.sucursalId = opp.SucursalId__c;
        context.sucursalName = opp.SucursalId__r == null ? null : opp.SucursalId__r.Name;
        context.sucursalValue = opp.Sucursal__c;
        context.syncedQuoteId = opp.Synced_Quote__c;
        context.currencyIsoCode = opp.CurrencyIsoCode;
        context.valorTotalOportunidad = opp.Valor_Total_Oportunidad_FX__c;
        context.totalAnticiposAprobados = opp.Total_Anticipos_Aprobados__c;
        context.saldoPendiente = opp.Saldo_Pendiente__c;
        context.products = getProducts(opportunityId);
        return context;
    }

    @AuraEnabled
    public static DraftSolicitudResult createDraftSolicitud(DraftSolicitudRequest payload) {
        validatePayload(payload);
        Opportunity opp = getOpportunityForDraft(payload.opportunityId);

        Anticipo__c solicitud = new Anticipo__c();
        solicitud.Oportunidad__c = payload.opportunityId;
        solicitud.CurrencyIsoCode = opp.CurrencyIsoCode;
        solicitud.Monto__c = payload.monto;
        solicitud.Tipo_Ingreso__c = payload.tipoIngreso;
        solicitud.Medio_Pago__c = payload.medioPago;
        solicitud.Fecha_Ingreso__c = payload.fechaIngreso;
        solicitud.Referencia_Comprobante__c = payload.referenciaComprobante;
        solicitud.Depositante__c = payload.depositante;
        solicitud.Comentarios_Asesor__c = payload.comentariosAsesor;
        solicitud.Estatus__c = STATUS_BORRADOR;

        if (payload.tipoIngreso == TIPO_RESERVA) {
            validateProductBelongsToOpportunity(payload.opportunityId, payload.productoId);
            solicitud.Producto__c = payload.productoId;
        }

        insert solicitud;

        DraftSolicitudResult result = new DraftSolicitudResult();
        result.anticipoId = solicitud.Id;
        result.estatus = solicitud.Estatus__c;
        return result;
    }

    @AuraEnabled
    public static DraftSolicitudResult sendToTreasury(Id anticipoId) {
        if (anticipoId == null) {
            throw new AuraHandledException('La solicitud es requerida.');
        }

        List<Anticipo__c> solicitudes = [
            SELECT Id, Estatus__c
            FROM Anticipo__c
            WHERE Id = :anticipoId
            LIMIT 1
        ];
        if (solicitudes.isEmpty()) {
            throw new AuraHandledException('La solicitud no existe.');
        }

        Anticipo__c solicitud = solicitudes[0];
        if (solicitud.Estatus__c != STATUS_BORRADOR) {
            throw new AuraHandledException('Solo se pueden enviar solicitudes en estado Borrador.');
        }

        Integer evidenceCount = [
            SELECT COUNT()
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :anticipoId
        ];
        if (evidenceCount == 0) {
            throw new AuraHandledException('Debe adjuntar al menos una evidencia antes de enviar a Tesorería.');
        }

        solicitud.Estatus__c = STATUS_EN_VALIDACION_TESORERIA;
        update solicitud;

        DraftSolicitudResult result = new DraftSolicitudResult();
        result.anticipoId = solicitud.Id;
        result.estatus = solicitud.Estatus__c;
        return result;
    }

    private static Opportunity getOpportunityForDraft(Id opportunityId) {
        List<Opportunity> opportunities = [
            SELECT Id, AccountId, CurrencyIsoCode
            FROM Opportunity
            WHERE Id = :opportunityId
            LIMIT 1
        ];
        if (opportunities.isEmpty()) {
            throw new AuraHandledException('La oportunidad no existe.');
        }
        if (opportunities[0].AccountId == null) {
            throw new AuraHandledException('La oportunidad debe tener un cliente relacionado.');
        }
        return opportunities[0];
    }

    private static void validatePayload(DraftSolicitudRequest payload) {
        if (payload == null) {
            throw new AuraHandledException('La solicitud es requerida.');
        }
        if (payload.opportunityId == null) {
            throw new AuraHandledException('La oportunidad es requerida.');
        }
        if (String.isBlank(payload.tipoIngreso)) {
            throw new AuraHandledException('El tipo de ingreso es requerido.');
        }
        if (payload.monto == null || payload.monto <= 0) {
            throw new AuraHandledException('El monto es requerido.');
        }
        if (String.isBlank(payload.medioPago)) {
            throw new AuraHandledException('El medio de pago es requerido.');
        }
        if (payload.fechaIngreso == null) {
            throw new AuraHandledException('La fecha de ingreso es requerida.');
        }
        if (String.isBlank(payload.referenciaComprobante)) {
            throw new AuraHandledException('La referencia o comprobante es requerido.');
        }
        if (payload.tipoIngreso == TIPO_RESERVA && payload.productoId == null) {
            throw new AuraHandledException('El vehículo es requerido para reservas.');
        }
    }

    private static void validateProductBelongsToOpportunity(Id opportunityId, Id productId) {
        List<OpportunityLineItem> lines = [
            SELECT Id
            FROM OpportunityLineItem
            WHERE OpportunityId = :opportunityId
                AND Product2Id = :productId
            LIMIT 1
        ];
        if (lines.isEmpty()) {
            throw new AuraHandledException('El vehículo seleccionado no pertenece a la oportunidad.');
        }
    }

    private static List<ProductOption> getProducts(Id opportunityId) {
        List<ProductOption> options = new List<ProductOption>();
        for (OpportunityLineItem item : [
            SELECT Id, Product2Id, Product2.Name, Product2.Marca__c,
                Product2.Modelo_De_Inter_s__c, Product2.vin__c,
                Product2.Producto_Reservado__c, Product2.esVehiculo__c,
                Product2.es_Vehiculo_usado__c
            FROM OpportunityLineItem
            WHERE OpportunityId = :opportunityId
                AND Product2Id != null
                AND Product2.RecordType.DeveloperName = 'Vehiculos'
                AND Product2.IsActive = true
                AND Product2.Producto_Reservado__c = false
                AND (Product2.esVehiculo__c = true OR Product2.es_Vehiculo_usado__c = true)
            ORDER BY Product2.Name
            LIMIT 100
        ]) {
            ProductOption option = new ProductOption();
            option.opportunityLineItemId = item.Id;
            option.productId = item.Product2Id;
            option.productName = item.Product2 == null ? null : item.Product2.Name;
            option.brand = item.Product2 == null ? null : item.Product2.Marca__c;
            option.model = item.Product2 == null ? null : item.Product2.Modelo_De_Inter_s__c;
            option.vin = item.Product2 == null ? null : item.Product2.vin__c;
            option.productReserved = item.Product2 == null ? null : item.Product2.Producto_Reservado__c;
            option.isNewVehicle = item.Product2 == null ? null : item.Product2.esVehiculo__c;
            option.isUsedVehicle = item.Product2 == null ? null : item.Product2.es_Vehiculo_usado__c;
            options.add(option);
        }
        return options;
    }

    public class DraftSolicitudRequest {
        @AuraEnabled public Id opportunityId { get; set; }
        @AuraEnabled public Decimal monto { get; set; }
        @AuraEnabled public String tipoIngreso { get; set; }
        @AuraEnabled public String medioPago { get; set; }
        @AuraEnabled public Date fechaIngreso { get; set; }
        @AuraEnabled public String referenciaComprobante { get; set; }
        @AuraEnabled public String depositante { get; set; }
        @AuraEnabled public String comentariosAsesor { get; set; }
        @AuraEnabled public Id productoId { get; set; }
    }

    public class DraftSolicitudResult {
        @AuraEnabled public Id anticipoId { get; set; }
        @AuraEnabled public String estatus { get; set; }
    }

    public class OpportunityContext {
        @AuraEnabled public Id opportunityId { get; set; }
        @AuraEnabled public String opportunityName { get; set; }
        @AuraEnabled public Id accountId { get; set; }
        @AuraEnabled public String accountName { get; set; }
        @AuraEnabled public Id ownerId { get; set; }
        @AuraEnabled public String ownerName { get; set; }
        @AuraEnabled public String recordTypeDeveloperName { get; set; }
        @AuraEnabled public Id jefeSucursalId { get; set; }
        @AuraEnabled public String jefeSucursalName { get; set; }
        @AuraEnabled public Id gerenteSucursalId { get; set; }
        @AuraEnabled public String gerenteSucursalName { get; set; }
        @AuraEnabled public Id sucursalId { get; set; }
        @AuraEnabled public String sucursalName { get; set; }
        @AuraEnabled public String sucursalValue { get; set; }
        @AuraEnabled public Id syncedQuoteId { get; set; }
        @AuraEnabled public String currencyIsoCode { get; set; }
        @AuraEnabled public Decimal valorTotalOportunidad { get; set; }
        @AuraEnabled public Decimal totalAnticiposAprobados { get; set; }
        @AuraEnabled public Decimal saldoPendiente { get; set; }
        @AuraEnabled public List<ProductOption> products { get; set; }
    }

    public class ProductOption {
        @AuraEnabled public Id opportunityLineItemId { get; set; }
        @AuraEnabled public Id productId { get; set; }
        @AuraEnabled public String productName { get; set; }
        @AuraEnabled public String brand { get; set; }
        @AuraEnabled public String model { get; set; }
        @AuraEnabled public String vin { get; set; }
        @AuraEnabled public Boolean productReserved { get; set; }
        @AuraEnabled public Boolean isNewVehicle { get; set; }
        @AuraEnabled public Boolean isUsedVehicle { get; set; }
    }
}
