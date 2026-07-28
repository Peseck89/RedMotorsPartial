public with sharing class QuoteSoftlandQueryService {
    private List<Quote> quoteList;
    public QuoteSoftlandQueryService(List<String> quoteIds) {
        init(quoteIds);
        system.debug(quoteList);
    }

    private void init(List<String> quoteIds){
        this.quoteList = [SELECT id,CurrencyIsoCode,BMW_CostoFijo__c,CPEstatusDeAprobacion__c ,Pedido_Interno_es_Plan__c , Centro_de_Costo__c,Precio_empleado__c, Cuenta_de_facturaci_n2__c , opportunity.Cuenta_de_Facturaci_n__c , opportunity.Empresa_Operadora__c, opportunity.bmw_compania__c,opportunity.Id_Oportunidad__c, opportunity.sucursal__c, sumtotal__c, tax, subtotal, bmw_descuentogeneral__c,
                                 opportunity.numeroconsecutivo__c,Canal_origen__c, opportunity.Tipo_de_cliente_mostrador__c , opportunity.BMW_Aseguradora__r.Name, BMW_Comentarios__c, Placa__c, VIN__c, account.codigosoftland__c, AccountId,
                          (SELECT id,Estado_entrega__c, Estado_reserva__c, totalprice__c, unitprice, TotalPrice, Discount,BMW_Alias__c , nombreproducto__c, codigo_producto__c, quantity,CurrencyIsoCode from quotelineitems)
                          FROM Quote where id =: quoteIds];
    }








    public List<Quote> getQuotes(){
        system.debug('QUOTES QUERIED');
        system.debug(this.quoteList);
        return this.quoteList;
    }

}
