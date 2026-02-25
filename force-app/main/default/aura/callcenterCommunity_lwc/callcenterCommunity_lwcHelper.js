({
    /* Start of Global variables _________________________________________________________________________________________________*/
    availability: [],
    esSincronica:null,
    listaEvenotsGlobalesFinal: [],
    countdown: null,
    eventosExistentes: [],
    yaCeros: {},
    servicioRelease:null,
    fechaRelease:null,
    serviceCenter: null,
    horas_: {
      "12:00 AM": "Available",
      "12:30 AM": "Available",
      "1:00 AM": "Available",
      "1:30 AM": "Available",
      "2:00 AM": "Available",
      "2:30 AM": "Available",
      "3:00 AM": "Available",
      "3:30 AM": "Available",
      "4:00 AM": "Available",
      "4:30 AM": "Available",
      "5:00 AM": "Available",
      "5:30 AM": "Available",
      "6:00 AM": "Available",
      "6:30 AM": "Available",
      "7:00 AM": "Available",
      "7:30 AM": "Available",
      "8:00 AM": "Available",
      "8:30 AM": "Available",
      "9:00 AM": "Available",
      "9:30 AM": "Available",
      "10:00 AM": "Available",
      "10:30 AM": "Available",
      "11:00 AM": "Available",
      "11:30 AM": "Available",
      "12:00 PM": "Available",
      "12:30 PM": "Available",
      "1:00 PM": "Available",
      "1:30 PM": "Available",
      "2:00 PM": "Available",
      "2:30 PM": "Available",
      "3:00 PM": "Available",
      "3:30 PM": "Available",
      "4:00 PM": "Available",
      "4:30 PM": "Available",
      "5:00 PM": "Available",
      "5:30 PM": "Available",
      "6:00 PM": "Available",
      "6:30 PM": "Available",
      "7:00 PM": "Available",
      "7:30 PM": "Available",
      "8:00 PM": "Available",
      "8:30 PM": "Available",
      "9:00 PM": "Available",
      "9:30 PM": "Available",
      "10:00 PM": "Available",
      "10:30 PM": "Available",
      "11:00 PM": "Available",
      "11:30 PM": "Available"
    },
    asesoresXcomunidad: null,
    mecanicosXespacio: null,
    horasList :["12:00 AM", "12:30 AM", "1:00 AM", "1:30 AM", "2:00 AM", "2:30 AM", "3:00 AM", "3:30 AM", "4:00 AM", "4:30 AM", "5:00 AM", "5:30 AM", "6:00 AM", "6:30 AM", "7:00 AM", "7:30 AM", "8:00 AM", "8:30 AM", "9:00 AM", "9:30 AM", "10:00 AM", "10:30 AM", "11:00 AM", "11:30 AM", "12:00 PM", "12:30 PM", "1:00 PM", "1:30 PM", "2:00 PM", "2:30 PM", "3:00 PM", "3:30 PM", "4:00 PM", "4:30 PM", "5:00 PM", "5:30 PM", "6:00 PM", "6:30 PM", "7:00 PM", "7:30 PM", "8:00 PM", "8:30 PM", "9:00 PM", "9:30 PM", "10:00 PM", "10:30 PM", "11:00 PM", "11:30 PM"],
    horas: {
      "12:00 AM": 0,
      "12:30 AM": 0,
      "1:00 AM": 0,
      "1:30 AM": 0,
      "2:00 AM": 0,
      "2:30 AM": 0,
      "3:00 AM": 0,
      "3:30 AM": 0,
      "4:00 AM": 0,
      "4:30 AM": 0,
      "5:00 AM": 0,
      "5:30 AM": 0,
      "6:00 AM": 0,
      "6:30 AM": 0,
      "7:00 AM": 0,
      "7:30 AM": 0,
      "8:00 AM": 0,
      "8:30 AM": 0,
      "9:00 AM": 0,
      "9:30 AM": 0,
      "10:00 AM": 0,
      "10:30 AM": 0,
      "11:00 AM": 0,
      "11:30 AM": 0,
      "12:00 PM": 0,
      "12:30 PM": 0,
      "1:00 PM": 0,
      "1:30 PM": 0,
      "2:00 PM": 0,
      "2:30 PM": 0,
      "3:00 PM": 0,
      "3:30 PM": 0,
      "4:00 PM": 0,
      "4:30 PM": 0,
      "5:00 PM": 0,
      "5:30 PM": 0,
      "6:00 PM": 0,
      "6:30 PM": 0,
      "7:00 PM": 0,
      "7:30 PM": 0,
      "8:00 PM": 0,
      "8:30 PM": 0,
      "9:00 PM": 0,
      "9:30 PM": 0,
      "10:00 PM": 0,
      "10:30 PM": 0,
      "11:00 PM": 0,
      "11:30 PM": 0
    },
    horasAv: {
      "12:00 AM": 1,
      "12:30 AM": 1,
      "1:00 AM": 1,
      "1:30 AM": 1,
      "2:00 AM": 1,
      "2:30 AM": 1,
      "3:00 AM": 1,
      "3:30 AM": 1,
      "4:00 AM": 1,
      "4:30 AM": 1,
      "5:00 AM": 1,
      "5:30 AM": 1,
      "6:00 AM": 1,
      "6:30 AM": 1,
      "7:00 AM": 1,
      "7:30 AM": 1,
      "8:00 AM": 1,
      "8:30 AM": 1,
      "9:00 AM": 1,
      "9:30 AM": 1,
      "10:00 AM": 1,
      "10:30 AM": 1,
      "11:00 AM": 1,
      "11:30 AM": 1,
      "12:00 PM": 1,
      "12:30 PM": 1,
      "1:00 PM": 1,
      "1:30 PM": 1,
      "2:00 PM": 1,
      "2:30 PM": 1,
      "3:00 PM": 1,
      "3:30 PM": 1,
      "4:00 PM": 1,
      "4:30 PM": 1,
      "5:00 PM": 1,
      "5:30 PM": 1,
      "6:00 PM": 1,
      "6:30 PM": 1,
      "7:00 PM": 1,
      "7:30 PM": 1,
      "8:00 PM": 1,
      "8:30 PM": 1,
      "9:00 PM": 1,
      "9:30 PM": 1,
      "10:00 PM": 1,
      "10:30 PM": 1,
      "11:00 PM": 1,
      "11:30 PM": 1
    },
    services: {
      "Mecánica Rápida": [{
        "Label": "Escazú",
        "value": "0054U000009hipBQAQ"
      }, {
        "Label": "Motorrad",
        "value": "0054U000009hiw2QAA"
      }, {
        "Label": "Pinares",
        "value": "0054U000009hiwHQAQ"
      }, {
        "Label": "Uruca",
        "value": "0054U000009hiwMQAQ"
      }],
      "Diagnóstico": [{
        "Label": "Motorrad",
        "value": "0054U000009hiwCQAQ"
      }],
      "Mecánica General": [{
        "Label": "Uruca",
        "value": "0054U000009hiwRQAQ"
      }],
      "Otobai": [{
        "Label": "Motorrad",
        "value": "0054U00000Bes4GQAR"
      }],
      "Enderezado y Pintura": [{
        "Label": "Uruca",
        "value": "0054U000009hiwWQAQ"
      }],
      "Avaluos Aseguradoras": [{
        "Label": "Uruca",
        "value": "0054U00000Dyaj4QAB"
      }],
      "Reparaciones Aseguradoras": [{
        "Label": "Uruca",
        "value": "0054U00000DyaiGQAR"
      }],
      "Reparaciones Sin Seguro": [{
        "Label": "Uruca",
        "value": "005PH000001lHW9YAM"
      }]
    },
    locations: {
      '0054U000009hiw2QAA': 'Motorrad',
      "0054U000009hiwHQAQ": "Pinares",
      "0054U000009hiwMQAQ": "Uruca",
      "0054U000009hiwCQAQ": "Motorrad",
      "0054U000009hiwRQAQ": "Uruca",
      "0054U00000Bes4GQAR": "Motorrad",
      "0054U000009hiwWQAQ": "Uruca",
      "0054U000009hipBQAQ": "Escazú",
      "005PH000000UgHxYAK": "Uruca",
      "0054U00000Dyaj4QAB": "Uruca",
      "0054U00000DyaiGQAR": "Uruca",
      "005PH000001lHW9YAM": "Uruca"
    },
    capacityBySucursal: {},
    cmp: '',
    additionalServices: {
      "Inspección vehículo": false,
      "Servicio aceite": false,
      "Pastillas de frenos": false,
      "Discos de frenos": false,
      "Batería": false,
      "Servicio aceite y Microfiltro": false,
      "Cambiar ambas escobillas": false,
      "Filtro de aire": false,
      "Alineado y Balanceo de llantas": false,
    },
    subServiceWasSelected: false,
    dataStructuresByServiceCenter: {},
    /*
     * DSBSC = dataStructuresByServiceCenter =-> DSBSC[i][0] = listOfEvents;  
     * DSBSC[i][1] = listOfDays; 
     * DSBSC[i][3] = availabilityByDates;  
     * DSBSC[i][4] = citationsByDate;  
     * DSBSC[i][5] = NoAvailabilityDates;*/
    
    
    // Elements to be replicated on each Service Center.
    // eBSC[i][0] = ServiceCenterID;  eBSC[i][1] = listOfEvents;  eBSC[i][3] = availabilityByDates;  eBSC[i][4] = citationsByDate;  eBSC[i][2] = listOfDays, 
    listOfEvents: [], // Server Response with the list of events
    listOfDays: [], // List of days based on server response________________:  [25/08/2022, 26/08/2022]
    availabilityByDates: {}, // List with the available spaces by day and hour_______:  {25/08/2022: {"7:30 AM": 0, "8:00 AM": 1, "8:30AM": 2, ... }
    citationsByDate: {}, // List of citations by date from StartTime to EndTime__:   {25/08/2022: [[25/08/2022, "7:30 AM", "9:30AM"], ...]; 26/08/2022: [[26/08/2022, "8:00 AM", "8:30AM"]]
    noServiceInformation: {},
    //Horas Listas y Dias
    operatingHoursList: {},
    operatingHoursListL: {},
    operatingHoursListM: {},
    operatingHoursListMi: {},
    operatingHoursListJ: {},
    operatingHoursListV: {},
    operatingHoursListS: {},
    //proceso recurrencia
    horasRecurrencias: {},
    minutosSucursal: 0,
    operatingHoursBySucursal: {},
    quantityOfOperatingHoursBySucursal: {},
    quantityOfCurrentEventsByDay: {},
    resultVehiculeIdGlobal: {},
    resultOfSelectedVehicle:[],
    
    /*Statistics By Date*/
    statisticsByDay: {},
    colorStatisticsByDay: {},
    eventosSinEspacios: {},
    
    currentDate: '',
    selectedDate: '',
    globalEventObj: '',
    sidebar: '',
    selectedDayBlock: '',
    gridTable: '',
    selectedService: '',
    selectedServiceCenter: '',
    
    /* New Citation Variables*/
    
    
    /* End of Global variables _________________________________________________________________________________________________*/
    
    //--------------------------------------  MOSTRAR SERVICIOS -----------------------------------
    
    convertListForDropMarca: function (component, event, helper, listOfElements) {
      var listSize = listOfElements.length;
     
      var result = [];
      var resultVehiculeId = {};
      if (listSize > 0) {
        for (var i = 0; i < listSize; i++) {
          var newElement = {
            'label': listOfElements[i].Servicio_con_acentos__c,
            'value': listOfElements[i].Servicios__c,
            'description': listOfElements[i].Descripcion_de_servicio__c
          };
          var newAssetDetail = {};
          result.push(newElement);
          // console.log(result);
          //resultVehiculeId[listOfElements[i].Id] = listOfElements[i];
        }
        component.set("v.optionsService", result);
        // component.set("v.selectedValue",result[0].value);
      }
    },
    
    //-------------------- MOSTRAR SUBSERVICIOS -------------------------
    
    crearSubServicios: function (component, event, helper, listOfElements) {
      var listSize = listOfElements.length;
    
      var result = [];
      var resultVehiculeId = {};
      
      if (listSize > 0) {
        var gridTable = document.getElementById("additionalTableService");
        for (var i = 0; i < listSize; i++) {
          //   'label': storeResponse[i].Servicios__c,
          //   'value': storeResponse[i].Servicios__c,
          var newTr = document.createElement("div");
          newTr.className = "row";
          newTr.id =  listOfElements[i];
    
          var newDivInt = document.createElement("div");
          newDivInt.className = "eventCard-action";
    
          
          var currentTr = newTr.appendChild(newDivInt);
          var currentTr2 = gridTable.appendChild(newTr);
        }
      }
    },
    
    convertListForSubServ: function (component, event, helper, listOfElements) {
      var listSize = listOfElements.length;
    
      var result = [];
      var resultVehiculeId = {};
      if (listSize > 0) {
        for (var i = 0; i < listSize; i++) {   
          if(listOfElements[i] == 'Cambio de aceite'){
            document.getElementById("cambioAceite").style.display = "";         
          }     
          if(listOfElements[i] == 'Cambio llantas'){
            document.getElementById("cambioLlantas").style.display = "";         
          } 
          if(listOfElements[i] == 'Cambio Frenos y/o Discos'){
            document.getElementById("cambioFrenos").style.display = "";         
          }     
          if(listOfElements[i] == 'Líquido de frenos'){
            document.getElementById("liquidoFrenos").style.display = "";         
          }   
          if(listOfElements[i] == 'Filtro de aire'){
            document.getElementById("filtroAire").style.display = "";         
          }   
          if(listOfElements[i] == 'Microfiltros A/C'){
            document.getElementById("microfiltrosAc").style.display = "";         
          }  
          if(listOfElements[i] == 'Batería'){
            document.getElementById("bateria").style.display = "";         
          }   
          if(listOfElements[i] == 'Cambio de escobillas  '){
            document.getElementById("cambioEscobillas").style.display = "";         
          } 
          if(listOfElements[i] == 'Alineado/Balanceo de llantas'){
            document.getElementById("alineadoLlantas").style.display = "";         
          } 
          //console.log(listOfElements);        
        }
        //change subservicios
        //component.set("v.optionsService", result);
      }
    },
    
    controlUndefinedValues: function(value){
      if(value ==='' || value===null || value ===undefined){
          return 'N/I';
      }
      return value;
    },
    handleGetVehiculeCitations: function (component, event, helper) {
      console.log('entro handleGetVehiculeCitations');
      var vehicleIdd = component.get("v.vehicleId").toString();
      var action = component.get("c.getNextVehiculeIdCitation");
    
      action.setParams({
        vehiculeId: vehicleIdd
      });
      action.setCallback(this, function (response) {
        var state = response.getState();
    
        if (state === "SUCCESS") {
          var storeResponse = response.getReturnValue();
          if (storeResponse != '') {
            component.set("v.vehiculeIdEvent", storeResponse);
            document.getElementById("vehiculeIdSoonEvent").style.display = "";
            component.set("v.isModalOpenExistingCitation", true);
            //document.getElementById("container").style.display = "none";
            console.log('corre conexion h 1');
          } else {
            document.getElementById("vehiculeIdSoonEvent").style.display = "none";
            component.set("v.isModalOpenExistingCitation", false);
    
          }
        }
      });
      $A.enqueueAction(action);
      console.log('salio handleGetVehiculeCitations');
    },
    
    /* Start of Functions to support view behaviour ___________________________________________________________________________________________________________*/
    
    findSelectedDayAvailability: function (component,formattedDate, serviceCenter) {
      console.log('entro findSelectedDayAvailability');
      //DSBSC = dataStructuresByServiceCenter =-> DSBSC[i][0] = listOfEvents;  DSBSC[i][1] = listOfDays; DSBSC[i][3] = availabilityByDates;  DSBSC[i][4] = citationsByDate;
      var serviceCenter = '';
      serviceCenter = component.get("v.selTabId");
      this.serviceCenter = component.get("v.selTabId");
      
      // console.log(this.dataStructuresByServiceCenter);
      // console.log('serviceCenter ' + serviceCenter );
      
      var availabilityByDates = this.dataStructuresByServiceCenter.get(serviceCenter);//este esta mal
      // console.log(this.dataStructuresByServiceCenter.get(serviceCenter));
      // console.log('availabilityByDates findSelectedDayAvailability');
      // console.log(availabilityByDates);
      var elementToEvaluate = availabilityByDates[2];
      // console.log('elementToEvaluate findSelectedDayAvailability' );
      // console.log(elementToEvaluate);
      if (availabilityByDates[2][formattedDate] === undefined) {
        availabilityByDates[2][formattedDate] = this.horasAv;
      }
      
      // console.log('salio findSelectedDayAvailability');
      // console.log(availabilityByDates[2][formattedDate]);
      return availabilityByDates[2][formattedDate];
    },
    
    loadDayAvailability: function (component, formattedDate, globalEventObj) {
      console.log('entro loadDayAvailability');
      // var selectedSucursal = component.get("v.selectedSucursal");
      // this.serviceCenter = selectedSucursal;
      
    
      var serviceCenter = '';
      serviceCenter = component.get("v.serviceSelected");
      // console.log('serviceCenter loadDayAvailability ' + serviceCenter);
    
      var dayAvailability = this.findSelectedDayAvailability(component,formattedDate, serviceCenter);
      //  console.log('dayAvailability loadDayAvailability ');
      //  console.log(dayAvailability);
      
      if (dayAvailability != undefined || dayAvailability != null) {
        var keysOfDays = Object.keys(dayAvailability);
        var listaTamao = Object.keys(dayAvailability).length - 1;
        //console.log(listaTamao);
        var tieneNegativo = false;
        var tieneCero = false;
        for(var j = 0; j <= listaTamao; j++){
          if(dayAvailability[keysOfDays[j]] < 0 ){
            tieneNegativo = true;
          }else if (dayAvailability[keysOfDays[j]] == 0 ){
            tieneCero = true;
          }
        }
    
        //  console.log(tieneNegativo);
        //  console.log(tieneCero);
        if(tieneNegativo == true && tieneCero != true){
          //console.log('Entro sumar')
          var listaTamao2 = Object.keys(dayAvailability).length - 1;
          //console.log(listaTamao2);
          for(var k = 0; k <= listaTamao2; k++){
            if(dayAvailability[keysOfDays[k]] < 0 ){
              dayAvailability[keysOfDays[k]] = 0;
            }
            else if(dayAvailability[keysOfDays[k]] == 0){
              dayAvailability[keysOfDays[k]] = 1;
            }
          }
          console.log(dayAvailability);
        }
        // TRATAR DE CUBRIR LO DE LOS HORARIOS
        var cantidadMinutos =  this.minutosSucursal;
        console.log('cantidadMinutos ' + cantidadMinutos )
        var quitarBloque = cantidadMinutos / 30;
        quitarBloque = quitarBloque + 1;
        console.log('quitarBloque ' + quitarBloque )
        console.log('=======================PROCESOS DE SALTO DE BLOQUES===============================');
       // Convert object into an array for easier manipulation
       var dayAvailabilityArray = Object.entries(dayAvailability);
       // Loop through the array to check for available slots and update accordingly
       for (var l = 0; l < dayAvailabilityArray.length; l++) {
           var [time, availability] = dayAvailabilityArray[l];
    
           // Check if the slot is available
           if (availability > 0) {
               var hasEnoughTime = true;
    
               // Check if there's enough time before a 0 slot (90 minutes)
               for (var m = 1; m < quitarBloque; m++) {
                   if (l + m >= dayAvailabilityArray.length || dayAvailabilityArray[l + m][1] <= 0) {
                       hasEnoughTime = false;
                       break;
                   }
               }
    
               // Update availability if there isn't enough time
               if (!hasEnoughTime) {
                   dayAvailabilityArray[l][1] = 0;
               }
           }
       }
    
       // Create a new object from the modified array
       var updatedDayAvailability = Object.fromEntries(dayAvailabilityArray);
       
       // Assign the modified data back to the dayAvailability variable
       dayAvailability = updatedDayAvailability;
        console.log('=======================FINAL PROCESOS DE SALTO DE BLOQUES===============================');
        // Create a new object from the modified array
        console.log(formattedDate);
        console.log(updatedDayAvailability);
        // 
        // console.log(dayAvailability);
    
        
        // console.log('entro if  dayAvailability ');
        var keysOfDays = Object.keys(dayAvailability);
        //console.log('=====================keysOfDays=======================');
        var keysSize = Object.keys(dayAvailability).length - 1;
        //console.log('=====================keysSize=======================');
        for (var i = 0; i <= keysSize; i++) {
          if (dayAvailability[keysOfDays[i]] > 0) {
            this.globalEventObj = this.addEvent(keysOfDays[i], dayAvailability[keysOfDays[i]], globalEventObj, formattedDate);
          }
        }
        console.log('salio if  dayAvailability loadDayAvailability');
        return this.globalEventObj;
    
      }
      console.log('salio loadDayAvailability');
      return "No events";
      
    },
    
    addEvent: function (title, desc, globalEventObj, selectedDate) {
    
      if (selectedDate != undefined) {
        if (!globalEventObj[selectedDate]) {
          globalEventObj[selectedDate] = {};
        }
        globalEventObj[selectedDate][title] = desc;
        this.globalEventObj = globalEventObj;
        return this.globalEventObj;
      }
    },
    
    showAllBeforeCalendar: function (component, event, helper) {
      document.getElementById("container").style.display = "";
      document.getElementById('sidebar').style.display = "";
      //document.getElementById('testJD').style.display = "";
    },
    
    
    /* End of Functions to support view behaviour ________________________________________________________________________________________________________________*/
    
    
    
    /* Start of Functions to support view behaviour _____________________________________________________________________________________________________________*/
    
    checkValue: function () {
      for (let key in this.additionalServices) {
        if (this.additionalServices[key] == true) {
          return true;
        }
      }
      return false;
    },
    
    // To set if a subservice was selected.
    setSubServiceSelection: function (component, value) {
      var vehicleSelected = component.get("v.vehicleSelected");
      var additionalComments = component.get("v.additionalComments");
    
      if (this.checkValue()) { // Subservicios seleccionados
          this.subServiceWasSelected = value;
          if (vehicleSelected != "") { // Quito el mensaje y muestro picklist
              document.getElementById("errorMessage").style.display = "none";
              document.getElementById("vehicleSelection").style.display = "";
              document.getElementById("ownVehicule").style.display = "";
          }
      }
        else { // Subservicios no seleccionados
            this.subServiceWasSelected = false;
            if (additionalComments === "" || additionalComments === undefined || additionalComments === null) {
                document.getElementById("errorMessage").style.display = "";
                document.getElementById("vehicleSelection").style.display = "none";
                document.getElementById("ownVehicule").style.display = "none";
            }else {
                document.getElementById("errorMessage").style.display = "none";
                document.getElementById("vehicleSelection").style.display = "";
                document.getElementById("ownVehicule").style.display = "";
      
            }
      }
    
    },
    
    
    /* Start Calendar functions______________________________________________________*/
    
    //Done ---------------------
    //Returns the calendar associated to the asesor.
    findCalendarName: function (asesor, asesoresByCalendar) {
      var asxcalendarSize = asesoresByCalendar.length - 1;
      for (var i = 0; i <= asxcalendarSize; i++) {
        
        if (asesoresByCalendar[i]["Asesor__c"] === asesor || asesoresByCalendar[i]["Calendario__c"] === asesor) {
          return asesoresByCalendar[i]["Calendario__c"];
        }
      }
      return "";
    },
    
    //Done ---------------------
    //Join the list of events and the calendar Id. 
    joinEventsAndAsesores: function (helper, asesoresByCalendar, eventResults) {
    
      var eventsSize = eventResults.length - 1;
      for (var i = 0; i <= eventsSize; i++) {
        var calendarName = this.findCalendarName(eventResults[i][3], asesoresByCalendar);
        // console.log('calendarName');
        // console.log(calendarName);
        eventResults[i].push(calendarName);
      }
    },
    
    
    findOperatingHours: function (sucursal) {
       console.log('entro findOperatingHours');
      console.log(this.operatingHoursList);
      var oppsHours = this.operatingHoursList;
      var oppsSize = oppsHours.length;
      // console.log(oppsHours);
      // console.log(oppsSize);
      console.log(sucursal);
      for (var i = 0; i <= oppsSize + 1; i++) {
        if (oppsHours[i][1] === sucursal) {
          return oppsHours[i];
        }
      }
       console.log('salio findOperatingHours');
      return null;
    },
    
    
    adaptHoursToOperatingHoursBySucursal: function (horas, sucursal) {
    
      //  console.log('=================================adaptHoursToOperatingHoursBySucursal==============================');
      //  console.log(horas);
    
      var horasCopy = JSON.parse(JSON.stringify(horas));
      var operativeHours = this.findOperatingHours(sucursal); // Should return something like this: ['0054U000009hipBQAQ', '0Hh8N00000005nZSAQ', '8:00 AM', '5:00 PM']
    
      var startHour = operativeHours[2];
      var startingPosition = Object.keys(horasCopy).indexOf(startHour)-1;
      var endHour = operativeHours[3];
      var endingPosition = Object.keys(horasCopy).indexOf(endHour)-1;
      var keys = Object.keys(horasCopy);
      var keysSize = keys.length - 1;
      //  console.log(horasCopy);
      //  console.log(operativeHours);
      //  console.log(startHour);
      //  console.log(endHour);
      //  console.log(startingPosition);
      //  console.log(endingPosition);
      //  console.log(keys);
      if (startingPosition >= 0) { // Changed here
        for (var position = 0; position < startingPosition; position++) {
          horasCopy[keys[position]] = -1;
        }
      }
      //console.log('====================== horasCopy ======================');
      //console.log(horasCopy);
      if (endingPosition <= keysSize) { // Changed here
        for (var position = endingPosition; position <= keysSize; position++) {
          horasCopy[keys[position]] = -1;
        }
      }
      // console.log(horasCopy);
      this.operatingHoursBySucursal[sucursal] = horasCopy;
      this.quantityOfOperatingHoursBySucursal[sucursal] = endingPosition - startingPosition;
      return horasCopy;
    },
    //inicio proceso semanal
    //this.horas, currentSucursal
    adaptHoursWeekly: function (horas, sucursal, diaSemana) {
      //console.log('================================adaptHoursWeekly================================');
      var horasCopy = JSON.parse(JSON.stringify(horas));
      var operativeHours = this.findOperatingHourSemanal(sucursal,diaSemana); // Should return something like this: ['0054U000009hipBQAQ', '0Hh8N00000005nZSAQ', '8:00 AM', '5:00 PM']
      // console.log(' operativeHours');
      // console.log(operativeHours);
      // console.log(' horasCopy');
      // console.log(horasCopy);
    
      var cantidadMinutos =  this.minutosSucursal;
      var quitarBloques = cantidadMinutos / 30;
      quitarBloques = quitarBloques + 1;
      // console.log(' cantidadMinutos');
      // console.log(cantidadMinutos);
      // console.log(' quitarBloques');
      // console.log(quitarBloques);
      var startHour = operativeHours[2];
      var startingPosition = Object.keys(horasCopy).indexOf(startHour)-1;
      var endHour = operativeHours[3];
      var endingPosition = Object.keys(horasCopy).indexOf(endHour) - quitarBloques;
      
      var keys = Object.keys(horasCopy);
      var keysSize = keys.length - 1;
    
      if (startingPosition >= 0) { // Changed here
        for (var position = 0; position < startingPosition; position++) {
          horasCopy[keys[position]] = -1;
        }
      }
    
      if (endingPosition <= keysSize) { // Changed here
        for (var position = endingPosition; position <= keysSize; position++) {
          horasCopy[keys[position]] = -1;
        }
      }
      this.operatingHoursBySucursal[sucursal] = horasCopy;
      // console.log(sucursal);
      // console.log(startingPosition);
      // console.log(endingPosition);
      
      this.quantityOfOperatingHoursBySucursal[sucursal] = endingPosition - startingPosition;
      //console.log(' salio adaptHoursWeekly');
      return horasCopy;
    },
    
    findOperatingHourSemanal: function (sucursal,diaSemana) {
      console.log('entro findOperatingHourSemanal');
      var oppsHours = this.operatingHoursList;
      if(diaSemana == 1){
         oppsHours = this.operatingHoursListL;
      }else if(diaSemana == 2){
         oppsHours = this.operatingHoursListM;
      }else if(diaSemana == 3){
         oppsHours = this.operatingHoursListMi;
      }else if(diaSemana == 4){
         oppsHours = this.operatingHoursListJ;
      }else if(diaSemana == 5){
         oppsHours = this.operatingHoursListV;
      }else if(diaSemana == 6){
         oppsHours = this.operatingHoursListS;
      }
      
      var oppsSize = oppsHours.length;
    
      for (var i = 0; i <= oppsSize + 1; i++) {
        if (oppsHours[i][1] === sucursal) {
          return oppsHours[i];
        }
      }
      console.log('salio findOperatingHourSemanal');
      return null;
    },
    
    //fin procesos semanal
    
    checkHourInOperativeHour: function (hour,formateDate) {
      console.log('==========================checkHourInOperativeHour==================================');
      console.log(hour);
      
      //proceso de horas
      var minutos = '';
      var d = new Date();
      var tiempoAct ;
      var formattedDate2 = d.getFullYear() + '-' + String(d.getMonth() + 1).padStart(2, '0') + '-' + String(d.getDate()).padStart(2, '0');
      console.log(formattedDate2);
      d.getHours(); // => 9
      d.getMinutes(); // =>  30
      d.getSeconds(); // => 51
      if( d.getMinutes() > 30){
        minutos = '30';
      }else{
        minutos = '00';
      }
      if( d.getHours() >= 12 ){
        var horaActual =  d.getHours()-12 + ':' +minutos + ' PM'; 
        tiempoAct = 'PM';
      }else{
        var horaActual =  d.getHours() + ':' +minutos + ' AM' ; 
        tiempoAct = 'AM';
      }
       console.log(horaActual);
      var minutosSucursales = this.minutosSucursal;
      var selectedService = this.selectedServiceCenter;
      var operativeHoursBySucursal = this.operatingHoursBySucursal[selectedService];
    
      var fechaSeleccionada = new Date(formateDate);
      var weekday =  fechaSeleccionada.getDay();
      var queRegresa = false;
    
      //var horasRec = component.get("v.selTabId") ;
      var listaRec = this.horasRecurrencias;
       console.log('==================listaRec====================');
       console.log(listaRec);
      // console.log(operativeHoursBySucursal);
      // console.log(formateDate);
      // console.log(formattedDate2 == formateDate);
      // console.log(hour.includes("AM"));
      // console.log(tiempoAct);
      // console.log(horaActual);
      //  console.log(hour);
      //  console.log(horaActual);
      // console.log(this.isTimeGreaterThan(hour,horaActual))
      if(formattedDate2 == formateDate){
        console.log('dentro formattedDate2 == formateDate');
        if(hour.includes("AM") && tiempoAct != "PM"){
          if(this.isTimeGreaterThan(hour,horaActual)){
    
            if (operativeHoursBySucursal[hour] != -1) {
              if(listaRec.length < 0){
                for(var j=0; j<listaRec.length; j++){
                  if(listaRec[j][0] == selectedService){
                    
                    if(hour >= listaRec[j][1] && hour < listaRec[j][2]){
                      if(weekday == 0 && listaRec[j][3]){
                        console.log('es Lunes');
                      }else if (weekday == 1 && listaRec[j][4]){
      
                      }else if (weekday == 2 && listaRec[j][5]){
      
                      }else if (weekday == 3 && listaRec[j][6]){
      
                      }else if (weekday == 4 && listaRec[j][7]){
      
                      }else if (weekday == 5 && listaRec[j][8]){
      
                      }else{
                        return true;
                      }             
                    } else{
                      return true;
                    }               
                  }else{
                    return true;
                  }
                }       
              }else{
                return true;
              }
            }
    
          }
          
        }else if(hour.includes("PM") && tiempoAct != "AM"){
          console.log('dentro if else');
          if(this.isTimeGreaterThan(hour,horaActual)){
            if (operativeHoursBySucursal[hour] != -1) {
              if(listaRec.length < 0){
                for(var j=0; j<listaRec.length; j++){
                    // console.log('========================== Hour' + hour);
                    // console.log(listaRec[j][1]);
                    // console.log(listaRec[j][3]);
                    // console.log(hour >= listaRec[j][1]);
                    // console.log(hour <= listaRec[j][2]);
                  if(listaRec[j][0] == selectedService){
                    if(hour >= listaRec[j][1] && hour < listaRec[j][2]){
                      if(weekday == 0 && listaRec[j][3]){
                        //console.log('es Lunes');
                      }else if (weekday == 1 && listaRec[j][4]){
      
                      }else if (weekday == 2 && listaRec[j][5]){
      
                      }else if (weekday == 3 && listaRec[j][6]){
      
                      }else if (weekday == 4 && listaRec[j][7]){
      
                      }else if (weekday == 5 && listaRec[j][8]){
      
                      }else{
                        return true;
                      }                
                    }   else{
                      return true;
                    }
                  }else{
                    return true;
                  }
                }  
              }else{
                return true;
              }
            }
          }
        }
        
      }else{
        console.log('dentro else');
        //console.log('dentro else formattedDate2 == formateDate')
        console.log('paso if resta');
        if (operativeHoursBySucursal[hour] != -1) {
          console.log('paso if resta');
          //console.log('dentro operativeHoursBySucursal[hour] != -1');
          if(listaRec.length < 0){
            console.log('paso if tamaño');
            //console.log('dentro listaRec.length');
            for(var j=0; j<listaRec.length; j++){
              
              if(listaRec[j][0] == selectedService){
                console.log('=============listaRec[j]=============');
                console.log(listaRec[j]);
                console.log('=============hour=============');
                console.log(hour);
                console.log('=============String(listaRec[j][1])=============');
                console.log(listaRec[j][1]);
                console.log(hour >= listaRec[j][1]);
                console.log('=============listaRec[j][2]=============');
                console.log(listaRec[j][2]);
                console.log(hour <= listaRec[j][2]);
                console.log('=============weekday=============');
                console.log(weekday);
                if(hour >= listaRec[j][1] && hour < listaRec[j][2]){
                  if(weekday == 0 && listaRec[j][3]){
                    console.log('es Lunes');
                    return false;
                  }else if (weekday == 1 && listaRec[j][4]){
                    console.log('es Martes');
                    return false;
                  }else if (weekday == 2 && listaRec[j][5]){
                    console.log('es Miercoles');
                    return false;
                  }else if (weekday == 3 && listaRec[j][6]){
                    console.log('es Lunes');
                    return false;
                  }else if (weekday == 4 && listaRec[j][7]){
                    console.log('es Lunes');
                    return false;
                  }else if (weekday == 5 && listaRec[j][8]){
                    console.log('es Lunes');
                    return false;
                  }else{
                    return true;
                  }               
                }  else{
                  queRegresa = true; 
                } 
              }else{
                queRegresa = true;              
              }
            }
            return queRegresa;
            console.log('salio semanal');
          }else{
            return true;
          }
            
        }
    
      }
      
      
        
      return false;
    },
    
    checkHourInOperativeHourNull: function (hour,formateDate,lstEventos) {
      //console.log('==========================checkHourInOperativeHourNull==================================');
      //console.log(hour);
      
      //proceso de horas
      var minutos = '';
      var d = new Date();
      var tiempoAct ;
      var formattedDate2 = d.getFullYear() + '-' + String(d.getMonth() + 1).padStart(2, '0') + '-' + String(d.getDate()).padStart(2, '0');
      //console.log(formattedDate2);
      d.getHours(); // => 9
      d.getMinutes(); // =>  30
      d.getSeconds(); // => 51
      if( d.getMinutes() > 30){
        minutos = '30';
      }else{
        minutos = '00';
      }
      if( d.getHours() >= 12 ){
        var horaActual =  d.getHours()-12 + ':' +minutos + ' PM'; 
        tiempoAct = 'PM';
      }else{
        var horaActual =  d.getHours() + ':' +minutos + ' AM' ; 
        tiempoAct = 'AM';
      }
       //console.log(horaActual);
      var minutosSucursales = this.minutosSucursal;
      var selectedService = this.selectedServiceCenter;
      var operativeHoursBySucursal = lstEventos;
    
      var fechaSeleccionada = new Date(formateDate);
      var weekday =  fechaSeleccionada.getDay();
      var queRegresa = false;
    
      //var horasRec = component.get("v.selTabId") ;
      var listaRec =  this.horasRecurrencias;
       //console.log('==================listaRec====================');
    // console.log(listaRec);
    // console.log(operativeHoursBySucursal);
    // console.log(formateDate);
    // console.log(formattedDate2 == formateDate);
    // console.log(hour.includes("AM"));
    // console.log(tiempoAct);
    // console.log(horaActual);
    //  console.log(hour);
    //  console.log(horaActual);
    // console.log(this.isTimeGreaterThan(hour,horaActual))
    if(formattedDate2 == formateDate){
      //console.log('dentro formattedDate2 == formateDate');
      if(hour.includes("AM") && tiempoAct != "PM"){
        if(this.isTimeGreaterThan(hour,horaActual)){
  
          if (operativeHoursBySucursal[hour] != -1) {
            if(listaRec.length < 0){
              for(var j=0; j<listaRec.length; j++){
                if(listaRec[j][0] == selectedService){
                  
                  if(hour >= listaRec[j][1] && hour < listaRec[j][2]){
                    if(weekday == 0 && listaRec[j][3]){
                      //console.log('es Lunes');
                    }else if (weekday == 1 && listaRec[j][4]){
    
                    }else if (weekday == 2 && listaRec[j][5]){
    
                    }else if (weekday == 3 && listaRec[j][6]){
    
                    }else if (weekday == 4 && listaRec[j][7]){
    
                    }else if (weekday == 5 && listaRec[j][8]){
    
                    }else{
                      return true;
                    }             
                  } else{
                    return true;
                  }               
                }else{
                  return true;
                }
              }       
            }else{
              return true;
            }
          }
  
        }
        
      }else if(hour.includes("PM") && tiempoAct != "AM"){
        //console.log('dentro if else');
        if(this.isTimeGreaterThan(hour,horaActual)){
          if (operativeHoursBySucursal[hour] != -1) {
            if(listaRec.length < 0){
              for(var j=0; j<listaRec.length; j++){
                  // console.log('========================== Hour' + hour);
                  // console.log(listaRec[j][1]);
                  // console.log(listaRec[j][3]);
                  // console.log(hour >= listaRec[j][1]);
                  // console.log(hour <= listaRec[j][2]);
                if(listaRec[j][0] == selectedService){
                  if(hour >= listaRec[j][1] && hour < listaRec[j][2]){
                    if(weekday == 0 && listaRec[j][3]){
                      //console.log('es Lunes');
                    }else if (weekday == 1 && listaRec[j][4]){
    
                    }else if (weekday == 2 && listaRec[j][5]){
    
                    }else if (weekday == 3 && listaRec[j][6]){
    
                    }else if (weekday == 4 && listaRec[j][7]){
    
                    }else if (weekday == 5 && listaRec[j][8]){
    
                    }else{
                      return true;
                    }                
                  }   else{
                    return true;
                  }
                }else{
                  return true;
                }
              }  
            }else{
              return true;
            }
          }
        }
      }
      
    }else{
      //console.log('dentro else');
      //console.log('dentro else formattedDate2 == formateDate')
      //console.log('paso if resta');
      if (operativeHoursBySucursal[hour] != -1) {
        //console.log('paso if resta');
        //console.log('dentro operativeHoursBySucursal[hour] != -1');
        if(listaRec.length < 0){
          //console.log('paso if tamaño');
          //console.log('dentro listaRec.length');
          for(var j=0; j<listaRec.length; j++){
            if(listaRec[j][0] == selectedService){
              if(hour >= String(listaRec[j][1]) && hour < listaRec[j][2]){
                if(weekday == 0 && listaRec[j][3]){
                  //console.log('es Lunes');
                }else if (weekday == 1 && listaRec[j][4]){
  
                }else if (weekday == 2 && listaRec[j][5]){
  
                }else if (weekday == 3 && listaRec[j][6]){
  
                }else if (weekday == 4 && listaRec[j][7]){
  
                }else if (weekday == 5 && listaRec[j][8]){
  
                }else{
                  return true;
                }               
              }  else{
                return true;
              } 
            }else{
              return true;
            }
          }
          //console.log('salio semanal');
        }else{
          return true;
        }
          
      }
  
    }
    
    
      
    return false;
    },

    //new method to find if current hour is greatter than the blue box one
    isTimeGreaterThan: function (time1, time2) {
      // Extract the hours, minutes, and AM/PM indicator from the time values
      const time1Parts = time1.split(/:| /);
      const time2Parts = time2.split(/:| /);
      
      let hour1 = parseInt(time1Parts[0], 10);
      const minute1 = parseInt(time1Parts[1], 10);
      const ampm1 = time1Parts[2].toUpperCase();
    
      let hour2 = parseInt(time2Parts[0], 10);
      const minute2 = parseInt(time2Parts[1], 10);
      const ampm2 = time2Parts[2].toUpperCase();
    
      // Adjust the hours based on the AM/PM indicator
      if (ampm1 === 'PM' && hour1 !== 12) {
        hour1 += 12;
      }
      
      if (ampm2 === 'PM' && hour2 !== 12) {
        hour2 += 12;
      }
    
      // Create two Date objects with the same date and the given hours and minutes
      const date = new Date();
      const dateWithTime1 = new Date(date.getFullYear(), date.getMonth(), date.getDate(), hour1, minute1, 0);
      const dateWithTime2 = new Date(date.getFullYear(), date.getMonth(), date.getDate(), hour2, minute2, 0);
    
      // Compare the time values
      return dateWithTime1 > dateWithTime2;
    },
    
    //Done ---------------------
    //Set the hours availability based on the sucursal capacity.
    setHoursCapacityBySucursal: function (currentSucursal) {
      //  console.log('=====================setHoursCapacityBySucursal=======================');
      //  console.log(currentSucursal)
      //  console.log(this.horas);
      //var operativeHour = this.adaptHoursToOperatingHoursBySucursal(this.horas, currentSucursal);
      var hoursCapacityBySucursal = JSON.parse(JSON.stringify(this.horas));
      // console.log(this.horas);
      // console.log(operativeHour);
      //console.log(hoursCapacityBySucursal);
      var keys = Object.keys(hoursCapacityBySucursal);
      var hoursCapacitySize = keys.length - 1;
     
      // console.log('=========== hoursCapacityBySucursal 1 ===========')
      // console.log(hoursCapacityBySucursal);
      for (var key in hoursCapacityBySucursal) {
        var value = hoursCapacityBySucursal[key];
        if (value === -1) {
          hoursCapacityBySucursal[key] = 0;
        } else {
          
          hoursCapacityBySucursal[key] = this.capacityBySucursal[currentSucursal];
        }
      }
      // console.log('=========== hoursCapacityBySucursal 2 ===========')
      //  console.log(hoursCapacityBySucursal);
      return hoursCapacityBySucursal;
    },
    
    //Done ---------------------
    //Define a data structure for each sucursal.
    defineDataStructuresForServiceCenters: function (listOfEvents) {
      console.log('defineDataStructuresForServiceCenters');
      console.log(this.capacityBySucursal);
      var toIterate = Object.keys(this.capacityBySucursal);
      console.log('defineDataStructuresForServiceCenters toIterate ' + toIterate);
      this.dataStructuresByServiceCenter = new Map();
      //console.log(listOfEvents);
     
      for (var i in toIterate) {
        //DSBSC = dataStructuresByServiceCenter =-> DSBSC[i][0] = listOfEvents;  DSBSC[i][1] = listOfDays; DSBSC[i][3] = availabilityByDates;  DSBSC[i][4] = citationsByDate;
        this.dataStructuresByServiceCenter.set(toIterate[i], [
          [],
          [], {}, {}, {} /* horas*/
        ]);
        console.log('==================================this.dataStructuresByServiceCenter==================================');
        console.log(this.dataStructuresByServiceCenter);
      }
      console.log('defineDataStructuresForServiceCenters dataStructuresByServiceCenter ' );
      console.log(this.dataStructuresByServiceCenter);
      console.log('defineDataStructuresForServiceCenters listOfEvents');
      console.log(listOfEvents);
  
      // var servicioSeleccionado = this.servicioSeleccionado;
      
      // var listOfAsesorXcal = this.asesoresXcalenadarios;
      console.log('=================asesoresXcalenadarios=====================');
      // console.log(listOfAsesorXcal);
      var listOfEventsSize = listOfEvents.length - 1;
      for (var i = 0; i <= listOfEventsSize; i++) {
        var idOfCalendar = listOfEvents[i][4];
        var elementToAdd = listOfEvents[i];
        if (this.dataStructuresByServiceCenter.get(idOfCalendar) != undefined) {
          var valueOfElement = this.dataStructuresByServiceCenter.get(idOfCalendar);
          valueOfElement[0].push(elementToAdd);
          this.dataStructuresByServiceCenter.set(idOfCalendar, valueOfElement);
        }
      }
      
      
      console.log('defineDataStructuresForServiceCenters dataStructuresByServiceCenter 2 ');
      console.log( this.dataStructuresByServiceCenter );
    },
      
      adaptListOfEventsToOppHours: function (listOfEvents) {
        console.log('entro adaptListOfEventsToOppHours');
        console.log('listOfEvents adaptListOfEventsToOppHours ');
        console.log(listOfEvents);
        console.log('horasList');
        //console.log(horasList); 
        console.log(this.horasList);
        var listSize = listOfEvents.length-1;
          
          for (var i = 0; i<=listSize;i++){
              
            
            if(listOfEvents[i][4] != undefined && listOfEvents[i][4] != '' ){
              var OppHour = this.findOperatingHours(listOfEvents[i][4]);
              console.log('=======================OppHourAQUI========================');
              console.log(OppHour);
              var startHourEvent = this.horasList.indexOf(listOfEvents[i][1]);
              var endHourEvent = this.horasList.indexOf(listOfEvents[i][2]);
              var oppHourStart = this.horasList.indexOf(OppHour[2]);
              
              var oppHourEnd = this.horasList.indexOf(OppHour[3]);
              
              if(startHourEvent < oppHourStart){
                //listOfEvents[i][1] = OppHour[2];'3:00 AM'
                listOfEvents[i][1] ="7:00 AM";
              }
              if(endHourEvent > oppHourEnd){
                  listOfEvents[i][2] = OppHour[3];
              }
            }
              
          }
          console.log('salio adaptListOfEventsToOppHours');
          //console.log(listOfEvents);
          return listOfEvents;
      },
    
    // Done ------------------
    // Step #0. Previous step: 
    // Just start the process.
    
    findAvailability: function (listOfEvents) { // Working... 
      console.log('entro findAvailability');
      //console.log(listOfEvents);
      /*listOfEvents = */this.adaptListOfEventsToOppHours(listOfEvents);
      console.log('paso findAvailability adaptListOfEventsToOppHours');
      this.defineDataStructuresForServiceCenters(listOfEvents); // Store elements in: this.dataStructuresByServiceCenter
      console.log('medio findAvailability');
      var serviceCenters = this.dataStructuresByServiceCenter;
      console.log(serviceCenters);
      for (let [key, value] of serviceCenters.entries()) {
        var element = value;
        element = this.listOfCitationsByDate(element, key);
        serviceCenters.set(key, element);
        
      }
      console.log('salio findAvailability');
    },
    
    // Done ------------------
    // Step #1. Previous step: Step #0
    // Based on the result of create availability by date (set the structure), add the data using setDayAvailability.
    listOfCitationsByDate: function (currentServiceCenter, serviceCenterId) {
      console.log('===============listOfCitationsByDate==============');
      var listOfDays = currentServiceCenter[1]; // listOfDays
      var listOfDaysSize = listOfDays.length;
      console.log(listOfDays);
      currentServiceCenter = this.createAvailabilityByDate(currentServiceCenter);
      var quantityOfDays = listOfDays.length - 1;
      console.log('===============currentServiceCenter==============');
      console.log(currentServiceCenter);
      for (var i = 0; i <= quantityOfDays; i++) {
        currentServiceCenter = this.setDayAvailability(currentServiceCenter, listOfDays[i], serviceCenterId); // Por arreglar.
      }
      console.log(currentServiceCenter);
      return currentServiceCenter;
    },
    
    // Done ------------------
    // Step #2. Previous step: Step #1
    // Set the possible hours for each day. Set the list of citations for each day.
    
    createAvailabilityByDate: function (serviceCenterData) { // Agrega Horas Disponibles a cada día y Crea lista de citas x día
      console.log('entro createAvailabilityByDate');
      var lOfEvents = serviceCenterData[0];
      console.log(lOfEvents);
      var eventSize2 = lOfEvents.length  - 1;
      for(var j = 0; j <= eventSize2; j++){
        if(lOfEvents[j][1] == '7:30 AM' && lOfEvents[j][2] == '7:30 AM' ){
          lOfEvents[j][1] = '7:00 AM';
        }
        if(lOfEvents[j][1] == '7:30 AM' && lOfEvents[j][2] == '6:30 AM' ){
          lOfEvents[j][1] = '7:00 AM';
          lOfEvents[j][2] = '5:00 PM';
        }
        if(lOfEvents[j][1] == '7:30 AM' && lOfEvents[j][2] == '8:00 AM' ){
          lOfEvents[j][1] = '7:00 AM';
        }
        if(lOfEvents[j][1] == '7:30 AM' && lOfEvents[j][2] == '3:30 PM' ){
          lOfEvents[j][1] = '6:00 AM';
          lOfEvents[j][2] = '6:00 PM';
        }
        if(lOfEvents[j][1] == '8:30 AM' && lOfEvents[j][2] == '9:00 AM' ){
          lOfEvents[j][1] = '8:00 AM';
        }
        if(lOfEvents[j][1] == '8:30 AM' && lOfEvents[j][2] == '3:30 PM' ){
          lOfEvents[j][1] = '8:00 AM';
        }
        if(lOfEvents[j][1] == '8:30 AM' && lOfEvents[j][2] == '8:00 AM' ){
          lOfEvents[j][1] = '8:00 AM';
          lOfEvents[j][2] = '6:00 PM';
        }
        if(lOfEvents[j][1] == '8:30 AM' && lOfEvents[j][2] == '3:30 PM' ){
          lOfEvents[j][1] = '8:00 AM';
          lOfEvents[j][2] = '6:00 PM';
        }
        if(lOfEvents[j][1] == '8:30 AM' && lOfEvents[j][2] == '8:30 AM' ){
          lOfEvents[j][1] = '8:00 AM';
        }
        if(lOfEvents[j][1] == '7:30 AM' && lOfEvents[j][2] == '5:00 PM' ){
          lOfEvents[j][1] = '7:00 AM';
        }
        if(lOfEvents[j][1] == '10:00 AM' && lOfEvents[j][2] == '10:15 AM' ){
          lOfEvents[j][2] = '10:30 AM';
        }
        if(lOfEvents[j][1] == '7:30 AM' && lOfEvents[j][2] == '2:00 PM' ){
          lOfEvents[j][1] = '7:00 AM';
        }
        if(lOfEvents[j][1] == '7:30 AM' && lOfEvents[j][2] == '4:30 PM' ){
          lOfEvents[j][1] = '7:00 AM';
        }
        if(lOfEvents[j][1] == '7:00 AM' && lOfEvents[j][2] == '2:00 PM' ){
          lOfEvents[j][1] = '12:00 PM';
        }
      }
      for(var k = 0; k <= eventSize2; k++){
        if(lOfEvents[k][1] == '3:00 PM' && lOfEvents[k][2] != '3:30 PM' ){
          lOfEvents[k][2] = '3:30 PM';
        }
        if(lOfEvents[k][1] == '3:30 PM' && lOfEvents[k][2] == '3:30 PM' ){
          lOfEvents[k][2] = '5:00 PM';
        }
        if(lOfEvents[k][1] == '8:30 AM' && lOfEvents[k][2] == '6:30 PM' ){
          lOfEvents[k][1] = '8:00 AM';
        }
        if(lOfEvents[k][1] == '8:30 AM' && lOfEvents[k][2] == '3:30 PM' ){
          lOfEvents[k][1] = '8:00 AM';
        }
        if(lOfEvents[k][1] == '8:30 AM' && lOfEvents[k][2] == '9:00 AM' ){
          lOfEvents[k][1] = '8:00 AM';
        }
        if(lOfEvents[k][1] == '8:30 AM' && lOfEvents[k][2] == '6:00 PM' ){
          lOfEvents[k][1] = '8:00 AM';
        }
        if(lOfEvents[k][1] == '8:30 AM' && lOfEvents[k][2] == '8:30 AM' ){
          lOfEvents[k][1] = '8:00 AM';
        }
        if(lOfEvents[k][1] == '1:00 PM' && lOfEvents[k][2] == '12:30 PM' ){
          lOfEvents[k][2] = '1:30 PM';
        }
        if(lOfEvents[k][1] == '12:30 PM' && lOfEvents[k][2] == '12:30 PM' ){
          lOfEvents[k][2] = '1:00 PM';
        }
        if(lOfEvents[k][1] == '7:00 AM' && lOfEvents[k][2] == '12:15 AM' ){
          lOfEvents[k][2] = '1:30 PM';
        }
        if(lOfEvents[k][1] == '7:30 AM' && lOfEvents[k][2] == '2:30 PM' ){
          lOfEvents[k][1] = '7:00 AM';
          lOfEvents[k][2] = '5:00 PM';
        }
        if(lOfEvents[k][1] == '7:00 AM' && lOfEvents[k][2] == '2:00 PM' ){
          lOfEvents[k][1] = '12:00 PM';
        }
        if(lOfEvents[k][2] == '12:15 AM' ){
          lOfEvents[k][2] = '1:30 PM';
        }
      }
    
      
      console.log('lOfEvents del ciclo');
      console.log(lOfEvents);
      var listOfDays = serviceCenterData[1];
      var availabilityByDates = serviceCenterData[2];
      var citationsByDate = serviceCenterData[3];
      var eventSize = lOfEvents.length - 1;
      for (var i = 0; i <= eventSize; i++) {
        
        var calendar = lOfEvents[i][4]; // Element with the calendarId.
        availabilityByDates[lOfEvents[i][0]] = this.setHoursCapacityBySucursal(lOfEvents[i][4]);
        if (!listOfDays.includes(lOfEvents[i][0])) {
          listOfDays.push(lOfEvents[i][0]);
        }
        // console.log('Por aqui le quito?');
        // Esta es la condicion que no está funcionando. Lo que necesito es agregar el elemento aunque ya el día esté en la lista. Debo hacerle un append a la lista del chunche.
        if (citationsByDate[lOfEvents[i][0]] != undefined) { // If the list already have the day.
          var elementToAdd = lOfEvents[i];
          citationsByDate[lOfEvents[i][0]].push(elementToAdd);
        }
        if (citationsByDate[lOfEvents[i][0]] === undefined) { // If it's added for the first time
          citationsByDate[lOfEvents[i][0]] = [lOfEvents[i]];
        }
      }
      return serviceCenterData;
    
    },
    
    // Done ------------------
    // Step #3. Previous step: Step #1.
    // Runs over the citations by date to run all the hours and set if it's available or not.
    setDayAvailability: function (currentServiceCenter, day, serviceCenterId,citations) {
      // console.log('======================= setDayAvailability ==========================');
      // console.log(serviceCenterId);
      var availabilityByDates = currentServiceCenter[2]; //availabilityByDates
      // console.log(availabilityByDates);
      var citationsByDate = currentServiceCenter[3]; //citationsByDate
      // console.log(citationsByDate);
      var citations = citationsByDate[day]; // Runs over the citations of the date
      // console.log('citations');
      // console.log(citations);
    
      
    
    
      var size = citations.length - 1;
      for (var i = 0; i <= size; i++) { // Adds to the day, what hours are available or not
        if (typeof citations[i] != "object") {
          // console.log("entro if object");
          i += 3;
          availabilityByDates[day] = this.setHoursAvailability(availabilityByDates[day], citations[1], citations[2], serviceCenterId, day);
        } else {
          // console.log("entro else object");
          if(citations[i][5]){
                      
            if(citations[i][5] != 'Asesor'){
              availabilityByDates[day] = this.setHoursAvailability(availabilityByDates[day], citations[i][1], citations[i][2], serviceCenterId, day,'');
            }else{
              
              availabilityByDates[day] = this.setHoursAvailability(availabilityByDates[day], citations[i][1], citations[i][2], serviceCenterId, day, citations[i][5]);
            }
          }else{
            availabilityByDates[day] = this.setHoursAvailability(availabilityByDates[day], citations[i][1], citations[i][2], serviceCenterId, day,'');
          }
        }
      }
      return currentServiceCenter;
    },
    
    // Done ------------------
    // Step #4. Previous step: Step #3. 
    // Runs over all the hour in the range of StartTime to EndTime to set Busy or Available este proceso CONTROLA LOS ASESORES O CALENDARIOS PARA LLENAR CON VACIOS.
    setHoursAvailability: function (hoursByDay, startTime, endTime, serviceCenterId, day,tipoCita) {
      
      var keys = Object.keys(hoursByDay);
      var startingPosition = Object.keys(hoursByDay).indexOf(startTime);
      var endingPosition = Object.keys(hoursByDay).indexOf(endTime) - 1;
      var startPositionOrdered = Object.keys(this.horas).indexOf(startTime) - 1;
      var endPositionOrdered = Object.keys(this.horas).indexOf(endTime) - 1;
      var numberOfSpaces = endPositionOrdered - startPositionOrdered;
    
      var asesoresTotales = this.asesoresXcomunidad;
      var mecanicos = this.mecanicosXespacio;
      var asesoresEspacios = 0;
      var mecanicosEspacios = 0;
    
    
      
    
    
      
       console.log(serviceCenterId);
       console.log( asesoresTotales);
       console.log(mecanicos);
    
      for (var i = 0; i < asesoresTotales.length; i++) {
        // console.log(asesoresTotales[i]);
        if(asesoresTotales[i].Id == serviceCenterId ){
          asesoresEspacios = asesoresTotales[i].expr0;
        }
      }
    
      for (var j = 0; j < mecanicos.length; j++) {
        //console.log(mecanicos[j] );
        if(mecanicos[j].Id == serviceCenterId ){
          mecanicosEspacios = mecanicos[j].Cantidad_de_Mecanicos__c;
        }
      }
    
    
      
       console.log(asesoresEspacios);
       console.log(mecanicosEspacios);
      
      var espaciosFinales = -1;
      //console.log('entro?');
    
      // if(tipoCita != null && tipoCita != ''){
      //   if(tipoCita == 'Asesor' && mecanicosEspacios > asesoresEspacios){
          
      //     //console.log(asesoresEspacios);
      //     espaciosFinales = ( asesoresEspacios - mecanicosEspacios ) - 1 ;
          
      //     //console.log(espaciosFinales);
      //   }
      // }
    
    
      // console.log('=============== proceso de Horas Servicio ===================');
      // var date = new Date(day);
      // var weekday =  date.getDay() + 1;
      
      // console.log('weekday horarios '+ weekday);
      // var operativeHours = helper.findOperatingHourSemanal(calendarioSel,weekday);
      // console.log(operativeHours);
      // var startHour = operativeHours[2];
      // var endHour = operativeHours[3];
    
    
      // var keysOfHours = Object.keys(hoursByDay);
      //  console.log(keysOfHours);
    
      //  var endingPosition = keysOfHours[keysOfHours.indexOf(endHour)-2];
      //  var startingPosition = keysOfHours[keysOfHours.indexOf(startHour)-2];
    
      //  console.log(startingPosition);
      //  console.log(endingPosition);
      //  var siHayEvento = true;
      // for(var o = 0; o < keysOfHours.length; o++){
      //  if(keysOfHours[o] != '12:00 AM' && keysOfHours[o] != '12:30 AM'){
      //    var mayorQue = helper.isTimeGreaterThan(keysOfHours[o],startingPosition);
      //    var menorQue = helper.isTimeGreaterThan(keysOfHours[o],endingPosition);
      //    if( mayorQue != true && menorQue != false ){
      //      console.log(keysOfHours[o]);
      //      console.log(hoursByDay[keysOfHours[o]]);
           
      //    }
      //  }
       
      // }
    
    
      
    
      for (var position = startingPosition; position <= endingPosition; position++) {
        console.log(position);
        console.log('hoursByDay[keys[position]]');
        console.log(hoursByDay[keys[position]]);
        hoursByDay[keys[position]] = Number(hoursByDay[keys[position]]) + espaciosFinales;
      }
    
      if (this.quantityOfCurrentEventsByDay[day] != undefined) {
        this.quantityOfCurrentEventsByDay[day] = this.quantityOfCurrentEventsByDay[day] + numberOfSpaces;
      } else {
        this.quantityOfCurrentEventsByDay[day] = numberOfSpaces;
      }
      console.log('===============setHoursAvailability================');
      console.log(keys);
      console.log(hoursByDay);
      console.log(startingPosition);
      console.log(endingPosition);
      return hoursByDay;
    },
    
    myTest: function () {
      document.getElementById("creandocita1").style.display = "none";
      document.getElementById("creandocita2").style.display = "none";
      document.getElementById("creandocita3_").style.display = "";
      component.set("v.isModalOpenFinalConfirmation", true);
      component.set("v.isModalOpenConfirmation", false);
      document.getElementById('creandocita1_').style.display = "none";
      //document.getElementById("citaCreada").style.display="";
    },
    
    /* End Calendar functions________________________________________________________________________________________________________________________*/
    
    
    
    /* Start of Server calls functions support ______________________________________________________________________________________________________*/
      
      convertDateTimeFormat: function(datetime){
          console.log(datetime);
          var date = new Date(Date.parse(datetime));
          var hour = new Date(date).getHours();
          var minute = new Date(date).getMinutes();
          var horas;
          if (hour<12){
              horas = hour.toString().padStart(2, '0') + ':' + minute.toString().padStart(2, '0') +'AM';
          }
          else{
              if(hour!=12){
                  hour = parseInt(hour) - 12;
              }
              horas = hour.toString().padStart(2, '0') + ':' + minute.toString().padStart(2, '0') +'PM';
          }
          var newdate = (date.getMonth() + 1) + '/' + date.getDate() + '/' +  date.getFullYear() + ' '+horas;
          return newdate;
          
      },
    
    // Done ------------------
    getHour: function (hour) { // Hour structure its: hh:mm AM/PM. e.g. "8:30 AM"
      var shortHour = hour.split(':')[0]; // Gets "8"
      var AMPM = hour.split(' ')[1].split(" ")[0]; // Gets "AM"
      if (AMPM === "PM" && shortHour != 12) {
        shortHour = 12 + Number(shortHour); // Convert the hour to 24h
      }
      return shortHour;
    },
    
    // Done ------------------    
    getMinute: function (hour) {
      return hour.split(':')[1].split(" ")[0]; // Gets "30 AM" and then just "30"
    },
    
    // Done ------------------ result like: {"Mecánica Rápida Uruca": x}. x= # of people.   
    convertCapacityBySucursalToJSON: function (capacityBySucursalList) {
      var sizeSucursalList = capacityBySucursalList.length;
      var newJson = {};
      for (var i = 0; i < sizeSucursalList; i++) {
        var element = capacityBySucursalList[i];
        var jsonValues = '{"' + [element.Id] + '":' + element.Cantidad_de_Mecanicos__c + '}';
        jsonValues = JSON.parse(jsonValues);
        newJson = Object.assign(newJson, jsonValues);
      }
      return newJson;
    },
    
    convertDateFormat: function (dateSelected) {
      const d = new Date(dateSelected);
      let year = d.getFullYear();
      let month = d.getMonth() + 1;
      let day = d.getDate();
      if (month < 10) {
        month = String('0') + String(month);
      }
      if (day < 10) {
        day = String('0') + String(day);
      }
      return year + "-" + month + "-" + day;
    },
    
    convertListValuesForDropdownList: function (component, event, helper, listOfElements) {
      var listSize = listOfElements.length;
      var result = [];
      var resultVehiculeId = {};
      if (listSize > 0) {
        for (var i = 0; i < listSize; i++) {
          var newElement = {
            'label': listOfElements[i].Name,
            'value': listOfElements[i].Id,
          };
          var newAssetDetail = {};
          result.push(newElement);
          resultVehiculeId[listOfElements[i].Id] = listOfElements[i];
        }
        component.set("v.userAssets", result);
        component.set("v.userAssetsDetails", result);
        this.resultVehiculeIdGlobal = resultVehiculeId;
        component.set("v.hasNoAssets", false);
      }
    },
    
    setEventsInformation: function (component, event, helper, listOfEvents) {
      if (listOfEvents != '') {
        component.set("v.userEvents", listOfEvents);
      }
    },
    
    mostrarPreguntas: function (component, event, helper) {
     
    },
      
      controlUndefinedValues: function(value){
          if(value ==='' || value===null || value ===undefined){
              return 'N/I';
          }
          return value;
      },
      
      setInformationForSelectedVehicle: function(component, event, helper){
          let myDiv = document.getElementById('vehicleInfo');
          var table = document.getElementById("vehicleInfoTable").getElementsByTagName('tbody')[0];
          
    
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
          
          
          cell1.innerText = this.controlUndefinedValues(this.resultOfSelectedVehicle.marca__c);
          cell2.innerText = this.controlUndefinedValues(this.resultOfSelectedVehicle.modelo__c);
          cell3.innerText = this.controlUndefinedValues(this.resultOfSelectedVehicle.Anio__c);
          cell4.innerText = this.controlUndefinedValues(this.resultOfSelectedVehicle.color__c);
          cell5.innerText = this.controlUndefinedValues(this.resultOfSelectedVehicle.numeroDePlaca__c);
         
      },
    
    processAdditionalServices: function (component) {
      var description = 'Services Selected:\n';
      var atLeastOne = false;
      var additionalServicesSelected = this.additionalServices;
      for (let key in additionalServicesSelected) {
        if (additionalServicesSelected[key] === true) {
          atLeastOne = true;
          description += key + '\n';
        }
      }
      if (atLeastOne === false) {
        description += 'N/A';
      }
      return description;
    },
    
    setVehiculeIdConfirmation: function (component) {
      var ownVehicleSelected = component.get("v.ownVehicleSelected"); // Id del vehículo propio seleccionado
      var vehicleId = component.get("v.vehicleId"); // Placa de vehículo que no es propio.
      var placa = this.resultVehiculeIdGlobal[ownVehicleSelected].Name; // Placa del vehículo propio seleccionado
      component.set("v.selectedPlaca", placa); // Usado para preconfirmación.
    
      if (ownVehicleSelected === '' || ownVehicleSelected === null || ownVehicleSelected === undefined) { // Si se seleccionó un vehículo que no es propio
        component.set("v.vehicleId", vehicleId); // 
        component.set("v.selectedPlaca", vehicleId);
      }
    },
    
    resetStatistics: function () {
      component.set("v.estimatedKM",'');
      this.quantityOfCurrentEventsByDay = {};
      this.quantityOfOperatingHoursBySucursal = {};
      this.colorStatisticsByDay = {};
      this.statisticsByDay = {};
    },
    
    // defineColorsForStatistics: function (resultByDay) {
    //   resultByDay = Number(resultByDay) * 100; // Converted to %. i.e. 99%.
    //   var result = 'green';
    //   if (resultByDay > 99) {
    //     result = 'gray';
    //   }
    //   if (resultByDay < 99 && resultByDay >= 75) {
    //     result = 'red';
    //   }
    //   if (resultByDay < 75 && resultByDay >= 50) {
    //     result = 'yellow';
    //   }
    //   if (resultByDay < 50 && resultByDay >= 0) {
    //     result = 'green';
    //   }
    //   return result;
    // },
    
    generateAvailabilityStatistics: function () {
      //console.log('entro generateAvailabilityStatistics');
      var dailySpaces = 0;
      var opsHoursBySucursal = JSON.parse(JSON.stringify(this.quantityOfOperatingHoursBySucursal));
      //console.log('opsHoursBySucursal');
      // console.log(opsHoursBySucursal); // este esta bien muestra las horas que se tienen disponibles
      // console.log('capacityBySucursal');
      // console.log(this.capacityBySucursal);//este esta bien muestra los agentes por sucursal
      for (var key in opsHoursBySucursal) {
        dailySpaces = opsHoursBySucursal[key] * this.capacityBySucursal[key];
      }
      //console.log(dailySpaces);
      // to be processed : quantityOfCurrentEventsByDay
      //console.log('medio generateAvailabilityStatistics');
      var listSpacesTaken = JSON.parse(JSON.stringify(this.quantityOfCurrentEventsByDay));
      //console.log(this.quantityOfCurrentEventsByDay);
      for (var key in listSpacesTaken) {
        var resultByDay = listSpacesTaken[key] / dailySpaces;
        this.statisticsByDay[key] = resultByDay;
        this.colorStatisticsByDay[key] = this.defineColorsForStatistics(resultByDay);
      }
      //console.log('salio generateAvailabilityStatistics');
    },
    
    /* End of Server calls functions support ________________________________________________________________________________________________________*/
    
    
    /* Server calls _________________________________________________________________________________________________________________________________*/
    
    createNewCalendarEvent: function (day, hour, component) {
      var user = component.get("v.userInfo").Id;
      var selectedVehicle = component.get("v.vehicleSelected");
      var vehicleId = component.get("v.vehicleId");
      var ownVehicleId = component.get("v.ownVehicleSelected");
      var keys = Object.keys(this.horas);
      //var serviceCenter = this.selectedServiceCenter;
      var serviceCenter = component.get("v.selTabId");
      console.log('crear evento ' + serviceCenter);
      console.log('crear evento ' + this.serviceCenter);
      var day_ = this.convertDateFormat(day);
      // Controlar cuando no hay eventos o cuando hay solo uno
      var citations = this.dataStructuresByServiceCenter.get(serviceCenter)[3][day_];
        // console.log("citations");
        // console.log(citations);
      var citationsSize = 0;
      if (citations != undefined) {
        citationsSize = citations.length;
      }
      var asesores = [];
      if (citationsSize >= 1) {
        for (var i = 0; i < citationsSize; i++) {
            
          var horasKeys = this.horasList;
          var startPosEvent = horasKeys.indexOf(citations[i][1])-1; // Gets the position of the citation hour. Start
          var endPosEvent =  horasKeys.indexOf(citations[i][2])-1; // Gets the position of the citation hour. End
          var startSelectedHour = horasKeys.indexOf(hour)-1;
          var endSelectedHour = startSelectedHour + 1;
     
          if (startPosEvent == startSelectedHour) {
            asesores.push(citations[i][3]);
          }
        }
          console.log(asesores);
      }
      
    
    
      // Get The Start Date and End Date values
      var keys = this.horasList;
      var positionOfStartHour = Number(Object.keys(this.horas).indexOf(hour)); // Gets the position of selected hour.
    
      var minutosFinales  = component.get("v.minutosSucursal");
       console.log('minutosFinales');
       console.log(minutosFinales);
      var minutosAgregar = minutosFinales / 30;
      // console.log('minutosAgregar');
      // console.log(minutosAgregar);
      var nextPosition = Number(positionOfStartHour + minutosAgregar); // Gets the position of the end hour.
      var endSelectedHour_ = '';
      if (nextPosition <= keys.length) {
        endSelectedHour_ = keys[nextPosition];
      }
    
      // Set the Datetime Variables for StartDateTime and EndDateTime
      var d = new Date(day);
      var startDateHour = new Date(day.getFullYear(), day.getMonth(), day.getDate());
      startDateHour.setHours(this.getHour(hour), this.getMinute(hour), 0, 0);
      var endDateHour = new Date(day.getFullYear(), day.getMonth(), day.getDate());
      endDateHour.setHours(this.getHour(endSelectedHour_), this.getMinute(endSelectedHour_), 0, 0);
    
    
      var kilometrosEsti = '';
      var ejemplo = component.get( "v.tipoCita" );
      var description = '';
      if(ejemplo == true){
        var lstPreguntas = component.get( "v.inputCount" );
        //console.log(lstPreguntas);
        for(var z = 0; z < lstPreguntas.length; z++){
          var pregunta = "v.pregunta" + (z+1);
          //console.log(pregunta);
          description += '\n\n' + ''+ lstPreguntas[z].Pregunta__c + ' ' + component.get(pregunta);
          //console.log('dentro descrip');
        }
    
      }else{
        
     
        description = this.processAdditionalServices(component);
        description += '\n' + 'Notas y comentarios:' + component.get("v.additionalComments");
        description += '\n\n' + 'Kilómetros estimados:' + component.get("v.estimatedKM");
        kilometrosEsti = '' + component.get("v.estimatedKM");
      }
      
    //================================= ESTO VALIDA QUE SI ESTE LIBRE ==================================

          
        
    var action1 = component.get("c.validarEventoVacio");
    action1.setParams({
      userId: user,
      calendarId: serviceCenter,
      daySelected: day,
      selectedStartHour: startDateHour,
      selectedEndHour: endDateHour,
      usersToExclude: asesores,
      selectedVehicle: selectedVehicle,
      vehicleId: ownVehicleId, // Placa de vehículo que no es propio.
      ownVehicleId: ownVehicleId, // Id vehículo que es propio
      description: description,
      selectedServiceCenter: null
    });
    console.log('=============================ESPACIO NO OCUPADO==========================');
    action1.setCallback(this, function (response) {
      
      var state = response.getState();
      console.log('response ' + state);
      if (state === "SUCCESS") {
        
        var result = response.getReturnValue();
        component.set('v.espacioNoOcupado', result);
        console.log(result);
        return result;
        console.log('corre conexion h 2');
      } else if (state === "INCOMPLETE") {
        // do something
      } else if (state === "ERROR") {
        console.log(response);
        console.log( JSON.stringify(response));
      
        console.log(response.getReturnValue());
        var errors = response.getError();
        console.log(response.getError);
        console.log("Error message: " + errors[0].message);

        if (errors) {
          if (errors[0] && errors[0].message) {
            console.log("Error message: " + errors[0].message);
          }
        } else {
          console.log("Unknown error");
        }
      }
    });
    $A.enqueueAction(action1);

    //================================== ESTO CREA LA CITA EN SALESFORCE ===============================
  setTimeout(() => {
    var espacioOcupado =  component.get('v.espacioNoOcupado');
    console.log( 'Espacio ocupado es : ' + espacioOcupado);
    if(espacioOcupado == true){

      var action = component.get("c.createCalendarEventW");
      action.setParams({
        KilimeEsti:kilometrosEsti,
        userId: null,
        calendarId: serviceCenter,
        daySelected: day,
        selectedStartHour: startDateHour,
        selectedEndHour: endDateHour,
        usersToExclude: asesores,
        selectedVehicle: 'esReserva',
        vehicleId: null, // Placa de vehículo que no es propio.
        ownVehicleId: null, // Id vehículo que es propio
        description: description,
        selectedServiceCenter: null
    
      });
    
      action.setCallback(this, function (response) {
        console.log('===================================');
        console.log(user);
        console.log(serviceCenter);
        console.log(day);
        console.log(startDateHour);
        console.log(endDateHour);
        console.log(asesores);
        console.log(selectedVehicle);
        console.log(ownVehicleId);
        console.log(description);
        console.log('===================================');
        var state = response.getState();
        console.log('response ' + state);
        if (state === "SUCCESS") {
          var result = response.getReturnValue();
          component.set('v.myResult', result);
          console.log(result);
          console.log(result.Id);
          component.set("v.eventIdcreado", result.Id);
          return result;
          console.log('corre conexion h 2');
        } else if (state === "INCOMPLETE") {
          // do something
        } else if (state === "ERROR") {
          console.log(response);
          console.log( JSON.stringify(response));
         
          console.log(response.getReturnValue());
          var errors = response.getError();
          console.log(response.getError);
          console.log("Error message: " + errors[0].message);
    
          if (errors) {
            if (errors[0] && errors[0].message) {
              console.log("Error message: " + errors[0].message);
            }
          } else {
            console.log("Unknown error");
          }
        }
      });
      $A.enqueueAction(action);
      }
      component.set("v.isLoading", false);
    }, 3000);

      var hourSelected = component.get("v.startDateHour");  
      var serviceCenter2 = component.get("v.selTabId");
      var action2 = component.get("c.releaseHoursAvailability");
      action2.setParams({
        
        "calendarId" : serviceCenter2,
        "horaSelc" : hourSelected          
      });
      action2.setCallback(this, function(response) {
        var state = response.getState();
        if (state === "SUCCESS") {
          var storeResponse = response.getReturnValue();  
          console.log(storeResponse);      
          //component.set("v.horasReservas", storeResponse);
          console.log('corre conexion h 7');
        } else {
          console.log("error");
          console.log(response.getError());
        }
  
      });
      $A.enqueueAction(action2);

    
    },
    
    getMecanicosResponse: function (component, event, helper, apexFunction, parameters) {
      console.log('entro getMecanicosResponse');
      var action = component.get(apexFunction);
      action.setParams(parameters);
      action.setCallback(this, function (response) {
    
        var state = response.getState();
        // console.log(state);
        // console.log('respuesta horasGlobales ' + state);
        if (state === "SUCCESS") {
          
          var storeResponse = response.getReturnValue();
          console.log(storeResponse);
    
        component.set("v.mecanicosSucursal", storeResponse);
        }
      });
      $A.enqueueAction(action);
      
      
      
    },
    
    
    // Generic Call to the server
    getServerResponse: function (component, event, helper, apexFunction, parameters) {
      component.set("v.estimatedKM",'');
      console.log('entro getServerResponse ');
      var action = component.get(apexFunction);
      action.setParams(parameters);
      action.setCallback(this, function (response) {
        
        var state = response.getState();
        console.log("getServerResponse status " + state);
        console.log('entrada respuestas' );
        if (state === "SUCCESS") {
          
          var result = response.getReturnValue();
          console.log('=================result==================' );
          console.log(result);
          var lstEvent = result[2];
          var resulsize = lstEvent.length;
          
          
          for(var i = 0; i < result[2].length; i++){    
            if(lstEvent[i][1] == '7:00 AM' && lstEvent[i][2] == '7:30 AM' ){
              lstEvent[i][1] = '7:00 AM';
            }
          }
    
    
          //fin proceso para correccion de horas duplicadas
    
          this.capacityBySucursal = this.convertCapacityBySucursalToJSON(result[3]);
          component.set("v.mecanicosXespacio",result[3]);
          this.mecanicosXespacio = result[3];
          var asesoresByCalendar = result[1];
          console.log('===================== asesoresByCalendar =====================');
          var asesoresByCalendar1 = result[0];        
          component.set("v.asesoresXcomunidad",asesoresByCalendar1);
          this.asesoresXcomunidad = asesoresByCalendar1;
          //var eventResults = result[2];
            console.log(lstEvent);
            for(var i = 0; i < result[2].length; i++){    
              if(lstEvent[i][1] == '7:30 AM' && lstEvent[i][2] == '7:30 AM' ){
                lstEvent[i][1] = '7:00 AM';
              }
            }
    
            console.log('a medio success');
          helper.joinEventsAndAsesores(helper, asesoresByCalendar, lstEvent);
          console.log('a fin success');
          //guardamos los eventos
          this.eventosExistentes =  lstEvent;
    
          this.findAvailability(lstEvent);
          console.log('salio success');
          //this.generateAvailabilityStatistics();
          console.log('corre conexion h 3');
        } else {
          console.log("error");
          console.log(response.getError());
        }
      });
      $A.enqueueAction(action);
      console.log('salio getServerResponse ');
    },
    
    cancelCita: function (component, event, helper) {
    
      var citationIdd = component.get("v.eventId");
      var action = component.get("c.cancelCitation");
      // console.log(citationIdd);
      // console.log(action);
      action.setParams({
        citationId: citationIdd
      });
    
      action.setCallback(this, function (response) {
        var state = response.getState();
        console.log(state);
        if (state === "SUCCESS") {
          var result = response.getReturnValue();
          component.set("v.userEvent", "");
          document.getElementById("confirmationOfCancelledCitation").style.display = "";
          //location.reload();
          console.log('corre conexion h 4');
        } else if (state === "INCOMPLETE") {
          // do something
        } else if (state === "ERROR") {
          var errors = response.getError();
          if (errors) {
            if (errors[0] && errors[0].message) {
              console.log("Error message: " + errors[0].message);
            }
          } else {
            console.log("Unknown error");
          }
        }
      });
      $A.enqueueAction(action);
    },
    
    
    myFunction2: function (component, event, helper) {
      console.log('entro myFunction2');
      component.set("v.controllerFirstRun", false);
      $(".button-collapse").sideNav();
      var calendar = document.getElementById("calendar-table");
      var gridTable = document.getElementById("table-body");
      helper.currentDate = helper.selectedDate;
      //helper.selectedDate = helper.currentDate;
      var selectedDayBlock = null;
      var globalEventObj = {};
    
      var sidebar = document.getElementById("sidebar");
    
      function createCalendar(date, side) {//correcto crea calendario
        console.log('entro createCalendar');
        console.log('-------Date-----');
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
    
        // setTimeout(() => {
          gridTable.innerHTML = "";
    
          var newTr = document.createElement("div");
          newTr.className = "row";
          var currentTr = gridTable.appendChild(newTr);
          // console.log('------log----- ' + startDate.getDay());
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
    
            var dayInLoop = new Date(saveDate.getFullYear(), saveDate.getMonth(), i, 0);
            var dayInLoopFormattedDate = dayInLoop.getFullYear() + '-' + String(dayInLoop.getMonth() + 1).padStart(2, '0') + '-' + String(dayInLoop.getDate()).padStart(2, '0');
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
            currentDay.innerHTML = i;
            if (component.get("v.controllerFirstRun") != true) {
              let eventMark = document.createElement("div");
              var correctDate = new Date();
              var todayDate = correctDate.setHours(0, 0, 0, 0);
              todayDate = new Date(todayDate);
              
              //aqui tomaremos los colores, se tiene la fecha
              var opsHoursBySucursal = JSON.parse(JSON.stringify(helper.quantityOfOperatingHoursBySucursal));
              console.log('====================opsHoursBySucursal===================');
              // console.log(opsHoursBySucursal);
              //var capacidadSucursal = helper.capacityBySucursal;
    
              var calendarioSel = component.get("v.selectedSucursal").toString();
              console.log('====================calendarioSel===================');
              // console.log(calendarioSel);
              
              //forateo de dia acutal
    
              var yourDate = dayInLoop;
              
              var month2 = '' + (yourDate.getMonth()+1);
              if(month2 < 10 ){
                month2 = '0' + month2;
              }
              var day2 = '' + yourDate.getDate();
              if(day2 < 10 ){
                day2 = '0' + day2;
              }
              var year2 = yourDate.getFullYear();
              yourDate = year2 + '-' + month2 + '-' + day2;
              //------------------------
              var eventosExistentes2 = helper.eventosExistentes;
              //RECORREMOS LA LISTA DE EVENTOS BUSCANDO EL DÍA
              var diasEvento = 0;
              for(let i=0 ; i < eventosExistentes2.length;i++){
                if(eventosExistentes2[i][4] == calendarioSel &&  eventosExistentes2[i][0] == yourDate ){
                  diasEvento += 1;
                }
              }
    
              //obtendremos los días
              var horaSucursalSel = opsHoursBySucursal[calendarioSel];
    
              //se reemplazo por cantidad de mecanicos
              //var capacidadSucursalSel = capacidadSucursal[calendarioSel];
              //minutosSucursal
              //**********************************************************************************************
              //**********************************************************************************************
              //**********************************************************************************************
              //*********************************** COLORES DEL CALENDARIO ***********************************
              //**********************************************************************************************
              //**********************************************************************************************
              var minutosSucursalT = component.get("v.minutosSucursal");
              var color = 'green';
              console.log('================ colores calendario ================');
              
              var serviceCenters = helper.dataStructuresByServiceCenter.get(calendarioSel);
              var listOfDate = serviceCenters[2];
              console.log(serviceCenters);
              console.log(yourDate);
              
              var asesoresTotales = helper.asesoresXcomunidad;
              var mecanicos = helper.mecanicosXespacio;
              var asesoresEspacios = 0;
              var mecanicosEspacios = 0;
              //var serviceCenterId = component.get("v.selectedSucursal").toString();
              for (var p = 0; p < asesoresTotales.length; p++) {      
                if(asesoresTotales[p].Id == calendarioSel ){
                  asesoresEspacios = asesoresTotales[p].expr0;
                }
              }
              for (var j = 0; j < mecanicos.length; j++) {      
                if(mecanicos[j].Id == calendarioSel ){
                  mecanicosEspacios = mecanicos[j].Cantidad_de_Mecanicos__c;
                }
              }
    
              //*********************** CORRECCION DE COLORES CLAENDARIO ****************************
              //var dayAvailability = listOfDate[yourDate];
              if(true){
                console.log("despues showEvents eventsOnSelectedDate");           
                // console.log(serviceCenters);
                var mapaSoloEventos = serviceCenters[3]; // este trae todos los eventos de la sucursal
                console.log(mapaSoloEventos);
                console.log("evento en día");
                var mapaEventoDia = mapaSoloEventos[yourDate]; // este trae los eventos del día seleccionado
                console.log(mapaEventoDia);
                //*************************************************************
                // AQUI VAMOS A INTENTAR ORDENAR LA LISTA CON LA CANTIDAD DE ESPACIOS DISPONIBLES, EL OBJETIVO SERA CONVERTIRLA DESPUES
                // A UNA LISTA CON SOLO LOS BLOQUES DENTRO DEL HORARIO PARA DESPUES RECORRER LOS HORARIOS EN BUSQUEDA DE N > 0,
                // SE VERIFICARA QUE EN ESOS ESPACIOS NO HAY HORAS CON ASESOR Y SI LO HAY QUE EVENTOS ASESOR < ASESORES TOTALES
                // SI HAY ESPACIO Y NO HAY ASESOR ENTONCES SE MUESTRA
                //************************************************************}
                var currentSucursal = component.get("v.selectedSucursal").toString();
                var oppsHours = helper.operatingHoursListS;
                var oppsSize = oppsHours.length;
                for (var x = 0; x < oppsSize ; x++) {
                  if(helper.operatingHoursListS[x][1] == currentSucursal){
                    if(helper.operatingHoursListS[x][2] == helper.operatingHoursListS[x][3] &&  dayInLoop.getDay() == 6 ){
                      color = 'red';
                    }
                  }
                }              
                
  
                if (mapaEventoDia != undefined ) {
                  console.log("===============LISTA ORDENADA===============");
                  var desordenada = serviceCenters[2];
                  console.log(desordenada);
                  var data = desordenada[yourDate];
                  for (let key in data) {
                    
                    data[key] = asesoresEspacios;                    
                    data[key] = asesoresEspacios;
                    
                    // console.log(listaAsesores[key]);
                    // console.log(sortedData[key]);
                  }
                  desordenada[yourDate] = data;
                  data = desordenada[yourDate];
                  console.log("===============LISTA ORDENADA===============");
                  console.log(desordenada[yourDate]);
                  
                  // Convert the time strings to Date objects and sort them
                  var sortedTimes = Object.keys(data)
                    .map((time) => ({ time, date: new Date(`2023-09-15 ${time}`) }))
                    .sort((a, b) => a.date - b.date);
              
                  // Create a new map with the sorted data
                  console.log(asesoresEspacios);
                  console.log(mecanicosEspacios);
                  var sortedData = {};
                  sortedTimes.forEach((item) => {
                    sortedData[item.time] = data[item.time];
                  });
                  console.log('===============sortedData===============');
                  console.log(sortedData);
  
                  let keys = Object.keys(sortedData);
  
                  var listaAsesores = {
                    "12:00 AM": 0,
                    "12:30 AM": 0,
                    "1:00 AM": 0,
                    "1:30 AM": 0,
                    "2:00 AM": 0,
                    "2:30 AM": 0,
                    "3:00 AM": 0,
                    "3:30 AM": 0,
                    "4:00 AM": 0,
                    "4:30 AM": 0,
                    "5:00 AM": 0,
                    "5:30 AM": 0,
                    "6:00 AM": 0,
                    "6:30 AM": 0,
                    "7:00 AM": 0,
                    "7:30 AM": 0,
                    "8:00 AM": 0,
                    "8:30 AM": 0,
                    "9:00 AM": 0,
                    "9:30 AM": 0,
                    "10:00 AM": 0,
                    "10:30 AM": 0,
                    "11:00 AM": 0,
                    "11:30 AM": 0,
                    "12:00 PM": 0,
                    "12:30 PM": 0,
                    "1:00 PM": 0,
                    "1:30 PM": 0,
                    "2:00 PM": 0,
                    "2:30 PM": 0,
                    "3:00 PM": 0,
                    "3:30 PM": 0,
                    "4:00 PM": 0,
                    "4:30 PM": 0,
                    "5:00 PM": 0,
                    "5:30 PM": 0,
                    "6:00 PM": 0,
                    "6:30 PM": 0,
                    "7:00 PM": 0,
                    "7:30 PM": 0,
                    "8:00 PM": 0,
                    "8:30 PM": 0,
                    "9:00 PM": 0,
                    "9:30 PM": 0,
                    "10:00 PM": 0,
                    "10:30 PM": 0,
                    "11:00 PM": 0,
                    "11:30 PM": 0
                  };
                  ;
  
                  for (let key in sortedData) {
                    
                    listaAsesores[key] = asesoresEspacios;                    
                    sortedData[key] = mecanicosEspacios;
                    
                    // console.log(listaAsesores[key]);
                    // console.log(sortedData[key]);
                  }
  
                  console.log(asesoresEspacios);
                  console.log(mecanicosEspacios);
                  for (let n = 0; n < keys.length; n++) {
                    let key = keys[n];
                    console.log('===============key===============');
                    console.log(key);
                    
                    listaAsesores[key] = asesoresEspacios;                    
                    sortedData[key] = mecanicosEspacios;
                    // console.log(listaAsesores[key]);
                    // console.log(sortedData[key]);
                    listaAsesores[key] = asesoresEspacios;                    
                    sortedData[key] = mecanicosEspacios; 
                    // console.log('===================dentroMILogica====================');
                    // console.log(sortedData);
                    // console.log(listaAsesores);
                    // Iterate over each array
                    //let dateValue = mapaEventoDia[i][0];
                    //[0] date [1] Hora Inicio [2] Hora final [3] ID [4] ID [5] Tipo de cita
                    for (let k = 0; k < mapaEventoDia.length; k++) {
                      // Access the date value at the first index of the current array
                      var horaDeInicio = mapaEventoDia[k][1];
                      var horaDeFin = mapaEventoDia[k][2];
                      var tipoCita = mapaEventoDia[k][5];
  
  
                      var result = [];
                      var currentDate = new Date(`2000-01-01 ${horaDeInicio}`);
                      var endArraydDate = new Date(`2000-01-01 ${horaDeFin}`);
  
                      while (currentDate < endArraydDate) {
                        var formattedTime = currentDate.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
                        if(formattedTime.toString()  == "05:00"){
                          formattedTime = '5:00 AM';
                        }else if(formattedTime.toString() == "05:30"){
                          formattedTime = '5:30 AM';
                        }else if(formattedTime.toString() == "06:00"){
                          formattedTime = '6:00 AM';
                        }else if(formattedTime.toString() == "06:30"){
                          formattedTime = '6:30 AM';
                        }else if(formattedTime.toString() == "07:00"){
                          formattedTime = '7:00 AM';
                        }else if(formattedTime.toString() == "07:30"){
                          formattedTime = '7:30 AM';
                        }else if(formattedTime.toString() == "08:00"){
                          formattedTime = '8:00 AM';
                        }else if(formattedTime.toString() == "08:30"){
                          formattedTime = '8:30 AM';
                        }else if(formattedTime.toString() == "09:00"){
                          formattedTime = '9:00 AM';
                        }else if(formattedTime.toString() == "09:30"){
                          formattedTime = '9:30 AM';
                        }else if(formattedTime.toString() == "10:00"){
                          formattedTime = '10:00 AM';
                        }else if(formattedTime.toString() == "10:30"){
                          formattedTime = '10:30 AM';
                        }else if(formattedTime.toString() == "11:00"){
                          formattedTime = '11:00 AM';
                        }else if(formattedTime.toString() == "11:30"){
                          formattedTime = '11:30 AM';
                        }
                        else if(formattedTime.toString() == "12:30"){
                          formattedTime = '12:30 PM';
                        }else if(formattedTime.toString()  == "12:00"){
                          formattedTime = '12:00 PM';
                        }else if(formattedTime.toString()  == "13:00"){
                          formattedTime = '1:00 PM';
                        }else if(formattedTime.toString()  == "13:30"){
                          formattedTime = '1:30 PM';
                        }else if(formattedTime.toString()  == "14:00"){
                          formattedTime = '2:00 PM';
                        }else if(formattedTime.toString()  == "14:30"){
                          formattedTime = '2:30 PM';
                        }else if(formattedTime.toString()  == "15:00"){
                          formattedTime = '3:00 PM';
                        }else if(formattedTime.toString()  == "15:30"){
                          formattedTime = '3:30 PM';
                        }else if(formattedTime.toString()  == "16:00"){
                          formattedTime = '4:00 PM';
                        }else if(formattedTime.toString()  == "16:30"){
                          formattedTime = '4:30 PM';
                        }else if(formattedTime.toString()  == "17:00"){
                          formattedTime = '5:00 PM';
                        }else if(formattedTime.toString()  == "17:30"){
                          formattedTime = '5:30 PM';
                        }else if(formattedTime.toString()  == "18:00"){
                          formattedTime = '6:00 PM';
                        }else if(formattedTime.toString()  == "18:30"){
                          formattedTime = '6:30 PM';
                        }else if(formattedTime.toString()  == "19:00"){
                          formattedTime = '7:00 PM';
                        }else if(formattedTime.toString()  == "19:30"){
                          formattedTime = '7:30 PM';
                        }
                        
  
                        result.push(formattedTime);
                        currentDate.setMinutes(currentDate.getMinutes() + 30);
                      }
                      // console.log('====================result====================');
                      // console.log(result);
                      //var asesoresEspacios = 0;
                      //var mecanicosEspacios = 0;
                      
                      for (let j = 0; j < result.length; j++) {         
          
                        if(sortedData.hasOwnProperty(key) && key == result[j]){
                      
                          if(mapaEventoDia[k][5] == 'Asesor'){
                            //AQUI SE REVISA SI ES ASESOR O NO
                            listaAsesores[key] = listaAsesores[key] - 1;
                            
                            console.log('===sucursal asesor quita 1===');
                            console.log(mapaEventoDia[k]);
                          }else{
                            // console.log('===sucursal le quita 1===');
                            //SI NO ES ENTONCES SOLO RESTAMOS 1 ESPACIO
                            sortedData[key] = sortedData[key] - 1;
                            
                          }
                        }    
                      }
  
                                     
  
                      // Convert string times to Date objects
                      // const startDate = new Date(`2000-01-01 ${startTime}`);
                      // const endDate = new Date(`2000-01-01 ${endTime}`);
                      // const targetDate = new Date(`2000-01-01 ${targetTime}`);
  
                      // Check if the target time is between the start and end times
                      //return targetDate >= startDate && targetDate <= endDate;   
                    }
  
                    
                    
                  }
                  // console.log('===============sortedDataNew===============');
                  //   console.log(sortedData);
                  //   console.log('===============listaAsesores===============');
                  //   console.log(listaAsesores);
  
                    var listaFinal = [];
                    listaFinal = listaAsesores;
                    var cantidadMinutos =  helper.minutosSucursal;
                    var quitarMinutos = cantidadMinutos / 30;
                    let keys1 = Object.keys(listaFinal);
                    // console.log(keys1);
                    for (let m = 0; m < keys1.length; m++) {
                      var siPasa = true;
                      let key = keys1[m];
                      // console.log('=======================(keys1);=================');
                      // console.log(key);
                      console.log('=======================(listaFinal);=================');
                      console.log(listaFinal);
  
                      //aqui vamos a controlar primero si es Sincronica
                      var boolEsSincronica =  helper.esSincronica;
                      if(boolEsSincronica == true){
                        if(listaFinal[key] > 0){
                          for (let o = m ; o < m + quitarMinutos && o < keys1.length; o++) {
  
                            if(listaFinal[keys[o]] > 0){
  
                            }else{
  
                              siPasa = false;
                              break;
                            }
                          }
                          if(!siPasa){
                            listaFinal[key] = 0;
                            listaFinal[key] = 0;
                          }else{
                            
                          }
                        }else{
                            listaFinal[key] = 0;
                            listaFinal[key] = 0;
                        }
  
                      }
  
  
                      if(listaFinal[key] > 0){
                        // console.log(m);
                        for (let o = m + 1; o <= m + quitarMinutos && o < keys1.length; o++) {
                          // console.log(o);
                          // console.log(keys[o]);
                          // console.log(sortedData[keys[o]]);
                          // console.log(keys1[o]);
                          // console.log(sortedData[keys1[o]]);
                          if(sortedData[keys[o]] > 0){
                            // console.log('=========== SI PASO ==============');
                            // console.log(key);
                            // console.log(sortedData[keys1[o]]);
                          }else{
                            // console.log('=========== NO PASO ==============');
                            // console.log(key);
                            // console.log(sortedData[keys1[o]]);
                            siPasa = false;
                            break;
                          }
                        }
                        if(!siPasa){
                          // console.log('=========== se resto a cero siPasa ==============');
                          listaFinal[key] = 0;
                          listaAsesores[key] = 0;
                          // console.log(listaAsesores[key]);
                          // console.log(listaFinal[key]);
                          listaFinal[key] = 0;
                        }
                      }else{
                        // console.log('=========== se resto a cero ==============');
                          listaFinal[key] = 0;
                          listaAsesores[key] = 0;
                          // console.log(listaAsesores[key]);
                          // console.log(listaFinal[key]);
                          listaFinal[key] = 0;
                      }
                    }
  
                    // console.log('===============listaFinal===============');                  
                    // console.log(listaFinal);
  
                    
                    // console.log('currentSucursal');
                    // console.log(currentSucursal);
                    var mapaCompleto = helper.dataStructuresByServiceCenter.get(currentSucursal)[2][yourDate];
                    // console.log(mapaCompleto);
                    helper.dataStructuresByServiceCenter.get(currentSucursal)[2][yourDate] = listaFinal;
                    // console.log(helper.dataStructuresByServiceCenter.get(currentSucursal)[2][yourDate]);
                    //var desordenada = mapaCompleto[2][yourDate];
                    //desordenada[yourDate];
                  let keysOfEventsOnSelectedDate = Object.keys(sortedData);
                  // console.log("==============================keysOfEventsOnSelectedDate==============================");
                  // console.log(keysOfEventsOnSelectedDate);
              
                  // console.log("SI EXISTEN EVENTOS");
              
                  let eventsCount = 0;
                  //=================== ESTO LO IMPRIME EN LOS CUADROS SI LOS ASESORES SON MENOS QUE MECANICOS==============
                    for (var key in keysOfEventsOnSelectedDate) {
                  //   // *******************************************************************
                  //   // AQUI VA UN IF QUE REVISA LA KEY Y LA BUSCA EN EL HORARIO DE EVENTOS
                  //   // SI ENCUENTRA EL EVENTO DE INICIO EN LOS EVENTOS Y LA CANTIDAD DE ASESORES ES LIMITE, LO PASAMOS asesoresEspacios
                      var pasaValidacion = false;
                      var contadorAsesor = 0;
                    //  console.log("==========================PASO 1==========================");
                    // console.log(asesoresEspacios);
                     for (var m = 0; m < mapaEventoDia.length; m++) {
                        var horarioActual = mapaEventoDia[m];
                        // console.log(horarioActual);
                  //     // Time strings to compare
                         var startTime = horarioActual[1];
                         var endTime = horarioActual[2];
                         var targetTime = keysOfEventsOnSelectedDate[key];
                        //  console.log(startTime);
                        //  console.log(endTime);
                        //  console.log(targetTime);
                         // Convert time strings to Date objects
                         var startDate1 = new Date(`2023-09-15 ${startTime}`);
                         var endDate1 = new Date(`2023-09-15 ${endTime}`);
                         var targetDate1 = new Date(`2023-09-15 ${targetTime}`);
              
                          if (
                            horarioActual[5] == "Asesor" &&
                            targetDate1 >= startDate1 &&
                            targetDate1 < endDate1
                          ) {
                            //console.log(horarioActual);
                            contadorAsesor = contadorAsesor + 1;
                          }
                        }
                        //  console.log(" PASO 2 ");
                        //  console.log('==========================contadorAsesor==========================');
                        //  console.log(contadorAsesor);
                        //  console.log('==========================contadorAsesor menor asesoresEspacios==========================');
                        // console.log(contadorAsesor < asesoresEspacios);
                        if (contadorAsesor < asesoresEspacios) {
                          pasaValidacion = true;
                        }
                        // console.log(" PASO 3 ");
                        // console.log(pasaValidacion);
                        if (pasaValidacion) {
                          // console.log(" PASO 4 dentro pasaValidacion");
                          var element = keysOfEventsOnSelectedDate[key];
                          // console.log("==========================element==========================");
                          //  console.log(element);
                          // console.log("yourDate");
                          // console.log(yourDate);
                          var toBeIncluded = helper.checkHourInOperativeHourNull(element,yourDate,listOfDate[yourDate]);
                          //  console.log("==========================toBeIncluded==========================");
                          
                          //  console.log(toBeIncluded);
                          if (toBeIncluded) { 
                          //   //******************AQUI DEBE DE CAMBIAR EL VALOR A 0 PARA QUE NO LO TOME********************
                          
                                              
                          }else{
                            var dayAvailability1 = listOfDate[yourDate];
                            //console.log(dayAvailability1);
                            dayAvailability1[keysOfEventsOnSelectedDate[key]] = 0;
                            // console.log('=======================dayAvailability1=========================');
                            // console.log(dayAvailability1);
                          }
                    }else{
                      // console.log('==========================No paso validacion==========================');
                      var dayAvailability1 = listOfDate[yourDate];
                      //  console.log(dayAvailability1);
                      //  console.log(keysOfEventsOnSelectedDate[key]);
                      dayAvailability1[keysOfEventsOnSelectedDate[key]] = 0;
                      // console.log('=======================dayAvailability1=========================');
                      // console.log(dayAvailability1);
                    }
              
                  }
                  //===================== FIN BLOQUE IMPRIMIR ======================
                }
              }
    
              //**********************************************************************************************
              if (listOfDate.hasOwnProperty(yourDate)) {
                console.log('Test 1');
                 // TRATAR DE CUBRIR LO DE LOS HORARIOS
                var cantidadMinutos =  helper.minutosSucursal;
                var quitarBloque = cantidadMinutos / 30;
                // console.log('=======================PROCESOS DE SALTO DE BLOQUES===============================');
                // console.log('=======================listOfDate===============================');
                // console.log(listOfDate);
                // console.log(listOfDate[yourDate]);
                // console.log(sortedData);
                var dayAvailability = sortedData;
                 console.log('=======================dayAvailability=======================');
  
                 console.log(dayAvailability);
                // Convert object into an array for easier manipulation
                var dayAvailabilityArray = Object.entries(dayAvailability);
    
                // Loop through the array to check for available slots and update accordingly
                for (var l = 0; l < dayAvailabilityArray.length; l++) {
                    var [time, availability] = dayAvailabilityArray[l];
    
                    // Check if the slot is available
                    if (availability > 0) {
                        var hasEnoughTime = true;
    
                        // Check if there's enough time before a 0 slot (90 minutes)
                        for (var m = 1; m < quitarBloque; m++) {
                            if (l + m >= dayAvailabilityArray.length || dayAvailabilityArray[l + m][1] <= 0) {
                                hasEnoughTime = false;
                                break;
                            }
                        }
    
                        // Update availability if there isn't enough time
                      if (!hasEnoughTime) {
                          dayAvailabilityArray[l][1] = 0;
                          
                      }
                  }
                }
    
                // Create a new object from the modified array
               var updatedDayAvailability = Object.fromEntries(dayAvailabilityArray);
               
               console.log(updatedDayAvailability);
               console.log('=============== proceso de Horas ===================');
               var date = new Date(yourDate);
               var weekday =  date.getDay() + 1;
               
                console.log('weekday horarios '+ weekday);
               var operativeHours = helper.findOperatingHourSemanal(calendarioSel,weekday);
               console.log(operativeHours);
               var startHour = operativeHours[2];
               var endHour = operativeHours[3];
    
    
               var keysOfHours = Object.keys(listaFinal);
              // console.log(keysOfHours);
              //var updatedDayAvailability1 = Object.fromEntries(listaFinal);
  
                
                quitarBloque = quitarBloque + 1;
                // quitarBloque = quitarBloque + 1;
                var endingPosition = keysOfHours[keysOfHours.indexOf(endHour)- quitarBloque];
                var startingPosition = keysOfHours[keysOfHours.indexOf(startHour)- 2];
  
              // console.log('==========================ANTONIO VE HORAS=========================');
              // console.log(date );  
              // console.log(date +1);          
              // console.log(startingPosition);
              // console.log(endingPosition);
              // console.log('=========================keysOfHours==========================');
              // console.log(keysOfHours);
              // console.log(listaFinal);
                var siHayEvento = true;
               for(var o = 0; o < keysOfHours.length ; o++){
                if(keysOfHours[o] != '12:00 AM' && keysOfHours[o] != '12:30 AM'){
                  var mayorQue = helper.isTimeGreaterThan(keysOfHours[o],startingPosition);
                  var menorQue = helper.isTimeGreaterThan(keysOfHours[o],endingPosition);
                  if( mayorQue == true && menorQue == false ){
                    console.log(keysOfHours[o]);
                    console.log(listaFinal[keysOfHours[o]]);
                    if( listaFinal[keysOfHours[o]] <= 0 || listaFinal[keysOfHours[o]] == -1){
                      siHayEvento = false;
                    }else{
                      siHayEvento = true;
                      break;
                    }
                    console.log( siHayEvento );
                  }
                }
                
               }
               if(siHayEvento){
                color = 'green';
               }else{
                color = 'red';
               }
               console.log( color );
                
              } 
              //**********************************************************************************************
              //**********************************************************************************************
              //**********************************************************************************************
              //**********************************************************************************************
              //**********************************************************************************************
              //**********************************************************************************************
              var oppsHours = helper.operatingHoursListS;
              var oppsSize = oppsHours.length;
              for (var x = 0; x < oppsSize ; x++) {
                if(helper.operatingHoursListS[x][1] == currentSucursal){
                  if(helper.operatingHoursListS[x][2] == helper.operatingHoursListS[x][3] &&  dayInLoop.getDay() == 6 ){
                    color = 'red';
                  }
                }
              }     
  
              if (color === 'gray' || dayInLoop.getTime() < todayDate.getTime() ||  dayInLoop.getDay() == 0) {
                currentDay.classList.add('inactive-day');
                color = 'gray'
              }
    
              if (color === undefined) {
                color = 'green';
                if (dayInLoop < todayDate.getTime()) {
                  color = 'gray';
                  currentDay.classList.add('inactive-day');
                }
              }
              console.log( ' Color Final' );
              console.log( color );
              var classColorAdapted = 'circle-' + color + '-availability';
              eventMark.className = classColorAdapted;
              currentDay.appendChild(eventMark);
    
            }
    
            currentTr.appendChild(currentDay);
          }
          
          //console.log('-------log2-----' + currentTr.getElementsByTagName("div").length);
          var diasCalendarioFinal = 0;
          if (currentTr.getElementsByTagName("div").length == 8) {
            diasCalendarioFinal = currentTr.getElementsByTagName("div").length - 4;
          } else if (currentTr.getElementsByTagName("div").length == 10) {
            diasCalendarioFinal = currentTr.getElementsByTagName("div").length - 5;
          } else if (currentTr.getElementsByTagName("div").length == 6) {
            diasCalendarioFinal = currentTr.getElementsByTagName("div").length - 3;
          } else {
            diasCalendarioFinal = currentTr.getElementsByTagName("div").length - 2;
          }
    
          for (let i = diasCalendarioFinal; i < 7; i++) {
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
          
        // }, !side ? 0 : 270);
        console.log('salio createCalendar FINAL');
      }
      
      // console.log( 'helper.currentDate ' + helper.currentDate )
      createCalendar(helper.currentDate);
      // console.log('paso el createCalendar AQUI');
    
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
        createCalendar(helper.currentDate, "left");
        setTimeout(() => {
          component.set("v.isLoading", false);
      }, 2000);
      }
      nextButton.onclick = function changeMonthNext() {
        component.set("v.isLoading", true);
        helper.currentDate = new Date(helper.currentDate.getFullYear(), helper.currentDate.getMonth() + 1);
        createCalendar(helper.currentDate, "right");
        setTimeout(() => {
          component.set("v.isLoading", false);
      }, 2000);
      }
    
      function addEvent(title, desc) {
        console.log('entro addEvent');
        if (!globalEventObj[helper.selectedDate.toDateString()]) {
          globalEventObj[helper.selectedDate.toDateString()] = {};
        }
        globalEventObj[helper.selectedDate.toDateString()][title] = desc;
        console.log('salio addEvent');
      }
    
      function subtract30MinutesFromTime(timeString) {
        const parts = timeString.split(' ');
        const timeParts = parts[0].split(':');
        const hours = parseInt(timeParts[0], 10);
        const minutes = parseInt(timeParts[1], 10);
        
        // Subtract 30 minutes
        const newMinutes = minutes - 30;
        let newHours = hours;
        
        if (newMinutes < 0) {
            newMinutes += 60;
            newHours--;
        }
        
        // Handle wrapping around midnight
        if (newHours < 0) {
            newHours += 12;
        }
        
        // Format the result as a string
        const ampm = parts[1];
        const newTime = `${newHours.toString().padStart(2, '0')}:${newMinutes.toString().padStart(2, '0')} ${ampm}`;
        
        return newTime;
      }
      
      function showEvents() {
        console.log('entro showEvents bueno');
        
        //llamada de metodo para guardar lista de valores
        var action = component.get("c.getHoursAvailability");
        //creacion de hora para calendario
        action.setCallback(this, function(response) {
          var state = response.getState();
          if (state === "SUCCESS") {
            var storeResponse = response.getReturnValue();        
            component.set("v.horasReservas", storeResponse);
            console.log('corre conexion h 5');
          } else {
            console.log("error");
            console.log(response.getError());
          }
    
        });
        $A.enqueueAction(action);
    
    
        let myNode = document.getElementById("sidebarEvents");
        while (myNode.lastElementChild) {
          myNode.removeChild(myNode.lastElementChild);
        }
        console.log(' FECHA formattedDate');
        let formattedDate = helper.selectedDate.getFullYear() + '-' + String(helper.selectedDate.getMonth() + 1).padStart(2, '0') + '-' + String(helper.selectedDate.getDate()).padStart(2, '0');
        console.log(formattedDate);
        let sidebarEvents = document.getElementById("sidebarEvents");
        let objWithDate = globalEventObj[helper.selectedDate.toDateString()];
        console.log('antes showEvents eventsOnSelectedDate');
        var asesoresTotales = helper.asesoresXcomunidad;
        var mecanicos = helper.mecanicosXespacio;
        var asesoresEspacios = 0;
        var mecanicosEspacios = 0;
        var serviceCenterId = component.get("v.selectedSucursal").toString();
        // console.log(serviceCenterId);
        // console.log( asesoresTotales);
        // console.log(mecanicos);
      
        for (var i = 0; i < asesoresTotales.length; i++) {
          // console.log(asesoresTotales[i]);
          if(asesoresTotales[i].Id == serviceCenterId ){
            asesoresEspacios = asesoresTotales[i].expr0;
          }
        }
      
        for (var j = 0; j < mecanicos.length; j++) {
          //console.log(mecanicos[j] );
          if(mecanicos[j].Id == serviceCenterId ){
            mecanicosEspacios = mecanicos[j].Cantidad_de_Mecanicos__c;
          }
        }
    
    
        if(mecanicosEspacios > asesoresEspacios){
          console.log('despues showEvents eventsOnSelectedDate');
          var currentSucursal = component.get("v.selectedSucursal").toString();
          console.log('currentSucursal');
          console.log(currentSucursal);
          var mapaCompleto = helper.dataStructuresByServiceCenter.get(currentSucursal);
          console.log(mapaCompleto);
          var mapaSoloEventos = mapaCompleto[3]; // este trae todos los eventos de la sucursal
          console.log(mapaSoloEventos);
          console.log('evento en día');
          var mapaEventoDia = mapaSoloEventos[formattedDate]; // este trae los eventos del día seleccionado
          console.log(mapaEventoDia);    
          //*************************************************************
          // AQUI VAMOS A INTENTAR ORDENAR LA LISTA CON LA CANTIDAD DE ESPACIOS DISPONIBLES, EL OBJETIVO SERA CONVERTIRLA DESPUES
          // A UNA LISTA CON SOLO LOS BLOQUES DENTRO DEL HORARIO PARA DESPUES RECORRER LOS HORARIOS EN BUSQUEDA DE N > 0,
          // SE VERIFICARA QUE EN ESOS ESPACIOS NO HAY HORAS CON ASESOR Y SI LO HAY QUE EVENTOS ASESOR < ASESORES TOTALES
          // SI HAY ESPACIO Y NO HAY ASESOR ENTONCES SE MUESTRA
          //************************************************************}
          
          // New array to add
          var longArray = 0;
          var listaCuandoExiste = null;
          if(mapaEventoDia != undefined){
            longArray = mapaEventoDia.length ;
            console.log(mapaEventoDia.length);
          }else{
            mapaEventoDia = [];
            listaCuandoExiste = {
              "12:00 AM": asesoresEspacios,
              "12:30 AM": asesoresEspacios,
              "1:00 AM": asesoresEspacios,
              "1:30 AM": asesoresEspacios,
              "2:00 AM": asesoresEspacios,
              "2:30 AM": asesoresEspacios,
              "3:00 AM": asesoresEspacios,
              "3:30 AM": asesoresEspacios,
              "4:00 AM": asesoresEspacios,
              "4:30 AM": asesoresEspacios,
              "5:00 AM": asesoresEspacios,
              "5:30 AM": asesoresEspacios,
              "6:00 AM": asesoresEspacios,
              "6:30 AM": asesoresEspacios,
              "7:00 AM": asesoresEspacios,
              "7:30 AM": asesoresEspacios,
              "8:00 AM": asesoresEspacios,
              "8:30 AM": asesoresEspacios,
              "9:00 AM": asesoresEspacios,
              "9:30 AM": asesoresEspacios,
              "10:00 AM": asesoresEspacios,
              "10:30 AM": asesoresEspacios,
              "11:00 AM": asesoresEspacios,
              "11:30 AM": asesoresEspacios,
              "12:00 PM": asesoresEspacios,
              "12:30 PM": asesoresEspacios,
              "1:00 PM": asesoresEspacios,
              "1:30 PM": asesoresEspacios,
              "2:00 PM": asesoresEspacios,
              "2:30 PM": asesoresEspacios,
              "3:00 PM": asesoresEspacios,
              "3:30 PM": asesoresEspacios,
              "4:00 PM": asesoresEspacios,
              "4:30 PM": asesoresEspacios,
              "5:00 PM": asesoresEspacios,
              "5:30 PM": asesoresEspacios,
              "6:00 PM": asesoresEspacios,
              "6:30 PM": asesoresEspacios,
              "7:00 PM": asesoresEspacios,
              "7:30 PM": asesoresEspacios,
              "8:00 PM": asesoresEspacios,
              "8:30 PM": asesoresEspacios,
              "9:00 PM": asesoresEspacios,
              "9:30 PM": asesoresEspacios,
              "10:00 PM": asesoresEspacios,
              "10:30 PM": asesoresEspacios,
              "11:00 PM": asesoresEspacios,
              "11:30 PM": asesoresEspacios
            };
          }
          var cantidadAgregada = 0;
          var newArray = null;
          console.log('===================== DIA ANTES =======================');
          var fechaHelper = helper.selectedDate;
          console.log(fechaHelper);
          var weekday =  fechaHelper.getDay();
          console.log(weekday);
          console.log('===================== DIA DESPUES =======================');
          console.log(formattedDate);
          //var weekday1 =  formattedDate.getDay();

          console.log('currentSucursal');
          console.log(currentSucursal);
  
          console.log('listRecurrentes');
          console.log(listRecurrentes);
  


          console.log('Dia semana ' + weekday);

          var listRecurrentes = helper.horasRecurrencias;

          for(let e = 0; e < listRecurrentes.length ; e++){
            console.log('dentro for paso');
            
            if(listRecurrentes[e][0] == currentSucursal ){
              cantidadAgregada = cantidadAgregada + 1 ; 
              if(weekday == 1 && listRecurrentes[e][4]){
                console.log('entro Lunes');
                newArray = [formattedDate, listRecurrentes[e][2],  listRecurrentes[e][3], listRecurrentes[e][1], listRecurrentes[e][0], "Asesor", listRecurrentes[e][0]];
                console.log(newArray);
                mapaEventoDia.push(newArray);
              }else if(weekday == 2 && listRecurrentes[e][5]){
                console.log('entro Martes');
                newArray = [formattedDate, listRecurrentes[e][2],  listRecurrentes[e][3], listRecurrentes[e][1], listRecurrentes[e][0], "Asesor", listRecurrentes[e][0]];
                console.log(newArray);
                mapaEventoDia.push(newArray);
              }else if(weekday == 3 && listRecurrentes[e][6]){
                console.log('entro Miercoles');
                newArray = [formattedDate, listRecurrentes[e][2],  listRecurrentes[e][3], listRecurrentes[e][1], listRecurrentes[e][0], "Asesor", listRecurrentes[e][0]];
                console.log(newArray);
                mapaEventoDia.push(newArray);
              }else if(weekday == 4 && listRecurrentes[e][7]){
                console.log('entro Jueves');
                newArray = [formattedDate, listRecurrentes[e][2],  listRecurrentes[e][3], listRecurrentes[e][1], listRecurrentes[e][0], "Asesor", listRecurrentes[e][0]];
                console.log(newArray);
                mapaEventoDia.push(newArray);
              }else if(weekday == 5 && listRecurrentes[e][8]){
                console.log('entro Viernes');
                newArray = [formattedDate, listRecurrentes[e][2],  listRecurrentes[e][3], listRecurrentes[e][1], listRecurrentes[e][0], "Asesor", listRecurrentes[e][0]];
                console.log(newArray);
                mapaEventoDia.push(newArray);
              }else if(weekday == 6 && listRecurrentes[e][9]){
                console.log('entro Sabado');
                newArray = [formattedDate, listRecurrentes[e][2],  listRecurrentes[e][3], listRecurrentes[e][1], listRecurrentes[e][0], "Asesor", listRecurrentes[e][0]];
                console.log(newArray);
                mapaEventoDia.push(newArray);
              }
            }
            console.log('dentro for paso salio');          
          }
          for (var f = 0; f < longArray; f++) {
            console.log('==elemento dentro==');
            console.log(mapaEventoDia[f]);
          }
          console.log('evento en día 1');
          console.log(mapaEventoDia);
          console.log('primer paso');
          
          // Push the new array into the existing array
          
          if(mapaEventoDia != undefined ){
    
            console.log('LISTA ORDENADA');
            var desordenada = mapaCompleto[2];
            if(desordenada[formattedDate] == undefined){
              console.log(listaCuandoExiste);
              desordenada[formattedDate] = listaCuandoExiste;
            }else{
              
            }
            var data = desordenada[formattedDate];
            // Convert the time strings to Date objects and sort them
            for (let key in data) {
                    
              data[key] = asesoresEspacios;                    
              data[key] = asesoresEspacios;
              
              // console.log(listaAsesores[key]);
              // console.log(sortedData[key]);
            }
            desordenada[formattedDate] = data;
            data = desordenada[formattedDate];
            console.log("===============LISTA ORDENADA===============");
            console.log(desordenada[formattedDate]);
            var sortedTimes = Object.keys(data)
            .map(time => ({ time, date: new Date(`2023-09-15 ${time}`) }))
            .sort((a, b) => a.date - b.date);
      
            // Create a new map with the sorted data
            var sortedData = {};
            sortedTimes.forEach(item => {
            sortedData[item.time] = data[item.time];
            });
      
            console.log(sortedData);
    
            
            console.log('keys');
            let keys = Object.keys(sortedData);
            var listaAsesores = {
              "12:00 AM": 0,
              "12:30 AM": 0,
              "1:00 AM": 0,
              "1:30 AM": 0,
              "2:00 AM": 0,
              "2:30 AM": 0,
              "3:00 AM": 0,
              "3:30 AM": 0,
              "4:00 AM": 0,
              "4:30 AM": 0,
              "5:00 AM": 0,
              "5:30 AM": 0,
              "6:00 AM": 0,
              "6:30 AM": 0,
              "7:00 AM": 0,
              "7:30 AM": 0,
              "8:00 AM": 0,
              "8:30 AM": 0,
              "9:00 AM": 0,
              "9:30 AM": 0,
              "10:00 AM": 0,
              "10:30 AM": 0,
              "11:00 AM": 0,
              "11:30 AM": 0,
              "12:00 PM": 0,
              "12:30 PM": 0,
              "1:00 PM": 0,
              "1:30 PM": 0,
              "2:00 PM": 0,
              "2:30 PM": 0,
              "3:00 PM": 0,
              "3:30 PM": 0,
              "4:00 PM": 0,
              "4:30 PM": 0,
              "5:00 PM": 0,
              "5:30 PM": 0,
              "6:00 PM": 0,
              "6:30 PM": 0,
              "7:00 PM": 0,
              "7:30 PM": 0,
              "8:00 PM": 0,
              "8:30 PM": 0,
              "9:00 PM": 0,
              "9:30 PM": 0,
              "10:00 PM": 0,
              "10:30 PM": 0,
              "11:00 PM": 0,
              "11:30 PM": 0
            };
            console.log('SI EXISTEN EVENTOS');
            console.log(asesoresEspacios);
            console.log(mecanicosEspacios);
            for (let key in sortedData) {
                    
              listaAsesores[key] = asesoresEspacios;                    
              sortedData[key] = mecanicosEspacios;
              
              // console.log(listaAsesores[key]);
              // console.log(sortedData[key]);
            }
            for (let key in listaAsesores) {
                    
              listaAsesores[key] = asesoresEspacios;                    
              listaAsesores[key] = asesoresEspacios;
              
              // console.log(listaAsesores[key]);
              // console.log(sortedData[key]);
            }
            for (let key in listaAsesores) {
              if( listaAsesores[key] != asesoresEspacios){
                listaAsesores[key] = asesoresEspacios;
              }     
  
              console.log('===============listaAsesores===============');
              console.log(listaAsesores[key]);
              // console.log(sortedData[key]);
            }
            for (let n = 0; n < keys.length; n++) {
              let key = keys[n];
              console.log('===============key===============');
              console.log(key);
              console.log(asesoresEspacios);
              console.log(mecanicosEspacios);
              listaAsesores[key] = asesoresEspacios;                    
              sortedData[key] = mecanicosEspacios;
              console.log(listaAsesores[key]);
              console.log(sortedData[key]);
              listaAsesores[key] = asesoresEspacios;                    
              sortedData[key] = mecanicosEspacios; 
              // console.log('===================dentroMILogica====================');
              // console.log(sortedData);
              console.log('listaAsesores');
              console.log(listaAsesores);
              // Iterate over each array
              //let dateValue = mapaEventoDia[i][0];
              //[0] date [1] Hora Inicio [2] Hora final [3] ID [4] ID [5] Tipo de cita
              for (let k = 0; k < mapaEventoDia.length; k++) {
                // Access the date value at the first index of the current array
                var horaDeInicio = mapaEventoDia[k][1];
                var horaDeFin = mapaEventoDia[k][2];
                var tipoCita = mapaEventoDia[k][5];
  
  
                var result = [];
                var currentDate = new Date(`2000-01-01 ${horaDeInicio}`);
                var endArraydDate = new Date(`2000-01-01 ${horaDeFin}`);
  
                while (currentDate < endArraydDate) {
                  var formattedTime = currentDate.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
                  if(formattedTime.toString()  == "05:00"){
                    formattedTime = '5:00 AM';
                  }else if(formattedTime.toString() == "05:30"){
                    formattedTime = '5:30 AM';
                  }else if(formattedTime.toString() == "06:00"){
                    formattedTime = '6:00 AM';
                  }else if(formattedTime.toString() == "06:30"){
                    formattedTime = '6:30 AM';
                  }else if(formattedTime.toString() == "07:00"){
                    formattedTime = '7:00 AM';
                  }else if(formattedTime.toString() == "07:30"){
                    formattedTime = '7:30 AM';
                  }else if(formattedTime.toString() == "08:00"){
                    formattedTime = '8:00 AM';
                  }else if(formattedTime.toString() == "08:30"){
                    formattedTime = '8:30 AM';
                  }else if(formattedTime.toString() == "09:00"){
                    formattedTime = '9:00 AM';
                  }else if(formattedTime.toString() == "09:30"){
                    formattedTime = '9:30 AM';
                  }else if(formattedTime.toString() == "10:00"){
                    formattedTime = '10:00 AM';
                  }else if(formattedTime.toString() == "10:30"){
                    formattedTime = '10:30 AM';
                  }else if(formattedTime.toString() == "11:00"){
                    formattedTime = '11:00 AM';
                  }else if(formattedTime.toString() == "11:30"){
                    formattedTime = '11:30 AM';
                  }
                  else if(formattedTime.toString() == "12:30"){
                    formattedTime = '12:30 PM';
                  }else if(formattedTime.toString()  == "12:00"){
                    formattedTime = '12:00 PM';
                  }else if(formattedTime.toString()  == "13:00"){
                    formattedTime = '1:00 PM';
                  }else if(formattedTime.toString()  == "13:30"){
                    formattedTime = '1:30 PM';
                  }else if(formattedTime.toString()  == "14:00"){
                    formattedTime = '2:00 PM';
                  }else if(formattedTime.toString()  == "14:30"){
                    formattedTime = '2:30 PM';
                  }else if(formattedTime.toString()  == "15:00"){
                    formattedTime = '3:00 PM';
                  }else if(formattedTime.toString()  == "15:30"){
                    formattedTime = '3:30 PM';
                  }else if(formattedTime.toString()  == "16:00"){
                    formattedTime = '4:00 PM';
                  }else if(formattedTime.toString()  == "16:30"){
                    formattedTime = '4:30 PM';
                  }else if(formattedTime.toString()  == "17:00"){
                    formattedTime = '5:00 PM';
                  }else if(formattedTime.toString()  == "17:30"){
                    formattedTime = '5:30 PM';
                  }else if(formattedTime.toString()  == "18:00"){
                    formattedTime = '6:00 PM';
                  }else if(formattedTime.toString()  == "18:30"){
                    formattedTime = '6:30 PM';
                  }else if(formattedTime.toString()  == "19:00"){
                    formattedTime = '7:00 PM';
                  }else if(formattedTime.toString()  == "19:30"){
                    formattedTime = '7:30 PM';
                  }
                  
  
                  result.push(formattedTime);
                  currentDate.setMinutes(currentDate.getMinutes() + 30);
                }
                // console.log('====================result====================');
                // console.log(result);
                //var asesoresEspacios = 0;
                //var mecanicosEspacios = 0;
                
                for (let j = 0; j < result.length; j++) {         
    
                  if(sortedData.hasOwnProperty(key) && key == result[j]){
                
                    if(mapaEventoDia[k][5] == 'Asesor'){
                      //AQUI SE REVISA SI ES ASESOR O NO
                      console.log('key dentro');
                      console.log(key);
                      listaAsesores[key] = listaAsesores[key] - 1;
                      console.log('===sucursal asesor quita 1=== ' + listaAsesores[key]);
                    }else{
                      // console.log('===sucursal le quita 1===');
                      console.log('key dentro');
                      console.log(key);
                      //SI NO ES ENTONCES SOLO RESTAMOS 1 ESPACIO
                      sortedData[key] = sortedData[key] - 1;
                      console.log('===sucursal Calendario quita 1=== ' + listaAsesores[key]);
                    }
                  }    
                }
  
                               
  
                // Convert string times to Date objects
                // const startDate = new Date(`2000-01-01 ${startTime}`);
                // const endDate = new Date(`2000-01-01 ${endTime}`);
                // const targetDate = new Date(`2000-01-01 ${targetTime}`);
  
                // Check if the target time is between the start and end times
                //return targetDate >= startDate && targetDate <= endDate;   
              }
  
              
              
            }
            var resultReal = [];
            var listaFinal = [];
            listaFinal = listaAsesores;
            var cantidadMinutos =  helper.minutosSucursal;
            var quitarMinutos = cantidadMinutos / 30;
            let keys1 = Object.keys(listaFinal);
            // console.log(keys1);
            for (let m = 0; m < keys1.length; m++) {
              var siPasa = true;
              let key = keys1[m];
  
              console.log('=======================(listaFinal);=================');
              console.log(listaFinal);
  
              //aqui vamos a controlar primero si es Sincronica
              var boolEsSincronica =  helper.esSincronica;
              if(boolEsSincronica == true){
                if(listaFinal[key] > 0){
                  for (let o = m ; o < m + quitarMinutos && o < keys1.length; o++) {
  
                    if(listaFinal[keys[o]] > 0){
  
                    }else{
  
                      siPasa = false;
                      break;
                    }
                  }
                  if(!siPasa){
                    listaFinal[key] = 0;
                    listaFinal[key] = 0;
                  }else{
                    
                  }
                }else{
                    listaFinal[key] = 0;
                    listaFinal[key] = 0;
                }
  
              }
  
              if(listaFinal[key] > 0){
                
                // console.log(m);
                for (let o = m + 1; o <= m + quitarMinutos && o < keys1.length; o++) {
                  // console.log(o);
                  // console.log(keys[o]);
                  // console.log(sortedData[keys[o]]);
                  // console.log(keys1[o]);
                  // console.log(sortedData[keys1[o]]);
                  if(sortedData[keys[o]] > 0){
                    
                    // console.log('=========== SI PASO ==============');
                    // console.log(key);
                    // console.log(sortedData[keys1[o]]);
                  }else{
                    // console.log('=========== NO PASO ==============');
                    // console.log(key);
                    // console.log(sortedData[keys1[o]]);
                    siPasa = false;
                    break;
                  }
                }
                if(!siPasa){
                  // console.log('=========== se resto a cero siPasa ==============');
                  listaFinal[key] = 0;
                  listaAsesores[key] = 0;
                  // console.log(listaAsesores[key]);
                  // console.log(listaFinal[key]);
                  listaFinal[key] = 0;
                }else{
                  resultReal.push(key);
                }
              }else{
                // console.log('=========== se resto a cero ==============');
                  listaFinal[key] = 0;
                  listaAsesores[key] = 0;
                  // console.log(listaAsesores[key]);
                  // console.log(listaFinal[key]);
                  listaFinal[key] = 0;
              }
            }
            console.log('===================resultReal===================');
            console.log(resultReal);
            let keysOfEventsOnSelectedDate = resultReal;
            let eventsCount = 0;
  
  
  
  
            //=================== ESTO LO IMPRIME EN LOS CUADROS SI LOS ASESORES SON MENOS QUE MECANICOS==============
            for (var z = 0; z < keysOfEventsOnSelectedDate.length; z++  ) {
              
              // *******************************************************************
              // AQUI VA UN IF QUE REVISA LA KEY Y LA BUSCA EN EL HORARIO DE EVENTOS
              // SI ENCUENTRA EL EVENTO DE INICIO EN LOS EVENTOS Y LA CANTIDAD DE ASESORES ES LIMITE, LO PASAMOS asesoresEspacios
              var pasaValidacion = false;
              var contadorAsesor = 0;
              // console.log(' PASO 1 ');
              // console.log (asesoresEspacios) ;
  
              /*
              for(var m = 0; m < mapaEventoDia.length; m++){
                var horarioActual = mapaEventoDia[m];
                // Time strings to compare
                var startTime = horarioActual[1];
                var endTime = horarioActual[2];
                var targetTime = keysOfEventsOnSelectedDate[key];
                // console.log(startTime);
                // console.log(endTime);
                // console.log(targetTime);
                // Convert time strings to Date objects
                var startDate = new Date(`2023-09-15 ${startTime}`);
                var endDate = new Date(`2023-09-15 ${endTime}`);
                var targetDate = new Date(`2023-09-15 ${targetTime}`);
    
                if( horarioActual[5] == 'Asesor' && targetDate >= startDate && targetDate < endDate){
                  // console.log(horarioActual);
                  contadorAsesor = contadorAsesor + 1;
                }
              }
              */
  
              //============================================
                //nuevo proceso para sacar a los improductivos
                //============================================
                /*
                var eventosRecurrentes = helper.horasRecurrencias;              
                var calendarioSel = component.get("v.selectedSucursal").toString();
                for (var q = 0; q < eventosRecurrentes.length; q++) {
                  var currentEventRecurrent = eventosRecurrentes[q];
  
                  var startTime = currentEventRecurrent[1];
                  var endTime = currentEventRecurrent[2];
                  var targetTime = keysOfEventsOnSelectedDate[key];
                  
                  var startDate = new Date(`2023-09-15 ${startTime}`);
                  var endDate = new Date(`2023-09-15 ${endTime}`);
                  var targetDate = new Date(`2023-09-15 ${targetTime}`);
                  if(currentEventRecurrent[0] == calendarioSel && targetDate >= startDate && targetDate < endDate){
                    contadorAsesor = contadorAsesor + 1;
                  }
                }
                */
              // console.log(' PASO 2 ');
              // console.log(contadorAsesor);
              // console.log(contadorAsesor < asesoresEspacios);
  
              //if(contadorAsesor < asesoresEspacios && sortedData[keysOfEventsOnSelectedDate[key]] > 0){
                pasaValidacion = true;
              //}
  
              // console.log(' PASO 3 ');
              // console.log(pasaValidacion);
              if(pasaValidacion){
                // console.log(' PASO 4 ');
                var element = keysOfEventsOnSelectedDate[z];      
                // console.log('element');   
                // console.log(element);                
                var toBeIncluded = helper.checkHourInOperativeHour(element,formattedDate);
                // console.log('toBeIncluded');   
                // console.log(toBeIncluded);          
                if (toBeIncluded == true) {
                  //console.log(' PASO 5 ');
                  var eventHourName = sortedData[element];
                  let eventContainer = document.createElement("div");
                  eventContainer.className = "eventCard col-md-3";
                  let eventAction = document.createElement("div");
                  eventAction.className = "eventCard-action";
                  // console.log(' PASO 6 ');
                  let eventActionExecution = document.createElement("button");
                  eventActionExecution.Type = "button";
                  eventActionExecution.className = "waves-effect waves-light btn blue lighten-2";
                  eventActionExecution.appendChild(document.createTextNode(element));
                  eventAction.appendChild(eventActionExecution);
                  eventContainer.appendChild(eventAction);
                  // console.log(' PASO 7 ');
                  sidebarEvents.appendChild(eventContainer);
                  eventsCount++;
                }
              }
              
              let emptyFormMessage = document.getElementById("sidebar-texttitle");
              emptyFormMessage.innerHTML = `${eventsCount} Citas Disponibles`;
    
            }
            //===================== FIN BLOQUE IMPRIMIR ======================
            if(cantidadAgregada > 0){
              mapaEventoDia.splice(longArray, cantidadAgregada);
            }
            
            console.log('evento en día 2');
            console.log(mapaEventoDia); 
          }else{
            //proceso normal si los mecanicos son menos o iguales a los asesores
            let eventsOnSelectedDate = helper.loadDayAvailability(component,formattedDate, globalEventObj);
            var intervalId = component.get("v.setIntervalId");
    
            if (eventsOnSelectedDate != "No events") {
            //console.log('entro showEvents No events');
            let keysOfEventsOnSelectedDate = Object.keys(eventsOnSelectedDate[formattedDate]);
            sidebarEvents.innerHTML = "";
            // console.log(keysOfEventsOnSelectedDate);
            // console.log(eventsOnSelectedDate);
            if (eventsOnSelectedDate) {
              let eventsCount = 0;
              for (var key in keysOfEventsOnSelectedDate) {
                var element = keysOfEventsOnSelectedDate[key];
                var weekday =  helper.selectedDate.getDay();
                var toBeIncluded = helper.checkHourInOperativeHour(element,formattedDate);
    
                
                if (toBeIncluded) {
                  var eventHourName = eventsOnSelectedDate[formattedDate][element];
                  let eventContainer = document.createElement("div");
                  eventContainer.className = "eventCard col-md-3";
                  let eventAction = document.createElement("div");
                  eventAction.className = "eventCard-action";
                  let eventActionExecution = document.createElement("button");
                  eventActionExecution.Type = "button";
                  eventActionExecution.className = "waves-effect waves-light btn blue lighten-2";
                  eventActionExecution.appendChild(document.createTextNode(element));
                  eventAction.appendChild(eventActionExecution);
                  eventContainer.appendChild(eventAction);
                  sidebarEvents.appendChild(eventContainer);
                  eventsCount++;
                }
              }
    
              let emptyFormMessage = document.getElementById("sidebar-texttitle");
              emptyFormMessage.innerHTML = `${eventsCount} Citas Disponibles`;
            }
            console.log('salio showEvents No events');
            } else {
              console.log('entro showEvents Else');
              let sidebarTitle = document.getElementById("sidebar-texttitle");
              sidebarTitle.innerHTML = 'Citas Disponibles:';
              let emptyMessage = document.createElement("div");
              emptyMessage.className = "empty-message";
              emptyMessage.innerHTML = "Lo sentimos, no hay citas disponibles en la fecha seleccionada.";
              sidebarEvents.appendChild(emptyMessage);
              let emptyFormMessage = document.getElementById("emptyFormTitle");
              emptyFormMessage.innerHTML = "No hay citas.";
              console.log('salio showEvents Else');
            }
          }
        }else{
          //proceso normal si los mecanicos son menos o iguales a los asesores
          let eventsOnSelectedDate = helper.loadDayAvailability(component,formattedDate, globalEventObj);
          var intervalId = component.get("v.setIntervalId");
    
          if (eventsOnSelectedDate != "No events") {
            console.log('entro showEvents No events');
            let keysOfEventsOnSelectedDate = Object.keys(eventsOnSelectedDate[formattedDate]);
            sidebarEvents.innerHTML = "";
            // console.log(keysOfEventsOnSelectedDate);
            // console.log(eventsOnSelectedDate);
            if (eventsOnSelectedDate) {
              let eventsCount = 0;
              for (var key in keysOfEventsOnSelectedDate) {
                var element = keysOfEventsOnSelectedDate[key];
                var weekday =  helper.selectedDate.getDay();
                var toBeIncluded = helper.checkHourInOperativeHour(element,formattedDate);
    
                
                if (toBeIncluded) {
                  var eventHourName = eventsOnSelectedDate[formattedDate][element];
                  let eventContainer = document.createElement("div");
                  eventContainer.className = "eventCard col-md-3";
                  let eventAction = document.createElement("div");
                  eventAction.className = "eventCard-action";
                  let eventActionExecution = document.createElement("button");
                  eventActionExecution.Type = "button";
                  eventActionExecution.className = "waves-effect waves-light btn blue lighten-2";
                  eventActionExecution.appendChild(document.createTextNode(element));
                  eventAction.appendChild(eventActionExecution);
                  eventContainer.appendChild(eventAction);
                  sidebarEvents.appendChild(eventContainer);
                  eventsCount++;
                }
              }
    
              let emptyFormMessage = document.getElementById("sidebar-texttitle");
              emptyFormMessage.innerHTML = `${eventsCount} Citas Disponibles`;
            }
            console.log('salio showEvents No events');
          } else {
            console.log('entro showEvents Else');
            let sidebarTitle = document.getElementById("sidebar-texttitle");
            sidebarTitle.innerHTML = 'Citas Disponibles:';
            let emptyMessage = document.createElement("div");
            emptyMessage.className = "empty-message";
            emptyMessage.innerHTML = "Lo sentimos, no hay citas disponibles en la fecha seleccionada.";
            sidebarEvents.appendChild(emptyMessage);
            let emptyFormMessage = document.getElementById("emptyFormTitle");
            emptyFormMessage.innerHTML = "No hay citas.";
            console.log('salio showEvents Else');
          }
        }
        
    
       
        /*helper.firstRun = false;*/
        console.log('salio showEvents');
      }
      //console.log('----------------------- Calendario muestra eventos 2 ----------------------');
      //showEvents();
    
      
      //este muestra los dias
      gridTable.onclick = function (e) {
        var intervalId = component.get("v.setIntervalId");
        console.log(intervalId);
        window.clearInterval(intervalId);
        clearInterval(intervalId);
        helper.countdown = false;
        console.log('event ' + e);
        console.log(e);
        console.log('este es el show event');
        console.log('entro gridTable click');
        if (!e.target.innerHTML.includes('circle-gray-availability')) {
          var tipoDeCita = component.get("v.citaMovil");
          if(tipoDeCita){
            helper.selectedDate = new Date(helper.currentDate.getFullYear(), helper.currentDate.getMonth(), parseInt(e.target.innerHTML));
          }else{            
            document.getElementById("sidebar").style.display = "";
            var elmntToView = document.getElementById("eventDayName");
            elmntToView.scrollIntoView();
      
            // document.getElementsByClassName("centroDeServicio")[0].style.display = "";
            // document.getElementsByClassName("centroDeServicio")[0].scrollIntoView();
            if (!e.target.classList.contains("col") || e.target.classList.contains("empty-day")) {
              return;
            }
            if (selectedDayBlock) {
              if (selectedDayBlock.classList.contains("blue") && selectedDayBlock.classList.contains("lighten-3")) {
                selectedDayBlock.classList.remove("blue");
                selectedDayBlock.classList.remove("lighten-3");
              }
            }
            selectedDayBlock = e.target;
            selectedDayBlock.classList.add("blue");
            selectedDayBlock.classList.add("lighten-3");
            helper.selectedDate = new Date(helper.currentDate.getFullYear(), helper.currentDate.getMonth(), parseInt(e.target.innerHTML));
            console.log('----------------------- Calendario muestra eventos 3----------------------');
            //proceso para cambiar las listas:
            //---------------------------------------
            var weekday =  helper.selectedDate.getDay();
                console.log('weekday horarios '+ weekday);
            var currentSucursal = component.get("v.selectedSucursal").toString();
            console.log('sucursal horarios ' + currentSucursal);
            console.log('sucursal horas ' + helper.horas);
            helper.adaptHoursWeekly(helper.horas, currentSucursal,weekday);
            console.log('salio adaptHoursWeekly');
            //---------------------------------------
            showEvents();
            document.getElementById("eventDayName").innerHTML = helper.selectedDate.toLocaleString("es-ES", {
              month: "long",
              day: "numeric",
              year: "numeric"
            });
          }
        }
        helper.handleChangeServiceCenter(component, event, helper);
        console.log('salio gridTable click');
      }
    
      var changeFormButton = document.getElementById("changeFormButton");
      var addForm = document.getElementById("addForm");
      changeFormButton.onclick = function (e) {
        console.log('entro changeFormButton click');
        addForm.style.top = 0;
        console.log('salio changeFormButton click');
      }
    
      var foo = document.getElementById("sidebarEvents");
      foo.onclick = function (e) {
        console.log('entro foo.onclick');
        var intervalId = component.get("v.setIntervalId");
        // console.log(intervalId);
        window.clearInterval(intervalId);
        clearInterval(intervalId);
        helper.countdown = false;
        var element = e.target;
        if (element.Type === "button") {
          var ddate = new Date(helper.selectedDate.getFullYear(), helper.selectedDate.getMonth(), helper.selectedDate.getDate());
          var selectedHour = element.innerText;
          if (element.className != "circle-gray-availability") {
            component.set("v.selectedHour", selectedHour);
            
          }
        }
    
        //crear el evento para crear una hora reserva.    
    
          
          //creacion de hora para calendario
          var day = new Date(ddate);
          var startDateHour = new Date(day.getFullYear(), day.getMonth(), day.getDate());
          startDateHour.setHours(helper.getHour(selectedHour), helper.getMinute(selectedHour), 0, 0);
          var serviceCenter = component.get("v.selTabId");
    
          component.set("v.startDateHour", startDateHour);  
          var action2 = component.get("c.getHourAvailability");
          //creacion de hora para calendario
          action2.setParams({
            
            "calendarId" : serviceCenter,
            "horaSelc" : startDateHour          
          });
          action2.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
              var storeResponse = response.getReturnValue();
              // console.log(storeResponse);
              component.set("v.horasReservas", storeResponse);
              // console.log('corre conexion h 8');
              var mensajeError = storeResponse;
              //proceso para revisar si existe
              // console.log("tiene Valor?");
              // console.log(mensajeError);
              var lOfEvents = mensajeError;
              //console.log(lOfEvents);
              var eventSize2 = lOfEvents.length;
              var variableControl = 1;
              for(var j = 0; j < eventSize2; j++){    
                var dateAnalisis = new Date(lOfEvents[j].fecha_reserva__c);  
                // console.log(dateAnalisis.toString());    
                // console.log(startDateHour.toString());              
                if(dateAnalisis.toString() == startDateHour.toString()){
                  variableControl = 0;
                }
                
              }
              console.log('variableControl' + variableControl);
              if(variableControl == 1){
                  component.set("v.isModalOtro", false);
                  var currentTime = new Date();   
                  console.debug("Test");
                  
                  var countdownDate = new Date(currentTime.getTime() + (3 * 60000));
                  // Update the countdown every second
                  // console.log("helper.countdown ");
                  // console.log(helper.countdown );
                  helper.countdown = false;
    
                  if(helper.countdown != undefined){
    
                  
               
              }
    
              
                //alert("Tiene 3 minutos para elegir.");        
                component.set("v.isModalMinutes", true);
    
                console.log('-------Date------- ' + helper.selectedDate)
                const dateEs = Date.parse(helper.selectedDate);
    
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
                //es aqui la fecha?
                component.set("v.selectedDate", helper.selectedDate.toDateString());
                helper.setVehiculeIdConfirmation(component);
              }else{
                var intervalId = component.get("v.setIntervalId");
                console.log(intervalId);
                window.clearInterval(intervalId);
                clearInterval(intervalId);
                helper.countdown = false;
                component.set("v.isModalMinutes", false);
                component.set("v.isModalOpenConfirmation", false);
                component.set("v.isModalOtro", true);
                variableControl = 1;
              }
            } else {
              console.log("error");
              console.log(response.getError());
            }
    
          });
          $A.enqueueAction(action2);
    
         
          var mensajeError = component.get("v.horasReservas");
          //proceso para revisar si existe
          // console.log("tiene Valor?");
          // console.log(mensajeError);
          var lOfEvents = mensajeError;
          //console.log(lOfEvents);
          var eventSize2 = lOfEvents.length;
          var variableControl = 1;
          for(var j = 0; j < eventSize2; j++){    
            var dateAnalisis = new Date(lOfEvents[j].fecha_reserva__c);  
            // console.log(dateAnalisis.toString());    
            // console.log(startDateHour.toString());              
            if(dateAnalisis.toString() == startDateHour.toString()){
              variableControl = 0;
            }
            
          }
          // console.log('variableControl' + variableControl);
              if(variableControl == 1){
                component.set("v.isModalOtro", false);
                var currentTime = new Date();        
                var countdownDate = new Date(currentTime.getTime() + (3 * 60000));
                // Update the countdown every second
    
    
    
                var interval = setInterval(function() {  
                // Get the current date and time
                var now = new Date().getTime();
    
                // Calculate the time remaining
                var timeRemaining = countdownDate - now;
    
                // Calculate the days, hours, minutes, and seconds
                var days = Math.floor(timeRemaining / (1000 * 60 * 60 * 24));
                var hours = Math.floor((timeRemaining % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
                var minutes = Math.floor((timeRemaining % (1000 * 60 * 60)) / (1000 * 60));
                var seconds = Math.floor((timeRemaining % (1000 * 60)) / 1000);
                
    
                // Display the countdown in a specific element on the page
                document.getElementById("countdown").innerHTML =  minutes + "m " + seconds + "s ";
    
                  // If the countdown is finished, display a message
                  if (timeRemaining < 0) {
                    var intervalId = component.get("v.setIntervalId");
                    console.log(intervalId);
                    window.clearInterval(intervalId);
                    clearInterval(intervalId);
                      document.getElementById("countdown").innerHTML = "Countdown Finished!";
                      component.set("v.isModalOffMinutes", true);          
                      component.set("v.isModalOpenConfirmation", false);
                  }
                }, 1000);
                //alert("Tiene 3 minutos para elegir.");        
                component.set("v.isModalMinutes", true);
                component.set("v.setIntervalId", interval) ;
                //document.getElementById('testJD').style.display = "";
                
                //document.getElementById('verificarSection').style.display = "none";
                //document.getElementById('additionalServices').style.display = "none";
                //es Aqui?
    
                console.log('-------Date------- ' + helper.selectedDate)
                const dateEs = Date.parse(helper.selectedDate);
    
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
              }else{
                clearInterval(helper.countdown);
                helper.countdown = false;
                component.set("v.isModalMinutes", false);
                component.set("v.isModalOpenConfirmation", false);
                component.set("v.isModalOtro", true);
                variableControl = 1;
              }
    
            
          console.log('salio foo.onclick');
        
        
        }
      //---------------- proceso de agendar cita   
    
      var cancelAdd = document.getElementById("cancelAdd");
      cancelAdd.onclick = function (e) {
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
      addEventButton.onclick = function (e) {
        console.log('entro   addEventButton.onclick');
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
          console.log('----------------------- Calendario muestra eventos ----------------------');
    
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
        console.log('salio   addEventButton.onclick');
      } // aqui*/
      //component.set("v.controllerFirstRun", false);
      console.log('salio myFunction2');
    },


    resetContador: function (component, event, helper) {
      clearInterval(helper.countdown);
      clearInterval(helper.countdown);
    
      helper.countdown = false;
    },
    
    createCalendar: function (currentDate, side, gridTable, selectedDayBlock, selectedDate, globalEventObj) {
      var startDate = new Date(currentDate.getFullYear(), currentDate.getMonth(), 1);
    
      var monthTitle = document.getElementById("month-name");
      var monthName = currentDate.toLocaleString("es-ES", {
        month: "long"
      });
      var yearNum = currentDate.toLocaleString("es-ES", {
        year: "numeric"
      });
      monthTitle.innerHTML = `${monthName} ${yearNum}`;
    
      if (side == "left") {
        gridTable.className = "animated fadeOutRight";
      } else {
        gridTable.className = "animated fadeOutLeft";
      }
    
      // setTimeout(() => {
        gridTable.innerHTML = "";
    
        var newTr = document.createElement("div");
        newTr.className = "row";
        var currentTr = gridTable.appendChild(newTr);
    
        for (let i = 1; i < (startDate.getDay() || 7); i++) {
          let emptyDivCol = document.createElement("div");
          emptyDivCol.className = "col empty-day";
          currentTr.appendChild(emptyDivCol);
        }
    
        var lastDay = new Date(currentDate.getFullYear(), currentDate.getMonth() + 1, 0);
        lastDay = lastDay.getDate();
    
        for (let i = 1; i <= lastDay; i++) {
          console.log('CALENDARIO EVENTO COLOR ' + i);
          if (currentTr.children.length >= 7) {
            currentTr = gridTable.appendChild(addNewRow());
          }
          let currentDay = document.createElement("div");
          currentDay.className = "col";
          if (selectedDayBlock == null && i == currentDate.getDate() || selectedDate.toDateString() == new Date(currentDate.getFullYear(), currentDate.getMonth(), i).toDateString()) {
            selectedDate = new Date(currentDate.getFullYear(), currentDate.getMonth(), i);
            var selectedFormattedDate = selectedDate.getFullYear() + '-' + String(selectedDate.getMonth() + 1).padStart(2, '0') + '-' + String(selectedDate.getDate()).padStart(2, '0');
    
            document.getElementById("eventDayName").innerHTML = selectedDate.toLocaleString("es-ES", {
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
          currentDay.innerHTML = i;
    
          if (component.get("v.controllerFirstRun") != true) {
    
            //show marks
            if (i === 21 || i === 17 || i === 12 || i === 13 || i === 14 || i === 18 || i === 19 || i === 20 || i === 22 /*globalEventObj[new Date(helper.currentDate.getFullYear(), helper.currentDate.getMonth(), i).toDateString()]*/ ) {
              let eventMark = document.createElement("div");
              eventMark.className = "circle-red-availability";
              currentDay.appendChild(eventMark);
            }
    
            if (i === 1 || i === 2 || i === 3 || i === 4 || i === 5 || i === 6 || i === 8 || i === 9 || i === 10 || i === 11 || i === 15 || i === 16
              /*globalEventObj[new Date(helper.currentDate.getFullYear(), helper.currentDate.getMonth(), i).toDateString()]*/
            ) {
              let eventMark = document.createElement("div");
              eventMark.className = "circle-green-availability";
              currentDay.appendChild(eventMark);
            }
            if (i === 24 || i === 23 || i === 25 || i === 26 || i === 27 || i === 28 || i === 29 || i === 30 || i === 31 /*globalEventObj[new Date(helper.currentDate.getFullYear(), helper.currentDate.getMonth(), i).toDateString()]*/ ) {
              let eventMark = document.createElement("div");
              eventMark.className = "circle-yellow-availability";
              currentDay.appendChild(eventMark);
            }
    
    
            //show marks
            if (globalEventObj[new Date(currentDate.getFullYear(), currentDate.getMonth(), i).toDateString()]) {
              let eventMark = document.createElement("div");
              eventMark.className = "day-mark";
              currentDay.appendChild(eventMark);
            }
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
    
      // }, !side ? 0 : 270);
      //component.set("v.controllerFirstRun", false);
    },
    
    myFunction: function (component, event, helper) {
    
      //helper.echo(component);
      /*$(".button-collapse").sideNav();*/
      var calendar = document.getElementById("calendar-table");
      var gridTable = document.getElementById("table-body");
      var selectedDayBlock = null;
      var globalEventObj = {};
      var currentDate = this.currentDate;
      var selectedServiceCenter = this.selectedServiceCenter;
      var selectedService = this.selectedService;
      var selectedDate = this.selectedDate;
      console.log('----------------------- Calendario muestra eventos 1 ----------------------');
      this.showEvents(component,selectedDate, globalEventObj, helper);
    
      this.createCalendar(this.currentDate, "", gridTable, selectedDayBlock, selectedDate, globalEventObj);
    
    },
    
    handleChangeServiceCenter: function (component, event, helper) {
    
      
      var selectedService = component.get("v.serviceSelected");
      helper.selectedService = selectedService;
      var selectedTabServiceCenter = component.get("v.selTabId");
      helper.selectedServiceCenter = selectedTabServiceCenter;
    
      var serviceCenterName = helper.locations[selectedTabServiceCenter];
      component.set("v.serviceCenterSelectedName", serviceCenterName);
    
      //helper.selectedDate = selectedTabServiceCenter;
      // To add the call of myFunction with the selections
      //helper.showEvents(selectedTabServiceCenter); 
      var tipoDeCita = component.get("v.citaMovil");
      if(tipoDeCita){        
        document.getElementById("sidebarMovil").style.display = "";
      }else{
        document.getElementById("sidebar").style.display = "";
        showEvents();
      }
      
      // To add the call of myFunction with the selections
      //helper.showEvents(component, event, helper, selectedTabServiceCenter);
      helper.myFunction2(component, event, helper);
      
    },
     addMinutesToTime: function(timeString, minutesToAdd) {
      // Parse the input time string
      const [hours, minutes, ampm] = timeString.split(/[:\s]+/);
    
      // Convert hours and minutes to integers
      let newHours = parseInt(hours);
      let newMinutes = parseInt(minutes);
    
      // Convert the time to 24-hour format for calculations
      if (ampm.toLowerCase() === 'pm' && newHours !== 12) {
        newHours += 12;
      } else if (ampm.toLowerCase() === 'am' && newHours === 12) {
        newHours = 0;
      }
    
      // Add minutes
      newMinutes += minutesToAdd;
    
      // Calculate new hours and minutes
      const overflowHours = Math.floor(newMinutes / 60);
      newHours = (newHours + overflowHours) % 24;
      newMinutes = newMinutes % 60;
    
      // Convert back to 12-hour format
      const newAmPm = newHours < 12 ? 'AM' : 'PM';
      newHours = newHours % 12 || 12;
    
      // Format the new time string
      const newTimeString = `${newHours}:${newMinutes.toString().padStart(2, '0')} ${newAmPm}`;
    
      return newTimeString;
    }        
    })