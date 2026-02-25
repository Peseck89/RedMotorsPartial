public class BMW_presupuestoVencido {
     @AuraEnabled
    public static String quoteVencido(String quoteId) {
       quote presupuesto = [Select Id, BMW_FechaVigente__c From quote where id =: quoteId];
        return presupuesto.BMW_FechaVigente__c;
    }

}