public with sharing class cT_QuotePDFEmail {
    public String subject { get; set; }
    public String body { get; set; }
    public String destinatario { get; set; }
    public Boolean enviado { get; set; }
    public Boolean comienzo { get; set; }

    private final Quote cot;

	public cT_QuotePDFEmail() {
        comienzo = true;
        enviado = false;
        cot = [select Account.Cedula__c,Account.Phone,Account.PersonMobilePhone,BMW_CodigoDeProducto__c,
        Opportunity.BMW_PlacaDeVehiculoOElVIN__c,
        Account.personemail,Account.CorreoElectronicoEmpresarial__c,
        Opportunity.BMW_PlacaDeVehiculoOElVIN__r.Kilometros__c,
        Opportunity.BMW_PlacaDeVehiculoOElVIN__r.Anio__c,
        Opportunity.BMW_PlacaDeVehiculoOElVIN__r.numeroDePlaca__c,
        Opportunity.BMW_PlacaDeVehiculoOElVIN__r.NumeroDeChasis__c,
        Opportunity.BMW_PlacaDeVehiculoOElVIN__r.marca__c, 
        Opportunity.WorkOrder__c,OpportunityId,
        Account.Name,Account.Pais__c,Account.Provincia__pr.Name,
        Account.Canton__r.Name,Account.Distrito__r.Name,Account.Barrio__c,Account.Calle__c,
        Account.Direccion_Residencial__c,Account.Direccion__c,Account.Type,
        id,Email,Description,Discount,ShippingAddress,CurrencyIsoCode,
        AdditionalAddress,ShippingHandling,Status,BillingAddress,Fax,
        ExpirationDate,Tax,AdditionalName,ShippingName,Vegencia_del_presupuesto__c,
        BillingName,QuoteToName,Name,QuoteNumber,TotalPrice,QuoteToAddress,
        Subtotal,Phone,GrandTotal,CreatedDate,OwnerId, Orden_De_Trabajo__c,
        
        (select id,Quantity,Description,Discount,UnitPrice,TotalPrice,BMW_Producto_Custom__c,
        BMW_TipoDeArticulo__c, Product2.Name,Product2.Codigo_de_Producto__c,BMW_Dispinible__c
                                                                from QuoteLineItems 
                                                                ) 
               from Quote
               where id =: ApexPages.currentPage().getParameters().get('id')
               LIMIT 1];    
               
        if (cot.Account.CorreoElectronicoEmpresarial__c != null) {
            destinatario = '' + cot.Account.CorreoElectronicoEmpresarial__c;    
        }       else {
            destinatario = '' + cot.Account.PersonEmail;
        }
        
        body =  'Adjunto encontrará el presupuesto del vehículo placa '+cot.Opportunity.BMW_PlacaDeVehiculoOElVIN__r.numeroDePlaca__c +'. ¡Cualquier consulta por favor contactarnos!.';
    }

    public Quote getQuote() {
        return cot;
    }
    
    public PageReference send() {
        // Define the email
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
        PageReference pdf  ;
        // Reference the attachment page and pass in the quote ID
        if (cot.Vegencia_del_presupuesto__c == '15 Días' || cot.Vegencia_del_presupuesto__c == '30 Días') {
             pdf =  Page.cT_newQuotePDFSello;
        }else {
             pdf =  Page.BMW_QuotePDFv2;
        }        
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
            //addresses+= ':'+opp.Account.personemail;
            String userName = UserInfo.getUserName();
            User activeUser = [Select Email From User where Username = : userName limit 1];
            String userEmail = activeUser.Email;
                    addresses += ':'+userEmail;
                
        }

        String[] toAddresses = addresses.split(':', 0);

        // Sets the paramaters of the email
        email.setSubject(subject);
        email.setToAddresses( toAddresses );
        String userId = UserInfo.getUserId();
        User dataUsuario = [SELECT Name,UserRole.RollupDescription,Email,MobilePhone,Phone,Title FROM User WHERE id = :userId];
        String nombreUsuario = dataUsuario.Name;
        String rolUsuario = dataUsuario.Title;
        String emailUsuario = dataUsuario.Email;
        String telefonoUsuario = dataUsuario.Phone;
        String firma = '<br />'
                        +' '+nombreUsuario+'<br />'
                        +' '+rolUsuario+'<br />'
                        +' '+emailUsuario+'<br />'
                        +' '+telefonoUsuario+'<br />'
                        +'<br />';
        String validez = '';
        if(cot.Vegencia_del_presupuesto__c == '15 Días')
        {
            validez = '15 días';
        }else if(cot.Vegencia_del_presupuesto__c == '30 Días') {
            validez = '30 días';
        }else {
            
        }
        //se comianza la construccion del cuerpo 
        body =  body.replace('\n', '<br/>');
        if(cot.Opportunity.BMW_PlacaDeVehiculoOElVIN__r.marca__c =='Moto BMW'){
            body = '<html style="overflow-y: hidden;">'
                +'<head>'
                +'<title></title>'
                +'</head>'
                +'<body style="height: auto; min-height: auto;"><img alt="logoMotoBMW" src="https://c.na137.content.force.com/servlet/servlet.ImageServer?id=0154U000008MEBX&oid=00D0P000000Dvkz" style="max-width: 676.207px; width: 259.983px; height: 86.9879px;" title="logoMotoBMW" /><br />'
                +'&nbsp;'
                +'<br/><div style="background:#F4F4F4; width:100%;padding: 30px 50px;font-family: Arial, Helvetica, sans-serif;color:#333333;font-size:50px;font-weight:bold">PRESUPUESTO.</div>'
                +'&nbsp;'
                +'<div style="width:100%;padding: 30px 50px;font-family: Arial, Helvetica, sans-serif;color:#333333;font-size:">Estimado/a Sr/Sra '+ cot.Account.Name +';<br />'
                +'<br />'
                +body
                +'<br /><br />'
                +'Nota: Este presupuesto cuenta con '
                +validez
                +' de validez.<br />'
                +'<br />'
                + firma
                +'&nbsp;</div>'
                +'<br />'
                +'&nbsp;'
                +'<table style="background: #F4F4F4; width:100%;padding: 30px 50px;font-family: Arial, Helvetica, sans-serif;color:#333333">'
                +'<tbody>'
                +'<tr>'
                +'<td><img alt="logoMotoBMW" src="https://c.na137.content.force.com/servlet/servlet.ImageServer?id=0154U000008MEBX&oid=00D0P000000Dvkz" style="max-width: 676.207px; width: 259.983px; height: 86.9879px;" title="logoMotoBMW" /></td>'
                +'<td style="width:750px;">'
                +'<span style="padding-left:23px;font-width:bold;font-size:17px;">'
                +'<b>BAVARIAN MOTORS CR S.A.</b>'
                +'<br/><b style="font-size:10px;padding-left:25px;"> Cédula Jur. No 3-101-502-521<br/>'
                +'</b><span style="font-size:10px;padding-left:25px;">'
                +'<b>Tel.:'
                +'</b> (506) 2547-5000'
                +'<b>Fax:'
                +'</b> (506) 2221-5002'
                +'<br/>'
                +'</span>'
                +'<span style="font-size:10px;padding-left:25px;">'
                +'Taller@redmotorscr.com www.bmw.co.cr'
                +'<br/></span> <span style="font-size:10px;padding-left:25px;">'
                +'<b>Apdo:</b> 7461150 <br/> </span>'
                +'<span style="font-size:10px;padding-left:25px;">'
                +'La Uruca, costado sur de la estación de servicio delta, San José, Costa Rica'
                +'</span></span></td></tr> </table>'
                +'</table>'
                +'</body>'
                +'</html>';
        }else if(cot.Opportunity.BMW_PlacaDeVehiculoOElVIN__r.marca__c =='Moto Kawa'){
            body = '<html style="overflow-y: hidden;">'
                +'<head>'
                +'<title></title>'
                +'</head>'
                +'<body style="height: auto; min-height: auto;"><img alt="logoKawasaki" src="https://c.na137.content.force.com/servlet/servlet.ImageServer?id=0154U000008MEBc&oid=00D0P000000Dvkz" style="max-width: 676.207px; width: 259.983px; height: 86.9965px;" title="logoKawasaki" /><br />'
                +'&nbsp;'
                +'<br/><div style="background:#F4F4F4; width:100%;padding: 30px 50px;font-family: Arial, Helvetica, sans-serif;color:#333333;font-size:50px;font-weight:bold">PRESUPUESTO.</div>'
                +'&nbsp;'
                +'<div style="width:100%;padding: 30px 50px;font-family: Arial, Helvetica, sans-serif;color:#333333;font-size:">Estimado/a Sr/Sra '+ cot.Account.Name +';<br />'
                +'<br />'
                +body
                +'<br /><br />'
                +'Nota: Este presupuesto cuenta con ' +validez +' de validez.<br />'
                +'<br />'
                + firma
                +'&nbsp;</div>'
                +'<br />'
                +'&nbsp;'
                +'<table style="background: #F4F4F4; width:100%;padding: 30px 50px;font-family: Arial, Helvetica, sans-serif;color:#333333">'
                +'<tbody>'
                +'<tr>'
                +'<td><img alt="logoKawasaki" src="https://c.na137.content.force.com/servlet/servlet.ImageServer?id=0154U000008MEBc&oid=00D0P000000Dvkz" style="max-width: 676.207px; width: 259.983px; height: 86.9965px;" title="logoKawasaki" /></td>'
                +'<td style="width:750px;">'
                +'<span style="padding-left:23px;font-width:bold;font-size:17px;">'
                +'<b>BAVARIAN MOTORS CR S.A.</b>'
                +'<br/><b style="font-size:10px;padding-left:25px;"> Cédula Jur. No 3-101-502-521<br/>'
                +'</b><span style="font-size:10px;padding-left:25px;">'
                +'<b>Tel.:'
                +'</b> (506) 2547-5000'
                +'<b>Fax:'
                +'</b> (506) 2221-5002'
                +'<br/>'
                +'</span>'
                +'<span style="font-size:10px;padding-left:25px;">'
                +'Taller@redmotorscr.com www.bmw.co.cr'
                +'<br/></span> <span style="font-size:10px;padding-left:25px;">'
                +'<b>Apdo:</b> 7461150 <br/> </span>'
                +'<span style="font-size:10px;padding-left:25px;">'
                +'La Uruca, costado sur de la estación de servicio delta, San José, Costa Rica'
                +'</span></span></td></tr> </table>'
                +'</table>'
                +'</body>'
                +'</html>';
        }else if(cot.Opportunity.BMW_PlacaDeVehiculoOElVIN__r.marca__c =='Vehículo Polaris'){
            body = '<html style="overflow-y: hidden;">'
                +'<head>'
                +'<title></title>'
                +'</head>'
                +'<body style="height: auto; min-height: auto;"><img alt="logoPolaris" src="https://c.na137.content.force.com/servlet/servlet.ImageServer?id=0154U000008MEBd&oid=00D0P000000Dvkz" style="max-width: 676.207px; width: 259.983px; height: 86.9879px;" title="logoPolaris" /><br />'
                +'&nbsp;'
                +'<br/><div style="background:#F4F4F4; width:100%;padding: 30px 50px;font-family: Arial, Helvetica, sans-serif;color:#333333;font-size:50px;font-weight:bold">PRESUPUESTO.</div>'
                +'&nbsp;'
                +'<div style="width:100%;padding: 30px 50px;font-family: Arial, Helvetica, sans-serif;color:#333333;font-size:">Hola;<br />'
                +'<br />'
                +body
                +'<br /><br />'
                +'Nota: Este presupuesto cuenta con ' +validez +' de validez.<br />'
                +'<br />'
                + firma
                +'&nbsp;</div>'
                +'<br />'
                +'&nbsp;'
                +'<table style="background: #F4F4F4; width:100%;padding: 30px 50px;font-family: Arial, Helvetica, sans-serif;color:#333333">'
                +'<tbody>'
                +'<tr>'
                +'<td><img alt="logoPolaris" src="https://c.na137.content.force.com/servlet/servlet.ImageServer?id=0154U000008MEBd&oid=00D0P000000Dvkz" style="max-width: 676.207px; width: 259.983px; height: 86.9879px;" title="logoPolaris" /></td>'
                +'<td style="width:750px;">'
                +'<span style="padding-left:23px;font-width:bold;font-size:17px;">'
                +'<b>BAVARIAN MOTORS CR S.A.</b>'
                +'<br/><b style="font-size:10px;padding-left:25px;"> Cédula Jur. No 3-101-502-521<br/>'
                +'</b><span style="font-size:10px;padding-left:25px;">'
                +'<b>Tel.:'
                +'</b> (506) 2547-5000'
                +'<b>Fax:'
                +'</b> (506) 2221-5002'
                +'<br/>'
                +'</span>'
                +'<span style="font-size:10px;padding-left:25px;">'
                +'Taller@redmotorscr.com www.bmw.co.cr'
                +'<br/></span> <span style="font-size:10px;padding-left:25px;">'
                +'<b>Apdo:</b> 7461150 <br/> </span>'
                +'<span style="font-size:10px;padding-left:25px;">'
                +'La Uruca, costado sur de la estación de servicio delta, San José, Costa Rica'
                +'</span></span></td></tr> </table>'
                +'</table>'
                +'</body>'
                +'</html>';
        }else{
            body = '<html style="overflow-y: hidden;">'
                +'<head>'
                +'<title></title>'
                +'</head>'
                +'<body style="height: auto; min-height: auto;"><img alt="bmwminiLogo" src="https://c.na137.content.force.com/servlet/servlet.ImageServer?id=0154U000008MEBh&oid=00D0P000000Dvkz" style="max-width: 716.673px; width: 238.993px; height: 80px;" title="bmwminiLogo" /><br />'
                +'&nbsp;'
                +'<br/><div style="background:#F4F4F4; width:100%;padding: 30px 50px;font-family: Arial, Helvetica, sans-serif;color:#333333;font-size:50px;font-weight:bold">PRESUPUESTO.</div>'
                +'&nbsp;'
                +'<div style="width:100%;padding: 30px 50px;font-family: Arial, Helvetica, sans-serif;color:#333333;font-size:">Hola;<br />'
                +'<br />'
                +body        
                +'<br /><br />'
                +'Nota: Este presupuesto cuenta con ' +validez +' de validez.<br />'
                +'<br />'        
                + firma
                +'&nbsp;</div>'
                +'<br />'
                +'&nbsp;'
                +'<table style="background: #F4F4F4; width:100%;padding: 30px 50px;font-family: Arial, Helvetica, sans-serif;color:#333333">'
                +'<tbody>'
                +'<tr>'
                +'<td><img alt="bmwminiLogo" src="https://c.na137.content.force.com/servlet/servlet.ImageServer?id=0154U000008MEBh&oid=00D0P000000Dvkz" style="max-width: 716.673px; width: 238.993px; height: 80px;" title="bmwminiLogo" /></td>'
                +'<td style="width:750px;">'
                +'<span style="padding-left:23px;font-width:bold;font-size:17px;">'
                +'<b>BAVARIAN MOTORS CR S.A.</b>'
                +'<br/><b style="font-size:10px;padding-left:25px;"> Cédula Jur. No 3-101-502-521<br/>'
                +'</b><span style="font-size:10px;padding-left:25px;">'
                +'<b>Tel.:'
                +'</b> (506) 2547-5000'
                +'<b>Fax:'
                +'</b> (506) 2221-5002'
                +'<br/>'
                +'</span>'
                +'<span style="font-size:10px;padding-left:25px;">'
                +'Taller@redmotorscr.com www.bmw.co.cr'
                +'<br/></span> <span style="font-size:10px;padding-left:25px;">'
                +'<b>Apdo:</b> 7461150 <br/> </span>'
                +'<span style="font-size:10px;padding-left:25px;">'
                +'La Uruca, costado sur de la estación de servicio delta, San José, Costa Rica'
                +'</span></span></td></tr> </table>'
                +'</table>'

                +'</body>'
                +'</html>';
        }



        email.setHtmlBody(body);

        email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});

        // Sends the email
        if (test.isRunningTest()) {
            
        }else{
            Messaging.SendEmailResult [] r = 
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email}); 
        }
          
		comienzo = false;
        enviado = true;
        return null;
    }
}