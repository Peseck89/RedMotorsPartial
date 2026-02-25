({
        
    doInit : function(component, event, helper) {
        helper.currentDate = new Date();
        helper.cmp=component;
        
	var action = component.get("c.fetchUser");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                component.set("v.userInfo", storeResponse);
            }
        });
        $A.enqueueAction(action);
        
        component.set('v.tabs', 
                [{label:"Escazú",id:"0054U000009hipBQAQ"},{label:"Pavas",id:"0054U000009hiw2QAA"},
                      {label:"Pinares",id:"0054U000009hiwHQAQ"},{label:"Uruca",id:"0054U000009hiwMQAQ"}]);
	},
    
    myTest: function () {
           document.getElementById("creandocita3").style.display="";
         document.getElementById("creandocita1").style.display="none";
         document.getElementById("creandocita2").style.display="none";

        },
    
    
    handleVerifyCalendar: function(component, event, helper){
        document.getElementById("sidebar").style.display="none";
        document.getElementsByClassName("centroDeServicio")[0].style.display="none";
        document.getElementById("container").style.display="";
        var selectedService = component.get("v.serviceSelected");
        var values = [];
        if(selectedService==="Otobai"){
            values = [{"label":"Pavas","id":"0054U00000Bes4GQAR"}];            
        }
        if(selectedService==="Mecánica Rápida"){
            values = [{label:"Escazú",id:"0054U000009hipBQAQ"},
                      {label:"Pavas",id:"0054U000009hiw2QAA"},
                      {label:"Pinares",id:"0054U000009hiwHQAQ"},
                      {label:"Uruca", id:"0054U000009hiwMQAQ"}];
        }
        if(selectedService==="Diagnóstico"){
            values = [{label:"Pavas",id:"0054U000009hiwCQAQ"},{label:"Uruca",id:"0054U000009hiwRQAQ"}];
        }
        if(selectedService==="Enderezado y Pintura"){
            values = [{label:"Uruca",id:"0054U000009hiwWQAQ"}];
        }
        
        component.set('v.tabs', values);
    },
    
    handleOnChangeSelectedService: function(component, event, helper){
        //Change HTML
        document.getElementById("container").style.display="none";
        document.getElementById("sidebar").style.display="none";
        document.getElementsByClassName("centroDeServicio")[0].style.display="none";
        
        // First Query Extraction for the availability
        var selectedService = event.getParam("value");
        component.set("v.serviceSelected", selectedService);
        
        var apexMethod = "c.getCalendarAvailabilityForService";
        var parameters = {selectedService : selectedService};
        
        
        // result[0] = Capacity by Sucursal | result[1] = Asesores By Calendar 		| result[2] = Event Results
        var result = helper.getServerResponse(component, event, helper, apexMethod, parameters);
    },
    
        handleChangeServiceCenter: function (component, event, helper) {
            var selectedService = component.get("v.serviceSelected");
            helper.selectedService = selectedService;
            var selectedTabServiceCenter = component.get("v.selTabId");
            helper.selectedServiceCenter = selectedTabServiceCenter;
            
            //helper.selectedDate = selectedTabServiceCenter;
			
            helper.myFunction();

            // To add the call of myFunction with the selections
            //helper.showEvents(selectedTabServiceCenter); 

            document.getElementById("sidebar").style.display ="";
            
            // To add the call of myFunction with the selections
            //helper.showEvents(component, event, helper, selectedTabServiceCenter);
    },
    
    myFunction: function(component, event, helper) {
        
        //helper.echo(component);

        $(".button-collapse").sideNav();
        var calendar = document.getElementById("calendar-table");
        var gridTable = document.getElementById("table-body");
        console.log(helper.currentDate);
        helper.currentDate = new Date();
        helper.selectedDate = helper.currentDate;
        var selectedDayBlock = null;
        var globalEventObj = {};

        var sidebar = document.getElementById("sidebar");

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
                lastDay = lastDay.getDate();

                for (let i = 1; i <= lastDay; i++) {
                    if (currentTr.children.length >= 7) {
                        currentTr = gridTable.appendChild(addNewRow());
                    }
                    let currentDay = document.createElement("div");
                    currentDay.className = "col";
                console.log(helper.currentDate.getDate());
                    if (selectedDayBlock == null && i == helper.currentDate.getDate() || helper.selectedDate.toDateString() == new Date(helper.currentDate.getFullYear(), helper.currentDate.getMonth(), i).toDateString()) {
                        helper.selectedDate = new Date(helper.currentDate.getFullYear(), helper.currentDate.getMonth(), i);

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

                    //show marks
                    if (globalEventObj[new Date(helper.currentDate.getFullYear(), helper.currentDate.getMonth(), i).toDateString()]) {
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
        }

        createCalendar(helper.currentDate);

        var todayDayName = document.getElementById("todayDayName");
        todayDayName.innerHTML = "Hoy es " + helper.currentDate.toLocaleString("es-ES", {
            weekday: "long",
            day: "numeric",
            month: "short"
        });

        var prevButton = document.getElementById("prev");
        var nextButton = document.getElementById("next");

        prevButton.onclick = function changeMonthPrev() {
            helper.currentDate = new Date(helper.currentDate.getFullYear(), helper.currentDate.getMonth() - 1);
            createCalendar(helper.currentDate, "left");
        }
        nextButton.onclick = function changeMonthNext() {
            helper.currentDate = new Date(helper.currentDate.getFullYear(), helper.currentDate.getMonth() + 1);
            createCalendar(helper.currentDate, "right");
        }

        function addEvent(title, desc) {
            if (!globalEventObj[helper.selectedDate.toDateString()]) {
                globalEventObj[helper.selectedDate.toDateString()] = {};
            }
            globalEventObj[helper.selectedDate.toDateString()][title] = desc;
        }
        

        function showEvents() {            
           	let myNode = document.getElementById("sidebarEvents");
            while (myNode.lastElementChild) {
               myNode.removeChild(myNode.lastElementChild);
  			}

            let formattedDate = helper.selectedDate.getFullYear() + '-' + String(helper.selectedDate.getMonth() + 1).padStart(2, '0') + '-' + String(helper.selectedDate.getDate()).padStart(2, '0');
            let sidebarEvents = document.getElementById("sidebarEvents");
            let objWithDate = globalEventObj[helper.selectedDate.toDateString()];
            
            let eventsOnSelectedDate = helper.loadDayAvailability(formattedDate, globalEventObj);
            if (eventsOnSelectedDate != "No events"){
                let keysOfEventsOnSelectedDate = Object.keys(eventsOnSelectedDate[formattedDate]);
                sidebarEvents.innerHTML = "";
                if (eventsOnSelectedDate) {
                	let eventsCount = 0;
                    for (var key in keysOfEventsOnSelectedDate) {
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
                    
                let emptyFormMessage = document.getElementById("sidebar-texttitle");
                emptyFormMessage.innerHTML = `${eventsCount} Citas Disponibles`;
            	} 
                
            }else {
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
        

        gridTable.onclick = function(e) {
            

            document.getElementsByClassName("centroDeServicio")[0].style.display="";
            document.getElementsByClassName("centroDeServicio")[0].scrollIntoView();

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

            //showEvents();
            document.getElementById("eventDayName").innerHTML = helper.selectedDate.toLocaleString("es-ES", {
                month: "long",
                day: "numeric",
                year: "numeric"
            });
            console.log(helper.currentDate);

        }

        var changeFormButton = document.getElementById("changeFormButton");
        var addForm = document.getElementById("addForm");
        changeFormButton.onclick = function(e) {
            addForm.style.top = 0;
        }
        
        var foo = document.getElementById("sidebarEvents");
        foo.onclick = function(e){
            var element = e.target;
            console.log(element);
            if (element.Type==="button"){
                var ddate = new Date(helper.selectedDate.getFullYear(), helper.selectedDate.getMonth(), helper.selectedDate.getDate());
                var selectedHour = element.innerText;
				var result = helper.createNewCalendarEvent(ddate, selectedHour, component);
                
            }
            document.getElementById('sidebar').style.display="none";
            document.getElementsByClassName('centroDeServicio')[0].style.display="none";
            document.getElementById('container').style.display="none";
            document.getElementById('testJD').style.display="";
            document.getElementById('verificarSection').style.display="none";
            
            
            //helper.myTest();
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
            
            if (helper.selectedServiceCenter!= undefined && helper.selectedService!= undefined){
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

        }
        console.log(helper.selectedDate);
    

    },
})