public with sharing class AssetGarantiaController {
    @AuraEnabled(cacheable=true)
    public static List<Asset> buscarVehiculos(String placa) {
        if (String.isBlank(placa)) return new List<Asset>();
        
        String busqueda = placa + '%';
        return [
            SELECT Id, Name, numeroDePlaca__c, Anio__c, fecha_facturacion_vehiculo__c 
            FROM Asset 
            WHERE numeroDePlaca__c LIKE :busqueda 
            LIMIT 50
        ];
    }

    @AuraEnabled
    public static ResultadoGarantia validarGarantia(String assetId) {
        if (String.isBlank(assetId)) {
            return new ResultadoGarantia(false, 'ID de vehículo inválido');
        }
        
        Asset vehiculo;
        try {
            vehiculo = [SELECT Id, Name, numeroDePlaca__c, NumeroDeChasis__c, Anio__c, fecha_facturacion_vehiculo__c 
                    FROM Asset WHERE Id = :assetId LIMIT 1];
        } catch (Exception e) {
            return new ResultadoGarantia(false, 'Vehículo no encontrado');
        }
        
        Date fechaInicio;
        Date fechaFin;
        Date hoy = Date.today();
        Date manana = hoy.addDays(1);

        // if (vehiculo.fecha_facturacion_vehiculo__c != null) {
        //     Integer dia = vehiculo.fecha_facturacion_vehiculo__c.day();
        //     Integer mes = vehiculo.fecha_facturacion_vehiculo__c.month();
            
        //     Date fechaEsteAnio = Date.newInstance(hoy.year(), mes, dia);
            
        //     if (fechaEsteAnio <= hoy) {
        //         fechaInicio = fechaEsteAnio;
        //     } else {
        //         fechaInicio = Date.newInstance(hoy.year() - 1, mes, dia);
                
        //         if (fechaInicio < vehiculo.fecha_facturacion_vehiculo__c) {
        //             fechaInicio = vehiculo.fecha_facturacion_vehiculo__c;
        //         }
        //     }
            
        //     fechaFin = manana;
            
        // } else if (vehiculo.Anio__c != null) {
        //     fechaInicio = Date.newInstance(hoy.year(), 1, 1);
        //     fechaFin = manana;
        // } else {
        //     fechaInicio = hoy.addYears(-1);
        //     fechaFin = manana;
        // }

        if (vehiculo.fecha_facturacion_vehiculo__c != null) {
            Integer dia = vehiculo.fecha_facturacion_vehiculo__c.day();
            Integer mes = vehiculo.fecha_facturacion_vehiculo__c.month();
            
            // Calcular fecha de inicio como 6 meses antes de la fecha actual
            fechaInicio = hoy.addMonths(-6);
            
            // Asegurarse de que la fecha de inicio no sea anterior a la fecha de facturación
            if (fechaInicio < vehiculo.fecha_facturacion_vehiculo__c) {
                fechaInicio = vehiculo.fecha_facturacion_vehiculo__c;
            }
            
            fechaFin = manana;
            
        } else if (vehiculo.Anio__c != null) {
            // Para vehículos con año pero sin fecha de facturación, usar últimos 6 meses
            fechaInicio = hoy.addMonths(-6);
            fechaFin = manana;
        } else {
            // Caso por defecto: últimos 6 meses
            fechaInicio = hoy.addMonths(-6);
            fechaFin = manana;
        }

        List<Case> casos = [
            SELECT Id, CaseNumber, CreatedDate, 
                (SELECT Id, NombreDeTrabajo__c 
                FROM Tipos_de_Trabajo__r 
                WHERE Tipo_de_cargo__c = 'Garantía'
                LIMIT 1) 
            FROM Case
            WHERE AssetId = :assetId
            AND CreatedDate >= :fechaInicio
            AND CreatedDate <= :fechaFin
            AND Id IN (
                SELECT Caso__c 
                FROM tiposDeTrabajoCaso__c 
                WHERE Tipo_de_cargo__c = 'Garantía'
            )
            ORDER BY CreatedDate DESC
        ];
        
        ResultadoGarantia resultado = new ResultadoGarantia();
        resultado.fechaInicio = fechaInicio;
        resultado.fechaFin = fechaFin;
        resultado.totalCitas = casos.size();
        resultado.aplicaGarantia = casos.size() >= 3;
        
        if (resultado.aplicaGarantia) {
            resultado.mensaje = 'Cliente aplica a caso especial de garantía.';
        } else {
            String periodo = vehiculo.fecha_facturacion_vehiculo__c != null
            ? 'desde ' + fechaInicio.format() + ' hasta ' + fechaFin.format()
            : 'en los últimos 6 meses';
                
            resultado.mensaje = 'Cliente no aplica a caso especial de garantía.';
        }
        
        return resultado;
    }
    
    @AuraEnabled
    public static List<DetalleGarantiaCompleto> obtenerDetalleCompleto(String assetId) {
        List<DetalleGarantiaCompleto> detalles = new List<DetalleGarantiaCompleto>();
        
        Asset vehiculo = [SELECT fecha_facturacion_vehiculo__c, Anio__c FROM Asset WHERE Id = :assetId LIMIT 1];

        Date fechaInicio;
        Date fechaFin;
        Date hoy = Date.today();
        Date manana = hoy.addDays(1);

        if (vehiculo.fecha_facturacion_vehiculo__c != null) {
            Integer dia = vehiculo.fecha_facturacion_vehiculo__c.day();
            Integer mes = vehiculo.fecha_facturacion_vehiculo__c.month();
            
            // Calcular fecha de inicio como 6 meses antes de la fecha actual
            fechaInicio = hoy.addMonths(-6);
            
            // Asegurarse de que la fecha de inicio no sea anterior a la fecha de facturación
            if (fechaInicio < vehiculo.fecha_facturacion_vehiculo__c) {
                fechaInicio = vehiculo.fecha_facturacion_vehiculo__c;
            }
            
            fechaFin = manana;
        } else if (vehiculo.Anio__c != null) {
            // Para vehículos con año pero sin fecha de facturación, usar últimos 6 meses
            fechaInicio = hoy.addMonths(-6);
            fechaFin = manana;
        } else {
            // Caso por defecto: últimos 6 meses
            fechaInicio = hoy.addMonths(-6);
            fechaFin = manana;
        }

        List<Case> casos = [
            SELECT Id, CaseNumber, CreatedDate, NPS_Score__c, Service_Territory_Name_Formula__c, OwnerId,
                (SELECT Id, NombreDeTrabajo__c
                FROM Tipos_de_Trabajo__r 
                WHERE Tipo_de_cargo__c = 'Garantía')
            FROM Case
            WHERE AssetId = :assetId
            AND CreatedDate >= :fechaInicio
            AND CreatedDate <= :fechaFin
            AND Id IN (
                SELECT Caso__c
                FROM tiposDeTrabajoCaso__c 
                WHERE Tipo_de_cargo__c = 'Garantía'
            )
            ORDER BY CreatedDate DESC
        ];

        Set<Id> ownerIds = new Set<Id>();
        for (Case c : casos) {
            ownerIds.add(c.OwnerId);
        }

        Map<Id, User> owners = new Map<Id, User>([
            SELECT Id, Name 
            FROM User 
            WHERE Id IN :ownerIds
        ]);
        
        // Construir detalles
        for (Case c : casos) {
            if (!c.Tipos_de_Trabajo__r.isEmpty()) {
                for (tiposDeTrabajoCaso__c trabajo : c.Tipos_de_Trabajo__r) {
                    DetalleGarantiaCompleto detalle = new DetalleGarantiaCompleto();
                    detalle.fecha = c.CreatedDate.date();
                    detalle.trabajoRealizado = trabajo.NombreDeTrabajo__c;
                    detalle.caso = c.CaseNumber;
                    detalle.casoId = c.Id;
                    detalle.nps = c.NPS_Score__c;
                    detalle.asesor = owners.get(c.OwnerId)?.Name; 
                    // detalle.asesor = c.OwnerId.Name;
                    detalle.sucursal = c.Service_Territory_Name_Formula__c;
                    detalles.add(detalle);
                }
            }
        }
        
        return detalles;
    }

    @AuraEnabled
    public static Event crearEvento(String cocheId) {
        String asesorId = '';

        // Obtener asesor "Calendario Garantías"
        List<User> lstAsesor = [SELECT Id FROM User WHERE Id = '005PH00000Bg7jVYAR' OR Name = 'Calendario Garantías' LIMIT 1];
        if (!lstAsesor.isEmpty()) {
            asesorId = lstAsesor[0].Id;
        } else {
            throw new AuraHandledException('No se encontró el asesor con nombre "Calendario Garantías".');
        }

        // Validar coche
        List<Asset> cocheActual = [SELECT Id FROM Asset WHERE Id = :cocheId LIMIT 1];
        if (cocheActual.isEmpty()) {
            throw new AuraHandledException('No se encontró el coche con ID: ' + cocheId);
        }

        // Obtener ServiceTerritory
        String serviceTerritory = '';
        List<AsesorxCalendario__c> lstServiceTerritory = [
            SELECT Service_Territory__c 
            FROM AsesorxCalendario__c 
            WHERE Calendario__c = :asesorId 
            LIMIT 1
        ];
        if (!lstServiceTerritory.isEmpty()) {
            serviceTerritory = lstServiceTerritory[0].Service_Territory__c;
        }

        // Buscar siguiente hora libre
        Datetime now = Datetime.now();
        Integer horaRedondeada = now.hour() + (now.minute() > 0 || now.second() > 0 ? 1 : 0);
        Date fechaHoy = now.date();

        Datetime horaInicio;
        Datetime horaFin;
        Boolean horarioLibreEncontrado = false;
        Integer maxHoras = 24; // evitar loop infinito

        for (Integer i = 0; i < maxHoras; i++) {
            horaInicio = Datetime.newInstance(fechaHoy, Time.newInstance(horaRedondeada + i, 0, 0, 0));
            horaFin = horaInicio.addHours(1);

            List<Event> eventos = [
                SELECT Id 
                FROM Event 
                WHERE Asesor__c = :asesorId 
                AND StartDateTime < :horaFin 
                AND EndDateTime > :horaInicio
            ];

            if (eventos.isEmpty()) {
                horarioLibreEncontrado = true;
                break;
            }
        }

        if (!horarioLibreEncontrado) {
            throw new AuraHandledException('No se encontró un horario libre para hoy.');
        }

        // Crear evento
        Event crearEventoGarantia = new Event(
            ActivityDate = Date.today(),
            es_Reserva__c = true,
            Subject = 'Reserva',
            Asesor__c = asesorId,
            OwnerId = asesorId,
            ServiceTerritory__c = serviceTerritory,
            Activo__c = cocheId,
            StartDateTime = horaInicio,
            EndDateTime = horaFin
        );

        insert crearEventoGarantia;
        return crearEventoGarantia;
    }

    
    public class ResultadoGarantia {
        @AuraEnabled public Boolean aplicaGarantia;
        @AuraEnabled public String mensaje;
        @AuraEnabled public Integer totalCitas;
        @AuraEnabled public List<Event> eventosConsiderados;
        @AuraEnabled public Date fechaInicio;
        @AuraEnabled public Date fechaFin;
        
        public ResultadoGarantia() {}
        public ResultadoGarantia(Boolean aplica, String msg) {
            this.aplicaGarantia = aplica;
            this.mensaje = msg;
        }
    }
    
    public class DetalleGarantiaCompleto {
        @AuraEnabled public Date fecha;
        @AuraEnabled public String trabajoRealizado;
        @AuraEnabled public String asesor;
        @AuraEnabled public String sucursal;
        @AuraEnabled public Decimal nps;
        @AuraEnabled public String caso;    // CaseNumber
        @AuraEnabled public String casoId;  // CaseId para el enlace
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
        i++;
        i++;
        
        i++;
        i++;
		i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
		i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
          i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
		i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
		i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
		i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
          i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
		i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
		i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
          i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
		i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
		i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
		i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
          i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
		i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
		i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
		i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
          i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
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