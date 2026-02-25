public class OrderTriggerHandler extends TriggerHandler {

    private Map<Id, Order> newOpMap;
    private List<Order> ListNewOrders;
    
    private Map<Id, Order> MapOldOrder;
    private List<Order> ListOldOrders;
    
    public OrderTriggerHandler() {
        this.newOpMap = (Map<Id, Order>) Trigger.newMap;
        this.ListNewOrders = (List<Order>) Trigger.New;
        this.ListOldOrders = (List<Order>) Trigger.Old;
        this.MapOldOrder = (Map<Id, Order>) Trigger.oldMap;         
    }
    
    public override void afterInsert(){
        List<Workorder> woUpdateList = new List<Workorder>();
        Set<Id> woIds = new Set<Id>();
        Map<Id,Id> mapWOIdOrderId = new Map<Id,Id>();
        for(Order op : ListNewOrders){
            if(op.Work_Order__c != null){
                woIds.add(op.Work_Order__c);
                mapWOIdOrderId.put(op.Work_Order__c,op.Id);
                //woUpdateList.add(new Workorder(Id = op.Work_Order__c,Order__c = op.Id));
            }
        }
        if(woIds.size()>0){
            for(WorkOrder wo : [Select Id, Order__c From WorkOrder Where ID IN: woIds]){
                if(wo.Order__c != null){
                    woUpdateList.add(new Workorder(Id = wo.Id,Order__c = mapWOIdOrderId.get(wo.Id)));
                }
            }
        	if(woUpdateList.size() > 0){
            	update woUpdateList;
        	}
        }
    }
    
    public override void afterUpdate(){
        Map<Id, Order> MapOrderNews = new Map<Id, Order>();
        Map<Id, Boolean> lastApprovedOrderInCase = new Map<Id,Boolean>();
        Set<Id> setOrderNews = new Set<Id>();
        Set<Id> idsOpTasks = new Set<Id>();
        Set<Id> actOpTasks = new Set<Id>();
        
        List<Workorder> woUpdateList = new List<Workorder>();
        List<Case> caseUpdateList = new List<Case>();
        
        Set<Id> accountIds = new Set<Id>();
        for(Order op: ListNewOrders) {
            if(op.Contribuyente__c != null) {
                accountIds.add(op.Contribuyente__c);
            } else {
                accountIds.add(op.AccountId);
            }
        }
        
        Map<Id, Account> invalidAccountsForOrderApproval = OrderService.getInvalidAccountsForOrderApproval(accountIds);
        Set<Id> ordersIdsWithUnavailableProducts = OrderService.getOrderIdsHavingUnavailableProducts(newOpMap.keySet());

        Set<Id> caseRelatedIds = new Set<Id>();
        for(Order currentOrd : ListNewOrders) if (!caseRelatedIds.contains(currentOrd.Case__c)) caseRelatedIds.add(currentOrd.Case__c);
        List<Order> otherOrders = [SELECT Id, Case__c, Status, OrderNumber FROM Order WHERE Case__c IN : caseRelatedIds AND Id NOT IN : ListNewOrders ]; //Lista de todas las ordenes relacionadas
        //for(Order currentOrd : ListNewOrders) Order removedOrder = otherOrders.remove(currentOrd.id);
        //se revisa las ordenes relacionadas que no se actualizaron
        for(Order currentOrd : otherOrders){ 
            if(!lastApprovedOrderInCase.containsKey(currentOrd.Case__c)) lastApprovedOrderInCase.put(currentOrd.Case__c, true); //Seteamos el mapa de las banderas de ordenes relacionadas
            system.debug('old: ' + currentOrd.OrderNumber + ' ' + currentOrd.Status);
            if(currentOrd.Status != 'Aprobado')lastApprovedOrderInCase.put(currentOrd.Case__c, false);
        }
        System.debug('other orders: ' + lastApprovedOrderInCase );
        // se revisan las ordenes nuevas que se actualizan
        for(Order currentOrd : ListNewOrders){
            if(!lastApprovedOrderInCase.containsKey(currentOrd.Case__c)) lastApprovedOrderInCase.put(currentOrd.Case__c, true); //Seteamos el mapa de las banderas de ordenes relacionadas
            system.debug('new: ' + currentOrd.OrderNumber + ' ' + currentOrd.Status);
            if(currentOrd.Status != 'Aprobado')lastApprovedOrderInCase.put(currentOrd.Case__c, false);
        }
        System.debug('new orders: ' + lastApprovedOrderInCase );

        List<WorkOrder> relatedWorkOrders = [SELECT Id FROM WorkOrder WHERE Id IN : newOpMap.keySet()];
        for(Order op : ListNewOrders){
            /*
              @Author: esteban@incompany.cr
              @Project: Proyecto 0609
            */
            if(op.Status == 'Aprobado' && MapOldOrder.get(op.Id).Status != 'Aprobado')
            {
                String request_id = String.valueOf(op.Id) +DateTime.now().getTime();
               /* if(invalidAccountsForOrderApproval.get(op.Contribuyente__c) != null || invalidAccountsForOrderApproval.get(op.AccountId) != null) {
                    op.addError('Para poder aprobar a order debe ingresar los valores faltantes en la cuenta: condición de pago e Impuesto, porfavor verifique e intente de nuevo.');
                }
                
                /* if(ordersIdsWithUnavailableProducts.contains(op.Id)){
                    op.addError('No hay cantidad disponible del product seleccionado. Porfavor valide la cantidad disponible.'); 
                }*/
                APIServiceLog sofltanProcesServiceLog = new APIServiceLog(request_id, APIServiceLogConstants.SOFTLAND_API_SERVICE_TYPE,
                                                                   		  APIServiceLogConstants.SOFTLAND_API_SERVICE_RELATED_OBJECT,
                                                                          op.Work_Order__c, APIServiceLogConstants.APILOG_WORKORDER_FIELD_REFERENCE);
                if(op.Work_Order__c != null)
                    woUpdateList.add(new Workorder(Id = op.Work_Order__c,
                                                   Status = 'Completado'));
                
                if(op.Case__c != null && lastApprovedOrderInCase.get(op.Case__c))
                    caseUpdateList.add(new Case(Id = op.Case__c,
                                                Status = 'Cerrado'));
                
                if(op.Contribuyente__c != null)
                {
                    OrderService.initSofltandProcess(op.Id,op.Contribuyente__c,request_id);
                    ProductController.setSoftlandConfirmation('request', request_id, op.Work_Order__c);
                }
                else
                {
                    OrderService.initSofltandProcess(op.Id,op.AccountId,request_id);
                    ProductController.setSoftlandConfirmation('request', request_id, op.Work_Order__c);
                }
                
            }
        }
        
        if(woUpdateList.size() > 0)
            //update woUpdateList;
        
        if(caseUpdateList.size() > 0){
            system.debug('Se actualizo el caso');
            //update caseUpdateList;
        }
    }
    
   /* public override void beforeInsert(){
        system.debug('ID');
        List<Id> woIds = new List<Id>();
         for(Order order : ListNewOrders){
			woIds.add(order.Work_Order__c);
         }
        List<Order> toDelete=[Select id from Order where Work_Order__c=:woIds];
        for(Order order : toDelete){
			order.Status='Draft';
        }
        update toDelete;
        delete toDelete;
        
    }*/
    
}