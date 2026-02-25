@RestResource(urlMapping='/fsl/v1/simpleSlots')
global with sharing class FSL_SimpleSlotsApi {

    // =======================
    // Request / Response DTOs
    // =======================
    global class SlotsRequest {
        public Id serviceTerritoryId;      // REQUIRED
        public Id workTypeId;              // REQUIRED
        public Datetime earliestStart;     // REQUIRED (intended in OH timezone; stored as UTC)
        public Datetime dueDate;           // REQUIRED (intended in OH timezone; stored as UTC)

        // Optional tuning
        public Integer slotStepMinutes;        // OPTIONAL (default: 30-minute grid)
        public Integer maxSlotsPerResource;    // OPTIONAL (default: 500)

        // Optional: explicitly pass the Operating Hours timezone ID
        // Example: "America/Costa_Rica"
        public String operatingHoursTimeZone;  // OPTIONAL
    }

    global class SlotDTO {
        public Id resourceId;
        public String resourceName;
        public Datetime startTime;   // UTC
        public Datetime endTime;     // UTC
        public Decimal grade;        // reserved for future scoring
    }

    global class TimeInterval {
        public Datetime startTime;   // UTC
        public Datetime endTime;     // UTC
        public TimeInterval(Datetime s, Datetime e) {
            startTime = s;
            endTime   = e;
        }
    }

    // =======================
    // Comparators
    // =======================
    global class SlotByStartTime implements System.Comparator<SlotDTO> {
        public Integer compare(SlotDTO a, SlotDTO b) {
            if (a == null && b == null) return 0;
            if (a == null) return -1;
            if (b == null) return 1;
            if (a.startTime == b.startTime) return 0;
            return a.startTime < b.startTime ? -1 : 1;
        }
    }

    global class IntervalByStartTime implements System.Comparator<TimeInterval> {
        public Integer compare(TimeInterval a, TimeInterval b) {
            if (a == null && b == null) return 0;
            if (a == null) return -1;
            if (b == null) return 1;
            if (a.startTime == b.startTime) return 0;
            return a.startTime < b.startTime ? -1 : 1;
        }
    }

    // =================
    // Response helper
    // =================
    private static List<SlotDTO> setErrorResponse(Integer code, String msg) {
        RestContext.response.statusCode = code;
        RestContext.response.addHeader('X-Error-Message', msg);
        return new List<SlotDTO>();
    }

    // ==============
    // REST entrypoint
    // ==============
    @HttpPost
    global static List<SlotDTO> getSimpleSlots() {
        // Parse request
        String raw = (RestContext.request.requestBody == null)
            ? ''
            : RestContext.request.requestBody.toString();

        SlotsRequest req;
        try {
            req = (SlotsRequest) JSON.deserialize(raw, SlotsRequest.class);
        } catch (Exception e) {
            return setErrorResponse(400, 'Invalid JSON: ' + e.getMessage());
        }
        if (req == null) return setErrorResponse(400, 'Empty request.');

        // Validate required fields
        if (req.serviceTerritoryId == null)
            return setErrorResponse(400, 'serviceTerritoryId is required.');
        if (req.workTypeId == null)
            return setErrorResponse(400, 'workTypeId is required.');
        if (req.earliestStart == null)
            return setErrorResponse(400, 'earliestStart is required.');
        if (req.dueDate == null)
            return setErrorResponse(400, 'dueDate is required.');
        if (req.earliestStart >= req.dueDate)
            return setErrorResponse(400, 'earliestStart must be before dueDate.');

        try {
            // 1) Work Type duration
            WorkType wt = [
                SELECT Id, EstimatedDuration, DurationType
                FROM WorkType
                WHERE Id = :req.workTypeId
                LIMIT 1
            ];

            Integer durationMinutes = getDurationMinutes(wt);
            if (durationMinutes <= 0) {
                durationMinutes = 60;
            }

            // Default grid step
            if (req.slotStepMinutes == null || req.slotStepMinutes <= 0) {
                req.slotStepMinutes = 30;
            }

            if (req.maxSlotsPerResource == null || req.maxSlotsPerResource <= 0) {
                req.maxSlotsPerResource = 500;
            }

            Datetime windowStartUtc = req.earliestStart;
            Datetime windowEndUtc   = req.dueDate;

            // 2) Required skills from Work Type
            Map<Id, Decimal> requiredSkills = getRequiredSkills(req.workTypeId);

            // 3) Active territory members (candidate resources)
            Set<Id> resourceIds = getActiveResourcesInTerritory(
                req.serviceTerritoryId,
                windowStartUtc,
                windowEndUtc
            );

            if (resourceIds.isEmpty()) {
                RestContext.response.statusCode = 200;
                return new List<SlotDTO>();
            }

            // 4) Filter by skills
            Set<Id> qualifiedResources = filterResourcesBySkills(resourceIds, requiredSkills);
            if (qualifiedResources.isEmpty()) {
                RestContext.response.statusCode = 200;
                return new List<SlotDTO>();
            }

            // 5) Service Territory Operating Hours + TimeZone
            ServiceTerritory st = [
                SELECT Id, OperatingHoursId, OperatingHours.TimeZone
                FROM ServiceTerritory
                WHERE Id = :req.serviceTerritoryId
                LIMIT 1
            ];

            String ohTimeZone = null;
            if (String.isNotBlank(req.operatingHoursTimeZone)) {
                ohTimeZone = req.operatingHoursTimeZone;
            } else if (st.OperatingHoursId != null &&
                       st.OperatingHours != null &&
                       String.isNotBlank(st.OperatingHours.TimeZone)) {
                ohTimeZone = st.OperatingHours.TimeZone;
            }

            Map<Integer, List<TimeSlot>> ohSlotsByDay = new Map<Integer, List<TimeSlot>>();
            if (st.OperatingHoursId != null) {
                ohSlotsByDay = getTimeSlotsByDay(st.OperatingHoursId);
            }

            // 6) Build slots per resource (respect busy SA + OH/timezone)
            List<SlotDTO> allSlots = new List<SlotDTO>();

            // Preload resource names
            Map<Id, ServiceResource> resMap = new Map<Id, ServiceResource>(
                [SELECT Id, Name FROM ServiceResource WHERE Id IN :qualifiedResources]
            );

            for (Id resId : qualifiedResources) {
                // Busy intervals from existing SAs in UTC
                List<TimeInterval> busy = getBusyIntervalsForResource(
                    resId, windowStartUtc, windowEndUtc
                );

                // Free intervals = window minus busy union
                TimeInterval window = new TimeInterval(windowStartUtc, windowEndUtc);
                List<TimeInterval> freeIntervals = computeFreeIntervals(window, busy);

                // Generate slots for this resource
                List<SlotDTO> slotsForResource = buildSlotsForResource(
                    resId,
                    resMap.containsKey(resId) ? resMap.get(resId).Name : null,
                    freeIntervals,
                    durationMinutes,
                    req.slotStepMinutes,
                    req.maxSlotsPerResource,
                    ohSlotsByDay,
                    ohTimeZone
                );

                allSlots.addAll(slotsForResource);
            }

            allSlots.sort(new SlotByStartTime());
            RestContext.response.statusCode = 200;
            return allSlots;

        } catch (Exception e) {
            return setErrorResponse(500, 'Failed to compute slots: ' + e.getMessage());
        }
    }

    // ==========================
    // Duration helper
    // ==========================
    private static Integer getDurationMinutes(WorkType wt) {
        if (wt == null || wt.EstimatedDuration == null) return 0;
        String dt = wt.DurationType;
        if (dt == 'Minutes' || dt == null) {
            return Integer.valueOf(wt.EstimatedDuration);
        } else if (dt == 'Hours') {
            return Integer.valueOf(wt.EstimatedDuration * 60);
        } else if (dt == 'Days') {
            return Integer.valueOf(wt.EstimatedDuration * 60 * 24);
        }
        return Integer.valueOf(wt.EstimatedDuration);
    }

    // ==========================
    // Skills helpers
    // ==========================
    private static Map<Id, Decimal> getRequiredSkills(Id workTypeId) {
        Map<Id, Decimal> required = new Map<Id, Decimal>();
        for (SkillRequirement sr : [
            SELECT SkillId, SkillLevel
            FROM SkillRequirement
            WHERE RelatedRecordId = :workTypeId
        ]) {
            required.put(sr.SkillId, sr.SkillLevel == null ? 0 : sr.SkillLevel);
        }
        return required;
    }

    private static Set<Id> filterResourcesBySkills(Set<Id> resourceIds, Map<Id, Decimal> requiredSkills) {
        if (requiredSkills.isEmpty()) return resourceIds;

        Map<Id, Map<Id, Decimal>> resourceSkillMap = new Map<Id, Map<Id, Decimal>>();
        for (ServiceResourceSkill srs : [
            SELECT ServiceResourceId, SkillId, SkillLevel
            FROM ServiceResourceSkill
            WHERE ServiceResourceId IN :resourceIds
        ]) {
            if (!resourceSkillMap.containsKey(srs.ServiceResourceId)) {
                resourceSkillMap.put(srs.ServiceResourceId, new Map<Id, Decimal>());
            }
            resourceSkillMap.get(srs.ServiceResourceId).put(
                srs.SkillId,
                srs.SkillLevel == null ? 0 : srs.SkillLevel
            );
        }

        Set<Id> qualified = new Set<Id>();
        for (Id resId : resourceIds) {
            Map<Id, Decimal> skills = resourceSkillMap.containsKey(resId)
                ? resourceSkillMap.get(resId)
                : new Map<Id, Decimal>();

            Boolean hasAll = true;
            for (Id reqSkillId : requiredSkills.keySet()) {
                if (!skills.containsKey(reqSkillId) ||
                    skills.get(reqSkillId) < requiredSkills.get(reqSkillId)) {
                    hasAll = false;
                    break;
                }
            }
            if (hasAll) qualified.add(resId);
        }
        return qualified;
    }

    // ==========================
    // Territory / resource helper
    // ==========================
    private static Set<Id> getActiveResourcesInTerritory(
        Id territoryId,
        Datetime startWindowUtc,
        Datetime endWindowUtc
    ) {
        Set<Id> resIds = new Set<Id>();

        for (ServiceTerritoryMember stm : [
            SELECT ServiceResourceId,
                   EffectiveStartDate,
                   EffectiveEndDate
            FROM ServiceTerritoryMember
            WHERE ServiceTerritoryId = :territoryId
        ]) {
            Datetime memStart = stm.EffectiveStartDate;
            Datetime memEnd   = stm.EffectiveEndDate;

            Boolean overlaps = true;
            if (memStart != null && memStart > endWindowUtc) overlaps = false;
            if (memEnd   != null && memEnd   < startWindowUtc) overlaps = false;

            if (overlaps) {
                resIds.add(stm.ServiceResourceId);
            }
        }

        return resIds;
    }

    // ==========================
    // Busy / free interval helpers (UTC)
    // ==========================
    private static List<TimeInterval> getBusyIntervalsForResource(
        Id serviceResourceId,
        Datetime startWindowUtc,
        Datetime endWindowUtc
    ) {
        List<TimeInterval> busy = new List<TimeInterval>();

        for (AssignedResource ar : [
            SELECT ServiceAppointment.SchedStartTime,
                   ServiceAppointment.SchedEndTime,
                   ServiceAppointment.Status
            FROM AssignedResource
            WHERE ServiceResourceId = :serviceResourceId
            AND ServiceAppointment.SchedStartTime != null
            AND ServiceAppointment.SchedEndTime   != null
            AND ServiceAppointment.SchedStartTime < :endWindowUtc
            AND ServiceAppointment.SchedEndTime   > :startWindowUtc
        ]) {
            if (ar.ServiceAppointment.Status == 'Canceled') continue;

            Datetime s = ar.ServiceAppointment.SchedStartTime;
            Datetime e = ar.ServiceAppointment.SchedEndTime;
            if (s == null || e == null || s >= e) continue;

            if (s < startWindowUtc) s = startWindowUtc;
            if (e > endWindowUtc)   e = endWindowUtc;

            busy.add(new TimeInterval(s, e));
        }

        busy.sort(new IntervalByStartTime());
        return busy;
    }

    private static List<TimeInterval> computeFreeIntervals(
        TimeInterval window,
        List<TimeInterval> busy
    ) {
        List<TimeInterval> free = new List<TimeInterval>();
        if (window == null || window.startTime >= window.endTime) return free;

        Datetime cursor = window.startTime;

        for (TimeInterval b : busy) {
            if (b == null || b.endTime <= cursor) continue;
            if (b.startTime > cursor) {
                free.add(new TimeInterval(cursor, b.startTime));
            }
            if (b.endTime > cursor) {
                cursor = b.endTime;
            }
            if (cursor >= window.endTime) break;
        }

        if (cursor < window.endTime) {
            free.add(new TimeInterval(cursor, window.endTime));
        }
        return free;
    }

    // ==========================
    // Operating Hours helpers
    // ==========================

    // Map English DayOfWeek to integer 1–7 (Monday=1 ... Sunday=7)
    private static Integer dayOfWeekToInt(String day) {
        if (day == null) return null;
        String d = day.toLowerCase();
        if (d == 'monday')    return 1;
        if (d == 'tuesday')   return 2;
        if (d == 'wednesday') return 3;
        if (d == 'thursday')  return 4;
        if (d == 'friday')    return 5;
        if (d == 'saturday')  return 6;
        if (d == 'sunday')    return 7;
        return null;
    }

    private static Map<Integer, List<TimeSlot>> getTimeSlotsByDay(Id operatingHoursId) {
        Map<Integer, List<TimeSlot>> result = new Map<Integer, List<TimeSlot>>();
        if (operatingHoursId == null) return result;

        for (TimeSlot ts : [
            SELECT Id, DayOfWeek, StartTime, EndTime
            FROM TimeSlot
            WHERE OperatingHoursId = :operatingHoursId
        ]) {
            if (ts.DayOfWeek == null || ts.StartTime == null || ts.EndTime == null) continue;

            Integer key = dayOfWeekToInt(ts.DayOfWeek);
            if (key == null) continue;

            if (!result.containsKey(key)) {
                result.put(key, new List<TimeSlot>());
            }
            result.get(key).add(ts);
        }
        return result;
    }

    // ==========================
    // Operating Hours check (UTC slot → local OH)
    // ==========================
    private static Boolean isWithinOperatingHours(
        Datetime slotStartUtc,
        Datetime slotEndUtc,
        Map<Integer, List<TimeSlot>> ohSlotsByDay,
        String ohTimeZone
    ) {
        if (ohSlotsByDay == null || ohSlotsByDay.isEmpty() || String.isBlank(ohTimeZone)) {
            return true;
        }

        Integer localDow;
        try {
            // 'u' = day number of week (1=Monday,...,7=Sunday) in the given timezone
            localDow = Integer.valueOf(slotStartUtc.format('u', ohTimeZone));
        } catch (Exception e) {
            return true; // do not block if timezone formatting fails
        }

        List<TimeSlot> daySlots = ohSlotsByDay.get(localDow);
        if (daySlots == null || daySlots.isEmpty()) {
            return false;
        }

        // Local minutes from midnight for slot bounds
        Integer slotStartMinutes = Integer.valueOf(slotStartUtc.format('H', ohTimeZone)) * 60
                                 + Integer.valueOf(slotStartUtc.format('m', ohTimeZone));
        Integer slotEndMinutes   = Integer.valueOf(slotEndUtc.format('H', ohTimeZone)) * 60
                                 + Integer.valueOf(slotEndUtc.format('m', ohTimeZone));

        // Reject slots that wrap past midnight or are zero-length in local day
        if (slotEndMinutes <= slotStartMinutes) {
            return false;
        }

        // Compute daily min/max bounds from all TimeSlots for that day
        Integer dailyStart = null;
        Integer dailyEnd   = null;
        for (TimeSlot ts : daySlots) {
            if (ts.StartTime == null || ts.EndTime == null) continue;

            Integer tsStartMinutes = ts.StartTime.hour() * 60 + ts.StartTime.minute();
            Integer tsEndMinutes   = ts.EndTime.hour()   * 60 + ts.EndTime.minute();

            if (dailyStart == null || tsStartMinutes < dailyStart) {
                dailyStart = tsStartMinutes;
            }
            if (dailyEnd == null || tsEndMinutes > dailyEnd) {
                dailyEnd = tsEndMinutes;
            }
        }

        if (dailyStart == null || dailyEnd == null) {
            return false;
        }

        // Slot must be fully contained within the global daily OH range
        if (slotStartMinutes >= dailyStart && slotEndMinutes <= dailyEnd) {
            return true;
        }
        return false;
    }

    // ==========================
    // Slot generation (free intervals + OH)
    // ==========================
    private static List<SlotDTO> buildSlotsForResource(
        Id resId,
        String resName,
        List<TimeInterval> freeIntervals,
        Integer durationMinutes,
        Integer stepMinutes,
        Integer maxSlotsPerResource,
        Map<Integer, List<TimeSlot>> ohSlotsByDay,
        String ohTimeZone
    ) {
        List<SlotDTO> slots = new List<SlotDTO>();
        if (durationMinutes <= 0 || stepMinutes <= 0) return slots;

        for (TimeInterval free : freeIntervals) {
            Datetime slotStart = free.startTime; // UTC

            while (slotStart.addMinutes(durationMinutes) <= free.endTime) {
                Datetime slotEnd = slotStart.addMinutes(durationMinutes);

                // Enforce Operating Hours in OH timezone (full containment)
                if (!isWithinOperatingHours(slotStart, slotEnd, ohSlotsByDay, ohTimeZone)) {
                    slotStart = slotStart.addMinutes(stepMinutes);
                    continue;
                }

                SlotDTO d = new SlotDTO();
                d.resourceId   = resId;
                d.resourceName = resName;
                d.startTime    = slotStart;
                d.endTime      = slotEnd;
                d.grade        = null;

                slots.add(d);
                if (slots.size() >= maxSlotsPerResource) {
                    return slots;
                }

                slotStart = slotStart.addMinutes(stepMinutes);
            }
        }
        return slots;
    }
}