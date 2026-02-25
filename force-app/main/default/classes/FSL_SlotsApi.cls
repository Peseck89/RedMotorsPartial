@RestResource(urlMapping='/fsl/v1/slots')
global with sharing class FSL_SlotsApi {

    // =======================
    // Request / Response DTOs
    // =======================
    global class SlotsRequest {
        public Id serviceAppointmentId;   // required
        public Id schedulingPolicyId;     // required
        public Id operatingHoursId;       // optional (booking)
        public Boolean exactAppointments; // optional (booking)
        public String mode;               // 'candidates' | 'booking' (default: 'booking')
        public String sortBy;             // 'grade' | 'starttime' (default: 'starttime')
    }
    global class SlotDTO {
        public Id resourceId;         // usually null for booking slots
        public String resourceName;   // populated for candidates (if resolvable)
        public Datetime startTime;
        public Datetime endTime;
        public Decimal grade;
    }

    // =======================
    // Comparators for sorting
    // =======================
    global class ByStartTime implements System.Comparator<SlotDTO> {
        public Integer compare(SlotDTO a, SlotDTO b) {
            if (a == null && b == null) return 0;
            if (a == null) return -1;
            if (b == null) return 1;
            if (a.startTime == b.startTime) return 0;
            return a.startTime < b.startTime ? -1 : 1;
        }
    }
    global class ByGradeDesc implements System.Comparator<SlotDTO> {
        public Integer compare(SlotDTO a, SlotDTO b) {
            Decimal ga = (a == null || a.grade == null) ? -1 : a.grade;
            Decimal gb = (b == null || b.grade == null) ? -1 : b.grade;
            if (ga == gb) return 0;
            return ga > gb ? -1 : 1; // higher grade first
        }
    }

    // ==============
    // REST entrypoint
    // ==============
    @HttpPost
    global static List<SlotDTO> getSlots() {
        // Parse request
        String raw = (RestContext.request.requestBody == null)
            ? ''
            : RestContext.request.requestBody.toString();

        SlotsRequest req;
        try {
            req = (SlotsRequest) JSON.deserialize(raw, SlotsRequest.class);
        } catch (Exception e) {
            return error(400, 'Invalid JSON: ' + e.getMessage());
        }
        if (req == null) return error(400, 'Empty request.');
        if (req.serviceAppointmentId == null) return error(400, 'serviceAppointmentId is required.');
        if (req.schedulingPolicyId == null)   return error(400, 'schedulingPolicyId is required.');

        if (String.isBlank(req.mode))   req.mode = 'booking';
        if (String.isBlank(req.sortBy)) req.sortBy = 'starttime';

        try {
            List<SlotDTO> outList = (req.mode == 'candidates')
                ? getCandidateSlots(req)
                : getBookingSlots(req);

            // Decorate with resource names when applicable (candidates)
            Set<Id> resIds = new Set<Id>();
            for (SlotDTO d : outList) if (d != null && d.resourceId != null) resIds.add(d.resourceId);
            if (!resIds.isEmpty()) {
                Map<Id, ServiceResource> resMap = new Map<Id, ServiceResource>(
                    [SELECT Id, Name FROM ServiceResource WHERE Id IN :resIds]
                );
                for (SlotDTO d : outList)
                    if (d != null && d.resourceId != null && resMap.containsKey(d.resourceId))
                        d.resourceName = resMap.get(d.resourceId).Name;
            }

            // Sort
            if (req.sortBy == 'grade') outList.sort(new ByGradeDesc());
            else                       outList.sort(new ByStartTime());

            RestContext.response.statusCode = 200;
            return outList;

        } catch (Exception e) {
            return error(500, 'Failed to compute slots: ' + e.getMessage());
        }
    }

    // ==========================
    // Implementation: Candidates
    // ==========================
    // Returns graded options per resource/time from GradeSlotsService
    private static List<SlotDTO> getCandidateSlots(SlotsRequest req) {
        List<SlotDTO> result = new List<SlotDTO>();

        // Build the grading service for this SA + Policy
        FSL.GradeSlotsService svc = new FSL.GradeSlotsService(req.schedulingPolicyId, req.serviceAppointmentId);

        // true -> convert to user's timezone (keeps output consistent with UI)
        FSL.AdvancedGapMatrix matrix = svc.GetGradedMatrix(true);

        if (matrix != null && matrix.ResourceIDToScheduleData != null) {
            for (Id resId : matrix.ResourceIDToScheduleData.keySet()) {
                FSL.ResourceScheduleData rsd = matrix.ResourceIDToScheduleData.get(resId);
                if (rsd == null || rsd.SchedulingOptions == null) continue;

                for (FSL.SchedulingOption opt : rsd.SchedulingOptions) {
                    if (opt == null || opt.Interval == null) continue;

                    SlotDTO d = new SlotDTO();
                    d.resourceId = resId;
                    d.startTime  = opt.Interval.Start;
                    d.endTime    = opt.Interval.Finish;
                    d.grade      = opt.Grade;
                    result.add(d);
                }
            }
        }
        return result;
    }

    // =========================
    // Implementation: Bookings
    // =========================
    // Returns arrival windows from AppointmentBookingService.getSlots(...)
    private static List<SlotDTO> getBookingSlots(SlotsRequest req) {
        List<SlotDTO> result = new List<SlotDTO>();

        // Resolve TimeZone: OperatingHours.TimeZone (string) -> System.TimeZone
        System.TimeZone tz = null;

        if (req.operatingHoursId != null) {
            OperatingHours oh = [
                SELECT Id, TimeZone
                FROM OperatingHours
                WHERE Id = :req.operatingHoursId
                LIMIT 1
            ];
            if (oh != null && String.isNotBlank(oh.TimeZone)) {
                tz = TimeZone.getTimeZone(oh.TimeZone);
            }
        }

        if (tz == null) {
            // Fallback via SA -> ServiceTerritory -> OperatingHours.TimeZone
            ServiceAppointment sa = [
                SELECT Id,
                       ServiceTerritoryId,
                       ServiceTerritory.OperatingHoursId,
                       ServiceTerritory.OperatingHours.TimeZone
                FROM ServiceAppointment
                WHERE Id = :req.serviceAppointmentId
                LIMIT 1
            ];
            if (sa.ServiceTerritory != null &&
                sa.ServiceTerritory.OperatingHours != null &&
                String.isNotBlank(sa.ServiceTerritory.OperatingHours.TimeZone)) {
                tz = TimeZone.getTimeZone(sa.ServiceTerritory.OperatingHours.TimeZone);
            }
        }

        if (tz == null) {
            // Last resort: user's timezone
            tz = UserInfo.getTimeZone();
        }

        // Call managed-package API (note the required TimeZone parameter)
        List<FSL.AppointmentBookingSlot> slots =
            FSL.AppointmentBookingService.getSlots(
                req.serviceAppointmentId,
                req.schedulingPolicyId,
                req.operatingHoursId,   // can be null if deriving via Territory OH
                tz,
                req.exactAppointments
            );

        for (FSL.AppointmentBookingSlot s : slots) {
            if (s == null || s.interval == null) continue;

            SlotDTO d = new SlotDTO();
            d.startTime = s.interval.Start;
            d.endTime   = s.interval.Finish;
            d.grade     = s.grade;
            // Resource typically not set in booking windows
            result.add(d);
        }
        return result;
    }

    // =================
    // Response helpers
    // =================
    private static List<SlotDTO> error(Integer code, String msg) {
        RestContext.response.statusCode = code;
        RestContext.response.addHeader('X-Error-Message', msg);
        return new List<SlotDTO>();
    }
}