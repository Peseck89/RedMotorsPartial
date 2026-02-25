public class savePDFfile {

    @AuraEnabled
    public static string getRelatedFile(Id recordId, String fromButton){
        String searchKeyword = '%' + fromButton + '%';
        try {
            List <ContentDocumentLink> files = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: recordId];
            List<Id> filesIds = new List<Id>();
            for(ContentDocumentLink docLink : files) filesIds.add(docLink.ContentDocumentId);

            ContentVersion doc = [SELECT ContentDocumentId, Title FROM ContentVersion WHERE ContentDocumentId IN : filesIds AND Title LIKE : searchKeyword LIMIT 1];
            return  doc.ContentDocumentId;
        } catch (Exception e) {throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String attachPDFinCase(Id caseId, String fromButton, String vfNamePage){

        String result = 'Success';
        try{
                
            Case thisCas = [SELECT Id, CaseNumber FROM Case WHERE Id =: caseId LIMIT 1];
            System.debug('Id record in attachPDFinCase constructor: ' + caseId);
            String titleSavedDocum = thisCas.CaseNumber + ' - ' + fromButton;

            PageReference pdfPage = ApexPages.currentPage();
            if(vfNamePage != null) pdfPage = new PageReference('/apex/' + vfNamePage);
            //Primer metodo implementado, toma la pagina por medio del nombre del boton, para futuras implementaciones pasar el nombre de la vf en la variable vfNamePage como en los siguientes metodos
            switch on fromButton {
                when 'Orden de trabajo' {
                    pdfPage = Page.CaseChecklistPDFBeta;
                }
                when 'Orden de trabajo firmada' {
                    System.debug('firmada '+vfNamePage);
                    pdfPage = new PageReference('/apex/' + vfNamePage);
                }
                when 'Orden de trabajo motos'{
                    //pdfPage = Page.ChecklistMotosPDFBeta;
                    pdfPage = new PageReference('/apex/ChecklistMotosPDFBeta');
                }
                when 'Orden de trabajo cuadra'{
                    pdfPage = Page.ChecklistCuadraPDF;
                }
                when 'Orden de trabajo mula'{
                    pdfPage = Page.ChecklistMulaPDF;
                }
                when else {
                    System.debug('Alerta: Error in switch o se paso el nombre de la pagina por medio de vfNamePage.');
                }
            }
            pdfPage.getParameters().put('id',thisCas.Id);
            
            Blob pdfBlob = generatePDFblob(pdfPage, thisCas.Id);
            
            generateOrUpdatePDFfile(pdfBlob, titleSavedDocum, thisCas.Id);
        } 
        catch(Exception e){result = e.getMessage();
        }
        return result;
    }
    
    @AuraEnabled (cacheable=true)
    public static String attachPDFinWO(Id woId, String fromButton, String vfNamePage, Boolean save, Boolean enviarEmail, String recipientEmail){

        String result = 'Success';
        try{
                
            WorkOrder thisWo = [SELECT Id, WorkOrderNumber, ServiceTerritoryId, Case.CaseNumber, Order__r.OrderNumber FROM WorkOrder WHERE Id =: woId LIMIT 1];
            System.debug('Id record in attachPDFinCase constructor: ' + woId);
            String titleSavedDocum = thisWo.WorkOrderNumber + ' - ' + fromButton;
            PageReference pdfPage = new PageReference('/apex/' + vfNamePage);
            System.debug('con nuevo metodo');
            //pdfPage.getParameters().put('id',thisWo.Id);
            
            Blob pdfBlob = generatePDFblob(pdfPage, thisWo.Id);
            
            system.debug('save : ' + save);
            if( save == true)generateOrUpdatePDFfile(pdfBlob, titleSavedDocum, thisWo.Id);

            if( enviarEmail == true ) result = sendEmailPDFAttachmentWo(thisWo, titleSavedDocum, pdfBlob, recipientEmail);
            system.debug('first result ' + result);
        } 
        catch(Exception e){result = e.getMessage();
        }
        system.debug('out result ' + result);
        return result;
    }
    @AuraEnabled (cacheable=true)
	public static String attachPDFinQuote(Id quoteId, String fromButton, String vfNamePage, Boolean save, Boolean enviarEmail, String recipientEmail){

        String result = 'Success';
        try{
                
            Quote thisQoute = [SELECT Id, Name FROM Quote WHERE Id =: quoteId LIMIT 1];
            System.debug('Id record in attachPDFinCase constructor: ' + quoteId);
            String titleSavedDocum = thisQoute.Name + ' - ' + fromButton;
            PageReference pdfPage = new PageReference('/apex/' + vfNamePage);
            System.debug('con nuevo metodo');
            //pdfPage.getParameters().put('id',thisWo.Id);
            
            Blob pdfBlob = generatePDFblob(pdfPage, thisQoute.Id);
            
            system.debug('save : ' + save);
            if( save == true)generateOrUpdatePDFfile(pdfBlob, titleSavedDocum, thisQoute.Id);

            if( enviarEmail == true ) result = sendEmailPDFAttachmentQuote(thisQoute, titleSavedDocum, pdfBlob, recipientEmail);
            system.debug('first result ' + result);
        } 
        catch(Exception e){
            result = e.getMessage();
        }
        system.debug('out result ' + result);
        return result;
    }
    @AuraEnabled
    public static String attachPDFinOpportunity(Id oppId, String fromButton, String vfNamePage, Boolean save, Boolean enviarEmail, String recipientEmail){

        String result = 'Success';
        try {
            Opportunity thisOpp = [SELECT Id, Name FROM Opportunity WHERE Id =: oppId LIMIT 1];
            System.debug('Id record in attachPDFinOpportunity constructor: ' + oppId);
            String titleSavedDocum = thisOpp.Name + ' - ' + fromButton;
            PageReference pdfPage = new PageReference('/apex/' + vfNamePage);
            System.debug('con nuevo metodo');

            Blob pdfBlob = generatePDFblob(pdfPage, thisOpp.Id);

            system.debug('save : ' + save);
            if( save == true)generateOrUpdatePDFfile(pdfBlob, titleSavedDocum, thisOpp.Id);

            //if( enviarEmail == true ) result = sendEmailPDFAttachmentWo(thisOpp, titleSavedDocum, pdfBlob, recipientEmail);
            system.debug('first result ' + result);
        } 
        catch (Exception e) { result = e.getMessage();
        }
        system.debug('out result ' + result);
        return result;
    }

    @AuraEnabled
    public static string getURL(){
        // String hostname = Url.getSalesforceBaseUrl().getHost();
        // String myDomain = hostname.split('\\.')[0];
        // if(myDomain.contains('--')) {
        //     //uses lastIndex to exclude namespace but include sandbox names
        //     // e.g. https://mydomain--sandbox--namespace.visualforce.com
        //     // and https://mydomain--namespace.visualforce.com
        //     myDomain = myDomain.substring(0, hostname.lastIndexOf('--'));
        // }
        // String lcBaseURL = 'https://' + myDomain + '.lightning.force.com';
        // System.debug(lcBaseURL);
        // return lcBaseURL;
        return System.URL.getSalesforceBaseUrl().toExternalForm();
    }
	@AuraEnabled
    public static Boolean getEnvioFormalizacion(Id oppId){

        Boolean envioFormalizacion = [SELECT Id, Envio_formalizacion_legal__c FROM Opportunity WHERE Id =: oppId LIMIT 1].Envio_formalizacion_legal__c;
        
        if(envioFormalizacion == true ) return true;
        return false;
    }
    @AuraEnabled
    public static Boolean getVehiculoReservado(Id oppId){

        Boolean vehiculoReservado = [SELECT Id, Tiene_Vehiculos_Reservados__c FROM Opportunity WHERE Id =: oppId LIMIT 1].Tiene_Vehiculos_Reservados__c;
        
        if(vehiculoReservado == true ) return true;
        return false;
    }
    @AuraEnabled
    public static Boolean getHasContact(Id oppId){
        Boolean hasContact = false;
        Opportunity opp1 = [Select Id,contacto__c From Opportunity Where Id =: oppId];
        if(opp1.contacto__c != null){
             hasContact = true;
        }
        return hasContact;
    }
    @AuraEnabled
    public static Boolean getDescuentoAprobado(Id oppId){

        Boolean descuentoAprobado = [SELECT Id, DescuentoAprobado__c FROM Opportunity WHERE Id =: oppId LIMIT 1].DescuentoAprobado__c;
        String aprobador = [SELECT Id, Aprobador__c FROM Opportunity WHERE Id =: oppId].Aprobador__c;
        if(descuentoAprobado == true || aprobador == null || aprobador == 'vendedor') return true; return false;
    }

    public static Blob generatePDFblob(PageReference pdfPage, String recordId){

        // generate and attach the PDF document
        //pdfPage.getParameters().put('id',recordId);
        Blob pdfBlob; //create a blob for the PDF content
        try {
            if (!Test.isRunningTest()) { pdfBlob = pdfPage.getContent(); //generate the pdf blob
            } else { 
                //otherwise, we are in testing context and getContent() gets funky so create the blob manually
                pdfBlob = Blob.valueOf('Some Text for a boring PDF file...');
            }
        } catch (VisualforceException e) { pdfBlob = Blob.valueOf('Error');
            System.debug('Error en getContent');
        }
        System.debug('Valor de blob: ' + pdfBlob.size());
        return pdfBlob;
    }

    public static void generateOrUpdatePDFfile(Blob pdfBlob, String titleSavedDocum, String recordId){

        if(pdfBlob.size() < 100 && !Test.isRunningTest()) System.debug('Error en pdfBlob.size()');
        else{

            //there`s not an existing document, and we create a new document
            ContentVersion existCVersion = new ContentVersion();
            String searchTitleDoc = '%' + titleSavedDocum + '%';
            System.debug('searchTitleDoc:' + searchTitleDoc);
            try{
                existCVersion = [SELECT Title, ContentSize, VersionData, ContentDocumentId FROM ContentVersion WHERE Title LIKE : searchTitleDoc AND IsLatest=true LIMIT 1];
            }
            catch(Exception err){
                existCVersion = null;
            }
            System.debug('existCVersion: ' + existCVersion);

            if(existCVersion != null){

                //implementar logica para actualizar
                System.debug('Entro a actualizar documento !!!!!!');
                ContentDocument cdToDelete = [SELECT Id FROM ContentDocument WHERE Id =: existCVersion.ContentDocumentId LIMIT 1]; delete cdToDelete;
                System.debug('Se borro el documento PDf !!!!!');
            }
            
            //Se genera el documento pdf
            ContentVersion cVersion = new ContentVersion();
            cVersion.ContentLocation = 'S';
            cVersion.Title = titleSavedDocum;
            cVersion.PathOnClient = cVersion.Title + '.pdf';
            cVersion.VersionData = pdfBlob;
            system.debug('pdfBlob en cversion: ' + pdfBlob );
            insert cVersion;
            system.debug('Se inserto cVersion: ' + cVersion);

            ContentVersion cVersion2 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: cVersion.Id LIMIT 1];
            System.debug('Cversion2: ' + cVersion2);
            Id conDocument = cVersion2.ContentDocumentId;
            ContentDocumentLink cDocLink = new ContentDocumentLink();
            cDocLink.ContentDocumentId = conDocument;
            cDocLink.LinkedEntityId = recordId;
            cDocLink.Visibility = 'AllUsers';
            cDocLink.ShareType = 'V';

            insert cDocLink;
            System.debug('Se genero un documento nuevo !!!!!');
            
        }
    }

    public static String getRecipientEmail(Id serviceTerritoryId){

        String emailUruca = 'despachouruca@redmotorscr.com';
        String emailEscazu = 'despachoescazu@redmotorscr.com';
        String emailPinares = 'despachopinares@redmotorscr.com';
        String emailPavas = 'despachopavas@redmotorscr.com';
        String emailOtobai = 'despachootobai@redmotorscr.com';

        ServiceTerritory st = new ServiceTerritory();
        String stName = '';
        try{
            st = [SELECT Id, Name FROM ServiceTerritory WHERE Id =: serviceTerritoryId ];
            stName = st.Name;
        }catch(Exception e){ st=null;stName = 'No territorio relacionado';
        }
        
        if(stName.contains('Uruca')) return emailUruca;if(stName.contains('Escaz')) return emailEscazu; if(stName.contains('Pinares')) return emailPinares;if(stName.contains('Pavas')) return emailPavas; if(stName.contains('Motorrad')) return emailPavas; if(stName.contains('Otobai')) return emailOtobai;return null;
    }

    public static String sendEmailPDFAttachmentWo(WorkOrder thisWo, String titleSavedDocum, Blob pdfBlob, String recipientEmail){

        //Order (Pedido) related to Work Order (Orden de trabajo).
        Respuesta_pedido__c resPedido = new Respuesta_pedido__c();
        String numPedido = '';
        try{
            resPedido = [SELECT Name, Work_Order__c FROM Respuesta_pedido__c WHERE  Work_Order__c =: thisWo.Id LIMIT 1];
            numPedido = resPedido.Name;
        }catch(Exception err){
            resPedido = null;
            numPedido = 'No tiene un pedido relacionado';
        }
        //Send Email part.
        Messaging.SingleEmailMessage sEmail = new Messaging.SingleEmailMessage();
        Messaging.EmailFileAttachment att = new Messaging.EmailFileAttachment();
        
        if(recipientEmail == null) recipientEmail = getRecipientEmail(thisWo.ServiceTerritoryId);
        system.debug('No Service Terrytor ' + thisWo.ServiceTerritoryId);
        String  urlRecord = System.URL.getSalesforceBaseUrl().toExternalForm();
                urlRecord += '/lightning/r/WorkOrder/' + thisWo.Id + '/view';
        System.debug('url: ' + urlRecord);
        String  messageBody = 'Alerta de despacho de repuestos.\n\n';
                messageBody += 'Se ha creado una alerta para despacho de repuestos para la Orden de trabajo: ' + thisWo.WorkOrderNumber;
                messageBody += ', Caso: ' + thisWo.Case.CaseNumber + ' y el Pedido: ' + numPedido + '.\n';
                messageBody += 'Puede ver el registro en el siguiente link: ' + urlRecord;
        sEmail.setSubject('Alerta despacho de repuestos.');
        sEmail.setPlainTextBody(messageBody);
        sEmail.setToAddresses(new String [] {recipientEmail, 'jpramirez@redmotorscr.com', 'admin@portalnetcr.com'});
        sEmail.setFileAttachments(new Messaging.EmailFileAttachment[] {att});

        att.setContentType('application/pdf');
        att.setFileName(titleSavedDocum);
        att.setBody(pdfBlob);

        if (recipientEmail != null){
            Messaging.SendEmailResult [] emailRes = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {sEmail});
            if(emailRes[0].success){
                System.debug('Email Sent!');
                return 'Email Success';
            } 
            else{return 'Email Error';
            }
        }
        system.debug('Email Error');
        return 'Email Error';
        
    }
    public static String sendEmailPDFAttachmentQuote(Quote thisQuote, String titleSavedDocum, Blob pdfBlob, String recipientEmail){

        
        //Send Email part.
        Messaging.SingleEmailMessage sEmail = new Messaging.SingleEmailMessage();
        Messaging.EmailFileAttachment att = new Messaging.EmailFileAttachment();
        
        if(recipientEmail == null) recipientEmail = 'admin@portalnetcr.com';
        String  urlRecord = System.URL.getSalesforceBaseUrl().toExternalForm();
                urlRecord += '/lightning/r/Quote/' + thisQuote.Id + '/view';
        System.debug('url: ' + urlRecord);
        String  messageBody = 'Alerta de despacho de repuestos.\n\n';
                messageBody += 'Se ha creado una alerta para despacho de repuestos para el Quote: ' + thisQuote.Name;
                //messageBody += ', Caso: ' + thisWo.Case.CaseNumber + ' y el Pedido: ' + numPedido + '.\n';
                messageBody += 'Puede ver el registro en el siguiente link: ' + urlRecord;
        sEmail.setSubject('Alerta despacho de repuestos.');
        sEmail.setPlainTextBody(messageBody);
        sEmail.setToAddresses(new String [] {recipientEmail, 'jpramirez@redmotorscr.com'});
        sEmail.setFileAttachments(new Messaging.EmailFileAttachment[] {att});

        att.setContentType('application/pdf');
        att.setFileName(titleSavedDocum);
        att.setBody(pdfBlob);

        if (recipientEmail != null){
            Messaging.SendEmailResult [] emailRes = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {sEmail});
            if(emailRes[0].success){
                System.debug('Email Sent!');
                return 'Email Success';
            } 
            else{return 'Email Error';
            }
        }
        system.debug('Email Error');
        return 'Email Error';
        
    }
}