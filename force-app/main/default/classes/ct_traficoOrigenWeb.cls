public class ct_traficoOrigenWeb {
    @InvocableMethod(label='Send Email Trafico' description='Send email when trafico equals origen web.' category='Lead')
    public static void insertAccounts(List<String> leads) {
        String idTrafico = '';
        String str = '';
        String marca = '';
        String familia = '';
        String primerNombre = '';
        String ultimoNombre = '';
        String documento = '';
        String modeloCot = '';
        String cuotaCot = '';
        String primaCot = '';
        String precioCot = '';
        String ownerFirstame = '';
        String ownerLastname = '';
        String cellPhone = '';
        String emailPhone = '';
        String destinatario = '';
        String leadId = '';
        List<Id> ids = new List<Id>();
        if (leads.size()>0) {
            idTrafico = leads[0];
            
        }
        List<Lead> traficoOriginal = [SELECT id,Vehiculo_cotizacion__c,DocumentId__c,RecordType__c,Modelo_De_Inter_s1__c,Marca__c,OwnerId,Owner.FirstName, Owner.LastName,Familia1__c,Modelo_cotizacion__c
        ,Cuota_mensual_cotizacion__c,Prima_cotizacion__c,Precio_cotizacion__c,FirstName,Email,LastName,Owner.Phone,Owner.Email FROM Lead WHERE Id =:idTrafico];        
        if(traficoOriginal.size()>0){
            String usuarioOwner = traficoOriginal[0].OwnerId;
            List<User> lstUsuario = [SELECT Id,MobilePhone FROM User WHERE Id =:usuarioOwner];
            leadId = traficoOriginal[0].Id;
            //str = traficoOriginal[0].Modelo_De_Inter_s1__c.substringBefore(' ').trim();
            marca = traficoOriginal[0].RecordType__c;
            primerNombre = traficoOriginal[0].FirstName;
            ultimoNombre = traficoOriginal[0].LastName;
            familia = traficoOriginal[0].Vehiculo_cotizacion__c;
            documento = traficoOriginal[0].DocumentId__c;
            modeloCot = traficoOriginal[0].Modelo_cotizacion__c;
            cuotaCot = String.valueof(traficoOriginal[0].Cuota_mensual_cotizacion__c.format());
            primaCot = String.valueof(traficoOriginal[0].Prima_cotizacion__c.format());
            precioCot = String.valueof(traficoOriginal[0].Precio_cotizacion__c.format());
            ownerFirstame = traficoOriginal[0].Owner.FirstName;
            ownerLastname = traficoOriginal[0].Owner.LastName;
            cellPhone = lstUsuario[0].MobilePhone;
            emailPhone = traficoOriginal[0].Owner.Email;
            destinatario = traficoOriginal[0].Email;
        }
        System.debug(' ** id lead ** ' + idTrafico);
  
        String cuerpoEmail = '';
        if( marca == 'BMW' ){
            cuerpoEmail = '<table style="background-color:white;font-family:Tahoma;border-collapse: collapse;width:600px;font-family:Tahoma;border: 1px solid;border-color: white;margin:0 auto;" cellpadding="0" cellspacing="0" >';
        }else if(marca == 'MINI'){
            cuerpoEmail = '<table style="background-color:white;font-family:Georgia;border-collapse: collapse;width:600px;font-family:Georgia;border: 1px solid;border-color: white;margin:0 auto;" cellpadding="0" cellspacing="0" >';
        }
        cuerpoEmail += '<tr>'
           + ' <td align="center">'
            + '  <table style="width:600px;background-color:white;border: 1px solid;border-color:#E5E6E6;" cellpadding="0" cellspacing="0" >'
           + '     <tr>'
              + '    <td style="padding:10px; ">&nbsp;</td>'
             + '   </tr>'
             + '   <tr>'
                 + ' <td>'
                  + '  <table  style="background-color:#E5E6E6;width:100%;">'
                   + '   <tr>'
                  + '       <td style="text-align:left;background-color:#E5E6E6; padding: 25px;">'
                    + '         <p style="font-weight: bold;font-size:20px;">Sr. (a) '+primerNombre+' '+ultimoNombre+'</p>'
                    + '         <p Style="font-size:20px;"> ';
                    if( marca == 'BMW' ){
                        cuerpoEmail +=  'Gracias por su interés en BMW. A continuación encontrará nuestras opciones para usted.</p>';
                    }else if(marca == 'MINI'){
                        cuerpoEmail +=  'Gracias por su interés en MINI. A continuación encontrará nuestras opciones para usted.</p>';
                    }else{

                    }
                    
                    
                    
                    cuerpoEmail +='     </td>'
                + '      </tr>'
            + '        </table>'
           + '       </td>'
          + '      </tr>'
           + '     <tr>'
            + '      <td style="padding:5px;">&nbsp;</td>'
            + '    </tr>'
            + '    <tr>'
               + '     <td style = "">'
              + '        <table style="width:100%;background-color:#white;height:30px;" cellpadding="0" cellspacing="0"  >'
               + '         <tr>'
              + '              <td style="padding-left: 20px;font-size:20px;">'
                + '            <span> '+familia+'</span>'
                + '            </td>'
                + '			<td style="padding-left: 20px;font-size:20px;">'
               + '             <td style="text-align:center;"><img alt="logo" src="https://redmotors.file.force.com/servlet/servlet.ImageServer?id='+documento+'&oid=00D0P000000Dvkz" style="max-width: 276.207px; height:150px;" title="logo" /></td>'
                + '            </td>'
                + '        </tr>'
                  + '    </table>'
              + '      </td>'
             + '   </tr>'
                + ' <tr>'
              + '    <td style="padding:5px;">&nbsp;</td>'
             + '   </tr>'
            + '      <tr>'
             + '       <td style = "">'
               + '       <table style="width:100%;background-color:#white;height:30px;" cellpadding="0" cellspacing="0"  >'
               + '         <tr>'
                  + '          <td style="padding-left: 20px;font-size:20px;">'
                 + '           <span>'
        + ' En el archivo adjunto a este email podrá encontrar la cotización y opciones de financiamiento del modelo elegido.</span>'
                    + '        </td>'
                   + '     </tr>'
                     + '    <tr>'
                     + '   <td>&nbsp;</td>'
                  + '      </tr>                '
                 + '     </table>'
               + '    </td>'
               + '   </tr>'
              + '    <tr><td style="padding:5px; ">&nbsp;</td></tr>'
            + '	<tr>'
             + '     	<td style="padding-top: 20px;">'
               + '        <span style="padding-left: 20px;  font-size: 20px;font-weight: bold;font-size:16px;">'+modeloCot+'</span>'
                + '	</td>'
           + '     </tr>'
            + '    <tr>'
             + '     <td>'
             + '     	<table style="width:600px;padding-left: 20px;padding-right: 20px;">'
               + '       <tr>'
              + '          <td style="padding-left: 15px;background:#E5E6E6;width:33%;height:30px;">Cuota mensual:</td>'
               + '         <td style="padding-left: 15px;background:#E5E6E6;width:33%;height:30px;">Monto de prima:</td>'
                + '        <td style="padding-left: 15px;background:#E5E6E6;width:33%;height:30px;">Precio:</td>'
                 + '     </tr>'
                 + '     <tr>'
                 + '     	<td style="padding-left: 15px;background:#E5E6E6;width:33%;height:30px;font-weight: bold;"> $' +cuotaCot+'</td>'
                 + '       <td style="padding-left: 15px;background:#E5E6E6;width:33%;height:30px;font-weight: bold;"> $'+primaCot+'</td>'
                 + '       <td style="padding-left: 15px;background:#E5E6E6;width:33%;height:30px;font-weight: bold;"> $'+precioCot+'</td>'
                 + '     </tr>'
                 + '   </table>'
                + '  </td>'
              + '  </tr>'
              + '  <tr><td style="padding:5px; ">&nbsp;</td></tr>'
            + '    <tr >'
             + '     <td style="padding-top: 20px;">'
                 + '   <table style="width:100%;background-color:white;height:30px;"  >'
                + '      <tr>'
               + '         <td>'
               + '           <span style="padding-left: 20px; font-size: 20px;"> En caso de dudas contacte a su asesor: </span>'
               + '         </td>'
                 + '     </tr>'
                + '    </table>'
              + '    </td>'
             + '   </tr>'
               + ' <tr><td style="padding:5px; ">&nbsp;</td></tr>'
              + '  <tr>'
              + '    <td style="">'
              + '      <table >'
               + '       <tr>'
               + '         <td style="color:#6C6C6C;padding-left: 20px;  font-size: 16px; line-height: 27px;">'
               + '           <span style="font-size: 18px;font-weight: bold;"> '+ownerFirstame+' '+ownerLastname+' </span><br>'
               + '             <span style="font-size: 18px;"> Iniciar WhatsApp: <a style="color:#3379a1;" href="https://api.whatsapp.com/send?phone='+cellPhone+'">'+cellPhone+'</a>  </span><br>'
               + '             <span style="font-size: 18px;"> Enviar email: <a style="color:#3379a1;" href="mailto:'+emailPhone+'">'+emailPhone+'</a>  </span><br>'
                + '        </td>'
               + '       </tr>              '
               + '     </table>            '
              + '    </td>'
             + '   </tr>';


             if( marca == 'BMW' ){
                cuerpoEmail += '    <tr>'
                    + '       <td>'
                    + '          <br>'
                    + '          <img alt="logo" src="https://redmotors.file.force.com/servlet/servlet.ImageServer?id=015PH0000004RMh&oid=00D0P000000Dvkz&lastMod=1665782772000" style="max-width: 276.207px; height:100px;" title="logo" />'
                    + '           </td>'
                    + '      </tr>'
                    + '    <tr>                '
                        + '   <td style = "padding:20px;">'
                    + '    <table style="padding:20px;width:100%;background-color:white;text-align:center;border-top: 2px solid; border-color: #E5E6E6;"  >'
                        + '     <tr>'
                        + '       <td style="text-align:left;">'
                        + '          <img alt="logo" src="https://redmotors.file.force.com/servlet/servlet.ImageServer?id=015PH0000004Qgg&oid=00D0P000000Dvkz&lastMod=1665782772000" style="max-width: 276.207px; height:30px;" title="logo" /> '                  
                        + '       </td>'
                        + '       <td style="text-align:left;">'
                        + '         Visítenos en:'
                        + '       </td>'
                        + '      <td style="padding-right: 10px;padding-left: 30px;">'
                        + '         <a style="color:#3379a1;" href="https://www.waze.com/es-419/live-map/directions/bmw-uruca-uruca,-san-jose?utm_campaign=default&utm_source=waze_website&utm_medium=lm_share_location&to=place.w.180813923.1808204771.2247866">Uruca</a>'                   
                        + '     </td>'
                        + '      <td style="padding-right: 10px;padding-left: 30px;">'
                            + '     <a style="color:#3379a1;" href="https://www.waze.com/es-419/live-map/directions/cr/san-jose/san-rafael/bmw-bavarian-motors?navigate=yes&utm_campaign=default&utm_source=waze_website&utm_medium=lm_share_location&to=place.ChIJ2XnMrXn8oI8RceU0yvZt5cs">Escazú</a>'
                        + '    </td>'
                            + '   <td style="padding-right: 10px;padding-left: 30px;">'
                            + '    <a style="color:#3379a1;" href="https://www.waze.com/es-419/live-map/directions/bmw-pinares-pinares,-sanchez,-curridabat?utm_campaign=default&utm_source=waze_website&utm_medium=lm_share_location&to=place.w.180879459.1808663519.730125">Pinares</a>'
                            + '   </td>'
                        + '   </tr>'
                        + '  </table>'
                        + ' </td>'
                        + '   </tr>'
                + '  </table>'
                + ' </td>'
                + '  </tr>'
                + '</table>';
            }else if(marca == 'MINI'){
                cuerpoEmail +=  '<tr>'
                +'           <td style="padding-left:20px;">'
                +'               <br>'
                   +'              <img alt="logo" src="https://redmotors.file.force.com/servlet/servlet.ImageServer?id=0150P000004zrEB&oid=00D0P000000Dvkz&lastMod=1665782772000" style="max-width: 276.207px; height:100px;" title="logo" />'
                   +'              </td>'
               +'              </tr>'
               +'            <tr>          '   
               +'            <td style = "padding:20px;">'
                  +'         <table style="padding:20px;width:100%;background-color:white;text-align:center;border-top: 2px solid; border-color: #E5E6E6;"  >'
                             +'<tr>'
               +'                <td style="text-align:left;">'
                  +'                 <img alt="logo" src="https://redmotors.file.force.com/servlet/servlet.ImageServer?id=015PH0000004Qgg&oid=00D0P000000Dvkz&lastMod=1665782772000" style="max-width: 276.207px; height:30px;" title="logo" /> '                 
                               +'</td>'
               +'                <td style="text-align:left;">'
                  +'                 Visítenos en:'
                     +'          </td>'
                        +'       <td style="padding-right: 200px;padding-left: 30px;">'
                    +'        <a style="color:#3379a1;" href="https://www.waze.com/es-419/live-map/directions/bmw-uruca-uruca,-san-jose?utm_campaign=default&utm_source=waze_website&utm_medium=lm_share_location&to=place.w.180813923.1808204771.2247866">MINI URUCA</a>'                   
                    +'           </td>                '
                       +'      </tr>'
               +'            </table>'
                  +'       </td>'
                     +'      </tr>'
               +'      </table>'
               +'    </td>'
               +'  </tr> '
               +' </table> ';
            }else{

            }

            if(destinatario != ''){
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
                OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'bmwcr@redmotorscr.com'];
                
                if( marca == 'BMW' ){
                    owea = [select Id from OrgWideEmailAddress where Address = 'bmwcr@redmotorscr.com'];
                }else if(marca == 'MINI'){
                    owea = [select Id from OrgWideEmailAddress where Address = 'minicr@redmotorscr.com'];
                }
                
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                if ( owea.size() > 0 ) {
                    email.setOrgWideEmailAddressId(owea.get(0).Id);
                }

                PageReference pdf = new PageReference('');
                // Reference the attachment page and pass in the quote ID
                if( marca == 'BMW' ){
                    pdf =  Page.cT_newTraficoWebPage;
                }else if(marca == 'MINI'){
                    pdf =  Page.cT_MiniTraficoWebPage;
                }
                //PageReference pdf =  Page.cT_newTraficoWebPage;


                pdf.getParameters().put('id',(String)leadId); 
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
                efa.setFileName('Cotización.pdf');
                efa.setBody(b);
                
                  
        
                String addresses;
                addresses = destinatario;

        
                String[] toAddresses = addresses.split(':', 0);
        
                // Sets the paramaters of the email

                if( marca == 'BMW' ){
                    email.setSubject('Cotización BMW Costa Rica');
                }else if(marca == 'MINI'){
                    email.setSubject('Cotización MINI Costa Rica');
                }else{

                }

                
                email.setToAddresses( toAddresses );
                email.setHtmlBody(cuerpoEmail);
        
                email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
        
                // Sends the email
                Messaging.SendEmailResult [] r = 
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});   

                }
            

    }
}