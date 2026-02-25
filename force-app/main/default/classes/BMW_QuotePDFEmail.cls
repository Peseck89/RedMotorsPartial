public with sharing class BMW_QuotePDFEmail {
    public String subject { get; set; }
    public String body { get; set; }
    public String destinatario { get; set; }
    public Boolean enviado { get; set; }
    public Boolean comienzo { get; set; }

    private final Quote cot;

	public BMW_QuotePDFEmail() {
        comienzo = true;
        enviado = false;
        cot = [select Account.Cedula__c,Account.Phone,Account.PersonMobilePhone,BMW_CodigoDeProducto__c,
        Opportunity.BMW_PlacaDeVehiculoOElVIN__c,
        Opportunity.BMW_PlacaDeVehiculoOElVIN__r.Kilometros__c,
        Opportunity.BMW_PlacaDeVehiculoOElVIN__r.Anio__c,
        Opportunity.BMW_PlacaDeVehiculoOElVIN__r.numeroDePlaca__c,
        Opportunity.BMW_PlacaDeVehiculoOElVIN__r.NumeroDeChasis__c,
        Opportunity.WorkOrder__c,OpportunityId,
        Account.Name,Account.Pais__c,Account.Provincia__pr.Name,
        Account.Canton__r.Name,Account.Distrito__r.Name,Account.Barrio__c,Account.Calle__c,
        Account.Direccion_Residencial__c,Account.Direccion__c,Account.Type,
        id,Email,Description,Discount,ShippingAddress,CurrencyIsoCode,
        AdditionalAddress,ShippingHandling,Status,BillingAddress,Fax,
        ExpirationDate,Tax,AdditionalName,ShippingName,
        BillingName,QuoteToName,Name,QuoteNumber,TotalPrice,QuoteToAddress,
        Subtotal,Phone,GrandTotal,CreatedDate,OwnerId, Orden_De_Trabajo__c,
        
        (select id,Quantity,Description,Discount,UnitPrice,TotalPrice,BMW_Producto_Custom__c,
        BMW_TipoDeArticulo__c, Product2.Name,Product2.Codigo_de_Producto__c,BMW_Dispinible__c
                                                                from QuoteLineItems 
                                                                ) 
               from Quote
               where id =: ApexPages.currentPage().getParameters().get('id')
               LIMIT 1];
    }

    public Quote getQuote() {
        return cot;
    }
    
    public PageReference send() {
        // Define the email
        if(destinatario != ''){
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 

        // Reference the attachment page and pass in the quote ID
        PageReference pdf =  Page.BMW_QuotePDFv2;
        pdf.getParameters().put('id',(String)cot.id); 
        pdf.setRedirect(true);

        // Take the PDF content
        Blob b;
        if(Test.isRunningTest()) { 
            b = blob.valueOf('Unit.Test');
        } else {
            b = pdf.getContent();
        }

        // Create the email attachment
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        efa.setFileName('Presupuesto.pdf');
        efa.setBody(b);
        
          

        String addresses;
        addresses = destinatario;
        Opportunity opp = [Select Id, Account.personemail From Opportunity Where Id =: cot.OpportunityId];
        if (opp.Account.personemail != null) {
            addresses+= ':'+opp.Account.personemail;
            String userName = UserInfo.getUserName();
            User activeUser = [Select Email From User where Username = : userName limit 1];
            String userEmail = activeUser.Email;
                    addresses += ':'+userEmail;
                
        }

        String[] toAddresses = addresses.split(':', 0);

        // Sets the paramaters of the email
        email.setSubject(subject);
        email.setToAddresses( toAddresses );
        email.setPlainTextBody(body);

        email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});

        // Sends the email
        Messaging.SendEmailResult [] r = 
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});   
		comienzo = false;
        enviado = true;
        return null;
        }
        else{
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Debe colocar un destinatario'));
            return null;
        }
    }
}