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

    handleOpenFlow : function(component, event, helper){
        var oppId = component.get('v.recordId');

        //Set startFlow true
        component.set("v.startFlow", true);

        //Find lightning flow from component
        var flow = component.find("testFlowID");
        //Put input variable values
        var inputVariables = [
            {
                name : "recordId",
                type : "String",
                value : oppId
            },
        ];
        //Reference flow`s Unique Name
        flow.startFlow("Select_vehicle_for_proforma_de_ventas", inputVariables);
    },

    handleAttachPDF : function(component, event, helper){
        let action = component.get("c.attachPDFinOpportunity");
        action.setParams({
            "oppId" : component.get('v.recordId'),
            "fromButton" : 'Factura proforma',
            "vfNamePage" : 'ct_facturaProforma?Id=' + component.get('v.recordId'),
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
            }
            else{
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    },

    // showNotification : function(title, message, variant){
    //     var toastEvent = $A.get("e.force:showToast");
    //         toastEvent.setParams({
    //             title : title,
    //             message : message,
    //             type : variant
    //         });
    //     toastEvent.fire();
    // },
})