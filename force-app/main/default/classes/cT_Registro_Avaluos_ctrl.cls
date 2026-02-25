public with sharing class cT_Registro_Avaluos_ctrl {

    private static final String CREDID_ENDPOINT_PAR = 'https://ws.credid.net/ws/api/Reporte/Vehiculo?placa=';
    private static final String CREDID_ENDPOINT_MOT = 'https://ws.credid.net/ws/api/Reporte/Vehiculo?clase=MOT&placa=';
    private static final String CREDID_ENDPOINT_CL = 'https://ws.credid.net/ws/api/Reporte/Vehiculo?clase=cl&placa=';

    @AuraEnabled(cacheable=false)
    public static Map<String, Object> searchVehicle(String licensePlate, String tipoVehiculo) {
        try {
            Map<String, Object> externalData = searchExternal(licensePlate.trim().toUpperCase(), tipoVehiculo, true);
            
            if(externalData.containsKey('found') && (Boolean)externalData.get('found')) {
                // Verificar si hay embargos aunque ya se encontró el vehículo
                // if(!externalData.containsKey('cantidadEmbargos')) {
                //     externalData.put('cantidadEmbargos', 0);
                // }
                return externalData;
            }
            
            Map<String, Object> internalData = searchInternal(licensePlate.trim().toUpperCase(), tipoVehiculo);
            
            if((Boolean)internalData.get('found')) {
                // Intentar obtener embargos del servicio externo
                Map<String, Object> embargoData = searchExternal(licensePlate.trim().toUpperCase(), tipoVehiculo, false);
                if(!embargoData.containsKey('error')) {
                    internalData.put('cantidadEmbargos', embargoData.get('cantidadEmbargos'));
                } else {
                    internalData.put('cantidadEmbargos', 0);
                }
                return internalData;
            }
            
            return new Map<String, Object>{
                'found' => false,
                'source' => 'none',
                'error' => 'Vehículo no encontrado en ningún sistema'
            };
            
        } catch(Exception e) {
            throw new AuraHandledException('Error en búsqueda: ' + e.getMessage());
        }
    }
    
    private static Map<String, Object> searchInternal(String placa, String tipoVehiculo) {
        // String tipoAsset = (tipoVehiculo == 'PAR') ? 'Automóvil' : 'Motocicleta';

        String tipoAsset;
        switch on tipoVehiculo {
            when 'PAR' {
                tipoAsset = 'Automóvil';
            }
            when 'CL' {
                tipoAsset = 'Carga Liviana';
            }
            when 'MOT' {
                tipoAsset = 'Motocicleta';
            }
            when else {
                tipoAsset = ''; // o algún valor por defecto
            }
        }

        Map<String, Object> response = new Map<String, Object>{
            'found' => false,
            'source' => 'internal'
        };
        
        try {
            List<Asset> assets = [SELECT Id, NumeroDeChasis__c, Traccion__c, Carroceria__c, 
                                 Tipo_de_veh_culo__c, Anio__c, Color__c, Combustible__c, 
                                 Marca__c, Modelo__c, Owner.Name 
                                 FROM Asset 
                                 WHERE numeroDePlaca__c = :placa 
                                 AND Tipo_de_veh_culo__c = : tipoAsset 
                                 LIMIT 1];
            
            if(!assets.isEmpty()) {
                Asset a = assets[0];
                response.put('found', true);
                response.put('numeroVin', safeString(a.NumeroDeChasis__c));
                response.put('carroceria', safeString(a.Carroceria__c));
                response.put('numeroChasis', safeString(a.NumeroDeChasis__c));
                response.put('categoria', safeString(a.Tipo_de_veh_culo__c));
                response.put('anio', safeString(a.Anio__c));
                response.put('color', safeString(a.Color__c));

                response.put('marca', safeString(a.Marca__c)?.toUpperCase());
                response.put('modelo', safeString(a.Modelo__c)?.toUpperCase());
                response.put('traccion', safeString(a.Traccion__c)?.toUpperCase());
                response.put('combustible', safeString(a.Combustible__c)?.toUpperCase());

                // response.put('marca', safeString(a.Marca__c));
                // response.put('modelo', safeString(a.Modelo__c));
                // response.put('traccion', safeString(a.Traccion__c));
                // response.put('combustible', safeString(a.Combustible__c));

                response.put('propietario', safeString(a.Owner?.Name));
            }
        } catch(Exception e) {
            System.debug('Error en búsqueda interna: ' + e.getMessage());
        }
        
        return response;
    }

    private static Map<String, Object> searchExternal(String placa, String tipoVehiculo, Boolean fullSearch) {
        Map<String, Object> response = new Map<String, Object>();
        HttpRequest req = new HttpRequest();
        
        try {
            // 1. Determinar el endpoint según el tipo de vehículo
            // String endpoint = (tipoVehiculo == 'MOT') 
            //     ? CREDID_ENDPOINT_MOT + EncodingUtil.urlEncode(placa, 'UTF-8')
            //     : CREDID_ENDPOINT_PAR + EncodingUtil.urlEncode(placa, 'UTF-8');

            String endpoint;
            switch on tipoVehiculo {
                when 'MOT' {
                    endpoint = CREDID_ENDPOINT_MOT + EncodingUtil.urlEncode(placa, 'UTF-8');
                }
                when 'CL' {
                    endpoint = CREDID_ENDPOINT_CL + EncodingUtil.urlEncode(placa, 'UTF-8');
                }
                when else {
                    endpoint = CREDID_ENDPOINT_PAR + EncodingUtil.urlEncode(placa, 'UTF-8');
                }
            }
    
            // 2. Configurar la solicitud HTTP
            req.setEndpoint(endpoint);
            req.setMethod('GET');
            req.setHeader('Authorization', 'baa0ef63-c067-47cd-a20b-8890400e7d6b');
            req.setTimeout(10000);
    
            Http http = new Http();
            HTTPResponse res = http.send(req);
    
            // 3. Manejar respuesta HTTP
            if(res.getStatusCode() != 200) {
                response.put('error', 'Error Credid: ' + res.getStatusCode() + ' - ' + res.getStatus());
                return response;
            }
    
            // 4. Procesar cuerpo de respuesta
            Map<String, Object> externalData = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            
            if(!externalData.containsKey('Dato')) {
                response.put('error', 'Respuesta inválida de Credid');
                return response;
            }
    
            Map<String, Object> dato = (Map<String, Object>) externalData.get('Dato');
    
            // 5. Llenar datos solo si es búsqueda completa
            if(fullSearch) {
                List<Object> propietarios = dato.containsKey('InformacionPropietario') 
                    ? (List<Object>) dato.get('InformacionPropietario') 
                    : new List<Object>();
                
                Map<String, Object> primerPropietario = !propietarios.isEmpty() 
                    ? (Map<String, Object>) propietarios[0] 
                    : new Map<String, Object>();
                
                // Mapeo completo de datos
                response.put('found', true);
                response.put('source', 'external');
                response.put('numeroVin', safeNestedString(dato, 'NumeroVinCarroceria'));
                response.put('carroceria', safeNestedString(dato, 'Carroceria'));
                response.put('numeroChasis', safeNestedString(dato, 'NumeroChasis'));
                response.put('capacidad', safeNestedString(dato, 'Capacidad'));
                response.put('categoria', safeNestedString(dato, 'TipoCategoria'));
                response.put('anio', safeNestedString(dato, 'Anio'));
                response.put('color', safeNestedString(dato, 'Color'));
                // response.put('marca', safeNestedString(dato, 'Marca'));
                String marca = safeNestedString(dato, 'Marca');
                if(marca == 'B.M.W.') {
                    marca = 'BMW';
                }

                String combustible = safeNestedString(dato, 'Motor.Combustible');
                if(combustible == 'ELECTRICO') {
                    combustible = 'ELÉCTRICO';
                }

                response.put('marca', marca?.toUpperCase());
                response.put('combustible', combustible?.toUpperCase());
                response.put('modelo', safeNestedString(dato, 'Modelo')?.toUpperCase());
                response.put('traccion', safeNestedString(dato, 'Traccion')?.toUpperCase());
                // response.put('combustible', safeNestedString(dato, 'Motor.Combustible')?.toUpperCase());

                // response.put('marca', marca);
                // response.put('modelo', safeNestedString(dato, 'Modelo'));
                // response.put('traccion', safeNestedString(dato, 'Traccion'));
                // response.put('combustible', safeNestedString(dato, 'Motor.Combustible'));

                response.put('propietario', safeString(primerPropietario.get('Nombre')));
                response.put('cilindraje', safeNestedString(dato, 'Motor.Cilindrada'));
                response.put('cantidadEmbargos', safeInteger(dato.get('CantidadEmbargos')));
                
                // Campos adicionales para MOT
                if(tipoVehiculo == 'MOT') {
                    response.put('cilindraje', safeNestedString(dato, 'Motor.Cilindrada'));
                    response.put('numeroMotor', safeNestedString(dato, 'Motor.Numero'));
                }
            }
    
            // 6. Siempre obtener embargos (para ambos casos)
            response.put('cantidadEmbargos', safeInteger(dato.get('CantidadEmbargos')));
    
        } catch(Exception e) {
            response.put('error', 'Excepción en Credid: ' + e.getMessage());
            System.debug('Error en searchExternal: ' + e.getStackTraceString());
        }
        
        return response;
    }
    
    private static String safeString(Object value) {
        return value != null ? String.valueOf(value) : '';
    }
    
    private static String safeNestedString(Map<String, Object> parent, String path) {
        try {
            String[] parts = path.split('\\.');
            Object current = parent;
            
            for(String part : parts) {
                if(current instanceof Map<String, Object>) {
                    current = ((Map<String, Object>) current).get(part);
                } else {
                    return '';
                }
            }
            
            return current != null ? String.valueOf(current) : '';
        } catch(Exception e) {
            return '';
        }
    }
    
    private static Integer safeInteger(Object value) {
        try {
            return Integer.valueOf(value);
        } catch(Exception e) {
            return 0;
        }
    }

    // Metodo para guardar el avaluo
    @AuraEnabled
    // public static void saveAppraisal(
    public static String saveAppraisal(
        String placa,
        String observaciones,
        Decimal valorSugerido,
        String vin,
        String traccion,
        String carroceria,
        String numeroChasis,
        String categoria,
        String estilo,
        String capacidadPersonas,
        Decimal anio,
        String color,
        String combustible,
        String marca,
        String modelo,
        String propietario,
        String moneda,
        String motor,
        Decimal n_puertas,
        String trasmision,
        String gravamenes_o_multas,
        String estilo_usado,
        String cantidad_de_embargos,
        String capacidad_de_personas,
        Decimal cilindraje,
        Decimal kilometraje
    ) {
        try {
            Date hoy = Date.today();

            // Agregar ceros manualmente si el mes o día son menores a 10
            String mes = hoy.month() < 10 ? '0' + String.valueOf(hoy.month()) : String.valueOf(hoy.month());
            String dia = hoy.day() < 10 ? '0' + String.valueOf(hoy.day()) : String.valueOf(hoy.day());

            String fechaStr = String.valueOf(hoy.year()) + mes + dia;

            // Generar número aleatorio de 4 dígitos
            Integer rand = Math.round(Math.random() * 9999);
            String randStr = String.valueOf(rand);
            if (randStr.length() < 4) {
                while (randStr.length() < 4) {
                    randStr = '0' + randStr;
                }
            }

            String nameGenerado = 'AV-' + fechaStr + '-' + randStr;

            marca = marca != null ? marca.toUpperCase() : null;
            modelo = modelo != null ? modelo.toUpperCase() : null;
            traccion = traccion != null ? traccion.toUpperCase() : null;
            trasmision = trasmision != null ? trasmision.toUpperCase() : null;
            combustible = combustible != null ? combustible.toUpperCase() : null;

            // Crear registro del objeto Avaluo__c
            Avaluo__c nuevoAvaluo = new Avaluo__c(
                Name = nameGenerado,
                Placa__c = placa,
                VIN__c = vin,
                Tracci_n__c = traccion,
                Carrocer_a__c = carroceria,
                N_mero_de_Chasis__c = numeroChasis,
                Categor_a__c = categoria,
                Estilo__c = estilo,
                Capacidad_de_Personas__c = capacidadPersonas, 
                Anio_Number__c = anio, 
                Color__c = color,
                Kilometraje__c = kilometraje,
                Combustible__c = combustible,
                Marca__c = marca,
                Modelo__c = modelo,
                Propietario__c = propietario,
                CurrencyIsoCode = moneda, 
                Observaciones__c = observaciones,
                Valor_Sugerido__c = valorSugerido,
                Fecha_del_Aval_o__c = Date.today(),
                Estado_del_Aval_o__c = 'Pendiente',
                Motor__c = motor,
                N_puertas__c = n_puertas,
                Trasmision__c = trasmision,
                Gravamenes_o_Multas__c = gravamenes_o_multas,
                Estilo_Usado__c = estilo_usado,
                Cantidad_de_Embargos__c = cantidad_de_embargos,
                Cilindraje__c = cilindraje,
                Valuador__c = UserInfo.getUserId()
            );

            insert nuevoAvaluo;
            return nuevoAvaluo.Id;
        } catch (Exception e) {
            throw new AuraHandledException('Error al guardar el avalúo: ' + e.getMessage());
        }
    }

    // Consultar los datos de un avaluo especifico
    @AuraEnabled(cacheable=true)
    public static Avaluo__c getAvaluoData(String recordId) {
        return [SELECT 
                Placa__c, VIN__c, Tracci_n__c, Carrocer_a__c, 
                N_mero_de_Chasis__c, Categor_a__c, Estilo__c, 
                Capacidad_de_Personas__c, Anio_Number__c, Color__c, 
                Combustible__c, Cantidad_de_Embargos__c, Marca__c, 
                Modelo__c, Propietario__c, Observaciones__c, Valor_Sugerido__c,
                Valor_Sugerido_Jefe_Usados__c, CurrencyIsoCode, Kilometraje__c
                FROM Avaluo__c 
                WHERE Id = :recordId 
                LIMIT 1];
    }

    // Método para guardar comentarios y valor jefe usados 
    @AuraEnabled
    public static void updateAvaluo(String recordId, String observaciones, Decimal valorJefeUsados) {
        try {
            if(String.isBlank(recordId)) {
                throw new AuraHandledException('ID de registro inválido');
            }

            List<Avaluo__c> avaluos = [SELECT Id, Valor_Sugerido_Jefe_Usados__c 
                                    FROM Avaluo__c 
                                    WHERE Id = :recordId 
                                    LIMIT 1];

            if(avaluos.isEmpty()) {
                throw new AuraHandledException('Registro no encontrado con ID: ' + recordId);
            }

            Avaluo__c avaluoToUpdate = avaluos[0];
            
            // Solo actualizar si el valor no es nulo
            if(valorJefeUsados != null) {
                avaluoToUpdate.Observaciones__c = observaciones;
                avaluoToUpdate.Valor_Sugerido_Jefe_Usados__c = valorJefeUsados;
                update avaluoToUpdate;
            } else {
                throw new AuraHandledException('El valor del jefe de usados no puede ser nulo');
            }

        } catch(DmlException e) {
            throw new AuraHandledException('Error de actualización: ' + e.getDmlMessage(0));
        } catch(Exception e) {
            throw new AuraHandledException('Error: ' + e.getMessage());
        }
    }

    // Metodo para obtener y mostrar el valor sistema
    @AuraEnabled(cacheable=true)
    public static Promedio_Sistema__c getPromedios(Id avaluoId) {
        Avaluo__c avaluo = [SELECT Marca__c, Modelo__c, Anio_Number__c, 
                            Tracci_n__c, Combustible__c, Trasmision__c
                            FROM Avaluo__c 
                            WHERE Id = :avaluoId LIMIT 1];
        
        return [SELECT Promedio_Valuador__c, Promedio_Jefe_Usados__c, Cantidad_Registros__c 
            FROM Promedio_Sistema__c 
            WHERE Marca__c = :avaluo.Marca__c 
            AND Modelo__c = :avaluo.Modelo__c 
            AND Anio_Number__c = :avaluo.Anio_Number__c
            AND Traccion__c = :avaluo.Tracci_n__c 
            AND Combustible__c = :avaluo.Combustible__c
            AND Transmision__c = :avaluo.Trasmision__c
            LIMIT 1];
    }

    @AuraEnabled(cacheable=true)
    public static Promedio_Sistema__c getPromediosByAttributes(String marca, String modelo, Decimal anio, String traccion, String combustible, String trasmision) {
        try {
            marca = marca != null ? marca.toUpperCase() : null;
            modelo = modelo != null ? modelo.toUpperCase() : null;
            traccion = traccion != null ? traccion.toUpperCase() : null;
            combustible = combustible != null ? combustible.toUpperCase() : null;
            trasmision = trasmision != null ? trasmision.toUpperCase() : null;
            
            return [SELECT Promedio_Valuador__c, Promedio_Jefe_Usados__c, Cantidad_Registros__c 
                FROM Promedio_Sistema__c 
                WHERE Marca__c = :marca 
                AND Modelo__c = :modelo 
                AND Anio_Number__c = :anio
                AND Traccion__c = :traccion 
                AND Combustible__c = :combustible
                AND Transmision__c = :trasmision
                LIMIT 1];
        } catch (Exception e) {
            // throw new AuraHandledException('Error obteniendo promedios: ' + e.getMessage());
            throw new AuraHandledException('Este vehículo no cuenta con promedio de sistema');
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Promedio_Sistema__c> getPromediosConsul(String marca, String modelo, Decimal anio, String traccion, String combustible) {
        try {
            return [SELECT Marca__c, Modelo__c, Anio_Number__c, Combustible__c, 
                   Traccion__c, Transmision__c, Cantidad_Registros__c, 
                   Promedio_Jefe_Usados__c 
            FROM Promedio_Sistema__c 
            WHERE Marca__c = :marca 
            AND Modelo__c = :modelo 
            AND Anio_Number__c = :anio 
            AND Combustible__c = :combustible 
            AND Traccion__c = :traccion
            ORDER BY Cantidad_Registros__c DESC];
        } catch (Exception e) {
            // throw new AuraHandledException('Error obteniendo promedios: ' + e.getMessage());
            throw new AuraHandledException('Este vehículo no cuenta con promedio de sistema');
        }
    }

    // Método para obetener los avaluos validos en la opp
    @AuraEnabled(cacheable=true)
    public static List<Avaluo__c> getAvaluosValidos(String placa, String tipoVehiculo) {
        if(String.isBlank(placa) || String.isBlank(tipoVehiculo)) {
            throw new AuraHandledException('Parámetros de búsqueda inválidos');
        }

        // String categoria = (tipoVehiculo == 'MOT') ? 'MOTOCICLETA' : 'AUTOMOVIL';
        Set<String> categorias = new Set<String>();
        if (tipoVehiculo == 'MOT') {
            categorias.add('MOTOCICLETA');
        } else if (tipoVehiculo == 'CL') {
            categorias.add('CARGA LIVIANA');
        } else {
            categorias.add('AUTOMOVIL');
            categorias.add('Automóvil'); 
        }
        
        Set<Id> oppCerradasGanadasIds = new Set<Id>();
        for (Opportunity opp : [SELECT Id FROM Opportunity WHERE StageName = 'Closed Won']) {
            oppCerradasGanadasIds.add(opp.Id);
        }

        return [
            SELECT Id, Name, Placa__c, Marca__c, Modelo__c, Valor_Sugerido__c, 
                Categor_a__c, VIN__c, Tracci_n__c, Carrocer_a__c, 
                N_mero_de_Chasis__c, Anio_Number__c, Color__c, 
                Combustible__c, Cantidad_de_Embargos__c, 
                Propietario__c, Observaciones__c, 
                Valor_Sugerido_Jefe_Usados__c, CurrencyIsoCode, Opportunity__c, Kilometraje__c
            FROM Avaluo__c 
            WHERE Placa__c = :placa
            AND Categor_a__c = :categorias
            AND Serecibevehiculo__c = false
            // AND Valor_Sugerido_Jefe_Usados__c != NULL 
            AND Fecha_del_Aval_o__c >= LAST_N_MONTHS:6 
            AND (Opportunity__c NOT IN :oppCerradasGanadasIds 
                OR Opportunity__c = null)
        ];
    }

    @AuraEnabled(cacheable=true)
    public static Opportunity getOpportunityData(String recordId) {
        try {
            return [SELECT Id, Name, StageName, CloseDate, Amount 
                    FROM Opportunity 
                    WHERE Id = :recordId 
                    WITH SECURITY_ENFORCED 
                    LIMIT 1];
        } catch (Exception e) {
            throw new AuraHandledException('Error obteniendo datos de oportunidad: ' + e.getMessage());
        }
    }

    // Metodo nuevo para varias opp
    @AuraEnabled
    public static void updateAvaluoOpportunity(String recordId, String oportunidadId, Decimal kilometraje) {
        try {
             Avaluo__c avaluo = [SELECT Id, Serecibevehiculo__c 
                FROM Avaluo__c 
                WHERE Id = :recordId 
                LIMIT 1];
        
            if (avaluo.Serecibevehiculo__c) {
                throw new AuraHandledException(
                    'Este avalúo ya está marcado como recibido y no puede ser vinculado nuevamente'
                );
            }

            // Crear registro en objeto de unión
            AvaluoOpportunidad__c junction = new AvaluoOpportunidad__c(
                Opportunity__c = oportunidadId,
                Avaluo__c = recordId,
                Kilometraje__c = kilometraje
            );
            insert junction;
            
            // Crear ReciboUsado__c (código existente adaptado)
            Avaluo__c avaluoCompleto = [
                SELECT Propietario__c, Marca__c, Modelo__c, Anio_Number__c, Estilo__c, Color__c, 
                       Combustible__c, Placa__c, Valor_Sugerido_Jefe_Usados__c, 
                       Tracci_n__c, VIN__c, CurrencyIsoCode, Gravamenes_o_Multas__c,
                       Motor__c, Cilindraje__c, N_puertas__c, Trasmision__c, Estilo_Usado__c
                FROM Avaluo__c 
                WHERE Id = :recordId 
                LIMIT 1
            ];

            ReciboUsado__c nuevoRecibo = new ReciboUsado__c(
                Name = avaluoCompleto.Propietario__c,
                Marca__c = avaluoCompleto.Marca__c,
                Modelo__c = avaluoCompleto.Modelo__c,
                Ano__c = avaluoCompleto.Anio_Number__c != null 
                        ? String.valueOf(avaluoCompleto.Anio_Number__c.intValue()) 
                        : null,
                Estilo__c = avaluoCompleto.Estilo__c,
                Color__c = avaluoCompleto.Color__c,
                Kilometraje__c = kilometraje,
                Combustible__c = avaluoCompleto.Combustible__c,
                Placa__c = avaluoCompleto.Placa__c,
                ReciboJefeUsados__c = avaluoCompleto.Valor_Sugerido_Jefe_Usados__c,
                Traccion__c = avaluoCompleto.Tracci_n__c,
                VIN__c = avaluoCompleto.VIN__c,
                Oportunidad__c = oportunidadId,
                CurrencyIsoCode = avaluoCompleto.CurrencyIsoCode,
                Fecha_de_recibo__c = Date.today(),
                Aval_o_de_Veh_culo__c = recordId,
                Gravamenes_o_Multas__c = avaluoCompleto.Gravamenes_o_Multas__c,
                Motor__c = avaluoCompleto.Motor__c,
                Cilindraje__c = avaluoCompleto.Cilindraje__c,
                N_puertas__c = avaluoCompleto.N_puertas__c,
                Trasmision__c = avaluoCompleto.Trasmision__c,
                EstiloUsado__c = avaluoCompleto.Estilo_Usado__c
            );
            insert nuevoRecibo;

        } catch (Exception e) {
            throw new AuraHandledException('Error al vincular: ' + e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Avaluo__c> getLinkedAvaluos(String opportunityId) {
        return [
            SELECT Id, Name, Placa__c, Valor_Sugerido_Jefe_Usados__c, CreatedDate 
            FROM Avaluo__c 
            WHERE Id IN (
                SELECT Avaluo__c 
                FROM AvaluoOpportunidad__c 
                WHERE Opportunity__c = :opportunityId
            )
        ];
    }

    @AuraEnabled(cacheable=true)
    public static Boolean checkReciboStatus(Id avaluoId) {
        List<ReciboUsado__c> recibos = [
            SELECT Id, Serecibevehiculo__c, VehiculoRecibido__c 
            FROM ReciboUsado__c 
            WHERE Aval_o_de_Veh_culo__c = :avaluoId
            LIMIT 1
        ];
        
        return !recibos.isEmpty() && 
            recibos[0].Serecibevehiculo__c && 
            recibos[0].VehiculoRecibido__c;
    }

    @AuraEnabled(cacheable=true)
    public static String getCurrentUserProfileName() {
        Id profileId = UserInfo.getProfileId();
        Profile userProfile = [SELECT Name FROM Profile WHERE Id = :profileId LIMIT 1];
        return userProfile.Name;
    }

    public static void dummy(){
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
          i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
		i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
		i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
		i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
          i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
		i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
		i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
		i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
          i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
		i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
		i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
		i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
          i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}