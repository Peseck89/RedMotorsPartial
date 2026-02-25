/**
    @Autor: David Leon Sanchez IS
    @Fecha creacion: 11/22/2019
    @Proyecto: Altica Gestiones
**/

public class GestionServices {
	
    //Metodo para el envio del pdf de recibo de pago al cliente
    @future(callout=true)
    public static void enviarEmailCliente(Id idGestion){
        PageReference pdf;
		Blob b;
        Id idAddress;
        Gestion__c gestion = new Gestion__c();
        
        gestion = [SELECT Id, Email_Cliente__c, Nombre_Completo__r.Name
                   FROM Gestion__c 
                   WHERE Id =: idGestion];
        System.debug(' ** GestionService ** ' + gestion);
        idAddress = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName =: 'Altica'].Id;
        pdf = Page.reciboPagoPDF;
        pdf.getParameters().put('Id', gestion.Id);
		if(Test.isRunningTest()){
			b = Blob.valueOf('Unit.Test');
		}else{
			b = pdf.getContentAsPDF();
		}
        
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        efa.setFileName('Recibo de Pago.pdf');
        efa.setBody(b);
        
        email.setSubject('Recibo de Pago');
        email.setOrgWideEmailAddressId(idAddress);
        email.setToAddresses(new List<String>{gestion.Email_Cliente__c});
		email.setPlainTextBody('<html>' + 
						'<body>' +
						'<img style="padding-left:60px;" src="https://c.na37.content.force.com/servlet/servlet.ImageServer?id=0150P000006ZrlV&oid=00DNq00000BChu2&lastMod=1506958279000" />' + '\n\n' +
						'Estimado(a) ' + gestion.Nombre_Completo__r.Name + '\n\n' +
						'Gracias por su solicitud, la misma ha sido procesada.' + '\n\n' +
						'Adjunto encontrará su recibo de pago.' + '\n\n' +
						'Agradecemos su preferencia y confianza.'
						);
        email.setHtmlBody('<html>' + 
						'<body>' +
						'<img style="padding-left:60px;" src="https://c.na37.content.force.com/servlet/servlet.ImageServer?id=0150P000006ZrlV&oid=00DNq00000BChu2&lastMod=1506958279000" />' + '<br><br>' +
						'Estimado(a) ' + gestion.Nombre_Completo__r.Name + '<br><br>' +
						'Gracias por su solicitud, la misma ha sido procesada.' + '<br><br>' +
						'Adjunto encontrará su recibo de pago.' + '<br><br>' +
						'Agradecemos su preferencia y confianza.'
						);
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{efa});
        
        try{
            Messaging.SendEmailResult[] result = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
        }catch(System.Exception e){
            System.debug(' ** ERROR AL ENVIAR RECIBO DE PAGO ** ' + e.getMessage());
        }
    }
}