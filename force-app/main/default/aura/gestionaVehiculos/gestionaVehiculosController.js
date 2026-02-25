({
	init: function (component, event, helper) {
        let urlString = window.location.href;
        console.log(urlString);
        var modifiedUrl = urlString.replace(/&marca&marca=/, '&marca=');
        console.log(modifiedUrl);
        let paramString = modifiedUrl.split('?')[1].split('=');
        console.log('aqui0');
        let paramMarca = modifiedUrl.split('&')[1].split('=');
        console.log('aqui00');
       	let userId = paramString[1];
        console.log('aqui000');
        let marcaSel = paramMarca[1];
        component.set("v.userId", userId);
        component.set("v.marcaSelected", marcaSel);
        console.log('aqui');
        var baseURL = '/s/communitycancelappointments';
        console.log('aqui2');
        //var url = baseURL + '?id=' + userId + '&marca=' + marcaSel;

        console.log('aqui3');
        //component.set("v.url", url);
        console.log('aqui4');
        helper.getUserHistorial(component, event, helper, userId);
    },showMenu : function(component, event, helper) {
        document.getElementById("barMenu").style.display = "none";
        document.getElementById("overlayMenu").style.display = "block";
        document.getElementById("layout-menu").style.transform = "none";
      },
    
      hideMenu: function(component, event, helper){
        document.getElementById("barMenu").style.display = "";
        document.getElementById("overlayMenu").style.display = "none";
        document.getElementById("layout-menu").style.transform = "translate3d(-100%, 0, 0)";
      },
      openModalCase: function(component, event, helper) {
        component.set("v.isModalNewCase", true);
      },
    
      createCase: function(component, event, helper) {
    
        var descripcionMensaje = component.get('v.descripcionCase');
        var action = component.get("c.createCaseComunidad");
        action.setParams({      
          "mensaje" : descripcionMensaje  
        });
        action.setCallback(this, function(response) {
          var state = response.getState();
          if (state === "SUCCESS") {
            // var storeResponse = response.getReturnValue();  
            console.log('caso creado');      
    
          } else {
            console.log("error");
            console.log(response.getError());
          }
    
        });
        $A.enqueueAction(action);
      },
      closeModelCase: function(component, event, helper) {
        // Set isModalOpen attribute to false  
        component.set("v.isModalNewCase", false);
      },    
      openSoporte: function(component, event, helper) {

        component.set("v.isModalOpenSoporte", true);
      },
      closeSoporte: function(component, event, helper) {
    
        component.set("v.isModalOpenSoporte", false);
      },

      openAlta: function(component, event, helper) {
        document.getElementById("modalAlta").style.display = "";
        
      },
      asignaTipo:function(component, event, helper){
        var selectedOptionValue = event.getParam("value");
        component.set("v.vehiculoTipo", selectedOptionValue);
      },
      asignarNuevo:function(component, event, helper){
        component.set("v.isLoading", true);
        var matricula = component.get('v.matricula');
        
        var vehiculoTipo = component.get('v.vehiculoTipo');

        if( matricula != null  ){
          helper.requestCreacion(component,event);
          setTimeout(() => {
            component.set("v.isLoading", false);
            document.getElementById("modalAlta").style.display = "none";
            document.getElementById("modalConfirm").style.display = "";
          }, 4000); 
        }else{
          //helper.requestCreacion(component,event);
          component.set("v.isLoading", false);
          
        }
        
      },
      mostrarTerminos: function(component, event, helper) {
        document.getElementById("terminosYcondiciones").style.display = "";
      },
      closeModalTerminos: function(component, event, helper) {
        document.getElementById("terminosYcondiciones").style.display = "none";
      },
      reload: function() {
 
        location.reload();
      },
      removerVehiculo : function(component, event, helper) {
        component.set("v.isLoading", true);
        helper.requestEliminacion(component,event);
        setTimeout(() => {
          component.set("v.isLoading", false);
          
          document.getElementById("modalMens").style.display = "none";
          document.getElementById("modalConfirm").style.display = "";
        }, 4000);        
       
        //location.reload();
        //window.location.replace('/');
      },
})