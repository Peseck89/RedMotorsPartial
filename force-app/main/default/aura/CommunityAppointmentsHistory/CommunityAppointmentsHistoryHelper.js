({
    getUserHistorial: function(component, event, helper, userId){
        var action = component.get("c.getUserHistory");
        action.setParams({'userId':userId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                console.log(storeResponse);
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
            return "Programada";
        }else if(variable==='No se presentó'){
            return "No asistió";
        }else if(variable==='Asistió'){
            return "Asistió";
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
                var status = data[i].Estado__c;
                console.log(status);
                if(data[i].CalendarName__c!=undefined){
                    calendarName = data[i].CalendarName__c.replace("Calendario","");
                }
                
                if(status==="Cancelada" || status==="No se presentó"){
                    newRow.className = "cancelled-appointment";
                }
                else{
                    newRow.className = "active-appointment";
                }
                
                var newdate= helper.convertDateTimeFormat(data[i].StartDateTime__c);
                // Convert newdate to a Date object if it's not already in Date format
                let formattedDate = new Date(data[i].StartDateTime__c);

                // Get the current date
                let currentDate = new Date();

                // Check if formattedDate is in the past
                console.log(newdate);
                console.log(formattedDate);
                console.log(currentDate);
                if (formattedDate < currentDate) {
                    console.log("The date is in the past.");
                } else {
                    console.log("The date is in the future or today.");
                }
                // startDateNewColumn.appendChild(document.createTextNode(newdate));
                let VehicleIdNewColumn = document.createElement("td");
                // VehicleIdNewColumn.appendChild(document.createTextNode(this.validateUndefined(data[i].VehicleId__c)));
                let AssessorNameNewColumn = document.createElement("td");
                // AssessorNameNewColumn.appendChild(document.createTextNode(data[i].AssessorName__c));
                let ServiceAndCenterNewColumn = document.createElement("td");
                // ServiceAndCenterNewColumn.appendChild(document.createTextNode(calendarName));
                let estadoNewColumn = document.createElement("td");
                // estadoNewColumn.appendChild(document.createTextNode(this.validateUndefinedStatus(data[i].Estado2__c)));
                let fechaDeAgenda = document.createElement("td");
                // fechaDeAgenda.appendChild(document.createTextNode(helper.convertDateTimeFormat(data[i].CreatedDate)));

                if (widthScreen <= 768) {
                    startDateNewColumn.appendChild(document.createTextNode(`Fecha: ${newdate}`));
                    VehicleIdNewColumn.appendChild(document.createTextNode(`Vehículo: ${this.validateUndefined(data[i].Activo__r.numeroDePlaca__c)}`));
                    AssessorNameNewColumn.appendChild(document.createTextNode(`Asesor: ${data[i].AssessorName__c}`));
                    ServiceAndCenterNewColumn.appendChild(document.createTextNode(`Servicio: ${calendarName}`));
                    if(formattedDate < currentDate && (data[i].Estado__c == undefined || data[i].Estado__c == '' )){
                        estadoNewColumn.appendChild(document.createTextNode(`Estado: `));
                    }else{
                        estadoNewColumn.appendChild(document.createTextNode(`Estado: ${this.validateUndefinedStatus(data[i].Estado__c)}`));
                    }
                    
                    fechaDeAgenda.appendChild(document.createTextNode(`Fecha de Agenda: ${helper.convertDateTimeFormat(data[i].CreatedDate)}`));


                } else if (widthScreen > 768) {
                    startDateNewColumn.appendChild(document.createTextNode(newdate));
                    VehicleIdNewColumn.appendChild(document.createTextNode(this.validateUndefined(data[i].Activo__r.numeroDePlaca__c)));
                    AssessorNameNewColumn.appendChild(document.createTextNode(data[i].AssessorName__c));
                    ServiceAndCenterNewColumn.appendChild(document.createTextNode(calendarName));
                    if(formattedDate < currentDate && (data[i].Estado__c == undefined || data[i].Estado__c == '' )){
                        estadoNewColumn.appendChild(document.createTextNode(''));
                    }else{
                        estadoNewColumn.appendChild(document.createTextNode(this.validateUndefinedStatus(data[i].Estado__c)));
                    }
                    
                    fechaDeAgenda.appendChild(document.createTextNode(helper.convertDateTimeFormat(data[i].CreatedDate)));

                }

                newRow.appendChild(startDateNewColumn);
                newRow.appendChild(VehicleIdNewColumn);
                newRow.appendChild(AssessorNameNewColumn);
                newRow.appendChild(ServiceAndCenterNewColumn);
                newRow.appendChild(fechaDeAgenda);
                newRow.appendChild(estadoNewColumn);
                
                
                dataRows.appendChild(newRow);
                
                console.log(newRow);
                
                i+=1;
            }
        }
        console.log("2");
    	
	},
    
});