public with sharing class QuoteApprovalController {

    // Objeto de resultado que el LWC recibe
    public class QuoteValidationResult {
        @AuraEnabled public Boolean isValid;
        @AuraEnabled public String message;
        @AuraEnabled public String centroDeCostosName;
        @AuraEnabled public Decimal totalQuote;
        @AuraEnabled public String estatusAprobacion;

        public QuoteValidationResult() {}

        public QuoteValidationResult(Boolean isValid, String message) {
            this.isValid = isValid;
            this.message = message;
        }
    }

    // 🔹 1) ¿Tiene aprobación pendiente?
    @AuraEnabled(cacheable=true)
    public static Boolean hasPendingApproval(Id quoteId) {
        if (quoteId == null) {
            return false;
        }

        List<Quote> quotes = [
            SELECT CPEstatusDeAprobacion__c
            FROM Quote
            WHERE Id = :quoteId
            LIMIT 1
        ];

        if (quotes.isEmpty()) {
            // Si no se encontró el quote, no marcamos pendiente
            return false;
        }

        String status = quotes[0].CPEstatusDeAprobacion__c;
        return status == 'En Proceso' || status == 'Pendiente';
    }

    // 🔹 2) Validar datos del Quote y devolver info para la tabla
    @AuraEnabled(cacheable=true)
    public static QuoteValidationResult validateQuoteData(Id quoteId) {
        if (quoteId == null) {
            return new QuoteValidationResult(false, 'No se recibió el Id del presupuesto.');
        }

        List<Quote> quotes = [
            SELECT Id,
                   Centro_de_Costo__c,
                   Centro_de_Costo__r.Name,
                   Centro_de_Costo__r.Aprobador__c,
                   BMW_CostoFijo__c,
                   GrandTotal,
                   CPEstatusDeAprobacion__c
            FROM Quote
            WHERE Id = :quoteId
            LIMIT 1
        ];

        if (quotes.isEmpty()) {
            return new QuoteValidationResult(false, 'No se encontró el presupuesto.');
        }

        Quote q = quotes[0];

        // Validación 1: Tiene centro de costos
        if (q.Centro_de_Costo__c == null) {
            return new QuoteValidationResult(false, 'El presupuesto no tiene un Centro de Costo asignado.');
        }

        // Validación 2: Costo fijo = TRUE
        if (q.BMW_CostoFijo__c == false) {
            return new QuoteValidationResult(false, 'El campo Costo Fijo debe estar marcado para enviar a aprobación.');
        }

        // Validación 3: No debe haber aprobación pendiente
        if (hasPendingApproval(quoteId)) {
            return new QuoteValidationResult(false, 'El presupuesto ya tiene una aprobación en proceso.');
        }

        // Si pasa todo, devolvemos info para la tabla
        QuoteValidationResult res = new QuoteValidationResult(true, 'OK');
        res.centroDeCostosName = q.Centro_de_Costo__r.Name;
        res.totalQuote = q.GrandTotal;
        res.estatusAprobacion = q.CPEstatusDeAprobacion__c;
        return res;
    }

    // 🔹 3) Enviar a aprobación
    @AuraEnabled
    public static void submitForApproval(Id quoteId, String comentarios) {
        if (quoteId == null) {
            throw new AuraHandledException('No se recibió el Id del presupuesto.');
        }

        List<Quote> quotes = [
            SELECT Id,
                   Centro_de_Costo__c,
                   Centro_de_Costo__r.Aprobador__c,
                   CPEstatusDeAprobacion__c,
                   CPComentariosDelAsesor__c,
                   CPAprobadorCentroDeCostos__c
            FROM Quote
            WHERE Id = :quoteId
            LIMIT 1
        ];

        if (quotes.isEmpty()) {
            throw new AuraHandledException('No se encontró el presupuesto.');
        }

        Quote q = quotes[0];

        // Actualizar campos del Quote
        q.CPComentariosDelAsesor__c = comentarios;
        q.CPAprobadorCentroDeCostos__c = q.Centro_de_Costo__r.Aprobador__c;
        q.CPEstatusDeAprobacion__c = 'En Proceso';
        q.Solicitante__c = UserInfo.getUserId();

        try {
            update q;
        } catch (Exception e) {
            // Mandamos el mensaje real al LWC
            throw new AuraHandledException('Error al actualizar el presupuesto: ' + e.getMessage());
        }
    }

}
