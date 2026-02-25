({
	getQuote : function(component, event, helper) {
        var quoId = component.get("v.recordId");
		var action =component.get("c.quoteVencido");
        action.setParams({ quoteId : quoId });
        console.log('The action value is: '+action);
         action.setCallback(this, function(a){ 
             console.log('a.getReturnValue()',a.getReturnValue());
            component.set("v.FechaVigente", a.getReturnValue());
           //  console.log('The accs are :'+JSON.stringify(a.getReturnValue()));
            console.log('The accs are :'+JSON.stringify(a.getReturnValue()));
          
        });
        $A.enqueueAction(action);
	}
})