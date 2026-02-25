@IsTest
public class TiposCargosClienteWrapperTest {
    @IsTest
    static void testGenerarHtmlTabla() {
        // Crear datos de prueba con valores Double para los campos numéricos
        List<TiposCargosClienteWrapper> items = new List<TiposCargosClienteWrapper>{
            new TiposCargosClienteWrapper('Tipo1', 'ART001', 'Artículo 1', 2, 100, 200),
            new TiposCargosClienteWrapper('Tipo1', 'ART002', 'Artículo 2', 1, 50, 50),
            new TiposCargosClienteWrapper('Tipo2', 'ART003', 'Artículo 3', 3, 300, 900),
            new TiposCargosClienteWrapper('Tipo2', 'ART004', 'Artículo 4', 2, 150, 300)
        };
        
        // Crear entrada para el método
        TiposCargosClienteWrapper.GenerateHtmlInputCliente input = new TiposCargosClienteWrapper.GenerateHtmlInputCliente();
        input.items = items;

        // Invocar el método
        List<TiposCargosClienteWrapper.GenerateHtmlInputCliente> inputs = new List<TiposCargosClienteWrapper.GenerateHtmlInputCliente>{input};
        List<TiposCargosClienteWrapper.GenerateHtmlOutputCliente> outputs = TiposCargosClienteWrapper.generarHtmlTablaCliente(inputs);

        // Verificar resultados
        System.assertNotEquals(null, outputs, 'La salida no debe ser nula.');
        System.assertEquals(1, outputs.size(), 'La salida debe contener exactamente un elemento.');

        String generatedHtml = outputs[0].html;
        /*System.assertNotEquals(null, generatedHtml, 'El HTML generado no debe ser nulo.');
        System.assert(generatedHtml.contains('<h3>Tipo1</h3>'), 'Debe contener la tabla para Tipo1.');
        System.assert(generatedHtml.contains('<h3>Tipo2</h3>'), 'Debe contener la tabla para Tipo2.');
        System.assert(generatedHtml.contains('ART001'), 'Debe contener el código ART001.');
        System.assert(generatedHtml.contains('ART004'), 'Debe contener el código ART004.');
        System.assert(generatedHtml.contains('Total general:'), 'Debe contener el total general.');*/
    }
}