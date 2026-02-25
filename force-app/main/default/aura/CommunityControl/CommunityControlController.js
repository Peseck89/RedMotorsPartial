({

  onRender:function(component, event, helper) {

    var myElement = document.getElementById("vehiculeId");
    if(myElement != null && myElement !== 'undefined'){
      var correUnaVez = component.get("v.correUnaVez");
      if(!correUnaVez){
    var urlParams = {};
    var url = decodeURIComponent(window.location.search.substring(1));
    var params = url.split('?');
    
    for (var i = 0; i < params.length; i++) {
        var param = params[i].split('=');
        var paramName = param[0];
        var paramValue = param[1];
        
        urlParams[paramName] = paramValue;
    }
    var servicioUrl = String(urlParams.servicio)
    if(servicioUrl != null && servicioUrl !== 'undefined'){
      console.log(servicioUrl);
      if(servicioUrl.split('&')[1] != null && servicioUrl.split('&')[1] !== 'undefined'){
        console.log(servicioUrl.split('&')[1]);
        var nuevoServicio = servicioUrl.split('&')[1];
        component.set("v.serviceSelected",nuevoServicio);
        component.set("v.selectedValue",nuevoServicio);
        component.set("v.Servicio",nuevoServicio);
      }
      
    }

    
      
        component.set("v.correUnaVez",true);
        console.log('=========================SI EXISTE EL DOCUMENTO================================');
        console.log('entro handleOnChangeSelectedService');
        //reiniciar las opciones
        //esconder todo de nuevo
        component.set("v.vehicleId", '');
        component.set("v.vehicleSelected", 'Vehículo Propio');
        component.set("v.estimatedKM",'');
        document.getElementById("vehiculeId").style.display = "none";
        var kmActual = component.get("v.estimatedKM");
        console.log("Km Actual " + kmActual);
        var comment = component.get("v.additionalComments");
        
        const elements = document.getElementsByClassName("destruir");
        console.log(elements.length);
    
        for(var j = 0; j < elements.length; j++){    
          elements[j].parentNode.removeChild(elements[j]);
        }
        component.set("v.vehicleSelected", 'Vehículo Propio');
        component.set("v.estimatedKM",'');
        var elmntToView = document.getElementById("vehicleSelection");
        elmntToView.scrollIntoView(); 
        var commentAdded = component.get("v.additionalComments");
        var selectedService = nuevoServicio;
        
    
        var urlService = component.get("v.servicioUrl");
    
        // if(selectedService != urlService){
        //   window.location.replace('https://redmotors--portalcom.sandbox.my.site.com/s/?servicio=' + selectedService )
        // }
    
        //sacar un objeto con los calendarios 
       
        var marcaSelec = component.get("v.marcaSelected").toString();


        //=====================================================

        var actionX = component.get("c.getSetupInformation");
        var marcaSelec = component.get("v.marcaSelected").toString();
        actionX.setParams({
          "marcaSel": marcaSelec
        });
        actionX.setCallback(this, function(response) {
          var state = response.getState();
          if (state === "SUCCESS") {
            var storeResponse = response.getReturnValue();
            console.log('storeResponse');
            console.log(storeResponse);
            console.log('storeResponse 0 ');
            console.log(storeResponse[0]);
            console.log('storeResponse 1 ');
            console.log(storeResponse[1]);
            console.log('storeResponse 2 ');
            console.log(storeResponse[2]);
            console.log('storeResponse 3 ');
            console.log(storeResponse[3]);
            console.log('storeResponse 4 ');
            console.log(storeResponse[4]);
            //Coloca los autos
            helper.convertListValuesForDropdownList(component, event, helper, storeResponse[2]);
            //lle los eventos
            helper.setEventsInformation(component, event, helper, storeResponse[1]);
            //lo coloca en una variable, las no service days
            helper.noServiceInformation = storeResponse[3];
            //lo coloca en una variable operatingHoursList
            helper.operatingHoursList = storeResponse[4];
            helper.operatingHoursListL = storeResponse[5];
            helper.operatingHoursListM = storeResponse[6];
            helper.operatingHoursListMi = storeResponse[7];
            helper.operatingHoursListJ = storeResponse[8];
            helper.operatingHoursListV = storeResponse[9];
            helper.operatingHoursListS = storeResponse[10];
            
            helper.horasRecurrencias = storeResponse[11];
            console.log('storeResponse 10 ');
            console.log(storeResponse[10]);
            console.log('storeResponse 11 ');
            console.log(storeResponse[11]);
    
            component.set("v.userInfo", storeResponse[0]);
            component.set("v.contactId", storeResponse[0].Contact.AccountId);
            component.set("v.userName", storeResponse[0].Name);
            component.set("v.userPhone", storeResponse[0].Contact.Phone);
            component.set("v.userEmail", storeResponse[0].Contact.Email);
            console.log('corre conexion 6');
    
          } else {
            console.log("error");
            console.log(response.getError());
          }
    
        });
        $A.enqueueAction(actionX);

        //=====================================================
        console.log(selectedService);
        console.log(marcaSelec);
        var action = component.get("c.getCalendarsObjects");
        action.setParams({
          serviceSelected: selectedService,
          marcaSel: marcaSelec
        });
        action.setCallback(this, function (response) {
          var state = response.getState();
          console.log('respuesta getCalendarsObjects ' + state);
          if (state === "SUCCESS") {
            var storeResponse = response.getReturnValue();
            console.log(storeResponse);
            if (storeResponse != '') {
              component.set('v.calendarList',storeResponse );
              console.log('corre conexion 3');
            } else {
              //document.getElementById("vehiculeIdSoonEvent").style.display = "none";
              //component.set("v.isModalOpenExistingCitation", false);
    
            }
          }
    
        });
        $A.enqueueAction(action);
        component.set("v.vehicleSelected", 'Vehículo Propio');
        //Change HTML
        //document.getElementById("container").style.display = "none";
        document.getElementById("sidebar").style.display = "none";
        document.getElementsByClassName("centroDeServicio")[0].style.display = "none";
        
        if(helper.subServiceWasSelected || comment!=""){
          document.getElementById("vehicleSelection").style.display = "";      
        }else{
          document.getElementById("errorMessage").style.display = "";
        }
        //document.getElementById("vehicleSelection").style.display = "";
        
        
        //document.getElementById("verifyCalendarButton").style.display = "none";
        document.getElementById("vehiculeId").style.display = "none";
        //document.getElementById("estimatedKM").style.display = "none";
        document.getElementById("vehicleInfo").style.display = "none";
        
        component.set("v.vehicleSelected", 'Vehículo Propio');
        //handle de los subservicios
        var marcaSelec = component.get("v.marcaSelected").toString();
        var action = component.get("c.getMarcasSubSer");
        action.setParams({
          "marcaSel": marcaSelec,
          "servicioSelec" : selectedService
        });
        action.setCallback(this, function(response) {
          var state = response.getState();
          console.log('conexion 4 ' + state);
          if (state === "SUCCESS") {
            var result = response.getReturnValue();
            var storeResponse = response.getReturnValue();
            //helper.convertListForSubServ(component, event, helper, storeResponse);
            console.log('corre conexion 4');
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
    
        document.getElementById("additionalServices").style.display = "";
        
        component.set("v.vehicleId", '');
        
        component.set("v.estimatedKM",'');
        document.getElementById("vehiculeId").style.display = "none";
        
        // First Query Extraction for the availability
        console.log('serviceSelected handleOnChangeSelectedService ' + selectedService);
        component.set("v.serviceSelected", selectedService);
    
        component.set("v.vehicleSelected", 'Vehículo Propio');
        component.set("v.estimatedKM",'');
    
        console.log('llamada metodo getCalendarAvailabilityForService');
        var apexMethod = "c.getCalendarAvailabilityForService";
        var parameters = {
          'selectedService': selectedService
        };
        setTimeout(() => {
          component.set("v.isLoading", false);
        }, 1000);
        var result = helper.getServerResponse(component, event, helper, apexMethod, parameters);
        console.log('paso metodo getCalendarAvailabilityForService');
        
    
        console.log('llamada metodo servicios');
        var b = component.get('c.crearSubServicios');
        $A.enqueueAction(b);
        
    
    
        component.set("v.vehicleSelected", 'Vehículo Propio');
        console.log('Paso metodo servicios');
        // result[0] = Capacity by Sucursal | result[1] = Asesores By Calendar     | result[2] = Event Results
        component.set("v.vehicleSelected", 'Vehículo Propio');
        console.debug('handle service ' + result);
        // reset statistics
        
        helper.resetStatistics();
        component.set("v.vehicleSelected", 'Vehículo Propio');
        console.log('salio handleOnChangeSelectedService');
        component.set("v.estimatedKM",'');
        

        
      }
    }

    

    console.log('=========================PROBANDOSalio================================');
  },

  handleKeyUp: function (component, event, helper) {
    var isEnterKey = event.keyCode === 13;
    var isPlacaBuscada = event.value;
    var queryTerm = component.find('enter-search').get('v.value');
    if (isEnterKey) {
      component.set('v.issearching', true);
        setTimeout(function() {
          var action = component.get("c.getAssetBuscado");
  
          action.setParams({
            cocheBuscado: queryTerm
          });
          action.setCallback(this, function (response) {
            var state = response.getState();
        
            if (state === "SUCCESS") {
              var storeResponse = response.getReturnValue();
              if (storeResponse != '') {
                alert('Searched for "' + storeResponse + '"!');
                //document.getElementById("container").style.display = "none";
                console.log('storeResponse');
                console.log(storeResponse);


                let myDiv = document.getElementById('vehicleInfo');
                var table = document.getElementById("vehicleInfoTable").getElementsByTagName('tbody')[0];
                
                document.getElementById("vehicleInfo").style.display = "";
                // Eliminar todos los elementos secundarios del div
                while (table.firstChild) {
                  table.removeChild(table.firstChild);
                }
                
                myDiv.classList = "table-responsive text-nowrap";
                myDiv.style="background: #f2f2f2;border: 1px solid #d9dee3;padding: 20px 13px; margin-bottom: 1%;font-size:18px;";
                
                var tableBody = document.getElementById("vehicleInfoTable").getElementsByTagName('tbody')[0];
                
                var newRow = tableBody.insertRow();
                var cell1 = newRow.insertCell(0);
                var cell2 = newRow.insertCell(1);
                var cell3 = newRow.insertCell(2);
                var cell4 = newRow.insertCell(3);
                var cell5 = newRow.insertCell(4);
                
                
                cell1.innerText = helper.controlUndefinedValues(storeResponse[0].marca__c);
                cell2.innerText = helper.controlUndefinedValues(storeResponse[0].modelo__c);
                cell3.innerText = helper.controlUndefinedValues(storeResponse[0].Anio__c);
                cell4.innerText = helper.controlUndefinedValues(storeResponse[0].color__c);
                cell5.innerText = helper.controlUndefinedValues(storeResponse[0].numeroDePlaca__c);
              
                
              } else {
                // document.getElementById("vehiculeIdSoonEvent").style.display = "none";
                // component.set("v.isModalOpenExistingCitation", false);                  
                document.getElementById("vehicleNoInfo").style.display = "";
              }
            }
          });
          $A.enqueueAction(action);

            
            component.set('v.issearching', false);
        }, 2000);

    }
  },

  

  doInit: function(component, event, helper) {
    component.set("v.isLoading", true);
    //component.set("v.url", 'https://redmotors.file.force.com/servlet/servlet.ImageServer?id=015PH0000004RMh&oid=00D0P000000Dvkz&lastMod=1692746709000');

    //marcaSelected es la marca pick
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

    component.set("v.marcaUrl", servicioUrl);
    helper.currentDate = new Date();
    helper.cmp = component;
    var action = component.get("c.getSetupInformation");
    var marcaSelec = component.get("v.marcaSelected").toString();
    action.setParams({
      "marcaSel": marcaSelec
    });
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var storeResponse = response.getReturnValue();
        console.log('storeResponse');
        console.log(storeResponse);
        console.log('storeResponse 0 ');
        console.log(storeResponse[0]);
        console.log('storeResponse 1 ');
        console.log(storeResponse[1]);
        console.log('storeResponse 2 ');
        console.log(storeResponse[2]);
        console.log('storeResponse 3 ');
        console.log(storeResponse[3]);
        console.log('storeResponse 4 ');
        console.log(storeResponse[4]);
        //almacena los coches
        component.set("v.listaCoches", storeResponse[2]);
        //Coloca los autos
        helper.convertListValuesForDropdownList(component, event, helper, storeResponse[2]);
        //lle los eventos
        helper.setEventsInformation(component, event, helper, storeResponse[1]);
        //lo coloca en una variable, las no service days
        helper.noServiceInformation = storeResponse[3];
        //lo coloca en una variable operatingHoursList
        helper.operatingHoursList = storeResponse[4];
        helper.operatingHoursListL = storeResponse[5];
        helper.operatingHoursListM = storeResponse[6];
        helper.operatingHoursListMi = storeResponse[7];
        helper.operatingHoursListJ = storeResponse[8];
        helper.operatingHoursListV = storeResponse[9];
        helper.operatingHoursListS = storeResponse[10];
        
        helper.horasRecurrencias = storeResponse[11];
        console.log('storeResponse 10 ');
        console.log(storeResponse[10]);
        console.log('storeResponse 11 ');
        console.log(storeResponse[11]);

        component.set("v.userInfo", storeResponse[0]);
        component.set("v.contactId", storeResponse[0].Contact.AccountId);
        component.set("v.userName", storeResponse[0].Name);
        component.set("v.userPhone", storeResponse[0].Contact.Phone);
        component.set("v.userEmail", storeResponse[0].Contact.Email);
        console.log('corre conexion 6');

      } else {
        console.log("error");
        console.log(response.getError());
      }

    });
    $A.enqueueAction(action);
    console.log('pasa');

    var b = component.get('c.handleAceptarMarca');
    $A.enqueueAction(b);

    
    var fu = component.get("c.getPreguntas");
    fu.setCallback(this, function (response) {
      var state = response.getState();
      console.log('respuesta preguntas ' + state);
      if (state === "SUCCESS") {
        var storeResponse = response.getReturnValue();
        console.log(storeResponse);
        if (storeResponse != '') {
          var numeroPreguntas = [];
          console.log(storeResponse.length);
          // for(var i = 0; i < storeResponse.length; i++){   
          //   console.log(storeResponse[i]); 
          //   numeroPreguntas.push(storeResponse[i].Pregunta__c);
            
          // }
          component.set('v.inputCount',storeResponse);
          console.log(numeroPreguntas);
        }

      }
    });
    $A.enqueueAction(fu);
    //crearSubServicios(component, event, helper);
    component.set('v.tabs', [{
      label: "Escazú",
      id: "0054U000009hipBQAQ"
    }, {
      label: "Motorrad",
      id: "0054U000009hiw2QAA"
    }, {
      label: "Pinares",
      id: "0054U000009hiwHQAQ"
    }, {
      label: "Uruca",
      id: "0054U000009hiwMQAQ"
    }]);

    setTimeout(() => {
      component.set("v.isLoading", false);
  }, 1000);


  var term = component.get("c.getTerminosYCondi");
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
    
  


  },
  handleOnChange: function(component, event, helper) {
    // component.set("v.isLoading", true);
    var idSelected  = event.getSource().get('v.name'); 
    var respuestaSelected = event.getParam("value");
    var conId = event.getSource().get('v.value');      
    console.log(idSelected == 1);
    console.log(respuestaSelected);
    if(idSelected == 1){
      component.set( "v.pregunta1" , respuestaSelected);
      var ejemplo = component.get( "v.pregunta1" );
      console.log('ejemplo = ' + ejemplo );
    }else if(idSelected == 2){
      component.set( "v.pregunta2" , respuestaSelected);

    }else if(idSelected == 3){
      component.set( "v.pregunta3" , respuestaSelected);

    }else if(idSelected == 4){
      component.set( "v.pregunta4" , respuestaSelected);

    }else if(idSelected == 5){
      component.set( "v.pregunta5" , respuestaSelected);
  
    }else if(idSelected == 6){
      component.set( "v.pregunta6" , respuestaSelected);

    }else if(idSelected == 7){
      component.set( "v.pregunta7" , respuestaSelected);

    }else if(idSelected == 8){
      component.set( "v.pregunta8" , respuestaSelected);
   
    }else if(idSelected == 9){
      component.set( "v.pregunta9" , respuestaSelected);
 
    }else if(idSelected == 10){
      component.set( "v.pregunta10" , respuestaSelected);

    }else if(idSelected == 11){
      component.set( "v.pregunta11" , respuestaSelected);

    }else if(idSelected == 12){
      component.set( "v.pregunta12" , respuestaSelected);

    }else if(idSelected == 13){
      component.set( "v.pregunta13" , respuestaSelected);

    }else if(idSelected == 14){
      component.set( "v.pregunta14" , respuestaSelected);

    }else if(idSelected == 15){
      component.set( "v.pregunta15" , respuestaSelected);

    }else if(idSelected == 16){
      component.set( "v.pregunta16" , respuestaSelected);

    }else if(idSelected == 17){
      component.set( "v.pregunta17" , respuestaSelected);

    }else if(idSelected == 18){
      component.set( "v.pregunta18" , respuestaSelected);

    }else if(idSelected == 19){
      component.set( "v.pregunta19" , respuestaSelected);

    }else if(idSelected == 20){
      component.set( "v.pregunta20" , respuestaSelected);

    }
    var button = component.find("myButton");
    button.set("v.disabled", false);
    setTimeout(() => {
      component.set("v.isLoading", false);
    }, 1000);
  },
  handleOnChangeSelectedService: function(component, event, helper) {
    component.set("v.isLoading", true);
    
    console.log('====================== PRIMERA CARGA =======================');
    var primeraCarga = component.get("v.serviceSelected");
    console.log(primeraCarga);
    var marcaSelected = component.get("v.marcaSelected");
    if(primeraCarga != event.getParam("value") && primeraCarga != '' && primeraCarga != null && primeraCarga != undefined){
      var nuevovalor = event.getParam("value");
        window.location.replace('https://redmotors.my.site.com/s/disponibilidades?servicio=' + marcaSelected + '&' +  nuevovalor);
      
    }


    console.log('entro handleOnChangeSelectedService');
    //reiniciar las opciones
    //esconder todo de nuevo
    component.set("v.vehicleId", '');
    component.set("v.vehicleSelected", 'Vehículo Propio');
    component.set("v.estimatedKM",'');
    document.getElementById("vehiculeId").style.display = "none";
    var kmActual = component.get("v.estimatedKM");
    console.log("Km Actual " + kmActual);
    var comment = component.get("v.additionalComments");
    
    const elements = document.getElementsByClassName("destruir");
    console.log(elements.length);

    for(var j = 0; j < elements.length; j++){    
      elements[j].parentNode.removeChild(elements[j]);
    }
    component.set("v.vehicleSelected", 'Vehículo Propio');
    component.set("v.estimatedKM",'');
    var elmntToView = document.getElementById("vehicleSelection");
    elmntToView.scrollIntoView(); 
    var commentAdded = component.get("v.additionalComments");
    var selectedService = event.getParam("value");
    

    var urlService = component.get("v.servicioUrl");

    // if(selectedService != urlService){
    //   window.location.replace('https://redmotors--portalcom.sandbox.my.site.com/s/?servicio=' + selectedService )
    // }

    //sacar un objeto con los calendarios 
    var action = component.get("c.getCalendarsObjects");
    var marcaSelec = component.get("v.marcaSelected").toString();
    console.log(selectedService);
    console.log(marcaSelec);
    action.setParams({
      serviceSelected: selectedService,
      marcaSel: marcaSelec
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      console.log('respuesta getCalendarsObjects ' + state);
      if (state === "SUCCESS") {
        var storeResponse = response.getReturnValue();
        console.log(storeResponse);
        if (storeResponse != '') {
          component.set('v.calendarList',storeResponse );
          console.log('corre conexion 3');
        } else {
          //document.getElementById("buscarCoche").style.display = "";
          //component.set("v.isModalOpenExistingCitation", false);

        }
      }

    });
    $A.enqueueAction(action);
    component.set("v.vehicleSelected", 'Vehículo Propio');
    //Change HTML
    //document.getElementById("container").style.display = "none";
    document.getElementById("sidebar").style.display = "none";
    document.getElementsByClassName("centroDeServicio")[0].style.display = "none";
    
    if(helper.subServiceWasSelected || comment!=""){
      document.getElementById("vehicleSelection").style.display = "";      
    }else{
      document.getElementById("errorMessage").style.display = "";
    }
    //document.getElementById("vehicleSelection").style.display = "";
    //document.getElementById("buscarCoche").style.display = "";
    
    //document.getElementById("verifyCalendarButton").style.display = "none";
    document.getElementById("vehiculeId").style.display = "none";
    //document.getElementById("estimatedKM").style.display = "none";
    document.getElementById("vehicleInfo").style.display = "none";
    
    component.set("v.vehicleSelected", 'Vehículo Propio');
    //handle de los subservicios
    var marcaSelec = component.get("v.marcaSelected").toString();
    var action = component.get("c.getMarcasSubSer");
    action.setParams({
      "marcaSel": marcaSelec,
      "servicioSelec" : selectedService
    });
    action.setCallback(this, function(response) {
      var state = response.getState();
      console.log('conexion 4 ' + state);
      if (state === "SUCCESS") {
        var result = response.getReturnValue();
        var storeResponse = response.getReturnValue();
        //helper.convertListForSubServ(component, event, helper, storeResponse);
        console.log('corre conexion 4');
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

    document.getElementById("additionalServices").style.display = "";
    
    component.set("v.vehicleId", '');
    
    component.set("v.estimatedKM",'');
    document.getElementById("vehiculeId").style.display = "none";
    
    // First Query Extraction for the availability
    console.log('serviceSelected handleOnChangeSelectedService ' + selectedService);
    component.set("v.serviceSelected", selectedService);

    component.set("v.vehicleSelected", 'Vehículo Propio');
    component.set("v.estimatedKM",'');

    console.log('llamada metodo getCalendarAvailabilityForService');
    var apexMethod = "c.getCalendarAvailabilityForService";
    var parameters = {
      'selectedService': selectedService
    };
    setTimeout(() => {
      component.set("v.isLoading", false);
    }, 1000);
    var result = helper.getServerResponse(component, event, helper, apexMethod, parameters);
    console.log('paso metodo getCalendarAvailabilityForService');
    

    console.log('llamada metodo servicios');
    var b = component.get('c.crearSubServicios');
    $A.enqueueAction(b);
    


    component.set("v.vehicleSelected", 'Vehículo Propio');
    console.log('Paso metodo servicios');
    // result[0] = Capacity by Sucursal | result[1] = Asesores By Calendar     | result[2] = Event Results
    component.set("v.vehicleSelected", 'Vehículo Propio');
    console.debug('handle service ' + result);
    // reset statistics
    
    helper.resetStatistics();
    component.set("v.vehicleSelected", 'Vehículo Propio');
    console.log('salio handleOnChangeSelectedService');
    component.set("v.estimatedKM",'');
    handleVerifyCalendar();
  },

  // doneRendering: function(component, event, helper) {
  //   console.log('entro afterrender');
  //   // Call someOtherFunction after the component has finished rendering
  //   //value="{!v.selectedValue}"
  //   var servUrl = component.get("v.selectedValue");
  //   console.log(servUrl);
  //   var combobox = this.template.querySelector("[data-id='generalServicios']");
  //   combobox.set("v.value", servUrl);
  // },

  openUrl: function(component,event,helper){
    console.log('Google Url');
    //https://www.google.com/calendar/render?action=TEMPLATE&text=test&details=prueba&location=mi+casa&dates=20230308T235300Z%2F20230309T235300Z
    var centroSel = component.get("v.eventIdcreado");
    
    console.log('Url');
    console.log(centroSel);
    console.log("https://redmotors.lightning.force.com/"+centroSel);
    component.set("v.isLoading", true);
    setTimeout(() => {
      window.open("https://redmotors.lightning.force.com/"+centroSel);
      component.set("v.isLoading", false);
    }, 4500);
    

  },

   formatDateForGoogleCalendar:function(startDate, endDate) {
    console.log('entro a google');
    var format = (date) => {
      return date.toISOString().replace(/[-:]/g, '');
    };
  
    var formattedStartDate = format(new Date(startDate));
    var formattedEndDate = format(new Date(endDate));
    console.log('salio a google');
    return `${formattedStartDate}/${formattedEndDate}`;
  },  

  handleAceptaMinutes:function(component, event, helper){
    component.set("v.isModalMinutes", false);
    component.set("v.isModalOpenConfirmation", true);
    //helper.mostrarPreguntas(component,event,helper);
    component.set("v.isModalOpenConfirmation", true);

    // setTimeout(() => {
    //   console.log('aqui')
    //   console.log('==========================Aqui estoy==========================');
    //   var elTipoCita =  component.get("v.tipoCita");
    //   console.log('==========================Aqui estoy 1==========================' + elTipoCita);
    //     if(elTipoCita){
    //       console.log('==========================Aqui estoy 2==========================');
    //       console.log(document.getElementById("containerForm"));
    //       var containerT = document.getElementById("containerFormulario");
    //       console.log('==========================Aqui estoy 3==========================');
    //       console.log(containerT);
    //       containerT.scrollIntoView(); 
    //       // Loop to create and append the input elements
    //       for (var i = 0; i <= 10; i++) {
    //           var labelT = document.createElement("label");
    //           //labelT.for = 'car';
    //           labelT.innerHTML = "Pregunta " + i + ":";
    //           var inputT = document.createElement("input");
    //           inputT.type = "text";
              
    //           inputT.addEventListener('change', function handleClick(event) {
    //             var checkValue =  event.currentTarget.checked;
    //             helper.additionalServices[nombreSub] = checkValue;
    //             helper.setSubServiceSelection(component, checkValue);
    //           });
    //           console.log('==========================Aqui estoy 4==========================');
    //           //input.addEventListener("change", handleOnChange);
    //           var currentTr6 = containerT.appendChild(labelT);
    //            var currentTr7 = containerT.appendChild(inputT);
              
    //       }
    //       console.log('==========================Aqui estoy 5==========================');
  
    //     }
    //     console.log('==========================Aqui sali==========================');
    //     var button = component.find("myButton");
    //     button.set("v.disabled", false);
    // }, 1000);
    
  },

  cerrarAceptaMinutes:function(component, event, helper){
    component.set("v.isLoading", true);
    var serviceCenter = component.get("v.selTabId");
    var startDateHour = component.get("v.startDateHour");
    var action = component.get("c.releaseHoursAvailability");
    action.setParams({
      
      "calendarId" : serviceCenter,
      "horaSelc" : startDateHour          
    });
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var storeResponse = response.getReturnValue();  
        console.log(storeResponse);      
        component.set("v.horasReservas", storeResponse);
        console.log('corre conexion h 7');
      } else {
        console.log("error");
        console.log(response.getError());
      }

    });
    $A.enqueueAction(action);

    component.set("v.isModalMinutes", false);
    component.set("v.isModalOpenConfirmation", false);

    setTimeout(() => {
      component.set("v.isLoading", false);
    }, 1000);
    
  },

  cerrarModalOtro:function(component, event, helper){
    component.set("v.isModalOtro", false);
  },

  handleAceptaOffMinutes:function(component, event, helper){
    component.set("v.isModalOffMinutes", false);
  },

  cancelCurrentCitation: function(component, event, helper) {
    component.set("v.isLoading", true);
    helper.cancelCita(component, event, helper);
    setTimeout(() => {
      component.set("v.isLoading", false);
    }, 1500);
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
      window.location.replace('https://redmotors.my.site.com/s/disponibilidades?servicio=' + marcaSelected )
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
        console.log('======================= storeResponse ===================');
        console.log(storeResponse);
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


  
  showMenu : function(component, event, helper) {
    document.getElementById("barMenu").style.display = "none";
    document.getElementById("overlayMenu").style.display = "block";
    document.getElementById("layout-menu").style.transform = "none";
  },

  hideMenu: function(component, event, helper){
    document.getElementById("barMenu").style.display = "";
    document.getElementById("overlayMenu").style.display = "none";
    document.getElementById("layout-menu").style.transform = "translate3d(-100%, 0, 0)";
  },

  myTest_: function(component, event, helper) {
    document.getElementById("creandocita3").style.display = "";
   
    document.getElementById("creandocita1").style.display = "none";
    document.getElementById("creandocita2").style.display = "none";
    document.getElementById("isModalOpenFinalConfirmation").style.display = "none";

  },

  myTest: function(component, event, helper) {
    component.set("v.isLoading", true);
    var intervalId = component.get("v.setIntervalId");
    var esFormulario = component.get("v.tipoCita");
    var lstPreguntas = component.get("v.inputCount");
    var noHayVacios = true;
    if(esFormulario == true){
      for(var z = 0; z < lstPreguntas.length; z++){
        var pregunta = "v.pregunta" + (z+1);
        var vacio = component.get(pregunta);
        if(vacio == null || vacio == undefined || vacio == ''){
          alert("Por favor complete el cuestionario.");
          noHayVacios = false;
        }else{
          noHayVacios = true;
        }
      }
      if(noHayVacios){
        window.clearInterval(intervalId);
          clearInterval(intervalId);
      
          console.log('entro myTest');
          var selectedHour = component.get("v.selectedHour");
          console.log(selectedHour);
          var ddate = new Date(helper.selectedDate.getFullYear(), helper.selectedDate.getMonth(), helper.selectedDate.getDate());
          console.log(ddate);
          var result = helper.createNewCalendarEvent(ddate, selectedHour, component);
          console.log('=============================ESPACIO NO OCUPADO DE REGRESO==========================');
          setTimeout(() => {
            var espacioOcupado =  component.get('v.espacioNoOcupado');
            console.log( 'Espacio ocupado es : ' + espacioOcupado);
            if(espacioOcupado == true){
              component.set("v.isModalOpenFinalConfirmation", true);
              component.set("v.isModalOpenConfirmation", false);
            }else{
              component.set("v.isModalLibreDeCitas", true);
              component.set("v.isModalOpenConfirmation", false);
              
            }
          }, 3000);
      }
    }else{
      window.clearInterval(intervalId);
      clearInterval(intervalId);
  
      console.log('entro myTest');
      var selectedHour = component.get("v.selectedHour");
      console.log(selectedHour);
      var ddate = new Date(helper.selectedDate.getFullYear(), helper.selectedDate.getMonth(), helper.selectedDate.getDate());
      console.log(ddate);
      var result = helper.createNewCalendarEvent(ddate, selectedHour, component);
      console.log('=============================ESPACIO NO OCUPADO DE REGRESO==========================');
      setTimeout(() => {
        var espacioOcupado =  component.get('v.espacioNoOcupado');
        console.log( 'Espacio ocupado es : ' + espacioOcupado);
        if(espacioOcupado == true){
          component.set("v.isModalOpenFinalConfirmation", true);
          component.set("v.isModalOpenConfirmation", false);
        }else{
          component.set("v.isModalLibreDeCitas", true);
          component.set("v.isModalOpenConfirmation", false);
          
        }
      }, 3000);
    }
    setTimeout(() => {
      component.set("v.isLoading", false);
    }, 4000);
    
  },
  
  nuevaCitaMovil: function(component, event, helper) {
    
    var servicioSelected = component.get("v.serviceSelected");
    var selectedServicio = component.get("v.vehicleId").toString();  
    var selectedSuc = component.get("v.selTabId");
    //{!v.userName}
    console.log('servicioSelected ' + servicioSelected);
    
    console.log('selectedService ' + selectedSuc);
    // nuevo metodo de fechas
    var clienteSelec =  component.get("v.userName");
    var placaSelec =  component.get("v.ownVehicleSelected");
    
    var ddate = new Date(helper.selectedDate.getFullYear(), helper.selectedDate.getMonth(), helper.selectedDate.getDate());
    console.log('===================== fecha Seleccionada ===========================');
    console.log(ddate);
    var action = component.get("c.mandarMensaje");
    action.setParams({
      "cliente": clienteSelec,
      "placa": placaSelec,
      "fecha": ddate,
      "calendarId": selectedSuc
    });
    action.setCallback(this, function(response) {
      var state = response.getState();
      console.log(state);
      if (state === "SUCCESS") {
        component.set("v.isModalCitaMovil",true); 
      }else{
        console.log("error");
        console.log(response.getError());
      }
      

      
    });
    $A.enqueueAction(action);
  },

  handleVerifyCalendar: function(component, event, helper) {
    component.set("v.isLoading", true);
    console.log('entro handleVerifyCalendar');
    //calendarios logica

    document.getElementById("sidebar").style.display = "none";

    document.getElementsByClassName("centroDeServicio")[0].style.display = "none";
    //AQUI SE MUESTRA EL CALENDARIO SI O NO
    var action = component.get("c.getHoraGlobal");

    var values = component.get('v.calendarList');
    component.set('v.selTabId', values[0].id);
    component.set("v.selectedSucursal", values[0].id);
    console.log('v.selTabId: ' + values[0].id);
    helper.selectedServiceCenter = values[0].id;
    var selectedTabServiceCenter = component.get("v.selTabId");
    helper.selectedServiceCenter = selectedTabServiceCenter;
    var serviceCenterName = helper.locations[selectedTabServiceCenter];
    component.set("v.serviceCenterSelectedName", serviceCenterName);

    var marcaSelected = component.get("v.marcaSelected").toString();
    var servicioSelected = component.get("v.serviceSelected");
    var selectedServicio = component.get("v.vehicleId").toString();  
      
    console.log('servicioSelected ' + servicioSelected);
    var selectedSuc = component.get("v.serviceCenterSelectedName");
    console.log('selectedService ' + selectedSuc);




    var apexMethod = "c.getMecanicosSucursal";
    var parameters = {
      'marcaSel': marcaSelected,
      'servicioSelec': servicioSelected,
      'selectedService': selectedSuc
    };
    var result = helper.getMecanicosResponse(component, event, helper, apexMethod, parameters);




    
    //horasGlobales
    action.setParams({
      marcaSel: marcaSelected,
      servicioSelec: servicioSelected,
      selectedService: selectedSuc
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      console.log('respuesta horasGlobales 2 ' + state);
      if (state === "SUCCESS") {
        var storeResponse = response.getReturnValue();
        console.log('storeResponse horasGlobales 2' );
        console.log(storeResponse);        
        console.log(component.get('v.tipoCita' ));

        if (storeResponse != undefined && storeResponse.length > 0) {
          
          if(marcaSelected != 'Motorrad'){
            if(storeResponse[0].Tipo_de_Cita__c == 'Formulario'){
              component.set('v.tipoCita', true );
              helper.minutosSucursal = storeResponse[0].Tiempo_de_cita_2__c;
              component.set('v.minutosSucursal',storeResponse[0].Tiempo_de_cita_2__c );
            }else if(storeResponse[0].Tipo_de_Cita__c == 'Bajo solicitud'){
              component.set('v.citaMovil', true );
              helper.minutosSucursal = '30';
              component.set('v.minutosSucursal','30');
            }else{
              component.set('v.tipoCita', false );
              helper.minutosSucursal = storeResponse[0].Tiempo_de_cita_2__c;
              component.set('v.minutosSucursal',storeResponse[0].Tiempo_de_cita_2__c );
            }
            
            
          }else{
            if(storeResponse[0].Tipo_de_Cita__c == 'Formulario'){
              component.set('v.tipoCita', true );
              helper.minutosSucursal = storeResponse[0].Tiempo_de_cita_2__c;
              component.set('v.minutosSucursal',storeResponse[0].Tiempo_de_cita_2__c );
            }else if(storeResponse[0].Tipo_de_Cita__c == 'Bajo solicitud'){
              component.set('v.citaMovil', true );
              helper.minutosSucursal = '30';
              component.set('v.minutosSucursal','30');
            }else{
              component.set('v.tipoCita', false );
              var varMotosKm = component.get("v.estimatedKM");
              console.log('varMotosKm');
              console.log(varMotosKm);
              if (varMotosKm >= 0 && varMotosKm <= 1000) {
                component.set('v.minutosSucursal',storeResponse[0].kmCero__c );
                helper.minutosSucursal = storeResponse[0].kmCero__c;
              } else if (varMotosKm >= 1001 && varMotosKm <= 5000) {
                component.set('v.minutosSucursal',storeResponse[0].kmMil__c );
                helper.minutosSucursal = storeResponse[0].kmMil__c;
              } else if (varMotosKm >= 5001 && varMotosKm <= 10000) {
                component.set('v.minutosSucursal',storeResponse[0].kmCincomil__c );
                helper.minutosSucursal = storeResponse[0].kmCincomil__c;
              } else if (varMotosKm >= 10001 && varMotosKm <= 15000) {
                component.set('v.minutosSucursal',storeResponse[0].kmDiezmil__c );
                helper.minutosSucursal = storeResponse[0].kmDiezmil__c;
              } else if (varMotosKm >= 15001 && varMotosKm <= 20000) {
                component.set('v.minutosSucursal',storeResponse[0].kmQuincemil__c );
                helper.minutosSucursal = storeResponse[0].kmQuincemil__c;
              } else if (varMotosKm >= 20001 && varMotosKm <= 25000) {
                component.set('v.minutosSucursal',storeResponse[0].kmVeintemil__c );
                helper.minutosSucursal = storeResponse[0].kmVeintemil__c;
              } else if (varMotosKm >= 25001 && varMotosKm <= 30000) {
                component.set('v.minutosSucursal',storeResponse[0].kmVeinticinco__c );
                helper.minutosSucursal = storeResponse[0].kmVeinticinco__c;
              } else if (varMotosKm >= 30001 && varMotosKm <= 35000) {
                component.set('v.minutosSucursal',storeResponse[0].kmTreinta__c );
                helper.minutosSucursal = storeResponse[0].kmTreinta__c;
              } else if (varMotosKm >= 35001 && varMotosKm <= 40000) {
                component.set('v.minutosSucursal',storeResponse[0].kmTreintacinco__c );
                helper.minutosSucursal = storeResponse[0].kmTreintacinco__c;
              } else if (varMotosKm >= 40001 && varMotosKm <= 45000) {
                component.set('v.minutosSucursal',storeResponse[0].kmCuarenta__c );
                helper.minutosSucursal = storeResponse[0].kmCuarenta__c;
              } else if (varMotosKm >= 45001 && varMotosKm <= 50000) {
                component.set('v.minutosSucursal',storeResponse[0].kmCuarentacinco__c );
                helper.minutosSucursal = storeResponse[0].kmCuarentacinco__c;
              } else {
                component.set('v.minutosSucursal',storeResponse[0].kmCuarentacinco__c );
                helper.minutosSucursal = storeResponse[0].kmCuarentacinco__c;
              }  
            } 
          }


          console.log(component.get('v.minutosSucursal'));
          //SI TIENE AQUI REGISTRO FORMULARIO ENTONCES OCULTAMOS CALENDARIO
          //SI TIENE AQUI REGISTRO FORMULARIO ENTONCES OCULTAMOS CALENDARIO
         
          
            console.log(storeResponse[0].Tipo_de_Cita__c);
            // document.getElementById("containerForm").style.display = "none";
            //document.getElementById("container").style.display = "";
            document.getElementById("centroDeServicio").style.display = "";
            console.log('antes de scroll');
            var elmntToView2 = document.getElementById("centroDeServicio");
            elmntToView2.scrollIntoView();
            var selectedService = component.get("v.serviceSelected");
            var selectedMarca = component.get("v.marcaSelected");
            console.log('servicio handleVerifyCalendar ' +  selectedService);

            var values = component.get('v.calendarList');
            console.log('values');
            console.log(values);
            component.set('v.tabs', values);
            component.set('v.selTabId', values[0].id);
            component.set("v.selectedSucursal", values[0].id);
            console.log('v.selTabId: ' + values[0].id);
            helper.selectedServiceCenter = values[0].id;
            var elmntToView = document.getElementById("calendar-table");
            elmntToView.scrollIntoView(); 
            console.log('termina handleVerifyCalendar');

            //helper.myFunction2(component, event, helper);

          
          //else{
          //   console.log(storeResponse[0].Tipo_de_Cita__c);
          //   var values = component.get('v.calendarList');
          //   console.log('values');
          //   console.log(values);
          //   component.set('v.tabs', values);
          //   component.set('v.selTabId', values[0].id);
          //   component.set("v.selectedSucursal", values[0].id);
          //   console.log('v.selTabId: ' + values[0].id);
          //   helper.selectedServiceCenter = values[0].id;
          //   document.getElementById("centroDeServicio").style.display = "";
          //   document.getElementById("container").style.display = "none";
          //   document.getElementById("containerForm").style.display = "";
          //   var elmntToView = document.getElementById("containerForm");
          //   elmntToView.scrollIntoView();
          // }
      


        } else {

          var values = component.get('v.calendarList');
            // console.log('values');
            // console.log(values);
            // component.set('v.tabs', values);
            // component.set('v.selTabId', values[0].id);
            // component.set("v.selectedSucursal", values[0].id);
            // console.log('v.selTabId: ' + values[0].id);
            // helper.selectedServiceCenter = values[0].id;
            // document.getElementById("centroDeServicio").style.display = "";
            // document.getElementById("container").style.display = "none";
            // document.getElementById("containerForm").style.display = "";
            // var elmntToView = document.getElementById("containerForm");
            // elmntToView.scrollIntoView();
            document.getElementById("containerForm").style.display = "none";
            document.getElementById("container").style.display = "";
            document.getElementById("centroDeServicio").style.display = "";
            console.log('antes de scroll');
            var elmntToView2 = document.getElementById("centroDeServicio");
            elmntToView2.scrollIntoView();
            console.log('despues de scroll');
            var selectedService = component.get("v.serviceSelected");
            var selectedMarca = component.get("v.marcaSelected");
            console.log('servicio handleVerifyCalendar ' +  selectedService);

            var values = component.get('v.calendarList');
            console.log('values');
            console.log(values);
            component.set('v.tabs', values);
            component.set('v.selTabId', values[0].id);
            component.set("v.selectedSucursal", values[0].id);
            console.log('v.selTabId: ' + values[0].id);
            helper.selectedServiceCenter = values[0].id;
            var elmntToView = document.getElementById("calendar-table");
            elmntToView.scrollIntoView(); 
            console.log('termina handleVerifyCalendar');
            elmntToView2.scrollIntoView();
            helper.myFunction2(component, event, helper);
        }
      }
    });
    $A.enqueueAction(action);

    
    setTimeout(() => {
      component.set("v.isLoading", false);
    }, 1000);
    console.log('salio handleVerifyCalendar');
  },

  handleOnChangeVehiculeId: function(component, event, helper) {
    
    var vehiculeSelected = component.get("v.vehicleId");
    if (vehiculeSelected != '') {
        document.getElementById("estimatedKM").style.display = "";
        document.getElementById("vehicleInfo").style.display = "";
        component.set("v.flagPlaca", "true");
        
    }
    //document.getElementById("container").style.display = "none";
    document.getElementById("vehicleInfo").style.display = "none";
    component.set("v.estimatedKM", '');
  },

  handleOnChangeEstimatedKM: function(component, event, helper) {
    var kmIngresados = event.getParam("value");
    component.set("v.estimatedKM", kmIngresados);

    //document.getElementById("container").style.display = "none";
  },

  handleKMVisivility: function(component, event, helper) {
    var vehiculeSelected = component.get("v.ownVehicleSelected");
    if (vehiculeSelected != '' && document.getElementById("alertExistingCitation") != "") {
      document.getElementById("estimatedKM").style.display = "";
      document.getElementById("vehicleInfo").style.display = "";
    }
  },
    
  onChangeComment:function(component, event, helper){
    console.log('=============================================');
    console.log(event.getParam("value"));
    component.set("v.additionalComments",event.getParam("value"));

         document.getElementById("errorMessage").style.display = "none";
         
         document.getElementById("vehicleSelection").style.display = "";  
      helper.setSubServiceSelection(component);
      console.log('=============================================');
      console.log(event.getParam("value"));
      component.set("v.additionalComments",event.getParam("value"));

           document.getElementById("errorMessage").style.display = "none";
           
           document.getElementById("vehicleSelection").style.display = "";  
  },

  handleOnChangeVehiculeSelection: function(component, event, helper) { 
    var comment = component.get("v.additionalComments");
    var vehicleSelected = event.getParam("value");

    console.log('====================== comment ======================');
    console.log(comment);

    component.set("v.vehicleSelected", vehicleSelected);
    var selectedService = component.get("v.serviceSelected");
      if( selectedService != "Mecánica Rápida" || helper.subServiceWasSelected || comment!="" ){ 
        component.set("v.vehicleId", '');
        component.set("v.ownVehicleSelected", '');
        var assets = component.get("v.userAssets");
        component.set("v.assets", assets);

        if (vehicleSelected === "Vehículo de alguien más") {
          document.getElementById("errorExistingCitation").style.display = "none";
          document.getElementById("vehiculeId").style.display = "";//document.getElementById('alertExistingCitation').style.display = "none";
          component.set("v.isModalOpenExistingCitation", false);
          document.getElementById('ownVehicule').style.display = "none";
        } else {
          document.getElementById("vehiculeId").style.display = "none";
          document.getElementById("vehiculeIdSoonEvent").style.display = "none";
          component.set("v.isModalOpenExistingCitation", false);
          document.getElementById('ownVehicule').style.display = "";
          var userEvent = component.get("v.userEvent");
          if (component.get("v.eventStartDate") != null) {//document.getElementById('alertExistingCitation').style.display = "none";
            component.set("v.isModalOpenExistingCitation", false);
            //document.getElementById('container').style.display = "none";
          } else {
            document.getElementById("ownVehicule").style.display = "";//document.getElementById("verifyCalendarButton").style.display = "";
          }
        }
        if(helper.subServiceWasSelected || comment!=""){
          //document.getElementById("container").style.display = "none";
          document.getElementById('estimatedKM').style.display = "none";
          document.getElementById("vehicleInfo").style.display = "none";
           document.getElementById("errorMessage").style.display = "none";
        }else{
          document.getElementById("errorMessage").style.display = "";
          document.getElementById("vehicleSelection").style.display="none";
        }
        
      }
      else{
          document.getElementById("errorMessage").style.display = "";
          document.getElementById("vehicleSelection").style.display="none";
      }
    

  },

  handleOnOwnChange: function(component, event, helper) {
    var ownVehicleSelected = event.getParam("value");
    helper.resultOfSelectedVehicle = helper.resultVehiculeIdGlobal[ownVehicleSelected];
    component.set("v.ownVehicleSelected", ownVehicleSelected);
    component.set("v.estimatedKM", '');
    document.getElementById("vehicleInfo").style.display = "";

    if (ownVehicleSelected != '') {
      document.getElementById("estimatedKM").style.display = "";
      document.getElementById("vehicleInfo").style.display = "";
      helper.setInformationForSelectedVehicle();
    } else {
      document.getElementById("estimatedKM").style.display = "none";
      document.getElementById("vehicleInfo").style.display = "none";
      document.getElementById("errorExistingCitation").style.display = "none";
    }


    var listOfEvents = component.get("v.userEvents");
    var listOfEventsSize = listOfEvents.length;
    for (var i = 0; i < listOfEventsSize; i++) {
        
      var event = listOfEvents[i];
        
      if (event.WhatId__c === ownVehicleSelected) {
          
        var eventDatetime = helper.convertDateTimeFormat(event.StartDateTime__c);
          

        component.set("v.eventStartDate", eventDatetime);
        component.set("v.eventCarId", event.WhatId__r.Name);
        component.set("v.eventLocation", event.CalendarName__c); //.replace("Calendario", ""));
        component.set("v.eventId", event.Id); //document.getElementById('container').style.display = 'none';//document.getElementById('alertExistingCitation').style.display = '';
        component.set("v.isModalOpenExistingCitation", true); //document.getElementById('verifyCalendarButton').style.display = 'none';
        component.set("v.estimatedKM", '');
        document.getElementById("vehicleInfo").style.display = ""; 
        document.getElementById("estimatedKM").style.display = "none"; 
        document.getElementById("errorExistingCitation").style.display = "";
        return 'withCitation';
      } 
        else {//document.getElementById('alertExistingCitation').style.display = 'none';
        component.set("v.isModalOpenExistingCitation", false); //document.getElementById('container').style.display = 'none';
        document.getElementById("estimatedKM").style.display = "";
        document.getElementById("errorExistingCitation").style.display = "none";
        document.getElementById("vehicleInfo").style.display = "";
        
      }
    }
  },

 
  handleChangeServiceCenter: function(component, event, helper) {
    component.set("v.isLoading", true);
    //este es el bueno este controla cuando se cambia el servicio en la tabs
    document.getElementById("container").style.display = "";
    
    document.getElementById("container").style.display = "";

    document.getElementById("container").style.display = "";
    document.getElementById("sidebar").style.display = "none";   
    var selectedService = component.get("v.serviceSelected");
    helper.selectedService = selectedService;
    
    var selectedTabServiceCenter = component.get("v.selTabId");
    component.set("v.selectedSucursal", selectedTabServiceCenter);//esto guarda el id de la sucurcsal

    console.log( 'handleChangeServiceCenter selectedTabServiceCenter ' + selectedTabServiceCenter);
    helper.selectedServiceCenter = selectedTabServiceCenter;

    var serviceCenterName = helper.locations[selectedTabServiceCenter];
    component.set("v.serviceCenterSelectedName", serviceCenterName);
    console.log( 'handleChangeServiceCenter serviceCenterSelectedName ' + serviceCenterName);
    document.getElementById("sidebar").style.display = "none";

    console.log('===================ANTES INTENTANDO IMPRIMIR===================');

    var sidebarEvents = document.getElementById("sidebarDiponibilidades");
    document.getElementById("sidebarDiponibilidades").style.display = "flow-root";
    // document.getElementById("sidebarDiponibilidadesLabel").style.display = "";
    sidebarEvents.innerHTML = "";

    let today = new Date();

    // Extract the day, month, and year
    let day = String(today.getDate()).padStart(2, '0'); // Adds a leading zero if needed
    let month = String(today.getMonth() + 1).padStart(2, '0'); // Months are zero-indexed
    let year = today.getFullYear();
    
    // Combine into the desired format
    let formattedDate = `${day}/${month}/${year}`;

  
   
    console.log('===================INTENTANDO IMPRIMIR===================');


    //document.getElementById("containerCalendario").style.display = "";
    var elmntToView = document.getElementById("containerCalendario");
    elmntToView.scrollIntoView();
    

    // To add the call of myFunction with the selections
    //helper.showEvents(component, event, helper, selectedTabServiceCenter);

    var action = component.get("c.getHoraGlobal");

    var marcaSelected = component.get("v.marcaSelected").toString();
    var servicioSelected = component.get("v.serviceSelected");
    var selectedServicio = component.get("v.vehicleId").toString();  
    var selectedSuc = component.get("v.serviceCenterSelectedName");

    var apexMethod = "c.getMecanicosSucursal";
    var parameters = {
      'marcaSel': marcaSelected,
      'servicioSelec': servicioSelected,
      'selectedService': selectedSuc
    };
    var result = helper.getMecanicosResponse(component, event, helper, apexMethod, parameters);



    console.log('servicioSelected ' + servicioSelected);
    
    console.log('selectedService ' + selectedSuc);
    
    //horasGlobales
    action.setParams({
      marcaSel: marcaSelected,
      servicioSelec: servicioSelected,
      selectedService: selectedSuc
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      console.log('respuesta horasGlobales 1 ' + state);
      if (state === "SUCCESS") {
        var storeResponse = response.getReturnValue();
        console.log('storeResponse horasGlobales 1' );
        console.log(storeResponse);
        
        if (storeResponse != undefined && storeResponse.length > 0) {
          
          if(marcaSelected != 'Motorrad'){
            component.set('v.minutosSucursal',storeResponse[0].Tiempo_de_cita_2__c );
            helper.minutosSucursal = storeResponse[0].Tiempo_de_cita_2__c;
          }else{
            var varMotosKm = component.get("v.estimatedKM");
            console.log('varMotosKm');
            console.log(varMotosKm);
            if (varMotosKm >= 0 && varMotosKm <= 1000) {
              component.set('v.minutosSucursal',storeResponse[0].kmCero__c );
              helper.minutosSucursal = storeResponse[0].kmCero__c;
            } else if (varMotosKm >= 1001 && varMotosKm <= 5000) {
              component.set('v.minutosSucursal',storeResponse[0].kmMil__c );
              helper.minutosSucursal = storeResponse[0].kmMil__c;
            } else if (varMotosKm >= 5001 && varMotosKm <= 10000) {
              component.set('v.minutosSucursal',storeResponse[0].kmCincomil__c );
              helper.minutosSucursal = storeResponse[0].kmCincomil__c;
            } else if (varMotosKm >= 10001 && varMotosKm <= 15000) {
              component.set('v.minutosSucursal',storeResponse[0].kmDiezmil__c );
              helper.minutosSucursal = storeResponse[0].kmDiezmil__c;
            } else if (varMotosKm >= 15001 && varMotosKm <= 20000) {
              component.set('v.minutosSucursal',storeResponse[0].kmQuincemil__c );
              helper.minutosSucursal = storeResponse[0].kmQuincemil__c;
            } else if (varMotosKm >= 20001 && varMotosKm <= 25000) {
              component.set('v.minutosSucursal',storeResponse[0].kmVeintemil__c );
              helper.minutosSucursal = storeResponse[0].kmVeintemil__c;
            } else if (varMotosKm >= 25001 && varMotosKm <= 30000) {
              component.set('v.minutosSucursal',storeResponse[0].kmVeinticinco__c );
              helper.minutosSucursal = storeResponse[0].kmVeinticinco__c;
            } else if (varMotosKm >= 30001 && varMotosKm <= 35000) {
              component.set('v.minutosSucursal',storeResponse[0].kmTreinta__c );
              helper.minutosSucursal = storeResponse[0].kmTreinta__c;
            } else if (varMotosKm >= 35001 && varMotosKm <= 40000) {
              component.set('v.minutosSucursal',storeResponse[0].kmTreintacinco__c );
              helper.minutosSucursal = storeResponse[0].kmTreintacinco__c;
            } else if (varMotosKm >= 40001 && varMotosKm <= 45000) {
              component.set('v.minutosSucursal',storeResponse[0].kmCuarenta__c );
              helper.minutosSucursal = storeResponse[0].kmCuarenta__c;
            } else if (varMotosKm >= 45001 && varMotosKm <= 50000) {
              component.set('v.minutosSucursal',storeResponse[0].kmCuarentacinco__c );
              helper.minutosSucursal = storeResponse[0].kmCuarentacinco__c;
            } else {
              component.set('v.minutosSucursal',storeResponse[0].kmCuarentacinco__c );
              helper.minutosSucursal = storeResponse[0].kmCuarentacinco__c;
            }          
          
          }



          console.log(component.get('v.minutosSucursal'));
          console.log(storeResponse[0].Tipo_de_Cita__c);
          //SI TIENE AQUI REGISTRO FORMULARIO ENTONCES OCULTAMOS CALENDARIO
          if(storeResponse[0].Tipo_de_Cita__c != 'Formulario'){
          //   console.log(storeResponse[0].Tipo_de_Cita__c);
          //   document.getElementById("containerForm").style.display = "none";
          //   document.getElementById("container").style.display = "";
          //   var elmntToView = document.getElementById("container");
          //   elmntToView.scrollIntoView();
            // helper.myFunction2(component, event, helper);
            component.set('v.tipoCita', false );
          }
         else{
          component.set('v.tipoCita', true );
          //   console.log(storeResponse[0].Tipo_de_Cita__c);
          //   document.getElementById("centroDeServicio").style.display = "";
          //   document.getElementById("container").style.display = "none";
          //   document.getElementById("containerForm").style.display = "";
          //   var elmntToView = document.getElementById("containerForm");
          //   elmntToView.scrollIntoView();
          }
          console.log(storeResponse[0].Tipo_de_Cita__c);
          document.getElementById("container").style.display = "none";
          component.set("v.isLoading", true);
          document.getElementById("container").style.display = "";
          console.log('antes de myFunction2 1');
          // helper.myFunction2(component, event, helper);
          console.log('si salio de myFunction2');
          // setTimeout(() => {
          //   component.set("v.isLoading", false);
          // }, 4000);

        } else {
          console.log(storeResponse[0].Tipo_de_Cita__c);
          // document.getElementById("centroDeServicio").style.display = "";
          // document.getElementById("container").style.display = "none";
          // document.getElementById("containerForm").style.display = "";
          // var elmntToView = document.getElementById("containerForm");
          // elmntToView.scrollIntoView();
          console.log('ELSE DENTRO DE CAMBIO DE CALENDARIO');
          //document.getElementById("containerForm").style.display = "none";
          document.getElementById("container").style.display = "";
          // var elmntToView = document.getElementById("container");
          // elmntToView.scrollIntoView(); 
          console.log('antes de myFunction2 2');
          // helper.myFunction2(component, event, helper);
          component.set("v.isLoading", false);
          console.log('si salio de myFunction2');
        }
      }
    });
    $A.enqueueAction(action);


    var action2 = component.get("c.saberEsSincronica");
    action2.setParams({
      marcaSel: marcaSelected,
      servicioSelec: servicioSelected,
      selectedService: selectedSuc
    });
    action2.setCallback(this, function (response) {
      var state = response.getState();
      console.log('respuesta saberEsSincronica ' + state);
      if (state === "SUCCESS") {
        var storeResponse = response.getReturnValue();
        console.log('storeResponse saberEsSincronica ' );
        console.log(storeResponse);
        helper.esSincronica = storeResponse;
      }
    });
    $A.enqueueAction(action2);

    // setTimeout(() => {
    //   component.set("v.isLoading", false);
    // }, 4000);


    helper.myFunction2(component, event, helper);
    
  },




  
  reload: function() {
 
    location.reload();
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
        console.log("error");
        console.log(response.getError());
      }

    });
    $A.enqueueAction(action);
  },
    
  // Add the text of the additional service selected.
  addServiceInspeccion: function(component, event, helper) {
    var elmntToView = document.getElementById("vehicleSelection");
    elmntToView.scrollIntoView(); 
    var checkValue = component.find("cbox_inspeccion").get("v.value");
    helper.additionalServices['Inspección vehículo'] = checkValue;
    helper.setSubServiceSelection(component, checkValue);
    
  },
    
  addServiceAceite: function(component, event, helper) {
    var elmntToView = document.getElementById("vehicleSelection");
    elmntToView.scrollIntoView();
    var checkValue = component.find("cbox_aceite").get("v.value");
    helper.additionalServices['Servicio aceite'] = checkValue;
    helper.setSubServiceSelection(component, checkValue);
  },
    
  addServicePastillasFrenos: function(component, event, helper) {
    var elmntToView = document.getElementById("vehicleSelection");
    elmntToView.scrollIntoView(); 
    var checkValue = component.find("cbox_pastillasFrenos").get("v.value");
    helper.additionalServices['Pastillas de frenos'] = checkValue;
    helper.setSubServiceSelection(component, checkValue);
  },
    
  addServiceDiscosFrenos: function(component, event, helper) {
    var elmntToView = document.getElementById("vehicleSelection");
    elmntToView.scrollIntoView(); 
    var checkValue = component.find("cbox_discosFrenos").get("v.value");
    helper.additionalServices['Discos de frenos'] = checkValue;
    helper.setSubServiceSelection(component, checkValue);
  },
    
  addServiceMicrofiltro: function(component, event, helper) {
    var elmntToView = document.getElementById("vehicleSelection");
    elmntToView.scrollIntoView(); 
    var checkValue = component.find("cbox_microfiltro").get("v.value");
    helper.additionalServices['Servicio aceite y Microfiltro'] = checkValue;
    helper.setSubServiceSelection(component, checkValue);
  },
    
  addServiceFiltroAire: function(component, event, helper){
    var elmntToView = document.getElementById("vehicleSelection");
    elmntToView.scrollIntoView(); 
    var checkValue = component.find("cbox_filtroAire").get("v.value");
    helper.additionalServices['Filtro de aire'] = checkValue;
    helper.setSubServiceSelection(component, checkValue);
        
  },
    addServiceBateria: function(component, event, helper){
    var elmntToView = document.getElementById("vehicleSelection");
    elmntToView.scrollIntoView(); 
    var checkValue = component.find("cbox_bateria").get("v.value");
    helper.additionalServices['Batería'] = checkValue;
    helper.setSubServiceSelection(component, checkValue);
  },
    
  addServiceEscobillas: function(component, event, helper) {
    var elmntToView = document.getElementById("vehicleSelection");
    elmntToView.scrollIntoView(); 
    var checkValue = component.find("cbox_escobillas").get("v.value");
    helper.additionalServices['Cambiar ambas escobillas'] = checkValue;
    helper.setSubServiceSelection(component, checkValue);
  },
    
    addServiceAlineadoBalanceo: function(component, event, helper) {
    var elmntToView = document.getElementById("vehicleSelection");
    elmntToView.scrollIntoView(); 
    var checkValue = component.find("cbox_alineadoBalanceo").get("v.value");
    helper.additionalServices['Alineado y Balanceo de llantas'] = checkValue;
    helper.setSubServiceSelection(component, checkValue);
  },

  crearSubServicios: function(component, event, helper) {
    console.log('entro crearSubServicios');
    var action = component.get("c.getSubServicios");
    var marcaSelec = component.get("v.marcaSelected").toString();
    var selectedService = component.get("v.serviceSelected").toString();
    console.log(marcaSelec);
    console.log(selectedService);
    action.setParams({
      "marcaSel": marcaSelec,
      "servicioSelec" : selectedService
    });
    
    action.setCallback(this, function(response) {
      var state = response.getState();
      console.log('state crearSubServicios' + state);
      if (state === "SUCCESS") {
        var storeResponse = response.getReturnValue();
        console.log('subSer' + storeResponse);
        var listSize = storeResponse.length;
        var listaTotal = storeResponse;
          var result = [];
          var resultVehiculeId = {};
          if (listSize > 0) {
            var gridTable = document.getElementById("additionalTableService");
            for (var i = 0; i < listSize; i++) {

              let text = String(listaTotal[i]);
              const myArray = text.split(",");
              console.log(myArray[0]);
              var nombreSub = myArray[0];
              var idDocSub = myArray[1];

              var newTr = document.createElement("div");
              newTr.className = "eventCard col-md-6 destruir";
              newTr.id = nombreSub;

              var newDivInt = document.createElement("div");
              newDivInt.className = "eventCard-action";

              var newLabelInt = document.createElement("label");
              newLabelInt.className = "list-group-item";
              newLabelInt.style.display = "flex";
              //newLabelInt.style.height = "70px";

              var newDivlIntLab = document.createElement("div");
              newDivlIntLab.className = "mr-servicio-image";
                          
              
              var newImgIntDiv = document.createElement("img");
              newImgIntDiv.className = "additionalServiceIcons";
              //https://redmotors.file.force.com/servlet/servlet.ImageServer?id=0154U000008XxqK&oid=00D0P000000Dvkz
              newImgIntDiv.src = "https://redmotors.file.force.com/servlet/servlet.ImageServer?id="+idDocSub + "&oid=00D0P000000Dvkz";
              //proceso imagen final              
              var newDivlInt2Lab = document.createElement("div");
              newDivlInt2Lab.className = "mr-servicio-text";
              newDivlInt2Lab.innerHTML += nombreSub;
              // if(nombreSub.length > 30){
              newDivlInt2Lab.style.fontSize = '11 px';
              // }

              var newDivlInt3Lab = document.createElement("div");
              newDivlInt3Lab.className = "mr-servicio-input";

              var newULlInt4Lab = document.createElement("input");
              newULlInt4Lab.className = "form-check-input me-1";
              newULlInt4Lab.type = "checkbox";
              newULlInt4Lab.addEventListener('click', function handleClick(event) {
                console.log('entro select');
                var checkValue =  event.currentTarget.checked;
                component.set('v.additionalSubService',event.currentTarget.id);
                helper.additionalServices[nombreSub] = checkValue;
                helper.setSubServiceSelection(component, checkValue);
              });
              newULlInt4Lab.id = nombreSub;

              var currentTr7 = newDivlInt3Lab.appendChild(newULlInt4Lab);  
              var currentTr5 = newDivlIntLab.appendChild(newImgIntDiv);              
              var currentTr4 = newLabelInt.appendChild(newDivlIntLab);
              var currentTr6 = newLabelInt.appendChild(newDivlInt2Lab);
              var currentTr8 = newLabelInt.appendChild(newDivlInt3Lab);
              var currentTr3 = newDivInt.appendChild(newLabelInt);
              var currentTr2 = newTr.appendChild(newDivInt);
              var currentTr1 = gridTable.appendChild(newTr);
            }
          }
          console.log('corre conexion 5');
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

   
    
    var c = component.get('c.getReportarFallo'); 
    c.setParams({
      "serviceSelected" : selectedService,
      "marcaSel": marcaSelec
    });
    c.setCallback(this, function(response) {
      console.log('====================== ENTRA ERRORES PREGUNTA ======================');
      var state = response.getState();
      if (state === "SUCCESS") {
        console.log(response.getReturnValue());
        var storeResponse = response.getReturnValue();

        var listSize = storeResponse.length;
        console.log(listSize);
        var result = [];
        var resultVehiculeId = {};
        if (listSize > 0) {
          for (var i = 0; i < listSize; i++) {
            console.log(storeResponse[i]);
            var newElement = {
              'label': storeResponse[i],
              'value': storeResponse[i]
            };
            var newAssetDetail = {};
            result.push(newElement);
            // console.log(result);
            //resultVehiculeId[listOfElements[i].Id] = listOfElements[i];
          }
          component.set("v.optionsErrors",result);
          
          // component.set("v.selectedValue",result[0].value);
        }

        
        
      } else {
        console.log("error");
        console.log(response.getError());
      }

    });
    $A.enqueueAction(c);




  },

  myFunction: function(component, event, helper) {
    component.set("v.controllerFirstRun", true);

    //helper.echo(component);

    $(".button-collapse").sideNav();
    var calendar = document.getElementById("calendar-table");
    var gridTable = document.getElementById("table-body");
    helper.currentDate = new Date();
    helper.selectedDate = helper.currentDate;
    var selectedDayBlock = null;
    var globalEventObj = {};

    function createCalendar(date, side) {
      helper.currentDate = date;
      var startDate = new Date(helper.currentDate.getFullYear(), helper.currentDate.getMonth(), 1);

      var monthTitle = document.getElementById("month-name");
      var monthName = helper.currentDate.toLocaleString("es-ES", {
        month: "long"
      });
      var yearNum = helper.currentDate.toLocaleString("es-ES", {
        year: "numeric"
      });
      monthTitle.innerHTML = `${monthName} ${yearNum}`;

      if (side == "left") {
        gridTable.className = "animated fadeOutRight";
      } else {
        gridTable.className = "animated fadeOutLeft";
      }

      setTimeout(() => {
        gridTable.innerHTML = "";

        var newTr = document.createElement("div");
        newTr.className = "row";
        var currentTr = gridTable.appendChild(newTr);

        for (let i = 1; i < (startDate.getDay() || 7); i++) {
          let emptyDivCol = document.createElement("div");
          emptyDivCol.className = "col empty-day";
          currentTr.appendChild(emptyDivCol);
        }

        var lastDay = new Date(helper.currentDate.getFullYear(), helper.currentDate.getMonth() + 1, 0);
        var saveDate = lastDay;
        lastDay = lastDay.getDate();

        for (let i = 1; i <= lastDay; i++) {
          if (currentTr.children.length >= 7) {
            currentTr = gridTable.appendChild(addNewRow());
          }
          let currentDay = document.createElement("div");
          currentDay.className = "col";

          /* JD Test
           * */
          var dayInLoop = new Date(saveDate.getFullYear(), saveDate.getMonth(), i, 0);
          var testDate = new Date(2022, 11, 1, 0);

          if (dayInLoop > testDate || dayInLoop < testDate) {
            //console.log("inside if");
          } else {
            currentDay.className = "col col2";
          }

          // fin JD test
          if (selectedDayBlock == null && i == helper.currentDate.getDate() || helper.selectedDate.toDateString() == new Date(helper.currentDate.getFullYear(), helper.currentDate.getMonth(), i).toDateString()) {
            helper.selectedDate = new Date(helper.currentDate.getFullYear(), helper.currentDate.getMonth(), i);
            var selectedFormattedDate = helper.selectedDate.getFullYear() + '-' + String(helper.selectedDate.getMonth() + 1).padStart(2, '0') + '-' + String(helper.selectedDate.getDate()).padStart(2, '0');

            document.getElementById("eventDayName").innerHTML = helper.selectedDate.toLocaleString("es-ES", {
              month: "long",
              day: "numeric",
              year: "numeric"
            });

            selectedDayBlock = currentDay;
            setTimeout(() => {
              currentDay.classList.add("blue");
              currentDay.classList.add("lighten-3");
            }, 900);
          }
          if (component.get("v.controllerFirstRun") != true) {

            let eventMark = document.createElement("div");
            var correctDate = new Date()



            //se reemplazo para la logica nueva
            var opsHoursBySucursal = JSON.parse(JSON.stringify(helper.quantityOfOperatingHoursBySucursal));
            console.log('opsHoursBySucursal 2');
            console.log(opsHoursBySucursal);
            console.log('capacityBySucursal 2');
            console.log(helper.capacityBySucursal);
            //var color = helper.colorStatisticsByDay[dayInLoopFormattedDate];
            var correctDate = new Date();
            var todayDate = correctDate.setHours(0, 0, 0, 0);
            todayDate = new Date(todayDate);
            var color = 'yellow';
            if (color === 'gray' || dayInLoop.getTime() < todayDate.getTime()) {
              currentDay.classList.add('inactive-day');
              color = 'gray'
            }

            if (color === undefined) {
              color = 'red';
              if (dayInLoop.getTime() < todayDate.getTime()) {
                color = 'gray';
                currentDay.classList.add('inactive-day');
              }
            }
            var classColorAdapted = 'circle-' + color + '-availability';
            eventMark.className = classColorAdapted;
            currentDay.appendChild(eventMark);

          }

          currentTr.appendChild(currentDay);
        }

        for (let i = currentTr.getElementsByTagName("div").length; i < 7; i++) {
          let emptyDivCol = document.createElement("div");
          emptyDivCol.className = "col empty-day";
          currentTr.appendChild(emptyDivCol);
        }

        if (side == "left") {
          gridTable.className = "animated fadeInLeft";
        } else {
          gridTable.className = "animated fadeInRight";
        }

        function addNewRow() {
          let node = document.createElement("div");
          node.className = "row";
          return node;
        }

      }, !side ? 0 : 270);
    }

    createCalendar(helper.currentDate);
    console.log('Paso el createCalendar');

    var todayDayName = document.getElementById("todayDayName");
    todayDayName.innerHTML = "Hoy es " + helper.currentDate.toLocaleString("es-ES", {
      weekday: "long",
      day: "numeric",
      month: "short"
    });

    var prevButton = document.getElementById("prev");
    var nextButton = document.getElementById("next");

    prevButton.onclick = function changeMonthPrev() {
      component.set("v.isLoading", true);
      helper.currentDate = new Date(helper.currentDate.getFullYear(), helper.currentDate.getMonth() - 1);
      helper.createCalendar(helper.currentDate, "left");
      setTimeout(() => {
        component.set("v.isLoading", false);
    }, 4000);
    }
    nextButton.onclick = function changeMonthNext() {
      component.set("v.isLoading", true);
      helper.currentDate = new Date(helper.currentDate.getFullYear(), helper.currentDate.getMonth() + 1);
      helper.createCalendar(helper.currentDate, "right");
      setTimeout(() => {
        component.set("v.isLoading", false);
    }, 4000);
    }

    function addEvent(title, desc) {
      if (!globalEventObj[helper.selectedDate.toDateString()]) {
        globalEventObj[helper.selectedDate.toDateString()] = {};
      }
      globalEventObj[helper.selectedDate.toDateString()][title] = desc;
    }

    var changeFormButton = document.getElementById("changeFormButton");
    var addForm = document.getElementById("addForm");
    changeFormButton.onclick = function(e) {
      addForm.style.top = 0;
    }

    var foo = document.getElementById("sidebarEvents");
    foo.onclick = function(e) {
      var element = e.target;
      if (element.Type === "button") {
        var ddate = new Date(helper.selectedDate.getFullYear(), helper.selectedDate.getMonth(), helper.selectedDate.getDate());
        var selectedHour = element.innerText;
        component.set("v.selectedHour", selectedHour);
        var result = helper.createNewCalendarEvent(ddate, selectedHour, component);

      }
      document.getElementById('sidebar').style.display = "none";
      document.getElementsByClassName('centroDeServicio')[0].style.display = "none";
      //document.getElementById('container').style.display = "none";
      //document.getElementById('testJD').style.display = "";
      component.set("v.isModalOpenConfirmation", true);
      
      document.getElementById('verificarSection').style.display = "none";
      document.getElementById('additionalServices').style.display = "none";

      console.log('-------Date------- ' + helper.selectedDate)
      //aqui se pone la fecha?
      const dateEs =  Date.parse(helper.selectedDate);

      const options = {
        weekday: 'long',
        year: 'numeric',
        month: 'long',
        day: 'numeric',
        hour: undefined,
        minute: undefined,
        second: undefined,
        hour12: undefined,
        timeZone: 'UTC',
        timeZoneName: undefined,
        // Specify the locale as 'es' for Spanish
        locale: 'es'
      };
      
      const formatter = new Intl.DateTimeFormat('es', options);
      const formattedDateES = formatter.format(dateEs);
      
      console.log(formattedDateES);
              component.set("v.startDateHourEsp", formattedDateES);


      component.set("v.selectedDate", helper.selectedDate.toDateString());
      helper.setVehiculeIdConfirmation(component);
    }



    var cancelAdd = document.getElementById("cancelAdd");
    cancelAdd.onclick = function(e) {
      addForm.style.top = "100%";
      let inputs = addForm.getElementsByTagName("input");
      for (let i = 0; i < inputs.length; i++) {
        inputs[i].value = "";
      }
      let labels = addForm.getElementsByTagName("label");
      for (let i = 0; i < labels.length; i++) {
        labels[i].className = "";
      }
    }
    // aqui
    var addEventButton = document.getElementById("addEventButton");
    addEventButton.onclick = function(e) {
      let title = document.getElementById("eventTitleInput").value.trim();
      let desc = document.getElementById("eventDescInput").value.trim();
      if (!title || !desc) {
        document.getElementById("eventTitleInput").value = "";
        document.getElementById("eventDescInput").value = "";
        let labels = addForm.getElementsByTagName("label");
        for (let i = 0; i < labels.length; i++) {
          labels[i].className = "";
        }
        return;
      }

      addEvent(title, desc);

      if (helper.selectedServiceCenter != undefined && helper.selectedService != undefined) {
        showEvents();
      }

      if (!selectedDayBlock.querySelector(".day-mark")) {
        selectedDayBlock.appendChild(document.createElement("div")).className = "day-mark";
      }

      let inputs = addForm.getElementsByTagName("input");
      for (let i = 0; i < inputs.length; i++) {
        inputs[i].value = "";
      }
      let labels = addForm.getElementsByTagName("label");
      for (let i = 0; i < labels.length; i++) {
        labels[i].className = "";
      }

    } // aqui*/
    //component.set("v.controllerFirstRun", false);
  },

  openModel: function(component, event, helper) {
    // Set isModalOpen attribute to true
    component.set("v.isModalOpenExistingCitation", true);
  },

  closeModel: function(component, event, helper) {
    // Set isModalOpen attribute to false  
    component.set("v.isModalOpenExistingCitation", false);
  },
  
  closeModelCase: function(component, event, helper) {
    // Set isModalOpen attribute to false  
    component.set("v.isModalNewCase", false);
  },
  closeModelConfirmation: function(component, event, helper) {
    console.log("helper.countdown");
    
    var intervalId = component.get("v.setIntervalId");
    console.log(intervalId);
    window.clearInterval(intervalId);
    clearInterval(intervalId);

    // Set isModalOpen attribute to false  
    component.set("v.isModalOpenConfirmation", false);
    helper.resetContador(component, event, helper);
    var serviceCenter = component.get("v.selTabId");
    var startDateHour = component.get("v.startDateHour");
    console.log('======================releaseHoursAvailability=========================');
        console.log(serviceCenter);
        console.log(startDateHour);
    var action = component.get("c.releaseHoursAvailability");
    action.setParams({
      
      "calendarId" : serviceCenter,
      "horaSelc" : startDateHour          
    });
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var storeResponse = response.getReturnValue();  
        console.log(storeResponse);      
        component.set("v.horasReservas", storeResponse);
        console.log('corre conexion h 7');
      } else {
        console.log("error");
        console.log(response.getError());
      }

    });
    $A.enqueueAction(action);
    
    helper.countdown = false;
    helper.showAllBeforeCalendar(component, event, helper);
  },

  submitDetails: function(component, event, helper) {
    // Set isModalOpen attribute to false
    //Add your code to call apex method or do some processing
    component.set("v.isModalOpenExistingCitation", false);
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
  closeModelNoCita: function(component, event, helper) {
    // Set isModalOpen attribute to false  
    component.set("v.isModalLibreDeCitas", false);
  },
  closeModalTerminos: function(component, event, helper) {
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
    //PROCESO PARA CARGA DE PLACAS Y CORREOS
    document.getElementById("vehiculosYcorreos").style.display = "";
    //document.getElementById("terminosYcondiciones").style.display = "none";                        
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
})