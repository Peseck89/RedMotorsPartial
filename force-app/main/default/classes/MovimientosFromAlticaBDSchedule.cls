/**
 * @description       : 
 * @author            : esteban@incompany.cr
 * @group             : 
 * @last modified on  : 19-10-2022
 * @last modified by  : esteban@incompany.cr
**/
public with sharing class MovimientosFromAlticaBDSchedule implements Schedulable{
    public void execute(SchedulableContext ctx) {
        MovimientosController.processMovimientos();
    }
}