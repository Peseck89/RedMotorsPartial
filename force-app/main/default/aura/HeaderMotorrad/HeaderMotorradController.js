({
    doInit: function(component, event, helper) {
        var urlParams = new URLSearchParams(window.location.search);
        var marca = urlParams.get("marca");
        
        if (marca) {
            component.set("v.marca", marca.toLowerCase()); 
        }
    }
})