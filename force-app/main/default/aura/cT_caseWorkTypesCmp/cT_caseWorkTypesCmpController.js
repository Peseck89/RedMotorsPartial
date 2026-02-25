({
    init : function(cmp, event, helper) {
        // var pageRef = cmp.get("v.pageReference");
        // console.log(pageRef);
        // var state = pageRef.state; // state holds any query params
        // var base64Context = state.inContextOfRef;

        // For some reason, the string starts with "1.", if somebody knows why,
        // this solution could be better generalized.
        // if (base64Context.startsWith("1\.")) {
        //     base64Context = base64Context.substring(2);
        // }
        // var addressableContext = JSON.parse(window.atob(base64Context));
        // cmp.set("v.recordId", addressableContext.attributes.recordId);

        console.log("paso por aqui");
        helper.checkWorkOrderExist(cmp);
    },
    
    closeBtn : function(component, event, helper) {
        component.set("v.displayModal", false);        
    },
    
    noBtn : function(component, event, helper) {
        component.set("v.displayModal", false);
    },

    onCancel : function(component, event, helper){
        var navEvent = $A.get("e.force:navigateToSObject");
        navEvent.setParams({
            recordId: component.get('v.recordId'),
            slideDevName : "related"
        });
        navEvent.fire();
    },

    onCloseAlert : function (component, event, helper){
        component.set("v.showAlert", false);
    },
})