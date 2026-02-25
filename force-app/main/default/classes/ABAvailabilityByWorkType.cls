public with sharing class ABAvailabilityByWorkType {
    // =========================
    // ====== WRAPPERS =========
    // =========================
    public class AvailabilityWindow {
        public Datetime start;
        public Datetime endTime;
        public Decimal grade;
        public String serviceResourceId;
        public String serviceTerritoryId;
        public Id calendarId;
        public Id policyId;
        public Id serviceId;
    }
    public class WorkTypeAvailability {
        public Id workTypeId;
        public String workTypeName;
        public Integer durationMinutes;
        public List<AvailabilityWindow> windows = new List<AvailabilityWindow>();
        public List<Map<String,Object>> requiredSkills = new List<Map<String,Object>>();
    }
    public class AvailabilityResponse {
        public List<WorkTypeAvailability> items = new List<WorkTypeAvailability>();
        public String toJson(){ return JSON.serialize(this); }
    }

    // =========================
    // ====== CONSTANTES =======
    // =========================
    private static final String FLOW_API_NAME = 'FSL_GetSlots';
    private static final String VAR_CALENDAR_ID = 'varCalendarId';
    private static final String VAR_POLICY_ID = 'varPolicyId';
    private static final String VAR_SERVICE_ID = 'varServiceId';
    private static final String VAR_TZ = 'varTz';
    private static final String VAR_START = 'varStart';
    private static final String VAR_END = 'varEnd';

    private static final String OUT_COL_SLOT_START = 'colSlotStart';
    private static final String OUT_COL_SLOT_FINISH = 'colSlotFinish';
    private static final String OUT_COL_GRADE = 'colGrade';

    // =========================
    // ====== API PUBLICO ======
    // =========================
    public static String getNextWeekAvailabilityJSON(List<Id> serviceTerritoryIds){
        return getNextWeekAvailability(serviceTerritoryIds).toJson();
    }

    public static AvailabilityResponse getNextWeekAvailability(List<Id> serviceTerritoryIds){
        
        Datetime startDt = Datetime.newInstance(Date.today(), Time.newInstance(0,0,0,0));
        Datetime endDt   = startDt.addDays(7);
        System.debug('[AVAIL] Rango fecha: startDt=' + startDt + ' endDt=' + endDt);

        List<WorkType> wts = [
            SELECT Id, Name, EstimatedDuration
            FROM WorkType
        ];
        System.debug('[AVAIL] WorkTypes encontrados: ' + wts);

        Map<Id, List<Map<String,Object>>> wtSkills = loadWorkTypeSkillsDynamic(wts);
        System.debug('[AVAIL] Skills por WorkType: ' + wtSkills);

        Id policyId = resolvePolicyIdDynamically();
        System.debug('[AVAIL] PolicyId usado: ' + policyId);

        String tzId;
        try { tzId = UserInfo.getTimeZone().getID(); }
        catch (Exception e) { tzId = 'UTC'; }
        System.debug('[AVAIL] TimeZone usada: ' + tzId);

        if (serviceTerritoryIds == null || serviceTerritoryIds.isEmpty()) {
            ServiceTerritory st = [
                SELECT Id
                FROM ServiceTerritory
                WHERE IsActive = true
                LIMIT 1
            ];
            serviceTerritoryIds = (st != null) ? new List<Id>{ st.Id } : new List<Id>();
        }
        System.debug('[AVAIL] Territorios usados: ' + serviceTerritoryIds);

        AvailabilityResponse resp = new AvailabilityResponse();

        for (WorkType wt : wts) {
            
            Integer dur = (wt.EstimatedDuration != null && wt.EstimatedDuration > 0)
                ? Integer.valueOf(wt.EstimatedDuration) : 60;

            Id serviceId = resolveServiceIdForWorkType(wt.Id, dur);
            System.debug('[AVAIL] WT: ' + wt.Name + ' Id=' + wt.Id + ' Duration=' + dur + ' ServiceId=' + serviceId);

            WorkTypeAvailability row = new WorkTypeAvailability();
            row.workTypeId = wt.Id;
            row.workTypeName = wt.Name;
            row.durationMinutes = dur;
            row.requiredSkills = wtSkills.get(wt.Id);

            for (Id terrId : serviceTerritoryIds) {
                Id calendarId = resolveCalendarId(terrId);
                System.debug('[AVAIL] Territory=' + terrId + ' CalendarId=' + calendarId);

                if (calendarId == null) continue;

                List<AvailabilityWindow> wins = runFlowGetSlots(calendarId, policyId, serviceId, tzId, startDt, endDt);
                System.debug('[AVAIL] Slots obtenidos WT=' + wt.Name + ': ' + wins);

                for (AvailabilityWindow w : wins) {
                    w.calendarId = calendarId;
                    w.policyId   = policyId;
                    w.serviceId  = serviceId;
                }

                row.windows.addAll(wins);
            }

            resp.items.add(row);
        }

        System.debug('[AVAIL] Resultado final=' + resp);
        return resp;
    }

    // =========================
    // ====== FLOW CALL ========
    // =========================
    private static List<AvailabilityWindow> runFlowGetSlots(
        Id calendarId, Id policyId, Id serviceId, String tzId, Datetime startDt, Datetime endDt
    ){
        Map<String,Object> inputs = new Map<String,Object>{
            VAR_CALENDAR_ID => (String)calendarId,
            VAR_POLICY_ID   => (String)policyId,
            VAR_SERVICE_ID  => (String)serviceId,
            VAR_TZ          => tzId,
            VAR_START       => startDt,
            VAR_END         => endDt
        };

        System.debug('[AVAIL] FLOW INPUTS: ' + inputs);

        Flow.Interview interview = Flow.Interview.createInterview(FLOW_API_NAME, inputs);
        interview.start();

        Object startsObj   = interview.getVariableValue(OUT_COL_SLOT_START);
        Object finishesObj = interview.getVariableValue(OUT_COL_SLOT_FINISH);
        Object gradesObj   = interview.getVariableValue(OUT_COL_GRADE);

        System.debug('[AVAIL] FLOW raw SlotStart=' + startsObj);
        System.debug('[AVAIL] FLOW raw SlotFinish=' + finishesObj);
        System.debug('[AVAIL] FLOW raw Grade=' + gradesObj);

        List<AvailabilityWindow> out = mapSlotsFromParallelCollections(startsObj, finishesObj, gradesObj);
        System.debug('[AVAIL] FLOW windows final=' + out);

        return out;
    }

    // =========================
    // ====== MAPPERS ==========
    // =========================
    private static List<AvailabilityWindow> mapSlotsFromParallelCollections(
        Object startsObj, Object finishesObj, Object gradesObj
    ){
        List<AvailabilityWindow> out = new List<AvailabilityWindow>();

        List<Datetime> starts = castListDatetime(startsObj);
        List<Datetime> finishes = castListDatetime(finishesObj);
        List<Decimal> grades = castListDecimal(gradesObj);

        Integer n = Math.min(starts.size(), Math.min(finishes.size(), grades.size()));

        for (Integer i = 0; i < n; i++) {
            if (starts[i] == null || finishes[i] == null) continue;

            AvailabilityWindow w = new AvailabilityWindow();
            w.start   = starts[i];
            w.endTime = finishes[i];
            w.grade   = grades[i];

            out.add(w);
        }
        return out;
    }

    private static List<Datetime> castListDatetime(Object o){
        List<Datetime> out = new List<Datetime>();
        if (o instanceof List<Object>) {
            for (Object v : (List<Object>) o) {
                try { out.add((Datetime)v); } catch (Exception e) { out.add(null); }
            }
        }
        return out;
    }

    private static List<Decimal> castListDecimal(Object o){
        List<Decimal> out = new List<Decimal>();
        if (o instanceof List<Object>) {
            for (Object v : (List<Object>) o) {
                try { out.add((Decimal)v); }
                catch (Exception e) {
                    try { out.add(Decimal.valueOf(String.valueOf(v))); }
                    catch (Exception ee) { out.add(null); }
                }
            }
        }
        return out;
    }

    // =========================
    // ====== DATA HELPERS =====
    // =========================

    private static Id resolveCalendarId(Id serviceTerritoryId){
        ServiceTerritory st = [
            SELECT OperatingHoursId 
            FROM ServiceTerritory 
            WHERE Id = :serviceTerritoryId
            LIMIT 1
        ];
        return st.OperatingHoursId;
    }

    private static Id resolvePolicyIdDynamically(){
        List<String> objs = new List<String>{
            'SchedulingPolicy',
            'FSL__Scheduling_Policy__c',
            'ServiceAppointmentBookingPolicy'
        };
        for (String o : objs){
            try {
                List<SObject> rows = Database.query('SELECT Id FROM ' + o + ' ORDER BY LastModifiedDate DESC LIMIT 1');
                if (!rows.isEmpty()) return (Id)rows[0].get('Id');
            } catch (Exception e) {}
        }
        return null;
    }

    private static Id resolveServiceIdForWorkType(Id wtId, Integer d){
        return wtId;
    }

    private static Map<Id, List<Map<String,Object>>> loadWorkTypeSkillsDynamic(List<WorkType> wts){
        Map<Id, List<Map<String,Object>>> out = new Map<Id, List<Map<String,Object>>>();
        Set<Id> ids = new Set<Id>();
        for (WorkType w : wts) ids.add(w.Id);

        try {
            List<SObject> rows = Database.query(
                'SELECT WorkTypeId, SkillId, SkillLevel FROM WorkTypeSkill WHERE WorkTypeId IN :ids'
            );
            for (SObject rec : rows) {
                Id wtId = (Id)rec.get('WorkTypeId');
                if (!out.containsKey(wtId)) out.put(wtId, new List<Map<String,Object>>());
                out.get(wtId).add(new Map<String,Object>{
                    'skillId' => rec.get('SkillId'),
                    'skillLevel' => rec.get('SkillLevel')
                });
            }
        } catch (Exception e) {}

        for (WorkType w : wts)
            if (!out.containsKey(w.Id)) out.put(w.Id, new List<Map<String,Object>>());

        return out;
    }
}