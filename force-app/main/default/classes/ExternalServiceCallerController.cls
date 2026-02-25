public class ExternalServiceCallerController {

    public String serviceResponse { get; set; }  // Variable to store and display the service response
    
    // This function will be called from the trigger handler
    @future(callout=true)
    public static Void sendDataFromTrigger(Id recordId) {
        try {
            String response = ExternalServiceCaller.sendToExternalService(recordId);
            System.debug('Service Response: ' + response);
        } catch(Exception e) {
            System.debug('Error: ' + e.getMessage());
        }
    }
}