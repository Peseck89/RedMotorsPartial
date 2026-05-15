/**
 * FSL_SimpleSlotsService
 *
 * Servicio interno para consultar slots disponibles en Field Service.
 * Wrapper de FSL_SimpleSlotsApi para uso nativo en Salesforce.
 *
 * Uso desde LWC/Aura:
 *   - Llamar métodos @AuraEnabled
 *
 * Uso desde Apex:
 *   - FSL_SimpleSlotsService.SlotsResult result = FSL_SimpleSlotsService.getAvailableSlots(params);
 *
 * Uso desde Flow:
 *   - Usar la clase FSL_SimpleSlotsService.GetSlotsInvocable
 *
 * @author Claude Code
 * @date 2025-12-04
 */
public with sharing class FSL_SimpleSlotsService {

    // ==========================
    // Request Parameters DTO
    // ==========================
    public class SlotsParams {
        @AuraEnabled public Id serviceTerritoryId { get; set; }
        @AuraEnabled public Id workTypeId { get; set; }
        @AuraEnabled public Datetime earliestStart { get; set; }
        @AuraEnabled public Datetime dueDate { get; set; }
        @AuraEnabled public Integer slotStepMinutes { get; set; }
        @AuraEnabled public Integer maxSlotsPerResource { get; set; }
        @AuraEnabled public String operatingHoursTimeZone { get; set; }
        @AuraEnabled public Integer capacityPercentage { get; set; }
        @AuraEnabled public Boolean excludeAbsences { get; set; }
        @AuraEnabled public Boolean enforceOperatingHours { get; set; }
        @AuraEnabled public Boolean windowInLocalTime { get; set; }
        @AuraEnabled public Boolean returnLocalTime { get; set; }
        @AuraEnabled public Integer overrideCapacity { get; set; }

        public SlotsParams() {
            // Defaults
            this.slotStepMinutes = 30;
            this.maxSlotsPerResource = 500;
            this.capacityPercentage = 100;
            this.excludeAbsences = true;
            this.enforceOperatingHours = true;  // Respects TimeSlots, excludes days without TimeSlots (e.g., Sundays)
            this.windowInLocalTime = false;
            this.returnLocalTime = true;
        }
    }

    // ==========================
    // Response DTOs
    // ==========================
    public class SlotsResult {
        @AuraEnabled public Boolean success { get; set; }
        @AuraEnabled public String errorMessage { get; set; }
        @AuraEnabled public List<SlotInfo> slots { get; set; }
        @AuraEnabled public List<ResourceUtilizationInfo> resourceUtilization { get; set; }
        @AuraEnabled public Integer totalSlotsGenerated { get; set; }
        @AuraEnabled public Integer totalSlotsReturned { get; set; }
        @AuraEnabled public Decimal globalUtilizationPercentage { get; set; }

        public SlotsResult() {
            this.success = true;
            this.slots = new List<SlotInfo>();
            this.resourceUtilization = new List<ResourceUtilizationInfo>();
            this.totalSlotsGenerated = 0;
            this.totalSlotsReturned = 0;
            this.globalUtilizationPercentage = 0;
        }
    }

    public class SlotInfo {
        @AuraEnabled public Id resourceId { get; set; }
        @AuraEnabled public String resourceName { get; set; }
        @AuraEnabled public Datetime startTime { get; set; }
        @AuraEnabled public Datetime endTime { get; set; }
        @AuraEnabled public String startTimeLocal { get; set; }
        @AuraEnabled public String endTimeLocal { get; set; }
        @AuraEnabled public Decimal grade { get; set; }
    }

    public class ResourceUtilizationInfo {
        @AuraEnabled public Id resourceId { get; set; }
        @AuraEnabled public String resourceName { get; set; }
        @AuraEnabled public Integer totalWindowMinutes { get; set; }
        @AuraEnabled public Integer busyMinutes { get; set; }
        @AuraEnabled public Integer absenceMinutes { get; set; }
        @AuraEnabled public Integer availableMinutes { get; set; }
        @AuraEnabled public Integer slotsGenerated { get; set; }
        @AuraEnabled public Decimal utilizationPercentage { get; set; }
        @AuraEnabled public Decimal potentialUtilization { get; set; }
    }

    // ==========================
    // Main Service Method (Apex callable)
    // ==========================

    /**
     * Get available slots - main service method
     * Can be called from any Apex code
     */
    public static SlotsResult getAvailableSlots(SlotsParams params) {
        SlotsResult result = new SlotsResult();

        try {
            // Validate required fields
            if (params.serviceTerritoryId == null) {
                throw new SlotsServiceException('serviceTerritoryId is required.');
            }
            if (params.workTypeId == null) {
                throw new SlotsServiceException('workTypeId is required.');
            }
            if (params.earliestStart == null) {
                throw new SlotsServiceException('earliestStart is required.');
            }
            if (params.dueDate == null) {
                throw new SlotsServiceException('dueDate is required.');
            }
            if (params.earliestStart >= params.dueDate) {
                throw new SlotsServiceException('earliestStart must be before dueDate.');
            }

            // Capacity resolution: overrideCapacity > ST.Capacity__c > capacityPercentage param > 100
            if (params.overrideCapacity != null && params.overrideCapacity > 0 && params.overrideCapacity <= 100) {
                params.capacityPercentage = params.overrideCapacity;
            } else if (params.capacityPercentage == null || params.capacityPercentage == 100) {
                Integer stCapacity = getServiceTerritoryCapacity(params.serviceTerritoryId);
                if (stCapacity != null) {
                    params.capacityPercentage = stCapacity;
                }
            }

            // Build the API request
            FSL_SimpleSlotsApi.SlotsRequest apiRequest = new FSL_SimpleSlotsApi.SlotsRequest();
            apiRequest.serviceTerritoryId = params.serviceTerritoryId;
            apiRequest.workTypeId = params.workTypeId;
            apiRequest.earliestStart = params.earliestStart;
            apiRequest.dueDate = params.dueDate;
            apiRequest.slotStepMinutes = params.slotStepMinutes;
            apiRequest.maxSlotsPerResource = params.maxSlotsPerResource;
            apiRequest.operatingHoursTimeZone = params.operatingHoursTimeZone;
            apiRequest.capacityPercentage = params.capacityPercentage;
            apiRequest.excludeAbsences = params.excludeAbsences;
            apiRequest.enforceOperatingHours = params.enforceOperatingHours;
            apiRequest.windowInLocalTime = params.windowInLocalTime;
            apiRequest.returnLocalTime = params.returnLocalTime;

            // Call the internal processor
            FSL_SimpleSlotsApi.SlotsResponse apiResponse = processSlots(apiRequest);

            // Map response to our DTOs
            result.totalSlotsGenerated = apiResponse.totalSlotsGenerated;
            result.totalSlotsReturned = apiResponse.totalSlotsReturned;
            result.globalUtilizationPercentage = apiResponse.globalUtilizationPercentage;

            // Map slots
            for (FSL_SimpleSlotsApi.SlotDTO slot : apiResponse.slots) {
                SlotInfo info = new SlotInfo();
                info.resourceId = slot.resourceId;
                info.resourceName = slot.resourceName;
                info.startTime = slot.startTime;
                info.endTime = slot.endTime;
                info.startTimeLocal = slot.startTimeLocal;
                info.endTimeLocal = slot.endTimeLocal;
                info.grade = slot.grade;
                result.slots.add(info);
            }

            // Map utilization
            for (FSL_SimpleSlotsApi.ResourceUtilization util : apiResponse.resourceUtilization) {
                ResourceUtilizationInfo info = new ResourceUtilizationInfo();
                info.resourceId = util.resourceId;
                info.resourceName = util.resourceName;
                info.totalWindowMinutes = util.totalWindowMinutes;
                info.busyMinutes = util.busyMinutes;
                info.absenceMinutes = util.absenceMinutes;
                info.availableMinutes = util.availableMinutes;
                info.slotsGenerated = util.slotsGenerated;
                info.utilizationPercentage = util.utilizationPercentage;
                info.potentialUtilization = util.potentialUtilization;
                result.resourceUtilization.add(info);
            }

        } catch (SlotsServiceException e) {
            result.success = false;
            result.errorMessage = e.getMessage();
        } catch (Exception e) {
            result.success = false;
            result.errorMessage = 'Error getting slots: ' + e.getMessage();
        }

        return result;
    }

    // ==========================
    // AuraEnabled Methods (for LWC/Aura)
    // ==========================

    /**
     * Get available slots - LWC/Aura callable
     * @param serviceTerritoryId Service Territory Id
     * @param workTypeId Work Type Id
     * @param earliestStart Start of window (local time if windowInLocalTime=true)
     * @param dueDate End of window (local time if windowInLocalTime=true)
     * @param options JSON string with optional parameters
     */
    @AuraEnabled(cacheable=false)
    public static SlotsResult getSlots(
        Id serviceTerritoryId,
        Id workTypeId,
        Datetime earliestStart,
        Datetime dueDate,
        String optionsJson
    ) {
        SlotsParams params = new SlotsParams();
        params.serviceTerritoryId = serviceTerritoryId;
        params.workTypeId = workTypeId;
        params.earliestStart = earliestStart;
        params.dueDate = dueDate;

        // Parse optional parameters from JSON
        if (String.isNotBlank(optionsJson)) {
            Map<String, Object> options = (Map<String, Object>) JSON.deserializeUntyped(optionsJson);

            if (options.containsKey('slotStepMinutes')) {
                params.slotStepMinutes = (Integer) options.get('slotStepMinutes');
            }
            if (options.containsKey('maxSlotsPerResource')) {
                params.maxSlotsPerResource = (Integer) options.get('maxSlotsPerResource');
            }
            if (options.containsKey('operatingHoursTimeZone')) {
                params.operatingHoursTimeZone = (String) options.get('operatingHoursTimeZone');
            }
            if (options.containsKey('capacityPercentage')) {
                params.capacityPercentage = (Integer) options.get('capacityPercentage');
            }
            if (options.containsKey('excludeAbsences')) {
                params.excludeAbsences = (Boolean) options.get('excludeAbsences');
            }
            if (options.containsKey('enforceOperatingHours')) {
                params.enforceOperatingHours = (Boolean) options.get('enforceOperatingHours');
            }
            if (options.containsKey('windowInLocalTime')) {
                params.windowInLocalTime = (Boolean) options.get('windowInLocalTime');
            }
            if (options.containsKey('returnLocalTime')) {
                params.returnLocalTime = (Boolean) options.get('returnLocalTime');
            }
            if (options.containsKey('overrideCapacity')) {
                params.overrideCapacity = (Integer) options.get('overrideCapacity');
            }
        }

        return getAvailableSlots(params);
    }

    /**
     * Get available slots with all parameters explicit - LWC/Aura callable
     * Useful when you need full control over all parameters
     */
    @AuraEnabled(cacheable=false)
    public static SlotsResult getSlotsWithParams(
        Id serviceTerritoryId,
        Id workTypeId,
        Datetime earliestStart,
        Datetime dueDate,
        Integer slotStepMinutes,
        Integer capacityPercentage,
        Boolean excludeAbsences,
        Boolean windowInLocalTime,
        Boolean returnLocalTime,
        String operatingHoursTimeZone
    ) {
        SlotsParams params = new SlotsParams();
        params.serviceTerritoryId = serviceTerritoryId;
        params.workTypeId = workTypeId;
        params.earliestStart = earliestStart;
        params.dueDate = dueDate;
        params.slotStepMinutes = slotStepMinutes != null ? slotStepMinutes : 30;
        params.capacityPercentage = capacityPercentage != null ? capacityPercentage : 100;
        params.excludeAbsences = excludeAbsences != null ? excludeAbsences : true;
        params.windowInLocalTime = windowInLocalTime != null ? windowInLocalTime : false;
        params.returnLocalTime = returnLocalTime != null ? returnLocalTime : true;
        params.operatingHoursTimeZone = operatingHoursTimeZone;

        return getAvailableSlots(params);
    }

    /**
     * Simple method to get slots for a specific date - LWC/Aura callable
     * Automatically sets window to full day in local timezone
     */
    @AuraEnabled(cacheable=false)
    public static SlotsResult getSlotsForDate(
        Id serviceTerritoryId,
        Id workTypeId,
        Date targetDate,
        String operatingHoursTimeZone
    ) {
        SlotsParams params = new SlotsParams();
        params.serviceTerritoryId = serviceTerritoryId;
        params.workTypeId = workTypeId;

        // Set window to full day (8:00 AM to 5:00 PM local)
        params.earliestStart = Datetime.newInstance(targetDate, Time.newInstance(8, 0, 0, 0));
        params.dueDate = Datetime.newInstance(targetDate, Time.newInstance(17, 0, 0, 0));
        params.windowInLocalTime = true;
        params.returnLocalTime = true;
        params.operatingHoursTimeZone = String.isNotBlank(operatingHoursTimeZone)
            ? operatingHoursTimeZone
            : 'America/Costa_Rica';

        return getAvailableSlots(params);
    }

    /**
     * Get slots for multiple days - LWC/Aura callable
     * Returns slots for a date range
     */
    @AuraEnabled(cacheable=false)
    public static SlotsResult getSlotsForDateRange(
        Id serviceTerritoryId,
        Id workTypeId,
        Date startDate,
        Date endDate,
        String operatingHoursTimeZone
    ) {
        SlotsParams params = new SlotsParams();
        params.serviceTerritoryId = serviceTerritoryId;
        params.workTypeId = workTypeId;

        // Set window from start date 8 AM to end date 5 PM
        params.earliestStart = Datetime.newInstance(startDate, Time.newInstance(8, 0, 0, 0));
        params.dueDate = Datetime.newInstance(endDate, Time.newInstance(17, 0, 0, 0));
        params.windowInLocalTime = true;
        params.returnLocalTime = true;
        params.enforceOperatingHours = true; // Filter by OH for multi-day
        params.operatingHoursTimeZone = String.isNotBlank(operatingHoursTimeZone)
            ? operatingHoursTimeZone
            : 'America/Costa_Rica';

        return getAvailableSlots(params);
    }

    // ==========================
    // Flow Invocable Method
    // ==========================

    /**
     * Invocable method for Flow Builder
     */
    @InvocableMethod(
        label='Get Available Slots'
        description='Returns available appointment slots for Field Service scheduling'
        category='Field Service'
    )
    public static List<FlowOutput> getAvailableSlotsInvocable(List<FlowInput> inputs) {
        List<FlowOutput> outputs = new List<FlowOutput>();

        for (FlowInput input : inputs) {
            FlowOutput output = new FlowOutput();

            try {
                SlotsParams params = new SlotsParams();
                params.serviceTerritoryId = input.serviceTerritoryId;
                params.workTypeId = input.workTypeId;
                params.earliestStart = input.earliestStart;
                params.dueDate = input.dueDate;
                params.operatingHoursTimeZone = input.operatingHoursTimeZone;
                params.capacityPercentage = input.capacityPercentage != null ? input.capacityPercentage : 100;
                params.excludeAbsences = input.excludeAbsences != null ? input.excludeAbsences : true;
                params.windowInLocalTime = input.windowInLocalTime != null ? input.windowInLocalTime : true;
                params.returnLocalTime = true;

                SlotsResult result = getAvailableSlots(params);

                output.success = result.success;
                output.errorMessage = result.errorMessage;
                output.totalSlotsAvailable = result.totalSlotsReturned;
                output.slotsJson = JSON.serialize(result.slots);
                output.utilizationJson = JSON.serialize(result.resourceUtilization);
                output.globalUtilizationPercentage = result.globalUtilizationPercentage;

            } catch (Exception e) {
                output.success = false;
                output.errorMessage = e.getMessage();
                output.totalSlotsAvailable = 0;
            }

            outputs.add(output);
        }

        return outputs;
    }

    // Flow Input class
    public class FlowInput {
        @InvocableVariable(required=true label='Service Territory ID')
        public Id serviceTerritoryId;

        @InvocableVariable(required=true label='Work Type ID')
        public Id workTypeId;

        @InvocableVariable(required=true label='Earliest Start')
        public Datetime earliestStart;

        @InvocableVariable(required=true label='Due Date')
        public Datetime dueDate;

        @InvocableVariable(label='Operating Hours Timezone')
        public String operatingHoursTimeZone;

        @InvocableVariable(label='Capacity Percentage (1-100)')
        public Integer capacityPercentage;

        @InvocableVariable(label='Exclude Absences')
        public Boolean excludeAbsences;

        @InvocableVariable(label='Window In Local Time')
        public Boolean windowInLocalTime;
    }

    // Flow Output class
    public class FlowOutput {
        @InvocableVariable(label='Success')
        public Boolean success;

        @InvocableVariable(label='Error Message')
        public String errorMessage;

        @InvocableVariable(label='Total Slots Available')
        public Integer totalSlotsAvailable;

        @InvocableVariable(label='Slots JSON')
        public String slotsJson;

        @InvocableVariable(label='Utilization JSON')
        public String utilizationJson;

        @InvocableVariable(label='Global Utilization Percentage')
        public Decimal globalUtilizationPercentage;
    }

    // ==========================
    // Internal Processing
    // ==========================

    /**
     * Process slots using the same logic as the REST API
     * This method contains the core logic extracted from FSL_SimpleSlotsApi
     */
    private static FSL_SimpleSlotsApi.SlotsResponse processSlots(FSL_SimpleSlotsApi.SlotsRequest req) {
        // Create a mock REST context for the API
        RestRequest restReq = new RestRequest();
        RestResponse restRes = new RestResponse();
        restReq.requestBody = Blob.valueOf(JSON.serialize(req));
        RestContext.request = restReq;
        RestContext.response = restRes;

        // Call the API method
        return FSL_SimpleSlotsApi.getSimpleSlots();
    }

    // ==========================
    // Debug / Summary Helper
    // ==========================

    /**
     * Generate a formatted summary log of the slots result
     * Useful for debugging and testing in Anonymous Apex
     * @param result The SlotsResult to summarize
     * @return Formatted string with summary
     */
    public static String getSummary(SlotsResult result) {
        if (result == null) {
            return '=== SLOTS SUMMARY ===\nResult is null';
        }

        List<String> lines = new List<String>();
        lines.add('');
        lines.add('╔══════════════════════════════════════════════════════════════╗');
        lines.add('║                    SLOTS SUMMARY                             ║');
        lines.add('╠══════════════════════════════════════════════════════════════╣');
        lines.add('║ Success: ' + String.valueOf(result.success).rightPad(51) + '║');

        if (!result.success) {
            lines.add('║ Error: ' + (result.errorMessage != null ? result.errorMessage : 'Unknown').rightPad(53) + '║');
        }

        lines.add('║ Total Slots: ' + String.valueOf(result.totalSlotsReturned).rightPad(47) + '║');
        lines.add('║ Global Utilization: ' + String.valueOf(result.globalUtilizationPercentage) + '%'.rightPad(39) + '║');
        lines.add('╠══════════════════════════════════════════════════════════════╣');

        // Group slots by resource
        Map<String, List<SlotInfo>> slotsByResource = new Map<String, List<SlotInfo>>();
        for (SlotInfo slot : result.slots) {
            String resName = slot.resourceName != null ? slot.resourceName : 'Unknown';
            if (!slotsByResource.containsKey(resName)) {
                slotsByResource.put(resName, new List<SlotInfo>());
            }
            slotsByResource.get(resName).add(slot);
        }

        // Resource utilization
        lines.add('║ RESOURCE UTILIZATION:                                        ║');
        for (ResourceUtilizationInfo util : result.resourceUtilization) {
            String utilLine = '║   • ' + util.resourceName + ': ' + util.utilizationPercentage + '% used, ' + util.slotsGenerated + ' slots';
            lines.add(utilLine.rightPad(63) + '║');
        }

        lines.add('╠══════════════════════════════════════════════════════════════╣');
        lines.add('║ AVAILABLE SLOTS BY RESOURCE:                                 ║');

        for (String resName : slotsByResource.keySet()) {
            List<SlotInfo> resourceSlots = slotsByResource.get(resName);
            lines.add('║                                                              ║');
            String resHeader = '║ ▸ ' + resName + ' (' + resourceSlots.size() + ' slots)';
            lines.add(resHeader.rightPad(63) + '║');

            // Show first 5 and last 2 slots if more than 7
            Integer showCount = Math.min(resourceSlots.size(), 5);
            for (Integer i = 0; i < showCount; i++) {
                SlotInfo slot = resourceSlots[i];
                String timeStr = slot.startTimeLocal + ' → ' + slot.endTimeLocal;
                lines.add('║     ' + timeStr.rightPad(57) + '║');
            }

            if (resourceSlots.size() > 7) {
                lines.add('║     ... (' + (resourceSlots.size() - 7) + ' more slots) ...'.rightPad(57) + '║');
                // Show last 2
                for (Integer i = resourceSlots.size() - 2; i < resourceSlots.size(); i++) {
                    SlotInfo slot = resourceSlots[i];
                    String timeStr = slot.startTimeLocal + ' → ' + slot.endTimeLocal;
                    lines.add('║     ' + timeStr.rightPad(57) + '║');
                }
            } else if (resourceSlots.size() > showCount) {
                for (Integer i = showCount; i < resourceSlots.size(); i++) {
                    SlotInfo slot = resourceSlots[i];
                    String timeStr = slot.startTimeLocal + ' → ' + slot.endTimeLocal;
                    lines.add('║     ' + timeStr.rightPad(57) + '║');
                }
            }
        }

        lines.add('╚══════════════════════════════════════════════════════════════╝');
        lines.add('');

        return String.join(lines, '\n');
    }

    /**
     * Print summary to debug log
     * @param result The SlotsResult to log
     */
    public static void logSummary(SlotsResult result) {
        System.debug(LoggingLevel.INFO, getSummary(result));
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
            System.debug(LoggingLevel.WARN, 'Could not read ST Capacity: ' + e.getMessage());
        }
        return null;
    }

    // ==========================
    // Custom Exception
    // ==========================
    public class SlotsServiceException extends Exception {}
}