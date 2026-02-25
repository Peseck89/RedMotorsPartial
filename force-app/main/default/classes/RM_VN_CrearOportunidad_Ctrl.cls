public with sharing class RM_VN_CrearOportunidad_Ctrl {

    static final Integer PAGE_SIZE = 50;

    public class RM_VN_SelectedItem_Wrapper {

        @AuraEnabled
        public String prodXBodId { get; set; }

        @AuraEnabled
        public String pbeFantasiaId { get; set; }

        @AuraEnabled
        public String pbeBararianId { get; set; }

        @AuraEnabled
        public String pbeSoftlandId { get; set; }
    }

    @AuraEnabled
    public static List<Account> validarCuenta(String cuentaId) {
        List<Account> lstAcc = [
            SELECT Id, FirstName, LastName, Name, Phone, PersonEmail, IsPersonAccount,
                   CorreoElectronicoEmpresarial__c, PersonContactId, Invoice_Email__c
            FROM Account
            WHERE Id = :cuentaId
        ];
        return lstAcc;
    }

    @AuraEnabled
    public static List<Account> crearCuenta(String cuentaId, String nombre, String apellido, String telefono, String email, String emailFact) {

        List<Account> lstAcc = [
            SELECT Id, FirstName, Invoice_Email__c, LastName, Name, Phone, PersonEmail, IsPersonAccount, CorreoElectronicoEmpresarial__c
            FROM Account
            WHERE Id = :cuentaId
        ];

        for (Account cuenta : lstAcc) {
            if (cuenta.IsPersonAccount == true) {
                cuenta.FirstName = nombre;
                cuenta.PersonEmail = email;
                cuenta.LastName = apellido;
            } else {
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
    public static Map<String, Object> createOpportunity(
        String contactoId,
        String accountId,
        List<RM_VN_SelectedItem_Wrapper> items,
        String brand,
        String year,
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
        String entidad,
        String numeroIdentificacion
    ) {
        Map<String, Object> responseMap = new Map<String, Object>{};

        // === NUEVA LÓGICA: tomar identificación desde la Cuenta (prioridad: cuenta de facturación) ===
        Id cuentaIdBusqueda;

        // Prioridad: Cuenta de Facturación (como pidió Luis)
        if (!String.isBlank(strCuentaFacturacion)) {
        try { cuentaIdBusqueda = (Id) strCuentaFacturacion; } catch (Exception e) { /* ignore */ }
}
        // Fallback: Cuenta principal
        if (cuentaIdBusqueda == null && !String.isBlank(accountId)) {
        try { cuentaIdBusqueda = (Id) accountId; } catch (Exception e) { /* ignore */ }
}

        // Si el UI ya no manda numeroIdentificacion, tomarlo desde la cuenta
        if (String.isBlank(numeroIdentificacion) && cuentaIdBusqueda != null)   {
                Account acc = [
                SELECT Id, Cedula__c, cedulaIdentificacionIntellect__c
                FROM Account
                WHERE Id = :cuentaIdBusqueda
                LIMIT 1
            ];

                numeroIdentificacion = acc.Cedula__c;
        }

        // Debug para confirmar qué está usando
        System.debug('>>> cuentaIdBusqueda=' + cuentaIdBusqueda + ' numeroIdentificacion=' + numeroIdentificacion);

        if (String.isBlank(accountId)) {
            throw new AuraHandledException('La cuenta es requerida.');
        }

        List<Account> accountList = [
            SELECT Id, Name, IsPersonAccount, Cedula__c, Cedula__pc, Tipo_de_Documento__pc
            FROM Account
            WHERE Id = :accountId
        ];
        if (accountList.isEmpty()) {
            throw new AuraHandledException('La cuenta ingresada no existe.');
        }

        if (String.isBlank(brand)) {
            throw new AuraHandledException('La marca es requerida.');
        }

        if (String.isBlank(year)) {
            throw new AuraHandledException('El año es requerido.');
        }

        if (items == null || items.isEmpty()) {
            throw new AuraHandledException('Se requiere al menos un vehiculo.');
        }

        Id softlandPBId = RM_VN_Service.getSoftlandPriceBookId(brand, year);
        if (softlandPBId == null) {
            throw new AuraHandledException('Favor de revisar la configuración de la lista de precio en Configuración de Ventas.');
        }

        Set<String> prodXBodIds = new Set<String>();
        Set<Id> pbeIds = new Set<Id>();
        for (RM_VN_SelectedItem_Wrapper selectedItem : items) {
            prodXBodIds.add(selectedItem.prodXBodId);
            pbeIds.add(selectedItem.pbeFantasiaId);
        }

        Map<String, ProductoXBodega__c> prodXBodMap = new Map<String, ProductoXBodega__c>([
            SELECT Id, Producto__c, Producto__r.Name, Bodega__c, Producto__r.ProductCode, Producto__r.Anno__c,
                   Producto__r.marcaVehiculo__c, Producto__r.modelo__c, Producto__r.Color__c, Producto__r.Color_Externo__c,
                   Producto__r.vin__c, Producto__r.Familia__c
            FROM ProductoXBodega__c
            WHERE Id IN :prodXBodIds
              AND (Producto__r.esVehiculo__c = TRUE OR Producto__r.es_Vehiculo_en_transito__c = TRUE)
              AND Producto__r.Producto_Reservado__c = false
              AND Disponible__c > 0
              AND Bodega__c != null
        ]);

        if (prodXBodMap.keySet().isEmpty()) {
            throw new AuraHandledException('Los registro de producto por bodega no fueron encontrados.');
        }

        if (items.size() != prodXBodMap.keySet().size()) {
            throw new AuraHandledException('Favor de validar, alguno de los vehiculos de inventario ya no estan disponibles.');
        }

        Map<String, PricebookEntry> pbeFantasiaMap = new Map<String, PricebookEntry>([
            SELECT Id, UnitPrice, Costo_Fijo__c, Pricebook2.Name, Product2.Name, Product2Id, Pricebook2Id, Jefe__c, Vendedor__c, Gerente__c
            FROM PricebookEntry
            WHERE Id IN :pbeIds
              AND IsActive = TRUE
              AND Pricebook2.IsActive = TRUE
              AND Product2.IsActive = TRUE
        ]);

        String familiActual = '';
        for (PricebookEntry prodB : [
            SELECT Id, UnitPrice, Costo_Fijo__c, Pricebook2.Name, Product2.Familia__c, Product2.Name, Product2Id, Pricebook2Id, Jefe__c, Vendedor__c, Gerente__c
            FROM PricebookEntry
            WHERE Id IN :pbeIds
              AND IsActive = TRUE
              AND Pricebook2.IsActive = TRUE
              AND Product2.IsActive = TRUE
        ]) {
            if (prodB.Product2.Familia__c != null) {
                familiActual = prodB.Product2.Familia__c;
            }
        }

        if (pbeFantasiaMap.keySet().isEmpty()) {
            throw new AuraHandledException('Algunos de los precios de la lista de precios de fantasia ya no se encuentra disponible.');
        }

        if (items.size() != pbeFantasiaMap.keySet().size()) {
            throw new AuraHandledException('Favor de validar, alguno de las listas de precios ya no estan disponibles.');
        }

        String oppRTName = '%' + brand + '%';
        List<RecordType> oppRTList = [
            SELECT Id
            FROM RecordType
            WHERE SobjectType = 'Opportunity'
              AND DeveloperName LIKE :oppRTName
              AND IsActive = TRUE
            LIMIT 1
        ];
        if (oppRTList.isEmpty()) {
            throw new AuraHandledException('No se encontro record type en la oportunidad relacionado a la marca ingresada.');
        }

        if (strCuentaFacturacion == null || strCuentaFacturacion == '') {
            strCuentaFacturacion = accountId;
        }

        // =========================
        // Tráfico (Lead) por identificación
        // =========================
        System.debug(System.LoggingLevel.ERROR, 'MI_NUM_ID_RAW => ' + numeroIdentificacion);

        String cleanNum = String.isBlank(numeroIdentificacion)
            ? null
            : numeroIdentificacion.replaceAll('[^0-9A-Za-z]', '').trim();

        System.debug(System.LoggingLevel.ERROR, 'MI_NUM_ID_CLEAN => ' + cleanNum);

        Lead trafico = null;
        if (String.isNotBlank(numeroIdentificacion)) {
            trafico = findValidTraffic(numeroIdentificacion);
        }
 System.debug('Trafico => ' + trafico);
 System.debug('Cedula => ' + numeroIdentificacion);
        System.debug(System.LoggingLevel.ERROR, 'MI_TRAFICO => ' +
            (trafico == null ? 'NULL' :
                (trafico.Id + ' | Status=' + trafico.Status + ' | IsConverted=' + trafico.IsConverted + ' | Created=' + trafico.CreatedDate)));

        // =========================
        // Crear Opportunity
        // =========================
        
        String traficoId='';
        if (trafico != null)  {
        traficoId=trafico.Id;
        }
        Opportunity newOpp = new Opportunity(
            Name = 'Modelo de Interés - ' + brand + ' ' + year,
            AccountId = accountId,
            trafico__c = traficoId,
            Sucursal__c = getSucursalName(),
            Pricebook2Id = softlandPBId,
            StageName = 'Oportunidad Calificada',
            CloseDate = System.today(),
            Enganche_monto__c = 0,
            Enganche_recibo__c = 'test',
            RecordTypeId = oppRTList[0].Id,
            CurrencyIsoCode = 'USD',
            Familia__c = familiActual,
            contacto__c = contactoId,
            LeadSource = strLeadSource,
            Realiza_Test_Drive__c = (String.isNotBlank(realizaTestDrive) && realizaTestDrive == 'Si'),
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

        
        System.debug(System.LoggingLevel.ERROR, 'MI_BEFORE_INSERT_OPP');
        insert newOpp;

        // ✅ Convertir Lead a "Convertido" (real conversion) y NO crear otra Opp
        if (trafico != null) {
            RM_VU_CrearOportunidad_Ctrl.convertTrafficLead(trafico.Id, accountId, contactoId);
        }

        // Quote ORIGINAL del proceso (NO duplicamos)
        Quote newQuote = new Quote(
            Name = newOpp.Id,
            CurrencyIsoCode = 'USD',
            OpportunityId = newOpp.Id
        );
        insert newQuote;

        Map<String, Oportunidad_Producto_Interes__c> pbeIdOPIMap = crearOPIRecords(newOpp.Id, brand, year, pbeFantasiaMap.values());

        List<Oportunidad_Producto_Interes__c> lstOppI = [
            SELECT Id, Familia__c
            FROM Oportunidad_Producto_Interes__c
            WHERE Oportunidad__c = :newOpp.Id
              AND Familia__c != null
        ];
        if (lstOppI.size() > 0) {
            if (familiActual != null && familiActual != '') {
                familiActual = lstOppI[0].Familia__c;
            }
        }

        List<Opportunity> lstOppAct = [
            SELECT Id, Familia__c
            FROM Opportunity
            WHERE Id = :newOpp.Id
        ];
        if (lstOppAct.size() > 0) {
            if ((lstOppAct[0].Familia__c == null || lstOppAct[0].Familia__c == '') && familiActual != null) {
                lstOppAct[0].Familia__c = familiActual;
                update lstOppAct;
            }
        }

        List<QuoteLineItem> qliToInsert = new List<QuoteLineItem>();

        for (RM_VN_SelectedItem_Wrapper pxbItem : items) {
            ProductoXBodega__c prodXbod = prodXBodMap.get(pxbItem.prodXBodId);
            Oportunidad_Producto_Interes__c oppProdInt = pbeIdOPIMap.get(pxbItem.pbeFantasiaId);

            QuoteLineItem newQLI = new QuoteLineItem(
                QuoteId = newQuote.Id,
                Product2Id = prodXbod.Producto__c,
                Quantity = 1,
                BMW_Bodega__c = prodXbod.Bodega__c,
                PricebookEntryId = pxbItem.pbeSoftlandId,
                UnitPrice = oppProdInt.Precio_Unitario__c,
                Oportunidad_Producto_Interes__c = oppProdInt.Id,
                Comision_Vendedor__c = ((oppProdInt.Comision_Porcentaje_Vendedor__c != null && oppProdInt.Precio_Unitario__c != null) ? ((oppProdInt.Comision_Porcentaje_Vendedor__c * oppProdInt.Precio_Unitario__c) / 100) : 0),
                Comision_Jefe__c = ((oppProdInt.Comision_Porcentaje_Jefe__c != null && oppProdInt.Precio_Unitario__c != null) ? ((oppProdInt.Comision_Porcentaje_Jefe__c * oppProdInt.Precio_Unitario__c) / 100) : 0),
                Comision_Gerente__c = ((oppProdInt.Comision_Porcentaje_Gerente__c != null && oppProdInt.Precio_Unitario__c != null) ? ((oppProdInt.Comision_Porcentaje_Gerente__c * oppProdInt.Precio_Unitario__c) / 100) : 0)
            );

            qliToInsert.add(newQLI);
        }

        if (!qliToInsert.isEmpty()) {
            insert qliToInsert;
        }

        responseMap.put('opportunityId', newOpp.Id);
        responseMap.put('quoteId', newQuote.Id);

        Set<Id> quoteIds = new Set<Id>();
        quoteIds.add(newQuote.Id);
        RM_SyncQuoteService.syncQuote(quoteIds);

        return responseMap;
    }

    @AuraEnabled(cacheable=true)
    public static List<RM_SelectOption_Wrapper> getTipoGasolina() {
        List<RM_SelectOption_Wrapper> options = new List<RM_SelectOption_Wrapper>();
        options.add(new RM_SelectOption_Wrapper('Todos', 'All'));
        Schema.DescribeFieldResult fieldResult = Product2.combustible__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f : ple) {
            if (f.isActive()) {
                options.add(new RM_SelectOption_Wrapper(f.getLabel(), f.getValue()));
            }
        }
        return options;
    }

    @AuraEnabled(cacheable=true)
    public static List<RM_SelectOption_Wrapper> getRecordTypes() {
        List<RM_SelectOption_Wrapper> options = new List<RM_SelectOption_Wrapper>();
        List<RecordType> recordTypeList = [
            SELECT Id, Name, IsActive, SobjectType, IsPersonType, DeveloperName
            FROM RecordType
            WHERE SobjectType = 'Account'
              AND DeveloperName IN ('Business_Account','PersonAccount')
              AND IsActive = TRUE
            ORDER BY Name
        ];
        for (RecordType rt : recordTypeList) {
            options.add(new RM_SelectOption_Wrapper(rt.Name, rt.Id));
        }
        return options;
    }

    public static Map<String, Oportunidad_Producto_Interes__c> crearOPIRecords(String oppId, String brand, String year, List<PricebookEntry> pbeList) {
        Map<String, Oportunidad_Producto_Interes__c> newOPIMap = new Map<String, Oportunidad_Producto_Interes__c>();
        for (PricebookEntry pbe : pbeList) {
            newOPIMap.put(
                pbe.Id,
                new Oportunidad_Producto_Interes__c(
                    Oportunidad__c = oppId,
                    Producto__c = pbe.Product2Id,
                    Marca__c = brand.trim(),
                    Anio__c = year.trim(),
                    Modelo_Interes__c = pbe.Product2.Name,
                    Cantidad__c = 1,
                    Precio_Unitario__c = pbe.UnitPrice,
                    Costo_Fijo__c = pbe.Costo_Fijo__c,
                    Comision_Porcentaje_Jefe__c = pbe.Jefe__c,
                    Comision_Porcentaje_Gerente__c = pbe.Gerente__c,
                    Comision_Porcentaje_Vendedor__c = pbe.Vendedor__c,
                    PricebookEntryId__c = pbe.Id,
                    CurrencyIsoCode = 'USD'
                )
            );
        }

        if (!newOPIMap.isEmpty()) {
            insert newOPIMap.values();
        }
        return newOPIMap;
    }

    public static Id getSoftlandPriceBookId(String brand) {
        List<Configuracion_de_ventas__c> marcaListaPrecioList = [
            SELECT Id, RM_ListaPrecioSoftland__c, RM_ListaPrecioSoftland__r.Id, RM_ListaPrecioSoftland__r.Name, Marca__c
            FROM Configuracion_de_ventas__c
            WHERE Marca__c = :brand
              AND RM_ListaPrecioSoftland__c != null
              AND RM_ListaPrecioSoftland__r.IsActive = true
              AND RM_ListaPrecioSoftland__r.CurrencyIsoCode = 'USD'
            LIMIT 1
        ];
        if (marcaListaPrecioList.isEmpty()) {
            throw new AuraHandledException('No se encontro lista de precio  de Softland relacionada a la marca ingresada.');
        }
        return marcaListaPrecioList[0].RM_ListaPrecioSoftland__c;
    }

    public static String getSucursalName() {
        String sucursal = '';
        Id userId = UserInfo.getUserId();
        List<User> userList = [SELECT Id, Sucursal__c FROM User WHERE Id = :userId AND Sucursal__c != null];
        if (!userList.isEmpty()) {
            if (userList[0].Sucursal__c != '' && userList[0].Sucursal__c != null) {
                sucursal = userList[0].Sucursal__c;
            }
        }
        return sucursal;
    }

    public static void dummy() {
        String test = '';
        test += '';
    }

    // =========================
    // Helpers Tráfico
    // =========================
    private static Lead findValidTraffic(String numeroIdentificacionRaw) {
        if (String.isBlank(numeroIdentificacionRaw)) return null;

        String raw = numeroIdentificacionRaw.trim();
        String clean = raw.replaceAll('[^0-9A-Za-z]', '');

        List<Lead> lst = [
            SELECT Id, Name, FirstName, LastName, Phone, Email, Status, IsConverted, CreatedDate, Numero_de_Identificacion_del__c
            FROM Lead
            WHERE (
                Numero_de_Identificacion_del__c = :raw
                OR Numero_de_Identificacion_del__c = :clean
                        OR Numero_de_Identificacion_del__c = :numeroIdentificacionRaw
            )
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];

        return lst.isEmpty() ? null : lst[0];
    }

    private static void setTrafficLookup(Opportunity opp, Id leadId) {
        if (opp == null || leadId == null) return;

        List<String> candidates = new List<String>{
            'trafico__c',
            'traficolead__c',
            'traffic__c',
            'lead__c',
            'leadid__c'
        };

        Map<String, Schema.SObjectField> fields = Opportunity.SObjectType.getDescribe().fields.getMap();

        Map<String, String> lowerToReal = new Map<String, String>();
        for (String k : fields.keySet()) {
            lowerToReal.put(k.toLowerCase(), k);
        }

        for (String api : candidates) {
            String real = lowerToReal.get(api.toLowerCase());
            if (real != null) {
                opp.put(real, leadId);
                System.debug(System.LoggingLevel.ERROR, 'MI_SET_TRAFFIC_LOOKUP => ' + real + '=' + leadId);
                return;
            }
        }

        System.debug(System.LoggingLevel.ERROR, 'MI_NO_TRAFFIC_LOOKUP_FIELD_FOUND');
    }

    private static void putIfFieldExists(SObject record, String fieldApiName, Object value) {
        if (record == null || value == null || String.isBlank(fieldApiName)) return;

        Map<String, Schema.SObjectField> fields = record.getSObjectType().getDescribe().fields.getMap();
        if (fields.containsKey(fieldApiName)) {
            record.put(fieldApiName, value);
        }
    }

    // =========================
    // Helpers Conversión Lead
    // =========================
    private static void convertTrafficLead(Id leadId, String accountId, String contactoId) {
        if (leadId == null) return;

        Lead l = [SELECT Id, IsConverted, Status FROM Lead WHERE Id = :leadId LIMIT 1];
        if (l.IsConverted) return;

        String convertedStatus = getAnyConvertedLeadStatusValue();
        if (String.isBlank(convertedStatus)) {
            convertedStatus = findLeadStatusValue(new List<String>{ 'Convertido', 'Converted' });
        }

        Boolean converted = false;

        try {
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(leadId);
            lc.setDoNotCreateOpportunity(true);

            if (String.isNotBlank(accountId)) {
                lc.setAccountId((Id)accountId);
            }
            if (String.isNotBlank(contactoId)) {
                lc.setContactId((Id)contactoId);
            }
            if (String.isNotBlank(convertedStatus)) {
                lc.setConvertedStatus(convertedStatus);
            }

            Database.LeadConvertResult res = Database.convertLead(lc, false);
            converted = (res != null && res.isSuccess());

            if (!converted && res != null && res.getErrors() != null && !res.getErrors().isEmpty()) {
                System.debug(System.LoggingLevel.ERROR, 'MI_LEAD_CONVERT_ERROR => ' + res.getErrors()[0].getMessage());
            }
        } catch (Exception e) {
            System.debug(System.LoggingLevel.ERROR, 'MI_LEAD_CONVERT_EXCEPTION => ' + e.getMessage());
        }

        if (!converted && String.isNotBlank(convertedStatus)) {
            try {
                update new Lead(Id = leadId, Status = convertedStatus);
                System.debug(System.LoggingLevel.ERROR, 'MI_LEAD_STATUS_FALLBACK_OK => ' + leadId + ' | Status=' + convertedStatus);
            } catch (Exception e2) {
                System.debug(System.LoggingLevel.ERROR, 'MI_LEAD_STATUS_FALLBACK_EXCEPTION => ' + e2.getMessage());
            }
        }
    }

    private static String getAnyConvertedLeadStatusValue() {
        List<LeadStatus> ls = [
            SELECT MasterLabel, SortOrder
            FROM LeadStatus
            WHERE IsConverted = true
            ORDER BY SortOrder
            LIMIT 1
        ];
        return ls.isEmpty() ? null : ls[0].MasterLabel;
    }

    private static String findLeadStatusValue(List<String> candidates) {
        if (candidates == null || candidates.isEmpty()) return null;

        List<Schema.PicklistEntry> values = Lead.Status.getDescribe().getPicklistValues();

        for (String desired : candidates) {
            if (String.isBlank(desired)) continue;

            for (Schema.PicklistEntry pe : values) {
                String v = pe.getValue();
                String lb = pe.getLabel();
                if (v != null && v.equalsIgnoreCase(desired)) return v;
                if (lb != null && lb.equalsIgnoreCase(desired)) return pe.getValue();
            }
        }
        return null;
    }
}