/**
 * Clase de prueba para el trigger handler de oportunidades
 * @author Marco Hernandez
 * @since 2024-06-01
 */
@isTest
public with sharing class RM_Opportunity_Trigger_Handler_Test {

    @TestSetup
    static void makeData(){
        RM_VN_DataFactoryHelper.createRecordsVN();
        
    }

    @IsTest
    static void testValidarOpportunityTrigger(){
        Account account = [SELECT Id FROM Account LIMIT 1];
        Campaign campanna = [SELECT Id FROM Campaign LIMIT 1];
        Pricebook2 pricebook = [SELECT Id FROM Pricebook2 LIMIT 1];

        PricebookEntry pricebookEntry = [SELECT Id, Product2Id, Product2.Name, Product2.esVehiculo__c,Pricebook2Id,CurrencyIsoCode FROM PricebookEntry WHERE Product2.IsActive = true AND Product2.esVehiculo__c = true AND Product2.Modelo_De_Inter_s__c != NULL LIMIT 1];
        System.debug('pricebookEntry: ' + pricebookEntry);

        //Cerrada Perdida
        List<Opportunity> newOpps = new List<Opportunity>();

        Opportunity newOppBMW = TestDataFactory.createOpportunity(account, 'Interesado', campanna, pricebook.Id, false);
        newOppBMW.LeadSource = 'Facebook';
        newOppBMW.RecordTypeId = TestDataFactory.getRecordTypeId('Opportunity', 'BMW');
        newOppBMW.Pricebook2Id = pricebookEntry.Pricebook2Id;
        newOppBMW.CurrencyIsoCode = pricebookEntry.CurrencyIsoCode;
        newOpps.add(newOppBMW);

        Opportunity newOppPolaris = TestDataFactory.createOpportunity(account, 'Interesado', campanna, pricebook.Id, false);
        newOppPolaris.LeadSource = 'Facebook';
        newOppPolaris.RecordTypeId = TestDataFactory.getRecordTypeId('Opportunity', 'Polaris');
        newOppPolaris.Pricebook2Id = pricebookEntry.Pricebook2Id;
        newOppPolaris.CurrencyIsoCode = pricebookEntry.CurrencyIsoCode;
        newOpps.add(newOppPolaris);

        Opportunity newOppMINI = TestDataFactory.createOpportunity(account, 'Interesado', campanna, pricebook.Id, false);
        newOppMINI.LeadSource = 'Facebook';
        newOppMINI.RecordTypeId = TestDataFactory.getRecordTypeId('Opportunity', 'MINI');
        newOppMINI.Pricebook2Id = pricebookEntry.Pricebook2Id;
        newOppMINI.CurrencyIsoCode = pricebookEntry.CurrencyIsoCode;
        newOpps.add(newOppMINI);

        Opportunity newOppKawasaki = TestDataFactory.createOpportunity(account, 'Interesado', campanna, pricebook.Id, false);
        newOppKawasaki.LeadSource = 'Facebook';
        newOppKawasaki.RecordTypeId = TestDataFactory.getRecordTypeId('Opportunity', 'Kawasaki');
        newOpps.add(newOppKawasaki);

        Opportunity newOppMotorrad = TestDataFactory.createOpportunity(account, 'Interesado', campanna, pricebook.Id, false);
        newOppMotorrad.LeadSource = 'Facebook';
        newOppMotorrad.RecordTypeId = TestDataFactory.getRecordTypeId('Opportunity', 'Motorrad');
        newOpps.add(newOppMotorrad);

        Opportunity newOppHarley = TestDataFactory.createOpportunity(account, 'Interesado', campanna, pricebook.Id, false);
        newOppHarley.LeadSource = 'Facebook';
        newOppHarley.RecordTypeId = TestDataFactory.getRecordTypeId('Opportunity', 'Harley_Davidson');
        newOpps.add(newOppHarley);

        insert newOpps;

        //setear opportunity line item and maintenance plan
        //fetch the pricebook entry entries where Product2.IsActive = true and AND Product2.esVehiculo__c = true
        
        //extract the pricebook entry
        Product2 product = pricebookEntry.Product2;

        OpportunityLineItem oppLineItem = TestDataFactory.createOpportunityLineItem(newOppBMW,product,pricebookEntry,true);

        //update product2 and set Producto_Reservado__c to true
        product.Producto_Reservado__c = true;
        update product;

        Plan_de_Mantenimiento__c planMtto = TestDataFactory.createPlanMantenimiento('Plan de Mantenimiento BMW',newOppBMW,oppLineItem,true);

        //update Trigger_control__c.Turned_off__c to false
        List<Trigger_control__c> triggerControl = [SELECT Id, Turned_off__c FROM Trigger_control__c WHERE Name = 'aprobacion de descuentos' LIMIT 1];
        triggerControl[0].Turned_off__c = true;
        update triggerControl;

        Test.setMock(HttpCalloutMock.class, new servicioEliminarReservaMock());

        newOppBMW.StageName = 'Cerrada Perdida';
        newOppBMW.RazonVentaPerdida__c = 'Compro otro auto/moto';
        update newOppBMW;

        triggerControl[0].Turned_off__c = false;
        update triggerControl;

        try {
            
            //change the record type
            // newOppBMW.RecordTypeId = TestDataFactory.getRecordTypeId('Opportunity', 'BMW');
            newOppBMW.StageName = 'Interesado';
            update newOppBMW;

            newOppBMW.RecordTypeId = TestDataFactory.getRecordTypeId('Opportunity', 'MINI');
            update newOppBMW;
        
        } catch (Exception e) {
            
        }

    }


    @IsTest
    static void testCambiarRecordTypeOportunidadMINI(){
        //fetch the existing opportunity
        Opportunity opp = [SELECT Id, RecordTypeId FROM Opportunity WHERE RecordTypeId =: TestDataFactory.getRecordTypeId('Opportunity', 'BMW') LIMIT 1];
        
        opp.RecordTypeId = TestDataFactory.getRecordTypeId('Opportunity', 'MINI');
        update opp;

        opp.RecordTypeId = TestDataFactory.getRecordTypeId('Opportunity', 'BMW');
        update opp;

        opp.RecordTypeId = TestDataFactory.getRecordTypeId('Opportunity', 'Polaris');
        update opp;

        opp.RecordTypeId = TestDataFactory.getRecordTypeId('Opportunity', 'Kawasaki');
        update opp;

        opp.RecordTypeId = TestDataFactory.getRecordTypeId('Opportunity', 'Motorrad');
        update opp;

        opp.RecordTypeId = TestDataFactory.getRecordTypeId('Opportunity', 'Harley_Davidson');
        update opp;
    }

 
}