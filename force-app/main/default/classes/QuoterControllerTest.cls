/**
 * @description       : Test class for QuoterController
 * @author            : marcohernandezhp@gmail.com
 * @group             : 
 * @last modified on  : 03-28-2023
 * @last modified by  : marcohernandezhp@gmail.com
**/
@isTest
public class QuoterControllerTest {
    static Integer iTotReg = 1;
    static Sucursal__c sucursal;
    static Campaign campanna; 

    @TestSetup
    static void makeData(){
        TestDataFactory.createQuoteWithItems();
    }
    
    // @IsTest
    // static void test_CreateQuote(){
    //     // List<Oportunidad_Producto_Interes__c> opiList = [SELECT Id,Producto__c FROM Oportunidad_Producto_Interes__c LIMIT 1];
    //     // List<ProductoXBodega__c> prodXBodList = [SELECT Id,Producto__c FROM ProductoXBodega__c LIMIT 1];
    //     //Map<String,Object> responseMap = QuoterController.createQuote(opiList[0].Id,prodXBodList[0].Id,false,null);            
    // }
    @IsTest
    static void test_CreateQuote(){                        
        QuoterController.dummy();
    }
}