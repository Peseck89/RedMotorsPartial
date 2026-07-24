trigger ChanceAccountContado on Account (before update) {
    // Obtiene el perfil del usuario actual
    String perfilUsuario = [SELECT Nombre_de_perfil__c FROM User WHERE Id = :UserInfo.getUserId()].Nombre_de_perfil__c;

    for (Account acc : Trigger.new) {
        // Verifica si el nombre de la cuenta es 'Bavarian Motors Cr S.A.'
        if (acc.FirstName == 'CLIENTE' && acc.LastName == 'CONTADO' || acc.Id == '001PH000009zy6vYAA') {
            
            // Si el perfil no es 'PT1', se verifica si los campos relevantes han sido modificados
            if (perfilUsuario != 'PT1') {
                Account oldAcc = Trigger.oldMap.get(acc.Id);

                if (acc.FirstName != oldAcc.FirstName || 
                    acc.LastName != oldAcc.LastName || 
                    acc.PersonEmail != oldAcc.PersonEmail || 
                    acc.CorreoElectronicoEmpresarial__c != oldAcc.CorreoElectronicoEmpresarial__c || 
                    acc.Phone != oldAcc.Phone || 
                    acc.PersonMobilePhone != oldAcc.PersonMobilePhone || 
                    acc.Bounced_email__c != oldAcc.Bounced_email__c || 
                    acc.Tipo_de_Documento__c != oldAcc.Tipo_de_Documento__c || 
                    acc.Cedula__c != oldAcc.Cedula__c || 
                    acc.nombreCliente__c != oldAcc.nombreCliente__c || 
                    acc.segundoApellido__c != oldAcc.segundoApellido__c || 
                    acc.fechaRegistro__c != oldAcc.fechaRegistro__c || 
                    //acc.No_envio_de_correos__c != oldAcc.No_envio_de_correos__c || 
                    acc.Invoice_Phone__c != oldAcc.Invoice_Phone__c || 
                    acc.Invoice_Email__c != oldAcc.Invoice_Email__c || 
                    acc.Comentario__c != oldAcc.Comentario__c || 
                    acc.Profesiones__c != oldAcc.Profesiones__c || 
                    acc.Sexo__c != oldAcc.Sexo__c || 
                    acc.Direccion_Residencial__c != oldAcc.Direccion_Residencial__c || 
                    acc.EstadoCivilTipos__c != oldAcc.EstadoCivilTipos__c || 
                    acc.Fecha_Nacimiento__c != oldAcc.Fecha_Nacimiento__c || 
                    acc.Has_Child_Activity__c != oldAcc.Has_Child_Activity__c || 
                    acc.Has_Child_Activity__pc != oldAcc.Has_Child_Activity__pc || 
                    acc.Inicio_de_labores__pc != oldAcc.Inicio_de_labores__pc || 
                    acc.ClienteAltica__c != oldAcc.ClienteAltica__c || 
                    acc.Tipo__pc != oldAcc.Tipo__pc || 
                    acc.Correo_electronico_Altica__c != oldAcc.Correo_electronico_Altica__c || 
                    acc.Movil_Altica__c != oldAcc.Movil_Altica__c || 
                    acc.Telefono_Altica__c != oldAcc.Telefono_Altica__c || 
                    acc.Community_User__pc != oldAcc.Community_User__pc || 
                    acc.Cliente_Exonerado__c != oldAcc.Cliente_Exonerado__c || 
                    acc.fechaCargaCliente__c != oldAcc.fechaCargaCliente__c || 
                    acc.conocidoComo__c != oldAcc.conocidoComo__c || 
                    acc.numeroIdentificacionEntidad__c != oldAcc.numeroIdentificacionEntidad__c || 
                    acc.codigoOficina__c != oldAcc.codigoOficina__c || 
                    acc.fechaRegistro__c != oldAcc.fechaRegistro__c || 
                    acc.Correo_Representante_Lega__c != oldAcc.Correo_Representante_Lega__c || 
                    acc.Revisado__c != oldAcc.Revisado__c || 
                    acc.Vehiculo_relacionado__pc != oldAcc.Vehiculo_relacionado__pc || 
                    acc.Monto_a_financiar_Altica__c != oldAcc.Monto_a_financiar_Altica__c || 
                    acc.Moneda_financiamiento_Altica__c != oldAcc.Moneda_financiamiento_Altica__c || 
                    acc.Pais__c != oldAcc.Pais__c || 
                    acc.Barrio__c != oldAcc.Barrio__c || 
                    acc.Provincia__c != oldAcc.Provincia__c || 
                    acc.Calle__c != oldAcc.Calle__c || 
                    acc.Canton__c != oldAcc.Canton__c || 
                    acc.Direccion__c != oldAcc.Direccion__c || 
                    acc.Distrito__c != oldAcc.Distrito__c || 
                    acc.Nivelacademico__c != oldAcc.Nivelacademico__c || 
                    acc.Tiene_Hijos__c != oldAcc.Tiene_Hijos__c || 
                    acc.Nivel_de_ingreso_familiar_anual__c != oldAcc.Nivel_de_ingreso_familiar_anual__c || 
                    acc.Cantidad_de_hijos__c != oldAcc.Cantidad_de_hijos__c || 
                    acc.Direccion_representante_legal__c != oldAcc.Direccion_representante_legal__c || 
                    acc.profesion__c != oldAcc.profesion__c || 
                    acc.Le_gusta_vacacionar__c != oldAcc.Le_gusta_vacacionar__c || 
                    acc.PracticaDeporte__c != oldAcc.PracticaDeporte__c || 
                    acc.Tipo_de_viaje__c != oldAcc.Tipo_de_viaje__c || 
                    acc.tipoDeporte__c != oldAcc.tipoDeporte__c || 
                    acc.Destino_favorito__c != oldAcc.Destino_favorito__c || 
                    acc.EquipoFutbolFavorito__c != oldAcc.EquipoFutbolFavorito__c || 
                    acc.PorGeneralSaleVacacionar__c != oldAcc.PorGeneralSaleVacacionar__c || 
                    acc.TipoMusicaPrefiere__c != oldAcc.TipoMusicaPrefiere__c || 
                    acc.frecuenciaCine__c != oldAcc.frecuenciaCine__c || 
                    acc.TieneGustosPreferencias__c != oldAcc.TieneGustosPreferencias__c || 
                    acc.tipoPeliculasGusta__c != oldAcc.tipoPeliculasGusta__c || 
                    acc.Gustospreferencias__c != oldAcc.Gustospreferencias__c || 
                    acc.Frecuencia_de_viaje__c != oldAcc.Frecuencia_de_viaje__c || 
                    acc.BillingAddress != oldAcc.BillingAddress || 
                    acc.ShippingAddress != oldAcc.ShippingAddress ) {
                    
                    acc.addError('Esta cuenta no se puede modificar.');
                }
            }
        }
    }
}