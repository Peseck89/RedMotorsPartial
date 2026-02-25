/**
 * @description       : 
 * @author            : esteban@incompany.cr
 * @group             : 
 * @last modified on  : 06-12-2022
 * @last modified by  : esteban@incompany.cr
**/
public with sharing class ClientesFromAlticaBDSchedule implements Schedulable{
    public void execute(SchedulableContext ctx) {
        ClientesController.processClientes();
    }
}