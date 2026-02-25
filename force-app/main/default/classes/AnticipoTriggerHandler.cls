/**
 * @description       : Clase trigger handler del objeto Anticipo
 * @author            : marcohernandezhp@gmail.com
 * @group             : Remotors
 * @last modified on  : 05-18-2023
 * @last modified by  : marcohernandezhp@gmail.com
**/
public class AnticipoTriggerHandler extends TriggerHandler {

	public List<Anticipo__c> newRecordList;
    public Map<Id, Anticipo__c> newRecordMap;
    public List<Anticipo__c> oldRecordList;
    public Map<Id, Anticipo__c> oldRecordMap;

    public AnticipoTriggerHandler() {
        this.newRecordList = (List<Anticipo__c>) Trigger.New;
        this.newRecordMap = (Map<Id, Anticipo__c>) Trigger.newMap;
        this.oldRecordList = (List<Anticipo__c>) Trigger.Old;
        this.oldRecordMap = (Map<Id, Anticipo__c>) Trigger.oldMap;        
    }  
    
	// public override void afterUpdate(){
        // Set<Id> anticipoIds = new Set<Id>();
        // for (Anticipo__c newRecord : newRecordList) {
        //     if (newRecord.Estatus__c != oldRecordMap.get(newRecord.Id).Estatus__c && newRecord.Estatus__c == 'Cancelado') {
        //         anticipoIds.add(newRecord.Id);
        //     }
        // }

        // if (anticipoIds.size()>0) {
        //     cancelAnticipo(anticipoIds);
        // }
	// }   
    
	public override void afterInsert(){
	}     
  
    // @Future(callout=true)
    // public static void cancelAnticipo(Set<Id> anticipoIds) {
    //     List<Anticipo__c> anticipoList = [SELECT Id,Identificador__c,Monto__c FROM Anticipo__c WHERE Id IN:anticipoIds];
    //     for (Anticipo__c anticipo : anticipoList) {
    //         cancelAnticipoSoftland(anticipo);
    //     }
    // }

    // public static void cancelAnticipoSoftland(Anticipo__c anticipo){
    //     Http http = new Http();        
    //     HttpRequest request = new HttpRequest();

    //     AuthResponse authResponse = getAuth();

    //     request.setEndpoint( Label.URLSoftland + '/IntegrationServices/softlandAPI/catalogs/unreserveVehicule?json='+EncodingUtil.urlEncode('{"compania":"'+ 'RMBAVARIAN' +'", "codArticulo": "000000000000018", "oportunidad": "op-0000001"}','UTF-8'));
    //     request.setHeader('Authorization', 'Bearer '+authResponse.access_token);            
    //     request.setMethod('GET');   
    //     HttpResponse response = http.send(request);
    //     String jsonString = response.getBody();
    // }

    // public class AuthResponse
    // {
    //     public String access_token;
    //     public String token_type;
    // }

    // public static AuthResponse getAuth(){
    //     Http http = new Http();        
    //     HttpRequest request = new HttpRequest();
    //     request.setEndpoint(Label.URLSoftland+'/'+Label.ambienteSoftland+'/oauth/token');
    //     request.setBody('clientId='+Label.ClientIdSoftland+'&clientSecret='+Label.clientSecretSoftland+'&grant_type=password');
    //     request.setHeader('Content-Type', 'application/text');
    //     request.setMethod('GET');
    //     request.setTimeout(20000);
        
    //     HttpResponse response = http.send(request);
    //     return (AuthResponse) System.JSON.deserialize(response.getBody(), AuthResponse.class);
    // }
}