public with sharing class cT_ChangeData_ctrl {
    @AuraEnabled()
    public static Account createAccount (String nombreCuenta,String apellido,String cedula,String telefono,String fechaNacimiento,String correoElectronico,String nombreEncargado,String telefonoEncargado,Boolean esEmpresarial) {
        return cT_ChangeDataBase.createAccount(nombreCuenta, apellido, cedula, telefono, fechaNacimiento, correoElectronico, nombreEncargado, telefonoEncargado, esEmpresarial);
    }
    @AuraEnabled()
    public static List<Account> updateAccount (String recordId, String cuentaId) {
        String contactRel = '';
        if(cuentaId != null){
            List<Contact> lstAcc = [Select Id From Contact where AccountId=:cuentaId ];
            if(lstAcc.size()>0){
                contactRel = lstAcc[0].id;
            }
        }

        if(recordId != null && recordId != 'undefined' && recordId !=''){
            List<Case> lstCase = new List<Case>();
            lstCase = [Select Id,AccountId,AssetId,COntactId,Cuenta_de_Facturacion__c
            From Case Where Id =:recordId  LIMIT 1 ];
            if(lstCase.size()>0){

                // String cocheId = lstCase[0].AssetId;

                for(Case coche : lstCase){
                    coche.AccountId = cuentaId;
                    // coche.Cuenta_de_Facturacion__c = cuentaId;
                    // if(contactRel != null && contactRel != ''){
                    //     coche.ContactId = contactRel;
                    // }                 
                }
                update lstCase;
                // List<WorkOrder> lstWo = [Select Id,AccountId,COntactId,Cuenta_de_Facturacion__c From WorkOrder Where CaseId =:recordId AND isLocked__c != true  ];
                // for(WorkOrder wo : lstWo){
                //     wo.AccountId = cuentaId;
                //     wo.Cuenta_de_Facturacion__c = cuentaId;
                //     if(contactRel != null && contactRel != ''){
                //         wo.ContactId = contactRel;
                //     }   
                // }
                // update lstWo;
                // List<Asset> lstAsset = [Select id,ContactId,AccountId From Asset Where Id =:cocheId  LIMIT 1];
                // for(Asset a : lstAsset){
                //     a.AccountId = cuentaId;
                //     if(contactRel != null && contactRel != ''){
                //         a.ContactId = contactRel;
                //         if(contactRel != null && contactRel != ''){
                //             a.ContactId = contactRel;
                //         }     
                //     }
                // }
                // update lstAsset;

            }else{
                List<WorkOrder> lstWo = new List<WorkOrder>();
                lstWo = [Select Id,AccountId,AssetId,ContactId,Cuenta_de_Facturacion__c 
                From WorkOrder Where Id =:recordId  LIMIT 1 ];
                if(lstWo.size()>0){
                    for(WorkOrder coche : lstWo){
                        coche.AccountId = cuentaId;
                        coche.Cuenta_de_Facturacion__c = cuentaId;
                        if(contactRel != null && contactRel != ''){
                            coche.ContactId = contactRel;
                        }  
                    }
                }                
                update lstWo;
                String cocheId = lstWo[0].AssetId;
                List<Asset> lstAsset = [Select id,ContactId,AccountId From Asset Where Id =:cocheId  LIMIT 1];
                for(Asset a : lstAsset){
                    a.AccountId = cuentaId;
                    if(contactRel != null && contactRel != ''){
                        a.ContactId = contactRel;
                    }     
                }
                update lstAsset;
            }                        
        }      
       
        
        
         List<Account> lstCuenta = [Select Id,Name,PersonEmail,CorreoElectronicoEmpresarial__c,Phone,codigoSoftland__c,Cedula__c From Account Where Id =:cuentaId ];
        return lstCuenta;
        
    }

    @AuraEnabled()
    public static List<Account> updateDataAccount (String cuentaId, String telCuenta, String identificacioCuenta, String correoCuenta) {
        List<Account> lstCuenta = [Select Id,Name,PersonEmail,CorreoElectronicoEmpresarial__c,Phone,codigoSoftland__c,Cedula__c,IsPersonAccount From Account Where Id =:cuentaId ];
        for(Account cuenta : lstCuenta){
            cuenta.Phone = telCuenta;
            cuenta.Cedula__c = identificacioCuenta;
            if(cuenta.IsPersonAccount == true){
                cuenta.PersonEmail = correoCuenta;
            }else{
                cuenta.CorreoElectronicoEmpresarial__c = correoCuenta;
            }
        }
        update lstCuenta;
        return lstCuenta;
    }

    @AuraEnabled()
    public static List<Contact> createContact (String recordId,String cuenta, String nombreContacto,String apellidoContacto,String telefonoContacto,String correoContacto) {
        List<Account> lstAcc = [Select Id From Account Where CorreoElectronicoEmpresarial__c = 'bavariancitas@testemail.com'];
        //crear contacto    
        Contact newContact = new Contact();  
        if(recordId != null && recordId != 'undefined' && recordId !=''){
            List<Case> lstCase = new List<Case>();
            lstCase = [Select Id,AccountId,Account.IsPersonAccount,AssetId,Asset.ContactId
            From Case Where Id =:recordId  LIMIT 1 ];
            if(lstCase.size()>0){
               
                if(lstCase[0].Account.IsPersonAccount == false){
                    newContact.Accountid = cuenta;
                }else{
                    newContact.Accountid = lstAcc[0].Id;
                }              

                newContact.FirstName = nombreContacto;
                newContact.LastName = apellidoContacto;
                newContact.Phone = telefonoContacto;
                newContact.Email = correoContacto;
                insert newContact;
                for(Case coche : lstCase){
                    coche.ContactId = newContact.id;
                    coche.Asset.ContactId = newContact.id;
                }
                update lstCase;
                List<WorkOrder> lstWo = new List<WorkOrder>();
                lstWo = [Select Id,AccountId,Account.IsPersonAccount,ContactId
                From WorkOrder Where CaseId =:recordId AND isLocked__c != true ];
                if(lstWo.size()>0){
                    for(WorkOrder woI : lstWo){
                        woI.ContactId = newContact.id;
                    }
                }
                update lstWo;
                List<Asset> lstAsset = [Select id,ContactId From Asset Where Id =:lstCase[0].AssetId  LIMIT 1];
                for(Asset a : lstAsset){
                    a.ContactId = newContact.id;
                }
                update lstAsset;
            }else{
                List<WorkOrder> lstWo = new List<WorkOrder>();
                lstWo = [Select Id,AccountId,Account.IsPersonAccount,case.ContactId,AssetId,Asset.ContactId
                From WorkOrder Where Id =:recordId  LIMIT 1 ];
                if(lstWo.size()>0){
                    if(lstWo[0].Account.IsPersonAccount == false){
                        newContact.Accountid = cuenta;
                    }else{
                        newContact.Accountid = lstAcc[0].Id;
                    }              

                    newContact.FirstName = nombreContacto;
                    newContact.LastName = apellidoContacto;
                    newContact.Phone = telefonoContacto;
                    newContact.Email = correoContacto;
                    insert newContact;
                    for(WorkOrder coche : lstWo){
                        coche.ContactId = newContact.id;
                        coche.case.ContactId = newContact.id;
                        coche.Asset.ContactId = newContact.id;
                    }
                }                
                update lstWo;
                //List<Case> lstCase = new List<Case>();
                lstCase = [Select Id,AccountId,ContactId
                From Case Where Id =:lstWo[0].CaseId ];  
                for(Case caso : lstCase){
                    caso.ContactId = newContact.id;
                }
                update lstCase;

                List<Asset> lstAsset = [Select id,ContactId From Asset Where Id =:lstWo[0].AssetId  LIMIT 1];
                for(Asset a : lstAsset){
                    a.ContactId = newContact.id;
                }
                update lstAsset;
            }                        
        } 

        List<Contact> lstContact = [Select Id,Name From Contact Where Id =:newContact.id ];
        return lstContact;
        
    }

    @AuraEnabled()
    public static List<Contact> updateContactData (String contactId,String nombreC, String apellidoC, String phoneC, String emailC, String cedulaCont) {
        List<Contact> lstContact = [Select Id,FirstName,LastName,Email,Phone,Cedula__c From Contact Where Id =:contactId ];

        for(Contact contacto : lstContact){
            contacto.FirstName = nombreC;
            contacto.LastName = apellidoC;
            contacto.Email = emailC;
            contacto.Phone = phoneC;
            //contacto.Cedula__c = cedulaCont;
        }

        update lstContact;
        return lstContact;
    }

    @AuraEnabled
    public static List<Contact> updateContactOtro(String recordId, String contactId) {
        if(recordId != null && recordId != 'undefined' && recordId !=''){
            List<Case> lstCase = new List<Case>();
            lstCase = [Select Id,AccountId,ContactId,AssetId
            From Case Where Id =:recordId  LIMIT 1 ];
            if(lstCase.size()>0){
                String cocheId = lstCase[0].AssetId;

                for(Case coche : lstCase){
                    coche.ContactId = contactId;
                }
                update lstCase;

                List<WorkOrder> lstWo = [Select Id,ContactId From WorkOrder Where CaseId =:recordId AND isLocked__c != true  ];
                for(WorkOrder wo : lstWo){
                    wo.ContactId = contactId;
                }
                update lstWo;
                
                List<Asset> lstAsset = [Select id,ContactId From Asset Where Id =:cocheId  LIMIT 1];
                for(Asset a : lstAsset){
                    a.ContactId = contactId;
                }
                update lstAsset;

            }else{
                List<WorkOrder> lstWo = new List<WorkOrder>();
                lstWo = [Select Id,AccountId,ContactId,CaseId,AssetId
                From WorkOrder Where Id =:recordId  LIMIT 1 ];

                String casoId = lstWo[0].CaseId;
                String cocheId = lstWo[0].AssetId;

                if(lstWo.size()>0){
                    for(WorkOrder coche : lstWo){
                        coche.ContactId = contactId;
                    }
                }        
                update lstWo;

                lstCase = [Select Id,AccountId,ContactId
                From Case Where Id =:casoId ];  
                for(Case caso : lstCase){
                    caso.ContactId = contactId;
                }
                update lstCase;

                List<Asset> lstAsset = [Select id,ContactId From Asset Where Id =:cocheId  LIMIT 1];
                for(Asset a : lstAsset){
                    a.ContactId = contactId;
                }
                update lstAsset;
            }                        
        }      
       
        List<Contact> lstContact = [Select Id,Name,Email,Phone From Contact Where Id =:contactId ];
        return lstContact;
        
    }

    @AuraEnabled
    public static List<Contact> updateContact(String recordId, String contactId) {
        if (recordId != null && recordId != 'undefined' && recordId != '') {
            // Variables para guardar la cuenta y contacto asociados al recordId
            Id accountId = null;
            Id contactIdFromRecord = null;
    
            // Intentar obtener el record como un Case
            List<Case> lstCase = [
                SELECT Id, AccountId, ContactId
                FROM Case
                WHERE Id = :recordId
                LIMIT 1
            ];
    
            if (!lstCase.isEmpty()) {
                accountId = lstCase[0].AccountId;
                contactIdFromRecord = lstCase[0].ContactId;
            } else {
                // Si no es un Case, intentamos obtenerlo como un WorkOrder
                List<WorkOrder> lstWo = [
                    SELECT Id, AccountId, ContactId
                    FROM WorkOrder
                    WHERE Id = :recordId
                    LIMIT 1
                ];
                if (!lstWo.isEmpty()) {
                    accountId = lstWo[0].AccountId;
                    contactIdFromRecord = lstWo[0].ContactId;
                }
            }
    
            // Si encontramos una cuenta asociada al recordId
            if (accountId != null) {
                Account acc = [
                    SELECT Id, Name, FirstName, LastName, IsPersonAccount, Phone, CorreoElectronicoEmpresarial__c,PersonEmail
                    FROM Account
                    WHERE Id = :accountId
                    LIMIT 1
                ];
    
                Contact contactToUpdate = [
                    SELECT Id, Name, FirstName, LastName, Email, Phone
                    FROM Contact
                    WHERE Id = :contactId
                    LIMIT 1
                ];
    
                if (acc.IsPersonAccount) {
                    // Si es una Person Account, actualizamos tanto los campos de la cuenta como del contacto
                    contactToUpdate.FirstName = acc.FirstName;
                    contactToUpdate.LastName = acc.LastName;
                    contactToUpdate.Email = acc.PersonEmail;
                    contactToUpdate.Phone = acc.Phone;
                } else {
                    // Si no es una Person Account, actualizamos solo los campos del contacto
                    if (acc.Name != null) {
                        contactToUpdate.FirstName = null;
                        contactToUpdate.LastName = acc.Name;
                    }
                    if (acc.Phone != null) {
                        contactToUpdate.Phone = acc.Phone;
                    }
                    if (acc.CorreoElectronicoEmpresarial__c != null) {
                        contactToUpdate.Email = acc.CorreoElectronicoEmpresarial__c;
                    }
                }
    
                // Guarda los cambios en el contacto
                update contactToUpdate;
            }
        }
        // Retornamos el contacto actualizado o sin cambios
        List<Contact> lstContact = [
            SELECT Id, Name, Email, Phone
            FROM Contact
            WHERE Id = :contactId
        ];
        return lstContact;
    }

    // Cambio de kilometraje y marcar check en caso
    @AuraEnabled
    public static void updateAssetkilometraje(Id assetId, Decimal kilometraje, Id caseId) {
        Asset assetRecord = [SELECT Id, Kilometros__c FROM Asset WHERE Id = :assetId LIMIT 1];
    
        Decimal kilometrajeActual = assetRecord.Kilometros__c != null ? assetRecord.Kilometros__c : 0;
        
        if (kilometraje <= kilometrajeActual) {
            throw new AuraHandledException('El Kilometraje no puede ser menor o igual al actual.');
        }
        
        assetRecord.Kilometros__c = kilometraje;
        update assetRecord;

        Case caso = [SELECT Id, Actualizo_Kilometraje__c, Kilometraje__c FROM Case WHERE Id = :caseId LIMIT 1];
        caso.Actualizo_Kilometraje__c = true;
        caso.Kilometraje__c = kilometraje;
        update caso;

        List<WorkOrder> workOrders = [SELECT Id, Kilometros__c FROM WorkOrder WHERE CaseId = :caseId];
        for (WorkOrder wo : workOrders) {
            wo.Kilometros__c = kilometraje;
        }
        if (!workOrders.isEmpty()) {
            update workOrders;
        }
    }

    // Validación multidioma para ver si el usuario logeado es admin
    @AuraEnabled(cacheable=true)
        public static Boolean isCurrentUserAdmin() {
        User currentUser = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
        String profileName = currentUser.Profile.Name;
        return profileName == 'System Administrator' 
           || profileName == 'Administrador del sistema';
    }

    // Trae el historial de kilometraje del asset relacionado
    @AuraEnabled(cacheable=true)
    public static List<Historial_Kilometraje__c> getHistorialVehiculo(String assetId) {
        try {
            return [SELECT UsuarioQueRealizaElCambio__r.Name, UltimoKilometraje__c, 
                           NuevoKilometraje__c, Name, Id, CreatedDate
                    FROM Historial_Kilometraje__c
                    WHERE Vehiculo__c = :assetId
                    ORDER BY CreatedDate DESC];
        } catch (Exception e) {
            throw new AuraHandledException('Error obteniendo historial: ' + e.getMessage());
        }
    }

    // Metodo original

    // @AuraEnabled
    // public static void updateKilometraje(String historialId, Decimal nuevoKm, Id assetId, Id caseId) {
    // Historial_Kilometraje__c historial = [
    //     SELECT Id, UltimoKilometraje__c 
    //     FROM Historial_Kilometraje__c 
    //     WHERE Id = :historialId
    // ];
        
    // if (nuevoKm < historial.UltimoKilometraje__c) {
    //     throw new AuraHandledException('El nuevo kilometraje no puede ser menor al anterior');
    // }
    
    // historial.NuevoKilometraje__c = nuevoKm;
    // update historial;

    // Case caso = [SELECT Id, Actualizo_Kilometraje__c, Kilometraje__c FROM Case WHERE Id = :caseId LIMIT 1];
    // caso.Actualizo_Kilometraje__c = true;
    // caso.Kilometraje__c = nuevoKm;
    // update caso;

    // Asset vehiculo = [SELECT Id, Kilometros__c FROM Asset WHERE Id = :assetId LIMIT 1];
    // vehiculo.Kilometros__c = nuevoKm;
    // update vehiculo;

    // List<WorkOrder> workOrders = [SELECT Id, Kilometros__c FROM WorkOrder WHERE CaseId = :caseId];
    //     for (WorkOrder wo : workOrders) {
    //         wo.Kilometros__c = nuevoKm;
    //     }
    //     if (!workOrders.isEmpty()) {
    //         update workOrders;
    //     }
    // }


    @AuraEnabled
    public static void updateAssetAddress(Id assetId, Id caseId, String state, String city, String street) {
        Asset assetToUpdate = new Asset(
            Id = assetId,
            Street = street,   // Distrito
            City = city,       // Cantón
            State = state,     // Provincia
            Country = 'Costa Rica',
            PostalCode = null,
            Latitude = null,
            Longitude = null,
            GeocodeAccuracy = null
        );
        update assetToUpdate;

        Case caseToUpdate = new Case(
            Id = caseId,
            Actualizo_direccion__c = true
        );
        update caseToUpdate;
    }

    public static Boolean isKilometrajeAdjustment = false;
    public static Boolean isTestAdminOverride = false;

    @AuraEnabled
    public static void updateKilometraje(String historialId, Decimal nuevoKm, Id assetId, Id caseId) {
        // Obtener el registro de historial
        Historial_Kilometraje__c historial = [
            SELECT Id, UltimoKilometraje__c, NuevoKilometraje__c 
            FROM Historial_Kilometraje__c 
            WHERE Id = :historialId
        ];
        
        // Validación básica
        if (nuevoKm < historial.UltimoKilometraje__c) {
            throw new AuraHandledException('El nuevo kilometraje no puede ser menor al anterior');
        }
        
        // Escenario 1: Reducción de kilometraje (eliminar historial)
        if (nuevoKm < historial.NuevoKilometraje__c) {
            try {
                // Activar bandera de ajuste
                isKilometrajeAdjustment = true;
                
                // 1. Eliminar el registro de historial
                delete historial;
                
                // 2. Actualizar Asset con nuevo valor
                Asset vehiculo = [SELECT Id, Kilometros__c FROM Asset WHERE Id = :assetId];
                vehiculo.Kilometros__c = nuevoKm;
                update vehiculo;
                
                // 3. Actualizar Caso
                Case caso = [SELECT Id, Kilometraje__c FROM Case WHERE Id = :caseId];
                caso.Kilometraje__c = nuevoKm;
                caso.Actualizo_Kilometraje__c = true;
                update caso;
                
                // 4. Actualizar WorkOrders
                List<WorkOrder> workOrders = [SELECT Id, Kilometros__c FROM WorkOrder WHERE CaseId = :caseId];
                for (WorkOrder wo : workOrders) {
                    wo.Kilometros__c = nuevoKm;
                }
                update workOrders;
                
            } finally {
                // Desactivar bandera siempre
                isKilometrajeAdjustment = false;
            }
        } 
        // Escenario 2: Aumento normal de kilometraje
        else {
            // Actualizar normalmente (sin cambios)
            historial.NuevoKilometraje__c = nuevoKm;
            update historial;
            
            Asset vehiculo = [SELECT Id, Kilometros__c FROM Asset WHERE Id = :assetId];
            vehiculo.Kilometros__c = nuevoKm;
            update vehiculo;
            
            Case caso = [SELECT Id, Kilometraje__c FROM Case WHERE Id = :caseId];
            caso.Kilometraje__c = nuevoKm;
            caso.Actualizo_Kilometraje__c = true;
            update caso;
            
            List<WorkOrder> workOrders = [SELECT Id, Kilometros__c FROM WorkOrder WHERE CaseId = :caseId];
            for (WorkOrder wo : workOrders) {
                wo.Kilometros__c = nuevoKm;
            }
            update workOrders;
        }
    }

    @AuraEnabled()
    public static List<Object> updateFacturacion (String recordId, String correoFact, String phoneFact) {
        List<Case> lstCase = new List<Case>();
        List<WorkOrder> lstWO = new List<WorkOrder>();
        if(recordId != null && recordId != 'undefined' && recordId !=''){

            lstWO = [Select Id,AccountId,Cuenta_de_Facturacion__c,Account.Invoice_Email__c,Account.Invoice_Phone__c
            From WorkOrder Where Id =:recordId AND isLocked__c != true  LIMIT 1 ];

            lstCase = [Select Id,AccountId,Cuenta_de_Facturacion__c,Account.Invoice_Email__c,Account.Invoice_Phone__c
            From Case Where Id =:recordId  LIMIT 1 ];

            List<Account> lstAccount = new List<Account>();
            if(lstCase.size()>0){
                lstAccount = [Select Id,Invoice_Email__c, Invoice_Phone__c From Account Where Id = : lstCase[0].Cuenta_de_Facturacion__c];
            }else{
                lstAccount = [Select Id,Invoice_Email__c, Invoice_Phone__c From Account Where Id = : lstWO[0].Cuenta_de_Facturacion__c];
            }
            
            if(lstAccount.size()>0){
                for(Account acc : lstAccount){
                    acc.Invoice_Email__c = correoFact;
                    acc.Invoice_Phone__c = phoneFact;
                }
                update lstAccount;
            }                      
        }      
       
        return lstCase;   
    }  
    
    @AuraEnabled()
    public static List<Object> cambiarFacturacion (String recordId, String accId) {
        List<Case> lstCase = new List<Case>();
        List<WorkOrder> lstWO = new List<WorkOrder>();
        if(recordId != null && recordId != 'undefined' && recordId !=''){

            lstWO = [Select Id,AccountId,Cuenta_de_Facturacion__c,Account.Invoice_Email__c,Account.Invoice_Phone__c
            From WorkOrder Where Id =:recordId  LIMIT 1 ];

            lstCase = [Select Id,AccountId,Cuenta_de_Facturacion__c,Account.Invoice_Email__c,Account.Invoice_Phone__c
            From Case Where Id =:recordId  LIMIT 1 ];

            List<Account> lstAccount = new List<Account>();
            if(lstCase.size()>0){
                lstCase[0].Cuenta_de_Facturacion__c = accId;
                update lstCase;
            }else{
                lstWO[0].Cuenta_de_Facturacion__c = accId;
                update lstWO;
            }                                        
        }      
       
        return lstCase;   
    }

    @AuraEnabled
    public static void cambiarFacturacionCaso(String recordId, String accId, Boolean actualizarWorkOrders) {
        // Actualizar el Caso
        Case caso = [SELECT Id, Cuenta_de_Facturacion__c FROM Case WHERE Id = :recordId];
        caso.Cuenta_de_Facturacion__c = accId;
        update caso;

        if(actualizarWorkOrders) {
        List<WorkOrder> workOrders = [SELECT Id, AccountId, Cuenta_de_Facturacion__c 
                                     FROM WorkOrder 
                                     WHERE CaseId = :recordId];
        
            for(WorkOrder wo : workOrders) {
                wo.Cuenta_de_Facturacion__c = accId;
                // Opcional: Si también quieres cambiar el AccountId (propietario)
                // wo.AccountId = accId;
            }
            
            if(!workOrders.isEmpty()) {
                update workOrders;
            }
        }   
    }

    @AuraEnabled
    public static void updateFacturacionCaso(String recordId, String correoFact, String phoneFact) {
        // Obtener el Case con su AccountId y la cuenta de facturación actual
        Case caso = [SELECT Id, AccountId, Cuenta_de_Facturacion__c 
                    FROM Case 
                    WHERE Id = :recordId];

        // Si NO tiene cuenta de facturación asignada
        if (caso.Cuenta_de_Facturacion__c == null) {
            caso.Cuenta_de_Facturacion__c = caso.AccountId;
            update caso;

            // Actualizar todas las Órdenes de Trabajo relacionadas
            List<WorkOrder> ordenesTrabajo = [SELECT Id FROM WorkOrder WHERE CaseId = :recordId];
            for (WorkOrder ot : ordenesTrabajo) {
                ot.Cuenta_de_Facturacion__c = caso.AccountId;
            }
            if (!ordenesTrabajo.isEmpty()) {
                update ordenesTrabajo;
            }
        }

        Id cuentaFacturacionId = caso.Cuenta_de_Facturacion__c;

        // Actualizar campos directamente en la cuenta
        Account cuentaFacturacion = new Account(
            Id = cuentaFacturacionId,
            Invoice_Email__c = correoFact,
            Invoice_Phone__c = phoneFact
        );
        update cuentaFacturacion;

        // Buscar tipos válidos de correo
        List<Tipo_de_datos_de_comunicaci_n__c> tiposCorreo = [
            SELECT Id FROM Tipo_de_datos_de_comunicaci_n__c
            WHERE Correo_Electrenico__c = true AND Name LIKE '%Facturación%'
        ];
        Set<Id> tipoCorreoIds = new Set<Id>();
        for (Tipo_de_datos_de_comunicaci_n__c tipo : tiposCorreo) {
            tipoCorreoIds.add(tipo.Id);
        }

        // Buscar tipos válidos de teléfono
        List<Tipo_de_datos_de_comunicaci_n__c> tiposTelefono = [
            SELECT Id FROM Tipo_de_datos_de_comunicaci_n__c
            WHERE Telefono__c = true AND Name LIKE '%Cobros%'
        ];
        Set<Id> tipoTelefonoIds = new Set<Id>();
        for (Tipo_de_datos_de_comunicaci_n__c tipo : tiposTelefono) {
            tipoTelefonoIds.add(tipo.Id);
        }

        // Actualizar correo si existe
        List<Correo__c> correos = [
            SELECT Id, Name
            FROM Correo__c
            WHERE Account__c = :cuentaFacturacionId
            AND Tipo_de_datos_de_comunicaci_n__c IN :tipoCorreoIds
            LIMIT 1
        ];
        if (!correos.isEmpty()) {
            Correo__c correo = correos[0];
            correo.Name = correoFact;
            update correo;
        }

        // Actualizar teléfono si existe
        List<Tel_fono__c> telefonos = [
            SELECT Id, N_mero_completo__c
            FROM Tel_fono__c
            WHERE Cuenta__c = :cuentaFacturacionId
            AND Tipo_de_datos_de_comunicaci_n__c IN :tipoTelefonoIds
            LIMIT 1
        ];
        if (!telefonos.isEmpty()) {
            Tel_fono__c telefono = telefonos[0];
            telefono.N_mero_de_tel_fono__c = phoneFact;
            update telefono;
        }
    }

    @AuraEnabled
    public static void updateFacturacionQuote(String recordId, String correoFact, String phoneFact) {
        // Obtener el Case con su AccountId y la cuenta de facturación actual
        Quote caso = [SELECT Id, AccountId, Cuenta_de_facturaci_n2__c 
                    FROM Quote 
                    WHERE Id = :recordId];

        // Si NO tiene cuenta de facturación asignada
        if (caso.Cuenta_de_facturaci_n2__c == null) {
            caso.Cuenta_de_facturaci_n2__c = caso.AccountId;
            update caso;

            
        }

        Id cuentaFacturacionId = caso.Cuenta_de_facturaci_n2__c;

       
    }

    @AuraEnabled(cacheable=true)
    public static List<Quote> getWorkOrderData (String recordId){
        List<Quote> lstQuote = [Select Id,
        AccountId,
        Account.Name,
        Account.Phone,
        Account.IsPersonAccount,
        Account.PersonContactId,
        Email,
        Cuenta_de_facturaci_n2__r.Name,
        Cuenta_de_facturaci_n2__r.Invoice_Email__c,
        Cuenta_de_facturaci_n2__r.Invoice_Phone__c,
        Account.Comentario__c,
        ContactId,
        Contact.FirstName,
        Contact.LastName,
        Contact.Name,
        Contact.Email,
        Contact.Phone,
        Contact.Cedula__c                
        From Quote Where Id =: recordId];

        return lstQuote;

    }

}
