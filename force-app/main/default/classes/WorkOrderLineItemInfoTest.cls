@IsTest
public class WorkOrderLineItemInfoTest {
    @IsTest
    static void testWorkOrderLineItemInfoConstructor() {
        // Valores de prueba para inicializar la clase
        String testName = 'Test Line Item';
        Decimal testAmount = 1000.50;
        String testChargeType = 'Service Charge';
        String testTipoTrabajo = 'Maintenance';

        // Crear una instancia de WorkOrderLineItemInfo
        WorkOrderLineItemInfo lineItemInfo = new WorkOrderLineItemInfo(testName, testAmount, testChargeType, testTipoTrabajo);

        // Validar que los valores fueron asignados correctamente
        System.assertEquals(testName, lineItemInfo.workOrderLineItemName, 'El nombre del elemento de línea de orden de trabajo no coincide.');
        System.assertEquals(testAmount, lineItemInfo.totalAmount, 'El monto total no coincide.');
        System.assertEquals(testChargeType, lineItemInfo.chargeType, 'El tipo de cargo no coincide.');
        System.assertEquals(testTipoTrabajo, lineItemInfo.tipoTrabajo, 'El tipo de trabajo no coincide.');
    }
}