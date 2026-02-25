public class CreateProductAfterWizardController {
    @AuraEnabled(cacheable=false)
    public static void addPicklistToRecordType(String recordTypeId, String RecordTypeName, String newValue, String RecordTypeDescription){
    	/*RecordType rt = [
            SELECT Id 
            FROM RecordType 
            WHERE SObjectType = 'Lead' 
            AND Name =: RecordTypeName 
            LIMIT 1
		];
		Id recordTypeId = rt.Id;*/
        List<String> fields = new List<String>{
            'Modelo_De_Inter_s1__c',
            'Modelo_De_Inter_s2__c', 
            'Modelo_De_Inter_s3__c',
            'Modelo_De_Inter_s4__c'
        };
        Integer respuestaRT = 204;
        for(String field : fields) {
            if(respuestaRT != 999){
                respuestaRT = PicklistValueCreator.addPicklistValueToRecordType(
                    'Lead', recordTypeId, field, newValue, 
                    RecordTypeDescription, RecordTypeName, RecordTypeName
                );
            }
        }
        /*PicklistValueCreator.addPicklistValueToRecordType('Lead', recordTypeId, 'Modelo_De_Inter_s1__c', newValue, RecordTypeDescription, RecordTypeName, RecordTypeName);
        PicklistValueCreator.addPicklistValueToRecordType('Lead', recordTypeId, 'Modelo_De_Inter_s2__c', newValue, RecordTypeDescription, RecordTypeName, RecordTypeName);
        PicklistValueCreator.addPicklistValueToRecordType('Lead', recordTypeId, 'Modelo_De_Inter_s3__c', newValue, RecordTypeDescription, RecordTypeName, RecordTypeName);
        PicklistValueCreator.addPicklistValueToRecordType('Lead', recordTypeId, 'Modelo_De_Inter_s4__c', newValue, RecordTypeDescription, RecordTypeName, RecordTypeName);*/

    }
    
    @AuraEnabled(cacheable=false)
    public static Integer createNewModeloByFamilia (String brand, String globalPicklist, String newValue, String controllingFieldValue, String recordTypeId, String recordTypeDescripton, String label, String recordTypeApiName) { 
        Map<String,Id> mapRecordTypeNameId = new Map<String,Id>();
        List<RecordType> RecordTypeList = [
            SELECT Id,Name
            FROM RecordType 
            WHERE SObjectType = 'Lead'       
		];
        for(RecordType rt : RecordTypeList){
            mapRecordTypeNameId.put(rt.Name,rt.Id);
        }
        if(!Test.isRunningTest()){
        	UpdateGlobalPicklistValue.updateGlobalPicklistValue(globalPicklist, newValue);
    	}
        PicklistValueCreator.addPicklistValue('Product2', 'Modelo_De_Inter_s', newValue, controllingFieldValue);
        Boolean yaExiste = false;
        yaExiste = PicklistValueCreator.addPicklistValue('Lead', 'Modelo_De_Inter_s1', newValue, controllingFieldValue);
        if(yaExiste == false){
            PicklistValueCreator.addPicklistValue('Lead', 'Modelo_De_Inter_s2', newValue, controllingFieldValue);
            PicklistValueCreator.addPicklistValue('Lead', 'Modelo_De_Inter_s3', newValue, controllingFieldValue);
            PicklistValueCreator.addPicklistValue('Lead', 'Modelo_De_Inter_s4', newValue, controllingFieldValue);
        }
        System.debug('label: '+label);
        System.debug('brand: '+brand);
        System.debug('newValue: '+newValue);
        System.debug('controllingFieldValue: '+controllingFieldValue);
        System.debug('recordTypeId: '+recordTypeId);
        System.debug('recordTypeDescripton: '+recordTypeDescripton);
        System.debug('recordTypeApiName: '+recordTypeApiName);
        
        
        if(brand == 'BMW' || brand == 'MINI' || brand == 'Motorrad' || brand == 'Polaris' || brand == 'Harley-Davidson' || brand == 'Indian'){
            addPicklistToRecordType(mapRecordTypeNameId.get(brand), brand, newValue, brand);
        }else if(brand == 'Kawasaki' || brand == 'KAWA'){
            addPicklistToRecordType(mapRecordTypeNameId.get('Kawasaki'),'Kawasaki', newValue, 'Kawasaki');
        }else if(brand == 'Todas'){
            addPicklistToRecordType(mapRecordTypeNameId.get('BMW'),'BMW', newValue, 'BMW');
            addPicklistToRecordType(mapRecordTypeNameId.get('MINI'),'MINI', newValue, 'MINI');
            addPicklistToRecordType(mapRecordTypeNameId.get('Kawasaki'),'Kawasaki', newValue, 'Kawasaki');
            addPicklistToRecordType(mapRecordTypeNameId.get('Motorrad'),'Motorrad', newValue, 'Motorrad');
            addPicklistToRecordType(mapRecordTypeNameId.get('Polaris'),'Polaris', newValue, 'Polaris');
            addPicklistToRecordType(mapRecordTypeNameId.get('Harley-Davidson'),'Harley-Davidson', newValue, 'Harley-Davidson');
            addPicklistToRecordType(mapRecordTypeNameId.get('Indian'),'Indian', newValue, 'Indian');            
        }else if(brand == 'Macas 2 Ruedas' || brand == 'Dos Ruedas'){
            addPicklistToRecordType(mapRecordTypeNameId.get('Kawasaki'),'Kawasaki', newValue, 'Kawasaki');
            addPicklistToRecordType(mapRecordTypeNameId.get('Motorrad'),'Motorrad', newValue, 'Motorrad');
            addPicklistToRecordType(mapRecordTypeNameId.get('Polaris'),'Polaris', newValue, 'Polaris');
            addPicklistToRecordType(mapRecordTypeNameId.get('Harley-Davidson'),'Harley-Davidson', newValue, 'Harley-Davidson');
            addPicklistToRecordType(mapRecordTypeNameId.get('Indian'),'Indian', newValue, 'Indian');        
        }else if(brand == 'Marcas Vehículos' || brand == 'Cuatro Ruedas'){
            addPicklistToRecordType(mapRecordTypeNameId.get('BMW'),'BMW', newValue, 'BMW');
            addPicklistToRecordType(mapRecordTypeNameId.get('MINI'),'MINI', newValue, 'MINI');
        }
        Integer retorno = PicklistValueCreator.addPicklistValueToRecordType('Product2', recordTypeId, 'Modelo_De_Inter_s__c', newValue, recordTypeDescripton, label, recordTypeApiName);
        if(retorno == 999){
            retorno = 204;
        }
        return retorno;
    }

    @AuraEnabled(cacheable=false)
    public static Map<String, Object> createProduct(String productJson) {
        try {
            Product2 newProduct = (Product2) JSON.deserialize(productJson, Product2.class);
            insert newProduct;
            
            return new Map<String, Object>{
                'success' => true,
                'recordId' => newProduct.Id
            };
        } catch (Exception e) {
            return new Map<String, Object>{
                'success' => false,
                'errorMessage' => e.getMessage() // Captura el mensaje del flujo ("Ya existe un producto...")
            };
        }
    }

   @AuraEnabled(cacheable=false)
   public static Id createPBEntry (String pricebookJson, String pentryJson, Boolean createPricebook) {
    system.debug('PricebookENtryJSON');
    system.debug(pentryJson);
    system.debug('createPricebook');
    system.debug(createPricebook);
    PricebookEntry newPEntry = (PricebookEntry)JSON.deserialize(pentryJson, PricebookEntry.class);
    if(createPricebook){
        system.debug('PricebookJSON');
        system.debug(pricebookJson);
        Pricebook2 pb = (Pricebook2)JSON.deserialize(pricebookJson, Pricebook2.class);
        insert pb;
        system.debug(pb);
        newPEntry.Pricebook2Id = pb.id;
    }   
    system.debug(newPEntry);
    insert newPEntry;
    system.debug(newPEntry.id);
    return newPEntry.id;
  }

   @AuraEnabled(cacheable=false)
    public static String getPricebook (String brand) { 
        Integer currentYear = Date.today().year();
        String queryKey = brand + ' - ' + currentYear;
        List<Pricebook2> pricebookList = [SELECT Id FROM Pricebook2 WHERE Name =: queryKey LIMIT 1];
        String pbookId = (pricebookList.isEmpty()) ? 'null' : pricebookList[0].Id;
        return pbookId;
   }
}