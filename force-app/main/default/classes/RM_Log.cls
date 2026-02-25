/**
 * @description       : 
 * @author            : marcohernandezhp@gmail.com
 * @group             : 
 * @last modified on  : 05-12-2023
 * @last modified by  : marcohernandezhp@gmail.com
**/
public class RM_Log {
    public static Log__c write(String message,String url,Boolean insertDML) {
        Log__c log = new Log__c(
            errorMessage2__c = message,
            URL__c = url
        );
        if (insertDML) {
            insert log;            
        }
        return log;
    }  
    
    public static Log__c write(String caseId,String workStepId,String message,String url,Boolean insertDML) {
        Log__c log = new Log__c(
            Caso__c = caseId,
            WorkStep__c = workStepId,
            errorMessage2__c = message,
            URL__c = url
        );
        if (insertDML) {
            insert log;            
        }
        return log;
    }      
    
    public static void write(String url, String message) {
        Log__c log = new Log__c(
            URL__c = url ,  
            errorMessage2__c = message
        );
        insert log;
    }

    public static Log__c writeAnticipo(String anticipoId,String message,String url,String tipo,Boolean insertDML) {
        Log__c log = new Log__c(
            Anticipo__c = anticipoId,
            errorMessage2__c = message,
            URL__c = url,
            Tipo__c = tipo
        );

        if (insertDML) {
            insert log;            
        }
        return log;
    }      
    
}