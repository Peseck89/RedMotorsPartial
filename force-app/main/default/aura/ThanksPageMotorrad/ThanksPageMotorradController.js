({
    doInit: function(component, event, helper) {
        // var urlParams = {};
        var urlParams = new URLSearchParams(window.location.search);
        var url = decodeURIComponent(window.location.search.substring(1));
        var params = url.split('?');

        var marca = urlParams.get("marca");
        
        if (marca) {
            component.set("v.marca", marca.toLowerCase()); 
        }
        
        for (var i = 0; i < params.length; i++) {
            var param = params[i].split('=');
            var paramName = param[0];
            var paramValue = param[1];
            
            urlParams[paramName] = paramValue;
        }
        var servicioUrl = String(urlParams.sucursal)
        
        component.set("v.sucursalSelected", servicioUrl);
        console.log('=======================servicioUrl======================');
        console.log(servicioUrl);
        setTimeout(() => {
        //   window.location.replace('https://redmotors.my.site.com/walkingmoto/s/')
        //   window.location.replace('/walkingmoto/s/?sucursal=Uruca&marca='+marca)
          window.location.replace('https://redmotorscr.com/walkinghome/motorrad/')
        }, 3000);
    },

    navigateToComponent : function(component, event, helper) {
        // window.location.replace('https://redmotorscr.com/walkinghome/'+servicioUrl.toLowerCase())
        // window.location.replace('/walkingmoto/s/?sucursal=Uruca&marca='+marca)
        window.location.replace('https://redmotorscr.com/walkinghome/motorrad/')
    },
})