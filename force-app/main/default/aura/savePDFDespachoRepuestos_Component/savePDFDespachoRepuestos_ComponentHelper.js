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
        let action = component.get("c.attachPDFinWO");
        action.setParams({
            "woId" : component.get('v.recordId'),
            "fromButton" : 'Despacho de repuestos',
            "vfNamePage" : 'AlbaranPDFGroupTc?id=' + component.get('v.recordId'),
            "save" : false,
            "enviarEmail" : true
        });
        action.setCallback(this, function(response){
            let state = response.getState();
            console.log('State: ' + state);
            if(state === "SUCCESS"){
                component.set("v.messagePDF", "Success");
                if(response.getReturnValue() === 'Email Success'){
                    console.log('Response before event: ' + response.getReturnValue());
                    $A.get('e.force:showToast').setParams
                    ({
                        "title" : "Success",
                        "message" : "Se envio el email correctamente",
                        "type" : "success",
                    }).fire();
                }
                if(response.getReturnValue() === 'Email Error'){
                    console.log("Failed with state: " + state);
                    $A.get('e.force:showToast').setParams
                    ({
                        "title" : "Error",
                        "message" : "No se envio el email, favor de revisar el territorio de servicio.",
                        "type" : "error",
                    }).fire();
                }
            }
            else{
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    },
})