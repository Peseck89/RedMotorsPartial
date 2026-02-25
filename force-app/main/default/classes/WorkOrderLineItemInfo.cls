public class WorkOrderLineItemInfo{
    @AuraEnabled
    public String workOrderLineItemName { get; set; }
    
    @AuraEnabled
    public Decimal totalAmount { get; set; }
    
    @AuraEnabled
    public String chargeType { get; set; }
    
    @AuraEnabled
    public String tipoTrabajo { get; set; }

    // Constructor para inicializar la clase
    public WorkOrderLineItemInfo(String workOrderLineItemName, Decimal totalAmount, String chargeType, string tipoTrabajo) {
        this.workOrderLineItemName = workOrderLineItemName;
        this.totalAmount = totalAmount;
        this.chargeType = chargeType;
        this.tipoTrabajo = tipoTrabajo;
    }
}