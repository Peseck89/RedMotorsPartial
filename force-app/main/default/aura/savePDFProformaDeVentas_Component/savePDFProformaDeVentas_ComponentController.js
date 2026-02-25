({
    doInit : function(component, event, helper) {
        helper.handleOpenFlow(component, event, helper);
    },

    statusChange : function(component, event, helper){
        if(event.getParam('status') === "FINISHED_SCREEN" || event.getParam('status') === "FINISHED"){
            // helper.showNotification ("Success!", "Termino correctamente el flujo", "success");
            component.set("v.startFlow", false);
            helper.handleGetURL(component, event, helper);
            helper.handleAttachPDF(component, event, helper);
            $A.get('e.force:refreshView').fire();
        }
        else if(event.getParam('status') === "ERROR"){
            // helper.showNotification ("Error!", "Hubo un error en el flujo", "error");
        }
    },

    //Spinner
    // function automatic called by aura:waiting event  
    showSpinner: function(component, event, helper) {
        // remove slds-hide class from mySpinner
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },    
        // function automatic called by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // add slds-hide class from mySpinner    
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
    }
    // End Spinnerp
})