public class cT_batchCumpleAltica implements Database.Batchable<sObject>,Database.Stateful{

    public Database.QueryLocator start(Database.BatchableContext bc) {
		if (test.isRunningTest()) {
            return Database.getQueryLocator(
                'Select Id,Sexo__c,Fecha_Nacimiento__c,PersonEmail From Account WHERE RecordTypeId IN (SELECT Id FROM RecordType WHERE Name = \'Cliente Físico\' OR Name = \'Cuenta Personal\' OR Name = \'RedMotors-Altica\')  AND Id IN (SELECT Nombre_Cliente_Altica__c FROM Oportunidad_de_Financiamiento__c WHERE Estado__c = \'Aprobada\' AND Etapa__c = \'Cliente formalizado.\') LIMIT 200 '
            );
        }else{
            return Database.getQueryLocator(
            'Select Id,Sexo__c,Fecha_Nacimiento__c,PersonEmail From Account WHERE RecordTypeId IN (SELECT Id FROM RecordType WHERE Name = \'Cliente Físico\' OR Name = \'Cuenta Personal\' OR Name = \'RedMotors-Altica\')  AND Id IN (SELECT Nombre_Cliente_Altica__c FROM Oportunidad_de_Financiamiento__c WHERE Estado__c = \'Aprobada\' AND Etapa__c = \'Cliente formalizado.\') '
        );
        }
        
    }
    public void execute(Database.BatchableContext bc, List<Account> scope){
        // process each batch of records
        String fechaHoy =  DateTime.now().format('yyyy-MM-dd');
        Integer anio = date.today().year();
        Integer mes = date.today().month();
        Integer dia = date.today().day();
        String body ='';

        // Create the email attachment
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
        
        email.setOrgWideEmailAddressId('0D20P0000004ESaSAM');

        List<Oportunidad_de_Financiamiento__c> oppFinan =  [SELECT Id,Estado__c,Etapa__c,Categoria__c,Nombre_Cliente_Altica__c FROM Oportunidad_de_Financiamiento__c WHERE Estado__c = 'Aprobada' AND Etapa__c = 'Cliente formalizado.' AND Nombre_Cliente_Altica__c  IN :scope ];

        for (Account acc : scope) {
            if ( acc.Fecha_Nacimiento__c != null) {
                Integer mesPersona = acc.Fecha_Nacimiento__c.month();
                Integer diaPersona = acc.Fecha_Nacimiento__c.day() ;                
                Boolean coche = false;
                Boolean moto = false;
				if (test.isRunningTest()) {
                  diaPersona = acc.Fecha_Nacimiento__c.day();  
                }
                if(mesPersona == mes && diaPersona== dia)
                {
                    if(acc.PersonEmail != null){
                        email.toAddresses = new String[] {''+acc.PersonEmail+''};
                    }else {
                        email.toAddresses = new String[] {'customdomain@test.com'};
                    }
                  
                    email.subject = 'Feliz cumpleaños, te desea Áltica Servicios';
                    if (acc.Sexo__c != null) {       
                        System.debug(acc.Sexo__c );
                        if (acc.Sexo__c == 'Mujer') {
                          if (oppFinan.size()> 0 ) {
                            body = '<html style="overflow-y: hidden;">'
                            +'<head>'
                            +'<title></title>'
                            +'</head>'
                            +'<body style="height: auto; min-height: auto;"><img alt="logoMotoBMW" src="https://c.na137.content.force.com/servlet/servlet.ImageServer?id=0154U000008MFTw&oid=00D0P000000Dvkz" style="max-width: 676.207px; width: 100%; height:100%;" title="logoMotoBMW" /><br />'
                            +'&nbsp;'                        
                            +'</body>'
                            +'</html>';
                          }
                        }else {
                            
                                for (Oportunidad_de_Financiamiento__c opps : oppFinan)
                                {
                                    if(opps.Nombre_Cliente_Altica__c == acc.id){
                                        if (opps.Categoria__c == 'Automóvil') {
                                        	coche = true;
                                        }else if (opps.Categoria__c == 'Moto') {
                                            moto = true;
                                        }
                                    }
                                        
                                    
                                }
                            
                            if ((coche && moto) || (moto == false)) {
                                body = '<html style="overflow-y: hidden;">'
                                +'<head>'
                                +'<title></title>'
                                +'</head>'
                                +'<body style="height: auto; min-height: auto;"><img alt="logoMotoBMW" src="https://c.na137.content.force.com/servlet/servlet.ImageServer?id=0154U000008MFU1&oid=00D0P000000Dvkz" style="max-width: 676.207px; width: 100%; height:100%;" title="logoMotoBMW" /><br />'
                                +'&nbsp;'                        
                                +'</body>'
                                +'</html>';

                            }else if(moto){
                                body = '<html style="overflow-y: hidden;">'
                                +'<head>'
                                +'<title></title>'
                                +'</head>'
                                +'<body style="height: auto; min-height: auto;"><img alt="logoMotoBMW" src="https://c.na137.content.force.com/servlet/servlet.ImageServer?id=0154U000008MFTr&oid=00D0P000000Dvkz" style="max-width: 676.207px; width: 100%; height:100%;" title="logoMotoBMW" /><br />'
                                +'&nbsp;'                        
                                +'</body>'
                                +'</html>';                                
                            }
                        }    

                        email.setHtmlBody(body);
                        if (test.isRunningTest()) {
                    
                        }else{
                            Messaging.SendEmailResult [] r = 
                            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email}); 
                        }
                    }
                }            
            }                        
        }
        
    }
    public void finish(Database.BatchableContext bc){

        // call some utility to send email
    }

}