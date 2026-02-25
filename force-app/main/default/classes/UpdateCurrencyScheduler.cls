public class UpdateCurrencyScheduler implements Schedulable {
    
    public void execute(SchedulableContext SC) 
    {
        List<PricebookEntry> pds = [SELECT Costo_Fijo__c,CurrencyIsoCode,Familia__c,Gerente__c,Id,IsActive,IsArchived,IsDeleted,Jefe__c,LastModifiedById,LastModifiedDate,Name,Pricebook2Id,Pricebook2.name, pricebookEntryId__c,Product2Id,ProductCode,SystemModstamp,UnitPrice,UseStandardPrice,Vendedor__c FROM PricebookEntry where ( (CurrencyIsoCode = 'CRC' and Pricebook2.name = 'Bavarian Dólar') OR (CurrencyIsoCode = 'USD' and Pricebook2.name = 'Bavarian Local') OR (CurrencyIsoCode = 'CRC' and Pricebook2.name = 'Otobai Dólares') OR (CurrencyIsoCode = 'USD' and Pricebook2.name = 'Otobai Local') ) and SystemModStamp >:Datetime.now().addMinutes(-7)];
        
        List<PricebookEntry> ToBeinserted = new List<PricebookEntry>();
        for(PricebookEntry pd : pds)
        {
            PricebookEntry pd1 = new PricebookEntry();
            pd1.Costo_Fijo__c = pd.Costo_Fijo__c;
            if(pd.Pricebook2.name == 'Otobai Local')
            {
                pd1.CurrencyIsoCode = 'CRC';
            }
            else if(pd.Pricebook2.name == 'Otobai Dólares')
            {
                pd1.CurrencyIsoCode = 'USD';
            }
            else if(pd.Pricebook2.name == 'Bavarian Local')
            {
                pd1.CurrencyIsoCode = 'CRC';
            }
            else if(pd.Pricebook2.name == 'Bavarian Dólar')
            {
                pd1.CurrencyIsoCode = 'USD';
            }
            //pd1.Familia__c = pd.Familia__c;
            pd1.Gerente__c = pd.Gerente__c;
            pd1.IsActive = pd.IsActive;
            //pd1.IsArchived = pd.IsArchived;
            //pd1.IsDeleted = pd.IsDeleted;
            pd1.Jefe__c = pd.Jefe__c;
            //pd1.Name = pd.Name;
            pd1.Pricebook2Id = pd.Pricebook2Id;
            pd1.pricebookEntryId__c = pd.pricebookEntryId__c;
            pd1.Product2Id = pd.Product2Id;
            //pd1.ProductCode = pd.ProductCode;
            pd1.UnitPrice = pd.UnitPrice;
            pd1.UseStandardPrice = pd.UseStandardPrice;
            pd1.Vendedor__c = pd.Vendedor__c;
            ToBeinserted.add(pd1);
        }
        if(pds.size()> 0)
        {
            Database.delete(pds, false);
        }
        if(ToBeinserted.size() > 0)
        {
            Database.insert(ToBeinserted, false);
        }
    }
}
/*
 for(Integer i=0;i<60;i)
{
UpdateCurrencyScheduler up2 = new UpdateCurrencyScheduler();
String sch2 = '0 '+ i +' * * * ?';
String jobName2 = 'Update Currency at minute ' + i;
System.schedule(jobName2, sch2, up2);
    i = i + 3;
}
*/