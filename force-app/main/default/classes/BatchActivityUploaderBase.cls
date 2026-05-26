public class BatchActivityUploaderBase {
    public class RecordTypeIds {
        public String idBMW;
        public String idMini;
        public String idMotorrad;

        public RecordTypeIds(String idBMW, String idMini, String idMotorrad) {
            this.idBMW = idBMW;
            this.idMini = idMini;
            this.idMotorrad = idMotorrad;
        }
    }

    public static RecordTypeIds getRecordTypeIds(Schema.DescribeSObjectResult sObjectDescribe) {
        Map<String, Schema.RecordTypeInfo> recordTypesByName = sObjectDescribe.getRecordTypeInfosByName();
        return new RecordTypeIds(
            recordTypesByName.get('BMW').getRecordTypeId(),
            recordTypesByName.get('MINI').getRecordTypeId(),
            recordTypesByName.get('Motorrad').getRecordTypeId()
        );
    }

    public static String convertDate(Date dt) {
        if (dt != null) {
            return dt.day() + '/' + dt.month() + '/' + dt.year();
        }

        return '';
    }

    public static Set<String> getSubjects(String objectName, String fieldName) {
        Set<String> values = new Set<String>();

        Schema.SObjectType s = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult r = s.getDescribe();
        Map<String, Schema.SObjectField> fields = r.fields.getMap();
        Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry pickListVal : ple) {
            values.add(pickListVal.getValue());
        }

        return values;
    }

    public static void sendDataflowSignal(String flowStatus, String payloadTag, String endpoint, String debugPrefix) {
        Map<String, Object> data = new Map<String, Object>();
        data.put('sfdataflow', flowStatus);
        if (payloadTag != null) {
            data.put('payloadTag', payloadTag);
        }

        String body = Json.serializePretty(data);
        System.debug(debugPrefix + ' :: ' + body);
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('content-type', 'application/json');
        req.setEndpoint(endpoint);
        req.setBody(body);

        if (!Test.isRunningTest()) {
            HttpResponse response = new Http().send(req);
            response.getBody();
            System.debug('Body ' + response.getBody());
        }
    }
}
