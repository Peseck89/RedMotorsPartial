({
    doInit: function(component, event, helper) {
      var urlParams = {};
        var url = decodeURIComponent(window.location.search.substring(1));
        var params = url.split('?');
        
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
        if (servicioUrl == 'Escazú') {
          component.set( 
            'v.servicioUrl',
            'escazu'
          )
        }
        setTimeout(() => {
          // window.location.replace("/walkingmini/s/");
          window.location.replace('https://redmotorscr.com/walkinghome/'+servicioUrl.toLowerCase())

        }, 3000);
      },

      navigateToComponent : function(component, event, helper) {
        var urlParams = {};
        var url = decodeURIComponent(window.location.search.substring(1));
        var params = url.split('?');
        
        for (var i = 0; i < params.length; i++) {
            var param = params[i].split('=');
            var paramName = param[0];
            var paramValue = param[1];
            
            urlParams[paramName] = paramValue;
        }
        var servicioUrl = String(urlParams.sucursal)
        // window.location.replace('/walkingmini/s/')
        if (servicioUrl == 'Escazú') {
          component.set( 
            'v.servicioUrl',
            'escazu'
          )
        }
        window.location.replace('https://redmotorscr.com/walkinghome/'+servicioUrl.toLowerCase())

      },
})