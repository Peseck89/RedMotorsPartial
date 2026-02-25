public class OAuthTokenService {

    // Method to get the OAuth 2.0 token
    public static String getAccessToken() {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
        // Set up the POST request to Salesforce OAuth endpoint
        request.setEndpoint('https://login.salesforce.com/services/oauth2/token');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');

        // Add the form data parameters for OAuth
        String body = 'grant_type=password' +
                      '&client_id=3MVG9LV8n9LkqoRMbTsMxGhkiRq9TUGgKMNfrTpNMRFdepqYsRbqM0KzMyoRs.NNhpLdTfgRAEMBkGotuGYBj' +
                      '&client_secret=22F8D4A6F316DFDF2472631D41F7FB6117355EE8568F861A2D0AC90CCA82174F' +
                      '&username=edna@redmotorscr.com' +
                      '&password=RedMotors2023!';

        request.setBody(body);

        // Send the request
        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200) {
            // Parse and return the access token from the response
            Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            return (String) result.get('access_token');
        } else {
            throw new AuraHandledException('Error: ' + response.getStatusCode() + ' ' + response.getBody());
        }
    }
}