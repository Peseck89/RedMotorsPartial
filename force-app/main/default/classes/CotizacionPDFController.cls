public class CotizacionPDFController {
    //<col width="13%" /><col width="15%" /><col width="38%" /><col width="20%" /><col width="20%" /><col width="17%" />
    public Cotizacion__c cot {get;set;}
    public decimal porMes1 {get;set;}
    public decimal porMes25 {get;set;}
    public decimal pagoMes1 {get;set;}
    public decimal pagoMes2 {get;set;}
    public string fecha {get;set;}
    public string fechaValidez {get;set;}
    
    public CotizacionPDFController(Apexpages.StandardController controller) {
        String recordId = controller.getId();//'a0c6C000000coz6';//Apexpages.currentPage().getParameters().get('Id');
        getData(recordId);
    }
    private void getData(String recordId) {
        
        cot = [select id,Ano__c,Prima__c,Monto_Prima__c,Plazo__c,porcentaje_valor_residual__c,
               Valor_Residual__c,Apellidos_Cliente__c,Nombre_Cliente__c,createdDate,Precio__c,
               Marca__c,Estilo__c,Producto__c,Fecha_Validez__c,(select id,Porcentaje_Credito__c,Monto__c 
                                                                from cargos__r
                                                                where Descripcion_Cargo__c = 'Comision_Sin_IVA'
                                                                LIMIT 1)
               from Cotizacion__c
               where id =: recordId 
               LIMIT 1];
        system.debug('cot'+cot);
        for(Distribucion__c d: [select id,Mes_Final__c,Mes_Inicial__c,Porcentaje_Tasa_Base__c,Variable_Tasa_Base__c,Spread__c
                                from Distribucion__c
                                where Cotizacion__r.Id =:recordId])
        {
             system.debug('d'+d);
            if(d.Variable_Tasa_Base__c == 0)
                porMes1 = d.Porcentaje_Tasa_Base__c ;
            if(d.Variable_Tasa_Base__c == 1)
                porMes25 = d.Spread__c;//d.Porcentaje_Tasa_Base__c ;
        }
        
        for(Tabla_Pagos__c p:[select id,Index__c,Intereses__c,Principal__c,Seguro_Monto_Fijo__c,Monto_Total__c,Saldo__c,
                              Administrativo__c,Impuestos__c
                              from Tabla_Pagos__c
                              where Cotizacion__r.Id =:recordId])
        {
             system.debug('p'+p);
            if(p.Index__c == 1)
                pagoMes1 = p.Monto_Total__c ;
            if(p.Index__c == 25	)
                pagoMes2 = p.Monto_Total__c ;
            
        }
        map<string,string> mapDias = new map<string,string>();
        map<string,string> mapMes = new map<string,string>();
        mapDias.put('Sunday', 'Domingo');
        mapDias.put('Monday', 'Lunes');
        mapDias.put('Tuesday', 'Martes');
        mapDias.put('Wednesday', 'Miercoles');
        mapDias.put('Thursday', 'Jueves');
        mapDias.put('Friday', 'Viernes');
        mapDias.put('Saturday', 'Sábado');
        
        mapMes.put('January', 'Enero');
        mapMes.put('February', 'Febrero');
        mapMes.put('March', 'Marzo');
        mapMes.put('April', 'Abril');
        mapMes.put('May', 'Mayo');
        mapMes.put('June', 'Junio');
        mapMes.put('July', 'Julio');
        mapMes.put('August', 'Agosto');
        mapMes.put('September', 'Septiembre');
        mapMes.put('October', 'Octubre');
        mapMes.put('November', 'Noviembre');
        mapMes.put('December', 'Diciembre');
        
        
        DateTime dt = cot.CreatedDate;
         system.debug('dt'+dt);
        fecha = dt.format('EEEE d, MMMM, yyyy');
        for(string md: mapDias.keySet())
            fecha = fecha.replace(md,mapDias.get(md));
        
            for(string mm: mapMes.keySet())
            fecha = fecha.replace(mm,mapMes.get(mm));
        
        
        DateTime dtVal = System.now();
        if (cot.Fecha_Validez__c == null){
            dtVal = dt.addDays(30);   
        }
        else{
            dtVal = cot.Fecha_Validez__c;
        }
        
        fechaValidez = dtVal.format('EEEE d, MMMM, yyyy');
        for(string md: mapDias.keySet())
            fechaValidez = fechaValidez.replace(md,mapDias.get(md));
        
        for(string mm: mapMes.keySet())
            fechaValidez = fechaValidez.replace(mm,mapMes.get(mm));
         system.debug('fechaValidez'+fechaValidez);
    }
}