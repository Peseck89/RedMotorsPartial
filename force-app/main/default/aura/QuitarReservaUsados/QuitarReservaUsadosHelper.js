({
	getCurrentOppHelper : function(component, event, helper) {
        let action = component.get("c.getCurrentOpp");
        action.setParams({
            "OppId": component.get('v.recordId') 
        });
        action.setCallback(this, function(response){
            let state = response.getState();
            if(state === "SUCCESS"){
                component.set("v.currentOpp", response.getReturnValue());
            }
            else{
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    },
    
    getModelosVehiculos : function(component, event, helper){
        let action = component.get("c.getModelosVehiculos");
        action.setParams({
            "OppId": component.get('v.recordId') 
        });
        action.setCallback(this, function(response){
            let state = response.getState();
            if(state === "SUCCESS"){
                component.set("v.modelosVehiculos", response.getReturnValue());
            }
            else{
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    },
    
    continueReservaHelper : function(component, event, helper){
        let action = component.get("c.getProduct");
        action.setParams({
            "ProdId" : component.get('v.selectedValue')
        });
        action.setCallback(this, function(response){
            let state = response.getState();
            if(state === "SUCCESS"){
                component.set("v.holder", response.getReturnValue());
            }
            else{
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    },
    
    checkAnticipoHelper : function(component, event, helper){
        let action = component.get("c.getAnticipo");
        action.setParams({
            "OppId" : component.get('v.recordId'),
            "ProdId" : component.get('v.selectedValue')
        });
        action.setCallback(this, function(response){
            let state = response.getState();
            if(state === "SUCCESS"){
                component.set("v.Anticipo", response.getReturnValue());
            }
            else{
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    },
    
    handleEliminarReservaHelper : function(component, event, helper){
        let action = component.get("c.makeEliminarReserva");
        action.setParams({
            "OppId" : component.get('v.recordId'),
            "ProdId" : component.get('v.selectedValue')
        });
        action.setCallback(this, function(response){
            let state = response.getState();
            if(state === "SUCCESS"){
                component.set("v.holder", response.getReturnValue());
                component.set("v.fPage2", false);
                component.set("v.fPage3", true);
                $A.get('e.force:showToast').setParams
                            ({
                            "title": "Success",
                            "message": "Se elimino la reserva correctamente",
                            "type": "success",
                            }).fire();
            }
            else{
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        $A.get('e.force:showToast').setParams
                            ({
                            "title": "Error",
                            "message": errors[0].message,
                            "type": "error",
                            }).fire();
                        console.log("Error message: " + errors[0].message);
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },
    
})