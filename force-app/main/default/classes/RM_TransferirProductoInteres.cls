/**
 * Clase que transfiere el producto de interes a oportunidad producto de interes despues de crear la opportunidad
 * @version 1.0
 * @test Class RM_TransferirProductoInteresTest
 * @author 
 * @since 
 */
public with sharing class RM_TransferirProductoInteres {

    public class inputTransferirProductoInteres {
        @InvocableVariable
        public String leadId;
    
        @InvocableVariable
        public String oppId;
    }

//crear metodo para ser llamado desde flow, recibira como paremetro leadId y oppId
    @InvocableMethod(label='Transferir Producto de Interes' description='Transferir Producto de Interes')
    public static void transferirProductoInteres(List<inputTransferirProductoInteres> input){
        //check if the input is not null
        if(input == null || input.size() == 0){
            throw new AuraHandledException('No se encontraron parametros');
        }

        //get the input
        String leadId = input[0].leadId;
        String oppId = input[0].oppId;

        //validar campos requeridos
        if(String.isBlank(leadId) || String.isBlank(oppId)){
            throw new AuraHandledException('Los campos (leadId,oppId) son requeridos');
        }

        //consultar el lead y la opp
        Lead lead = [SELECT Id, Precio1__c,Marca__c,Modelo_De_Inter_s1__c,Familia1__c,Ano1__c,Codigo_de_producto__c FROM Lead WHERE Id = :leadId];
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Id = :oppId];

        //validar que el lead y la opp existan
        if(lead == null || opp == null){
            throw new AuraHandledException('No se encontró el lead o la oportunidad');
        }

        List <OpportunityLineItem> olis = new List <OpportunityLineItem>();
        if( lead.Precio1__c != null && lead.Codigo_de_producto__c != null) {
            olis.add(createOppLineItem(lead,opp));                
        }
        
        if (olis.size() > 0) {
            INSERT olis;
        }

        Map<Id, OpportunityLineItem> oliMap = new Map<Id, OpportunityLineItem>(olis);

        List<Oportunidad_Producto_Interes__c> opiList = new List<Oportunidad_Producto_Interes__c>();
        for (OpportunityLineItem tmpOLI : [SELECT Product2Id,PricebookEntryId,UnitPrice,OpportunityId,Modelo_De_Inter_s1__c,Marca__c,Familia1__c,Quantity,PricebookEntry.Vendedor__c,PricebookEntry.Gerente__c,PricebookEntry.Costo_Fijo__c, PricebookEntry.Jefe__c,Anio_Interes__c FROM OpportunityLineItem WHERE Id IN :oliMap.keySet()]) {
            opiList.add(crearOppProdInteres1(tmpOLI));
        }
        if(opiList.size() > 0){
            INSERT opiList;
        }

    }

    //crear metodo para crear un opportunityLineItem,
    public static OpportunityLineItem createOppLineItem(Lead ld,Opportunity opp){
        OpportunityLineItem newOLI = new OpportunityLineItem();
        newOLI.OpportunityId = opp.Id;
        newOLI.UnitPrice = ld.Precio1__c;
        newOLI.Marca__c = ld.Marca__c;
        newOLI.Modelo_De_Inter_s1__c = ld.Modelo_De_Inter_s1__c;
        newOLI.Familia1__c = ld.Familia1__c;
        newOLI.Anio_Interes__c = ld.Ano1__c;
        newOLI.Quantity = 1;

        if(String.isNotBlank(ld.Codigo_de_producto__c)){
            newOLI.PricebookEntryId = ld.Codigo_de_producto__c;
        }
        return newOLI;
    }

    public static Oportunidad_Producto_Interes__c crearOppProdInteres1(OpportunityLineItem oli) {
        return new Oportunidad_Producto_Interes__c(
            Producto__c = oli.Product2Id,
            Precio_Unitario__c = oli.UnitPrice,
            Oportunidad__c = oli.OpportunityId,
            Modelo_Interes__c = oli.Modelo_De_Inter_s1__c,
            Marca__c = oli.Marca__c,
            Familia__c = oli.Familia1__c,
            Cantidad__c = oli.Quantity,
            Anio__c = oli.Anio_Interes__c,
            Comision_Porcentaje_Vendedor__c = oli.PricebookEntry.Vendedor__c,
            Comision_Porcentaje_Jefe__c = oli.PricebookEntry.Jefe__c,
            Comision_Porcentaje_Gerente__c = oli.PricebookEntry.Gerente__c,
            PricebookEntryId__c = oli.PricebookEntryId,
            Costo_Fijo__c = oli.PricebookEntry.Costo_Fijo__c,
            CurrencyIsoCode = 'USD'
        );
    }

}