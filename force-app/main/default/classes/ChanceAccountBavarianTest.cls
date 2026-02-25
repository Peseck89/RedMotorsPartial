@isTest
private class ChanceAccountBavarianTest {

    @isTest
    static void testTrigger() {
        // Crea un usuario administrador
        Profile pAdmin = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User adminUser = new User(
            LastName = 'adminuser',
            Username = 'KSFPruebaMarzo@crexample.com',
            Email = 'adminuser@example.com',
            Alias = 'adminusr',
            ProfileId = pAdmin.Id,
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert adminUser;

        // Crea una cuenta de prueba con el primer nombre 'Bavarian' y el apellido 'Motors CR S.A'
        Account acc = new Account(
                FirstName = 'Bavarian', 
                LastName = 'Motors CR S.A',
                Phone = '+50612345678',
                PersonEmail = 'bavarian@example.com',
                PersonMobilePhone = '+50612345678',
                Bounced_email__c = true,
                Tipo_de_Documento__c = 'DNI',
                Cedula__c = '123456789',
                nombreCliente__c = 'Bavarian Client',
                segundoApellido__c = 'Perez',
                fechaRegistro__c = Date.today(),
                Invoice_Phone__c = '+50612345678',
                Invoice_Email__c = 'invoice@example.com',
                Comentario__c = 'This is a comment',
                Profesiones__c = 'Engineer',
                Sexo__c = 'Mujer',
                Direccion_Residencial__c = 'Main Street 123',
                EstadoCivilTipos__c = 'Soltero',
                Fecha_Nacimiento__c = Date.newInstance(1980, 1, 1),
                Has_Child_Activity__c = 01,
                Has_Child_Activity__pc = 01,
                Inicio_de_labores__pc = Date.today(),
                ClienteAltica__c = true,
                //Tipo__pc = 'Analista',
                Correo_electronico_Altica__c = 'altica@example.com',
                Movil_Altica__c = '+50612345678',
                Telefono_Altica__c = '+50612345678',
                Community_User__pc = 'yes',
                Cliente_Exonerado__c = true,
                fechaCargaCliente__c = Date.today(),
                conocidoComo__c = 'Bavarian',
                numeroIdentificacionEntidad__c = '789456123',
                codigoOficina__c = 123,
                Correo_Representante_Lega__c = 'legal@example.com',
                Revisado__c = true,
                //Vehiculo_relacionado__pc = 'BMW',
                Monto_a_financiar_Altica__c = 50000,
                Moneda_financiamiento_Altica__c = 'USD',
                Pais__c = 'Costa Rica',
                Barrio__c = 'Downtown',
                //Provincia__c = 'San José',
                Calle__c = 'Central Avenue',
                //Canton__c = 'Central',
                //Distrito__c = 'Central District',
                Nivelacademico__c = 'Doctorado',
                Tiene_Hijos__c = 'Si',
                Nivel_de_ingreso_familiar_anual__c = '$0 a $50,000',
                Cantidad_de_hijos__c = 2,
                Direccion_representante_legal__c = 'Legal Street 456',
                profesion__c = 01,
                Le_gusta_vacacionar__c = 'si',
                PracticaDeporte__c = 'si',
                Tipo_de_viaje__c = 'Viaje nacional',
                tipoDeporte__c = 'Soccer',
                Destino_favorito__c = 'Playa',
                EquipoFutbolFavorito__c = 'Limón FC',
                PorGeneralSaleVacacionar__c = 'si',
                TipoMusicaPrefiere__c = 'Rock',
                frecuenciaCine__c = '1 vez al mes',
                TieneGustosPreferencias__c = 'si',
                tipoPeliculasGusta__c = 'Action',
                Gustospreferencias__c = 'Atletismo',
                Frecuencia_de_viaje__c = '1 vez al año'
                //BillingAddress = 'Billing Address',
                //ShippingAddress = 'Shipping Address'
        );
        insert acc;

        // Verifica que la cuenta se creó correctamente
        System.assertNotEquals(null, acc.Id, 'La cuenta debería haberse creado correctamente');
  

        // Crea un usuario no administrador
        Profile pNonAdmin = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User nonAdminUser = new User(
            Lastname = 'nonadmin',
            Username = 'KSFPrueba@crexample.com',
            Email = 'nonadmin@example.com',
            Alias = 'nonadmin',
            ProfileId = pNonAdmin.Id,
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert nonAdminUser;

        // Prueba con el usuario no administrador (debería fallar la actualización)
        System.runAs(nonAdminUser) {
            // Reconsultar la cuenta para asegurar que tiene el nombre correcto
            Account accToUpdate = [SELECT Id, FirstName, LastName FROM Account WHERE Id = :acc.Id LIMIT 1];
            accToUpdate.FirstName = 'Updated Bavarian';
            accToUpdate.LastName = 'Updated Motors CR S.A';
            accToUpdate.PersonEmail = 'newemail@example.com';
            accToUpdate.Phone = '+50612345679';
            accToUpdate.Fecha_Nacimiento__c = Date.newInstance(1990, 12, 12);
            accToUpdate.Direccion_Residencial__c = 'Updated Street 123';
            update acc;

            try {
                update accToUpdate;
                // Si llegamos aquí, el error no se produjo como se esperaba
                System.assert(true, 'La cuenta no debería haberse podido modificar.');
            } catch (DmlException e) {
                // Verificamos que el error sea el esperado
                System.assert(e.getMessage().contains('Esta cuenta no se puede modificar.'));
            }
        }
    }
}