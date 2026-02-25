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
	handleGetEnvioFormalizacion : function(component, event, helper){
        let action = component.get("c.getEnvioFormalizacion");
        action.setParams({
            "oppId" : component.get('v.recordId')
        });
        action.setCallback(this, function(response){
            let state = response.getState();
            if(state === "SUCCESS"){
                console.log('Envio Formalización: ' + response.getReturnValue());
                component.set("v.envioFormalizacion", response.getReturnValue());
                
            }
            
        });
        $A.enqueueAction(action);
    },
    handleGetVehiculoReservado : function(component, event, helper){
        let action = component.get("c.getVehiculoReservado");
        action.setParams({
            "oppId" : component.get('v.recordId')
        });
        action.setCallback(this, function(response){
            let state = response.getState();
            if(state === "SUCCESS"){
                console.log('Vehiculo Reservado: ' + response.getReturnValue());
                component.set("v.vehiculoReservado", response.getReturnValue());
                
            }
            
        });
        $A.enqueueAction(action);
    },
    handleGetHasContact : function(component, event, helper){
        let action = component.get("c.getHasContact");
        action.setParams({
            "oppId" : component.get('v.recordId')
        });
        action.setCallback(this, function(response){
            let state = response.getState();
            if(state === "SUCCESS"){
                console.log('Has Contact: ' + response.getReturnValue());
                component.set("v.hasContact", response.getReturnValue());
                
            }
            
        });
        $A.enqueueAction(action);
    },
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
                if(response.getReturnValue() === true && component.get('v.vehiculoReservado') == true &&  component.get('v.envioFormalizacion') == true &&  component.get('v.hasContact') == true){
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url" : component.get('v.instanceURL') + '/apex/cT_newPlanNegocioUsado?Id=' + component.get('v.recordId')
                    });
                    urlEvent.fire();
                }
            }
            else{
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    },
})