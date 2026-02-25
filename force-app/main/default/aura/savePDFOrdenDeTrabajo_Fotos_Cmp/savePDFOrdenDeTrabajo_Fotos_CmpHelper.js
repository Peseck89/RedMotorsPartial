({
    handleGetURL : function(component, event, helper) {
        let action = component.get("c.getURL");
        action.setCallback(this, function(response){
            let state = response.getState();
            if(state === "SUCCESS"){
                component.set("v.instanceURL", response.getReturnValue());
            }
            else{
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    },

    handleAttachPDF : function(component, event, helper){
        let action = component.get("c.attachPDFinCase");
        action.setParams({
            "caseId" : component.get('v.recordId'),
            "fromButton" : 'Orden de trabajo - Fotos',
            "vfNamePage" : 'CaseChecklistPDFBeta_v2'
        });
        action.setCallback(this, function(response){
            let state = response.getState();
            console.log('State: ' + state);
            if(state === "SUCCESS"){
                component.set("v.messagePDF", "Success");
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url" : component.get('v.instanceURL') + '/apex/CaseChecklistPDFBeta_v2?Id=' + component.get('v.recordId')
                });
                urlEvent.fire();
            }
            else{
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    },
})