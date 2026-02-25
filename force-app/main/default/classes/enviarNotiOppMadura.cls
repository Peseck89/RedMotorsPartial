public with sharing class enviarNotiOppMadura {
    @InvocableMethod(label='Send aprrov request' description='Returns the list of opp' category='Opportunity')
    public static void enviarNoti(List<String> IdOpps){
        String IdOpp = IdOpps[0];
        List<Messaging.SingleEmailMessage> mail = new list<Messaging.SingleEmailMessage> ();
        List<Opportunity> oppList = [Select Id, Name,Owner.Name,Owner.Email  FROM Opportunity where Id =: IdOpp];
        
            for(Opportunity op : oppList){
                Messaging.SingleEmailMessage mailpoli = new Messaging.SingleEmailMessage();
                                string body = CurpoCorreoHTML(op.Owner.Name,op.Name,op.Id);     
                                string asunto = 'Oportunidad cartera madura.';
                                mailpoli.setHtmlBody(body);
                                mailpoli.setSubject(asunto);
                                mailpoli.setToAddresses(new String[]{op.Owner.Email});
                                //mailpoli.setCcAddresses(new String[]{'mario@incompany.cr','bricet@incompany.cr'});
                                mail.add(mailpoli);
            }
            if (Test.isRunningTest()) {
                
            }else {
                Messaging.SendEmailResult[] result = Messaging.sendEmail(mail);
            }

        }

        
                            
    
    
    public static string CurpoCorreoHTML(string OwnerFullNameOpp, string NameOpp,String IdOpp){
                                    
                String salidaBody =  '<html style="overflow-y: hidden;">'
                +'<head>'
                +'<title></title>'
                +'</head>'
                +'<body style="height: auto; min-height: auto;background:#f5f5f9;"><div style="width:600px;margin: 0 auto;padding: 10px;position: relative;background-color:white;"><br />'
                +' '
                +'<div style="background:#F4F4F4; width:500px;padding: 30px 50px;font-family: Arial, Helvetica, sans-serif;color:#333333;font-size:25px;font-weight:bold">Oportunidad a etapa calificada.</div>'
                +' '                 
                +'<br />'
                +'<p style="width:580px">	Estimado '+OwnerFullNameOpp+':</p>'+
                '<br/>'+
                'La oportunidad '+NameOpp+' ha pasado a la etapa calificada.'+
                '<br/>'+
                'Es momento de que contacte a este cliente.'+
                '<br />'+
                '<br />'+
                '<p> Para acceder a los datos de contacto de esta Oportunidad, haga clic en el siguiente link:</p><p style="font-weight: bold;"> https://redmotors.my.salesforce.com/'+IdOpp+'</p>'+
                '<br />'+
                '<p style="width:580px"> Salesforce </p>'+
                +' </div>'
                +'<br />'
                +' '
                +'</div>'
                +'</body>'
                +'</html>';
        
        return salidaBody;
    }
    
}