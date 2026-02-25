({
  init: function (component, event, helper) {
    var action = component.get("c.obtenerDatosUsuario");
    //action.setParams({'userId':userId});
    action.setCallback(this, function (response) {
      var state = response.getState();
      console.log("state");
      console.log(state);
      if (state === "SUCCESS") {
        var storeResponse = response.getReturnValue();
        console.log(storeResponse);
        component.set("v.nombreUser", storeResponse[0].FirstName);
        component.set("v.apellidoUser", storeResponse[0].LastName);
        component.set("v.telefonoUser", storeResponse[0].MobilePhone);
        component.set("v.correoUser", storeResponse[0].Email);
        component.set("v.userName", storeResponse[0].Username);
        var nombre = storeResponse[0].FirstName
        var apellido = storeResponse[0].LastName
        var nombreCompleto = nombre + " " + apellido
        component.set("v.userNameH", nombreCompleto);
        //component.set("v.contraUser",storeResponse[0].FirstName);
      } else {
        console.log("error");
        console.log(response);
        console.log(response.getError()[0].message);
      }
    });
    $A.enqueueAction(action);
    //location.reload();
    //window.location.replace('/');

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
  handleNombre: function (component, event, helper) {
    var nombreValue = event.getParam("value");
    component.set("v.nombreUser", nombreValue);
  },

  handleApellido: function (component, event, helper) {
    var apellidoValue = event.getParam("value");
    component.set("v.apellidoUser", apellidoValue);
  },

  handleTelefono: function (component, event, helper) {
    var telefonoValue1 = event.getParam("value");
    component.set("v.telefonoUser", telefonoValue1);
  },

  handleEmail: function (component, event, helper) {
    console.log("prueba");
    console.log("==================prueba==================");

    console.log(event.getParam("value"));
    var emailValue1 = event.getParam("value");
    component.set("v.correoUser", emailValue1);
    component.set("v.cambioCorreo", false);
  },

  handleContra: function (component, event, helper) {
    console.log("entro 0");
    var contraValue1 = event.getParam("value");
    console.log("entro");

    component.set("v.contraUser", contraValue1);
  },
  actualizarInfo: function (component, event, helper) {
    var showSpinner = true;
    component.set("v.showSpinner", showSpinner);

    var nombreUser = component.get("v.nombreUser");
    console.log(nombreUser);
    var apellidoUser = component.get("v.apellidoUser");
    console.log(apellidoUser);
    var telefonoUser = component.get("v.telefonoUser");
    console.log(telefonoUser);

    var phoneNumberPattern = /^\+506\d{8}$/;
    if (!phoneNumberPattern.test(telefonoUser)) {
      alert(
        "Número de teléfono no válido. Debe empezar por +506 y tener una longitud total de 10 dígitos."
      );
      var showSpinner = false;
      component.set("v.showSpinner", showSpinner);
      return;
    }

    var correoUser = component.get("v.correoUser");
    // var emailPattern = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
    var emailPattern = /^(?!.*\.\.)(?!.*\.$)(?!^\.)([a-zA-Z0-9._%+-]{1,63}[a-zA-Z0-9%+-])@([a-zA-Z0-9](?:[a-zA-Z0-9-]{0,251}[a-zA-Z0-9])?\.[a-zA-Z]{2,63})$/;

    if (!emailPattern.test(correoUser)) {
      alert("Ingrese un correo valido.");
      var showSpinner = false;
      component.set("v.showSpinner", showSpinner);
      return;
    }
    console.log(correoUser);

    var contraUser = component.get("v.contraUser");

    var actionValidarCorreo = component.get("c.revisarCorreo");
    actionValidarCorreo.setParams({ correo: correoUser });
    actionValidarCorreo.setCallback(this, function (response) {
      var state = response.getState();
      console.log("state");
      console.log(state);
      if (state === "SUCCESS") {
        var storeResponse = response.getReturnValue();
        console.log(storeResponse);
        console.log("storeResponse valor correo");
        var seModifico = component.get("v.cambioCorreo");
        var userName = component.get("v.userName");
        if (storeResponse == false || seModifico != false) {
          if (seModifico == false) {
            alert(
              "La actualización de este correo será relacionada con notificaciones de Red Motors, el acceso a BMW Service se mantendrá con la cuenta de correo: " +
                userName
            );
            var showSpinner = false;
            component.set("v.showSpinner", showSpinner);
          }

          var action = component.get("c.actualizarDatosUsuario");
          action.setParams({
            firstName: nombreUser,
            lastName: apellidoUser,
            telefono: telefonoUser,
            correo: correoUser,
            // contra: contraUser,
          });
          action.setCallback(this, function (response) {
            var state = response.getState();
            console.log("state");
            console.log(state);
            if (state === "SUCCESS") {
              // Metodo antiguo que da problemas de cache
              // var storeResponse = response.getReturnValue();
              // console.log(storeResponse);
              // alert("Actualización de datos correcta");
              // window.location.reload(true);
              // location.reload();

              var storeResponse = response.getReturnValue();
              console.log(storeResponse);
              alert("Actualización de datos correcta");

              // Actualizar los datos en el componente sin recargar la página
              component.set("v.nombreUser", nombreUser);
              component.set("v.apellidoUser", apellidoUser);
              component.set("v.telefonoUser", telefonoUser);
              component.set("v.correoUser", correoUser);

              // Ocultar el spinner
              component.set("v.showSpinner", false);
            } else {
              console.log("error");
              console.log(response);
              console.log(response.getError()[0].message);
              var showSpinner = false;
              component.set("v.showSpinner", showSpinner);
            }
          });
          $A.enqueueAction(action);
        } else {
          alert("El correo ya existe en la organización.");
          var showSpinner = false;
          component.set("v.showSpinner", showSpinner);
        }
      } else {
        console.log("error");
        console.log(response);
        console.log(response.getError()[0].message);
        var showSpinner = false;
        component.set("v.showSpinner", showSpinner);
      }
    });
    $A.enqueueAction(actionValidarCorreo);

    console.log("termina validar");
  },

  cambiarContraU: function (component, event, helper) {
    var contraUser = component.get("v.contraUser");
    var contraUser1 = component.get("v.contraUser1");
    console.log(contraUser);
    if (contraUser != null && contraUser != undefined && contraUser != "") {
      console.log("entro validar contra");
      // Define validation criteria
      var minLength = 8;
      var maxLength = 20;
      var hasUpperCase = /[A-Z]/;
      var hasLowerCase = /[a-z]/;
      var hasNumbers = /[0-9]/;
      var hasSpecialCharacters = /[!@#\$%\^&\*\(\),\.\?\:\{\}\|\<\>]/;
      console.log("entro 1");
      // Check password length
      if (contraUser.length < minLength || contraUser.length > maxLength) {
        alert(
          "La contraseña debe tener entre " +
            minLength +
            " y " +
            maxLength +
            " caracteres."
        );
        return;
      }
      console.log("entro 2");
      // Check for at least one uppercase letter
      if (!hasUpperCase.test(contraUser)) {
        alert("La contraseña debe contener al menos una letra mayúscula.");
        return;
      }
      console.log("entro 3");
      // Check for at least one lowercase letter
      if (!hasLowerCase.test(contraUser)) {
        alert("La contraseña debe contener al menos una letra minúscula.");
        return;
      }
      console.log("entro 4");
      // Check for at least one number
      if (!hasNumbers.test(contraUser)) {
        alert("La contraseña debe contener al menos un número.");
        return;
      }
      console.log("entro 5");
      // Check for at least one special character
      if (!hasSpecialCharacters.test(contraUser)) {
        alert(
          'La contraseña debe contener al menos un carácter especial (!@#$%^&*(),.?":{}|<>).'
        );
        return;
      }
      console.log("entro 6");
      // If all validations pass, set the value
    }
    if (contraUser == contraUser1) {
      var action = component.get("c.cambiarContra");
      action.setParams({ contra: contraUser });
      action.setCallback(this, function (response) {
        var state = response.getState();
        console.log("state");
        console.log(state);
        if (state === "SUCCESS") {
          var storeResponse = response.getReturnValue();
          console.log(storeResponse);

          if (storeResponse == true) {
            alert("Proceso correcto.");
            location.reload();
          } else {
            alert("Ha ocurrido un error.");
          }

          //this.displayHistoryData(component, event, helper, storeResponse);
        } else {
          console.log("error");
          console.log(response);
          console.log(response.getError()[0].message);
        }
      });
      $A.enqueueAction(action);
    } else {
      alert("Las contraseñas no coinciden");
      return;
    }
  },

  showMenu: function (component, event, helper) {
    document.getElementById("barMenu").style.display = "none";
    document.getElementById("overlayMenu").style.display = "block";
    document.getElementById("layout-menu").style.transform = "none";
    console.log("Open");
  },

  hideMenu: function (component, event, helper) {
    document.getElementById("barMenu").style.display = "";
    document.getElementById("overlayMenu").style.display = "none";
    document.getElementById("layout-menu").style.transform =
      "translate3d(-100%, 0, 0)";
    console.log("Close");
  },

  openModal: function (component, event, helper) {
    component.set("v.isModalInsc", true);
  },

  closeModal: function (component, event, helper) {
    component.set("v.isModalInsc", false);
  },
  mostrarCambiarMarca: function (component, event, helper) {
    component.set("v.isModalChangeMarca", true); //document.getElementById('verifyCalendarButton').style.display = 'none';
  },

  cerrarCambiarMarca: function (component, event, helper) {
    component.set("v.isModalChangeMarca", false); //document.getElementById('verifyCalendarButton').style.display = 'none';
  },

  handleOnChangeSelectedMarca: function (component, event, helper) {
    //var marcaSelected = document.getElementById("checkMarcas").get("v.value");
    var marcaSelected = event.getParam("value");
    component.set("v.marcaSelected", marcaSelected);

    //marcaSelected es la marca pick
    var marcaUrlAnt = component.get("v.marcaUrl");
    if (marcaSelected != marcaUrlAnt) {
      window.location.replace(
        "/s/communityprofile?servicio=" + marcaSelected
      );
    }

    component.set("v.optionsService", "");
    var action = component.get("c.getSetupInformation");
    var marcaSelec = component.get("v.marcaSelected").toString();

    action.setParams({
      marcaSel: marcaSelec,
    });
    action.setCallback(this, function (response) {
      var state = response.getState();

      if (state === "SUCCESS") {
        var storeResponse = response.getReturnValue();
        helper.convertListValuesForDropdownList(
          component,
          event,
          helper,
          storeResponse[2]
        );
        //helper.setEventsInformation(component, event, helper, storeResponse[1]);
        //helper.noServiceInformation = storeResponse[3];
        helper.operatingHoursList = storeResponse[4];
        component.set("v.userInfo", storeResponse[0]);
        component.set("v.userName", storeResponse[0].Name);
        component.set("v.userPhone", storeResponse[0].Contact.Phone);
        component.set("v.userEmail", storeResponse[0].Contact.Email);
        console.log("corre conexion 1");
      } else {
        console.log("error");
        console.log(response);
      }
    });
    $A.enqueueAction(action);

    var action2 = component.get("c.getMarcasConfig");
    action2.setParams({
      marcaSel: marcaSelec,
    });
    action2.setCallback(this, function (response) {
      var state = response.getState();
      console.log(response);
      console.log(state);
      if (state === "SUCCESS") {
        var result = response.getReturnValue();
        console.log("From server" + result);
        var storeResponse = response.getReturnValue();
        console.log(storeResponse[1]);
        helper.convertListForDropMarca(component, event, helper, storeResponse);
        console.log("corre conexion 2");
      } else {
        var errors = response.getError();
        if (errors) {
          if (errors[0] && errors[0].message) {
            console.log("Error message: " + errors[0].message);
          }
        }
      }
    });
    $A.enqueueAction(action2);

    console.log("paso");
  },

  handleAceptarMarca: function (component, event, helper) {
    console.log("entro");

    //let eventsOnSelectedDate = helper.loadDayAvailability(formattedDate, globalEventObj);
    var marcaSelec = component.get("v.marcaSelected").toString();
    console.log(marcaSelec);
    var action = component.get("c.getMarcasConfig");
    action.setParams({
      marcaSel: marcaSelec,
    });
    action.setCallback(this, function (response) {
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
        console.log("corre conexion 2");
      } else {
        var errors = response.getError();
        if (errors) {
          if (errors[0] && errors[0].message) {
            console.log("Error message: " + errors[0].message);
          }
        }
      }
    });
    $A.enqueueAction(action);

    var defaultOptions =
      "[{label: a ,value: 'option1' },{label: b , value: 'option2'}]";
    //location.reload();
  },

  openModalCase: function (component, event, helper) {
    component.set("v.isModalNewCase", true);
  },

  createCase: function (component, event, helper) {
    var descripcionMensaje = component.get("v.descripcionCase");
    var action = component.get("c.createCaseComunidad");
    action.setParams({
      mensaje: descripcionMensaje,
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        component.set("v.isModalNewCase", false);
        alert("Caso creado con exito.");
        // var storeResponse = response.getReturnValue();
        console.log("caso creado");
      } else {
        console.log("Error al crear el caso de consulta");
        console.log(response.getError());
      }
    });
    $A.enqueueAction(action);
  },

  closeModelCase: function (component, event, helper) {
    // Set isModalOpen attribute to false
    component.set("v.isModalNewCase", false);
  },

  callApi: function (component, event, helper) {
    // Call the Apex controller method
    var action = component.get("c.callExternalApi");
    console.log("mierda");
    console.log("hola");
    console.log("hola1");
    console.log("hola2");
    console.log("hola3");
    console.log("hola4");
    // Set up the callback
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        // Set the response to the component attribute
        console.log(response.getReturnValue());
        //component.set("v.apiResponse", response.getReturnValue());
        //component.set("v.error", null);
      } else {
        // Handle any errors
        var errors = response.getError();
        if (errors && errors[0] && errors[0].message) {
          console.log(errors[0].message);
        } else {
          console.log("Unknown error");
        }
      }
    });

    // Enqueue the action
    $A.enqueueAction(action);
  },

  openSoporte: function(component, event, helper) {

    component.set("v.isModalOpenSoporte", true);
  },
  closeSoporte: function(component, event, helper) {

    component.set("v.isModalOpenSoporte", false);
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