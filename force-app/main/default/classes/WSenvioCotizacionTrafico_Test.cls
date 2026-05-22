@isTest
public class WSenvioCotizacionTrafico_Test {
    private static Set<String> activeValues(Schema.SObjectField fieldToken) {
        Set<String> values = new Set<String>();
        for (Schema.PicklistEntry entry : fieldToken.getDescribe().getPicklistValues()) {
            if (entry.isActive()) values.add(entry.getValue());
        }
        return values;
    }

    private static String activeValue(Schema.SObjectField fieldToken, String preferred, String fallback) {
        String firstActive;
        for (Schema.PicklistEntry entry : fieldToken.getDescribe().getPicklistValues()) {
            if (!entry.isActive()) continue;
            if (firstActive == null) firstActive = entry.getValue();
            if (entry.getValue() == preferred) return entry.getValue();
        }
        return fallback != null ? fallback : firstActive;
    }

    private static String sharedModelValue() {
        String preferred = 'BMW-320-VR-EXECUTIVE';
        Set<String> leadModels = activeValues(Lead.Modelo_De_Inter_s1__c);
        if (leadModels.contains(preferred)) return preferred;

        Set<String> productModels = activeValues(Product2.Modelo_De_Inter_s__c);
        for (Schema.PicklistEntry entry : Lead.Modelo_De_Inter_s1__c.getDescribe().getPicklistValues()) {
            if (entry.isActive() && productModels.contains(entry.getValue())) {
                return entry.getValue();
            }
        }
        for (Schema.PicklistEntry entry : Lead.Modelo_De_Inter_s1__c.getDescribe().getPicklistValues()) {
            if (entry.isActive()) return entry.getValue();
        }
        return null;
    }

    private static void createTemplateProduct(String modelo) {
        insert new Product2(
            Name = 'Producto Plantilla Trafico',
            ProductCode = modelo.substringBefore(' '),
            Codigo_de_Producto__c = modelo.substringBefore(' '),
            NombredePlantilla__c = 'NewMultimarcacotizacion_1678510036978',
            IsActive = true
        );
    }

    private static Lead buildLead(String marca, String marca2, String marca3, String marca4, String modelo, Boolean cotizar) {
        Lead l = new Lead(
            FirstName = 'Test',
            LastName = 'Trafico',
            Company = 'Test Co',
            Email = 'trafico' + String.valueOf(Math.abs(Crypto.getRandomInteger())) + '@test.com',
            Marca__c = marca,
            Marca2__c = marca2,
            Marca3__c = marca3,
            Marca4__c = marca4,
            Cotizacion_1__c = cotizar && modelo != null,
            Cotizacion_2__c = false,
            Cotizacion_3__c = false,
            Cotizacion_4__c = false
        );
        if (modelo != null) {
            l.Familia1__c = 'Serie 3';
            l.Modelo_De_Inter_s1__c = modelo;
        }
        insert l;
        return l;
    }

    @isTest
    private static void testBMW() {
        String bmwMarca = activeValue(Lead.Marca__c, 'BMW', null);
        String modelo = sharedModelValue();

        Lead ld = buildLead(bmwMarca, null, null, null, modelo, modelo != null);
        Lead ldSinProducto = modelo == null ? null : buildLead(bmwMarca, null, null, null, modelo, true);
        Lead ld2 = buildLead(bmwMarca, null, null, null, null, false);
        if (modelo != null) {
            createTemplateProduct(modelo);
        }
        WSenvioCotizacionTrafico.testEnvioMultimarcaExitoso = true;

        Test.startTest();
        WSenvioCotizacionTrafico.testProductosCotizacion = modelo == null
            ? new List<Product2>()
            : new List<Product2>{
                new Product2(
                    Name = 'Producto Trafico Cotizacion',
                    Modelo_De_Inter_s__c = modelo,
                    Link_ficha_t_cnica__c = 'https://example.com/ficha.pdf'
                )
            };
	    String resultado = WSenvioCotizacionTrafico.envioCotizacion(ld.Id, ld.OwnerId);
        WSenvioCotizacionTrafico.testProductosCotizacion = null;
        String resultadoMultimarcaConModelo;
        if (modelo != null) {
            resultadoMultimarcaConModelo = WSenvioCotizacionTrafico.envioCotizacionMultimarca(ld.Id, ld.OwnerId);
        }
        String resultadoSinProducto;
        if (modelo != null) {
            WSenvioCotizacionTrafico.testProductosCotizacion = new List<Product2>();
            resultadoSinProducto = WSenvioCotizacionTrafico.envioCotizacion(ldSinProducto.Id, ldSinProducto.OwnerId);
            WSenvioCotizacionTrafico.testProductosCotizacion = null;
        }
	    String resultado2 = WSenvioCotizacionTrafico.envioCotizacion(ld2.Id, ld2.OwnerId);    
	    String resultado3 = WSenvioCotizacionTrafico.envioCotizacionMultimarca(ld2.Id, ld2.OwnerId);    
        Test.stopTest();

        System.assertNotEquals(null, resultado);
        System.assertNotEquals(null, resultado2);
        System.assertNotEquals(null, resultado3);
        if (modelo != null) {
            System.assertNotEquals(null, resultadoMultimarcaConModelo);
            System.assertEquals('no enviado', resultadoSinProducto);
        }
        WSenvioCotizacionTrafico.testEnvioMultimarcaExitoso = null;
    }
		
}