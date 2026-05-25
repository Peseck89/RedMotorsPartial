/**
 * TimeSheetService
 * Servicio central para gestion de TimeSheet / TimeSheetEntry (FSL estandar).
 * Coexiste con Registro_de_Tiempo__c (custom) sin interferir con flows existentes.
 *
 * @author Red Motors Development Team
 */
public with sharing class TimeSheetService {

    // ============================================================================
    // CONSTANTS - TimeSheet Status (FSL standard)
    // ============================================================================
    public static final String TS_STATUS_NEW       = 'Borrador';
    public static final String TS_STATUS_SUBMITTED = 'En Progreso';
    public static final String TS_STATUS_APPROVED  = 'Terminado';

    // ============================================================================
    // CONSTANTS - TimeSheetEntry Type (standard field)
    // ============================================================================
    public static final String TSE_TYPE_PRODUCTIVO    = 'Tiempo productivo';
    public static final String TSE_TYPE_NO_PRODUCTIVO = 'Tiempo no productivo';
    public static final String TSE_TYPE_MUERTO        = 'Tiempo muerto';
    public static final String TSE_TYPE_PERSONAL      = 'Tiempo personal';

    // ============================================================================
    // CONSTANTS - Detalle Tipo Entrada (custom picklist)
    // ============================================================================
    public static final String DETALLE_TRABAJO    = 'Trabajo';
    public static final String DETALLE_PAUSA      = 'Pausa';
    public static final String DETALLE_RETRABAJO  = 'Retrabajo';
    public static final String DETALLE_LIMPIEZA   = 'Limpieza';
    public static final String DETALLE_VACACIONES  = 'Vacaciones';
    public static final String DETALLE_ENFERMEDAD  = 'Dia de enfermedad';
    public static final String DETALLE_PERSONAL    = 'Ausencia personal';
    public static final String DETALLE_CAPACITACION = 'Capacitacion';
    public static final String DETALLE_OTRA        = 'Otra ausencia';

    // ============================================================================
    // CONSTANTS - Tipo de Etapa (custom picklist)
    // ============================================================================
    public static final String ETAPA_TRABAJO = 'Trabajo';
    public static final String ETAPA_PAUSA   = 'Pausa';

    // ============================================================================
    // CONSTANTS - Mapeo Motivo de Pausa → Type
    // Pausas (tiempo no productivo) vs Tiempos muertos
    // ============================================================================
    private static final Set<String> MOTIVOS_PAUSA = new Set<String>{
        'Almuerzo', 'Café', 'Reuniones', 'Médico de empresa'
    };
    private static final Set<String> MOTIVOS_TIEMPO_MUERTO = new Set<String>{
        'Elaboración de presupuesto', 'Espera de repuesto',
        'Espera de asignación', 'Limpieza', 'Cambio de vehículo', 'Cambio de tarea'
    };

    /**
     * Determina el Type de TSE basado en el motivo de pausa.
     * Pausas personales → Tiempo no productivo
     * Tiempos muertos (esperas, etc.) → Tiempo muerto
     */
    public static String getTypeForMotivoPausa(String motivoPausa) {
        if (String.isBlank(motivoPausa)) return TSE_TYPE_MUERTO;
        if (MOTIVOS_PAUSA.contains(motivoPausa)) return TSE_TYPE_NO_PRODUCTIVO;
        if (MOTIVOS_TIEMPO_MUERTO.contains(motivoPausa)) return TSE_TYPE_MUERTO;
        return TSE_TYPE_MUERTO; // default para motivos no mapeados
    }

    // ============================================================================
    // CONSTANTS - Estado Revision (custom picklist on TimeSheet)
    // ============================================================================
    public static final String REVISION_PENDIENTE = 'Pendiente';
    public static final String REVISION_APROBADO  = 'Aprobado';
    public static final String REVISION_RECHAZADO = 'Rechazado';

    // ============================================================================
    // CONSTANTS - Jornada laboral estándar
    // ============================================================================
    public static final Integer WORK_START_HOUR   = 7;   // 7:00 AM
    public static final Integer WORK_START_MINUTE = 0;
    public static final Integer WORK_END_HOUR     = 17;  // 5:00 PM
    public static final Integer WORK_END_MINUTE   = 0;

    // ============================================================================
    // HELPERS: Bilingual status comparison (English API vs Spanish custom labels)
    // ============================================================================

    /**
     * Checks if status represents New/Borrador (handles both English API and Spanish custom values).
     */
    public static Boolean isStatusNew(String status) {
        return status == 'New' || status == TS_STATUS_NEW;
    }

    /**
     * Checks if status represents Submitted/En Progreso (handles both English API and Spanish custom values).
     */
    public static Boolean isStatusSubmitted(String status) {
        return status == 'Submitted' || status == TS_STATUS_SUBMITTED;
    }

    /**
     * Checks if status represents Approved/Terminado (handles both English API and Spanish custom values).
     */
    public static Boolean isStatusApproved(String status) {
        return status == 'Approved' || status == TS_STATUS_APPROVED;
    }

    // ============================================================================
    // STATIC: Alert data from last DailyTimeSheetProcessor run
    // ============================================================================
    private static List<Map<String, String>> lastRunAlerts = new List<Map<String, String>>();

    /**
     * Returns alert data from the last createDailyTimeSheets() call.
     * Each map has keys: mechanicName, tsId, tsStatus
     */
    public static List<Map<String, String>> getLastRunAlerts() {
        return lastRunAlerts;
    }

    // ============================================================================
    // PUBLIC METHODS
    // ============================================================================

    /**
     * Obtiene o crea el TimeSheet del dia para un ServiceResource.
     * @param serviceResourceId ID del ServiceResource (mecanico)
     * @return Id del TimeSheet existente o recien creado
     */
    public static Id getOrCreateTimeSheetForToday(Id serviceResourceId) {
        if (serviceResourceId == null) {
            return null;
        }
        return new TimeSheetCreator().getOrCreate(serviceResourceId);
    }

    /**
     * Crea una TimeSheetEntry vinculada al TimeSheet del dia.
     * Overload sin saId (backwards compatible).
     */
    public static Id createTimeSheetEntry(Id srId, DateTime startTime, DateTime endTime,
            String type, String detalle, String tipoEtapa, String motivoPausa,
            Integer ciclo, Id woId, Id woliId) {
        return createTimeSheetEntry(srId, startTime, endTime, type, detalle,
            tipoEtapa, motivoPausa, ciclo, woId, woliId, null);
    }

    /**
     * Crea una TimeSheetEntry vinculada al TimeSheet del dia.
     * @param srId ServiceResource ID
     * @param startTime Inicio de la entrada
     * @param endTime Fin de la entrada (null si abierta)
     * @param type Tipo estandar (Tiempo productivo, Tiempo muerto, etc.)
     * @param detalle Detalle tipo entrada (Trabajo, Pausa, Retrabajo, etc.)
     * @param tipoEtapa Tipo de etapa (Trabajo o Pausa)
     * @param motivoPausa Motivo de pausa (solo si tipoEtapa = Pausa)
     * @param ciclo Numero de ciclo
     * @param woId Work Order ID (opcional, para Subject)
     * @param woliId Work Order Line Item ID (opcional, para Subject)
     * @param saId Service Appointment ID (opcional, Lookup directo TSE → SA)
     * @return Id de la TimeSheetEntry creada
     */
    public static Id createTimeSheetEntry(Id srId, DateTime startTime, DateTime endTime,
            String type, String detalle, String tipoEtapa, String motivoPausa,
            Integer ciclo, Id woId, Id woliId, Id saId) {
        if (srId == null) {
            return null;
        }
        return new TimeSheetEntryCreator().createEntry(srId, startTime, endTime,
            type, detalle, tipoEtapa, motivoPausa, ciclo, woId, woliId, saId);
    }

    /**
     * Cierra la TimeSheetEntry abierta (sin EndTime) del tipo especificado.
     * @param srId ServiceResource ID
     * @param tipoEtapa Tipo de etapa a cerrar (Trabajo o Pausa), null para cerrar cualquiera
     */
    public static void closeOpenTimeSheetEntry(Id srId, String tipoEtapa) {
        if (srId == null) {
            return;
        }
        new TimeSheetEntryCreator().closeOpenEntry(srId, tipoEtapa);
    }

    /**
     * Obtiene el ServiceResource del usuario logueado.
     * @return Id del ServiceResource, null si no existe
     */
    public static Id getCurrentMecanicoId() {
        try {
            Id currentUserId = UserInfo.getUserId();
            List<ServiceResource> recursos = [
                SELECT Id
                FROM ServiceResource
                WHERE RelatedRecordId = :currentUserId
                AND IsActive = true
                LIMIT 1
            ];
            return recursos.isEmpty() ? null : recursos[0].Id;
        } catch (Exception e) {
            return null;
        }
    }

    /**
     * Crea TimeSheets diarios para todos los mecanicos activos.
     * Usado por TimeSheetDailyScheduler.
     * @return Map con contadores: created, skipped, alerts, absenceEntries
     */
    public static Map<String, Integer> createDailyTimeSheets() {
        return new DailyTimeSheetProcessor().process();
    }

    // ============================================================================
    // APPROVAL METHODS
    // ============================================================================

    /**
     * Marca un TimeSheet como aprobado por el lider.
     * Solo aplica si el TS esta en Terminado con Estado_Revision = Pendiente.
     * @param tsId TimeSheet ID
     */
    @AuraEnabled
    public static void approveTimeSheet(Id tsId) {
        new TimeSheetApprovalHandler().approve(new List<Id>{ tsId });
    }

    /**
     * Aprueba multiples TimeSheets de forma masiva.
     * @param tsIds Lista de TimeSheet IDs
     */
    @AuraEnabled
    public static void approveTimeSheetsBulk(List<Id> tsIds) {
        if (tsIds == null || tsIds.isEmpty()) return;
        new TimeSheetApprovalHandler().approve(tsIds);
    }

    /**
     * Rechaza un TimeSheet. Lo devuelve a En Progreso para correccion.
     * @param tsId TimeSheet ID
     * @param reason Motivo del rechazo
     */
    @AuraEnabled
    public static void rejectTimeSheet(Id tsId, String reason) {
        new TimeSheetApprovalHandler().reject(tsId, reason);
    }

    /**
     * Marca un TimeSheet como pendiente de revision (llamado al marcar salida).
     * @param tsId TimeSheet ID
     */
    public static void submitForReview(Id tsId) {
        if (tsId == null) return;
        new TimeSheetApprovalHandler().submitForReview(tsId);
    }

    /**
     * Obtiene el ServiceTerritory del usuario actual (via ServiceResource → STM).
     * @return Map con id, name del territorio, o null si no tiene
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, String> getCurrentUserTerritory() {
        Id userId = UserInfo.getUserId();
        List<ServiceResource> srs = [
            SELECT Id FROM ServiceResource
            WHERE RelatedRecordId = :userId AND IsActive = true LIMIT 1
        ];
        if (srs.isEmpty()) return null;

        Date today = Date.today();
        Id srId = srs[0].Id;
        List<ServiceTerritoryMember> stms = [
            SELECT ServiceTerritoryId, ServiceTerritory.Name
            FROM ServiceTerritoryMember
            WHERE ServiceResourceId = :srId
            AND EffectiveStartDate <= :today
            AND (EffectiveEndDate = null OR EffectiveEndDate >= :today)
            ORDER BY TerritoryType DESC
            LIMIT 1
        ];
        if (stms.isEmpty()) return null;

        return new Map<String, String>{
            'id' => stms[0].ServiceTerritoryId,
            'name' => stms[0].ServiceTerritory.Name
        };
    }

    /**
     * Obtiene las TimeSheetEntries detalladas de un TimeSheet.
     * @param timeSheetId ID del TimeSheet
     * @return Lista de TSE wrappers
     */
    @AuraEnabled
    public static List<TimeSheetEntryDetail> getTimeSheetEntries(Id timeSheetId) {
        if (timeSheetId == null) return new List<TimeSheetEntryDetail>();

        List<TimeSheetEntry> entries = [
            SELECT Id, Subject, StartTime, EndTime, Type,
                   Tipo_de_Etapa__c, Detalle_Tipo_Entrada__c, Motivo_de_Pausa__c,
                   Ciclo__c, WorkOrderLineItemId, WorkOrderId
            FROM TimeSheetEntry
            WHERE TimeSheetId = :timeSheetId
            ORDER BY StartTime ASC
        ];

        List<TimeSheetEntryDetail> details = new List<TimeSheetEntryDetail>();
        for (TimeSheetEntry tse : entries) {
            TimeSheetEntryDetail d = new TimeSheetEntryDetail();
            d.id = tse.Id;
            d.subject = tse.Subject;
            d.startTime = tse.StartTime;
            d.endTime = tse.EndTime;
            d.type = tse.Type;
            d.tipoEtapa = tse.Tipo_de_Etapa__c;
            d.detalle = tse.Detalle_Tipo_Entrada__c;
            d.motivoPausa = tse.Motivo_de_Pausa__c;
            d.ciclo = tse.Ciclo__c != null ? Integer.valueOf(tse.Ciclo__c) : null;
            d.isClosed = tse.EndTime != null;
            if (tse.StartTime != null && tse.EndTime != null) {
                d.duracionMin = (tse.EndTime.getTime() - tse.StartTime.getTime()) / 60000.0;
            }
            details.add(d);
        }
        return details;
    }

    /**
     * Actualiza las horas de ingreso/salida de un TimeSheet (correccion del lider).
     * @param tsId TimeSheet ID
     * @param horaIngreso Hora de ingreso ("HH:mm")
     * @param horaSalida Hora de salida ("HH:mm") - puede ser null
     */
    @AuraEnabled
    public static void updateTimeSheetHours(Id tsId, String horaIngreso, String horaSalida) {
        new TimeSheetApprovalHandler().updateHours(tsId, horaIngreso, horaSalida);
    }

    // ============================================================================
    // WRAPPER CLASS: TimeSheetEntryDetail
    // ============================================================================

    public class TimeSheetEntryDetail {
        @AuraEnabled public Id id;
        @AuraEnabled public String subject;
        @AuraEnabled public DateTime startTime;
        @AuraEnabled public DateTime endTime;
        @AuraEnabled public String type;
        @AuraEnabled public String tipoEtapa;
        @AuraEnabled public String detalle;
        @AuraEnabled public String motivoPausa;
        @AuraEnabled public Integer ciclo;
        @AuraEnabled public Boolean isClosed;
        @AuraEnabled public Decimal duracionMin;
    }

    /**
     * Obtiene los TimeSheets de un territorio para una fecha dada.
     * Usado por el componente de gestion del lider.
     * @param serviceTerritoryId ID del ServiceTerritory
     * @param targetDate Fecha objetivo
     * @return Lista de TimeSheets con datos del mecanico y entradas
     */
    @AuraEnabled(cacheable=true)
    public static List<TimeSheetSummary> getTimeSheetsForTerritory(Id serviceTerritoryId, Date targetDate) {
        return new TimeSheetQueryHandler().getForTerritory(serviceTerritoryId, targetDate);
    }

    // ============================================================================
    // WRAPPER CLASS: TimeSheetSummary (for leader component)
    // ============================================================================

    public class TimeSheetSummary {
        @AuraEnabled public Id timeSheetId;
        @AuraEnabled public String mecanicoName;
        @AuraEnabled public Id serviceResourceId;
        @AuraEnabled public String status;
        @AuraEnabled public String estadoRevision;
        @AuraEnabled public String comentarioRechazo;
        @AuraEnabled public String horaIngreso;
        @AuraEnabled public String horaSalida;
        @AuraEnabled public Decimal horasLaboradas;
        @AuraEnabled public Decimal totalTrabajoMin;
        @AuraEnabled public Decimal totalPausaMin;
        @AuraEnabled public Integer totalEntries;
        @AuraEnabled public Date fecha;
    }

    /**
     * Recalcula los tiempos acumulados de un WOLI a partir de TimeSheetEntry.
     * Suma duraciones agrupando por Tipo_de_Etapa__c y Detalle_Tipo_Entrada__c.
     * Actualiza los campos Total_Trabajo_Min__c, Total_Pausa_Min__c, Total_Retrabajo_Min__c en el WOLI.
     * @param woliId WorkOrderLineItem ID (filtro de TSEs y destino del update)
     * @param saId ServiceAppointment ID (ya no se usa para escribir, se mantiene por compatibilidad)
     */
    public static void recalculateAccumulatedTime(Id woliId, Id saId) {
        if (woliId == null) {
            return;
        }
        new AccumulatedTimeCalculator().recalculate(woliId);
    }

    // ============================================================================
    // INNER CLASS: TimeSheetCreator (without sharing for elevated DML)
    // ============================================================================

    private without sharing class TimeSheetCreator {

        public Id getOrCreate(Id serviceResourceId) {
            Date today = Date.today();
            Date tomorrow = today.addDays(1);

            // Buscar TimeSheet existente para hoy
            List<TimeSheet> existing = [
                SELECT Id, Status
                FROM TimeSheet
                WHERE ServiceResourceId = :serviceResourceId
                AND StartDate = :today
                ORDER BY CreatedDate DESC
                LIMIT 1
            ];

            if (!existing.isEmpty()) {
                return existing[0].Id;
            }

            // Obtener el User Id del ServiceResource para asignar como Owner
            List<ServiceResource> srs = [SELECT RelatedRecordId FROM ServiceResource WHERE Id = :serviceResourceId LIMIT 1];

            // Crear nuevo TimeSheet
            TimeSheet ts = new TimeSheet();
            ts.ServiceResourceId = serviceResourceId;
            ts.StartDate = today;
            ts.EndDate = tomorrow;
            ts.Status = TS_STATUS_NEW;
            if (!srs.isEmpty() && srs[0].RelatedRecordId != null) {
                ts.OwnerId = srs[0].RelatedRecordId;
            }
            insert ts;

            // Share with leaders
            shareTimeSheetWithLeaders(ts);

            return ts.Id;
        }

        private void shareTimeSheetWithLeaders(TimeSheet ts) {
            try {
                List<PermissionSetAssignment> liderPSAs = [
                    SELECT AssigneeId
                    FROM PermissionSetAssignment
                    WHERE PermissionSet.Name = 'RM_Lider_Taller'
                    AND Assignee.IsActive = true
                ];
                List<TimeSheetShare> shares = new List<TimeSheetShare>();
                for (PermissionSetAssignment psa : liderPSAs) {
                    if (psa.AssigneeId == ts.OwnerId) continue;
                    shares.add(new TimeSheetShare(
                        ParentId = ts.Id,
                        UserOrGroupId = psa.AssigneeId,
                        AccessLevel = 'Edit',
                        RowCause = Schema.TimeSheetShare.RowCause.Manual
                    ));
                }
                if (!shares.isEmpty()) {
                    insert shares;
                }
            } catch (Exception e) {
            }
        }
    }

    // ============================================================================
    // INNER CLASS: TimeSheetEntryCreator (without sharing for elevated DML)
    // ============================================================================

    private without sharing class TimeSheetEntryCreator {

        public Id createEntry(Id srId, DateTime startTime, DateTime endTime,
                String type, String detalle, String tipoEtapa, String motivoPausa,
                Integer ciclo, Id woId, Id woliId, Id saId) {

            // Obtener o crear el TimeSheet del dia
            Id tsId = new TimeSheetCreator().getOrCreate(srId);
            if (tsId == null) {
                return null;
            }

            // Construir Subject descriptivo
            String subject = buildSubject(detalle, tipoEtapa, motivoPausa, woId, woliId, saId);

            // Crear TimeSheetEntry
            TimeSheetEntry tse = new TimeSheetEntry();
            tse.TimeSheetId = tsId;
            tse.StartTime = startTime != null ? startTime : DateTime.now();
            tse.EndTime = endTime;
            tse.Subject = subject;

            // Intentar setear Type (campo estandar - puede tener valores restringidos)
            setFieldSafe(tse, 'Type', type);

            // Standard FSL lookups
            if (woliId != null) {
                tse.WorkOrderLineItemId = woliId;
            }
            if (woId != null) {
                tse.WorkOrderId = woId;
            }

            // Campos custom
            setFieldSafe(tse, 'Tipo_de_Etapa__c', tipoEtapa);
            setFieldSafe(tse, 'Detalle_Tipo_Entrada__c', detalle);
            setFieldSafe(tse, 'Motivo_de_Pausa__c', motivoPausa);
            setFieldSafe(tse, 'Ciclo__c', ciclo != null ? ciclo : 1);

            // Lookup a ServiceAppointment (opcional)
            setFieldSafe(tse, 'ServiceAppointment__c', saId);

            insert tse;

            return tse.Id;
        }

        public void closeOpenEntry(Id srId, String tipoEtapa) {
            Date today = Date.today();

            // Buscar TSE abierta (sin EndTime) del TimeSheet de hoy
            String query = 'SELECT Id, StartTime FROM TimeSheetEntry ' +
                'WHERE TimeSheet.ServiceResourceId = :srId ' +
                'AND TimeSheet.StartDate = :today ' +
                'AND EndTime = null';

            if (String.isNotBlank(tipoEtapa) && fieldExistsOnTSE('Tipo_de_Etapa__c')) {
                query += ' AND Tipo_de_Etapa__c = :tipoEtapa';
            }

            query += ' ORDER BY StartTime DESC LIMIT 1';

            List<TimeSheetEntry> openEntries = Database.query(query);

            if (!openEntries.isEmpty()) {
                TimeSheetEntry tse = openEntries[0];
                tse.EndTime = DateTime.now();
                update tse;
            }
        }

        private String buildSubject(String detalle, String tipoEtapa, String motivoPausa,
                Id woId, Id woliId, Id saId) {
            String subject = '';

            if (String.isNotBlank(detalle)) {
                subject = detalle;
            } else if (String.isNotBlank(tipoEtapa)) {
                subject = tipoEtapa;
            }

            if (String.isNotBlank(motivoPausa)) {
                subject += ' - ' + motivoPausa;
            }

            // Agregar numero de SA (ej: SA-11759)
            if (saId != null) {
                try {
                    List<ServiceAppointment> saList = [
                        SELECT AppointmentNumber FROM ServiceAppointment WHERE Id = :saId LIMIT 1
                    ];
                    if (!saList.isEmpty() && saList[0].AppointmentNumber != null) {
                        subject += ' ' + saList[0].AppointmentNumber;
                    }
                } catch (Exception e) {
                    // Si falla, no bloquear la creacion
                }
            }

            return subject.left(255);
        }

        private void setFieldSafe(SObject record, String fieldName, Object value) {
            try {
                if (value != null) {
                    record.put(fieldName, value);
                }
            } catch (Exception e) {
            }
        }

        private Boolean fieldExistsOnTSE(String fieldName) {
            try {
                Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.TimeSheetEntry
                    .fields.getMap();
                return fieldMap.containsKey(fieldName.toLowerCase());
            } catch (Exception e) {
                return false;
            }
        }
    }

    // ============================================================================
    // INNER CLASS: DailyTimeSheetProcessor (without sharing for Scheduler)
    // ============================================================================

    private without sharing class DailyTimeSheetProcessor {

        public Map<String, Integer> process() {
            lastRunAlerts = new List<Map<String, String>>();

            Map<String, Integer> counters = new Map<String, Integer>{
                'created' => 0,
                'skipped' => 0,
                'alerts' => 0,
                'absenceEntries' => 0,
                'skippedNonWorking' => 0
            };

            Date today = Date.today();
            Date tomorrow = today.addDays(1);
            DateTime startOfDayDT = DateTime.newInstance(today, Time.newInstance(0, 0, 0, 0));
            DateTime endOfDayDT = DateTime.newInstance(tomorrow, Time.newInstance(0, 0, 0, 0));

            // 1. Obtener todos los ServiceResource activos (mecanicos)
            List<ServiceResource> activeResources = [
                SELECT Id, Name, RelatedRecordId
                FROM ServiceResource
                WHERE IsActive = true
                AND ResourceType = 'T'
            ];

            if (activeResources.isEmpty()) {
                return counters;
            }

            Set<Id> srIds = new Set<Id>();
            for (ServiceResource sr : activeResources) {
                srIds.add(sr.Id);
            }

            // 1b. Filter mechanics by Operating Hours — skip non-working days
            Set<Id> workingSrIds = getWorkingMechanicsForDate(srIds, today);
            Set<Id> skippedSrIds = new Set<Id>();
            for (Id srId : srIds) {
                if (!workingSrIds.contains(srId)) {
                    skippedSrIds.add(srId);
                }
            }
            counters.put('skippedNonWorking', skippedSrIds.size());

            // 2. Buscar TimeSheets existentes para hoy
            Map<Id, TimeSheet> existingTSBySR = new Map<Id, TimeSheet>();
            for (TimeSheet ts : [
                SELECT Id, ServiceResourceId, Status
                FROM TimeSheet
                WHERE ServiceResourceId IN :srIds
                AND StartDate = :today
            ]) {
                existingTSBySR.put(ts.ServiceResourceId, ts);
            }

            // 3. Buscar ResourceAbsences para hoy
            Map<Id, List<ResourceAbsence>> absencesBySR = new Map<Id, List<ResourceAbsence>>();
            String absQuery = 'SELECT Id, ResourceId, Start, End, Type';
            if (fieldExistsOnRA('Clasificacion__c')) {
                absQuery += ', Clasificacion__c';
            }
            absQuery += ' FROM ResourceAbsence WHERE ResourceId IN :srIds ' +
                'AND Start < :endOfDayDT AND End > :startOfDayDT';

            for (ResourceAbsence ra : Database.query(absQuery)) {
                if (!absencesBySR.containsKey(ra.ResourceId)) {
                    absencesBySR.put(ra.ResourceId, new List<ResourceAbsence>());
                }
                absencesBySR.get(ra.ResourceId).add(ra);
            }

            // 4. Procesar cada mecanico
            List<TimeSheet> tsToInsert = new List<TimeSheet>();
            Map<Id, Id> srToNewTS = new Map<Id, Id>();

            for (ServiceResource sr : activeResources) {
                // Skip mechanics on non-working days
                if (skippedSrIds.contains(sr.Id)) {
                    counters.put('skipped', counters.get('skipped') + 1);
                    continue;
                }

                TimeSheet existingTS = existingTSBySR.get(sr.Id);

                if (existingTS != null) {
                    if (existingTS.Status == TS_STATUS_NEW) {
                        // Ya existe en New -> skip
                        counters.put('skipped', counters.get('skipped') + 1);
                    } else {
                        // Existe en otro status -> log alerta y guardar datos
                        counters.put('alerts', counters.get('alerts') + 1);
                        lastRunAlerts.add(new Map<String, String>{
                            'mechanicName' => sr.Name,
                            'tsId' => existingTS.Id,
                            'tsStatus' => existingTS.Status
                        });
                    }
                    continue;
                }

                // Crear nuevo TimeSheet (Owner = mecanico para visibilidad)
                TimeSheet ts = new TimeSheet();
                ts.ServiceResourceId = sr.Id;
                ts.StartDate = today;
                ts.EndDate = tomorrow;
                ts.Status = TS_STATUS_NEW;
                if (sr.RelatedRecordId != null) {
                    ts.OwnerId = sr.RelatedRecordId;
                }
                tsToInsert.add(ts);
            }

            if (!tsToInsert.isEmpty()) {
                insert tsToInsert;
                counters.put('created', tsToInsert.size());

                for (TimeSheet ts : tsToInsert) {
                    srToNewTS.put(ts.ServiceResourceId, ts.Id);
                }

                // 4b. Share new TimeSheets with territory leaders (RM_Lider_Taller PS users)
                shareTimeSheetsWithLeaders(tsToInsert);
            }

            // 5. Crear TSEs de ausencia para los TS recien creados
            List<TimeSheetEntry> tseToInsert = new List<TimeSheetEntry>();

            for (Id srId : srToNewTS.keySet()) {
                List<ResourceAbsence> absences = absencesBySR.get(srId);
                if (absences == null || absences.isEmpty()) continue;

                Id tsId = srToNewTS.get(srId);

                for (ResourceAbsence ra : absences) {
                    // Calcular interseccion con el dia de hoy
                    DateTime tseStart = ra.Start < startOfDayDT ? startOfDayDT : ra.Start;
                    DateTime tseEnd = ra.End > endOfDayDT ? endOfDayDT : ra.End;

                    TimeSheetEntry tse = new TimeSheetEntry();
                    tse.TimeSheetId = tsId;
                    tse.StartTime = tseStart;
                    tse.EndTime = tseEnd;
                    tse.Subject = 'Ausencia: ' + (ra.Type != null ? ra.Type : 'Sin tipo');

                    // Clasificacion desde el campo custom
                    String clasificacion = TSE_TYPE_PERSONAL; // default
                    try {
                        Object clasVal = ra.get('Clasificacion__c');
                        if (clasVal != null) {
                            clasificacion = String.valueOf(clasVal);
                        }
                    } catch (Exception e) {
                        // Campo no existe, usar default
                    }
                    setFieldSafe(tse, 'Type', clasificacion);

                    // Detalle basado en el tipo de ausencia
                    String detalle = mapAbsenceTypeToDetalle(ra.Type);
                    setFieldSafe(tse, 'Detalle_Tipo_Entrada__c', detalle);
                    setFieldSafe(tse, 'Tipo_de_Etapa__c', ETAPA_PAUSA);
                    setFieldSafe(tse, 'Ciclo__c', 1);

                    tseToInsert.add(tse);
                }

                // Si la ausencia cubre toda la jornada, marcar TS como Submitted
                if (coversFullDay(absences, startOfDayDT, endOfDayDT)) {
                    TimeSheet ts = new TimeSheet(Id = tsId);
                    ts.Status = TS_STATUS_SUBMITTED;
                    update ts;
                }
            }

            if (!tseToInsert.isEmpty()) {
                insert tseToInsert;
                counters.put('absenceEntries', tseToInsert.size());
            }

            return counters;
        }

        private String mapAbsenceTypeToDetalle(String absenceType) {
            if (String.isBlank(absenceType)) return DETALLE_OTRA;

            String typeLower = absenceType.toLowerCase();
            if (typeLower.contains('vacation') || typeLower.contains('vacacion')) return DETALLE_VACACIONES;
            if (typeLower.contains('sick') || typeLower.contains('enfermedad')) return DETALLE_ENFERMEDAD;
            if (typeLower.contains('personal')) return DETALLE_PERSONAL;
            if (typeLower.contains('training') || typeLower.contains('capacitacion')) return DETALLE_CAPACITACION;
            return DETALLE_OTRA;
        }

        private Boolean coversFullDay(List<ResourceAbsence> absences, DateTime dayStart, DateTime dayEnd) {
            // Simplified: if any single absence covers the full day
            for (ResourceAbsence ra : absences) {
                if (ra.Start <= dayStart && ra.End >= dayEnd) {
                    return true;
                }
            }
            return false;
        }

        /**
         * Returns the set of SR Ids that belong to a territory with operating hours
         * configured for the given date. Mechanics without a territory or whose
         * territory has no OperatingHours are included (treated as no limit).
         */
        private Set<Id> getWorkingMechanicsForDate(Set<Id> srIds, Date targetDate) {
            Set<Id> result = new Set<Id>();
            if (srIds == null || srIds.isEmpty()) return result;

            // Get territory memberships active on targetDate
            Map<Id, Set<Id>> srToTerritoryIds = new Map<Id, Set<Id>>();
            Set<Id> allTerritoryIds = new Set<Id>();

            for (ServiceTerritoryMember stm : [
                SELECT ServiceResourceId, ServiceTerritoryId
                FROM ServiceTerritoryMember
                WHERE ServiceResourceId IN :srIds
                AND EffectiveStartDate <= :targetDate
                AND (EffectiveEndDate = null OR EffectiveEndDate >= :targetDate)
            ]) {
                if (!srToTerritoryIds.containsKey(stm.ServiceResourceId)) {
                    srToTerritoryIds.put(stm.ServiceResourceId, new Set<Id>());
                }
                srToTerritoryIds.get(stm.ServiceResourceId).add(stm.ServiceTerritoryId);
                allTerritoryIds.add(stm.ServiceTerritoryId);
            }

            // Get OperatingHoursId per territory
            Map<Id, Id> territoryToOH = new Map<Id, Id>();
            if (!allTerritoryIds.isEmpty()) {
                for (ServiceTerritory st : [
                    SELECT Id, OperatingHoursId
                    FROM ServiceTerritory
                    WHERE Id IN :allTerritoryIds
                ]) {
                    if (st.OperatingHoursId != null) {
                        territoryToOH.put(st.Id, st.OperatingHoursId);
                    }
                }
            }

            // Collect unique OH Ids and check for TimeSlots on the target day
            Set<Id> ohIds = new Set<Id>(territoryToOH.values());
            Set<Id> workingOHIds = new Set<Id>();
            String dayName = getDayOfWeekString(targetDate);

            if (!ohIds.isEmpty()) {
                for (TimeSlot ts : [
                    SELECT OperatingHoursId
                    FROM TimeSlot
                    WHERE OperatingHoursId IN :ohIds
                    AND DayOfWeek = :dayName
                    LIMIT 200
                ]) {
                    workingOHIds.add(ts.OperatingHoursId);
                }
            }

            // Determine which SRs are working
            for (Id srId : srIds) {
                Set<Id> territories = srToTerritoryIds.get(srId);

                // No territory → include (no limit)
                if (territories == null || territories.isEmpty()) {
                    result.add(srId);
                    continue;
                }

                // Check if at least one territory operates today
                Boolean hasWorkingTerritory = false;
                for (Id stId : territories) {
                    Id ohId = territoryToOH.get(stId);
                    if (ohId == null) {
                        // Territory without OH → treat as no limit
                        hasWorkingTerritory = true;
                        break;
                    }
                    if (workingOHIds.contains(ohId)) {
                        hasWorkingTerritory = true;
                        break;
                    }
                }

                if (hasWorkingTerritory) {
                    result.add(srId);
                }
            }

            return result;
        }

        /**
         * Converts a Date to the English DayOfWeek string used in TimeSlot.DayOfWeek.
         * Salesforce stores DayOfWeek as 'Monday', 'Tuesday', etc.
         */
        private String getDayOfWeekString(Date d) {
            // DateTime.format('EEEE') returns English day name in GMT
            DateTime dt = DateTime.newInstance(d, Time.newInstance(12, 0, 0, 0));
            return dt.formatGMT('EEEE');
        }

        private Boolean fieldExistsOnRA(String fieldName) {
            try {
                Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.ResourceAbsence
                    .fields.getMap();
                return fieldMap.containsKey(fieldName.toLowerCase());
            } catch (Exception e) {
                return false;
            }
        }

        private void setFieldSafe(SObject record, String fieldName, Object value) {
            try {
                if (value != null) {
                    record.put(fieldName, value);
                }
            } catch (Exception e) {
            }
        }

        /**
         * Share newly created TimeSheets with users who have RM_Lider_Taller permission set.
         * This gives leaders visibility of all mechanic TimeSheets in the standard list view,
         * since TimeSheet OWD is Private (Lookup to ServiceResource, not Master-Detail).
         */
        private void shareTimeSheetsWithLeaders(List<TimeSheet> newTimeSheets) {
            try {
                // Get users with RM_Lider_Taller PS
                List<PermissionSetAssignment> liderPSAs = [
                    SELECT AssigneeId
                    FROM PermissionSetAssignment
                    WHERE PermissionSet.Name = 'RM_Lider_Taller'
                    AND Assignee.IsActive = true
                ];
                if (liderPSAs.isEmpty()) return;

                Set<Id> leaderIds = new Set<Id>();
                for (PermissionSetAssignment psa : liderPSAs) {
                    leaderIds.add(psa.AssigneeId);
                }

                // Remove TS owners from leader set (they already have access)
                Set<Id> tsOwnerIds = new Set<Id>();
                for (TimeSheet ts : newTimeSheets) {
                    tsOwnerIds.add(ts.OwnerId);
                }

                List<TimeSheetShare> sharesToInsert = new List<TimeSheetShare>();
                for (TimeSheet ts : newTimeSheets) {
                    for (Id leaderId : leaderIds) {
                        if (leaderId == ts.OwnerId) continue; // Skip owner
                        sharesToInsert.add(new TimeSheetShare(
                            ParentId = ts.Id,
                            UserOrGroupId = leaderId,
                            AccessLevel = 'Edit',
                            RowCause = Schema.TimeSheetShare.RowCause.Manual
                        ));
                    }
                }

                if (!sharesToInsert.isEmpty()) {
                    insert sharesToInsert;
                }
            } catch (Exception e) {
            }
        }
    }

    // ============================================================================
    // INNER CLASS: TimeSheetApprovalHandler (without sharing for leader operations)
    // ============================================================================

    private without sharing class TimeSheetApprovalHandler {

        public void approve(List<Id> tsIds) {
            List<TimeSheet> sheets = [
                SELECT Id, Status, Estado_Revision__c
                FROM TimeSheet
                WHERE Id IN :tsIds
            ];

            List<TimeSheet> toUpdate = new List<TimeSheet>();
            for (TimeSheet ts : sheets) {
                if (ts.Status == TS_STATUS_APPROVED && ts.Estado_Revision__c == REVISION_PENDIENTE) {
                    ts.Estado_Revision__c = REVISION_APROBADO;
                    toUpdate.add(ts);
                }
            }

            if (!toUpdate.isEmpty()) {
                update toUpdate;
            }
        }

        public void reject(Id tsId, String reason) {
            List<TimeSheet> sheets = [
                SELECT Id, Status, Estado_Revision__c
                FROM TimeSheet
                WHERE Id = :tsId
                LIMIT 1
            ];

            if (sheets.isEmpty()) return;
            TimeSheet ts = sheets[0];

            if (ts.Status != TS_STATUS_APPROVED) return;

            ts.Status = TS_STATUS_SUBMITTED;
            ts.Estado_Revision__c = REVISION_RECHAZADO;
            ts.Comentario_Rechazo__c = reason;
            update ts;
        }

        public void submitForReview(Id tsId) {
            TimeSheet ts = new TimeSheet(Id = tsId);
            ts.Estado_Revision__c = REVISION_PENDIENTE;
            update ts;
        }

        public void updateHours(Id tsId, String horaIngresoStr, String horaSalidaStr) {
            TimeSheet ts = new TimeSheet(Id = tsId);
            if (String.isNotBlank(horaIngresoStr)) {
                List<String> parts = horaIngresoStr.split(':');
                ts.Hora_de_ingreso__c = Time.newInstance(
                    Integer.valueOf(parts[0]), Integer.valueOf(parts[1]), 0, 0);
            }
            if (String.isNotBlank(horaSalidaStr)) {
                List<String> parts = horaSalidaStr.split(':');
                ts.Hora_de_salida__c = Time.newInstance(
                    Integer.valueOf(parts[0]), Integer.valueOf(parts[1]), 0, 0);
            }
            update ts;
        }
    }

    // ============================================================================
    // INNER CLASS: TimeSheetQueryHandler (with sharing for territory-based access)
    // ============================================================================

    private without sharing class TimeSheetQueryHandler {

        public List<TimeSheetSummary> getForTerritory(Id serviceTerritoryId, Date targetDate) {
            if (serviceTerritoryId == null || targetDate == null) {
                return new List<TimeSheetSummary>();
            }

            // Get active mechanics for this territory on the target date
            Set<Id> srIds = new Set<Id>();
            for (ServiceTerritoryMember stm : [
                SELECT ServiceResourceId
                FROM ServiceTerritoryMember
                WHERE ServiceTerritoryId = :serviceTerritoryId
                AND EffectiveStartDate <= :targetDate
                AND (EffectiveEndDate = null OR EffectiveEndDate >= :targetDate)
            ]) {
                srIds.add(stm.ServiceResourceId);
            }

            if (srIds.isEmpty()) {
                return new List<TimeSheetSummary>();
            }

            // Query TimeSheets for these mechanics on target date
            List<TimeSheet> sheets = [
                SELECT Id, ServiceResourceId, ServiceResource.Name, Status,
                       StartDate, Hora_de_ingreso__c, Hora_de_salida__c, Horas_laboradas__c,
                       Estado_Revision__c, Comentario_Rechazo__c,
                       (SELECT Id FROM TimeSheetEntries)
                FROM TimeSheet
                WHERE ServiceResourceId IN :srIds
                AND StartDate = :targetDate
                ORDER BY ServiceResource.Name ASC
            ];

            // Also get accumulated work/pause time from TSEs
            Map<Id, Decimal> trabajoByTS = new Map<Id, Decimal>();
            Map<Id, Decimal> pausaByTS = new Map<Id, Decimal>();
            Set<Id> tsIds = new Set<Id>();
            for (TimeSheet ts : sheets) {
                tsIds.add(ts.Id);
            }

            if (!tsIds.isEmpty()) {
                for (AggregateResult ar : [
                    SELECT TimeSheetId, Tipo_de_Etapa__c,
                           SUM(Duracion_min__c) totalMin
                    FROM TimeSheetEntry
                    WHERE TimeSheetId IN :tsIds
                    AND EndTime != null
                    GROUP BY TimeSheetId, Tipo_de_Etapa__c
                ]) {
                    Id tsId = (Id) ar.get('TimeSheetId');
                    String tipo = (String) ar.get('Tipo_de_Etapa__c');
                    Decimal total = (Decimal) ar.get('totalMin');
                    if (total == null) total = 0;

                    if (tipo == ETAPA_TRABAJO) {
                        trabajoByTS.put(tsId, total);
                    } else if (tipo == ETAPA_PAUSA) {
                        pausaByTS.put(tsId, total);
                    }
                }
            }

            // Build summaries
            List<TimeSheetSummary> summaries = new List<TimeSheetSummary>();
            for (TimeSheet ts : sheets) {
                TimeSheetSummary s = new TimeSheetSummary();
                s.timeSheetId = ts.Id;
                s.mecanicoName = ts.ServiceResource.Name;
                s.serviceResourceId = ts.ServiceResourceId;
                s.status = ts.Status;
                s.estadoRevision = ts.Estado_Revision__c;
                s.comentarioRechazo = ts.Comentario_Rechazo__c;
                s.horaIngreso = ts.Hora_de_ingreso__c != null ?
                    formatTime(ts.Hora_de_ingreso__c) : null;
                s.horaSalida = ts.Hora_de_salida__c != null ?
                    formatTime(ts.Hora_de_salida__c) : null;
                s.horasLaboradas = ts.Horas_laboradas__c;
                s.totalTrabajoMin = trabajoByTS.containsKey(ts.Id) ? trabajoByTS.get(ts.Id) : 0;
                s.totalPausaMin = pausaByTS.containsKey(ts.Id) ? pausaByTS.get(ts.Id) : 0;
                s.totalEntries = ts.TimeSheetEntries != null ? ts.TimeSheetEntries.size() : 0;
                s.fecha = ts.StartDate;
                summaries.add(s);
            }

            return summaries;
        }

        private String formatTime(Time t) {
            if (t == null) return null;
            Integer h = t.hour();
            Integer m = t.minute();
            return String.valueOf(h).leftPad(2, '0') + ':' + String.valueOf(m).leftPad(2, '0');
        }
    }

    // ============================================================================
    // INNER CLASS: AccumulatedTimeCalculator (without sharing for SA update)
    // ============================================================================

    private without sharing class AccumulatedTimeCalculator {

        public void recalculate(Id woliId) {
            Decimal trabajoMin = 0;
            Decimal pausaMin = 0;
            Decimal retrabajoMin = 0;

            List<TimeSheetEntry> entries = [
                SELECT Id, Tipo_de_Etapa__c, Detalle_Tipo_Entrada__c, StartTime, EndTime
                FROM TimeSheetEntry
                WHERE WorkOrderLineItemId = :woliId
                AND EndTime != null
            ];

            for (TimeSheetEntry tse : entries) {
                Decimal durationMin = 0;
                if (tse.StartTime != null && tse.EndTime != null) {
                    Long millisDiff = tse.EndTime.getTime() - tse.StartTime.getTime();
                    durationMin = millisDiff / 60000.0;
                }

                String detalle = tse.Detalle_Tipo_Entrada__c;
                String tipoEtapa = tse.Tipo_de_Etapa__c;

                if (detalle == DETALLE_RETRABAJO) {
                    retrabajoMin += durationMin;
                } else if (tipoEtapa == ETAPA_PAUSA) {
                    pausaMin += durationMin;
                } else if (tipoEtapa == ETAPA_TRABAJO) {
                    trabajoMin += durationMin;
                }
            }

            // Escribir acumulados directamente en el WOLI (ya no en SA)
            WorkOrderLineItem woli = new WorkOrderLineItem(Id = woliId);
            woli.put('Total_Trabajo_Min__c', trabajoMin.setScale(2));
            woli.put('Total_Pausa_Min__c', pausaMin.setScale(2));
            woli.put('Total_Retrabajo_Min__c', retrabajoMin.setScale(2));
            update woli;
        }
    }
}
