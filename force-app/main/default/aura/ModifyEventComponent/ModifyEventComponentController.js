({
	doInit : function( component, event, helper ) {
         $A.util.toggleClass(component.find('resultsDiv'),'slds-is-open');
        helper.getEventRecordsHelper( component, event, helper );
     },
     
     searchRecords : function( component, event, helper ) {
         if( !$A.util.isEmpty(component.get('v.searchString')) ) {
         	helper.searchRecordsHelper( component, event, helper, '' );
         } else {
             $A.util.removeClass(component.find('resultsDiv'),'slds-is-open');
         }
     },
     
     selectItem : function( component, event, helper ) {
         if(!$A.util.isEmpty(event.currentTarget.id)) {
             var recordsList = component.get('v.recordsList');
             var index = recordsList.findIndex(x => x.value === event.currentTarget.id)
             if(index != -1) {
                 var selectedRecord = recordsList[index];
             }
             var eventDetail = component.get('v.EventRecord');
             eventDetail.Activo = selectedRecord.value;
             component.set('v.EventRecord',eventDetail);
             component.set('v.selectedRecord',selectedRecord);
             component.set('v.value',selectedRecord.value);
             $A.util.removeClass(component.find('resultsDiv'),'slds-is-open');
         }
     },
        
    showRecords : function( component, event, helper ) {
        helper.searchRecordsHelper( component, event, helper, '' );     
       // if(!$A.util.isEmpty(component.get('v.recordsList')) && !$A.util.isEmpty(component.get('v.searchString'))) {
       //    $A.util.addClass(component.find('resultsDiv'),'slds-is-open');
       // }           
     },
     
     removeItem : function( component, event, helper ){
         component.set('v.selectedRecord','');
         component.set('v.value','');
         component.set('v.searchString','');
         var eventDetail = component.get('v.EventRecord');
         eventDetail.Activo = '';
         component.set('v.EventRecord',eventDetail);
         setTimeout( function() {
             component.find( 'inputLookup' ).focus();
         }, 250);
     },
    
    blurEvent : function( component, event, helper ){
        $A.util.removeClass(component.find('resultsDiv'),'slds-is-open');
    },
    
    handleClick : function( component, event, helper ){
        var eventDetail = component.get('v.EventRecord');
        helper.updateEventRecordsHelper( component, event, helper,eventDetail);
        $A.get('e.force:refreshView').fire();
    },
    
    handleCloseClick : function( component, event, helper ){
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    }
})