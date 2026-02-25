({
    checkWorkOrderExist : function(cmp) {
        var recordId = cmp.get("v.recordId");
		var action = cmp.get("c.existWorkOrder");
        action.setParams({ caseId : recordId });
        action.setCallback(this, function(response) {
			console.log("response:"+response);
			if(response.getReturnValue() != null && response.getReturnValue() != ""){
				cmp.set('v.existWorkOrder',true);
			}else{
				cmp.set('v.existWorkOrder',false);
			}
        });
        $A.enqueueAction(action);
    }	
})