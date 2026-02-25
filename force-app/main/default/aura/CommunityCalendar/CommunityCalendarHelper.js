({

	/* Start of Global variables _________________________________________________________________________________________________*/
	availability: [],
	horas_: {
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
		"5:00 PM": "Available"
	},
	horas: {
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
		"5:00 PM": 0
	},
    horasAv: {
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
		"5:00 PM": 1
	},
	services: {
		"Mecánica Rápida": [{
			"Label": "Escazú",
			"value": "0054U000009hipBQAQ"
		}, {
			"Label": "Pavas",
			"value": "0054U000009hiw2QAA"
		}, {
			"Label": "Pinares",
			"value": "0054U000009hiwHQAQ"
		}, {
			"Label": "Uruca",
			"value": "0054U000009hiwMQAQ"
		}],
		"Diagnóstico": [{
			"Label": "Pavas",
			"value": "0054U000009hiwCQAQ"
		}, {
			"Label": "Uruca",
			"value": "0054U000009hiwRQAQ"
		}],
		"Otobai": [{
			"Label": "Pavas",
			"value": "0054U00000Bes4GQAR"
		}],
		"Enderezado y Pintura": [{
			"Label": "Uruca",
			"value": "0054U000009hiwWQAQ"
		}]
	},
	capacityBySucursal: {},
        cmp:'',
	dataStructuresByServiceCenter: {}, //DSBSC = dataStructuresByServiceCenter =-> DSBSC[i][0] = listOfEvents;	DSBSC[i][1] = listOfDays; DSBSC[i][3] = availabilityByDates;	DSBSC[i][4] = citationsByDate;	


	// Elements to be replicated on each Service Center.
	// eBSC[i][0] = ServiceCenterID;	eBSC[i][1] = listOfEvents;	eBSC[i][3] = availabilityByDates;	eBSC[i][4] = citationsByDate;	eBSC[i][2] = listOfDays, 
	listOfEvents: [], // Server Response with the list of events
	listOfDays: [], // List of days based on server response________________:	[25/08/2022, 26/08/2022]
	availabilityByDates: {}, // List with the available spaces by day and hour_______:	{25/08/2022: {"7:30 AM": 0, "8:00 AM": 1, "8:30AM": 2, ... }
	citationsByDate: {}, // List of citations by date from StartTime to EndTime__: 	{25/08/2022: [[25/08/2022, "7:30 AM", "9:30AM"], ...]; 26/08/2022: [[26/08/2022, "8:00 AM", "8:30AM"]]

	/*
	TEST
	*/

	currentDate: '',
	selectedDate: '',
	globalEventObj: '',
	sidebar: '',
	selectedDayBlock: '',
	gridTable: '',
	selectedService: '',
	selectedServiceCenter: '',


	/* End of Global variables _________________________________________________________________________________________________*/


	/* Start of Functions to support view behaviour ___________________________________________________________________________________________________________*/

	findSelectedDayAvailability: function(formattedDate, serviceCenter) {
		//DSBSC = dataStructuresByServiceCenter =-> DSBSC[i][0] = listOfEvents;	DSBSC[i][1] = listOfDays; DSBSC[i][3] = availabilityByDates;	DSBSC[i][4] = citationsByDate;

       var availabilityByDates = this.dataStructuresByServiceCenter.get(this.selectedServiceCenter);       
       var elementToEvaluate = availabilityByDates[2];
		if (elementToEvaluate[formattedDate] === undefined) {
            availabilityByDates[2][formattedDate] = this.horasAv;
            console.log("Inside the if");
            console.log(availabilityByDates);
		}
        console.log("after changes");
        console.log(availabilityByDates);
		return availabilityByDates[2][formattedDate];
	},

	loadDayAvailability: function(formattedDate, globalEventObj) {
		console.log("loadDayAvailability");
		var serviceCenter = this.serviceCenter;
		var dayAvailability = this.findSelectedDayAvailability(formattedDate, serviceCenter);
        console.log(dayAvailability);

		if (dayAvailability != undefined || dayAvailability != null) {
			var keysOfDays = Object.keys(dayAvailability);
            console.log(keysOfDays);
			var keysSize = Object.keys(dayAvailability).length - 1;
            console.log(keysSize);
			console.log("Next is the for");
			for (var i = 0; i <= keysSize; i++) {
				if (dayAvailability[keysOfDays[i]] > 0) {
					this.globalEventObj = this.addEvent(keysOfDays[i], dayAvailability[keysOfDays[i]], globalEventObj, formattedDate);
                    console.log(this.globalEventObj);
				}
			}
            console.log("this.globalEventObj in load day aava");
            console.log(this.globalEventObj);
			return this.globalEventObj;

		}
		return "No events";
	},

	addEvent: function(title, desc, globalEventObj, selectedDate) {
		if (selectedDate != undefined) {
			if (!globalEventObj[selectedDate]) {
				globalEventObj[selectedDate] = {};
			}
			globalEventObj[selectedDate][title] = desc;
			this.globalEventObj = globalEventObj;
			return this.globalEventObj;
		}
	},


	/* End of Functions to support view behaviour ________________________________________________________________________________________________________________*/



	/* Start of Functions to support view behaviour _____________________________________________________________________________________________________________*/



	/* Start Calendar functions______________________________________________________*/

	//Done ---------------------
	//Retorns the calendar associated to the asesor.
	findCalendarName: function(asesor, asesoresByCalendar) {
		var asxcalendarSize = asesoresByCalendar.length;
		for (var i = 0; i <= asxcalendarSize; i++) {
			if (asesoresByCalendar[i]["Asesor__c"] === asesor) {
				return asesoresByCalendar[i]["Calendario__c"];
			}
		}
	},

	//Done ---------------------
	//Join the list of events and the calendar Id. 
	joinEventsAndAsesores: function(helper, asesoresByCalendar, eventResults) {
		var eventsSize = eventResults.length - 1;
		for (var i = 0; i <= eventsSize; i++) {
			eventResults[i].push(this.findCalendarName(eventResults[i][3], asesoresByCalendar));
		}
		console.log("joinEventsAndAsesores");
	},

	//Done ---------------------
	//Set the hours availability based on the sucursal capacity.
	setHoursCapacityBySucursal: function(currentSucursal) {
		console.log("setHoursCapacityBySucursal");
		var hoursCapacityBySucursal = JSON.parse(JSON.stringify(this.horas));
		var keys = Object.keys(hoursCapacityBySucursal);
		var hoursCapacitySize = keys.length - 1;

		for (var i = 0; i <= hoursCapacitySize; i++) {
			hoursCapacityBySucursal[keys[i]] = this.capacityBySucursal[currentSucursal];
		}
		return hoursCapacityBySucursal;
	},

	//Done ---------------------
	//Define a data structure for each sucursal.
	defineDataStructuresForServiceCenters: function(listOfEvents) {
		console.log("defineDataStructuresForServiceCenters");
		var toIterate = Object.keys(this.capacityBySucursal);
		this.dataStructuresByServiceCenter = new Map();

		for (var i in toIterate) {
			//DSBSC = dataStructuresByServiceCenter =-> DSBSC[i][0] = listOfEvents;	DSBSC[i][1] = listOfDays; DSBSC[i][3] = availabilityByDates;	DSBSC[i][4] = citationsByDate;
			this.dataStructuresByServiceCenter.set(toIterate[i], [
				[],
				[], {}, {}
			]);
		}

		var listOfEventsSize = listOfEvents.length - 1;
		for (var i = 0; i <= listOfEventsSize; i++) {
			var idOfCalendar = listOfEvents[i][4];
			var elementToAdd = listOfEvents[i];
			var valueOfElement = this.dataStructuresByServiceCenter.get(idOfCalendar);
			valueOfElement[0].push(elementToAdd);
			this.dataStructuresByServiceCenter.set(idOfCalendar, valueOfElement);
		}
	},

	// Done ------------------
	// Step #0. Previous step: 
	// Just start the process.

	findAvailability: function(listOfEvents) { // Working... 
		console.log("findAvailability");
		this.defineDataStructuresForServiceCenters(listOfEvents); // Store elements in: this.dataStructuresByServiceCenter
		var serviceCenters = this.dataStructuresByServiceCenter;

		for (let [key, value] of serviceCenters.entries()) {
			var element = value;
			element = this.listOfCitationsByDate(element);
			serviceCenters.set(key, element);
		}

		console.log(this.dataStructuresByServiceCenter);
	},

	// Done ------------------
	// Step #1. Previous step: Step #0
	// Based on the result of create availability by date (set the structure), add the data using setDayAvailability.
	listOfCitationsByDate: function(currentServiceCenter) {
		console.log("listOfCitationsByDate");
		var listOfDays = currentServiceCenter[1]; // listOfDays
		var listOfDaysSize = listOfDays.length;
		currentServiceCenter = this.createAvailabilityByDate(currentServiceCenter);
		var quantityOfDays = listOfDays.length - 1;

		for (var i = 0; i <= quantityOfDays; i++) {
			currentServiceCenter = this.setDayAvailability(currentServiceCenter, listOfDays[i]); // Por arreglar.
		}
		return currentServiceCenter;

	},

	// Done ------------------
	// Step #2. Previous step: Step #1
	// Set the possible hours for each day. Set the list of citations for each day.

	createAvailabilityByDate: function(serviceCenterData) { // Agrega Horas Disponibles a cada día y Crea lista de citas x día
		console.log("createAvailabilityByDate");
		var lOfEvents = serviceCenterData[0];
		var listOfDays = serviceCenterData[1];
		var availabilityByDates = serviceCenterData[2];
		var citationsByDate = serviceCenterData[3];
		var eventSize = lOfEvents.length - 1;

		for (var i = 0; i <= eventSize; i++) {
			//var test = this.setHoursCapacityBySucursal(lOfEvents[i][4]);
			//this.availabilityByDates[lOfEvents[i][0]] = JSON.parse(JSON.stringify(this.horas)); // It gives hours to the day.
			var calendar = lOfEvents[i][4]; // Element with the calendarId.
			availabilityByDates[lOfEvents[i][0]] = this.setHoursCapacityBySucursal(lOfEvents[i][4]);

			if (!listOfDays.includes(lOfEvents[i][0])) {
				listOfDays.push(lOfEvents[i][0]);
			}
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
	setDayAvailability: function(currentServiceCenter, day) {
		var availabilityByDates = currentServiceCenter[2]; //availabilityByDates
		var citationsByDate = currentServiceCenter[3]; //citationsByDate

		var citations = citationsByDate[day]; // Runs over the citations of the date
		var size = citations.length - 1;

		for (var i = 0; i <= size; i++) { // Adds to the day, what hours are available or not
			if (typeof citations[i] != "object") {
				i += 3;
				availabilityByDates[day] = this.setHoursAvailability(availabilityByDates[day], citations[1], citations[2]);
			} else {
				availabilityByDates[day] = this.setHoursAvailability(availabilityByDates[day], citations[i][1], citations[i][2]);
			}
		}
		return currentServiceCenter;
	},

	// Done ------------------
	// Step #4. Previous step: Step #3. 
	// Runs over all the hour in the range of StartTime to EndTime to set Busy or Available.
	setHoursAvailability: function(hoursByDay, startTime, endTime) {
		var keys = Object.keys(hoursByDay);
		var startingPosition = Object.keys(hoursByDay).indexOf(startTime);
		var endingPosition = Object.keys(hoursByDay).indexOf(endTime) - 1;
		for (var position = startingPosition; position <= endingPosition; position++) {
			hoursByDay[keys[position]] = Number(hoursByDay[keys[position]]) - 1;
		}
		return hoursByDay;
	},
    
        myTest: function () {
          document.getElementById("creandocita1").style.display="none";
          document.getElementById("creandocita2").style.display="none";
            document.getElementById("citaCreada").style.display="";
          

        },

	/* End Calendar functions________________________________________________________________________________________________________________________*/



	/* Start of Server calls functions support ______________________________________________________________________________________________________*/

	// Done ------------------
	getHour: function(hour) { // Hour structure its: hh:mm AM/PM. e.g. "8:30 AM"
		var shortHour = hour.split(':')[0]; // Gets "8"
		var AMPM = hour.split(' ')[1].split(" ")[0]; // Gets "AM"
		if (AMPM === "PM" && shortHour != 12) {
			shortHour = 12 + Number(shortHour); // Convert the hour to 24h
		}
		return shortHour;
	},

	// Done ------------------    
	getMinute: function(hour) {
		return hour.split(':')[1].split(" ")[0]; // Gets "30 AM" and then just "30"
	},

	// Done ------------------    
	convertCapacityBySucursalToJSON: function(capacityBySucursalList) {
		var sizeSucursalList = capacityBySucursalList.length;
		var newJson = {};
		for (var i = 0; i < sizeSucursalList; i++) {
			var element = capacityBySucursalList[i];
			var jsonValues = '{"' + [element.Id] + '":' + element.expr0 + '}';
			jsonValues = JSON.parse(jsonValues);
			newJson = Object.assign(newJson, jsonValues);
		}
		return newJson;
	},
    
    convertDateFormat: function(dateSelected){
        const d = new Date(dateSelected);
        let year = d.getFullYear();
        let month = d.getMonth()+1;
        let day = d.getDate();
        if(month<10){
            month = String('0') + String(month);
        }
        if(day<10){
            day = String('0') + String(day);
        }
        return year+"-"+month+"-"+day;
    },

	/* End of Server calls functions support ________________________________________________________________________________________________________*/


	/* Server calls _________________________________________________________________________________________________________________________________*/

	createNewCalendarEvent: function(day, hour, component) {
        var user = component.get("v.userInfo").Id;
        
        var keys = Object.keys(this.horas);     
        var serviceCenter = this.selectedServiceCenter;
        var day_ = this.convertDateFormat(day);
        // Controlar cuando no hay eventos o cuando hay solo uno
        var citations = this.dataStructuresByServiceCenter.get(serviceCenter)[3][day_];
        var citationsSize = citations.length-1;
        var asesores = [];
        
        console.log(this.dataStructuresByServiceCenter.get(serviceCenter));
        
            for (var i = 0; i<=citationsSize; i++){
                
                var positionOfStartHour = Number(Object.keys(this.horas).indexOf(citations[i][1])); // Gets the position of selected hour.
				var positionOfEndtHour = Number(Object.keys(this.horas).indexOf(citations[i][2])); // Gets the position of selected hour.
                var selectedHour = Number(Object.keys(this.horas).indexOf(hour));
                if(selectedHour>=positionOfStartHour && selectedHour<=positionOfEndtHour){
                    asesores.push(citations[i][3]);                        
                } 
            }
        
		// Get The Start Date and End Date values
		var keys = Object.keys(this.horas);
		var positionOfStartHour = Number(Object.keys(this.horas).indexOf(hour)); // Gets the position of selected hour.
		var nextPosition = Number(positionOfStartHour + 1); // Gets the position of the end hour.
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

		var action = component.get("c.createCalendarEventW");
		action.setParams({
			userId: user,
			calendarId: serviceCenter,
			daySelected: day,
			selectedStartHour: startDateHour,
			selectedEndHour: endDateHour, 
            usersToExclude: asesores
		});
		action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var result = response.getReturnValue();
                console.log(result);
                component.set('v.myResult', result);
				return result;
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

	// Generic Call to the server
	getServerResponse: function(component, event, helper, apexFunction, parameters) {
		var action = component.get(apexFunction);
		action.setParams(parameters);

		action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var result = response.getReturnValue();
				this.capacityBySucursal = this.convertCapacityBySucursalToJSON(result[0]);
				var asesoresByCalendar = result[1];
				var eventResults = result[2];

				helper.joinEventsAndAsesores(helper, asesoresByCalendar, eventResults);
				this.findAvailability(eventResults);
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

	showEvents: function(selectedDate, globalEventObj) {
		if (this.selectedServiceCenter != undefined && this.selectedService != undefined) {
			let myNode = document.getElementById("sidebarEvents");
			while (myNode.lastElementChild) {
				console.log("674");
				myNode.removeChild(myNode.lastElementChild);
				console.log("676");
			}

			let formattedDate = selectedDate.getFullYear() + '-' + String(selectedDate.getMonth() + 1).padStart(2, '0') + '-' + String(selectedDate.getDate()).padStart(2, '0');
			let sidebarEvents = document.getElementById("sidebarEvents");
			let objWithDate = globalEventObj[selectedDate.toDateString()];
			console.log("682");

			let eventsOnSelectedDate = this.loadDayAvailability(formattedDate, globalEventObj);
			console.log("685");
			if (eventsOnSelectedDate != "No events") {
				console.log("687");
                console.log(eventsOnSelectedDate);
                console.log(eventsOnSelectedDate[formattedDate]);
				let keysOfEventsOnSelectedDate = Object.keys(eventsOnSelectedDate[formattedDate]);
				sidebarEvents.innerHTML = "";
				if (eventsOnSelectedDate) {
					console.log("691");
					let eventsCount = 0;
					for (var key in keysOfEventsOnSelectedDate) {
						console.log("694");
						var element = keysOfEventsOnSelectedDate[key];
						var eventHourName = eventsOnSelectedDate[formattedDate][element];

						let eventContainer = document.createElement("div");
						eventContainer.className = "eventCard";

						let eventAction = document.createElement("div");
						eventAction.className = "eventCard-action";

						// TEST JD
						let eventActionExecution = document.createElement("button");
						eventActionExecution.Type = "button";
						eventActionExecution.className = "waves-effect waves-light btn blue lighten-2";
						eventActionExecution.appendChild(document.createTextNode(element));

						eventAction.appendChild(eventActionExecution);
						eventContainer.appendChild(eventAction);

						let markWrapper = document.createElement("div");
						markWrapper.className = "eventCard-mark-wrapper";

						let mark = document.createElement("div");
						mark.classList = "eventCard-mark";

						markWrapper.appendChild(mark);
						eventContainer.appendChild(markWrapper);

						sidebarEvents.appendChild(eventContainer);

						eventsCount++;
					}
					console.log("726");

					let emptyFormMessage = document.getElementById("sidebar-texttitle");
					emptyFormMessage.innerHTML = `${eventsCount} Citas Disponibles`;
				}

			} else {
				console.log("733");
				let sidebarTitle = document.getElementById("sidebar-texttitle");
				sidebarTitle.innerHTML = 'Citas Disponibles:';
				let emptyMessage = document.createElement("div");
				emptyMessage.className = "empty-message";
				emptyMessage.innerHTML = "Lo sentimos, no hay citas disponibles en la fecha seleccionada.";
				sidebarEvents.appendChild(emptyMessage);
				let emptyFormMessage = document.getElementById("emptyFormTitle");
				emptyFormMessage.innerHTML = "No hay citas.";
			}
		}
	},

    createCalendar: function (currentDate, side, gridTable, selectedDayBlock, selectedDate, globalEventObj ) {
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

				var lastDay = new Date(currentDate.getFullYear(), currentDate.getMonth() + 1, 0);
				lastDay = lastDay.getDate();

				for (let i = 1; i <= lastDay; i++) {
					if (currentTr.children.length >= 7) {
						currentTr = gridTable.appendChild(addNewRow());
					}
					let currentDay = document.createElement("div");
					currentDay.className = "col";
					if (selectedDayBlock == null && i == currentDate.getDate() || selectedDate.toDateString() == new Date(currentDate.getFullYear(), currentDate.getMonth(), i).toDateString()) {
						selectedDate = new Date(currentDate.getFullYear(), currentDate.getMonth(), i);

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

					//show marks
					if (globalEventObj[new Date(currentDate.getFullYear(), currentDate.getMonth(), i).toDateString()]) {
						let eventMark = document.createElement("div");
						eventMark.className = "day-mark";
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
		},
                                   
	myFunction: function(component, event, helper) {

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
		console.log(selectedDate + ' - ' +  globalEventObj);
		this.showEvents(selectedDate, globalEventObj);
		this.createCalendar(this.currentDate, "", gridTable, selectedDayBlock, selectedDate, globalEventObj );
		
	}
})