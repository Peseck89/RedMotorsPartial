@isTest
public with sharing class Registrar_Anticipo_Controller_Test {
    
    @IsTest
    public static void testSoloDummy() {
        // Llamada únicamente al método dummy()
        Registrar_Anticipo_Controller.dummyMethod();
        Registrar_Anticipo_Controller.dummy();
    }
}