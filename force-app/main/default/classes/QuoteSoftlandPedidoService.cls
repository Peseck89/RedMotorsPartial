public class QuoteSoftlandPedidoService {
    private QuoteSoftlandQueryService queryService;
    private List<ApiCallSoftland> apiCalls;
    private List<Account> accountsToUpdate;

    public QuoteSoftlandPedidoService(List<String> quoteIds) {
        apiCalls = new List<ApiCallSoftland>();
        accountsToUpdate = new List<Account>();
        System.debug('Creando pedido ara');
        System.debug(quoteIds);
        queryService = new QuoteSoftlandQueryService(quoteIds);
        calculateQuotePedidoPayload();
    }

    private void calculateQuotePedidoPayload(){
        for(Quote quote: this.queryService.getQuotes()){
            String empresa = resolveCompanyErpCode(quote);
            AccountSoftlandService.AccountSoftlandResult accRes = AccountSoftlandService.getSoftlandAccount(quote.Cuenta_de_facturaci_n2__c);
            cls_ClientJSONResponse clienteResponse = accRes.clienteResponse;
            if (accRes.shouldUpdate && accRes.accountToUpdate != null) {
                this.accountsToUpdate.add(accRes.accountToUpdate);
            }
            if(clienteResponse.operationResult.code == '00'){
                QuoteSoftlandPayload payload = new QuoteSoftlandPayload();

                String moneda;
                if(quote.CurrencyIsoCode == 'USD'){
                    moneda = 'D';
                }else{
                    moneda = 'L';
                }

				String centroCostoValue;
                if (quote.Centro_de_Costo__c != null) {
                    List<CentroCosto__c> centrodeCostoList = [SELECT Name, Id, centroCosto__c FROM CentroCosto__c WHERE Id = :quote.Centro_de_Costo__c LIMIT 1];

                    if (!centrodeCostoList.isEmpty() && (quote.CPEstatusDeAprobacion__c == 'Aprobado')) {
                        CentroCosto__c centrodeCosto = centrodeCostoList[0];
                        centroCostoValue = centrodeCosto.centroCosto__c;
                    }else{
                        centroCostoValue = '';

                    }


                }





                String tipocliente = 'Comercial';
                if(quote.BMW_CostoFijo__c == true){
                    tipocliente = 'Interno';
                }else if(quote.Precio_empleado__c == True){
                    tipocliente = 'Empleado';
                }

                String tipodeclienteMostrador = '';

                if(quote.opportunity.Tipo_de_cliente_mostrador__c == 'Taller'){
                    tipodeclienteMostrador = 'Taller';
                }else if(quote.opportunity.Tipo_de_cliente_mostrador__c == 'Mecánico independiente'){
                    tipodeclienteMostrador = 'Mecánico independiente';
                }else{
                    tipodeclienteMostrador = quote.opportunity.Tipo_de_cliente_mostrador__c;
                }

                payload.tipodeclienteMostrador = tipodeclienteMostrador;

                //quote.opportunity.Tipo_de_cliente_mostrador__c
                //
                payload.mediocomunicacion = quote.Canal_origen__c;



                payload.pedido_interno_esPlan = quote.Pedido_Interno_es_Plan__c;

                payload.cargo = tipocliente;
                payload.compania = empresa;

                payload.aseguradoraPedido = quote.opportunity.BMW_Aseguradora__r.Name != null ? quote.opportunity.BMW_Aseguradora__r.Name : '';


                string vin = quote.VIN__c != null ? quote.VIN__c : '';
                string placa = quote.Placa__c != null ? quote.Placa__c : '';
                payload.vin = vin;
                payload.placa = placa;

                payload.taller = quote.opportunity.sucursal__c + ' - Mostrador';
                payload.total_mercaderia = String.valueOf(quote.sumtotal__c);
                payload.descripcion = quote.BMW_Comentarios__c;
                payload.total_impuesto2 = '0';
                payload.total_impuesto1 = String.valueOf(quote.tax);
                payload.total_a_facturar = String.valueOf(quote.sumtotal__c);
                payload.request_id = String.valueOf(quote.id) +DateTime.now().getTime();
                payload.porc_descuento2 = '0';
                payload.porc_descuento1 = String.valueOf(quote.bmw_descuentogeneral__c);
                payload.oportunidad = quote.opportunity.Id_Oportunidad__c;
                payload.monto_descuento2 = '0';
                payload.monto_descuento1 = '0';
                payload.moneda = moneda;
                payload.cod_cliente = clienteResponse.operationResult.description;
                payload.lineas = new List<QuoteSoftlandPayload.QuoteLine>();

                for(QuoteLineItem item : quote.QuoteLineItems){
                    if (item.Estado_reserva__c != null && item.Estado_reserva__c == 'Reservado') {
                        QuoteSoftlandPayload.QuoteLine linea = new QuoteSoftlandPayload.QuoteLine();
                linea.centro_costo = centroCostoValue;
                        linea.total_mercaderia = String.valueOf(item.TotalPrice);
                        linea.total_impuesto = '0.00';
                        linea.total_descuento = item.Discount > 0 ? String.valueOf(item.unitPrice - item.TotalPrice) : '0';
                        linea.total_a_facturar = String.valueOf(item.TotalPrice);
                        linea.precio_unitario = String.valueOf(item.unitPrice);
                        linea.porc_descuento = String.valueOf(item.Discount);
                        linea.monto_descuento =  item.Discount > 0 ?  String.valueOf(item.unitPrice - item.TotalPrice) : '0';
                        linea.id_linea = item.id;
                        //linea.desc_articulo = String.valueOf(item.BMW_Alias__c);          //(item.nombreProducto__c);
                        linea.desc_articulo = String.isNotBlank(item.BMW_Alias__c) ? String.valueOf(item.BMW_Alias__c) : String.valueOf(item.nombreProducto__c);

                        linea.comentario = '';
                        linea.cod_articulo = item.codigo_producto__c;
                        linea.cantidad = String.valueOf(item.quantity);
                        payload.lineas.add(linea);
                    }
                }
                addApiCall(JSON.serialize(payload));
            }
        }
    }

    private void addApiCall(String payload){
        ApiCallSoftland apiCall = new ApiCallSoftland();
        apiCall.payload = payload;
        apiCall.method = 'POST';
        this.apiCalls.add(apiCall);
    }

    public List<ApiCallSoftland> getAPICalls(){
        return this.apiCalls;
    }
    public List<Account> getAccountsToUpdate(){
        return this.accountsToUpdate;
    }

    private static String resolveCompanyErpCode(Quote quote) {
        try {
            EmpresaContext context;
            if (quote.Opportunity.Empresa_Operadora__c != null) {
                context = EmpresaResolver.resolve(quote.Opportunity.Empresa_Operadora__c);
            } else {
                context = EmpresaResolver.resolveByCodigo(resolveLegacyCompanyCode(quote.Opportunity.BMW_Compania__c));
            }

            validateSupportedCompany(context.codigo);
            return context.requireCodigoErp();
        } catch (EmpresaConfigurationException e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static String resolveLegacyCompanyCode(String legacyCompany) {
        if (String.isBlank(legacyCompany)) {
            throw new AuraHandledException('No existe empresa configurada para crear el pedido de Quote.');
        }

        String normalizedCompany = legacyCompany.trim().toUpperCase();
        if (normalizedCompany == 'BAVARIAN' || normalizedCompany == 'RMBAVARIAN') {
            return 'RMBAVARIAN';
        }
        if (normalizedCompany == 'OTOBAI' || normalizedCompany == 'RMOTOBAI') {
            return 'RMOTOBAI';
        }
        if (normalizedCompany == 'RMPEKING') {
            return 'RMPEKING';
        }

        throw new AuraHandledException('Empresa no soportada para crear el pedido de Quote.');
    }

    private static void validateSupportedCompany(String companyCode) {
        String normalizedCompany = String.isBlank(companyCode) ? null : companyCode.trim().toUpperCase();
        if (
            normalizedCompany == 'RMBAVARIAN' ||
            normalizedCompany == 'RMOTOBAI' ||
            normalizedCompany == 'RMPEKING'
        ) {
            return;
        }

        throw new AuraHandledException('Empresa no soportada para crear el pedido de Quote.');
    }



}
