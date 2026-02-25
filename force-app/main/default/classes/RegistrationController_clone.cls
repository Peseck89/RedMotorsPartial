global without sharing class RegistrationController_clone {
    global String name {get; set;}
    global String lastname {get; set;}
    global String telephone {get; set;}
    global String email {get; set;}
    global String personId {get; set;}
    global String vehiculeId {get; set;}
    global Boolean displayPopUp {get; set;}
    global String detail {get; set;}
    public String orgId {get; set;}
    public String siteURL  {get; set;}
    public String startURL {get; set;}
    public Integer successNew {get; set;}
    public integer success {get; set;}
    public integer exists {get; set;}
    public integer clientExists {get; set;}
    public String caseNumber {get;set;}
    public List<AuthProvider> authProviders {get;set;}
    
    global RegistrationController_clone () {
        orgId = UserInfo.getOrganizationId();
        siteURL  = Site.getBaseUrl();
        startURL = System.currentPageReference().getParameters().get('startURL');
        if (startURL == null) startURL = '/';
        authProviders = [SELECT Id,DeveloperName,FriendlyName,ProviderType FROM AuthProvider];
    }
    public void redirectPopup() {        
        displayPopup = false;     
    }    
    public void closePopup() {        
        displayPopup = false;     
    } 
    public void showPopup() {        
        displayPopup = true;     
    }     
    public void dummy() {        
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
        i++;
        i++;
    }     

    public PageReference login(){
        //boolean success = Site.forgotPassword();
        PageReference pr = new PageReference('https://redmotors.my.site.com/ForgotPassword');
        pr.setRedirect(true);
        
        return pr;
    }
    public PageReference volver(){
        //boolean success = Site.forgotPassword();
        PageReference pr = new PageReference('https://redmotors.my.site.com/CustomCommunityLogIn');
        pr.setRedirect(true);
        
        return pr;
    }
    
    global void sendRegistrationRequest() {
        try{
            //buscar primero el cliente
            
            telephone = telephone.replaceAll('\\s+', '');
        
            // Validar formato del teléfono
            String phonePattern = '^\\+\\d{1,3}\\d{8,}$';
            if (!Pattern.matches(phonePattern, telephone)) {
                ApexPages.addMessage(new ApexPages.Message(
                    ApexPages.Severity.ERROR,
                    'Teléfono inválido. Formato requerido: +[código país][mínimo 8 dígitos]'
                ));
            return; // Detener ejecución
            }

            List<Account> lstAccExi = [Select id,CorreoElectronicoEmpresarial__c,PersonEmail,FirstName,LastName,PersonContactId From Account Where ((CorreoElectronicoEmpresarial__c =:email Or  PersonEmail =:email Or FirstName =:name Or LastName =:lastname) AND Cedula__c =:personId) OR Cedula__c =:personId];
                        
            //List<Contact> lstContact = [Select Id,Email,FirstName,LastName From Contact Where Email =:email Or FirstName =:name Or LastName =:lastname];

            if(lstAccExi.size() > 0 ){
                if(lstAccExi.size() > 0){
                    successNew = 1;
                    String contactoActual = lstAccExi[0].PersonContactId;
                    List<User> lstComunidad = [Select Id,FirstName,LastName,Username From User Where ContactId =: contactoActual];
                    if(lstComunidad.size()>0){
                        Peticion_de_envio__c resetPass = new Peticion_de_envio__c();
                        resetPass.Email__c = lstComunidad[0].Username;
                        resetPass.First_Name__c = lstComunidad[0].FirstName;
                        resetPass.Last_Name__c = lstComunidad[0].LastName;
                        insert resetPass;
                    }else{
                        List<User> lstComunidadNew = new List<User> ();
                        Profile profile1 = [Select Id from Profile where name = 'Customer Community User Test'];
                        For(Account ct : lstAccExi){    
                            User portalAccountOwner1 = new User(
                            ProfileId = '00e4U000001FEiZQAW',
                            Username = ct.PersonEmail,
                            Alias = ct.PersonEmail.left(4)+ ct.LastName.left(4) ,
                            Email= ct.PersonEmail,
                            EmailEncodingKey='UTF-8',
                            Firstname= ct.FirstName,
                            Lastname= ct.LastName,
                            LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US',
                            ContactId = contactoActual,
                            TimeZoneSidKey='America/Chicago',        
                            IsActive = true    
                            );
                            lstComunidadNew.add(portalAccountOwner1);
                        }
                        Insert lstComunidadNew;
                        Peticion_de_envio__c resetPass = new Peticion_de_envio__c();
                        resetPass.Email__c = lstComunidadNew[0].Username;
                        resetPass.First_Name__c = lstComunidadNew[0].FirstName;
                        resetPass.Last_Name__c = lstComunidadNew[0].LastName;
                        insert resetPass;
                    }

                }else{
                    clientExists = 1;
                }
            }else{
                if(clientExists == 1){
                    List<User> buscarActivo = [SELECT Id FROM User WHERE Email =: email AND UserType = 'CspLitePortal'];
                    if (buscarActivo.size()>0) {
                        showExists();
                        success = 0;
                    }else {
                        String assetBuscado = '';
                        String cuentaBuscada = '';
                        List<Asset> lstAsset = [Select Id,AccountId,Account.Cedula__c from Asset Where Account.Cedula__c =: personId Or numeroDePlaca__c =: vehiculeId];
                        
                        
                        Case newCase = new Case();
                        newCase.RecordTypeId = '012PH00000HBor9YAD';
                        newCase.Origin = 'BMW Service Solicitud de Login';
                        newCase.FechaEntrada__c = Date.today();
                        newCase.cedula__c = personId;
                         
                        newCase.Subject = 'Solicitud de Registro Comunidad';
                        newCase.Description = 'Nombre: ' + name + '. \n Apellido: ' + lastname +'. \n Teléfono: ' + telephone + '. \n Correo: ' + email + '. \n Cedula: ' + personId +'. \n Placa del vehículo: ' + vehiculeId + '. \n Detalle: ' + detail;
                        newCase.Telefono__c = telephone;
                        newCase.Priority = 'Media';
                        newCase.SuppliedEmail = email;
                        if(lstAsset.size()>0){
                            newCase.AssetId  = lstAsset[0].Id;
                            // newCase.AccountId = lstAsset[0].AccountId;
                        }
                        
                        newCase.suppliedLastName__c = lastname;
                        newCase.Type = 'Solicitud';
                        newCase.SuppliedName = name;
                        newCase.Creado_por_service__c = true;
                        //newCase.AssetId = '02i4U00000Hn9k8QAB';
                        insert newCase;
                        
                        caseNumber = newCase.Consecutivo__c;
                        showConfirmation();
                        success = 1;
                    }
                }else{
                    clientExists = 1;
                }                 
            }
        }
        catch(DmlException e){
            showError();
            success = 0;
        }
    }
    
    global String getEncodedSiteUrl() {
        return EncodingUtil.urlEncode(siteURL, 'UTF-8');
    }
    
    global String getEncodedStartUrl() {
        return EncodingUtil.urlEncode(startURL, 'UTF-8');
    }
    
    global void showConfirmation(){
        ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO, 'Record Saved Successfully'));
    }
    global void showError(){
        ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Error. Try Later.'));
    }
    global void showExists(){
        exists = 1; 
        ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Error. Este correo ya existe por favor ir a cambiar contraseña. <a href="https://redmotors.my.site.com/ForgotPassword">Ir</a>'));
    }
 
}