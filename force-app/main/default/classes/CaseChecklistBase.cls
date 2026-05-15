/**
 * @description       : Helpers comunes para los controllers Visualforce
 *                      CaseChecklistController (v1) y CaseChecklistController_v2.
 *                      Refactor conservador Grupo 22. No contiene lógica nueva:
 *                      solo extrae bloques idénticos entre ambos controllers.
 *                      No reemplaza properties públicas, wrappers internos ni constructors;
 *                      ambos controllers siguen siendo los puntos de entrada Visualforce
 *                      (CaseChecklistPDFBeta y CaseChecklistPDFBeta_v2 respectivamente).
 * @group             : Grupo 22 - Refactor controllers Case Checklist
**/
public with sharing class CaseChecklistBase {

    /**
     * Devuelve los Cambio_de_Propietario__c en estado 'Pendiente' asociados al Case o al Asset.
     * SOQL idéntico en v1 (L112-113) y v2 (L50-51).
     */
    public static List<Cambio_de_Propietario__c> getCambioPropietarioPendiente(Id caseId, Id assetId) {
        return [
            SELECT Id, Asset__c, Case__c, Cuenta_Anterior__c, Cuenta_Nueva__c, Estado__c
            FROM Cambio_de_Propietario__c
            WHERE (Case__c = :caseId OR Asset__c = :assetId)
              AND Estado__c = 'Pendiente'
        ];
    }

    /**
     * Devuelve la primera WorkOrder asociada al Case para mostrar la ubicación.
     * SOQL idéntico en v1 (L172) y v2 (L122).
     */
    public static List<WorkOrder> getUbicacionPorCaso(Id caseId) {
        return [
            SELECT Id, ServiceTerritoryId, CaseId
            FROM WorkOrder
            WHERE CaseId = :caseId
            LIMIT 1
        ];
    }

    /**
     * Calcula el kilometraje a mostrar:
     *  - Si la lista de WorkOrder tiene al menos 1 elemento Y su Kilometros__c no es null y != 0,
     *    devuelve OT[0].Kilometros__c.
     *  - En cualquier otro caso devuelve el fallback (típicamente cs.Asset.Kilometros__c).
     * Lógica idéntica byte-a-byte (tras normalizar whitespace) en v1 (L145-151) y v2 (L96-104).
     */
    public static Decimal calcularKilometros(List<WorkOrder> ot, Decimal fallback) {
        if (ot != null && ot.size() > 0
            && ot[0].Kilometros__c != null && ot[0].Kilometros__c != 0) {
            return ot[0].Kilometros__c;
        }
        return fallback;
    }
}