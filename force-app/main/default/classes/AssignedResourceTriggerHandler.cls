/**
 * @description Handler para validar que los recursos asignados cumplan con todos los requisitos:
 *              - Skills requeridos por el WorkType
 *              - Sin ausencias durante el horario de la cita
 *              - Dentro del horario de operación del territorio (usando timezone del Operating Hours)
 *              - Membresía activa en el territorio (desactivado)
 *              - Sin doble asignación (otra cita en el mismo horario)
 * @author RedMotors
 * @lastModifiedBy Deam Saavedra
 * @lastModifiedDate 2026-01-21
 * @changeLog Corrección en validación de Operating Hours: ahora usa el timezone configurado
 *            en Operating Hours del territorio para convertir los horarios correctamente
 */
public with sharing class AssignedResourceTriggerHandler extends TriggerHandler {

    private List<AssignedResource> newRecordList;
    private Map<Id, AssignedResource> oldRecordMap;

    // Cache para nombres de skills (evita queries repetidas)
    private static Map<Id, String> skillNameCache = new Map<Id, String>();

    public AssignedResourceTriggerHandler() {
        this.newRecordList = (List<AssignedResource>) Trigger.New;
        this.oldRecordMap = (Map<Id, AssignedResource>) Trigger.oldMap;
    }

    public override void beforeInsert() {
        validateSkillRequirements(newRecordList);
        // validateResourceAbsences(newRecordList);  // Desactivado: FSL maneja ausencias nativamente. El hard-block interfería con Dispatcher Console y agendamiento desde LWC.
        validateOperatingHours(newRecordList);  // Usa Operating Hours del territorio del RECURSO
        validateNoDoubleBooking(newRecordList);
    }

    public override void afterInsert() {
        shareWithAssignedResource(newRecordList);
        stampAssignedUserOnSA(newRecordList);
    }

    public override void beforeUpdate() {
        // Solo validar si cambió el ServiceResourceId
        List<AssignedResource> recordsToValidate = new List<AssignedResource>();
        for (AssignedResource ar : newRecordList) {
            AssignedResource oldAr = oldRecordMap.get(ar.Id);
            if (ar.ServiceResourceId != oldAr.ServiceResourceId) {
                recordsToValidate.add(ar);
            }
        }
        if (!recordsToValidate.isEmpty()) {
            validateSkillRequirements(recordsToValidate);
            // validateResourceAbsences(recordsToValidate);  // Desactivado: FSL maneja ausencias nativamente.
            validateOperatingHours(recordsToValidate);  // Usa Operating Hours del territorio del RECURSO
            validateNoDoubleBooking(recordsToValidate);
        }
    }

    /**
     * @description Valida que cada ServiceResource tenga los skills requeridos por el WorkType
     * @param newList Lista de AssignedResource a validar
     */
    public static void validateSkillRequirements(List<AssignedResource> newList) {
        // 1. Obtener IDs de ServiceAppointments y ServiceResources
        Set<Id> saIds = new Set<Id>();
        Set<Id> resourceIds = new Set<Id>();

        for (AssignedResource ar : newList) {
            if (ar.ServiceAppointmentId != null) {
                saIds.add(ar.ServiceAppointmentId);
            }
            if (ar.ServiceResourceId != null) {
                resourceIds.add(ar.ServiceResourceId);
            }
        }

        if (saIds.isEmpty() || resourceIds.isEmpty()) {
            return;
        }

        // 2. Obtener WorkTypeId de cada ServiceAppointment
        Map<Id, Id> saToWorkTypeMap = getWorkTypeForServiceAppointments(saIds);

        // 3. Obtener SkillRequirements por WorkType
        Set<Id> workTypeIds = new Set<Id>();
        for (Id workTypeId : saToWorkTypeMap.values()) {
            if (workTypeId != null) {
                workTypeIds.add(workTypeId);
            }
        }

        if (workTypeIds.isEmpty()) {
            return;
        }

        Map<Id, Set<Id>> workTypeSkillsMap = getRequiredSkillsByWorkType(workTypeIds);

        // 4. Obtener Skills de cada ServiceResource
        Map<Id, Set<Id>> resourceSkillsMap = getResourceSkills(resourceIds);

        // 5. Cargar nombres de skills para mensajes de error
        loadSkillNames(workTypeSkillsMap);

        // 6. Validar cada AssignedResource
        for (AssignedResource ar : newList) {
            Id workTypeId = saToWorkTypeMap.get(ar.ServiceAppointmentId);
            if (workTypeId == null) {
                continue; // No hay WorkType, no validar
            }

            Set<Id> requiredSkills = workTypeSkillsMap.get(workTypeId);
            if (requiredSkills == null || requiredSkills.isEmpty()) {
                continue; // WorkType no tiene skills requeridos
            }

            Set<Id> resourceSkills = resourceSkillsMap.get(ar.ServiceResourceId);
            if (resourceSkills == null) {
                resourceSkills = new Set<Id>();
            }

            // Encontrar skills faltantes
            List<String> missingSkillNames = new List<String>();
            for (Id skillId : requiredSkills) {
                if (!resourceSkills.contains(skillId)) {
                    String skillName = skillNameCache.get(skillId);
                    if (skillName != null) {
                        missingSkillNames.add(skillName);
                    } else {
                        missingSkillNames.add(skillId);
                    }
                }
            }

            if (!missingSkillNames.isEmpty()) {
                ar.addError('El recurso no tiene los skills requeridos: ' +
                    String.join(missingSkillNames, ', '));
            }
        }
    }

    /**
     * @description Obtiene el WorkTypeId para cada ServiceAppointment
     *              El WorkType viene del WorkOrder o WorkOrderLineItem padre
     * @param saIds Set de IDs de ServiceAppointment
     * @return Map de ServiceAppointmentId -> WorkTypeId
     */
    private static Map<Id, Id> getWorkTypeForServiceAppointments(Set<Id> saIds) {
        Map<Id, Id> saToWorkTypeMap = new Map<Id, Id>();

        // Query ServiceAppointments con su ParentRecord
        List<ServiceAppointment> saList = [
            SELECT Id, ParentRecordId
            FROM ServiceAppointment
            WHERE Id IN :saIds
        ];

        // Separar los ParentRecordIds por tipo de objeto
        Set<Id> workOrderIds = new Set<Id>();
        Set<Id> woliIds = new Set<Id>();
        Map<Id, Id> saToParentMap = new Map<Id, Id>();

        for (ServiceAppointment sa : saList) {
            if (sa.ParentRecordId != null) {
                saToParentMap.put(sa.Id, sa.ParentRecordId);
                String sObjectType = sa.ParentRecordId.getSObjectType().getDescribe().getName();
                if (sObjectType == 'WorkOrder') {
                    workOrderIds.add(sa.ParentRecordId);
                } else if (sObjectType == 'WorkOrderLineItem') {
                    woliIds.add(sa.ParentRecordId);
                }
            }
        }

        // Obtener WorkTypeId de WorkOrders
        Map<Id, Id> woToWorkTypeMap = new Map<Id, Id>();
        if (!workOrderIds.isEmpty()) {
            for (WorkOrder wo : [SELECT Id, WorkTypeId FROM WorkOrder WHERE Id IN :workOrderIds]) {
                woToWorkTypeMap.put(wo.Id, wo.WorkTypeId);
            }
        }

        // Obtener WorkTypeId de WorkOrderLineItems
        Map<Id, Id> woliToWorkTypeMap = new Map<Id, Id>();
        if (!woliIds.isEmpty()) {
            for (WorkOrderLineItem woli : [SELECT Id, WorkTypeId FROM WorkOrderLineItem WHERE Id IN :woliIds]) {
                woliToWorkTypeMap.put(woli.Id, woli.WorkTypeId);
            }
        }

        // Mapear SA -> WorkType
        for (ServiceAppointment sa : saList) {
            Id parentId = saToParentMap.get(sa.Id);
            if (parentId != null) {
                if (woToWorkTypeMap.containsKey(parentId)) {
                    saToWorkTypeMap.put(sa.Id, woToWorkTypeMap.get(parentId));
                } else if (woliToWorkTypeMap.containsKey(parentId)) {
                    saToWorkTypeMap.put(sa.Id, woliToWorkTypeMap.get(parentId));
                }
            }
        }

        return saToWorkTypeMap;
    }

    /**
     * @description Obtiene los Skills requeridos por cada WorkType
     * @param workTypeIds Set de IDs de WorkType
     * @return Map de WorkTypeId -> Set de SkillIds requeridos
     */
    private static Map<Id, Set<Id>> getRequiredSkillsByWorkType(Set<Id> workTypeIds) {
        Map<Id, Set<Id>> workTypeSkillsMap = new Map<Id, Set<Id>>();

        for (SkillRequirement sr : [
            SELECT Id, RelatedRecordId, SkillId
            FROM SkillRequirement
            WHERE RelatedRecordId IN :workTypeIds
        ]) {
            if (!workTypeSkillsMap.containsKey(sr.RelatedRecordId)) {
                workTypeSkillsMap.put(sr.RelatedRecordId, new Set<Id>());
            }
            workTypeSkillsMap.get(sr.RelatedRecordId).add(sr.SkillId);
        }

        return workTypeSkillsMap;
    }

    /**
     * @description Obtiene los Skills de cada ServiceResource
     * @param resourceIds Set de IDs de ServiceResource
     * @return Map de ServiceResourceId -> Set de SkillIds que tiene
     */
    private static Map<Id, Set<Id>> getResourceSkills(Set<Id> resourceIds) {
        Map<Id, Set<Id>> resourceSkillsMap = new Map<Id, Set<Id>>();

        for (ServiceResourceSkill srs : [
            SELECT Id, ServiceResourceId, SkillId
            FROM ServiceResourceSkill
            WHERE ServiceResourceId IN :resourceIds
        ]) {
            if (!resourceSkillsMap.containsKey(srs.ServiceResourceId)) {
                resourceSkillsMap.put(srs.ServiceResourceId, new Set<Id>());
            }
            resourceSkillsMap.get(srs.ServiceResourceId).add(srs.SkillId);
        }

        return resourceSkillsMap;
    }

    /**
     * @description Carga los nombres de los skills para mostrar en mensajes de error
     * @param workTypeSkillsMap Map con los skills por WorkType
     */
    private static void loadSkillNames(Map<Id, Set<Id>> workTypeSkillsMap) {
        Set<Id> allSkillIds = new Set<Id>();
        for (Set<Id> skillIds : workTypeSkillsMap.values()) {
            allSkillIds.addAll(skillIds);
        }

        // Solo consultar skills que no estén en cache
        Set<Id> skillsToQuery = new Set<Id>();
        for (Id skillId : allSkillIds) {
            if (!skillNameCache.containsKey(skillId)) {
                skillsToQuery.add(skillId);
            }
        }

        if (!skillsToQuery.isEmpty()) {
            for (Skill s : [SELECT Id, MasterLabel FROM Skill WHERE Id IN :skillsToQuery]) {
                skillNameCache.put(s.Id, s.MasterLabel);
            }
        }
    }

    // ==================================================================================
    // VALIDACIÓN 2: AUSENCIAS DEL RECURSO (ResourceAbsence)
    // ==================================================================================
    // VALIDACIÓN 3: HORARIO DE OPERACIÓN (Operating Hours)
    // ==================================================================================

    /**
     * @description Valida que la cita esté dentro del horario de operación del territorio del RECURSO
     * @param newList Lista de AssignedResource a validar
     */
    private static void validateOperatingHours(List<AssignedResource> newList) {
        // 1. Obtener IDs de ServiceAppointments y ServiceResources
        Set<Id> saIds = new Set<Id>();
        Set<Id> resourceIds = new Set<Id>();
        for (AssignedResource ar : newList) {
            if (ar.ServiceAppointmentId != null) {
                saIds.add(ar.ServiceAppointmentId);
            }
            if (ar.ServiceResourceId != null) {
                resourceIds.add(ar.ServiceResourceId);
            }
        }

        if (saIds.isEmpty() || resourceIds.isEmpty()) {
            return;
        }

        // 2. Obtener ServiceAppointments (solo horarios)
        Map<Id, ServiceAppointment> saMap = new Map<Id, ServiceAppointment>([
            SELECT Id, SchedStartTime, SchedEndTime, AppointmentNumber
            FROM ServiceAppointment
            WHERE Id IN :saIds
        ]);

        // 3. Obtener territorio PRIMARIO de cada recurso (TerritoryType = 'P')
        Date today = Date.today();
        List<ServiceTerritoryMember> stmList = [
            SELECT Id, ServiceResourceId, ServiceTerritoryId,
                   ServiceTerritory.Name, ServiceTerritory.OperatingHoursId,
                   ServiceTerritory.OperatingHours.TimeZone
            FROM ServiceTerritoryMember
            WHERE ServiceResourceId IN :resourceIds
            AND TerritoryType = 'P'
            AND EffectiveStartDate <= :today
            AND (EffectiveEndDate >= :today OR EffectiveEndDate = null)
        ];

        // Mapear recurso -> territorio primario
        Map<Id, ServiceTerritoryMember> resourceTerritoryMap = new Map<Id, ServiceTerritoryMember>();
        for (ServiceTerritoryMember stm : stmList) {
            resourceTerritoryMap.put(stm.ServiceResourceId, stm);
        }

        // 4. Obtener Operating Hours IDs de los territorios
        Set<Id> ohIds = new Set<Id>();
        for (ServiceTerritoryMember stm : stmList) {
            if (stm.ServiceTerritory.OperatingHoursId != null) {
                ohIds.add(stm.ServiceTerritory.OperatingHoursId);
            }
        }

        if (ohIds.isEmpty()) {
            return; // Sin operating hours configurados
        }

        // 5. Obtener TimeSlots
        List<TimeSlot> timeSlots = [
            SELECT Id, OperatingHoursId, DayOfWeek, StartTime, EndTime
            FROM TimeSlot
            WHERE OperatingHoursId IN :ohIds
        ];

        // Organizar TimeSlots por OperatingHoursId y DayOfWeek
        Map<String, List<TimeSlot>> slotsByOHAndDay = new Map<String, List<TimeSlot>>();
        for (TimeSlot ts : timeSlots) {
            String key = ts.OperatingHoursId + '_' + ts.DayOfWeek;
            if (!slotsByOHAndDay.containsKey(key)) {
                slotsByOHAndDay.put(key, new List<TimeSlot>());
            }
            slotsByOHAndDay.get(key).add(ts);
        }

        // 6. Validar cada AssignedResource
        for (AssignedResource ar : newList) {
            ServiceAppointment sa = saMap.get(ar.ServiceAppointmentId);
            if (sa == null || sa.SchedStartTime == null || sa.SchedEndTime == null) {
                continue; // Cita no programada
            }

            // Obtener territorio del RECURSO (no de la cita)
            ServiceTerritoryMember stm = resourceTerritoryMap.get(ar.ServiceResourceId);
            if (stm == null || stm.ServiceTerritory.OperatingHoursId == null) {
                continue; // Recurso sin territorio primario o sin operating hours
            }

            // Obtener timezone del territorio del recurso
            String tzId = stm.ServiceTerritory.OperatingHours.TimeZone;

            // Convertir horario de cita a hora local usando format() con timezone
            // Esto evita problemas de conversión manual
            String localStartStr = sa.SchedStartTime.format('HH:mm', tzId);
            String localEndStr = sa.SchedEndTime.format('HH:mm', tzId);
            String dayOfWeekStr = sa.SchedStartTime.format('EEEE', tzId);

            // Convertir día de la semana al formato FSL (inglés)
            String dayOfWeek = convertDayToEnglish(dayOfWeekStr);
            String key = stm.ServiceTerritory.OperatingHoursId + '_' + dayOfWeek;

            List<TimeSlot> slots = slotsByOHAndDay.get(key);
            if (slots == null || slots.isEmpty()) {
                ar.addError('No se puede asignar al territorio "' + stm.ServiceTerritory.Name + '". ' +
                    'El día ' + dayOfWeek + ' no está configurado en el horario de operación.');
                continue;
            }

            // Parsear horas de la cita (en hora local)
            Integer startHour = Integer.valueOf(localStartStr.split(':')[0]);
            Integer startMin = Integer.valueOf(localStartStr.split(':')[1]);
            Integer endHour = Integer.valueOf(localEndStr.split(':')[0]);
            Integer endMin = Integer.valueOf(localEndStr.split(':')[1]);

            // Encontrar el rango total de operación del día
            Integer ohStartHour = 23, ohStartMin = 59;
            Integer ohEndHour = 0, ohEndMin = 0;
            for (TimeSlot ts : slots) {
                // Inicio más temprano
                if (ts.StartTime.hour() < ohStartHour ||
                    (ts.StartTime.hour() == ohStartHour && ts.StartTime.minute() < ohStartMin)) {
                    ohStartHour = ts.StartTime.hour();
                    ohStartMin = ts.StartTime.minute();
                }
                // Fin más tarde
                if (ts.EndTime.hour() > ohEndHour ||
                    (ts.EndTime.hour() == ohEndHour && ts.EndTime.minute() > ohEndMin)) {
                    ohEndHour = ts.EndTime.hour();
                    ohEndMin = ts.EndTime.minute();
                }
            }

            // Convertir a minutos desde medianoche para comparar fácilmente
            Integer appointmentStart = startHour * 60 + startMin;
            Integer appointmentEnd = endHour * 60 + endMin;
            Integer ohStart = ohStartHour * 60 + ohStartMin;
            Integer ohEnd = ohEndHour * 60 + ohEndMin;

            // Verificar si la cita está dentro del rango de operación
            Boolean withinHours = (appointmentStart >= ohStart && appointmentEnd <= ohEnd);

            if (!withinHours) {
                String ohStartStr = String.valueOf(ohStartHour).leftPad(2, '0') + ':' + String.valueOf(ohStartMin).leftPad(2, '0');
                String ohEndStr = String.valueOf(ohEndHour).leftPad(2, '0') + ':' + String.valueOf(ohEndMin).leftPad(2, '0');
                ar.addError('No se puede asignar al territorio "' + stm.ServiceTerritory.Name + '". ' +
                    'Horario de operación para ' + dayOfWeek + ': ' + ohStartStr + ' - ' + ohEndStr +
                    '. La cita es de ' + localStartStr + ' a ' + localEndStr);
            }
        }
    }

    /**
     * @description Convierte nombre del día de español/locale a inglés (formato FSL)
     */
    private static String convertDayToEnglish(String day) {
        if (day == null) return 'Monday';
        day = day.toLowerCase();
        if (day.contains('lunes') || day.contains('monday')) return 'Monday';
        if (day.contains('martes') || day.contains('tuesday')) return 'Tuesday';
        if (day.contains('miércoles') || day.contains('miercoles') || day.contains('wednesday')) return 'Wednesday';
        if (day.contains('jueves') || day.contains('thursday')) return 'Thursday';
        if (day.contains('viernes') || day.contains('friday')) return 'Friday';
        if (day.contains('sábado') || day.contains('sabado') || day.contains('saturday')) return 'Saturday';
        if (day.contains('domingo') || day.contains('sunday')) return 'Sunday';
        return day;
    }

    // ==================================================================================
    // SHARING: Compartir SA con el mecánico asignado
    // ==================================================================================

    /**
     * @description Cuando se asigna un recurso a una SA, comparte la SA con el usuario del recurso
     *              para que pueda verla aunque no sea el owner.
     */
    private static void shareWithAssignedResource(List<AssignedResource> newList) {
        Set<Id> resourceIds = new Set<Id>();
        for (AssignedResource ar : newList) {
            if (ar.ServiceResourceId != null) {
                resourceIds.add(ar.ServiceResourceId);
            }
        }
        if (resourceIds.isEmpty()) return;

        // Obtener el UserId de cada ServiceResource
        Map<Id, Id> resourceToUserMap = new Map<Id, Id>();
        for (ServiceResource sr : [SELECT Id, RelatedRecordId FROM ServiceResource WHERE Id IN :resourceIds AND RelatedRecordId != null]) {
            resourceToUserMap.put(sr.Id, sr.RelatedRecordId);
        }
        if (resourceToUserMap.isEmpty()) return;

        // Verificar shares existentes para no duplicar
        Set<Id> saIds = new Set<Id>();
        for (AssignedResource ar : newList) {
            if (ar.ServiceAppointmentId != null) {
                saIds.add(ar.ServiceAppointmentId);
            }
        }
        Set<String> existingShares = new Set<String>();
        for (ServiceAppointmentShare sas : [SELECT ParentId, UserOrGroupId FROM ServiceAppointmentShare
                WHERE ParentId IN :saIds AND RowCause = 'Manual']) {
            existingShares.add(sas.ParentId + '_' + sas.UserOrGroupId);
        }

        // Crear shares
        List<ServiceAppointmentShare> sharesToInsert = new List<ServiceAppointmentShare>();
        for (AssignedResource ar : newList) {
            Id userId = resourceToUserMap.get(ar.ServiceResourceId);
            if (userId == null || ar.ServiceAppointmentId == null) continue;

            String key = ar.ServiceAppointmentId + '_' + userId;
            if (existingShares.contains(key)) continue;

            sharesToInsert.add(new ServiceAppointmentShare(
                ParentId = ar.ServiceAppointmentId,
                UserOrGroupId = userId,
                AccessLevel = 'Edit',
                RowCause = Schema.ServiceAppointmentShare.RowCause.Manual
            ));
            existingShares.add(key);
        }

        if (!sharesToInsert.isEmpty()) {
            Database.insert(sharesToInsert, false); // AllowPartialSuccess
        }
    }

    /**
     * @description Stampa el UserId del mecánico asignado en SA.Assigned_User__c
     *              para poder filtrar list views por "mis citas asignadas"
     */
    private static void stampAssignedUserOnSA(List<AssignedResource> newList) {
        Set<Id> resourceIds = new Set<Id>();
        for (AssignedResource ar : newList) {
            if (ar.ServiceResourceId != null) {
                resourceIds.add(ar.ServiceResourceId);
            }
        }
        if (resourceIds.isEmpty()) return;

        Map<Id, Id> resourceToUserMap = new Map<Id, Id>();
        for (ServiceResource sr : [SELECT Id, RelatedRecordId FROM ServiceResource WHERE Id IN :resourceIds AND RelatedRecordId != null]) {
            resourceToUserMap.put(sr.Id, sr.RelatedRecordId);
        }
        if (resourceToUserMap.isEmpty()) return;

        List<ServiceAppointment> sasToUpdate = new List<ServiceAppointment>();
        for (AssignedResource ar : newList) {
            Id userId = resourceToUserMap.get(ar.ServiceResourceId);
            if (userId != null && ar.ServiceAppointmentId != null) {
                sasToUpdate.add(new ServiceAppointment(
                    Id = ar.ServiceAppointmentId,
                    Assigned_User__c = userId
                ));
            }
        }
        if (!sasToUpdate.isEmpty()) {
            Database.update(sasToUpdate, false);
        }
    }

    // ==================================================================================
    // VALIDACIÓN 5: DOBLE ASIGNACIÓN
    // ==================================================================================

    /**
     * @description Valida que el recurso no tenga otra cita en el mismo horario
     * @param newList Lista de AssignedResource a validar
     */
    private static void validateNoDoubleBooking(List<AssignedResource> newList) {
        // 1. Obtener IDs de ServiceAppointments y ServiceResources
        Set<Id> saIds = new Set<Id>();
        Set<Id> resourceIds = new Set<Id>();

        for (AssignedResource ar : newList) {
            if (ar.ServiceAppointmentId != null) {
                saIds.add(ar.ServiceAppointmentId);
            }
            if (ar.ServiceResourceId != null) {
                resourceIds.add(ar.ServiceResourceId);
            }
        }

        if (saIds.isEmpty() || resourceIds.isEmpty()) {
            return;
        }

        // 2. Obtener horarios de las citas actuales
        Map<Id, ServiceAppointment> saMap = new Map<Id, ServiceAppointment>([
            SELECT Id, SchedStartTime, SchedEndTime, AppointmentNumber
            FROM ServiceAppointment
            WHERE Id IN :saIds
        ]);

        // 3. Encontrar rango de fechas para la query
        Datetime minStart = null;
        Datetime maxEnd = null;
        for (ServiceAppointment sa : saMap.values()) {
            if (sa.SchedStartTime != null && sa.SchedEndTime != null) {
                if (minStart == null || sa.SchedStartTime < minStart) {
                    minStart = sa.SchedStartTime;
                }
                if (maxEnd == null || sa.SchedEndTime > maxEnd) {
                    maxEnd = sa.SchedEndTime;
                }
            }
        }

        if (minStart == null || maxEnd == null) {
            return; // No hay citas programadas
        }

        // Estados a excluir (citas canceladas o completadas no cuentan)
        Set<String> excludedStatuses = new Set<String>{'Canceled', 'Completed', 'Cancelada', 'Completada', 'Cannot Complete', 'No se pudo completar'};

        // 4. Buscar otras asignaciones del mismo recurso que podrían solapar
        List<AssignedResource> existingAssignments = [
            SELECT Id, ServiceResourceId,
                   ServiceAppointment.Id, ServiceAppointment.AppointmentNumber,
                   ServiceAppointment.SchedStartTime, ServiceAppointment.SchedEndTime,
                   ServiceAppointment.Status
            FROM AssignedResource
            WHERE ServiceResourceId IN :resourceIds
            AND ServiceAppointment.Id NOT IN :saIds
            AND ServiceAppointment.SchedStartTime < :maxEnd
            AND ServiceAppointment.SchedEndTime > :minStart
            AND ServiceAppointment.Status NOT IN :excludedStatuses
        ];

        // Organizar por recurso
        Map<Id, List<AssignedResource>> existingByResource = new Map<Id, List<AssignedResource>>();
        for (AssignedResource existing : existingAssignments) {
            if (!existingByResource.containsKey(existing.ServiceResourceId)) {
                existingByResource.put(existing.ServiceResourceId, new List<AssignedResource>());
            }
            existingByResource.get(existing.ServiceResourceId).add(existing);
        }

        // 5. Validar cada AssignedResource
        for (AssignedResource ar : newList) {
            ServiceAppointment sa = saMap.get(ar.ServiceAppointmentId);
            if (sa == null || sa.SchedStartTime == null || sa.SchedEndTime == null) {
                continue; // Cita no programada
            }

            List<AssignedResource> resourceAssignments = existingByResource.get(ar.ServiceResourceId);
            if (resourceAssignments == null || resourceAssignments.isEmpty()) {
                continue; // Sin otras asignaciones
            }

            // Verificar solapamiento con asignaciones existentes
            for (AssignedResource existing : resourceAssignments) {
                ServiceAppointment existingSA = existing.ServiceAppointment;
                // Solapamiento: existing.Start < new.End AND existing.End > new.Start
                if (existingSA.SchedStartTime < sa.SchedEndTime && existingSA.SchedEndTime > sa.SchedStartTime) {
                    ar.addError('El recurso ya tiene asignada la cita ' + existingSA.AppointmentNumber +
                        ' en ese horario (' + existingSA.SchedStartTime.format('dd/MM/yyyy HH:mm') +
                        ' - ' + existingSA.SchedEndTime.format('dd/MM/yyyy HH:mm') + ')');
                    break; // Solo mostrar el primer conflicto
                }
            }
        }
    }
}