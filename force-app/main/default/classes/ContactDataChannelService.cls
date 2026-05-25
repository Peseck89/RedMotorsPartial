public with sharing class ContactDataChannelService {
    private static String utf8(String value) {
        return EncodingUtil.urlDecode(value, 'UTF-8');
    }

    public static List<Tipo_de_datos_de_comunicaci_n__c> obtenerTiposDatosComunicacion(
        Id accountOrContactId,
        String channel,
        Boolean treatCuentaEmpresarialAsBusiness
    ) {
        Id accountId = resolveAccountId(accountOrContactId);
        String tipoCuenta = getCommunicationAccountType(accountId, treatCuentaEmpresarialAsBusiness);

        if (channel == 'EMAIL') {
            return [
                SELECT Id, Name
                FROM Tipo_de_datos_de_comunicaci_n__c
                WHERE Correo_Electrenico__c = TRUE
                AND Tipo_de_cuenta__c = :tipoCuenta
                ORDER BY Name
            ];
        }

        if (channel == 'ADDRESS') {
            return [
                SELECT Id, Name
                FROM Tipo_de_datos_de_comunicaci_n__c
                WHERE Direccion__c = TRUE
                AND Tipo_de_cuenta__c = :tipoCuenta
                ORDER BY Name
            ];
        }

        return [
            SELECT Id, Name
            FROM Tipo_de_datos_de_comunicaci_n__c
            WHERE Telefono__c = TRUE
            AND Tipo_de_cuenta__c = :tipoCuenta
            ORDER BY Name
        ];
    }

    public static void clearOtherPrimaryPhones(Tel_fono__c telefono) {
        if (telefono == null || telefono.Telefono_principal__c != true) return;

        List<Tel_fono__c> otrosPrincipales = [
            SELECT Id
            FROM Tel_fono__c
            WHERE Cuenta__c = :telefono.Cuenta__c
            AND Id != :telefono.Id
            AND Telefono_principal__c = true
        ];

        for (Tel_fono__c tel : otrosPrincipales) {
            tel.Telefono_principal__c = false;
        }
        if (!otrosPrincipales.isEmpty()) update otrosPrincipales;
    }

    public static void clearOtherPrimaryIdentifications(Identificacion__c identificacion) {
        if (identificacion == null || identificacion.Identificacion_principal__c != true) return;

        List<Identificacion__c> otrasPrincipales = [
            SELECT Id
            FROM Identificacion__c
            WHERE Cuenta__c = :identificacion.Cuenta__c
            AND Id != :identificacion.Id
            AND Identificacion_principal__c = true
        ];

        for (Identificacion__c ident : otrasPrincipales) {
            ident.Identificacion_principal__c = false;
        }
        if (!otrasPrincipales.isEmpty()) update otrasPrincipales;
    }

    public static void clearOtherPrimaryAccountContacts(Id accountId, Id relacionId) {
        List<Contacto_por_cuenta__c> existentes = [
            SELECT Id
            FROM Contacto_por_cuenta__c
            WHERE Account__c = :accountId
            AND Es_primario__c = true
            AND Id != :relacionId
        ];

        for (Contacto_por_cuenta__c cpc : existentes) {
            cpc.Es_primario__c = false;
        }
        if (!existentes.isEmpty()) update existentes;
    }

    public static String validarCorreoContacto(String correo) {
        if (String.isBlank(correo)) {
            return utf8('Debe llenar el campo de correo electr%C3%B3nico.');
        }

        String correoLower = correo.toLowerCase().trim();
        String dominio = correoLower.contains('@') ? correoLower.split('@')[1] : '';

        Set<String> bloqueadosSet = new Set<String>();
        for (Mantenimientos_de_email__c b : [
            SELECT Email_Bloqueado__c
            FROM Mantenimientos_de_email__c
        ]) {
            if (b.Email_Bloqueado__c != null) {
                bloqueadosSet.add(b.Email_Bloqueado__c.toLowerCase().trim());
            }
        }
        if (bloqueadosSet.contains(correoLower)) {
            return 'El correo ' + correoLower + ' tiene un formato de correo temporal, por favor ingrese uno permanente.';
        }

        Set<String> temporalesSet = new Set<String>();
        for (Email_Temporal__mdt t : [
            SELECT MasterLabel
            FROM Email_Temporal__mdt
        ]) {
            if (t.MasterLabel != null) {
                temporalesSet.add(t.MasterLabel.toLowerCase().trim());
            }
        }
        if (temporalesSet.contains(correoLower)) {
            return 'El correo ' + correoLower + ' es ' + utf8('gen%C3%A9rico') + ', ingrese uno real.';
        }

        List<Dominio_no_aceptado__mdt> dominios = [
            SELECT DeveloperName
            FROM Dominio_no_aceptado__mdt
            WHERE DeveloperName = :dominio
            LIMIT 1
        ];
        if (!dominios.isEmpty()) {
            return 'El correo posee un dominio incorrecto';
        }

        return 'OK';
    }

    public static void validarCorreoContactoOrThrow(String correo) {
        String resultado = validarCorreoContacto(correo);
        if (resultado != 'OK') {
            throw new AuraHandledException(resultado);
        }
    }

    public static void validarCorreoNuevaRelacionOrThrow(String correo) {
        if (correo == null) {
            throw new AuraHandledException('Los datos del correo no pueden estar ' + utf8('vac%C3%ADos') + '.');
        }
        if (String.isBlank(correo)) {
            throw new AuraHandledException('El campo Correo es obligatorio.');
        }

        String correoLower = correo.toLowerCase().trim();
        Set<String> blacklist = new Set<String>();
        for (Mantenimientos_de_email__c b : [
            SELECT Email_Bloqueado__c
            FROM Mantenimientos_de_email__c
        ]) {
            blacklist.add(b.Email_Bloqueado__c?.toLowerCase());
        }
        if (blacklist.contains(correoLower)) {
            throw new AuraHandledException('El correo ' + correoLower + ' es ' + utf8('gen%C3%A9rico') + ', ingrese uno real.');
        }

        if (correoLower.contains('@')) {
            String dominio = correoLower.substringAfter('@');
            Set<String> dominiosBloqueados = new Set<String>();
            Set<String> dominiosTemporales = new Set<String>();
            for (Dominio_no_aceptado__mdt d : [SELECT DeveloperName FROM Dominio_no_aceptado__mdt]) {
                dominiosBloqueados.add(d.DeveloperName.toLowerCase());
            }
            if (dominiosBloqueados.contains(dominio)) {
                throw new AuraHandledException('El correo posee un dominio incorrecto');
            }

            for (Email_Temporal__mdt d : [SELECT MasterLabel FROM Email_Temporal__mdt]) {
                dominiosTemporales.add(d.MasterLabel.toLowerCase());
            }
            if (dominiosTemporales.contains(dominio)) {
                throw new AuraHandledException('El correo tiene un formato de correo temporal, por favor ingrese uno permanente.');
            }
        }
    }

    public static void createAccountEmailIfMissing(Id accountId, String correo, Boolean principal) {
        List<Correo__c> correoExistente = [
            SELECT Id
            FROM Correo__c
            WHERE Account__c = :accountId
            AND Name = :correo
            LIMIT 1
        ];

        if (!correoExistente.isEmpty()) return;

        insert new Correo__c(
            Account__c = accountId,
            Activo__c = true,
            Name = correo,
            Tipo_de_datos_de_comunicaci_n__c = getPersonalCommunicationTypeId(),
            Principal__c = principal
        );
    }

    public static void createAccountPhoneIfMissing(
        Id accountId,
        String telefono,
        Boolean principal,
        String tipoTelefono,
        Boolean validarDuplicado
    ) {
        String numero = telefono.length() > 8 ? telefono.substring(telefono.length() - 8) : telefono;
        String codigo = telefono.contains('+') ? telefono.substring(0, 4) : '+506';

        if (validarDuplicado == true) {
            TelefonoController.validarDuplicadoTelefono(codigo, numero, accountId, null);
        }

        List<Tel_fono__c> telefonoExistente = [
            SELECT Id
            FROM Tel_fono__c
            WHERE Cuenta__c = :accountId
            AND N_mero_de_tel_fono__c = :numero
            LIMIT 1
        ];

        if (!telefonoExistente.isEmpty()) return;

        Tel_fono__c telefonoNuevo = new Tel_fono__c(
            C_digo_de_rea__c = codigo,
            N_mero_de_tel_fono__c = numero,
            Telefono_principal__c = principal,
            Cuenta__c = accountId,
            Tipo_de_datos_de_comunicaci_n__c = getPersonalCommunicationTypeId()
        );

        if (tipoTelefono != null) {
            telefonoNuevo.Tipo_telefono__c = tipoTelefono;
        }

        insert telefonoNuevo;
    }

    public static void createInitialIdentificationIfMissing(
        Id accountId,
        String tipoDocumentoId,
        String pais,
        String numeroIdentificacion
    ) {
        String tipoDocumentoKey = String.isBlank(tipoDocumentoId) ? '01' : tipoDocumentoId;
        String tipoDocumento = resolveTipoDocumentoFlowName(tipoDocumentoKey);

        List<Tipo_de_documento__c> tipos = [
            SELECT Id
            FROM Tipo_de_documento__c
            WHERE Name = :tipoDocumento
            OR Codigo__c = :tipoDocumentoKey
            LIMIT 1
        ];

        if (tipos.isEmpty()) {
            throw new AuraHandledException('No se ' + utf8('encontr%C3%B3') + ' el tipo de documento especificado: ' + tipoDocumento);
        }

        List<Account> accs = [
            SELECT Id
            FROM Account
            WHERE Cedula__c = :numeroIdentificacion
            AND Id != :accountId
            LIMIT 1
        ];
        List<Identificacion__c> identificaciones = [
            SELECT Id
            FROM Identificacion__c
            WHERE Identificaci_n__c = :numeroIdentificacion
            LIMIT 1
        ];

        if (!accs.isEmpty() || !identificaciones.isEmpty()) return;

        insert new Identificacion__c(
            Cuenta__c = accountId,
            Tipo_de_documento__c = tipos[0].Id,
            Pais__c = pais,
            Identificaci_n__c = numeroIdentificacion,
            Identificacion_principal__c = true
        );
    }

    private static Id getPersonalCommunicationTypeId() {
        return [
            SELECT Id
            FROM Tipo_de_datos_de_comunicaci_n__c
            WHERE Name = 'Personal'
            LIMIT 1
        ].Id;
    }

    private static String resolveTipoDocumentoFlowName(String tipoDocumentoId) {
        if (String.isBlank(tipoDocumentoId)) {
            tipoDocumentoId = '01';
        }

        if (tipoDocumentoId == '01') return utf8('C%C3%A9dula Fisica');
        if (tipoDocumentoId == '02') return utf8('C%C3%A9dula Juridica');
        if (tipoDocumentoId == '03') return 'Dimex';
        if (tipoDocumentoId == '04') return 'NITE';
        if (tipoDocumentoId == 'Pasaporte') return 'Pasaporte';
        if (tipoDocumentoId == 'Carnet de residente') return 'Carnet de residente';
        return tipoDocumentoId;
    }

    private static Id resolveAccountId(Id accountOrContactId) {
        if (accountOrContactId == null) {
            throw new AuraHandledException('Debe enviar el Id de la cuenta.');
        }

        List<Account> accounts = [
            SELECT Id
            FROM Account
            WHERE Id = :accountOrContactId
            LIMIT 1
        ];
        if (!accounts.isEmpty()) return accounts[0].Id;

        List<Contacto_por_cuenta__c> contacts = [
            SELECT Account__c
            FROM Contacto_por_cuenta__c
            WHERE Contact__c = :accountOrContactId
            LIMIT 1
        ];
        if (contacts.isEmpty()) {
            throw new AuraHandledException('Debe enviar el Id de la cuenta.');
        }
        return contacts[0].Account__c;
    }

    private static String getCommunicationAccountType(Id accountId, Boolean treatCuentaEmpresarialAsBusiness) {
        Account acc = [
            SELECT RecordType.Name
            FROM Account
            WHERE Id = :accountId
            LIMIT 1
        ];

        String recordTypeName = acc.RecordType.Name;
        if (
            (recordTypeName != null && recordTypeName.startsWith('Cliente Jur')) ||
            (treatCuentaEmpresarialAsBusiness == true && recordTypeName == 'Cuenta empresarial')
        ) {
            return 'Cuenta empresarial';
        }
        return 'Cuenta personal';
    }
}
