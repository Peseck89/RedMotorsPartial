public with sharing class OpportunityServiceInvoker {
    @InvocableMethod(label='Enviar Oportunidad a API Externa' description='Envía los datos de una oportunidad a un servicio externo')
    public static void sendOpportunity(List<Id> opportunityIds) {
        if (opportunityIds == null || opportunityIds.isEmpty()) {
            System.debug('No se recibieron IDs de Oportunidad');
            return;
        }
        String url = Label.URLSoftland;
        String clientId = Label.ClientIdSoftland;
        String clientSecret = Label.clientSecretSoftland;
        
       
        Opportunity opp = [
            SELECT Id, ConsecutivoOportunidad__c, AccountId, Account.IsPersonAccount,
                Pricebook2Id, Pricebook2.Name, Empresa_Operadora__c
                           FROM Opportunity WHERE Id = :opportunityIds[0] LIMIT 1];
        
        System.debug('ID Opp '+opp.Id);
        String pricebookname = resolveCompanyCode(opp);
        
        Account acc;

        String emailbuscado = '';
        if(opp.Account.IsPersonAccount){
            acc = [SELECT Id, Name, IsPersonAccount, FirstName, LastName, Phone, PersonEmail
                       FROM Account WHERE Id = :opp.AccountId LIMIT 1];
            emailbuscado = acc.PersonEmail;
        }else{
            acc = [SELECT Id, Name, IsPersonAccount, FirstName, LastName, Phone, CorreoElectronicoEmpresarial__c
                       FROM Account WHERE Id = :opp.AccountId LIMIT 1];
            emailbuscado = acc.CorreoElectronicoEmpresarial__c;
        }
        
        
        OpportunityLineItem oli = [SELECT Product2.VIN__c FROM OpportunityLineItem
                                   WHERE OpportunityId = :opp.Id LIMIT 1];
        
        //String bearerToken = 'PLACEHOLDER_FOR_BEARER_TOKEN'; // Obtener el token adecuadamente
        
        Map<String, Object> payload = new Map<String, Object>();
        payload.put('compania', pricebookname);
        payload.put('usuario', UserInfo.getUserEmail());
        payload.put('vin', oli != null ? oli.Product2.VIN__c : '');
        payload.put('oportunidad', opp.ConsecutivoOportunidad__c);
        payload.put('telefono', acc.Phone);
        payload.put('correo', emailbuscado);
        payload.put('primer_nombre', acc.IsPersonAccount ? acc.FirstName : acc.Name);
        payload.put('primer_apellido', acc.IsPersonAccount ? acc.LastName : '');
        payload.put('segundo_nombre','');
        payload.put('segundo_apellido','');
        payload.put('placa', opp.ConsecutivoOportunidad__c);
        payload.put('modelo', opp.ConsecutivoOportunidad__c);
        
        String requestBody = JSON.serialize(payload);
        
        String token = ExternalAuthService.authenticate();
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint('http://172.176.136.132:5080/ServiciosSoftlandProductivos/softlandAPI/payment/newVehiculeLink');
        //req.setEndpoint('http://172.176.136.132:5080/IntegrationServices/softlandAPI/payment/newVehiculeLink');
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer '+token);
        req.setHeader('Content-Type', 'application/json');
        req.setBody(requestBody);
        req.setTimeout(120000);
        
        HttpResponse res;
        try {
            res = new Http().send(req);
        } catch (Exception e) {
            System.debug('Error en el callout: ' + e.getMessage());
            return;
        }

        if (res.getStatusCode() == 200) {
            System.debug('Respuesta exitosa: ' + res.getBody());
            
            // Procesar la respuesta
            String responseBody = res.getBody();
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            Map<String, Object> operationResult = (Map<String, Object>) responseMap.get('operationResult');
            String description = (String) operationResult.get('description');
            String codigo = (String) operationResult.get('code');
            
            System.debug('Código de respuesta: ' + codigo + ' Descripción: ' + description);
        } else {
            System.debug('Error en la respuesta: ' + res.getBody());
        }
    }
    
    private static String resolveCompanyCode(Opportunity opp) {
        String companyCode;

        if (opp.Empresa_Operadora__c != null) {
            companyCode = EmpresaResolver.resolve(opp.Empresa_Operadora__c).codigo;
        } else if (opp.Pricebook2Id != null && opp.Pricebook2 != null) {
            companyCode = resolveLegacyCompanyFromPricebook(opp.Pricebook2.Name);
        } else {
            throw new AuraHandledException('No existe empresa configurada para enviar el enlace de pago.');
        }

        if (companyCode == 'RMBAVARIAN' || companyCode == 'RMOTOBAI') {
            return companyCode;
        }
        if (companyCode == 'RMPEKING') {
            throw new AuraHandledException('No existe configuración confirmada de enlace de pago Softland para RMPEKING.');
        }

        throw new AuraHandledException('Empresa no soportada para enviar el enlace de pago: ' + companyCode);
    }

    private static String resolveLegacyCompanyFromPricebook(String pricebookName) {
        if (String.isBlank(pricebookName)) {
            throw new AuraHandledException('No existe empresa configurada para enviar el enlace de pago.');
        }

        String normalizedName = pricebookName.trim().toUpperCase();
        if (normalizedName.contains('BAVARIAN') || normalizedName == 'RMBAVARIAN') {
            return 'RMBAVARIAN';
        }
        if (normalizedName.contains('OTOBAI') || normalizedName == 'RMOTOBAI') {
            return 'RMOTOBAI';
        }
        if (normalizedName.contains('PEKING') || normalizedName == 'RMPEKING') {
            return 'RMPEKING';
        }

        throw new AuraHandledException('Empresa no soportada para enviar el enlace de pago: ' + pricebookName);
    }

}
