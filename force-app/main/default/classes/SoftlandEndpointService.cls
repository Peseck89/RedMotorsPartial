public inherited sharing class SoftlandEndpointService {
    private static final String BASE_URL = 'http://172.176.136.132:5080';
    private static final String SANDBOX_SERVICE = 'IntegrationServices';
    private static final String PRODUCTION_SERVICE = 'ServiciosSoftlandProductivos';

    @TestVisible private static Boolean overrideIsSandbox;
    private static Boolean cachedIsSandbox;

    public static String authToken() {
        return buildEndpoint('oauth/token');
    }

    public static String existenciaArticuloReserva() {
        return buildEndpoint('softlandAPI/Catalogs/getExistenciaArticuloReserva');
    }

    public static String reservaApartadoArticulos() {
        return buildEndpoint('softlandAPI/reserve/request');
    }

    public static String existenciaArticuloOportunidad() {
        return buildEndpoint('softlandAPI/Catalogs/getExistenciaArticuloOportunidad');
    }

    public static String reservaApartadoQuote() {
        return buildEndpoint('softlandAPI/Opportunities/ReserveRequest');
    }

    public static String reservaVehiculoOportunidad() {
        return buildEndpoint('softlandAPI/Catalogs/addVehiculeOpportunity');
    }

    private static String buildEndpoint(String relativePath) {
        return BASE_URL + '/' + getServiceContext() + '/' + relativePath;
    }

    private static String getServiceContext() {
        return isSandbox() ? SANDBOX_SERVICE : PRODUCTION_SERVICE;
    }

    private static Boolean isSandbox() {
        if (overrideIsSandbox != null) {
            return overrideIsSandbox;
        }

        if (cachedIsSandbox == null) {
            try {
                cachedIsSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
            } catch (System.QueryException qe) {
                String domain = System.Url.getOrgDomainUrl().toExternalForm().toLowerCase();
                cachedIsSandbox = domain.contains('--') || domain.contains('.sandbox.');
            }
        }

        return cachedIsSandbox;
    }
}