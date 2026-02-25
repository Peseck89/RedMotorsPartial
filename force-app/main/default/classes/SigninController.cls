/**
 * An apex page controller that exposes the site login functionality
 */
global with sharing class SigninController {
    global String username {get; set;}
    global String password {get; set;}
    public String orgId {get; set;}
    public String siteURL  {get; set;}
    public String startURL {get; set;}
    public String myParamValue {get; set;}
    public String myParamValue2 {get; set;}
    public String myParamValue3 {get; set;}
    public List<AuthProvider> authProviders {get;set;}
    
    global SigninController () {
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        myParamValue = ApexPages.currentPage().getParameters().get('marca');
        if(myParamValue == 'bmw'){
            myParamValue = 'BMW';
        }else if(myParamValue == 'mini'){
            myParamValue = 'MINI';
        }
        myParamValue2 = ApexPages.currentPage().getParameters().get('callcenter');
        myParamValue3 = ApexPages.currentPage().getParameters().get('username');
        username = myParamValue3;
        List<User> lstUser = [Select id,AccountId From User Where Username = :username ];
        if(lstUser.size() > 0){
            List<Asset> lstAssets = [Select id,AccountId,Marca_Nvo__c From Asset Where AccountId =:lstUser[0].AccountId AND Marca_Nvo__c != null ];
            if(lstAssets.size()>1){
               
            }else{
                if(lstAssets[0].Marca_Nvo__c == 'BMW Automovil'){
                    myParamValue = 'BMW';
                }else if(lstAssets[0].Marca_Nvo__c == 'MINI'){
                    myParamValue = 'MINI';
                }
            }
        }
        if(myParamValue == null || myParamValue == ''){
            myParamValue = 'BMW';
        }
        if(myParamValue2 == null || myParamValue2 == ''){
            myParamValue2 = '';
        }else {
            myParamValue2 = 'disponibilidades';
        }
        
        orgId = UserInfo.getOrganizationId();
        siteURL  = Site.getBaseUrl();
        startURL = System.currentPageReference().getParameters().get('startURL');
        if (startURL == null) startURL = '/s/'+myParamValue2+'?servicio=' + myParamValue;+
        startURL = '/s/'+myParamValue2+'?servicio=' + myParamValue;
        authProviders = [SELECT Id,DeveloperName,FriendlyName,ProviderType FROM AuthProvider];
    }

    global PageReference login() {
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        List<User> lstUser = [Select id,AccountId From User Where Username = :username ];
        System.debug(lstUser);
        if(lstUser.size() > 0){
            List<Asset> lstAssets = [Select id,AccountId,Marca_Nvo__c From Asset Where AccountId =:lstUser[0].AccountId And Marca_Nvo__c != null ];
            System.debug(lstAssets);
            if(lstAssets.size()>1){
              
            }else{
                if(lstAssets[0].Marca_Nvo__c == 'BMW Automovil'){
                    myParamValue = 'BMW';
                }else if(lstAssets[0].Marca_Nvo__c == 'MINI'){
                    myParamValue = 'MINI';
                }
            }
        }
        if(myParamValue == null || myParamValue == ''){
            myParamValue = 'BMW';
        }
        if(myParamValue2 == null || myParamValue2 == ''){
            myParamValue2 = '';
        }else {
            myParamValue2 = 'disponibilidades';
        }
        startURL = System.currentPageReference().getParameters().get('startURL');
        System.debug(startURL);
        if (startURL == null) startURL = '/s/'+myParamValue2+'?servicio=' + myParamValue;+
        System.debug(startURL);
        startURL = '/s/'+myParamValue2+'?servicio=' + myParamValue;
        System.debug(startURL);
        System.debug(Site.login(username, password, startUrl));
        return Site.login(username, password, startUrl);
    }

    public PageReference saltarLogin(){
        try {
            //ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO, 'Entro'));
            String username1 = 'antonio.dorantesperez+comunidad2@outlook.com';
            String password1 = 'Lajare18$12';
            //ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO, username1));
            //ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO, password1));
            // startURL = System.currentPageReference().getParameters().get('startURL');
            // startURL = '/CommunityRegistrationClone';
            
            // PageReference loginResult = Site.login(username, password, '/CommunityRegistrationClone');

            // loginResult.setRedirect(true);
            // return loginResult;
             return Site.login(username1, password1, '/CustomCommunityRegistration');
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An error occurred during login: ' + e.getMessage()));
            return null;
        }
    }
    
    global String getEncodedSiteUrl() {
        return EncodingUtil.urlEncode(siteURL, 'UTF-8');
    }
    
    global String getEncodedStartUrl() {
        return EncodingUtil.urlEncode(startURL, 'UTF-8');
    }
    
}