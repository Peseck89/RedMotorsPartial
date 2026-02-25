public class TiposCargosClienteWrapper {
    @AuraEnabled
    public String tipoTrabajo { get; set; }
    @AuraEnabled
    public String codigoArticulo { get; set; }
    @AuraEnabled
    public String nombre { get; set; }
    @AuraEnabled
    public Integer cantidad { get; set; }
    @AuraEnabled
    public Double precioConDescuento { get; set; }
    @AuraEnabled
    public Double monto { get; set; }

    public TiposCargosClienteWrapper() {
    }

    public TiposCargosClienteWrapper(String tipoTrabajo, String codigoArticulo, String nombre, Integer cantidad, Double precioConDescuento, Double monto) {
        this.tipoTrabajo = tipoTrabajo;
        this.codigoArticulo = codigoArticulo;
        this.nombre = nombre;
        this.cantidad = cantidad;
        this.precioConDescuento = precioConDescuento;
        this.monto = monto;
    }
    public class GenerateHtmlInputCliente {
        @InvocableVariable
        public List<TiposCargosClienteWrapper> items;
    }

    public class GenerateHtmlOutputCliente {
        @InvocableVariable
        public String html;
    }

    @InvocableMethod(label='Generar HTML Tabla Cliente')
    public static List<GenerateHtmlOutputCliente> generarHtmlTablaCliente(List<GenerateHtmlInputCliente> inputs) {
        List<GenerateHtmlOutputCliente> outputs = new List<GenerateHtmlOutputCliente>();

        for (GenerateHtmlInputCliente input : inputs) {
            // Agrupar items por tipoTrabajo
            Map<String, List<TiposCargosClienteWrapper>> groupedItems = new Map<String, List<TiposCargosClienteWrapper>>();
            
            for (TiposCargosClienteWrapper item : input.items) {
                if (!groupedItems.containsKey(item.tipoTrabajo)) {
                    groupedItems.put(item.tipoTrabajo, new List<TiposCargosClienteWrapper>());
                }
                groupedItems.get(item.tipoTrabajo).add(item);
            }
            
            // Generar HTML con tablas separadas para cada tipoTrabajo
            String html = '';
            Decimal montoTotal = 0;
            Decimal precioConDescuentoTotalGeneral = 0;
            
            for (String tipoTrabajo : groupedItems.keySet()) {
                Decimal monto = 0;
                Decimal precioConDescuentoTotal = 0;
                
                //html += '<h3>' + tipoTrabajo + '</h3>';  // Título del tipo de trabajo
                
                html += '<table role="presentation" style="width:100%;border-collapse:collapse;border:0;border-spacing:0;color: #707070">' +
                        '<caption style="text-align: start;">'+tipoTrabajo+'</caption>' +
                         // '<thead>' +
                        '<tr>' +
                        '<th style="font-size: 12px; border:1px solid black; text-align:center">Nombre</th>' +
                        '<th style="font-size: 12px; border:1px solid black; text-align:center">Cantidad</th>' +
                        '<th style="font-size: 12px; border:1px solid black; text-align:center">Monto</th>' +
                        '<th style="font-size: 12px; border:1px solid black; text-align:center">Precio a facturar</th>' +
                        '</tr>'; 
                        //'</thead>' +
                        //'<tbody>'
                       
                
                for (TiposCargosClienteWrapper item : groupedItems.get(tipoTrabajo)) {
                    monto += item.monto;
                    precioConDescuentoTotal += item.precioConDescuento;
                    montoTotal += item.monto;
                    precioConDescuentoTotalGeneral += item.precioConDescuento;
                    
                    html += '<tr>' +
                            '<td style="font-size: 12px; border:1px solid black; text-align:center">' + item.nombre + '</td>' +
                            '<td style="font-size: 12px; border:1px solid black; text-align:center">' + item.cantidad + '</td>' +
                            '<td style="font-size: 12px; border:1px solid black; text-align:center" class="amount-column">$' + item.monto + '</td>' +
                            '<td style="font-size: 12px; border:1px solid black; text-align:center" class="price-column">$' + item.precioConDescuento + '</td>' +
                            '</tr>';
                }
                
                html += '<tr class="total-row">' +
                       // '<td colspan="3" style="text-align:right;"><strong>Total:</strong></td>' +
                        '<td style="font-size: 14px; border:1px solid black; " colspan="2">Total:</td>' +
                        '<td style="font-size: 14px; border:1px solid black; text-align:center" class="amount-column">$' + monto + '</td>' +
                        '<td style="font-size: 14px; border:1px solid black; text-align:center" class="price-column">$' + precioConDescuentoTotal + '</td>' +
                        '</tr>';
                
                //html += '</tbody></table><br/>';  // Espacio entre tablas
                html += '</table><br/>';  // Espacio entre tablas
            }
            
            // Agregar total general alineado a la izquierda
            //html += '<p style="text-align:left;"><strong>Total general: $' + precioConDescuentoTotalGeneral + '</strong></p>';

            GenerateHtmlOutputCliente output = new GenerateHtmlOutputCliente();
            output.html = html;
            outputs.add(output);
        }

        return outputs;
    }
}