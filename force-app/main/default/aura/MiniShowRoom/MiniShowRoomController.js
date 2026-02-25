({
    doInit: function(component, event, helper) {
        var action = component.get("c.getFamilia");
        action.setParams({
            marca: 'MINI'
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                console.log(storeResponse);
                component.set("v.familias", storeResponse);
            }else{
                console.log(response.getError());
            }
        });
        $A.enqueueAction(action);

        var urlParams = {};
        var url = decodeURIComponent(window.location.search.substring(1));
        var params = url.split('?');
        
        for (var i = 0; i < params.length; i++) {
            var param = params[i].split('=');
            var paramName = param[0];
            var paramValue = param[1];
            
            urlParams[paramName] = paramValue;
        }
        var servicioUrl = String(urlParams.sucursal)
        
        component.set("v.sucursalSelected", servicioUrl);
        

        component.set("v.isLoading", false);
    },

    changeFamilia: function(component, event, helper) {
        console.log('IMPRIME');
        var valordentro = event.target.id;
        component.set("v.familiaSeleccionado",valordentro);

        var links = document.querySelectorAll('.vehicles-list a');
            links.forEach(function(link) {
                link.classList.remove('active');
        });

        event.target.classList.add('active');

        var obtenerImagen = component.get("c.getImagenes");
        obtenerImagen.setParams({
            familia: valordentro,
            marca: 'MINI'
        });
        obtenerImagen.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                console.log(storeResponse);
                component.set("v.imagenes",storeResponse);
            }
        });
        $A.enqueueAction(obtenerImagen);


        console.log(valordentro);
        var action = component.get("c.getVehiculos");
        action.setParams({
            familia: valordentro,
            marca:'MINI'
          });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                console.log(storeResponse);
                var listSize = storeResponse.length;
                var gridTable = document.getElementById("displayCoches");
                console.log(storeResponse.length);
                gridTable.innerHTML = '';
                for (var i = 0; i <= listSize; i++) {
                    console.log('=================entra fro=================');
                    console.log(storeResponse[i]);
                    let text = String(storeResponse[i].Modelo_De_Inter_s__c);
                    console.log(storeResponse[i].Modelo_De_Inter_s__c);
                    let family = String(storeResponse[i].Familia__c);
                    var newDivlInt3Lab = document.createElement("div");
                    newDivlInt3Lab.className = "car-container";

                    newDivlInt3Lab.onclick = function changeMonthPrev() {
                        console.log('dentro');                   
                        if(text != null && text != '' && text != undefined){
                            component.set("v.modeloSeleccionado", text);
                        }     
                        
                        component.set("v.isModalInsc", true);
                        if(family != null && family != '' && family != undefined){
                            component.set("v.familiaFinal", family);
                        }
                        //component.set("v.familiaFinal", family);
                        console.log('===================Familia guardada====================');
                        console.log(family);
                    }

                    var newDivlInt4Lab = document.createElement("h2");
                    newDivlInt4Lab.className = "car-title";
                    newDivlInt4Lab.innerHTML += text;

                    var newDivlInt5Lab = document.createElement("img");
                    newDivlInt5Lab.className = "car-image";

                    var objeto = component.get("v.imagenes");
                    console.log('=================text=================');
                    console.log(text);
                    console.log('=================objeto=================');
                    console.log(objeto);
                    
                    
                    for (var j = 0; j < objeto.length; j++) {
                        console.log(objeto[j]);
                        var keys = Object.keys(objeto[j]);
                        console.log(keys);
                        for(var k = 0; k < keys.length; k++){
                            console.log(text);
                            var modeloInteres = keys[k];
                            console.log(modeloInteres);
                            console.log(objeto[j][modeloInteres])
                            console.log(text.includes(modeloInteres));
                            if (text.includes(modeloInteres)) {
                                var idImagen = objeto[j][modeloInteres];
                            }    
                        }
                        
                    }
                    newDivlInt5Lab.src =  "https://redmotors.file.force.com/servlet/servlet.ImageServer?id="+idImagen + "&oid=00D0P000000Dvkz";;
                    
                    console.log('pasa imagen');
                    var newButtonInt = document.createElement("button");
                    newButtonInt.className = "car-container-button";
                    newButtonInt.innerHTML += 'Me interesa este modelo';
                    console.log('pasa me interesa');
                    newButtonInt.onclick = function changeMonthPrev() {
                        console.log('dentro');                        
                        if(text != null && text != '' && text != undefined){
                            component.set("v.modeloSeleccionado", text);
                        }     
                        
                        component.set("v.isModalInsc", true);
                        if(family != null && family != '' && family != undefined){
                            component.set("v.familiaFinal", family);
                        }
                        //component.set("v.familiaFinal", family);
                        console.log('===================Familia guardada====================');
                        console.log(family);
                    }
                    console.log('pasa me boton');
                    var currentTr1 = gridTable.appendChild(newDivlInt3Lab);
                    var currentTr2 = newDivlInt3Lab.appendChild(newDivlInt4Lab);
                    var currentTr3 = newDivlInt3Lab.appendChild(newDivlInt5Lab);
                    var currentTr4 = newDivlInt3Lab.appendChild(newButtonInt);
                    console.log('pasa agregar');
                }
                
            }
        });
        $A.enqueueAction(action);

        

    },

    onChange: function (cmp, evt, helper) {
        var seleccionado = evt.getSource().get('v.value');
        console.log('Dentro select');
        console.log(seleccionado);
        cmp.set("v.tiempoEstimado", seleccionado);
    },

    onChangeOtro: function (cmp, evt, helper) {
        var seleccionado = evt.getSource().get('v.value');
        console.log('Dentro select');
        console.log(seleccionado);
        cmp.set("v.otroMedio", seleccionado);
    },

    openShowInsc: function(component, event, helper) {
        component.set("v.isModalInsc", true);
    },
    
    closeShowInsc: function(component, event, helper) {
        component.set("v.isModalInsc", false); 
    },

    navigateToComponent: function(component, event, helper) {
        component.set("v.isLoading", true);
        var cedulaBuscar =  component.get("v.cedulaCliente");
        console.log(cedulaBuscar);
        var obtenerCedula = component.get("c.getCedula");
        obtenerCedula.setParams({
            cedula: cedulaBuscar
        });
        obtenerCedula.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                console.log(storeResponse);
                component.set("v.infoCedula",storeResponse);
                var values = storeResponse[0].split(";");
                console.log(values);
                component.set("v.nombreCliente",values[0]);//nombre
                component.set("v.apellidoCliente",values[1]);//apellido
                component.set("v.emailCliente",values[3]);//correo
                component.set("v.telefonoCliente",values[4]);//telefono
                var tipo = storeResponse[1];
                if(tipo == 'existe'){
                    component.set("v.isModalExiste",true);
                    component.set("v.isLoading", false);
                }else{
                    component.set("v.isModalNuevo",true);
                    component.set("v.isLoading", false);
                }
            }
        });
        $A.enqueueAction(obtenerCedula);

    
        
        component.set("v.isModalDatos",false);
        //window.location.replace('/walking/s/personal-data')
    },

    navigateToComponent2: function(component, event, helper) {
        component.set("v.isLoading", true);
        console.log('dentro lead');  
        //datos cliente
        var nombreBuscar =  component.get("v.nombreCliente");
        var apellidoBuscar =  component.get("v.apellidoCliente");
        var emailBuscar =  component.get("v.emailCliente");
        var telefonoBuscar =  component.get("v.telefonoCliente");
        var cedulaBuscar = component.get("v.cedulaCliente");
        //datos vehiculos
        var familiaBuscar =  component.get("v.familiaFinal");
        var modeloBuscar =  component.get("v.modeloSeleccionado");
        var tiempoBuscar = component.get("v.tiempoEstimado");
        var sucursalBuscar = component.get("v.sucursalSelected");
        var otroMedioBuscar = component.get("v.otroMedio");

        if (sucursalBuscar == 'Escazu') {
            component.set("v.sucursalBuscar", 'Escazú')
            sucursalBuscar = 'Escazú';
        }

        console.log('Sucursal: ', sucursalBuscar);
        
        console.log(tiempoBuscar);
        var createTrafico = component.get("c.createTrafico");
        createTrafico.setParams({
            nombre: nombreBuscar,
            apellido: apellidoBuscar,
            correo: emailBuscar,
            telefono: telefonoBuscar,
            tiempoAprox : tiempoBuscar,
            familia: familiaBuscar,
            modelo: modeloBuscar,
            marca: 'MINI',
            cedula: cedulaBuscar,
            sucursal:sucursalBuscar,
            otroMedio:otroMedioBuscar
        });
        console.log(nombreBuscar);
        console.log(apellidoBuscar);
        console.log(emailBuscar);
        console.log(telefonoBuscar);
        console.log(tiempoBuscar);
        console.log(familiaBuscar);
        console.log(modeloBuscar);

        createTrafico.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                console.log(storeResponse);
                component.set("v.isLoading", false);
                if (sucursalBuscar == 'Escazú') {
                    window.location.replace('/walkingmini/s/minithankspage?sucursal=Escazu');
                } else {
                    window.location.replace('/walkingmini/s/minithankspage?sucursal='+sucursalBuscar);
                }
            }else{
                component.set("v.isLoading", false);
            }
        });
        $A.enqueueAction(createTrafico);
        //window.location.replace('/walking/s/inscripicion')
    },

    closeModalNuevo: function(component, event, helper) {
        component.set("v.isModalNuevo",false);
        component.set("v.isModalDatos", true)
        component.set("v.isModalInsc", false)
    },

    closeModalexiste: function(component, event, helper) {
        component.set("v.isModalExiste",false);
        component.set("v.isModalDatos", true)
        component.set("v.isModalInsc", false)
    },

    returnHome : function(component, event, helper) {
        window.location.replace('/walkingmini/s/')
    },

    navigateToComponentInsc: function(component, event, helper) {
        window.location.replace('/walkingmini/s/minithankspage?sucursal='+sucursalBuscar);
    }
})