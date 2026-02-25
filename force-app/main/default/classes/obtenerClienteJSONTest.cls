@isTest
public with sharing class obtenerClienteJSONTest {
    @TestSetup
    static void setup(){
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Cedula__c = '3102416518';
        insert acc;
        
        Encabezado__c buro = new Encabezado__c();
        buro.Cuenta__c = acc.Id;
        insert buro;
        
        actividadesNegocios__c act = new actividadesNegocios__c();
        act.nivelDeRiesgo__c = 1.00;
        act.nombreActividad__c = 'Administrador de Empresas';
        insert act;
        
        Oportunidad_de_Financiamiento__c opp = new Oportunidad_de_Financiamiento__c();
        opp.Name = 'Test opp';
        opp.Nombre_Cliente_Altica__c = acc.Id;
        opp.formularioConozcaSuCliente__c = true;
        opp.origenRecursos__c = 1.00;
        opp.estructuraPropiedad__c = 1.00;
        opp.comportamiento__c = 1.00;
        opp.tipoDeProducto__c = 1.00;
        opp.tipoMontoFrecuenciaTransacciones__c = 1.00;
        insert opp;
    }

    @isTest
    static void obtenerClienteTest() {
        obtenerClienteJSON.obtenerCliente('3102416518');
    }

    
    @isTest
    static void updateClienteTest() {
        Oportunidad_de_Financiamiento__c opp = [SELECT Id FROM Oportunidad_de_Financiamiento__c WHERE Name = 'Test opp'];
        StaticResource resource = [SELECT Id, Body FROM StaticResource WHERE Name = 'clienteResource' LIMIT 1];
        String jsonStr = resource.Body.toString();
        obtenerClienteJSON.updateCliente(jsonStr,opp);
    }
}