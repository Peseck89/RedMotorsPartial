({
	echo : function(component, event, helper) {
        component.set('v.btnDisabled',true);
        // create a one-time use instance of the serverEcho action
        // in the server-side controller
        var action = component.get("c.sendCheckOrderSoftland");
        action.setParams({orderId : component.get("v.recordId") });

        // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                alert(response.getReturnValue());
                location.reload();
            }
            else if (state === "INCOMPLETE") {
                //alert(response.getReturnValue());
                console.log(response);
            }
            else if (state === "ERROR") {
                console.log(response);
                //alert(response.getReturnValue());
                var errors = response.getError();
            }
        });
        $A.enqueueAction(action);
    }
})