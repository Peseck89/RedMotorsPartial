public with sharing class EmpresaPricebookResolver {

    public static final String STATUS_EXITO = 'EXITO';
    public static final String STATUS_NO_CONFIGURADO = 'NO_CONFIGURADO';
    public static final String STATUS_SELECCION_REQUERIDA = 'SELECCION_REQUERIDA';
    public static final String STATUS_ERROR = 'ERROR';

    private static final Map<String, String> LEGACY_COMPANY_TO_ERP_CODE =
        new Map<String, String>{
            'BAVARIAN' => 'RMBAVARIAN',
            'OTOBAI' => 'RMOTOBAI'
        };

    public class PricebookResolutionRequest {
        @InvocableVariable(label='Id de Empresa (opcional; vacío = Empresa ausente, error controlado)')
        public Id empresaId;
        @InvocableVariable(label='Compañía legacy (fallback temporal; solo se usa cuando Id de Empresa está vacío)')
        public String legacyCompany;
        @InvocableVariable(label='CurrencyIsoCode (opcional)')
        public String currencyIsoCode;
        @InvocableVariable(label='Pricebook actual (opcional)')
        public Id currentPricebookId;
    }

    public class PricebookOption {
        @InvocableVariable
        public Id pricebookId;
        @InvocableVariable
        public String label;
        @InvocableVariable
        public String currencyIsoCode;

        public PricebookOption(Id pricebookId, String label, String currencyIsoCode) {
            this.pricebookId = pricebookId;
            this.label = label;
            this.currencyIsoCode = currencyIsoCode;
        }
    }

    public class PricebookResolutionResult {
        @InvocableVariable
        public String status;
        @InvocableVariable
        public Id empresaId;
        @InvocableVariable
        public Id pricebookId;
        @InvocableVariable
        public String mensaje;
        @InvocableVariable
        public List<PricebookOption> opciones;

        public PricebookResolutionResult() {
            this.opciones = new List<PricebookOption>();
        }

        public Boolean isExito() {
            return status == STATUS_EXITO;
        }
    }

    @InvocableMethod(
        label='RM Resolver Pricebook de Empresa'
        description='Resuelve el Pricebook activo de una Empresa por CurrencyIsoCode, bulk-safe. Nunca selecciona por nombre ni Id fijo.'
        category='Empresa'
    )
    public static List<PricebookResolutionResult> resolve(List<PricebookResolutionRequest> requests) {
        List<PricebookResolutionResult> results = new List<PricebookResolutionResult>();
        if (requests == null || requests.isEmpty()) {
            return results;
        }

        Set<Id> empresaIds = new Set<Id>();
        Set<String> legacyErpCodes = new Set<String>();
        for (PricebookResolutionRequest request : requests) {
            if (request != null && request.empresaId != null) {
                empresaIds.add(request.empresaId);
            } else if (request != null) {
                String legacyErpCode = getLegacyErpCode(request.legacyCompany);
                if (legacyErpCode != null) {
                    legacyErpCodes.add(legacyErpCode);
                }
            }
        }

        Map<Id, Empresa__c> empresasById = new Map<Id, Empresa__c>();
        Map<String, List<Empresa__c>> empresasByLegacyErpCode = new Map<String, List<Empresa__c>>();
        for (Empresa__c empresa : [
            SELECT Id, Activa__c, Codigo_ERP__c
            FROM Empresa__c
            WHERE Id IN :empresaIds OR Codigo_ERP__c IN :legacyErpCodes
        ]) {
            empresasById.put(empresa.Id, empresa);
            if (String.isNotBlank(empresa.Codigo_ERP__c)) {
                String normalizedErpCode = empresa.Codigo_ERP__c.trim().toUpperCase();
                if (!empresasByLegacyErpCode.containsKey(normalizedErpCode)) {
                    empresasByLegacyErpCode.put(normalizedErpCode, new List<Empresa__c>());
                }
                empresasByLegacyErpCode.get(normalizedErpCode).add(empresa);
            }
        }

        Set<Id> resolvedEmpresaIds = new Set<Id>(empresasById.keySet());
        Map<Id, List<Pricebook2>> pricebooksByEmpresa = getActivePricebooksByEmpresa(resolvedEmpresaIds);

        for (PricebookResolutionRequest request : requests) {
            results.add(resolveOne(request, empresasById, empresasByLegacyErpCode, pricebooksByEmpresa));
        }
        return results;
    }

    public static PricebookResolutionResult resolveForEmpresa(
        Id empresaId,
        String currencyIsoCode,
        Id currentPricebookId
    ) {
        PricebookResolutionRequest request = new PricebookResolutionRequest();
        request.empresaId = empresaId;
        request.currencyIsoCode = currencyIsoCode;
        request.currentPricebookId = currentPricebookId;

        return resolve(new List<PricebookResolutionRequest>{ request })[0];
    }

    public static PricebookResolutionResult resolveForSource(
        Id empresaId,
        String legacyCompany,
        String currencyIsoCode,
        Id currentPricebookId
    ) {
        PricebookResolutionRequest request = new PricebookResolutionRequest();
        request.empresaId = empresaId;
        request.legacyCompany = legacyCompany;
        request.currencyIsoCode = currencyIsoCode;
        request.currentPricebookId = currentPricebookId;

        return resolve(new List<PricebookResolutionRequest>{ request })[0];
    }

    public static Map<Id, List<Pricebook2>> getActivePricebooksByEmpresa(Set<Id> empresaIds) {
        Map<Id, List<Pricebook2>> result = new Map<Id, List<Pricebook2>>();
        if (empresaIds == null || empresaIds.isEmpty()) {
            return result;
        }

        for (Pricebook2 pb : [
            SELECT Id, Name, CurrencyIsoCode, Empresa__c
            FROM Pricebook2
            WHERE Empresa__c IN :empresaIds AND IsActive = true
        ]) {
            if (!result.containsKey(pb.Empresa__c)) {
                result.put(pb.Empresa__c, new List<Pricebook2>());
            }
            result.get(pb.Empresa__c).add(pb);
        }
        return result;
    }

    private static PricebookResolutionResult resolveOne(
        PricebookResolutionRequest request,
        Map<Id, Empresa__c> empresasById,
        Map<String, List<Empresa__c>> empresasByLegacyErpCode,
        Map<Id, List<Pricebook2>> pricebooksByEmpresa
    ) {
        PricebookResolutionResult result = new PricebookResolutionResult();

        if (request == null) {
            result.status = STATUS_ERROR;
            result.mensaje = 'Falta la Empresa para resolver el Pricebook.';
            return result;
        }

        Id effectiveEmpresaId = request.empresaId;
        if (effectiveEmpresaId == null) {
            if (String.isBlank(request.legacyCompany)) {
                result.status = STATUS_ERROR;
                result.mensaje = 'Falta la Empresa para resolver el Pricebook.';
                return result;
            }

            String legacyErpCode = getLegacyErpCode(request.legacyCompany);
            if (legacyErpCode == null) {
                result.status = STATUS_ERROR;
                result.mensaje = 'La compañía heredada no está configurada como fallback temporal.';
                return result;
            }

            List<Empresa__c> legacyMatches = empresasByLegacyErpCode.get(legacyErpCode);
            if (legacyMatches == null || legacyMatches.isEmpty()) {
                result.status = STATUS_NO_CONFIGURADO;
                result.mensaje = 'No existe una Empresa activa configurada para la compañía heredada.';
                return result;
            }
            if (legacyMatches.size() > 1) {
                result.status = STATUS_ERROR;
                result.mensaje = 'Existe más de una Empresa configurada para la compañía heredada.';
                return result;
            }
            effectiveEmpresaId = legacyMatches[0].Id;
        }

        Empresa__c empresa = empresasById.get(effectiveEmpresaId);
        if (empresa == null) {
            result.status = STATUS_ERROR;
            result.mensaje = 'La Empresa indicada no existe.';
            return result;
        }
        result.empresaId = effectiveEmpresaId;
        if (empresa.Activa__c != true) {
            result.status = STATUS_ERROR;
            result.mensaje = 'La Empresa indicada está inactiva.';
            return result;
        }

        List<Pricebook2> candidates = pricebooksByEmpresa.get(effectiveEmpresaId);
        if (candidates == null) {
            candidates = new List<Pricebook2>();
        }

        List<Pricebook2> filtered = new List<Pricebook2>();
        for (Pricebook2 pb : candidates) {
            if (String.isNotBlank(request.currencyIsoCode) && pb.CurrencyIsoCode != request.currencyIsoCode) {
                continue;
            }
            filtered.add(pb);
            result.opciones.add(new PricebookOption(pb.Id, pb.Name, pb.CurrencyIsoCode));
        }

        Boolean currentWasIncompatible = false;
        if (request.currentPricebookId != null) {
            for (Pricebook2 pb : filtered) {
                if (pb.Id == request.currentPricebookId) {
                    result.status = STATUS_EXITO;
                    result.pricebookId = pb.Id;
                    return result;
                }
            }
            currentWasIncompatible = true;
        }

        if (filtered.isEmpty()) {
            result.status = STATUS_NO_CONFIGURADO;
            result.mensaje = currentWasIncompatible
                ? 'El Pricebook actual no pertenece a esta Empresa o no cumple la moneda/estado requerido, y no hay otro Pricebook configurado.'
                : 'No hay Pricebooks activos configurados para esta Empresa.';
            return result;
        }

        if (filtered.size() == 1) {
            result.status = STATUS_EXITO;
            result.pricebookId = filtered[0].Id;
            if (currentWasIncompatible) {
                result.mensaje = 'El Pricebook actual no pertenece a esta Empresa; se seleccionó automáticamente la única opción válida.';
            }
            return result;
        }

        result.status = STATUS_SELECCION_REQUERIDA;
        result.mensaje = currentWasIncompatible
            ? 'El Pricebook actual no pertenece a esta Empresa; existen varias opciones válidas y se requiere selección manual.'
            : 'Existen varios Pricebooks válidos para esta Empresa; se requiere selección manual.';
        return result;
    }

    private static String getLegacyErpCode(String legacyCompany) {
        if (String.isBlank(legacyCompany)) {
            return null;
        }
        return LEGACY_COMPANY_TO_ERP_CODE.get(legacyCompany.trim().toUpperCase());
    }
}
