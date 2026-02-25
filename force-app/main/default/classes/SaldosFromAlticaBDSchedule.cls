/**
 * @description       : 
 * @author            : esteban@incompany.cr
 * @group             : 
 * @last modified on  : 20-10-2022
 * @last modified by  : esteban@incompany.cr
**/
public with sharing class SaldosFromAlticaBDSchedule implements Schedulable{
    public void execute(SchedulableContext ctx) {
        SaldosController.processSaldos();
    }
}