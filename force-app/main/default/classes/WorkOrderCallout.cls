public class WorkOrderCallout {
    
    public class Request {
        @InvocableVariable(label='Order ID' required=true)
        public String orderId;

        @InvocableVariable(label='Company Type' required=true)
        public String companyType;
    }

    @InvocableMethod(label='Cancel Work Order' description='Invoke this method to cancel a work order')
    public static void cancelWorkOrderAsync(List<Request> requests) {
        if(!requests.isEmpty()) {
            Request req = requests[0];
            WorkOrderCancelOrder.cancelWorkOrder(req.orderId, req.companyType);
        }
    }
}