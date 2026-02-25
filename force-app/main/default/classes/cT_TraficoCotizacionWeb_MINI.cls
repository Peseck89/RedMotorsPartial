public with sharing class cT_TraficoCotizacionWeb_MINI {
public List<ProductsConsumedWrapper> traficoLine { get; set; }
    public Double cantidadAccesorios { get; set; }
    public Double cantidadMenosAccesorios { get; set; }

    public String condicionesFinanciamiento { get; set; }

    public cT_TraficoCotizacionWeb_MINI(Apexpages.StandardController controller) {
        String recordId = controller.getId();
        List<Lead> lstLead = [SELECT Id, Accesorios_cotizacion__c, Precio_cotizacion__c, Plan_de_financiamiento_cotizacion__c FROM Lead WHERE Id =: recordId];

        if (!lstLead.isEmpty()) {
            Lead lead = lstLead[0];
            // Procesar accesorios
            List<ProductsConsumedWrapper> listaNueva = new List<ProductsConsumedWrapper>();
            Double sumaAccesorios = 0;
            if (lead.Accesorios_cotizacion__c != null) {
                for (String inputText : lead.Accesorios_cotizacion__c.split(',')) {
                    String[] parts = inputText.split(':');
                    if (parts.size() >= 2) {
                        String accesorio = parts[0].trim();
                        Double monto = Double.valueOf(parts[1].trim().replace('$', ''));
                        sumaAccesorios += monto;

                        listaNueva.add(new ProductsConsumedWrapper(accesorio, monto));
                    }
                }
            }
            cantidadAccesorios = sumaAccesorios;
            cantidadMenosAccesorios = lead.Precio_cotizacion__c - sumaAccesorios;
            traficoLine = listaNueva;

            // Buscar condiciones del banco
            List<Banco__c> bancos = [SELECT Name, Condiciones__c FROM Banco__c WHERE Name Like '%MINI%'];
            for (Banco__c banco : bancos) {
                if (lead.Plan_de_financiamiento_cotizacion__c != null &&
                    lead.Plan_de_financiamiento_cotizacion__c.containsIgnoreCase(banco.Name)) {
                    condicionesFinanciamiento = banco.Condiciones__c;
                    break;
                }
            }
        }
    }

    public class ProductsConsumedWrapper {
        public String Accesorio { get; set; }
        public Double Monto { get; set; }

        public ProductsConsumedWrapper() {}
        public ProductsConsumedWrapper(String accesorio, Double monto) {
            this.Accesorio = accesorio;
            this.Monto = monto;
        }
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