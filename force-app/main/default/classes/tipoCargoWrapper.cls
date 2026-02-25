public class tipoCargoWrapper {
    @AuraEnabled
    public tipoCargo__c tipoCargo { get; set; }
    @AuraEnabled
    public List<Subtipo_de_trabajo_del_caso__c> subtipoTrabajos { get; set; }

    public tipoCargoWrapper(tipoCargo__c tc, List<Subtipo_de_trabajo_del_caso__c> subtipos) {
        this.tipoCargo = tc;
        this.subtipoTrabajos = subtipos;
    }
}