({
	goOppdata : function(component, event, helper) {
        component.set("v.Spinner",true);
		var action = component.get('c.init');
        action.setParams({});
        action.setCallback(this, function(response) {
            var state = response.getState();
            var ret = response.getReturnValue();
            switch (state) {
                case 'SUCCESS':
                    component.set("v.Spinner",false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Success!',
                        message: 'Last 6 month data uploaded successfully!',
                        type: 'success'
                    });
                    toastEvent.fire();
                    break;
                case 'ERROR':
                    component.set("v.Spinner",false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error Message',
                        message:'This is Error ...!!!',
                        duration:' 4000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                    break;
            }
        });
        $A.enqueueAction(action);
	},
    goLeaddata : function(component, event, helper) {
        component.set("v.Spinner",true);
		var action = component.get('c.initLeads');
        action.setParams({});
        console.log(action);
        action.setCallback(this, function(response) {
            var state = response.getState();
            var ret = response.getReturnValue();
            switch (state) {
                case 'SUCCESS':
                    component.set("v.Spinner",false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Success!',
                        message: 'Leads data uploaded successfully!',
                        type: 'success'
                    });
                    toastEvent.fire();
                    break;
                case 'ERROR':
                    component.set("v.Spinner",false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error Message',
                        message:'This is Error ...!!!',
                        duration:' 4000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                    break;
            }
        });
        $A.enqueueAction(action);
	},
    setoppdata : function(component, event, helper){
         component.set("v.Spinner",true);
		var action = component.get('c.init2');
        action.setParams({});
        action.setCallback(this, function(response) {
            var state = response.getState();
            var ret = response.getReturnValue();
            switch (state) {
                case 'SUCCESS':
                    component.set("v.Spinner",false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Success!',
                        message: 'Data uploaded successfully!',
                        type: 'success'
                    });
                    toastEvent.fire();
                    break;
                case 'ERROR':
                    component.set("v.Spinner",false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error Message',
                        message:'Erro During Uploading Data',
                        duration:' 4000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                    break;
            }
        });
        $A.enqueueAction(action);
    }
})