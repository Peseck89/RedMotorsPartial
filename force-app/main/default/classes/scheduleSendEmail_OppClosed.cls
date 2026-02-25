global with sharing class scheduleSendEmail_OppClosed implements Schedulable{
    global void execute(SchedulableContext sc) {
        String idTemplate;
        Boolean envio = false;
        String[] toAddresses = new String[]{};
        toAddresses.add('vnunez@redmotorscr.com');
        toAddresses.add('oaparicio@redmotorscr.com');
        toAddresses.add('antonio.dorantesperez@outlook.com');
        List<User> lstOpp = [SELECT id FROM User WHERE UserName = 'rzamora@redmotorscr.com' LIMIT 1 ];
        List<Messaging.SendEmailResult> emails = new List<Messaging.SendEmailResult>();  
        idTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName =: 'OportunidadesCerradas_N'].Id;
		OrgWideEmailAddress[] idAddress = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName =: 'Red Motors'];
        Messaging.SingleEmailMessage correo = new Messaging.SingleEmailMessage();
			correo.setOrgWideEmailAddressId(idAddress.get(0).Id);
			correo.setTemplateId(idTemplate);
			correo.setSaveAsActivity(false);
			correo.setTargetObjectId(lstOpp[0].id);
			// correo.setWhatId();
			correo.setToAddresses(toAddresses);
            emails = Messaging.sendEmail(new Messaging.Email[]{correo});
            if(emails.get(0).isSuccess()){
				envio = true;
			}
    }
}