@isTest
public class BMW_presupuestoVencido_test {
     @testSetup static void setup(){
         
    opportunity opp = new opportunity();
    opp.Name = 'FGT789K';
    opp.StageName = 'Oportunidad Calificada';
    opp.CloseDate =  Date.newInstance(2023,06,12);
    insert opp;     
    
    quote presupuesto = new quote();
    presupuesto.Name = 'PT-00008058';
    presupuesto.OpportunityId = opp.Id;
    insert presupuesto;
     }
    @isTest 
    public static void presVencido(){
        quote presupuesto = [Select Id, BMW_FechaVigente__c From quote];
        
    test.startTest();
    BMW_presupuestoVencido.quoteVencido(presupuesto.Id);
    test.stopTest();
    }
    
}