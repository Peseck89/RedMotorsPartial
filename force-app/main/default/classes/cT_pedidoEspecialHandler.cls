public with sharing class cT_pedidoEspecialHandler {
    public static  void handleTrigger(List<Pedido_Especial__c> TriggerNew,System.TriggerOperation triggerEvent){
        switch on triggerEvent{
            when AFTER_INSERT{
                revision(TriggerNew);
                System.debug('en after insert');
            } 
        }
    }

    public static void revision(List<Pedido_Especial__c> coleeccion){  
                        System.debug('en revision');
        

        String body;
        String addresses;
        String [] toAddresses = new List<String>();

        List<Id> ids = new List<Id>();
        
        set<id> oppoid = new set <id>();
        for(Pedido_Especial__c regActual : coleeccion){
            oppoid.add(regActual.Oportunidad__c);
            
        }
        List<Opportunity> opporelacionadas = [Select id, name, OwnerId,Owner.Email,Owner.Name, recordtype.name FROM Opportunity Where id = : oppoid];
        Map<Id, String> oppoRecordTypeName = new Map<Id, String>();
        Map<Id, String> oppIdEmail = new Map<Id, String>();
        Map<Id, String> oppIdName = new Map<Id, String>();
        Map<Id, String> oppIdOwnerName = new Map<Id, String>();
        for(Opportunity opp :opporelacionadas){
            oppoRecordTypeName.put(OPP.ID,OPP.RECORDTYPE.NAME);
            oppIdEmail.put(opp.Id,opp.Owner.Email);
            oppIdName.put(opp.Id,opp.Name);
            oppIdOwnerName.put(opp.Id,opp.Owner.Name);
        }
       
        
        for(Pedido_Especial__c regActual : coleeccion){           
            if(regActual != null ){
                System.debug('Entro creacion');
                // ids.add(regActual.Aprobador_Nivel_2__c);   
                //sacamos los correos
                //List<User> receptor = [SELECT id,Email FROM User  LIMIT 1];
                //for(User usrActual : receptor){
                  //  toAddresses.add(usrActual.Email);
                //}    
                System.debug('recordtype '+oppoRecordTypeName.get(regActual.Oportunidad__c));
                toAddresses.add(oppIdEmail.get(regActual.Oportunidad__c));
                if(oppoRecordTypeName.get(regActual.Oportunidad__c)=='BMW'){
                    System.debug('agregando correo');
                    toAddresses.add('PEV_ABMW@redmotorscr.com');
                }    
                 else if(oppoRecordTypeName.get(regActual.Oportunidad__c)=='MINI'){
                    toAddresses.add('PEV_AMINI@redmotorscr.com');
                }   
                else if(oppoRecordTypeName.get(regActual.Oportunidad__c)=='Motorrad'){
                    toAddresses.add('PEV_MBMW@redmotorscr.com');
                }
                else if(oppoRecordTypeName.get(regActual.Oportunidad__c)=='Kawasaki'){
                    toAddresses.add('PEV_MKAWA@redmotorscr.com');
                }   
                else if(oppoRecordTypeName.get(regActual.Oportunidad__c)=='Polaris'){
                    toAddresses.add('PEV_MPOLARIS@redmotorscr.com');
                }   
                    else {
                        toAddresses.add('soporte@redmotorscr.com');
                    }
 
                // Define the email
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
                //si se quiere un adjunto
                //PageReference pdf  ;
                //pdf =  Page.cT_newQuotePDFSello;
                //pdf.getParameters().put('id',(String)cot.id); 
                //pdf.setRedirect(true);
                // Create the email attachment
                //Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                //efa.setFileName('Presupuesto.pdf');
                //efa.setBody(b);
                
                email.setSubject('Solicitud de pedido especial.');
                email.setToAddresses( toAddresses );
            
                body = '<html style="overflow-y: hidden;">'
                +'<head>'
                +'<title></title>'
                +'</head>'
                +'<body style="height: auto; min-height: auto;background:#f5f5f9;"><div style="width:600px;margin: 0 auto;padding: 10px;position: relative;background-color:white;"><br />'
                +' '
                +'<div style="background:#F4F4F4; width:500px;padding: 30px 50px;font-family: Arial, Helvetica, sans-serif;color:#333333;font-size:25px;font-weight:bold">Solicitud de pedido especial.</div>'
                +' '
                +'<div style="width:600px;padding: 30px 50px;font-family: Arial, Helvetica, sans-serif;color:#333333;">Se ha creado una nueva solicitud de vehículo pedido especial.<br />'            
                +'<br />'
                +'<p> Número de la oportunidad: '+ oppIdName.get(regActual.Oportunidad__c) +  '</p> '
                +'<br />'
                +'<p> Asesor: '+oppIdOwnerName.get(regActual.Oportunidad__c) +' </p> '
                +'<br />'
                +'<p> - Tipo del vehículo: '+ regActual.Tipo__c +  '</p> '
                +'<p> - Año: '+ regActual.Anio__c +  '</p> '
                +'<p> - Marca: '+ regActual.Marca__c +  '</p> '
                +'<p> - Modelo: '+ regActual.Modelo__c +  '</p> '
                +'<p> - Color: '+ regActual.Color__c +  '</p> '
                +'<p> - Código de tapicería: '+ regActual.Codigo_Tapiceria__c +  '</p> '
                +'<p> - Comentario: '+ regActual.Comentario__c +  '</p> '                     
                +'<br />'
                +'<p> Ir a la oportunidad: <a href="https://redmotors.lightning.force.com/lightning/r/Opportunity/'+ regActual.Oportunidad__c +'/view">' + oppIdName.get(regActual.Oportunidad__c)  +  '</a> </p>'
                +' </div>'
                +'<br />'
                +' '
                +'</div>'
                +'</body>'
                +'</html>';

                email.setHtmlBody(body);
                //email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
                // Sends the email
                if (test.isRunningTest()) {
                    
                }else{
                    System.debug('Entro envio');
                    Messaging.SendEmailResult [] r = 
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email}); 
                    System.debug('Envio');
                }
            } 
        }
    }

}