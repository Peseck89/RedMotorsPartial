/**
 * @description       : Test Class for CT_Summary_Controller
 * @author            : marcohernandezhp@gmail.com
 * @group             : Redmotors
 * @last modified on  : 01-04-2023
 * @last modified by  : marcohernandezhp@gmail.com
**/
@isTest
public with sharing class CT_Summary_Controller_Test {

    @TestSetup
    static void makeData(){
        TestDataFactory.prepareConsoleRecords();
    }

    @IsTest
    static void testGetData(){
        List<WorkStep> workStepList = [SELECT Id, CT_TieneSubtipo__c,Status FROM WorkStep WHERE CT_TieneSubtipo__c = TRUE];
        workStepList[0].Status = 'En curso'; 
        update workStepList[0];
        CT_Summary_Controller.getData();        
    }
}