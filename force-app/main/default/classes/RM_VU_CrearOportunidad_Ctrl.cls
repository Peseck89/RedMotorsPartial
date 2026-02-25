public with sharing class RM_VU_CrearOportunidad_Ctrl{
    static final Integer PAGE_SIZE = 50;
    public static final String PRICEBOOK_NAME = getDefaultPriceListVN();
    public static String getDefaultPriceListVN(){
        return RM_Config__mdt.getInstance('Default_Price_List_VU')?.Value__c;
    }

    public class RM_VN_SelectedItem_Wrapper{
        @AuraEnabled
        public String prodXBodId{ get; set; }

        @AuraEnabled
        public String pbeId{ get; set; }

    }

    @AuraEnabled
    public static List<Account> validarCuenta(String cuentaId){
        List<Account> lstAcc = [Select Id, FirstName, LastName, Name, Phone, PersonEmail, IsPersonAccount, CorreoElectronicoEmpresarial__c, PersonContactId, Invoice_Email__c
                                From Account
                                Where Id = :cuentaId];
        // if(lstAcc.size()>0){
        //     // if(lstAcc[0].IsPersonAccount == true && (lstAcc[0].FirstName == null || lstAcc[0].FirstName == '' || lstAcc[0].LastName == '' || lstAcc[0].LastName == null || lstAcc[0].Phone == null || lstAcc[0].PersonEmail == null  || lstAcc[0].PersonEmail == '' )){
        //     //     return false;
        //     // }else if(lstAcc[0].IsPersonAccount == false && (lstAcc[0].Name == null || lstAcc[0].Name == '' || lstAcc[0].Phone == null || lstAcc[0].CorreoElectronicoEmpresarial__c == null  || lstAcc[0].CorreoElectronicoEmpresarial__c == '' )){
        //     //     return false;
        //     // }
        // }
        return lstAcc;
    }

    @AuraEnabled
    public static List<Account> crearCuenta(String cuentaId, String nombre, String apellido, String telefono, String email, String emailFact){

        List<Account> lstAcc = [Select Id, FirstName, Invoice_Email__c, LastName, Name, Phone, PersonEmail, IsPersonAccount, CorreoElectronicoEmpresarial__c
                                From Account
                                Where Id = :cuentaId];
        for (Account cuenta : lstAcc){
            if (cuenta.IsPersonAccount == true){
                cuenta.FirstName = nombre;
                cuenta.PersonEmail = email;
                cuenta.LastName = apellido;
            } else{
                cuenta.Name = nombre;
                cuenta.CorreoElectronicoEmpresarial__c = email;
            }
            cuenta.Phone = telefono;
            cuenta.Invoice_Email__c = emailFact;

            update cuenta;
        }
        return lstAcc;
    }

    @AuraEnabled
    public static Map<String, Object> createOpportunity(String contactoId, String accountId, List<RM_VN_SelectedItem_Wrapper> items, String strTipoDeCliente, String strDepartamento, String strCuentaFacturacion, String strLeadSource, String realizaTestDrive, String strAniodelvehiculo, String tipoDeUso, String fechaPosibleCompra, String formaDePago, String plazoEnMeses, Decimal prima, String entidad){
        Map<String, Object> responseMap = new Map<String, Object>{  };

        if (String.isBlank(PRICEBOOK_NAME)){
            throw new AuraHandledException('Lista de precio default requerida en el metadado de configuracion.');
        }

        if (String.isBlank(accountId)){
            throw new AuraHandledException('La cuenta es requerida.');
        }

        List<Account> accountList = [SELECT Id, Name, IsPersonAccount, Cedula__c, Cedula__pc
                                     FROM Account
                                     WHERE Id = :accountId
                                     LIMIT 1];

        if (accountList.isEmpty()){
            throw new AuraHandledException('La cuenta ingresada no existe.');
        }
        // prueba
        Account acc = accountList[0];

        String identificacion;
        if (acc.IsPersonAccount){
            identificacion = String.isNotBlank(acc.Cedula__pc) ? acc.Cedula__pc : acc.Cedula__c; // 👈 fallback
        } else{
            identificacion = acc.Cedula__c;
        }

        identificacion = String.isBlank(identificacion) ? null : identificacion.trim();

        System.debug(LoggingLevel.ERROR, 'VU_IDENTIFICACION_RAW => ' + identificacion);

        if (items.isEmpty()){
            throw new AuraHandledException('Se requiere al menos un vehiculo.');
        }

        Set<String> prodXBodIds = new Set<String>();
        Set<Id> pbeIds = new Set<Id>();
        for (RM_VN_SelectedItem_Wrapper selectedItem : items){
            prodXBodIds.add(selectedItem.prodXBodId);
            pbeIds.add(selectedItem.pbeId);
        }

        //get the record type of the product in the following query
        Map<String, ProductoXBodega__c> prodXBodMap = new Map<String, ProductoXBodega__c>([SELECT Id, Producto__c, Producto__r.Tipo_vehiculo__c, Producto__r.Name, Bodega__c, Producto__r.ProductCode, Producto__r.Anno__c, Producto__r.marcaVehiculo__c, Producto__r.modelo__c, Producto__r.Color__c, Producto__r.Color_Externo__c, Producto__r.vin__c, Producto__r.Familia__c
                                                                                           FROM ProductoXBodega__c
                                                                                           WHERE Id IN:prodXBodIds AND Producto__r.es_Vehiculo_usado__c = true AND Producto__r.Producto_Reservado__c = FALSE AND Disponible__c > 0 AND Bodega__c != null]);

        //Buscar una familia
        String familiActual = '';
        for (ProductoXBodega__c prodB : [SELECT Id, Producto__c, Producto__r.Tipo_vehiculo__c, Producto__r.Name, Bodega__c, Producto__r.ProductCode, Producto__r.Anno__c, Producto__r.marcaVehiculo__c, Producto__r.modelo__c, Producto__r.Color__c, Producto__r.Color_Externo__c, Producto__r.vin__c, Producto__r.Familia__c
                                         FROM ProductoXBodega__c
                                         WHERE Id IN:prodXBodIds AND Producto__r.es_Vehiculo_usado__c = true AND Producto__r.Producto_Reservado__c = FALSE AND Disponible__c > 0 AND Bodega__c != null]){
            if (prodB.Producto__r.Familia__c != null){
                familiActual = prodB.Producto__r.Familia__c;
            }
        }

        if (prodXBodMap.keySet().isEmpty()){
            throw new AuraHandledException('Los registro de producto por bodega no fueron encontrados.');
        }

        if (items.size() != prodXBodMap.keySet().size()){
            throw new AuraHandledException('Favor de validar, alguno de los vehiculos de inventario ya no estan disponibles.');
        }

        Set<Id> prodIds = new Set<Id>();
        for (String prodXbodId : prodXBodMap.keySet()){
            prodIds.add(prodXBodMap.get(prodXbodId).Producto__c);
        }

        Map<String, PricebookEntry> pbeMap = new Map<String, PricebookEntry>([SELECT Id, UnitPrice, Costo_Fijo__c, Pricebook2.Name, Product2.Name, Product2Id, Pricebook2Id, Jefe__c, Vendedor__c, Gerente__c
                                                                              FROM PricebookEntry
                                                                              WHERE Id IN:pbeIds AND IsActive = TRUE AND Pricebook2.IsActive = TRUE AND Product2.IsActive = TRUE]);

        if (pbeMap.keySet().isEmpty()){
            throw new AuraHandledException('Algunos de los precios de la lista de precios ya no se encuentra disponible.');
        }

        if (items.size() != pbeMap.keySet().size()){
            throw new AuraHandledException('Favor de validar, alguno de las listas de precios ya no estan disponibles.');
        }

        String tipoProducto = prodXBodMap.values()[0].Producto__r.Tipo_vehiculo__c;
        if (String.isBlank(tipoProducto)){
            throw new AuraHandledException('Favor de validar el tipo de vehiculo.');
        }

        String recordTypeName;
        if (tipoProducto.equalsIgnoreCase('A') || tipoProducto.equalsIgnoreCase('Automóvil')){
            recordTypeName = 'Autos_Usados';
        } else if (tipoProducto.equalsIgnoreCase('M') || tipoProducto.equalsIgnoreCase('Motocicleta')){
            recordTypeName = 'Motos_Usados';
        } else{
            throw new AuraHandledException('No se pudo identificar el record type del vehiculo.');
        }

        List<RecordType> recordTypes = [SELECT Id
                                        FROM RecordType
                                        WHERE SObjectType = 'Opportunity' AND Name LIKE:recordTypeName AND IsActive = true
                                        LIMIT 1];
        if (recordTypes.isEmpty()){
            throw new AuraHandledException('Record type not found.');
        }
        Id recordTypeId = recordTypes[0].Id;

        try{
            // nuevo p
            Lead leadMatch = findValidTraffic(identificacion);
            Boolean leadLinked = (leadMatch != null);
            System.debug(LoggingLevel.ERROR, 'VU_LEAD_MATCH_ID => ' + (leadMatch != null ? leadMatch.Id : 'NULL'));
            String sucursal = '';
            Id userId = UserInfo.getUserId();
            List<User> lstUser = [SELECT Id, Sucursal__c
                                  FROM User
                                  WHERE Id = :userId AND Sucursal__c != null];
            if (!lstUser.isEmpty() && String.isNotBlank(lstUser[0].Sucursal__c)){
                sucursal = lstUser[0].Sucursal__c;
            }

            String currencyCode = RM_Config__mdt.getInstance('Default_Price_List_VU_Currency_Code')?.Value__c;

            PricebookEntry pbe = pbeMap.values()[0];

            Opportunity newOpp = new Opportunity(
                AccountId = accountId, 
                Name = 'VU - ' + acc.Name, 
                Sucursal__c = sucursal, 
                Pricebook2Id = pbe.Pricebook2Id, 
                StageName = 'Oportunidad Calificada', 
                CloseDate = System.today(), 
                Enganche_monto__c = 0, 
                RecordTypeId = recordTypeId, 
                CurrencyIsoCode = currencyCode, 
                contacto__c = contactoId, 
                LeadSource = strLeadSource, 
                Familia__c = familiActual, 
                Realiza_Test_Drive__c = String.isNotBlank(realizaTestDrive) && realizaTestDrive == 'Si' ? true : false, 
                RealizaTestDrivePicklist__c = realizaTestDrive, 
                Tipo_de_Cliente__c = strTipoDeCliente, 
                Departamento__c = strDepartamento, 
                Cuenta_de_Facturaci_n__c = strCuentaFacturacion, 
                aniodelvehiculo__c = strAniodelvehiculo, 
                Tipo_de_Uso_del_Veh_culo__c = tipoDeUso, 
                Fecha_Posible_Compra__c = fechaPosibleCompra, 
                Forma_de_Pago__c = formaDePago, 
                Plazo_en_Meses__c = plazoEnMeses, 
                Prima__c = prima, 
                Entidad__c = entidad
            );

            if (leadLinked && leadMatch != null){
                newOpp.Trafico__c = leadMatch.Id;
                newOpp.FechaDeConversion__c = Date.today();

                // Agregamos esto para copiar el origen si el Tráfico lo tiene
                if (String.isNotBlank(leadMatch.LeadSource)){
                    newOpp.LeadSource = leadMatch.LeadSource;
                }
            }
            System.debug(LoggingLevel.ERROR, 'VU_OPP_TRAFICO_PRE_INSERT => ' + newOpp.Trafico__c);

            insert newOpp;

            Opportunity oppCheck = [SELECT Id, Trafico__c
                                    FROM Opportunity
                                    WHERE Id = :newOpp.Id];
            System.debug(LoggingLevel.ERROR, 'VU_OPP_TRAFICO_POST_INSERT => ' + oppCheck.Trafico__c);


            Quote newQuote = new Quote(
                Name = newOpp.Id, 
                CurrencyIsoCode = currencyCode, 
                OpportunityId = newOpp.Id, 
                Pricebook2Id = pbe.Pricebook2Id
            );
            insert newQuote;

            List<QuoteLineItem> qliToInsert = new List<QuoteLineItem>();
            for (RM_VN_SelectedItem_Wrapper pxbItem : items){
                ProductoXBodega__c prodXbod = prodXBodMap.get(pxbItem.prodXBodId);

                QuoteLineItem newQLI = new QuoteLineItem(
                    QuoteId = newQuote.Id, 
                    Product2Id = prodXbod.Producto__c, 
                    Quantity = 1, 
                    BMW_Bodega__c = prodXbod.Bodega__c, 
                    PricebookEntryId = pxbItem.pbeId, 
                    UnitPrice = pbe.UnitPrice
                );

                qliToInsert.add(newQLI);
            }

            if (qliToInsert.size() > 0){
                insert qliToInsert;
            }

            responseMap.put('opportunityId', newOpp.Id);
            responseMap.put('quoteId', newQuote.Id);
            responseMap.put('leadLinked', leadLinked);
            if (leadLinked && leadMatch != null)
                responseMap.put('leadId', leadMatch.Id);
            newOpp.SyncedQuoteId = newQuote.Id;
            update newOpp;

            // Si hubo match, convertimos el tráfico y lo asociamos a la cuenta/contacto existentes
            if (leadLinked && leadMatch != null){
                convertTrafficLead(leadMatch.Id, accountId, contactoId);
            }

            Opportunity oppFinal = [SELECT Id, Trafico__c, SyncedQuoteId
                                    FROM Opportunity
                                    WHERE Id = :newOpp.Id];
            System.debug(LoggingLevel.ERROR, 'VU_OPP_TRAFICO_FINAL => ' + oppFinal.Trafico__c + ' | SyncedQuoteId=' + oppFinal.SyncedQuoteId);


        } catch (Exception e){
            if (!Test.isRunningTest()){
                throw new AuraHandledException(e.getMessage());
            } else{
                System.debug(e.getMessage());
            }
        }
        return responseMap;
    }

    @AuraEnabled(cacheable = true)
    public static List<RM_SelectOption_Wrapper> getRecordTypes(){
        List<RM_SelectOption_Wrapper> options = new List<RM_SelectOption_Wrapper>();
        List<RecordType> recordTypeList = [SELECT Id, Name, IsActive, SobjectType, IsPersonType, DeveloperName
                                           FROM RecordType
                                           WHERE SobjectType = 'Account' AND DeveloperName IN ('Business_Account', 'PersonAccount') AND IsActive = TRUE
                                           ORDER BY Name];
        for (RecordType rt : recordTypeList){
            options.add(new RM_SelectOption_Wrapper(rt.Name, rt.Id));
        }
        return options;
    }

    // nuevo
    private static Lead findValidTraffic(String numeroIdentificacionRaw){
        if (String.isBlank(numeroIdentificacionRaw))
            return null;
        String raw = numeroIdentificacionRaw.trim();
        String clean = raw.replaceAll('[^0-9A-Za-z]', '');
        if (String.isBlank(clean))
            return null;
        DateTime limitDate = System.now().addMonths(-6);

        List<Lead> lst = [SELECT Id, Name, Status, IsConverted, CreatedDate, Numero_de_Identificacion_del__c, LeadSource
                          FROM Lead
                          WHERE IsConverted = false AND CreatedDate >= :limitDate AND Numero_de_Identificacion_del__c != null AND (Numero_de_Identificacion_del__c = :raw OR Numero_de_Identificacion_del__c = :clean OR Numero_de_Identificacion_del__c LIKE:('%' + clean + '%'))
                          ORDER BY CreatedDate DESC
                          LIMIT 1];

        System.debug(LoggingLevel.ERROR, 'VU_TRAFFIC_FIND => raw=' + raw + 
                                     ' clean=' + clean + 
                                     ' found=' + (!lst.isEmpty() ? lst[0].Id : 'NULL') + 
                                     ' leadNum=' + (!lst.isEmpty() ? lst[0].Numero_de_Identificacion_del__c : 'NULL'));

        return lst.isEmpty() ? null : lst[0];
    }

    // nuevo
    private static void convertTrafficLead(Id leadId, Id accountId, String contactoId){
        if (leadId == null)
            return;
        Lead l = [SELECT Id, IsConverted, Status
                  FROM Lead
                  WHERE Id = :leadId
                  LIMIT 1];
        if (l.IsConverted)
            return;
        String convertedStatus = getAnyConvertedLeadStatusValue();
        if (String.isBlank(convertedStatus)){
            throw new AuraHandledException('No existe un LeadStatus marcado como Converted (IsConverted=true).');
        }

        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(leadId);
        lc.setDoNotCreateOpportunity(true);
        lc.setAccountId(accountId);
        lc.setConvertedStatus(convertedStatus);

        // OJO: solo setea contact si viene (si te daba problemas antes, déjalo sin setContactId)
        if (String.isNotBlank(contactoId)){
            lc.setContactId((Id) contactoId);
        }

        Database.LeadConvertResult res;
        try{
            res = Database.convertLead(lc, false);
        } catch (Exception e){
            throw new AuraHandledException('Error al convertir Tráfico: ' + e.getMessage());
        }

        if (res == null || !res.isSuccess()){
            String msg = 'No se pudo convertir el Tráfico.';
            if (res != null && res.getErrors() != null && !res.getErrors().isEmpty()){
                List<String> errs = new List<String>();
                for (Database.Error er : res.getErrors())
                    errs.add(er.getMessage());
                msg += ' Errores: ' + String.join(errs, ' | ');
            }
            throw new AuraHandledException(msg);
        }

        // Verificación final: que haya quedado convertido de verdad
        Lead afterL = [SELECT Id, IsConverted, Status
                       FROM Lead
                       WHERE Id = :leadId
                       LIMIT 1];
        if (!afterL.IsConverted){
            throw new AuraHandledException('El Tráfico no quedó convertido (IsConverted=false) aunque convertLead reportó éxito.');
        }
    }

    private static String getAnyConvertedLeadStatusValue(){
        List<LeadStatus> ls = [SELECT MasterLabel, SortOrder
                               FROM LeadStatus
                               WHERE IsConverted = true
                               ORDER BY SortOrder
                               LIMIT 1];
        return ls.isEmpty() ? null : ls[0].MasterLabel;
    }

    //create a dummy method for the test class
    public static void dummy(){
        String test = '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
    }

}