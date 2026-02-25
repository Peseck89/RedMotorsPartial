({
    doInit: function(component, event, helper) {
        // var action = component.get('c.statusListItemsView');
        
        const empApi = component.find('empApi');
        const channel = '/event/Page_Refresh__e';    
        const replayId = -1;
        empApi.subscribe(channel, replayId, $A.getCallback(eventReceived => {
            //Payload will have attribues(Fields) values from published plat form event
            console.log('Received event ', eventReceived.data.payload.Name__c);
            
            component.set('v.flagInterval',true);// Flag to stop timer
            var a = component.get('c.handleChangeTerritoryFilter1');
            $A.enqueueAction(a);
        })).then(subscription => {
            // Confirm that we have subscribed to the event channel.
            console.log('Subscribed to channel ', subscription.channel);
            // Save subscription to unsubscribe later
            //component.set('v.subscription', subscription);
        });
            
            var action = component.get('c.getAllTerritoy');
            action.setCallback(this, function(response){
            var state = response.getState();
            console.log('response.getState() :: '+response.getState());
            if(state === "SUCCESS"){
            var result = response.getReturnValue();
            component.set('v.territoryFilter1',result);
        }
        });
            $A.enqueueAction(action);
            
            var action1 = component.get('c.getTipoDeServicio');
            action1.setCallback(this, function(response){
            var state = response.getState(); 
            console.log('response.getState() :: '+response.getState());
            if(state === "SUCCESS"){
            var result = response.getReturnValue();
            component.set('v.tipoDeServiceFilter2',result);
        }
        });
            $A.enqueueAction(action1);
            
            var action2 = component.get('c.getuserList');
            action2.setCallback(this, function(response){
            var state = response.getState(); 
            console.log('response.getState() :: '+response.getState());
            if(state === "SUCCESS"){
            var result = response.getReturnValue();
            component.set('v.UserListFilter3',result);
        }
        });
            $A.enqueueAction(action2);
            
            var action3 = component.get('c.getStatus');
            action3.setCallback(this, function(response){
            var state = response.getState(); 
            console.log('response.getState() :: '+response.getState());
            if(state === "SUCCESS"){
            var result = response.getReturnValue();
            component.set('v.StatusFilter4',result);
        }
        });
            $A.enqueueAction(action3);
            
            component.set("v.statusValue", "Nueva");
            var action = component.get('c.handleChangeTerritoryFilter1');
            $A.enqueueAction(action);
            
            //helper.getWorkStepOrderRecords(component, helper);
        },
            
            closeModel: function(component, event, helper) {
                // Set isModalOpen attribute to false  
                component.set("v.isModalOpen", false);
                component.set("v.isStartButtonClick",false);
                component.set("v.isCompleteButtonClick",false);
                component.set("v.isPauseButtonClick",false);
                component.set("v.isUnPauseButtonClick",false);
                component.set("v.isAddContactButtonClick",false);
                component.set("v.isChangeContactButtonClick",false);
            },
            
            handleChangeTerritoryFilter1 : function(component, event, helper) {
                console.log('piclist 1 value changed');
                var tryVal = component.get("v.territoryValue");
                var tipoVal = component.get("v.tipoValue");
                var contactLookupVal = component.get("v.contactLookupValue");
                var statusVal = component.get("v.statusValue");
                var startDateVal = component.get("v.StartDateValue");
                var endDateVal = component.get("v.EndDateValue");
                console.log('statusVal :: '+statusVal);
                var action = component.get('c.getFilteredDate');
				var turnOnInterval=(statusVal=='En curso'||statusVal=='All')  //MFC              
                action.setParams({
                    "filter1" : tryVal,
                    "filter2" : tipoVal,
                    "filter3" : contactLookupVal,            
                    "filter4fromDate" : startDateVal,
                    "filter5ToDate" : endDateVal,
                    "filter6status" : statusVal,
                    "pageSize" : component.get("v.pageSize").toString(),
                    "pageNumber" : component.get("v.pageNumber").toString()
                    
                });
                action.setCallback(this, function(response){
                    var state = response.getState(); 
                    console.log('handleChangeTerritoryFilter1 callback');
                    if(state === "SUCCESS"){   
                        var result = response.getReturnValue();
                        //console.log('result length :: '+result.wmList.length);
                        if(result.wmList.length < component.get("v.pageSize")){
                            component.set("v.isLastPage", true);
                        } else{
                            component.set("v.isLastPage", false);
                        }
                        
                        component.set("v.resultSize", result.wmList.length);
                        component.set('v.responseWrapperRec',result);
                        if(component.get("v.pageNumber").toString() == '1')
                        {
                            component.set('v.hidePrevPage',true);
                        }
                        else
                        {
                            component.set('v.hidePrevPage',false);
                        }
                        if(turnOnInterval){
                        	helper.refresh(component, event, helper );
                        }
                        if( (!component.get('v.isOn'))&&turnOnInterval){
                            console.log('ENTRAAAAAAAAAA');
                        	helper.startTimer(component, event, helper );//Start Timer
                    	}
                    }
                });
                $A.enqueueAction(action);                
            },
            
            handleTerritoryOnChange : function (component, event, helper){
                component.set("v.pageNumber", 1);
                var a = component.get('c.handleChangeTerritoryFilter1');
                $A.enqueueAction(a);
            },
            
            handleTipoDeServiceOnChange : function (component, event, helper){
                component.set("v.pageNumber", 1);
                var a = component.get('c.handleChangeTerritoryFilter1');
                $A.enqueueAction(a);
            },
            
            handleStausOnChange : function (component, event, helper){
                component.set("v.pageNumber", 1);
                var a = component.get('c.handleChangeTerritoryFilter1');
                $A.enqueueAction(a);
            },
            
            handleStartDateOnChange : function (component, event, helper){
                component.set("v.pageNumber", 1);
                var a = component.get('c.handleChangeTerritoryFilter1');
                $A.enqueueAction(a);
            },
            
            handleEndDateOnChange : function (component, event, helper){
                component.set("v.pageNumber", 1);
                var a = component.get('c.handleChangeTerritoryFilter1');
                $A.enqueueAction(a);
            },
            
            handleContactLookupChange : function (component, event, helper){
                component.set("v.pageNumber", 1);
                var contactLookupId = event.getParam("value")[0];
                console.log('contactLookupId ' + contactLookupId);
                if(contactLookupId != undefined)
                {
                    console.log('IF contactLookupId :: '+contactLookupId);
                    component.set("v.contactLookupValue",contactLookupId);
                    var action = component.get('c.handleChangeTerritoryFilter1');
                    $A.enqueueAction(action);
                }
                else
                {
                    component.set("v.contactLookupValue",null);
                    var action = component.get('c.handleChangeTerritoryFilter1');
                    $A.enqueueAction(action);
                }
            },
            
            handleChangeOwnerClick: function(component, event, helper) {
                component.set("v.isModalOpen", true);
                var tabledata = event.target.closest('.test').dataset;
                var recId = tabledata.record;
                component.set('v.recId',recId);
                console.log('data Id = '+ recId);
            },
            
            handleOnSuccess : function(component, event, helper) {
                component.set('v.recId','');
                component.set("v.isModalOpen", false);
                //$A.get('e.force:refreshView').fire();
                component.find('notifLib').showToast({
                    "variant": "success",
                    "title": "Contact Updated",
                    "message": "Contact Record Updated Successfully!"
                });
            },
            
            handleStartClick : function(component, event, helper) {
                console.log('handleStartClick invoked::');
                component.set("v.isStartButtonClick",true);
                var tabledata = event.target.closest('.test').dataset;
                var recId = tabledata.record;
                component.set('v.recId',recId);
                console.log('recId :: '+recId);        
                var today = new Date().toISOString();        
                component.set("v.showCurrentDateTime", today);
            },
            
            handleCompleteClick : function(component, event, helper) {
                component.set("v.isCompleteButtonClick",true);
                var tabledata = event.target.closest('.test').dataset;
                var recId = tabledata.record;
                component.set('v.recId',recId);
                console.log('recId :: '+recId);
                var today = new Date().toISOString();        
                component.set("v.showCurrentDateTime", today);
                console.log('today :: '+today);
            },
            
            handleOnSuccessStart : function(component, event, helper) {        
                var action = component.get('c.updateNewStatus');
                action.setParams({
                    "recId" : component.get("v.recId")         
                });
                action.setCallback(this, function(response){
                    var state = response.getState();            
                    console.log('state :: '+state);
                    if(state === "SUCCESS"){
                        if(response.getReturnValue() == "Success")
                        {
                            component.set("v.isStartButtonClick",false);
                            var a = component.get('c.handleChangeTerritoryFilter1');
                            $A.enqueueAction(a);
                        }
                        else
                        {
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title : 'Error',
                                message: response.getReturnValue(),
                                duration:' 3000',
                                key: 'info_alt',
                                type: 'error',
                                mode: 'pester'
                            });
                            toastEvent.fire();
                        }
                        console.log('response.getReturnValue() :: '+response.getReturnValue());                               
                    }
                });
                $A.enqueueAction(action);
            },
            handleOnSuccessComplete : function(component, event, helper) {        
                var action = component.get('c.updateCompleteStatus');
                action.setParams({
                    "recId" : component.get("v.recId")         
                });
                action.setCallback(this, function(response){
                    var state = response.getState(); 
                    if(state === "SUCCESS"){
                        if(response.getReturnValue() == "Success")
                        {
                            component.set("v.isCompleteButtonClick",false);
                            var a = component.get('c.handleChangeTerritoryFilter1');
                            $A.enqueueAction(a);
                        }
                        else
                        {
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title : 'Error',
                                message: response.getReturnValue(),
                                duration:' 3000',
                                key: 'info_alt',
                                type: 'error',
                                mode: 'pester'
                            });
                            toastEvent.fire();
                        }                
                        console.log('response.getReturnValue() :: '+response.getReturnValue());          
                    }
                });
                $A.enqueueAction(action);
            },
            
            handleOnSuccessUnPause : function(component, event, helper) {        
                var action = component.get('c.updateUnPauseStatus');
                action.setParams({
                    "recId" : component.get("v.recId"), 
                    "dateHoraDe" : component.get("v.showCurrentDateTime")     
                });
                action.setCallback(this, function(response){
                    var state = response.getState(); 
                    if(state === "SUCCESS"){
                        if(response.getReturnValue() == "Success")
                        {
                            component.set("v.isUnPauseButtonClick",false);
                            var a = component.get('c.handleChangeTerritoryFilter1');
                            $A.enqueueAction(a);
                        }
                        else
                        {
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title : 'Error',
                                message: response.getReturnValue(),
                                duration:' 3000',
                                key: 'info_alt',
                                type: 'error',
                                mode: 'pester'
                            });
                            toastEvent.fire();
                        }                
                        console.log('response.getReturnValue() :: '+response.getReturnValue());                
                    }            
                });
                $A.enqueueAction(action);
            },
            
            handleOnSuccessPause : function(component, event, helper) {        
                var action = component.get('c.updatePauseStatus');
                action.setParams({
                    "recId" : component.get("v.recId")         
                });
                action.setCallback(this, function(response){
                    var state = response.getState(); 
                    if(state === "SUCCESS"){
                        if(response.getReturnValue() == "Success")
                        {
                            component.set("v.isPauseButtonClick",false);
                            var a = component.get('c.handleChangeTerritoryFilter1');
                            $A.enqueueAction(a);
                        }
                        else
                        {
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title : 'Error',
                                message: response.getReturnValue(),
                                duration:' 3000',
                                key: 'info_alt',
                                type: 'error',
                                mode: 'pester'
                            });
                            toastEvent.fire();
                        }
                        console.log('response.getReturnValue() :: '+response.getReturnValue());
                    }
                });
                $A.enqueueAction(action);
            },
            
            handlePauseClick : function (component, event, helper){
                component.set("v.isPauseButtonClick",true);
                var tabledata = event.target.closest('.test').dataset;
                var recId = tabledata.record;
                component.set('v.recId',recId);
                console.log('recId :: '+recId);
                var today = new Date().toISOString();        
                component.set("v.showCurrentDateTime", today);
            },
            
            handleUnPauseClick : function (component, event, helper){
                component.set("v.isUnPauseButtonClick",true);
                var tabledata = event.target.closest('.test').dataset;
                var recId = tabledata.record;
                component.set('v.recId',recId);
                console.log('recId :: '+recId);
                var today = new Date().toISOString();        
                component.set("v.showCurrentDateTime", today);
            },
            
            handleAddNewContactClick : function (component, event, helper){
                component.set("v.isAddContactButtonClick",true);
                var tabledata = event.target.closest('.test').dataset;
                var recId = tabledata.record;
                component.set('v.recId',recId);
                console.log('recId :: '+recId);
            },
            
            handleNewCreatedContactSuccess : function (component, event, helper){
                var action = component.get('c.associateCreatedContactWithWorkStep');
                action.setParams({
                    "workStepRecordId" : component.get("v.recId"),
                    "createdContactRecordId" : event.getParam("id")            
                });
                action.setCallback(this, function(response){
                    var state = response.getState(); 
                    if(state === "SUCCESS"){
                        if(response.getReturnValue() == "Success")
                        {
                            component.set("v.isAddContactButtonClick",false);
                            component.find('notifLib').showToast({
                                "variant": "success",
                                "title": "Contact Created",
                                "message": "Contact Record Created Successfully!"
                            });
                            var a = component.get('c.handleChangeTerritoryFilter1');
                            $A.enqueueAction(a);
                        }
                        else
                        {
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title : 'Error',
                                message: response.getReturnValue(),
                                duration:' 3000',
                                key: 'info_alt',
                                type: 'error',
                                mode: 'pester'
                            });
                            toastEvent.fire();
                        }
                        console.log('response.getReturnValue() :: '+response.getReturnValue());
                    }
                });
                $A.enqueueAction(action);
            },
            
            
            handleChangeContactClick : function (component, event, helper){
                component.set("v.isChangeContactButtonClick",true);
                var tabledata = event.target.closest('.test').dataset;
                var recId = tabledata.record;
                component.set('v.recId',recId);
                console.log('recId :: '+recId);
            },
            
            handleOnSuccessChangeContact : function (component, event, helper){
                component.set("v.isChangeContactButtonClick",false);
                component.find('notifLib').showToast({
                    "variant": "success",
                    "title": "Contact Updated",
                    "message": "Contact Record Updated Successfully!"
                });
            },
            
            updateIniciar : function(component, event, helper) {       
                var descriptionValue = component.find("descField").get("v.value");
                var statusValue = component.find("statusField").get("v.value");
                //var contatcLookupValue = component.find("Mecnicasignadofield").get("v.value");
                var startDateValue = component.find("startDateField").get("v.value");
                
                var action = component.get('c.updateWorkStepOnStart');
                action.setParams({
                    "recId" : component.get("v.recId"),
                    "description" : descriptionValue,
                    "Status" : statusValue,
                    "contactId" : '',
                    "startDate" : startDateValue
                });
                action.setCallback(this, function(response){
                    var state = response.getState(); 
                    if(state === "SUCCESS"){
                        if(response.getReturnValue() == "Success")
                        {
                            component.set("v.isStartButtonClick",false);                     
                        }
                        else
                        {
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title : 'Error',
                                message: response.getReturnValue(),
                                duration:' 3000',
                                key: 'info_alt',
                                type: 'error',
                                mode: 'pester'
                            });
                            toastEvent.fire();
                        }
                        console.log('response.getReturnValue() :: '+response.getReturnValue());
                    }
                });
                $A.enqueueAction(action);
            },
            
            updateCompletar : function(component, event, helper) { 
                var statusValue = component.find("statusFieldOnComplete").get("v.value");
                var startDateValue = component.find("startTimeIdOnComplete").get("v.value");
                var endDateValue = component.find("endTimeIdOnComplete").get("v.value");
                
                var action = component.get('c.updateWorkStepOnComplete');
                action.setParams({
                    "recId" : component.get("v.recId"),            
                    "Status" : statusValue,
                    "startDate" : startDateValue,
                    "endDate" : endDateValue
                });
                action.setCallback(this, function(response){
                    var state = response.getState(); 
                    if(state === "SUCCESS"){
                        if(response.getReturnValue() == "Success")
                        {
                            component.set("v.isCompleteButtonClick",false);                     
                        }
                        else
                        {
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title : 'Error',
                                message: response.getReturnValue(),
                                duration:' 3000',
                                key: 'info_alt',
                                type: 'error',
                                mode: 'pester'
                            });
                            toastEvent.fire();
                        }
                        console.log('response.getReturnValue() :: '+response.getReturnValue());
                    }
                });
                $A.enqueueAction(action);
            },
            
            onNext : function(component, event, helper) {        
                var pageNumber = component.get("v.pageNumber");
                component.set("v.pageNumber", pageNumber+1);
                var a = component.get('c.handleChangeTerritoryFilter1');
                $A.enqueueAction(a);
                component.set("v.isLastPage", true);
                component.set("v.hidePrevPage", true);
                //helper.getWorkStepOrderRecords(component, helper);
            },
            
            onPrev : function(component, event, helper) {        
                var pageNumber = component.get("v.pageNumber");
                component.set("v.pageNumber", pageNumber-1);
                var a = component.get('c.handleChangeTerritoryFilter1');
                $A.enqueueAction(a);  
                component.set("v.isLastPage", true);
                component.set("v.hidePrevPage", true);
                //helper.getWorkStepOrderRecords(component, helper);
            },
            
              filter : function (component, event, helper){
                var toggle=component.get("v.toggleFilter");
                var container = component.find('containerTable');
                var row = component.find('row');
                  console.log(row);
                if(toggle){
                    $A.util.addClass(container, 'bigtable');
                     $A.util.addClass(row[0], 'reduceFont');
                }else{
                    $A.util.removeClass(container, 'bigtable');
                    $A.util.addClass(row[0], 'reduceFont');
                }               
                component.set("v.toggleFilter", !toggle);
            },
            
            navToRecord: function(component, event, helper) {
             var navService = component.find("navService");
            var tabledata = event.target.closest('.nav').dataset;
                console.log(recId);
            var recId = tabledata.record;
                console.log(recId);
            var pageReference = {
                type: 'standard__recordPage',
                attributes: {
                    recordId: recId,
                    actionName:'view'
                }
        		};
            event.preventDefault();
        	navService.navigate(pageReference);
        	},
            
            
})