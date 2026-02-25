({
    doInit : function(component, event, helper) {
        var myPageRef = component.get("v.pageReference");
var parentRecordId = myPageRef.state.c__parentRecordId;
        console.log('parentRecordId', parentRecordId);
        //var value = helper.getParameterByName(component , event, 'inContextOfRef');
        //var context = JSON.parse(window.atob(value));
        component.set("v.parentRecordId", parentRecordId);
            var action = component.get("c.getEmpresa");
            action.setParams({
                "IdPlantilla": component.get("v.parentRecordId")
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS") {
                    component.set("v.EmpresaPlantilla", response.getReturnValue());
                    console.log('component.get ',component.get("v.EmpresaPlantilla"));
                }
            });
         $A.enqueueAction(action);
        
	},
    regresarPlantilla: function(component, event, helper) {
        component.find("navService").navigate({
            "type": "standard__recordPage",
            "attributes": {
                "recordId": component.get("v.parentRecordId"),
                "objectApiName": "Plantilla_de_Presupuesto__c",
                "actionName": "view"
            }
        });
    },
    handleSubmit: function(component, event, helper) {
        alert('Guardado Correctamente');
        $A.get('e.force:refreshView').fire();
        /*var params = event.getParams();
        component.find("navService").navigate({
        "type": "standard__recordPage",
        "attributes": {
            "recordId": params.response.id,
            "objectApiName": "Linea_Plantilla_de_Presupuesto__c",
            "actionName": "view"
        }
    });*/
    },
    handleSave: function(component, event, helper) {
            //component.set("v.lineaPlantilla.Plantilla_de_Presupuesto__c", component.get("v.parentRecordId"));
            console.log('dentro ', v.lineaPlantilla);
            component.find("lineaPlantillaRecordCreator").saveRecord(function(saveResult) {
                if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                    // record is saved successfully
                    var resultsToast = $A.get("e.force:showToast");
                    resultsToast.setParams({
                        "title": "Guardado",
                        "message": "Linea de Plantilla guardada Corractamente."
                    });
                    resultsToast.fire();

                } else if (saveResult.state === "INCOMPLETE") {
                    // handle the incomplete state
                    console.log("User is offline, device doesn't support drafts.");
                } else if (saveResult.state === "ERROR") {
                    // handle the error state
                    console.log('Problem saving linea plantilla, error: ' + JSON.stringify(saveResult.error));
                } else {
                    console.log('Unknown problem, state: ' + saveResult.state + ', error: ' + JSON.stringify(saveResult.error));
                }
            });
        
    }
})