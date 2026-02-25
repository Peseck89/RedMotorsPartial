public without sharing class ABAvailabilityFSL_GetSlots {

    // ===== Wrappers =====
    public class AvailabilityResponse {
        public List<WorkTypeAvailability> items = new List<WorkTypeAvailability>();
        public String toJson(){ return JSON.serialize(this); }
    }
    public class WorkTypeAvailability {
        public Id workTypeId;
        public String workTypeName;
        public Integer durationMinutes;
        public List<TimeWindow> windows = new List<TimeWindow>();
    }
    public class TimeWindow {
        public Datetime start;
        public Datetime endTime;
        public Decimal grade;
    }

    // ===== API =====
    public static String getNextWeekAvailabilityJSON(List<Id> serviceTerritoryIds, Boolean includeNonWorkHours){
        System.debug('=== getNextWeekAvailabilityJSON START ===');
        System.debug('Input territories: ' + serviceTerritoryIds);
        System.debug('Include non work hours: ' + includeNonWorkHours);

        String result = getNextWeekAvailability(serviceTerritoryIds, includeNonWorkHours).toJson();

        System.debug('=== getNextWeekAvailabilityJSON END === result: ' + result);
        return result;
    }

    public static AvailabilityResponse getNextWeekAvailability(List<Id> serviceTerritoryIds, Boolean includeNonWorkHours){

        System.debug('=== getNextWeekAvailability START ===');

        Datetime startDt = Datetime.newInstance(Date.today().addDays(7),  Time.newInstance(0,0,0,0));
        Datetime endDt   = Datetime.newInstance(Date.today().addDays(14), Time.newInstance(0,0,0,0));
        System.debug('[STEP] Date Range: ' + startDt + ' -> ' + endDt);

        // WorkType
        List<WorkType> wts = [
            SELECT Id, Name, EstimatedDuration
            FROM WorkType
            WHERE Id = '08qNq000000IbXNIA0'
            LIMIT 1
        ];
        
        //WHERE Name = 'Servicio de Mecánica Rápida XT JABV'
        
        System.debug('[STEP] WorkTypes found: ' + wts.size());

        if (wts.isEmpty()){
            System.debug('[ERROR] WorkType NOT FOUND');
            return new AvailabilityResponse();
        }

        WorkType wt = wts[0];
        System.debug('[OK] WorkType: ' + wt.Name + ' (' + wt.Id + ') Duration: ' + wt.EstimatedDuration);

        // Scheduling Policy
        Id policyId = resolvePolicyIdLatest();
        System.debug('[OK] Scheduling Policy Found: ' + policyId);

        // Service Territory
        if (serviceTerritoryIds == null || serviceTerritoryIds.isEmpty()){
            System.debug('[INFO] No Territory passed, selecting default active territory');
            ServiceTerritory st = [SELECT Id, Name FROM ServiceTerritory WHERE Id= '0HhNq000000LRjZKAW' LIMIT 1]; //IsActive = true LIMIT 1];
            System.debug('[OK] Using Territory: ' + st.Name + ' (' + st.Id + ')');
            serviceTerritoryIds = new List<Id>{ st.Id };
        }

        System.debug('[STEP] Final Territories to evaluate: ' + serviceTerritoryIds);

        AvailabilityResponse resp = new AvailabilityResponse();

        Integer dur = (wt.EstimatedDuration != null && wt.EstimatedDuration > 0)
                      ? Integer.valueOf(wt.EstimatedDuration) : 60;

        WorkTypeAvailability row = new WorkTypeAvailability();
        row.workTypeId = wt.Id;
        row.workTypeName = wt.Name;
        row.durationMinutes = dur;

        // Loop Territories
        for (Id terrId : serviceTerritoryIds){
            System.debug('--- PROCESSING TERRITORY ' + terrId + ' ---');

            Id calendarId = resolveOperatingHours(terrId);
            System.debug('[OK] Operating Hours Calendar: ' + calendarId);

            if (calendarId == null){
                System.debug('[WARN] Territory has NO operating hours, skipping...');
                continue;
            }

            ServiceAppointment sa = null;

            try {
                System.debug('[STEP] Creating Probe Appointment for Territory ' + terrId);

                sa = createProbeServiceAppointment(
                        wt.Id, terrId, startDt, endDt, dur, policyId, null, 'Hours', 'Nueva'
                    );

                System.debug('[OK] Probe ServiceAppointment Created: ' + sa.Id);

                TimeZone tz = UserInfo.getTimeZone();
                System.debug('[INFO] User Timezone: ' + tz);

                /*List<FSL.AppointmentBookingSlot> slots =
                    FSL.AppointmentBookingService.getSlots(
                        '08pNq000003N7rtIAC', policyId, calendarId, tz, true
                    );*/
                
                List<FSL.AppointmentBookingSlot> slots = FSL.AppointmentBookingService.getSlots(sa.Id, policyId, calendarId, tz, true);

                System.debug('[OK] Slots returned: ' + (slots == null ? 0 : slots.size()));

                if (slots != null){
                    for (FSL.AppointmentBookingSlot s : slots){
                        TimeWindow tw = new TimeWindow();
                        if (s.Interval != null){
                            tw.start   = s.Interval.Start;
                            tw.endTime = s.Interval.Finish;
                        }
                        tw.grade = s.Grade;

                        System.debug('[SLOT] Start: ' + tw.start + ' End: ' + tw.endTime + ' Grade: ' + tw.grade);

                        if (tw.start != null && tw.endTime != null){
                            row.windows.add(tw);
                        }
                    }
                }

            } catch (Exception e){
                System.debug('[ERROR][GetSlots] ' + e.getMessage() + ' | ' + e.getStackTraceString());
            } finally {
                if (sa != null){
                    try {
                        //delete sa;
                        System.debug('[OK] Probe SA deleted: ' + sa.Id);
                    } catch (Exception exDel){
                        System.debug('[WARN] Could not delete probe SA ' + sa.Id + ': ' + exDel.getMessage());
                    }
                }
            }
        }

        resp.items.add(row);

        System.debug('[DONE] Total WorkType Records: ' + resp.items.size());
        System.debug('=== getNextWeekAvailability END ===');
        return resp;
    }

    // ===== Helpers =====
    private static Id resolvePolicyIdLatest(){
        System.debug('[STEP] Resolving latest Scheduling Policy...');
        try {
            List<SObject> rows = Database.query(
                'SELECT Id, Name FROM FSL__Scheduling_Policy__c ORDER BY LastModifiedDate DESC LIMIT 1'
            );
            
            //'SELECT Id, Name FROM FSL__Scheduling_Policy__c ORDER BY LastModifiedDate DESC LIMIT 1' a2ONq000009YOynMAG
            if (!rows.isEmpty()) {
                System.debug('[OK] Found managed policy: ' + rows[0].get('Id'));
                return (Id)rows[0].get('Id');
            }
        } catch (Exception ignore){}

        return null;
    }

    private static Id resolveOperatingHours(Id territoryId){
        System.debug('[STEP] Fetching Operating Hours for Territory ' + territoryId);

        ServiceTerritory st = [
            SELECT OperatingHoursId, Name
            FROM ServiceTerritory
            WHERE Id = :territoryId
            LIMIT 1
        ];

        System.debug('[OK] Territory: ' + st.Name + ' Calendar: ' + st.OperatingHoursId);

        return st != null ? st.OperatingHoursId : null;
    }

    private static ServiceAppointment createProbeServiceAppointment(
        Id workTypeId,
        Id territoryId,
        Datetime startDt,
        Datetime endDt,
        Integer durationMinutes,
        Id policyId,
        Id parentWorkOrderId,
        String durationType,
    	String statusValue
    ){

        System.debug('[CREATE-SA] START - WorkType: ' + workTypeId + ', Territory: ' + territoryId);

        // Get WO
        Id woId = parentWorkOrderId;
        if (woId == null){
            try {
                WorkOrder wo = [
                    SELECT Id, WorkOrderNumber
                    FROM WorkOrder
                    WHERE ServiceTerritoryId = :territoryId
                    ORDER BY CreatedDate DESC
                    LIMIT 1
                ];
                woId = (wo != null) ? wo.Id : null;
                System.debug('[CREATE-SA] Found WO: ' + woId);
            } catch (Exception ignore){}
        }
        
        woId='0WONq000009kUabOAE';

        ServiceAppointment sa = new ServiceAppointment();
        sa.Subject            = 'AB Probe - ' + String.valueOf(workTypeId);
        sa.WorkTypeId         = workTypeId;
        sa.ServiceTerritoryId = territoryId;
        sa.EarliestStartTime  = startDt;
        sa.DueDate            = endDt;
        sa.Duration           = durationMinutes;
        sa.DurationType       = durationType;
        sa.FSL__Use_Async_Logic__c = false;
        sa.OwnerId  = '005Nq00000PPDbZIAX';

        if (policyId != null) sa.FSL__Scheduling_Policy_Used__c = policyId;
        if (woId != null) sa.ParentRecordId = woId;

        //sa.SchedStartTime = startDt;
        //sa.SchedEndTime   = startDt.addMinutes(durationMinutes);

        
        sa.Status = String.isNotBlank(statusValue)  ? statusValue  : 'Nueva';

        System.debug('[CREATE-SA] INSERTING SA...');
        insert sa;
        System.debug('[CREATE-SA] INSERTED SA Id: ' + sa.Id);

        return sa;
    }
}