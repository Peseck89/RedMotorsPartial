({
  doInit: function (component, event, helper) {
    var recordId = component.get("v.recordId");
    var action = component.get("c.getValidacionCase");
    action.setParams({ caseId: recordId });

    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var resultado = response.getReturnValue();

        console.log("Valores validados:");
        console.log("direccionIncomplete: ", resultado.direccionIncomplete);
        console.log("kilometrajeIncomplete: ", resultado.kilometrajeIncomplete);
        console.log("infoInComplete: ", resultado.infoInComplete);

        // Asignar valores directamente sin lógica adicional
        component.set("v.infoInComplete", resultado.infoInComplete);
        component.set("v.direccionIncomplete", resultado.direccionIncomplete);
        component.set("v.kilometrajeIncomplete", resultado.kilometrajeIncomplete);

        // Solo inicializar el componente si todo está completo
        if (
          resultado.infoInComplete === false &&
          resultado.direccionIncomplete === false &&
          resultado.kilometrajeIncomplete === false
        ) {
          helper.doInit(component, event, helper);
        }
      } else {
        console.error("Error en validación del caso:", response.getError());
        // Mostrar mensaje de error general
        component.set("v.direccionIncomplete", true);
      }
    });

    $A.enqueueAction(action);
  },
});