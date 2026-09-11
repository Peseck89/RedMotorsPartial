/**
* @description Mantiene el campo Opportunity.Detalle_de_Productos__c con una línea por cada
*              producto de la oportunidad, con el formato:
*                  Nombre del producto - Cantidad - Precio de venta
*              Siempre reconstruye el detalle completo a partir de los OpportunityLineItem
*              vigentes, por eso se puede invocar en insert, update, delete y undelete sin
*              que el resultado dependa del orden de ejecución.
**/
public without sharing class OpportunityDetalleProductosService {

    private static final Integer LARGO_MAXIMO = 32768;
    private static final String SEPARADOR = ' - ';
    private static final String SALTO_DE_LINEA = '\n';
    private static final String SEPARADOR_MILES = ',';
    private static final String SEPARADOR_DECIMAL = '.';

    /**
    * @description Recalcula el detalle de productos de las oportunidades indicadas.
    * @param opportunityIds Ids de las oportunidades a refrescar
    **/
    public static void actualizarDetalle(Set<Id> opportunityIds) {
        if (opportunityIds == null) {
            return;
        }

        Set<Id> idsOportunidades = new Set<Id>(opportunityIds);
        idsOportunidades.remove(null);
        if (idsOportunidades.isEmpty()) {
            return;
        }

        List<Opportunity> oportunidades = [
            SELECT Id, Detalle_de_Productos__c, CurrencyIsoCode,
                   (SELECT Id, Name, Quantity, UnitPrice, Product2.Name
                    FROM OpportunityLineItems
                    ORDER BY CreatedDate ASC)
            FROM Opportunity
            WHERE Id IN :idsOportunidades
        ];

        List<Opportunity> paraActualizar = new List<Opportunity>();
        integrarDetalle(idsOportunidades, oportunidades, paraActualizar);

        if (paraActualizar.isEmpty()) {
            return;
        }

        // Parcial: si una oportunidad no se puede actualizar (validación, bloqueo, etc.) no se
        // debe impedir el alta o la edición del producto, que es la operación que el usuario pidió.
        List<Database.SaveResult> resultados = Database.update(paraActualizar, false);
        for (Integer i = 0; i < resultados.size(); i++) {
            if (!resultados[i].isSuccess()) {
                System.debug(LoggingLevel.ERROR,
                    'No se pudo actualizar Detalle_de_Productos__c en ' + paraActualizar[i].Id +
                    ': ' + resultados[i].getErrors());
            }
        }
    }

    /**
    * @description Fusiona el detalle calculado en una lista de Opportunity que será actualizada
    *              por el consumidor. No ejecuta SOQL ni DML.
    * @param opportunityIds Ids cuyo detalle debe refrescarse
    * @param oportunidades Oportunidades con Detalle_de_Productos__c, CurrencyIsoCode y sus OLI
    * @param paraActualizar Lista compartida que recibirá los cambios
    **/
    public static void integrarDetalle(
        Set<Id> opportunityIds,
        List<Opportunity> oportunidades,
        List<Opportunity> paraActualizar
    ) {
        if (opportunityIds == null || opportunityIds.isEmpty() ||
            oportunidades == null || paraActualizar == null) {
            return;
        }

        Map<Id, Opportunity> actualizacionesPorId = new Map<Id, Opportunity>();
        for (Opportunity actualizacion : paraActualizar) {
            actualizacionesPorId.put(actualizacion.Id, actualizacion);
        }

        for (Opportunity opp : oportunidades) {
            if (!opportunityIds.contains(opp.Id)) {
                continue;
            }

            String detalle = construirDetalle(opp);
            if (detalle == opp.Detalle_de_Productos__c) {
                continue;
            }

            Opportunity actualizacion = actualizacionesPorId.get(opp.Id);
            if (actualizacion == null) {
                actualizacion = new Opportunity(Id = opp.Id);
                paraActualizar.add(actualizacion);
                actualizacionesPorId.put(opp.Id, actualizacion);
            }
            actualizacion.Detalle_de_Productos__c = detalle;
        }
    }

    /**
    * @description Arma el texto del detalle a partir de los productos de la oportunidad.
    * @param opp Oportunidad con su subconsulta de OpportunityLineItems
    * @return String con una línea por producto, o null si la oportunidad ya no tiene productos
    **/
    @TestVisible
    private static String construirDetalle(Opportunity opp) {
        List<String> lineas = new List<String>();

        for (OpportunityLineItem oli : opp.OpportunityLineItems) {
            lineas.add(
                obtenerNombreProducto(oli) + SEPARADOR +
                formatearCantidad(oli.Quantity) + SEPARADOR +
                formatearPrecio(oli.UnitPrice, opp.CurrencyIsoCode)
            );
        }

        if (lineas.isEmpty()) {
            return null;
        }

        String detalle = String.join(lineas, SALTO_DE_LINEA);
        return detalle.length() > LARGO_MAXIMO ? detalle.abbreviate(LARGO_MAXIMO) : detalle;
    }

    private static String obtenerNombreProducto(OpportunityLineItem oli) {
        if (oli.Product2 != null && String.isNotBlank(oli.Product2.Name)) {
            return oli.Product2.Name;
        }
        return String.isNotBlank(oli.Name) ? oli.Name : '(Producto sin nombre)';
    }

    private static String formatearCantidad(Decimal cantidad) {
        if (cantidad == null) {
            return '0';
        }
        return cantidad == cantidad.round()
            ? String.valueOf(cantidad.round())
            : cantidad.setScale(2, System.RoundingMode.HALF_UP).toPlainString();
    }

    /**
    * @description Formatea el precio con separador de miles. No usa Decimal.format() a propósito:
    *              ese método depende de la configuración regional del usuario que agrega el
    *              producto, y el texto queda guardado en el campo para todos los demás.
    **/
    private static String formatearPrecio(Decimal precio, String moneda) {
        Decimal valor = precio == null ? 0 : precio;
        // Los precios de la org llegan con hasta 4 decimales (integración Softland); se respetan
        // los decimales que traiga el dato, con un mínimo de dos y un máximo de cuatro.
        Integer decimales = Math.min(Math.max(valor.scale(), 2), 4);
        Decimal redondeado = valor.setScale(decimales, System.RoundingMode.HALF_UP);

        String plano = redondeado.abs().toPlainString();
        String parteEntera = plano.contains(SEPARADOR_DECIMAL) ? plano.substringBefore(SEPARADOR_DECIMAL) : plano;
        String parteDecimal = plano.contains(SEPARADOR_DECIMAL) ? plano.substringAfter(SEPARADOR_DECIMAL) : '';

        String entero = '';
        Integer digitos = 0;
        for (Integer i = parteEntera.length() - 1; i >= 0; i--) {
            entero = parteEntera.substring(i, i + 1) + entero;
            digitos++;
            if (Math.mod(digitos, 3) == 0 && i > 0) {
                entero = SEPARADOR_MILES + entero;
            }
        }

        String textoPrecio = (redondeado < 0 ? '-' : '') + entero +
            (String.isBlank(parteDecimal) ? '' : SEPARADOR_DECIMAL + parteDecimal);

        return String.isBlank(moneda) ? textoPrecio : moneda + ' ' + textoPrecio;
    }
}
