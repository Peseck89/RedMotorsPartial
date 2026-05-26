public with sharing class walkingCommunityControllerBase {

    public static List<AggregateResult> getFamilia(String marca) {
        return [SELECT Marca__c, Grupo__c
                FROM Product2
                WHERE walking_product__c = true
                AND Marca__c = :marca
                AND Grupo__c != null
                GROUP BY Marca__c, Grupo__c 
                ORDER BY Grupo__c];
    }

    public static List<Product2> getVehiculos(String familia, String marca) {
        return [SELECT Modelo_De_Inter_s__c, Familia__c
                FROM Product2
                WHERE Grupo__c = :familia
                AND walking_product__c = true
                AND Marca__c = :marca
                ORDER BY Orden_Walking__c];
    }

    public static void createOportunidad(String leadId) {
        System.debug('=== INICIO createOportunidad - leadId: ' + leadId);

        // 1. Obtener el Lead (tráfico)
        Lead trafico = [
            SELECT Id, FirstName, LastName, Email, MobilePhone, Phone,
                Marca__c, Familia1__c, Modelo_De_Inter_s1__c,
                Numero_de_Identificacion_del__c, Sucursal__c,
                FechaPosibleCompra__c, RecordTypeId, RecordType.Name,
                LeadSource, Action__c, Campana__c, Campa_aNew__c,
                Fuente__c, Medio__c, Ano1__c, CreatedDate,
                Codigo_de_producto__c, CodigoProducto__c,
                Tipo_de_Identificaci_n__c, Convertido_custom__c
            FROM Lead
            WHERE Id = :leadId
            LIMIT 1
        ];

        if (trafico.Convertido_custom__c == true) {
            System.debug('=== Lead ya está convertido, saliendo');
            return;
        }

        // 2. Obtener RecordType de Opportunity (mismo nombre que el del Lead)
        String rtName = trafico.RecordType.Name;
        List<RecordType> rtOpp = [
            SELECT Id FROM RecordType
            WHERE Name = :rtName AND SobjectType = 'Opportunity'
            LIMIT 1
        ];
        String oppRecordTypeId = !rtOpp.isEmpty() ? rtOpp[0].Id : null;

        System.debug('=== RT Opportunity: ' + oppRecordTypeId + ' (' + rtName + ')');

        // 3. Buscar Account existente por cédula
        String cedula = trafico.Numero_de_Identificacion_del__c;
        Account cuentaExistente = null;

        if (String.isNotBlank(cedula)) {
            List<Account> lstCuenta = [
                SELECT Id, IsPersonAccount, PersonEmail, FirstName, LastName
                FROM Account
                WHERE Cedula__c = :cedula
                LIMIT 1
            ];
            if (!lstCuenta.isEmpty()) {
                cuentaExistente = lstCuenta[0];
            }
        }

        System.debug('=== Cuenta existente: ' + cuentaExistente);

        // 4. Si no existe cuenta, crear Person Account
        if (cuentaExistente == null) {
            RecordType rtPersonAccount = [
                SELECT Id FROM RecordType
                WHERE SobjectType = 'Account' AND DeveloperName = 'PersonAccount'
                LIMIT 1
            ];

            Account nuevaCuenta = new Account();
            nuevaCuenta.RecordTypeId = rtPersonAccount.Id;
            nuevaCuenta.FirstName = trafico.FirstName;
            nuevaCuenta.LastName = trafico.LastName;
            nuevaCuenta.PersonEmail = trafico.Email;
            nuevaCuenta.Phone = trafico.Phone;
            nuevaCuenta.Cedula__c = cedula;

            // Asignar tipo de documento según longitud de cédula
            if (String.isNotBlank(cedula)) {
                if (cedula.length() == 9) {
                    nuevaCuenta.Tipo_de_Documento__c = '01'; // Personal
                } else if (cedula.length() == 12) {
                    nuevaCuenta.Tipo_de_Documento__c = '03'; // DIMEX
                } else {
                    nuevaCuenta.Tipo_de_Documento__c = '04'; // NITE
                }
            }

            insert nuevaCuenta;
            cuentaExistente = [SELECT Id, IsPersonAccount, PersonEmail FROM Account WHERE Id = :nuevaCuenta.Id];
            System.debug('=== Cuenta creada: ' + cuentaExistente.Id);
        }

        // 5. Buscar o crear Contact (para Person Accounts buscar por email)
        String contactoId = null;
        if (cuentaExistente.IsPersonAccount) {
            List<Contact> lstContact = [
                SELECT Id FROM Contact
                WHERE Email = :cuentaExistente.PersonEmail
                LIMIT 1
            ];
            if (lstContact.isEmpty()) {
                // Para Person Accounts el Contact se crea automáticamente,
                // pero si no se encuentra, buscamos por AccountId
                lstContact = [
                    SELECT Id FROM Contact
                    WHERE AccountId = :cuentaExistente.Id
                    LIMIT 1
                ];
            }
            if (!lstContact.isEmpty()) {
                contactoId = lstContact[0].Id;
            }
        }

        // 6. Obtener currency del PriceBookEntry si hay código de producto
        String currencyCode = null;
        String nombreProducto = null;

        if (String.isNotBlank(trafico.Codigo_de_producto__c)) {
            List<PricebookEntry> lstPBE = [
                SELECT CurrencyIsoCode, Product2.Name
                FROM PricebookEntry
                WHERE Id = :trafico.Codigo_de_producto__c
                LIMIT 1
            ];
            if (!lstPBE.isEmpty()) {
                currencyCode = lstPBE[0].CurrencyIsoCode;
                nombreProducto = lstPBE[0].Product2.Name;
            }
        } else if (String.isNotBlank(trafico.CodigoProducto__c)) {
            nombreProducto = trafico.CodigoProducto__c;
        }

        // 7. Crear la Opportunity
        Opportunity nuevaOpp = new Opportunity();
        nuevaOpp.AccountId = cuentaExistente.Id;
        nuevaOpp.StageName = 'Oportunidad Calificada';
        nuevaOpp.CloseDate = Date.today().addDays(57);
        nuevaOpp.Tipo_de_Cliente__c = 'Conquista';
        nuevaOpp.LeadSource = trafico.LeadSource;
        nuevaOpp.aniodelvehiculo__c = trafico.Ano1__c;
        nuevaOpp.CampaignId = trafico.Campana__c;
        nuevaOpp.Campana__c = trafico.Campana__c;
        nuevaOpp.Familia__c = trafico.Familia1__c;
        nuevaOpp.FechaDeIngreso__c = Date.valueOf(trafico.CreatedDate);
        nuevaOpp.FechaDeConversion__c = Date.today();
        nuevaOpp.ModeloDeInteresOriginal__c = trafico.Modelo_De_Inter_s1__c;
        nuevaOpp.Sucursal__c = trafico.Sucursal__c;
        nuevaOpp.Fecha_Posible_Compra__c = trafico.FechaPosibleCompra__c;
        nuevaOpp.Acci_n__c = trafico.Action__c;
        nuevaOpp.Fuente__c = trafico.Fuente__c;
        nuevaOpp.Medio__c = trafico.Medio__c;
        nuevaOpp.Campa_aNew__c = trafico.Campa_aNew__c;
        nuevaOpp.Trafico__c = trafico.Id;

        if (oppRecordTypeId != null) {
            nuevaOpp.RecordTypeId = oppRecordTypeId;
        }
        if (contactoId != null) {
            nuevaOpp.contacto__c = contactoId;
        }
        if (currencyCode != null) {
            nuevaOpp.CurrencyIsoCode = currencyCode;
        }
        if (nombreProducto != null) {
            nuevaOpp.NombreProducto__c = nombreProducto;
        }

        insert nuevaOpp;
        System.debug('=== Opportunity creada: ' + nuevaOpp.Id);

        // 8. Vincular registros WalkIn a la Opportunity
        List<Registro_WalkIn__c> walkIns = [
            SELECT Id, Opportunity__c
            FROM Registro_WalkIn__c
            WHERE Trafico__c = :trafico.Id
        ];
        if (!walkIns.isEmpty()) {
            for (Registro_WalkIn__c w : walkIns) {
                w.Opportunity__c = nuevaOpp.Id;
            }
            update walkIns;
        }

        // 9. Transferir OLIs y OPIs (misma invocable que usa el Flow)
        // CORRECTO - usar la clase wrapper del InvocableMethod
        RM_TransferirProductoInteres.inputTransferirProductoInteres input = new RM_TransferirProductoInteres.inputTransferirProductoInteres();
        input.leadId = trafico.Id;
        input.oppId = nuevaOpp.Id;
        RM_TransferirProductoInteres.transferirProductoInteres(new List<RM_TransferirProductoInteres.inputTransferirProductoInteres>{ input });
                // 10. Marcar Lead como convertido custom
        trafico.Convertido_custom__c = true;
        trafico.Status = 'Qualified';
        update trafico;

        // 11. Mover Tasks del Lead a la Opportunity
        List<Task> tasks = [
            SELECT Id, WhatId, WhoId
            FROM Task
            WHERE WhoId = :trafico.Id
        ];
        if (!tasks.isEmpty()) {
            for (Task t : tasks) {
                t.WhatId = nuevaOpp.Id;
                t.WhoId = null;
            }
            update tasks;
        }

        System.debug('=== FIN createOportunidad ===');
    }

    public static List<Cita_trafico_online__c> buscarCitaPorCedula(String cedula) {
        if (String.isBlank(cedula)) {
            return new List<Cita_trafico_online__c>();
        }

        List<Cita_trafico_online__c> citas = [
            SELECT Id, Name, Nombre__c, Modelo__c, Inicio__c, Sucursal__c, Cedula__c, Status__c
            FROM Cita_trafico_online__c
            WHERE Cedula__c = :cedula
            AND Status__c = 'Agendada'
            ORDER BY Inicio__c DESC
        ];

        return citas;
    }
}
