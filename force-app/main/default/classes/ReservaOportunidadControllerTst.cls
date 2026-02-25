@isTest
public with sharing class ReservaOportunidadControllerTst {
    
    @IsTest
    public static void testSoloDummy() {
        // Llamada únicamente al método dummy()
        ReservaOportunidadController.dummyMethod();
        ReservaOportunidadController.dummy();
    }
}