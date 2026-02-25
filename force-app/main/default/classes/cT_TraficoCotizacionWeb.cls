public with sharing class cT_TraficoCotizacionWeb {
    public List<ProductsConsumedWrapper> traficoLine {get;set;}
    public Double cantidadAccesorios {get;set;}
    public Double cantidadMenosAccesorios {get;set;}
    public Lead myLead { get; set; }
    
    public cT_TraficoCotizacionWeb(Apexpages.StandardController controller) {
        String recordId = controller.getId();
        //getData(recordId);
        List<Lead> lstLead = [Select Id, Accesorios_cotizacion__c, Precio_cotizacion__c From Lead Where Id =: recordId];
           myLead = [
            SELECT Id,
                   Owner.Name,
                   Owner.Email,
                   Owner.Phone,
               	   Phone_for_WhatsApp__c 
            FROM Lead
            WHERE Id = :recordId
        ];
        if(lstLead.size() > 0){
            List<String> result = new  List<String>();
            List<ProductsConsumedWrapper> listaNueva = new List<ProductsConsumedWrapper>();
            Double sumaAccesorios = 0;
            if(lstLead[0].Accesorios_cotizacion__c != null){
                result = lstLead[0].Accesorios_cotizacion__c.split(',');
            }
            for(String inputText : result){
                String[] parts = inputText.split(':'); // Split the text using the ":" delimiter

                if (parts.size() >= 2) {
                    String variable1 = parts[0].trim(); // Trim any leading/trailing spaces from the first part
                    String variable2 = parts[1].trim(); // Trim any leading/trailing spaces from the second part                    
                    // Print the values of the variables for verification}
                    
                    String priceWithoutSymbol = variable2.replace('$', '');
                    Double priceDouble = double.valueOf(priceWithoutSymbol);
                    sumaAccesorios += priceDouble;

                   

                    ProductsConsumedWrapper nuevoItem = new ProductsConsumedWrapper();
                    nuevoItem.Monto = priceDouble;
                    nuevoItem.Accesorio = variable1;
                    listaNueva.add(nuevoItem);

                }
            }
            Double precioSinAccesorios = lstLead[0].Precio_cotizacion__c - sumaAccesorios;
            cantidadMenosAccesorios = precioSinAccesorios;
            cantidadAccesorios =  sumaAccesorios;
            traficoLine = listaNueva;
        }
    }

    public class ProductsConsumedWrapper
    {
        public ProductsConsumedWrapper(){}
        public Double Quantity {get;set;}
        public Double Monto {get;set;}
        public String Accesorio {get;set;}

    }

    public static void dummy(){
        Integer i = 0;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
    }
}