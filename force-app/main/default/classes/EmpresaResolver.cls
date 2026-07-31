public with sharing class EmpresaResolver {
    private static final String NULL_ID_MESSAGE = 'El Id de Empresa es requerido.';
    private static final String NULL_CODE_MESSAGE = 'El código de Empresa es requerido.';

    private static Map<Id, EmpresaContext> contextsById = new Map<Id, EmpresaContext>();
    private static Map<String, EmpresaContext> contextsByCode = new Map<String, EmpresaContext>();

    public static EmpresaContext resolve(Id empresaId) {
        if (empresaId == null) {
            throw new EmpresaConfigurationException(NULL_ID_MESSAGE);
        }

        if (!contextsById.containsKey(empresaId)) {
            Map<Id, EmpresaContext> resolved = resolveAll(new Set<Id>{ empresaId });
            if (!resolved.containsKey(empresaId)) {
                throw new EmpresaConfigurationException(
                    'No existe una Empresa configurada para el Id ' + empresaId + '.'
                );
            }
        }
        return contextsById.get(empresaId);
    }

    public static EmpresaContext resolveByCodigo(String codigo) {
        String normalizedCode = normalizeCode(codigo);
        if (!contextsByCode.containsKey(normalizedCode)) {
            Map<String, EmpresaContext> resolved = resolveAllByCodigo(
                new Set<String>{ normalizedCode }
            );
            if (!resolved.containsKey(normalizedCode)) {
                throw new EmpresaConfigurationException(
                    'No existe una Empresa configurada para el código ' + normalizedCode + '.'
                );
            }
        }
        return contextsByCode.get(normalizedCode);
    }

    public static Map<Id, EmpresaContext> resolveAll(Set<Id> empresaIds) {
        if (empresaIds == null || empresaIds.contains(null)) {
            throw new EmpresaConfigurationException(NULL_ID_MESSAGE);
        }

        Map<Id, EmpresaContext> result = new Map<Id, EmpresaContext>();
        if (empresaIds.isEmpty()) {
            return result;
        }

        Set<Id> idsToQuery = new Set<Id>();
        for (Id empresaId : empresaIds) {
            if (contextsById.containsKey(empresaId)) {
                result.put(empresaId, contextsById.get(empresaId));
            } else {
                idsToQuery.add(empresaId);
            }
        }

        if (!idsToQuery.isEmpty()) {
            for (Empresa__c empresa : [
                SELECT Id, Codigo__c, Codigo_ERP__c, Nombre_Legal__c, Activa__c
                FROM Empresa__c
                WHERE Id IN :idsToQuery
            ]) {
                EmpresaContext context = toValidatedContext(empresa);
                cache(context);
                result.put(empresa.Id, context);
            }
        }

        Set<Id> missingIds = new Set<Id>(empresaIds);
        missingIds.removeAll(result.keySet());
        if (!missingIds.isEmpty()) {
            throw new EmpresaConfigurationException(
                'No existe configuración de Empresa para uno o más Ids solicitados.'
            );
        }
        return result;
    }

    public static Map<String, EmpresaContext> resolveAllByCodigo(Set<String> codigos) {
        if (codigos == null || codigos.contains(null)) {
            throw new EmpresaConfigurationException(NULL_CODE_MESSAGE);
        }

        Set<String> normalizedCodes = new Set<String>();
        for (String codigo : codigos) {
            normalizedCodes.add(normalizeCode(codigo));
        }

        Map<String, EmpresaContext> result = new Map<String, EmpresaContext>();
        if (normalizedCodes.isEmpty()) {
            return result;
        }

        Set<String> codesToQuery = new Set<String>();
        for (String codigo : normalizedCodes) {
            if (contextsByCode.containsKey(codigo)) {
                result.put(codigo, contextsByCode.get(codigo));
            } else {
                codesToQuery.add(codigo);
            }
        }

        if (!codesToQuery.isEmpty()) {
            for (Empresa__c empresa : [
                SELECT Id, Codigo__c, Codigo_ERP__c, Nombre_Legal__c, Activa__c
                FROM Empresa__c
                WHERE Codigo__c IN :codesToQuery
            ]) {
                EmpresaContext context = toValidatedContext(empresa);
                String normalizedCode = normalizeCode(context.codigo);
                if (result.containsKey(normalizedCode) || contextsByCode.containsKey(normalizedCode)) {
                    throw new EmpresaConfigurationException(
                        'Se encontró más de una Empresa para el código ' + normalizedCode + '.'
                    );
                }
                cache(context);
                result.put(normalizedCode, context);
            }
        }

        Set<String> missingCodes = new Set<String>(normalizedCodes);
        missingCodes.removeAll(result.keySet());
        if (!missingCodes.isEmpty()) {
            throw new EmpresaConfigurationException(
                'No existe configuración de Empresa para uno o más códigos solicitados.'
            );
        }
        return result;
    }

    private static EmpresaContext toValidatedContext(Empresa__c empresa) {
        if (empresa == null || empresa.Id == null) {
            throw new EmpresaConfigurationException(NULL_ID_MESSAGE);
        }
        if (String.isBlank(empresa.Codigo__c)) {
            throw new EmpresaConfigurationException(
                'La Empresa ' + empresa.Id + ' no tiene código configurado.'
            );
        }
        if (empresa.Activa__c != true) {
            throw new EmpresaConfigurationException(
                'La Empresa ' + empresa.Codigo__c + ' está inactiva.'
            );
        }
        // Codigo_ERP__c/Nombre_Legal__c ya no se validan aquí como "configuración incompleta"
        // genérica: EmpresaContext los deja opcionales en el constructor y los exige solo cuando
        // un consumidor real llama requireCodigoErp()/requireNombreLegal(). Ver EmpresaContext.cls.

        return new EmpresaContext(
            empresa.Id,
            empresa.Codigo__c,
            empresa.Codigo_ERP__c,
            empresa.Nombre_Legal__c,
            empresa.Activa__c
        );
    }

    private static String normalizeCode(String codigo) {
        if (String.isBlank(codigo)) {
            throw new EmpresaConfigurationException(NULL_CODE_MESSAGE);
        }
        return codigo.trim().toUpperCase();
    }

    private static void cache(EmpresaContext context) {
        String normalizedCode = normalizeCode(context.codigo);
        if (
            contextsByCode.containsKey(normalizedCode) &&
            contextsByCode.get(normalizedCode).empresaId != context.empresaId
        ) {
            throw new EmpresaConfigurationException(
                'Se encontró más de una Empresa para el código ' + normalizedCode + '.'
            );
        }
        contextsById.put(context.empresaId, context);
        contextsByCode.put(normalizedCode, context);
    }
}
