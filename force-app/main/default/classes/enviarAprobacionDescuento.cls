public with sharing class enviarAprobacionDescuento {
    @InvocableMethod(label='Enviar aprobacion descuento' description='metodo de enviarAprobacionDescuento' category='WorkOrder')
    public static void enviarNoti(List<String> IdWO){
        String WOid = IdWO[0];
        List<Messaging.SingleEmailMessage> mail = new list<Messaging.SingleEmailMessage> ();
        List<WorkOrder> oppList = [Select Id,productosDescMO__c,ServiceTerritoryId,productosDescMaterial__c,Nivel_de_aprobaci_n_descuento_para_art_c__c,Nivel_de_aprobaci_n_descuento_para_MO__c,WorkOrderNumber,Owner.FirstName,Owner.LastName,Owner.Email  FROM WorkOrder where Id =: WOid];
        String  correo1 = 'info@redmotorscr.com';
        String correo2 = 'info@redmotorscr.com';
        String aprobador = '';
            for(WorkOrder op : oppList){
                List<ServiceTerritory> lstService = [SELECT id,Asesor_de_repuestos_asignado__c,Asesor_de_servicio_asignado__c,
                Jefe_de_repuesto_asignado__c,Jefe_de_sucursal_asignado__c,
                Gerente_asignado__c,Gerente_repuestos_asignado__c,Asesor_de_repuestos_asignado__r.FirstName,
                Asesor_de_repuestos_asignado__r.Email, Asesor_de_servicio_asignado__r.Email,Asesor_de_servicio_asignado__r.FirstName,
                Jefe_de_repuesto_asignado__r.Email,Jefe_de_repuesto_asignado__r.FirstName,
                 Jefe_de_sucursal_asignado__r.Email,Jefe_de_sucursal_asignado__r.FirstName,
                Gerente_asignado__r.Email,Gerente_asignado__r.FirstName,
                 Gerente_repuestos_asignado__r.Email,Gerente_repuestos_asignado__r.FirstName
                FROM ServiceTerritory WHERE Id =: op.ServiceTerritoryId];
                if(op.Nivel_de_aprobaci_n_descuento_para_art_c__c != null || op.Nivel_de_aprobaci_n_descuento_para_MO__c != null){

                    if(op.Nivel_de_aprobaci_n_descuento_para_art_c__c == 'Gerente'){
                        correo1 = lstService[0].Gerente_repuestos_asignado__r.Email;
                        aprobador = lstService[0].Gerente_repuestos_asignado__r.FirstName;
                        
                    }else if(op.Nivel_de_aprobaci_n_descuento_para_art_c__c == 'Jefe'){
                        correo1 = lstService[0].Jefe_de_repuesto_asignado__r.Email;
                        aprobador = lstService[0].Jefe_de_repuesto_asignado__r.FirstName;

                    }
                    // else if(op.Nivel_de_aprobaci_n_descuento_para_art_c__c == 'Asesor'){
                    //     correo1 = lstService[0].Asesor_de_repuestos_asignado__r.Email;
                    //     aprobador = lstService[0].Asesor_de_repuestos_asignado__r.FirstName;

                    // }

                    if(op.Nivel_de_aprobaci_n_descuento_para_MO__c == 'Gerente'){
                        correo2 = lstService[0].Gerente_asignado__r.Email;
                        aprobador = lstService[0].Gerente_asignado__r.FirstName;

                    }else if(op.Nivel_de_aprobaci_n_descuento_para_MO__c == 'Jefe'){
                        correo2 = lstService[0].Jefe_de_sucursal_asignado__r.Email;
                        aprobador = lstService[0].Jefe_de_sucursal_asignado__r.FirstName;

                    }
                    // else if(op.Nivel_de_aprobaci_n_descuento_para_MO__c == 'Asesor'){
                    //     correo2 = lstService[0].Asesor_de_servicio_asignado__r.Email;
                    //     aprobador = lstService[0].Asesor_de_servicio_asignado__r.FirstName;

                    // }
                    // correo1 = 'antonio.dorantesperez@outlook.com';
                    // correo2 = 'antonio.dorantesperez@outlook.com';
                    Messaging.SingleEmailMessage mailpoli = new Messaging.SingleEmailMessage();
                    string body = CurpoCorreoHTML(op.Owner.FirstName,op.Owner.LastName,'test',op.Id,op,aprobador);     
                    string asunto = 'Nueva solicitud de descuento.';
                    mailpoli.setHtmlBody(body);
                    mailpoli.setSubject(asunto);
                    mailpoli.setToAddresses(new String[]{correo2,correo1});
                    //mailpoli.setCcAddresses(new String[]{'mario@incompany.cr','bricet@incompany.cr'});
                    mail.add(mailpoli);
                }            
            }
            if (Test.isRunningTest()) {
                
            }else {
                Messaging.SendEmailResult[] result = Messaging.sendEmail(mail);
            }

        }

        
                            
    
    
    public static string CurpoCorreoHTML(string OwnerFullNameOpp, string OwnerFullLastNameOpp, string NameOpp,String IdOpp,WorkOrder regActual,String aprobador ){
                                    
                String salidaBody =  '<html style="overflow-y: hidden;">'
                +'<head>'
                +'<title></title>'
                +'</head>'
                +'<body style="height: auto; min-height: auto;background:#f5f5f9;"><div style="width:600px;margin: 0 auto;padding: 10px;position: relative;background-color:white;"><br />'
                +' '
                +'<div style="background:#F4F4F4; width:500px;padding: 30px 50px;font-family: Arial, Helvetica, sans-serif;color:#333333;font-size:25px;font-weight:bold">SOLICITUD DE APROBACIÓN DE DESCUENTO.</div>'
                +' '
                +'<div style="width:600px;padding: 30px 50px;font-family: Arial, Helvetica, sans-serif;color:#333333;">Hola '+aprobador+' se ha creado una nueva solicitud de descuento por parte del asesor '+OwnerFullNameOpp +' ' +OwnerFullLastNameOpp +'<br />'
                +'<br />'
                +'<br />'
                +'<p> Número de orden de trabajo: <a href="https://redmotors.lightning.force.com/lightning/r/WorkOrder/'+ regActual.Id +'/view">' + regActual.WorkOrderNumber + '</a> </p> '
                +'<br />'
                +'<p> A continuación se muestra los productos o mano de obra que se necesita por aprobación: </p> '
                +'<br />'
                +'<table border="1" style="border-collapse:collapse" ><tr><th>Código</th><th>Nombre de producto</th><th>Descuento</th></tr>';
                //falta sacar los productos de WO y MO solo si tienen en la listas
                List <String> result = new List<String>();
                List<String> lstAlpha = new List<String>();
                String woLiActual = '';
                
           

                List<WorkorderLineItem> productosDesc = [SELECT Id,WorkOrderId,Descuento_Formula__c,Product2.Codigo_de_Producto__c,Product2Id,Product2.Name FROM WorkorderLineItem WHERE Work_Order_Mano__c =: regActual.id OR Work_Order_Productos__c =: regActual.id ];
                                                
                for (WorkorderLineItem productActual : productosDesc) {
                    salidaBody = salidaBody  
                    +'<tr><td>' + productActual.Product2.Codigo_de_Producto__c  + '</td><td>' +  productActual.Product2.Name + '</td><td>' + productActual.Descuento_Formula__c + '%</td></tr>';
                }

                salidaBody = salidaBody  
                +'</table>'
                +'<br />'
                //+'<p>Ingrese al siguiente link para realizar la aprobación respectiva:   <a href="https://redmotors.lightning.force.com/lightning/r/Aprobaci_n_Descuento__c/'+ regActual.id +'/view">aquí</a> </p>'
                +'<p>Ingrese al siguiente link para realizar la aprobación respectiva:   <a href="https://redmotors.lightning.force.com/lightning/r/WorkOrder/'+ regActual.Id +'/view">' + regActual.WorkOrderNumber + '</a> </p>'
                +'<br />'
                +' </div>'
                +'<br />'
                +' Saludos. '
                +'</div>'
                +'</body>'
                +'</html>';
        
        return salidaBody;
    }
}