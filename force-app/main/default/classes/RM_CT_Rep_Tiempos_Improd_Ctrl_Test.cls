/**
 * @description       : Clase de pruebas reporte de tiempos improductivos
 * @author            : marcohernandezhp@gmail.com
 * @group             : Redmotors
 * @last modified on  : 05-29-2023
 * @last modified by  : marcohernandezhp@gmail.com
**/
@IsTest
public class RM_CT_Rep_Tiempos_Improd_Ctrl_Test {
    @TestSetup
    static void makeData(){
        TestDataFactory.prepareConsoleRecords();
    }

    @IsTest 
    static void test_GetRecords(){
        List<String> territories;
        String caseNumber;
        String workOrderNumber;
        String mecanicoId;
        Date startDate;
        Date endDate;
        Integer pageNumber;

        //Consultar tareas filtros en null
        RM_CT_Rep_Tiempos_Improd_Ctrl.getRecords(territories,mecanicoId,caseNumber,workOrderNumber,startDate,endDate,pageNumber);       

        // //consultar tareas con un rango de fecha
        startDate = System.today();  
        endDate = System.today().addDays(5);
        RM_CT_Rep_Tiempos_Improd_Ctrl.getRecords(territories,mecanicoId,caseNumber,workOrderNumber,startDate,endDate,pageNumber);
        

    }  
}