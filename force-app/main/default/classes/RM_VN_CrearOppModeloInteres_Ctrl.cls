public with sharing class RM_VN_CrearOppModeloInteres_Ctrl {

    @AuraEnabled
    public static List<Account> validarCuenta (String cuentaId){
        List<Account> lstAcc = [
            SELECT Id, FirstName, LastName, Name, Phone, PersonEmail, IsPersonAccount,
                   CorreoElectronicoEmpresarial__c, PersonContactId, Invoice_Email__c
            FROM Account
            WHERE Id =: cuentaId
        ];
        return lstAcc;
    }

    @AuraEnabled
    public static List<Account> crearCuenta (String cuentaId, String nombre, String apellido, String telefono, String email, String emailFact){

        List<Account> lstAcc = [
            SELECT Id, FirstName, Invoice_Email__c, LastName, Name, Phone, PersonEmail,
                   IsPersonAccount, CorreoElectronicoEmpresarial__c
            FROM Account
            WHERE Id =: cuentaId
        ];
        for(Account cuenta : lstAcc){
            if(cuenta.IsPersonAccount == true){
                cuenta.FirstName = nombre;
                cuenta.PersonEmail = email;
                cuenta.LastName = apellido;
            }else{
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
    public static Map<String,Object> createOpportunity(
        String contactoId,
        String brand,
        String familly,
        String year,
        String accountId,
        String productFantasiaId,
        String priceBookEntryId,
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
        String numeroIdentificacion,
        String tipoIdentificacion
    ){
        Map<String,Object> result = new Map<String,Object>();

        // Si ya no viene desde UI, tomarlo desde la Cuenta seleccionada
        
        



        if (String.isBlank(brand)) {
            throw new AuraHandledException('Debe ingresar marca');
        }
        if (String.isBlank(familly)) {
            throw new AuraHandledException('Debe ingresar la familia');
        }
        if (String.isBlank(year)) {
            throw new AuraHandledException('Debe ingrsar el año');
        }
        if (String.isBlank(accountId)) {
            throw new AuraHandledException('Debe seleccionar una cuenta');
        }
        if (String.isBlank(productFantasiaId)) {
            throw new AuraHandledException('Debe seleccionar un modelo de interés');
        }
        if (String.isBlank(priceBookEntryId)) {
            throw new AuraHandledException('Debe seleccionar un precio para el modelo de interés');
        }
        Account acc = [
        SELECT Id, Cedula__c
        FROM Account
        WHERE Id = :accountId
        LIMIT 1
    ];
        numeroIdentificacion = acc.Cedula__c;
        // Traer cuenta (necesitamos IsPersonAccount para setear __pc)
        List<Account> accountList = [
            SELECT Id, Name, IsPersonAccount
            FROM Account
            WHERE Id =: accountId
        ];
        if (accountList.isEmpty()) {
            throw new AuraHandledException('No se encontró la cuenta');
        }
        Account account = accountList[0];

        // ✅ Actualiza identificación en la cuenta ANTES de crear la oportunidad
        
        // =====================
        // Guardar identificación en Account (bloque original)
        // =====================
        Account accUpd = new Account(Id = account.Id);

        

        // ✅ Buscar tráfico por identificación
        Lead trafico = null;
        if (String.isNotBlank(numeroIdentificacion)) {
            trafico = findValidTraffic(numeroIdentificacion);
        }

        // Producto + pricebookentry
        List<Product2> productList = [
            SELECT Id, Name, Marca__c, Familia__c, Modelo_De_Inter_s__c,
                (SELECT Id, Pricebook2Id, UnitPrice, Costo_Fijo__c, Gerente__c, Vendedor__c, Jefe__c, CurrencyIsoCode
                 FROM PricebookEntries
                 WHERE Id =: priceBookEntryId)
            FROM Product2
            WHERE Id =: productFantasiaId
        ];
        if (productList.isEmpty()) {
            throw new AuraHandledException('No se encontró el modelo de interés');
        }

        if (String.isBlank(familly)) {
            if (String.isNotBlank(productList[0].Familia__c)) {
                familly = productList[0].Familia__c;
            }
        }

        Product2 product = productList[0];
        if (product.PricebookEntries.isEmpty()) {
            throw new AuraHandledException('No se encontró el precio del modelo de interés');
        }

        List<RecordType> recordTypeList = [
            SELECT Id
            FROM RecordType
            WHERE SobjectType = 'Opportunity'
            AND DeveloperName = :brand.toUpperCase()
            AND IsActive = true
        ];
        if (recordTypeList.isEmpty()) {
            throw new AuraHandledException('No se encontró el tipo de oportunidad para la marca del modelo de interés');
        }
        RecordType recordType = recordTypeList[0];
        PricebookEntry pbe = product.PricebookEntries[0];

        // Sucursal por usuario
        String sucursal = '';
        Id userId = UserInfo.getUserId();
        List<User> lstUser = [SELECT Id, Sucursal__c FROM User WHERE Id =: userId AND Sucursal__c != null];
        if (!lstUser.isEmpty() && String.isNotBlank(lstUser[0].Sucursal__c)) {
            sucursal = lstUser[0].Sucursal__c;
        }

        // Crear Opportunity
        Opportunity opp = new Opportunity();
        opp.Name = account.Name + ' - ' + brand + '-' + familly + '-' + year + '-' + System.now().format('dd/MM/yyyy HH:mm');
        opp.AccountId = account.Id;
        opp.Sucursal__c = sucursal;
        opp.StageName = 'Interesado';
        opp.CloseDate = Date.today().addDays(30);
        opp.Pricebook2Id = pbe.Pricebook2Id;
        opp.RecordTypeId = recordType.Id;
        opp.Familia__c = familly;

        opp.contacto__c = contactoId;
        opp.LeadSource = strLeadSource;

        opp.RealizaTestDrivePicklist__c = realizaTestDrive;
        opp.Realiza_Test_Drive__c = (String.isNotBlank(realizaTestDrive) && realizaTestDrive == 'Si');

        opp.Tipo_de_Cliente__c = strTipoDeCliente;
        opp.Departamento__c = strDepartamento;
        opp.Cuenta_de_Facturaci_n__c = strCuentaFacturacion;
        opp.aniodelvehiculo__c = strAniodelvehiculo;
        opp.Tipo_de_Uso_del_Veh_culo__c = tipoDeUso;
        opp.Fecha_Posible_Compra__c = fechaPosibleCompra;
        opp.Forma_de_Pago__c = formaDePago;
        opp.Plazo_en_Meses__c = plazoEnMeses;
        opp.Prima__c = prima;
        opp.Entidad__c = entidad;

        opp.CurrencyIsoCode = pbe.CurrencyIsoCode;

        // ✅ Setear lookup de tráfico en la Opp (trafico__c o equivalente)
        if (trafico != null) {
        opp.trafico__c = trafico.Id;
        }

        insert opp;

        // ✅ Convertir Lead a "Convertido" (real conversion) y NO crear otra Opp
        if (trafico != null) {
            RM_VU_CrearOportunidad_Ctrl.convertTrafficLead(trafico.Id, accountId, contactoId);
        }

        // OpportunityLineItem
        OpportunityLineItem oppLineItem = new OpportunityLineItem();
        oppLineItem.OpportunityId = opp.Id;
        oppLineItem.PricebookEntryId = pbe.Id;
        oppLineItem.Quantity = 1;
        oppLineItem.UnitPrice = pbe.UnitPrice;
        insert oppLineItem;

        // Oportunidad_Producto_Interes__c
        Oportunidad_Producto_Interes__c oppProdInteres = new Oportunidad_Producto_Interes__c();
        oppProdInteres.PricebookEntryId__c = pbe.Id;
        oppProdInteres.Oportunidad__c = opp.Id;
        oppProdInteres.Marca__c = brand;
        oppProdInteres.Familia__c = familly;
        oppProdInteres.Anio__c = year;
        oppProdInteres.Modelo_Interes__c = product.Modelo_De_Inter_s__c;
        oppProdInteres.Producto__c = product.Id;
        oppProdInteres.Cantidad__c = 1;
        oppProdInteres.Costo_Fijo__c = pbe.Costo_Fijo__c;
        oppProdInteres.Precio_Unitario__c = pbe.UnitPrice;
        oppProdInteres.Gerente__c = pbe.Gerente__c;
        oppProdInteres.Vendedor__c = pbe.Vendedor__c;
        oppProdInteres.Jefe__c = pbe.Jefe__c;
        insert oppProdInteres;

        // Re-asegurar familia en Opportunity si llega vacía
        String familiActual = familly;
        List<Oportunidad_Producto_Interes__c> lstOppI = [
            SELECT Id, Familia__c
            FROM Oportunidad_Producto_Interes__c
            WHERE Oportunidad__c =: opp.Id AND Familia__c != null
            LIMIT 1
        ];
        if (!lstOppI.isEmpty() && String.isNotBlank(lstOppI[0].Familia__c)) {
            familiActual = lstOppI[0].Familia__c;
        }

        List<Opportunity> lstOppAct = [SELECT Id, Familia__c FROM Opportunity WHERE Id =: opp.Id];
        if (!lstOppAct.isEmpty()) {
            if (String.isBlank(lstOppAct[0].Familia__c) && String.isNotBlank(familiActual)) {
                lstOppAct[0].Familia__c = familiActual;
                update lstOppAct;
            }
        }

        result.put('opportunityId', opp.Id);
        return result;
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
            )
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];

        return lst.isEmpty() ? null : lst[0];
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
        } catch (Exception e) {
            // si no se puede convertir por permisos/reglas, hacemos fallback abajo
        }

        if (!converted && String.isNotBlank(convertedStatus)) {
            try {
                update new Lead(Id = leadId, Status = convertedStatus);
            } catch (Exception e2) {
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