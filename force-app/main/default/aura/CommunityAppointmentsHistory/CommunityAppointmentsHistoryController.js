({
  init: function (component, event, helper) {
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
        var nombre = storeResponse[0].FirstName;
        var apellido = storeResponse[0].LastName;
        var nombreCompleto = nombre + " " + apellido;
        component.set("v.userName", nombreCompleto);
      } else {
        console.log("error");
        console.log(response);
        console.log(response.getError()[0].message);
      }
    });
    $A.enqueueAction(actionUsername);

    let urlString = window.location.href;
    console.log(urlString);
    var modifiedUrl = urlString.replace(/&marca&marca=/, "&marca=");
    console.log(modifiedUrl);
    let paramString = modifiedUrl.split("?")[1].split("=");
    let paramMarca = modifiedUrl.split("&")[1].split("=");
    let userId = paramString[1];
    let marcaSel = paramMarca[1];
    component.set("v.userId", userId);
    component.set("v.marcaSelected", marcaSel);

    var baseURL = "/s/communitycancelappointments";

    var url = baseURL + "?id=" + userId + "&marca=" + marcaSel;

    component.set("v.url", url);
    helper.getUserHistorial(component, event, helper, userId);
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
        // var storeResponse = response.getReturnValue();
        console.log("caso creado");
      } else {
        console.log("error");
        console.log(response.getError());
      }
    });
    $A.enqueueAction(action);
  },
  closeModelCase: function (component, event, helper) {
    // Set isModalOpen attribute to false
    component.set("v.isModalNewCase", false);
  },
  openSoporte: function (component, event, helper) {
    component.set("v.isModalOpenSoporte", true);
  },
  closeSoporte: function (component, event, helper) {
    component.set("v.isModalOpenSoporte", false);
  },
  mostrarTerminos: function (component, event, helper) {
    document.getElementById("terminosYcondiciones").style.display = "";
  },
  closeModalTerminos: function (component, event, helper) {
    document.getElementById("terminosYcondiciones").style.display = "none";
  },
});