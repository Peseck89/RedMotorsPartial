({
	 getData : function(cmp, event) {
        var actionplantillas = cmp.get("c.getPlantillas");
      
       actionplantillas.setCallback( this, function(actionResult) {
           var state = actionResult.getState();
         
           if (state === "SUCCESS"){
               var result = actionResult.getReturnValue();
               cmp.set("v.mydata",result);
                var contenedorIds = [ ];  
                var plantillas = [ ];
               
              for (var i = 0; i < result.length; i++) {
                 
                  var row = result[i];              
           
              
   
                   contenedorIds.push(row.Id);
                     
                            plantillas.push(row.Plantilla__c);
                    }
                  
                     var selectedRowsIds =  contenedorIds;
                  cmp.set("v.plantillas",  plantillas);
                cmp = cmp.find("plantillasList");
        cmp.set("v.selectedRows", selectedRowsIds);
                
              
               
       
                    
                
               
               
              
           }
       });
       $A.enqueueAction(actionplantillas);
       
   }
})