public with sharing class RM_VN_GetOppRecordTypes_Ctrl {

    @AuraEnabled(cacheable=true)
    public static List<RecordType> getRecordTypes() {
        Map<String, Schema.RecordTypeInfo> recordTypeInfos = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByDeveloperName();
        List<RecordType> recordTypes = new List<RecordType>();
        Set<String> excludedRecordTypes = new Set<String>{'Autos_Usados', 'Cartera_Madura', 'Motos_Usados', 'BMW_Taller', 'Harley_Davidson','Principal','Master','Mostrador'};

        for (String rtDevName : recordTypeInfos.keySet()) {
            //also exclude the main record type for the object
            if (!excludedRecordTypes.contains(rtDevName)) {
                Schema.RecordTypeInfo rtInfo = recordTypeInfos.get(rtDevName);
                if (rtInfo.isAvailable() && rtInfo.isActive()) {
                    RecordType rt = new RecordType();
                    rt.DeveloperName = rtDevName;
                    rt.Name = rtInfo.getName();
                    if (rtDevName == 'Kawasaki') {
                        rt.Name = 'Kawa';
                        rt.DeveloperName = 'Kawa';
                    }
                    recordTypes.add(rt);
                }
            }
        }
    
        return recordTypes;
    }

}