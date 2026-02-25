({
    doInit: function(component, event, helper) {
        var urlParams = new URLSearchParams(window.location.search);
        var marca = urlParams.get("marca");
        
        if (marca) {
            component.set("v.marca", marca.toLowerCase()); 
        }
    },

    navigateToComponent2: function(component, event, helper) {
        const marca = component.get("v.marca");
        // window.location.replace(`/walkingmoto/s/showroom${marca}?sucursal=Uruca`);
        window.location.replace('/walkingmoto/s/showroommotorrad?sucursal=Uruca&marca='+marca);
    }
})