public class OppFinanciamientoCtrl {
    private id documentID;
    private map<string, string> fieldsMAP;
    list<string> fields = new list<string>();
    
    public OppFinanciamientoCtrl(){
        
    }
    
    public string doMergeFields(String Id, string text) 
    {
        fieldsMAP = new map<string, string>();
        list<Opp_Finacial__mdt> mergeField =  [select label, Field__c from Opp_Finacial__mdt] ;
        for (Opp_Finacial__mdt m : mergeField )
        {
            fields.add(m.Field__c);
        }	        
        system.debug('fields' +fields);
        string query = 'select ' +  String.join(fields, ',') + ' from Oportunidad_de_Financiamiento__c where id=\''+ Id+'\'';
        query =  query.replace(')','');
        system.debug('query' + query.replace('(',''));
        
        SObject s = Database.query(query.replace('(',''));
        
        Oportunidad_de_Financiamiento__c oppF = [select Tipo_Cargo__c 
                                                   from Oportunidad_de_Financiamiento__c 
                                                  where id= :Id];
        string detalleAprobacion = '';
        string comisionInfo = '';
        
        if(oppF.Tipo_Cargo__c == 'Financiado Independientemente')
        {
            detalleAprobacion = '<tr style="height: 21px;">'+
                '<td style="border-right-style: dotted; border-right-color: #000000; border-left-color: #000000; overflow: hidden; padding: 0px 3px; vertical-align: bottom; font-size: 10pt;" data-sheets-value="{&quot;1&quot;:2,&quot;2&quot;:&quot;Tasa de inter&eacute;s fija primeros 24 meses&quot;}">Tasa de inter&eacute;s fija primeros {{MesFinal}} meses</td>'+
                '<td style="border-right-style: dotted;border-right-color: #000000; border-bottom-style: dotted; border-bottom-color: #000000; overflow: hidden; padding: 0px 3px; vertical-align: bottom; font-size: 10pt; text-align: center;" colspan="3" rowspan="1" data-sheets-value="{&quot;1&quot;:3,&quot;3&quot;:0.0875}" data-sheets-numberformat="[null,3,&quot;0.00%&quot;,1]">{{TasaMesFinal1}}%</td>'+
                '</tr>'+
                '</tr>'+
                '<tr style="height: 21px;">'+
                '<td style="border-right-style: dotted; border-right-color: #000000; border-left-color: #000000; overflow: hidden; padding: 0px 3px; vertical-align: bottom; font-size: 10pt;" data-sheets-value="{&quot;1&quot;:2,&quot;2&quot;:&quot;Tasa de inter&eacute;s fija primeros 24 meses&quot;}">Cuota fija por {{MesFinal}} meses</td>'+
                '<td style="border-right-style: dotted; border-right-color: #000000; border-bottom-style: dotted; border-bottom-color: #000000; overflow: hidden; padding: 0px 3px; vertical-align: bottom; font-size: 10pt; text-align: center;" colspan="3" rowspan="1" data-sheets-value="{&quot;1&quot;:3,&quot;3&quot;:0.0875}" data-sheets-numberformat="[null,3,&quot;0.00%&quot;,1]">{{Cuota24}}</td>'+
                '</tr>'+
                '<tr style="height: 21px;">'+
                '<td style="border-right-style: dotted; border-right-color: #000000; border-left-color: #000000; overflow: hidden; padding: 0px 3px; vertical-align: bottom; font-size: 10pt;" data-sheets-value="{&quot;1&quot;:2,&quot;2&quot;:&quot;Seguro mensual&quot;}">Seguro mensual</td>'+
                '<td style="border-right-style: dotted; border-right-color: #000000; border-bottom-style: dotted; border-bottom-color: #000000; overflow: hidden; padding: 0px 3px; vertical-align: bottom; font-size: 10pt; text-align: center;" colspan="3" rowspan="1" data-sheets-value="{&quot;1&quot;:3,&quot;3&quot;:43.82}" data-sheets-numberformat="[null,2,&quot;0.00&quot;,1]">{{seguro}}</td>'+
                '</tr>'+
                '<tr style="height: 21px;">'+
                '<td style="border-right-style: dotted; border-right-color: #000000; border-left-color: #000000; overflow: hidden; padding: 0px 3px; vertical-align: bottom; font-size: 10pt;" data-sheets-value="{&quot;1&quot;:2,&quot;2&quot;:&quot;Cargo por administraci&oacute;n&quot;}">Cargo por administraci&oacute;n del mes 1 al {{MesFinal}}</td>'+
                '<td style="border-right-style: dotted; border-right-color: #000000; border-bottom-style: dotted; border-bottom-color: #000000; overflow: hidden; padding: 0px 3px; vertical-align: bottom; font-size: 10pt; text-align: center;" colspan="3" rowspan="1" data-sheets-value="{&quot;1&quot;:3,&quot;3&quot;:37.74}" data-sheets-numberformat="[null,2,&quot;0.00&quot;,1]">{{Cargo_Admin}}</td>'+
                '</tr>'+
                '<tr style="height: 21px;">'+
                '<td style="border-right-style: dotted; border-right-color: #000000; border-left-color: #000000; overflow: hidden; padding: 0px 3px; vertical-align: bottom; font-size: 10pt;" data-sheets-value="{&quot;1&quot;:2,&quot;2&quot;:&quot;Seguro mensual&quot;}">IVA del mes 1 al {{MesFinal}}</td>'+
                '<td style="border-right-style: dotted; border-right-color: #000000; border-bottom-style: dotted; border-bottom-color: #000000; overflow: hidden; padding: 0px 3px; vertical-align: bottom; font-size: 10pt; text-align: center;" colspan="3" rowspan="1" data-sheets-value="{&quot;1&quot;:3,&quot;3&quot;:43.82}" data-sheets-numberformat="[null,2,&quot;0.00&quot;,1]">{{Iva}}</td>'+
                '</tr>'+
                '<tr style="height: 21px;">'+
                '<td style="border-right-style: dotted; border-right-color: #000000; border-left-color: #000000; overflow: hidden; padding: 0px 3px; vertical-align: bottom; font-size: 10pt;" data-sheets-value="{&quot;1&quot;:2,&quot;2&quot;:&quot;Seguro mensual&quot;}">Comisi&oacute;n</td>'+
                '<td style="border-right-style: dotted; border-right-color: #000000; border-bottom-style: dotted; border-bottom-color: #000000; overflow: hidden; padding: 0px 3px; vertical-align: bottom; font-size: 10pt; text-align: center;" colspan="3" rowspan="1" data-sheets-value="{&quot;1&quot;:3,&quot;3&quot;:37.74}" data-sheets-numberformat="[null,2,&quot;0.00&quot;,1]">{{comision}}</td>'+
                '</tr>'+
                '<tr style="height: 21px;">'+
                '<td style="border-right-style: dotted; border-right-color: #000000; border-left-color: #000000; overflow: hidden; padding: 0px 3px; vertical-align: bottom; font-size: 10pt;" data-sheets-value="{&quot;1&quot;:2,&quot;2&quot;:&quot;Seguro mensual&quot;}">GPS</td>'+
                '<td style="border-right-style: dotted; border-right-color: #000000; border-bottom-style: dotted; border-bottom-color: #000000; overflow: hidden; padding: 0px 3px; vertical-align: bottom; font-size: 10pt; text-align: center;" colspan="3" rowspan="1" data-sheets-value="{&quot;1&quot;:3,&quot;3&quot;:37.74}" data-sheets-numberformat="[null,2,&quot;0.00&quot;,1]">{{gps}}</td>'+
                '</tr>'+
                '<tr style="height: 21px;">'+
                '<td style="border-right-color: transparent; border-bottom-color: transparent; border-left-color: #000000; overflow: hidden; padding: 0px 3px; vertical-align: bottom; background-color: #1f3864; font-size: 10pt; color: #ffffff;" data-sheets-value="{&quot;1&quot;:2,&quot;2&quot;:&quot;Detalle de la aprobaci&oacute;n&quot;}">TOTAL CUOTA FIJA MENSUAL DEL MES 1 al {{MesFinal}}</td>'+
                '<td style="text-align:center;border-right-color: #000000; border-bottom-color: transparent; overflow: hidden; padding: 0px 3px; vertical-align: bottom; background-color: #1f3864;font-size: 10pt; color: #ffffff;" colspan="3" >{{totalmes1}}</td>'+
                '</tr>'+
                '<tr style="height: 21px;">'+
                '<td style="border-right-style: dotted; border-right-color: #000000; border-left-color: #000000; overflow: hidden; padding: 0px 3px; vertical-align: bottom; font-size: 10pt;" data-sheets-value="{&quot;1&quot;:2,&quot;2&quot;:&quot;Tasa de inter&eacute;s fija primeros 24 meses&quot;}">Tasa variable a partir mes {{MesFinal2}}</td>'+
                '<td style="border-bottom-style: dotted; border-bottom-color: #000000; overflow: hidden; padding: 0px 3px; vertical-align: bottom; font-size: 10pt; text-align: right;" colspan="2" rowspan="1" data-sheets-value="{&quot;1&quot;:2,&quot;2&quot;:&quot;prime rate 3 meses +&quot;}">Prime rate a 3 meses</td>'+
                '<td style="border-right-style: dotted;border-right-color: #000000; border-bottom-style: dotted; border-bottom-color: #000000; overflow: hidden; padding: 0px 3px; vertical-align: bottom; font-size: 10pt; text-align: center;" data-sheets-value="{&quot;1&quot;:3,&quot;3&quot;:0.0875}" data-sheets-numberformat="[null,3,&quot;0.00%&quot;,1]">{{TasaMesFinal2}}%</td>'+
                '</tr>'+
                '<tr style="height: 21px;">'+
                '<td style="border-right-style: dotted; border-right-color: #000000; border-left-color: #000000; overflow: hidden; padding: 0px 3px; vertical-align: bottom; font-size: 10pt;" data-sheets-value="{&quot;1&quot;:2,&quot;2&quot;:&quot;Cargo por administraci&oacute;n&quot;}">Cargo por administraci&oacute;n a partir del mes {{MesFinal2}}</td>'+
                '<td style="border-right-style: dotted; border-right-color: #000000; border-bottom-style: dotted; border-bottom-color: #000000; overflow: hidden; padding: 0px 3px; vertical-align: bottom; font-size: 10pt; text-align: center;" colspan="3" rowspan="1" data-sheets-value="{&quot;1&quot;:3,&quot;3&quot;:37.74}" data-sheets-numberformat="[null,2,&quot;0.00&quot;,1]">{{Cargo_Admin19}}</td>'+
                '</tr>'+
                '<tr style="height: 21px;">'+
                '<td style="border-right-style: dotted; border-right-color: #000000; border-left-color: #000000; overflow: hidden; padding: 0px 3px; vertical-align: bottom; font-size: 10pt;" data-sheets-value="{&quot;1&quot;:2,&quot;2&quot;:&quot;Seguro mensual&quot;}">IVA a partir del mes {{MesFinal2}}</td>'+
                '<td style="border-right-style: dotted; border-right-color: #000000; border-bottom-style: dotted; border-bottom-color: #000000; overflow: hidden; padding: 0px 3px; vertical-align: bottom; font-size: 10pt; text-align: center;" colspan="3" rowspan="1" data-sheets-value="{&quot;1&quot;:3,&quot;3&quot;:43.82}" data-sheets-numberformat="[null,2,&quot;0.00&quot;,1]">{{Iva19}}</td>'+
                '</tr>';
        }else
        {
            detalleAprobacion = '<tr style="height: 21px;">'+
                '<td style="border-right-style: dotted; border-right-color: #000000; border-left-color: #000000; overflow: hidden; padding: 0px 3px; vertical-align: bottom; font-size: 10pt;" data-sheets-value="{&quot;1&quot;:2,&quot;2&quot;:&quot;Tasa de inter&eacute;s fija primeros 24 meses&quot;}">{{distribucion}}</td>'+
                '</tr>'+
                '<tr style="height: 21px;">'+
                '<td style="border-right-style: dotted; border-right-color: #000000; border-left-color: #000000; overflow: hidden; padding: 0px 3px; vertical-align: bottom; font-size: 10pt;" data-sheets-value="{&quot;1&quot;:2,&quot;2&quot;:&quot;Tasa de inter&eacute;s fija primeros 24 meses&quot;}">Cuota fija por {{MesFinal}} meses</td>'+
                '<td style="border-right-style: dotted; border-right-color: #000000; border-bottom-style: dotted; border-bottom-color: #000000; overflow: hidden; padding: 0px 3px; vertical-align: bottom; font-size: 10pt; text-align: center;" colspan="3" rowspan="1" data-sheets-value="{&quot;1&quot;:3,&quot;3&quot;:0.0875}" data-sheets-numberformat="[null,3,&quot;0.00%&quot;,1]">{{Cuota24}}</td>'+
                '</tr>'+
                '<tr style="height: 21px;">'+
                '<td style="border-right-style: dotted; border-right-color: #000000; border-left-color: #000000; overflow: hidden; padding: 0px 3px; vertical-align: bottom; font-size: 10pt;" data-sheets-value="{&quot;1&quot;:2,&quot;2&quot;:&quot;Cargo por administraci&oacute;n&quot;}">Cargo por administraci&oacute;n</td>'+
                '<td style="border-right-style: dotted; border-right-color: #000000; border-bottom-style: dotted; border-bottom-color: #000000; overflow: hidden; padding: 0px 3px; vertical-align: bottom; font-size: 10pt; text-align: center;" colspan="3" rowspan="1" data-sheets-value="{&quot;1&quot;:3,&quot;3&quot;:37.74}" data-sheets-numberformat="[null,2,&quot;0.00&quot;,1]">{{Cargo_Admin}}</td>'+
                '</tr>'+
                '<tr style="height: 21px;">'+
                '<td style="border-right-style: dotted; border-right-color: #000000; border-left-color: #000000; overflow: hidden; padding: 0px 3px; vertical-align: bottom; font-size: 10pt;" data-sheets-value="{&quot;1&quot;:2,&quot;2&quot;:&quot;Seguro mensual&quot;}">IVA</td>'+
                '<td style="border-right-style: dotted; border-right-color: #000000; border-bottom-style: dotted; border-bottom-color: #000000; overflow: hidden; padding: 0px 3px; vertical-align: bottom; font-size: 10pt; text-align: center;" colspan="3" rowspan="1" data-sheets-value="{&quot;1&quot;:3,&quot;3&quot;:43.82}" data-sheets-numberformat="[null,2,&quot;0.00&quot;,1]">{{Iva}}</td>'+
                '</tr>'+
                '<tr style="height: 21px;">'+
                '<td style="border-right-style: dotted; border-right-color: #000000; border-left-color: #000000; overflow: hidden; padding: 0px 3px; vertical-align: bottom; font-size: 10pt;" data-sheets-value="{&quot;1&quot;:2,&quot;2&quot;:&quot;Seguro mensual&quot;}">Seguro mensual</td>'+
                '<td style="border-right-style: dotted; border-right-color: #000000; border-bottom-style: dotted; border-bottom-color: #000000; overflow: hidden; padding: 0px 3px; vertical-align: bottom; font-size: 10pt; text-align: center;" colspan="3" rowspan="1" data-sheets-value="{&quot;1&quot;:3,&quot;3&quot;:43.82}" data-sheets-numberformat="[null,2,&quot;0.00&quot;,1]">{{seguro}}</td>'+
                '</tr>';
            
            comisionInfo ='<tr style="height: 21px;">'+
                '<td style="border-right-style: dotted; border-right-color: #000000; border-left-color: #000000; overflow: hidden; padding: 0px 3px; vertical-align: bottom; font-size: 10pt;">Comisi&oacute;n</td>'+
                '<td style="border-right-style: dotted; border-right-color: #000000; border-bottom-style: dotted; border-bottom-color: #000000; overflow: hidden; padding: 0px 3px; vertical-align: bottom; font-size: 10pt; text-align: center;" colspan="2" rowspan="1" >{{Comision__c}}%</td>'+
                '<td style="border-right-color: #000000; border-bottom-style: dotted; border-right-style: dotted; border-bottom-color: #000000; overflow: hidden; padding: 0px 3px; vertical-align: bottom; font-size: 10pt; text-align: right;" >{{Monto_Comision__c}}</td>'+
                '</tr>'+
                '<tr style="height: 21px;">'+
                '<td style="border-right-style: dotted; border-right-color: #000000; border-left-color: #000000; overflow: hidden; padding: 0px 3px; vertical-align: bottom; font-size: 10pt;">GPS</td>'+
                '<td style="border-bottom-style: dotted; border-bottom-color: #000000; overflow: hidden; padding: 0px 3px; vertical-align: bottom;" data-sheets-numberformat="[null,3,&quot;0.00%&quot;,1]">&nbsp;</td>'+
                '<td style="border-right-style: dotted; border-right-color: #000000; border-bottom-style: dotted; border-bottom-color: #000000; overflow: hidden; padding: 0px 3px; vertical-align: bottom;">&nbsp;</td>'+
                '<td style="border-right-color: #000000; border-bottom-style: dotted; border-right-style: dotted; border-bottom-color: #000000; overflow: hidden; padding: 0px 3px; vertical-align: bottom; font-size: 10pt; text-align: right;" >{{GPS__c}}</td>'+
                '</tr>';
        }
        text = text.replace('{{detalleAprobacion}}', detalleAprobacion);
        text = text.replace('{{comisionInfo}}', comisionInfo);
        
        
        string fieldValue = (string)s.get(fields[0]);
        string tipoCargo =  (string)s.get(fields[0]);
        for (Opp_Finacial__mdt mg :mergeField)
        {
            system.debug('field to find : ' + '<<' + mg.Field__c + '>>');
            //system.debug('field value : ' +  s.get(mg.Field__c));
            system.debug('text : ' +  text);
            
            Object sObjectfieldValue = s.get(mg.Field__c);
            system.debug('sObjectfieldValue: ' +  (sObjectfieldValue != null ? String.valueOf(sObjectfieldValue) : ''));
            String valueToReplace = (sObjectfieldValue != null ? String.valueOf(sObjectfieldValue) : ' '); 
            text = text.replace('{{' + mg.Field__c + '}}', valueToReplace);
        }
        
        StaticResource static_resource = [SELECT Id, SystemModStamp,Name
                                          FROM StaticResource 
                                          WHERE Name = 'logo'
                                          LIMIT 1];
        String url_file_ref = '/resource/'
            + String.valueOf(((DateTime)static_resource.get('SystemModStamp')).getTime())
            + '/' 
            + static_resource.get('Name');			
        text = text.replace('{{logo}}', url_file_ref);
        
        String tabla = '<p>&nbsp;</p>'+
            '<table style="border-collapse: collapse;text-align: center;" width="86%">'+
            '<tbody>'+
            '<tr>'+
            '<td colspan="6" style="margin:left:20%;text-align: center; font-size: 14.5pt; font-family: Arial; background-color: transparent; font-weight: 400; font-style: normal; font-variant: normal; text-decoration: none; vertical-align: baseline; white-space: pre-wrap;"><p style="text-align: center;"><span style="font-weight: 400;text-align: center;">Tabla de Pagos con condiciones iniciales</span></p>'+
            '</td></tr>'+
            '<tr>'+
            '<td style="border: black 0.5pt solid;border-rigth-color:transparent;text-align: center; ">'+
            '<p><span style="text-align: center; font-size: 12.5pt; font-family: Arial; color: #000000; background-color: transparent; font-weight: 400; font-style: normal; font-variant: normal; text-decoration: none; vertical-align: baseline; white-space: pre-wrap;">Mes</span></p>'+
            '   </td>'+
            '<td style="border: black 0.5pt solid;border-rigth-color:transparent;text-align: center; ">'+
            '<p><span style="text-align: center; font-size: 12.5pt; font-family: Arial; color: #000000; background-color: transparent; font-weight: 400; font-style: normal; font-variant: normal; text-decoration: none; vertical-align: baseline; white-space: pre-wrap;">Cuota</span></p>'+
            '   </td>'+
            '<td style="border: black 0.5pt solid;border-rigth-color:transparent;text-align: center; ">'+
            '<p><span style="text-align: center; font-size: 12.5pt; font-family: Arial; color: #000000; background-color: transparent; font-weight: 400; font-style: normal; font-variant: normal; text-decoration: none; vertical-align: baseline; white-space: pre-wrap;">Intereses</span></p>'+
            '</td>'+
            '<td style="border: black 0.5pt solid;border-rigth-color:transparent;text-align: center; ">'+
            '<p><span style="text-align: center; font-size: 12.5pt; font-family: Arial; color: #000000; background-color: transparent; font-weight: 400; font-style: normal; font-variant: normal; text-decoration: none; vertical-align: baseline; white-space: pre-wrap;">Amortizaci&oacute;n</span></p>'+
            '</td>'+
            '<td style="border: black 0.5pt solid;border-rigth-color:transparent;text-align: center; ">'+
            '<p><span style="text-align: center; font-size: 12.5pt; font-family: Arial; color: #000000; background-color: transparent; font-weight: 400; font-style: normal; font-variant: normal; text-decoration: none; vertical-align: baseline; white-space: pre-wrap;">Administrativo</span></p>'+
            '   </td>';
        if(oppF.Tipo_Cargo__c == 'Financiado Independientemente')
        {
            tabla += '<td style="border: black 0.5pt solid;border-rigth-color:transparent;text-align: center; ">'+
            '<p><span style="text-align: center; font-size: 12.5pt; font-family: Arial; color: #000000; background-color: transparent; font-weight: 400; font-style: normal; font-variant: normal; text-decoration: none; vertical-align: baseline; white-space: pre-wrap;">GPS</span></p>'+
            '</td>'+
            '<td style="border: black 0.5pt solid;border-rigth-color:transparent;text-align: center; ">'+
            ' <p><span style="text-align: center; font-size: 12.5pt; font-family: Arial; color: #000000; background-color: transparent; font-weight: 400; font-style: normal; font-variant: normal; text-decoration: none; vertical-align: baseline; white-space: pre-wrap;">Comisión</span></p>'+
            '</td>';
        }
        
            tabla += '<td style="border: black 0.5pt solid;border-rigth-color:transparent;text-align: center; ">'+
            '<p><span style="text-align: center; font-size: 12.5pt; font-family: Arial; color: #000000; background-color: transparent; font-weight: 400; font-style: normal; font-variant: normal; text-decoration: none; vertical-align: baseline; white-space: pre-wrap;">Seguros</span></p>'+
            '</td>'+
            '<td style="border: black 0.5pt solid;border-rigth-color:transparent;text-align: center; ">'+
            ' <p><span style="text-align: center; font-size: 12.5pt; font-family: Arial; color: #000000; background-color: transparent; font-weight: 400; font-style: normal; font-variant: normal; text-decoration: none; vertical-align: baseline; white-space: pre-wrap;">Impuesto</span></p>'+
            '</td>'+
            '<td style="border: black 0.5pt solid;border-rigth-color:transparent;text-align: center; ">'+
            '<p><span style="text-align: center; font-size: 12.5pt; font-family: Arial; color: #000000; background-color: transparent; font-weight: 400; font-style: normal; font-variant: normal; text-decoration: none; vertical-align: baseline; white-space: pre-wrap;">Total de Cuota</span></p>'+
            '   </td>'+
            '<td style="border: black 0.5pt solid;text-align: center; ">'+
            '<p><span style="text-align: center; font-size: 12.5pt; font-family: Arial; color: #000000; background-color: transparent; font-weight: 400; font-style: normal; font-variant: normal; text-decoration: none; vertical-align: baseline; white-space: pre-wrap;">Saldo</span></p>'+
            '</td>'+
            '</tr>';
              
        decimal cuota = 0;
        decimal cargo = 0;
        decimal iva = 0;
        decimal seguro = 0;
        integer seg=0;
        decimal val = 0;
        decimal gps = 0;
        decimal cuota19 = 0;
        decimal cargo19 = 0;
        decimal iva19 = 0;
        decimal comision = 0;
        decimal totalmes1 = 0;
        
        for(Tabla_Pagos__c p:[select id,Index__c,Intereses__c,Principal__c,Seguro_Monto_Fijo__c,Monto_Total__c,Saldo__c,
                              Administrativo__c,Impuestos__c,Monto__c,cotizacion__r.Monto_Seguro__c,GPS__c,Comision__c
                                from Tabla_Pagos__c
                               where Cotizacion__r.Oportunidad_de_Financiamiento__c =: Id 
                                 and Cotizacion__r.Estado__c = 'Aceptada'
                             order by id])
        {
            if(seg == 0)
            {
                cuota = (p.Monto__c==null?0:p.Monto__c);//Monto_Total__c;
                cargo = p.Administrativo__c;
                iva = p.Impuestos__c;
                seguro = p.cotizacion__r.Monto_Seguro__c;
                gps = (p.GPS__c==null?0:p.GPS__c);
                comision = p.Comision__c;
                
            }
            if(seg == 19)
            {
                cuota19 = p.Monto__c;//Monto_Total__c;
                cargo19 = p.Administrativo__c;
                iva19 = p.Impuestos__c;
            }
            val = p.Monto_Total__c;
            
            tabla+= '<tr><td style="border: black 0.5pt solid;text-align: center; font-size: 12.5pt; font-family: Arial;">'+p.Index__c+'</td>'
                +'<td style="border: black 0.5pt solid;text-align: center; font-size: 12.5pt; font-family: Arial;">'+p.Monto__c+'</td>'
                +'<td style="border: black 0.5pt solid;text-align: center; font-size: 12.5pt; font-family: Arial;">'+p.Intereses__c+'</td>'
                +'<td style="border: black 0.5pt solid;text-align: center; font-size: 12.5pt; font-family: Arial;">'+p.Principal__c+'</td>'
                +'<td style="border: black 0.5pt solid;text-align: center; font-size: 12.5pt; font-family: Arial;">'+p.Administrativo__c+'</td>';
                if(oppF.Tipo_Cargo__c == 'Financiado Independientemente')
                {
                    tabla+='<td style="border: black 0.5pt solid;text-align: center; font-size: 12.5pt; font-family: Arial;">'+(p.GPS__c==null?0:p.GPS__c)+'</td>'
                +'<td style="border: black 0.5pt solid;text-align: center; font-size: 12.5pt; font-family: Arial;">'+(p.Comision__c==null?0:p.Comision__c)+'</td>';
                }
                tabla+= '<td style="border: black 0.5pt solid;text-align: center; font-size: 12.5pt; font-family: Arial;">'+(p.Seguro_Monto_Fijo__c==null?0:p.Seguro_Monto_Fijo__c)+'</td>'
                +'<td style="border: black 0.5pt solid;text-align: center; font-size: 12.5pt; font-family: Arial;">'+p.Impuestos__c+'</td>'
                +'<td style="border: black 0.5pt solid;text-align: center; font-size: 12.5pt; font-family: Arial;">'+(val !=null?val.setScale(2):0)+'</td>'
                +'<td style="border: black 0.5pt solid;text-align: center; font-size: 12.5pt; font-family: Arial;">'+p.Saldo__c+'</td></tr>';
            seg++;
        }
        tabla += '</tbody>'
           		+ '</table>';
        totalmes1 = (cuota ==null?0:cuota) + 
            		(seguro==null?0:seguro) + 
            		(cargo ==null?0:cargo) + 
            		(iva ==null?0:iva) +
            		(comision==null?0:comision) +
            		(gps==null?0:gps);
        
        text = text.replace('{{tablapago}}', tabla);
        text = text.replace('{{Cuota24}}', string.valueOf(cuota));
		if(cargo != null){
			text = text.replace('{{Cargo_Admin}}', string.valueOf(cargo));
		}else{
			text = text.replace('{{Cargo_Admin}}', '0');
		}
        text = text.replace('{{Iva}}', string.valueOf(iva));
        text = text.replace('{{seguro}}', string.valueOf(seguro));
        text = text.replace('{{gps}}', string.valueOf(gps));
        text = text.replace('{{Cuota19}}', string.valueOf(cuota19));
		if(cargo19 != null){
			text = text.replace('{{Cargo_Admin19}}', string.valueOf(cargo19));
		}else{
			text = text.replace('{{Cargo_Admin19}}', '0');
		}
        text = text.replace('{{Iva19}}', string.valueOf(iva19));
        text = text.replace('{{totalmes1}}', string.valueOf(totalmes1));
        
        
        seg =0;
        string distribucion = '';
        string distribucion1 = '';
        string distribucion2 = '';
        
        string MesFinal1 = '';
        decimal TasaMesFinal1 = 0;
        string MesFinal2 = '';
        decimal TasaMesFinal2 = 0;
        
        for(Distribucion__c d: [select id,Mes_Final__c,Mes_Inicial__c,Porcentaje_Tasa_Base__c, spread__c
                                          from Distribucion__c
                                         where Cotizacion__r.Oportunidad_de_Financiamiento__c =: Id 
                                 		   and Cotizacion__r.Estado__c = 'Aceptada'])
        {
            if(seg==0)
            {
                MesFinal1 = string.valueOf(d.Mes_Final__c);
                TasaMesFinal1= (d.spread__c==null?0:d.spread__c);
                distribucion = ' ' +
                    'Tasa de inter&eacute;s fija primeros '+ d.Mes_Final__c + ' meses</td>' +
                               ' <td style="border-right-style: dotted;border-right-color: #000000; border-bottom-style: dotted; border-bottom-color: #000000; overflow: hidden; padding: 0px 3px; vertical-align: bottom; font-size: 10pt; text-align: center;" colspan="3" rowspan="1" data-sheets-value="{&quot;1&quot;:3,&quot;3&quot;:0.0875}" data-sheets-numberformat="[null,3,&quot;0.00%&quot;,1]">'+TasaMesFinal1+'%</td>' +
                               '</tr>  ';
                distribucion1 = ' ' +
                    'Tasa de inter&eacute;s fija primeros '+ d.Mes_Final__c + ' meses</td>' +
                               ' <td style="border-right-style: dotted;border-right-color: #000000; border-bottom-style: dotted; border-bottom-color: #000000; overflow: hidden; padding: 0px 3px; vertical-align: bottom; font-size: 10pt; text-align: center;" colspan="3" rowspan="1" data-sheets-value="{&quot;1&quot;:3,&quot;3&quot;:0.0875}" data-sheets-numberformat="[null,3,&quot;0.00%&quot;,1]">'+ TasaMesFinal1+'%</td>' +
                              '';

            }
            else
            {
                MesFinal2 = string.valueOf(d.Mes_inicial__c);
                TasaMesFinal2= (d.spread__c==null?0:d.spread__c);
                
                 distribucion2 = '' +
                    'Tasa variable a partir mes '+ d.Mes_inicial__c+'</td>' +
                                '<td style="border-bottom-style: dotted; border-bottom-color: #000000; overflow: hidden; padding: 0px 3px; vertical-align: bottom; font-size: 10pt; text-align: right;" colspan="2" rowspan="1" data-sheets-value="{&quot;1&quot;:2,&quot;2&quot;:&quot;prime rate 3 meses +&quot;}">Prime rate a 3 meses +</td>' +
                                '<td style="border-right-style: dotted;border-right-color: #000000; border-bottom-style: dotted; border-bottom-color: #000000; overflow: hidden; padding: 0px 3px; vertical-align: bottom; font-size: 10pt; text-align: center;" data-sheets-value="{&quot;1&quot;:3,&quot;3&quot;:0.0875}" data-sheets-numberformat="[null,3,&quot;0.00%&quot;,1]">'+ TasaMesFinal2+'%' +
                                '';
                distribucion += '<tr><td style="border-right-style: dotted; border-right-color: #000000; border-left-color: #000000; overflow: hidden; padding: 0px 3px; vertical-align: bottom; font-size: 10pt;">' +
                    'Tasa variable a partir mes '+ d.Mes_inicial__c+'</td>' +
                                '<td style="border-bottom-style: dotted; border-bottom-color: #000000; overflow: hidden; padding: 0px 3px; vertical-align: bottom; font-size: 10pt; text-align: right;" colspan="2" rowspan="1" data-sheets-value="{&quot;1&quot;:2,&quot;2&quot;:&quot;prime rate 3 meses +&quot;}">Prime rate a 3 meses +</td>' +
                                '<td style="border-right-style: dotted;border-right-color: #000000; border-bottom-style: dotted; border-bottom-color: #000000; overflow: hidden; padding: 0px 3px; vertical-align: bottom; font-size: 10pt; text-align: center;" data-sheets-value="{&quot;1&quot;:3,&quot;3&quot;:0.0875}" data-sheets-numberformat="[null,3,&quot;0.00%&quot;,1]">'+ TasaMesFinal2+'%' +
                                '';
               
            }
            seg++;
        }
        text = text.replace('{{distribucion}}',distribucion);
        text = text.replace('{{distribucion1}}',distribucion1);
        text = text.replace('{{distribucion2}}',distribucion2);
        text = text.replace('{{TasaMesFinal1}}', string.valueOf(TasaMesFinal1));
        text = text.replace('{{TasaMesFinal2}}', string.valueOf(TasaMesFinal2));
        
        text = text.replace('{{MesFinal}}', string.valueOf((MesFinal1==null?'':MesFinal1)));
        text = text.replace('{{MesFinal2}}', string.valueOf((MesFinal2==null?'':MesFinal2)));
        text = text.replace('{{comision}}', string.valueOf((comision==null?0:comision)));
        
        //Cargos por mora
        string mora = '';
        system.debug('tipo ' + (string)s.get('TipoProducto__c'));
        string tipo = (string)s.get('TipoProducto__c');
        system.debug('tipo ' + tipo);
        if(tipo.contains('Leasing'))
        {
            mora = ''
                 + '1-5 d&iacute;as mora</td>'
                 + '<td style="border-bottom-style: dotted; border-bottom-color: #000000; overflow: hidden; padding: 0px 3px; vertical-align: bottom;" data-sheets-numberformat="[null,3,&quot;0%&quot;,1]">&nbsp;</td>'
                 + '<td style="border-bottom-style: dotted; border-bottom-color: #000000; overflow: hidden; padding: 0px 3px; vertical-align: bottom;font-size: 10pt;" data-sheets-value="{&quot;1&quot;:2,&quot;2&quot;:&quot;$10&quot;}" data-sheets-numberformat="[null,3,&quot;0%&quot;,1]" data-sheets-formula="=IF(R20C3=&quot;CREDITO PRENDARIO&quot;,R[-26]C[5],R[-21]C[5])">$0</td>'
                 + '<td style="border-right-style: dotted;border-right-color: #000000; border-bottom-style: dotted; border-bottom-color: #000000; overflow: hidden; padding: 0px 3px; vertical-align: bottom;" data-sheets-numberformat="[null,3,&quot;0%&quot;,1]">&nbsp;</td>'
                 + '</tr>'
                 + '<tr style="height: 21px;">'
                 + '<td style="border-right-style: dotted; border-right-color: #000000; border-left-color: #000000; overflow: hidden; padding: 0px 3px; vertical-align: bottom; font-size: 10pt; text-align: center;" data-sheets-value="{&quot;1&quot;:2,&quot;2&quot;:&quot;60 d&iacute;as mora&quot;}" data-sheets-formula="=IF(R20C3=&quot;CREDITO PRENDARIO&quot;,R[-26]C[6],R[-21]C[6])">6-30 d&iacute;as mora</td>'
                 + '<td style="border-bottom-style: dotted; border-bottom-color: #000000; overflow: hidden; padding: 0px 3px; vertical-align: bottom;" data-sheets-numberformat="[null,3,&quot;0%&quot;,1]">&nbsp;</td>'
                 + '<td style="font-size: 10pt;border-bottom-style: dotted; border-bottom-color: #000000; overflow: hidden; padding: 0px 3px; vertical-align: bottom;" data-sheets-value="{&quot;1&quot;:2,&quot;2&quot;:&quot;$20&quot;}" data-sheets-numberformat="[null,3,&quot;0%&quot;,1]" data-sheets-formula="=IF(R20C3=&quot;CREDITO PRENDARIO&quot;,R[-26]C[5],R[-21]C[5])">$50</td>'
                 + '<td style="border-right-style: dotted;border-right-color: #000000; border-bottom-style: dotted; border-bottom-color: #000000; overflow: hidden; padding: 0px 3px; vertical-align: bottom;" data-sheets-numberformat="[null,3,&quot;0%&quot;,1]">&nbsp;</td>'
                 + '</tr>'
                 + '<tr style="height: 21px;">'
                 + '<td style="border-right-style: dotted; border-right-color: #000000; border-left-color: #000000; overflow: hidden; padding: 0px 3px; vertical-align: bottom; font-size: 10pt; text-align: center;" data-sheets-value="{&quot;1&quot;:2,&quot;2&quot;:&quot;90 d&iacute;as mora&quot;}" data-sheets-formula="=IF(R20C3=&quot;CREDITO PRENDARIO&quot;,R[-26]C[6],R[-21]C[6])">31 d&iacute;as mora</td>'
                 + '<td style="border-bottom-style: dotted; border-bottom-color: #000000; overflow: hidden; padding: 0px 3px; vertical-align: bottom;" data-sheets-numberformat="[null,3,&quot;0%&quot;,1]">&nbsp;</td>'
                 + '<td style="font-size: 10pt;border-bottom-style: dotted; border-bottom-color: #000000; overflow: hidden; padding: 0px 3px; vertical-align: bottom;" data-sheets-value="{&quot;1&quot;:2,&quot;2&quot;:&quot;$30&quot;}" data-sheets-numberformat="[null,3,&quot;0%&quot;,1]" data-sheets-formula="=IF(R20C3=&quot;CREDITO PRENDARIO&quot;,R[-26]C[5],R[-21]C[5])">$75</td>'
                 + '<td style="border-right-style: dotted;border-right-color: #000000; border-bottom-style: dotted; border-bottom-color: #000000; overflow: hidden; padding: 0px 3px; vertical-align: bottom;" data-sheets-numberformat="[null,3,&quot;0%&quot;,1]">&nbsp;'
                 + '';
        }
        else
        {
            mora = ' '
                 + '30 d&iacute;as mora</td>'
                 + '<td style="border-bottom-style: dotted; border-bottom-color: #000000; overflow: hidden; padding: 0px 3px; vertical-align: bottom;" data-sheets-numberformat="[null,3,&quot;0%&quot;,1]">&nbsp;</td>'
                 + '<td style="font-size: 10pt;border-bottom-style: dotted; border-bottom-color: #000000; overflow: hidden; padding: 0px 3px; vertical-align: bottom;" data-sheets-value="{&quot;1&quot;:2,&quot;2&quot;:&quot;$10&quot;}" data-sheets-numberformat="[null,3,&quot;0%&quot;,1]" data-sheets-formula="=IF(R20C3=&quot;CREDITO PRENDARIO&quot;,R[-26]C[5],R[-21]C[5])">$10</td>'
                 + '<td style="border-right-style: dotted;border-right-color: #000000; border-bottom-style: dotted; border-bottom-color: #000000; overflow: hidden; padding: 0px 3px; vertical-align: bottom;" data-sheets-numberformat="[null,3,&quot;0%&quot;,1]">&nbsp;</td>'
                 + '</tr>'
                 + '<tr style="height: 21px;">'
                 + '<td style="border-right-style: dotted; border-right-color: #000000; border-left-color: #000000; overflow: hidden; padding: 0px 3px; vertical-align: bottom; font-size: 10pt; text-align: center;" data-sheets-value="{&quot;1&quot;:2,&quot;2&quot;:&quot;60 d&iacute;as mora&quot;}" data-sheets-formula="=IF(R20C3=&quot;CREDITO PRENDARIO&quot;,R[-26]C[6],R[-21]C[6])">60 d&iacute;as mora</td>'
                 + '<td style="border-bottom-style: dotted; border-bottom-color: #000000; overflow: hidden; padding: 0px 3px; vertical-align: bottom;" data-sheets-numberformat="[null,3,&quot;0%&quot;,1]">&nbsp;</td>'
                 + '<td style="font-size: 10pt;border-bottom-style: dotted; border-bottom-color: #000000; overflow: hidden; padding: 0px 3px; vertical-align: bottom;" data-sheets-value="{&quot;1&quot;:2,&quot;2&quot;:&quot;$20&quot;}" data-sheets-numberformat="[null,3,&quot;0%&quot;,1]" data-sheets-formula="=IF(R20C3=&quot;CREDITO PRENDARIO&quot;,R[-26]C[5],R[-21]C[5])">$20</td>'
                 + '<td style="border-right-style: dotted;border-right-color: #000000; border-bottom-style: dotted; border-bottom-color: #000000; overflow: hidden; padding: 0px 3px; vertical-align: bottom;" data-sheets-numberformat="[null,3,&quot;0%&quot;,1]">&nbsp;</td>'
                 + '</tr>'
                 + '<tr style="height: 21px;">'
                 + '<td style="border-right-style: dotted; border-right-color: #000000; border-left-color: #000000; overflow: hidden; padding: 0px 3px; vertical-align: bottom; font-size: 10pt; text-align: center;" data-sheets-value="{&quot;1&quot;:2,&quot;2&quot;:&quot;90 d&iacute;as mora&quot;}" data-sheets-formula="=IF(R20C3=&quot;CREDITO PRENDARIO&quot;,R[-26]C[6],R[-21]C[6])">90 d&iacute;as mora</td>'
                 + '<td style="border-bottom-style: dotted; border-bottom-color: #000000; overflow: hidden; padding: 0px 3px; vertical-align: bottom;" data-sheets-numberformat="[null,3,&quot;0%&quot;,1]">&nbsp;</td>'
                 + '<td style="font-size: 10pt;border-bottom-style: dotted; border-bottom-color: #000000; overflow: hidden; padding: 0px 3px; vertical-align: bottom;" data-sheets-value="{&quot;1&quot;:2,&quot;2&quot;:&quot;$30&quot;}" data-sheets-numberformat="[null,3,&quot;0%&quot;,1]" data-sheets-formula="=IF(R20C3=&quot;CREDITO PRENDARIO&quot;,R[-26]C[5],R[-21]C[5])">$30</td>'
                 + '<td style="border-right-style: dotted;border-right-color: #000000; border-bottom-style: dotted; border-bottom-color: #000000; overflow: hidden; padding: 0px 3px; vertical-align: bottom;" data-sheets-numberformat="[null,3,&quot;0%&quot;,1]">&nbsp;'
                 + '';
        }
        text = text.replace('{{mora}}',mora);
        text = text.replace('00:00:00','');
        return text;
    }
    
}