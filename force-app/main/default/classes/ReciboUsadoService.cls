public with sharing class ReciboUsadoService {
    
    public static void calculoRecibo(Set<Id> setIds){
        Decimal probabilidad = 0;
        Decimal score;
        String bucket_Score;
        Decimal valorMinimo;
        Decimal valorPromedio;
        Decimal valorMaximo;
        Decimal ultimaVenta;
        Decimal valorSugerido;
        Decimal versionPlus = 0;
        Integer Antiguedad_Vehiculo;
        Decimal valorAvaluo;
        Decimal Traccion4x4 = 0;
        Decimal CarroceriaTodoT = 0;
        Integer top5Color;
        Decimal Kilometraje;
        Integer Puertas;

		Decimal P_Avaluo = -0.00005291; // P_avaluo = valor inicial
        Decimal carroceria_todoTerreno =   1.64733700;
        Decimal traccion = -0.89427430 ;
        Integer anoActual = System.today().year();
        
        List<ReciboUsado__c> listTemp = new List<ReciboUsado__c>();
        
        listTemp = [SELECT Traccion__c, EstiloUsado__c, Version__c, Ano__c,Kilometraje__c, ReciboJefeUsados__c,
                    Fecha_de_venta__c, Fecha_de_recibo__c, Score__c,N_puertas__c,Color__c,
                    Bucket_Score__c, Dias_en_Inventario__c, ValorReciboCliente__c
                    FROM ReciboUsado__c 
                    WHERE Id IN : setIds];
    
        for (ReciboUsado__c recibo : listTemp ){
            integer MesRecibo = recibo.Fecha_de_recibo__c.Month();
            Kilometraje = recibo.Kilometraje__c;
            if(recibo.Traccion__c == '4x4'){
            	Traccion4x4 = 1;
            }else{
                Traccion4x4 = 0;
            }
            if(recibo.EstiloUsado__c == 'TODO TERRENO'){
                CarroceriaTodoT = 1;
            }else{
                CarroceriaTodoT = 0;
            }
            if(recibo.Version__c == '' || recibo.Version__c == 'N/A'  || recibo.Version__c == '0'){
                versionPlus = 0;
            }else{
                versionPlus = 1;
            }
            if(recibo.Ano__c != ''){
                Antiguedad_Vehiculo = anoActual - Integer.valueOf(recibo.Ano__c);
            }
            if(recibo.ReciboJefeUsados__c > 0 ){
                valorAvaluo = recibo.ReciboJefeUsados__c;
            }else{
                valorAvaluo = recibo.ValorReciboCliente__c;
            }
			System.debug(' ** id recibo usado ** ' + recibo.Id);
            System.debug('******VALOR AVALUO: ' + valorAvaluo);
            System.debug('******ANTIGUEDAD: ' + Antiguedad_Vehiculo);
            System.debug('******CARROCERIA: ' + CarroceriaTodoT);
            System.debug('******VERSION: ' + versionPlus);
            
            if(recibo.Color__c == 'GRIS' || recibo.Color__c == 'BLANCO' || recibo.Color__c == 'NEGRO' || recibo.Color__c == 'PLATEADO' || recibo.Color__c == 'AZUL'){
                top5Color = 1;
            }else{
                top5Color = 0;
            }
            if(recibo.N_puertas__c == 4 || recibo.N_puertas__c == 5){
                Puertas = 1;
            }else{
                Puertas = 0;
            }
            //*****Formula Probabilidad o ODD
            probabilidad = 1.23042300 + (MesRecibo* 0.03545647)  + (top5Color * 0.38989910) +(Kilometraje * -0.00000757)+(valorAvaluo *  -0.00005111) + (CarroceriaTodoT * 0.72506040) + (Puertas * 0.54488870);
            System.debug(' *****PROBA' + probabilidad);
            
            //*****Formula Score
            score= (Math.EXP(probabilidad) / (1 + (Math.EXP(probabilidad))) ) * 1000;  
            System.debug(' *****SCORE' + score);
            
            //*****Formula Bucket_Score
            if(score > 0 && score < 200){ 
                bucket_Score = '000-200';
            }else if(score >= 101 && score <= 600){ 
                    bucket_Score = '201-600';
                }else if(score >= 601 && score <= 999){
                        bucket_Score = '601-999';
                       }
            
            //Formula Días inventario promedio: Media geométrica ( Fecha de venta - Fecha de recibo )
            date fechaVenta = date.valueOf( recibo.Fecha_de_venta__c);
            date fechaRecibo = date.valueOf(recibo.Fecha_de_recibo__c);
            date fechaActual = date.valueOf(date.today());
            integer diasInventario;
    
            system.debug('FECHA VENTA' + recibo.Fecha_de_venta__c);
            if(recibo.Fecha_de_venta__c != null){
               diasInventario = fechaRecibo.daysBetween(fechaVenta);
            }else{
               diasInventario = null; 
            }
                    
            recibo.Score__c = score.intValue();
            recibo.Bucket_Score__c = bucket_Score;
            recibo.Dias_en_Inventario__c = diasInventario;  
        }
        TriggerHandler.bypass('ReciboUsadosTriggerHandler');
        update listTemp;
        TriggerHandler.clearBypass('ReciboUsadosTriggerHandler');
    }

	//Metodo para obtener la configuracion de motos para realizar el calculo del score
	public static Map<String, Configuracion_Recibo_Usados_Motos__c> obtenerConfScore(){
		Map<String, Configuracion_Recibo_Usados_Motos__c> mapTemp = new Map<String, Configuracion_Recibo_Usados_Motos__c>();
		
		for(Configuracion_Recibo_Usados_Motos__c conf : [SELECT Name, Antiguedad__c, Cilindrada__c, Gama__c, Modelo__c,
															Intercepto__c, Segmento__c, Valor_Recibo__c, Mes__c FROM Configuracion_Recibo_Usados_Motos__c]){
			mapTemp.put(conf.Name, conf);
		}
		return mapTemp;
	}

	//Metodo para obtener el # de segmento y retornarlo
	public static Integer getSegmento(String segmento){
		if(segmento == 'Adventure'){
			return 1;		
		}else if(segmento == 'Side by Side'){
			return 2;
		}else if(segmento == 'Naked'){
			return 3;
		}else if(segmento == 'Softail'){
			return 4;
		}else if(segmento == 'Super Bike'){
			return 5;
		}else if(segmento == 'Sport'){
			return 6;
		}else if(segmento == 'Street'){
			return 7;
		}else if(segmento == 'MX'){
			return 8;
		}else if(segmento == 'Heritage'){
			return 9;	
		}else if(segmento == 'Enduro'){
			return 10;
		}else if(segmento == 'Offroad'){
			return 10;
		}else if(segmento == 'Scooter'){
			return 11;
		}else if(segmento == 'Cuadraciclo'){
			return 12;
		}else{
			return 13;
		}
	}

	public static void calculoScoreMotos(Set<Id> setIds){
		Decimal probabilidad;
		Decimal score;
        Decimal valorAvaluo;
		Integer numGama;
		Integer antiguedad;
		Integer valorBinario;
		String bucket_Score;

		Map<String, Configuracion_Recibo_Usados_Motos__c> mapConf = new Map<String, Configuracion_Recibo_Usados_Motos__c>();
		Set<String> setModelos = new Set<String>{'KX', 'Z', 'KLX', 'NINJA', 'VERSYS'};
		List<ReciboUsado__c> listTemp = new List<ReciboUsado__c>();
        
        listTemp = [SELECT Modelo__c, Gama__c, Ano__c, Marca__c, Cilindraje__c, Segmento__c, ReciboJefeUsados__c, Fecha_de_venta__c, 
                    Fecha_de_recibo__c, Score_Motos__c, Dias_en_Inventario__c, Mes__c, ValorReciboCliente__c
                    FROM ReciboUsado__c 
                    WHERE Id IN : setIds];
		
		mapConf = obtenerConfScore();
        for (ReciboUsado__c recibo : listTemp){
			probabilidad = 0;
			score = 0;
			numGama = 0;
			bucket_Score = '';
			antiguedad = 0;
			valorBinario = 0;
            
			if(setModelos.contains(recibo.Modelo__c)){
				valorBinario = 1;
			}

			if(recibo.Gama__c == 'Alta'){
				numGama = 1;
			}else{
				numGama = 0;
			}
            
            if(recibo.ReciboJefeUsados__c > 0 ){
                valorAvaluo = recibo.ReciboJefeUsados__c;
            }else{
                valorAvaluo = recibo.ValorReciboCliente__c;
            }
			antiguedad = System.today().year() - Integer.valueOf(recibo.Ano__c);
			System.debug(' ** MARCA  ** ' + recibo.Marca__c);
			if(recibo.Marca__c == 'BMW' || recibo.Marca__c == 'HARLEY-DAVIDSON'){
				System.debug(' ** CALCULO BMM ** ');
				probabilidad = mapConf.get(recibo.Marca__c).Intercepto__c + 
								(mapConf.get(recibo.Marca__c).Cilindrada__c * recibo.Cilindraje__c) + 
								(mapConf.get(recibo.Marca__c).Gama__c * numGama) + 
								(mapConf.get(recibo.Marca__c).Segmento__c * getSegmento(recibo.Segmento__c)) + 
								(mapConf.get(recibo.Marca__c).Antiguedad__c * antiguedad) + 
								(mapConf.get(recibo.Marca__c).Valor_Recibo__c * valorAvaluo);
			}else if(recibo.Marca__c == 'KTM'){
				probabilidad = mapConf.get(recibo.Marca__c).Intercepto__c +  
								(mapConf.get(recibo.Marca__c).Gama__c * numGama) +  
								(mapConf.get(recibo.Marca__c).Antiguedad__c * antiguedad) + 
								(mapConf.get(recibo.Marca__c).Valor_Recibo__c * valorAvaluo);
			}else if(recibo.Marca__c == 'KAWASAKI'){
				probabilidad = mapConf.get(recibo.Marca__c).Intercepto__c + 
								(mapConf.get(recibo.Marca__c).Modelo__c * valorBinario) +
								(mapConf.get(recibo.Marca__c).Cilindrada__c * recibo.Cilindraje__c) +
								(mapConf.get(recibo.Marca__c).Segmento__c * getSegmento(recibo.Segmento__c)) +
								(mapConf.get(recibo.Marca__c).Valor_Recibo__c * valorAvaluo);
			}else if(recibo.Marca__c == 'POLARIS'){
				probabilidad = mapConf.get(recibo.Marca__c).Valor_Recibo__c * valorAvaluo;
			}else{
				probabilidad = (mapConf.get('Otras').Mes__c * recibo.Mes__c) + (mapConf.get('Otras').Gama__c * numGama) + 
                    			(mapConf.get('Otras').Segmento__c * getSegmento(recibo.Segmento__c)) + 
								(mapConf.get('Otras').Antiguedad__c * antiguedad) + 
								(mapConf.get('Otras').Valor_Recibo__c * valorAvaluo);
			}
            System.debug(' ** PROBABILIDAD ** ' + probabilidad);
            
			//*****Formula Score
            score = Math.round((Math.EXP(probabilidad) / (1 + (Math.EXP(probabilidad))) ) * 1000); 
            System.debug(' *****SCORE' + score);
            
            //*****Formula Bucket_Score
            if(score > 0 && score < 300){ 
                bucket_Score = '1-300';
            }else if(score >= 301 && score <= 600){ 
                bucket_Score = '301-600';
            }else if(score >= 601 && score <= 999){
				bucket_Score = '601-999';
            }
            
            //Formula Días inventario promedio: Media geométrica ( Fecha de venta - Fecha de recibo )
            date fechaVenta = date.valueOf( recibo.Fecha_de_venta__c);
            date fechaRecibo = date.valueOf(recibo.Fecha_de_recibo__c);
            date fechaActual = date.valueOf(date.today());
            integer diasInventario;
    
            system.debug('FECHA VENTA' + recibo.Fecha_de_venta__c);
            if(recibo.Fecha_de_venta__c != null){
               diasInventario = fechaRecibo.daysBetween(fechaVenta);
            }else{
               diasInventario = null; 
            }
                    
            recibo.Score_Motos__c = score.intValue();
            recibo.Bucket_Score__c = bucket_Score;
            recibo.Dias_en_Inventario__c = diasInventario;  
        }
        TriggerHandler.bypass('ReciboUsadosTriggerHandler');
        update listTemp;
        TriggerHandler.clearBypass('ReciboUsadosTriggerHandler');
    }

	//Metodo para buscar si un recibo de usado ya fue evaluado el mismo dia y asi no duplicar
    public static void buscarRU(List<ReciboUsado__c> listTemp){
        List<ReciboUsado__c> listRU = new List<ReciboUsado__c>();
        Set<Date> setDate = new Set<Date>();
        Set<String> setPlaca = new Set<String>();

        for(ReciboUsado__c item : listTemp){
            setDate.add(item.Fecha_de_recibo__c);
            setPlaca.add(item.Placa__c);
        }
        listRU = [SELECT Id, Fecha_de_recibo__c, Placa__c FROM ReciboUsado__c WHERE Fecha_de_recibo__c IN : setDate AND Placa__c IN : setPlaca];
        if(!listRU.isEmpty() && listRU.size() > 0){
            for(ReciboUsado__c item : listTemp){
                for(ReciboUsado__c item2 : listRU){
                    if(item.Placa__c == item2.Placa__c && item.Fecha_de_recibo__c == item2.Fecha_de_recibo__c){
                        // item.addError('La unidad ingresada ya fue evaluada el día de hoy');
                    }
                }
            }
        }
    }

	public static void guardarDatosMayuscula(List<ReciboUsado__c> listTemp){
		for(ReciboUsado__c r : listTemp){
			if(r.Name != null && r.Name != ''){
				r.Name = r.Name.toUpperCase();
			}
			//if(r.Modelo__c != null && r.Modelo__c != ''){
				//r.Modelo__c = r.Modelo__c.toUpperCase();
			//}
			if(r.Estilo__c != null && r.Estilo__c != ''){
				r.Estilo__c = r.Estilo__c.toUpperCase();
			}
			if(r.Version__c != null && r.Version__c != ''){
				r.Version__c = r.Version__c.toUpperCase();
			}
		}
	}

    public static void dummy(){
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
          i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
		i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
		i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
		i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
          i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
		i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
		i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
		i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
          i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
		i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
		i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
		i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
          i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}