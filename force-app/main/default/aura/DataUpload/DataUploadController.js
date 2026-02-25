({
    uploadLead : function(component, event, helper) {
       
        var action = component.get("c.initiateLeadImport");
        action.setCallback(this, function(response) {
             // Close the action panel
            
            var state = response.getState();
            if (state === "SUCCESS") 
            {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title" : "Success",
                    "message" : "Data Uploading Process Started!!",
                    "type" : "success"
                });
                toastEvent.fire();
               
            }
            else
            {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title" : "Failure",
                    "message" : "Backend Process not started!!",
                    "type" : "error"
                });
            	toastEvent.fire();
            }
        })
        $A.enqueueAction(action);
 },
 uploadOpportunity : function(component, event, helper) {
       
    var action = component.get("c.initiateOpportunityImport");
    action.setCallback(this, function(response) {
         // Close the action panel
        
        var state = response.getState();
        if (state === "SUCCESS") 
        {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title" : "Success",
                "message" : "Data Uploading Process Started!!",
                "type" : "success"
            });
            toastEvent.fire();
           
        }
        else
        {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title" : "Failure",
                "message" : "Backend Process not started!!",
                "type" : "error"
            });
            toastEvent.fire();
        }
    })
    $A.enqueueAction(action);
}                            
 })