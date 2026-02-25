public class UpdateGlobalPicklistValue {

    // Method to update Global Picklist with new value
    public static void updateGlobalPicklistValue(String apiName, String newValue) {
        // Base URL for Tooling API using the Org Domain dynamically
        String baseUrl = 'callout:Tooling_API_Credential';
        
        // Construct the query string with API Name dynamically inserted
        String query = 'SELECT id, MasterLabel, Description, FullName, Metadata FROM GlobalValueSet WHERE DeveloperName = \'' + apiName + '\'';
        
        // URL encode the query string
        String encodedQuery = EncodingUtil.urlEncode(query, 'UTF-8');
        String queryURL = baseUrl + '/services/data/v47.0/tooling/query?q=' + encodedQuery;
        
        // Send GET request to retrieve the metadata of the Global Picklist
        String retrieveResponse = sendRequest(null, queryURL, 'GET');
        System.debug('Raw Retrieve Response: ' + retrieveResponse);
        
        // Parse the response
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(retrieveResponse);
        List<Object> records = (List<Object>) responseMap.get('records');
        
        if (!records.isEmpty()) {
            Map<String, Object> firstRecord = (Map<String, Object>) records[0];
            Map<String, Object> metadataMap = (Map<String, Object>) firstRecord.get('Metadata');
            
            // 1. Verificar si el valor ya existe
            List<Object> customValuesObj = (List<Object>) metadataMap.get('customValue');
            List<Map<String, Object>> customValues = new List<Map<String, Object>>();
            Boolean valueExists = false;
            
            for (Object obj : customValuesObj) {
                Map<String, Object> valueMap = (Map<String, Object>) obj;
                customValues.add(valueMap);
                
                // Comparar el valor nuevo con los existentes (case-sensitive)
                if (valueMap.get('valueName') == newValue) {
                    valueExists = true;
                    System.debug('El valor "' + newValue + '" ya existe en el Global Picklist. No se agregará.');
                    break;
                }
            }
            
            // 2. Si no existe, agregarlo
            if (!valueExists) {
                Map<String, Object> newPicklistValue = new Map<String, Object>{
                    'valueName' => newValue,
                    'label' => newValue,
                    'isActive' => true
                };
                customValues.add(newPicklistValue);
                
                // Actualizar metadata
                String updatedMetadata = '{"Metadata" : {"customValue" : ' + JSON.serialize(customValues) + ',"description" : null,"masterLabel" : "' + apiName + '","sorted" : false}}';
                
                // Enviar PATCH request
                String fullRetrieveURL = baseUrl + ((Map<String, Object>) firstRecord.get('attributes')).get('url');
                String updateResponse = sendRequest(updatedMetadata, fullRetrieveURL, 'PATCH');
                System.debug('Update Response: ' + updateResponse);
            }
        } else {
            System.debug('No Global Picklist found with the given API Name: ' + apiName);
        }
	}
    
    // Helper method to send HTTP requests (GET/POST/PATCH)
    private static String sendRequest(String fieldInfo, String metadataURL, String reqType) {
        HttpRequest req = new HttpRequest();
        system.debug( 'UserInfo.getSessionId()');
        system.debug( UserInfo.getSessionId());
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
        req.setHeader('Content-Type', 'application/json');
        
        // Set the request body for POST and PATCH requests
        if (fieldInfo != null) {
            req.setBody(fieldInfo);  
        }
        
        System.debug('JSON SENT');
        System.debug(req.getBody());
        
        // Set the method type (GET, POST, or PATCH)
        if (reqType == 'PATCH') {
            req.setMethod('POST');
            metadataURL += '?_HttpMethod=PATCH';
        } else {
            req.setMethod(reqType);
        }
        
        // Set the endpoint URL
        req.setEndpoint(metadataURL);
        
        // Send the request and return the response body
        Http httpReq = new Http();
        HttpResponse res = httpReq.send(req);
        system.debug('HEY');
        system.debug(res);
        return res.getBody();
    }
}