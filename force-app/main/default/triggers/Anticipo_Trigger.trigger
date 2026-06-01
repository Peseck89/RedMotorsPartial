/**
 * @description       : Trigger Anticipo
 * @author            : marcohernandezhp@gmail.com
 * @group             : Redmotors
 * @last modified on  : 05-15-2023
 * @last modified by  : marcohernandezhp@gmail.com
**/
trigger Anticipo_Trigger on Anticipo__c (after insert, after update, after delete, after undelete) {
    new AnticipoTriggerHandler().run();
}
