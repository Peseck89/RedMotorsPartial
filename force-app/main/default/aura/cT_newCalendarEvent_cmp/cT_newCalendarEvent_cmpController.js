({
    init : function(component, event, helper) {
        helper.getModelosVehiculos(component, event, helper);
        //var flow = component.find("Reserva_de_Citas_v2");
        //flow.startFlow("citaCalendario1");
        console.log('Actions');
        console.log(component.get("v.sObjectName"));
        console.log(component.get("v.ActivityDateTime"));
       
    },
    doSomething : function(component, event, helper) {

        var userId = component.get("v.selectedValue");
        var fechaSel = component.get("v.selectedDate");
        if(userId == null || fechaSel == null){
            window.alert('Por favor llene ambos campos');

        }else{
            helper.getUserHistorial(component, event, helper, userId,fechaSel );
        }
        
    },
    clean : function(component, event, helper) {

        component.set("v.selectedValue",'');
        component.set("v.selectedDate",'');
        var tbody = document.getElementById("dataRows");
        while (tbody.firstChild) {
            tbody.removeChild(tbody.firstChild);
          }
        //helper.getUserHistorial(component, event, helper, userId);
    },
    handleStatusChange : function(component, event, helper) {

        component.set("v.selectedValue",'test');
        //helper.getUserHistorial(component, event, helper, userId);
    },
})