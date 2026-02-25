@IsTest
public class HL_FieldDescribeUtil_Test {
    @isTest
    public static void runTest() {
        Schema.SObjectField theField = Lead.Modelo_De_Inter_s1_New__c;
        Schema.SObjectField ctrlField = Lead.Familia1__c;
        Map<String, List<String>> values = HL_FieldDescribeUtil.getDependentOptionsImpl(theField, ctrlField);
    }
}