public class PicklistJsonTransform {
    public static String transformJson(String objectName, String inputJson, String picklistField, String newValue, String recordTypeDescripton, String label, String recordTypeApiName) {
        // Parse the input JSON
        Map<String, Object> inputMap = (Map<String, Object>) JSON.deserializeUntyped(inputJson);
        
        // Extract the values array
        List<Object> values = (List<Object>) inputMap.get('values');
        
        // Prepare the list of picklist values
        List<Map<String, String>> picklistValues = new List<Map<String, String>>();
        for (Object valueObj : values) {
            Map<String, Object> valueMap = (Map<String, Object>) valueObj;
            String valueName = (String) valueMap.get('value');
            Map<String, String> valueNameMap = new Map<String, String>{
                'valueName' => valueName
            };
            picklistValues.add(valueNameMap);
        }
        
        // Add the new value at the end of the picklist values
        if (newValue != null) {
            picklistValues.add(new Map<String, String>{
                'valueName' => newValue
            });
        }
        
        // Sort the picklist values by valueName (excluding the new value)
        picklistValues.sort(new PicklistValueComparator());
        
        // Construct the final JSON structure
        Map<String, Object> metadataMap = new Map<String, Object>{};
        Map<String, Object> finalMap = new Map<String, Object>{};
        String leadProcess = 'Motos';
        if(recordTypeDescripton == 'BMW' || recordTypeDescripton == 'MINI'){
            leadProcess = 'Autos';
        }
       	if(objectName == 'Lead'){
            metadataMap = new Map<String, Object>{
            'active' => true,
            'businessProcess' => leadProcess,
            'compactLayoutAssignment' => null,
            'description' => recordTypeDescripton,
            'label' => label,
            'picklistValues' => new List<Map<String, Object>>{
                new Map<String, Object>{
                    'picklist' => picklistField,
                    'values' => picklistValues
                }
            },
            'urls' => null
        };
            finalMap = new Map<String, Object>{
            	'Metadata' => metadataMap,
            	'FullName' => 'Lead.' + recordTypeApiName
        	};
        }
        else{
            metadataMap = new Map<String, Object>{
            'active' => true,
            'businessProcess' => null,
            'compactLayoutAssignment' => null,
            'description' => recordTypeDescripton,
            'label' => label,
            'picklistValues' => new List<Map<String, Object>>{
                new Map<String, Object>{
                    'picklist' => picklistField,
                    'values' => picklistValues
                }
            },
            'urls' => null
        };
            finalMap = new Map<String, Object>{
                'Metadata' => metadataMap,
                'FullName' => 'Product2.' + recordTypeApiName
            };
        }
            
        // Serialize the final map to JSON
        return JSON.serializePretty(finalMap);
    }
    
    // Comparator to sort picklist values by valueName
    private class PicklistValueComparator implements System.Comparator<Map<String, String>> {
        public Integer compare(Map<String, String> a, Map<String, String> b) {
            return a.get('valueName').compareTo(b.get('valueName'));
        }
    }
}