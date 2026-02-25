({
	doInit : function(component, event, helper) {
        var recordId = component.get("v.recordId");
         var action = component.get("c.getImageFromAsset");
        action.setParams({
        	"caseId": recordId
    	});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.imagenTipo", response.getReturnValue());
                var tipo = response.getReturnValue();        
                switch(tipo) {
                    case 'Auto':
                         component.set("v.pdfVisualforce", "CaseChecklistPDFBeta");
                        break;
                    case 'Moto':
                         component.set("v.pdfVisualforce", "ChecklistMotosPDFBeta");
                        break;
                    case 'Mula':
                         component.set("v.pdfVisualforce", "ChecklistMulaPDF");
                        break;
                    case 'Cuadra':
                         component.set("v.pdfVisualforce", "ChecklistCuadraPDF");
                        break;
                    default:
                        break;
                }
            } else {
                component.set("v.imagenTipo", "Auto");
                component.set("v.pdfVisualforce", "CaseChecklistPDFBeta");
                console.error("Error al obtener la imagen del perfil: ", response.getError());
            }
        });
        $A.enqueueAction(action);
		
	}
})