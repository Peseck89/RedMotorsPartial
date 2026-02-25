public with sharing class PicklistValueCreator {

    public static Boolean addPicklistValue(String objectName, String fieldName, String newValue, String controllingFieldValue) {
        String fieldapi = fieldName + '__c';
        if(!test.isrunningtest() && fieldName != 'Modelo_De_Inter_s2' && fieldName != 'Modelo_De_Inter_s3' && fieldName != 'Modelo_De_Inter_s4'){
        	List<String> existingValues = getPicklistValues(objectName, fieldapi);
            if(existingValues.contains(newValue)) {
            	System.debug('El valor ' + newValue + ' ya existe en el picklist, no se agregará nuevamente');
                return true;
            }
        }
        String baseUrl = 'callout:Tooling_API_Credential';
        // Step 1: Query the CustomField Metadata
        System.debug('fieldName: ' + fieldName);
		System.debug('objectName: ' + objectName);
        String query = 'SELECT Id, Metadata FROM CustomField WHERE DeveloperName = \'' + fieldName + 
                       '\' AND TableEnumOrId = \'' + objectName + '\'';
        String endpoint = baseUrl + '/services/data/v63.0/tooling/query/?q=' + EncodingUtil.urlEncode(query, 'UTF-8');
        system.debug('endpoint');
        system.debug(endpoint);
        HttpRequest queryReq = new HttpRequest();
        queryReq.setEndpoint(endpoint);
        queryReq.setMethod('GET');
        queryReq.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        queryReq.setHeader('Content-Type', 'application/json');
        
        Http queryHttp = new Http();
        HttpResponse queryRes = queryHttp.send(queryReq);
        System.debug('Status code: ' + queryRes.getStatusCode());
		System.debug('Response body: ' + queryRes.getBody());
        if (queryRes.getStatusCode() == 200) {
            Map<String, Object> queryResult = (Map<String, Object>) JSON.deserializeUntyped(queryRes.getBody());
            List<Object> records = (List<Object>) queryResult.get('records');
            
            if (!records.isEmpty()) {
                Map<String, Object> fieldRecord = (Map<String, Object>) records[0];
                String fieldId = (String) fieldRecord.get('Id');
                Map<String, Object> metadata = (Map<String, Object>) fieldRecord.get('Metadata');
                
                // Ensure valueSet exists
                Map<String, Object> valueSet = (Map<String, Object>) metadata.get('valueSet');
                if (valueSet == null) {
                    System.debug('Value set is null for field: ' + fieldName);
                    return false;
                }
                
                // Get valueSettings and ensure it exists
                List<Object> valueSettings = (List<Object>) valueSet.get('valueSettings');
                if (valueSettings == null) {
                    valueSettings = new List<Object>();
                }
                
                // Add the new picklist value and controlling field value
                valueSettings.add(new Map<String, Object>{
                    'valueName' => newValue,
                    'controllingFieldValue' => new List<String>{controllingFieldValue}
                });
                
                // Update valueSet in metadata
                valueSet.put('valueSettings', valueSettings);
                metadata.put('valueSet', valueSet);
                
                // Prepare the PATCH request
                String updateEndpoint = baseUrl + '/services/data/v63.0/tooling/sobjects/CustomField/' + fieldId;
                
                HttpRequest updateReq = new HttpRequest();
                updateReq.setEndpoint(updateEndpoint);
                updateReq.setMethod('PATCH');
                updateReq.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
                updateReq.setHeader('Content-Type', 'application/json');
                updateReq.setBody(JSON.serialize(new Map<String, Object>{ 'Metadata' => metadata }));
                
                // Debug the URL and request body
                System.debug('PATCH Request URL: ' + updateEndpoint);
                System.debug('PATCH Request Body: ' + updateReq.getBody());
                
                // Send the PATCH request
                Http updateHttp = new Http();
                HttpResponse updateRes = updateHttp.send(updateReq);
                
                if (updateRes.getStatusCode() == 204) {
                    System.debug('Picklist value added successfully.');
                } else {
                    System.debug('Failed to add picklist value: ' + updateRes.getBody());
                }
            } else {
                System.debug('No matching field found.');
            }
        } else {
            System.debug('Failed to query CustomField metadata: ' + queryRes.getBody());
        }
        return false;
    }
    
    public static List<String> getPicklistValuesForRecordType(String recordTypeId, String picklistFieldName) {
        List<String> picklistValues = new List<String>();
        String baseUrl = 'callout:Tooling_API_Credential';
        
        try {
            // Step 1: Perform a GET request to fetch RecordType metadata
            String endpoint = baseUrl + '/services/data/v63.0/tooling/sobjects/RecordType/' + recordTypeId;
            system.debug('getPicklistValuesForRecordType endpoint');
            system.debug(endpoint);
            HttpRequest getRequest = new HttpRequest();
            getRequest.setEndpoint(endpoint);
            getRequest.setMethod('GET');
            getRequest.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
            getRequest.setHeader('Content-Type', 'application/json');
            
            Http getHttp = new Http();
            HttpResponse getResponse = getHttp.send(getRequest);
            system.debug('Respuesta TOOLING API para: CAMPO '+ picklistFieldName);
            //system.debug(getResponse.getBody());
            
            if (getResponse.getStatusCode() == 200) {
                // Parse the response
                Map<String, Object> recordTypeData = (Map<String, Object>) JSON.deserializeUntyped(getResponse.getBody());
                Map<String, Object> metadata = (Map<String, Object>) recordTypeData.get('Metadata');
                
                // Step 2: Extract the picklist values for the specific field
                List<Object> picklistValuesList = (List<Object>) metadata.get('picklistValues');
                if (picklistValuesList != null) {
                    for (Object picklistObj : picklistValuesList) {
                        Map<String, Object> picklistMap = (Map<String, Object>) picklistObj;
                        if (picklistMap.get('picklist') == picklistFieldName) {
                            List<Object> values = (List<Object>) picklistMap.get('values');
                            system.debug('VALORES');
                            system.debug(values);
                            for (Object valueObj : values) {
                                Map<String, Object> valueMap = (Map<String, Object>) valueObj;
                                //if (valueMap.get('active') == true) { // Only add active values
                                    picklistValues.add((String) valueMap.get('valueName'));
                                    //System.debug(valueMap.get('valueName'));
                               //}
                            }
                            break;
                        }
                    }
                }
            } else {
                System.debug('Failed to retrieve record type metadata: ' + getResponse.getBody());
            }
        } catch (Exception ex) {
            System.debug('Error fetching picklist values: ' + ex.getMessage());
            throw new AuraHandledException('Error fetching picklist values: ' + ex.getMessage());
        }
        
        return picklistValues;
    }

    public static List<String> getPicklistValues(String objectName, String fieldName) {
        List<String> picklistValues = new List<String>();

        try {
            // Get the describe information for the object
            Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
            if (objectType == null) {
                throw new IllegalArgumentException('Invalid object name: ' + objectName);
            }

            // Get the describe information for the field
            Schema.DescribeSObjectResult describeObjectResult = objectType.getDescribe();
            Map<String, Schema.SObjectField> fieldsMap = describeObjectResult.fields.getMap();
            if (!fieldsMap.containsKey(fieldName)) {
                throw new IllegalArgumentException('Invalid field name: ' + fieldName + ' for object: ' + objectName);
            }

            // Get the picklist values for the field
            Schema.DescribeFieldResult fieldDescribe = fieldsMap.get(fieldName).getDescribe();
            if (fieldDescribe.getType() != Schema.DisplayType.Picklist) {
                throw new IllegalArgumentException('Field ' + fieldName + ' is not a picklist field.');
            }

            // Collect the picklist values
            for (Schema.PicklistEntry picklistEntry : fieldDescribe.getPicklistValues()) {
                picklistValues.add(picklistEntry.getLabel());
            }
        } catch (Exception ex) {
            System.debug('Error fetching picklist values: ' + ex.getMessage());
            throw new AuraHandledException('Error fetching picklist values: ' + ex.getMessage());
        }

        return picklistValues;
    }
    
    public static void addPicklistValueWithoutControllingField(String objectName, String fieldName, String newValue) {
        
        String baseUrl = 'callout:Tooling_API_Credential';
    
        // Step 1: Query the CustomField Metadata
        String query = 'SELECT Id, Metadata FROM CustomField WHERE DeveloperName = \'' + fieldName + 
                       '\' AND TableEnumOrId = \'' + objectName + '\'';
        String endpoint = baseUrl + '/services/data/v63.0/tooling/query/?q=' + EncodingUtil.urlEncode(query, 'UTF-8');
        System.debug('endpoint');
        System.debug(endpoint);
        
        HttpRequest queryReq = new HttpRequest();
        queryReq.setEndpoint(endpoint);
        queryReq.setMethod('GET');
        queryReq.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        queryReq.setHeader('Content-Type', 'application/json');
        
        Http queryHttp = new Http();
        HttpResponse queryRes = queryHttp.send(queryReq);
        
        if (queryRes.getStatusCode() == 200) {
            Map<String, Object> queryResult = (Map<String, Object>) JSON.deserializeUntyped(queryRes.getBody());
            List<Object> records = (List<Object>) queryResult.get('records');
            
            if (!records.isEmpty()) {
                Map<String, Object> fieldRecord = (Map<String, Object>) records[0];
                String fieldId = (String) fieldRecord.get('Id');
                Map<String, Object> metadata = (Map<String, Object>) fieldRecord.get('Metadata');
                
                // Ensure valueSet exists
                Map<String, Object> valueSet = (Map<String, Object>) metadata.get('valueSet');
                if (valueSet == null) {
                    System.debug('Value set is null for field: ' + fieldName);
                    return;
                }
                
                // Get valueSetDefinition and ensure it exists
                Map<String, Object> valueSetDefinition = (Map<String, Object>) valueSet.get('valueSetDefinition');
                List<Object> valueList = (List<Object>) valueSetDefinition.get('value');
                if (valueList == null) {
                    valueList = new List<Object>();
                }
                
                // Add the new picklist value to the value list
                valueList.add(new Map<String, Object>{
                    'valueName' => newValue
                });
                
                // Update valueSetDefinition
                valueSetDefinition.put('value', valueList);
                valueSet.put('valueSetDefinition', valueSetDefinition);
                valueSet.put('valueSettings', new List<Object>());  // Set valueSettings as an empty list
                
                metadata.put('valueSet', valueSet);
                
                // Prepare the PATCH request
                String updateEndpoint = baseUrl + '/services/data/v63.0/tooling/sobjects/CustomField/' + fieldId;
                
                HttpRequest updateReq = new HttpRequest();
                updateReq.setEndpoint(updateEndpoint);
                updateReq.setMethod('PATCH');
                updateReq.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
                updateReq.setHeader('Content-Type', 'application/json');
                updateReq.setBody(JSON.serialize(new Map<String, Object>{ 'Metadata' => metadata }));
                
                // Debug the URL and request body
                System.debug('PATCH Request URL: ' + updateEndpoint);
                System.debug('PATCH Request Body: ' + updateReq.getBody());
                
                // Send the PATCH request
                Http updateHttp = new Http();
                HttpResponse updateRes = updateHttp.send(updateReq);
                
                if (updateRes.getStatusCode() == 204) {
                    System.debug('Picklist value added successfully.');
                } else {
                    System.debug('Failed to add picklist value: ' + updateRes.getBody());
                }
            } else {
                System.debug('No matching field found.');
            }
        } else {
            System.debug('Failed to query CustomField metadata: ' + queryRes.getBody());
        }
    }
    
    public static Map<String, List<String>> getControllingAndDependentValues(String objectName, String recordTypeId, String picklistName) {
        // Step 1: Make the callout
        String responseBody = makeUIPicklistCallout(objectName, recordTypeId, picklistName);
    
        // Step 2: Process the response and return the result
        return getControllingAndDependentValues(responseBody);
    }
    
    public static String makeUIPicklistCallout(String objectName, String recordTypeId, String picklistName) {
        String responseBody = '';
        try {
            // Base Tooling API endpoint
            String baseUrl = 'callout:Tooling_API_Credential';
            String endpoint = baseUrl + '/services/data/v63.0/ui-api/object-info/' + objectName + '/picklist-values/' + recordTypeId + '/' + picklistName;
            System.debug('Endpoint: ' + endpoint);
    
            // Prepare HTTP request
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod('GET');
            req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
            req.setHeader('Content-Type', 'application/json');
    
            // Send HTTP request
            Http http = new Http();
            HttpResponse res = http.send(req);
    
            // Check the response status
            if (res.getStatusCode() == 200) {
                responseBody = res.getBody();
            } else {
                System.debug('Error: HTTP request failed with status ' + res.getStatusCode());
                System.debug('Response: ' + res.getBody());
            }
        } catch (Exception ex) {
            System.debug('Exception: ' + ex.getMessage());
        }
        System.debug('Response: ' + responseBody);
        return responseBody;
    }

    public static Map<String, List<String>> getControllingAndDependentValues(String responseBody) {
        Map<String, List<String>> controllingToDependentMap = new Map<String, List<String>>();
    
        if (String.isBlank(responseBody)) {
            return controllingToDependentMap;
        }
    
        try {
            // Parse the response body
            Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
    
            // Extract controllerValues and picklist values
            Map<String, Object> controllerValues = (Map<String, Object>) response.get('controllerValues');
            List<Object> valuesRaw = (List<Object>) response.get('values');
    
            // Initialize map with all controller values with empty lists
            for (String controllerKey : controllerValues.keySet()) {
                if (!controllingToDependentMap.containsKey(controllerKey)) {
                    controllingToDependentMap.put(controllerKey, new List<String>());
                }
            }
    
            // Process picklist values and their validFor indices
            for (Object valueRaw : valuesRaw) {
                Map<String, Object> value = (Map<String, Object>) valueRaw;
                String dependentValue = (String) value.get('value');
                List<Object> validFor = (List<Object>) value.get('validFor');
    
                if (validFor != null && !validFor.isEmpty()) {
                    for (Object indexObj : validFor) {
                        Integer index = ((Double) indexObj).intValue();
                        String controllingValue = null;
    
                        // Find the controlling value that corresponds to the index
                        for (String key : controllerValues.keySet()) {
                            if (((Double) controllerValues.get(key)).intValue() == index) {
                                controllingValue = key;
                                break;
                            }
                        }
    
                        // Map controlling value to dependent value
                        if (controllingValue != null) {
                            if (!controllingToDependentMap.containsKey(controllingValue)) {
                                controllingToDependentMap.put(controllingValue, new List<String>());
                            }
                            controllingToDependentMap.get(controllingValue).add(dependentValue);
                        }
                    }
                } else {
                    // Add values without dependencies to the map with an empty list
                    controllingToDependentMap.put(dependentValue, new List<String>());
                }
            }
        } catch (Exception ex) {
            System.debug('Exception: ' + ex.getMessage());
        }
    
        return controllingToDependentMap;
    }

    public static Integer makePatchRecordtypeCallout(String recordTypeId, String picklistFieldName, String patchData) {
        String baseUrl = 'callout:Tooling_API_Credential';
        Integer response = 0;
        String endpoint = baseUrl + '/services/data/v63.0/tooling/sobjects/RecordType/' + recordTypeId;
            HttpRequest patchRequest = new HttpRequest();
            patchRequest.setEndpoint(endpoint);
            patchRequest.setMethod('PATCH');
            patchRequest.setTimeout(120000);
            //ßpatchRequest.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
            patchRequest.setHeader('Content-Type', 'application/json');
            patchRequest.setBody((patchData));
    
            // Debug the URL and request body for PATCH
            System.debug('PATCH Request URL endpoint: ' + endpoint);
            System.debug('patchData: ' + patchData);

           // System.debug('PATCH Request Body: ' + patchRequest.getBody());
            
            Http patchHttp = new Http();
            HttpResponse patchResponse = patchHttp.send(patchRequest);
            System.debug('RESPONSE : ' + patchResponse);
            Boolean isDuplicate = patchResponse.getBody().contains('Duplicate') || patchResponse.getBody().contains('duplicate');
            if (patchResponse.getStatusCode() == 204 || isDuplicate) {
                System.debug('Record Type updated successfully.'); return 204;
                 
            } else {
                System.debug('Failed to update record type: ' + patchResponse.getBody());
            }
            response = patchResponse.getStatusCode();
        return response;
    }

    public Static Integer addPicklistValueToRecordType(String objectName, String recordTypeId, String picklistName, String newField, String recordTypeDescripton, String label, String recordTypeApiName){
        // Step 1: Make the callout
        if(picklistName != 'Modelo_De_Inter_s2__c' && picklistName != 'Modelo_De_Inter_s3__c' && picklistName != 'Modelo_De_Inter_s4__c'){
            List<String> existingRecordTypeValues = getPicklistValuesForRecordType(recordTypeId, picklistName);
            if(existingRecordTypeValues.contains(newField)) {
                System.debug('El valor ' + newField + ' ya existe en el record type, no se agregará nuevamente');
                return 999;
            }
        }
        String responsePickListValues = makeUIPicklistCallout(objectName, recordTypeId, picklistName);
        System.debug('UI Request');
        system.debug(responsePickListValues);
        String patchData = PicklistJsonTransform.transformJson(objectName, responsePickListValues, picklistName, newField, recordTypeDescripton, label, recordTypeApiName);
        // Step 2: Process the response and return the result
        return makePatchRecordtypeCallout(recordTypeId, picklistName, patchData);
    }
    
    
}