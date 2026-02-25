({
    redirectToURL: function(component, event, helper) {
        // Utiliza el evento force:navigateToList para abrir una lista de registros
        var listEvent = $A.get("e.force:navigateToList");
        listEvent.setParams({
            "listViewName": null,
            "scope": "Event"
        });
        listEvent.fire();
    }
})