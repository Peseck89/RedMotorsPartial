({
  doInit: function (component, event, helper) {
    // Obtener el casoId desde la URL
    var urlParams = {};
    var url = decodeURIComponent(window.location.search.substring(1));
    var params = url.split("?");
    console.log(params);
    for (var i = 0; i < params.length; i++) {
      var param = params[i].split("=");
      var paramName = param[0];
      var paramValue = param[1];

      urlParams[paramName] = paramValue;
    }
    console.log('URL a la carga del componente', urlParams.marca);
    var servicioUrl = String(urlParams.id);
    var marcaUrl = String(urlParams.marca)
    if (servicioUrl != null && servicioUrl !== "undefined") {
      component.set("v.caseId", servicioUrl);
      component.set("v.marcaSelected", marcaUrl)
    }
    console.log("==================servicioUrl==================");
    console.log(servicioUrl);

    var action = component.get("c.obtenerDatosUsuario");
    action.setCallback(this, function (response) {
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
    $A.enqueueAction(action);

    // Inicializar variables de totales para cada categoría
    var totalNecesario = 0;
    var totalRecomendado = 0;
    var totalSugerido = 0;

    var totalNecesarioFinal = 0;
    var totalRecomendadoFinal = 0;
    var totalSugeridoFinal = 0;

    var totalAmount = 0;
    var totalVerdes = 0;
    var totalPresupuesto = 0; // Inicializar totalPresupuesto
    var totalGrupos = 0; // Inicializar totalGrupos

    component.set("v.disabledButon", true);

    // Inicializar lista de nombres
    var todosNombres = [];

    // Inicializar contadores
    var cantidadRecomendado = 0;
    var cantidadSugerido = 0;
    var cantidadNecesario = 0;
    var approvedNecesario = [];
    var approvedRecomendado = [];
    var approvedSugerido = [];

    var actionPrueba = component.get(
      "c.getWorkOrderLineItemsGroupedByTipoTrabajo"
    );
    actionPrueba.setParams({
      casoId: servicioUrl,
    });
    actionPrueba.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        console.log("=============actionPrueba=============");
        var storeResponse = response.getReturnValue();
        if (storeResponse != "") {
          console.log(storeResponse);
          var keys = Object.keys(storeResponse);
          console.log("Number of groups:", keys.length);

          // Iterar sobre todos los elementos y agrupar por tiposDeTrabajo__c y Categor_a_de_presupuesto__c
          for (var key in storeResponse) {
            if (storeResponse.hasOwnProperty(key)) {
              var items = storeResponse[key];

              // Agrupar más elementos por su Categor_a_de_presupuesto__c
              var groupedByCategory = {};

              items.forEach(function (item) {
                var category =
                  item.categoradepresupuesto;
                if (!groupedByCategory[category]) {
                  groupedByCategory[category] = [];
                }
                groupedByCategory[category].push(item);
              });

              // Procesar cada grupo de categoría por separado
              for (var category in groupedByCategory) {
                if (groupedByCategory.hasOwnProperty(category)) {
                  var data = groupedByCategory[category];
                  console.log(category);
                  var totalPrice = 0; // Inicializa el total de precio por categoría

                  data.forEach(function (item) {
                    if (item.tipodecargo != "Perro") {
                      totalPrice += parseFloat(item.totalFacturar2);
                    }
                    if(item.tipodecargo == "Garantía" || item.estadoAporbacionEnService == 'Aprobado'){
                      totalAmount += parseFloat(item.totalFacturar2);
                    }
                    // Categorize approved items based on category
                    var itemDetails = {
                      name: item.productoOrAlias,
                      price: item.totalFacturar2,
                      moneda: item.currencyIsoCode,
                      category: category,
                    };
                  });

                  if (category === "Urgente") {
                    totalNecesario += totalPrice;
                    cantidadNecesario += 1;
                  } else if (category === "Sugerido") {
                    totalRecomendado += totalPrice;
                    cantidadRecomendado += 1;
                  } else if (category === "Proximo") {
                    totalSugerido += totalPrice;
                    cantidadSugerido += 1;
                  }

                  // totalGrupos += 1;
                  if(data[0].estadoAporbacionEnService !== 'Aprobado') {
                    totalGrupos += 1;
                  } else {
                    totalGrupos += 0
                  }

                  console.log('Total de puntos pendientes', totalGrupos);
                  console.log('Estado de aprobación', data[0].estadoAporbacionEnService);

                  
                  console.log('================== Estamos aqui =================');
                  // Crear un contenedor para cada combinación de tiposDeTrabajo__c + categoría
                  var divsContainer = document.createElement("div");
                  divsContainer.className = "points-container";

                  // Crear el nuevo contenedor de puntos
                  var newPointsContainerChild = document.createElement("div");
                  newPointsContainerChild.className = "points-container-child";

                  var groupContainer = document.createElement("div");
                  groupContainer.className = "group-container";

                  // Crear un título para cada grupo basado en tiposDeTrabajo__r.Name
                  var groupTitle = document.createElement("h3");
                  groupTitle.innerText = data[0].tiposDeTrabajoName 
                  newPointsContainerChild.appendChild(groupTitle);

                  // Aquí va el boton
                  let isActive = false;
                  console.log('================== Estamos aqui 1 =================');
                  var mediaButton = document.createElement("button");
                  mediaButton.className = "slds-button slds-button_outline-brand btn-cam";
                  mediaButton.id = data[0].tiposDeTrabajoId;
                  mediaButton.setAttribute("data-tipo", data[0].tiposDeTrabajoName)
                  
                  mediaButton.onclick = function () {
                    var buttonId = this.id
                    var tipo = this.dataset.tipo
                    
                    component.set("v.tipoTrabajoNombre", tipo);
                    
                    console.log("ID del boton: ", buttonId);
                    console.log("Tipo del boton: ", tipo);
                    
                    var actionFiles = component.get("c.nestedJsonUrlByTipoTrabajo");
                    console.log("Action Files Object:", actionFiles);
                  
                    actionFiles.setParams({
                      objectId: buttonId,
                    });
                  
                    let currentImageIndex = 0;
                    let galleryItems = []; 
                  
                    actionFiles.setCallback(this, function (response) {
                      var state = response.getState();
                      
                      if (state === "SUCCESS") {
                        var nestedJson = response.getReturnValue();
                        var parsedJson = JSON.parse(nestedJson);
                        
                        var mainWorkContainer = document.getElementById("mainWorkContainer");
                        var subWorkContainer = document.getElementById("subWorkContainer");
                        
                        mainWorkContainer.innerHTML = ""; 
                        subWorkContainer.innerHTML = "";
                        galleryItems = []; 
                        
                        // Función para crear elementos de imagen o video
                        function createMediaElement(file) {
                          let mediaElement;
                          let fileType = file.fileType;
                          
                          if (fileType === "JPG" || fileType === "JPEG" || fileType === "PNG") {
                            mediaElement = document.createElement("img");
                            mediaElement.src = file.url;
                            mediaElement.alt = file.name || "Imagen de trabajo";
                            mediaElement.classList.add("image-item");
                            galleryItems.push({ url: file.url, type: "image" });
                          } else if (fileType === "MP4" || fileType === "MOV") {
                            mediaElement = document.createElement("video");
                            mediaElement.src = file.url;
                            mediaElement.controls = true;
                            mediaElement.width = 280;
                            mediaElement.classList.add("image-item");
                            galleryItems.push({ url: file.url, type: "video" });
                          }
                          
                          mediaElement.onclick = function () {
                            openModal(galleryItems.indexOf(galleryItems.find(i => i.url === file.url)));
                          };
                          
                          return mediaElement;
                        }
                    
                        parsedJson.files.forEach(function (file) {
                          if (["JPG", "JPEG", "PNG", "MP4", "MOV"].includes(file.fileType)) {
                            var mediaElement = createMediaElement(file);
                            mainWorkContainer.appendChild(mediaElement);
                          }
                        });
                    
                        let subWorkGroups = {};
                        parsedJson.subTipoTrabajos.forEach(function (file) {
                          let key = file.relatedObjectId || file.name;
                          
                          if (!subWorkGroups[key]) {
                            subWorkGroups[key] = [];
                          }
                          subWorkGroups[key].push(file);
                        });
                    
                        Object.keys(subWorkGroups).forEach(function (key) {
                          let group = subWorkGroups[key];
                          
                          let subWorkWrapper = document.createElement("div");
                          subWorkWrapper.classList.add("subwork-wrapper");
                        
                          let subWorkTitle = document.createElement("h1");
                          subWorkTitle.style.paddingTop = "20px";
                          subWorkTitle.textContent = group[0].name || "Subtrabajo";
                          subWorkWrapper.appendChild(subWorkTitle);
                        
                          let subWorkSection = document.createElement("div");
                          subWorkSection.classList.add("image-grid");
                        
                          group.forEach(function (file) {
                            if (["JPG", "JPEG", "PNG", "MP4", "MOV"].includes(file.fileType)) {
                              let mediaElement = createMediaElement(file);
                              subWorkSection.appendChild(mediaElement);
                            }
                          });
                        
                          subWorkWrapper.appendChild(subWorkSection);
                        
                          subWorkContainer.appendChild(subWorkWrapper);
                        });
                        
                        component.set("v.loaded", true);
                      } else {
                        console.error("Error in response: ", response.getError());
                      }
                    });
                    

                    $A.enqueueAction(actionFiles);

                    isActive = true;
                    component.set("v.isActive", true);
                  
                    function openModal(index) {
                      currentImageIndex = index;
                      var modal = document.getElementById("galleryModal");
                      var modalImg = document.getElementById("galleryImage");
                      var modalVideo = document.getElementById("galleryVideo");
                  
                      var currentItem = galleryItems[currentImageIndex];
                      modal.style.display = "flex";
                  
                      if (currentItem.type === "image") {
                        modalImg.src = currentItem.url;
                        modalImg.style.display = "block";
                        modalVideo.style.display = "none";
                      } else if (currentItem.type === "video") {
                        modalVideo.src = currentItem.url;
                        modalVideo.style.display = "block";
                        modalImg.style.display = "none";
                      }
                    }
                  
                    document.getElementById("closeModal").onclick = function () {
                      document.getElementById("galleryModal").style.display = "none";
                      document.getElementById("galleryVideo").pause(); 
                    };
                  
                    document.getElementById("prevImage").onclick = function () {
                      currentImageIndex = (currentImageIndex - 1 + galleryItems.length) % galleryItems.length;
                      openModal(currentImageIndex);
                    };
                  
                    document.getElementById("nextImage").onclick = function () {
                      currentImageIndex = (currentImageIndex + 1) % galleryItems.length;
                      openModal(currentImageIndex);
                    };

                  };

                  console.log('================== Estamos aqui 2=================');
                  groupContainer.appendChild(mediaButton);
                  
                  // Crear un elemento <ul> para contener los elementos de la lista
                  var listHeader = document.createElement("div");
                  listHeader.className = "list-header";
                  var listHeaderElements = document.createElement("div");
                  listHeaderElements.className = "list-header-e";

                  var cantTitle = document.createElement("p");
                  cantTitle.innerText = "Cantidad";
                  var monedaTitle = document.createElement("p");
                  monedaTitle.innerText = "Monto";
                  var itemList = document.createElement("ul");
                  itemList.className = "list-container";
                  console.log('================== Estamos aqui 4=================');
                  for (var j = 0; j < data.length; j++) {
                    // Crear el elemento de lista (<li>) para cada WorkOrderLineItem
                    var newLi = document.createElement("li");
                    newLi.className = "list-item";

                    var liContent = document.createElement("div");
                    liContent.className = "second-list-items";

                    // Crear un elemento <p> para el nombre del producto
                    var productElement = document.createElement("p");
                    if(data[j].tipoProducto === "Mano de Obra") {
                      productElement.innerText ="MO" + " " + data[j].productoOrAlias;
                    } else {
                      productElement.innerText =data[j].productoOrAlias;
                    }
                    newLi.appendChild(productElement);

                    newLi.appendChild(liContent);

                    // Crear un elemento <p> para el nombre del tipo de cargo
                    var cargoElement = document.createElement("p");
                    cargoElement.className = "cargo-element";

                    cargoElement.innerText =
                      data[j].tipodecargo;
                    liContent.appendChild(cargoElement);
                    listHeader.appendChild(cargoElement);
                    listHeader.appendChild(listHeaderElements);

                    listHeaderElements.appendChild(cantTitle);
                    listHeaderElements.appendChild(monedaTitle);

                    // Crear un elemento <p> para la cantidad
                    var quantityElement = document.createElement("p");
                    //quantityElement.innerText = "Cantidad: " + data[j].Quantity;
                    if(data[j].tipoProducto === "Mano de Obra") {
                      // quantityElement.innerText = data[j].quantity + " "+ "Horas";
                      quantityElement.innerText = parseFloat(data[j].quantity.toLocaleString("es-US", {minimumFractionDigits: 0,maximumFractionDigits: 2,})) + " "+ "Horas";
                    } else {
                      quantityElement.innerText = data[j].quantity;
                    }
                    quantityElement.className = "quantity-element";
                    liContent.appendChild(quantityElement);

                    // Crear un elemento <label> para el precio
                    var newLabelElement = document.createElement("label");
                    console.log('================== Estamos aqui 5 =================');
                    if (
                      data[j].tipodecargo == "Cliente"
                    ) {

                      component.set(
                        "v.currencyIso",
                        data[j].currencyIsoCode + " "
                      );
                      newLabelElement.innerText =
                        data[j].currencyIsoCode +
                        " " +
                        parseFloat(
                          data[j].totalFacturar2.toLocaleString("es-US", {
                            minimumFractionDigits: 0,
                            maximumFractionDigits: 2,
                          })
                        );                    
                    } else {
                      component.set(
                        "v.currencyIso",
                        data[j].currencyIsoCode + " "
                      );
                      newLabelElement.innerText =
                        data[j].currencyIsoCode +
                        " " +
                        parseFloat(
                          data[j].totalFacturar2.toLocaleString("es-US", {
                            minimumFractionDigits: 0,
                            maximumFractionDigits: 2,
                          })
                        ); 
                    }
                    liContent.appendChild(newLabelElement);
                    console.log('================== Estamos aqui 6 =================');
                    component.set(
                      "v.numOrden",
                      data[j].workOrderNumber
                    );
                    // Append the list item to the <ul> element
                    itemList.appendChild(newLi);
                  }
                  console.log('================== Estamos aqui 7 =================');
                  // Append the item list to the group container

                  // Create a <label> element for the total price
                  var moneda = component.get("v.currencyIso");
                  var totalLabelElement = document.createElement("label");
                  totalLabelElement.className = "total-amount";
                  // totalLabelElement.innerText = "Total: " + moneda + " " + totalPrice.toFixed(2) + "+ IVA";
                  totalLabelElement.innerText =
                    "Total: " +
                    moneda +
                    " " +
                    totalPrice.toLocaleString("es-US", {
                      minimumFractionDigits: 0,
                      maximumFractionDigits: 2,
                    });
                  // groupContainer.appendChild(totalLabelElement);
                  console.log('================== Estamos aqui 8 =================');
                  // Create the toggle switch element
                  var newToggleElement = document.createElement("label");
                  newToggleElement.className = "switch";
                  var newToggleInElement = document.createElement("input");
                  newToggleInElement.type = "checkbox"; // Toggle switch
                  newToggleElement.appendChild(newToggleInElement);
                  var newToggleSpElement = document.createElement("span");
                  newToggleSpElement.className = "slider round";
                  newToggleElement.appendChild(newToggleSpElement);

                  // By default, the toggle is checked and counts towards totals
                  // newToggleInElement.checked = true;
                  newToggleInElement.checked = false;
                  // totalVerdes += 1;
                  // totalAmount += totalPrice;
                  totalPresupuesto += totalPrice; // Include all prices in totalPresupuesto by default

                  // Add product names to todosNombres
                  todosNombres.push(
                    ...data.map(function (item) {
                      return item.productoOrAlias;
                    })
                  );
                  console.log('================== Estamos aqui 9 =================');
                  // Check if the toggle should be disabled based on conditions
                  var isDisabled = false;
                  isDisabled = data.some(function (item) {
                    console.log(item);
                    return (
                      item.aprobador == "Asesor" ||
                      item.tipodecargo != "Cliente" ||
                      item.estadoAporbacionEnService ==
                        "Aprobado"
                    );
                  });
                  console.log(isDisabled);
                  if (isDisabled) {
                    newToggleInElement.disabled = true;
                    // newToggleSpElement.className = "slider round slider-disabled";
                    newToggleSpElement.className = "slider-test";
                  }

                  // console.log("Prueba selccionados: ", totalVerdes);
                  // Logic to update based on toggle state
                  (function (
                    toggleInput,
                    amount,
                    workIds,
                    productNames,
                    category
                  ) {
                    toggleInput.addEventListener(
                      "change",
                      function handleToggle(event) {
                        if (toggleInput.checked) {
                          // Elemento aprobado
                          totalAmount += amount;
                          totalVerdes += 1;

                          // Actualizar totales de acuerdo a la categoría
                          if (category === "Urgente") {
                            totalNecesarioFinal += amount;
                            // Add item back to approvedNecesario when the toggle is checked
                            productNames.forEach(function (productName) {
                              var itemString = productName;
                              console.log("Prueba de agregar: ", itemString);

                              approvedNecesario.push(itemString);
                            });
                            console.log(
                              "Updated approvedNecesario (after add):",
                              approvedNecesario
                            );
                            component.set(
                              "v.approvedNecesario",
                              approvedNecesario
                            );
                          } else if (category === "Sugerido") {
                            totalRecomendadoFinal += amount;
                            // Add item back to approvedRecomendado when the toggle is checked
                            productNames.forEach(function (productName) {
                              var itemString = productName;

                              approvedRecomendado.push(itemString);
                            });
                            console.log(
                              "Updated approvedRecomendado (after add):",
                              approvedRecomendado
                            );
                            component.set(
                              "v.approvedRecomendado",
                              approvedRecomendado
                            );
                          } else if (category === "Proximo") {
                            console.log(
                              "============================totalSugeridoFinal============================"
                            );
                            console.log(totalSugeridoFinal);
                            totalSugeridoFinal += amount;
                            // Add item back to approvedSugerido when the toggle is checked
                            productNames.forEach(function (productName) {
                              var itemString = productName;

                              approvedSugerido.push(itemString);
                            });
                            console.log(
                              "Updated approvedSugerido (after add):",
                              approvedSugerido
                            );
                            component.set(
                              "v.approvedSugerido",
                              approvedSugerido
                            );
                          }

                          var todosUpdate = component.get("v.dataToUpdate");
                          var todosNombres = component.get("v.todosNombres");

                          todosUpdate.push(...workIds);

                          console.log("=====================productNames");
                          console.log(productNames);
                          todosNombres.push(...productNames);

                          component.set("v.dataToUpdate", todosUpdate);
                          console.log("=====================approvedSugerido");
                          console.log(approvedSugerido);
                          component.set("v.todosNombres", todosNombres);
                        } else {
                          // Elemento no aprobado
                          totalAmount -= amount;
                          totalVerdes -= 1;

                          if (category === "Urgente") {
                            totalNecesarioFinal -= amount;
                            approvedNecesario = approvedNecesario.filter(
                              (item) => !productNames.includes(item)
                            );
                            component.set(
                              "v.approvedNecesario",
                              approvedNecesario
                            );
                          } else if (category === "Sugerido") {
                            totalRecomendadoFinal -= amount;
                            approvedRecomendado = approvedRecomendado.filter(
                              (item) => !productNames.includes(item)
                            );
                            component.set(
                              "v.approvedRecomendado",
                              approvedRecomendado
                            );
                          } else if (category === "Proximo") {
                            totalSugeridoFinal -= amount;
                            approvedSugerido = approvedSugerido.filter(
                              (item) => !productNames.includes(item)
                            );
                            component.set(
                              "v.approvedSugerido",
                              approvedSugerido
                            );
                          }

                          var todosUpdate = component.get("v.dataToUpdate");
                          var todosNombres = component.get("v.todosNombres");

                          workIds.forEach(function (workId, index) {
                            var indexUpdate = todosUpdate.indexOf(workId);
                            if (indexUpdate !== -1) {
                              todosUpdate.splice(indexUpdate, 1);
                            }

                            var indexNombre = todosNombres.indexOf(
                              productNames[index]
                            );
                            if (indexNombre !== -1) {
                              todosNombres.splice(indexNombre, 1);
                            }
                          });

                          component.set("v.dataToUpdate", todosUpdate);
                          component.set("v.todosNombres", todosNombres);
                        }

                        console.log("Prueba selccionados: ", totalVerdes);

                        if (totalVerdes === 0) {
                          component.set("v.disabledButon", true);
                        } else if (totalVerdes > 0) {
                          component.set("v.disabledButon", false);
                        }

                        // Actualizar atributos del componente
                        if (totalAmount < 0) {
                          totalAmount = 0;
                        }
                        component.set(
                          "v.cantidadAprobado",
                          totalAmount.toLocaleString("es-US", {
                            minimumFractionDigits: 0,
                            maximumFractionDigits: 2,
                          })
                        );
                        component.set("v.cantidadVerdes", totalVerdes);
                        component.set("v.cantidadTotal", totalGrupos);
                        component.set(
                          "v.cantidadPresupuesto",
                          totalPresupuesto.toLocaleString("es-US", {
                            minimumFractionDigits: 0,
                            maximumFractionDigits: 2,
                          })
                        );

                        // Actualizar los totales de las secciones
                        component.set(
                          "v.totalNecesarioFinal",
                          totalNecesarioFinal.toLocaleString("es-US", {
                            minimumFractionDigits: 0,
                            maximumFractionDigits: 2,
                          })
                        );

                        component.set(
                          "v.totalRecomendadoFinal",
                          totalRecomendadoFinal.toLocaleString("es-US", {
                            minimumFractionDigits: 0,
                            maximumFractionDigits: 2,
                          })
                        );
                        console.log(
                          "============================totalSugeridoFinal============================"
                        );
                        console.log(totalSugeridoFinal);

                        component.set(
                          "v.totalSugeridoFinal",
                          totalSugeridoFinal.toLocaleString("es-US", {
                            minimumFractionDigits: 0,
                            maximumFractionDigits: 2,
                          })
                        );

                        console.log(
                          "============================totalSugeridoFinal============================"
                        );
                        console.log(component.get(v.totalSugeridoFinal));
                      }
                    );
                  })(
                    newToggleInElement,
                    totalPrice,
                    data.map(function (item) {
                      return item.tiposDeTrabajoId;
                    }),
                    data.map(function (item) {
                      return (
                        item.productoOrAlias +
                        " - " +
                        component.get("v.currencyIso") +
                        " " +
                        item.totalFacturar2.toLocaleString("es-US", {
                          minimumFractionDigits: 0,
                          maximumFractionDigits: 2,
                        })
                      );
                    }),
                    category
                  );
                  console.log("========================== data MO Productos ==========================");
                  console.log(data);
                  console.log(
                    data.map(function (item) {
                      return item.productoOrAlias
                    })
                  );
                  // Append the toggle switch to the group container
                  groupContainer.appendChild(newToggleElement);

                  // Append all the necessary containers to the main div
                  newPointsContainerChild.appendChild(groupContainer);
                  divsContainer.appendChild(newPointsContainerChild);
                  divsContainer.appendChild(listHeader);
                  divsContainer.appendChild(itemList);
                  divsContainer.appendChild(totalLabelElement);

                  // Determine the correct parent container based on the category
                  var parentContainer;
                  if (category == "Sugerido") {
                    parentContainer = document.getElementById("referenceId-1");
                  } else if (category == "Proximo") {
                    parentContainer = document.getElementById("referenceId-2");
                  } else if (category == "Urgente") {
                    parentContainer = document.getElementById("referenceId-3");
                  }

                  parentContainer.appendChild(divsContainer);
                }
              }
            }
          }

          // Set the initial values for totals in the component
          component.set(
            "v.totalNecesario",
            totalNecesario.toLocaleString("es-US", {
              minimumFractionDigits: 0,
              maximumFractionDigits: 2,
            })
          );

          component.set(
            "v.totalSugerido",
            totalSugerido.toLocaleString("es-US", {
              minimumFractionDigits: 0,
              maximumFractionDigits: 2,
            })
          );

          component.set(
            "v.totalRecomendado",
            totalRecomendado.toLocaleString("es-US", {
              minimumFractionDigits: 0,
              maximumFractionDigits: 2,
            })
          );

          // Update component attributes after processing all groups
          component.set("v.cantidadRecomendado", cantidadRecomendado);
          component.set("v.cantidadSugerido", cantidadSugerido);
          component.set("v.cantidadNecesario", cantidadNecesario);

          component.set(
            "v.cantidadAprobado",
            totalAmount.toLocaleString("es-US", {
              minimumFractionDigits: 0,
              maximumFractionDigits: 2,
            })
          );

          component.set(
            "v.cantidadPresupuesto",
            totalPresupuesto.toLocaleString("es-US", {
              minimumFractionDigits: 0,
              maximumFractionDigits: 2,
            })
          );
          component.set("v.cantidadVerdes", totalVerdes);
          component.set("v.cantidadTotal", totalGrupos);
          component.set("v.todosNombres", todosNombres);
          component.set("v.approvedNecesario", approvedNecesario);
          component.set("v.approvedRecomendado", approvedRecomendado);
          component.set("v.approvedSugerido", approvedSugerido);
        }
      }
    });

    $A.enqueueAction(actionPrueba);

    var actionDatos = component.get("c.caseInfo");
    actionDatos.setParams({
      casoId: servicioUrl,
    });
    actionDatos.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var storeResponse = response.getReturnValue();
        if (storeResponse != "") {
          var data = storeResponse;
          function formatFecha(fecha) {
            var date = new Date(fecha);
            var day = ("0" + date.getDate()).slice(-2);
            var month = ("0" + (date.getMonth() + 1)).slice(-2);
            var year = date.getFullYear();
            return day + "/" + month + "/" + year;
          }
          // Set case and vehicle info
          component.set("v.propietario", data[0].Account.Name);
          component.set("v.contacto", data[0].Contact.Name);
          component.set("v.cedula", data[0].Account.Cedula__c);
          component.set("v.telefono", data[0].Account.Phone);
          component.set("v.correo", data[0].Contact.Email);
          component.set("v.fechaEntrada", formatFecha(data[0].CreatedDate));
          component.set("v.placa", data[0].Asset.numeroDePlaca__c);
          component.set("v.marca", data[0].Asset.marca__c);
          component.set("v.modelo", data[0].Asset.modelo__c);
          component.set("v.anio", data[0].Asset.Anio__c);
          component.set("v.vin", data[0].Asset.NumeroDeChasis__c);
          component.set("v.kilometraje", data[0].Asset.Kilometros__c);
          component.set("v.combustible", data[0].Asset.Combustible__c);
          component.set("v.tipoVehiculo", data[0].Asset.Tipo_de_veh_culo__c);
          console.log("Tipo de vehiculo: ", data[0].Asset.Tipo_de_veh_culo__c);
        }
        console.log("corre conexion h 1");
      } else {
        console.log("error 1");
      }
    });
    $A.enqueueAction(actionDatos);

    var action = component.get("c.getMarcasConfig");
    action.setParams({
      casoId: servicioUrl,
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var storeResponse = response.getReturnValue();
      } else {
        console.error("Error retrieving MarcasConfig: ");
        console.error(response.getError());
      }
    });
    $A.enqueueAction(action);

    // Logic for fetching stages
    var action2 = component.get("c.obtenerStages");
    action2.setParams({
      casoId: servicioUrl,
    });
    action2.setCallback(this, function (response) {
      var state = response.getState();
      console.log("Actual 1", state);

      if (state === "SUCCESS") {
        var storeResponse = response.getReturnValue();
        console.log("==============DATA TIMELINE==============");
        console.log(storeResponse);
        var stages = response.getReturnValue();

        // Fetch current stage
        helper.fetchCurrentStage(component, stages);
      } else {
        console.error("Error retrieving stages: ");
        console.error(response.getError());
      }
    });
    $A.enqueueAction(action2);
  },

  handleButtonClick: function (component, event, helper) {
    component.set("v.isLoading", true);
    var todosUpdate = component.get("v.dataToUpdate");
    var todosNombres = component.get("v.todosNombres");
    console.log(todosUpdate);
    console.log(todosNombres);
    var action = component.get("c.cambiarEstado");
    action.setParams({
      tipoTrabajoCasoId: todosUpdate,
      estado: "Aprobado",
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      console.log(state);
      if (state === "SUCCESS") {
        console.log("paso");
        alert("Proceso correcto.");
        location.reload();
      } else if (state === "ERROR") {
        // Log errors
        var errors = response.getError();
        console.error(errors);      
    }
    });
    $A.enqueueAction(action);
    component.set("v.isLoading", false);
  },

  mostrarCambiarMarca: function (component, event, helper) {
    component.set("v.isModalChangeMarca", true); //document.getElementById('verifyCalendarButton').style.display = 'none';
  },

  cerrarCambiarMarca: function (component, event, helper) {
    component.set("v.isModalChangeMarca", false); //document.getElementById('verifyCalendarButton').style.display = 'none';
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

    // Actualizar el aria-expanded
    var button = event.getSource();
    button.set("v.ariaExpanded", !isOpen2);
    console.log("Pressed");
  },

  toggleAccordion3: function (component, event, helper) {
    var isOpen3 = component.get("v.isOpen3");
    component.set("v.isOpen3", !isOpen3); // Alternar el estado

    // Actualizar el aria-expanded
    var button = event.getSource();
    button.set("v.ariaExpanded", !isOpen3);
    console.log("Pressed");
  },

  toggleAccordion4: function (component, event, helper) {
    var isOpen4 = component.get("v.isOpen4");
    component.set("v.isOpen4", !isOpen4); // Alternar el estado

    // Actualizar el aria-expanded
    var button = event.getSource();
    button.set("v.ariaExpanded", !isOpen4);
    console.log("Pressed");
  },

  openShowInsc: function (component, event, helper) {
    component.set("v.isModalInsc", true);
  },

  closeShowInsc: function (component, event, helper) {
    component.set("v.isModalInsc", false);
  },

  closeShowMedia: function (component, event, helper) {
    component.set("v.isActive", false);
  },

  handleToggleChange: function (component, event, helper) {
    // Lógica para manejar el cambio del interruptor de "Aprobar todo"
    var allToggleElements = document.querySelectorAll(
      '.switch input[type="checkbox"]'
    );
    var totalAmount = 0;
    var totalVerdes = 0;
    var totalPresupuesto = 0;
    var totalNecesario = 0;
    var totalRecomendado = 0;
    var totalSugerido = 0;

    var todosUpdate = [];
    var todosNombres = [];

    allToggleElements.forEach(function (toggle) {
      if (!toggle.disabled) {
        toggle.checked = true;
        var amount = parseFloat(toggle.getAttribute("data-amount"));
        var category = toggle.getAttribute("data-category");

        // totalAmount += amount;
        // totalVerdes += 1;
        totalPresupuesto += amount;

        if (category === "Necesario") {
          totalNecesario += amount;
        } else if (category === "Recomendado") {
          totalRecomendado += amount;
        } else if (category === "Sugerido") {
          totalSugerido += amount;
        }

        var workIds = toggle.getAttribute("data-work-ids").split(",");
        console.log("=======================toggle");
        console.log(toggle);
        var productNames = toggle.getAttribute("data-product-names").split(",");
        console.log("Product Names 2: ", productNames);

        todosUpdate.push(...workIds);
        todosNombres.push(...productNames);
      }
    });

    component.set(
      "v.cantidadAprobado",
      totalAmount.toLocaleString("es-US", {
        minimumFractionDigits: 0,
        maximumFractionDigits: 2,
      })
    );
    component.set("v.cantidadVerdes", totalVerdes);
    component.set(
      "v.cantidadPresupuesto",
      totalPresupuesto.toLocaleString("es-US", {
        minimumFractionDigits: 0,
        maximumFractionDigits: 2,
      })
    );
    component.set(
      "v.totalNecesario",
      totalNecesario.toLocaleString("es-US", {
        minimumFractionDigits: 0,
        maximumFractionDigits: 2,
      })
    );
    component.set(
      "v.totalRecomendado",
      totalRecomendado.toLocaleString("es-US", {
        minimumFractionDigits: 0,
        maximumFractionDigits: 2,
      })
    );
    component.set(
      "v.totalSugerido",
      totalSugerido.toLocaleString("es-US", {
        minimumFractionDigits: 0,
        maximumFractionDigits: 2,
      })
    );
    component.set("v.dataToUpdate", todosUpdate);
    component.set("v.todosNombres", todosNombres);

    console.log(
      "Totales actualizados: Necesario =",
      totalNecesario,
      "Recomendado =",
      totalRecomendado,
      "Sugerido =",
      totalSugerido
    );
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
    
    var servicio = component.get("v.caseId")
    if (marcaSelected != marcaUrlAnt) {
      window.location.replace(
        '/s/communitymanageworks?id=' + servicio + '?marca=' + marcaSelected
        // "https://redmotors.my.site.com/s/?servicio=" + marcaSelected
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