({
    doInit : function(component, event, helper) {
        
        helper.handleGetURL(component, event, helper);
        helper.handleGetEnvioFormalizacion(component, event, helper);
        helper.handleGetVehiculoReservado(component, event, helper);
        helper.handleGetHasContact(component, event, helper);
        helper.handleGetDescuentoAprobado(component, event, helper);
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