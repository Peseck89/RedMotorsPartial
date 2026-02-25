({
    doInit: function(component, event, helper) {
        // Llama al método helper para obtener el valor de IsAsesor__c
        helper.fetchUserIsAsesor(component);
    },

    handleNewRecord: function(component, event, helper) {
        // Verifica la condición aquí
        var isAsesor = component.get("v.isAsesor");
        
        if(isAsesor === true){
            // Si IsAsesor__c es verdadero, mostrar un mensaje
            alert("El asesor está activo.");
        } else {
            // Si IsAsesor__c es falso, crear un caso
            var createRecordEvent = $A.get("e.force:createRecord");
            createRecordEvent.setParams({"entityApiName": "Case"}); // Cambia con el objeto que deseas crear
            createRecordEvent.fire();
        }
    }
})