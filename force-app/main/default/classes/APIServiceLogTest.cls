@isTest 
public class APIServiceLogTest {
    
    static testMethod void APIServiceLogTest() {
        Test.startTest();
		APIServiceLog apiLog = new APIServiceLog('requestId', APIServiceLogConstants.SOFTLAND_API_SERVICE_TYPE, APIServiceLogConstants.SOFTLAND_API_SERVICE_RELATED_OBJECT, 'relatedObjectId', APIServiceLogConstants.APILOG_WORKORDER_FIELD_REFERENCE);
        apiLog.setRequest('JOSN Request');
        apiLog.setResponse('JOSN Response');
        APIServiceLog apiLogGet = new APIServiceLog('requestId');
        Test.stopTest();
    }
}