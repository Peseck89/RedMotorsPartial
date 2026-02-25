public with sharing class cT_aprobacionDescuentoHandler {
    public static  void handleTrigger(List<Aprobaci_n_Descuento__c> TriggerNew,System.TriggerOperation triggerEvent){
        switch on triggerEvent{
            when AFTER_INSERT{
                revision(TriggerNew);
                
            } 
            when AFTER_UPDATE{
                autorizando(TriggerNew);
            } 
        }
    }

    public static void revision(List<Aprobaci_n_Descuento__c> coleeccion){        
        String body;
        String addresses;
        String [] toAddresses = new List<String>();

        List<Id> ids = new List<Id>();
        for(Aprobaci_n_Descuento__c regActual : coleeccion){
            if(regActual.Aprobador_Nivel_2__c != null ){
                System.debug('Entro creacion');
                ids.add(regActual.Aprobador_Nivel_2__c);   
                //sacamos los correos
                List<User> receptor = [SELECT id,Email FROM User  WHERE Id =:regActual.Aprobador_Nivel_2__c];
                for(User usrActual : receptor){
                    toAddresses.add(usrActual.Email);
                }                  
                toAddresses.add('jpramirez@redmotorscr.com');
                toAddresses.add('admin@portalnetcr.com');
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
                
                email.setSubject('Nuevo Aprobación Descuento');
                email.setToAddresses( toAddresses );
            
                body = '<html style="overflow-y: hidden;">'
                +'<head>'
                +'<title></title>'
                +'</head>'
                +'<body style="height: auto; min-height: auto;background:#f5f5f9;"><div style="width:600px;margin: 0 auto;padding: 10px;position: relative;background-color:white;"><br />'
                +' '
                +'<div style="background:#F4F4F4; width:500px;padding: 30px 50px;font-family: Arial, Helvetica, sans-serif;color:#333333;font-size:25px;font-weight:bold">SOLICITUD DE APROBACIÓN DE DESCUENTO.</div>'
                +' '
                +'<div style="width:600px;padding: 30px 50px;font-family: Arial, Helvetica, sans-serif;color:#333333;">Hola: se ha creado una nueva solicitud de descuento.<br />'
                +'<br />'
                +'<br />'
                +'<p> Número de orden de trabajo: <a href="https://redmotors.lightning.force.com/lightning/r/WorkOrder/'+ regActual.Work_Order__c +'/view">' + regActual.Work_Order__r.WorkOrderNumber + '</a> </p> '
                +'<br />'
                +'<p> Producto con descuento: </p> '
                +'<br />'
                +'<table><tr><th></th><th></th><th></th></tr>';
                
                List<Descuento_por_linea__c> productosDesc = [SELECT Id,Descuento__c,Work_Order_Line_Item__c,Articulo_o_mano_de_obra__c FROM Descuento_por_linea__c WHERE Aprobaci_n_Descuento__c =:regActual.id  ];
                for (Descuento_por_linea__c productActual : productosDesc) {
                    body = body  
                    +'<tr><td>' + productActual.Articulo_o_mano_de_obra__c + '</td><td></td><td>' + productActual.Descuento__c + '%</td></tr>';
                }

                body = body  
                +'</table>'
                +'<br />'
                +'<p>Para ver y aprobar dele clic   <a href="https://redmotors.lightning.force.com/lightning/r/Aprobaci_n_Descuento__c/'+ regActual.id +'/view">aquí</a> </p>'
                +'<br />'
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

    public static void autorizando(List<Aprobaci_n_Descuento__c> coleeccion){
        String body;
        String addresses;
        String [] toAddresses = new List<String>();

        List<Id> ids = new List<Id>();

        List<Aprobaci_n_Descuento__c> aprobaActualizar = new List<Aprobaci_n_Descuento__c>();
        List<WorkOrderLineItem> wolisActualizar = new List<WorkOrderLineItem>();

        for(Aprobaci_n_Descuento__c regActual : coleeccion){
            if(regActual.Estado_general__c == null && regActual.Nivel_de_aprobaci_n__c == 'Nivel 3' && regActual.Estado_nivel_1__c != null && regActual.Estado_nivel_3__c == null && regActual.Aprobador_Nivel_3__c != null){
                ids.add(regActual.Aprobador_Nivel_3__c);   
                //sacamos los correos
                List<User> receptor = [SELECT id,Email FROM User WHERE Id =:regActual.Aprobador_Nivel_3__c];
                for(User usrActual : receptor){
                    toAddresses.add(usrActual.Email);
                }    
                toAddresses.add('jpramirez@redmotorscr.com');
                toAddresses.add('admin@portalnetcr.com');
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
                
                email.setSubject('Nuevo Aprobación Descuento');
                email.setToAddresses( toAddresses );
            
                body = '<html style="overflow-y: hidden;">'
                +'<head>'
                +'<title></title>'
                +'</head>'
                +'<body style="height: auto; min-height: auto;background:#f5f5f9;"><div style="width:600px;margin: 0 auto;padding: 10px;position: relative;background-color:white;"><br />'
                +' '
                +'<div style="background:#F4F4F4; width:500px;padding: 30px 50px;font-family: Arial, Helvetica, sans-serif;color:#333333;font-size:25px;font-weight:bold">SOLICITUD DE APROBACIÓN DE DESCUENTO.</div>'
                +' '
                +'<div style="width:600px;padding: 30px 50px;font-family: Arial, Helvetica, sans-serif;color:#333333;">Hola: se ha creado una nueva solicitud de descuento.<br />'
                +'<br />'
                +'<br />'
                +'<p> Número de orden de trabajo: <a href="https://redmotors.lightning.force.com/lightning/r/WorkOrder/'+ regActual.Work_Order__c +'/view">' + regActual.Work_Order__r.WorkOrderNumber + '</a> </p> '
                +'<br />'
                +'<p> Producto con descuento: </p> '
                +'<br />'
                +'<table><tr><th></th><th></th><th></th></tr>';
                
                List<Descuento_por_linea__c> productosDesc = [SELECT Id,Descuento__c,Work_Order_Line_Item__c,Articulo_o_mano_de_obra__c FROM Descuento_por_linea__c WHERE Aprobaci_n_Descuento__c =:regActual.id  ];
                for (Descuento_por_linea__c productActual : productosDesc) {
                    body = body  
                    +'<tr><td>' + productActual.Articulo_o_mano_de_obra__c + '</td><td></td><td>' + productActual.Descuento__c + '%</td></tr>';
                }

                body = body  
                +'</table>'
                +'<br />'
                +'<p>Para ver y aprobar dele clic   <a href="https://redmotors.lightning.force.com/lightning/r/Aprobaci_n_Descuento__c/'+ regActual.id +'/view">aquí</a> </p>'
                +'<br />'
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
                    Messaging.SendEmailResult [] r = 
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email}); 
                }
            }else if((regActual.Estado_general__c == null && regActual.Nivel_de_aprobaci_n__c == 'Nivel 2' && regActual.Estado_nivel_1__c == 'Aprobado' )||(regActual.Estado_general__c == null && regActual.Nivel_de_aprobaci_n__c == 'Nivel 3' && regActual.Estado_nivel_1__c == 'Aprobado' && regActual.Estado_nivel_3__c == 'Aprobado' )){
                //proceso apra aprobar los descuentos de nivel 2
                Aprobaci_n_Descuento__c acc  = new Aprobaci_n_Descuento__c(Id = regActual.Id);
                acc.Estado_general__c = 'Aprobado';

                List<Descuento_por_linea__c> productosDesc = [SELECT Id,Descuento__c,Work_Order_Line_Item__c FROM Descuento_por_linea__c WHERE Aprobaci_n_Descuento__c =:regActual.id  ];
                for (Descuento_por_linea__c productActual : productosDesc) {
                    WorkOrderLineItem productosActu = [SELECT Id,Discount,porcentajeDescuento__c FROM WorkOrderLineItem WHERE id =:productActual.Work_Order_Line_Item__c  ];
                    productosActu.Discount = productActual.Descuento__c;
                    productosActu.porcentajeDescuento__c = productActual.Descuento__c;
                    wolisActualizar.add(productosActu);
                }

                aprobaActualizar.add(acc);                
            }
        }
        if(aprobaActualizar.size() > 0){
            update aprobaActualizar;
        }
        if(wolisActualizar.size() > 0){
            update wolisActualizar;
        }
    }
}