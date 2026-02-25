public class BusquedaDetalladaController {
    public static String getUserSucursal(){
        User usr = [Select Id, Sucursal__c From User Where Id =: UserInfo.getUserId()];
        return usr.Sucursal__c;
    }
    @AuraEnabled(cacheable=true)
    public static List<Pricebook2> getActivePricebooks() {
        String sucursal = getUserSucursal();
        System.debug('sucursal '+sucursal);
        String pricebookName = 'Bavarian%';
        if(sucursal == 'Uruca' || sucursal == 'Pinares' || sucursal == 'Escazú'){
            pricebookName = 'Bavarian%';
        }else{ pricebookName = 'Otobai%';
        }
        return [
            SELECT Id, Name, IsStandard, IsActive
            FROM Pricebook2
            WHERE IsActive = true
  			AND (Name LIKE 'Bavarian%' OR Name LIKE: pricebookName)
            ORDER BY IsStandard DESC, Name ASC
        ];
    }
    @AuraEnabled(cacheable=true)
    public static List<ServiceTerritory> getActiveServiceTerritories() {
        return [
            SELECT Id, Name, IsActive
            FROM ServiceTerritory
            WHERE IsActive = true
            ORDER BY Name ASC
        ];
    }
    @AuraEnabled(cacheable=false)
    public static List<WoliGridWrapper> searchProducts (String productType, String queryValue, Id workOrder, Id priceBookId, Id serviceTerritoryId) { 
                String sucursal = getUserSucursal();
        String territoryName;
        if(sucursal == 'Pinares'){ territoryName = 'Pinares - Mecánica Rápida';
        }else if(sucursal == 'Escazú'){
            territoryName = 'Escazú - Mecánica Rápida';
        }else{ territoryName = 'Uruca - Mecánica Rápida';
        }
        ServiceTerritory st = [Select Id, Name From ServiceTerritory Where Name =:territoryName];

                BusquedaDetalladaHelper busquedaHelper = new BusquedaDetalladaHelper(workOrder);
        return busquedaHelper.searchProductsbyValue(productType, queryValue, priceBookId, st.Id);
    }
   

}