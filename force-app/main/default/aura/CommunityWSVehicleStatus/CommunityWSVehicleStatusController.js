({
    doInit: function(component, event, helper) {
        //Obtener el casoId
    
        var urlParams = {};
        var url = decodeURIComponent(window.location.search.substring(1));
        var params = url.split('?');
        console.log(params);
        for (var i = 0; i < params.length; i++) {
            var param = params[i].split('=');
            var paramName = param[0];
            var paramValue = param[1];
            
            urlParams[paramName] = paramValue;
        }
        console.log(urlParams);
        var servicioUrl = String(urlParams.id);
        if(servicioUrl != null && servicioUrl !== 'undefined'){
          component.set("v.caseId", servicioUrl);      
        }
        console.log('==================servicioUrl==================');
        console.log(servicioUrl);     
        
        var action2 = component.get("c.obtenerStages");
        action2.setParams({
            casoId: servicioUrl
        });
        action2.setCallback(this, function (response) {
            var state = response.getState();
            console.log('Actual 1', state);
            
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                console.log('==============DATA==============');
                console.log(storeResponse);
                var stages = response.getReturnValue();
                
                // Fetch current stage
                helper.fetchCurrentStage(component, stages);
                
            }else{

                console.error('Error retrieving stages: ' );
                console.error(response.getError());
            }
        });
        $A.enqueueAction(action2);

    }
})