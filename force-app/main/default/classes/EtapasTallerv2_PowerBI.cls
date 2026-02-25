public class EtapasTallerv2_PowerBI {
    @future(callout=true)
    public static void sendDataToPowerBIFuture() {
        String powerBIUrl = 'https://api.powerbi.com/beta/a83f6b08-ff0c-4a98-aa10-3f539d058b4e/datasets/0ba428c6-6f74-487a-b0c1-77d74b5c402a/rows?experience=power-bi&key=o4vBcMkRd9tP%2Byag2SkmSi1XKFQB9cic4b7j88QKaxd6m6mQ8Pr%2FdD50YkhyBrc8a6xFz3pB0jEvBEshnrZX0Q%3D%3D';
       
        List<EstadosDeOrden__c> vehiculosListos = [
            SELECT Casos__c
            FROM EstadosDeOrden__c 
            WHERE Name = 'Vehículo Listo' 
            AND FechaInicio__c != null
            AND Casos__r.CreatedDate != TODAY 
			AND Casos__r.Status <> 'Cerrado' 
            AND Casos__r.CreatedDate >= 2025-03-20T00:00:00Z
    	];
        
    
        List<EstadosDeOrden__c> estadosOrdenes2 = [
            SELECT 
                Casos__r.CreatedDate, 
                Casos__c, 
                Casos__r.Status, 
                Casos__r.Service_Territory1__r.Name, 
                Name,
                FechaInicio__c,
                FechaFin__c,
                Casos__r.Asset.Name,
                Casos__r.Vin__c,
                Casos__r.Asset.marca__c, 
                Casos__r.Asset.modelo__c,
                Casos__r.Asset.anio__c,
                Casos__r.Asset.Tipo_de_veh_culo__c,
                Casos__r.Owner.Name,
                Casos__r.consecutivo__c,
            	Casos__r.Account.name,
            	Casos__r.Priority,
            	Casos__r.Asset.combustible__c
            FROM EstadosDeOrden__c
            WHERE Casos__r.CreatedDate = TODAY 
               OR (Casos__r.Status <> 'Cerrado' 
                   AND Casos__r.CreatedDate >= 2025-03-20T00:00:00Z )
        ];
        
     // Eliminar los casos con etapa listo
        Set<Id> casosIDs = new Set<Id>();
        for (EstadosDeOrden__c eo : vehiculosListos) {
            if (eo.Casos__c != null) {
                casosIDs.add(eo.Casos__c);
            }
        }
        
        for (Integer i = estadosOrdenes2.size() - 1; i >= 0; i--) {
            if (casosIDs.contains(estadosOrdenes2[i].Casos__c)) {
                estadosOrdenes2.remove(i);
            }
        }
        
        List<EstadosDeOrden__c> estadosOrdenes = new List<EstadosDeOrden__c>(estadosOrdenes2);
        
        List<Map<String, Object>> records = new List<Map<String, Object>>();
        
        Datetime v_hora_ejecucion = convertToLocalTime(System.now());        
        for (EstadosDeOrden__c estado : estadosOrdenes) {
            Map<String, Object> record = new Map<String, Object>();
          //  record.put('Caso', estado.Casos__c); Se elimina ya que en el reporte no se usa este ID
            record.put('Taller', estado.Casos__r.Service_Territory1__r != null ? estado.Casos__r.Service_Territory1__r.Name : '');
            record.put('Etapa', estado.Name);
            record.put('Matricula', estado.Casos__r.Asset != null ? estado.Casos__r.Asset.Name : '');
            record.put('VIN', estado.Casos__r.Vin__c);
            record.put('Marca', estado.Casos__r.Asset != null ? estado.Casos__r.Asset.marca__c : '');
            record.put('Modelo', estado.Casos__r.Asset != null ? estado.Casos__r.Asset.modelo__c : '');
            record.put('Anio', estado.Casos__r.Asset != null ? estado.Casos__r.Asset.anio__c : '');
            record.put('Asesor', estado.Casos__r.Owner.Name);
            record.put('Tipo de Vehiculo', estado.Casos__r.Asset != null ? estado.Casos__r.Asset.Tipo_de_veh_culo__c : '');
            record.put('Prioridad', estado.Casos__r.Priority);
            record.put('Combustible', estado.Casos__r.Asset.combustible__c);
            
            // Convertir las fechas a la zona horaria local
            record.put('Fecha Entrada', convertToLocalTime(estado.Casos__r.CreatedDate));
            record.put('Estado Caso', estado.Casos__r.Status);
            record.put('Inicio Etapa', convertToLocalTime(estado.FechaInicio__c));
            record.put('Fin Etapa', estado.FechaFin__c != null ? convertToLocalTime(estado.FechaFin__c) : null);
         //   record.put('ID del Caso', estado.Casos__r.consecutivo__c);
            record.put('ID del Caso', String.valueOf(estado.Casos__r.consecutivo__c).right(8));
            // Aplicamos la conversión para la última hora de ejecución
            record.put('Fecha Hora Ejecucion', v_hora_ejecucion);
            
            record.put('Nombre del Cliente', estado.Casos__r.Account.name);
            
            if (estado.FechaFin__c != null) {
                record.put('Estatus de Etapa', 'Finalizada');
            } else {
                record.put('Estatus de Etapa', 'En Proceso');
            }
            
            // Cálculo de Minutos Laborales
            if (estado.FechaInicio__c != null && estado.FechaFin__c != null) {
                Datetime inicio = estado.FechaInicio__c;
                Datetime fin = estado.FechaFin__c;
                Integer minutosLaborales = 0;
                while (inicio < fin) {
                    Integer diaSemana = Integer.valueOf(inicio.format('u'));
                    if (diaSemana >= 2 && diaSemana <= 6 &&
                        inicio.format('HH:mm') >= '08:00' && inicio.format('HH:mm') <= '17:00') {
                        minutosLaborales++;
                    }
                    inicio = inicio.addMinutes(1);
                }
                record.put('Minutos Laborales', minutosLaborales);
                record.put('Hora Laborales', minutosLaborales / 60.0);
            } else {
                record.put('Minutos Laborales', 0.0);
                record.put('Hora Laborales', 0.0);
            }
            
            records.add(record);
        }
        
        if (!records.isEmpty()) {
            String requestBody = JSON.serialize(records);
            HttpRequest request = new HttpRequest();
            request.setEndpoint(powerBIUrl);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setBody(requestBody);
            
            Http http = new Http();
            HttpResponse response = http.send(request);
            
            if (response.getStatusCode() != 200) {
                System.debug('Error al enviar datos a Power BI: ' + response.getBody());
            } else {
                System.debug('Datos enviados exitosamente a Power BI.');
            }
        }
    }
    
    // Método que convierte un DateTime (en UTC) a la hora local del usuario
    public static DateTime convertToLocalTime(DateTime utcDateTime) {
        if(utcDateTime == null) return null;
        TimeZone tz = UserInfo.getTimeZone();
        Long offsetMillis = tz.getOffset(utcDateTime);
        Long utcMillis = utcDateTime.getTime();
        Long localMillis = utcMillis + offsetMillis;
        // Convertir de milisegundos a segundos y castear a Integer
        Integer localSeconds = (Integer)(localMillis / 1000);
        // Se usa newInstanceGmt para obtener el DateTime base y se suman los segundos
        return DateTime.newInstanceGmt(1970, 1, 1, 0, 0, 0).addSeconds(localSeconds);
    }
}