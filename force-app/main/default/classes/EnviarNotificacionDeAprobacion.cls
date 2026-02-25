public class EnviarNotificacionDeAprobacion {
    public static void enviarNoti(String IdOpp){
        List<Messaging.SingleEmailMessage> mail = new list<Messaging.SingleEmailMessage> ();
        List<Opportunity> oppList = [Select Id, NombreDestinoDescuento__c,Account.Name,Owner.Name,Name,ModelosProductos__c,MontodeExtras__c,
                                     ValorTotal__c,Importetotaldelnegocio__c,
									MontodeRegalias__c,Detalle_regalias__c,Detalle_de_Extras__c,MontoSoporteTotal__c,
									Descuento_Total_Moneda__c,Descuento_Total__c,Margen_Total__c, SumaCostoTotal__c,SumaListaPrecio__c FROM Opportunity where Id =: IdOpp];
        
        
        
        
        
        for(Opportunity op : oppList){
             Messaging.SingleEmailMessage mailpoli = new Messaging.SingleEmailMessage();
                              	string body = CurpoCorreoHTML(op.NombreDestinoDescuento__c,op.Owner.Name,op.Name,
                                         op.ModelosProductos__c,string.valueof(Integer.valueof(op.MontodeExtras__c)),string.valueof(Integer.valueof(op.ValorTotal__c)),
                                         string.valueof(Integer.valueof(op.Importetotaldelnegocio__c)),string.valueof(Integer.valueof(op.MontodeRegalias__c)),string.valueof(op.Detalle_de_Extras__c),
                                         string.valueof(Integer.valueof(op.MontoSoporteTotal__c)),
                                         string.valueof(Integer.valueof(op.Descuento_Total_Moneda__c)),string.valueof(op.Descuento_Total__c),
                                         string.valueof(op.Margen_Total__c),string.valueof(op.Id),string.valueof(Integer.valueof(op.MontodeRegalias__c)),string.valueof(op.Detalle_regalias__c),
                                         string.valueOf(Integer.valueof(op.SumaListaPrecio__c)), string.valueOf(Integer.valueof(op.SumaCostoTotal__c))); 
                                                              
                                                              
            					string asunto = 'Solicitud de Descuento para '+op.Account.Name+'.';
         						mailpoli.setHtmlBody(body);
                                mailpoli.setSubject(asunto);
                                mailpoli.setToAddresses(new String[]{'oaparicio@redmotorscr.com','prosales@redmotorscr.com'});
       							//mailpoli.setCcAddresses(new String[]{'mario@incompany.cr','bricet@incompany.cr'});
                                mail.add(mailpoli);
        }
 			Messaging.SendEmailResult[] result = Messaging.sendEmail(mail);
        						
    }
    
    
    public static string CurpoCorreoHTML(string NombreDestinoDescuento,string OwnerFullNameOpp, string NameOpp,
                                         string ModelosProductos,string MontodeExtras,string ValorTotal,
                                         string Importetotaldelnegocio,string MontodeRegalia, string DetalleDeExtras,
                                         string MontoSoporteTotal,string DescuentoTotalMoneda,string DescuentoTotal,
                                         string MargenTotal,string IdOpp,string MontodeRegalias,string Detalle_regalias,
                                         string ListaPrecio,string CostoOportunidad 
                                        ){
                string salidaBody ='<!DOCTYPE html>'+
                '<html>'+
                '<head>'+
                '<meta charset="UTF-8">'+
                    '<title></title>'+
                '</head>'+
                '<body>'+
                        
                '<p>	Estimado '+NombreDestinoDescuento+':'+
                    '<br/>'+
                'El asesor '+OwnerFullNameOpp+', ha solicitado un descuento para la oportunidad '+NameOpp+'.'+
                '<ul style="list-style: none !important;">'+
                    '<li>Modelo: '+ModelosProductos+'</li>'+
                    '<li>Margen total de la oportunidad: '+MargenTotal+'%</li>'+
                    '<li>Lista de precio: $'+ListaPrecio+'</li>'+
                    '<li>Monto de Extras:  $'+MontodeExtras+'</li>'+
                    '<li>Detalle de Extras: '+DetalleDeExtras+'</li>'+
                    '<li>Costo de la oportunidad: $ '+CostoOportunidad+'</li>'+
                    '<br/>'+
                
                    '<li>Monto de Regalías: $'+MontodeRegalias+'</li>'+
                    '<li>Detalle de Regalías: '+Detalle_regalias+'</li>'+
                    '<li>Monto de Soporte Total: $ '+MontoSoporteTotal+'</li>'+
                    '<br/>'+
                
                    '<li>Descuento Aplicado $: '+DescuentoTotalMoneda+'</li>'+
                    '<li>Descuento %: '+DescuentoTotal+'</li>'+
                    '<br/>'+
                
                    '<li>Precio de Facturación: $ '+Importetotaldelnegocio+'</li>'+
                '</ul>'+
                
                'Para acceder a tal oportunidad de click en el siguiente link: https://redmotors.my.salesforce.com/'+IdOpp+'</p>'+
                '</body>'+
                '</html>';
            
        
        return salidaBody;
    }
    
}