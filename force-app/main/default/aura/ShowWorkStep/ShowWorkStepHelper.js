({
    startTimer:function (component, event, helper) {
          var intervalID;	
          var startWork;
          var now=new Date();  
          var horas ;
          var difDates;
          var stepWorks=component.get('v.responseWrapperRec').wmList;
          if(/*component.get('v.statusValue')=="All"||*/component.get('v.statusValue')=='En curso'){
             
             intervalID =setInterval(() => {
                 component.set('v.isOn',true);
                 var statusVal = component.get("v.statusValue");
                 if(statusVal!='En curso'){
                 //component.set('v.loaded',true);
                 //helper.reset(component, event, helper );
                 clearInterval(intervalID);
                 //console.log('Limpiezaaaa'+component.get('v.loaded')+' '+component.get('v.flagInterval'));
                 setTimeout(() => {component.set('v.flagInterval',false);console.log("después");helper.startTimer(component, event, helper );}, 2000);
                 //;
             	};
                //console.log(stepWorks);
            	now = new Date(now.getTime() + 1000);
                //document.getElementById("0hF8J000000000LUAQ").innerHTML = hours+'hrs '+minutes+'mins '+seconds+'secs';
                for (let i = 0; i < stepWorks.length; i++) {
                if(startWork=stepWorks[i].StartTime!=null && stepWorks[i].status=='En curso' ){
                 	horas=3600000*stepWorks[i].pausedHours;
                   // console.log(stepWorks[i].pausedHours);
                	startWork= new Date(stepWorks[i].StartTime);
                 	difDates=now - startWork-horas;
                 	//console.log(horas);
                	const hours = parseInt(Math.abs(difDates) / (1000 * 60 * 60));
                    const minutes = parseInt(Math.abs(difDates) / (1000 * 60) % 60);
                 	/*console.log(difDates/60000+'>'+stepWorks[i].Cantidaddehoras*60+'???');
                 console.log(difDates/60000>stepWorks[i].Cantidaddehoras*60);
                 
                 if(difDates/60000>stepWorks[i].Cantidaddehoras*60 && stepWorks[i].Cantidaddehoras!==undefined){
                 console.log(hours+'>'+stepWorks[i].Tiempotrabajadoenmins/60+'???'+stepWorks[i].Cantidaddehoras);
                 	var a = component.get('c.handleChangeTerritoryFilter1');
            		$A.enqueueAction(a);
             	 }*/
                    const seconds = parseInt(Math.abs(difDates) / (1000) % 60); 
                 try{document.getElementById(stepWorks[i].recordId).innerHTML = hours+'hrs '+minutes+'mins '+seconds+'secs';
             	 }catch (error) {
                  //console.error(error);
                  clearInterval(intervalID);
                  component.set('v.flagInterval',false);
                  // expected output: ReferenceError: nonExistentFunction is not defined
                  // Note - error messages will vary depending on browser
                }				
            	}
                	
			}
            }, 1000);
            }
                 
	},
       refresh:function(component, event, helper){
           var refreshvalID;
           refreshvalID =setInterval(() => {
               var statusVal = component.get("v.statusValue");
               if(statusVal=='En curso'||statusVal=='All'){
               		console.log('Refresh');
                   var a = component.get('c.handleChangeTerritoryFilter1');
                   $A.enqueueAction(a);
           }else{
                  console.log('NO Refresh, STOP thread');
                  clearInterval(refreshvalID);
               
           }
               
               }, 300000);
                	
	},
   
    
})