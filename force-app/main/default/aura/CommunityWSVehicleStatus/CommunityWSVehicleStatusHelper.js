({
    initializeSteps: function(component) {
        
        var estadoActual = component.get("v.estadoActual");
        console.log('===============estadoActual');
        console.log(estadoActual);
        var steps = component.get("v.steps");
        var activeIndex = steps.indexOf(estadoActual);
        component.set("v.activeIndex", activeIndex);

        var stepWrappers = steps.map(function(step, index) {
            var stepClass = '';
            if (index < activeIndex) {
                stepClass = 'slds-progress__item slds-is-completed';
            } else if (index === activeIndex) {
                stepClass = 'slds-progress__item slds-is-active';
            } else {
                stepClass = 'slds-progress__item';
            }

            var tooltipPosition = 'position:absolute;top:-50px;left:calc(' + (index / (steps.length - 1) * 100) + '% + 5px);transform:translateX(-50%)';
            return {
                step: step,
                stepClass: stepClass,
                tooltipPosition: tooltipPosition
            };
        });

        component.set("v.stepWrappers", stepWrappers);
    },


    fetchCurrentStage : function(component, stages) {
        var action = component.get("c.obtenerPaso");
        action.setParams({ casoId: component.get("v.caseId") });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var currentStage = response.getReturnValue();
                console.log(currentStage);
                // Set the class for each stage
                stages.forEach(function(stage) {
                    if (stage.Case_Stage__c === currentStage) {
                        stage.class = 'actual-tl';
                        component.set("v.estadoActual", stage.Nombre_Mostrar__c);
                    } else if (stage.Stage_Order__c < stages.find(s => s.Case_Stage__c === currentStage).Stage_Order__c) {
                        stage.class = 'active-tl';
                    } else {
                        stage.class = '';
                    }
                });

                component.set("v.stages", stages);
                console.log('============v.stages===================');
                console.log(stages);
            } else {
                console.error('Error retrieving current stage: ', response.getError());
            }
        });

        $A.enqueueAction(action);
    }

})