public with sharing class RM_VU_Service {

    public static final String PRICEBOOK_NAME = getDefaultPriceListVN();

    public static final Integer PAGE_SIZE = 15;

    public static String getDefaultPriceListVN() {
        return RM_Config__mdt.getInstance('Default_Price_List_VN')?.Value__c;
    }  

    public static List<PricebookEntry> gePBEBavarian( String priceBookId,String currencyCode,String brand, String year, String modelOrName, String placa) {        
        List<PricebookEntry> pbeList = new List<PricebookEntry>();

        String soqlString = 'SELECT Product2Id,UnitPrice FROM PricebookEntry WHERE Pricebook2Id = :priceBookId AND Pricebook2.IsActive = TRUE AND Pricebook2.CurrencyIsoCode = :currencyCode AND CurrencyIsoCode = :currencyCode AND IsActive = TRUE AND Product2.IsActive = TRUE AND Product2.es_Vehiculo_usado__c = TRUE AND Product2.Producto_Reservado__c = FALSE ';
        
        if(String.isNotBlank(brand)){
            brand = '%'+String.escapeSingleQuotes(brand)+'%';
            soqlString += ' AND Product2.marcaVehiculo__c LIKE :brand';
        }
        
        if(String.isNotBlank(modelOrName)){
            modelOrName = '%'+String.escapeSingleQuotes(modelOrName.trim())+'%';
            soqlString += ' AND (Product2.modelo__c LIKE :modelOrName OR Product2.Name LIKE :modelOrName)';
        }

        if(String.isNotBlank(year)){
            year = String.escapeSingleQuotes(year.trim());
            soqlString += ' AND Product2.Anno__c = :year';
        }

        if(String.isNotBlank(placa)){
            placa = '%'+String.escapeSingleQuotes(placa.trim())+'%';
            soqlString += ' AND (Product2.ProductCode LIKE :placa OR Product2.vin__c LIKE :placa)';
        }

        soqlString += ' WITH SECURITY_ENFORCED ';
        
        try {
            pbeList = (List<PricebookEntry>) Database.query(soqlString);
        } catch(Exception e) {
            System.debug(e.getMessage());
            return pbeList;
        }
        return pbeList;
    }
}