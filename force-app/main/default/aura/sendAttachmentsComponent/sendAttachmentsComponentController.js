({
    doInit : function(component, event, helper) {
        component.set('v.routeInput', {recordId: component.get('v.recordId')});
        
        helper.getUsers(component, event, helper);
        
        helper.getAttachmentsHelper(component, event, helper);
    },
    
    handleUserChange: function (component, event, helper) {
        var selectedValues = event.getParam("value");
        component.set("v.selectedUserList", selectedValues);
    },
    
    getSelectedUsers : function(component, event, helper){
        var selectedValues = component.get("v.selectedUserList");
    },
    
    updateSelectedAttachments: function (component, event) {
        var selectedRows = event.getParam('selectedRows');
        component.set("v.selectedAttachments", selectedRows);
    },
    
    sendAttachmnets : function(component, event, helper){
        helper.sendAttachmentsHelper(component, event, helper);
    },
    
    showSpinner: function(component, event, helper) {
        component.set("v.Spinner", true); 
    },
    
    hideSpinner : function(component,event,helper){
        component.set("v.Spinner", false);
    },
    
    closeError : function(component,event,helper){
        helper.hideErrorToast(component, event, helper);
    },
    
    closeSuccess : function(component,event,helper){
        helper.hideSuccessToast(component, event, helper);	    
    }
})