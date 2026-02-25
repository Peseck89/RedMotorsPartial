({
    echo : function(component, event, helper) {
        let button = event.getSource();
    	button.set('v.disabled',true);
        // alert("Tu solicitud está siendo procesada, por favor espera en esta pantalla hasta recibir el mensaje de respuesta del sistema.");
        
        // create a one-time use instance of the serverEcho action
        // in the server-side controller
        var action = component.get("c.getClienteLagoDatos");
        //alert(cmp.get("v.recordId"));
        action.setParams({oportunidadFinanciamientoId : component.get("v.recordId") });

        // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                alert(response.getReturnValue());
                location.reload();
            }
            else if (state === "INCOMPLETE") {
                alert(response.getReturnValue());
                console.log(response);
            }
            else if (state === "ERROR") {
                console.log(response);
                alert(response.getReturnValue());
                var errors = response.getError();
            }
        });
        $A.enqueueAction(action);
    }
})