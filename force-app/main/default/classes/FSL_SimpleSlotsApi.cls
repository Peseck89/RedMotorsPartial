@RestResource(urlMapping='/fsl/v1/simpleSlots')
global with sharing class FSL_SimpleSlotsApi {

    // =======================
    // Debug flag - set to true to enable detailed logging
    // =======================
    private static final Boolean DEBUG_ENABLED = true;

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

        // Optional: capacity percentage (1-100). Maximum utilization threshold.
        // If (current utilization + one slot) > capacityPercentage, NO slots are shown.
        // If (current utilization + one slot) <= capacityPercentage, ALL available slots are shown.
        // Example: Current utilization 70%, slot adds 20%, capacity 80% -> 90% > 80% -> NO slots
        // Example: Current utilization 55%, slot adds 20%, capacity 80% -> 75% < 80% -> ALL slots shown
        public Integer capacityPercentage;     // OPTIONAL (default: 100 = no limit)

        // Optional: whether to exclude ResourceAbsence records (breaks, lunch, PTO, etc.)
        // Default: true (absences are excluded)
        public Boolean excludeAbsences;        // OPTIONAL (default: true)

        // Optional: force Operating Hours filtering even when explicit window is provided
        // Default: false (OH NOT enforced when earliestStart/dueDate are provided)
        // Set to true if you want to filter slots by Operating Hours even with custom window
        public Boolean enforceOperatingHours;  // OPTIONAL (default: false)

        // Optional: indicates that earliestStart and dueDate are in local time (operatingHoursTimeZone)
        // If true, the API will convert them to UTC internally
        // Default: false (dates are assumed to be in UTC)
        public Boolean windowInLocalTime;  // OPTIONAL (default: false)

        // Optional: return slot times in local timezone instead of UTC
        // If true, startTime and endTime in response will be formatted in local time
        // Default: false (times returned in UTC)
        public Boolean returnLocalTime;  // OPTIONAL (default: false)

        // Optional: override capacity percentage. Takes priority over capacityPercentage and ST.Capacity__c.
        // If not provided, falls back to capacityPercentage, then ST.Capacity__c, then 100.
        public Integer overrideCapacity;  // OPTIONAL
    }

    global class SlotDTO {
        public Id resourceId;
        public String resourceName;
        public Datetime startTime;       // UTC (or local if returnLocalTime=true)
        public Datetime endTime;         // UTC (or local if returnLocalTime=true)
        public String startTimeLocal;    // Formatted local time string (e.g., "2025-12-04 08:00")
        public String endTimeLocal;      // Formatted local time string (e.g., "2025-12-04 10:00")
        public Decimal grade;            // reserved for future scoring
    }

    // NEW: Resource utilization metrics
    global class ResourceUtilization {
        public Id resourceId;
        public String resourceName;
        public Integer totalWindowMinutes;      // Total minutes in the requested window
        public Integer busyMinutes;             // Minutes occupied by ServiceAppointments
        public Integer absenceMinutes;          // Minutes occupied by ResourceAbsence
        public Integer availableMinutes;        // Minutes truly available (window - busy - absences)
        public Integer slotsGenerated;          // Number of slots generated for this resource
        public Decimal utilizationPercentage;   // Current utilization: (busy + absence) / window * 100
        public Decimal potentialUtilization;    // Utilization if all generated slots were booked
    }

    // NEW: Wrapper response with slots + utilization
    global class SlotsResponse {
        public List<SlotDTO> slots;
        public List<ResourceUtilization> resourceUtilization;
        public Integer totalSlotsGenerated;     // Before capacity limit
        public Integer totalSlotsReturned;      // After capacity limit
        public Decimal globalUtilizationPercentage;  // Average utilization across all resources
    }

    global class TimeInterval {
        public Datetime startTime;   // UTC
        public Datetime endTime;     // UTC
        public TimeInterval(Datetime s, Datetime e) {
            startTime = s;
            endTime   = e;
        }

        // Helper to get duration in minutes
        public Integer getDurationMinutes() {
            if (startTime == null || endTime == null) return 0;
            Long diffMillis = endTime.getTime() - startTime.getTime();
            return (Integer)(diffMillis / 60000);
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
    // Response helper (for error cases, returns empty SlotsResponse)
    // =================
    private static SlotsResponse setErrorResponse(Integer code, String msg) {
        RestContext.response.statusCode = code;
        RestContext.response.addHeader('X-Error-Message', msg);
        SlotsResponse resp = new SlotsResponse();
        resp.slots = new List<SlotDTO>();
        resp.resourceUtilization = new List<ResourceUtilization>();
        resp.totalSlotsGenerated = 0;
        resp.totalSlotsReturned = 0;
        resp.globalUtilizationPercentage = 0;
        return resp;
    }

    // =================
    // Debug helper
    // =================
    private static void debugLog(String message) {
        if (DEBUG_ENABLED) {
            System.debug(LoggingLevel.INFO, '### FSL_SimpleSlotsApi: ' + message);
        }
    }

    // ==============
    // REST entrypoint - NOW RETURNS SlotsResponse instead of List<SlotDTO>
    // ==============
    @HttpPost
    global static SlotsResponse getSimpleSlots() {
        // Parse request
        String raw = (RestContext.request.requestBody == null)
            ? ''
            : RestContext.request.requestBody.toString();

        debugLog('Raw request body: ' + raw);

        SlotsRequest req;
        try {
            req = (SlotsRequest) JSON.deserialize(raw, SlotsRequest.class);
        } catch (Exception e) {
            return setErrorResponse(400, 'Invalid JSON: ' + e.getMessage());
        }
        if (req == null) return setErrorResponse(400, 'Empty request.');

        // Log deserialized values for debugging
        debugLog('Deserialized capacityPercentage: ' + req.capacityPercentage);
        debugLog('Deserialized overrideCapacity: ' + req.overrideCapacity);
        debugLog('Deserialized excludeAbsences: ' + req.excludeAbsences);
        debugLog('Deserialized enforceOperatingHours: ' + req.enforceOperatingHours);

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
            debugLog('WorkType duration (minutes): ' + durationMinutes);

            // Default grid step
            if (req.slotStepMinutes == null || req.slotStepMinutes <= 0) {
                req.slotStepMinutes = 30;
            }

            if (req.maxSlotsPerResource == null || req.maxSlotsPerResource <= 0) {
                req.maxSlotsPerResource = 500;
            }

            // Default excludeAbsences to true
            if (req.excludeAbsences == null) {
                req.excludeAbsences = true;
            }
            debugLog('excludeAbsences: ' + req.excludeAbsences);

            // NEW: Default enforceOperatingHours to true
            // When true, Operating Hours filter is applied (respects TimeSlots, excludes days without TimeSlots like Sundays)
            // When false, Operating Hours do NOT filter slots (client-defined window is respected)
            if (req.enforceOperatingHours == null) {
                req.enforceOperatingHours = true;
            }
            debugLog('enforceOperatingHours: ' + req.enforceOperatingHours);

            // NEW: Default windowInLocalTime to false
            if (req.windowInLocalTime == null) {
                req.windowInLocalTime = false;
            }
            debugLog('windowInLocalTime: ' + req.windowInLocalTime);

            // NEW: Default returnLocalTime to false
            if (req.returnLocalTime == null) {
                req.returnLocalTime = false;
            }
            debugLog('returnLocalTime: ' + req.returnLocalTime);

            // Get timezone early since we may need it for conversion
            // 5) Service Territory Operating Hours + TimeZone + Capacity (moved up)
            ServiceTerritory st = [
                SELECT Id, OperatingHoursId, OperatingHours.TimeZone, Capacity__c
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
            debugLog('Operating Hours TimeZone: ' + ohTimeZone);

            // Capacity resolution: overrideCapacity > capacityPercentage > ST.Capacity__c > 100
            if (req.overrideCapacity != null && req.overrideCapacity > 0 && req.overrideCapacity <= 100) {
                debugLog('Using overrideCapacity: ' + req.overrideCapacity);
                req.capacityPercentage = req.overrideCapacity;
            } else if (req.capacityPercentage == null) {
                if (st.Capacity__c != null) {
                    req.capacityPercentage = ((Decimal) st.Capacity__c).intValue();
                    debugLog('Using ST.Capacity__c: ' + req.capacityPercentage);
                } else {
                    req.capacityPercentage = 100;
                    debugLog('capacityPercentage was null, no ST Capacity, defaulting to 100');
                }
            } else if (req.capacityPercentage <= 0 || req.capacityPercentage > 100) {
                debugLog('capacityPercentage out of range (' + req.capacityPercentage + '), defaulting to 100');
                req.capacityPercentage = 100;
            }
            debugLog('Final capacityPercentage: ' + req.capacityPercentage);

            // Convert window times from local to UTC if requested
            Datetime windowStartUtc = req.earliestStart;
            Datetime windowEndUtc   = req.dueDate;

            if (req.windowInLocalTime && String.isNotBlank(ohTimeZone)) {
                debugLog('Converting window from local time (' + ohTimeZone + ') to UTC');
                debugLog('Original earliestStart (local): ' + req.earliestStart);
                debugLog('Original dueDate (local): ' + req.dueDate);

                // Convert local time to UTC
                windowStartUtc = convertLocalToUtc(req.earliestStart, ohTimeZone);
                windowEndUtc = convertLocalToUtc(req.dueDate, ohTimeZone);

                debugLog('Converted earliestStart (UTC): ' + windowStartUtc);
                debugLog('Converted dueDate (UTC): ' + windowEndUtc);
            }

            debugLog('=== WINDOW DEBUG ===');
            debugLog('Window Start (UTC): ' + windowStartUtc);
            debugLog('Window End (UTC): ' + windowEndUtc);
            debugLog('Window Duration (minutes): ' + new TimeInterval(windowStartUtc, windowEndUtc).getDurationMinutes());

            // 2) Required skills from Work Type
            Map<Id, Decimal> requiredSkills = getRequiredSkills(req.workTypeId);
            debugLog('Required skills count: ' + requiredSkills.size());

            // 3) Active territory members (candidate resources)
            Set<Id> resourceIds = getActiveResourcesInTerritory(
                req.serviceTerritoryId,
                windowStartUtc,
                windowEndUtc
            );
            debugLog('Active resources in territory: ' + resourceIds.size());

            if (resourceIds.isEmpty()) {
                RestContext.response.statusCode = 200;
                SlotsResponse emptyResp = new SlotsResponse();
                emptyResp.slots = new List<SlotDTO>();
                emptyResp.resourceUtilization = new List<ResourceUtilization>();
                emptyResp.totalSlotsGenerated = 0;
                emptyResp.totalSlotsReturned = 0;
                emptyResp.globalUtilizationPercentage = 0;
                return emptyResp;
            }

            // 4) Filter by skills
            Set<Id> qualifiedResources = filterResourcesBySkills(resourceIds, requiredSkills);
            debugLog('Qualified resources (after skill filter): ' + qualifiedResources.size());

            if (qualifiedResources.isEmpty()) {
                RestContext.response.statusCode = 200;
                SlotsResponse emptyResp = new SlotsResponse();
                emptyResp.slots = new List<SlotDTO>();
                emptyResp.resourceUtilization = new List<ResourceUtilization>();
                emptyResp.totalSlotsGenerated = 0;
                emptyResp.totalSlotsReturned = 0;
                emptyResp.globalUtilizationPercentage = 0;
                return emptyResp;
            }

            // 5) Operating Hours TimeSlots (ServiceTerritory already queried above)
            Map<Integer, List<TimeSlot>> ohSlotsByDay = new Map<Integer, List<TimeSlot>>();
            if (st.OperatingHoursId != null) {
                ohSlotsByDay = getTimeSlotsByDay(st.OperatingHoursId);
            }

            // 6) Build slots per resource (respect busy SA + absences + conditionally OH)
            List<SlotDTO> allSlots = new List<SlotDTO>();
            List<ResourceUtilization> allUtilization = new List<ResourceUtilization>();
            Integer totalSlotsBeforeCapacity = 0;

            // Preload resource names
            Map<Id, ServiceResource> resMap = new Map<Id, ServiceResource>(
                [SELECT Id, Name FROM ServiceResource WHERE Id IN :qualifiedResources]
            );

            // Preload absences for all qualified resources if needed
            Map<Id, List<TimeInterval>> absencesByResource = new Map<Id, List<TimeInterval>>();
            if (req.excludeAbsences) {
                absencesByResource = getAbsencesForResources(
                    qualifiedResources, windowStartUtc, windowEndUtc
                );
            }

            // NEW: Enhanced debug for absences
            debugLog('=== ABSENCE DEBUG ===');
            debugLog('excludeAbsences flag: ' + req.excludeAbsences);
            if (req.excludeAbsences) {
                for (Id resId : absencesByResource.keySet()) {
                    List<TimeInterval> absForRes = absencesByResource.get(resId);
                    String resName = resMap.containsKey(resId) ? resMap.get(resId).Name : 'Unknown';
                    debugLog('Resource ' + resName + ' (' + resId + ') has ' + absForRes.size() + ' absences:');
                    for (TimeInterval ti : absForRes) {
                        debugLog('  -> Absence: ' + ti.startTime + ' to ' + ti.endTime + ' (' + ti.getDurationMinutes() + ' min)');
                    }
                }
            }

            for (Id resId : qualifiedResources) {
                String resName = resMap.containsKey(resId) ? resMap.get(resId).Name : 'Unknown';
                debugLog('=== Processing resource: ' + resName + ' (' + resId + ') ===');

                // Busy intervals from existing SAs in UTC
                List<TimeInterval> busyFromSA = getBusyIntervalsForResource(
                    resId, windowStartUtc, windowEndUtc
                );
                debugLog('Busy intervals from ServiceAppointments: ' + busyFromSA.size());
                Integer busyMinutesSA = calculateTotalMinutes(busyFromSA);
                debugLog('Total busy minutes (SA): ' + busyMinutesSA);

                // Get absences for this resource
                List<TimeInterval> absences = new List<TimeInterval>();
                if (req.excludeAbsences && absencesByResource.containsKey(resId)) {
                    absences = absencesByResource.get(resId);
                }
                debugLog('Absence intervals for this resource: ' + absences.size());
                Integer absenceMinutesForRes = calculateTotalMinutes(absences);
                debugLog('Total absence minutes: ' + absenceMinutesForRes);

                // NEW: Log each absence interval
                for (TimeInterval abs : absences) {
                    debugLog('  Absence interval: ' + abs.startTime + ' to ' + abs.endTime);
                }

                // Merge all busy intervals (SA + Absences)
                List<TimeInterval> allBusy = mergeIntervals(busyFromSA, absences);
                debugLog('Merged busy intervals count: ' + allBusy.size());
                Integer totalBusyMinutes = calculateTotalMinutes(allBusy);
                debugLog('Total busy minutes (merged): ' + totalBusyMinutes);

                // NEW: Log merged intervals
                for (TimeInterval merged : allBusy) {
                    debugLog('  Merged busy: ' + merged.startTime + ' to ' + merged.endTime);
                }

                // Free intervals = window minus busy union
                TimeInterval window = new TimeInterval(windowStartUtc, windowEndUtc);
                List<TimeInterval> freeIntervals = computeFreeIntervals(window, allBusy);
                debugLog('Free intervals count: ' + freeIntervals.size());
                Integer freeMinutes = calculateTotalMinutes(freeIntervals);
                debugLog('Total free minutes: ' + freeMinutes);

                // NEW: Log free intervals
                for (TimeInterval freeInt : freeIntervals) {
                    debugLog('  Free interval: ' + freeInt.startTime + ' to ' + freeInt.endTime);
                }

                // Calculate current utilization percentage
                Integer windowMinutes = window.getDurationMinutes();
                Decimal currentUtilization = 0;
                if (windowMinutes > 0) {
                    currentUtilization = (Decimal)(totalBusyMinutes * 100) / windowMinutes;
                }
                debugLog('Current utilization: ' + currentUtilization.setScale(2) + '%');

                // Calculate how much utilization one slot would add
                Decimal slotUtilizationImpact = 0;
                if (windowMinutes > 0) {
                    slotUtilizationImpact = (Decimal)(durationMinutes * 100) / windowMinutes;
                }
                debugLog('Each slot adds: ' + slotUtilizationImpact.setScale(2) + '% utilization');

                // Check if adding even ONE slot would exceed capacity
                Decimal utilizationAfterOneSlot = currentUtilization + slotUtilizationImpact;
                debugLog('Utilization after 1 slot: ' + utilizationAfterOneSlot.setScale(2) + '% (capacity limit: ' + req.capacityPercentage + '%)');

                List<SlotDTO> slotsForResource = new List<SlotDTO>();

                if (utilizationAfterOneSlot > req.capacityPercentage) {
                    // Adding even one slot would exceed capacity - don't show any slots
                    debugLog('*** CAPACITY EXCEEDED: ' + utilizationAfterOneSlot.setScale(2) + '% > ' + req.capacityPercentage + '% - NO SLOTS for this resource');
                } else {
                    // Capacity OK - generate ALL available slots for this resource
                    debugLog('Capacity OK: ' + utilizationAfterOneSlot.setScale(2) + '% <= ' + req.capacityPercentage + '% - showing ALL available slots');
                    slotsForResource = buildSlotsForResource(
                        resId,
                        resName,
                        freeIntervals,
                        durationMinutes,
                        req.slotStepMinutes,
                        req.maxSlotsPerResource,
                        ohSlotsByDay,
                        ohTimeZone,
                        req.enforceOperatingHours,
                        req.returnLocalTime
                    );
                    debugLog('Slots generated for resource: ' + slotsForResource.size());
                }

                totalSlotsBeforeCapacity += slotsForResource.size();

                // Calculate utilization metrics for this resource
                ResourceUtilization utilization = new ResourceUtilization();
                utilization.resourceId = resId;
                utilization.resourceName = resName;
                utilization.totalWindowMinutes = windowMinutes;
                utilization.busyMinutes = busyMinutesSA;
                utilization.absenceMinutes = absenceMinutesForRes;
                utilization.availableMinutes = freeMinutes;
                utilization.slotsGenerated = slotsForResource.size();
                utilization.utilizationPercentage = currentUtilization.setScale(2);

                // Potential utilization = current + impact of ONE slot (what would happen if booked)
                // This shows how close to capacity the resource would be after booking
                utilization.potentialUtilization = utilizationAfterOneSlot.setScale(2);

                debugLog('Resource utilization: current=' + utilization.utilizationPercentage + '%, potential=' + utilization.potentialUtilization + '%');
                allUtilization.add(utilization);

                allSlots.addAll(slotsForResource);
            }

            // Sort all slots by start time
            allSlots.sort(new SlotByStartTime());

            // NEW: Calculate global utilization
            Decimal globalUtilization = 0;
            if (!allUtilization.isEmpty()) {
                Decimal sumUtilization = 0;
                for (ResourceUtilization ru : allUtilization) {
                    sumUtilization += ru.utilizationPercentage;
                }
                globalUtilization = sumUtilization / allUtilization.size();
                globalUtilization = globalUtilization.setScale(2);
            }

            debugLog('=== FINAL RESULT ===');
            debugLog('Total slots generated: ' + totalSlotsBeforeCapacity);
            debugLog('Total slots returned: ' + allSlots.size());
            debugLog('Global utilization: ' + globalUtilization + '%');

            // Build response
            SlotsResponse response = new SlotsResponse();
            response.slots = allSlots;
            response.resourceUtilization = allUtilization;
            response.totalSlotsGenerated = totalSlotsBeforeCapacity;
            response.totalSlotsReturned = allSlots.size();
            response.globalUtilizationPercentage = globalUtilization;

            RestContext.response.statusCode = 200;
            return response;

        } catch (Exception e) {
            debugLog('ERROR: ' + e.getMessage() + ' | Stack: ' + e.getStackTraceString());
            return setErrorResponse(500, 'Failed to compute slots: ' + e.getMessage());
        }
    }

    // ==========================
    // Helper to calculate total minutes from intervals
    // ==========================
    private static Integer calculateTotalMinutes(List<TimeInterval> intervals) {
        Integer total = 0;
        for (TimeInterval ti : intervals) {
            if (ti != null) {
                total += ti.getDurationMinutes();
            }
        }
        return total;
    }

    // ==========================
    // Merge two lists of intervals into one sorted, non-overlapping list
    // ==========================
    private static List<TimeInterval> mergeIntervals(List<TimeInterval> list1, List<TimeInterval> list2) {
        List<TimeInterval> combined = new List<TimeInterval>();
        if (list1 != null) {
            combined.addAll(list1);
        }
        if (list2 != null) {
            combined.addAll(list2);
        }

        if (combined.isEmpty()) {
            return combined;
        }

        // Sort by start time
        combined.sort(new IntervalByStartTime());

        // Merge overlapping intervals
        List<TimeInterval> merged = new List<TimeInterval>();
        TimeInterval current = combined[0];

        for (Integer i = 1; i < combined.size(); i++) {
            TimeInterval next = combined[i];

            // If current and next overlap or are adjacent, merge them
            if (next.startTime <= current.endTime) {
                // Extend current interval if next ends later
                if (next.endTime > current.endTime) {
                    current = new TimeInterval(current.startTime, next.endTime);
                }
            } else {
                // No overlap, add current to result and move to next
                merged.add(current);
                current = next;
            }
        }
        // Don't forget the last interval
        merged.add(current);

        return merged;
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
    // Resource Absences helper (breaks, lunch, PTO, etc.)
    // ==========================
    private static Map<Id, List<TimeInterval>> getAbsencesForResources(
        Set<Id> resourceIds,
        Datetime startWindowUtc,
        Datetime endWindowUtc
    ) {
        Map<Id, List<TimeInterval>> result = new Map<Id, List<TimeInterval>>();

        // Initialize empty lists for all resources
        for (Id resId : resourceIds) {
            result.put(resId, new List<TimeInterval>());
        }

        debugLog('=== QUERYING ResourceAbsence ===');
        debugLog('Resource IDs: ' + resourceIds);
        debugLog('Window: ' + startWindowUtc + ' to ' + endWindowUtc);

        // Query ResourceAbsence records that overlap with the window
        List<ResourceAbsence> absences = [
            SELECT Id, ResourceId, Start, End, Type, AbsenceNumber
            FROM ResourceAbsence
            WHERE ResourceId IN :resourceIds
            AND Start < :endWindowUtc
            AND End > :startWindowUtc
        ];

        debugLog('ResourceAbsence records found: ' + absences.size());

        for (ResourceAbsence ra : absences) {
            debugLog('Processing absence: ' + ra.AbsenceNumber + ' Type=' + ra.Type +
                     ' Start=' + ra.Start + ' End=' + ra.End + ' ResourceId=' + ra.ResourceId);

            if (ra.Start == null || ra.End == null || ra.Start >= ra.End) {
                debugLog('  -> Skipping: invalid dates');
                continue;
            }

            Datetime s = ra.Start;
            Datetime e = ra.End;

            // Clamp to window bounds
            if (s < startWindowUtc) {
                debugLog('  -> Clamping start from ' + s + ' to ' + startWindowUtc);
                s = startWindowUtc;
            }
            if (e > endWindowUtc) {
                debugLog('  -> Clamping end from ' + e + ' to ' + endWindowUtc);
                e = endWindowUtc;
            }

            TimeInterval absInterval = new TimeInterval(s, e);
            result.get(ra.ResourceId).add(absInterval);
            debugLog('  -> Added absence interval: ' + s + ' to ' + e + ' (' + absInterval.getDurationMinutes() + ' min)');
        }

        // Sort each resource's absences by start time
        for (Id resId : result.keySet()) {
            result.get(resId).sort(new IntervalByStartTime());
        }

        return result;
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
                   ServiceAppointment.Status,
                   ServiceAppointment.AppointmentNumber
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
            debugLog('Busy SA: ' + ar.ServiceAppointment.AppointmentNumber + ' [' + s + ' - ' + e + ']');
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

        debugLog('Computing free intervals. Window: ' + window.startTime + ' to ' + window.endTime);
        debugLog('Busy intervals to subtract: ' + busy.size());

        Datetime cursor = window.startTime;

        for (TimeInterval b : busy) {
            if (b == null || b.endTime <= cursor) {
                debugLog('  Skipping busy interval (already passed): ' + (b != null ? b.startTime + ' - ' + b.endTime : 'null'));
                continue;
            }
            if (b.startTime > cursor) {
                TimeInterval freeInterval = new TimeInterval(cursor, b.startTime);
                free.add(freeInterval);
                debugLog('  Free gap found: ' + cursor + ' to ' + b.startTime + ' (' + freeInterval.getDurationMinutes() + ' min)');
            }
            if (b.endTime > cursor) {
                cursor = b.endTime;
            }
            if (cursor >= window.endTime) break;
        }

        if (cursor < window.endTime) {
            TimeInterval lastFree = new TimeInterval(cursor, window.endTime);
            free.add(lastFree);
            debugLog('  Final free gap: ' + cursor + ' to ' + window.endTime + ' (' + lastFree.getDurationMinutes() + ' min)');
        }

        debugLog('Total free intervals: ' + free.size());
        return free;
    }

    // ==========================
    // Operating Hours helpers
    // ==========================

    // Map English DayOfWeek to integer 1-7 (Monday=1 ... Sunday=7)
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
    // Operating Hours check (UTC slot -> local OH)
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
    // Slot generation (free intervals + conditionally OH)
    // Generates ALL slots where the WorkType duration fits
    // Capacity check is done BEFORE calling this method
    // ==========================
    private static List<SlotDTO> buildSlotsForResource(
        Id resId,
        String resName,
        List<TimeInterval> freeIntervals,
        Integer durationMinutes,
        Integer stepMinutes,
        Integer maxSlotsPerResource,
        Map<Integer, List<TimeSlot>> ohSlotsByDay,
        String ohTimeZone,
        Boolean enforceOH,          // Control Operating Hours filtering
        Boolean includeLocalTime    // Include local time string fields
    ) {
        List<SlotDTO> slots = new List<SlotDTO>();
        if (durationMinutes <= 0 || stepMinutes <= 0) return slots;

        debugLog('Building ALL slots. enforceOH=' + enforceOH + ', duration=' + durationMinutes +
                 'min, step=' + stepMinutes + 'min');

        for (TimeInterval free : freeIntervals) {
            debugLog('  Processing free interval: ' + free.startTime + ' to ' + free.endTime +
                     ' (' + free.getDurationMinutes() + ' min)');

            // Align slot start to the next multiple of stepMinutes
            Datetime slotStart = alignToStepMinutes(free.startTime, stepMinutes);
            debugLog('  Aligned slot start: ' + slotStart + ' (from ' + free.startTime + ')');

            while (slotStart.addMinutes(durationMinutes) <= free.endTime) {
                Datetime slotEnd = slotStart.addMinutes(durationMinutes);

                // Only enforce Operating Hours if explicitly requested
                if (enforceOH && !isWithinOperatingHours(slotStart, slotEnd, ohSlotsByDay, ohTimeZone)) {
                    slotStart = slotStart.addMinutes(stepMinutes);
                    continue;
                }

                SlotDTO d = new SlotDTO();
                d.resourceId   = resId;
                d.resourceName = resName;
                d.startTime    = slotStart;
                d.endTime      = slotEnd;
                d.grade        = null;

                // Add local time strings if timezone is available
                if (includeLocalTime && String.isNotBlank(ohTimeZone)) {
                    d.startTimeLocal = slotStart.format('yyyy-MM-dd HH:mm', ohTimeZone);
                    d.endTimeLocal   = slotEnd.format('yyyy-MM-dd HH:mm', ohTimeZone);
                }

                slots.add(d);

                if (slots.size() >= maxSlotsPerResource) {
                    debugLog('  Max slots per resource reached: ' + maxSlotsPerResource);
                    return slots;
                }

                slotStart = slotStart.addMinutes(stepMinutes);
            }
        }

        debugLog('  Total slots generated: ' + slots.size());
        return slots;
    }

    // ==========================
    // Slot alignment helper
    // ==========================

    /**
     * Aligns a datetime to the next multiple of stepMinutes.
     * If the datetime is already aligned, it returns as-is.
     *
     * Example with stepMinutes=30:
     *   13:00 -> 13:00 (already aligned)
     *   13:15 -> 13:30 (next multiple)
     *   13:30 -> 13:30 (already aligned)
     *   13:50 -> 14:00 (next multiple)
     */
    private static Datetime alignToStepMinutes(Datetime dt, Integer stepMinutes) {
        if (dt == null || stepMinutes == null || stepMinutes <= 0) {
            return dt;
        }

        // Get the minutes component of the datetime (0-59)
        Integer minute = dt.minute();

        // Calculate remainder when divided by step
        Integer remainder = Math.mod(minute, stepMinutes);

        // If already aligned, return as-is
        if (remainder == 0) {
            return dt;
        }

        // Otherwise, advance to the next multiple
        Integer minutesToAdd = stepMinutes - remainder;
        return dt.addMinutes(minutesToAdd);
    }

    // ==========================
    // Service Territory Capacity Helper
    // ==========================

    private static Integer getServiceTerritoryCapacity(Id serviceTerritoryId) {
        if (serviceTerritoryId == null) return null;
        try {
            List<ServiceTerritory> sts = [
                SELECT Capacity__c FROM ServiceTerritory WHERE Id = :serviceTerritoryId LIMIT 1
            ];
            if (!sts.isEmpty() && sts[0].Capacity__c != null) {
                return ((Decimal) sts[0].Capacity__c).intValue();
            }
        } catch (Exception e) {
            debugLog('Could not read ST Capacity: ' + e.getMessage());
        }
        return null;
    }

    // ==========================
    // Timezone conversion helpers
    // ==========================

    /**
     * Convert a Datetime from local timezone to UTC.
     * The input datetime is interpreted as being in the specified timezone,
     * and converted to the equivalent UTC time.
     *
     * Example: 2025-12-04 08:00 in America/Costa_Rica (UTC-6) -> 2025-12-04 14:00 UTC
     */
    private static Datetime convertLocalToUtc(Datetime localTime, String timeZoneId) {
        if (localTime == null || String.isBlank(timeZoneId)) {
            return localTime;
        }

        try {
            // Get the timezone
            TimeZone tz = TimeZone.getTimeZone(timeZoneId);
            if (tz == null) {
                debugLog('WARNING: Invalid timezone ID: ' + timeZoneId);
                return localTime;
            }

            // Get offset in milliseconds for this datetime
            // Note: getOffset returns negative values for timezones behind UTC
            Integer offsetMs = tz.getOffset(localTime);

            // The input localTime is stored internally as UTC by Salesforce,
            // but we want to interpret it as local time.
            // So we need to SUBTRACT the offset to get the true UTC time.
            //
            // Example: User sends "2025-12-04T08:00:00.000Z" meaning 8 AM Costa Rica
            // Costa Rica is UTC-6, so offset = -6 hours = -21600000 ms
            // True UTC = 08:00 - (-6 hours) = 08:00 + 6 hours = 14:00 UTC

            Datetime utcTime = localTime.addSeconds(-offsetMs / 1000);

            debugLog('Timezone conversion: ' + localTime + ' (' + timeZoneId + ') -> ' + utcTime + ' (UTC)');
            debugLog('  Offset: ' + offsetMs + ' ms (' + (offsetMs / 3600000) + ' hours)');

            return utcTime;
        } catch (Exception e) {
            debugLog('ERROR in timezone conversion: ' + e.getMessage());
            return localTime;
        }
    }
}