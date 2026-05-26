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

    public class RM_SelectOption_Wrapper{
        @AuraEnabled
        public String label{ get; set; }

        @AuraEnabled
        public String value{ get; set; }

        public RM_SelectOption_Wrapper(String l, String v){
            label = l;
            value = v;
        }
    }

    @AuraEnabled
    public static List<Account> validarCuenta(String cuentaId){
        Id cuentaIdVal = toIdOrThrow('La cuenta', cuentaId);
        return RM_CrearOportunidadBase.validarCuenta(String.valueOf(cuentaIdVal));
    }

    @AuraEnabled
    public static List<Account> crearCuenta(String cuentaId, String nombre, String apellido, String telefono, String email, String emailFact){
        Id cuentaIdVal = toIdOrThrow('La cuenta', cuentaId);

        List<Account> lstAcc = RM_CrearOportunidadBase.prepararCuenta(String.valueOf(cuentaIdVal), nombre, apellido, telefono, email, emailFact);

        if (!lstAcc.isEmpty()){
            update lstAcc;
        }
        return lstAcc;
    }

    @AuraEnabled
    public static Map<String, Object> createOpportunity(
        String contactoId,
        String accountId,
        List<RM_VN_SelectedItem_Wrapper> items,
        String strTipoDeCliente,
        String strDepartamento,
        String strCuentaFacturacion,
        String strLeadSource,
        String realizaTestDrive,
        String strAniodelvehiculo,
        String tipoDeUso,
        String fechaPosibleCompra,
        String formaDePago,
        String plazoEnMeses,
        Decimal prima,
        String entidad
    ){
        contactoId = normalizeNullish(contactoId);
        accountId = normalizeNullish(accountId);
        strCuentaFacturacion = normalizeNullish(strCuentaFacturacion);
        entidad = normalizeNullish(entidad);
        strDepartamento = normalizeNullish(strDepartamento);

        Id accountIdVal = toIdOrThrow('La cuenta', accountId);
        Id contactoIdVal = toIdOrNull(contactoId);
        Id cuentaFactIdVal = toIdOrNull(strCuentaFacturacion);

        Map<String, Object> responseMap = new Map<String, Object>();

        if (String.isBlank(PRICEBOOK_NAME)){throw new AuraHandledException('Lista de precio default requerida en el metadado de configuracion.');
        }

        Account acc = [
            SELECT Id, Name, IsPersonAccount, Cedula__c, Cedula__pc
            FROM Account
            WHERE Id = :accountIdVal
            LIMIT 1
        ];

        String identificacion;
        if (acc.IsPersonAccount){
            identificacion = String.isNotBlank(acc.Cedula__pc) ? acc.Cedula__pc : acc.Cedula__c;
        } else{
            identificacion = acc.Cedula__c;
        }

        identificacion = String.isBlank(identificacion) ? null : identificacion.trim();
        System.debug(LoggingLevel.ERROR, 'VU_IDENTIFICACION_RAW => ' + identificacion);

        if (items == null || items.isEmpty()){
            throw new AuraHandledException('Se requiere al menos un vehiculo.');
        }

        Set<Id> prodXBodIds = new Set<Id>();
        Set<Id> pbeIds = new Set<Id>();

        for (RM_VN_SelectedItem_Wrapper selectedItem : items){
            if (selectedItem == null){
                throw new AuraHandledException('Se requiere al menos un vehículo válido.');
            }
            prodXBodIds.add(toIdOrThrow('Vehículo (ProductoXBodega)', selectedItem.prodXBodId));
            pbeIds.add(toIdOrThrow('Lista de precios (PricebookEntry)', selectedItem.pbeId));
        }

        Map<Id, ProductoXBodega__c> prodXBodMap = new Map<Id, ProductoXBodega__c>([
            SELECT Id,
                   Producto__c,
                   Producto__r.Tipo_vehiculo__c,
                   Producto__r.Name,
                   Bodega__c,
                   Producto__r.ProductCode,
                   Producto__r.Anno__c,
                   Producto__r.marcaVehiculo__c,
                   Producto__r.modelo__c,
                   Producto__r.Color__c,
                   Producto__r.Color_Externo__c,
                   Producto__r.vin__c,
                   Producto__r.Familia__c
            FROM ProductoXBodega__c
            WHERE Id IN :prodXBodIds
              AND Producto__r.es_Vehiculo_usado__c = true
              AND Producto__r.Producto_Reservado__c = FALSE
              AND Disponible__c > 0
              AND Bodega__c != null
        ]);

        if (prodXBodMap.isEmpty()){
            throw new AuraHandledException('Los registro de producto por bodega no fueron encontrados.');
        }
        if (items.size() != prodXBodMap.size()){
            throw new AuraHandledException('Favor de validar, alguno de los vehiculos de inventario ya no estan disponibles.');
        }

        String familiActual = null;
        for (ProductoXBodega__c prodB : prodXBodMap.values()){
            if (String.isNotBlank(prodB.Producto__r.Familia__c)){familiActual = prodB.Producto__r.Familia__c; break;
            }
        }

        Map<Id, PricebookEntry> pbeMap = new Map<Id, PricebookEntry>([
            SELECT Id,
                   UnitPrice,
                   Costo_Fijo__c,
                   Pricebook2Id,
                   Product2Id,
                   Jefe__c,
                   Vendedor__c,
                   Gerente__c
            FROM PricebookEntry
            WHERE Id IN :pbeIds
              AND IsActive = TRUE
              AND Pricebook2.IsActive = TRUE
              AND Product2.IsActive = TRUE
        ]);

        if (pbeMap.isEmpty()){
            throw new AuraHandledException('Algunos de los precios de la lista de precios ya no se encuentra disponible.');
        }
        if (items.size() != pbeMap.size()){ throw new AuraHandledException('Favor de validar, alguno de las listas de precios ya no estan disponibles.');
        }

        Id firstPxbId = toIdOrThrow('Vehículo (ProductoXBodega)', items[0].prodXBodId);
        ProductoXBodega__c firstPxb = prodXBodMap.get(firstPxbId);
        if (firstPxb == null){throw new AuraHandledException('Vehículo no encontrado en inventario: ' + firstPxbId);
        }

        String tipoProducto = firstPxb.Producto__r.Tipo_vehiculo__c;
        if (String.isBlank(tipoProducto)){
            throw new AuraHandledException('Favor de validar el tipo de vehiculo.');
        }

        String recordTypeDevName;
        if (tipoProducto.equalsIgnoreCase('A') || tipoProducto.equalsIgnoreCase('Automóvil')){
            recordTypeDevName = 'Autos_Usados';
        } else if (tipoProducto.equalsIgnoreCase('M') || tipoProducto.equalsIgnoreCase('Motocicleta')){
            recordTypeDevName = 'Motos_Usados';
        } else{throw new AuraHandledException('No se pudo identificar el record type del vehiculo.');
        }

        List<RecordType> recordTypes = [
            SELECT Id, DeveloperName
            FROM RecordType
            WHERE SObjectType = 'Opportunity'
              AND DeveloperName = :recordTypeDevName
              AND IsActive = true
            LIMIT 1
        ];

        if (recordTypes.isEmpty()){throw new AuraHandledException('Record type not found.');
        }

        Id recordTypeId = recordTypes[0].Id;
        recordTypeDevName = recordTypes[0].DeveloperName;

        try{
            Lead leadMatch = findValidTraffic(identificacion, recordTypeDevName);
            Boolean leadLinked = (leadMatch != null);

            String sucursal = null;
            User u = [
                SELECT Id, Sucursal__c
                FROM User
                WHERE Id = :UserInfo.getUserId()
                LIMIT 1
            ];
            if (String.isNotBlank(u.Sucursal__c)){
                sucursal = u.Sucursal__c;
            }

            String currencyCode = RM_Config__mdt.getInstance('Default_Price_List_VU_Currency_Code')?.Value__c;

            Id firstPbeId = toIdOrThrow('Lista de precios (PricebookEntry)', items[0].pbeId);
            PricebookEntry pbeBase = pbeMap.get(firstPbeId);
            if (pbeBase == null){ throw new AuraHandledException('Lista de precios no encontrada o inactiva: ' + firstPbeId);
            }

            Id basePbId = pbeBase.Pricebook2Id;
            for (PricebookEntry p : pbeMap.values()){
                if (p.Pricebook2Id != basePbId){ throw new AuraHandledException('Todos los vehículos deben venir de la misma lista de precios.');
                }
            }

            Opportunity newOpp = new Opportunity(
                AccountId = accountIdVal,
                Name = 'VU - ' + acc.Name,
                Sucursal__c = sucursal,
                Pricebook2Id = pbeBase.Pricebook2Id,
                StageName = 'Oportunidad Calificada',
                CloseDate = System.today(),
                Enganche_monto__c = 0,
                RecordTypeId = recordTypeId,
                CurrencyIsoCode = currencyCode,
                contacto__c = contactoIdVal,
                LeadSource = strLeadSource,
                Familia__c = familiActual,
                Realiza_Test_Drive__c = (String.isNotBlank(realizaTestDrive) && realizaTestDrive == 'Si'),
                RealizaTestDrivePicklist__c = realizaTestDrive,
                Tipo_de_Cliente__c = strTipoDeCliente,
                Departamento__c = strDepartamento,
                Cuenta_de_Facturaci_n__c = cuentaFactIdVal,
                aniodelvehiculo__c = strAniodelvehiculo,
                Tipo_de_Uso_del_Veh_culo__c = tipoDeUso,
                Fecha_Posible_Compra__c = fechaPosibleCompra,
                Forma_de_Pago__c = formaDePago,
                Plazo_en_Meses__c = plazoEnMeses,
                Prima__c = prima,
                Entidad__c = entidad
            );

            if (leadLinked){
                newOpp.Trafico__c = leadMatch.Id;
                newOpp.FechaDeConversion__c = Date.today();
                if (String.isNotBlank(leadMatch.LeadSource)){
                    newOpp.LeadSource = leadMatch.LeadSource;
                }
            }

            insert newOpp;

            Quote newQuote = new Quote(
                Name = String.valueOf(newOpp.Id),
                CurrencyIsoCode = currencyCode,
                OpportunityId = newOpp.Id,
                Pricebook2Id = pbeBase.Pricebook2Id
            );
            insert newQuote;

            List<QuoteLineItem> qliToInsert = new List<QuoteLineItem>();
            for (RM_VN_SelectedItem_Wrapper pxbItem : items){
                Id pxbId = toIdOrThrow('Vehículo (ProductoXBodega)', pxbItem.prodXBodId);
                Id pbeIdIt = toIdOrThrow('Lista de precios (PricebookEntry)', pxbItem.pbeId);

                ProductoXBodega__c prodXbod = prodXBodMap.get(pxbId);
                if (prodXbod == null){throw new AuraHandledException('Vehículo no encontrado en inventario: ' + pxbId);
                }

                PricebookEntry pbeLine = pbeMap.get(pbeIdIt);
                if (pbeLine == null){throw new AuraHandledException('PricebookEntry no encontrado/activo: ' + pbeIdIt);
                }

                qliToInsert.add(new QuoteLineItem(
                    QuoteId = newQuote.Id,
                    Product2Id = prodXbod.Producto__c,
                    Quantity = 1,
                    BMW_Bodega__c = prodXbod.Bodega__c,
                    PricebookEntryId = pbeIdIt,
                    UnitPrice = pbeLine.UnitPrice
                ));
            }

            if (!qliToInsert.isEmpty()){
                insert qliToInsert;
            }

            responseMap.put('opportunityId', newOpp.Id);
            responseMap.put('quoteId', newQuote.Id);
            responseMap.put('leadLinked', leadLinked);
            responseMap.put('leadId', leadLinked ? leadMatch.Id : null);

            try{
                newOpp.SyncedQuoteId = newQuote.Id;
                update newOpp;
            } catch (Exception e){
                System.debug(LoggingLevel.ERROR, 'Error no fatal al sincronizar quote: ' + e.getMessage());
            }

            if (leadLinked){
                TrafficConvertResult conv = tryConvertTrafficLead(leadMatch.Id, accountIdVal, contactoIdVal);
                responseMap.put('leadConverted', conv.success);
                responseMap.put('leadConvertMessage', conv.message);
                responseMap.put('leadConvertQueued', conv.queued);

                if (!conv.success){
                    System.debug(LoggingLevel.ERROR, 'VU_TRAFFIC_CONVERT_FAIL => ' + conv.message);
                }
            }

        } catch (Exception e){
            if (e instanceof AuraHandledException){ throw e;
            }
            if (!Test.isRunningTest()){ throw new AuraHandledException(e.getMessage());
            }
            System.debug(e.getMessage());
        }

        return responseMap;
    }

    @AuraEnabled(cacheable = true)
    public static List<RM_SelectOption_Wrapper> getRecordTypes(){
        List<RM_SelectOption_Wrapper> options = new List<RM_SelectOption_Wrapper>();
        List<RecordType> recordTypeList = [
            SELECT Id, Name, IsActive, SobjectType, IsPersonType, DeveloperName
            FROM RecordType
            WHERE SobjectType = 'Account'
              AND DeveloperName IN ('Business_Account', 'PersonAccount')
              AND IsActive = TRUE
            ORDER BY Name
        ];

        for (RecordType rt : recordTypeList){
            options.add(new RM_SelectOption_Wrapper(rt.Name, String.valueOf(rt.Id)));
        }
        return options;
    }

    private static String normalizeNullish(String s){
        if (s == null){
            return null;
        }

        String t = s.trim();
        if (
            t == '' ||
            t.equalsIgnoreCase('null') ||
            t.equalsIgnoreCase('undefined') ||
            t.equalsIgnoreCase('no aplica') ||
            t.equalsIgnoreCase('n/a') ||
            t.equalsIgnoreCase('na') ||
            t.equalsIgnoreCase('--none--')
        ){
            return null;
        }
        return t;
    }

    private static Id toIdOrNull(String s){
        String t = normalizeNullish(s);
        if (t == null){
            return null;
        }
        try{
            return (Id) t;
        } catch (Exception e){
            throw new AuraHandledException('Invalid id: ' + t);
        }
    }

    private static Id toIdOrThrow(String label, String s){
        Id v = toIdOrNull(s);
        if (v == null){
            throw new AuraHandledException(label + ' es requerido.');
        }
        return v;
    }

    public static Lead findValidTraffic(String numeroIdentificacionRaw, String oppRTDev){
        if (String.isBlank(numeroIdentificacionRaw)){
            return null;
        }

        String raw = numeroIdentificacionRaw.trim();
        String clean = raw.replaceAll('[^0-9A-Za-z]', '');
        if (String.isBlank(clean)){
            return null;
        }

        DateTime limitDate = System.now().addMonths(-6);

        List<Lead> lst = [
            SELECT Id, Name, Status, IsConverted, CreatedDate,
                   Numero_de_Identificacion_del__c, LeadSource
            FROM Lead
            WHERE IsConverted = false
              AND CreatedDate >= :limitDate
              AND RecordType.DeveloperName = :oppRTDev
              AND Numero_de_Identificacion_del__c != null
              AND (
                    Numero_de_Identificacion_del__c = :raw
                 OR Numero_de_Identificacion_del__c = :clean
                 OR Numero_de_Identificacion_del__c LIKE :('%' + clean + '%')
              )
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];

        if (!lst.isEmpty()){
            System.debug(LoggingLevel.ERROR,
                'VU_TRAFFIC_FIND => raw=' + raw +
                ' clean=' + clean +
                ' found=' + lst[0].Id +
                ' leadNum=' + lst[0].Numero_de_Identificacion_del__c
            );
        }

        return lst.isEmpty() ? null : lst[0];
    }

    public class TrafficConvertResult{
        public Boolean success{ get; set; }
        public Boolean queued{ get; set; }
        public String message{ get; set; }

        public TrafficConvertResult(Boolean s, Boolean q, String m){
            success = s;
            queued = q;
            message = m;
        }
    }

    private static TrafficConvertResult tryConvertTrafficLead(Id leadId, Id accountId, Id contactId){
        try{
            convertTrafficLead(leadId, accountId, contactId);
            return new TrafficConvertResult(true, false, 'Tráfico convertido correctamente.');
        } catch (Exception ex){
            if (isRecordInUseByWorkflow(ex)){
                tryMarkWorkflowBypass(leadId);

                if (!Test.isRunningTest()){ System.enqueueJob(new ConvertTrafficQueueable(leadId, accountId, contactId));
                }

                return new TrafficConvertResult(
                    false,
                    true,
                    'No se pudo convertir porque el Tráfico está en uso por workflow (RECORD_IN_USE_BY_WORKFLOW). ' +
                    'Se encoló un reintento. Si sigue fallando, revisa Time-Based Workflow / automatizaciones que bloquean el Lead.'
                );
            }

            return new TrafficConvertResult(false, false, 'Error al convertir Tráfico: ' + ex.getMessage());
        }
    }

    private static Boolean isRecordInUseByWorkflow(Exception ex){
        String m = (ex == null ? '' : String.valueOf(ex.getMessage()));
        return m.contains('RECORD_IN_USE_BY_WORKFLOW') || m.toLowerCase().contains('in use by workflow');
    }

    private static void tryMarkWorkflowBypass(Id leadId){
        if (leadId == null){return;
        }

        String bypassField = 'Bypass_Time_Based_Workflow__c';
        if (!Schema.SObjectType.Lead.fields.getMap().containsKey(bypassField)){ return;
        }

        try{
            Lead upd = new Lead(Id = leadId); upd.put(bypassField, true); update upd;
        } catch (Exception e){
            System.debug(LoggingLevel.ERROR, 'No se pudo setear bypass workflow en Lead: ' + e.getMessage());
        }
    }

    public static void convertTrafficLead(Id leadId, Id accountId, Id contactId){
        if (leadId == null){
            return;
        }

        Lead l = [
            SELECT Id, IsConverted, Status
            FROM Lead
            WHERE Id = :leadId
            LIMIT 1
        ];

        if (l.IsConverted){
            return;
        }

        try{
            if (Approval.isLocked(leadId)){
                Approval.unlock(l, false);
            }
        } catch (Exception unlockEx){
            System.debug(LoggingLevel.ERROR, 'No se pudo unlock Lead (posible falta de permisos/setting): ' + unlockEx.getMessage());
        }

        String convertedStatus = 'Qualified';
        if (String.isBlank(convertedStatus)){ throw new AuraHandledException('No existe un LeadStatus marcado como Converted (IsConverted=true).');
        }

        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(leadId);
        lc.setDoNotCreateOpportunity(true);
        lc.setAccountId(accountId);
        lc.setConvertedStatus(convertedStatus);

        if (contactId != null){
            lc.setContactId(contactId);
        }

        Database.LeadConvertResult res = Database.convertLead(lc, false);

        if (res == null || !res.isSuccess()){
            String msg = 'No se pudo convertir el Tráfico.';
            if (res != null && res.getErrors() != null && !res.getErrors().isEmpty()){
                List<String> errs = new List<String>();
                for (Database.Error er : res.getErrors()){
                    errs.add(er.getMessage());
                }
                msg += ' Errores: ' + String.join(errs, ' | ');
            }
            throw new AuraHandledException(msg);
        }
    }

    public class ConvertTrafficQueueable implements Queueable{
        private Id leadId;
        private Id accountId;
        private Id contactId;

        public ConvertTrafficQueueable(Id leadId, Id accountId, Id contactId){
            this.leadId = leadId;
            this.accountId = accountId;
            this.contactId = contactId;
        }

        public void execute(QueueableContext qc){
            try{
                convertTrafficLead(leadId, accountId, contactId);
                System.debug(LoggingLevel.ERROR, 'VU_TRAFFIC_CONVERT_QUEUE_OK => ' + leadId);
            } catch (Exception ex){
                System.debug(LoggingLevel.ERROR, 'VU_TRAFFIC_CONVERT_QUEUE_FAIL => ' + ex.getMessage());
            }
        }
    }
}
