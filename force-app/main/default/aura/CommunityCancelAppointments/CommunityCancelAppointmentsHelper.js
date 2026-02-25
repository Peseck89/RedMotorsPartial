({
    getUserHistorial: function(component, event, helper, userId){
        var action = component.get("c.getUserHistoryActive");
        action.setParams({'userId':userId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                this.displayHistoryData(component, event, helper, storeResponse);
                
            }
            else{
                console.log("error");
                console.log(response);
                console.log(response.getError()[0].message);
            }

        });
        $A.enqueueAction(action);
    },
    
    validateUndefined: function(variable){
        if(variable===undefined){
            return "-";
        }
        return variable;
    },
    
    validateUndefinedStatus: function(variable){
        console.log('================= variable =======================$A')
        console.log(variable);
        if(variable===undefined){
            return "Activa";
        }else if(variable==='No se presentó'){
            return "No activa";
        }else if(variable==='Asistió'){
            return "Activa";
        }else{
            return "No activa";
        }
        return variable;
    },
    
    convertDateTimeFormat: function(datetime){
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
    
    displayHistoryData: function(component, event, helper, data){
        console.log("displayHistoryData");

        var widthScreen = parseInt(window.innerWidth)

        console.log(`Ancho de la pantalla: ${widthScreen}`);

        if (data!=''){
            let dataRows = document.getElementById("dataRows");
            console.log(data);
            var dataLength = data.length;
            console.log(dataLength);
            var i=0;
            while (i<=dataLength){
                console.log(data[i]);
                let newRow = document.createElement("tr");
                let startDateNewColumn = document.createElement("td");
                var calendarName = "-";
                var evnentId = data[i].Id;
                var status = data[i].Estado__c;
                
                if(data[i].CalendarName__c!=undefined){
                    calendarName = data[i].CalendarName__c.replace("Calendario","");
                }
                
                // if(status==="Cancelada"){
                //     newRow.className = "cancelled-appointment";
                // }
                // else{
                //     newRow.className = "active-appointment";
                // }
                
                var newdate= helper.convertDateTimeFormat(data[i].StartDateTime__c);

                
                // startDateNewColumn.appendChild(document.createTextNode(newdate));
                let VehicleIdNewColumn = document.createElement("td");
                // VehicleIdNewColumn.appendChild(document.createTextNode(this.validateUndefined(data[i].VehicleId__c)));
                let AssessorNameNewColumn = document.createElement("td");
                // AssessorNameNewColumn.appendChild(document.createTextNode(data[i].AssessorName__c));
                let ServiceAndCenterNewColumn = document.createElement("td");
                // ServiceAndCenterNewColumn.appendChild(document.createTextNode(calendarName));
                let estadoNewColumn = document.createElement("td");
                // estadoNewColumn.appendChild(document.createTextNode(this.validateUndefinedStatus(data[i].Estado2__c)));


                // Get today's date
                var estadoFinal;
                var today = new Date();
                today.setHours(0, 0, 0, 0); // Normalize today's date to remove time

                // Convert the event date to a comparable format
                var eventDate = new Date(Date.parse(data[i].StartDateTime__c));
                eventDate.setHours(0, 0, 0, 0);

                if (eventDate < today) {
                    estadoFinal = 'No activa';
                }else{
                    estadoFinal = 'Activa';
                }

                if (widthScreen <= 768) {
                    startDateNewColumn.appendChild(document.createTextNode(`Fecha: ${newdate}`));
                    VehicleIdNewColumn.appendChild(document.createTextNode(`Vehículo: ${this.validateUndefined(data[i].VehicleId__c)}`));
                    AssessorNameNewColumn.appendChild(document.createTextNode(`Asesor: ${data[i].AssessorName__c}`));
                    ServiceAndCenterNewColumn.appendChild(document.createTextNode(`Servicio: ${calendarName}`));
                    estadoNewColumn.appendChild(document.createTextNode(`Estado: ${estadoFinal}`));

                } else if (widthScreen > 768) {
                    startDateNewColumn.appendChild(document.createTextNode(newdate));
                    VehicleIdNewColumn.appendChild(document.createTextNode(this.validateUndefined(data[i].VehicleId__c)));
                    AssessorNameNewColumn.appendChild(document.createTextNode(data[i].AssessorName__c));
                    ServiceAndCenterNewColumn.appendChild(document.createTextNode(calendarName));
                    estadoNewColumn.appendChild(document.createTextNode(estadoFinal));
                }
                
                let botonNewColumn = document.createElement("td");
                var buttonElement = document.createElement("button");
                buttonElement.innerHTML = "Modificar";
                buttonElement.id = evnentId;
                buttonElement.className = "btn btn-primary";
                buttonElement.style.marginTop = "0px";

                

                // Disable the button if the event date is older than today
                if (eventDate < today) {
                    buttonElement.disabled = true;
                    buttonElement.className += " disabled"; // Optional: Add a 'disabled' class for styling
                }

                buttonElement.addEventListener("click", function(event){
                    var currentElementId = event.target.id;                    
                    component.set("v.eventId", currentElementId);
                    document.getElementById('modalMens').style.display = "";
                });

                botonNewColumn.appendChild(buttonElement);

                
                newRow.appendChild(startDateNewColumn);
                newRow.appendChild(VehicleIdNewColumn);
                newRow.appendChild(AssessorNameNewColumn);
                newRow.appendChild(ServiceAndCenterNewColumn);
                newRow.appendChild(estadoNewColumn);
                newRow.appendChild(botonNewColumn);
                
                dataRows.appendChild(newRow);
                
                console.log(newRow);
                
                i+=1;
            }
        }
        console.log("2");
    	
	},
    cancelCita: function (component) {
  
        var citationIdd = component.get("v.eventId");
        var action = component.get("c.cancelCitation");

        console.log(citationIdd);
        // console.log(action);

        action.setParams({"citationId":citationIdd});

        action.setCallback(this, function (response) {
            
          var state = response.getState();
          console.log(state);
          if (state === "SUCCESS") {
            var result = response.getReturnValue();            
            console.log('corre conexion h 4');
          } else if (state === "INCOMPLETE") {
            // do something
          } else if (state === "ERROR") {
            var errors = response.getError();
            console.log("Unknown error");
            if (errors) {
                console.log("Unknown error");
              if (errors[0] && errors[0].message) {
                console.log("Error message: " + errors[0].message);
              }
            } else {
              console.log("Unknown error");
            }
          }
        });
        $A.enqueueAction(action);
        console.log(action);
    }
});