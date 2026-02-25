/**
 * @description       : 
 * @author            : luis.sandoval.rocha@gmail.com
 * @group             : 
 * @last modified on  : 02-11-2023
 * @last modified by  : luis.sandoval.rocha@gmail.com
**/
public class UsadosEnviarNotiAprobacion {
    

    
    @InvocableMethod(label='Send aprrov request usados' description='Returns the list of opp' category='Opportunity')
    public static void enviarNotiUsados(List<String> IdOppsUsados){   
        Set<String> vehicleIds = new Set<String>();     
        List<Opportunity> oppList = [
                                    SELECT Id,Aprobador__c,Owner.Email,DirectorVentas__r.Email,GerenteSucursal__r.Email,JefeSucursal__r.Email,
                                    NombreDestinoDescuento__c,Account.Name,Owner.Name,Name,ModelosProductos__c,MontodeExtras__c,MontodeRegalias__c,ValorTotal__c,Importetotaldelnegocio__c,
                                    Recibe_usado__c,Placa_usado__c , Detalle_regalias__c,Detalle_de_Extras__c,MontoSoporteTotal__c,Descuento_Total_Moneda__c,
                                    Descuento_Total__c,Margen_Total__c, SumaCostoTotal__c,SumaListaPrecio__c,CurrencyIsoCode,Total__c,
                                    (
                                        SELECT Id,PrecioFacturacion2__c,Opportunity_Line_Item__c,Montodescuento__c,Product2.Name,ListPrice,Product2Id,Product2.Detalle_de_Polarizado__c,Product2.Polarizado__c,
                                        Product2.vin__c,Product2.esVehiculo__c,Product2.es_Vehiculo_usado__c,Regal_a__c,Montoderegalias__c,Montodeextras__c,Soporte__c,Product2.esExtra__c,Costo_Final__c,TotalPrice,Costo_Fijo__c,esRegalia__c,esExtra__c,
                                        Oportunidad_Producto_Interes__r.Precio_Unitario__c,Oportunidad_Producto_Interes__r.Costo_Fijo__c,Costo_Fijo_Softland__c,VN_Precio_Venta_Fantasia_FX__c,VN_Descuento_Aplicado_Monto_FX__c,VN_Descuento_Aplicado_Porcentaje_FX__c
                                        FROM OpportunityLineItems
                                    ),
                                    (
                                        SELECT Id,ReciboJefeUsados__c,Serecibevehiculo__c,MontoSoporte__c,Placa__c,ValorReciboCliente__c
                                        FROM ReciboUsadosOportunidad__r WHERE Serecibevehiculo__c = true
                                    ),
                                    (
                                        SELECT Id,SumRegaliasQuote__c
                                        FROM Quotes
                                        WHERE IsSyncing__c = true
                                    )
                                    FROM Opportunity
                                    WHERE Id IN :IdOppsUsados];
        
        
        
        Set<Id> productIds = new Set<Id>();
        String emailto;
        for (Opportunity opp : oppList) {
            if(opp.Aprobador__c == 'Director'){ emailto = opp.DirectorVentas__r.Email;
            }
            if(opp.Aprobador__c == 'Gerente'){ emailto = opp.GerenteSucursal__r.Email;
            }
            if(opp.Aprobador__c == 'Jefe'){ emailto = opp.JefeSucursal__r.Email;
            }
            if(opp.Aprobador__c == 'Vendedor'){  emailto = opp.Owner.Email;
            }
            for (OpportunityLineItem oli : opp.OpportunityLineItems) { productIds.add(oli.Product2Id);   

                if (oli.Product2.es_Vehiculo_usado__c) { vehicleIds.add(oli.Product2Id);
                }
            }            
        }
    System.debug('emailto: '+emailto);
        if(test.isRunningTest()){
            emailto = 'prueba@gmail.com';
        }
        
        List<Product2> vehicleList = new List<Product2>();
        if (vehicleIds.size()>0) {
            vehicleList = new List<Product2>([
                SELECT Id,vin__c,
                (
                    SELECT Id, Name, Monto_Dolar__c, Monto_local__c, Product__c, Rubro__c, CurrencyIsoCode
                    FROM Detalles_Costo_Productos__r
                )
                FROM Product2 
                WHERE Id IN :vehicleIds]);            
        }                                                            
        
        List<Detalle_Costo_Producto__c> lstCosotosProductoExt = new List<Detalle_Costo_Producto__c> ();
         String codigoDelProducto = '';
        // List<Quote> lstQuote = [SELECT id FROM Quote WHERE OpportunityId =: IdOpp];
        // System.debug(lstQuote);
         Double sumaOtrosGastos = 0;
         Double costoTotal = 0;
         Double precioTotal = 0;
         Double sumaRegalias = 0;
         Double sumaExtrasPrecio = 0;
         Double sumaExtrasCosto = 0;
         Double sumaSoporte = 0;
         Double costoUsado = 0;
         Double precioQuote = 0;
             Double porcenQuote = 0;

         String placaUsado = '';
         Boolean Serecibevehiculo ;

         Double soporteUsado = 0;
        // String tablaExtras = '<table style="border-collapse: collapse;text-align: center;" width="86%">'+
        // '<tbody style="font-family: Arial, Helvetica, sans-serif;color:#333333;width:550px">'+
        // '<tr>'+
        // '<td colspan="6" style="margin:left:20%;text-align: center; font-size: 12pt; font-family: Arial; background-color: transparent; font-weight: 400; font-style: normal; font-variant: normal; text-decoration: none; vertical-align: baseline; white-space: pre-wrap;"><p style="text-align: center;"><span style="font-weight: 400;text-align: center;">Tabla de otros gastos</span></p>'+
        // '</td></tr>'+
        // '<tr><th>Rubro</th><th>Monto Dolar</th><th>Monto Local</th></tr>';

        List<Messaging.SingleEmailMessage> singleEmailMessageList = new list<Messaging.SingleEmailMessage> ();
        for(Opportunity opp : oppList){

            Messaging.SingleEmailMessage singleEmailMessage = new Messaging.SingleEmailMessage();  
            singleEmailMessage.setHtmlBody(createTestEmailHTML(opp,vehicleList));
            singleEmailMessage.setSubject(String.format('Solicitud de Descuento para {0}.', new List<String>{opp.Account.Name}));
            singleEmailMessage.setToAddresses(new String[]{emailto,'admin@portalnetcr.com'});
            singleEmailMessageList.add(singleEmailMessage);
        }

     Messaging.SendEmailResult[] result = Messaging.sendEmail(singleEmailMessageList);                    
    }
    
    public static String createTestEmailHTML(Opportunity opp,List<Product2> vehicleList){
        List<String> currencyFormat = new String[]{'0','number','###,###,##0.00'};

        Decimal oppMargen = 0;
        Decimal totalPrecioVentaFantasia = 0;
        Decimal totalCostoFijoFantasia = 0;
        Decimal totalCostoFijoSoftland = 0;
        Decimal totalCostoFijoSoftland2 = 0;

        Decimal totalPrecioVenta = 0;
        Decimal TotalRegaliasQ = 0;
        

        Set<Id> productIds = new Set<Id>();

        Decimal totalFacturacion = 0;

        for (OpportunityLineItem oli : opp.OpportunityLineItems) {
            productIds.add(oli.Product2Id);   
            if (oli.Product2.es_Vehiculo_usado__c) {
                totalFacturacion += oli.TotalPrice;
                totalPrecioVentaFantasia += oli.Oportunidad_Producto_Interes__r != null && oli.Oportunidad_Producto_Interes__r.Precio_Unitario__c != null ? oli.Oportunidad_Producto_Interes__r.Precio_Unitario__c : 0;
                totalCostoFijoFantasia += oli.Oportunidad_Producto_Interes__r != null && oli.Oportunidad_Producto_Interes__r.Costo_Fijo__c != null ? oli.Oportunidad_Producto_Interes__r.Costo_Fijo__c : 0;
                totalCostoFijoSoftland += oli.Costo_Fijo_Softland__c != null ? oli.Costo_Fijo_Softland__c : 0;
            }
            if (oli.Product2.es_Vehiculo_usado__c || oli.esExtra__c) {
                totalPrecioVenta += oli.TotalPrice;
            }
        }            
       
        Decimal stepOne = totalPrecioVentaFantasia + opp.MontodeExtras__c;
        Decimal stepTwo = totalCostoFijoFantasia + opp.MontodeRegalias__c + opp.MontoSoporteTotal__c;

        if (!Test.isRunningTest()) {   
            if (stepOne > 0) {                
                oppMargen = ((totalPrecioVentaFantasia - stepTwo) / stepOne)*100;        
            }         
            oppMargen = Math.round(oppMargen * 100) / 100.0;        
        }
        oppMargen = Math.round(oppMargen * 100) / 100.0;     
        
        //System.debug(totalPrecioVentaFantasia);
        //System.debug(totalCostoFijoFantasia);
        //System.debug(margenRealOpp);
        //System.debug(oppMargen);
        //System.debug(totalCostoFijoSoftland2);
        //System.debug(totalCostoFijoSoftland);
        String html = ''
        +'<!DOCTYPE html>'
        +'<html>'
        +'<head>'
        +'  <meta charset="utf-8">'
        +'  <meta name="viewport" content="width=device-width, initial-scale=1">'
        +'  <title>Solicitud de descuento</title>'
        +'  <style type="text/css">'
        +'    .container{'
        +'      padding:10px;'
        +'      width: 70%;'
        +'      margin: 0 auto;'
        +'    }'
        +''
        +'    body{'
        +'      padding: 2px;'
        +'    }'
        +''
        +'    * {'
        +'      font-family:Arial, Helvetica, sans-serif; '
        +'    }'
        +''
        +'    .title{'
        +'      text-align: center;'
        +'      background-color:#F4F4F4;'
        +'      padding: 25px;'
        +'      font-size: 20px;'
        +'      font-weight: bold;'
        +'    }'
        +'    th{'
        +'      padding:7px 5px;'
        +'      text-align: left;'
        +'      color: #8a8a8a;'   
        +'    }'
        +'    th strong{'
        +'      font-size: 14px;'
        +'      color: #8a8a8a;'
        +'    }'
        +'    td strong {'
        +'      padding:10px 5px;'
        +'      font-size: 14px;'
        +'      color: #8a8a8a;'
        +'    }    '
        +'    td {'
        +'      padding:10px 5px;'
        +'      font-size: 14px;'
        +'      color: #8a8a8a;'
        +'    }'
        +'  </style>'
        +'</head>'
        +'<body>'
        +'    <div class="container">'
        +'      '
        +'      <p class="title">'
        +'        Solicitud descuento para la oportunidad.'
        +'      </p>'
        +'      '
        +'      <p style="text-align: left;">'
        +'        Estimad@: ' +opp.NombreDestinoDescuento__c+ ''
        +'      </p>'
        +''
        +'      <p style="text-align: left;">'
        +'      El asesor '+opp.Owner.Name+', ha solicitado un descuento para la oportunidad '+opp.Name+'.'
        +'      </p> '
        +'      '
        +'      <p style="text-align: left;">'
        +'        Detalles de negocio con precios de lista:'
        +'      </p>';

        Integer conta = 1;
                   
        for (OpportunityLineItem oli : opp.OpportunityLineItems ) {
            if(oli.Montodeextras__c == null){
                oli.Montodeextras__c = 0.0;
            }
            if(oli.Montoderegalias__c == null){
                oli.Montoderegalias__c = 0.0;
            }
            if (oli.Product2.es_Vehiculo_usado__c) {           
                Decimal priceList = +oli.Oportunidad_Producto_Interes__r != null && oli.Oportunidad_Producto_Interes__r.Precio_Unitario__c != null ? oli.Oportunidad_Producto_Interes__r.Precio_Unitario__c : 0;
                Decimal discountAmount = priceList - oli.TotalPrice ;                                                 
                Decimal discountPercent = oli.ListPrice !=null && oli.ListPrice > 0 ? discountAmount / oli.ListPrice : 0;        
            html += '<table style="border-collapse: collapse; width: 100%; height: 108px; border-color: white;" border="1">'
                +'   <tbody>'
                +'      <tr style="">'
                +'         <th style="width: 50%;  background-color: #e1e1e1;" colspan="2"><strong>Producto '+conta+':</strong></th>'
                +'      </tr>'
                +'      <tr style=" background-color: #fbfbfb;">'
                +'         <td style="width: 50%; "><strong>VIN:</strong></td>'
                +'         <td style="width: 50%; ">'+ oli.Product2.vin__c +'</td>'
                +'      </tr>'
                +'      <tr style=" background-color: #faf8f7;">'
                +'         <td style="width: 50%; "><strong>Nombre del producto:</strong></td>'
                +'         <td style="width: 50%; ">'+ oli.Product2.Name +'</td>'
                +'      </tr>'
                +'      <tr style=" background-color: #fbfbfb;">'
                +'         <td style="width: 50%; "><strong>Precio de lista:</strong></td>'
                +'         <td style="width: 50%; ">'+ String.format(oli.VN_Precio_Venta_Fantasia_FX__c.format(), currencyFormat) + ' '+ opp.CurrencyIsoCode +'</td>'
                +'      </tr>'
                +'      <tr style=" background-color: #faf8f7;">'
                +'         <td style="width: 50%; "><strong>Precio de facturaci&oacute;n:</strong></td>'
                +'         <td style="width: 50%; ">'+  String.format(oli.TotalPrice.format(), currencyFormat) + ' '+ opp.CurrencyIsoCode +'</td>'
                +'      </tr>'
                +'      <tr style=" background-color: #fbfbfb;">'
                +'         <td style="width: 50%; "><strong>Descuento aplicado:</strong></td>'
                +'         <td style="width: 50%; height: 18px;">'+ String.format(oli.VN_Descuento_Aplicado_Monto_FX__c.format(), currencyFormat) + ' '+ opp.CurrencyIsoCode +' </td>'
                +'      </tr>'
                +'      <tr style=" background-color: #faf8f7;">'
                +'         <td style="width: 50%; "><strong>Porcentaje descuento:</strong></td>'
                +'         <td style="width: 50%; height: 18px;">'+ oli.VN_Descuento_Aplicado_Porcentaje_FX__c  +' %</td>'
                +'      </tr>'                
                +'   </tbody>'
                +'</table>'
                +'<br/>'
                +'<table style="border-collapse: collapse; width: 100%; border-color: white;" border="1">'
                +'   <tbody>'
                +'      <tr style="background-color: #ebe7e7;color: #8a8a8a;">'
                +'         <th style="width: 50%; text-align: center;" colspan="2"><strong>Detalle de extras:</strong></th>'
                +'         <th style="width: 50%;text-align: center;" colspan="2"><strong>Detalle de regalías:</strong></th>         '
                +'      </tr>'
                +'      <tr style=" background-color: #E1E1E1;text-align: center;color: #8a8a8a;">'
                +'         <td style="width: 25%;font-weight: bold;">Nombre:</td>'
                +'         <td style="width: 25%;font-weight: bold;">Precio:</td>'
                +'         <td style="width: 25%;font-weight: bold;">Nombre:</td>'
                +'         <td style="width: 25%;font-weight: bold;">Precio:</td>'
                +'      </tr>'
                +'      <tr style=" background-color: white; text-align: center;">'
                        +'<td colspan="2" style="vertical-align:top;"  width="50%" >'+getExtras(oli,opp,'extra')+'</td>'
                        +'<td colspan="2"  style="vertical-align:top;"  width="50%" >'+getExtras(oli,opp,'regalia')+'</td>'
                +'      </tr>'
                +'      <tr style=" background-color: white;font-weight: bold;">'
                +'         <td style="text-align:right;">Total extras:</td>'
                +'          <td  style="text-align:center;">'+String.format(oli.Montodeextras__c.format(), currencyFormat)+' USD</td>'
                +'          <td style="text-align:right;">Total regalias:</td>'
                +'          <td  style="text-align:center;">'+String.format(oli.Montoderegalias__c.format(), currencyFormat)+' USD</td>'
                +'      </tr>      '
                +'   </tbody>'
                +'</table>';
                conta ++;
            }                                                                                    
        }

        html +=''
        +'<br/>'
        +''
        +'<table style="border-collapse: collapse; width: 100%; border-color: white;" border="1">'
        +'   <tbody>'
        +'      <tr style="">'
        +'         <th style="width: 100%;  background-color: #e1e1e1;" colspan="6"><strong>Recibe usado:</strong></th>'
        +'      </tr>';
    for (Product2 vehicle : vehicleList) {
            for (Detalle_Costo_Producto__c dcp : vehicle.Detalles_Costo_Productos__r) {
                totalCostoFijoSoftland2 += dcp.Monto_Dolar__c != null ? dcp.Monto_Dolar__c : 0;
          }
        }
        Map <Id,Decimal> productoCostoFijo = new Map<Id,Decimal>();
        Decimal costoProducto = 0;
        //Recorre lista de productos
        for (Product2 vehicle : vehicleList) {
            //recorre lista detalle de costo para armar mapa
             for (Detalle_Costo_Producto__c dcp : vehicle.Detalles_Costo_Productos__r) {
                 //agrega el valor de cada precio al costo de producto
                 if(dcp.Product__c == vehicle.Id){
                	costoProducto += dcp.Monto_Dolar__c != null ? dcp.Monto_Dolar__c : 0;
                 }
            }
            //ingresa el valor al mapa
            productoCostoFijo.put(vehicle.Id,costoProducto);
            costoProducto = 0;
        }
        
        for (Quote sumReg : opp.Quotes){
            TotalRegaliasQ += sumReg.SumRegaliasQuote__c; 
              
        }
         Decimal totalFacturacionMasExtras = totalFacturacion + (opp.MontodeExtras__c != null ? opp.MontodeExtras__c : 0);
         Decimal margenRealOpp =  totalFacturacionMasExtras - (totalCostoFijoSoftland2 + TotalRegaliasQ);
         if (!Test.isRunningTest()) {  
            if (totalFacturacionMasExtras>0) {                
                margenRealOpp = (margenRealOpp/totalFacturacionMasExtras)*100;
            }
        }
        //System.debug(totalFacturacionMasExtras);
        //System.debug(costoProducto);
        //System.debug(margenRealOpp);
        //System.debug(productoCostoFijo);
        //System.debug(totalCostoFijoSoftland2);
        //System.debug(totalCostoFijoSoftland);
        
        for (ReciboUsado__c reciboUsado : opp.ReciboUsadosOportunidad__r) {
            String recieved = reciboUsado.Serecibevehiculo__c ? 'Si' : 'No';
html += '      <tr style=" background-color: #fbfbfb; text-align: center;">'
        +'         <td style="width: 20%;font-weight: bold;">Recibe usado:</td>'
        +'         <td style="width: 5%;">'+recieved+'</td>'
        +'         <td style="width: 30%;font-weight: bold;">Placa de vehículo usado:</td>'
        +'         <td style="width: 10%;">' + reciboUsado.Placa__c + '</td>'
        +'         <td style="width: 25%;font-weight: bold;">Monto total soporte:</td>'
        +'         <td style="width: 10%;">'+ String.format(reciboUsado.MontoSoporte__c.format(), currencyFormat)  +' USD</td>'
        +'      </tr>';
        }
html +='   </tbody>'
        +'</table>'
        +''
        +'<br/>';

html +='<table style="border-collapse: collapse; width: 100%; " border="0">'
    +'      <tr style="background-color: #E1E1E1;">'
    +'         <th style="width: 100%;  background-color: #e1e1e1;" colspan ="4"><strong>Margen aproximado de ganancia:</strong></th>'
    +'      </tr>'
    +'<tr aria-selected="false"  style="background:#FBFBFB;">'
        +'<td style="text-align:left;border-right:1px solid #ffffff;padding:10px 5px;border-top:1px solid #ffffff;width:25%;">'
            +'<span style="text-align:left;font-weight:bold">Total de facturación: </span>                '
        +'</td>'
        +'<td style="text-align:left;border-right:1px solid #ffffff;padding:10px 5px;border-top:1px solid #ffffff;width:25%;">'
            +'<span style="text-align:left;">'+  String.format(totalPrecioVenta.setScale(2).format(), currencyFormat) +' '+ opp.CurrencyIsoCode + '</span>                '
        +'</td>'
        +'<td style="text-align:left;border-right:1px solid #ffffff;padding:10px 5px;border-top:1px solid #ffffff;width:25%;">'
            +'<span style="text-align:left;font-weight:bold"> Margen de la oportunidad:</span>'
        +'</td>'
        +'<td style="text-align:left;border-right:1px solid #ffffff;padding:10px 5px;border-top:1px solid #ffffff;width:25%;" >'
        +'  <span style="text-align:left;"> '+oppMargen+ ' %</span>'
        +'</td>'
    +'</tr>'
+'</table>  '
        
        +'<h3 style="color:red;">Precios y costos se encuentran en proceso de costeo y definición (nota aclaratoria negocio)</h3>'
        +'<table style="border-collapse: collapse; width: 100%; " border="0">'
        +'    <tbody>'
        +'       <tr style="">'
        +'          <td style="width: 50%; background-color: #d9d9d9;font-weight:bold;" colspan="2"><span ><strong>Margen real Softland:</strong></span></td>'
        +'       </tr>';
                 conta = 1;
                 for (Product2 vehicle : vehicleList) {
                     html +=''
        +'       <tr style="background-color: #ebe7e7; border: none;font-size: medium;color: #8a8a8a;font-weight: bold;">'
        +'          <td style="width: 100%;font-weight:bold;" colspan="2"><span ><strong>Producto '+conta+': '+vehicle.vin__c+'</strong></span></td>'
        +'       </tr>'
        +'       <tr style="">'
        +'          <td style="width: 50%;"><span style="font-weight: 400;font-weight:bold;">Costo real producto en Softland:</span></td>'
        +'          <td style="width: 50%;">'+String.format(productoCostoFijo.get(vehicle.Id).setScale(2).format(), currencyFormat) + ' '+ opp.CurrencyIsoCode +'</td>'
        +'       </tr>';
            conta++;
            }html +=''
        +'      <tr style="background-color: #E1E1E1;">'
        +'         <th style="width: 100%;  background-color: #e1e1e1;font-weight:bold;" colspan ="2"><strong>Rubros costeados:</strong></th>'
        +'      </tr>'
        +' </table>';

        html +='<br/><table style="border-collapse: collapse; width: 100%;  border-color: white;" border="1">'
        +'    <tbody>';

        conta = 1;
        for (Product2 vehicle : vehicleList) {
            html +=''
            +'       <tr style="background-color: #ebe7e7; border: none;font-size: medium;color: #8a8a8a;font-weight: bold;">'
            +'          <td style="width: 100%;font-weight:bold;" colspan="2"><span ><strong>Producto '+conta+': '+vehicle.vin__c+'</strong></span></td>'
            +'       </tr>'

            +'       <tr style="background-color: #d9d9d9; border: none;font-size: medium;color: #8a8a8a;font-weight: bold;text-align:center;">'
            +'          <td style="width: 50%; font-weight:bold;">Nombre rubro:</td>'
            +'          <td style="width: 50%; font-weight:bold;">Monto:</td>'
            +'       </tr>';

            String bgColor = 'FBFBFB';
            for (Detalle_Costo_Producto__c dcp : vehicle.Detalles_Costo_Productos__r) {
                Decimal montoDolar = (dcp.Monto_Dolar__c != null) ? dcp.Monto_Dolar__c : 0;
                html +=''
                +'       <tr style="text-align:center;background-color:#'+bgColor+';">'
                +'          <td style="width: 50%;">'+dcp.Rubro__c+'</td>'
                +'          <td style="width: 50%;">'+ String.format(montoDolar.setScale(2).format(), currencyFormat) + ' '+ opp.CurrencyIsoCode +'</td>'                
                +'       </tr>';  
                if (bgColor == 'FBFBFB') {
                    bgColor = 'FAF8F7';
                }else{
                    bgColor = 'FBFBFB';
                }
            }
            conta++;
    }
        html +='</table>';        


        html +='<br/><table style="border-collapse: collapse; width: 100%; " border="0">'
        +'       <tr style="">'
        +'          <td style="width: 50%;font-weight:bold;">Margen real de la oportunidad:</td>'
        +'          <td style="width: 50%;">'+  margenRealOpp.setScale(2).format() + ' % </td>'
        +'       </tr>'
        +'    </tbody>'
        +' </table>';


        html += '<br/><br/><div style="text-align:center;">'
        +'  Para acceder a tal oportunidad de click en el siguiente link:'
        +'  <a href="https://redmotors.my.salesforce.com/'+opp.Id+'">https://redmotors.my.salesforce.com/'+opp.Id+ '</a>'
        +'</div>'
        +'    '
        +'    </div>'
        +'</body>'
        +'</html>';
        return html;
    }

    private static String getExtras(OpportunityLineItem oli,Opportunity opp,String tipo){
        List<String> currencyFormat = new String[]{'0','number','###,###,##0.00'};
        String html = '<table style="font-family:Arial, Helvetica, sans-serif;" width="100%">';
        String bgColor = 'FBFBFB';
        
        for (OpportunityLineItem oliTmp : opp.OpportunityLineItems) {
            if (
                ((tipo == 'extra' && oliTmp.esExtra__c) || (tipo == 'regalia' && oliTmp.esRegalia__c)) 
                && (oliTmp.Opportunity_Line_Item__c != null && oliTmp.Opportunity_Line_Item__c == oli.Id)) {
                html += ''
                +'<tr style="font-size: medium;background-color:#'+bgColor+';">'
                +'    <td style="padding:7px 5px;" width="50%;border:none;">'
                +'        <span style="text-align:right;font-family:Arial, Helvetica, sans-serif;">'+oliTmp.Product2.Name+'</span>'
                +'    </td>'
                +'    <td style="padding:7px 5px;" width="50%;border:none;">'
                +'        <span style="text-align:left;font-family:Arial, Helvetica, sans-serif;">'
                +'        '+String.format(oliTmp.TotalPrice.format(), currencyFormat)+' USD'
                +'        </span>'
                +'    </td>'            
                +'</tr>';
                if (bgColor == 'FBFBFB') {
                    bgColor = 'FAF8F7';
                }else{
                    bgColor = 'FBFBFB';
                }
            }
        }

        html += '</table>';
        return html;
    }

   


    private static String getHtmlUsedVehicles(Opportunity opp) {
        List<String> currencyFormat = new String[]{'0','number','###,###,##0.00'};
        String html = ''+
                    +'<tr style="background-color: #E1E1E1; border: none;font-size: 10px;text-align:left;color: #8a8a8a;font-weight: bold;">'
                        +'<th  style="padding:7px 5px;font-size:20px;">'
                        +'Recibe usado'
                        +'</th>'
                        +'<th  style="padding:7px 5px;" >'
                        +'</th>'
                        +'<th  style="padding:7px 5px;font-size:20px;" > '
                        +'</th>'
                        +'<th  style="padding:7px 5px;font-size:20px;" >'
                        +'</th>'
                        +'<th  style="padding:7px 5px;font-size:20px;" >'
                        +'</th>                '
                    +'</tr>';

        for (ReciboUsado__c reciboUsado : opp.ReciboUsadosOportunidad__r) {
            String recieved = reciboUsado.Serecibevehiculo__c ? 'Si' : 'No';
            html +='<tr aria-selected="false"  style="color: #333333;font-size: 20px;background:#FBFBFB;">'
                        +'<td style="text-align:left;border-right:1px solid #ffffff;padding:10px 5px;border-top:1px solid #ffffff;width:50%;">'
                            +'<span style="text-align:left;font-weight:bold">Recibe usado: '+ recieved +' </span>               '
                        +'</td>'
                        +'<td style="text-align:left;border-right:1px solid #ffffff;padding:10px 5px;border-top:1px solid #ffffff;width:50%;">'
                            +'<span style="text-align:left;font-weight:bold">Placa de vehículo usado </span>                '
                        +'</td>'
                        +'<td style="text-align:left;border-right:1px solid #ffffff;padding:10px 5px;border-top:1px solid #ffffff;width:50%;">'
                            +'<span style="text-align:left;font-weight:bold"> ' + reciboUsado.Placa__c + ' </span>'
                        +'</td>'
                        +'<td style="text-align:left;border-right:1px solid #ffffff;padding:10px 5px;border-top:1px solid #ffffff;width:50%;">'
                            +'<span style="text-align:left;font-weight:bold"> Monto total soporte </span>'
                        +'</td>'
                        +'<td style="text-align:left;border-right:1px solid #ffffff;padding:10px 5px;border-top:1px solid #ffffff;width:50%;">'
                            +'<span style="text-align:left;font-weight:bold"> '+ String.format(reciboUsado.MontoSoporte__c.format(), currencyFormat)  +' USD</span>'
                        +'</td>'
                  +'</tr> ';
                }
        return html;            
    }
    
}