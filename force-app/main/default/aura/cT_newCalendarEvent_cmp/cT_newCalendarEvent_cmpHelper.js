({
    getModelosVehiculos : function(component, event, helper){
        let action = component.get("c.getModelosVehiculos");
        action.setParams({
            
        });
        action.setCallback(this, function(response){
            let state = response.getState();
            if(state === "SUCCESS"){
                component.set("v.modelosVehiculos", response.getReturnValue());
            }
            else{
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    },

    getUserHistorial: function(component, event, helper, userId, fechaSel){

        var t = document.getElementById("table");
        var trs = t.getElementsByTagName("tr");
        var tds = null;
        
        for (var i=0; i<trs.length; i++)
        {
            tds = trs[i].getElementsByTagName("td");
            for (var n=1; n<tds.length -1;n++)
            {
                t.deleteRow(n);
            }
        }


        var action = component.get("c.getUserHistory");
        action.setParams({'AsesorId':userId, 'fechaBuscar':fechaSel});
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

    displayHistoryData: function(component, event, helper, data){
        console.log("displayHistoryData");
        if (data!=''){
            let dataRows = document.getElementById("dataRows");
            console.log(data);
            var dataLength = data.length;
            console.log(dataLength);
            var i=0;
            while (i<dataLength){
                console.log(data[i]);
                let newRow = document.createElement("tr");
                let startDateNewColumn = document.createElement("td");
                var calendarName = "-";
                newRow.className = "cancelled-appointment";
                
                var newdate= helper.convertDateTimeFormat(data[i].StartDateTime);
                var newdateFin = helper.convertDateTimeFormat(data[i].EndDateTime);
                startDateNewColumn.appendChild(document.createTextNode(newdate));
                let VehicleIdNewColumn = document.createElement("td");
                VehicleIdNewColumn.appendChild(document.createTextNode(this.validateUndefined(data[i].Asesor__r.Name)));
                let AssessorNameNewColumn = document.createElement("td");
                AssessorNameNewColumn.appendChild(document.createTextNode(newdateFin));
                let ServiceAndCenterNewColumn = document.createElement("td");
                ServiceAndCenterNewColumn.appendChild(document.createTextNode(calendarName));
               
                
                newRow.appendChild(startDateNewColumn);
                
                newRow.appendChild(AssessorNameNewColumn);
                newRow.appendChild(VehicleIdNewColumn);


                
                dataRows.appendChild(newRow);
                
                console.log(newRow);
                
                i+=1;
            }
        }
        console.log("2");
    	
	},
    validateUndefined: function(variable){
        if(variable===undefined){
            return "-";
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
    
})