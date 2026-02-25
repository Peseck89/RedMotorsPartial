({
	searchRecordsHelper : function(component, event, helper, value) {
 		$A.util.removeClass(component.find("Spinner"), "slds-hide");
        var searchString = component.get('v.searchString');
       
        component.set('v.message', '');
        component.set('v.recordsList', []);

     	var action = component.get('c.fetchRecords');
        action.setParams({
            'searchString' : searchString,
            'value' : value
        });
        action.setCallback(this,function(response){
        var result = response.getReturnValue();
        if(response.getState() === 'SUCCESS') {
            if(result.length > 0) {
                 if( $A.util.isEmpty(value) ) {
                     component.set('v.recordsList',result);        
                 } else {
                     component.set('v.selectedRecord', result[0]);
                 }
     		} else {
                 component.set('v.message', "No Records Found for '" + searchString + "'");
            }
         } else {

                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    component.set('v.message', errors[0].message);
                }
            }
            if( $A.util.isEmpty(value) )
                $A.util.addClass(component.find('resultsDiv'),'slds-is-open');
         $A.util.addClass(component.find("Spinner"), "slds-hide");
        });
        $A.enqueueAction(action); 
 	},
    
    getEventRecordsHelper : function(component, event, helper) {
 		$A.util.removeClass(component.find("Spinner"), "slds-hide");
        var recordId = component.get('v.recordId');
     	var action = component.get('c.fetchEventDetail');
        action.setParams({
            'recordId' : recordId
        });
        action.setCallback(this,function(response){
        var result = response.getReturnValue();
        if(response.getState() === 'SUCCESS') {
            if(result != null) {
                component.set('v.EventRecord',result);
                if(result.Activo != null && result.Activo != undefined){
                    helper.searchRecordsHelper( component, event, helper, result.Activo );
                }
            }          
        } else {
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    component.set('v.mainMessage', errors[0].message);
                }
            }
        });
        $A.enqueueAction(action); 
 	},
    
    updateEventRecordsHelper : function(component, event, helper, value) {
 		$A.util.removeClass(component.find("SpinnerMain"), "slds-hide");
     	var action = component.get('c.updateEventDetail');
        var recordId = component.get('v.recordId');
        action.setParams({
            'recordId': recordId,
            'Activo': value.Activo,
            'tipoCargoCliente': value.tipoCargoCliente,
            'tipoCargoAseguradora': value.tipoCargoAseguradora,
            'tipoCargoGarantia' : value.tipoCargoGarantia,
            'tipoCargoBci': value.tipoCargoBci
        });
        action.setCallback(this,function(response){
        var result = response.getReturnValue();
        if(response.getState() === 'SUCCESS') {
            if(result['label'] == 'Updated'){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    mode: 'dismissible',
                    message: 'Event is Updated',
                    type : 'success'
                });
                toastEvent.fire();
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
        		dismissActionPanel.fire();
            }
        } else {
             var errors = response.getError();
             if (errors && errors[0] && errors[0].message) {
                 component.set('v.message', errors[0].message);
             }
         }
         $A.util.addClass(component.find("SpinnerMain"), "slds-hide");
        });
        $A.enqueueAction(action); 
 	}
})