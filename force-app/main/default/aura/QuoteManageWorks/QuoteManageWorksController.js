({
  doInit: function (component, event, helper) {
    console.log("=== INICIANDO doInit ===");

    var urlParams = {};
    var url = decodeURIComponent(window.location.search.substring(1));
    var params = url.split("&");

    console.log("URL completa:", window.location.href);
    console.log("Parámetros URL:", params);

    for (var i = 0; i < params.length; i++) {
      var param = params[i].split("=");
      var paramName = param[0];
      var paramValue = param[1];
      urlParams[paramName] = paramValue;
      console.log("Parámetro:", paramName, "=", paramValue);
    }

    var quoteId = String(urlParams.quoteId);
    var marcaUrl = String(urlParams.marca);

    console.log("quoteId extraído:", quoteId);
    console.log("marcaUrl extraída:", marcaUrl);

    if (quoteId != null && quoteId !== "undefined" && quoteId !== "null") {
      component.set("v.quoteId", quoteId);
      component.set("v.marcaSelected", marcaUrl);
      console.log("Valores establecidos en componente");
    } else {
      console.log("ERROR: quoteId no válido:", quoteId);
      return;
    }

    component.set("v.totalNecesario", 0);
    component.set("v.totalRecomendado", 0);
    component.set("v.totalSugerido", 0);
    component.set("v.totalNecesarioFinal", 0);
    component.set("v.totalRecomendadoFinal", 0);
    component.set("v.totalSugeridoFinal", 0);
    component.set("v.cantidadAprobado", 0);
    component.set("v.cantidadPresupuesto", 0);
    component.set("v.cantidadVerdes", 0);
    component.set("v.cantidadTotal", 0);
    component.set("v.cantidadNecesario", 0);
    component.set("v.cantidadSugerido", 0);
    component.set("v.cantidadRecomendado", 0);

    component.set("v.disabledButon", true);

    component.set("v.todosNombres", []);
    component.set("v.approvedNecesario", []);
    component.set("v.approvedRecomendado", []);
    component.set("v.approvedSugerido", []);

    console.log("Llamando a método Apex quoteInfo...");
    var action = component.get("c.quoteInfo");
    action.setParams({
      quoteId: quoteId,
    });

    action.setCallback(this, function (response) {
      console.log("Respuesta recibida de Apex");
      var state = response.getState();
      console.log("Estado de la respuesta:", state);

      if (state === "SUCCESS") {
        console.log("Respuesta SUCCESS - Procesando datos...");
        var result = response.getReturnValue();
        console.log("Datos recibidos:", JSON.stringify(result));

        var quoteData = result.quote;
        var assetData = result.asset;

        console.log("Quote data:", quoteData);
        console.log("Asset data:", assetData);

        if (quoteData) {
          console.log("Estableciendo datos del Quote...");

          component.set(
            "v.propietario",
            quoteData.Account ? quoteData.Account.Name : "N/A"
          );
          component.set(
            "v.cedula",
            quoteData.Account ? quoteData.Account.Cedula__c : "N/A"
          );
          component.set(
            "v.telefono",
            quoteData.Account ? quoteData.Account.Phone : "N/A"
          );

          if (quoteData.Contact) {
            component.set("v.contacto", quoteData.Contact.Name || "N/A");
            component.set("v.correo", quoteData.Contact.Email || "N/A");
          } else {
            console.log("Contacto no disponible en el Quote");
            component.set("v.contacto", "N/A");
            component.set("v.correo", "N/A");

            if (quoteData.AccountId) {
              helper.getContactFromAccount(component, quoteData.AccountId);
            }
          }

          component.set("v.numOrden", quoteData.QuoteNumber || "N/A");

          if (quoteData.GrandTotal) {
            component.set(
              "v.cantidadPresupuesto",
              quoteData.GrandTotal.toLocaleString("es-US", {
                minimumFractionDigits: 0,
                maximumFractionDigits: 2,
              })
            );
            component.set("v.currencyIso", quoteData.CurrencyIsoCode || "USD");
          } else {
            component.set("v.cantidadPresupuesto", "0.00");
          }
          console.log("Datos del Quote establecidos");
        }

        if (assetData) {
          console.log("Estableciendo datos del Asset...");
          component.set("v.placa", assetData.numeroDePlaca__c || "");
          component.set("v.marca", assetData.marca__c || "");
          component.set("v.modelo", assetData.modelo__c || "");
          component.set("v.anio", assetData.Anio__c || "");
          component.set("v.vin", assetData.NumeroDeChasis__c || "");
          component.set("v.kilometraje", assetData.Kilometros__c || "");
          component.set("v.combustible", assetData.Combustible__c || "");
          component.set("v.tipoVehiculo", assetData.Tipo_de_veh_culo__c || "");
          console.log("Datos del Asset establecidos");
        } else {
          console.log("No se encontró Asset, usando placa del Quote");
          component.set("v.placa", quoteData.Placa__c || "");
        }

        console.log("Llamando a método Apex getQuoteTrabajosGrouped...");
        var action2 = component.get("c.getQuoteTrabajosGrouped");
        action2.setParams({
          quoteId: quoteId,
        });

        action2.setCallback(this, function (response2) {
          var state2 = response2.getState();
          if (state2 === "SUCCESS") {
            var result2 = response2.getReturnValue();
            console.log(
              "Bloques de tareas recibidos:",
              JSON.stringify(result2)
            );

            component.set("v.bloquesNecesario", result2.urgentes || []);
            component.set("v.bloquesRecomendado", result2.proximos || []);
            component.set("v.bloquesSugerido", result2.sugeridos || []);
            component.set(
              "v.totalNecesario",
              result2.totalUrgente.toLocaleString("es-US", {
                minimumFractionDigits: 0,
                maximumFractionDigits: 2,
              })
            );
            component.set(
              "v.totalSugerido",
              result2.totalProximo.toLocaleString("es-US", {
                minimumFractionDigits: 0,
                maximumFractionDigits: 2,
              })
            );
            component.set(
              "v.totalRecomendado",
              result2.totalSugerido.toLocaleString("es-US", {
                minimumFractionDigits: 0,
                maximumFractionDigits: 2,
              })
            );
            component.set("v.cantidadNecesario", result2.countUrgente || 0);
            component.set("v.cantidadSugerido", result2.countProximo || 0);
            component.set("v.cantidadRecomendado", result2.countSugerido || 0);
            component.set(
              "v.cantidadTotal",
              result2.countUrgente +
                result2.countProximo +
                result2.countSugerido || 0
            );

            // --- AQUÍ VA EL CÓDIGO NUEVO ---
            // Inicializar los mapas después de obtener los bloques
            component.set("v.todosQuoteLineItems", {});
            component.set("v.quoteLineItemsSeleccionados", []);
            // --- FIN DEL CÓDIGO NUEVO ---

            helper.renderTrabajos(component, result2.urgentes, "referenceId-3");
            helper.renderTrabajos(component, result2.proximos, "referenceId-2");
            helper.renderTrabajos(
              component,
              result2.sugeridos,
              "referenceId-1"
            );
          } else if (state2 === "ERROR") {
            console.error(
              "Error al obtener bloques de tareas:",
              response2.getError()
            );
          }
        });

        $A.enqueueAction(action2);
      } else if (state === "ERROR") {
        console.log("ERROR en respuesta Apex");
        var errors = response.getError();
        console.error("Errores:", errors);

        if (errors && errors[0] && errors[0].message) {
          console.error("Mensaje de error:", errors[0].message);
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            title: "Error",
            message: "Error al cargar los datos: " + errors[0].message,
            type: "error",
          });
          toastEvent.fire();
        }
      } else if (state === "INCOMPLETE") {
        console.log("Respuesta INCOMPLETE");
      }
    });

    console.log("Encolando acción Apex...");
    $A.enqueueAction(action);
    console.log("Acción encolada");

    $A.get("e.force:refreshView").fire();
  },

  handleButtonClick: function (component, event, helper) {
    component.set("v.isLoading", true);

    helper.aprobarTareasSeleccionadas(component);

    component.set("v.isLoading", false);
  },

  mostrarCambiarMarca: function (component, event, helper) {
    component.set("v.isModalChangeMarca", true);
  },

  cerrarCambiarMarca: function (component, event, helper) {
    component.set("v.isModalChangeMarca", false);
  },

  toggleAccordion: function (component, event, helper) {
    var isOpen = component.get("v.isOpen");
    component.set("v.isOpen", !isOpen);

    var button = event.getSource();
    button.set("v.ariaExpanded", !isOpen);
    console.log("Pressed");
  },

  toggleAccordion2: function (component, event, helper) {
    var isOpen2 = component.get("v.isOpen2");
    component.set("v.isOpen2", !isOpen2);

    var button = event.getSource();
    button.set("v.ariaExpanded", !isOpen2);
    console.log("Pressed");
  },

  toggleAccordion3: function (component, event, helper) {
    var isOpen3 = component.get("v.isOpen3");
    component.set("v.isOpen3", !isOpen3);

    var button = event.getSource();
    button.set("v.ariaExpanded", !isOpen3);
    console.log("Pressed");
  },

  toggleAccordion4: function (component, event, helper) {
    var isOpen4 = component.get("v.isOpen4");
    component.set("v.isOpen4", !isOpen4);

    var button = event.getSource();
    button.set("v.ariaExpanded", !isOpen4);
    console.log("Pressed");
  },

  // openShowInsc: function (component, event, helper) {
  //   component.set("v.isModalInsc", true);
  // },

  openShowInsc: function (component, event, helper) {
    // Forzar recalculo y limpieza de arrays antes de mostrar el modal
    var todosQLIsMap = component.get("v.todosQuoteLineItems") || {};
    var currentSeleccionados =
      component.get("v.quoteLineItemsSeleccionados") || [];
    // Normalizar a array simple
    var quoteLineItemsSeleccionados = Array.isArray(currentSeleccionados)
      ? JSON.parse(JSON.stringify(currentSeleccionados))
      : [];

    // Llamamos al helper para recalcular contadores (usa la misma función que ya tienes)
    helper.actualizarContadores(
      component,
      todosQLIsMap,
      quoteLineItemsSeleccionados
    );

    // Abrir modal
    component.set("v.isModalInsc", true);
  },

  closeShowInsc: function (component, event, helper) {
    component.set("v.isModalInsc", false);
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

  mostrarCambiarMarca: function (component, event, helper) {
    component.set("v.isModalChangeMarca", true);
  },

  cerrarCambiarMarca: function (component, event, helper) {
    component.set("v.isModalChangeMarca", false);
  },

  handleOnChangeSelectedMarca: function (component, event, helper) {
    var marcaSelected = event.getParam("value");
    component.set("v.marcaSelected", marcaSelected);

    var marcaUrlAnt = component.get("v.marcaUrl");

    var servicio = component.get("v.quoteId");
    if (marcaSelected != marcaUrlAnt) {
      window.location.replace(
        "/s/quotemanageworks?quoteId=" + servicio + "&marca=" + marcaSelected
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
        console.log("caso creado");
      } else {
        console.log("Error al crear el caso de consulta");
        console.log(response.getError());
      }
    });
    $A.enqueueAction(action);
  },

  closeModelCase: function (component, event, helper) {
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

  closeModalVehiculos: function (component, event, helper) {
    document.getElementById("vehiculosYcorreos").style.display = "none";
  },

  closeModalTerminos: function (component, event, helper) {
    document.getElementById("terminosYcondiciones").style.display = "none";
    var term = component.get("c.setTerminosYCondi");
    term.setCallback(this, function (response) {
      var state = response.getState();
      console.log("respuesta terminos " + state);
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
  closeModalConfirmacion: function (component, event, helper) {
    component.set("v.isModalOpenConfirmation", false);
  },
  setVisible: function (component, event, helper) {
    var check = component.find("boxPack");
    var buttonCmp = component.find("btnAceptar");

    buttonCmp.set("v.disabled", false);
    check.set("v.disabled", true);
  },
});