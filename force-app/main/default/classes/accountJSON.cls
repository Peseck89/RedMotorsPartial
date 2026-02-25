public class accountJSON {
    public static String createAccount(String jsonStr) 
    {
        JSONGenerator gen = JSON.createGenerator(False);

        accountRequestJSON wrapAccountJSON = accountRequestJSON.parsePropuesta(jsonStr);
        String idSoftland = wrapAccountJSON.cliente;
        String name = wrapAccountJSON.nombre;
        String moneda = wrapAccountJSON.moneda;
        String categoriaCliente = wrapAccountJSON.categoriaCliente;
        String condicionPago = wrapAccountJSON.condicionPago;
        String barrio = wrapAccountJSON.barrio;
        String direccion = wrapAccountJSON.otrasSenas;
        String telefono1 = wrapAccountJSON.telefono1;
        String telefono2 = wrapAccountJSON.telefono2;
        String email = wrapAccountJSON.email;
        String contribuyenteId = wrapAccountJSON.contribuyenteId;
        String contribuyenteTipo = wrapAccountJSON.contribuyenteTipo;
        String contribuyenteRazonSocial = wrapAccountJSON.contribuyenteRazonSocial;
        String impuesto = wrapAccountJSON.impuesto;
        try
        {  
            System.debug(idSoftland);
            List<Account> acc =   [
                                        SELECT Id,Monedas_Iden__c
                                        FROM Account
                                        WHERE codigoSoftland__c = :idSoftland
                                    ];
            if(acc.size()==0)
            {

                condicionPago__c vCondicionPago = [SELECT Id,condicionPago__c FROM condicionPago__c WHERE condicionPago__c=:condicionPago];
                account newAccount = new Account();
                newAccount.codigoSoftland__c = idSoftland;
                newAccount.LastName = name;
                newAccount.Monedas_Iden__c = moneda;
                newAccount.condicionPago__c = vCondicionPago.Id;
                // newAccount.pais__c = pais;
                // newAccount.provincia__c = provincia;
                // newAccount.canton__c = canton;
                // newAccount.distrito__c = distrito;
                newAccount.barrio__c = barrio;
                newAccount.Direccion__c = direccion;
                newAccount.Phone = telefono1;
                newAccount.Telefono2__c = telefono2;
                newAccount.CorreoElectronicoEmpresarial__c = email;
                newAccount.Cedula__c = contribuyenteId;
                System.debug('Tipo: '+contribuyenteTipo);
                newAccount.Tipo_de_Documento__c = contribuyenteTipo;
                categoriaCliente__c vCategoriaCliente = [SELECT Id,categoriaCliente__c FROM categoriaCliente__c WHERE categoriaCliente__c =:categoriaCliente];
                newAccount.categoriaCliente__c = vCategoriaCliente.Id;
                impuesto__c vImpuesto = [SELECT Id,codigoImpuesto__c FROM impuesto__c WHERE codigoImpuesto__c=:Impuesto];
                newAccount.impuesto__c = vImpuesto.Id;
                newAccount.RecordTypeId = contribuyenteTipo=='1'?'0120P000000aqmZQAQ':'0120P000000ENVvQAO';
                insert newAccount;	

                gen.writeStartObject();
                gen.writeFieldName('Solicitud');
                gen.writeStartObject();
                gen.writeStringField('CODIGO', '200');
                gen.writeStringField('RESULT', 'La solicitud fue procesada exitosamente');
                gen.writeEndObject();
                gen.writeEndObject();
            } else {
                Account actualAccount = acc[0];
                actualAccount.LastName = name;
                actualAccount.Monedas_Iden__c = moneda;
                condicionPago__c vCondicionPago = [SELECT Id,condicionPago__c FROM condicionPago__c WHERE condicionPago__c=:condicionPago];
                actualAccount.condicionPago__c = vCondicionPago.Id;
                // actualAccount.pais__c = pais;
                // actualAccount.provincia__c = provincia;
                // actualAccount.canton__c = canton;
                // actualAccount.distrito__c = distrito;
                actualAccount.barrio__c = barrio;
                actualAccount.Direccion__c = direccion;
                actualAccount.Phone = telefono1;
                actualAccount.Telefono2__c = telefono2;
                actualAccount.CorreoElectronicoEmpresarial__c = email;
                actualAccount.Cedula__c = contribuyenteId;
                actualAccount.Tipo_de_Documento__c = contribuyenteTipo;
                categoriaCliente__c vCategoriaCliente = [SELECT Id,categoriaCliente__c FROM categoriaCliente__c WHERE categoriaCliente__c =:categoriaCliente];
                actualAccount.categoriaCliente__c = vCategoriaCliente.Id;
                impuesto__c vImpuesto = [SELECT Id,codigoImpuesto__c FROM impuesto__c WHERE codigoImpuesto__c=:Impuesto];
                actualAccount.impuesto__c = vImpuesto.Id;
                update actualAccount;

                gen.writeStartObject();
                gen.writeFieldName('Solicitud');
                gen.writeStartObject();
                gen.writeStringField('CODIGO', '201');
                gen.writeStringField('RESULT', 'La solicitud fue procesada exitosamente');
                gen.writeEndObject();
                gen.writeEndObject();
            }
            

        } catch(Exception ex)
        {
            gen = JSON.createGenerator(False);
            gen.writeStartObject();
            gen.writeFieldName('Solicitud');
            gen.writeStartObject();
            gen.writeStringField('CODIGO', '500');
            gen.writeStringField('RESULT', ex.getMessage()+' - '+ex.getLineNumber());
            gen.writeEndObject();
            gen.writeEndObject();
        }

        return gen.getAsString();
    }

    //Deserializador para las nuevas solicitudes
    public class accountRequestJSON {
        //Identificador del formulario
        public String cliente;
        public String nombre;
        public String moneda;
        public String condicionPago;
        public String categoriaCliente;
        public String pais;
        public String provincia;
        public String canton;
        public String distrito;
        public String barrio;
        public String otrasSenas;
        public String telefono1;
        public String telefono2;
        public String email;
        public String contribuyenteId;
        public String contribuyenteTipo;
        public String contribuyenteRazonSocial;
        public String contribuyenteAlias;
        public String impuesto;
    }

    public static accountRequestJSON parsePropuesta(String json) {
        return(accountRequestJSON) System.JSON.deserialize(json, accountRequestJSON.class);
    }
}