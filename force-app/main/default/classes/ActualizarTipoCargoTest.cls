@isTest
public class ActualizarTipoCargoTest {
	@isTest(SeeAllData=True)
    public static void TestActualizar()
    {
        List<ActualizarTipoCargo.FlowInput> inputs = new List<ActualizarTipoCargo.FlowInput>();
        ActualizarTipoCargo.FlowInput input = new ActualizarTipoCargo.FlowInput();
        tipoCargo__c tcargo = [SELECT Id, Work_Order_Line_Item__c FROM tipoCargo__c WHERE Work_Order_Line_Item__c != null and Work_Order_Line_Item__r.Estado__c != 'Facturado' LIMIT 1];
        WorkOrderLineItem Woli = [SELECT Id, WorkOrderId FROM WorkOrderLineItem WHERE Id =: tcargo.Work_Order_Line_Item__c LIMIT 1];
        input.WO = [SELECT Id, CurrencyIsoCode, tipoDeGasto__c FROM WorkOrder WHERE Id =: Woli.WorkOrderId LIMIT 1];
        input.WO.tipoDeGasto__c = 'BCI';
        System.debug('input.WO: ' + input.WO);
        inputs.add(input);
        ActualizarTipoCargo.ActualizarRegistros(inputs);
    }    
}