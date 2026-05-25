/**
 * ResourceAbsenceTimeSheetHandler
 * Maneja la creacion automatica de TimeSheet + TimeSheetEntry cuando se registra
 * o modifica una ResourceAbsence.
 *
 * 3 escenarios segun documento de diseno:
 * (a) NO existe TS para el dia -> Crear TS + TSE
 *     - Si ausencia cubre jornada completa -> TS.Status = Terminado, TSE 7:00-17:00
 *     - Si ausencia es parcial -> TS.Status = En Progreso, TSE con horas reales
 * (b) TS existe en Borrador o En Progreso -> Crear TSE, NO cambiar status, notificar lider
 * (c) TS existe en Terminado -> NO crear TSE, notificar lider para revision manual
 *
 * @author Red Motors Development Team
 */
public with sharing class ResourceAbsenceTimeSheetHandler {

    // Recursion guard
    private static Boolean isProcessing = false;

    // Test visibility: counter for notification attempts
    @TestVisible
    private static Integer notificationsSentCount = 0;

    public static void handleAfterInsertUpdate(List<ResourceAbsence> newList,
            Map<Id, ResourceAbsence> oldMap) {
        if (isProcessing) return;
        isProcessing = true;

        try {
            List<ResourceAbsence> toProcess = new List<ResourceAbsence>();

            for (ResourceAbsence ra : newList) {
                if (oldMap == null) {
                    // Insert - always process
                    toProcess.add(ra);
                } else {
                    // Update - process if dates, type, or clasificacion changed
                    ResourceAbsence oldRa = oldMap.get(ra.Id);
                    if (oldRa != null && (
                        ra.Start != oldRa.Start ||
                        ra.End != oldRa.End ||
                        ra.Type != oldRa.Type ||
                        getClasificacion(ra) != getClasificacion(oldRa)
                    )) {
                        toProcess.add(ra);
                    }
                }
            }

            if (!toProcess.isEmpty()) {
                new AbsenceProcessor().processAbsences(toProcess);
            }
        } finally {
            isProcessing = false;
        }
    }

    private static String getClasificacion(ResourceAbsence ra) {
        try {
            Object val = ra.get('Clasificacion__c');
            return val != null ? String.valueOf(val) : null;
        } catch (Exception e) {
            return null;
        }
    }

    // ============================================================================
    // INNER CLASS: AbsenceProcessor (without sharing for elevated DML)
    // ============================================================================

    private without sharing class AbsenceProcessor {

        // Track which TS keys were newly created (scenario a) vs existing (scenario b/c)
        private Set<String> newlyCreatedTSKeys = new Set<String>();

        // Collect notification data for scenarios b and c
        private List<NotificationInfo> pendingNotifications = new List<NotificationInfo>();

        // User timezone for correct DateTime conversions
        private TimeZone userTZ = UserInfo.getTimeZone();

        /**
         * Converts a Date + hour/minute to a DateTime in the user's timezone (stored as UTC).
         * DateTime.newInstance(Date, Time) creates GMT — this adjusts for the user's offset.
         */
        private DateTime toUserTZDateTime(Date d, Integer hour, Integer minute) {
            DateTime gmtDt = DateTime.newInstance(d, Time.newInstance(hour, minute, 0, 0));
            Integer offsetMs = userTZ.getOffset(gmtDt);
            return gmtDt.addSeconds(-(offsetMs / 1000));
        }

        /**
         * Checks if the Status represents an Approved/Terminado TimeSheet.
         * Delegates to centralized bilingual helper in TimeSheetService.
         */
        private Boolean isStatusApproved(String status) {
            return TimeSheetService.isStatusApproved(status);
        }

        public void processAbsences(List<ResourceAbsence> absences) {
            // Collect all SR IDs and date ranges
            Set<Id> srIds = new Set<Id>();
            Date minDate;
            Date maxDate;

            for (ResourceAbsence ra : absences) {
                srIds.add(ra.ResourceId);
                Date startDate = ra.Start.date();
                Date endDate = ra.End.date();

                if (minDate == null || startDate < minDate) minDate = startDate;
                if (maxDate == null || endDate > maxDate) maxDate = endDate;
            }

            // Query existing TimeSheets for the date range
            Map<String, TimeSheet> existingTSMap = new Map<String, TimeSheet>();
            for (TimeSheet ts : [
                SELECT Id, ServiceResourceId, StartDate, Status
                FROM TimeSheet
                WHERE ServiceResourceId IN :srIds
                AND StartDate >= :minDate
                AND StartDate <= :maxDate
            ]) {
                String key = ts.ServiceResourceId + '_' + ts.StartDate.format();
                existingTSMap.put(key, ts);
            }

            // Query SR names for notifications
            Map<Id, String> srNames = new Map<Id, String>();
            for (ServiceResource sr : [SELECT Id, Name FROM ServiceResource WHERE Id IN :srIds]) {
                srNames.put(sr.Id, sr.Name);
            }

            // Phase 1: Identify new TSs to create and collect notification data
            List<TimeSheet> tsToInsert = new List<TimeSheet>();
            List<TimeSheetEntry> tseToInsert = new List<TimeSheetEntry>();

            for (ResourceAbsence ra : absences) {
                Date startDate = ra.Start.date();
                Date endDate = ra.End.date();

                Date currentDate = startDate;
                while (currentDate <= endDate) {
                    String tsKey = ra.ResourceId + '_' + currentDate.format();
                    TimeSheet existingTS = existingTSMap.get(tsKey);

                    if (existingTS == null) {
                        // Scenario (a): No TS exists -> create new one
                        TimeSheet ts = new TimeSheet();
                        ts.ServiceResourceId = ra.ResourceId;
                        ts.StartDate = currentDate;
                        ts.EndDate = currentDate.addDays(1);
                        ts.Status = TimeSheetService.TS_STATUS_NEW;
                        tsToInsert.add(ts);
                        newlyCreatedTSKeys.add(tsKey);
                    } else if (isStatusApproved(existingTS.Status)) {
                        // Scenario (c): TS is Terminado -> don't create TSE, notify leader
                        String mecName = srNames.containsKey(ra.ResourceId) ? srNames.get(ra.ResourceId) : 'Mecanico';
                        pendingNotifications.add(new NotificationInfo(
                            ra.ResourceId,
                            'Ausencia requiere revision manual',
                            'El TimeSheet de ' + mecName + ' ya esta Terminado. La ausencia del ' +
                                currentDate.format() + ' requiere revision manual.',
                            currentDate
                        ));
                    }
                    // Scenario (b) for existing TS in Borrador/En Progreso: handled below

                    currentDate = currentDate.addDays(1);
                }
            }

            // Insert new TimeSheets
            if (!tsToInsert.isEmpty()) {
                insert tsToInsert;
                for (TimeSheet ts : tsToInsert) {
                    String key = ts.ServiceResourceId + '_' + ts.StartDate.format();
                    existingTSMap.put(key, ts);
                }
            }

            // Phase 2: Create TSEs
            for (ResourceAbsence ra : absences) {
                Date startDate = ra.Start.date();
                Date endDate = ra.End.date();

                Date currentDate = startDate;
                while (currentDate <= endDate) {
                    // Day boundaries in user's timezone (converted to UTC for comparison)
                    DateTime dayStart = toUserTZDateTime(currentDate, 0, 0);
                    DateTime dayEnd = toUserTZDateTime(currentDate.addDays(1), 0, 0);

                    String tsKey = ra.ResourceId + '_' + currentDate.format();
                    TimeSheet ts = existingTSMap.get(tsKey);

                    if (ts == null) {
                        currentDate = currentDate.addDays(1);
                        continue;
                    }

                    // Scenario (c): TS Terminado -> skip
                    if (isStatusApproved(ts.Status) && !newlyCreatedTSKeys.contains(tsKey)) {
                        currentDate = currentDate.addDays(1);
                        continue;
                    }

                    // Scenario (b): Existing TS in Borrador or En Progreso -> add TSE + notify
                    if (!newlyCreatedTSKeys.contains(tsKey)) {
                        String mecName = srNames.containsKey(ra.ResourceId) ? srNames.get(ra.ResourceId) : 'Mecanico';
                        pendingNotifications.add(new NotificationInfo(
                            ra.ResourceId,
                            'Ausencia registrada en TimeSheet activo',
                            'Se agrego entrada de ausencia al TimeSheet de ' + mecName + ' el ' +
                                currentDate.format() + '.',
                            currentDate
                        ));
                    }

                    // Calculate TSE times
                    DateTime tseStart;
                    DateTime tseEnd;

                    if (newlyCreatedTSKeys.contains(tsKey) && coversFullDay(ra, currentDate)) {
                        // Scenario (a) full day: use standard work hours in user's timezone
                        tseStart = toUserTZDateTime(currentDate,
                            TimeSheetService.WORK_START_HOUR, TimeSheetService.WORK_START_MINUTE);
                        tseEnd = toUserTZDateTime(currentDate,
                            TimeSheetService.WORK_END_HOUR, TimeSheetService.WORK_END_MINUTE);
                    } else {
                        // Partial day or existing TS: use actual absence hours (clamped to this day)
                        tseStart = ra.Start < dayStart ? dayStart : ra.Start;
                        tseEnd = ra.End > dayEnd ? dayEnd : ra.End;
                    }

                    // Skip if zero or negative duration (e.g., absence ends at midnight)
                    if (tseEnd <= tseStart) {
                        currentDate = currentDate.addDays(1);
                        continue;
                    }

                    // Build TSE
                    TimeSheetEntry tse = new TimeSheetEntry();
                    tse.TimeSheetId = ts.Id;
                    tse.StartTime = tseStart;
                    tse.EndTime = tseEnd;
                    tse.Subject = 'Ausencia: ' + (ra.Type != null ? ra.Type : 'Sin tipo');

                    // Clasificacion
                    String clasificacion = TimeSheetService.TSE_TYPE_PERSONAL;
                    try {
                        Object clasVal = ra.get('Clasificacion__c');
                        if (clasVal != null) {
                            clasificacion = String.valueOf(clasVal);
                        }
                    } catch (Exception e) {
                        // Campo no existe
                    }
                    setFieldSafe(tse, 'Type', clasificacion);

                    // Detalle
                    String detalle = mapAbsenceTypeToDetalle(ra.Type);
                    setFieldSafe(tse, 'Detalle_Tipo_Entrada__c', detalle);
                    setFieldSafe(tse, 'Tipo_de_Etapa__c', TimeSheetService.ETAPA_PAUSA);
                    setFieldSafe(tse, 'Ciclo__c', 1);

                    tseToInsert.add(tse);
                    currentDate = currentDate.addDays(1);
                }
            }

            if (!tseToInsert.isEmpty()) {
                insert tseToInsert;
            }

            // Phase 3: Update status of newly created TSs
            List<TimeSheet> tsToUpdate = new List<TimeSheet>();
            for (ResourceAbsence ra : absences) {
                Date startDate = ra.Start.date();
                Date endDate = ra.End.date();

                Date currentDate = startDate;
                while (currentDate <= endDate) {
                    String tsKey = ra.ResourceId + '_' + currentDate.format();

                    if (newlyCreatedTSKeys.contains(tsKey)) {
                        TimeSheet ts = existingTSMap.get(tsKey);
                        if (ts != null) {
                            TimeSheet tsUpd = new TimeSheet(Id = ts.Id);
                            if (coversFullDay(ra, currentDate)) {
                                tsUpd.Status = TimeSheetService.TS_STATUS_APPROVED;
                                // Set Hora fields to pass VR TS_Terminado_Requiere_Ambas_Horas
                                setFieldSafe(tsUpd, 'Hora_de_ingreso__c',
                                    Time.newInstance(TimeSheetService.WORK_START_HOUR, TimeSheetService.WORK_START_MINUTE, 0, 0));
                                setFieldSafe(tsUpd, 'Hora_de_salida__c',
                                    Time.newInstance(TimeSheetService.WORK_END_HOUR, TimeSheetService.WORK_END_MINUTE, 0, 0));
                            } else {
                                tsUpd.Status = TimeSheetService.TS_STATUS_SUBMITTED;
                            }
                            tsToUpdate.add(tsUpd);
                        }
                    }
                    currentDate = currentDate.addDays(1);
                }
            }

            if (!tsToUpdate.isEmpty()) {
                update tsToUpdate;
            }

            // Phase 4: Send notifications to leaders (non-critical)
            if (!pendingNotifications.isEmpty()) {
                sendLeaderNotifications(pendingNotifications, srIds);
            }
        }

        /**
         * Determines if a ResourceAbsence covers the full work day for a given date.
         * Full day = absence starts at or before WORK_START_HOUR and ends at or after WORK_END_HOUR.
         */
        private Boolean coversFullDay(ResourceAbsence ra, Date targetDate) {
            // Work hours in user's timezone (converted to UTC for comparison with RA datetimes)
            DateTime workStart = toUserTZDateTime(targetDate,
                TimeSheetService.WORK_START_HOUR, TimeSheetService.WORK_START_MINUTE);
            DateTime workEnd = toUserTZDateTime(targetDate,
                TimeSheetService.WORK_END_HOUR, TimeSheetService.WORK_END_MINUTE);
            return ra.Start <= workStart && ra.End >= workEnd;
        }

        /**
         * Sends bell notifications to territory leaders for scenarios (b) and (c).
         * Non-critical: wrapped in try/catch.
         */
        private void sendLeaderNotifications(List<NotificationInfo> notifications, Set<Id> srIds) {
            try {
                // Get CustomNotificationType
                List<CustomNotificationType> notifTypes = [
                    SELECT Id FROM CustomNotificationType
                    WHERE DeveloperName = 'Redmotors_Notification' LIMIT 1
                ];
                if (notifTypes.isEmpty()) {
                    return;
                }
                Id notifTypeId = notifTypes[0].Id;

                // Find territories for the mechanics
                Map<Id, Set<Id>> srToTerritoryIds = new Map<Id, Set<Id>>();
                Set<Id> allTerritoryIds = new Set<Id>();
                for (ServiceTerritoryMember stm : [
                    SELECT ServiceResourceId, ServiceTerritoryId
                    FROM ServiceTerritoryMember
                    WHERE ServiceResourceId IN :srIds
                    AND EffectiveStartDate <= TODAY
                    AND (EffectiveEndDate = null OR EffectiveEndDate >= TODAY)
                ]) {
                    if (!srToTerritoryIds.containsKey(stm.ServiceResourceId)) {
                        srToTerritoryIds.put(stm.ServiceResourceId, new Set<Id>());
                    }
                    srToTerritoryIds.get(stm.ServiceResourceId).add(stm.ServiceTerritoryId);
                    allTerritoryIds.add(stm.ServiceTerritoryId);
                }

                // Find leaders: users with RM_Lider_Taller perm set who are STMs of the same territory
                Set<Id> leaderUserIds = new Set<Id>();
                for (PermissionSetAssignment psa : [
                    SELECT AssigneeId FROM PermissionSetAssignment
                    WHERE PermissionSet.Name = 'RM_Lider_Taller'
                    AND Assignee.IsActive = true
                ]) {
                    leaderUserIds.add(psa.AssigneeId);
                }

                if (leaderUserIds.isEmpty()) {
                    return;
                }

                // Map territory → leader users (via STM)
                Map<Id, Set<Id>> territoryToLeaders = new Map<Id, Set<Id>>();
                for (ServiceTerritoryMember stm : [
                    SELECT ServiceTerritoryId, ServiceResource.RelatedRecordId
                    FROM ServiceTerritoryMember
                    WHERE ServiceTerritoryId IN :allTerritoryIds
                    AND ServiceResource.RelatedRecordId IN :leaderUserIds
                    AND EffectiveStartDate <= TODAY
                    AND (EffectiveEndDate = null OR EffectiveEndDate >= TODAY)
                ]) {
                    if (!territoryToLeaders.containsKey(stm.ServiceTerritoryId)) {
                        territoryToLeaders.put(stm.ServiceTerritoryId, new Set<Id>());
                    }
                    territoryToLeaders.get(stm.ServiceTerritoryId).add(stm.ServiceResource.RelatedRecordId);
                }

                // Send notifications
                for (NotificationInfo info : notifications) {
                    Set<Id> recipientIds = new Set<Id>();

                    // Find leaders in the mechanic's territories
                    Set<Id> mecTerritories = srToTerritoryIds.get(info.serviceResourceId);
                    if (mecTerritories != null) {
                        for (Id terrId : mecTerritories) {
                            Set<Id> terrLeaders = territoryToLeaders.get(terrId);
                            if (terrLeaders != null) {
                                recipientIds.addAll(terrLeaders);
                            }
                        }
                    }

                    // Fallback: if no leaders found in territory, send to all leaders
                    if (recipientIds.isEmpty()) {
                        recipientIds.addAll(leaderUserIds);
                    }

                    // Convert Set<Id> to Set<String> for CustomNotification.send()
                    Set<String> recipients = new Set<String>();
                    for (Id rid : recipientIds) {
                        recipients.add(String.valueOf(rid));
                    }

                    Messaging.CustomNotification notification = new Messaging.CustomNotification();
                    notification.setTitle(info.title);
                    notification.setBody(info.body);
                    notification.setNotificationTypeId(notifTypeId);
                    notification.setTargetId(info.serviceResourceId);

                    try {
                        notification.send(recipients);
                        notificationsSentCount++;
                    } catch (Exception sendEx) {
                    }
                }
            } catch (Exception e) {
            }
        }

        private String mapAbsenceTypeToDetalle(String absenceType) {
            if (String.isBlank(absenceType)) return TimeSheetService.DETALLE_OTRA;

            String typeLower = absenceType.toLowerCase();
            if (typeLower.contains('vacation') || typeLower.contains('vacacion')) return TimeSheetService.DETALLE_VACACIONES;
            if (typeLower.contains('sick') || typeLower.contains('enfermedad')) return TimeSheetService.DETALLE_ENFERMEDAD;
            if (typeLower.contains('personal')) return TimeSheetService.DETALLE_PERSONAL;
            if (typeLower.contains('training') || typeLower.contains('capacitacion')) return TimeSheetService.DETALLE_CAPACITACION;
            return TimeSheetService.DETALLE_OTRA;
        }

        private void setFieldSafe(SObject record, String fieldName, Object value) {
            try {
                if (value != null) {
                    record.put(fieldName, value);
                }
            } catch (Exception e) {
            }
        }
    }

    // ============================================================================
    // WRAPPER: NotificationInfo
    // ============================================================================

    private class NotificationInfo {
        public Id serviceResourceId;
        public String title;
        public String body;
        public Date targetDate;

        public NotificationInfo(Id srId, String title, String body, Date targetDate) {
            this.serviceResourceId = srId;
            this.title = title;
            this.body = body;
            this.targetDate = targetDate;
        }
    }
}
