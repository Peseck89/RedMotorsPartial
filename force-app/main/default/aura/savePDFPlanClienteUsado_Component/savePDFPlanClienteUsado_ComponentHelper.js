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

    /* Funcion que verifica si el descuento esta aprobado y restringe la descarga y visualizacion en  caso de que no sea asi
    handleGetDescuentoAprobado : function(component, event, helper){
        let action = component.get("c.getDescuentoAprobado");
        action.setParams({
            "oppId" : component.get('v.recordId')
        });
        action.setCallback(this, function(response){
            let state = response.getState();
            if(state === "SUCCESS"){
                console.log('Descuento aprobado: ' + response.getReturnValue());
                component.set("v.descuentoAprobado", response.getReturnValue());
                if(response.getReturnValue() === true) helper.handleAttachPDF(component, event, helper);
            }
            else{
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    },
    */

    handleAttachPDF : function(component, event, helper){
        let action = component.get("c.attachPDFinOpportunity");
        action.setParams({
            "oppId" : component.get('v.recordId'),
            "fromButton" : 'Plan de cliente',
            "vfNamePage" : 'cT_newPlanClienteUsado?Id=' + component.get('v.recordId'),
            "save" : true
        });
        action.setCallback(this, function(response){
            let state = response.getState();
            console.log('State: ' + state);
            if(state === "SUCCESS"){
                component.set("v.messagePDF", "Success");
                if(response.getReturnValue() === 'Email Success'){
                $A.get('e.force:showToast').setParams
                    ({
                        "title": "Success",
                        "message": "Se envio el email correctamente",
                        "type": "success",
                    }).fire();
                }
                if(response.getReturnValue() === 'Email Error'){
                    console.log("Failed with state: " + state);
                    $A.get('e.force:showToast').setParams
                    ({
                        "title": "Error",
                        "message": "No se envio el email, favor de revisar el territorio de servicio.",
                        "type": "error",
                    }).fire();
                }
                console.log(component.get('v.instanceURL') + '/apex/cT_newPlanClienteUsado?Id=' + component.get('v.recordId'));
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url" : component.get('v.instanceURL') + '/apex/cT_newPlanClienteUsado?Id=' + component.get('v.recordId')
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