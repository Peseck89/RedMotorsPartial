/**
 * @description       : Helpers comunes para los controllers Visualforce
 *                      cT_newPlanVentaControler (VN) y cT_newPlanVentaUsadoControler (VU).
 *                      Refactor conservador Grupo 17. No contiene lógica nueva:
 *                      solo extrae cálculos y SOQLs idénticos entre ambos controllers.
 *                      No reemplaza properties públicas, wrappers internos ni constructors;
 *                      los controllers siguen siendo los puntos de entrada Visualforce.
 * @group             : Grupo 17 - Refactor controllers PDF plan de venta
**/
public with sharing class cT_newPlanVentaBase {

    /**
     * Wrapper inmutable para los totales calculados sobre la Opportunity.
     * Reemplaza la asignación directa de tres variables locales en los constructors.
     */
    public class Totales {
        public Decimal valorTotalNegocio          = 0;
        public Decimal oppDescuentoTotalMonto     = 0;
        public Decimal oppDescuentoTotalPorcentaje = 0;
    }

    /**
     * Calcula los totales sumando OpportunityLineItems de la Opportunity ya consultada.
     * Reproduce exactamente la lógica original presente tanto en VN como en VU,
     * incluyendo el bloque ya existente en Partial y Producción que suma
     * Montoderegalias__c al valorTotalNegocio cuando la línea es vehículo.
     *
     * @param oppList Lista de Opportunity con OpportunityLineItems ya cargadas via subquery
     * @param esUsado true  -> usa Product2.es_Vehiculo_usado__c (VU)
     *                false -> usa Product2.esVehiculo__c        (VN)
     */
    public static Totales calcularTotales(List<Opportunity> oppList, Boolean esUsado) {
        Totales t = new Totales();
        if (oppList == null) {
            return t;
        }
        for (Opportunity opp : oppList) {
            if (opp.OpportunityLineItems == null) {
                continue;
            }
            for (OpportunityLineItem oli : opp.OpportunityLineItems) {
                Boolean esVehiculo = esUsado
                    ? (oli.Product2 != null && oli.Product2.es_Vehiculo_usado__c == true)
                    : (oli.Product2 != null && oli.Product2.esVehiculo__c == true);

                if (esVehiculo || oli.esExtra__c) {
                    t.valorTotalNegocio += oli.TotalPrice;
                }
                if (esVehiculo && oli.Montoderegalias__c != null) {
                    t.valorTotalNegocio += oli.Montoderegalias__c;
                }

                t.oppDescuentoTotalMonto       += oli.VN_Descuento_Aplicado_Monto_FX__c;
                t.oppDescuentoTotalPorcentaje  += oli.VN_Descuento_Aplicado_Porcentaje_FX__c;
            }
        }
        return t;
    }

    /**
     * Última Quote (ordenada por Name desc) asociada a la Opportunity.
     * SOQL idéntico al primer SELECT de getDataQuote en VN y VU.
     */
    public static List<Quote> getUltimaQuote(String oppId) {
        return [
            SELECT Id, Name
            FROM Quote
            WHERE OpportunityId = :oppId
            ORDER BY Name DESC
            LIMIT 1
        ];
    }

    /**
     * ReciboUsado__c con Serecibevehiculo__c = true asociado a la Opportunity.
     * SOQL idéntico al bloque final de getDataQuote en VN y VU.
     */
    public static List<ReciboUsado__c> getReciboUsadoFinal(String oppId) {
        return [
            SELECT Id, Marca__c, Ano__c, Placa__c, MontoSoporte__c,
                   ValorReciboCliente__c, ReciboJefeUsados__c, Modelo__c
            FROM ReciboUsado__c
            WHERE Oportunidad__c = :oppId
              AND Serecibevehiculo__c = true
        ];
    }
}