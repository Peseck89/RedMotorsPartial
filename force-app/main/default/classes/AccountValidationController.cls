public class AccountValidationController {
	@AuraEnabled()
    public static void actualizaCaso(string caseId, string contactId){
        Case caso = [Select Id, ContactId From Case Where Id =:caseId LIMIT 1];  caso.ContactId = contactId; update caso;
    }
    @AuraEnabled()
    public static void actualizaAsset(string assetId, string modelo){
        Asset ast = [Select Id, Modelo_Nvo2__c From Asset Where Id =:assetId LIMIT 1];  ast.Modelo_Nvo2__c = modelo; update ast;
    }
    @AuraEnabled()
    public static Boolean updateOnlyId(String cedula, String tipoDocumento, String cuenta){
        Account acc= new Account();
        acc.Id= cuenta;
        acc.Tipo_de_Documento__c= tipoDocumento;
        acc.Cedula__c= cedula;
        update acc;  
        return true;
    }
	@AuraEnabled(cacheable=false)
    public static String getContact (Id caseId) { 
        System.debug('CaseId '+caseId);
         Case caseValidation =[SELECT Account.PersonEmail,Account.Phone,AccountId,Account.RecordTypeId,Account.CorreoElectronicoEmpresarial__c
                                     ,Account.Invoice_Email__c,Account.Invoice_Phone__c,Account.SoftlandValidation__c,Account.codigoSoftland__c,
                              		 ContactId,Contact.Email,Contact.Phone,Contact.FirstName,Contact.LastName
                              FROM Case WHERE Id=:caseId LIMIT 1];
        return caseValidation.ContactId;
    }
	@AuraEnabled(cacheable=false)
    public static String accountValidation (Id caseId) { 
        Case caseValidation =[SELECT AssetId,Account.PersonEmail,Account.Phone,AccountId,Account.RecordTypeId,Account.CorreoElectronicoEmpresarial__c
                                     ,Account.Invoice_Email__c,Account.Invoice_Phone__c,Account.SoftlandValidation__c,Account.codigoSoftland__c,
                              		 ContactId,Contact.Email,Contact.Phone,Contact.FirstName,Contact.LastName
                              FROM Case WHERE Id=:caseId LIMIT 1];
        
        String recordType=getRecordTypeNameById('Account',caseValidation.Account.RecordTypeId);
        Boolean clienteFisico= (recordType.contains('Físico')||recordType.contains('Altica')||recordType.contains('personal'));
        Boolean validarSoftland= (!caseValidation.Account.SoftlandValidation__c && caseValidation.Account.codigoSoftland__c!=null);
        Boolean accountError=(!clienteFisico && caseValidation.ContactId==null); 
        String AccountMessageError = accountError? 'La cuenta es empresarial y el caso NO posee contacto.':'';
        if(caseValidation.AssetId != null){
            Asset assetRelated = [Select Id,Marca_Nvo__c, Modelo_Nvo2__c  From Asset Where Id=: caseValidation.AssetId];
            System.debug('la marca es: '+ assetRelated.Marca_Nvo__c + ' y el modelo es : '+assetRelated.Modelo_Nvo2__c);
            if(assetRelated.Marca_Nvo__c != 'Otro' && assetRelated.Modelo_Nvo2__c == 'Otro'){
                System.debug('la marca es: '+ assetRelated.Marca_Nvo__c + ' y el modelo es : '+assetRelated.Modelo_Nvo2__c);
                accountError = true; 
                AccountMessageError = 'Es marca ' +assetRelated.Marca_Nvo__c+ ' y tiene en el campo modelo la opción: otro, por favor especifique su modelo.';
            }
        } 
        
        
        if(!clienteFisico && !accountError){
            accountError= (caseValidation.Contact.Email==null || caseValidation.Contact.Phone==null || caseValidation.Contact.FirstName==null || caseValidation.Contact.LastName==null );
            AccountMessageError='Falta información en el CONTACTO, revise los campos necesarios: Correo, Teléfono ,Primer Nombre y Apellido.';
        }
        if(caseValidation.Account.PersonEmail == 'n/a@redmotorscr.com' || caseValidation.Account.PersonEmail == 'contabilidabmw@redmotorscr.com'){
            accountError = true; AccountMessageError = 'Esta cuenta personal tiene un correo “comodín”. Por favor actualizar el correo con uno proporcionado por el cliente.';
        }
        if(caseValidation.Account.CorreoElectronicoEmpresarial__c == 'n/a@redmotorscr.com' || caseValidation.Account.CorreoElectronicoEmpresarial__c == 'contabilidabmw@redmotorscr.com'){
            accountError = true; AccountMessageError = 'Esta cuenta empresarial tiene un correo “comodín”. Por favor actualizar el correo con uno proporcionado por el cliente.';
        }
        Boolean validate= validarSoftland||(caseValidation.Account.Phone==null)||accountError   ||(caseValidation.Account.PersonEmail==null && clienteFisico)  ||(caseValidation.Account.CorreoElectronicoEmpresarial__c==null && (!clienteFisico))  ||(caseValidation.Account.Invoice_Email__c==null||caseValidation.Account.Invoice_Phone__c==null);
        return '{"Id":"'+caseValidation.AccountId+'",'+'"CaseId":"'+caseValidation.Id+'",'+'"isPhysical":'+clienteFisico+','+'"validate":'+validate+','+'"softlandValidated":'+!validarSoftland+','+'"AccountError":'+accountError+','+'"AccountMessageError":'+'"'+AccountMessageError+'"'+'}';
    }

    @AuraEnabled(cacheable=false)
    public static String accountValidationByOpportunity (Id oppId) { 
        System.debug('oppId: ' + oppId);
        Opportunity opportunityValidation =[SELECT  Account.PersonEmail,
                                                    Account.Phone,
                                                    AccountId,
                                                    Account.RecordTypeId,
                                                    Account.CorreoElectronicoEmpresarial__c,
                                                    Account.Invoice_Email__c,
                                                    Account.Invoice_Phone__c,
                                                    Account.SoftlandValidation__c,
                                                    Account.codigoSoftland__c,
                                                    contacto__r.Id,
                                                    contacto__r.Email,
                                                    contacto__r.Phone,
                                                    contacto__r.FirstName,
                                                    contacto__r.LastName
                                            FROM Opportunity WHERE Id =: oppId LIMIT 1];
        
        String recordType=getRecordTypeNameById('Account',opportunityValidation.Account.RecordTypeId);
        Boolean clienteFisico= (recordType.contains('Físico')||recordType.contains('Altica')||recordType.contains('personal'));
        Boolean validarSoftland= (!opportunityValidation.Account.SoftlandValidation__c && opportunityValidation.Account.codigoSoftland__c!=null);
        
        Boolean accountError=(!clienteFisico && opportunityValidation.contacto__r.Id==null);
        String AccountMessageError = accountError? 'La cuenta es empresarial y el caso NO posee contacto.':'';
        if(!clienteFisico && !accountError){ accountError= (opportunityValidation.contacto__r.Email==null || opportunityValidation.contacto__r.Phone==null || opportunityValidation.contacto__r.FirstName==null || opportunityValidation.contacto__r.LastName==null ); AccountMessageError='Falta información en el CONTACTO, revise los campos necesarios: Correo, Teléfono ,Primer Nombre y Apellido.';
        }
        Boolean validate= validarSoftland||(opportunityValidation.Account.Phone==null)||accountError   ||(opportunityValidation.Account.PersonEmail==null && clienteFisico) ||(opportunityValidation.Account.CorreoElectronicoEmpresarial__c==null && (!clienteFisico)) ||(opportunityValidation.Account.Invoice_Email__c==null||opportunityValidation.Account.Invoice_Phone__c==null);
        return '{"Id":"'+opportunityValidation.AccountId+'",'+'"OppId":"'+opportunityValidation.Id+'",'+'"isPhysical":'+clienteFisico+','+'"validate":'+validate+','+'"softlandValidated":'+!validarSoftland+','+'"AccountError":'+accountError+','+'"AccountMessageError":'+'"'+AccountMessageError+'"'+'}';
    }
    
    public static String getRecordTypeNameById(String objectName, Id strRecordTypeId)
    {
        return Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosById().get(strRecordTypeId).getName();
    }

    @AuraEnabled(cacheable=false)
    public static softlandWrapperResponse getSoftlandAccount(String AcountId){
        system.debug('AcountId: ' + AcountId);
        Account softlandCode= [select codigoSoftland__c from Account where id=:AcountId limit 1];
        if(softlandCode!=null){
            List<Object> results;
            softlandWrapperResponse account;
            HttpCalloutGetClient getAccount = new HttpCalloutGetClient();
            if(Test.isRunningTest()){
           	 	results=(List<Object>) JSON.deserializeUntyped('[ { "cliente": "C116571", "nombre": "DESARROLLOS E INVERSIONES M Y C", "alias": "DESARROLLOS E INVERSIONES M Y C", "contacto": " ", "activo": "S", "cargo": " ", "id": "3101171751", "moneda": "CRC", "condicionPago": "0", "categoriaCliente": "COM", "pais": "CRI", "provincia": "4", "canton": "07", "distrito": "01", "barrio": "01", "otras_senas": null, "telefono1": "fewsfeaef", "telefono2": "88978376", "email": "mar09f@gmail.hom", "email_doc_electronico": "mar09f@gmail.hom", "email_doc_electronico_copia": "mar09f@gmail.hom", "contribuyente": [], "categoria": [], "impuesto": [] } ]');
            }else{
                if(getAccount.getSoftlandAccount(softlandCode.codigoSoftland__c).getBody().contains('Client not found')){ softlandCode.codigoSoftland__c = '';update softlandCode;
                }
                else{
                	results=(List<Object>) JSON.deserializeUntyped(getAccount.getSoftlandAccount(softlandCode.codigoSoftland__c).getBody());   
                	
                    account=(softlandWrapperResponse)JSON.deserialize(JSON.serialize(results[0]),softlandWrapperResponse.class); account.ID=AcountId; account.cliente=softlandCode.codigoSoftland__c;
                }
            }
            system.debug('Respuesta');
            system.debug(results);
            //account.telefono2=account.telefono1;
            //account.updateAccount();
            system.debug('Objeto');
            system.debug(account);
            return account;
        }else{
            return null;
        }
    }
    
    public class softlandWrapperResponse{
        @AuraEnabled public String cliente;
       	@AuraEnabled public String email;
        @AuraEnabled public String telefono1;
        @AuraEnabled public String telefono2;
        @AuraEnabled public String email_doc_electronico;
        @AuraEnabled public String ID;
        @AuraEnabled public List<Contribuyente> contribuyente;
        
    }

    public class Contribuyente {
        @AuraEnabled  public String id ;
        @AuraEnabled  public String tipo ;
        @AuraEnabled  public String razonSocial ;
        @AuraEnabled  public String alias ;
    }

    @AuraEnabled(cacheable=false)
    public static object updateSoftlandAccount(String accountWrapper){
        softlandWrapperResponse JSONAcount=(softlandWrapperResponse)JSON.deserialize(accountWrapper,softlandWrapperResponse.class);
        String response;
        HttpCalloutGetClient updateClient = new HttpCalloutGetClient();
        if(Test.isRunningTest()){
           	 response=('{"operationResult":{"code":"00","description":"Cliente actualizado exitosamente"}}');
        }else{
         	 response=updateClient.updateSoftlandClient(accountWrapper).getBody();   
        }
        System.debug('Respuesta de actualización cliente: '+response.trim().contains('"code":"00"'));
        System.debug(response.trim());
        if(response.trim().contains('"code":"00"')){
        	Account acc= new Account();
            acc.Id=JSONAcount.ID;
            acc.Softland_Email__c=JSONAcount.email;
            acc.Softland_Phone__c=JSONAcount.telefono1;
            acc.Softland_FE_Email__c=JSONAcount.email_doc_electronico;
        	acc.SoftlandValidation__c=true;
        	update acc;  
        }
        return response;
    }
    
}