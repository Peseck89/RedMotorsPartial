({
    doInit: function(component, event, helper){
        const flow = component.find("flowData");
        flow.startFlow("Busca_Cedula_Cliente");
    }
});