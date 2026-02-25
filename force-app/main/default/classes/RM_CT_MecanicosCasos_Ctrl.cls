public with sharing class RM_CT_MecanicosCasos_Ctrl {

    @AuraEnabled(cacheable=true)
    public static Map<String,Object> getData(String mecanicoId){
        Map<String,Object> response = new Map<String,Object>();
        try {   

            String query = 'SELECT Caso__c,Caso__r.CaseNumber,RM_Mecanico__r.Name FROM WorkStep';
            
            query += ' WHERE Caso__c != NULL AND RM_Mecanico__c != NULL AND Status = \'Completada\'';
            if (String.isNotBlank(mecanicoId)) {
                query += ' AND RM_Mecanico__c = :mecanicoId ';
            }
            query += ' ORDER BY RM_Mecanico__r.Name ';
            List<WorkStep> workSteps = (List<WorkStep>) Database.query(query);
            Map<String,WorkStep> workStepsMap = new Map<String,WorkStep>();
            for (WorkStep ws : workSteps) {
                String llave = ws.Caso__c+'_'+ws.RM_Mecanico__c;
                workStepsMap.put(llave,ws);
            }
            response.put('records',workStepsMap.values());
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return response;
    }
}