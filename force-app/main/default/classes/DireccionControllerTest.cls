@isTest
public class DireccionControllerTest {

    @isTest
    static void testObtenerDirecciones() {
        Account acc = new Account(LastName = 'Test',FirstName = 'asdasdasd',Cedula__c = '635462733');
        insert acc;

        GeoData geo = getGeoData();
        Direccion__c dir = new Direccion__c(Direccion__c = 'Calle 123', Cuenta__c = acc.Id, Provincia__c = geo.provinciaId, Canton__c = geo.cantonId,Distrito__c= geo.distritoId );
        insert dir;

        List<Direccion__c> direcciones = DireccionController.obtenerDirecciones(acc.Id);
        System.assertEquals(1, direcciones.size());
    }

    @isTest
    static void testGuardarDireccionPrimera() {
        Account acc = new Account(LastName = 'Test',FirstName = 'asdasdasd',Cedula__c = '635462733');
        insert acc;
		
        GeoData geo = getGeoData();
        Direccion__c dir = new Direccion__c(Direccion__c = 'Av Siempre Viva', Cuenta__c = acc.Id, Provincia__c = geo.provinciaId, Canton__c = geo.cantonId,Distrito__c = geo.distritoId);

        Test.startTest();
        Direccion__c result = DireccionController.guardarDireccion(dir);
        Test.stopTest();

        System.assert(result.Direccion_principal__c);
    }

    @isTest
    static void testGuardarDireccionDesmarcaOtros() {
        Account acc = new Account(LastName = 'Test',FirstName = 'asdasdasd',Cedula__c = '635462733');
        insert acc;
		
        GeoData geo = getGeoData();
        Direccion__c d1 = new Direccion__c(Direccion__c = 'Eliminar', Cuenta__c = acc.Id, Provincia__c = geo.provinciaId,Canton__c = geo.cantonId, Distrito__c = geo.distritoId, Direccion_principal__c = true );
		insert d1;
        Direccion__c d2 = new Direccion__c(Direccion__c = 'Calle Dos', Cuenta__c = acc.Id,Provincia__c = geo.provinciaId, Canton__c = geo.cantonId , Distrito__c = geo.distritoId);
        insert d2;

        d2.Direccion_principal__c = true;
        Test.startTest();
        DireccionController.guardarDireccion(d2);
        Test.stopTest();

        d1 = [SELECT Direccion_principal__c FROM Direccion__c WHERE Id = :d1.Id];
        d2 = [SELECT Direccion_principal__c FROM Direccion__c WHERE Id = :d2.Id];

        System.assertEquals(false, d1.Direccion_principal__c);
        System.assertEquals(true, d2.Direccion_principal__c);
    }

    @isTest
    static void testEliminarDireccion() {
        Account acc = new Account(LastName = 'Test',FirstName = 'asdasdasd',Cedula__c = '635462733');
        insert acc;

        GeoData geo = getGeoData();
        Direccion__c dir = new Direccion__c(Direccion__c = 'Eliminar', Cuenta__c = acc.Id, Provincia__c = geo.provinciaId ,Canton__c = geo.cantonId, Distrito__c = geo.distritoId );
        insert dir;

        Test.startTest();
        DireccionController.eliminarDireccion(dir.Id);
        Test.stopTest();

        List<Direccion__c> resultados = [SELECT Id FROM Direccion__c WHERE Id = :dir.Id];
        System.assertEquals(0, resultados.size());
    }

    @isTest
    static void testObtenerProvinciasYGeografia() {

        List<Provincia__c> provincias = DireccionController.obtenerProvincias();
        List<Canton__c> cantones = DireccionController.obtenerCantones();
        List<Distrito__c> distritos = DireccionController.obtenerDistritos();

    }

    @isTest
    static void testGeografiaFiltradaYTiposComunicacion() {
        Account acc = new Account(LastName = 'Tipos', FirstName = 'Direccion', Cedula__c = '635462734');
        insert acc;

        GeoData geo = getGeoData();
        insert new Tipo_de_datos_de_comunicaci_n__c(
            Name = 'Direccion Test',
            Direccion__c = true,
            Tipo_de_cuenta__c = 'Cuenta personal'
        );

        Test.startTest();
        List<Canton__c> cantones = DireccionController.obtenerCantonesPorProvincia(geo.provinciaId);
        List<Distrito__c> distritos = DireccionController.obtenerDistritosPorCanton(geo.cantonId);
        List<Tipo_de_datos_de_comunicaci_n__c> tipos = DireccionController.obtenerTiposDatosComunicacion(acc.Id);
        try {
            DireccionController.obtenerTiposDatosComunicacion(null);
            System.assert(false, 'Debe rechazar accountId nulo.');
        } catch (AuraHandledException e) {
            System.assertNotEquals(null, e.getMessage());
        }
        Test.stopTest();

        System.assertNotEquals(null, cantones);
        System.assertNotEquals(null, distritos);
        System.assertNotEquals(null, tipos);
    }

    @isTest
    static void testContactDataChannelServiceTiposPorCanalYContacto() {
        Account acc = crearCuentaEmpresarial('Tipos Servicio');

        insert new List<Tipo_de_datos_de_comunicaci_n__c>{
            new Tipo_de_datos_de_comunicaci_n__c(Name = 'Direccion Servicio', Direccion__c = true, Tipo_de_cuenta__c = 'Cuenta empresarial'),
            new Tipo_de_datos_de_comunicaci_n__c(Name = 'Email Servicio', Correo_Electrenico__c = true, Tipo_de_cuenta__c = 'Cuenta empresarial'),
            new Tipo_de_datos_de_comunicaci_n__c(Name = 'Telefono Servicio', Telefono__c = true, Tipo_de_cuenta__c = 'Cuenta empresarial')
        };

        Contact con = new Contact(LastName = 'Contacto Servicio', AccountId = acc.Id);
        insert con;
        insert new Contacto_por_cuenta__c(Account__c = acc.Id, Contact__c = con.Id);

        Test.startTest();
        List<Tipo_de_datos_de_comunicaci_n__c> direcciones =
            ContactDataChannelService.obtenerTiposDatosComunicacion(acc.Id, 'ADDRESS', true);
        List<Tipo_de_datos_de_comunicaci_n__c> correos =
            ContactDataChannelService.obtenerTiposDatosComunicacion(acc.Id, 'EMAIL', true);
        List<Tipo_de_datos_de_comunicaci_n__c> telefonos =
            ContactDataChannelService.obtenerTiposDatosComunicacion(acc.Id, 'PHONE', true);
        List<Tipo_de_datos_de_comunicaci_n__c> direccionesContacto =
            ContactDataChannelService.obtenerTiposDatosComunicacion(con.Id, 'ADDRESS', true);
        try {
            ContactDataChannelService.obtenerTiposDatosComunicacion(null, 'ADDRESS', true);
            System.assert(false, 'Debe rechazar Id nulo.');
        } catch (AuraHandledException e) {
            System.assertNotEquals(null, e.getMessage());
        }
        Test.stopTest();

        System.assert(!direcciones.isEmpty(), 'Debe retornar tipos de direccion.');
        System.assert(!correos.isEmpty(), 'Debe retornar tipos de correo.');
        System.assert(!telefonos.isEmpty(), 'Debe retornar tipos de telefono.');
        System.assert(!direccionesContacto.isEmpty(), 'Debe resolver tipos desde contacto.');
    }

    @isTest
    static void testContactDataChannelServiceDesmarcaPrimarios() {
        Account acc = crearCuentaEmpresarial('Primarios Servicio');

        Tipo_de_datos_de_comunicaci_n__c tipo = new Tipo_de_datos_de_comunicaci_n__c(
            Name = 'Telefono Primario',
            Telefono__c = true,
            Tipo_de_cuenta__c = 'Cuenta empresarial'
        );
        insert tipo;

        String codigoArea = getPicklistValue('Tel_fono__c', 'C_digo_de_rea__c');
        Tel_fono__c tel1 = new Tel_fono__c(
            Cuenta__c = acc.Id,
            C_digo_de_rea__c = codigoArea,
            N_mero_de_tel_fono__c = '11112222',
            Tipo_de_datos_de_comunicaci_n__c = tipo.Id,
            Telefono_principal__c = true
        );
        Tel_fono__c tel2 = new Tel_fono__c(
            Cuenta__c = acc.Id,
            C_digo_de_rea__c = codigoArea,
            N_mero_de_tel_fono__c = '11113333',
            Tipo_de_datos_de_comunicaci_n__c = tipo.Id,
            Telefono_principal__c = true
        );
        insert new List<Tel_fono__c>{ tel1, tel2 };

        Contact con1 = new Contact(LastName = 'Primario Uno', AccountId = acc.Id);
        Contact con2 = new Contact(LastName = 'Primario Dos', AccountId = acc.Id);
        insert new List<Contact>{ con1, con2 };
        Contacto_por_cuenta__c rel1 = new Contacto_por_cuenta__c(Account__c = acc.Id, Contact__c = con1.Id, Es_primario__c = true);
        Contacto_por_cuenta__c rel2 = new Contacto_por_cuenta__c(Account__c = acc.Id, Contact__c = con2.Id, Es_primario__c = true);
        insert new List<Contacto_por_cuenta__c>{ rel1, rel2 };

        Test.startTest();
        ContactDataChannelService.clearOtherPrimaryPhones(null);
        ContactDataChannelService.clearOtherPrimaryPhones(tel2);
        ContactDataChannelService.clearOtherPrimaryAccountContacts(acc.Id, rel2.Id);
        Test.stopTest();

        tel1 = [SELECT Telefono_principal__c FROM Tel_fono__c WHERE Id = :tel1.Id];
        rel1 = [SELECT Es_primario__c FROM Contacto_por_cuenta__c WHERE Id = :rel1.Id];
        System.assertEquals(false, tel1.Telefono_principal__c);
        System.assertEquals(false, rel1.Es_primario__c);
    }

    @isTest
    static void testContactDataChannelServiceIdentificaciones() {
        Account acc = crearCuentaEmpresarial('Identificaciones Servicio');
        Tipo_de_documento__c tipoDocumento = getTipoDocumentoFisico();
        String pais = getPicklistValue('Identificacion__c', 'Pais__c');

        Identificacion__c ident1 = new Identificacion__c(
            Cuenta__c = acc.Id,
            Tipo_de_documento__c = tipoDocumento.Id,
            Pais__c = pais,
            Identificaci_n__c = uniqueCode() + '1',
            Identificacion_principal__c = true
        );
        Identificacion__c ident2 = new Identificacion__c(
            Cuenta__c = acc.Id,
            Tipo_de_documento__c = tipoDocumento.Id,
            Pais__c = pais,
            Identificaci_n__c = uniqueCode() + '2',
            Identificacion_principal__c = true
        );
        insert new List<Identificacion__c>{ ident1, ident2 };

        Test.startTest();
        ContactDataChannelService.clearOtherPrimaryIdentifications(null);
        ContactDataChannelService.clearOtherPrimaryIdentifications(ident2);
        ContactDataChannelService.createInitialIdentificationIfMissing(
            acc.Id,
            '01',
            pais,
            uniqueCode() + '3'
        );
        try {
            ContactDataChannelService.createInitialIdentificationIfMissing(
                acc.Id,
                'No existe',
                pais,
                uniqueCode() + '4'
            );
            System.assert(false, 'Debe rechazar tipo de documento inexistente.');
        } catch (AuraHandledException e) {
            System.assertNotEquals(null, e.getMessage());
        }
        Test.stopTest();

        ident1 = [SELECT Identificacion_principal__c FROM Identificacion__c WHERE Id = :ident1.Id];
        System.assertEquals(false, ident1.Identificacion_principal__c);
    }

    @isTest
    static void testContactDataChannelServiceValidacionesCorreo() {
        Test.startTest();
        String resultadoVacio = ContactDataChannelService.validarCorreoContacto('');
        String resultadoOk = ContactDataChannelService.validarCorreoContacto('servicio.' + uniqueCode() + '@example-valid.com');
        try {
            ContactDataChannelService.validarCorreoContactoOrThrow('');
            System.assert(false, 'Debe rechazar correo vacio.');
        } catch (AuraHandledException e) {
            System.assertNotEquals(null, e.getMessage());
        }
        try {
            ContactDataChannelService.validarCorreoNuevaRelacionOrThrow(null);
            System.assert(false, 'Debe rechazar correo nulo.');
        } catch (AuraHandledException e) {
            System.assertNotEquals(null, e.getMessage());
        }
        try {
            ContactDataChannelService.validarCorreoNuevaRelacionOrThrow('');
            System.assert(false, 'Debe rechazar correo vacio.');
        } catch (AuraHandledException e) {
            System.assertNotEquals(null, e.getMessage());
        }
        ContactDataChannelService.validarCorreoNuevaRelacionOrThrow('nuevo.' + uniqueCode() + '@example-valid.com');
        Test.stopTest();

        System.assertNotEquals(null, resultadoVacio);
        System.assertEquals('OK', resultadoOk);
    }

    @isTest
    static void testContactDataChannelServiceCreacionIdempotente() {
        Account acc = new Account(LastName = 'Creacion Servicio', FirstName = 'Direccion', Cedula__c = uniqueCode());
        insert acc;

        upsertTipoPersonal();

        Test.startTest();
        ContactDataChannelService.createAccountEmailIfMissing(acc.Id, 'crear.' + uniqueCode() + '@example-valid.com', true);
        ContactDataChannelService.createAccountPhoneIfMissing(acc.Id, '+50622223333', true, null, false);
        ContactDataChannelService.createAccountPhoneIfMissing(acc.Id, '+50622223333', true, null, false);
        Test.stopTest();

        System.assertEquals(1, [SELECT COUNT() FROM Tel_fono__c WHERE Cuenta__c = :acc.Id AND N_mero_de_tel_fono__c = '22223333']);
    }

    private static GeoData getGeoData() {
        List<Provincia__c> provincias = [SELECT Id FROM Provincia__c LIMIT 1];
        Provincia__c provincia;
        if (provincias.isEmpty()) {
            provincia = new Provincia__c(Name = 'Provincia Test', CodigoProvincia__c = uniqueCode());
            insert provincia;
        } else {
            provincia = provincias[0];
        }

        List<Canton__c> cantones = [SELECT Id FROM Canton__c LIMIT 1];
        Canton__c canton;
        if (cantones.isEmpty()) {
            canton = new Canton__c(Name = 'Canton Test', CodigoCanton__c = uniqueCode(), Provincia__c = provincia.Id);
            insert canton;
        } else {
            canton = cantones[0];
        }

        List<Distrito__c> distritos = [SELECT Id FROM Distrito__c LIMIT 1];
        Distrito__c distrito;
        if (distritos.isEmpty()) {
            distrito = new Distrito__c(Name = 'Distrito Test', CodigoDistrito__c = uniqueCode(), Provincia__c = provincia.Id, Canton__c = canton.Id);
            insert distrito;
        } else {
            distrito = distritos[0];
        }

        return new GeoData(provincia.Id, canton.Id, distrito.Id);
    }

    private static String uniqueCode() {
        return String.valueOf(Math.abs(Crypto.getRandomInteger())).left(8);
    }

    private static String getPicklistValue(String objectApiName, String fieldApiName) {
        Schema.DescribeFieldResult fieldDescribe = Schema.getGlobalDescribe()
            .get(objectApiName)
            .getDescribe()
            .fields
            .getMap()
            .get(fieldApiName)
            .getDescribe();
        for (Schema.PicklistEntry entry : fieldDescribe.getPicklistValues()) {
            if (entry.isActive()) return entry.getValue();
        }
        return null;
    }

    private static Account crearCuentaEmpresarial(String nombre) {
        RecordType rt = [
            SELECT Id
            FROM RecordType
            WHERE SObjectType = 'Account'
            AND Name = 'Cliente Jurídico'
            LIMIT 1
        ];
        Account acc = new Account(
            Name = nombre + ' ' + uniqueCode(),
            RecordTypeId = rt.Id,
            Cedula__c = uniqueCode()
        );
        insert acc;
        return acc;
    }

    private static Tipo_de_documento__c getTipoDocumentoFisico() {
        String nombre = EncodingUtil.urlDecode('C%C3%A9dula Fisica', 'UTF-8');
        List<Tipo_de_documento__c> existentes = [
            SELECT Id
            FROM Tipo_de_documento__c
            WHERE Name = :nombre
            OR Codigo__c = '01'
            LIMIT 1
        ];
        if (!existentes.isEmpty()) return existentes[0];

        Tipo_de_documento__c tipo = new Tipo_de_documento__c(Name = nombre, Codigo__c = '01');
        insert tipo;
        return tipo;
    }

    private static void upsertTipoPersonal() {
        List<Tipo_de_datos_de_comunicaci_n__c> existentes = [
            SELECT Id
            FROM Tipo_de_datos_de_comunicaci_n__c
            WHERE Name = 'Personal'
            LIMIT 1
        ];
        if (existentes.isEmpty()) {
            insert new Tipo_de_datos_de_comunicaci_n__c(
                Name = 'Personal',
                Correo_Electrenico__c = true,
                Telefono__c = true,
                Tipo_de_cuenta__c = 'Cuenta personal'
            );
        }
    }

    private class GeoData {
        Id provinciaId;
        Id cantonId;
        Id distritoId;

        GeoData(Id provinciaId, Id cantonId, Id distritoId) {
            this.provinciaId = provinciaId;
            this.cantonId = cantonId;
            this.distritoId = distritoId;
        }
    }
}
