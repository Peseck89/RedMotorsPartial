/**
 * @description       : Clase de prueba para escribir log
 * @author            : marcohernandezhp@gmail.com
 * @group             : Redmotors
 * @last modified on  : 05-12-2023
 * @last modified by  : marcohernandezhp@gmail.com
**/
@isTest
public class RM_Log_Test {
    
    @IsTest
    public static void testInserts(){
        RM_Log.write('url', 'inserts');
        RM_Log.write('url', 'inserts',false);        
        RM_Log.write(null,null,'url', 'inserts',true);        
        RM_Log.writeAnticipo(null,'test',null,'Consultar Anticipo',false);        
    }
}