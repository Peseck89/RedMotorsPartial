/*
 * Creado por: K.Rojas (IS)
 * Fecha creacion: 27/03/2019
 * Descripcion: Clase controlador de vfBusquedaReciboUsado
*/

public with sharing class controllerBusquedaReciboUsado {
    
    public ReciboUsado__c recibo{get;set;}
    public String reciboId{get;set;}
    public Double valorSugeridoVenta{get;set;}
    public Boolean showFields{get;set;}
    public String tipoVehiculo{get;set;}
    public Boolean showBlockSearchMoto{get;set;}
    public Boolean showBlockSearchCar{get;set;}
    public Boolean showTypeRecord{get;set;}
    public String showMessage{get;set;}
      
    public controllerBusquedaReciboUsado(ApexPages.StandardController stdController){
        String nameProfile = '';
        String tipoRegistro = '';
        Id idUserProfile;
        recibo = new ReciboUsado__c();
        
        idUserProfile = UserInfo.getProfileId();
        showBlockSearchMoto = false;
        showBlockSearchCar = false;
        showTypeRecord = true;
        System.debug(' ** ID USER PROFILE ** ' + idUserProfile);
        nameProfile = [SELECT Name FROM Profile WHERE Id =: idUserProfile LIMIT 1].Name;
        System.debug(' ** USER PROFILE NAME ** ' + nameProfile);
        if(nameProfile == 'Asesor de Ventas BMW' || nameProfile == 'Asesor de Ventas MINI'){
            showFields = false;
        }else{
            showFields = true;
        }
        if(ApexPages.currentPage().getParameters().get('Id') != null){
            reciboId = ApexPages.currentPage().getParameters().get('Id');
            tipoRegistro = [SELECT RecordType.Name FROM ReciboUsado__c WHERE Id =: reciboId].RecordType.Name;
            showTypeRecord = false;
            System.debug(' ** TIPO REGISTRO ** ' + tipoRegistro);
            if(tipoRegistro == 'Automóvil'){
                showBlockSearchCar = true;
            }else{
                showBlockSearchMoto = true;
            }
        }              
    }

    public void showSearchBlock(){
        System.debug(' ** Metodo Mostrar Bloques Busqueda ** ');
        System.debug(tipoVehiculo);
        if(tipoVehiculo == 'Automóvil'){
            showBlockSearchCar = true;
            showBlockSearchMoto = false;
            recibo.RecordTypeId = '0120P000000ESxJ';
        }else if(tipoVehiculo == 'Motocicleta'){
            showBlockSearchMoto = true;
            showBlockSearchCar = false;
            recibo.RecordTypeId = '0120P000000ESxK';
        }else{
            showBlockSearchCar = false;
            showBlockSearchMoto = false;
        }
    }
    
    //Metodo para realizar el calculo del avaluo de autos
    public void Buscar() {  
        Double sumavalorfinal = 0;
        Double sumavalorSugerido = 0;
        Double sumavalorInventario = 0;
        Double sumaReciboJefeUsado = 0;
        Double sumaValorFinalSugerido = 0;
        Double sumaMargenReal = 0;
        Double Average = 0;
        Boolean sinErrores = true;
        Boolean sumoAnio = false;
        Boolean restoAnio = false;
        Double sumValorFinalVenta = 0;
        Integer count = 0; 
        
        //Consulta los valores de Recibo
        if(reciboId != null && reciboId != ''){
            //Aqui
            recibo = [Select Id, Name, Marca__c, Ano__c, Combustible__c, EstiloUsado__c, Traccion__c, Trasmision__c, Modelo__c,
                        Valor_final__c, Valor_minimo__c, Valor_maximo__c, Valor_promedio__c, ReciboJefeUsados__c, Valor_sugerido_de_recibo__c, 
                        ValorReciboCliente__c, Cantidad_revendedor__c, Score__c, Bucket_Score__c, Semaforo_Bucket__c, Valor_sugerido_de_recibo_minimo__c,
                        Valor_sugerido_de_recibo_maximo__c, Dias_inventario_promedio__c, Valor_ultima_venta__c, Valor_Sugerido_Venta__c
                        From ReciboUsado__c 
                        where Id =: reciboId];
        }else{
            System.debug(' ** Marca ** ' + recibo.Marca__c);
            if(recibo.Marca__c == null || recibo.Marca__c == ''){
                sinErrores = false;
                ApexPages.addMessage(New ApexPages.Message(ApexPages.Severity.ERROR, 'Campo Marca Obligatorio'));
            }else if(recibo.Ano__c == null || recibo.Ano__c == ''){
                sinErrores = false;
                ApexPages.addMessage(New ApexPages.Message(ApexPages.Severity.ERROR, 'Campo Año Obligatorio'));
            }/*else if(recibo.Modelo__c == null || recibo.Modelo__c == ''){
                sinErrores = false;
                ApexPages.addMessage(New ApexPages.Message(ApexPages.Severity.ERROR, 'Campo Modelo Obligatorio'));
            }*/else if(recibo.EstiloUsado__c == null || recibo.EstiloUsado__c == ''){
                sinErrores = false;
                ApexPages.addMessage(New ApexPages.Message(ApexPages.Severity.ERROR, 'Campo Carrocería Obligatorio'));
            }else if(recibo.Trasmision__c == null || recibo.Trasmision__c == ''){
                sinErrores = false;
                ApexPages.addMessage(New ApexPages.Message(ApexPages.Severity.ERROR, 'Campo Trasmisión Obligatorio'));
            }else if(recibo.Combustible__c == null || recibo.Combustible__c == ''){
                sinErrores = false;
                ApexPages.addMessage(New ApexPages.Message(ApexPages.Severity.ERROR, 'Campo Combustible Obligatorio'));
            }else if(recibo.Traccion__c == null || recibo.Traccion__c == ''){
                sinErrores = false;
                ApexPages.addMessage(New ApexPages.Message(ApexPages.Severity.ERROR, 'Campo Tracción Obligatorio'));
            }
        }

        if(sinErrores){
            //Valor MIN
            List<ReciboUsado__c> valorMinimo = [Select Id, Valor_final__c 
                                                From ReciboUsado__c 
                                                Where Marca__c =: recibo.Marca__c and Ano__c =: recibo.Ano__c and 
                                                    EstiloUsado__c =: recibo.EstiloUsado__c and Trasmision__c =: recibo.Trasmision__c and  
                                                    Combustible__c =: recibo.Combustible__c and Traccion__c =: recibo.Traccion__c and Valor_final__c > 0];
            if(valorMinimo.isEmpty() && valorMinimo.size() == 0 ){
                System.debug(' ** SE SUMA UN AÑO MAS ** ');
                recibo.Ano__c = String.valueOf(Integer.valueOf(recibo.Ano__c) + 1);
                sumoAnio = true;
                valorMinimo = [Select Id, Valor_final__c 
                                                From ReciboUsado__c 
                                                Where Marca__c =: recibo.Marca__c and Ano__c =: recibo.Ano__c and 
                                                    EstiloUsado__c =: recibo.EstiloUsado__c and Trasmision__c =: recibo.Trasmision__c and  
                                                    Combustible__c =: recibo.Combustible__c and Traccion__c =: recibo.Traccion__c and Valor_final__c > 0];
            }
            if(valorMinimo.isEmpty() && valorMinimo.size() == 0 ){
                System.debug(' ** SE RESTA UN AÑO MAS ** ');
                recibo.Ano__c = String.valueOf(Integer.valueOf(recibo.Ano__c) - 2);
                sumoAnio = false;
                restoAnio = true;
                valorMinimo = [Select Id, Valor_final__c 
                                                From ReciboUsado__c 
                                                Where Marca__c =: recibo.Marca__c and Ano__c =: recibo.Ano__c and 
                                                    EstiloUsado__c =: recibo.EstiloUsado__c and Trasmision__c =: recibo.Trasmision__c and  
                                                    Combustible__c =: recibo.Combustible__c and Traccion__c =: recibo.Traccion__c and Valor_final__c > 0];
            }
            System.debug('***LIST Valor minim: ' + valorMinimo);
            System.debug('***LIST Valor minim: ' + valorMinimo.size());

            //Valor MAX
            List<ReciboUsado__c> valorMaximo = [Select Id, Valor_final__c 
                                                From ReciboUsado__c 
                                                Where Marca__c =: recibo.Marca__c and Ano__c =: recibo.Ano__c and 
                                                    EstiloUsado__c =: recibo.EstiloUsado__c and Trasmision__c =: recibo.Trasmision__c and 
                                                    Combustible__c =: recibo.Combustible__c and Traccion__c =: recibo.Traccion__c and Valor_final__c > 0];
            if(valorMaximo.isEmpty() && valorMaximo.size() == 0 ){
                System.debug(' ** SE SUMA UN AÑO MAS ** ');
                recibo.Ano__c = String.valueOf(Integer.valueOf(recibo.Ano__c) + 1);
                sumoAnio = true;
                valorMaximo = [Select Id, Valor_final__c 
                                                From ReciboUsado__c 
                                                Where Marca__c =: recibo.Marca__c and Ano__c =: recibo.Ano__c and 
                                                    EstiloUsado__c =: recibo.EstiloUsado__c and Trasmision__c =: recibo.Trasmision__c and 
                                                    Combustible__c =: recibo.Combustible__c and Traccion__c =: recibo.Traccion__c and Valor_final__c > 0];
            }
            if(valorMaximo.isEmpty() && valorMaximo.size() == 0 ){
                System.debug(' ** SE RESTA UN AÑO MAS ** ');
                recibo.Ano__c = String.valueOf(Integer.valueOf(recibo.Ano__c) - 2);
                sumoAnio = false;
                restoAnio = true;
                valorMaximo = [Select Id, Valor_final__c 
                                                From ReciboUsado__c 
                                                Where Marca__c =: recibo.Marca__c and Ano__c =: recibo.Ano__c and 
                                                    EstiloUsado__c =: recibo.EstiloUsado__c and Trasmision__c =: recibo.Trasmision__c and 
                                                    Combustible__c =: recibo.Combustible__c and Traccion__c =: recibo.Traccion__c and Valor_final__c > 0];
            }
            System.debug('***LIST Valor minim: ' + valorMaximo);
            System.debug('***LIST Valor minim: ' + valorMaximo.size());

            //Valor Promedio
            List<ReciboUsado__c> valorPromedio = [Select Id, Valor_final__c 
                                                    From ReciboUsado__c 
                                                    Where Marca__c =: recibo.Marca__c and Ano__c =: recibo.Ano__c and 
                                                        EstiloUsado__c =: recibo.EstiloUsado__c and Trasmision__c =: recibo.Trasmision__c and 
                                                        Combustible__c =: recibo.Combustible__c and Traccion__c =: recibo.Traccion__c and Valor_final__c > 0];

            //Valor ultima venta: Valor de la última unidad (Marca y modelo) vendida
            List<ReciboUsado__c> ultimoRegistroCreado = [Select Id, Valor_final__c, Fecha_de_recibo__c
                                                            From ReciboUsado__c 
                                                            Where Marca__c =: recibo.Marca__c and Ano__c =: recibo.Ano__c and 
                                                            EstiloUsado__c =: recibo.EstiloUsado__c and Trasmision__c =: recibo.Trasmision__c and 
                                                            Combustible__c =: recibo.Combustible__c and Traccion__c =: recibo.Traccion__c and Valor_final__c > 0 ORDER BY Fecha_de_recibo__c DESC LIMIT 1 ];
            if(ultimoRegistroCreado.isEmpty() && ultimoRegistroCreado.size() == 0 ){
                System.debug(' ** SE SUMA UN AÑO MAS ** ');
                recibo.Ano__c = String.valueOf(Integer.valueOf(recibo.Ano__c) + 1);
                sumoAnio = true;
                ultimoRegistroCreado = [Select Id, Valor_final__c, Fecha_de_recibo__c
                                        From ReciboUsado__c 
                                        Where Marca__c =: recibo.Marca__c and Ano__c =: recibo.Ano__c and 
                                        EstiloUsado__c =: recibo.EstiloUsado__c and Trasmision__c =: recibo.Trasmision__c and 
                                        Combustible__c =: recibo.Combustible__c and Traccion__c =: recibo.Traccion__c and Valor_final__c > 0 ORDER BY Fecha_de_recibo__c DESC LIMIT 1 ];
            }
            if(ultimoRegistroCreado.isEmpty() && ultimoRegistroCreado.size() == 0 ){
                System.debug(' ** SE RESTA UN AÑO MAS ** ');
                recibo.Ano__c = String.valueOf(Integer.valueOf(recibo.Ano__c) - 2);
                sumoAnio = false;
                restoAnio = true;
                ultimoRegistroCreado = [Select Id, Valor_final__c, Fecha_de_recibo__c
                                        From ReciboUsado__c 
                                        Where Marca__c =: recibo.Marca__c and Ano__c =: recibo.Ano__c and 
                                        EstiloUsado__c =: recibo.EstiloUsado__c and Trasmision__c =: recibo.Trasmision__c and 
                                        Combustible__c =: recibo.Combustible__c and Traccion__c =: recibo.Traccion__c and Valor_final__c > 0 ORDER BY Fecha_de_recibo__c DESC LIMIT 1 ];
            }
            System.debug('***LIST Valor minim: ' + ultimoRegistroCreado);
            System.debug('***LIST Valor minim: ' + ultimoRegistroCreado.size());
            
            List<ReciboUsado__c> ultimaVenta = [Select Id, Valor_final__c, Fecha_de_venta__c
                                                From ReciboUsado__c 
                                                Where Marca__c =: recibo.Marca__c and Ano__c =: recibo.Ano__c and 
                                                    EstiloUsado__c =: recibo.EstiloUsado__c and Trasmision__c =: recibo.Trasmision__c and 
                                                    Combustible__c =: recibo.Combustible__c and Traccion__c =: recibo.Traccion__c and Valor_final__c > 0 
                                                    ORDER BY Fecha_de_venta__c DESC LIMIT 1 ];

            //Valor Inventario promedio Promedio ( Fecha de Venta – Fecha de Recibo )
            List<ReciboUsado__c> inventarioPromedio = [Select Id, Dias_en_Inventario__c, Revendedor__c, Valor_final__c 
                                                        From ReciboUsado__c 
                                                        Where Marca__c =: recibo.Marca__c and Ano__c =: recibo.Ano__c and 
                                                            EstiloUsado__c =: recibo.EstiloUsado__c and Trasmision__c =: recibo.Trasmision__c and 
                                                            Combustible__c =: recibo.Combustible__c and Traccion__c =: recibo.Traccion__c and Valor_final__c > 0];
            System.debug(' ** lista inventario size ** ' + inventarioPromedio.size());

            //Valor Sugerido de Venta
            List<ReciboUsado__c> reciboSugeridoVenta = [Select Id, ReciboJefeUsados__c, Valor_final__c, ValorReciboCliente__c, Valor_sugerido_de_recibo__c 
                                                        From ReciboUsado__c 
                                                        Where Marca__c =: recibo.Marca__c and Ano__c =: recibo.Ano__c and 
                                                            EstiloUsado__c =: recibo.EstiloUsado__c and Trasmision__c =: recibo.Trasmision__c and 
                                                            Combustible__c =: recibo.Combustible__c and Traccion__c =: recibo.Traccion__c];
            //Calculo Suma Cantidad Revendedor
            if(!inventarioPromedio.isEmpty() && inventarioPromedio.size() > 0){
                recibo.Cantidad_revendedor__c = 0;
                for(ReciboUsado__c r : inventarioPromedio){
                    if(r.Revendedor__c){
                        recibo.Cantidad_revendedor__c = recibo.Cantidad_revendedor__c + 1;
                    }
                }
            }
            recibo.Valor_minimo__c = 1000000;
            if(!valorMinimo.isEmpty() && valorMinimo.size() > 0){
                for(ReciboUsado__c item : valorMinimo){
                    if(item.Valor_final__c != null && recibo.Valor_minimo__c > item.Valor_final__c){
                        recibo.Valor_minimo__c = item.Valor_final__c;
                    }
                }
                if(recibo.Valor_minimo__c == 1000000){
                    recibo.Valor_minimo__c  = 0;
                }
            }else{
                recibo.Valor_minimo__c = 0;
            }
            recibo.Valor_maximo__c = 0;
            if(!valorMaximo.isEmpty() && valorMaximo.size() > 0){
                for(ReciboUsado__c item : valorMaximo){
                    if(item.Valor_final__c != null && item.Valor_final__c > 0 && item.Valor_final__c > recibo.Valor_maximo__c){
                        recibo.Valor_maximo__c = item.Valor_final__c;
                    }
                }
            }
            if((recibo.Valor_minimo__c == null || recibo.Valor_minimo__c == 0) && (recibo.Valor_maximo__c == null || recibo.Valor_maximo__c ==0)){
                ApexPages.addMessage(New ApexPages.Message(ApexPages.Severity.WARNING, 'La unidad consultada no tiene valor de venta historico.'));
            }else{
                recibo.Valor_ultima_venta__c = ultimaVenta[0].Valor_final__c;
                //Valor promedio
                for(ReciboUsado__c ru : valorPromedio){
                    if(ru.Valor_final__c != null) {
                        sumavalorfinal = sumavalorfinal + ru.Valor_final__c;
                        count = count + 1;
                    } 
                } 
                recibo.Valor_promedio__c = sumavalorfinal / count;         
              
                //Dias promedio de inventario
                count = 0;
                for(ReciboUsado__c ru : inventarioPromedio){
                    if(ru.Dias_en_Inventario__c != null && ru.Valor_final__c > 0){
                        sumavalorInventario= sumavalorInventario + ru.Dias_en_Inventario__c; 
                        count = count + 1;
                    }
                }
                recibo.Dias_inventario_promedio__c = sumavalorInventario/inventarioPromedio.Size();         
          
                //Valor Sugerido de Venta -reciboSugeridoVenta
                System.debug(' ** lista recibo usados base ** ' + reciboSugeridoVenta);
                for(ReciboUsado__c ru : reciboSugeridoVenta){
                    if(ru.Valor_final__c != null && ru.Valor_final__c > 0){
                        if(ru.ReciboJefeUsados__c != null && ru.ReciboJefeUsados__c > 0){
                            sumaReciboJefeUsado = sumaReciboJefeUsado + ru.ReciboJefeUsados__c;
                        }else if(ru.ValorReciboCliente__c != null && ru.ValorReciboCliente__c > 0){
                            sumaReciboJefeUsado = sumaReciboJefeUsado + ru.ValorReciboCliente__c;
                        }                    
                        if(ru.Valor_final__c != null && ru.Valor_final__c > 0){
                            sumaValorFinalSugerido = sumaValorFinalSugerido + ru.Valor_final__c;
                        }
                    }
                }
                System.debug(' ** total recibo jefe usado ** ' + sumaReciboJefeUsado);
                System.debug(' ** total valor final ** ' + sumaValorFinalSugerido);
                sumaMargenReal = ((sumaValorFinalSugerido - sumaReciboJefeUsado) / sumaReciboJefeUsado); 
                System.debug(' ** suma margen real ** ' + sumaMargenReal);
                Average = sumaMargenReal;
                if(reciboId != null && reciboId != ''){
                    if(recibo.ReciboJefeUsados__c > 0 && recibo.ReciboJefeUsados__c != null){
                        System.debug(' ** monto recibo jefe usado base, valor sugerido recibo ** ' + recibo.ReciboJefeUsados__c);
                        recibo.Valor_sugerido_de_recibo__c = recibo.ReciboJefeUsados__c;
                    }else if(recibo.ValorReciboCliente__c != null && recibo.ValorReciboCliente__c > 0){
                        System.debug(' ** monto valor avaluo base, valor sugerido recibo ** ' + recibo.ReciboJefeUsados__c);
                        recibo.Valor_sugerido_de_recibo__c = recibo.ValorReciboCliente__c;
                    }
                    if(recibo.ReciboJefeUsados__c > 0 && recibo.ReciboJefeUsados__c != null){
                        System.debug(' ** monto recibo jefe usado base, valor sugerido venta ** ' + recibo.ReciboJefeUsados__c);
                        recibo.Valor_Sugerido_Venta__c = recibo.ReciboJefeUsados__c * (1 + Average);
                    }else if(recibo.ValorReciboCliente__c != null && recibo.ValorReciboCliente__c > 0){
                        System.debug(' ** monto valor avaluo base, valor sugerido venta ** ' + recibo.ReciboJefeUsados__c);
                        recibo.Valor_Sugerido_Venta__c = recibo.ValorReciboCliente__c * (1 + Average);
                    }
                }else{
                    Date paramDate, paramDate2;
                    if(!ultimoRegistroCreado.isEmpty() && ultimoRegistroCreado.size() > 0){
                        paramDate = ultimoRegistroCreado[0].Fecha_de_recibo__c;
                        paramDate2 = paramDate.addMonths(-3);
                        System.debug(' ** fecha 1 ** ' + paramDate);
                        System.debug(' ** fecha  2 **  ' + paramDate2);
                        
                        List<ReciboUsado__c> listTemp = [SELECT Id, ValorReciboCliente__c, Fecha_de_recibo__c, Score__c, ReciboJefeUsados__c, Valor_final__c
                                                            FROM ReciboUsado__c 
                                                            WHERE Marca__c =: recibo.Marca__c AND Ano__c =: recibo.Ano__c AND 
                                                            EstiloUsado__c =: recibo.EstiloUsado__c AND Trasmision__c =: recibo.Trasmision__c AND 
                                                            Combustible__c =: recibo.Combustible__c AND Fecha_de_recibo__c >= :paramDate2 AND Fecha_de_recibo__c <= :paramDate];
                        recibo.Valor_sugerido_de_recibo__c = 0;
                        System.debug(' ** LISTA RECIBO USADOS CONSULTA ** ' + listTemp);
                        if(!listTemp.isEmpty() && listTemp.size() > 0){
                            Double montoDepreciacion = 0;
                            Double saldoInicial = 0;
                            Double valorAvaluoDepreciado = 0;
                            Double margen = 0;
                            Double sumMargen = 0;
                            Integer annoDiferencia = 0; 
                            Integer countTemp = 0;
                            Integer countTemp2 = 0;  
                            Double margenUtilidadObjetivo = Double.valueOf(LABEL.MargenUtilidadObjetivoAuto);

                            System.debug(' ** MARGEN UTILIDAD OBJETIVO ** ' + margenUtilidadObjetivo);
                            recibo.Score__c = 0;
                            sumaReciboJefeUsado = 0;
                            count = 0;
                            countTemp = 0;

                            for(ReciboUsado__c r : listTemp){
                                if(r.Valor_final__c != null && r.Valor_final__c > 0){
                                    System.debug(' ** RECIBO USADO ** ' + r);
                                    if(r.ReciboJefeUsados__c != null && r.ReciboJefeUsados__c > 0){
                                        annoDiferencia = System.Date.today().year() - Integer.valueOf(r.Fecha_de_recibo__c.year());
                                        System.debug(' ** DIFERENCIA DE ANIOS ** ' + annoDiferencia);
                                        saldoInicial = r.ReciboJefeUsados__c;
                                        while(countTemp < annoDiferencia){
                                            System.debug(' ** SALDO INICIAL ** ' + saldoInicial);
                                            montoDepreciacion = saldoInicial * 0.10;
                                            System.debug(' ** MONTO DEPRECIACION ** ' + montoDepreciacion);
                                            saldoInicial = saldoInicial - montoDepreciacion;
                                            System.debug(' ** SALDO INICIAL ** ' + saldoInicial);
                                            countTemp =  countTemp + 1;
                                        }
                                        countTemp = 0;
                                        count = count + 1;
                                        valorAvaluoDepreciado = valorAvaluoDepreciado + saldoInicial;
                                        System.debug(' ** VALOR AVALUO DEPRECIADO ** ' + valorAvaluoDepreciado);
                                        margen = (r.Valor_final__c / r.ReciboJefeUsados__c) - 1;
                                        System.debug(' ** MARGEN ** ' + margen);
                                        sumMargen = sumMargen + margen;
                                        System.debug(' ** SUMATORIA MARGEN ** ' + sumMargen);
                                        if(r.Score__c != null){
                                            recibo.Score__c = recibo.Score__c + r.Score__c;
                                        }
                                        countTemp2 = countTemp2 + 1;
                                    }else if(r.ValorReciboCliente__c != null && r.ValorReciboCliente__c > 0){
                                        annoDiferencia = System.Date.today().year() - Integer.valueOf(r.Fecha_de_recibo__c.year());
                                        System.debug(' ** DIFERENCIA DE ANIOS ** ' + annoDiferencia);
                                        saldoInicial = r.ValorReciboCliente__c;
                                        while(countTemp < annoDiferencia){
                                            System.debug(' ** SALDO INICIAL ** ' + saldoInicial);
                                            montoDepreciacion = saldoInicial * 0.10;
                                            System.debug(' ** MONTO DEPRECIACION ** ' + montoDepreciacion);
                                            saldoInicial = saldoInicial - montoDepreciacion;
                                            System.debug(' ** SALDO INICIAL ** ' + saldoInicial);
                                            countTemp =  countTemp + 1;
                                        }
                                        countTemp = 0;
                                        count = count + 1;
                                        valorAvaluoDepreciado = valorAvaluoDepreciado + saldoInicial;
                                        System.debug(' ** VALOR AVALUO DEPRECIADO ** ' + valorAvaluoDepreciado);
                                        margen = (r.Valor_final__c / r.ValorReciboCliente__c) - 1;
                                        System.debug(' ** MARGEN ** ' + margen);
                                        sumMargen = sumMargen + margen;
                                        System.debug(' ** SUMATORIA MARGEN ** ' + sumMargen);
                                        if(r.Score__c != null){
                                            recibo.Score__c = recibo.Score__c + r.Score__c;
                                        }
                                        countTemp2 = countTemp2 + 1;
                                    }
                                }
                            }
                            sumMargen = sumMargen / countTemp2;
                            System.debug(' ** PROMEDIO MARGEN ** ' + sumMargen);
                            recibo.Valor_sugerido_de_recibo__c = valorAvaluoDepreciado / countTemp2;
                            if(sumoAnio){
                                recibo.Valor_sugerido_de_recibo__c = recibo.Valor_sugerido_de_recibo__c * 0.9;
                            }
                            if(restoAnio){
                                recibo.Valor_sugerido_de_recibo__c = recibo.Valor_sugerido_de_recibo__c * 1.10;
                            }
                            if(sumMargen < margenUtilidadObjetivo){
                                recibo.Valor_Sugerido_Venta__c = recibo.Valor_sugerido_de_recibo__c * (1 + margenUtilidadObjetivo);
                            }else{
                                recibo.Valor_Sugerido_Venta__c = recibo.Valor_sugerido_de_recibo__c * (1 + sumMargen);
                            } 
                            recibo.Score__c = recibo.Score__c / countTemp2;
                            if(recibo.Score__c <= 300){
                                recibo.Bucket_Score__c = '1-300';
                            }else if(recibo.Score__c >= 301 && recibo.Score__c <= 600){
                                recibo.Bucket_Score__c = '301-600';
                            }else{
                                recibo.Bucket_Score__c = '601-999';
                            }
                        }
                    }
                }
            }
        }
    }

    /**
    * @description metodo para calcular el avaluo de motos
    */ 
    public void BuscarMoto() {  
        Double sumavalorfinal = 0;
        Double sumavalorSugerido = 0;
        Double sumavalorInventario = 0;
        Double sumaReciboJefeUsado = 0;
        Double sumaValorFinalSugerido = 0;
        Double sumaMargenReal = 0;
        Double Average = 0;
        Boolean sinErrores = true;
        Boolean sumoAnio = false;
        Boolean restoAnio = false;
        Integer count = 0;
        
        System.debug(' ** METODO MOTOCICLETA ** '); 
        //Consulta los valores de Recibo
        if(reciboId != null && reciboId != ''){
            recibo = [Select Id, Name, Marca__c, Ano__c, Modelo__c, Valor_final__c, Valor_minimo__c, Valor_maximo__c, Valor_promedio__c, ReciboJefeUsados__c, 
                        Valor_sugerido_de_recibo__c, ValorReciboCliente__c, Cantidad_revendedor__c, Score__c, Score_Motos__c, Bucket_Score__c, 
                        Semaforo_Bucket__c, Semaforo_Bucket_Motos__c, Valor_sugerido_de_recibo_minimo__c, Valor_sugerido_de_recibo_maximo__c, Cilindraje__c, 
                        Segmento__c, Gama__c, Dias_inventario_promedio__c, Valor_ultima_venta__c, Valor_Sugerido_Venta__c
                        From ReciboUsado__c 
                        where Id =: reciboId];
        }else{
            System.debug(' ** Marca ** ' + recibo.Marca__c);
            if(recibo.Marca__c == null || recibo.Marca__c == ''){
                sinErrores = false;
                ApexPages.addMessage(New ApexPages.Message(ApexPages.Severity.ERROR, 'Campo Marca Obligatorio'));
            }else if(recibo.Ano__c == null || recibo.Ano__c == ''){
                sinErrores = false;
                ApexPages.addMessage(New ApexPages.Message(ApexPages.Severity.ERROR, 'Campo Año Obligatorio'));
            }else if(recibo.Modelo__c == null || recibo.Modelo__c == ''){
                sinErrores = false;
                ApexPages.addMessage(New ApexPages.Message(ApexPages.Severity.ERROR, 'Campo Modelo Obligatorio'));
            }else if(recibo.Cilindraje__c == null || recibo.Cilindraje__c == 0){
                sinErrores = false;
                ApexPages.addMessage(New ApexPages.Message(ApexPages.Severity.ERROR, 'Campo Cilindraje Obligatorio'));
            }else if(recibo.Segmento__c == null || recibo.Segmento__c == ''){
                sinErrores = false;
                ApexPages.addMessage(New ApexPages.Message(ApexPages.Severity.ERROR, 'Campo Segmento Obligatorio'));
            }else if(recibo.Gama__c == null || recibo.Gama__c == ''){
                sinErrores = false;
                ApexPages.addMessage(New ApexPages.Message(ApexPages.Severity.ERROR, 'Campo Gama Obligatorio'));
            }
        }

        if(sinErrores){
            System.debug(' ** RECIBO USADO ** ' + recibo);
            //Valor MIN
            List<ReciboUsado__c> valorMinimo = [Select Id, Valor_final__c 
                                                From ReciboUsado__c 
                                                Where Marca__c =: recibo.Marca__c and Ano__c =: recibo.Ano__c and 
                                                    Modelo__c =: recibo.Modelo__c and Cilindraje__c =: recibo.Cilindraje__c and  
                                                    Segmento__c =: recibo.Segmento__c and Gama__c =: recibo.Gama__c and Valor_final__c > 0];
            if(valorMinimo.isEmpty() && valorMinimo.size() == 0){
                System.debug(' ** SE SUMA UN AÑO MAS ** ');
                recibo.Ano__c = String.valueOf(Integer.valueOf(recibo.Ano__c) + 1);
                sumoAnio = true;
                valorMinimo = [Select Id, Valor_final__c 
                                                From ReciboUsado__c 
                                                Where Marca__c =: recibo.Marca__c and Ano__c =: recibo.Ano__c and 
                                                    Modelo__c =: recibo.Modelo__c and Cilindraje__c =: recibo.Cilindraje__c and  
                                                    Segmento__c =: recibo.Segmento__c and Gama__c =: recibo.Gama__c and Valor_final__c > 0];
            }
            if(valorMinimo.isEmpty() && valorMinimo.size() == 0){
                System.debug(' ** SE RESTA UN AÑO MAS ** ');
                recibo.Ano__c = String.valueOf(Integer.valueOf(recibo.Ano__c) - 2);
                sumoAnio = false;
                restoAnio = true;
                valorMinimo = [Select Id, Valor_final__c 
                                                From ReciboUsado__c 
                                                Where Marca__c =: recibo.Marca__c and Ano__c =: recibo.Ano__c and 
                                                    Modelo__c =: recibo.Modelo__c and Cilindraje__c =: recibo.Cilindraje__c and  
                                                    Segmento__c =: recibo.Segmento__c and Gama__c =: recibo.Gama__c and Valor_final__c > 0];
            }
            System.debug('***LIST Valor minim: ' + valorMinimo);
            System.debug('***LIST Valor minim: ' + valorMinimo.size());

            //Valor MAX
            List<ReciboUsado__c> valorMaximo = [Select Id, Valor_final__c 
                                                From ReciboUsado__c 
                                                Where Marca__c =: recibo.Marca__c and Ano__c =: recibo.Ano__c and 
                                                    Modelo__c =: recibo.Modelo__c and Cilindraje__c =: recibo.Cilindraje__c and  
                                                    Segmento__c =: recibo.Segmento__c and Gama__c =: recibo.Gama__c and Valor_final__c > 0];
            if(valorMaximo.isEmpty() && valorMaximo.size() == 0){
                System.debug(' ** SE SUMA UN AÑO MAS ** ');
                recibo.Ano__c = String.valueOf(Integer.valueOf(recibo.Ano__c) + 1);
                sumoAnio = true;
                valorMaximo = [Select Id, Valor_final__c 
                                                From ReciboUsado__c 
                                                Where Marca__c =: recibo.Marca__c and Ano__c =: recibo.Ano__c and 
                                                    Modelo__c =: recibo.Modelo__c and Cilindraje__c =: recibo.Cilindraje__c and  
                                                    Segmento__c =: recibo.Segmento__c and Gama__c =: recibo.Gama__c and Valor_final__c > 0];
            }
            if(valorMaximo.isEmpty() && valorMaximo.size() == 0){
                System.debug(' ** SE RESTA UN AÑO MAS ** ');
                recibo.Ano__c = String.valueOf(Integer.valueOf(recibo.Ano__c) - 2);
                sumoAnio = false;
                restoAnio = true;
                valorMaximo = [Select Id, Valor_final__c 
                                                From ReciboUsado__c 
                                                Where Marca__c =: recibo.Marca__c and Ano__c =: recibo.Ano__c and 
                                                    Modelo__c =: recibo.Modelo__c and Cilindraje__c =: recibo.Cilindraje__c and  
                                                    Segmento__c =: recibo.Segmento__c and Gama__c =: recibo.Gama__c and Valor_final__c > 0];
            }
            System.debug('***LIST Valor max: ' + valorMaximo);
            System.debug('***LIST Valor max: ' + valorMaximo.size());

            //Valor Promedio
            List<ReciboUsado__c> valorPromedio = [Select Id, Valor_final__c 
                                                    From ReciboUsado__c 
                                                    Where Marca__c =: recibo.Marca__c and Ano__c =: recibo.Ano__c and 
                                                    Modelo__c =: recibo.Modelo__c and Cilindraje__c =: recibo.Cilindraje__c and  
                                                    Segmento__c =: recibo.Segmento__c and Gama__c =: recibo.Gama__c and Valor_final__c > 0];

            //Valor ultima venta: Valor de la última unidad (Marca y modelo) vendida
            List<ReciboUsado__c> ultimoRegistroCreado = [Select Id, Valor_final__c, Fecha_de_recibo__c
                                                From ReciboUsado__c 
                                                Where Marca__c =: recibo.Marca__c and Ano__c =: recibo.Ano__c and 
                                                    Modelo__c =: recibo.Modelo__c and Cilindraje__c =: recibo.Cilindraje__c and  
                                                    Segmento__c =: recibo.Segmento__c and Gama__c =: recibo.Gama__c and Valor_final__c > 0 
                                                    ORDER BY Fecha_de_recibo__c DESC LIMIT 1 ];
            if(ultimoRegistroCreado.isEmpty() && ultimoRegistroCreado.size() == 0){
                System.debug(' ** SE SUMA UN AÑO MAS ** ');
                recibo.Ano__c = String.valueOf(Integer.valueOf(recibo.Ano__c) + 1);
                sumoAnio = true;
                ultimoRegistroCreado = [Select Id, Valor_final__c, Fecha_de_recibo__c
                                                From ReciboUsado__c 
                                                Where Marca__c =: recibo.Marca__c and Ano__c =: recibo.Ano__c and 
                                                    Modelo__c =: recibo.Modelo__c and Cilindraje__c =: recibo.Cilindraje__c and  
                                                    Segmento__c =: recibo.Segmento__c and Gama__c =: recibo.Gama__c and Valor_final__c > 0 
                                                    ORDER BY Fecha_de_recibo__c DESC LIMIT 1 ];
            }
            if(ultimoRegistroCreado.isEmpty() && ultimoRegistroCreado.size() == 0){
                System.debug(' ** SE RESTA UN AÑO MAS ** ');
                recibo.Ano__c = String.valueOf(Integer.valueOf(recibo.Ano__c) - 2);
                sumoAnio = false;
                restoAnio = true;
                ultimoRegistroCreado = [Select Id, Valor_final__c, Fecha_de_recibo__c
                                                From ReciboUsado__c 
                                                Where Marca__c =: recibo.Marca__c and Ano__c =: recibo.Ano__c and 
                                                    Modelo__c =: recibo.Modelo__c and Cilindraje__c =: recibo.Cilindraje__c and  
                                                    Segmento__c =: recibo.Segmento__c and Gama__c =: recibo.Gama__c and Valor_final__c > 0 
                                                    ORDER BY Fecha_de_recibo__c DESC LIMIT 1 ];
            }

            List<ReciboUsado__c> ultimaVenta = [Select Id, Valor_final__c, Fecha_de_venta__c
                                                From ReciboUsado__c 
                                                Where Marca__c =: recibo.Marca__c and Ano__c =: recibo.Ano__c and 
                                                    Modelo__c =: recibo.Modelo__c and Cilindraje__c =: recibo.Cilindraje__c and  
                                                    Segmento__c =: recibo.Segmento__c and Gama__c =: recibo.Gama__c and Valor_final__c > 0 
                                                    ORDER BY Fecha_de_venta__c DESC LIMIT 1 ];

            //Valor Inventario promedio Promedio ( Fecha de Venta – Fecha de Recibo )
            List<ReciboUsado__c> inventarioPromedio = [Select Id, Dias_en_Inventario__c, Revendedor__c, Valor_final__c 
                                                        From ReciboUsado__c 
                                                        Where Marca__c =: recibo.Marca__c and Ano__c =: recibo.Ano__c and 
                                                            Modelo__c =: recibo.Modelo__c and Cilindraje__c =: recibo.Cilindraje__c and  
                                                            Segmento__c =: recibo.Segmento__c and Gama__c =: recibo.Gama__c and Valor_final__c > 0];
            System.debug(' ** lista inventario size ** ' + inventarioPromedio.size());

            //Valor Sugerido de Venta
            List<ReciboUsado__c> reciboSugeridoVenta = [Select Id, ReciboJefeUsados__c, Valor_final__c, ValorReciboCliente__c, Valor_sugerido_de_recibo__c,
                                                        Fecha_de_recibo__c 
                                                        From ReciboUsado__c 
                                                        Where Marca__c =: recibo.Marca__c and Ano__c =: recibo.Ano__c and 
                                                            Modelo__c =: recibo.Modelo__c and Cilindraje__c =: recibo.Cilindraje__c and  
                                                            Segmento__c =: recibo.Segmento__c and Gama__c =: recibo.Gama__c];
            //Calculo Suma Cantidad Revendedor
            if(!inventarioPromedio.isEmpty() && inventarioPromedio.size() > 0){
                recibo.Cantidad_revendedor__c = 0;
                for(ReciboUsado__c r : inventarioPromedio){
                    if(r.Revendedor__c){
                        recibo.Cantidad_revendedor__c = recibo.Cantidad_revendedor__c + 1;
                    }
                }
            }
            recibo.Valor_minimo__c = 1000000;
            if(!valorMinimo.isEmpty() && valorMinimo.size() > 0){
                for(ReciboUsado__c item : valorMinimo){
                    if(item.Valor_final__c != null && recibo.Valor_minimo__c > item.Valor_final__c){
                        recibo.Valor_minimo__c = item.Valor_final__c;
                    }
                }
                if(recibo.Valor_minimo__c == 1000000){
                    recibo.Valor_minimo__c  = 0;
                }
            }else{
                recibo.Valor_minimo__c = 0;
            }
            recibo.Valor_maximo__c = 0;
            if(!valorMaximo.isEmpty() && valorMaximo.size() > 0){
                for(ReciboUsado__c item : valorMaximo){
                    if(item.Valor_final__c != null && item.Valor_final__c > 0 && item.Valor_final__c > recibo.Valor_maximo__c){
                        recibo.Valor_maximo__c = item.Valor_final__c;
                    }
                }
            }
            if((recibo.Valor_minimo__c == null || recibo.Valor_minimo__c == 0) && (recibo.Valor_maximo__c == null || recibo.Valor_maximo__c ==0)){
                ApexPages.addMessage(New ApexPages.Message(ApexPages.Severity.WARNING, 'La unidad consultada no tiene valor de venta historico.'));
            }else{
                recibo.Valor_ultima_venta__c = ultimaVenta[0].Valor_final__c;
                //Valor promedio
                for(ReciboUsado__c ru : valorPromedio){
                    if(ru.Valor_final__c != null) {
                        sumavalorfinal = sumavalorfinal + ru.Valor_final__c;
                        count = count + 1;
                    } 
                } 
                recibo.Valor_promedio__c = sumavalorfinal / count;         
              
                //Dias promedio de inventario
                count = 0;
                for(ReciboUsado__c ru : inventarioPromedio){
                    if(ru.Dias_en_Inventario__c != null && ru.Valor_final__c > 0){
                        sumavalorInventario= sumavalorInventario + ru.Dias_en_Inventario__c; 
                        count = count + 1;
                    }
                }
                recibo.Dias_inventario_promedio__c = sumavalorInventario/inventarioPromedio.Size();         
          
                //Valor Sugerido de Venta -reciboSugeridoVenta
                System.debug(' ** lista recibo usados base ** ' + reciboSugeridoVenta);
                for(ReciboUsado__c ru : reciboSugeridoVenta){
                    if(ru.Valor_final__c != null && ru.Valor_final__c > 0){
                        if(ru.ReciboJefeUsados__c != null && ru.ReciboJefeUsados__c > 0){
                            sumaReciboJefeUsado = sumaReciboJefeUsado + ru.ReciboJefeUsados__c;
                        }else if(ru.ValorReciboCliente__c != null && ru.ValorReciboCliente__c > 0){
                            sumaReciboJefeUsado = sumaReciboJefeUsado + ru.ValorReciboCliente__c;
                        }                    
                        if(ru.Valor_final__c != null && ru.Valor_final__c > 0){
                            sumaValorFinalSugerido = sumaValorFinalSugerido + ru.Valor_final__c;
                        }
                    }
                }
                System.debug(' ** total recibo jefe usado ** ' + sumaReciboJefeUsado);
                System.debug(' ** total valor final ** ' + sumaValorFinalSugerido);
                sumaMargenReal = ((sumaValorFinalSugerido - sumaReciboJefeUsado) / sumaReciboJefeUsado); 
                System.debug(' ** suma margen real ** ' + sumaMargenReal);
                Average = sumaMargenReal;
                if(reciboId != null && reciboId != ''){
                    if(recibo.ReciboJefeUsados__c > 0 && recibo.ReciboJefeUsados__c != null){
                        System.debug(' ** monto recibo jefe usado base, valor sugerido recibo ** ' + recibo.ReciboJefeUsados__c);
                        recibo.Valor_sugerido_de_recibo__c = recibo.ReciboJefeUsados__c;
                    }else if(recibo.ValorReciboCliente__c != null && recibo.ValorReciboCliente__c > 0){
                        System.debug(' ** monto valor avaluo base, valor sugerido recibo ** ' + recibo.ReciboJefeUsados__c);
                        recibo.Valor_sugerido_de_recibo__c = recibo.ValorReciboCliente__c;
                    }
                    if(recibo.ReciboJefeUsados__c > 0 && recibo.ReciboJefeUsados__c != null){
                        System.debug(' ** monto recibo jefe usado base, valor sugerido venta ** ' + recibo.ReciboJefeUsados__c);
                        recibo.Valor_Sugerido_Venta__c = recibo.ReciboJefeUsados__c * (1 + Average);
                    }else if(recibo.ValorReciboCliente__c != null && recibo.ValorReciboCliente__c > 0){
                        System.debug(' ** monto valor avaluo base, valor sugerido venta ** ' + recibo.ReciboJefeUsados__c);
                        recibo.Valor_Sugerido_Venta__c = recibo.ValorReciboCliente__c * (1 + Average);
                    }
                }else{
                    Date paramDate, paramDate2;
                    if(!ultimoRegistroCreado.isEmpty() && ultimoRegistroCreado.size() > 0){
                        paramDate = ultimoRegistroCreado[0].Fecha_de_recibo__c;
                        paramDate2 = paramDate.addMonths(-3);
                        System.debug(' ** fecha 1 ** ' + paramDate);
                        System.debug(' ** fecha  2 **  ' + paramDate2);
                        
                        List<ReciboUsado__c> listTemp = [SELECT Id, ValorReciboCliente__c, Fecha_de_recibo__c, Score_Motos__c, ReciboJefeUsados__c, Valor_final__c,
                                                            Ano__c
                                                            FROM ReciboUsado__c 
                                                            Where Marca__c =: recibo.Marca__c and Ano__c =: recibo.Ano__c and 
                                                                Modelo__c =: recibo.Modelo__c and Cilindraje__c =: recibo.Cilindraje__c and  
                                                                Segmento__c =: recibo.Segmento__c and Gama__c =: recibo.Gama__c and 
                                                                Fecha_de_recibo__c >= :paramDate2 AND Fecha_de_recibo__c <= :paramDate];
                        if(listTemp.isEmpty() && listTemp.size() == 0){
                            listTemp = [SELECT Id, ValorReciboCliente__c, Fecha_de_recibo__c, Score_Motos__c, ReciboJefeUsados__c, Valor_final__c,
                                                            Ano__c
                                                            FROM ReciboUsado__c 
                                                            Where Marca__c =: recibo.Marca__c and Ano__c =: recibo.Ano__c and 
                                                                Modelo__c =: recibo.Modelo__c and Cilindraje__c =: recibo.Cilindraje__c and  
                                                                Segmento__c =: recibo.Segmento__c and Gama__c =: recibo.Gama__c and 
                                                                Fecha_de_recibo__c >= :paramDate2 AND Fecha_de_recibo__c <= :paramDate];
                        }
                        if(listTemp.isEmpty() && listTemp.size() == 0){
                            listTemp = [SELECT Id, ValorReciboCliente__c, Fecha_de_recibo__c, Score_Motos__c, ReciboJefeUsados__c, Valor_final__c,
                                                            Ano__c
                                                            FROM ReciboUsado__c 
                                                            Where Marca__c =: recibo.Marca__c and Ano__c =: recibo.Ano__c and 
                                                                Modelo__c =: recibo.Modelo__c and Cilindraje__c =: recibo.Cilindraje__c and  
                                                                Segmento__c =: recibo.Segmento__c and Gama__c =: recibo.Gama__c and 
                                                                Fecha_de_recibo__c >= :paramDate2 AND Fecha_de_recibo__c <= :paramDate];
                        }
                        System.debug(' ** LISTA USADOS ** ' + listTemp);

                        recibo.Valor_sugerido_de_recibo__c = 0;
                        if(!listTemp.isEmpty() && listTemp.size() > 0){
                            Double montoDepreciacion = 0;
                            Double saldoInicial = 0;
                            Double valorAvaluoDepreciado = 0;
                            Double margen = 0;
                            Double sumMargen = 0;
                            Integer annoDiferencia = 0; 
                            Integer countTemp = 0;  
                            Integer countTemp2 = 0; 
                            Double margenUtilidadObjetivo = Double.valueOf(LABEL.MargenUtilidadObjetivoMoto);
                            
                            System.debug(' ** MARGEN UTILIDAD OBJETIVO ** ' + margenUtilidadObjetivo);
                            recibo.Score_Motos__c = 0;
                            sumaReciboJefeUsado = 0;
                            count = 0;
                            countTemp = 0;
                            for(ReciboUsado__c r : listTemp){
                                if(r.Valor_final__c != null && r.Valor_final__c > 0){
                                    if(r.ReciboJefeUsados__c != null && r.ReciboJefeUsados__c > 0){
                                        annoDiferencia = System.Date.today().year() - Integer.valueOf(r.Fecha_de_recibo__c.year());
                                        System.debug(' ** DIFERENCIA DE ANIOS ** ' + annoDiferencia);
                                        saldoInicial = r.ReciboJefeUsados__c;
                                        while(countTemp < annoDiferencia){
                                            System.debug(' ** SALDO INICIAL ** ' + saldoInicial);
                                            montoDepreciacion = saldoInicial * 0.10;
                                            System.debug(' ** MONTO DEPRECIACION ** ' + montoDepreciacion);
                                            saldoInicial = saldoInicial - montoDepreciacion;
                                            System.debug(' ** SALDO INICIAL ** ' + saldoInicial);
                                            countTemp =  countTemp + 1;
                                        }
                                        countTemp = 0;
                                        count = count + 1;
                                        valorAvaluoDepreciado = valorAvaluoDepreciado + saldoInicial;
                                        System.debug(' ** VALOR AVALUO DEPRECIADO ** ' + valorAvaluoDepreciado);
                                        margen = (r.Valor_final__c / r.ReciboJefeUsados__c) - 1;
                                        System.debug(' ** MARGEN ** ' + margen);
                                        sumMargen = sumMargen + margen;
                                        System.debug(' ** SUMATORIA MARGEN ** ' + sumMargen);
                                        if(r.Score_Motos__c != null){
                                            recibo.Score_Motos__c = recibo.Score_Motos__c + r.Score_Motos__c;
                                        }
                                        countTemp2 = countTemp2 + 1;
                                    }else if(r.ValorReciboCliente__c != null && r.ValorReciboCliente__c > 0){
                                        annoDiferencia = System.Date.today().year() - Integer.valueOf(r.Fecha_de_recibo__c.year());
                                        System.debug(' ** DIFERENCIA DE ANIOS ** ' + annoDiferencia);
                                        saldoInicial = r.ValorReciboCliente__c;
                                        while(countTemp < annoDiferencia){
                                            System.debug(' ** SALDO INICIAL ** ' + saldoInicial);
                                            montoDepreciacion = saldoInicial * 0.10;
                                            System.debug(' ** MONTO DEPRECIACION ** ' + montoDepreciacion);
                                            saldoInicial = saldoInicial - montoDepreciacion;
                                            System.debug(' ** SALDO INICIAL ** ' + saldoInicial);
                                            countTemp =  countTemp + 1;
                                        }
                                        countTemp = 0;
                                        count = count + 1;
                                        valorAvaluoDepreciado = valorAvaluoDepreciado + saldoInicial;
                                        System.debug(' ** VALOR AVALUO DEPRECIADO ** ' + valorAvaluoDepreciado);
                                        margen = (r.Valor_final__c / r.ValorReciboCliente__c) - 1;
                                        System.debug(' ** MARGEN ** ' + margen);
                                        sumMargen = sumMargen + margen;
                                        System.debug(' ** SUMATORIA MARGEN ** ' + sumMargen);
                                        if(r.Score_Motos__c != null){
                                            recibo.Score_Motos__c = recibo.Score_Motos__c + r.Score_Motos__c;
                                        }
                                        countTemp2 = countTemp2 + 1;
                                    }
                                }
                            }
                            sumMargen = sumMargen / countTemp2;
                            System.debug(' ** PROMEDIO MARGEN ** ' + sumMargen);
                            recibo.Valor_sugerido_de_recibo__c = valorAvaluoDepreciado / countTemp2;
                            if(sumoAnio){
                                recibo.Valor_sugerido_de_recibo__c = recibo.Valor_sugerido_de_recibo__c * 0.9;
                            }
                            if(restoAnio){
                                recibo.Valor_sugerido_de_recibo__c = recibo.Valor_sugerido_de_recibo__c * 1.10;
                            }
                            if(sumMargen < margenUtilidadObjetivo){
                                recibo.Valor_Sugerido_Venta__c = recibo.Valor_sugerido_de_recibo__c * (1 + margenUtilidadObjetivo);
                            }else{
                                recibo.Valor_Sugerido_Venta__c = recibo.Valor_sugerido_de_recibo__c * (1 + sumMargen);
                            } 
                            recibo.Score_Motos__c = recibo.Score_Motos__c / countTemp2;
                            if(recibo.Score_Motos__c <= 300){
                                recibo.Bucket_Score__c = '1-300';
                            }else if(recibo.Score_Motos__c >= 301 && recibo.Score__c <= 600){
                                recibo.Bucket_Score__c = '301-600';
                            }else{
                                recibo.Bucket_Score__c = '601-999';
                            }
                        }
                    }
                }
            }
        }
    }
    
    public boolean showAPIResponse {get;set;}
    public boolean showAPIDataResponse {get;set;}
    public ResponseWrapper apiResponse {get;set;}
    public DataWrapper data {get;set;}
    public String marcaValue {get;set;}
    public String lineaValue {get;set;}
    public String modelValue {get;set;}
    public String transmissionValue {get;set;}
    public String combustibleValue {get;set;}
    public String estiloValue {get;set;}
    public List<SelectOption> lstLinea {get;set;}

    public List<SelectOption> getMarcaValues() {
        List<SelectOption> marcaList = new List<SelectOption>();
        marcaList.add(new SelectOption('--None--','--None--'));
        Set<String> allValues = new Set<String>();
        for(AggregateResult rec :  [select Marca__c from Marca_Modelo__c where Marca__c != null group by Marca__c order by Marca__c])
        {
                String macraVal = (String)rec.get('Marca__c');
               if(!allValues.contains(macraVal))
               {
                    allValues.add(macraVal);
                    marcaList.add(new SelectOption(macraVal,macraVal));
               }
        }
        
        return marcaList;
    }

    public void  updateLineaList() {
        lstLinea = new List<SelectOption>();
        lstLinea.add(new SelectOption('--None--','--None--'));
        Set<String> lineas = new Set<String>();
        for(AggregateResult rec :  [select Linea__c from Marca_Modelo__c where Marca__c =:marcaValue and Linea__c != null group by Linea__c order by Linea__c])
        {
            String lineaVal = (String)rec.get('Linea__c');
            if(!lineas.contains(lineaVal))
            {
                lineas.add(lineaVal);
                lstLinea.add(new SelectOption(lineaVal,lineaVal));
            }
        }
    }

    public List<SelectOption>  getModelValues() {
        List<SelectOption> lstModelos = new List<SelectOption>();
        lstModelos.add(new SelectOption('--None--','--None--'));
        Set<String> allValues = new Set<String>();
        for(AggregateResult rec :  [select Modelo__c from Marca_Modelo__c where Modelo__c != null group by Modelo__c order by Modelo__c desc])
        {
            String modeloVal = (String)rec.get('Modelo__c');
            if(!allValues.contains(modeloVal))
            {
                allValues.add(modeloVal);
                lstModelos.add(new SelectOption(modeloVal,modeloVal));
            }
        }
        return lstModelos;   
    }

    public List<SelectOption>  getTransmissionValues() {
        List<SelectOption> lstTransmission = new List<SelectOption>();
        lstTransmission.add(new SelectOption('--None--','--None--'));
        Set<String> allValues = new Set<String>();
        for(AggregateResult rec :  [select Transmission__c from Marca_Modelo__c where Transmission__c != null group by Transmission__c order by Transmission__c])
        {
            String transmissionVal = (String)rec.get('Transmission__c'); 	
            if(!allValues.contains(transmissionVal))
            {
                allValues.add(transmissionVal);
                lstTransmission.add(new SelectOption(transmissionVal,transmissionVal));
            }
        }
        return lstTransmission;   
    }

    public List<SelectOption>  getCombustibleValues() {
        List<SelectOption> lstCombustible = new List<SelectOption>();
        lstCombustible.add(new SelectOption('--None--','--None--'));
        Set<String> allValues = new Set<String>();

        for(AggregateResult rec :  [select Combustible__c from Marca_Modelo__c where Combustible__c != null group by Combustible__c order by Combustible__c])
        {
            String combustibleVal = (String)rec.get('Combustible__c'); 	
            if(!allValues.contains(combustibleVal))
            {
                allValues.add(combustibleVal);
                lstCombustible.add(new SelectOption(combustibleVal,combustibleVal));
            }
        }
        return lstCombustible;   
    }

    public List<SelectOption> getEstiloValues() {
        List<SelectOption> lstEstilo = new List<SelectOption>();
        lstEstilo.add(new SelectOption('--None--','--None--'));
        Set<String> allValues = new Set<String>();
        for(AggregateResult rec :  [select Estilo__c from Marca_Modelo__c where Estilo__c != null group by Estilo__c order by Estilo__c])
        {
            String estiloVal = (String)rec.get('Estilo__c');
            if(!allValues.contains(estiloVal))
            {
                allValues.add(estiloVal);
                lstEstilo.add(new SelectOption(estiloVal,estiloVal));
            }
        }
        return lstEstilo;
    }

    public void getAPIValues()
    {
        showAPIResponse = true;
        showAPIDataResponse = false;
        apiResponse = new ResponseWrapper();
        String url = 'http://143.208.181.92:5185/consultaController.ashx?';
        
        String parameters = '';
        
        if(marcaValue != null)
            parameters += 'marca='+EncodingUtil.urlEncode(marcaValue, 'UTF-8');
        
        if(lineaValue != null)
            parameters += '&linea='+EncodingUtil.urlEncode(lineaValue, 'UTF-8');
        
        if(modelValue != null)    
            parameters += '&modelo='+EncodingUtil.urlEncode(modelValue, 'UTF-8');
        
        if(combustibleValue != null)
            parameters += '&combustible='+EncodingUtil.urlEncode(combustibleValue, 'UTF-8');
        
        if(transmissionValue != null)
            parameters += '&transmision='+EncodingUtil.urlEncode(transmissionValue, 'UTF-8');

        if(estiloValue != null)
        parameters += '&estilo='+EncodingUtil.urlEncode(estiloValue, 'UTF-8');
        
        Http http = new Http();
    
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url+parameters);
        req.setMethod('GET');
        req.setTimeout(120000);

        try 
        {
            HttpResponse res =  http.send(req);
            System.debug( res.getBody());
            
            apiResponse = (ResponseWrapper) JSON.deserialize(res.getBody(), ResponseWrapper.class);
            if(apiResponse.code == '00')
            {
                Decimal descriptionValue = Decimal.ValueOf(apiResponse.description); //Integer.ValueOf(apiResponse.description);
                String descriptionValueCurrency = '₡' + String.valueOf(descriptionValue.format());
                apiResponse.description = descriptionValueCurrency.replace(',', '|').replace('.', ',').replace('|', '.');

                Decimal descriptionDollarValue = Decimal.ValueOf(apiResponse.descriptionDollar); //Integer.ValueOf(apiResponse.description);
                String descriptionDollarValueCurrency = '$' + String.valueOf(descriptionDollarValue.format());
                apiResponse.descriptionDollar = descriptionDollarValueCurrency.replace(',', '|').replace('.', ',').replace('|', '.');
                if(apiResponse.description == '₡0' || apiResponse.description == '₡0.0' || apiResponse.description == '₡')
                {
                    showMessage = 'No se encontraron resultados';
                }
                else
                {
                    showMessage = 'Monto Colones: ' + apiResponse.description + '  | Monto Dólares: ' + apiResponse.descriptionDollar;
                }
           }
           else
           {
                apiResponse.description = 'Esta marca o modelo de vehículo está sujeto a valoración física';
           }
        }
        catch(System.CalloutException e) {
            System.debug('Callout error: '+ e); 
        }
    }
    
    
    public class ResponseWrapper
    {
        public String code {get;set;}
        public String description {get;set;}
        public String descriptionDollar {get;set;}
    }
    
    
    public void getAPIListValues()
    {
        showAPIResponse = false;
        showAPIDataResponse = true;
        
        String url = 'http://143.208.181.92:5185/consultaAutosController.ashx';
        
        Http http = new Http();
    
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('GET');
    	req.setTimeout(120000);
        try 
        {
            HttpResponse res =  http.send(req);
            System.debug(':::::'+ res.getBody());
            
            data = (DataWrapper) JSON.deserialize(res.getBody(), DataWrapper.class);
            
            //List<ReciboUsado__c> reciboList = new List<ReciboUsado__c>();
            List<Marca_Modelo__c> lstMarcaModel = new List<Marca_Modelo__c>();
            DeleteRecordsBatch.startExecution([select id from Marca_Modelo__c]);
            if(data != null && data.recibos.size() > 0)
            {
                for(ListResponseWrapper rec : data.recibos)
                {
                    /*
                    reciboList.add(new ReciboUsado__c(Name = rec.recibido,
                                                      Marca__c = rec.marca,
                                                      Ano__c = rec.modelo,
                                                      Modelo__c = rec.linea,
                                                      Combustible__c = rec.combustible,
                                                      Trasmision__c = rec.transmision));
                    */
                    lstMarcaModel.add(new Marca_Modelo__c(
                                                    Marca__c = rec.marca, 
                                                    Linea__c = rec.linea,
                                                    Modelo__c = rec.modelo,
                                                    Transmission__c = rec.transmision,
                                                    Combustible__c = rec.combustible,
                                                    Estilo__c= rec.estilo));
                }
                
                if(lstMarcaModel.size() > 0)
                {
                    //insert reciboList;
                    InsertRecordsBatch.startExecution(lstMarcaModel);
                }
                   
                apexpages.addMessage(new ApexPages.message(Apexpages.Severity.CONFIRM, lstMarcaModel.size() + ' marca modelo records created successfully.'));
            }
        }
        catch(Exception e) {
            apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR, e.getMessage()));
            System.debug('Callout error: '+ e); 
        }
    }
    
    public class DataWrapper
    {
        public List<ListResponseWrapper> recibos {get;set;}
    }
    
    public class ListResponseWrapper
    {
        public String recibido {get;set;}
        public String marca {get;set;}
        public String modelo {get;set;}
        public String linea {get;set;}
        public String combustible {get;set;}
        public String transmision {get;set;}
        public String estilo {get;set;}
    }
}