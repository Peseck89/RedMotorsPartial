trigger ChanceAccountOtobai on Account (before update) {

    String perfilUsuario = [
        SELECT Nombre_de_perfil__c 
        FROM User 
        WHERE Id = :UserInfo.getUserId()
    ].Nombre_de_perfil__c;

    for (Account acc : Trigger.new) {

        if (acc.Name == 'OTOBAI MOTOR CR S.A.' || acc.Id == '0014U00002IpmIxQAJ') {

            // Si el perfil NO es el administrador (PT1), validamos qué está cambiando
            if (perfilUsuario != 'PT1') {
                
                // Obtenemos la versión de la cuenta antes de este cambio
                Account cuentaVieja = Trigger.oldMap.get(acc.Id);
                
                // Variable para marcar si tocaron un campo prohibido
                Boolean modificoCamposRestringidos = false;

                // Evaluamos los campos que vienen en la petición de actualización
                for (String fieldName : Trigger.newMap.get(acc.Id).getPopulatedFieldsAsMap().keySet()) {
                    
                    // Ignoramos campos del sistema que cambian automáticamente
                    if (fieldName == 'LastModifiedDate' || fieldName == 'LastModifiedById' || fieldName == 'SystemModstamp') {
                        continue;
                    }
                    
                    // EXCEPCIÓN: Si están modificando estos dos campos, permitimos que continúe el ciclo sin marcar error
                    if (fieldName == 'codigoSoftland__c' || fieldName == 'respuestaServidor__c') {
                        continue;
                    }
                    
                    // Si el valor nuevo es diferente al viejo en cualquier otro campo, se activa la restricción
                    if (acc.get(fieldName) != cuentaVieja.get(fieldName)) {
                        modificoCamposRestringidos = true;
                        break; // Ya encontramos una falta, no hace falta seguir revisando más campos
                    }
                }

                // Si intentó modificar campos que no pertenecen a Softland o Respuesta del Servidor
                if (modificoCamposRestringidos) {
                    acc.addError('Esta cuenta no se puede modificar.');
                }
            }
        }
    }
}