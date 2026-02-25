({
    getUserHistorial: function(component, event, helper, userId){
        console.log('getUserHistorial');
        var action = component.get("c.getUserActualInfo");
        action.setParams({'userId':userId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state');
            console.log(state);
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

    requestEliminacion: function(component, event, helper, userId){
        var motivoBaja = component.get('v.motivoBaja');
        var vehiculoId = component.get('v.vehiculoId');
        var action = component.get("c.createCaseDesasocia");
        action.setParams({'vehiculoId':vehiculoId,'motivoBaja':motivoBaja});
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state');
            console.log(state);
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

    requestCreacion: function(component, event, helper, userId){
        var vinVehiculo = component.get('v.vinVehiculo');
        var codModelo = component.get('v.codModelo');
        var matricula = component.get('v.matricula');
        var marca = component.get('v.marca');
        var vehiculoTipo = component.get('v.vehiculoTipo');

        var action = component.get("c.createCaseAsocia");
        action.setParams({'vinVehiculo':vinVehiculo ,'codModelo':codModelo ,'matricula':matricula,'marca':marca,'vehiculoTipo':vehiculoTipo});
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state');
            console.log(state);
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
        if(variable===undefined){
            return "Activa";
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
        console.log(data);
        if (data!=''){
            let dataRows = document.getElementById("dataRows");
            console.log(data);
            var dataLength = data.length;
            console.log(dataLength);
            var i=0;
            while (i<=dataLength){
                console.log(data[i]);
                var evnentId = data[i].Id;
                let newRow = document.createElement("tr");
                //let startDateNewColumn = document.createElement("td");
                var calendarName = "-";
                            
                //var newdate= helper.convertDateTimeFormat(data[i].Name);
                
                // startDateNewColumn.appendChild(document.createTextNode(newdate));

                let VehicleIdNewColumn = document.createElement("td");
                // // VehicleIdNewColumn.appendChild(document.createTextNode(this.validateUndefined(data[i].VehicleId__c)));
                let AssessorNameNewColumn = document.createElement("td");
                // // AssessorNameNewColumn.appendChild(document.createTextNode(data[i].AssessorName__c));
                // let ServiceAndCenterNewColumn = document.createElement("td");
                // // ServiceAndCenterNewColumn.appendChild(document.createTextNode(calendarName));
                // let estadoNewColumn = document.createElement("td");
                // // estadoNewColumn.appendChild(document.createTextNode(this.validateUndefinedStatus(data[i].Estado2__c)));
                // let fechaDeAgenda = document.createElement("td");
                // // fechaDeAgenda.appendChild(document.createTextNode(helper.convertDateTimeFormat(data[i].CreatedDate)));

                if (widthScreen <= 768) {
                    //startDateNewColumn.appendChild(document.createTextNode(`Fecha: ${newdate}`));
                    VehicleIdNewColumn.appendChild(document.createTextNode(this.validateUndefined(data[i].Name)));
                    var link=document.createElement("button");
                    link.innerHTML = "Desasignar";                   
                    link.Type = "button";    
                    link.id = evnentId; 
                    link.style.marginTop = "0px";
                    link.addEventListener("click", function(event){
                        var currentElementId = event.target.id;                    
                        //component.set("v.eventId", currentElementId);
                        document.getElementById('modalMens').style.display = "";
                        console.log('MENSAJE PARA VER SI ESTA DENTRO');
                        console.log(currentElementId);
                    });                
                    
                    link.className = "btn cambiarMarca  btn-primary btn-block";
                    AssessorNameNewColumn.appendChild(link);
                    //AssessorNameNewColumn.appendChild(document.createTextNode(`Asesor: ${data[i].AssessorName__c}`));
                    // ServiceAndCenterNewColumn.appendChild(document.createTextNode(`Servicio: ${calendarName}`));
                    // estadoNewColumn.appendChild(document.createTextNode(`Estado: ${this.validateUndefinedStatus(data[i].Estado2__c)}`));
                    // fechaDeAgenda.appendChild(document.createTextNode(`Fecha de Agenda: ${helper.convertDateTimeFormat(data[i].CreatedDate)}`));


                } else if (widthScreen > 768) {
                //     startDateNewColumn.appendChild(document.createTextNode(newdate));
                    VehicleIdNewColumn.appendChild(document.createTextNode(this.validateUndefined(data[i].Name)))
                    // VehicleIdNewColumn.appendChild(document.createTextNode(`Vehiculo: ${this.validateUndefined(data[i].Name)}`));
                    var link=document.createElement("button");
                    link.innerHTML = "Desasignar";                   
                    link.Type = "button";    
                    link.id = evnentId; 
                    link.style.marginTop = "0px";
                    link.addEventListener("click", function(event){
                        var currentElementId = event.target.id;                    
                        component.set("v.vehiculoId", currentElementId);
                        document.getElementById('modalMens').style.display = "";
                        console.log('MENSAJE PARA VER SI ESTA DENTRO');
                        console.log(currentElementId);
                    });                
                    
                    link.className = "btn cambiarMarca  btn-primary btn-block";
                    AssessorNameNewColumn.appendChild(link);
                //     AssessorNameNewColumn.appendChild(document.createTextNode(data[i].AssessorName__c));
                //     ServiceAndCenterNewColumn.appendChild(document.createTextNode(calendarName));
                //     estadoNewColumn.appendChild(document.createTextNode(this.validateUndefinedStatus(data[i].Estado2__c)));
                //     fechaDeAgenda.appendChild(document.createTextNode(helper.convertDateTimeFormat(data[i].CreatedDate)));

                }

                //newRow.appendChild(startDateNewColumn);
                newRow.appendChild(VehicleIdNewColumn);
                newRow.appendChild(AssessorNameNewColumn);
                // newRow.appendChild(ServiceAndCenterNewColumn);
                // newRow.appendChild(fechaDeAgenda);
                // newRow.appendChild(estadoNewColumn);
                
                
                dataRows.appendChild(newRow);
                
                console.log(newRow);
                
                i+=1;
            }
        }
        console.log("2");
    	
	},
    
});