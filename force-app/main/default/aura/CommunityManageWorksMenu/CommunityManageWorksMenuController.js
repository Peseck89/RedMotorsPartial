({
  irUrlCaso: function (component, event, helper) {
    var newUrl = "/s/communitymanageworks?id=500Ei00000E7qoDIAR";
    window.location.replace(newUrl);
  },

  doInit: function (component, event, helper) {
    var action = component.get("c.getCases");
    //action.setParams({ casoId: component.get("v.caseId") });

    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var cases = response.getReturnValue();
        component.set("v.cases", cases);
        helper.renderCases(component, cases); // Llama al helper para renderizar los casos
      }
      // Manejo de errores si es necesario
    });
    $A.enqueueAction(action);

    var actionQuotes = component.get("c.getQuotes");
    actionQuotes.setCallback(this, function (response) {
        var state = response.getState();
        if (state === "SUCCESS") {
            var quotes = response.getReturnValue();
            component.set("v.quotes", quotes);
            helper.renderQuotes(component, quotes); // Llama al helper para renderizar los quotes
        }
        // Manejo de errores si es necesario
    });
    $A.enqueueAction(actionQuotes);

    var actionUsername = component.get("c.obtenerDatosUsuario");
    actionUsername.setCallback(this, function (response) {
      var state = response.getState();
      console.log("state");
      console.log(state);
      if (state === "SUCCESS") {
        var storeResponse = response.getReturnValue();
        console.log(storeResponse);
        component.set("v.nombreUser", storeResponse[0].FirstName);
        component.set("v.apellidoUser", storeResponse[0].LastName);
        var nombre = storeResponse[0].FirstName
        var apellido = storeResponse[0].LastName
        var nombreCompleto = nombre + " " + apellido
        component.set("v.userName", nombreCompleto);
      } else {
        console.log("error");
        console.log(response);
        console.log(response.getError()[0].message);
      }
    });
    $A.enqueueAction(actionUsername);

    var marcaUrlAnt = component.get("v.marcaSelected");
    var urlParams = {};
    var url = decodeURIComponent(window.location.search.substring(1));
    var params = url.split('?');
    
    for (var i = 0; i < params.length; i++) {
        var param = params[i].split('=');
        var paramName = param[0];
        var paramValue = param[1];
        
        urlParams[paramName] = paramValue;
    }
    var servicioUrl = String(urlParams.servicio).split('&')[0];
    if(servicioUrl != null && servicioUrl !== 'undefined'){
      if(marcaUrlAnt != servicioUrl){

        component.set("v.marcaSelected", servicioUrl);
      }
    }

  },

  showMenu: function (component, event, helper) {
    document.getElementById("barMenu").style.display = "none";
    document.getElementById("overlayMenu").style.display = "block";
    document.getElementById("layout-menu").style.transform = "none";
  },

  hideMenu: function (component, event, helper) {
    document.getElementById("barMenu").style.display = "";
    document.getElementById("overlayMenu").style.display = "none";
    document.getElementById("layout-menu").style.transform =
      "translate3d(-100%, 0, 0)";
  },

  mostrarCambiarMarca: function(component, event, helper) {
    component.set("v.isModalChangeMarca", true); //document.getElementById('verifyCalendarButton').style.display = 'none';
  },

  cerrarCambiarMarca: function(component, event, helper) {
    component.set("v.isModalChangeMarca", false); //document.getElementById('verifyCalendarButton').style.display = 'none';
  },

  handleOnChangeSelectedMarca: function(component, event, helper){
    //var marcaSelected = document.getElementById("checkMarcas").get("v.value");
    var marcaSelected = event.getParam("value");
    component.set("v.marcaSelected", marcaSelected);


    //marcaSelected es la marca pick
    var marcaUrlAnt = component.get("v.marcaUrl");
    if( marcaSelected != marcaUrlAnt ){
      window.location.replace('/s/communitymanageworksmenu?servicio=' + marcaSelected )
    }


    
    component.set("v.optionsService", '');
    var action = component.get("c.getSetupInformation");
    var marcaSelec = component.get("v.marcaSelected").toString();
    
    action.setParams({
      "marcaSel": marcaSelec
    });
    action.setCallback(this, function(response) {
      var state = response.getState();
      
      if (state === "SUCCESS") {
        var storeResponse = response.getReturnValue();
        helper.convertListValuesForDropdownList(component, event, helper, storeResponse[2]);
        //helper.setEventsInformation(component, event, helper, storeResponse[1]);
        //helper.noServiceInformation = storeResponse[3];
        helper.operatingHoursList = storeResponse[4];
        component.set("v.userInfo", storeResponse[0]);
        component.set("v.userName", storeResponse[0].Name);
        component.set("v.userPhone", storeResponse[0].Contact.Phone);
        component.set("v.userEmail", storeResponse[0].Contact.Email);
        console.log('corre conexion 1');
      } else {
        console.log("error");
        console.log(response);
      }

    });
    $A.enqueueAction(action);



    var action2 = component.get("c.getMarcasConfig");
    action2.setParams({
      "marcaSel": marcaSelec
    });
    action2.setCallback(this, function(response) {
      var state = response.getState();
      console.log(response);
      console.log(state);
      if (state === "SUCCESS") {
        var result = response.getReturnValue();
        console.log("From server" + result);
        var storeResponse = response.getReturnValue();
        console.log(storeResponse[1]);
        helper.convertListForDropMarca(component, event, helper, storeResponse);
        console.log('corre conexion 2');
      }else{
        var errors = response.getError();
        if (errors) {
          if (errors[0] && errors[0].message) {
            console.log("Error message: " + errors[0].message);
          }
        }
      }
    });
    $A.enqueueAction(action2);



    console.log('paso');
  },

  handleAceptarMarca: function(component, event, helper){
    console.log('entro');
    
    //let eventsOnSelectedDate = helper.loadDayAvailability(formattedDate, globalEventObj);
    var marcaSelec = component.get("v.marcaSelected").toString();
    console.log(marcaSelec);
    var action = component.get("c.getMarcasConfig");
    action.setParams({
      "marcaSel": marcaSelec
    });
    action.setCallback(this, function(response) {
      var state = response.getState();
      console.log(response);
      console.log(state);
      if (state === "SUCCESS") {
        var result = response.getReturnValue();
        console.log("From server" + result);
        var storeResponse = response.getReturnValue();
        console.log(storeResponse[1]);
        helper.convertListForDropMarca(component, event, helper, storeResponse);
        component.set("v.isModalChangeMarca", false); 
        console.log('corre conexion 2');
      }else{
        var errors = response.getError();
        if (errors) {
          if (errors[0] && errors[0].message) {
            console.log("Error message: " + errors[0].message);
          }
        }
      }
    });
    $A.enqueueAction(action);
    
    var defaultOptions = "[{label: a ,value: 'option1' },{label: b , value: 'option2'}]";
    //location.reload();
  },

  openSoporte: function(component, event, helper) {

    component.set("v.isModalOpenSoporte", true);
  },
  closeSoporte: function(component, event, helper) {

    component.set("v.isModalOpenSoporte", false);
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
        component.set("v.isModalNewCase", false);
        alert("Caso creado con exito.");
        // var storeResponse = response.getReturnValue();  
        console.log('caso creado');      

      } else {
        console.log("Error al crear caso consulta");
        console.log(response.getError());
      }

    });
    $A.enqueueAction(action);
  },

  closeModelCase: function(component, event, helper) {
    // Set isModalOpen attribute to false  
    component.set("v.isModalNewCase", false);
  },

  mostrarTerminos: function(component, event, helper) {
    document.getElementById("terminosYcondiciones").style.display = "";
  },

  closeModalVehiculos: function(component, event, helper) {
    document.getElementById("vehiculosYcorreos").style.display = "none";
  },

  closeModalTerminos: function(component, event, helper) {
    document.getElementById("terminosYcondiciones").style.display = "none";
    var term = component.get("c.setTerminosYCondi");
    term.setCallback(this, function (response) {
      var state = response.getState();
      console.log('respuesta terminos ' + state);
      if (state === "SUCCESS") {
        var storeResponse = response.getReturnValue();
        console.log(storeResponse);
        if (!storeResponse) {
          document.getElementById("terminosYcondiciones").style.display = "";
          
        }
      }
    });
    $A.enqueueAction(term);
    document.getElementById("vehiculosYcorreos").style.display = "";
    document.getElementById("terminosYcondiciones").style.display = "none";
  },
  closeModalConfirmacion: function(component, event, helper){
    component.set("v.isModalOpenConfirmation", false);
  },
  setVisible: function(component, event, helper){
    
    var check = component.find("boxPack");
    var buttonCmp = component.find("btnAceptar");

    // Set the 'disabled' attribute based on the checkbox value
    buttonCmp.set("v.disabled", false);
    check.set("v.disabled", true);
  }
});