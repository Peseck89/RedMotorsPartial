public with sharing class TrabajoWrappers {
    public class TrabajoWrapper {
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String workOrderId { get; set; }
        @AuraEnabled public String aseguradora { get; set; }
        @AuraEnabled public String aseguradoraNombre { get; set; }
        @AuraEnabled public String centroDeCostos { get; set; }
        @AuraEnabled public String centroDeCostosNombre { get; set; }
        @AuraEnabled public String nombreTrabajo { get; set; }
        @AuraEnabled public String alias { get; set; }
        @AuraEnabled public Boolean changeAlias { get; set; }
        @AuraEnabled public String prioridad { get; set; }
        @AuraEnabled public String tipoTrabajo { get; set; }
        @AuraEnabled public String tarea { get; set; }
        @AuraEnabled public String tipoCargo { get; set; }
        @AuraEnabled public String aprobador { get; set; }
        @AuraEnabled public String manoDeObra { get; set; }
        @AuraEnabled public String manoDeObraNombre { get; set; }
        @AuraEnabled public Decimal uts { get; set; }
        @AuraEnabled public Decimal utsReal { get; set; }
        @AuraEnabled public Decimal totalUts { get; set; }
        @AuraEnabled public Decimal totalSubtrabajos { get; set; }
        @AuraEnabled public Decimal utsDelTipoDeTrabajo { get; set; }
        @AuraEnabled public List<SubtrabajoWrapper> subtrabajos { get; set; }
    }
    
    public class SubtrabajoWrapper {
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String nombre { get; set; }
        @AuraEnabled public String alias { get; set; }
        @AuraEnabled public String manoDeObra { get; set; }
        @AuraEnabled public String manoDeObraNombre { get; set; }
        @AuraEnabled public String pasoDeTrabajo { get; set; }
        @AuraEnabled public String tipoTrabajo {get;set; }
        @AuraEnabled public String tipoTrabajoNombre {get;set; }
        @AuraEnabled public Decimal horas { get; set; }
        @AuraEnabled public Decimal uts { get; set; }
        @AuraEnabled public Decimal utsDelTipoDeTrabajo { get; set; }
    }
}