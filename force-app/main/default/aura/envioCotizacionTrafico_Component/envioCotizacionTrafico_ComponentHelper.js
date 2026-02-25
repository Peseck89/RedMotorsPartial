({
    helperEnvioCotizacion : function(component, event, helper) {
        var action = component.get("c.envioCotizacion");
        action.setParams({
            "idTrafico" : component.get('v.recordId')
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state = "SUCCESS"){
                var result = response.getReturnValue();
                console.log('========================= result =========================');
                console.log(result);
                if(result == 'Cotización enviada'){
                    $A.get('e.force:showToast').setParams
                    ({
                        "title": "Success",
                        "message": "Cotización enviada correctamente!",
                        "type": "success",
                    }).fire();
                    console.log('Cotización enviada correctamente');
                }else{
                    $A.get('e.force:showToast').setParams
                    ({
                        "title": "Error",
                        "message": "Hubo un problema en el envio de la cotizacion",
                        "type": "error",
                    }).fire();
                    console.log('Error en helperEnvioCotizacion');
                }
                window.setTimeout(
                    $A.getCallback(function() {
                        //window.location.reload();
                    }), 5000
                );
            }
        });
        $A.enqueueAction(action);
    },

    helperEnvioCotizacionMultimarca : function(component, event, helper){
        var action = component.get("c.envioCotizacionMultimarca");
        action.setParams({
            "idTrafico" : component.get('v.recordId')
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state = "SUCCESS"){
                var result = response.getReturnValue();
                if(result == 'Cotización enviada'){
                    $A.get('e.force:showToast').setParams
                    ({
                        "title": "Success",
                        "message": "Cotización enviada correctamente!",
                        "type": "success",
                    }).fire();
                    console.log('Cotización enviada correctamente');
                }else{
                    $A.get('e.force:showToast').setParams
                    ({
                        "title": "Error",
                        "message": "Hubo un problema en el envio de la cotizacion",
                        "type": "error",
                    }).fire();
                    console.log('Error en helperEnvioCotizacion :(');
                }
                window.setTimeout(
                    $A.getCallback(function() {
                        alert(isValid);
                    }), 5000
                );
                //window.location.reload();
            }
        });
        $A.enqueueAction(action);
    },
})