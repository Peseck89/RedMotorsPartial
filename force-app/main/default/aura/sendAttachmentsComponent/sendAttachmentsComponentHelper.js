({
    getUsers : function(component, event, helper) {
        var action = component.get("c.getUserList");
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log("response: ", response.getReturnValue());
            if (component.isValid() && state === "SUCCESS") {
                var result = response.getReturnValue();
                var plValues = [];
                for (var i = 0; i < result.length; i++) {
                    plValues.push({
                        label: result[i],
                        value: result[i]
                    });
                }
                component.set("v.UserList", plValues);
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        
        $A.enqueueAction(action);	
    },
    
    getAttachmentsHelper : function(component, event, helper){
        var recordId = component.get('v.recordId');
        
        component.set('v.columns', [
            {label: 'Nombre del archivo', fieldName: 'Name', type: 'text'},
            {label: 'Fecha de creación', fieldName: 'CreatedDate', type: 'date-local'}
        ]);
        
        var action = component.get("c.getAttachments");
        action.setParams({
            "oppId": recordId    
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.attachmentsList", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);     
    },
    
    sendAttachmentsHelper : function(component, event, helper){
        var self = this;
        if(this.validateRequest(component, event, helper)){
            this.hideErrorToast(component, event, helper);
            
            var cc = component.find("ccEmail").get("v.value");
            var ccEmailIdList = null;
            if(cc && cc != ""){
                ccEmailIdList = cc.split(',');    
            }
            
            var userNames = component.get("v.selectedUserList");        
            var recordId = component.get('v.recordId');
            var selectedAttachments = component.get("v.selectedAttachments");
            var selectedAttachmentIds= [];
            selectedAttachments.forEach(function(attachment){
                selectedAttachmentIds.push(attachment.Id);
            });
            
            var action = component.get("c.sendEmail");
            action.setParams({
                "oppId": recordId,
                "userNames": userNames,
                "attachmentIds": selectedAttachmentIds,
                "ccEmailIdList": ccEmailIdList
            });
            
            action.setCallback(this, function(response){
                var state = response.getState();
                console.log("sendAttachmentsHelper response", response.getState());
                if (state === "SUCCESS") {
                    helper.showSuccessToast(component, event, helper);
                }
            });
            $A.enqueueAction(action);
        }else{
            this.showErrorToast(component, event, helper);    
        }  
    },
    
    showErrorToast : function(component, event, helper) {
        component.set('v.isAnyError', true);
    },
    
    hideErrorToast : function(component, event, helper) {
        component.set('v.isAnyError', false);
    },
    
    showSuccessToast : function(component, event, helper) {
        component.set('v.isAttachmentSent', true);
    },
    
    hideSuccessToast : function(component, event, helper) {
        component.set('v.isAttachmentSent', false);
    },
    
    validateRequest : function(component, event, helper){
        var isValidRequest = true;
        var userNames = component.get("v.selectedUserList"); 
        var selectedAttachments = component.get("v.selectedAttachments");
        
        if(userNames.length <= 0){
        	isValidRequest = false;    
        }
        if(selectedAttachments.length <= 0){
        	isValidRequest = false;       
        }
        return isValidRequest;
    }
})