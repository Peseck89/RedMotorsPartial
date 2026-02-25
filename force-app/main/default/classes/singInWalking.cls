/**
 * An apex page controller that exposes the site login functionality
 */
global with sharing class  singInWalking {
    public String siteURL  {get; set;}
    public String startURL {get; set;}
    public String decodedStartURL {get; set;}
    
    global singInWalking() {
		Integer i=0;
        i = i +1;
        i = i +1;        
        i = i +1;        
        i = i +1;        
        i = i +1;        
        i = i +1;        
        i = i +1;        
        i = i +1;        
        i = i +1;        
        i = i +1;     
        siteURL  = Site.getBaseUrl();
        startURL = System.currentPageReference().getParameters().get('sucursal');
        if (startURL == null) startURL = '/';
        
    }
    public PageReference saltarLogin(){
        try {
            //ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO, 'Entro'));
            // String username1 = 'antonio.dorantesperez+comunidad2@outlook.com';
            // String password1 = 'Lajare18$11';

            // String username1 = 'antonio.dorantesperez+1@outlook.com';
            // String password1 = 'Yandrax14';


            String username1 = 'autologin@redmotorscr.com';
            String password1 = 'RMCR2024$$AL';
            
            //ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO, username1));
            //ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO, password1));
            // startURL = System.currentPageReference().getParameters().get('startURL');
            // startURL = '/CommunityRegistrationClone';
            
            // PageReference loginResult = Site.login(username, password, '/CommunityRegistrationClone');

            // loginResult.setRedirect(true);
            // return loginResult;
        
            return Site.login(username1, password1, '/walking/s/showroom?sucursal=' + startURL);
            // return Site.login(username1, password1, '/walking/s/showroom?sucursal='+startURL);
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An error occurred during login: ' + e.getMessage()));
            return null;
        }
    }

    public PageReference saltarLoginMini(){
        try {
            //ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO, 'Entro'));
            String username1 = 'autologin@redmotorscr.com';
            String password1 = 'RMCR2024$$AL';

            // String username1 = 'antonio.dorantesperez+1@outlook.com';
            // String password1 = 'Yandrax14';


            // String username1 = 'admin@portalnetcr.com.portalcom';
            // String password1 = 'Portal2023';
            
            //ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO, username1));
            //ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO, password1));
            // startURL = System.currentPageReference().getParameters().get('startURL');
            // startURL = '/CommunityRegistrationClone';
            
            // PageReference loginResult = Site.login(username, password, '/CommunityRegistrationClone');

            // loginResult.setRedirect(true);
            // return loginResult;
        
            return Site.login(username1, password1, '/walkingmini/s/minishowroom?sucursal=' + startURL);
            // return Site.login(username1, password1, '/walkingmini/s/minishowroom?sucursal='+startURL);
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An error occurred during login: ' + e.getMessage()));
            return null;
        }
    }

    public String marca { 
        get {
            if(marca == null) {
                marca = ApexPages.currentPage().getParameters().get('marca');
            }
            return marca;
        }
        set;
    }

    public PageReference saltarLoginMoto(){
        try {
            //ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO, 'Entro'));
            String username1 = 'autologin@redmotorscr.com';
            String password1 = 'RMCR2024$$AL';

            // String username1 = 'antonio.dorantesperez+1@outlook.com';
            // String password1 = 'Yandrax14';

            // String username1 = 'admin@portalnetcr.com.portalcom';
            // String password1 = 'Portal20242';
            
            //ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO, username1));
            //ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO, password1));
            // startURL = System.currentPageReference().getParameters().get('startURL');
            // startURL = '/CommunityRegistrationClone';
            
            // PageReference loginResult = Site.login(username, password, '/CommunityRegistrationClone');

            // loginResult.setRedirect(true);
            // return loginResult;
        
            return Site.login(username1, password1, '/walkingmoto/s/showroommotorrad?sucursal=Uruca&marca='+marca);
            // return Site.login(username1, password1, '/walkingmoto/s/showroommotorrad?sucursal='+startURL);
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An error occurred during login: ' + e.getMessage()));
            return null;
        }
    }
}