/*
    Creado por David Leon
    Fecha 1/16/2020
*/

public with sharing class CotizacionService  {
    
    //Metodo para actualizar la oportunidad de financiamiento con base a la informacion de la cotizacion ligada
    public static void actualizarOpF(Id idOpF){
        Oportunidad_de_Financiamiento__c opF = new Oportunidad_de_Financiamiento__c();
        Cotizacion__c cotizacion = new Cotizacion__c();
        Distribucion__c distribucionFija = new Distribucion__c();
        Distribucion__c distribucionVariable = new Distribucion__c();
        Tabla_Pagos__c tpFija = new Tabla_Pagos__c();
        Tabla_Pagos__c tpVariable = new Tabla_Pagos__c();
        Tabla_Pagos__c maxMonto = new Tabla_Pagos__c();
        List<Cargo__c> listCargos = new List<Cargo__c>();
        Tabla_Pagos__c gpsMonto = new Tabla_Pagos__c();
        
                
        opF = [SELECT Categoria__c, Ano__c, Subcategoria__c, Moneda__c, Monto_del_seguro_numero__c, PlazoOF__c, Valor_Altica__c, Prima_Altica__c,
                Producto__c, Spread__c, Comision__c, GPS__c, Profesion__c, Valor_residual__c, Estimacion_numero__c, Cuota_24_meses_Numero__c, PlazoTasaFija__c,
                cargo_administrativo_fijo__c, cargo_administrativo_segundo__c, IVA__c, IVA_2__c, Monto_del_seguro_segundo_tracto__c, Activo__c, Condicion_Activo__c,
                CuotaTotal__c, Inicio_plazo_variable__c, CuotaTotalPrimerTracto__c,
                GPS_TP__c,Comision_TP__c 
                FROM Oportunidad_de_Financiamiento__c WHERE Id =: idOpF];   
        
        cotizacion = [SELECT Id, Activo__c, Ano__c, Condicion_Activo__c, Moneda__c, Monto_Seguro__c, Plazo__c, Precio__c, Producto__c,
                    Profesion__c, Monto_Prima__c, Valor_Residual__c
                    FROM Cotizacion__c WHERE Oportunidad_de_Financiamiento__c =: idOpF AND Estado__c =: 'Aceptada'];
                    
        distribucionFija = [SELECT Spread__c, Mes_Inicial__c, Mes_Final__c, Cuota__c 
                            FROM Distribucion__c 
                            WHERE Cotizacion__c =: cotizacion.Id AND Mes_Inicial__c =: 1 LIMIT 1];
        distribucionVariable = [SELECT Spread__c, Mes_Inicial__c, Mes_Final__c, Cuota__c 
                            FROM Distribucion__c 
                            WHERE Cotizacion__c =: cotizacion.Id AND Mes_Inicial__c =: distribucionFija.Mes_Final__c + 1 LIMIT 1];

        listCargos = [SELECT Porcentaje_Credito__c, Monto__c, Descripcion_Cargo__c FROM Cargo__c WHERE Cotizacion__c =: cotizacion.Id];

        tpFija = [SELECT Administrativo__c, Impuestos__c, Monto_Total__c, Seguro_Monto_Fijo__c, Monto__c
                    FROM Tabla_Pagos__c 
                    WHERE Cotizacion__c =: cotizacion.Id AND Index__c =: 1 LIMIT 1];
        tpVariable = [SELECT Administrativo__c, Impuestos__c, Seguro_Monto_Fijo__c, Monto_Total__c
                        FROM Tabla_Pagos__c 
                        WHERE Cotizacion__c =: cotizacion.Id AND Index__c =: distribucionVariable.Mes_Inicial__c LIMIT 1];
                        
        maxMonto = [SELECT Id, Monto_Total__c,GPS__c,Comision__c
                    FROM Tabla_Pagos__c 
                    WHERE Cotizacion__c =: cotizacion.Id ORDER BY Monto_Total__c DESC LIMIT 1];
        gpsMonto = [SELECT Id, GPS__c,Comision__c
                    FROM Tabla_Pagos__c 
                    WHERE Cotizacion__c =: cotizacion.Id ORDER BY Id LIMIT 1];

        opF.Ano__c = cotizacion.Ano__c;
        opF.Monto_del_seguro_numero__c = cotizacion.Monto_Seguro__c;
        opF.PlazoOF__c = cotizacion.Plazo__c;
        opF.Valor_Altica__c = cotizacion.Precio__c;
        opF.Prima_Altica__c = cotizacion.Monto_Prima__c;
        opF.Producto__c = cotizacion.Producto__c;
        opF.Profesion__c = cotizacion.Profesion__c;
        opF.Valor_residual__c = cotizacion.Valor_Residual__c;
        opF.Activo__c = cotizacion.Activo__c;
        opF.Condicion_Activo__c = cotizacion.Condicion_Activo__c;
        opF.Cuota_paybac__c = maxMonto.Monto_Total__c * 3;
        opF.PlazoTasaFija__c = distribucionFija.Mes_Final__c;
        opF.Cuota_24_meses_Numero__c = tpFija.Monto__c;
        opF.cargo_administrativo_fijo__c = tpFija.Administrativo__c;
        opF.cargo_administrativo_segundo__c = tpVariable.Administrativo__c;
        opF.IVA__c = tpFija.Impuestos__c;
        opF.IVA_2__c = tpVariable.Impuestos__c;
        opF.Monto_del_seguro_segundo_tracto__c = tpFija.Seguro_Monto_Fijo__c;
        opF.CuotaTotal__c = tpVariable.Monto_Total__c;
        opF.Inicio_plazo_variable__c = distribucionVariable.Mes_Inicial__c;
        opF.CuotaTotalPrimerTracto__c = tpFija.Monto_Total__c;
        opF.GPS_TP__c = gpsMonto.GPS__c;
        opf.Comision_TP__c = gpsMonto.Comision__c;
        if(distribucionFija.Spread__c != null && distribucionFija.Spread__c > 0){
            opF.Spread__c = distribucionFija.Spread__c;
        }else{
            opF.Spread__c = distribucionVariable.Spread__c;
        }
        if(cotizacion.Moneda__c == 'USD'){
            opF.Moneda__c = 'Dólares';
        }else{
            opF.Moneda__c = 'Colones';
        }

        List<AggregateResult> AggregateResultList = [SELECT SUM(Monto_Total__c)sumCuotas, SUM(Seguro_Monto_Fijo__c)sumSeguros 
                                                        FROM Tabla_Pagos__c WHERE Cotizacion__c =: cotizacion.Id];
        for(AggregateResult aggr : AggregateResultList){
            opF.Estimacion_numero__c = ((Decimal)aggr.get('sumCuotas') - (Decimal)aggr.get('sumSeguros'));
        }

        for(Cargo__c c : listCargos){
            if(c.Descripcion_Cargo__c == 'GPS'){
                opF.GPS__c = c.Monto__c;
            }
            if(c.Descripcion_Cargo__c.contains('Comisión')){
                opF.Comision__c = c.Porcentaje_Credito__c;      
            }
        }
        try{
            TriggerHandler.bypass('OportunidadFinanciamientoTriggerHandler');
            update opF;
            TriggerHandler.clearBypass('OportunidadFinanciamientoTriggerHandler');
        }catch(DmlException ex){
            System.debug(' ** ERROR AL ACTUALIZAR OpF CON BASE A INFO DE COTIZACION **');
            System.debug(ex.getMessage());
        }
    }
}