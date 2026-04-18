public with sharing class ct_nuevoAccountController {

    @AuraEnabled
    public static Id crearCuenta(Map<String, Object> accountData) {
        if (accountData == null || accountData.isEmpty()) {
            throw new AuraHandledException('Los datos de la cuenta no pueden ser nulos.');
        }
        String cedulaActual = (String)accountData.get('Cedula__c');
        Account acc = new Account();

        // Campos básicos
        if (accountData.containsKey('RecordTypeId'))
            acc.RecordTypeId = (String)accountData.get('RecordTypeId');

        if (accountData.containsKey('Tipos_de_cuenta__c'))
            acc.Tipos_de_cuenta__c = (String)accountData.get('Tipos_de_cuenta__c');

        if (accountData.containsKey('Tipo_de_Documento__c'))
            acc.Tipo_de_Documento__c = (String)accountData.get('Tipo_de_Documento__c');

        if (accountData.containsKey('Cedula__c'))
            acc.Cedula__c = (String)accountData.get('Cedula__c');

        if (accountData.containsKey('PaisPicklist__c'))
            acc.PaisPicklist__c = (String)accountData.get('PaisPicklist__c');

        // Datos personales obligatorios
        if (accountData.containsKey('FirstName'))
            acc.FirstName = (String)accountData.get('FirstName');

        if (accountData.containsKey('MiddleName'))
            acc.MiddleName = (String)accountData.get('MiddleName');

        if (accountData.containsKey('LastName'))
            acc.LastName = (String)accountData.get('LastName');

        if (accountData.containsKey('Sexo__c'))
            acc.Sexo__c = (String)accountData.get('Sexo__c');

        if (accountData.containsKey('Fecha_Nacimiento__c') && accountData.get('Fecha_Nacimiento__c') != null)
            acc.Fecha_Nacimiento__c = Date.valueOf((String)accountData.get('Fecha_Nacimiento__c'));

        if (accountData.containsKey('Profesiones__c'))
            acc.Profesiones__c = (String)accountData.get('Profesiones__c');

        if (accountData.containsKey('EstadoCivilTipos__c'))
            acc.EstadoCivilTipos__c = (String)accountData.get('EstadoCivilTipos__c');

        // Validación final del campo obligatorio más común
        if (String.isBlank(acc.LastName) || acc.LastName.length() < 3 || acc.LastName.length() > 20) {
            throw new AuraHandledException('El apellido debe tener entre 3 y 20 caracteres.');
        }

        // Validación 1: Duplicado por apellido
        if (!String.isBlank(acc.LastName)) {
            List<Account> similares = [SELECT Id FROM Account WHERE FirstName = :acc.FirstName AND LastName = :acc.LastName AND IsPersonAccount = true LIMIT 1];
            if (!similares.isEmpty()) {
                throw new AuraHandledException('Ya existe una cuenta con el mismo Nombre.');
            }
        }

        // Validación 2: Tipo y número de cédula
        if (!String.isBlank(acc.Tipo_de_Documento__c) && !String.isBlank(acc.Cedula__c)) {
            List<Account> duplicados = [SELECT Id FROM Account WHERE Tipo_de_Documento__c = :acc.Tipo_de_Documento__c AND Cedula__c = :acc.Cedula__c LIMIT 1];
            if (!duplicados.isEmpty()) {
                throw new AuraHandledException('Ya existe una cuenta con este tipo y número de cédula.');
            }
        }

        // Validación 3: Correo ya asignado
        if (accountData.containsKey('Correo__c')) {
            String correo = (String)accountData.get('Correo__c');
            if (!String.isBlank(correo)) {
                List<Correo__c> existentes = [SELECT Id FROM Correo__c WHERE Name = :correo AND Account__c != null LIMIT 1];
                if (!existentes.isEmpty()) {
                    throw new AuraHandledException('Este correo electrónico ya está asignado a otra cuenta.');
                }
            }
        }
        List<Account> lstAcc = [Select Id From Account Where Cedula__c =: cedulaActual  LIMIT 1];
        if(lstAcc.size()>0){
            throw new AuraHandledException('Ya existe una cuenta con este tipo y número de cédula.');
        }else{
            insert acc;
        }
        
        return acc.Id;
    }

    @AuraEnabled
    public static List<C_digo_actividad_econ_mica_Hacienda__c> buscarActividadComercial(String searchKey) {
        if (String.isBlank(searchKey)) {
            return new List<C_digo_actividad_econ_mica_Hacienda__c>();
        }

        return [
            SELECT Name, Nombre_actividad_econ_mica__c
            FROM C_digo_actividad_econ_mica_Hacienda__c
            WHERE Name LIKE :('%' + searchKey + '%')
            OR Nombre_actividad_econ_mica__c LIKE :('%' + searchKey + '%')
            ORDER BY Nombre_actividad_econ_mica__c
            LIMIT 10
        ];
    }

    @AuraEnabled
    public static Id crearCuentaJuridica(Map<String, Object> accountData) {
        if (accountData == null || accountData.isEmpty()) {
            throw new AuraHandledException('Los datos de la cuenta no pueden ser nulos.');
        }

        // Buscar RecordTypeId de cuenta no Person Account
        List<RecordType> tipos = [
            SELECT Id FROM RecordType
            WHERE SObjectType = 'Account' AND IsPersonType = false AND Name = 'Cuenta empresarial' LIMIT 1
        ];

        if (tipos.isEmpty()) {
            throw new AuraHandledException('No se encontró un RecordType válido para cuentas jurídicas.');
        }

        Account acc = new Account();

        acc.RecordTypeId = tipos[0].Id;

        if (accountData.containsKey('Tipos_de_cuenta__c'))
            acc.Tipos_de_cuenta__c = (String)accountData.get('Tipos_de_cuenta__c');

        if (accountData.containsKey('Tipo_de_Documento__c'))
            acc.Tipo_de_Documento__c = (String)accountData.get('Tipo_de_Documento__c');

        if (accountData.containsKey('PaisPicklist__c'))
            acc.PaisPicklist__c = (String)accountData.get('PaisPicklist__c');

        if (accountData.containsKey('Cedula__c'))
            acc.Cedula__c = (String)accountData.get('Cedula__c');

        if (accountData.containsKey('Name'))
            acc.Name = (String)accountData.get('Name');

        if (accountData.containsKey('Description'))
            acc.Description = (String)accountData.get('Description');

        // Validación: nombre de empresa obligatorio
        if (String.isBlank(acc.Name) || acc.Name.length() < 3 || acc.Name.length() > 100) {
            throw new AuraHandledException('El nombre debe tener entre 3 y 100 caracteres.');
        }

        // Validación 1: Duplicado por nombre
        List<Account> duplicadosNombre = [SELECT Id FROM Account WHERE Name = :acc.Name AND IsPersonAccount = false LIMIT 1];
        if (!duplicadosNombre.isEmpty()) {
            throw new AuraHandledException('Ya existe una cuenta jurídica con el mismo nombre.');
        }

        // Validación 2: Tipo y número de cédula
        if (!String.isBlank(acc.Tipo_de_Documento__c) && !String.isBlank(acc.Cedula__c)) {
            List<Account> duplicados = [SELECT Id FROM Account WHERE Tipo_de_Documento__c = :acc.Tipo_de_Documento__c AND Cedula__c = :acc.Cedula__c LIMIT 1];
            if (!duplicados.isEmpty()) {
                throw new AuraHandledException('Ya existe una cuenta con este tipo y número de cédula.');
            }
        }

        // Validación 3: Correo ya asignado
        if (accountData.containsKey('Correo__c')) {
            String correo = (String)accountData.get('Correo__c');
            if (!String.isBlank(correo)) {
                List<Correo__c> existentes = [SELECT Id FROM Correo__c WHERE Name = :correo AND Account__c != null LIMIT 1];
                if (!existentes.isEmpty()) {
                    throw new AuraHandledException('Este correo electrónico ya está asignado a otra cuenta.');
                }
            }
        }

        insert acc;
        return acc.Id;
    }

    @AuraEnabled
    public static void actualizarCorreoYTelefono(Id accountId) {
        if (accountId == null) {
            throw new AuraHandledException('El ID de cuenta no puede ser nulo.');
        }

        Account acc = [SELECT Id, IsPersonAccount FROM Account WHERE Id = :accountId];

        // Buscar correo principal
        List<Correo__c> correos = [SELECT Name FROM Correo__c WHERE Principal__c = true AND Account__c = :accountId LIMIT 1];
        if (!correos.isEmpty()) {
            if (acc.IsPersonAccount) {
                acc.PersonEmail = correos[0].Name;
            } else {
                acc.CorreoElectronicoEmpresarial__c = correos[0].Name;
            }
        }

        // Buscar teléfono principal
        List<Tel_fono__c> telefonos = [SELECT N_mero_completo__c FROM Tel_fono__c WHERE Telefono_principal__c = true AND Cuenta__c = :accountId LIMIT 1];
        if (!telefonos.isEmpty()) {
            acc.Phone = telefonos[0].N_mero_completo__c;
        }

        update acc;
    }

    @AuraEnabled(cacheable=true)
    public static Account getAccountById(Id accountId) {
        if (accountId == null) {
            throw new AuraHandledException('El ID de cuenta no puede ser nulo.');
        }

        return [
            SELECT Id,Name,Description, RecordTypeId, FirstName, MiddleName, LastName, Sexo__c, Fecha_Nacimiento__c,
                   Profesiones__c, EstadoCivilTipos__c, Cedula__c, PaisPicklist__c, Tipos_de_cuenta__c, Tipo_de_Documento__c,
                   C_digo_actividad_econ_mica_Hacienda__c, C_digo_actividad_econ_mica_Hacienda__r.Name,C_digo_actividad_econ_mica_Hacienda__r.Nombre_actividad_econ_mica__c
            FROM Account
            WHERE Id = :accountId
            LIMIT 1
        ];
    }

    @AuraEnabled
    public static void actualizarCuenta(Id accountId, Map<String, Object> campos) {
        if (accountId == null || campos == null || campos.isEmpty()) {
            throw new AuraHandledException('El ID de cuenta y los datos no pueden ser nulos.');
        }

        Account cuentaActual = [SELECT Id, Name, FirstName, LastName, IsPersonAccount, Sexo__c, Fecha_Nacimiento__c,
                                Profesiones__c, EstadoCivilTipos__c, Cedula__c, PaisPicklist__c,
                                Tipos_de_cuenta__c, Tipo_de_Documento__c,C_digo_actividad_econ_mica_Hacienda__c
                                FROM Account WHERE Id = :accountId LIMIT 1];

        Account acc = new Account(Id = accountId);

        if (campos.containsKey('Name'))
            acc.Name = (String)campos.get('Name');

        if (campos.containsKey('Description'))
            acc.Description = (String)campos.get('Description');

        if (campos.containsKey('FirstName'))
            acc.FirstName = (String)campos.get('FirstName');

        if (campos.containsKey('MiddleName'))
            acc.MiddleName = (String)campos.get('MiddleName');

        if (campos.containsKey('LastName'))
            acc.LastName = (String)campos.get('LastName');

        if (campos.containsKey('Sexo__c'))
            acc.Sexo__c = (String)campos.get('Sexo__c');

        if (campos.containsKey('Fecha_Nacimiento__c') && campos.get('Fecha_Nacimiento__c') != null)
            acc.Fecha_Nacimiento__c = Date.valueOf((String)campos.get('Fecha_Nacimiento__c'));

        if (campos.containsKey('Profesiones__c'))
            acc.Profesiones__c = (String)campos.get('Profesiones__c');

        if (campos.containsKey('EstadoCivilTipos__c'))
            acc.EstadoCivilTipos__c = (String)campos.get('EstadoCivilTipos__c');

        if (campos.containsKey('Cedula__c'))
            acc.Cedula__c = (String)campos.get('Cedula__c');

        if (campos.containsKey('PaisPicklist__c'))
            acc.PaisPicklist__c = (String)campos.get('PaisPicklist__c');

        if (campos.containsKey('Tipos_de_cuenta__c'))
            acc.Tipos_de_cuenta__c = (String)campos.get('Tipos_de_cuenta__c');

        if (campos.containsKey('Tipo_de_Documento__c'))
            acc.Tipo_de_Documento__c = (String)campos.get('Tipo_de_Documento__c');

        if (campos.containsKey('Actividad_Comercial__c'))
        acc.C_digo_actividad_econ_mica_Hacienda__c = (String)campos.get('Actividad_Comercial__c');

        // --- Validaciones por tipo de cuenta ---
        if (!String.isBlank(acc.LastName) && String.isBlank(acc.Name)) {
            if (acc.LastName.length() < 3 || acc.LastName.length() > 20) {
                throw new AuraHandledException('El apellido debe tener entre 3 y 20 caracteres.');
            }

            // Validar duplicado solo si se modificó LastName o FirstName
            Boolean cambioNombrePersona = (campos.containsKey('FirstName') && acc.FirstName != cuentaActual.FirstName) ||
                                        (campos.containsKey('LastName') && acc.LastName != cuentaActual.LastName);

            if (cambioNombrePersona) {
                List<Account> similares = [
                    SELECT Id
                    FROM Account
                    WHERE FirstName = :acc.FirstName AND LastName = :acc.LastName AND IsPersonAccount = true AND Id != :accountId
                    LIMIT 1
                ];
                if (!similares.isEmpty()) {
                    throw new AuraHandledException('Ya existe una cuenta con el mismo Nombre.');
                }
            }

        } else if (String.isBlank(acc.LastName) && !String.isBlank(acc.Name)) {
            if (acc.Name.length() < 3 || acc.Name.length() > 100) {
                throw new AuraHandledException('El nombre debe tener entre 3 y 100 caracteres.');
            }

            // Validar duplicado solo si se modificó el campo Name
            if (campos.containsKey('Name') && acc.Name != cuentaActual.Name) {
                List<Account> duplicadosNombre = [
                    SELECT Id
                    FROM Account
                    WHERE Name = :acc.Name AND IsPersonAccount = false AND Id != :accountId
                    LIMIT 1
                ];
                if (!duplicadosNombre.isEmpty()) {
                    throw new AuraHandledException('Ya existe una cuenta jurídica con el mismo nombre.');
                }
            }
        }

        // Validación 2: Tipo y número de cédula
        if (!String.isBlank(acc.Tipo_de_Documento__c) && !String.isBlank(acc.Cedula__c)) {
            List<Account> duplicados = [
                SELECT Id
                FROM Account
                WHERE Tipo_de_Documento__c = :acc.Tipo_de_Documento__c AND Cedula__c = :acc.Cedula__c AND Id != :accountId
                LIMIT 1
            ];
            if (!duplicados.isEmpty()) {
                throw new AuraHandledException('Ya existe una cuenta con este tipo y número de cédula.');
            }
        }

        update acc;
    }


    @AuraEnabled(cacheable=false)
    public static List<TiposDocumentoxTiposCuenta__c> obtenerTiposDocumentoCuenta(String tipoCuenta) {
        if (tipoCuenta == null) {
            throw new AuraHandledException('Debe seleccionar el tipo de la cuenta.');
        }

        return [
            SELECT Id, Tipo_de_documento__r.Name,Tipo_de_documento__c,Tipo_de_cuenta__r.Name FROM TiposDocumentoxTiposCuenta__c 
            WHERE Tipo_de_cuenta__r.Name =: tipoCuenta
            ORDER BY  Tipo_de_documento__r.Name
            ];
    }


    @AuraEnabled
    public static void eliminarCuenta(Id accountId) {
        if (accountId == null) {
            throw new AuraHandledException('El ID de la cuenta no puede ser nulo para eliminar.');
        }

        try {
            delete [SELECT Id FROM Account WHERE Id = :accountId];
        } catch (Exception e) {
            throw new AuraHandledException('Error al eliminar la cuenta: ' + e.getMessage());
        }
    }


    @AuraEnabled
    public static void validarCuentaExistente(String cedula, String tipoCuenta) {
        if (String.isBlank(cedula) || String.isBlank(tipoCuenta)) {
            throw new AuraHandledException('Debe proporcionar cédula y tipo de cuenta.');
        }

        List<Account> lstAcc = [
            SELECT Id 
            FROM Account 
            WHERE Cedula__c = :cedula
            AND Tipos_de_cuenta__c = :tipoCuenta
            LIMIT 1
        ];

        if (!lstAcc.isEmpty()) {
            throw new AuraHandledException('Ya existe una cuenta con este tipo y número de cédula.');
        }
    }

    @AuraEnabled(cacheable=true)
    public static Boolean esPerfilAdministrador() {
        User u = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
        return u.Profile.Name == 'System Administrator';
    }


    
}