({
  loadQuoteLineItems: function (component, quoteId) {
    console.log("=== INICIANDO loadQuoteLineItems ===");
    console.log("quoteId:", quoteId);

    var action = component.get("c.getQuoteLineItemsGrouped");
    action.setParams({
      quoteId: quoteId,
    });

    action.setCallback(this, function (response) {
      console.log("Respuesta de getQuoteLineItemsGrouped recibida");
      var state = response.getState();
      console.log("Estado:", state);

      if (state === "SUCCESS") {
        console.log("Procesando items de la cotización...");
        var storeResponse = response.getReturnValue();
        console.log("Items recibidos:", JSON.stringify(storeResponse));

        // Procesar items de la cotización
        this.processItems(component, storeResponse);
      } else if (state === "ERROR") {
        console.error(
          "Error en getQuoteLineItemsGrouped:",
          response.getError()
        );
      }
    });

    console.log("Encolando acción getQuoteLineItemsGrouped...");
    $A.enqueueAction(action);
  },

  processItems: function (component, itemsData) {
    console.log("=== INICIANDO processItems ===");
    console.log("Datos a procesar:", itemsData);

    // ... lógica de procesamiento con logs
    console.log("=== FINALIZANDO processItems ===");
  },

  getContactFromAccount: function (component, accountId) {
    console.log("Buscando contacto para Account:", accountId);

    var action = component.get("c.getContactFromAccount");
    action.setParams({
      accountId: accountId,
    });

    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var contact = response.getReturnValue();
        if (contact) {
          console.log("Contacto encontrado:", contact);
          component.set("v.contacto", contact.Name);
          component.set("v.correo", contact.Email);
        }
      }
    });
    $A.enqueueAction(action);
  },

  renderTrabajos: function (component, bloques, containerId) {
    var container = document.getElementById(containerId);
    if (!container) return;

    container.innerHTML = "";

    if (!bloques || bloques.length === 0) {
      var emptyMessage = document.createElement("div");
      emptyMessage.className = "THIS empty-message";
      emptyMessage.innerText = "No hay trabajos en esta categoría";
      container.appendChild(emptyMessage);
      return;
    }

    // Obtener el estado actual de las tareas
    var action = component.get("c.getEstadoTareas");
    action.setParams({
      quoteId: component.get("v.quoteId"),
    });

    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var estadoTareas = response.getReturnValue();
        this.renderTrabajosConCheckboxes(
          component,
          bloques,
          containerId,
          estadoTareas
        );
      }
    });
    $A.enqueueAction(action);
  },

  renderTrabajosConCheckboxes: function (
    component,
    bloques,
    containerId,
    estadoTareas
  ) {
    var self = this;
    var container = document.getElementById(containerId);

    if (!container) {
      console.error("Container not found:", containerId);
      return;
    }

    container.innerHTML = "";

    if (!bloques || bloques.length === 0) {
      var emptyMessage = document.createElement("div");
      emptyMessage.className = "empty-message";
      emptyMessage.innerText = "No hay trabajos en esta categoría";
      container.appendChild(emptyMessage);
      return;
    }

    console.log("Bloques a renderizar:", bloques);

    var todosQLIsMap = component.get("v.todosQuoteLineItems") || {};

    bloques.forEach(function (bloque) {
      var bloqueDiv = document.createElement("div");
      bloqueDiv.className = "bloque-tarea";
      bloqueDiv.style =
        "margin-bottom: 20px; padding: 15px; border: 1px solid #ddd; border-radius: 8px;";

      var estadoActual = estadoTareas[bloque.nombreTarea] || "Pendiente";
      var estaAprobada = estadoActual === "Aprobado";
      var estaRechazada = estadoActual === "Rechazado";

      var headerDiv = document.createElement("div");
      headerDiv.style =
        "display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px;";

      var nombreDiv = document.createElement("div");
      nombreDiv.style = "flex-grow: 1;";
      nombreDiv.innerHTML =
        '<h3 style="margin: 0; color: #2c3e50; font-size: 16px;">' +
        (bloque.tareaName || bloque.nombreTarea) +
        "</h3>";

      var toggleContainer = document.createElement("div");
      toggleContainer.style = "display: flex; align-items: center; gap: 10px;";

      var estadoSpan = document.createElement("span");
      estadoSpan.style =
        "padding: 4px 8px; border-radius: 12px; font-size: 12px; font-weight: bold;";
      estadoSpan.style.backgroundColor = estaAprobada
        ? "#4CAF50"
        : estaRechazada
        ? "#f44336"
        : "#ff9800";
      estadoSpan.style.color = "white";
      estadoSpan.textContent = estadoActual;

      var qliIds = [];
      if (bloque.items && bloque.items.length > 0) {
        bloque.items.forEach(function (item) {
          if (item.Id) {
            // Usar JSON.parse(JSON.stringify()) para evitar Proxies
            var cleanItemId = JSON.parse(JSON.stringify(item.Id));
            qliIds.push(cleanItemId);

            todosQLIsMap[cleanItemId] = {
              tarea: bloque.nombreTarea,
              nombre: bloque.tareaName,
              amount: item.TotalPrice.toFixed(2) || 0,
              category: bloque.prioridad,
              description:
                (item.Product2 && item.Product2.Name) ||
                item.Description ||
                item.BMW_Alias__c ||
                "Sin descripción",
            };
          }
        });
      }

      var newToggleElement = document.createElement("label");
      newToggleElement.className = "switch";
      var newToggleInElement = document.createElement("input");
      newToggleInElement.type = "checkbox"; // Toggle switch
      newToggleElement.appendChild(newToggleInElement);
      var newToggleSpElement = document.createElement("span");
      newToggleSpElement.className = "slider round";
      newToggleElement.appendChild(newToggleSpElement);

      newToggleInElement.checked = estaAprobada;
      newToggleInElement.disabled = estaAprobada;
      newToggleInElement.setAttribute("data-tarea", bloque.nombreTarea);
      newToggleInElement.setAttribute("nombre-tarea", bloque.tareaName);
      newToggleInElement.setAttribute("data-qli-ids", JSON.stringify(qliIds));

      newToggleInElement.addEventListener("change", function (event) {
        var isChecked = event.target.checked;
        var qliIdsStr = event.target.getAttribute("data-qli-ids");

        // Convertir a array normal IMMEDIATAMENTE
        var qliIds = qliIdsStr
          ? JSON.parse(JSON.stringify(JSON.parse(qliIdsStr)))
          : [];

        var tareaName = event.target.getAttribute("data-tarea");
        var tareaLabel = event.target.getAttribute("nombre-tarea");

        console.log("=== TOGGLE CHANGE ===");
        console.log("Tarea:", tareaName);
        console.log("Tarea nombre:", tareaLabel);
        console.log("Checked:", isChecked);
        console.log("QLI IDs (RAW):", qliIdsStr);
        console.log("QLI IDs (CLEAN):", qliIds);
        console.log("Cantidad de QLIs:", qliIds.length);

        event.target.style.backgroundColor = isChecked ? "#0070d2" : "#dddbdd";
        self.manejarToggleChange(component, qliIds, tareaName, isChecked);
      });

      // TOGGLE NATIVO no en uso
      var toggle = document.createElement("input");
      toggle.type = "checkbox";
      toggle.className = "slds-toggle";
      toggle.checked = estaAprobada;
      toggle.disabled = estaAprobada;
      toggle.setAttribute("data-tarea", bloque.nombreTarea);
      toggle.setAttribute("nombre-tarea", bloque.tareaName);
      toggle.setAttribute("data-qli-ids", JSON.stringify(qliIds));
      toggle.style =
        "width: 40px; height: 20px; position: relative; appearance: none; background: #dddbdd; border-radius: 20px; cursor: pointer; transition: background 0.3s;";
      toggle.style.backgroundColor = estaAprobada ? "#d3d3d3" : "#dddbdd";

      toggle.addEventListener("change", function (event) {
        var isChecked = event.target.checked;
        var qliIdsStr = event.target.getAttribute("data-qli-ids");

        // Convertir a array normal IMMEDIATAMENTE
        var qliIds = qliIdsStr
          ? JSON.parse(JSON.stringify(JSON.parse(qliIdsStr)))
          : [];

        var tareaName = event.target.getAttribute("data-tarea");
        var tareaLabel = event.target.getAttribute("nombre-tarea");

        console.log("=== TOGGLE CHANGE ===");
        console.log("Tarea:", tareaName);
        console.log("Tarea nombre:", tareaLabel);
        console.log("Checked:", isChecked);
        console.log("QLI IDs (RAW):", qliIdsStr);
        console.log("QLI IDs (CLEAN):", qliIds);
        console.log("Cantidad de QLIs:", qliIds.length);

        event.target.style.backgroundColor = isChecked ? "#0070d2" : "#dddbdd";
        self.manejarToggleChange(component, qliIds, tareaName, isChecked);
      });

      toggleContainer.appendChild(newToggleElement);
      // toggleContainer.appendChild(toggle);
      toggleContainer.appendChild(estadoSpan);
      headerDiv.appendChild(nombreDiv);
      headerDiv.appendChild(toggleContainer);
      bloqueDiv.appendChild(headerDiv);

      // Tabla de items (MANTÉN TU CÓDIGO ACTUAL)
      if (bloque.items && bloque.items.length > 0) {
        var tableContainer = document.createElement("div");
        tableContainer.className = "THIS table-container";

        // Header de la tabla
        var tableHeader = document.createElement("div");
        tableHeader.className = "THIS table-header";
        tableHeader.innerHTML =
          '<div class="THIS col-desc">Descripción</div>' +
          '<div class="THIS col-qty">Cantidad</div>' +
          '<div class="THIS col-amount">Monto</div>';
        tableContainer.appendChild(tableHeader);

        // Filas de items
        var itemsContainer = document.createElement("div");
        itemsContainer.className = "THIS items-container";

        // Agrupar items por tipo (Materiales primero, luego MO)
        var materiales = [];
        var manosDeObra = [];
        var otros = [];

        bloque.items.forEach(function (item) {
          if (item.BMW_TipoDeArticulo__c === "Materiales") {
            materiales.push(item);
          } else if (item.BMW_TipoDeArticulo__c === "Mano de Obra") {
            manosDeObra.push(item);
          } else {
            otros.push(item);
          }
        });

        // Función para crear filas (MANTENIENDO EXACTAMENTE EL CÓDIGO ACTUAL)
        function crearFilas(items, tipo) {
          if (items.length === 0) return;

          items.forEach(function (item) {
            var itemRow = document.createElement("div");
            itemRow.className = "THIS item-row";
            itemRow.setAttribute("data-quotelineitem-id", item.Id || "");

            var descripcion =
              (item.Product2 && item.Product2.Name) ||
              item.Description ||
              item.BMW_Alias__c ||
              "Sin descripción";

            itemRow.innerHTML =
              '<div class="THIS col-desc">' +
              '   <span class="THIS item-desc" title="' +
              descripcion +
              '">' +
              descripcion +
              "</span>" +
              '   <span class="THIS item-type">' +
              (item.BMW_TipoDeArticulo__c || tipo || "N/A") +
              "</span>" +
              "</div>" +
              '<div class="THIS col-qty">' +
              (item.Quantity || 0) +
              ' <span class="THIS unit-label">' +
              (item.BMW_TipoDeArticulo__c === "Materiales"
                ? "Ud"
                : item.BMW_TipoDeArticulo__c === "Mano de Obra"
                ? "Horas"
                : "Ud") +
              "</span>" +
              "</div>" +
              '<div class="THIS col-amount">' +
              component.get("v.currencyIso") +
              " " +
              (item.TotalPrice
                ? item.TotalPrice.toLocaleString("es-US", {
                    minimumFractionDigits: 2,
                    maximumFractionDigits: 2,
                  })
                : "0.00") +
              "</div>";

            itemsContainer.appendChild(itemRow);
          });
        }

        // Crear filas por tipo
        crearFilas(materiales, "Materiales");
        crearFilas(manosDeObra, "Mano de Obra");
        crearFilas(otros, "Otros");

        tableContainer.appendChild(itemsContainer);

        // Fila final - Total de la tarea
        var totalRow = document.createElement("div");
        totalRow.className = "THIS total-row";
        totalRow.innerHTML =
          '<div class="THIS total-label">Total:</div>' +
          '<div class="THIS total-amount">' +
          component.get("v.currencyIso") +
          " " +
          (bloque.totalTarea
            ? bloque.totalTarea.toLocaleString("es-US", {
                minimumFractionDigits: 2,
                maximumFractionDigits: 2,
              })
            : "0.00") +
          "</div>";

        tableContainer.appendChild(totalRow);
        bloqueDiv.appendChild(tableContainer);
      }

      container.appendChild(bloqueDiv);
    });

    console.log(
      "DEBUG todosQLIsMap (primeros 20 keys):",
      Object.keys(todosQLIsMap).slice(0, 20)
    );
    console.log(
      "DEBUG todosQLIsMap full sample:",
      JSON.stringify(
        Object.keys(todosQLIsMap)
          .slice(0, 20)
          .reduce(function (acc, k) {
            acc[k] = todosQLIsMap[k];
            return acc;
          }, {})
      )
    );

    component.set("v.todosQuoteLineItems", todosQLIsMap);
  },

  manejarToggleChange: function (component, qliIds, tareaName, isChecked) {
    var current = component.get("v.quoteLineItemsSeleccionados") || [];
    // clonar y normalizar
    var selSet = new Set(
      (current || []).map(function (i) {
        return String(i);
      })
    );

    // asegurar que qliIds es array normal:
    if (typeof qliIds === "string") {
      try {
        qliIds = JSON.parse(qliIds);
      } catch (e) {
        qliIds = qliIds.split(",");
      }
    }
    qliIds = Array.isArray(qliIds) ? qliIds : [qliIds];

    qliIds.forEach(function (id) {
      id = String(id);
      if (isChecked) selSet.add(id);
      else selSet.delete(id);
    });

    var newSelected = Array.from(selSet);
    component.set("v.quoteLineItemsSeleccionados", newSelected);

    // actualizar contadores usando el mapa existente
    this.actualizarContadores(
      component,
      component.get("v.todosQuoteLineItems") || {},
      newSelected
    );
  },

  actualizarContadores: function (
    component,
    todosQLIsMap,
    quoteLineItemsSeleccionados
  ) {
    console.log("=== ACTUALIZANDO CONTADORES (AGRUPO POR TAREA) ===");

    // Normalize inputs
    todosQLIsMap = todosQLIsMap || {};
    quoteLineItemsSeleccionados = Array.isArray(quoteLineItemsSeleccionados)
      ? quoteLineItemsSeleccionados
      : [];

    var tareasPorCategoria = {
      Necesario: {}, // taskName -> { total: number, items: [ {id, description, amount} ] }
      Recomendado: {},
      Sugerido: {},
    };

    var totalAprobado = 0;
    var totalNecesario = 0;
    var totalRecomendado = 0;
    var totalSugerido = 0;

    quoteLineItemsSeleccionados.forEach(function (qliId) {
      var qliInfo = todosQLIsMap[qliId];
      if (!qliInfo) return;

      // Normalizar categoría (mapear variantes)
      var cat = (qliInfo.category || "").toString();
      var categoria = "Sugerido";
      if (
        cat.toLowerCase().indexOf("necesario") !== -1 ||
        cat.toLowerCase().indexOf("urgente") !== -1
      ) {
        categoria = "Necesario";
      } else if (cat.toLowerCase().indexOf("recomend") !== -1) {
        categoria = "Recomendado";
      } else {
        categoria = "Sugerido";
      }

      var tareaName = qliInfo.nombre || qliInfo.tarea || "Sin nombre";
      if (!tareasPorCategoria[categoria][tareaName]) {
        tareasPorCategoria[categoria][tareaName] = { total: 0, items: [] };
      }

      var amount = Number(qliInfo.amount || 0);
      tareasPorCategoria[categoria][tareaName].total += amount;
      tareasPorCategoria[categoria][tareaName].items.push({
        id: qliId,
        description: qliInfo.description || qliInfo.tarea || "Sin descripción",
        amount: amount,
      });

      // Totales por tipo
      totalAprobado += amount;
      if (categoria === "Necesario") totalNecesario += amount;
      else if (categoria === "Recomendado") totalRecomendado += amount;
      else if (categoria === "Sugerido") totalSugerido += amount;
    });

    // Convertir a arrays ordenados para iterar en markup
    function mapToArray(obj) {
      var arr = [];
      for (var t in obj) {
        if (obj.hasOwnProperty(t)) {
          arr.push({
            tarea: t,
            total: obj[t].total.toLocaleString("es-US", {
              minimumFractionDigits: 0,
              maximumFractionDigits: 2,
            }),
            items: obj[t].items,
          });
        }
      }
      // opcional: ordenar por total descendente
      arr.sort(function (a, b) {
        return b.total - a.total;
      });
      return arr;
    }

    var approvedNecesarioTasks = mapToArray(tareasPorCategoria.Necesario);
    var approvedRecomendadoTasks = mapToArray(tareasPorCategoria.Recomendado);
    var approvedSugeridoTasks = mapToArray(tareasPorCategoria.Sugerido);

    console.log(
      "Aprobaciones totales:",
      approvedNecesarioTasks.length,
      approvedRecomendadoTasks.length,
      approvedSugeridoTasks.length
    );

    console.log(
      "DEBUG approvedNecesarioTasks (post-group):",
      JSON.stringify(approvedNecesarioTasks, null, 2)
    );
    console.log(
      "DEBUG approvedRecomendadoTasks (post-group):",
      JSON.stringify(approvedRecomendadoTasks, null, 2)
    );
    console.log(
      "DEBUG approvedSugeridoTasks (post-group):",
      JSON.stringify(approvedSugeridoTasks, null, 2)
    );

    console.log("=== FIN ACTUALIZANDO CONTADORES AGRUPADOS ===");

    // También mantener arrays simples de nombres por compatibilidad
    var approvedNecesarioNames = approvedNecesarioTasks.map(function (t) {
      return t.tarea;
    });
    var approvedRecomendadoNames = approvedRecomendadoTasks.map(function (t) {
      return t.tarea;
    });
    var approvedSugeridoNames = approvedSugeridoTasks.map(function (t) {
      return t.tarea;
    });

    // Setear atributos
    component.set("v.approvedNecesario", approvedNecesarioNames);
    component.set("v.approvedRecomendado", approvedRecomendadoNames);
    component.set("v.approvedSugerido", approvedSugeridoNames);

    component.set("v.approvedNecesarioTasks", approvedNecesarioTasks);
    component.set("v.approvedRecomendadoTasks", approvedRecomendadoTasks);
    component.set("v.approvedSugeridoTasks", approvedSugeridoTasks);

    component.set(
      "v.totalNecesarioFinal",
      totalNecesario.toLocaleString("es-US", {
        minimumFractionDigits: 0,
        maximumFractionDigits: 2,
      })
    );

    component.set(
      "v.totalRecomendadoFinal",
      totalRecomendado.toLocaleString("es-US", {
        minimumFractionDigits: 0,
        maximumFractionDigits: 2,
      })
    );

    component.set(
      "v.totalSugeridoFinal",
      totalSugerido.toLocaleString("es-US", {
        minimumFractionDigits: 0,
        maximumFractionDigits: 2,
      })
    );

    // component.set("v.cantidadAprobado", totalAprobado.toFixed(2));
    component.set(
      "v.cantidadAprobado",
      totalAprobado.toLocaleString("es-US", {
        minimumFractionDigits: 0,
        maximumFractionDigits: 2,
      })
    );
    // component.set("v.cantidadVerdes", quoteLineItemsSeleccionados.length);
    component.set(
      "v.cantidadVerdes",
      approvedNecesarioTasks.length +
        approvedRecomendadoTasks.length +
        approvedSugeridoTasks.length
    );
    component.set("v.disabledButon", quoteLineItemsSeleccionados.length === 0);
  },

  aprobarTareasSeleccionadas: function (component) {
    var self = this;
    component.set("v.isLoading", true);

    var currentSeleccionados =
      component.get("v.quoteLineItemsSeleccionados") || [];
    // Asegurar array normal y strings limpios
    var quoteLineItemsSeleccionados = JSON.parse(
      JSON.stringify(currentSeleccionados)
    )
      .map(function (id) {
        return String(id).trim();
      })
      .filter(function (id) {
        return id && id !== "undefined" && id !== "null";
      });

    if (quoteLineItemsSeleccionados.length === 0) {
      component.set("v.isLoading", false);
      var toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
        title: "Información",
        message: "No hay items seleccionados para aprobar",
        type: "info",
      });
      toastEvent.fire();
      return;
    }

    var emailData = this.prepararDatosParaEmail(component);

    var action = component.get("c.aprobarRechazarQuoteLineItems");
    action.setParams({
      quoteId: component.get("v.quoteId"),
      quoteLineItemIds: quoteLineItemsSeleccionados,
      estado: "Aprobado",
      aprobado: true,
    });

    action.setCallback(this, function (response) {
      component.set("v.isLoading", false);
      var state = response.getState();
      if (state === "SUCCESS") {
        var result = response.getReturnValue();

        self.enviarEmailTareas(component, emailData);

        // feedback
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          title: "¡Éxito!",
          message: result.message,
          type: "success",
        });
        toastEvent.fire();

        // limpiar selección y refrescar vista
        component.set("v.quoteLineItemsSeleccionados", []);
        setTimeout(function () {
          component.set("v.isModalInsc", false);
          window.location.reload();
        }, 1000);
      } else {
        console.error("Error al aprobar tareas:", response.getError());
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          title: "Error",
          message: "Error al aprobar los items",
          type: "error",
        });
        toastEvent.fire();
      }
    });

    $A.enqueueAction(action);
  },

  prepararDatosParaEmail: function (component) {
    return {
      tareasNecesario: component.get("v.approvedNecesarioTasks") || [],
      tareasRecomendado: component.get("v.approvedRecomendadoTasks") || [],
      tareasSugerido: component.get("v.approvedSugeridoTasks") || [],
      currencyIso: component.get("v.currencyIso") || "USD",
    };
  },

  enviarEmailTareas: function (component, emailData) {
    var action = component.get("c.enviarEmailTareasAprobadas");
    action.setParams({
      quoteId: component.get("v.quoteId"),
      tareasNecesarioJSON: JSON.stringify(emailData.tareasNecesario || []),
      tareasRecomendadoJSON: JSON.stringify(emailData.tareasRecomendado || []),
      tareasSugeridoJSON: JSON.stringify(emailData.tareasSugerido || []),
      currencyIso: emailData.currencyIso,
    });

    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        console.log("Email enviado exitosamente");
      } else {
        console.error("Error al enviar email:", response.getError());
        // No mostrar error al usuario para no interrumpir el flujo principal
      }
    });

    $A.enqueueAction(action);
  },
});