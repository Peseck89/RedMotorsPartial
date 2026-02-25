({
	doInit : function(component, event, helper) {
		//component.set('v.routeInput', {recordId: component.get('v.recordId')});
        helper.getCurrentOppHelper(component, event, helper);
        helper.getModelosUsados(component, event, helper);
	},
    
    continueReserva : function(component, event, helper){
        component.set("v.fPage1", false);
        component.set("v.fPage2", true);
        helper.continueReservaHelper(component, event, helper);
        helper.checkAnticipoHelper(component, event, helper);
        
    },
    
    handleReserva : function(component, event, helper){
        helper.handleReservaHelper(component, event, helper);
    },
    
    onCancel : function(component, event, helper){
        var navEvent = $A.get("e.force:navigateToSObject");
        navEvent.setParams({
            recordId: component.get('v.recordId'),
            slideDevName : "related"
        });
        navEvent.fire();
    },
})