@isTest
public class TriggerHelperTest {
    @TestSetup
    static void setup(){
            Campaign campana = new Campaign();
       campana.RecordTypeId = '0120P000000EPLHQA4';
       campana.Name = 'Campaña Red Motors';
       insert campana;
       
       Lead lead = new Lead();
       Lead.FirstName = 'Bricet';
       Lead.LastName = 'Rojas Gamboa';
       Lead.Email = 'bricet@incompany.cr';
       Lead.Phone = '22558877';
       Lead.MobilePhone = '88554477';
       Lead.Marca__c = 'BMW';
       Lead.Modelo_De_Inter_s1__c = 'BM101 - X2 - Sdrive 18i Premium';
       Lead.Familia1__c = 'X2';
       Lead.Ano1__c = '2020';
       Lead.FechaPosibleCompra__c = '1 a 3 meses';
       Lead.Sucursal__c = 'Uruca';
       Lead.Campana__c = campana.Id;
       Lead.LeadSource = 'Página Web';
       insert Lead;      
       
    }
    
   @istest  
    static void test1() {
       Campaign cam =[SELECT Id,Name FROM Campaign where Name = 'Campaña Red Motors' ];
       Lead lead2 = new Lead();
       Lead2.FirstName = 'Bricet';
       Lead2.LastName = 'Rojas Gamboa';
       Lead2.Email = 'bricet@incompany.cr';
       Lead2.Phone = '22558877';
       Lead2.MobilePhone = '88554477';
       Lead2.Marca__c = 'BMW';
       Lead2.Modelo_De_Inter_s1__c = 'BM101 - X2 - Sdrive 18i Premium';
       Lead2.Familia1__c = 'X2';
       Lead2.Ano1__c = '2020';
       Lead2.FechaPosibleCompra__c = '1 a 3 meses';
       Lead2.Sucursal__c = 'Uruca';
       Lead2.Campana__c = cam.Id;
       Lead2.LeadSource = 'Página Web';
       insert Lead2;
       }
}