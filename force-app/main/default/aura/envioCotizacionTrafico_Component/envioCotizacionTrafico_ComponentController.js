({
    doInit : function(component, event, helper) {
        var action = component.get("c.getLead");
        action.setParams({
            "leadId" : component.get('v.recordId')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state == "SUCCESS" && component.isValid()){
                var thisLead = response.getReturnValue();
                component.set("v.currentLead", thisLead);
                console.log(thisLead);
                console.log('result.Cotizacion_1__c -> ' + thisLead.Cotizacion_1__c);
                if(thisLead.Cotizacion_1__c == true || thisLead.Cotizacion_2__c == true || thisLead.Cotizacion_3__c == true || thisLead.Cotizacion_4__c == true){
                    if(thisLead.Marca__c == 'BMW' || thisLead.Marca__c == 'MINI' || thisLead.Marca__c == 'Motorrad' || thisLead.Marca__c == 'Kawasaki' || thisLead.Marca__c == 'Polaris' || thisLead.Marca__c == 'Indian')helper.helperEnvioCotizacion(component, event, helper);
                    else helper.helperEnvioCotizacionMultimarca(component, event, helper);
                }
                else{
                    $A.get('e.force:showToast').setParams
                    ({
                        "title": "Error",
                        "message": "El campo Cotización en la sección Vehículo de Interés tiene que estar marcado",
                        "type": "error",
                    }).fire();
                    console.log('El campo Cotización en la sección Vehículo de Interés tiene que estar marcado');
                }
            }else{
                $A.get('e.force:showToast').setParams
                ({
                    "title": "Error",
                    "message": "Hubo un problema en el envio de la cotización.",
                    "type": "error",
                }).fire();
                console.error("fail:" + response.getError()[0].message); 
            }
            window.setTimeout(
                $A.getCallback(function() {
                    window.location.reload();
                }), 5000
            );
        });
        $A.enqueueAction(action);
    }
})